--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local groups = {}

function groups.chatOOC(slot, message)
	local groupid = getElementData(source, "group_"..slot..":id")
	if not groupid then return exports.sarp_notify:addNotify(source, "Nie posiadasz grupy na tym slocie.") end

	if not haveGroupPermission(source, groupid, 512) then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do używania czatu OOC grupy.")
	end
	local r, g, b = unpack(groupsData[groupid].color)
	for i, v in ipairs(getElementsByType( "player" )) do
		if isPlayerInGroup(v, groupid) then
			triggerClientEvent( "addPlayerOOCMessage", v, string.format("(( %s (%s): %s ))", getElementData(source, "player:username"), groupsData[groupid].name, message), tonumber(r), tonumber(g), tonumber(b) )
		end
	end
end

addEvent("groups:chatOOC", true)
addEventHandler( "groups:chatOOC", root, groups.chatOOC )

function groups.chatIC(slot, message)
	local groupid = getElementData(source, "group_"..slot..":id")
	if not groupid then return exports.sarp_notify:addNotify(source, "Nie posiadasz grupy na tym slocie.") end

	local r, g, b = unpack(groupsData[groupid].color)
	for i, v in ipairs(getElementsByType( "player" )) do
		if isPlayerInGroup(v, groupid) then
			outputChatBox( string.format("** %s: %s **", getElementData(source, "player:username"), message), v, tonumber(r), tonumber(g), tonumber(b) )
		end
	end
end

addEvent("groups:chatIC", true)
addEventHandler( "groups:chatIC", root, groups.chatIC )

function groups.magazinePull(id, amount, groupid)
	if not haveGroupPermission(source, groupid, 4096) then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do wyciągania przedmiotów z magazynu.")
	end
	local product = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_magazine` WHERE `uid` = ?", id)

	if not product[1] or product[1].item_count - amount < 0 then
		return exports.sarp_notify:addNotify(source, "Brak produktów o takiej liczbie w magazynie.")
	end

	if product[1].item_count - amount == 0 then
		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_magazine` WHERE `uid` = ?", id)
	else
		exports.sarp_mysql:mysql_change("UPDATE `sarp_magazine` SET `item_count` = `item_count` - ? WHERE `uid` = ?", amount, id)
	end

	exports.sarp_items:createItem(getElementData(source, "player:id"), 1, product[1].item_name, product[1].item_type, product[1].item_value1, product[1].item_value2, amount, 0)
	exports.sarp_notify:addNotify(source, "Produkt został wyciągnięty z magazynu")
end

addEvent("magazinePull", true)
addEventHandler( "magazinePull", root, groups.magazinePull )

function groups.playerBuy(productID)
	local product = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_magazine` WHERE `uid` = ?", productID)

	if not product[1] or product[1].item_count == 0 then
		return exports.sarp_notify:addNotify(source, "Brak produktu w magazynie sklepu.")
	end

	if product[1].price > getPlayerMoney( source ) then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz wystarczającej ilości gotówki.")
	end

	if not exports.sarp_doors:isGroupDoor(product[1].groupid, source) or groupsData[product[1].groupid].type ~= 19 then
		return exports.sarp_notify:addNotify(source, "Nie znajdujesz się w budynku, który umożliwia sprzedaż za pomocą /kup.")
	end

	if product[1].item_count - 1 == 0 then
		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_magazine` WHERE `uid` = ?", productID)
	else
		exports.sarp_mysql:mysql_change("UPDATE `sarp_magazine` SET `item_count` = `item_count` - 1 WHERE `uid` = ?", productID)
	end

	exports.sarp_main:givePlayerCash(source, - product[1].price)
	exports.sarp_items:createItem(getElementData(source, "player:id"), 1, product[1].item_name, product[1].item_type, product[1].item_value1, product[1].item_value1, 1, 0)
	exports.sarp_notify:addNotify(source, "Zakupiłeś przedmiot w sklepie.")
end

addEvent("playerBuy", true)
addEventHandler( "playerBuy", root, groups.playerBuy )

function groups.checkIn(motelID, day)
	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_hotel` WHERE `player_id` = ? AND `door_id` = ?", getElementData(source, "player:id"), motelID)
	if query[1] then
		local date

		date = day * 86400

		if query[1].date < getRealTime().timestamp then
			date = date + getRealTime().timestamp

			if date - getRealTime().timestamp > 2678400 then
				return exports.sarp_notify:addNotify(source, "Maksymalnie możesz wynająć pokój na 31 dni.")
			end
			exports.sarp_notify:addNotify(source, string.format("Zostałeś zameldowany w hotelu na %d dni.", day))
		else
			date = date + query[1].date
			
			if date - getRealTime().timestamp > 2678400 then
				return exports.sarp_notify:addNotify(source, "Maksymalnie możesz wynająć pokój na 31 dni.")
			end

			exports.sarp_notify:addNotify(source, string.format("Przedłużyłeś swój pobyt w hotelu o %d dni.", day))
		end

		exports.sarp_mysql:mysql_change("UPDATE `sarp_hotel` SET `date` = ? WHERE `player_id` = ? AND `door_id` = ?", date, getElementData(source, "player:id"), motelID)
	else
		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_hotel` SET `date` = ?, `player_id` = ?, `door_id` = ?", getRealTime().timestamp + (day * 86400), getElementData(source, "player:id"), motelID)
		exports.sarp_notify:addNotify(source, string.format("Zostałeś zameldowany w hotelu na %d dni.", day))
	end

	setElementData(source, "player:spawn", {1, motelID})
	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `spawnType` = ?, `spawnID` = ? WHERE `player_id` = ?", 1, motelID, getElementData(source, "player:id"))
	exports.sarp_main:givePlayerCash(source, - (day * 14))
end

addEvent('motelcheckIn', true)
addEventHandler( 'motelcheckIn', root, groups.checkIn )

function groups.checkOut(motelID)
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_hotel` WHERE `player_id` = ? AND `group_id` = ?", getElementData(source, "player:id"), motelID)
	exports.sarp_notify:addNotify(source, "Zostałeś wymeldowany z hotelu.")
end

addEvent('motelcheckOut', true)
addEventHandler( 'motelcheckOut', root, groups.checkOut )

function groups.endArrest()
	setElementData(source, "player:arrestTime", 0)
	local doorID = getElementData(source, "player:door")

	local doorElement = false
	for i, v in ipairs(getElementsByType( "marker" )) do
		if getElementData(v, "doors:id") == doorID and not getElementData(v, "doors:exit") then
			doorElement = v
		end
	end

	if isElement(doorElement) then
 		setElementPosition( source, getElementPosition( doorElement ) )
 		setElementRotation( source, getElementRotation( doorElement ) )
 		setElementDimension( source, getElementDimension( doorElement ) )
 		setElementInterior( source, getElementInterior( doorElement ) )
 		setElementData( source, "player:door", false)
 		exports.sarp_notify:addNotify(source, "Zostałeś wypuszczony z więzienia.")
 	end
end

addEvent('endArrest', true)
addEventHandler( 'endArrest', root, groups.endArrest )