--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local offerData = {}
local offer = {}
local Settings = {
	dowod = 50,
	prawojazdy = 100,
	vehReg = 100
}

function createOffer(playerid, playerid2, type, price, info)
	if not type then return end

	if getElementData(playerid2, "activeoffer") then
		return exports.sarp_notify:addNotify(playerid, "Gracz o podanym id posiada aktywną oferte.")
	end

	local service = {}
	if type == 1 then
		service = {cost = price, seller = playerid, service = string.format("Pojazd - %s (UID: %d, %dHP)", getVehicleNameFromModel(info.model), info.id, isElement(info.mtaID) and getElementHealth(info.mtaID) or info.hp)}
	elseif type == 2 then
		service = {cost = price, seller = playerid, service = string.format("Przedmiot - %s (%d, %d)", info.name, info.value1, info.value2)}
	elseif type == 3 then
		service = {cost = price, seller = playerid, service = string.format("wyrobienie dowodu osobistego"), group = info.group}
	elseif type == 4 then
		service = {cost = price, seller = playerid, service = string.format("wyrobienie prawo jazdy"), group = info.group}
	elseif type == 5 then
		service = {cost = price, seller = playerid, service = string.format("Przedmiot - %s (%d sztuk)", info.name, info.amount), group = info.group}
	elseif type == 6 then
		service = {cost = price, seller = playerid, service = string.format("Zdjęcie blokady na koła (%s, UID: %d)", getVehicleNameFromModel(getElementModel(info.element)), getElementData(info.element, "vehicle:id")), group = info.group}
	elseif type == 7 then
		service = {cost = price, seller = playerid, service = string.format("Zarejestrowanie pojazdu (%s, UID: %d)", getVehicleNameFromModel(info.model), info.uid ), group = info.group}
	elseif type == 8 then
		service = {cost = price, seller = playerid, service = string.format("Mandat (%d punktów karnych)", info.points ), group = info.group}
	elseif type == 9 then
		service = {cost = price, seller = playerid, service = "Karnet na siłownie", group = info.group}
	elseif type == 10 then
		service = {cost = price, seller = playerid, service = "Leczenie", group = info.group}
	elseif type == 11 then
		service = {cost = price, seller = playerid, service = "Przywitanie się"}
	elseif type == 12 then
		service = {cost = price, seller = playerid, service = "Naprawa karoserii", group = info.group}
	elseif type == 13 then
		service = {cost = price, seller = playerid, service = "Naprawa silnika", group = info.group}
	elseif type == 14 then
		service = {cost = price, seller = playerid, service = string.format("Montaż części (%s)", info.name), group = info.group}
	elseif type == 15 then
		service = {cost = price, seller = playerid, service = string.format("Demontaż części (%s)", getElementData(info.vehid, "vehicle:tuning")[info.tune_id].name), group = info.group}
	elseif type == 16 then
		service = {cost = price, seller = playerid, service = "Wywiad", group = info.group}
	elseif type == 17 then
		service = {cost = price, seller = playerid, service = "Reklama", group = info.group}
	elseif type == 18 then
		service = {cost = price, seller = playerid, service = string.format("Dołączenie do grupy dynamicznej (%s)", info.name), group = info.group}
	end

	local timer = setTimer( function () 
		disableOffer(playerid2) 
		triggerClientEvent( "offer:disable", playerid2 ) 
		end, 30000, 1, playerid2 )
	table.insert(offerData, {dealer = playerid, buyer = playerid2, type = type, price = math.floor(price), info = info, timer = timer})
	setElementData(playerid2, "activeoffer", true)

	triggerClientEvent("offer:show", playerid2, service )
	exports.sarp_notify:addNotify(playerid, string.format("Wysłałeś ofertę do gracza %s.", exports.sarp_main:getPlayerRealName(playerid2)))

end

addEvent('createOffer', true)
addEventHandler( 'createOffer', root, createOffer )

function getOfferID(playerid)
	local id = 0
	for i, v in ipairs(offerData) do
		if v.buyer == playerid then
			id = i
			break
		end
	end
	return id
end

function acceptOffer(playerid, payment)
	local id = getOfferID(playerid)

	if not id then return end

	local pX, pY, pZ = getElementPosition( offerData[id].buyer )
	if getDistanceBetweenPoints3D( pX, pY, pZ, getElementPosition( offerData[id].dealer ) ) > 5.0 then
		disableOffer(playerid)
		return exports.sarp_notify:addNotify(playerid, "Oferta anulowana. Gracz nie znajduje się blisko Ciebie.")
	end

	if not isElement(offerData[id].dealer) or not exports.sarp_main:isPlayerLogged(offerData[id].dealer) then
		disableOffer(playerid)
		return exports.sarp_notify:addNotify(playerid, "Gracz wysyłajacy oferte opuścił gre, oferta odrzucona.")
	end

	if (payment == 1 and offerData[id].price > getElementData(playerid, "player:money")) or (payment == 2 and offerData[id].price > getElementData(playerid, "player:bank")) then
		disableOffer(playerid)
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz wystarczającej ilości gotówki.")
	end

	if offerData[id].type == 1 then
		if not exports.sarp_vehicles:isVehicleOwner(offerData[id].dealer, offerData[id]['info'].id, true) then
			disableOffer(playerid)
			return exports.sarp_notify:addNotify(offerData[id].buyer, "Sprzedający nie jest właścicielem tego pojazdu.")
		end

		exports.sarp_vehicles:changeVehicleOwner(offerData[id]['info'].id, 1, getElementData(offerData[id].buyer, "player:id"))
		exports.sarp_main:givePlayerCash(offerData[id].dealer, offerData[id].price)
	elseif offerData[id].type == 2 then
		if not exports.sarp_items:isItemOwner(offerData[id].dealer, offerData[id]['info'].id) then
			disableOffer(playerid)
			return exports.sarp_notify:addNotify(playerid, "Sprzedający nie jest właścicielem tego przedmiotu.")
		end

		exports.sarp_items:setItemData(offerData[id]['info'].id, "ownerID", getElementData(offerData[id].buyer, "player:id"), 'owner')
		exports.sarp_main:givePlayerCash(offerData[id].dealer, offerData[id].price)
	elseif offerData[id].type == 3 then
		if exports.sarp_main:havePlayerDocument(offerData[id].buyer, 1) then
			disableOffer(offerData[id].buyer)
			return exports.sarp_notify:addNotify(playerid, "Posiadasz już wyrobiony dowód osobisty!")
		end

		local documents = getElementData( offerData[id].buyer, "player:documents" )
		setElementData( offerData[id].buyer, "player:documents", documents + 1)

		exports.sarp_groups:giveGroupCash(offerData[id]['info'].element, offerData[id].price)
	elseif offerData[id].type == 4 then
		if exports.sarp_main:havePlayerDocument(offerData[id].buyer, 2) then
			disableOffer(offerData[id].buyer)
			return exports.sarp_notify:addNotify(playerid, "Posiadasz już wyrobione prawo jazdy!")
		end

		local documents = getElementData( offerData[id].buyer, "player:documents" )
		setElementData( offerData[id].buyer, "player:documents", documents + 2)
		exports.sarp_groups:giveGroupCash(offerData[id]['info'].element, offerData[id].price)
	
	elseif offerData[id].type == 5 then
		local product = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_magazine` WHERE `uid` = ?", offerData[id]['info'].id)

		if not product[1] or product[1].item_count - offerData[id]['info'].amount < 0 then
			disableOffer(offerData[id].buyer)
			return exports.sarp_notify:addNotify(source, "Oferta została odrzucona. Brak produktów o takiej liczbie w magazynie.")
		end

		if product[1].item_count - offerData[id]['info'].amount == 0 then
			exports.sarp_mysql:mysql_change("DELETE FROM `sarp_magazine` WHERE `uid` = ?", offerData[id]['info'].id)
		else
			exports.sarp_mysql:mysql_change("UPDATE `sarp_magazine` SET `item_count` = `item_count` - ? WHERE `uid` = ?", offerData[id]['info'].amount, offerData[id]['info'].id)
		end

		exports.sarp_items:createItem(getElementData(offerData[id].buyer, "player:id"), 1, product[1].item_name, product[1].item_type, product[1].item_value1, product[1].item_value2, offerData[id]['info'].amount, 0)

		exports.sarp_groups:giveGroupCash(product[1].groupid, offerData[id].price)
	elseif offerData[id].type == 6 then
		setElementData( offerData[id]['info'].element, "vehicle:policeBlock", 0)
		exports.sarp_vehicles:setVehicleData(offerData[id]['info'].element, 'policeBlock', 0)

		if getElementData(offerData[id]['info'].element, "vehicle:manual") == false then
			setElementFrozen( offerData[id]['info'].element, false )
		end

		exports.sarp_groups:giveGroupCash(offerData[id]['info'].groupid, offerData[id].price)
	elseif offerData[id].type == 7 then
		triggerEvent('registerVehicle', offerData[id].dealer, offerData[id]['info'].uid)
		exports.sarp_groups:giveGroupCash(offerData[id]['info'].groupid, offerData[id].price)
	elseif offerData[id].type == 8 then
		local driverPoints = getElementData(offerData[id].buyer, "player:driverPoints")

		if driverPoints + offerData[id]['info'].points >= 24 then
			setElementData(offerData[id].buyer, "player:documents", getElementData(offerData[id].buyer, "player:documents") - 2)
			setElementData(offerData[id].buyer, "player:driverPoints", 0)
			exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `driverPoints` = 0, `documents` = ?, `driverBlock` = ? WHERE `player_id` = ?", getElementData(offerData[id].buyer, "player:documents"), getRealTime().timestamp + 604800, getElementData(offerData[id].buyer, "player:id"))
		else
			setElementData(offerData[id].buyer, "player:driverPoints", driverPoints + offerData[id]['info'].points)
			exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `driverPoints` = ? WHERE `player_id` = ?", getElementData(offerData[id].buyer, "player:driverPoints"), getElementData(offerData[id].buyer, "player:id"))
		end
		exports.sarp_groups:giveGroupCash(offerData[id]['info'].groupid, offerData[id].price)
	elseif offerData[id].type == 9 then
		local lastTrening = getElementData(offerData[id].buyer, "player:lastTrening")

		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_gym` SET `player_id` = ?, `group_id` = ?, `date` = ?, `type` = 1", getElementData(offerData[id].buyer, "player:id"), offerData[id]['info'].groupid, getRealTime().timestamp)

		exports.sarp_groups:giveGroupCash(offerData[id]['info'].groupid, offerData[id].price)
	elseif offerData[id].type == 10 then
		setElementData( offerData[id].buyer, 'player:bw', 0)
		setElementHealth( offerData[id].buyer, 40 )
	elseif offerData[id].type == 11 then
		if getElementData(offerData[id].buyer, "player:cuffed") or getElementData(offerData[id].dealer, "player:cuffed") then
			exports.sarp_notify:addNotify(offerData[id].dealer, "Któryś z graczy jest zakuty w kajdanki.")
			disableOffer(offerData[id].buyer)
			return
		end

		local pRX, pRY, pRZ = getElementRotation( offerData[id].dealer )

		local player = offerData[id].dealer
		local matrix = player.matrix
		local newPosition = matrix:transformPosition(Vector3(0, 1, 0))

		setElementPosition( offerData[id].buyer, newPosition )
		setElementRotation( offerData[id].buyer, 0, 0, pRZ + 180 )
		setPedAnimation( offerData[id].dealer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false, false )
		setPedAnimation( offerData[id].buyer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false, false )
	elseif offerData[id].type == 12 then
		cancelPayment = true

		if not isElement(offerData[id]['info'].vehid) then
			return exports.sarp_notify:addNotify( offerData[id].dealer, "Ten pojazd nie jest zespawnowany.")
		end

		if not exports.sarp_doors:isGroupDoor(offerData[id]['info'].groupid, offerData[id].buyer) then
			return exports.sarp_notify:addNotify(offerData[id].buyer, "Aby użyć tej komendy musisz znajdować sie w budynku warsztatu.")
		end

		local repairLVL = exports.sarp_groups:getGroupLevelValue(offerData[id]['info'].groupid, "repairTime") / 100

		setElementData(offerData[id]['info'].vehid, "vehicle:repairTime", offerData[id].price * repairLVL)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairMechanic", offerData[id].dealer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairOwner", offerData[id].buyer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairInfo", {payment, offerData[id].price, offerData[id]['info'].groupid})
		setElementData(offerData[id]['info'].vehid, "vehicle:repairType", 1)
		setElementFrozen( offerData[id]['info'].vehid, true )
	elseif offerData[id].type == 13 then
		cancelPayment = true

		if not isElement(offerData[id]['info'].vehid) then
			return exports.sarp_notify:addNotify( offerData[id].dealer, "Ten pojazd nie jest zespawnowany.")
		end

		if not exports.sarp_doors:isGroupDoor(offerData[id]['info'].groupid, offerData[id].buyer) then
			return exports.sarp_notify:addNotify(offerData[id].buyer, "Aby użyć tej komendy musisz znajdować sie w budynku warsztatu.")
		end

		local repairLVL = exports.sarp_groups:getGroupLevelValue(offerData[id]['info'].groupid, "repairTime") / 100

		setElementData(offerData[id]['info'].vehid, "vehicle:repairTime", 120 * repairLVL)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairMechanic", offerData[id].dealer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairOwner", offerData[id].buyer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairInfo", {payment, offerData[id].price, offerData[id]['info'].groupid})
		setElementData(offerData[id]['info'].vehid, "vehicle:repairType", 2)
		setElementFrozen( offerData[id]['info'].vehid, true )
	elseif offerData[id].type == 14 then
		cancelPayment = true

		if not isElement(offerData[id]['info'].vehid) then
			return exports.sarp_notify:addNotify( offerData[id].dealer, "Ten pojazd nie jest zespawnowany.")
		end

		if not exports.sarp_doors:isGroupDoor(offerData[id]['info'].groupid, offerData[id].buyer) then
			return exports.sarp_notify:addNotify(offerData[id].buyer, "Aby użyć tej komendy musisz znajdować sie w budynku warsztatu.")
		end

		setElementData(offerData[id]['info'].vehid, "vehicle:repairTime", 45)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairMechanic", offerData[id].dealer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairOwner", offerData[id].buyer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairInfo", {payment, offerData[id].price, offerData[id]['info'].groupid, offerData[id]['info'].id})
		setElementData(offerData[id]['info'].vehid, "vehicle:repairType", 3)
		setElementFrozen( offerData[id]['info'].vehid, true )
	elseif offerData[id].type == 15 then
		cancelPayment = true

		if not isElement(offerData[id]['info'].vehid) then
			return exports.sarp_notify:addNotify( offerData[id].dealer, "Ten pojazd nie jest zespawnowany.")
		end

		if not exports.sarp_doors:isGroupDoor(offerData[id]['info'].groupid, offerData[id].buyer) then
			return exports.sarp_notify:addNotify(offerData[id].buyer, "Aby użyć tej komendy musisz znajdować sie w budynku warsztatu.")
		end

		setElementData(offerData[id]['info'].vehid, "vehicle:repairTime", 45)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairMechanic", offerData[id].dealer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairOwner", offerData[id].buyer)
		setElementData(offerData[id]['info'].vehid, "vehicle:repairInfo", {payment, offerData[id].price, offerData[id]['info'].groupid, offerData[id]['info'].tune_id})
		setElementData(offerData[id]['info'].vehid, "vehicle:repairType", 4)
		setElementFrozen( offerData[id]['info'].vehid, true )
	elseif offerData[id].type == 16 then
		setElementData(offerData[id].buyer, "player:interview", getElementData(offerData[id].dealer, "player:id"))
		setElementData(offerData[id].dealer, "player:interview", getElementData(offerData[id].buyer, "player:id"))
	elseif offerData[id].type == 17 then
		--tylko wpis do logów
	elseif offerData[id].type == 18 then
		triggerEvent( "memberAddDynamicGroup", offerData[id].dealer, offerData[id].buyer, offerData[id]['info'].id)
	end

	--wpis do log
	if offerData[id]['info'] and offerData[id]['info'].groupid then
		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_log` VALUES (0, 4, 2, ?, ?, ?, ?, ?)", offerData[id]['info'].groupid, offerData[id].price, getElementData(offerData[id].dealer, "player:id"), getRealTime().timestamp, getPlayerIP( offerData[id].dealer ))
	end

	if not cancelPayment then
		if payment == 1 then
			exports.sarp_main:givePlayerCash(offerData[id].buyer, - offerData[id].price)
		elseif payment == 2 then
			setElementData(offerData[id].buyer, "player:bank", getElementData(offerData[id].buyer, "player:bank") - offerData[id].price)
		end
	end

	exports.sarp_notify:addNotify(offerData[id].buyer, string.format("Zaakceptowałeś oferte od gracza %s.", getElementData(offerData[id].dealer, "player:username")))
	exports.sarp_notify:addNotify(offerData[id].dealer, string.format("Gracz %s zaakceptował twoją oferte.", getElementData(offerData[id].buyer, "player:username")))

	disableOffer(playerid)
end

addEvent('offer:accept', true)
addEventHandler('offer:accept', root, acceptOffer)

function disableOffer(playerid)
	local id = getOfferID(playerid)
	if offerData[id] and isTimer( offerData[id].timer ) then
		killTimer( offerData[id].timer )
	end

	table.remove(offerData, id)
	setElementData(playerid, "activeoffer", false)
end

addEvent( 'offer:disable', true )
addEventHandler( 'offer:disable', root, disableOffer )

local function playerQuit()
	if getElementData(source, "activeoffer") then
		disableOffer(source)
	end
end

addEventHandler( "onPlayerQuit", root, playerQuit )

function offer.cmd(playerid, cmd, playerid2, cmd2, ...)

	setElementData(playerid, "activeoffer", false)
	if not playerid2 or not cmd2 then
		return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] [pojazd | przedmiot | dowod | prawojazdy | rejestracja | mandat | karnet | montaz | demontaz | wywiad | reklama]")
	end

	local more = {...}
	playerid2 = exports.sarp_main:getPlayerFromID(playerid2)

	if getDistanceToElement(playerid, playerid2) > 3.0 then
		return exports.sarp_notify:addNotify(playerid, "Znajdujesz się zbyt daleko gracza.")
	end

	
	if cmd2 == 'pojazd' then
		local price = tonumber(more[1])
		local vehid = getPedOccupiedVehicle( playerid )
		local vehUID = getElementData(vehid, "vehicle:id")

		if not price then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] pojazd [cena]")
		end

		if not vehid or not getVehicleController( vehid ) then
			return exports.sarp_notify:addNotify(playerid, "Musisz znajdować się w pojeździe aby użyć tej komendy.")
		end
		local vehInfo = exports.sarp_vehicles:getVehicleData(vehUID, {'ownerID', 'ownerType', 'model', 'mtaID', 'hp', 'id'})

		if vehInfo.ownerType ~= 1 or vehInfo.ownerID ~= getElementData(playerid, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Pojazd w którym się znajdujesz nie należy do Ciebie.")
		end

		createOffer(playerid, playerid2, 1, price, vehInfo)

	elseif cmd2 == 'przedmiot' then
		local id, price = tonumber(more[1]), tonumber(more[2])

		if not price then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] przedmiot [ID przedmiotu] [cena]")
		end

		local itemInfo = exports.sarp_items:getItemData(id, {"ownerType", "ownerID", "used", "name", "id"})

		if not itemInfo or itemInfo.ownerType ~= 1 or itemInfo.ownerID ~= getElementData(playerid, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz przedmiotu o podanym UID w ekwipunku.")
		end

		if itemInfo.used then
			return exports.sarp_notify:addNotify(playerid, "Przedmiot który chcesz sprzedaż wciąż jest w użyciu.")
		end

		createOffer(playerid, playerid2, 2, price, itemInfo)
	elseif cmd2 == 'dowod' then

		if not exports.sarp_groups:isDutyInGroupType(playerid, 1) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not exports.sarp_doors:isGroupDoor(getElementData(playerid, "player:duty"), playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
		end

		if exports.sarp_main:havePlayerDocument(playerid2, 1) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym ID posiada już wyrobiony dowód osobisty.")
		end

		createOffer(playerid, playerid2, 3, Settings.dowod, {id = 0, groupid = getElementData(playerid, "player:duty")})
	elseif cmd2 == 'prawojazdy' then
		if not exports.sarp_groups:isDutyInGroupType(playerid, 1) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not exports.sarp_doors:isGroupDoor(getElementData(playerid, "player:duty"),playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
		end

		if exports.sarp_main:havePlayerDocument(playerid2, 2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym ID posiada już wyrobione prawo jazdy.")
		end

		local driverBlock = exports.sarp_mysql:mysql_result("SELECT `driverBlock` FROM `sarp_characters` WHERE `player_id` = ?", getElementData(playerid2, "player:id"))[1].driverBlock

		if driverBlock > getRealTime().timestamp then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz ma zablokowaną możliwość wyrabiania prawa jazdy na 7 dni.")
		end

		createOffer(playerid, playerid2, 4, Settings.prawojazdy, {id = 0, groupid = getElementData(playerid, "player:duty")})
	elseif cmd2 == 'rejestracja' then
		if not exports.sarp_groups:isDutyInGroupType(playerid, 1) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not exports.sarp_doors:isGroupDoor(getElementData(playerid, "player:duty"),playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
		end

		local vehicleID = tonumber(more[1])

		if not vehicleID then
			return exports.sarp_notify:addNotify(playerid, "Użyj /o [ID gracza] rejestracja [UID pojazdu]")
		end

		if not exports.sarp_vehicles:isVehicleOwner(playerid2, vehicleID, true, false) then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz nie jest właścicielem pojazdu o podanym UID.")
		end

		local vehicleInfo = exports.sarp_vehicles:getVehicleData(vehicleID, {'model', 'registered'})

		if vehicleInfo.registered == 1 then
			return exports.sarp_notify:addNotify(playerid, "Pojazd o podanym UID jest już zarejestrowany!")
		end

		createOffer(playerid, playerid2, 7, Settings.vehReg, {model = vehicleInfo.model, uid = vehicleID, groupid = getElementData(playerid, "player:duty")})
	
	elseif cmd2 == 'mandat' then
		local points, price = tonumber(more[1]), tonumber(more[2])

		if not exports.sarp_groups:isDutyInGroupType(playerid, 2) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not points or not price then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] mandat [liczba punktów karnych] [kwota]")
		end

		if not exports.sarp_main:havePlayerDocument(playerid2, 2) then
			return exports.sarp_notify:addNotify(playerid, "Gracz o podanym ID nie posiada prawo jazdy.")
		end
		if points < 0 or points > 24 then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowa ilość punktów karnych.")
		end
		if price < 0 then
			return exports.sarp_notify:addNotify(playerid, "Nieprawidłowa kwota nałożenia mandatu.")
		end

		createOffer(playerid, playerid2, 8, price, {points = points, groupid = getElementData(playerid, "player:duty")})

	elseif cmd2 == 'karnet' then
		if not exports.sarp_groups:isDutyInGroupType(playerid, 11) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		local query = exports.sarp_mysql:mysql_result("SELECT `date` FROM `sarp_gym` WHERE `group_id` = ? AND `player_id` = ? AND `date` > ? AND `type` = 1", getElementData(playerid, "player:duty"), getElementData(playerid2, "player:id"), getRealTime().timestamp - 84600)

		if query[1] then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz posiada już karnet do tej siłowni.")
		end

		createOffer(playerid, playerid2, 9, 100, {groupid = getElementData(playerid, "player:duty")})
	elseif cmd2 == 'leczenie' then
		if not exports.sarp_groups:isDutyInGroupType(playerid, 3) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		local bw = getElementData(playerid2, "player:bw")

		if bw <= 0 then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz nie posiada BW.")
		end

		createOffer(playerid, playerid2, 10, bw/10, {groupid = getElementData(playerid, "player:duty")})
	elseif cmd2 == 'naprawa' then
		if not exports.sarp_groups:isDutyInGroupType(playerid, 9) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not exports.sarp_doors:isGroupDoor(getElementData(playerid, "player:duty"),playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
		end

		local vehid = getPedOccupiedVehicle( playerid2 )
		if not vehid or not getVehicleController( vehid ) then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz nie znajduje się w pojeździe na miejscu kierowcy.")
		end

		local active = getElementData(vehid, "vehicle:repairTime")

		if active then
			return exports.sarp_notify:addNotify(playerid, "Nie można robić kilku czynności przy jednym pojeździe!")
		end

		local repair = tostring(more[1])

		if repair == 'k' then
			local price = 0

			for i = 0, 6 do
				if getVehiclePanelState( vehid, i ) ~= 0 then
					price = price + 20
				end
			end

			for i = 0, 5 do
				if getVehicleDoorState( vehid, i ) ~= 0 and getVehicleDoorState( vehid, i ) ~= 1 then
					price = price + 20
				end
			end

			for i = 0, 3 do
				if getVehicleLightState( vehid, i ) ~= 0 then
					price = price + 10
				end
			end

			for i, v in ipairs({getVehicleWheelStates( vehid )}) do
				if v == 1 or v == 2 then
					price = price + 30
				end
			end

			if price == 0 then
				return exports.sarp_notify:addNotify(playerid, "Ten pojazd nie ma uszkodzonej karoserii.")
			end

			createOffer(playerid, playerid2, 12, price, {groupid = getElementData(playerid, "player:duty"), vehid = vehid})
		elseif repair == 's' then
		
		local HP = getElementHealth( vehid )
		local mnoznik = 1
		if HP > 900 then
			mnoznik = 1
		elseif HP > 700 then
			mnoznik = 1.3
		elseif HP > 400 then
			mnoznik = 1.8
		else
			mnoznik = 2.0
		end

		local price = (1000.0 - HP) * mnoznik
		createOffer(playerid, playerid2, 13, price, {groupid = getElementData(playerid, "player:duty"), vehid = vehid})
		else
			return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] naprawa [k(aroseria)/s(ilnik)]")
		end
	elseif cmd2 == 'montaz' then
		local groupID = getElementData(playerid, "player:duty")

		if not exports.sarp_groups:isDutyInGroupType(playerid, 9) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not exports.sarp_doors:isGroupDoor(groupID,playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
		end

		if not exports.sarp_groups:getGroupLevelValue(groupID, "addComponent") then
			return exports.sarp_notify:addNotify(playerid, "Twoja grupa posiada zbyt mały poziom do użycia tej komendy.")
		end

		local vehid = getPedOccupiedVehicle( playerid2 )
		if not vehid or not getVehicleController( vehid ) then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz nie znajduje się w pojeździe na miejscu kierowcy.")
		end

		local active = getElementData(vehid, "vehicle:repairTime")

		if active then
			return exports.sarp_notify:addNotify(playerid, "Nie można robić kilku czynności przy jednym pojeździe!")
		end

		local id = tonumber(more[1])

		if not id then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] montaz [ID przedmiotu]")
		end

		local itemInfo = exports.sarp_items:getItemData(id, {"ownerType", "ownerID", "type", "value1", "value2", "name", "id"})

		if not itemInfo or itemInfo.ownerType ~= 1 or itemInfo.ownerID ~= getElementData(playerid, "player:id") then
			return exports.sarp_notify:addNotify(playerid, "Nie posiadasz przedmiotu o podanym UID w ekwipunku.")
		end

		if itemInfo.type ~= 9 then
			return exports.sarp_notify:addNotify(playerid, "Przedmiot o podanym ID nie służy do montażu.")
		end

		local tuning = getElementData(vehid, "vehicle:tuning")

		local have = false
		if type(tuning) == 'table' then
			for i, v in ipairs(tuning) do
				if itemInfo.value1 == v.type and itemInfo.value2 == v.value then
					have = true
					break
				end
			end
		end

		if have then
			return exports.sarp_notify:addNotify(playerid, "Taka część jest już zamontowana w tym pojeździe.")
		end

		itemInfo.vehid = vehid
		itemInfo.groupid = getElementData(playerid, "player:duty")

		createOffer(playerid, playerid2, 14, 50, itemInfo)
	elseif cmd2 == 'demontaz' then
		local groupID = getElementData(playerid, "player:duty")

		if not exports.sarp_groups:isDutyInGroupType(playerid, 9) then
			return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
		end

		if not exports.sarp_doors:isGroupDoor(groupID, playerid) then
			return exports.sarp_notify:addNotify(playerid, "Aby użyć tej komendy musisz znajdować sie w budynku grupy.")
		end

		if not exports.sarp_groups:getGroupLevelValue(groupID, "addComponent") then
			return exports.sarp_notify:addNotify(playerid, "Twoja grupa posiada zbyt mały poziom do użycia tej komendy.")
		end

		local vehid = getPedOccupiedVehicle( playerid2 )
		if not vehid or not getVehicleController( vehid ) then
			return exports.sarp_notify:addNotify(playerid, "Ten gracz nie znajduje się w pojeździe na miejscu kierowcy.")
		end

		local active = getElementData(vehid, "vehicle:repairTime")

		if active then
			return exports.sarp_notify:addNotify(playerid, "Nie można robić kilku czynności przy jednym pojeździe!")
		end

		triggerClientEvent( playerid, "vehicleTuningSelect", playerid, playerid2, vehid )

	elseif cmd2 == 'wywiad' then
        if not exports.sarp_groups:isDutyInGroupType(playerid, 12) then
            return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
        end

        if getElementData(playerid, "player:interview") or getElementData(playerid2, "player:interview") then
            return exports.sarp_notify:addNotify(playerid, "Ty, bądź gracz do którego wysyłasz oferte posiada rozpoczęty wywiad.")
        end

        createOffer(playerid, playerid2, 16, 0, {groupid = getElementData(playerid, "player:duty")})
    elseif cmd2 == 'reklama' then
        local price = tonumber(more[1])
        if not exports.sarp_groups:isDutyInGroupType(playerid, 12) then
            return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na służbie odpowiedniej grupy.")
        end
        if not price then
            return exports.sarp_notify:addNotify(playerid, "Użyj: /o [ID gracza] reklama [koszt]")
        end
        createOffer(playerid, playerid2, 17, price, {groupid = getElementData(playerid, "player:duty")})
    end
end

addCommandHandler( "o", offer.cmd )

function offer.product(productID, amount, playerid)
	local groupDuty = getElementData(source, "player:duty")

	if not groupDuty then
		return exports.sarp_notify:addNotify(source, "Nie znajdujesz się na służbie w żadnej grupie.")
	end

	local product = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_magazine` WHERE `uid` = ? AND `groupid` = ?", productID, groupDuty)

	if not product[1] or product[1].item_count - amount < 0 then
		return exports.sarp_notify:addNotify(source, "W magazynie nie ma wystarczającej ilości przedmiotów do złożenia tej oferty.")
	end

	local groupName = exports.sarp_groups:getGroupData(groupDuty, "name")
	createOffer(source, playerid, 5, product[1].price * amount, {id = productID, amount = amount, name = product[1].item_name, group = groupName})
end

addEvent('productOffer', true)
addEventHandler( 'productOffer', root, offer.product )