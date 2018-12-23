--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

--[[
	Głównym założeniem jest wczytywanie tylko tych grup, których gracze są w grze aby zużywać jak najmniej pamięci i nie wysyłać
	zbędnych zapytań do bazy danych.
]]

local dGroup = {}
local groupsData = {}

function dGroup.onStart()
	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData( v, "player:logged") then
			loadPlayerDynamicGroup(v)
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot, dGroup.onStart )

function getGroupDataID(id)
	for i, v in ipairs(groupsData) do
		if v.id == id then
			return i
		end
	end

	return false
end

function getPlayerPermission(groupID, playerid, perm)
	local id = getGroupDataID(groupID)

	if not id then return false end

	for i, v in ipairs(groupsData[id].members) do
		if v.mtaID == playerid then
			if exports.sarp_main:bitAND(v.permissions, perm) ~= 0 then
				return true
			else
				return false
			end
		end
	end

	return false
end

function loadPlayerDynamicGroup(playerid)
	local pGroup = exports.sarp_mysql:mysql_result("SELECT `ownerID` FROM `sarp_dynamic_groups_members` WHERE `player_id` = ?", getElementData(playerid, "player:id"))

	if not pGroup[1] then return false end

	for i, v in ipairs(pGroup) do
		local groupID = getGroupDataID(v.ownerID)
		if not groupID then
			local group = exports.sarp_mysql:mysql_result("SELECT `id`, `name`, `owner_id`, `cash` FROM `sarp_dynamic_groups` WHERE `id` = ?", v.ownerID)

			if not group[1] then return end

			local groupMember = exports.sarp_mysql:mysql_result("SELECT g.`player_id`, c.`name`, c.`surname`, g.`permissions` FROM `sarp_dynamic_groups_members` g, `sarp_characters` c WHERE g.`ownerID` = ? AND c.`player_id` = g.`player_id`", group[1].id)

			if not groupMember[1] then return end

			table.insert(groupsData, {
				id = group[1].id,
				name = group[1].name,
				owner = group[1].owner_id,
				cash = group[1].cash,
				members = {}
			})

			local id = #groupsData

			for i, v in ipairs(groupMember) do
				table.insert(groupsData[id].members, {
					player_id = v.player_id,
					username = v.name.." "..v.surname,
					permissions = v.permissions,
					mtaID = getElementData(playerid, "player:id") == v.player_id and playerid or nil
				})
			end
		else
			for i, v in ipairs(groupsData[groupID].members) do
				if v.player_id == getElementData(playerid, "player:id") then
					v.mtaID = playerid
				end
			end
		end
	end
end

addEvent("loadPlayerDynamicGroup", true)
addEventHandler( "loadPlayerDynamicGroup", root, loadPlayerDynamicGroup )

function dGroup.create(name)
	--sprawdzamy liczbę grup
	local count = 0
	for i, v in ipairs(groupsData) do
		for j, k in ipairs(v.members) do
			if k.mtaID == source then
				count = count + 1
			end
		end
	end

	if count >= 2 then
		return exports.sarp_notify:addNotify("Maksymalnie możesz przynależeć do 2 grup dynamicznych.")
	end

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_dynamic_groups` SET `name` = ?, `owner_id` = ?", name, getElementData(source, "player:id"))
	local id = exports.sarp_mysql:mysql_result("SELECT `id` FROM `sarp_dynamic_groups` WHERE `owner_id` = ? ORDER BY `id` DESC", getElementData(source, "player:id"))[1].id or 0
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_dynamic_groups_members` SET `player_id` = ?, `ownerID` = ?, `permissions = ?`", getElementData(source, "player:id"), id, 7 )
	loadPlayerDynamicGroup(source)
	showDynamicGroup(source)
end

addEvent("createDynamicGroup", true)
addEventHandler( "createDynamicGroup", root, dGroup.create )

function dGroup.setName(mainID, name)
	local id = getGroupDataID(mainID)
	if groupsData[id].owner ~= getElementData( source, "player:id") then 
		return exports.sarp_notify:addNotify(source, "Ta opcja dostępna jest tylko dla właściciela grupy dynamicznej.") 
	end

	groupsData[id].name = name
	exports.sarp_mysql:mysql_change("UPDATE `sarp_dynamic_groups` SET `name` = ? WHERE `id` = ?", name, mainID)
	showDynamicGroup(source, mainID)
end

addEvent("setNameDynamicGroup", true)
addEventHandler( "setNameDynamicGroup", root, dGroup.setName )

function dGroup.memberKick(mainID, playerID)
	local id = getGroupDataID(mainID)

	if groupsData[id].owner ~= getElementData(source, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

	if groupsData[id].owner == playerID then
		return exports.sarp_notify:addNotify(source, "Wyrzucenie właściciela grupy nie jest możliwe.")
	end

	for i, v in ipairs(groupsData[id].members) do
		if playerID == v.player_id then
			table.remove(groupsData[id].members, i)
			break
		end
	end

	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_dynamic_groups_members` WHERE `player_id` = ? AND `ownerID` = ?", playerID, mainID)
	exports.sarp_notify:addNotify(source, "Gracz został wyrzucony z grupy.")
	showDynamicGroup(source, mainID, 2)
end

addEvent("memberKickDynamicGroup", true)
addEventHandler( "memberKickDynamicGroup", root, dGroup.memberKick )

function dGroup.memberSave(mainID, playerID, perm)
	local id = getGroupDataID(mainID)

	if groupsData[id].owner ~= getElementData(source, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

	if groupsData[id].owner == playerID then
		return exports.sarp_notify:addNotify(source, "Manipulowanie uprawnieniami właściciela nie jest możliwe.")
	end

	for i, v in ipairs(groupsData[id].members) do
		if playerID == v.player_id then
			v.permissions = perm
			break
		end
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_dynamic_groups_members` SET `permissions` = ? WHERE `player_id` = ? AND `ownerID` = ?", perm, playerID, mainID)
	exports.sarp_notify:addNotify(source, "Uprawnienia gracza zostały zapisane.")
	showDynamicGroup(source, mainID, 2)
end

addEvent("memberSaveDynamicGroup", true)
addEventHandler( "memberSaveDynamicGroup", root, dGroup.memberSave )

function dGroup.vehicleSpawn(mainID, vehID)
	local spawn = exports.sarp_vehicles:setVehicleSpawnState(vehID)

	if not getPlayerPermission(mainID, source, 1) then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

	exports.sarp_notify:addNotify(source, string.format("Pojazd został %s.", spawn and "zespawnowany" or "odspawnowany"))
	showDynamicGroup(source, mainID, 3)
end

addEvent("vehicleSpawnDynamicGroup", true)
addEventHandler("vehicleSpawnDynamicGroup", root, dGroup.vehicleSpawn)

function dGroup.leave(mainID)
	local id = getGroupDataID(mainID)

	if groupsData[id].owner == getElementData(source, "player:id") then
		table.remove(groupsData, id)
		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_dynamic_groups` WHERE `id` = ?", mainID)
		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_dynamic_groups_members` WHERE `ownerID` = ?", mainID)
	else
		for i, v in ipairs(groupsData[id].members) do
			if groupsData[id].player_id == getElementData(source, "player:id") then
				table.remove(groupData[id].members, i)
			end
		end
		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_dynamic_groups_members` WHERE `ownerID` = ? AND `player_id`", mainID, getElementData( source, "player:id"))
	end
end

addEvent("leaveDynamicGroup", true)
addEventHandler( "leaveDynamicGroup", root, dGroup.leave )

function dGroup.add(playerElement, mainID)
	if groupsData[id].owner ~= getElementData(source, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

	local id = getGroupDataID(mainID)

	for i, v in ipairs(groupsData[id].members) do
		if v.player_id == getElementData(playerElement, "player:id") then
			return exports.sarp_notify:addNotify(source, "Ten gracz przynależy już do tej grupy!")
		end
	end

	local count = 0
	for i, v in ipairs(groupsData) do
		for j, k in ipairs(v.members) do
			if k.mtaID == playerElement then
				count = count + 1
			end
		end
	end

	if count >= 2 then
		return exports.sarp_notify:addNotify("Maksymalnie możesz przynależeć do 2 grup dynamicznych.")
	end

	table.insert(groupsData[id].members, {
		player_id = getElementData(playerElement, "player:id"),
		username = getElementData(playerElement, "player:username"),
		permissions = 0,
		mtaID = getElementData(playerid, "player:id")
	})
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_dynamic_groups_members` SET `player_id` = ?, `ownerID` = ?", getElementData(playerElement, "player:id"), mainID)
	showDynamicGroup(source, mainID, 2)
end

addEvent("memberAddDynamicGroup", true)
addEventHandler( "memberAddDynamicGroup", root, dGroup.add )

function dGroup.doorKick(mainID, doorID)
	local id = getGroupDataID(mainID)

	if groupsData[id].owner ~= getElementData(source, "player:id") and not exports.sarp_doors:isDoorOwner(source, doorID, true) then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

	for i, v in ipairs(getElementsByType( "marker" )) do
		if getElementData(v, "type:doors") and not getElementData(v, "doors:exit") and getElementData(v, "doors:id") == doorID then
			setElementData( v, "doors:accessGroup", 0)
		end
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_doors` SET `accessGroup` = ? WHERE `id` = ?", 0, mainID)
	showDynamicGroup(source, mainID, 4)
end

addEvent("doorKickDynamicGroup", true)
addEventHandler( "doorKickDynamicGroup", root, dGroup.doorKick )

function dGroup.vehicleKick(mainID, vehicleID)
	local id = getGroupDataID(mainID)

	local ownerID = false

	if groupsData[id].owner ~= getElementData(source, "player:id") and not exports.sarp_vehicles:isVehicleOwner(source, vehicleID, true, true) then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

	exports.sarp_vehicles:setVehicleData(vehicleID, "accessGroup", 0)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_vehicles` SET `accessGroup` = ? WHERE `id` = ?", 0, vehicleID)
	showDynamicGroup(source, mainID, 3)
end

addEvent("vehicleKickDynamicGroup", true)
addEventHandler( "vehicleKickDynamicGroup", root, dGroup.vehicleKick )

function dGroup.showPlayer(elementType, elementID)
	local groupData = {}
	for i, v in ipairs(groupsData) do
		for j, k in ipairs(v.members) do
			if k.mtaID == source then
				table.insert(groupData, {id = v.id, name = v.name})
			end
		end
	end

	triggerClientEvent( source, "showPlayerDynamicGroup", root, groupData, {elementType, elementID} )
end

addEvent("showPlayerDynamicGroup", true)
addEventHandler( "showPlayerDynamicGroup", root, dGroup.showPlayer )

function dGroup.onQuit()
	--wypierdalamy jeżeli trzeba
	for i, v in ipairs(groupsData) do
		for j, k in ipairs(v.members) do
			if k.mtaID == source then
				local online = 0

				for g, h in ipairs(v.members) do
					if isElement(h.mtaID) then
						online = online + 1
					end
				end

				if online > 1 then
					k.mtaID = nil
				else
					table.remove(groupsData, i)
				end
			end
		end
	end
end

addEventHandler( "onPlayerQuit", root, dGroup.onQuit )

function showDynamicGroup(playerid, groupID, tabID)
	local groupData = {}
	for i, v in ipairs(groupsData) do
		for j, k in ipairs(v.members) do
			if k.mtaID == playerid then
				table.insert(groupData, v)
			end
		end
	end

	for i, v in ipairs(groupData) do
		groupData[i].vehicles = exports.sarp_vehicles:getDynamicGroupVehicles(v.id) or nil
	end

	--imie i nazwisko właściciela
	for i, v in ipairs(groupData) do
		for j, k in ipairs(v.members) do
			if v.owner == k.player_id then
				v.ownerName = k.username
			end
		end
	end

	triggerClientEvent( playerid, "showDynamicGroup", playerid, groupData, groupID, tabID )
end

function dGroup.cmd(playerid, cmd, ...)
	local params = {...}
	local slot, shortcut = tonumber(params[1]), tostring(params[2])

	if not slot then
		return showDynamicGroup(playerid)
	end

	local groupData = {}
	for i, v in ipairs(groupsData) do
		for j, k in ipairs(v.members) do
			if k.mtaID == playerid then
				table.insert(groupData, i)
			end
		end
	end

	if not groupData[slot] then
		return exports.sarp_notify:addNotify("Na tym slocie nie posiadasz żadnej grupy.")
	end

	local id = groupData[slot]

	if shortcut == 'wplac' then
		local doorid = getElementData(playerid, "player:door")
		if not exports.sarp_doors:isDoorGroupType(doorid, 22) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w budynku banku.")
		end

		local cash = math.floor(tonumber(params[3]) or 0)

		if not cash then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /gd [slot (1-2)] wplac [kwota]")
		end

		local pMoney = getElementData(playerid, "player:money")
		if cash <= 0 or cash > pMoney then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz takiej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(playerid, - cash)
		groupsData[id].cash = groupsData[id].cash + cash
		exports.sarp_mysql:mysql_change("UPDATE `sarp_dynamic_groups` SET `cash` = ? WHERE `id` = ?", groupsData[id].cash, groupsData[id].id)

		exports.sarp_notify:addNotify(playerid, "Pieniądze zostały wpłacone na konto grupy dynamicznej.")
	elseif shortcut == 'wyplac' then
		 local doorid = getElementData(playerid, "player:door")

		if not exports.sarp_doors:isDoorGroupType(doorid, 22) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w budynku banku.")
		end

		if not getPlayerPermission(groupsData[id].id, playerid, 4) then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do wykonania tej czynności.")
	end

		local cash = math.floor(tonumber(params[3]) or 0)

		if not cash then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /gd [slot (1-2)] wyplac [kwota]")
		end

		local gMoney = groupsData[id].cash
		if cash <= 0 or cash > gMoney then
			return exports.sarp_notify:addNotify(playerid, "Na koncie grupy dynamicznej nie ma takiej ilości gotówki.")
		end

		groupsData[id].cash = groupsData[id].cash - cash
		exports.sarp_mysql:mysql_change("UPDATE `sarp_dynamic_groups` SET `cash` = ? WHERE `id` = ?", groupsData[id].cash, groupsData[id].id)
		exports.sarp_main:givePlayerCash(playerid, cash)
		exports.sarp_notify:addNotify(playerid, "Pieniądze zostały wypłacone z konta grupy dynamicznej.")
	else
		return exports.sarp_notify:addNotify(playerid, "Użyj: /gd [slot (1-2)] [wplac, wyplac]")
	end

end

addCommandHandler( "gd", dGroup.cmd )