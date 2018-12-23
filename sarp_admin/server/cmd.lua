--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

--[[
	TYPY KAR:
	1 = AJ
	2 = GAMESCORE
	3 = kick
	4 = ban
	5 = blokada postaci
	6 = warn
--]]

local cmd = {}

function cmd.visible(playerid)
	if not getPlayerPermission(playerid, 512) then return end

	if getElementAlpha( playerid ) == 255 then
		setElementAlpha(playerid, 0)
		exports.sarp_notify:addNotify(playerid, "Od teraz jesteś niewidoczny.")
	else
		setElementAlpha( playerid, 255 )
		exports.sarp_notify:addNotify(playerid, "Od teraz jesteś widoczny.")
	end
end

addCommandHandler( "visible", cmd.visible)

function cmd.setpos(playerid, cmd, posX, posY, posZ)
	if not getPlayerPermission(playerid, 512) then return end

	if not (posX or posY or posZ) then
		return exports.sarp_notify:addNotify( playerid, "Użyj: /setpos [posX] [posY] [posZ]")
	end

	setElementPosition( playerid, posX, posY, posZ )
end

addCommandHandler( "setpos", cmd.setpos )

function cmd.goto(playerid, cmd, playerid2)
	if not getPlayerPermission(playerid, 512) then return end

	local playerid2 = exports.sarp_main:getPlayerFromID(playerid2)

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /goto [playerid]")
	end

	teleportP1toP2(playerid, playerid2)
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s teleportował się do %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username")))
end
addCommandHandler( "goto", cmd.goto )

function cmd.tp(playerid, cmd, p1, p2)
	if not getPlayerPermission(playerid, 512) then return end

	local p1, p2 = exports.sarp_main:getPlayerFromID(p1), exports.sarp_main:getPlayerFromID(p2)

	if not (p1 and p2) then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /tp [playerid] [playerid2]")
	end

	teleportP1toP2(p1, p2)
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s teleportował %s do %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(p1, "player:username"), getElementData(p2, "player:username")))
end

addCommandHandler( "tp", cmd.tp )

function cmd.aduty(playerid)
	if not getPlayerPermission(playerid, 512) then return end

	if getElementData(playerid, "admin:duty") then
		local time = getRealTime().timestamp - getElementData(playerid, "admin:duty")
		local minute, second = time / 60, time % 60

		exports.sarp_notify:addNotify(playerid, string.format("Zszedłeś ze służby administratora. Byłeś na służbie %d min, %d sec.", minute, second))
		exports.sarp_logs:createLog('adminDUTY', string.format('%s zszedł ze służby %sa. (%d min, %d sec)', getElementData(playerid, "global:name"), getElementData(playerid, "global:rank"), minute, second))
		
		if minute > 0 then
			exports.sarp_mysql:mysql_change("INSERT INTO `sarp_log` SET `log_date` = ?, `log_ip` = ?, `log_value` = ?, `log_type` = 5, `log_ownertype` = 1, `log_owner` = ?", getRealTime().timestamp, getPlayerIP( playerid ), minute, getElementData(playerid, "player:id"))
		end
		setElementData( playerid, "admin:duty", false )
	else
		setElementData( playerid, "admin:duty", getRealTime().timestamp )
		exports.sarp_notify:addNotify(playerid, "Wszedłeś na służbę administratora. Miłej gry." )
		exports.sarp_logs:createLog('adminDUTY', string.format("%s wszedł na służbę %sa.", getElementData(playerid, "global:name"), getElementData(playerid, "global:rank")))
	end
end

addCommandHandler( "aduty", cmd.aduty )

function cmd.set(playerid, cmd, cmd2, ...)
	if not getPlayerPermission(playerid, 1) then return end

	local more = {...}
	if cmd2 == 'skin' then
		local playerid2, skin = exports.sarp_main:getPlayerFromID(more[1]), tonumber(more[2])
		if not playerid2 or not skin then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /set skin [playerid] [id skina]" )
		end
		if not exports.sarp_main:isPlayerLogged(playerid2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym mtaID nie istnieje, albo nie jest zalogowany.")
		end
		if skin > 312 or skin < 0 then
			return exports.sarp_notify:addNotify(playerid, "Skiny od 0 do 312.")
		end

		setElementModel( playerid2, skin )
		setElementData(playerid2, "player:skin", skin)

		exports.sarp_notify:addNotify(playerid2, string.format("%s zmienił twój domyślny skin.", getElementData(playerid, "global:name")))
		exports.sarp_notify:addNotify(playerid, string.format("Zmieniłeś domyślny skin dla gracza %s", getElementData(playerid2, "player:username")))
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił domyślny skin dla %s na %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username"), skin))
	elseif cmd2 == 'dimension' then
		local playerid2, vw = exports.sarp_main:getPlayerFromID(more[1]), tonumber(more[2])

		if not vw then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /set dimension [playerid] [dimension]" )
		end

		if not exports.sarp_main:isPlayerLogged(playerid2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym mtaID nie istnieje, albo nie jest zalogowany.")
		end

		setElementDimension( playerid2, vw )
		exports.sarp_notify:addNotify(playerid, string.format("Zmieniłeś dimension id dla gracza %s", getElementData(playerid2, "player:username")))
		exports.sarp_notify:addNotify(playerid2, string.format("Administrator %s zmienił tobie świat.", getElementData(playerid, "global:name")))
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił dimension id dla %s na %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username"), vw))

	elseif cmd2 == 'interior' then
		local playerid2, interior = exports.sarp_main:getPlayerFromID(more[1]), tonumber(more[2])

		if not interior then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /set interior [playerid] [interior]" )
		end

		if not exports.sarp_main:isPlayerLogged(playerid2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym mtaID nie istnieje, albo nie jest zalogowany.")
		end

		setElementInterior( playerid2, interior )
		exports.sarp_notify:addNotify(playerid, string.format("Zmieniłeś interior id dla gracza %s", getElementData(playerid2, "player:username")))
		exports.sarp_notify:addNotify(playerid2, string.format("Administrator %s zmienił tobie interior.", getElementData(playerid, "global:name")))
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił interior id dla %s na %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username"), interior))


	elseif cmd2 == 'hp' then
		local playerid2, hp = exports.sarp_main:getPlayerFromID(more[1]), tonumber(more[2])

		if not hp then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /set hp [playerid] [ilość hp]" )
		end

		if not exports.sarp_main:isPlayerLogged(playerid2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym mtaID nie istnieje, albo nie jest zalogowany.")
		end

		if hp > 100 or hp < 0 then
			return exports.sarp_notify:addNotify(playerid, "HP nie może być większe od 100, ani mniejsze od 0.")
		end

		setElementData(playerid2, "player:health", hp)
		exports.sarp_notify:addNotify(playerid2, "Administrator zmienił Tobie ilość HP.")
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił ilość HP dla %s na %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username"), hp))
	elseif cmd2 == 'sila' then
		local playerid2, sila = exports.sarp_main:getPlayerFromID(more[1]), tonumber(more[2])

		if not sila then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /set sila [playerid] [ilość siły]" )
		end

		if not exports.sarp_main:isPlayerLogged(playerid2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym mtaID nie istnieje, albo nie jest zalogowany.")
		end

		setElementData(playerid2, "player:strength", sila)
	else
		exports.sarp_notify:addNotify(playerid, "Użyj: /set [skin | dimension | interior | hp | sila]" )
	end
end

addCommandHandler( "set", cmd.set )

function cmd.spec(playerid, cmd, playerid2)
	if not getPlayerPermission(playerid, 512) then return end

	local player = exports.sarp_main:getPlayerFromID(playerid2)

	if getElementData(playerid, "admin:spec") then
		setElementData(playerid, "admin:spec", false)
		setCameraTarget(playerid, playerid)
		local pX, pY, pZ, rotation, interior, dimension = exports.sarp_main:getSpawnPosition(playerid)

		setElementPosition( playerid, pX, pY, pZ )
		setElementRotation( playerid, 0, 0, rotation )
		setElementDimension( playerid, dimension )
		setElementInterior( playerid, interior )
		setElementAlpha( playerid, 255 )

		exports.sarp_notify:addNotify(playerid, "Specowanie gracza zakończone.")
	else
		if not player then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /spec [playerid]")
		end

		if playerid == player then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz specować siebie! [Panda zajebie]")
		end

		setElementData(playerid, "admin:spec", getElementData(playerid, "player:mtaID"))
		removePedFromVehicle(playerid)
		setElementDimension(playerid, getElementDimension(player))
		setElementInterior(playerid, getElementInterior(player))
		setElementPosition(playerid, 0, 0, -50)
		setCameraTarget(playerid, player)
		setElementAlpha( playerid, 0 )
	end
end

addCommandHandler( "spec", cmd.spec)

function cmd.kick(playerid, cmd, playerid2, ...)
	if not getPlayerPermission(playerid, 512) then return end

	local more = {...}
	local player = exports.sarp_main:getPlayerFromID(playerid2)
	local reason = table.concat(more, " ", 1, #more)

	if string.len(reason) <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /kick [id gracza] [powód]")
	end

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_penalty` SET `player_id` = ?, `global_id` = ?, `admin` = ?, `type` = 3, `value` = ?, `reason` = ?, `expired` = ?, `date` = ?, `serial` = ?", 
	 	getElementData(player, "player:id"),
	 	getElementData(player, "global:id"),
	 	getElementData(playerid, "global:id"),
	 	0,
	 	tostring(reason),
	 	getRealTime().timestamp + 2592000,
	 	getRealTime().timestamp,
	 	getPlayerSerial( player ))

	triggerClientEvent( "penalty:show", resourceRoot, getElementData(player, "player:username"), 3, getElementData(playerid, "global:name"), tostring(reason), 0 )
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s wyrzucił %s z serwera, powód: %s", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(player, "player:username"), reason))
	kickPlayer(player, reason)
end

addCommandHandler( "kick", cmd.kick )

function cmd.ban(playerid, cmd, playerid2, time, ...)
	if not getPlayerPermission(playerid, 512) then return end

	local more = {...}
	local player = exports.sarp_main:getPlayerFromID(playerid2)
	local reason, time = table.concat(more, " ", 1, #more), tonumber(time)

	if string.len(reason) <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /ban [id gracza] [czas w miesiącach] [powód]")
	end

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_penalty` SET `player_id` = ?, `global_id` = ?, `admin` = ?, `type` = 4, `value` = ?, `reason` = ?, `expired` = ?, `date` = ?, `serial` = ?", 
		 	getElementData(player, "player:id"),
		 	getElementData(player, "global:id"),
		 	getElementData(playerid, "global:id"),
		 	getRealTime().timestamp + (2592000 * time),
		 	tostring(reason),
		 	getRealTime().timestamp + 2592000,
		 	getRealTime().timestamp,
		 	getPlayerSerial( player ))
	
	triggerClientEvent( "penalty:show", resourceRoot, getElementData(player, "player:username"), 4, getElementData(playerid, "global:name"), tostring(reason), time * 30 )
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s zabanował %s na %d miesięcy, powód: %s", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(player, "player:username"), time, reason))
	kickPlayer(player, "Ban: "..reason)
end

addCommandHandler( "ban", cmd.ban)

function cmd.aj(playerid, cmd, playerid2, time, ...)
	if not getPlayerPermission(playerid, 512) then return end

	local more = {...}
	local more, player, time = table.concat(more, " ", 1, #more), exports.sarp_main:getPlayerFromID(playerid2), tonumber(time)

	 if string.len(more) <= 0 then
	 	return exports.sarp_notify:addNotify(playerid, "Użyj: /aj [id gracza] [czas w minutach] [powód]")
	 end
	 
	 if isPedInVehicle( player ) then
	 	removePedFromVehicle ( player )
	 end
	 setElementData(player, "player:aj", 60 * time)
	 setElementInterior( player, 10 )
	 setElementPosition( player, 419.6140, 2536.6030, 10.0000 )
	 setElementDimension( player, 1000 + getElementData(player, "player:id") )
	 exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `aj` = ? WHERE `player_id` = ?", time * 60, getElementData(player, "player:id"))
	 exports.sarp_mysql:mysql_change("INSERT INTO `sarp_penalty` SET `player_id` = ?, `global_id` = ?, `admin` = ?, `type` = 1, `value` = ?, `reason` = ?, `expired` = ?, `date` = ?", 
		 	getElementData(player, "player:id"),
		 	getElementData(player, "global:id"),
		 	getElementData(playerid, "global:id"),
		 	time * 60,
		 	tostring(more),
		 	getRealTime().timestamp + 2592000,
		 	getRealTime().timestamp)

	 triggerClientEvent( player, "player:aj", player )
	 triggerClientEvent( "penalty:show", resourceRoot, getElementData(player, "player:username"), 1, getElementData(playerid, "global:name"), tostring(more), time )
	 exports.sarp_logs:createLog('adminACTION', string.format("%s %s nadał AJ dla %s na %d minut, powód: %s", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(player, "player:username"), time, more))

end

addCommandHandler( "aj", cmd.aj )

function cmd.glob(playerid, cmd, ...)
	if not getPlayerPermission(playerid, 512) then return end

	local text = {...}
	text = table.concat(text, " ", 1, #text)

	if string.len(text) <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /glob [tekst]" )
	end

	triggerClientEvent( "addPlayerOOCMessage", root, "(( [" .. getElementData(playerid, "player:mtaID") .. "] ".. getElementData(playerid, "global:name") ..": ".. text .. " ))", 230, 230, 230 )
end

addCommandHandler( "glob", cmd.glob )

function cmd.gamescore(playerid, cmd, playerid2, score, ...)
	if not getPlayerPermission(playerid, 512) then return end

	local more = {...}
	local player, score, reason = exports.sarp_main:getPlayerFromID(playerid2), tonumber(score), table.concat(more, " ", 1, #more)

	if string.len(reason) <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /gamescore [id gracza] [liczba punktów] [powód]")
	end

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_penalty` SET `player_id` = ?, `global_id` = ?, `admin` = ?, `type` = 2, `value` = ?, `reason` = ?, `expired` = ?, `date` = ?", 
		 	getElementData(player, "player:id"),
		 	getElementData(player, "global:id"),
		 	getElementData(playerid, "global:id"),
		 	score,
		 	tostring(reason),
		 	0,
		 	getRealTime().timestamp)

	setElementData(player, "global:score", getElementData(player, "global:score") + score)
	exports.sarp_mysql:mysql_change("UPDATE `core_members` SET `score` = ? WHERE `member_id` = ?", getElementData( player, "global:score"), getElementData(player, "global:id"))
	triggerClientEvent( "penalty:show", resourceRoot, getElementData(player, "player:username"), 2, getElementData(playerid, "global:name"), tostring(reason), score )
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s nadał %d punktów gamescore dla %s, powód: %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), score, getElementData(player, "player:username"), reason))

end

addCommandHandler( "gamescore", cmd.gamescore )

function cmd.unbw(playerid, cmd, playerid2)
	if not getPlayerPermission(playerid, 512) then return end

	local player = exports.sarp_main:getPlayerFromID(playerid2)

	if not player then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /unbw [id gracza]" )
	end

	if getElementData(player, "player:bw") == 0 then
		return exports.sarp_notify:addNotify(playerid, "Ten gracz nie ma BW.")
	end

	setElementData(player, 'player:bw', 0)
	exports.sarp_notify:addNotify(player, string.format("%s zdjął tobie BW.", getElementData(playerid, "global:name")))
	exports.sarp_notify:addNotify(playerid, string.format("Zdjąłeś BW graczowi %s.", getElementData(player, "player:username")))
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s zdjął BW dla %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(player, "player:username")))

end

addCommandHandler( "unbw", cmd.unbw )

function cmd.block(playerid, cmd, playerid2, ...)
	if not getPlayerPermission(playerid, 512) then return end

	local player, more = exports.sarp_main:getPlayerFromID(playerid2), {...}
	local reason = table.concat(more, " ", 1, #more)

	if string.len(reason) <= 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /block [id gracza] [powód]" )
	end

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_penalty` SET `player_id` = ?, `global_id` = ?, `admin` = ?, `type` = 5, `value` = ?, `reason` = ?, `expired` = ?, `date` = ?", 
		 	getElementData(player, "player:id"),
		 	getElementData(player, "global:id"),
		 	getElementData(playerid, "global:id"),
		 	0,
		 	tostring(reason),
		 	0,
		 	getRealTime().timestamp)

	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `block` = 1 WHERE `player_id` = ?", getElementData( player, "player:id" ))
	triggerClientEvent( "penalty:show", resourceRoot, getElementData(player, "player:username"), 5, getElementData(playerid, "global:name"), tostring(reason), 0 )
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s zablokował postać dla %s, powód: %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(player, "player:username"), reason))
	kickPlayer( player, "Blokada postaci, powód: ".. reason )
end

addCommandHandler( "block", cmd.block )

function cmd.zamroz(playerid, cmd, playerid2)
	if not getPlayerPermission(playerid, 512) then return end

 	playerid2 = exports.sarp_main:getPlayerFromID(playerid2)

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /zamroz [id gracza]" )
	end

	setElementFrozen( playerid2, true )
	exports.sarp_notify:addNotify(playerid, string.format("Zamroziłeś gracza %s.", getElementData(playerid2, "player:username")))
	exports.sarp_notify:addNotify(playerid2, string.format("Administrator %s zamroził Ciebie.", getElementData(playerid, "global:name")))
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s zamroził %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username")))
end

addCommandHandler( "zamroz", cmd.zamroz )

function cmd.odmroz(playerid, cmd, playerid2)
	if not getPlayerPermission(playerid, 512) then return end
	
	playerid2 = exports.sarp_main:getPlayerFromID(playerid2)

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /odmroz [id gracza]" )
	end

	setElementFrozen( playerid2, false )
	exports.sarp_notify:addNotify(playerid, string.format("Odmroził gracza %s.", getElementData(playerid2, "player:username")))
	exports.sarp_notify:addNotify(playerid2, string.format("Administrator %s odmroził Ciebie.", getElementData(playerid, "global:name")))
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s odmroził %s.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username")))

end

addCommandHandler( "odmroz", cmd.odmroz )

function cmd.ado(playerid, cmd, ...)
	if not getPlayerPermission(playerid, 512) then return end
	local message = table.concat({...}, " ")

	if string.len(message) == 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /ado [akcja]")
	end

	outputChatBox( "** ".. message.. " **", root, 150, 150, 200)
end

addCommandHandler( "ado", cmd.ado )

function cmd.getpos(playerid, cmd)
	if not getPlayerPermission(playerid, 512) then return end
	local pX, pY, pZ = getElementPosition( playerid )
	local rX, rY, rZ = getElementRotation( playerid )
	outputConsole( string.format("%f, %f, %f, %f, %f, %f", pX, pY, pZ, rX, rY, rZ))
	exports.sarp_notify:addNotify(playerid, "Twoja pozycja została umieszczona w konsoli.")
end

addCommandHandler( "getpos", cmd.getpos )

function cmd.tpspawn(playerid, cmd, ...)
	if not getPlayerPermission(playerid, 512) then return end
	local params = {...}
	local playerid2 = exports.sarp_main:getPlayerFromID(params[1])

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /tpspawn [ID gracza]")
	end

	local pX, pY, pZ, rotation, interior, dimension = exports.sarp_main:getSpawnPosition(playerid)
	
	removePedFromVehicle( playerid2 )

	setElementPosition( playerid2, pX, pY, pZ )
	setElementRotation( playerid2, 0, 0, rotation)
	setElementInterior( playerid2, interior )
	setElementDimension( playerid2, dimension )
	triggerEvent( "objects:load", root, playerid, getElementDimension( playerid ), getElementInterior( playerid ) )
	exports.sarp_notify:addNotify(playerid, string.format("Teleportowałeś gracza %s na miejsce spawnu.", getElementData(playerid2, "player:username")))
	exports.sarp_notify:addNotify(playerid2, string.format("%s %s teleportował Ciebie do miejscu spawnu.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name")))
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s teleportował %s na miejsce spawnu.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), getElementData(playerid2, "player:username")))
end

addCommandHandler( "tpspawn", cmd.tpspawn )

function cmd.pogoda(playerid, cmd, id)
	if not getPlayerPermission(playerid, 512) then return end
	id = tonumber(id)

	if not id then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /pogoda [ID pogody od 0 do 255]")
	end

	if id > 255 or id < 0 then
		return exports.sarp_notify:addNotify(playerid, "Nieprawidłowe ID pogody.")
	end

	setWeather( id )
	exports.sarp_notify:addNotify(playerid, "Pogoda została zmieniona.")
end

addCommandHandler( "pogoda", cmd.pogoda )

function cmd.jetpack(playerid, cmd)
	if not getPlayerPermission(playerid, 512) then return end

  setPedWearingJetpack ( playerid, true )
  exports.sarp_notify:addNotify(playerid, "Jetpack został ".. true and "włączony." or "wyłączony.")
end

addCommandHandler( "jetspack", cmd.jetpack )

function cmd.dekoduj(playerid, cmd, ...)
	if not getPlayerPermission(playerid, 512) then return end
	local params = {...}
	local IDmaski = params[1]

	if IDmaski == nil then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /dekoduj [kod maski]")
	end

	local query = exports.sarp_mysql:mysql_result("SELECT `player_id`, `name`, `surname` FROM `sarp_characters` WHERE md5(`player_id`) LIKE ?", IDmaski.."%")

	if not query[1] then
		return exports.sarp_notify:addNotify(playerid, "Wprowadzono błędny kod maski.")
	end

	triggerClientEvent(playerid, "addPlayerOOCMessage", playerid, string.format("Kod maski: %s - [UID: %d] %s %s", IDmaski, query[1].player_id, query[1].name, query[1].surname), 255, 255, 255)
end

addCommandHandler( "dekoduj", cmd.dekoduj )