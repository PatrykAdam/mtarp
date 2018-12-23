--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local admin = {}

function admin.cmd(playerid, cmd, cmd2, ...)
	if not exports.sarp_admin:getPlayerPermission(playerid, 16) then return end
	
	local more = {...}
	if cmd2 == 'stworz' then
		local model = tonumber(more[1])
		if not model then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av stworz [model]")
		end
		if model > 611 or model < 400 then
			return exports.sarp_notify:addNotify(playerid, "Nie ma pojazdu o takim ID!")
		end
		local x, y, z = getElementPosition( playerid )
		local UID = createVeh(model, x, y+5, z, 0, 0, 0, color)

		triggerClientEvent( "vehicle:admcolor", playerid, UID)
		exports.sarp_notify:addNotify( playerid,  "Utworzyłeś pojazd o UID: ".. UID)
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s utworzył pojazd %s (UID: %d).", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getVehicleNameFromModel(model), UID))

	elseif cmd2 == 'color' then
		local UID = tonumber(more[1])

		if not UID then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av color [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end
		triggerClientEvent( "vehicle:admcolor", playerid, UID)

	elseif cmd2 == 'goto' then
		local UID = tonumber(more[1])

		if not UID then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av goto [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end

		local x, y, z = getElementPosition( vehiclesData[UID].mtaID )
		local vw, interior = getElementDimension( vehiclesData[UID].mtaID ), getElementInterior( vehiclesData[UID].mtaID )

		setElementPosition( playerid, x, y, z )
		setElementInterior( playerid,  interior )
		setElementDimension( playerid, vw )

		exports.sarp_notify:addNotify( playerid,  "Teleportowałeś się do pojazdu. (UID: ".. UID ..")" )
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s teleportował się do pojazdu o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))


	elseif cmd2 == 'gethere' then
		local UID = tonumber(more[1])

		if not UID then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av gethere [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end

		local x, y, z = getElementPosition( playerid )
		local vw, interior = getElementDimension( playerid ), getElementInterior( playerid )

		setElementPosition( vehiclesData[UID].mtaID, x + 3, y, z + 5 )
		setElementInterior( vehiclesData[UID].mtaID, interior )
		setElementDimension( vehiclesData[UID].mtaID, vw )

		exports.sarp_notify:addNotify( playerid,  "Pojazd (UID: ".. UID .. ") został teleportowany do Ciebie." )
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s teleportował do siebie pojazd o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))

	elseif cmd2 == 'lista' then
		outputChatBox( "LISTA POJAZDÓW:",playerid )
		for i, a in pairs(vehiclesData) do
			outputChatBox( vehiclesData[i].id.. ". ".. getVehicleNameFromModel(vehiclesData[i].model), playerid )
		end

	elseif cmd2 == 'spawn' then
		local UID = tonumber(more[1])

		if not UID then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av spawn [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		if vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd jest juz zespawnowany!" )
		end

		setVehicleSpawnState(UID, true)
		setElementData( vehiclesData[UID].mtaID, "vehicle:manual", false)
		setElementFrozen( vehiclesData[UID].mtaID, false )

		exports.sarp_notify:addNotify( playerid,  "Pojazd (UID: ".. UID .. ") został zespawnowany" )
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zespawnował pojazd o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))

	elseif cmd2 == 'unspawn' then
		local UID = tonumber(more[1])

		if not UID then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av unspawn [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end

		exports.sarp_notify:addNotify( playerid,  "Pojazd (UID: ".. UID .. ") został odspawnowany" )
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s odspawnował pojazd o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))
		setVehicleSpawnState(UID, false)

	elseif cmd2 == 'napraw' then
		local UID = tonumber(more[1])

		if not (UID) then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av napraw [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end

		exports.sarp_logs:createLog('adminACTION', string.format("%s %s naprawił pojazd o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))
		setElementData(vehiclesData[UID].mtaID, "vehicle:health", 1000.0)
		fixVehicle( vehiclesData[UID].mtaID )

	elseif cmd2 == 'usun' then
		local UID = tonumber(more[1])

		if not UID then
			return	exports.sarp_notify:addNotify( playerid,  "Uzyj: /av usun [UID]" )
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_vehicles` WHERE `id`= ?", UID)
		
		if vehiclesData[UID].mtaID then
			triggerEvent('gpsDestroy', resourceRoot, vehiclesData[UID].mtaID)
			destroyElement( vehiclesData[UID].mtaID )
		end

		exports.sarp_logs:createLog('adminACTION', string.format("%s %s usunął pojazd o UID: %d. (%s)", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID, getVehicleNameFromModel( vehiclesData[UID].model )))
		vehiclesData[UID] = nil
		exports.sarp_notify:addNotify( playerid,  "Pojazd (UID: ".. UID .. ") został usunięty." )
	elseif cmd2 == 'owner' then
		local type, id, UID = tonumber(more[2]), tonumber(more[3]), tonumber(more[1])

		if not (type or id) or type > 3 and type < 0 then
			return exports.sarp_notify:addNotify( playerid,  "Uzyj: /av owner [UID] [nikt = 0, gracz = 1, grupa = 2] [id gracza/grupy]" )
		end

		if type == 1 then
			local playerid = exports.sarp_main:getPlayerFromID(id)
			id = getElementData(playerid, "player:id")

		elseif type == 2 then
			if not exports.sarp_groups:isGroup(id) then
				return exports.sarp_notify:addNotify( playerid,  "Grupa o podanym ID nie istnieje." )
			end
		end

		if vehiclesData[UID] == nil then
			return exports.sarp_notify:addNotify( playerid,  "Nie istnieje pojazd o takim UID!" )
		end

		vehiclesData[UID].ownerID = id
		vehiclesData[UID].ownerType = type
		saveVehicle(UID, 'owner')
	
		exports.sarp_notify:addNotify(playerid, "Zmieniono właściciela dla pojazdu o UID: ".. UID)
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił właściciela pojazdu %s o UID: %d.(ownerType: %d, ownerID: %d)", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getVehicleNameFromModel( vehiclesData[UID].model ), UID, type, id))
	elseif cmd2 == 'reczny' then
		local UID, status = tonumber(more[1]), tonumber(more[2])
		
		if not UID then
			return exports.sarp_notify:addNotify( playerid,  "Użyj: /av reczny [UID]")
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end

		if getElementData( vehiclesData[UID].mtaID, "vehicle:manual") then
			setElementData( vehiclesData[UID].mtaID, "vehicle:manual", false)

			if vehiclesData[UID].policeBlock == 0 then
				setElementFrozen( vehiclesData[UID].mtaID, false )
			end
			exports.sarp_notify:addNotify(playerid, 'Hamulec ręczny został odciągnięty.')
			exports.sarp_logs:createLog('adminACTION', string.format("%s %s odciągnął hamulec ręczny w pojeździe o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))
		else
			setElementData( vehiclesData[UID].mtaID, "vehicle:manual", true)
			setElementFrozen( vehiclesData[UID].mtaID, true )
			exports.sarp_notify:addNotify(playerid, 'Hamulec ręczny został zaciągnięty.')
			exports.sarp_logs:createLog('adminACTION', string.format("%s %s zaciągnął hamulec ręczny w pojeździe o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))
		end

		setPlayerHandbrake(playerid, vehiclesData[UID].mtaID)
	elseif cmd2 == 'paliwo' then
		local UID = tonumber(more[1])
		
		if not UID then
			return exports.sarp_notify:addNotify( playerid,  "Użyj: /av paliwo [UID]")
		end

		if not vehiclesData[UID].mtaID then
			return exports.sarp_notify:addNotify( playerid,  "Ten pojazd nie jest zespawnowany." )
		end

		setElementData(vehiclesData[UID].mtaID, "vehicle:fuel", getVehicleMaxFuel( getElementModel( vehiclesData[UID].mtaID ) ))
		exports.sarp_notify:addNotify(playerid, 'Uzupełniony został bak pojazdu.')
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zatankował pojazd o UID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), UID))
	else
		exports.sarp_notify:addNotify( playerid,  "Uzyj: /av [stworz | lista | color | usun | goto | lista | gethere | spawn | unspawn | owner | hp | reczny | paliwo]" )
	end
end

addCommandHandler( "av", admin.cmd)