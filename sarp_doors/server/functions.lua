--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function isDoorGroupType(doorid, grouptype)
	if doorid and isElement(doorid) and getElementData(doorid, "doors:ownerType") == 2 then
		local gType = exports.sarp_groups:getGroupData(getElementData(doorid, "doors:ownerID"), "type")
		if type(grouptype) == 'table' then
			for i, v in ipairs(grouptype) do
				if v == gType then
					return true
				end
			end
		else
			if grouptype == gType then
				return true
			end
		end
	end
	return false
end

function isGroupDoor(groupid, playerid)
	local door = getElementData(playerid, "player:door")

	if door and groupid and isElement(door) and getElementData(door, "doors:ownerType") == 2 and getElementData(door, "doors:ownerID") == groupid 
	or exports.sarp_zones:haveZonePermission(playerid, 16, true) then
		return true
	end
	return false
end

function haveDoorEquipment(id, equipment)
	local element = getDoorElement(id)
	if isElement(element) and exports.sarp_main:bitAND(getElementData(element, "doors:equipment"), equipment) ~= 0 then 
		return true
	end
	return false
end

function createDoor(posX, posY, posZ, posRot, interior, dimension, pickup)
	local id = 1
	local doors = getElementsByType( "marker" )
	while doors[id] and getDoorElement(id) do
		id = id + 1
	end

	local door = createMarker( posX, posY, posZ, "corona", 3.0, 0, 255, 0, 0)
	local exit = createMarker( posX, posY, posZ, "corona", 3.0, 255, 255, 255, 0)

	setElementDimension( door, dimension )
	setElementInterior( door, interior )
	setElementDimension( exit, id )
	setElementInterior( exit, interior )

	setElementData( exit, "type:doors", true )
	setElementData( exit, "doors:exit", true )
	setElementData( exit, "doors:parent", door)

	setElementData( door, "type:doors", true )
	setElementData( door, "doors:id", id )
	setElementData( door, "doors:name", "Budynek #"..id )
	setElementData( door, "doors:description", "W trakcie remontu." )
	setElementData( door, "doors:lock", 0 )
	setElementData( door, "doors:entry", 0 )
	setElementData( door, "doors:posRot", posRot )
	setElementData( door, "doors:exitRot", 0 )
	setElementData( door, "doors:ownerType", 0 )
	setElementData( door, "doors:accessGroup", 0 )
	setElementData( door, "doors:ownerID", 0 )
	setElementData( door, "doors:garage", 0 )
	setElementData( door, "doors:objects", 0 )
	setElementData( door, "doors:equipment", 0 )
	setElementData( door, "doors:ownerName", "Nie przypisano")
	setElementData( door, "doors:parent", exit)

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_doors` SET `id` = ?, `posX` = ?, `posY` = ?, `posZ` = ?, `interior` = ?, `dimension` = ?, `lock` = 1, `name` = ?, `description` = 'Budynek w remoncie', `pickup` = ?, `exitX` = ?, `exitY` = ?, `exitZ` = ?, `exitdimension` = ?", id, posX, posY, posZ, interior, dimension, getElementData( door, "doors:name"), pickup, posX, posY, posZ, id)
	outputServerLog( "Utworzony zostal budynek. (UID: ".. id ..")" )
	return id
end

function getPlayerDoors(playerid)
	local door = {}
	for i, v in pairs(getElementsByType( "marker" )) do
		if not getElementData( v, "doors:exit") and getElementData( v, "doors:ownerID") == getElementData(playerid, "player:id") and getElementData( v, "doors:ownerType") == 1 then
			table.insert(door, v)
		end
	end
	return door
end

function destroyDoor(id)
	local element = getDoorElement(id)
	destroyElement( element )
	destroyElement( getElementData( element, "doors:parent" ) )
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_doors` WHERE `id`= ?", id)
end

function getDoorElement(id)
	for i, v in ipairs(getElementsByType( "marker" )) do
		if getElementData( v, "type:doors") and not getElementData( v, "doors:exit") and getElementData( v, "doors:id") == id then
			return v
		end
	end

	return false
end

function isDoorOwner(playerid, element, mainOwner)
	if mainOwner then
		if getElementData( element, "doors:ownerType") == 1 and getElementData( element, "doors:ownerID") == getElementData( playerid, "player:id" )
		or exports.sarp_admin:getPlayerPermission(playerid, 8) then
			return true
		end
	else
		local query = exports.sarp_mysql:mysql_result("SELECT COUNT(*) as isMember FROM `sarp_doors_members` WHERE `player_id` = ? AND `doorid` = ?", getElementData(playerid, "player:id"), id)
		if getElementData( element, "doors:ownerType") == 1 and getElementData( element, "doors:ownerID") == getElementData( playerid, "player:id" )
		or query[1].isMember > 1
		or getElementData( element, "doors:ownerType") == 2 and exports.sarp_groups:haveGroupPermission(playerid, getElementData( element, "doors:ownerID"), 16)
		or exports.sarp_admin:getPlayerPermission(playerid, 8)
		or exports.sarp_dynamic_group:getPlayerPermission(getElementData( element, "doors:accessGroup"), playerid, 2) then
			return true
		end
	end
	return false
end

function havePosessionPermission(playerid, doorid, perm)
	local query = exports.sarp_mysql:mysql_result("SELECT `perm` FROM `sarp_doors_members` WHERE `doorid` = ? AND `player_id` = ?", doorid, getElementData(playerid, "player:id"))
		if query[1] and exports.sarp_main:bitAND(query[1].perm, perm) ~= 0 then 
			return true
		end
	return false
end

function isElementInRange(ele, x, y, z, range)
   if isElement(ele) and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(range) == "number" then
      return getDistanceBetweenPoints3D(x, y, z, getElementPosition(ele)) <= range -- returns true if it the range of the element to the main point is smaller than (or as big as) the maximum range.
   end
   return false
end

function saveDoor(id, what)
	local element = getDoorElement(id)
	if what == 'pos' then
		local pX, pY, pZ = getElementPosition( element )
		local exit = getElementData( element, "doors:parent")
		local eX, eY, eZ = getElementPosition( exit )

		exports.sarp_mysql:mysql_change("UPDATE `sarp_doors` SET `posX` = ?, `posY` = ?, `posZ` = ?, `posRot` = ?, `interior` = ?, `dimension` = ?,`exitX` = ?, `exitY` = ?, `exitZ` = ?, `exitRot` = ?, `exitinterior` = ?, `exitdimension` = ?, `lock` = ? WHERE `id` = ?", pX, pY, pZ, getElementRotation( element ), getElementInterior( element ), getElementDimension( element ), eX, eY, eZ, getElementRotation( exit ), getElementInterior( exit ), getElementDimension( exit ), getElementData( element, "doors:lock" ), id)
	elseif what == 'owner' then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_doors` SET `ownerType` = ?, `ownerID` = ?, `accessGroup` = ? WHERE `id` = ?", getElementData( element, "doors:ownerType" ), getElementData( element, "doors:ownerID" ), getElementData( element, "doors:accessGroup"), id)
	elseif what == 'other' then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_doors` SET `description` = ?, `name` = ?, `entry` = ?, `garage` = ?, `objects` = ?, `equipment` = ?, `url` = ? WHERE `id` = ?", getElementData( element, "doors:description" ), getElementData( element, "doors:name" ), getElementData( element, "doors:entry" ), getElementData( element, "doors:garage" ), getElementData( element, "doors:objects" ), getElementData( element, "doors:equipment" ), getElementData( element, "doors:url" ), id)
	end
end