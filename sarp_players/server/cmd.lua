--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local cmd = {}

function cmd.plac(playerid, cmd, playerid2, money)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	playerid2, money = exports.sarp_main:getPlayerFromID(playerid2), math.floor((tonumber(money)))

	if getDistanceToElement(playerid, playerid2) > 3.0 then
		return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
	end

	if not money or not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /plac [id gracza] [ilość]")
	end

	if money > getElementData(playerid, "player:money") or money <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz takiej ilości gotówki.")
	end
	local name = exports.sarp_main:getPlayerRealName(playerid2)
	triggerEvent( "main:me", playerid, string.format("przekazuje gotówkę dla %s.", name))
	exports.sarp_main:givePlayerCash(playerid, -money)
	exports.sarp_main:givePlayerCash(playerid2, money)
	exports.sarp_notify:addNotify(playerid, string.format("Przekazałeś %d$ dla %s.", money, name) )
	exports.sarp_notify:addNotify(playerid2, string.format("Otrzymałeś %d$ od %s.", money, exports.sarp_main:getPlayerRealName(playerid)) )
	exports.sarp_logs:createLog('CASH', string.format("[UID:%d] %s przekazał %d$ dla [UID:%d] %s.", getElementData(playerid, "player:id"), getElementData(playerid, "player:username"), money, getElementData(playerid2, "player:id"), getElementData(playerid2, "player:username")))
end
addCommandHandler( "plac", cmd.plac )

function cmd.kup(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local doorid = getElementData(playerid, "player:door")
	if not doorid then return false end

	local groupid = getElementData(doorid, "doors:ownerID")
	local sklep, odziezowy = exports.sarp_doors:isDoorGroupType(doorid, 19), exports.sarp_doors:isDoorGroupType(doorid, 21)

	if not doorid or not groupid or not sklep and not odziezowy then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz użyć tej komendy w tym miejscu.")
	end

	if sklep then
		local productList = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_magazine` WHERE `groupid` = ?", groupid)

		if #productList == 0 then
			return exports.sarp_notify:addNotify(playerid, "Brak produktów w sklepie.")
		end

		triggerClientEvent(playerid, "buyList", playerid, productList)
	end

	if odziezowy then
		setElementData(playerid, "player:lastskin", getElementModel( playerid ))
		triggerClientEvent(playerid, "buySkin", playerid )
	end
end
addCommandHandler( "kup", cmd.kup )

function cmd.opis(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local params = {...}

	if params[1] == 'usun' then
		local vehicle = getPedOccupiedVehicle( playerid )
		if vehicle and getVehicleOccupant( vehicle ) == playerid and exports.sarp_vehicles:isVehicleOwner(playerid, getElementData(vehicle, "vehicle:id")) then
			setElementData(vehicle, "vehicle:desc", '')
			triggerClientEvent( "changeDescription", vehicle )
			exports.sarp_notify:addNotify(playerid, "Opis pojazdu został usunięty.")
		else
			setElementData(playerid, "player:desc", '')
			triggerClientEvent( "changeDescription", playerid )
			exports.sarp_notify:addNotify(playerid, "Opis postaci został usunięty.")
		end
	else
		local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_desc` WHERE `char_id` = ?", getElementData( playerid, "player:id" ))
		triggerClientEvent( 'showDescription', playerid, query )
	end
end
addCommandHandler( "opis", cmd.opis )

function cmd.stats(playerid, cmd, playerid2)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	playerid2 = exports.sarp_main:getPlayerFromID(playerid2)

	if exports.sarp_admin:getPlayerPermission(playerid, 512) and isElement(playerid2) then
		triggerClientEvent( 'stats:show', playerid, playerid2 )
	else
		triggerClientEvent( 'stats:show', playerid, playerid )
	end
end

addCommandHandler( "stats", cmd.stats )

function cmd.w(playerid, cmd, playerid2, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local message, playerid2 = {...}, exports.sarp_main:getPlayerFromID(playerid2)
	message = table.concat( message, " ", 1, #message )

	if message == '' or not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /w [playerid] [wiadomość]")
	end


	if getElementData(playerid2, "blockPW") then
		return exports.sarp_notify:addNotify(playerid, "Gracz o podanym id zablokował otrzymywanie wiadomości.")
	end

	local text

	text = string.format("(( %s (%d): %s ))", exports.sarp_main:getPlayerRealName(playerid2), getElementData(playerid2, "player:mtaID"), message)
	triggerClientEvent( "addPlayerOOCMessage", playerid, text, 241, 206, 150 )
	text = string.format("(( %s (%d): %s ))", exports.sarp_main:getPlayerRealName(playerid), getElementData(playerid, "player:mtaID"), message)
	triggerClientEvent( "addPlayerOOCMessage", playerid2, text, 255, 188, 93 )
	exports.sarp_logs:createLog('PW', string.format('[UID: %d] %s wysyła wiadomość do [UID: %d] %s: %s', getElementData(playerid, "player:id"), getElementData(playerid, "player:username"), getElementData(playerid2, "player:id"), getElementData(playerid2, "player:username"), message))

	setElementData(playerid, "lastPlayerMSG", playerid2)
	setElementData(playerid2, "lastPlayerMSG", playerid)
end

addCommandHandler( "w", cmd.w )

function cmd.re(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local message = table.concat( {...}, " ", 1, #{...} )
	local playerid2 = getElementData(playerid, "lastPlayerMSG")
	if not isElement(playerid2) then
		return exports.sarp_notify:addNotify(playerid, "Nie pisałeś ostatnio z żadną osobą.")
	end

	if message == '' then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /re [wiadomość]")
	end

	if playerid == playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz wysłać wiadomości do siebie.")
	end

	if getElementData(playerid2, "blockPW") then
		return exports.sarp_notify:addNotify(playerid, "Gracz o podanym id zablokował otrzymywanie wiadomości.")
	end
	
	local text

	text = string.format("(( %s (%d): %s ))", exports.sarp_main:getPlayerRealName(playerid2), getElementData(playerid2, "player:mtaID"), message)
	triggerClientEvent( "addPlayerOOCMessage", playerid, text, 241, 206, 150 )
	text = string.format("(( %s (%d): %s ))", exports.sarp_main:getPlayerRealName(playerid), getElementData(playerid, "player:mtaID"), message)
	triggerClientEvent( "addPlayerOOCMessage", playerid2, text, 255, 188, 93 )
	exports.sarp_logs:createLog('PW', string.format('[UID: %d] %s wysyła wiadomość do [UID: %d] %s: %s', getElementData(playerid, "player:id"), getElementData(playerid, "player:username"), getElementData(playerid2, "player:id"), getElementData(playerid2, "player:username"), message))

	setElementData(playerid, "lastPlayerMSG", playerid2)
	setElementData(playerid2, "lastPlayerMSG", playerid)
end

addCommandHandler( "re", cmd.re )

function cmd.sprobuj(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local message = table.concat({...}, " ")

	if string.len(message) == 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /sprobuj [akcja]")
	end

	local random = math.random(1, 2)

	if getElementData(playerid, "player:sex") == 1 then
		if random == 1 then
			triggerEvent( "main:me", playerid, string.format("zawiódł próbując %s.", message) )
		else
			triggerEvent( "main:me", playerid, string.format("odniósł sukces próbując %s.", message) )
		end
	else
		if random == 1 then
			triggerEvent( "main:me", playerid, string.format("zawiódła próbując %s.", message) )
		else
			triggerEvent( "main:me", playerid, string.format("odniósła sukces próbując %s.", message) )
		end
	end
end

addCommandHandler( "sprobuj", cmd.sprobuj )

function cmd.pokaz(playerid, cmd, document, id)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	if document == 'prawko' then
		local playerid2 = exports.sarp_main:getPlayerFromID(id)
		local haveDocument = exports.sarp_main:havePlayerDocument(playerid, 2)

		if not haveDocument then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz prawo jazdy.")
		end

		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /pokaz prawko [ID gracza]")
		end

		if playerid == playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz pokazać sobie dokumentu.")
		end

		triggerEvent( "main:me", playerid, string.format("pokazuje prawo jazdy dla %s.", exports.sarp_main:getPlayerRealName(playerid2)) )
		outputChatBox( string.format("** Gracz %s pokazał tobie swoje prawo jazdy. (Imie i nazwisko: %s, Punkty karne: %d/24) **", exports.sarp_main:getPlayerRealName(playerid), getElementData(playerid, "player:username"), 0), playerid2, 150, 150, 200)
	elseif document == 'dowod' then
		local playerid2 = exports.sarp_main:getPlayerFromID(id)
		local haveDocument = exports.sarp_main:havePlayerDocument(playerid, 1)

		if not haveDocument then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz dowodu osobistego.")
		end

		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /pokaz dowod [ID gracza]")
		end

		if playerid == playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz pokazać sobie dokumentu.")
		end

		triggerEvent( "main:me", playerid, string.format("pokazuje dowód osobisty dla %s.", exports.sarp_main:getPlayerRealName(playerid2)) )
		outputChatBox( string.format("** Gracz %s pokazał tobie swój dowód osobisty. (Imie i nazwisko: %s, Wiek: %d lat) **", exports.sarp_main:getPlayerRealName(playerid), getElementData(playerid, "player:username"), getElementData(playerid, "player:age")), playerid2, 150, 150, 200)
	else
		return exports.sarp_notify:addNotify(playerid, "Użyj: /pokaz [dowod, prawko]")
	end
end

addCommandHandler( "pokaz", cmd.pokaz )

function cmd.akceptujsmierc(playerid, cmd)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end

	local bwTime = getElementData(playerid, "player:bw")

	if not bwTime or bwTime <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz być nieprzytomny.")
	end

	if getElementData(playerid, "player:hours") < 3 then
		return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz mieć przegrane przynajmniej 3 godziny na postaci.")
	end

	triggerClientEvent(playerid, "acceptDeath", playerid )
end

addCommandHandler( "akceptujsmierc", cmd.akceptujsmierc )

function cmd.silownia(playerid, cmd)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local doorid = getElementData(playerid, "player:door")

	if getElementData(playerid, "player:earnStrength") then
		triggerClientEvent( "stopEarnStrength", playerid )
		setElementData( playerid, "player:earnStrength", false )
		return
	end

	if not doorid or not exports.sarp_doors:isDoorGroupType(doorid, 11) then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz użyć tutaj tej komendy.")
	end

	local query = exports.sarp_mysql:mysql_result("SELECT *, SUM(`earnPoints`) AS points FROM `sarp_gym` WHERE `player_id` = ? AND `date` > ? AND `type` = 1", getElementData(playerid, "player:id"), getRealTime().timestamp - 84600)

	local group = exports.sarp_doors:getDoorData(doorid, "ownerID")
	local haveTicket = false
	for i, v in ipairs(query) do
		if v.group_id == group then
			haveTicket = true
		end
	end

	if not haveTicket then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz zakupionego karnetu w tej siłowni.")
	end

	if query[1] and tonumber(query[1].points) > 6 then
		return exports.sarp_notify:addNotify(playerid, "Limit ćwiczeń z karnetu został wykorzystany.")
	end
	
	setElementData(playerid, "player:earnStrength", true)
	triggerClientEvent(playerid, "earnStrength", playerid )	
end

addCommandHandler( "silownia", cmd.silownia )

function cmd.spawn(playerid, cmd)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local spawnList = {}

	table.insert(spawnList, {id = 1, type = 0, name = "Centrum handlowe"})

	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_hotel` WHERE `player_id` = ? AND `date` > ?", getElementData(playerid, "player:id"), getRealTime().timestamp)

	for i, v in ipairs(query) do
		table.insert(spawnList, {id = v.door_id, type = 1, name = exports.sarp_doors:getDoorData(v.door_id, "name")})
	end

	local playerDoor = exports.sarp_doors:getPlayerDoors(playerid)

	for i, v in ipairs(playerDoor) do
		table.insert(spawnList, {id = v.id, type = 2, name = v.name})
	end

	local query = exports.sarp_mysql:mysql_result("SELECT `doorid` FROM `sarp_doors_members` WHERE `player_id` = ?", getElementData(playerid, "player:id"))
	for i, v in ipairs(query) do
		if v.doorid then
			table.insert(spawnList, {id = v.id, type = 2, name = exports.sarp_doors:getDoorData(v.doorid, "name")})
		end
	end

	triggerClientEvent(playerid, "spawnGUI", playerid, spawnList)
end

addCommandHandler( "spawn", cmd.spawn )
addEvent('playerSpawn', true)
addEventHandler( 'playerSpawn', root, cmd.spawn )

function cmd.subtype(playerid, cmd)
	local vehicle = getPedOccupiedVehicle( playerid )

	if vehicle and getElementData(vehicle, "vehicle:subType") then
		exports.sarp_notify:addNotify(playerid, getElementData(vehicle, "vehicle:subType"))
	else
		exports.sarp_notify:addNotify(playerid, 'Brak')
	end
end

addCommandHandler( "subtype", cmd.subtype )