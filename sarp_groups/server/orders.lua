--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local orders = {}

function orders.accept(id)
	local query = exports.sarp_mysql:mysql_result("SELECT `status`, `doorid` FROM `sarp_orders` WHERE `id` = ?", id)

	if not (query[1] and query[1].status == 1) then
		return exports.sarp_notify:addNotify( source, "Te zgłoszenie nie jest już aktywne.")
	end

	local findDoor = false
	for i, v in ipairs(getElementsByType( "marker" )) do
		if getElementData( v, "type:doors") and not getElementData( v, "doors:exit") and getElementData( v, "doors:id") == query[1].doorid then
			findDoor = v
		end
	end

	if not findDoor then
		return exports.sarp_notify:addNotify( source, "Wystąpił błąd, podane drzwi w zgłoszeniu nie istnieją.")
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_orders` SET `status` = 2")
	setElementData( source, "player:activeOrder", id)

	local pX, pY, pZ = getElementPosition( findDoor )

	triggerClientEvent( source, "roadOrder", source, id, pX, pY, pZ)
end

addEvent( 'acceptOrder', true)
addEventHandler( 'acceptOrder', root, orders.accept )

function orders.complete()
	local activeOrder = getElementData( source, "player:activeOrder")
	if not activeOrder then return end


	exports.sarp_mysql:mysql_change("UPDATE `sarp_orders` SET `status` = 3")

	--pobieramy informacje, sprawdzamy czy jest taki sam produkt, jeżeli nie to tworzymy nowy

	local orderData = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_orders` WHERE `id` = ? LIMIT 1", activeOrder)

	if not orderData[1] then
		return exports.sarp_notify:addNotify( source, "Wystąpił błąd, zgłoszenie zostało całkowicie usunięte.")
	end

	local element = exports.sarp_doors:getDoorElement(orderData[1].doorid)

	local check = exports.sarp_mysql:mysql_result("SELECT `uid` FROM `sarp_magazine` WHERE `groupid` = ? AND `item_name` = ? AND `item_value1` = ? AND `item_value2` = ? LIMIT 1", getElementData(element, "doors:ownerID"), orderData[1].name, orderData[1].value1, orderData[1].value2 )

	if check[1] then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_magazine` SET `item_count` = `item_count` + ? WHERE `uid` = ?", orderData[1].count, check[1].uid)
	else
		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_magazine` SET `groupid` = ?, `item_name` = ?, `item_value1` = ?, `item_value2` = ?, `item_type` = ?, `item_count` = ?", getElementData(element, "doors:ownerID"), orderData[1].name, orderData[1].value1, orderData[1].value2, orderData[1].type, orderData[1].count)
	end

	local shippment = orderData[1].cost/10
	if isPlayerInGroupType(source, 15) then
		exports.sarp_notify:addNotify(source, string.format("Paczka została dostarczona - na konto grupy trafiło %d$.", 50 + shippment))
		giveGroupCash(getElementData(element, "doors:ownerID"), 50 + shippment)
	else
		exports.sarp_notify:addNotify(source, string.format("Paczka została dostarczona - zarobiłeś %d$.", 50 + shippment))
		setElementData( source, "player:jobsCash", getElementData( source, "player:jobsCash") + 50 + shippment)
		exports.sarp_players:givePlayerCash(source, 50 + shippment)
	end

	removeElementData( source, "player:activeOrder" )
end
addEvent( 'completeOrder', true)
addEventHandler( 'completeOrder', root, orders.complete )

function orders.onQuit()
	local order = getElementData( source, "player:activeOrder")

	if order then
		local query = exports.sarp_mysql:mysql_result("SELECT COUNT(*) as total FROM `sarp_orders` WHERE `id` = ? AND `status` = 2", order)

		if not query[1] or query[1].total == 0 then return end

		exports.sarp_mysql:mysql_change("UPDATE `sarp_orders` SET `status` = 1 WHERE `id` = ?", order)
	end
end

addEventHandler( "onPlayerQuit", root, orders.onQuit )