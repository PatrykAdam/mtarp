--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local admin = {}

function admin.panel(playerid)
	if not exports.sarp_admin:getPlayerPermission(playerid, 128) then return end

	admin.reload(playerid)
end

function admin.group_create(name, type, tag, color, bank)
	local id = createGroup( tostring(name), tonumber(type), tostring(tag), color, tonumber(bank))

	exports.sarp_notify:addNotify(source, string.format("Stworzyłeś grupę o ID: %d.", id))
	admin.reload(source)
end

addEvent("admin:group_create", true)
addEventHandler( "admin:group_create", root, admin.group_create )

function admin.group_playerKick(player, groupid)
	member_delete(player, groupid)
	admin.reload(source)
end

addEvent("admin:group_playerKick", true)
addEventHandler( "admin:group_playerKick", root, admin.group_playerKick )

function admin.group_playerSave(player, groupid, data)
	local playerid = exports.sarp_main:getPlayerFromID(player)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_group_member` SET `perm` = ? WHERE `player_id` = ? AND `group_id` = ?",
						data.perm,
						getElementData(playerid, "player:id"),
						groupid)
	
	if playerid then
		exports.sarp_main:loadMemberGroup(playerid)
	end

	admin.reload(source)
end

addEvent("admin:group_playerSave", true)
addEventHandler( "admin:group_playerSave", root, admin.group_playerSave )

function admin.group_playerAdd(player, groupid)
	member_add(player, groupid)
	admin.reload(source)
end

addEvent("admin:group_playerAdd", true)
addEventHandler( "admin:group_playerAdd", root, admin.group_playerAdd )

function admin.reload(playerid)
	triggerClientEvent( playerid, "admin:group", playerid, groupsData)
end

function admin.group_edit(id, data)
	if not groupsData[id] then return end

	local playerid = exports.sarp_main:getPlayerFromID(tonumber(data.leader))

	groupsData[id].name = data.name
	groupsData[id].tag = data.tag
	groupsData[id].type = data.type
	groupsData[id].bank = data.bank
	groupsData[id].color = data.color

	if playerid then
		groupsData[id].leader = getElementData(playerid, "player:id")
	end
	saveGroup(id)

	admin.reload(source)
	exports.sarp_notify:addNotify(source, "Ustawienia grupy zostały zaaktualizowane.")
end

addEvent("admin:group_edit", true)
addEventHandler( "admin:group_edit", root, admin.group_edit )

function admin.group_delete(id)
	if not groupsData[id] then return end

	deleteGroup(id)

	admin.reload(source)
end

addEvent("admin:group_delete", true)
addEventHandler( "admin:group_delete", root, admin.group_delete )

function admin.groupcmd(playerid, cmd, cmd2, ...)
	
	admin.panel(playerid)
end

addCommandHandler( "ag", admin.groupcmd )