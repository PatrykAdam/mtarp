--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local workshop = {}

function workshop.cancelRepair(vehicle)
	if isElement(vehicle) then
		local owner, mechanic = getElementData(vehicle, "vehicle:repairOwner"), getElementData(vehicle, "vehicle:repairMechanic")

		if isElement(owner) then
			exports.sarp_notify:addNotify(owner, "Naprawa została anulowana, gracz zbyt mocno się oddalił bądź wyszedł z gry.")
		end

		if isElement(mechanic) then
			exports.sarp_notify:addNotify(mechanic, "Naprawa została anulowana, gracz zbyt mocno się oddalił bądź wyszedł z gry.")
		end

		removeElementData( vehicle, "vehicle:repairTime" )
		removeElementData( vehicle, "vehicle:repairMechanic" )
		removeElementData( vehicle, "vehicle:repairOwner" )
		removeElementData( vehicle, "vehicle:repairInfo" )
		removeElementData( vehicle, "vehicle:repairType" )
	end
end

addEvent('cancelRepair', true)
addEventHandler( 'cancelRepair', root, workshop.cancelRepair )

function workshop.repairFinish(vehicle)
	local owner = getElementData(vehicle, "vehicle:repairOwner")
	local repair = getElementData(vehicle, "vehicle:repairType")
	local mechanic = getElementData(vehicle, "vehicle:repairMechanic")
	if not (isElement(vehicle) and isElement(owner) and isElement(mechanic)) then return end

	local info = getElementData(vehicle, "vehicle:repairInfo")

	if info[1] == 1 then
		if getElementData(owner, "player:bank") < info[2] then
			return exports.sarp_notify:addNotify(mechanic, "Klient nie posiada wystarczającej ilości gotówki, usługa została anulowana.")
		end

		exports.sarp_main:givePlayerCash(owner, - info[2])
	elseif payment == 2 then
		if getElementData(owner, "player:bank") < info[2] then
			return exports.sarp_notify:addNotify(mechanic, "Klient nie posiada wystarczającej ilości gotówki, usługa została anulowana.")
		end
		setElementData(owner, "player:bank", getElementData(owner, "player:bank") - info[2])
	end

	giveGroupCash(info[3], info[2])

	if repair == 1 then
		for i = 0, 6 do
			if getVehiclePanelState( vehicle, i ) ~= 0 then
				setVehiclePanelState( vehicle, i, 0 )
			end
		end

		for i = 0, 5 do
			if getVehicleDoorState( vehicle, i ) ~= 0 and getVehicleDoorState( vehicle, i ) ~= 1 then
				setVehicleDoorState( vehicle, i, 0 )
			end
		end

		for i = 0, 3 do
			if getVehicleLightState( vehicle, i ) ~= 0 then
				setVehicleLightState( vehicle, i, 0 )
			end
		end

		setVehicleWheelStates( vehicle, 0, 0, 0, 0 )
	elseif repair == 2 then
		setElementHealth( vehicle, 1000.0 )
	elseif repair == 3 then
		local itemInfo = exports.sarp_items:getItemData( info[4], {"ownerType", "ownerID", "id"})

		if not itemInfo or itemInfo.ownerType ~= 1 or itemInfo.ownerID ~= getElementData(mechanic, "player:id") then
			return exports.sarp_notify:addNotify(mechanic, "Montaż anulowano, nie posiadasz przy sobie przedmiotu.")
		end

		local vX, vY, vZ = getElementPosition( vehicle )
		local rX, rY, rZ = getElementRotation( vehicle )
		local interior = getElementInterior( vehicle )
		local dimension = getElementDimension( vehicle )

		exports.sarp_items:setItemData(itemInfo.id, {ownerType = 4, ownerID = getElementData(vehicle, "vehicle:id")}, nil, "owner")
		triggerEvent( 'updateVehicleTuning', root, getElementData(vehicle, "vehicle:id"))
		vehicle = exports.sarp_vehicles:setVehicleSpawnState(getElementData(vehicle, "vehicle:id"), 'respawn')
		setElementPosition( vehicle, vX, vY, vZ )
		setElementRotation( vehicle, rX, rY, rZ )
		setElementInterior( vehicle, interior )
		setElementDimension( vehicle, dimension )
	elseif repair == 4 then
		local tuning = getElementData( vehicle, "vehicle:tuning")
		local vX, vY, vZ = getElementPosition( vehicle )
		local rX, rY, rZ = getElementRotation( vehicle )
		local interior = getElementInterior( vehicle )
		local dimension = getElementDimension( vehicle )

		exports.sarp_items:setItemData(tuning[info[4]].id, {ownerType = 1, ownerID = getElementData(owner, "player:id")}, nil, "owner")
		triggerEvent( 'updateVehicleTuning', root, getElementData(vehicle, "vehicle:id"))
		vehicle = exports.sarp_vehicles:setVehicleSpawnState(getElementData(vehicle, "vehicle:id"), 'respawn')
		setElementPosition( vehicle, vX, vY, vZ )
		setElementRotation( vehicle, rX, rY, rZ )
		setElementInterior( vehicle, interior )
		setElementDimension( vehicle, dimension )
	end
	triggerEvent('saveVehicle', root, getElementData(vehicle, "vehicle:id"), 'health')

	if getElementData( vehicle, "vehicle:manual") == false then
		setElementFrozen( vehicle, false )
	end

	exports.sarp_notify:addNotify(mechanic, "Usługa została zakończona.")
end

addEvent('repairFinish', true)
addEventHandler( 'repairFinish', root, workshop.repairFinish )