--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local bots = {}
bots.enable = true

bots.config = {
	driveLicense = 100,
	IDcard = 200,
	plate = 200,
	govID = 1,
}


function bots.document(id, data)
	if id == 1 then
		if exports.sarp_main:havePlayerDocument(source, 2) then
			return exports.sarp_notify:addNotify(source, "Posiadasz już wyrobione prawo jazdy.")
		end

		if getElementData(source, "player:money") < bots.config['driveLicense'] then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz wystarczającej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(source, - bots.config['driveLicense'])
		setElementData(source, "player:documents", getElementData(source, "player:documents") + 2)
		giveGroupCash(bots.config['govID'], bots.config['driveLicense'])

		exports.sarp_notify:addNotify(source, "Prawo jazdy zostały wyrobione.")

	elseif id == 2 then
		if exports.sarp_main:havePlayerDocument(source, 1) then
			return exports.sarp_notify:addNotify(source, "Posiadasz już wyrobiony dowód osobisty.")
		end

		if getElementData(source, "player:money") < bots.config['IDcard'] then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz wystarczającej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(source, - bots.config['IDcard'])
		setElementData(source, "player:documents", getElementData(source, "player:documents") + 1)
		giveGroupCash(bots.config['govID'], bots.config['IDcard'])

		exports.sarp_notify:addNotify(source, "Dowód osobisty został wydany.")
	elseif id == 3 then
		local vehicle = exports.sarp_vehicles:getVehicleData(data, {'ownerID', 'ownerType', 'registered', 'mtaID'})

		if not exports.sarp_vehicles:isVehicleOwner(source, data, true) then
			return exports.sarp_notify:addNotify(source, "Nie jesteś właścicielem pojazdu o podanym UID.")
		end

		if vehicle.registered == 1 then
			return exports.sarp_notify:addNotify(source, "Pojazd o podanym UID jest już zarejestrowany.")
		end

		exports.sarp_main:givePlayerCash(source, - bots.config['plate'])
		exports.sarp_vehicles:setVehicleData(data, {plate = string.format('LS%05d', data), registered = 1})
		triggerEvent( "saveVehicle", source, data, 'other' )
		giveGroupCash(bots.config['govID'], bots.config['plate'])

		if vehicle.mtaID and isElement(vehicle.mtaID) then
			local vX, vY, vZ = getElementPosition( vehicle.mtaID )
			local rX, rY, rZ = getElementRotation( vehicle.mtaID )
			local interior = getElementInterior( vehicle.mtaID )
		local dimension = getElementDimension( vehicle.mtaID )
			local vehicleID = exports.sarp_vehicles:setVehicleSpawnState(data, 'respawn')
			setElementPosition( vehicleID, vX, vY, vZ )
			setElementRotation( vehicleID, rX, rY, rZ )
			setElementInterior( vehicleID, interior )
			setElementDimension( vehicleID, dimension )
		end

		exports.sarp_notify:addNotify(source, "Pojazd został zarejestrowany.")
	end
end

addEvent("documentGOV", true)
addEventHandler( "documentGOV", root, bots.document )

function bots.setStatus()
	if bots.enable then
		triggerClientEvent( "runGOVbots", root )
	else
		triggerClientEvent( "disableGOVbots", root )
	end
end

addEventHandler( "onPlayerJoin", root, function()
	if bots.enable then
		triggerClientEvent(source, "runGOVbots", source )
	else
		triggerClientEvent(source, "disableGOVbots", source )
	end
end)
addEventHandler( "onResourceStart", resourceRoot, function()
	setTimer(bots.setStatus, 1000, 1)
end)

function bots.cmd(playerid, cmd)
	local groupid = getElementData(playerid, "player:duty")

	if not isDutyInGroupType(playerid, 1) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if not haveGroupPermission(playerid, groupid, 8192) then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do włączania/wyłączania bota.")
	end

	bots.enable = not bots.enable
	bots.setStatus()

	exports.sarp_notify:addNotify(playerid, string.format("Bot w urzędzie został %s.", bots.enable and "włączony" or "wyłączony"))
end

addCommandHandler( "ugov", bots.cmd )