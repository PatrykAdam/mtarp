--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local group = {}

function group.spawn(vehid, slot)
	if not vehiclesData[vehid].ownerType == 2 or not isVehicleOwner(source, vehid) then
		return exports.sarp_notify(source, "Nie posiadasz uprawnień do zarządzania pojazdami.")
	end

	if vehiclesData[vehid].mtaID then
		setVehicleSpawnState(vehid, false)
		exports.sarp_notify:addNotify(source, "Pojazd został odspawnowany.", 'success', 1000)
	else
		setVehicleSpawnState(vehid, true)
		exports.sarp_notify:addNotify(source, "Pojazd został zespawnowany.", 'success', 1000)
	end
	triggerEvent( "group:vehicle", source, slot )
end

addEvent("group:spawnvehicle", true)
addEventHandler( "group:spawnvehicle", root, group.spawn )

function group.vehicle(slot)
	local groupid = getElementData(source, "group_"..slot..":id")
	if not groupid then return exports.sarp_notify:addNotify(source, "Nie posiadasz grupy na tym slocie.") end
	local vehicle = {}
	for i, v in pairs(vehiclesData) do
		if v and vehiclesData[i].ownerID == groupid and vehiclesData[i].ownerType == 2 then
			table.insert(vehicle, vehiclesData[i])
		end
	end
	return triggerClientEvent( "group:showvehicle", source, vehicle, slot )
end

addEvent("group:vehicle", true)
addEventHandler( "group:vehicle", root, group.vehicle)

function group.blockSubmit(informaction)
	if isElement(informaction[1]) then
		local vehUID = getVehicleUID(informaction[1])
		setElementData( informaction[1], "vehicle:policeBlock", informaction[2])
		vehiclesData[vehUID].policeBlock = informaction[2]
		local vX, vY, vZ = getElementPosition( informaction[1] )
		local rX, rY, rZ = getElementRotation( informaction[1] )
		local vw, interior = getElementDimension( informaction[1] ), getElementInterior( informaction[1] )
		vehiclesData[vehUID].posX = vX
		vehiclesData[vehUID].posY = vY
		vehiclesData[vehUID].posZ = vZ
		vehiclesData[vehUID].rotX = rX
		vehiclesData[vehUID].rotY = rY
		vehiclesData[vehUID].rotZ = rZ
		vehiclesData[vehUID].dimension = vw
		vehiclesData[vehUID].interior = interior
		setVehicleSpawnState(vehUID, false)
		setVehicleSpawnState(vehUID, true)
		saveVehicle(vehUID, 'pos')
		saveVehicle(vehUID, 'other')
	
		exports.sarp_notify:addNotify(source, "Blokada na koła została nałożona.")
	end
end

addEvent("blockSubmit", true)
addEventHandler( "blockSubmit", root, group.blockSubmit )