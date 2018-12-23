--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local doors = {}

function loadDoors()
	local count = 0
	local doorsData = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_doors`")

	for id, v in ipairs(doorsData) do
		local door = createMarker( doorsData[id].posX, doorsData[id].posY, doorsData[id].posZ, "corona", 1.0, 0, 255, 0, 0 )
		local exit = createMarker( doorsData[id].exitX, doorsData[id].exitY, doorsData[id].exitZ, "corona", 1.0, 255, 255, 255, 0 )

		setElementDimension( door, doorsData[id].dimension )
		setElementInterior( door, doorsData[id].interior )
		setElementDimension( exit, doorsData[id].exitdimension )
		setElementInterior( exit, doorsData[id].exitinterior )

		setElementData( exit, "type:doors", true )
		setElementData( exit, "doors:exit", true )
		setElementData( exit, "doors:parent", door)

		setElementData( door, "type:doors", true )
		setElementData( door, "doors:id", doorsData[id].id )
		setElementData( door, "doors:name", doorsData[id].name )
		setElementData( door, "doors:description", doorsData[id].description )
		setElementData( door, "doors:lock", doorsData[id].lock )
		setElementData( door, "doors:entry", doorsData[id].entry )
		setElementData( door, "doors:posRot", doorsData[id].posRot )
		setElementData( door, "doors:exitRot", doorsData[id].exitRot )
		setElementData( door, "doors:ownerType", doorsData[id].ownerType )
		setElementData( door, "doors:accessGroup", doorsData[id].accessGroup )
		setElementData( door, "doors:ownerID", doorsData[id].ownerID )
		setElementData( door, "doors:garage", doorsData[id].garage )
		setElementData( door, "doors:arrest", doorsData[id].arrest )
		setElementData( door, "doors:objects", doorsData[id].objects )
		setElementData( door, "doors:equipment", doorsData[id].equipment )
		setElementData( door, "doors:parent", exit)
		local ownerName = false
		if doorsData[id].ownerType == 1 then
			local query = exports.sarp_mysql:mysql_result("SELECT `name`, `surname` FROM `sarp_characters` WHERE `player_id` = ?", doorsData[id].ownerID)
			if not query[1] then 
				ownerName = "Nie przypisano"
			else
				ownerName = query[1].name.." "..query[1].surname
			end
		elseif doorsData[id].ownerType == 2 then
			local query = exports.sarp_mysql:mysql_result("SELECT `name`, `type` FROM `sarp_groups` WHERE `id` = ?", doorsData[id].ownerID)
			if not query[1] then
				ownerName = "Nie przypisano"
			else
				ownerName = query[1].name
				doorsData[id].subType = query[1].type
			end
		else
			ownerName = "Nie przypisano"
		end
		setElementData( door, "doors:ownerName", ownerName)
		if haveDoorEquipment(id, 1) then
			setElementData( door, "doors:url", doorsData[id].url )
		end
	end

	outputDebugString( "Wczytano ".. #doorsData .." drzwi z bazy danych." )
end
addEventHandler( "onResourceStart", resourceRoot, loadDoors )

function doorTeleport(playerid)
	if not exports.sarp_main:isPlayerLogged( playerid ) then return end

	for i, v in ipairs(getElementsByType( "marker" )) do
		if getElementData(v, "type:doors") then
			local dX, dY, dZ = getElementPosition( v )
			local parent = getElementData( v, "doors:parent")
			local eX, eY, eZ = getElementPosition( parent )

			if getDistanceBetweenPoints3D( dX, dY, dZ, getElementPosition( playerid ) ) <= 1.0 and getElementDimension( v ) == getElementDimension( playerid ) and getElementInterior( v ) == getElementInterior( playerid ) then
				if getElementData( v, "doors:lock") == 1 or getElementData( parent, "doors:lock") == 1 then
					return exports.sarp_notify:addNotify(playerid, "Drzwi w tym budynku są zamknięte.")
				end

				if getElementData( playerid, "player:arrestTime") then
					return exports.sarp_notify:addNotify(playerid, "Przechodzenie przez drzwi wyłączone podczas aresztu.")
				end

				if not getElementData( v, "doors:exit") and getElementData( v, "doors:entry") > 0 then
					local cash = getElementData( playerid, "player:money")

					if cash < getElementData( v, "doors:entry") then
						return exports.sarp_notify:addNotify(playerid, "Nie posiadasz wystarczającej ilości gotówki aby wejść do tego budynku.")
					end
					exports.sarp_main:givePlayerCash(playerid, -cash)
				end

				local vehicle = getPedOccupiedVehicle( playerid )

				if vehicle then
					local driver = getVehicleOccupant(vehicle)

					if getElementData( v, "doors:garage") == 0 and driver == playerid then
						return
					end

					if driver and driver == playerid then
						removePedFromVehicle( playerid )

						setElementPosition( vehicle, eX, eY, eZ + 1)
						setElementDimension( vehicle, getElementDimension( parent ) )
						setElementInterior( vehicle, getElementInterior( parent ) )
						warpPedIntoVehicle( playerid, vehicle )
					end
				end

				setElementPosition( playerid, eX, eY, eZ )
				setElementDimension( playerid, getElementDimension( parent ) )
				setElementInterior( playerid, getElementInterior( parent ) )

				if not getElementData( v, "doors:exit") then
					setElementData( playerid, "player:door", v )

					if haveDoorEquipment(getElementData( v, "doors:id"), 1) and getElementData( v, "doors:url") then
						triggerClientEvent( playerid, "doorSound", playerid, getElementData( v, "doors:url") )
					end
				else
					setElementData( playerid, "player:door", false)
					triggerClientEvent( playerid, "doorSoundOff", root )
				end

				triggerEvent( "objects:load", root, playerid, getElementDimension( parent ), getElementInterior( parent ) )

				return true
			end
		end
	end
end

addEventHandler( "onPlayerJoin", root, function ()
	bindKey(source, "E", "down", doorTeleport)
end)

addEventHandler( "onResourceStart", resourceRoot, function ()
	for i, v in ipairs(getElementsByType( "player" )) do
		unbindKey( v, "E", "both" )
		bindKey(v, "E", "down", doorTeleport)
	end
end)

addEventHandler( "onResourceStop", resourceRoot, function ()
	for i, v in ipairs(getElementsByType( "player" )) do
		unbindKey(v, "E", "down", doorTeleport)
	end
end)