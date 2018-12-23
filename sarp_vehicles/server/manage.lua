--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local vehicles = {}

function vehicles.newVehicleURL(vehUID, url)
	if not isElement(vehiclesData[vehUID].mtaID) then return end
	if not isVehicleOwner(source, vehUID, false) then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do tego pojazdu.")
	end

	setElementData(vehiclesData[vehUID].mtaID, "vehicle:url", url)
	saveVehicle(vehUID, "other")

	for i, v in pairs(getVehicleOccupants( vehiclesData[vehUID].mtaID )) do
		triggerClientEvent(v, "updateVehicleURL", v, url)
	end
end

addEvent('newVehicleURL', true)
addEventHandler( 'newVehicleURL', root, vehicles.newVehicleURL )

function vehicles.register(uid)
	vehiclesData[uid].registered = 1

	local registration
	registration = string.format('LS%05d', uid)

	vehiclesData[uid].plate = registration
	saveVehicle(uid, 'other')

	if isElement(vehiclesData[uid].mtaID) then
		setVehicleSpawnState(uid, false)
		setVehicleSpawnState(uid, true)
	end
end

addEvent('registerVehicle', true)
addEventHandler( 'registerVehicle', root, vehicles.register )

function vehicles.tuning(id)
	local tuning = vehiclesData[id].tuning

	if #tuning == 0 then
		return exports.sarp_notify:addNotify(source, "Ten pojazd nie posiada żadnego dodatku.")
	end

	triggerClientEvent( source, "vehicleTuning", source, vehiclesData[id].model, tuning )
end

addEvent('vehicleTuning', true)
addEventHandler( 'vehicleTuning', root, vehicles.tuning )

function vehicles.show(playerid, update)
	local playerVehicle = getPlayerVehicles(playerid)

	if #playerVehicle == 0 then return exports.sarp_notify:addNotify(playerid, "Nie posiadasz żadnego pojazdu.") end

	return triggerClientEvent( "playerVehicle", playerid, playerVehicle, update )
end

function vehicles.spawn(vehid)
	if not (vehiclesData[vehid].ownerType == 1 or vehiclesData[vehid].ownerID == getElementData(source, "player:id")) then
		return exports.sarp_notify:addNotify(source, "Ten pojazd nie należy już do Ciebie!")
	end

	if vehiclesData[vehid].mtaID then
		setVehicleSpawnState(vehid, false)
		exports.sarp_notify:addNotify(source, "Pojazd został odspawnowany.")
	else
		setVehicleSpawnState(vehid, true)
		exports.sarp_notify:addNotify(source, "Pojazd został zespawnowany.")
	end

	vehicles.show(source, true)
end

addEvent("vehlist:spawn", true)
addEventHandler( "vehlist:spawn", root, vehicles.spawn )

function vehicles.access(mainID, uid)
	if not isVehicleOwner(source, uid, true, true) then
			return exports.sarp_notify:addNotify(source, "Nie jesteś właścicielem tego pojazdu.")
		end

		setVehicleData(uid, "accessGroup", mainID)
		saveVehicle(uid, 'owner')
		exports.sarp_notify:addNotify(source, string.format("Zmieniono udostępnianie pojazdu o UID %d.", uid))
end

addEvent("accessVehicleDynamicGroup", true)
addEventHandler( "accessVehicleDynamicGroup", root, vehicles.access )

function changecolor(UID, col1, col2)
	if not exports.sarp_admin:getPlayerPermission(source, 16) then return end
	if vehiclesData[UID] and vehiclesData[UID].mtaID then
		vehiclesData[UID].color1 = col1
		vehiclesData[UID].color2 = col2
		saveVehicle(UID, 'other')
		setVehicleColor( vehiclesData[UID].mtaID, col1[1], col1[2], col1[3], col2[1], col2[2], col2[3] )
		exports.sarp_notify:addNotify(source, string.format("Zmieniłeś kolor dla pojazdu o UID: %d.", UID))
	end
end

addEvent('vehicle:changecolor', true)
addEventHandler( 'vehicle:changecolor', root, changecolor )

function vehicles.cmd(playerid, cmd, cmd2, ...)
	if cmd2 == 'zamknij' then
		local vehid = getNearestVehicle(playerid)

		if not isElement(vehid) then
			return exports.sarp_notify:addNotify(playerid, "Nie znaleziono w poblizu pojazdu do którego masz kluczyki.")
		end

		if isVehicleLocked( vehid ) then
			setVehicleLocked( vehid, false )
			exports.sarp_notify:addNotify(playerid, "Otworzyłeś pojazd za pomocą kluczyków.")
		else
			setVehicleLocked( vehid, true )
			exports.sarp_notify:addNotify(playerid, "Zamknąłeś pojazd za pomocą kluczyków.")
		end
		setPedAnimation( playerid, "int_house", "wash_up", 1000, false, false, false, false )
		setTimer(setPedAnimation, 1000, 1, playerid )
	elseif cmd2 == 'zaparkuj' then
		local vehid = getPedOccupiedVehicle ( playerid )
		local vehUID = getVehicleUID(vehid)

		if not isPlayerDriver(playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz być na miejscu kierowcy w pojeździe.")
		end
		
		if getVehicleEngineState( vehid ) then
			return exports.sarp_notify:addNotify(playerid, "Musisz najpierw wyłączyć silnik.")
		end
		
		if not isVehicleOwner(playerid, vehUID, false) then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz kluczyków do tego pojazdu.")
		end

			local vX, vY, vZ = getElementPosition( vehid )
			local rX, rY, rZ = getElementRotation( vehid )
			local vw, interior = getElementDimension( vehid ), getElementInterior( vehid )
			vehiclesData[vehUID].posX = vX
			vehiclesData[vehUID].posY = vY
			vehiclesData[vehUID].posZ = vZ
			vehiclesData[vehUID].rotX = rX
			vehiclesData[vehUID].rotY = rY
			vehiclesData[vehUID].rotZ = rZ
			vehiclesData[vehUID].dimension = vw
			vehiclesData[vehUID].interior = interior
			setVehicleSpawnState(vehid, false)
			setVehicleSpawnState(vehid, true)
			warpPedIntoVehicle( playerid, vehiclesData[vehUID].mtaID )
			saveVehicle(vehUID, 'pos')
			exports.sarp_notify:addNotify(playerid, "Przeparkowałeś pojazd pomyślnie.")
	elseif cmd2 == 'info' then
		local vehid = getPedOccupiedVehicle ( playerid )
		local vehUID = getVehicleUID(vehid)

		if not isPlayerDriver(playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz być na miejscu kierowcy w pojeździe.")
		end

		if not isVehicleOwner(playerid, vehUID, false) then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do tego pojazdu.")
		end
		local vehicle = vehiclesData[vehUID]

		if vehicle.ownerType == 2 then
			vehicle.groupName = exports.sarp_groups:getGroupData(vehicle.ownerID, "name")
		end

		if vehicle.mtaID then
				vehicle.mileage = getElementData(vehicle.mtaID, "vehicle:mileage")
				vehicle.fuel = getElementData(vehicle.mtaID, "vehicle:fuel")
		end

		triggerClientEvent( "vehicle:info", playerid, vehicle, false)
	elseif cmd2 == 'audio' then
		local vehid = getPedOccupiedVehicle ( playerid )
		local vehUID = getVehicleUID(vehid)

		if not isPlayerDriver(playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz być na miejscu kierowcy w pojeździe.")
		end

		if not isVehicleOwner(playerid, vehUID, false) then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do tego pojazdu.")
		end

		local isAudio = false

		for i, v in ipairs(vehiclesData[vehUID].tuning) do
			if v.type == 3 then
				isAudio = true
				break
			end
		end

		if not isAudio then
			return exports.sarp_notify:addNotify(playerid, "W tym pojeździe nie ma zamontowanego systemu audio.")
		end

		triggerClientEvent( playerid, "changeVehicleURL", root, vehUID, vehiclesData[vehUID].url )
	else
		vehicles.show(playerid, false)
	end
end

addCommandHandler( "v", vehicles.cmd)