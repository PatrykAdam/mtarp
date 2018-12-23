--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function createGroup(name, type, tag, color, bank)
	local UID = 1
	while groupsData[UID] do
		UID = UID + 1
	end

	groupsData[UID] = {}
	groupsData[UID].id = UID
	groupsData[UID].type = type
	groupsData[UID].name = name
	groupsData[UID].tag = tag
	groupsData[UID].leader = 0
	groupsData[UID].color = color
	groupsData[UID].bank = bank
	groupsData[UID].payday = 0
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_groups` SET `id` = ?, `type` = ?, `name` = ?, `tag` = ?, `color` = ?, `bank` = ?", groupsData[UID].id, groupsData[UID].type, groupsData[UID].name, groupsData[UID].tag, table.concat(groupsData[UID].color, ", "), groupsData[UID].bank)
	outputServerLog( "Utworzona zostala grupa o nazwie: ".. name .."(TAG: ".. tag ..", UID: ".. UID..")" )
	return UID
end

function getPlayersDutyCount(type)
	local count = 0

	for i, v in ipairs(getElementsByType( "player" )) do
		for k = 1, 3 do
			local group = getElementData( v, "group_".. k .. ":id")
			if group and groupsData[group].type == type then
				if getElementData( v, "player:duty") == group then
					count = count + 1
				end
			end
		end
	end

	return count
end

function deleteGroup(id)
	groupsData[id] = nil
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_groups` WHERE `id`= ?", id)
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_group_member` WHERE `group_id` = ?", id)
	exports.sarp_main:reloadMemberGroup(id)
end

function setGroupData(groupid, data, value)
	if groupsData[groupid] and groupsData[groupid][data] then
		groupsData[groupid][data] = value
	end
	saveGroup(groupid)
end

function getGroupData(groupid, data)
	if data then
		if groupsData[groupid] then
			return groupsData[groupid][data]
		else 
			return false
		end
	end
	return groupsData[groupid]
end

function member_add(id, group)
	local playerid = exports.sarp_main:getPlayerFromID(id)
	if isPlayerInGroup(playerid, group) then return end
	if not freeSlot(playerid) then return end
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_group_member` SET `player_id` = ?, `group_id` = ?", getElementData(playerid, "player:id"), group )
	if playerid then
		exports.sarp_main:loadMemberGroup(playerid)
	end
end

function member_delete(id, group)
	local playerid = exports.sarp_main:getPlayerFromID(id)
	if not isPlayerInGroup(playerid, group) then return end
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_group_member` WHERE `player_id` = ? AND `group_id` = ?", getElementData(playerid, "player:id"), group)

	if playerid then
		exports.sarp_main:loadMemberGroup(playerid)
		setElementData(playerid, "player:duty", false)
	end
end

function giveGroupCash(groupid, cash)
	if groupsData[groupid] then
		groupsData[groupid].bank = groupsData[groupid].bank + cash
		saveGroup(groupid)
	end
end

function isDutyInGroupType(playerid, groupType)
	local duty = getElementData(playerid, "player:duty")
	if not groupsData[duty] then return false end

	if type(groupType) == 'table' then
		for i, v in ipairs(groupType) do
			if groupsData[duty].type == v then
				return true
			end
		end
	else
		if groupsData[duty].type == groupType then
			return true
		end
	end
	return false
end

function isGroup(groupid)
	if groupsData[groupid] then
		return true
	end
	return false
end

function freeSlot(playerid)
	for i = 1, 3 do
		local groupid = getElementData(playerid, "group_"..i..":id")
		if not groupid then return true end
	end
	return false
end

function haveGroupPermission(playerid, groupid, perm)
	local gperm = getElementData(playerid, "group_"..groupid..":perm")
		if gperm and exports.sarp_main:bitAND(gperm, perm) ~= 0 then 
			return true
		end
	return false
end

function haveGroupFlags(groupid, flags)
	if groupsData[groupid] and exports.sarp_main:bitAND(groupsData[groupid].flags, flags) == 0 then return false else return true	end
end


function saveGroup(id)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_groups` SET `name` = ?, `tag` = ?, `leader` = ?, `color` = ?, `type` = ?, `bank` = ? WHERE `id` = ?",
			groupsData[id].name,
			groupsData[id].tag,
			groupsData[id].leader,
			table.concat(groupsData[id].color, ", "),
			groupsData[id].type,
			groupsData[id].bank,
			id)
end

function cuffPlayer(playerid, playerid2)
	local cuff = getElementData(playerid2, "player:cuffed")
	local playerName = exports.sarp_main:getPlayerRealName(playerid2)

	if not cuff then
		if getPedOccupiedVehicle( playerid2 ) then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz skuć gracza, który znajduje się w pojeździe.")
		end

		if getElementData(playerid, "cuffedPlayer") then
			return exports.sarp_notify:addNotify(playerid, "Masz już skutą jakąś osobe.")
		end

		if getElementData(playerid2, "player:cuffed") then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz jest już skuty.")
		end

		attachElements( playerid2, playerid, 0, 0.5 )
		triggerEvent( "main:me", playerid, string.format("nakłada kajdanki dla %s.", playerName))
		setElementData( playerid2, "player:cuffed", true )
		setElementData( playerid, "cuffedPlayer", playerid2)
		toggleControl( playerid2, "fire", false )
		toggleControl( playerid2, "aim_weapon", false )
	else
		detachElements( playerid2, playerid )
		triggerEvent( "main:me", playerid, string.format("ściąga kajdanki dla %s.", playerName))
		setElementData( playerid2, "player:cuffed", false )
		setElementData( playerid, "cuffedPlayer", false)
		toggleControl( playerid2, "fire", true )
		toggleControl( playerid2, "aim_weapon", true )
	end
end

addEvent('cuffPlayer', true)
addEventHandler( 'cuffPlayer', root, cuffPlayer )

function getGroupLevelValue(groupid, value)
	local gType = groupsData[groupid].type
	local lvl = groupsData[groupid].level
	if lvl > 5 or lvl < 1 then lvl = 1	end

	if type(value) == 'table' then
		for i, v in ipairs(value) do
			local valueData = {}

			local output = groupsLVL[gType][lvl][v]

			if value then
				if output == "true" then
					output = true
				end

				if output == 'false' then
					output = false
				end

				valueData[v] = output
			end
		end
		return #valueData > 0 and valueData or false
	else
		local output = groupsLVL[gType][lvl][value]

		if output then
			if output == "true" then
				output = true
			end

			if output == 'false' then
				output = false
			end
			return output
		end
	end

	return false
end

function isPlayerInGroupType(playerid, type)
	for i = 1, 3 do
		local groupid = getElementData(playerid, string.format("group_%d:id", i))

		if groupid and groupsData[groupid].type == type then
			return true
		end
	end
	
	return false
end