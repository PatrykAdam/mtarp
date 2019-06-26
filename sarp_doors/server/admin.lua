--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function adrzwi(playerid, cmd, cmd2, ...)
	if not exports.sarp_admin:getPlayerPermission(playerid, 8) then return end
	
	local more = {...}
	print(cmd2)

	if cmd2 == 'stworz' then
		local pX, pY, pZ = getElementPosition( playerid )
		local rX, rY, rZ = getElementRotation( playerid )
		local interior, dimension = getElementInterior( playerid ), getElementDimension( playerid )

		local uid = createDoor(pX, pY, pZ, rZ, interior, dimension, 1239)
		exports.sarp_notify:addNotify(playerid, "Pomyslnie stworzono drzwi (UID: " .. uid .. ").")
	elseif cmd2 == 'nazwa' then
		local uid = tonumber(more[1])
		if not uid then
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad nazwa [id drzwi] [nazwa]" )
		end

		local element = getDoorElement(uid)

		if not element then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe id drzwi." )
		end
		print(element)

		table.remove(more, 1)
		local name = table.concat(more, " ")
		if name and string.len(name) > 0 then
			setElementData(element, "doors:name", name)
			saveDoor(uid, 'desc')
			exports.sarp_notify:addNotify(playerid, "Pomyslnie zmieniono nazwę drzwi (UID: " .. uid .. ")" )
		else
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad nazwa ".. uid .. " [nazwa]" )
		end
	elseif cmd2 == 'desc' or cmd2 == 'opis' then
		local uid = tonumber(more[1])
		if not uid then
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad opis [id drzwi] [tekst]" )
		end

		local element = getDoorElement(uid)

		if not element then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe id drzwi." )
		end
		table.remove(more, 1)
		local desc = table.concat(more, " ")
		if desc and string.len(desc) > 0 then
			setElementData(element, "doors:description", desc)
			saveDoor(uid, 'desc')
			exports.sarp_notify:addNotify(playerid, "Pomyslnie zmieniono opis drzwi (UID: " .. uid .. ")" )
		else
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad nazwa ".. uid .. " [nazwa]" )
		end
	elseif cmd2 == 'usun' then
		local uid = tonumber(more[1])
		if not uid then
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad usun [id drzwi]" )
		end

		local element = getDoorElement(uid)

		if not element then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe id drzwi." )
		end
		destroyDoor(uid)
		exports.sarp_notify:addNotify(playerid, "Pomyslnie usunięto drzwi (UID: " .. uid .. ").")
	elseif cmd2 == 'goto' then
		local uid = tonumber(more[1])
		if not uid then
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad goto [id drzwi]" )
		end

		local element = getDoorElement(uid)

		if not element then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe id drzwi." )
		end
		local dX, dY, dZ, dRot = getElementPosition( element ), getElementData( element, "doors:posRot")
		setElementPosition( playerid, dX, dY, dZ )
		setElementRotation( playerid, 0, 0, dRot )
		setElementDimension( playerid, getElementDimension( element ) )
		setElementInterior( playerid, getElementInterior( element ) )
	elseif cmd2 == 'wejscie' then
		local uid = tonumber(more[1])
		if not uid then
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad wejscie [id drzwi]" )
		end
		local element = getDoorElement(uid)

		if not element then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe id drzwi." )
		end
		local pX, pY, pZ = getElementPosition( playerid )
		local rX, rY, rZ = getElementRotation( playerid )
		local interior, dimension = getElementInterior( playerid ), getElementDimension( playerid )
		setElementPosition( element, pX, pY, pZ )
		setElementDimension( element, dimension )
		setElementInterior( element, interior )
		setElementData( element, "doors:posRot", rZ)
		saveDoor(uid, 'pos')
		exports.sarp_notify:addNotify(playerid, "Pomyslnie zmieniono pozycje wejścia drzwi (UID: " .. uid .. ")." )
	elseif cmd2 == 'owner' or cmd2 == 'wlasciciel' then
		local uid, type = tonumber(more[1]), tonumber(more[2])

			if not type then
				return exports.sarp_notify:addNotify(playerid, "Użyj: /ad owner [id drzwi] [1 = gracz, 2 = grupa] [id ownera]" )
			end

			local element = getDoorElement(uid)

			if not element then
				return exports.sarp_notify:addNotify(playerid, "Drzwi o podanym uid nie istnieją.")
			end

			local owner
			if type == 1 then
				local player_id = exports.sarp_main:getPlayerFromID(tonumber(more[3]))
				owner = getElementData(player_id, "player:id")

				if not owner then
					return exports.sarp_notify:addNotify(playerid, "Gracz o podanym id nie istnieje.")
				end
			elseif type == 2 then
				owner = tonumber(more[3])

				if not exports.sarp_groups:isGroup(owner) then
					return exports.sarp_notify:addNotify(playerid, "Grupa o podanym id nie istnieje.")
				end
			else
				return exports.sarp_notify:addNotify(playerid, "Zły typ grupy")
			end
			setElementData( element, "doors:ownerType", type)
			setElementData( element, "doors:ownerID", owner)

			saveDoor(uid, 'owner')
			exports.sarp_notify:addNotify(playerid, "Pomyslnie zmieniono właściciela drzwi (UID: " .. uid .. ")." )
	elseif cmd2 == 'lista' then
		local text = "LISTA DRZWI:"
		for i, v in ipairs( getElementsByType( "pickup" )) do
			if isElement(v) then
				text = text .. string.format('\n%d. %s, Właściciel: %d, %s', getElementData( v, "doors:id" ), getElementData( v, "doors:name" ), getElementData( v, "doors:ownerID" ), getElementData( v, "doors:ownerType" ))
			end
		end
		exports.sarp_notify:addNotify(playerid, text, 5000)
	elseif cmd2 == 'wyjscie' then
		local uid = tonumber(more[1])
		if not uid then
			return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad wyjscie [id drzwi]" )
		end

		local element = getDoorElement(uid)

		if not element then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe id drzwi." )
		end
		local pX, pY, pZ = getElementPosition( playerid )
		local rX, rY, rZ = getElementRotation( playerid )
		local interior, dimension = getElementInterior( playerid ), getElementDimension( playerid )
		
		local parent = getElementData( element, "doors:parent")

		setElementPosition( parent, pX, pY, pZ )
		setElementData( element, "doors:exitRot", rZ)
		setElementDimension( parent, dimension )
		setElementInterior( parent, interior )
		saveDoor(uid, 'pos')
		exports.sarp_notify:addNotify(playerid, string.format('Pomyslnie zmieniono pozycje wyjścia drzwi (UID: %d)', uid) )
	else
		return exports.sarp_notify:addNotify(playerid, "Uzyj: /ad [stworz | usun | lista | goto | wejscie | wyjscie | nazwa | opis | owner]" )
	end
end

addCommandHandler( "ad", adrzwi )
