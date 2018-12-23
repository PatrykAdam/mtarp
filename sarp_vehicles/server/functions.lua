--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function isVehicleOwner(playerid, UID, mainOwner, sell)
	if not vehiclesData[UID] then return false end
	if not sell then
		if mainOwner then
			if  vehiclesData[UID].ownerType == 1 and vehiclesData[UID].ownerID == getElementData(playerid, "player:id") 
			or exports.sarp_admin:getPlayerPermission(playerid, 16)
			or exports.sarp_groups:haveGroupPermission(playerid, vehiclesData[UID].ownerID, 8) then
				return true
			end
		else
			if vehiclesData[UID].ownerType == 1 and vehiclesData[UID].ownerID == getElementData(playerid, "player:id")
				or exports.sarp_admin:getPlayerPermission(playerid, 16)
				or vehiclesData[UID].ownerType == 2 and exports.sarp_groups:haveGroupPermission(playerid, vehiclesData[UID].ownerID, 128)
				or exports.sarp_dynamic_group:getPlayerPermission(vehiclesData[UID].accessGroup, playerid, 1) then
				return true
			end
		end
	end
	if sell and vehiclesData[UID].ownerType == 1 and vehiclesData[UID].ownerID == getElementData(playerid, "player:id")
	or exports.sarp_admin:getPlayerPermission(playerid, 16) then
		return true
	else
		return false
	end
	return false
end

function getVehicleData(id, data)
	if vehiclesData[id] then
		if type(data) == 'table' then
			local vehicleData = {}
			for i, v in ipairs(data) do
				vehicleData[v] = vehiclesData[id][v]
			end
			return vehicleData
		else
			return vehiclesData[id][data]
		end
	end
	return false
end

function getNearestVehicle(playerid)
	local pX, pY, pZ = getElementPosition( playerid )
	local radius = createColSphere( pX, pY, pZ, 5.0 )
	local vehicle = getElementsWithinColShape( radius, "vehicle" )
	local vehicleID = false
	local lastDistance = 5.0

	for i, v in ipairs(vehicle) do
		local vX, vY, vZ = getElementPosition( v )
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, vX, vY, vZ )
		if lastDistance > distance and getElementDimension( playerid ) == getElementDimension( v ) then
			lastDistance = distance
			vehicleID = v
		end
	end

	destroyElement( radius )

	return vehicleID
end

function setVehicleData(id, data, value)
	if vehiclesData[id] then
		if type(data) == 'table' then
			for i, v in pairs(data) do
				vehiclesData[id][i] = v
			end
		else
			vehiclesData[id][data] = value
		end
	end
end

function createVeh(vmodel, vposX, vposY, vposZ, vrotX, vrotY, vrotZ)
	local id = 1
	while vehiclesData[id] do
		id = id + 1
	end

	vehiclesData[id] = {}
	vehiclesData[id].id = id
	vehiclesData[id].mtaID = nil
	vehiclesData[id].model = vmodel
	vehiclesData[id].ownerType =  0
	vehiclesData[id].ownerID = 0
	vehiclesData[id].posX = vposX
	vehiclesData[id].posY = vposY
	vehiclesData[id].posZ = vposZ
	vehiclesData[id].rotX = vrotX
	vehiclesData[id].rotY = vrotY
	vehiclesData[id].rotZ = vrotZ
	vehiclesData[id].plate = tostring("BRAK")
	vehiclesData[id].engine = false
	vehiclesData[id].lights = split( '0, 0, 0, 0', ', ' )
	vehiclesData[id].panels = split( '0, 0, 0, 0, 0, 0, 0', ', ' )
	vehiclesData[id].doors = split( '0, 0, 0, 0, 0, 0', ', ' )
	vehiclesData[id].wheels = split( '0, 0, 0, 0', ', ' )
	vehiclesData[id].hp = 1000.0
	vehiclesData[id].interior = 0
	vehiclesData[id].dimension = 0
	vehiclesData[id].mileage = 0
	vehiclesData[id].fuel = getVehicleMaxFuel( vmodel)
	vehiclesData[id].color1 = split( '0, 0, 0', ', ' )
	vehiclesData[id].color2 = split( '0, 0, 0', ', ' )
	vehiclesData[id].tuning = {}
	vehiclesData[id].registered = 0
	vehiclesData[id].policeBlock = 0
	vehiclesData[id].ownerName = "Nie przypisano"
	vehiclesData[id].accessGroup = 0
	
	local car = createVehicle( vmodel, vposX, vposY, vposZ, vrotX, vrotY, vrotZ, 'BRAK')

	vehiclesData[id].mtaID = car

	setVehicleDamageProof( car, true )
	setVehicleOverrideLights( car, 1 )

	for p=1, 6 do
		setVehiclePanelState( car, p, vehiclesData[id].panels[p+1] )
	end

	for p=0, 5 do
		setVehicleDoorState( car, p, vehiclesData[id].doors[p+1] )
	end

	for p=0, 3 do
		setVehicleLightState( car, p, vehiclesData[id].lights[p+1] )
	end

	setVehicleWheelStates( car, vehiclesData[id].wheels[1], vehiclesData[id].wheels[2], vehiclesData[id].wheels[3], vehiclesData[id].wheels[4] )
	setVehicleLocked( car, true )

	setElementData(car, "vehicle:health", vehiclesData[id].hp)
	setElementHealth( car, vehiclesData[id].hp > 1000.0 and 1000.0 or vehiclesData[id].hp )

	setElementData(car, "vehicle:id", vehiclesData[id].id)
	setElementData(car, "vehicle:manual", false)
	setElementData(car, "vehicle:signal", 0)
	setElementData(car, "vehicle:mileage", vehiclesData[id].mileage)
	setElementData(car, "vehicle:fuel", vehiclesData[id].fuel)
	setElementData(car, "vehicle:policeBlock", vehiclesData[id].policeBlock)
	setElementData(car, "vehicle:ownerName", vehiclesData[id].ownerName)
	setElementData(car, "vehicle:spawnPosition", {x = vehiclesData[id].posX, y = vehiclesData[id].posY, z =vehiclesData[id].posZ, interior = vehiclesData[id].interior, dimension = vehiclesData[id].dimension})
	setElementData(car, "vehicle:tuning", vehiclesData[id].tuning)

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_vehicles` SET `id` = ?, `model` = ?, `posX` = ?, `posY` = ?, `posZ` = ?, `rotX` = ?, `rotY` = ?, `rotZ` = ?, `plate` = 'BRAK'", id, vmodel, vposX, vposY, vposZ, vrotX, vrotY, vrotZ)
	return id
end

function setVehicleSpawnState(id, state)
	if not vehiclesData[id] then return end


	if state == nil then
		if isElement(vehiclesData[id].mtaID) then
			state = false
		else
			state = true
		end
	end

	if state == 'respawn' then
		setVehicleSpawnState(id, false)
		local vehicle = setVehicleSpawnState(id, true)
		return vehicle
	end
	
	if state == true then
		local car = createVehicle( vehiclesData[id]['model'], vehiclesData[id]['posX'], vehiclesData[id]['posY'], vehiclesData[id]['posZ'], vehiclesData[id]['rotX'], vehiclesData[id]['rotY'], vehiclesData[id]['rotZ'], vehiclesData[id]['plate'] )
		vehiclesData[id].mtaID = car
		setVehicleOverrideLights( car, 1 )
		setVehicleColor( car, vehiclesData[id].color1[1], vehiclesData[id].color1[2], vehiclesData[id].color1[3], vehiclesData[id].color2[1], vehiclesData[id].color2[2], vehiclesData[id].color2[3] )
		setVehicleDamageProof( car, true )

		for p=1, 6 do
			setVehiclePanelState( car, p, vehiclesData[id].panels[p+1] )
		end

		for p=0, 5 do
			setVehicleDoorState( car, p, vehiclesData[id].doors[p+1] )
		end

		for p=0, 3 do
			setVehicleLightState( car, p, vehiclesData[id].lights[p+1] )
		end

		for j, b in ipairs(vehiclesData[id].tuning) do
			if b.type == 1 then
				addVehicleUpgrade( car, b.value )
			end
			if b.type == 2 then
				for k, l in ipairs(lightColors) do
					if k == b.value then
						setVehicleHeadLightColor( car, unpack(l) )
					end
				end
			end
			if b.type == 3 then
				setElementData(car, "vehicle:audio", true)
				setElementData(car, "vehicle:url", vehiclesData[id].url)
			end
			if b.type == 4 then
				setElementData(car, "vehicle:Ccontrol", true)
			end
		end

		if vehiclesData[id].hp < 300.0 then
			vehiclesData[id].hp = 300.0
		end

		setElementData(car, "vehicle:health", vehiclesData[id].hp)
		setElementHealth( car, vehiclesData[id].hp > 1000.0 and 1000.0 or vehiclesData[id].hp )

		if vehiclesData[id].hp > 300.0 then
			setElementFrozen( car, true )
		end
		setVehicleLocked( car, true )

		setElementInterior( car, vehiclesData[id].interior )
		setElementDimension( car, vehiclesData[id].dimension )

		setElementData(car, "vehicle:id", vehiclesData[id].id)
		setElementData(car, "vehicle:manual", true)
		setElementData(car, "vehicle:signal", 0)
		setElementData(car, "vehicle:mileage", vehiclesData[id].mileage)
		setElementData(car, "vehicle:fuel", vehiclesData[id].fuel)
		setElementData(car, "vehicle:policeBlock", vehiclesData[id].policeBlock)
		setElementData(car, "vehicle:desc", vehiclesData[id].description)
		setElementData(car, "vehicle:ownerType", vehiclesData[id].ownerType)
		setElementData(car, "vehicle:ownerID", vehiclesData[id].ownerID)
		setElementData(car, "vehicle:ownerName", vehiclesData[id].ownerName)
		setElementData(car, "vehicle:spawnPosition", {x = vehiclesData[id].posX, y = vehiclesData[id].posY, z =vehiclesData[id].posZ, interior = vehiclesData[id].interior, dimension = vehiclesData[id].dimension})
		setElementData(car, "vehicle:tuning", vehiclesData[id].tuning)

		setVehicleWheelStates( car, vehiclesData[id].wheels[1], vehiclesData[id].wheels[2], vehiclesData[id].wheels[3], vehiclesData[id].wheels[4] )
		return car
	else
		saveVehicle(id, 'health')

		vehiclesData[id].engine = false

		triggerEvent('gpsDestroy', resourceRoot, vehiclesData[id].mtaID)
		destroyElement( vehiclesData[id]['mtaID'] )
		vehiclesData[id]['mtaID'] = nil
	end
end

function updateVehicleTuning(vehicleID)
	local tuningQuery = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_items` WHERE `ownerType` = 4 AND `ownerID` = ?", vehicleID)
	local tuning = {}

	for i, v in ipairs(tuningQuery) do
		table.insert(tuning, {type = v.value1, value = v.value2, name = v.name, id = v.id})
	end

	vehiclesData[vehicleID].tuning = tuning
end

addEvent('updateVehicleTuning', true)
addEventHandler( 'updateVehicleTuning', root, updateVehicleTuning )

function changeVehicleOwner(UID, ownerType, ownerID)
	vehiclesData[UID].ownerType = ownerType
	vehiclesData[UID].ownerID = ownerID
	saveVehicle(UID, 'owner')
end

function getVehicleUID(car)
	if not car then return false end
	local UID
	for i, a in pairs(vehiclesData) do
		if vehiclesData[i]['mtaID'] == car then
			UID = vehiclesData[i]['id']
			break
		end
	end
	return UID
end

function getPlayerVehicles(playerid)
	local vehicle = {}
	for i, v in pairs(vehiclesData) do
		if vehiclesData[i].ownerID == getElementData(playerid, "player:id") and vehiclesData[i].ownerType == 1 then
			if vehiclesData[i].mtaID then
				vehiclesData[i].mileage = getElementData(vehiclesData[i].mtaID, "vehicle:mileage")
				vehiclesData[i].fuel = getElementData(vehiclesData[i].mtaID, "vehicle:fuel")
			end
			table.insert(vehicle, vehiclesData[i])
		end
	end
	return vehicle
end

function getDynamicGroupVehicles(groupid)
	local data = {}
	for i, v in pairs(vehiclesData) do
		if vehiclesData[i].accessGroup == groupid then
			table.insert(data, {id = v.id, ownerName = v.ownerName, model = v.model, hp = v.hp, mtaID = v.mtaID})
		end
	end

	return data
end

function saveVehicle(vehid, what)
	if what == 'health' then
		local panels, doors, lights, hp = {}, {}, {}, getElementData( vehiclesData[vehid].mtaID, "vehicle:health" )

		for i=0, 6 do
    		panels[i+1] = getVehiclePanelState ( vehiclesData[vehid].mtaID, i )
		end
		for i=0, 5 do
    		doors[i+1] = getVehicleDoorState ( vehiclesData[vehid].mtaID, i )
		end
		for i=0, 3 do
    		lights[i+1] = getVehicleLightState ( vehiclesData[vehid].mtaID, i )
		end
		
		local wheels = {} 
		wheels[1], wheels[2], wheels[3], wheels[4] = getVehicleWheelStates( vehiclesData[vehid].mtaID )
		vehiclesData[vehid].lights = lights
		vehiclesData[vehid].panels = panels
		vehiclesData[vehid].doors = doors
		vehiclesData[vehid].wheels = wheels
		vehiclesData[vehid].hp = hp

		exports.sarp_mysql:mysql_change('UPDATE `sarp_vehicles` SET `panels` = ?, `doors` = ?, `lights` = ?, `wheels` = ?, `hp` = ? WHERE `id` = ?', table.concat( panels, ", ", 1, #panels ), table.concat( doors, ", ", 1, #doors ), table.concat( lights, ", ", 1, #lights ), table.concat( wheels, ", ", 1, #wheels ), hp, vehid)
	
	elseif what == 'pos' then
		exports.sarp_mysql:mysql_change('UPDATE `sarp_vehicles` SET `posX` = ?, `posY` = ?, `posZ` = ?, `rotX` = ?, `rotY` = ?, `rotZ` = ?, `interior` = ?, `dimension` = ? WHERE `id` = ?', vehiclesData[vehid].posX, vehiclesData[vehid].posY, vehiclesData[vehid].posZ, vehiclesData[vehid].rotX, vehiclesData[vehid].rotY, vehiclesData[vehid].rotZ, vehiclesData[vehid].interior, vehiclesData[vehid].dimension, vehid)
	
	elseif what == 'other' then
		if vehiclesData[vehid].mtaID and isElement(vehiclesData[vehid].mtaID) then
			vehiclesData[vehid].description = getElementData(vehiclesData[vehid].mtaID, "vehicle:desc")
			vehiclesData[vehid].url = getElementData(vehiclesData[vehid].mtaID, "vehicle:url")
			vehiclesData[vehid].mileage = getElementData(vehiclesData[vehid].mtaID, "vehicle:mileage")
		end
		exports.sarp_mysql:mysql_change('UPDATE `sarp_vehicles` SET `registered` = ?, `plate` = ?, `model` = ?, `mileage` = ?, `fuel` = ?, `color1` = ?, `color2` = ?, `policeBlock` = ?, `description` = ?, `url` = ? WHERE `id` = ?', vehiclesData[vehid].registered, vehiclesData[vehid].plate, vehiclesData[vehid].model, vehiclesData[vehid].mileage, vehiclesData[vehid].fuel, table.concat(vehiclesData[vehid].color1, ", ", 1), table.concat(vehiclesData[vehid].color2, ", ", 1), vehiclesData[vehid].policeBlock, vehiclesData[vehid].description, vehiclesData[vehid].url, vehid)
	
	elseif what == 'owner' then
		if vehiclesData[vehid].ownerType == 1 then
			local query = exports.sarp_mysql:mysql_result("SELECT `name`, `surname` FROM `sarp_characters` WHERE `player_id` = ?", vehiclesData[vehid].ownerID)
			ownerName = query[1].name.." "..query[1].surname
		elseif vehiclesData[vehid].ownerType == 2 then
			local query = exports.sarp_mysql:mysql_result("SELECT `name`, `type` FROM `sarp_groups` WHERE `id` = ?", vehiclesData[vehid].ownerID)
			ownerName = query[1].name
			vehiclesData[vehid].subType = query[1].type
		else
			ownerName = "Nie przypisano"
		end

		if isElement(vehiclesData[vehid].mtaID) then
			setElementData(vehiclesData[vehid].mtaID, "vehicle:ownerName", ownerName)
			setElementData(vehiclesData[vehid].mtaID, "vehicle:subType", vehiclesData[vehid].subType)
		end

		vehiclesData[vehid].ownerName = ownerName
		exports.sarp_mysql:mysql_change('UPDATE `sarp_vehicles` SET `ownerType` = ?, `ownerID` = ?, `accessGroup` = ? WHERE `id` = ?', vehiclesData[vehid].ownerType, vehiclesData[vehid].ownerID, vehiclesData[vehid].accessGroup, vehid)
	end
end

addEvent('saveVehicle', true)
addEventHandler( 'saveVehicle', root, saveVehicle )

function setPlayerHandbrake(playerid, vehid)
	if getElementData(vehid, "vehicle:manual") == true and isPedInVehicle( playerid ) then
		toggleControl( playerid, "accelerate", false )
		toggleControl( playerid, "brake_reverse", false )
		bindKey(playerid, "w", "down", function () exports.sarp_notify:addNotify(playerid, 'Musisz najpierw odciągnąć hamulec ręczny!') end)
	else
		toggleControl( playerid, "accelerate", true )
		toggleControl( playerid, "brake_reverse", true )
		unbindKey( playerid, "w", "down" )
	end
end

addEvent("setPlayerHandbrake", true)
addEventHandler( "setPlayerHandbrake", root, setPlayerHandbrake )

function isPlayerDriver(playerid)
	local vehicle = getPedOccupiedVehicle( playerid )
	if not vehicle then return end
	local driver = getVehicleOccupant( vehicle )
	return (driver == playerid) and true or false
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end