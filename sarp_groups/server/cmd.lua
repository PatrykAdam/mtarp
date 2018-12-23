--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local cmd = {}
local gpsList = {}

function cmd.gpsDestroy(vehicle)
	if gpsList[vehicle] then
		destroyElement( gpsList[vehicle] )
		gpsList[vehicle] = nil
	end
end

addEvent('gpsDestroy', true)
addEventHandler( 'gpsDestroy', root, cmd.gpsDestroy)

function cmd.onStartEnter(player, seat)
	local cuffed = getElementData(player, "cuffedPlayer")
	local cuffed2 = getElementData(player, "player:cuffed")
	
	if cuffed2 then
	cancelEvent()
	end
	if cuffed and seat <= getVehicleMaxPassengers( source ) and seat ~= 0 then
		cancelEvent()
		if not isPedInVehicle( cuffed ) then
			detachElements( cuffed )
			setTimer( warpPedIntoVehicle, 1500, 1, cuffed, source, seat )
		else
			setTimer( removePedFromVehicle, 1500, 1, cuffed )
			setTimer(attachElements, 2000, 1, cuffed, player, 0, 0.5 )
		end
	end
end

addEventHandler( "onVehicleStartEnter", root, cmd.onStartEnter )

function cmd.onStartExit(player, seat)
	local cuffed = getElementData(player, "player:cuffed")

	if cuffed then
		cancelEvent()
	end
end

addEventHandler( "onVehicleStartExit", root, cmd.onStartExit )

function cmd.group(playerid, cmd, slot, cmd2, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local slot = tonumber(slot)
	local params = {...}

	if not cmd2 then
		triggerClientEvent( "showGroupList", playerid )
		return
	end

	if slot > 3 or slot < 1 then
		return exports.sarp_notify:addNotify(playerid, "Możliwe sloty od 1 do 3.")
	end

	if not getElementData(playerid, "group_"..slot..":id") then
		return exports.sarp_notify:addNotify(playerid, "Na tym slocie nie posiadasz żadnej grupy.")
	end

	if cmd2 == 'info' then
		triggerClientEvent( "showGroupInfo", playerid, slot, getGroupData(getElementData(playerid, "group_"..slot..":id")) )

	elseif cmd2 == 'online' then
		triggerClientEvent( "showGroupOnline", playerid, slot )

	elseif cmd2 == 'duty' then
		local text, groupid = '', getElementData(playerid, "player:duty")

		if groupid then
			local time = getElementData(playerid, "group_".. slot ..":duty_time")
			local h, m = math.floor(time/60), time % 60

			setElementData(playerid, "player:duty", false)
			setElementData(playerid, "player:dutyInfo", false)
			setElementData(playerid, "group:type", false)
			exports.sarp_mysql:mysql_change("UPDATE `sarp_group_member` SET `duty_time` = ? WHERE `player_id` = ?", time, getElementData(playerid, "player:id"))

			for i, v in pairs(gpsList) do
				if isElementVisibleTo( v, playerid ) then
					setElementVisibleTo( v, playerid, false )
				end
			end

			exports.sarp_notify:addNotify(playerid, string.format("Zakończyłeś służbe w grupie %s (UID: %d). Przepracowałeś dzisiaj %dh %dmin.", groupsData[groupid].name, groupid, h, m))
		else
			local groupid = getElementData(playerid, "group_"..slot..":id")
			setElementData(playerid, "player:duty", groupid)

			local dutyInfo = {}
			setElementData(playerid, "group:type", groupsData[groupid].type)

			if haveGroupFlags(groupid, 4) then
				local color = groupsData[groupid].color
				dutyInfo[1] = exports.sarp_main:RGBToHex(tonumber(color[1]), tonumber(color[2]), tonumber(color[3]))
				dutyInfo[2] = groupsData[groupid].tag
				setElementData(playerid, "player:dutyInfo", dutyInfo)
			end

			for i, v in pairs( gpsList ) do
				if not isElementVisibleTo( v, playerid ) then
					setElementVisibleTo( v, playerid, true )
				end
			end

			exports.sarp_notify:addNotify(playerid, string.format("Rozpocząłeś słuzbę w grupie %s (UID: %d).", groupsData[groupid].name, groupid))
		end
	elseif cmd2 == 'przebierz' then
		local pSkin, gSkin = getElementData(playerid, "player:skin"), getElementData(playerid, "group_"..slot..":skin")
		if gSkin == -1 then
			return exports.sarp_notify:addNotify(playerid, "Nie masz ustawionego stroju służbowego.")
		end
		if getElementModel(playerid) == pSkin then
			setElementModel( playerid, gSkin )
			exports.sarp_notify:addNotify(playerid, "Przebrałeś się w ubranie służbowe.")
		else
			setElementModel( playerid, pSkin)
			exports.sarp_notify:addNotify(playerid, "Przebrałeś się w ubranie codzienne.")
		end
	elseif cmd2 == 'pojazdy' or cmd2 == 'v' then
		triggerEvent( "group:vehicle", playerid, slot )
	elseif cmd2 == 'zapros' then
		local playerid2 = exports.sarp_main:getPlayerFromID(params[1])
		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /g [slot (1-3)] zapros [id gracza]")
		end

		local groupid = getElementData(playerid, "group_"..slot..":id")
		if not haveGroupPermission(playerid, groupid, 8192) then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do zarządzania pracownikami.")
		end

		if not freeSlot(playerid2) then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz nie posiada wolnego slotu grupowego.")
		end

		if isPlayerInGroup(playerid2, groupid) then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz należy już do tej grupy.")
		end


		member_add(getElementData(playerid2, "player:mtaID"), groupid)

		exports.sarp_notify:addNotify(playerid, string.format("Dodałeś gracza %s do grupy %s.", exports.sarp_main:getPlayerRealName(playerid2), groupsData[groupid].name))
		exports.sarp_notify:addNotify(playerid2, string.format("Zostałeś dodany do grupy %s przez %s", groupsData[groupid].name, exports.sarp_main:getPlayerRealName(playerid)))

	elseif cmd2 == 'wypros' then

		local playerid2 = exports.sarp_main:getPlayerFromID(params[1])
		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /g [slot (1-3)] wypros [id gracza]")
		end

		local groupid = getElementData(playerid, "group_"..slot..":id")
		if not haveGroupPermission(playerid, groupid, 8192) then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do zarządzania pracownikami.")
		end

		if groupsData[groupid].leader == getElementData(playerid2, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz wyrzucić lidera grupy.")
		end

		if playerid == playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz wyrzucić siebie.")
		end

		member_delete(getElementData(playerid2, "player:id"), groupid)
		exports.sarp_notify:addNotify(playerid2, string.format("Zostałeś wyrzucony z grupy %s.", groupsData[groupid].name))

	elseif cmd2 == 'opusc' then
		local groupid = getElementData(playerid, "group_"..slot..":id")

		if groupsData[groupid].leader == getElementData(playerid, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz odejść jako lider grupy.")
		end

		if haveGroupFlags(groupid, 8) then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz odejść z tej grupy.")
		end

		member_delete(getElementData(playerid, "player:id"), groupid)

		exports.sarp_notify:addNotify(playerid, string.format("Odszedłeś z grupy %s.", groupsData[groupid].name))
	elseif cmd2 == 'magazyn' then
		local groupid = getElementData(playerid, "group_"..slot..":id")
		if not haveGroupPermission(playerid, groupid, 4096) then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do wyciągania przedmiotów z magazynu.")
		end

		if not exports.sarp_doors:isGroupDoor(groupid, playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować się w budynku należącym do grupy.")
		end

		local productList = exports.sarp_mysql:mysql_result("SELECT `uid`, `item_count`, `item_name` FROM `sarp_magazine` WHERE `groupid` = ?", groupid)

		if #productList == 0 then
			return exports.sarp_notify:addNotify(playerid, "Brak produktów w magazynie grupy.")
		end

		triggerClientEvent(playerid, "magazineShow", playerid, productList, groupid)
	elseif cmd2 == 'wplac' then
		local groupid = getElementData(playerid, "group_"..slot..":id")
		local doorid = getElementData(playerid, "player:door")
		if not exports.sarp_doors:isDoorGroupType(doorid, 22) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w budynku banku.")
		end

		if groupsData[groupid].leader ~= getElementData(playerid, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz dostepu do tej komendy.")
		end

		local money = math.floor(tonumber(params[1]))

		if not money then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /g [slot (1-3)] wplac [kwota]")
		end

		local pMoney = getElementData(playerid, "player:money")
		if money < 0 or money > pMoney then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz takiej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(playerid, - money)
		giveGroupCash(groupid, money)

		exports.sarp_notify:addNotify(playerid, "Pieniądze zostały wpłacone na konto grupy.")
		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_log` VALUES (0, 2, 2, ?, ?, ?, ?, ?)", groupid, money, getElementData(playerid, "player:id"), getRealTime().timestamp, getPlayerIP(playerid))
	elseif cmd2 == 'wyplac' then
		local groupid = getElementData(playerid, "group_"..slot..":id")
		local doorid = getElementData(playerid, "player:door")

		if not exports.sarp_doors:isDoorGroupType(doorid, 22) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w budynku banku.")
		end

		if not haveGroupFlags(groupid, 16) then
			return exports.sarp_notify:addNotify(playerid, "Ta grupa nie posiada dostępu do tej komendy.")
		end

		if groupsData[groupid].leader ~= getElementData(playerid, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz dostepu do tej komendy.")
		end

		local money = math.floor(tonumber(params[1]))

		if not money then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /g [slot (1-3)] wyplac [kwota]")
		end

		local gMoney = groupsData[groupid].bank
		if money < 0 or money > gMoney then
			return exports.sarp_notify:addNotify(playerid, "Na koncie grupy nie ma takiej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(playerid, money)
		giveGroupCash(groupid, - money)

		exports.sarp_notify:addNotify(playerid, "Pieniądze zostały wypłacone z konta grupy.")
		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_log` VALUES (0, 3, 2, ?, ?, ?, ?, ?)", groupid, money, getElementData(playerid, "player:id"), getRealTime().timestamp, getPlayerIP(playerid))
	elseif cmd2 == 'pomoc' then
		local groupid = getElementData(playerid, "group_"..slot..":id")
		triggerClientEvent( playerid, 'groupHelp', playerid, groupsData[groupid].type)
	end
end

addCommandHandler( "g", cmd.group )

function cmd.d(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local msg = {...}
	local groupid = getElementData(playerid, "player:duty")

	if getElementData(playerid, "player:muted") then
		return exports.sarp_notify:addNotify(playerid, "Posiadasz nałożony knebel - nie możesz nic mówić.")
	end

	if getElementData(playerid, "player:bw") > 0 then
		return exports.sarp_notify:addNotify(playerid, "Podczas BW nie możesz używać tej komendy.")
	end

	if not groupid or not haveGroupFlags(groupid, 1) or not isPlayerInGroup(playerid, groupid) then 
		return exports.sarp_notify:addNotify(playerid, "Grupa, w której jesteś na służbie nie posiada uprawnień do używania tej komendy.")
	end

	if #msg == 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /d [tekst]")
	end

	message = table.concat(msg, " ")

	for i, v in ipairs(getElementsByType( "player" )) do
		for j = 1, 3 do
			local groupid = getElementData(playerid, "group_"..j..":id")
			if groupid and haveGroupFlags(groupid, 1) then
				outputChatBox( string.format("** [%s] %s: %s **", groupsData[groupid].tag, getElementData(playerid, "player:username"), message), v, 214, 51, 51)
			end
		end
	end

	local rad = 15.0
	local name = exports.sarp_main:getPlayerRealName(playerid)
	local pX, pY, pZ = getElementPosition( playerid )
	local pInterior, pDimension = getElementInterior( playerid ), getElementDimension( playerid )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )

	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		if distance < rad / 16 then
			outputChatBox( name.. " mówi (przez radio): " .. message, v, 230, 230, 230)
		elseif distance < rad / 8 then
			outputChatBox( name.. " mówi (przez radio): " .. message, v, 200, 200, 200)
		elseif distance < rad / 4 then
			outputChatBox( name.. " mówi (przez radio): " .. message, v, 170, 170, 170)
		elseif distance < rad / 2 then
			outputChatBox( name.. " mówi (przez radio): " .. message, v, 140, 140, 140)
		else
			outputChatBox( name.. " mówi (przez radio): " .. message, v, 110, 110, 110)
		end
	end
	destroyElement( radius )

end

addCommandHandler( "d", cmd.d )

function cmd.podaj(playerid, cmd, id)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	playerid2 = exports.sarp_main:getPlayerFromID(id)
	local groupDuty = getElementData(playerid, "player:duty")

	if not groupDuty or not isPlayerInGroup(playerid, groupDuty) then
		return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz być na służbie grupy.")
	end

	if not exports.sarp_doors:isGroupDoor(playerid, groupDuty) then
		return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
	end


	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /podaj [ID gracza]")
	end

	if exports.sarp_players:getDistanceToElement(playerid, playerid2) > 3.0 then
		return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
	end

	local productList = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_magazine` WHERE `groupid` = ?", groupDuty)

	if #productList == 0 then
		return exports.sarp_notify:addNotify(playerid, "Brak produktów w magazynie grupy.")
	end

	--event pokazujący listę przedmiotów itp
	triggerClientEvent(playerid, "productSell", playerid, productList, playerid2)
end

addCommandHandler( "podaj", cmd.podaj )

function cmd.przeszukaj(playerid, cmd, element, elementID)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	if not isDutyInGroupType(playerid, {2, 4, 5, 6, 13}) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if element == 'pojazd' then
		local vehid = getPedOccupiedVehicle( playerid )

		if not vehid then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować się w pojeździe.")
		end

		local itemsList = exports.sarp_items:getItemsData(3, getElementData(vehid, "vehicle:id"))

		if #itemsList == 0 then
			return exports.sarp_notify:addNotify(playerid, "W pojeździe nie znaleziono żadnego przedmiotu.")
		end

		--wyświetlamy przedmioty w GUI
		triggerClientEvent( playerid, "searchElement", playerid, itemsList, vehid )
	elseif element == 'gracz' then
		local playerid2 = exports.sarp_main:getPlayerFromID(elementID)

		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /przeszukaj gracz [ID gracza]")
		end

		if exports.sarp_players:getDistanceToElement(playerid, playerid2) > 3.0 then
			return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
		end

		local itemsList = exports.sarp_items:getItemsData(1, getElementData(playerid2, "player:id"))

		if #itemsList == 0 then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym ID nie posiada żadnego przedmiotu przy sobie.")
		end

		--wyświetlamy przedmioty w GUI
		triggerClientEvent( playerid, "searchElement", playerid, itemsList, playerid2 )
		triggerEvent( "main:me", playerid, string.format("przeszukuje gracza %s.", exports.sarp_main:getPlayerRealName(playerid2) ))
	else
		return exports.sarp_notify:addNotify(playerid, "Użyj: /przeszukaj [pojazd, gracz]")
	end
end

addCommandHandler( "przeszukaj", cmd.przeszukaj )

function cmd.skuj(playerid, cmd, mtaID)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local playerid2 = exports.sarp_main:getPlayerFromID(mtaID)

	if not isDutyInGroupType(playerid, 2) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /skuj [ID gracza]")
	end

	if exports.sarp_players:getDistanceToElement(playerid, playerid2) > 3.0 then
		return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
	end

	cuffPlayer(playerid, playerid2)
end

addCommandHandler( "skuj", cmd.skuj )

function cmd.gps(playerid, cmd)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	if not isDutyInGroupType(playerid, 2) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end
	local vehicle = getPedOccupiedVehicle( playerid )
	if not vehicle or getVehicleOccupant( vehicle ) ~= playerid then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w żadnym pojeździe na miejscu kierowcy.")
	end

	local groupID = getElementData( playerid, "player:duty" )
	if not gpsList[vehicle] then
		gpsList[vehicle] = createBlipAttachedTo( vehicle, 0, 2.0, groupsData[groupID].color[1], groupsData[groupID].color[2], groupsData[groupID].color[3], 255, 0, 99999.0, resourceRoot )
		for i, v in ipairs( getElementsByType( "player" ) ) do
			if isDutyInGroupType(v, 2) then
				setElementVisibleTo( gpsList[vehicle], v, true )
			end
		end
		exports.sarp_notify:addNotify(playerid, "GPS został włączony.")
	else
		destroyElement( gpsList[vehicle] )
		gpsList[vehicle] = nil
		exports.sarp_notify:addNotify(playerid, "GPS został wyłączony.")
	end
end

addCommandHandler( "gps", cmd.gps )

function cmd.blokada(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local params = {...}

	if not isDutyInGroupType(playerid, 2) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	local vehicleID = exports.sarp_vehicles:getNearestVehicle(playerid)

	if not isElement(vehicleID) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w pobliżu żadnej pojazdu.")
	end

	local policeBlock = getElementData(vehicleID, "vehicle:policeBlock")

	if params[1] == "naloz" then
		local price = tonumber(params[2])

		if policeBlock > 0 then
			return exports.sarp_notify:addNotify(playerid, "Ten pojazd posiada już nałożoną blokade na koła.")
		end

		if not price then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /blokada naloz [koszt zdjęcia]")
		end

		triggerClientEvent(playerid, "blockAccept", vehicleID, math.floor(price) )
	elseif params[1] == "zdejmij" then
		local playerid2 = exports.sarp_main:getPlayerFromID(params[2])

		if policeBlock == 0 then
			return exports.sarp_notify:addNotify(playerid, "Ten pojazd nie posiada nałożonej blokady na koła.")
		end

		if exports.sarp_admin:getPlayerPermission(playerid, 512) then
			setElementData( vehicleID, "vehicle:policeBlock", 0)
			exports.sarp_vehicles:setVehicleData(getElementData(vehicleID, "vehicle:id"), 'policeBlock', 0)

			if getElementData( vehicleID, "vehicle:manual") == false then
				setElementFrozen( vehicleID, false )
			end
			return exports.sarp_notify:addNotify(playerid, "Blokada została zdjęta z pojazdu.")
		end

		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /blokada zdejmij [ID gracza]")
		end

		triggerEvent("createOffer", playerid, playerid, playerid2, 6, policeBlock, {element = vehicleID})
	else
		return exports.sarp_notify:addNotify(playerid, "Użyj: /blokada [naloz, zdejmij]")
	end
end

addCommandHandler( "blokada", cmd.blokada )

function cmd.hotel(playerid, cmd, cmd2, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	
	local doorid = getElementData(playerid, "player:door")

	if not doorid or not exports.sarp_doors:isDoorGroupType(doorid, 20) then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz użyć tutaj tej komendy.")
	end

	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_hotel` WHERE `player_id` = ? AND `door_id` = ?", getElementData(playerid, "player:id"), doorid)

	local motelID, date = doorid, 0

	if query[1] then
		date = query[1].date
	end
	triggerClientEvent( playerid, "showMotel", playerid, motelID, date )
end

addCommandHandler( "hotel", cmd.hotel )

function cmd.pokoj(playerid, cmd, cmd2, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local params = {...}

	local doorid = getElementData(playerid, "player:door")

	if not doorid or not exports.sarp_doors:isDoorGroupType(doorid, 20) then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz użyć tutaj tej komendy.")
	end


	if cmd2 == 'wejdz' then
		local playerid2 = exports.sarp_main:getPlayerFromID(params[1])

		if not playerid2 then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /pokoj wejdz [ID gracza]")
		end

		if getElementData(playerid2, "player:inHotel") ~= doorid then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym ID nie znajduje się w pokoju tego hotelu.")
		end

		if playerid2 == playerid then
			return exports.sarp_notify:addNotify(playerid, "Nie możesz wejść sam do swojego pokoju. (Aby to zrobić użyj /pokoj)")
		end

		if getElementData(playerid, "player:inHotel") == true then
		 return exports.sarp_notify:addNotify(playerid, "Jesteś już w innym pokoju. Aby z niego wyjść naciśnij 'E'.")
		end

		if getElementData(playerid2, "player:hotelLock") then
			return exports.sarp_notify:addNotify(playerid, "Drzwi do pokoju tego gracza są zamknięte.")
		end

		setElementData(playerid, "player:inHotel", true)
		setElementPosition( playerid, 2233.173828125, -1112, 1050.8828125 )
		setElementInterior( playerid, 5 )
		setElementDimension( playerid, 1000 + getElementData(playerid2, "player:id"))

		local position = exports.sarp_doors:getDoorData(doorid, {"exitX", "exitY", "exitZ", "exitRot", "exitinterior", "exitdimension"})

		bindKey(playerid, "E", "down", function(playerid, pos)
			setElementPosition( playerid, position.exitX, position.exitY, position.exitZ )
			setElementInterior( playerid, position.exitinterior )
			setElementDimension( playerid, position.exitdimension )
			unbindKey( playerid, "E", "down" )
			setElementData(playerid, "player:inHotel", false)
		end, playerid, position)

	elseif cmd2 == 'zamknij' then
		if not getElementData(playerid, "player:inHotel") then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować się w swoim pokoju.")
		end

		local lock = getElementData(playerid, "player:hotelLock")
		setElementData(playerid, "player:hotelLock", not lock)
		exports.sarp_notify:addNotify(playerid, string.format("%s drzwi w pokoju.", lock and "Otworzyłeś" or "Zamknąłeś"))
	else
		local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_hotel` WHERE `door_id` = ? AND `player_id` = ?", doorid, getElementData(playerid, "player:id"))

		if not query[1] or query[1].date < getRealTime().timestamp then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz wynajętego pokoju w tym hotelu. Wpisz /hotel aby wynająć.")
		end

		local position = exports.sarp_doors:getDoorData(doorid, {"exitX", "exitY", "exitZ", "exitRot", "exitinterior", "exitdimension"})
		if not getElementData(playerid, "player:inHotel") then
			setElementData(playerid, "player:inHotel", doorid)
			setElementPosition( playerid, 2233.173828125, -1112, 1050.8828125 )
			setElementInterior( playerid, 5 )
			setElementDimension( playerid, 1000 + getElementData(playerid, "player:id"))

			bindKey(playerid, "E", "down", function(playerid, pos)
				setElementPosition( playerid, position.exitX, position.exitY, position.exitZ )
				setElementInterior( playerid, position.exitinterior )
				setElementDimension( playerid, position.exitdimension )
				unbindKey( playerid, "E", "down" )
				setElementData(playerid, "player:inHotel", false)
			end, playerid, position)
		else
			setElementPosition( playerid, position.exitX, position.exitY, position.exitZ )
			setElementInterior( playerid, position.exitinterior )
			setElementDimension( playerid, position.exitdimension )
			unbindKey( playerid, "E", "down" )
			setElementData(playerid, "player:inHotel", false)
		end
	end
	exports.sarp_notify:addNotify(playerid, "Użyj: /pokoj [wejdz, zamknij]")
end

addCommandHandler( "pokoj", cmd.pokoj )

function cmd.megafon(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end

	local msg = {...}

	if not exports.sarp_items:isPlayerUseItem(playerid, 3) then
		return exports.sarp_notify:addNotify(playerid, "Nie używasz aktualnie megafonu.")
	end

	local groupid = getElementData(playerid, "player:duty")

	if not groupid or not haveGroupFlags(groupid, 1) or not isPlayerInGroup(playerid, groupid) then 
		return exports.sarp_notify:addNotify(playerid, "Grupa, w której jesteś na służbie nie posiada uprawnień do używania tej komendy.")
	end

	if getElementData(playerid, "player:muted") then
		return exports.sarp_notify:addNotify(playerid, "Posiadasz nałożony knebel - nie możesz nic mówić.")
	end

	if getElementData(playerid, "player:bw") > 0 then
		return exports.sarp_notify:addNotify(playerid, "Podczas BW nie możesz używać tej komendy.")
	end

	if #msg == 0 then
		return outputChatBox( "Uzyj: /m [tekst]", playerid )
	end

	local message = table.concat(msg, " ")
	local rad = 35.0
	local name = getPlayerRealName( playerid )
	local pX, pY, pZ = getElementPosition( playerid )
	local pInterior, pDimension = getElementInterior( playerid ), getElementDimension( playerid )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )

	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		if distance < rad then
			outputChatBox( name .. " mówi przez megafon: ".. message.."!!", v, 255, 255, 155)
		end
	end
	destroyElement( radius )
end

addCommandHandler( "m", cmd.megafon )
addCommandHandler( "megafon", cmd.megafon )

function cmd.bariera(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local params = {...}

	local groupid = getElementData(playerid, "player:duty")

	if not groupid or not haveGroupFlags(groupid, 64) or not isPlayerInGroup(playerid, groupid) then 
		return exports.sarp_notify:addNotify(playerid, "Grupa, w której jesteś na służbie nie posiada uprawnień do używania tej komendy.")
	end

	if params[1] == 'usun' then
		triggerClientEvent( "barrierDestroy", playerid )
	elseif params[1] == 'stworz' then
		params[2] = tonumber(params[2])

		if params[2] == 1 then
			triggerEvent( "objects:create", playerid,  1425, false)
		elseif params[2] == 2 then
			triggerEvent( "objects:create", playerid,  3578, false)
		elseif params[2] == 3 then
			triggerEvent( "objects:create", playerid,  1282, false)
		elseif params[2] == 4 then
			triggerEvent( "objects:create", playerid,  1228, false)
		elseif params[2] == 5 then
			triggerEvent( "objects:create", playerid,  1434, false)
		elseif params[2] == 6 then
			triggerEvent( "objects:create", playerid,  1424, false)
		elseif params[2] == 7 then
			triggerEvent( "objects:create", playerid,  1437, false)
		elseif params[2] == 8 then
			triggerEvent( "objects:create", playerid,  14449, false)
		elseif params[2] == 9 then
			triggerEvent( "objects:create", playerid,  1238, false)
		else
			return exports.sarp_notify:addNotify(playerid, "Użyj: /bariera stworz [ID 1-9]")
		end

		exports.sarp_notify:addNotify(playerid, "Utworzyłeś barierę, ustaw teraz ją w odpowiedniej pozycji następnie zapisz.")
	else
		return exports.sarp_notify:addNotify(playerid, "Użyj: /bariera [stworz, usun]")
	end
end

addCommandHandler( "bariera", cmd.bariera )

function cmd.radar(playerid, cmd)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local groupid = getElementData(playerid, "player:duty")

	if not isDutyInGroupType(playerid, {2, 4, 5, 6, 13}) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	local vehicle = getPedOccupiedVehicle( playerid)
	if vehicle and ( getPedOccupiedVehicleSeat( playerid ) == 0 or getPedOccupiedVehicleSeat( playerid ) == 1) then
		local vehicleData = exports.sarp_vehicles:getVehicleData(getElementData(vehicle, "vehicle:id"), {"ownerType", "ownerID"})
		
		if vehicleData.ownerType ~= 2 or vehicleData.ownerID ~= groupid then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć ten komendy musisz znajdować się w pojeździe grupy.")
		end

		triggerClientEvent( playerid, "PoliceRadar:ToggleManual", playerid, getPedOccupiedVehicle( playerid) )
	end
end
addCommandHandler( "pradar", cmd.radar )

function cmd.zbadaj(playerid, cmd, ...)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	local params = {...}
	local playerid2 = exports.sarp_main:getPlayerFromID(params[1])
	local groupid = getElementData(playerid, "player:duty")

	if not isDutyInGroupType(playerid, {2}) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /zbadaj [ID gracza]")
	end

	triggerEvent( "main:me", playerid, string.format("bada stan gracza %s.", exports.sarp_main:getPlayerRealName(playerid2)))
	exports.sarp_notify:addNotify(playerid, string.format("Alkohol we krwi: %.02f‰.", getElementData(playerid2, "drunkLevel")))
end

addCommandHandler( "zbadaj", cmd.zbadaj )

function cmd.knebel(playerid, cmd, playerid2)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	playerid2 = exports.sarp_main:getPlayerFromID(playerid2)

	if not isDutyInGroupType(playerid, {2}) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /knebel [ID gracza]")
	end

	if not getElementData(playerid2, "player:muted") then
		triggerEvent("main:me", playerid, string.format("zakłada knebel dla %s.", exports.sarp_main:getPlayerRealName(playerid2)))
		setElementData(playerid2, "player:muted", true)
	else
		triggerEvent("main:me", playerid, string.format("zdejmuje knebel dla %s.", exports.sarp_main:getPlayerRealName(playerid2)))
		removeElementData( playerid2, "player:muted" )
	end
end
addCommandHandler( "knebel", cmd.knebel )

function cmd.live(playerid, cmd, ...)
	local params = {...}
	local message = table.concat(params, " ")

	if not isDutyInGroupType(playerid, 12) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if string.len(message) == 0 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /live [tekst]")
	end

	if tostring(params[1]) == 'zakoncz' then
		updateNewsMessage()
	else
		updateNewsMessage(message, playerid, 1)
	end
end

addCommandHandler( "live", cmd.live )

function cmd.wywiad(playerid, cmd, params)
	if params == 'zakoncz' then
		local interview = getElementData(playerid, "player:interview")

		if not interview then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz rozpoczętego wywiadu.")
		end

		local playerid2 = exports.sarp_main:getPlayerFromID(interview)

		if playerid2 then
			removeElementData( playerid2, "player:interview" )
			exports.sarp_notify:addNotify(playerid2, string.format("Gracz %s zakończył wywiad.", exports.sarp_main:getPlayerRealName(playerid)))
		end

		removeElementData( playerid, "player:interview" )

		exports.sarp_notify:addNotify(playerid, "Wywiad został zakończony.")
		updateNewsMessage()
	else
		exports.sarp_notify:addNotify(playerid, "Użyj: /wywiad [zakoncz]")
	end
end

addCommandHandler( "wywiad", cmd.wywiad )

local advTimer = false
function cmd.reklama(playerid, cmd, ...)
	local params = {...}
	local time, message = tonumber(params[1]), table.concat(params, " ", 2)

	if not isDutyInGroupType(playerid, 12) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if not (time and string.len(message) ~= 0) then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /reklama [czas w minutach] [treść]")
	end
	
	if isTimer(advTimer) then
		killTimer( advTimer )
	end

	updateNewsMessage(message, playerid, 3)

	advTimer = setTimer(updateNewsMessage, time * 60000, 1)
end

addCommandHandler( "reklama", cmd.reklama )

function cmd.zabierz(playerid, cmd, playerID, itemID)
	local playerid2 = exports.sarp_main:getPlayerFromID(playerID)
	local groupID, itemID = getElementData(playerid, "player:duty"), tonumber(itemID)

	if not isDutyInGroupType(playerid, 2) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie grupy, która ma dostęp do tej komendy.")
	end

	if not haveGroupFlags(groupID, 256) then
		return exports.sarp_notify:addNotify(playerid, "Grupa, w której jesteś na służbie nie posiada uprawnień do używania tej komendy.")
	end

	if not (playerid2 and itemID) then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /zabierz [ID gracza] [UID przedmiotu]")
	end

	if exports.sarp_players:getDistanceToElement(playerid, playerid2) > 3.0 then
		return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
	end

	local item = exports.sarp_items:getItemData(itemID, {'ownerType', 'ownerID', 'name', 'used'})

	if not (item and item.ownerType == 1 and item.ownerID == getElementData(playerid2, "player:id")) then
		return exports.sarp_notify:addNotify(playerid, "Ten gracz nie posiada przedmiotu o podanym UID.")
	end

	if item.used then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz zabrać przedmiotu, który jest w użyciu.")
	end


	exports.sarp_items:setItemData(itemID, 'ownerID', getElementData(playerid, "player:id"), 'owner')
	triggerEvent('onItemsUpdate', playerid, playerid)
	triggerEvent('onItemsUpdate', playerid2, playerid2)
	exports.sarp_notify:addNotify(playerid, string.format("Zabrałeś przedmiot %s dla gracza %s.", item.name, exports.sarp_main:getPlayerRealName(playerid2)))
	exports.sarp_notify:addNotify(playerid2, string.format("%s zabrał tobie przedmiot %s.", exports.sarp_main:getPlayerRealName(playerid), item.name))
end

addCommandHandler( "zabierz", cmd.zabierz )

function cmd.paczka(playerid, cmd)
	local groupid = getElementData(playerid, "player:duty")

	if not (groupid and groupsData[groupid].type == 15 or getElementData(playerid, "player:jobs") == 2) then
		return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy, musisz być na służbie w grupie o typie Logistyki bądź prace dorywczą.")
	end

	if not (groupid and groupsData[groupid].type == 15) and getElementData(playerid, "player:jobs") == 2 and getElementData( playerid, "player:jobsCash" ) >= getElementData( playerid, "player:jobsCashMax") then
		return exports.sarp_notify:addNotify(playerid, "Przekroczyłeś limit dzienny w pracach dorywczych - wróć jutro.")
	end

	if not (groupid and groupsData[groupid].type == 15) and getPlayersDutyCount(15) > 0 then
		return exports.sarp_notify:addNotify(playerid, "Ktoś jest na służbie w grupie logistycznej, dlatego praca dorywcza została wstrzymana.")
	end

	if getElementData( playerid, "player:activeOrder") then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz używać tej komendy w czasie dostarczania paczki.")
	end

	--sprawdzamy czy jest w podanej pozycji
	local orderData = false
	local showBlip = false
	if getDistanceBetweenPoints3D( -535.865234, -501.860352, 25.517845, getElementPosition( playerid ) ) > 10.0 then
		showBlip = true
	else
		orderData = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_orders` WHERE `status` = 1" )

		if not orderData[1] then
			return exports.sarp_notify:addNotify(playerid, "Brak paczek w magazynie.")
		end

		for i, v in ipairs(orderData) do
			v.shippment = 50 + v.cost/10

			for j, k in ipairs(getElementsByType( "marker" )) do
				if getElementData( k, "type:doors") and not getElementData( k, "doors:exit") and getElementData( k, "doors:id") == v.doorid then
					v.position = Vector3(getElementPosition( k ))
					v.gName = getGroupData(getElementData(k, "doors:ownerID"), "name")
				end
 			end
		end
	end

	triggerClientEvent( playerid, "showOrders", playerid, showBlip, orderData)
end

addCommandHandler( "paczka", cmd.paczka )

function cmd.areszt(playerid, cmd, playerid2, time)
	playerid2, time = exports.sarp_main:getPlayerFromID(tonumber(playerid2)), tonumber(time)

	local lastDistance = 3.0
	local doorArrest = false
	for i, v in ipairs(getElementsByType( "marker" )) do
		local pX, pY, pZ = getElementPosition( playerid )
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, getElementPosition( v ) )

		if distance < lastDistance then
			if getElementData(v, "type:doors") and getElementData(v, "doors:arrest") then
				lastDistance = distance
				doorArrest = v
			end
		end
	end

	if not doorArrest or not isElement(doorArrest) then
		return exports.sarp_notify:addNotify(playerid, "Nie znaleziono w pobliżu odpowiednich drzwi do użycia tej komendy.")
	end

	if not playerid2 then
		return exports.sarp_notify:addNotify(playerid, 'Użyj: /areszt [ID gracza] [czas w godzinach (OOC)]')
	end

	if getElementData(playerid2, "player:arrestTime") and getElementData(doorArrest, "doors:id") == getElementData(playerid2, "player:door") then
		setElementPosition( playerid2, getElementPosition( doorArrest ) )
		setElementRotation( playerid2, getElementPosition( doorArrest ) )
		setElementDimension( playerid2, getElementDimension( doorArrest ) )
		setElementInterior( playerid2, getElementInterior( doorArrest ) )
		setElementData( playerid2, "player:door", false)
		setElementData(playerid2, "player:arrestTime", false)
		return exports.sarp_notify:addNotify(playerid, "Gracz został wypuszczony z aresztu.")
	end

	if not time then
		return exports.sarp_notify:addNotify(playerid, 'Użyj: /areszt [ID gracza] [czas w godzinach (OOC)]')
	end

	if exports.sarp_players:getDistanceToElement(playerid, playerid2) > 3.0 then
		return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
	end


	local exit = getElementData(doorArrest, "doors:parent")

	setElementPosition( playerid2, getElementPosition( exit ) )
	setElementRotation( playerid2, getElementPosition( exit ) )
	setElementDimension( playerid2, getElementDimension( exit ) )
	setElementInterior( playerid2, getElementInterior( exit ) )
	setElementData( playerid2, "player:door", getElementData(doorArrest, "doors:id"))
	setElementData( playerid2, "player:arrestTime", getRealTime().timestamp + time * 3600)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `arrestTime` = ?, `arrestDoor` = ? WHERE `player_id` = ?", getRealTime().timestamp + time * 3600, getElementData(doorArrest, "doors:id"), getElementData(playerid2, "player:id"))
	exports.sarp_notify:addNotify(playerid, string.format("Uwięziłeś gracza %s na %d godzin.", exports.sarp_main:getPlayerRealName(playerid2), time))
	exports.sarp_notify:addNotify(playerid2, string.format("Zostałeś uwięziony przez %s na %d godzin.", exports.sarp_main:getPlayerRealName(playerid), time))
end

addCommandHandler( 'areszt', cmd.areszt )