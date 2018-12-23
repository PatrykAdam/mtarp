--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local vehicles = {}
vehiclesData = {}

function vehicles.load()	
	local count = 0
	local query = exports.sarp_mysql:mysql_result( "SELECT * FROM `sarp_vehicles`" )

	local vehiclesTuning = {}
	local tuningQuery = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_items` WHERE `ownerType` = 4")

	for i, v in ipairs(tuningQuery) do
		if not vehiclesTuning[v.ownerID] then
			vehiclesTuning[v.ownerID] = {}
		end
		
		table.insert(vehiclesTuning[v.ownerID], {type = v.value1, value = v.value2, name = v.name, id = v.id})
	end


	for i, v in ipairs (query) do

		local id = query[i].id
		vehiclesData[id] = {}
		vehiclesData[id].id = id
		vehiclesData[id].mtaID = nil
		vehiclesData[id].model = query[i].model
		vehiclesData[id].ownerType =  query[i].ownerType
		vehiclesData[id].ownerID = query[i].ownerID
		vehiclesData[id].color1 = split( query[i].color1, ', ')
		vehiclesData[id].color2 = split( query[i].color2, ', ' )
		vehiclesData[id].posX = query[i].posX
		vehiclesData[id].posY = query[i].posY
		vehiclesData[id].posZ = query[i].posZ
		vehiclesData[id].rotX = query[i].rotX
		vehiclesData[id].rotY = query[i].rotY
		vehiclesData[id].rotZ = query[i].rotZ
		vehiclesData[id].plate = tostring(query[i].plate)
		vehiclesData[id].engine = false
		vehiclesData[id].lights = split( query[i].lights, ', ' )
		vehiclesData[id].panels = split( query[i].panels, ', ' )
		vehiclesData[id].doors = split( query[i].doors, ', ' )
		vehiclesData[id].wheels = split( query[i].wheels, ', ' )
		vehiclesData[id].hp = query[i].hp
		vehiclesData[id].interior = query[i].interior
		vehiclesData[id].dimension = query[i].dimension
		vehiclesData[id].mileage = query[i].mileage
		vehiclesData[id].fuel = query[i].fuel
		vehiclesData[id].policeBlock = query[i].policeBlock
		vehiclesData[id].registered = query[i].registered
		vehiclesData[id].description = query[i].description
		vehiclesData[id].url = query[i].url
		vehiclesData[id].accessGroup = query[i].accessGroup

		if vehiclesData[id].ownerType == 1 then
			local query = exports.sarp_mysql:mysql_result("SELECT `name`, `surname` FROM `sarp_characters` WHERE `player_id` = ?", vehiclesData[id].ownerID)
			if not query[1] then 
				ownerName = "Nie przypisano"
			else
				ownerName = query[1].name.." "..query[1].surname
			end
		elseif vehiclesData[id].ownerType == 2 then
			local query = exports.sarp_mysql:mysql_result("SELECT `name`, `type` FROM `sarp_groups` WHERE `id` = ?", vehiclesData[id].ownerID)
			if not query[1] then
				ownerName = "Nie przypisano"
			else
				ownerName = query[1].name
				vehiclesData[id].subType = query[1].type
			end
		else
			ownerName = "Nie przypisano"
		end
		vehiclesData[id].ownerName = ownerName
		vehiclesData[id].tuning = {}

		if vehiclesTuning[id] then
			vehiclesData[id].tuning = vehiclesTuning[id]
		end

		if vehiclesData[id].registered == 0 then
			vehiclesData[id].plate = '--'
		end

		if vehiclesData[id].ownerType ~= 1 then
			local car = createVehicle( vehiclesData[id].model, vehiclesData[id].posX, vehiclesData[id].posY, vehiclesData[id].posZ, vehiclesData[id].rotX, vehiclesData[id].rotY, vehiclesData[id].rotZ, vehiclesData[id].plate)

			vehiclesData[id].mtaID = car

			for p=0, 6 do
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

			setVehicleColor( car, vehiclesData[id].color1[1], vehiclesData[id].color1[2], vehiclesData[id].color1[3], vehiclesData[id].color2[1], vehiclesData[id].color2[2], vehiclesData[id].color2[3] )
			
			setVehicleDamageProof( car, true )
			
			setVehicleOverrideLights( car, 1 )

			setElementInterior( car, vehiclesData[id].interior )
			setElementDimension( car, vehiclesData[id].dimension )

			if vehiclesData[id].hp < 300.0 then
				vehiclesData[id].hp = 300.0
			end

			setElementData(car, "vehicle:health", vehiclesData[id].hp)
			setElementHealth( car, vehiclesData[id].hp > 1000.0 and 1000.0 or vehiclesData[id].hp )

			if vehiclesData[id].hp > 300.0 then
				setElementFrozen( car, true )
			end
			
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

			if vehiclesData[id].ownerType == 2 then
				setElementData(car, "vehicle:subType", vehiclesData[id].subType)
			end

			setVehicleLocked( car, true )
			setVehicleWheelStates( car, vehiclesData[id].wheels[1], vehiclesData[id].wheels[2], vehiclesData[id].wheels[3], vehiclesData[id].wheels[4] )
		end
		count = count + 1
	end
	
	outputDebugString( 'Wczytano '.. count .. ' pojazdow z bazy danych')
end

addEventHandler( "onResourceStart", resourceRoot, vehicles.load )

function vehicles.stop()
	for i, v in ipairs( getElementsByType( "vehicle" )) do
		local id = getVehicleUID(v)
		saveVehicle(id, 'health')
		saveVehicle(id, 'other')
	end
end

addEventHandler( "onResourceStop", resourceRoot, vehicles.stop )

function vehicles.enter(playerid, seat, jacked)
	if getElementType( playerid ) == 'ped' then return end
	-- Wylaczenie silnika 
	local id = getVehicleUID(source)
	if not vehiclesData[id].engine then
		setVehicleEngineState( source, false )
	end

   	-- Wlaczenie zadawania obrazen dla pojazdu
   	if getVehicleOccupant( source ) and seat == 0 then
			setVehicleDamageProof( source, false )
			setPlayerHandbrake(playerid, source)
			
			if vehiclesData[id].policeBlock > 0 then
				exports.sarp_notify:addNotify(playerid, string.format("Ten pojazd posiada nałożoną blokadę na koła w wysokości %d$.", vehiclesData[id].policeBlock))
			end
		end

	setElementData( playerid, "player:inVehicle", true )
end

addEventHandler ( "onVehicleEnter", root, vehicles.enter )

function vehicles.exit(playerid, seat, jacked)
	setElementData( playerid, "player:inVehicle", false )
	if playerid and seat == 0 then
		setVehicleDamageProof( source, true )
	end
	local id = getVehicleUID(source)
	saveVehicle(id, 'health')
	saveVehicle(id, 'other')
	if getElementData(source, "vehicle:manual") then
		toggleControl( playerid, "accelerate", true )
		toggleControl( playerid, "brake_reverse", true )
		unbindKey( playerid, "w", "down" )
	end
end

addEventHandler ( "onVehicleExit", root, vehicles.exit )

function vehicles.bind(playerid)
	unbindKey( playerid, "k", "down" )
	unbindKey( playerid, "l", "down" )
	unbindKey( playerid, "lalt", "down" )

	bindKey(playerid, "k", "down", function(playerid)
		local vehicle = getPedOccupiedVehicle( playerid )

		if vehicle and getVehicleOccupant( vehicle ) == playerid then
			triggerEvent( "setVehicleEngineState", playerid, vehicle, not getVehicleEngineState( vehicle ) )
		end
	end, playerid)
	bindKey(playerid, "l", "down", function(playerid)
		local vehicle = getPedOccupiedVehicle( playerid )

		if vehicle and getVehicleOccupant( vehicle ) == playerid then
			if getVehicleOverrideLights( vehicle ) ~= 2 then
				setVehicleOverrideLights( vehicle, 2 )
				exports.sarp_notify:addNotify(playerid, 'Światła w pojeździe zostały zapalone.')
			else
				setVehicleOverrideLights( vehicle, 1 )
				exports.sarp_notify:addNotify(playerid, 'Światła w pojeździe zostały zgaszone.')
			end
		end
	end, playerid)
	bindKey(playerid, "lalt", "down", function(playerid)
		local vehicle = getPedOccupiedVehicle( playerid )

		if vehicle and getVehicleOccupant( vehicle ) == playerid then
			if getElementSpeed(vehicle, 1) > 5 or isElementInWater(vehicle) then
				return exports.sarp_notify:addNotify(playerid, 'Aby zaciągnąć ręczny musisz się zatrzymać.')
			end

			if getElementData( vehicle, "vehicle:manual") then
				setElementData( vehicle, "vehicle:manual", false)

				if getElementData(vehicle, "vehicle:policeBlock") == 0 and not getElementData(vehicle, "vehicle:repairTime") then
					setElementFrozen( vehicle, false )
				end
				exports.sarp_notify:addNotify(playerid, 'Hamulec ręczny został odciągnięty.')
			else
				setElementData( vehicle, "vehicle:manual", true)
				setElementFrozen( vehicle, true )
				exports.sarp_notify:addNotify(playerid, 'Hamulec ręczny został zaciągnięty.')
			end
			triggerEvent( "setPlayerHandbrake", playerid, playerid, vehicle )
		end
	end, playerid)
end

function vehicles.onJoin()
	vehicles.bind(source)
end

addEventHandler( "onPlayerJoin", root, vehicles.onJoin )

function vehicles.onStart()
	for i, v in ipairs(getElementsByType( "player" )) do
		vehicles.bind(v)
	end
end

addEventHandler( "onResourceStart", root, vehicles.onStart )

function vehicles.onDamage(loss)
	local vehicleID = getElementData(source, "vehicle:id")
	local newHP = getElementData( source, "vehicle:health") - loss

	cancelEvent()
	setElementData(source, "vehicle:health", newHP)
	setElementHealth( source, newHP )

	if getElementHealth ( source ) < 300 then 
		setElementHealth ( source, 300 )
		setElementData(source, "vehicle:health", 300)

		setVehicleDamageProof( source, true )
	end
end

addEventHandler( "onVehicleDamage", root, vehicles.onDamage )

function vehicles.onExplode()
	local vehicleID = getElementData(source, "vehicle:id")
	setElementHealth ( source, 300 )

	local vX, vY, vZ = getElementPosition( source )
	local vRX, vRY, vRZ = getElementRotation( source )

	vehiclesData[vehicleID].hp = 300
	vehiclesData[vehicleID].posX = vX
	vehiclesData[vehicleID].posY = vY
	vehiclesData[vehicleID].posZ = vZ
	vehiclesData[vehicleID].rotX = 0
	vehiclesData[vehicleID].rotY = vRY
	vehiclesData[vehicleID].rotZ = vRZ
	saveVehicle(vehicleID, 'pos')

	local vehicle = setVehicleSpawnState( vehicleID, 'respawn' )
	cancelEvent()
end

addEventHandler( "onVehicleExplode", root, vehicles.onExplode )