--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local Settings = {
	max_groups = 3
}

local player = {}

function player.spawn(character)
	--sprawdzamy czy taka postać istnieje oraz czy jest przypisana do konta globalnego ( na wszelki wypadek )
	local query = exports.sarp_mysql:mysql_result('SELECT * FROM `sarp_characters` WHERE `global_id` = ? AND `player_id` = ?', getElementData(source, 'global:id'), character)
	
	if not query[1] then
		kickPlayer( source, "Wystąpił błąd podczas wczytywania informacji o twojej postaci. Zgłoś to!" )
	end
	
	if query[1].lastskin == nil or not query[1].lastskin  then
		query[1].lastskin = query[1].skin
	end
	
	-- ustawiamy zmienne dotyczące postaci
	setElementData( source, "player:id", query[1].player_id)
	setElementData( source, "player:skin", query[1].skin )
	setElementData( source, "player:username", query[1].name .. " ".. query[1].surname )
	setElementData( source, "player:bank", query[1].bank )
	setElementData( source, "player:documents", query[1].documents)
	setElementData( source, "player:admin", query[1].admin )
	setElementData( source, "player:age", query[1].age )
	setElementData( source, "player:sex", query[1].sex )
	setElementData( source, "player:hours", tonumber(query[1].hours) )
	setElementData( source, "player:minutes", tonumber(query[1].minutes) )
	setElementData( source, "player:online_today", tonumber(query[1].online_today) )
	setElementData( source, "player:duty", false )
	setElementData( source, "admin:duty", false )
	setElementData( source, "player:mask", false )
	setElementData( source, "player:bw", tonumber(query[1].bw) )
	setElementData( source, "player:aj", tonumber(query[1].aj))
	setElementData( source, "player:anim", false)
	setElementData( source, "player:lastdmg", 0 )
	setElementData( source, "activeoffer", false)
	setElementData( source, "HUD:status", true)
	setElementData( source, "player:dmg", 0)
	setElementData( source, "player:visible", query[1].ukryta )
	setElementData( source, "player:driverPoints", query[1].driverPoints)
	setElementData( source, "player:spawn", {query[1].spawnType, query[1].spawnID})
	setElementData( source, "player:walkStyle", query[1].walking)
	setElementData( source, "player:strength", query[1].strength)
	setElementData( source, "player:drugLevel", query[1].drugLevel)
	setElementData( source, "player:money", query[1].money )
	setElementData( source, "player:health", query[1].hp )
	setElementData( source, "player:maxHealth", 100)
	setElementData( source, "player:logged", true)
	setElementData( source, "player:jobs", query[1].jobs)
	setElementData( source, "player:jobsCash", query[1].jobsCash)
	setElementData( source, "player:jobsCashMax", 300)
	setElementData( source, "newsBar", true)
	for i = 69, 79 do
		setPedStat ( source, i, 200 ) 
	end
	loadMemberGroup(source)

	exports.sarp_logs:createLog('SESSION', string.format("[ID:%d] %s zalogował się na postać %s. (GID: %d, NICK: %s)", getElementData(source, "player:mtaID"), getPlayerName( source ), getElementData(source, "player:username"), getElementData(source, "global:id"), getElementData(source, "global:name")))
	setPlayerName( source, string.gsub(getElementData(source, "player:username"), " ", "_" ))
	setPedWalkingStyle( source, query[1].walking )

	bindKey(source, "F9", "down", function(playerid)
		local status = getElementData( playerid, "HUD:status" )
		triggerClientEvent(playerid, 'showHUD', playerid, not status )
		if getElementData(playerid, "radar:gtaV") then
			triggerClientEvent(playerid, 'showRadar', playerid, not status )
		else
			setPlayerHudComponentVisible( playerid, "radar", not status )
		end
		setElementData( playerid, "HUD:status", not status)
		setElementData( playerid, "radar", not status)
	end)

	setCameraTarget( source )
	showChat( source, true )
	setPlayerBlurLevel ( source, 0 )
	setPlayerHudComponentVisible( source, "crosshair", true )

	--zabezpieczenie przed skokiem życia
	if getElementData( source, "player:maxHealth") < getElementData( source, "player:health") then
		setElementData( source, "player:health", getElementData( source, "player:maxHealth"))
	end

	setElementHealth( source, query[1].hp > 100 and 100 or query[1].hp )

	if getElementData(source, "radar:gtaV") then
		triggerClientEvent(source, 'showRadar', source, true )
	else
		setPlayerHudComponentVisible( source, "radar", true )
	end

	if getElementData(source, "chatOOC") then
		triggerClientEvent(source, "showChatOOC", source, true, false )
	end

	if query[1].aj > 0 then
		spawnPlayer( source, 419.6140, 2536.6030, 10.0000, 0, query[1].lastskin )
		setElementDimension( source, 1000 + query[1].id )
		setElementInterior( source, 10 )
		triggerClientEvent(source, "player:aj", source )
	elseif query[1].qs + 300 > getRealTime().timestamp or query[1].bw > 0 then
		spawnPlayer( source, query[1].posX, query[1].posY, query[1].posZ, 0, query[1].lastskin )
		exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `qs` = 0 WHERE `player_id` = ?", query[1].player_id)
	else
		local pX, pY, pZ, rotation, interior, dimension = getSpawnPosition(source)

		spawnPlayer( source, pX, pY, pZ, rotation, query[1].lastskin, interior, dimension )
	end
	setElementRotation( source, 0, 0, 0 )
	setCameraTarget( source )

	triggerEvent( "objects:load", root, source, getElementDimension( source ), getElementInterior( source ) )
	triggerClientEvent(source, 'showHUD', source, true )

	--wczytujemy grupy dynamiczne gracza
	triggerEvent( "loadPlayerDynamicGroup", root, source )


	local globname = getElementData( source, "global:name" )
	local globid = getElementData( source, "global:id" )
	sendMessage( source, "Witaj #25bd00".. globname.."#FFFFFF (GID: ".. globid ..")")
	sendMessage( source, "Zalogowałeś się na postać: #25bd00".. getElementData(source, "player:username") .." #FFFFFF(UID: ".. getElementData(source, "player:id") ..", mtaID: ".. getElementData(source, "player:mtaID") .. ")" )

	if exports.sarp_admin:getPlayerPermission(source, 512) then
		sendMessage( source, string.format("Ranga: %s%s", getElementData(source, "global:color"), getElementData(source, "global:rank")))
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `online` = 1, `last` = ? WHERE `player_id` = ?", getRealTime().timestamp, query[1].player_id)
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_log` VALUES (0, 1, 1, ?, 0, 0, ?, ?)", query[1].player_id, getRealTime().timestamp, getPlayerIP( source ))
	exports.sarp_notify:addNotify(source, "Zostałeś zalogowany. Miłej gry!")
end

addEvent("spawnPlayer", true)
addEventHandler( "spawnPlayer", root, player.spawn )

function loadMemberGroup(playerid)
	--usuwamy grupy jeżeli są
	for i = 1, 3 do
		local groupid = getElementData(playerid, "group_"..i..":id")
		if groupid then
			removeElementData( playerid, "group_".. i ..":id" )
			removeElementData( playerid, "group_".. i ..":name" )
			removeElementData( playerid, "group_".. i ..":rank" )
			removeElementData( playerid, "group_".. i ..":perm" )
			removeElementData( playerid, "group_".. i ..":skin" )
			removeElementData( playerid, "group_".. i ..":duty_time" )
		end
	end

	local groups = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_group_member` WHERE `player_id`= ?", getElementData(playerid, "player:id" ))

	for i = 1, #groups do
		local groupsname = exports.sarp_mysql:mysql_result("SELECT `name` FROM `sarp_groups` WHERE `id`= ?", groups[i].group_id)
		if not groupsname then return end
		setElementData(playerid, "group_".. i ..":id", groups[i].group_id)
		setElementData(playerid, "group_".. i ..":name", groupsname[1].name)
		setElementData(playerid, "group_".. i ..":rank", groups[i].rank)
		setElementData(playerid, "group_".. i ..":perm", groups[i].perm)
		setElementData(playerid, "group_".. i ..":skin", groups[i].skin)
		setElementData(playerid, "group_".. i ..":duty_time", groups[i].duty_time)
	end
end

function reloadMemberGroup(groupid)
	for i, v in ipairs(getElementsByType( "player" )) do
		if isPlayerLogged(v) then
			for i = 1, 3 do
				if getElementData(v, "group_"..i..":id") and getElementData(v, "group_"..i..":id") == groupid then
					loadMemberGroup(v)
					break
				end
			end
		end
	end
end

function getPlayersInGroup(groupid)
	local players = {}
	for i, v in pairs(getElementsByType( "player")) do
		if isPlayerLogged(v) then
			for j = 1, 3 do
				if getElementData(v, "group_"..j..":id") and getElementData(v, "group_"..j..":id") == groupid then
					table.insert(players, v)
				end
			end
		end
	end

	return players
end

function getPlayerElement(UID)
	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData(v, "player:mtaID") == UID then
			return v
		end
	end
	return false
end

function getSpawnPosition(playerid)
	local spawn = getElementData(playerid, "player:spawn")

	local pX, pY, pZ, rotation, interior, dimension = 0, 0, 0, 0, 0, 0
	--spawn główny
	if spawn[1] == 0 then
		if spawn[2] == 0 then
			pX, pY, pZ = 1129.09765625, -1467.6455078125, 15.730888366699
		end
		if spawn[2] == 1 then
			pX, pY, pZ = 1129.09765625, -1467.6455078125, 15.730888366699
		end
	
	--hotel
	elseif spawn[1] == 1 then
		local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_hotel` WHERE `door_id` = ? AND `player_id` = ?", spawn[2], getElementData(playerid, "player:id"))
		
		if not query[1] or query[1].date < getRealTime().timestamp then
			setElementData(playerid, "player:spawn", {0, 0})
			return getSpawnPosition(playerid)
		end

		local position = exports.sarp_doors:getDoorData(query[1].door_id, {"exitX", "exitY", "exitZ", "exitRot", "exitinterior", "exitdimension"})

		if not position then
			setElementData(playerid, "player:spawn", {0, 0})
			return getSpawnPosition(playerid)
		end

		bindKey(playerid, "E", "down", function(playerid, pos)
			setElementPosition( playerid, position.exitX, position.exitY, position.exitZ )
			setElementInterior( playerid, position.exitinterior )
			setElementDimension( playerid, position.exitdimension )
			unbindKey( playerid, "E", "down" )
			setElementData(playerid, "player:inHotel", false)
		end, playerid, position)
		setElementData(playerid, "player:inHotel", query[1].door_id)

		pX, pY, pZ, rotation, interior, dimension = 2233.173828125, -1112, 1050.8828125, 180, 5, 1000 + getElementData(playerid, "player:id")
	--domy
	elseif spawn[1] == 2 then
		local door = exports.sarp_doors:getDoorData(spawn[2], {"exitX", "exitY", "exitZ", "exitRot", "exitinterior", "exitdimension", "ownerType", "ownerID"})

		if not door or door.ownerType ~= 1 or door.ownerID ~= getElementData(playerid, "player:id") then
			setElementData(playerid, "player:spawn", {0, 0})
			return getSpawnPosition(playerid)
		end

		pX, pY, pZ, rotation, interior, dimension = door.exitX, door.exitY, door.exitZ, door.exitRot, door.exitinterior, door.exitdimension
	end

	return pX, pY, pZ, rotation, interior, dimension
end

function savePlayer(playerid)
	if isPlayerLogged(playerid) then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `skin` = ?, `lastskin` = ?, `money` = ?, `bank` = ?, `hp` = ?, `hours` = ?, `minutes` = ?, `online_today` = ?, `bw` = ?, `aj` = ?, `documents` = ?, `walking` = ? WHERE `player_id` = ?",
				getElementData(playerid, "player:skin"),
				getElementModel(playerid),
				getElementData( playerid, "player:money"),
				getElementData(playerid, "player:bank"),
				getElementHealth( playerid ),
				getElementData(playerid, "player:hours"),
				getElementData(playerid, "player:minutes"),
				getElementData(playerid, "player:online_today"),
				getElementData(playerid, "player:bw"),
				getElementData(playerid, "player:aj"),
				getElementData(playerid, "player:documents"),
				getElementData(playerid, "player:walking"),
				getElementData(playerid, "player:id"))
		exports.sarp_mysql:mysql_change("UPDATE `core_members` SET `score` = ? WHERE `member_id` = ?", getElementData( playerid, "global:score"), getElementData( playerid, "global:id"))
	end
end

addEvent("savePlayer", true)
addEventHandler("savePlayer", root, savePlayer)

function player.qs(qtype)
	if qtype == "Kicked" or qtype == "Bad Connection" or qtype == "Timed out" or (getElementData(source, "player:logged") and getElementData(source, "player:bw") > 0) then
		if isPlayerLogged(source) then
			local pX, pY, pZ = getElementPosition( source )
			exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `posX` = ?, `posY` = ?, `posZ` = ?, `qs` = ? WHERE `player_id` = ?", pX, pY, pZ, getRealTime().timestamp, getElementData(source, "player:id"))
		end
	end
	if isPlayerLogged(source) then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `online` = 0 WHERE `player_id` = ?", getElementData(source, "player:id"))
		savePlayer(source)
	end
end

addEventHandler( "onPlayerQuit", root, player.qs )

function serverStop()
	for i, v in ipairs(getElementsByType( "player" )) do
		if isElement(v) and getElementData(v, "player:logged") then
			exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `online` = 0 WHERE `player_id` = ?", getElementData(v, "player:id"))
			savePlayer( v )
		end
	end
end

addEventHandler( "onResourceStop", root, player.qs )

function player.onDamage(attacker, weapon, body, loss)
	cancelEvent()
	local newHP = getElementData(source, "player:health") - loss
	local maxHP = getElementData(source, "player:maxHealth")
	setElementData(source, "player:health", newHP)
	setElementHealth( source, newHP > maxHP and maxHP or newHP )
end

addEventHandler( "onPlayerDamage", root, player.onDamage )

function isPlayerLogged(playerid)
	if playerid == false then return false end
	
	if isElement(playerid) and getElementData(playerid, "player:logged") then
		return true
	end
	return false
end

function givePlayerCash(playerid, cash)
	cash = tonumber(cash)

	setElementData( playerid, "player:money", getElementData( playerid, "player:money" ) + cash )
	savePlayer(playerid)
end

function player.changeWalkingStyle(style)
		setPedWalkingStyle( source, style )
		setElementData(source, "player:walking", style)
end

addEvent('changeWalkingStyle', true)
addEventHandler( 'changeWalkingStyle', root, player.changeWalkingStyle )

--Komendy
local cmd = {}

function cmd.qs(playerid)
	if isPlayerLogged(playerid) then
		savePlayer(playerid)
		local pX, pY, pZ = getElementPosition( playerid )
		exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `posX` = ?, `posY` = ?, `posZ` = ?, `qs` = ? WHERE `player_id` = ?", pX, pY, pZ, getRealTime().timestamp, getElementData(playerid, "player:id"))
		kickPlayer( playerid, "" )
	end
end

addCommandHandler( "qs", cmd.qs )

function cmd.q(playerid)
	savePlayer(playerid)
	kickPlayer( playerid, "" )
end

addCommandHandler( "q", cmd.q )