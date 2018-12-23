--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function getZoneID(id)
	for i, v in ipairs(getElementsByType( "colshape" )) do
		if getElementData(v, "isZone") and getElementData(v, "zoneID") == id then
			return v
		end
	end
	return false
end

function createZone(pX, pY, pZ, dimension, interior, pW, pD, pH)
	local id = 1
	local colshape = getElementsByType( "colshape" )
	while colshape[id] and getZoneID(id) do
		id = id + 1
	end

	local element = createColCuboid( pX, pY, pZ, pW, pD, pH )
	setElementData(element, "isZone", true)
	setElementData(element, "zoneID", id)
	setElementData(element, "zoneOwnerType", 0)
	setElementData(element, "zoneOwner", 0)
	setElementData(element, "zonePermission", 0)

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_zones` SET `id` = ?, `posX` = ?, `posY` = ?, `posZ` = ?, `dimension` = ?, `interior` = ?, `width` = ?, `height` = ?, `depth` = ?", id, pX, pY, pZ, dimension, interior, pW, pH, pD)

	return id
end

function deleteZone(id)
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_zones` WHERE `id` = ?", getElementData(id, "zoneID"))
	destroyElement( id )
end

function isZoneOwner(playerid, zoneElement)
	if getElementData(zoneElement, "zoneOwnerType") == 1 and getElementData(zoneElement, "zoneOwner") == getElementData(playerid, "player:id")
	or getElementData(zoneElement, "zoneOwnerType") == 2 and exports.sarp_groups:isPlayerInGroup(playerid, getElementData(zoneElement, "zoneOwner")) then
		return true
	end
	return false
end

function haveZonePermission(playerid, permission, zoneOwner)
	local zoneList = detectPlayerZone(playerid)
	if #zoneList == 0 then return false end

	local isOwner = false
	if zoneOwner then
		for i, v in ipairs(zoneList) do
			if isZoneOwner(playerid, v) then
				isOwner = true
				break
			end
		end

		if not isOwner then
			return false
		end 
	end

	for i, v in ipairs(zoneList) do
		if exports.sarp_main:bitAND(getElementData(v, "zonePermission"), permission) ~= 0 then
			return true, v, getElementData(v, "zoneOwner")
		end
	end

	return false
end