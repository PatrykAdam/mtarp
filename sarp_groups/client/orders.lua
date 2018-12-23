--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local orders = {}
local ordersData = {}

function orders.hide()
	destroyElement( ordersData.window )
	showCursor( false )

	--czyścimy pamięć
	ordersData = {}
end

function orders.accept()
	local id = guiGridListGetSelectedItem( ordersData.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie wybrałeś żadnego zlecenia.")
	end

	triggerServerEvent( "acceptOrder", localPlayer, ordersData.list[id].id )
end

function orders.show(blip, data)
	if blip then
		exports.sarp_notify:addNotify("Aby użyć tej komendy musisz znajdować się w magazynie paczek, miejsce zostało zaznaczone na mapie.")

		if isElement(orders.blip) then return end
		orders.blip = createBlip( -535.865234, -501.860352, 25.517845 )
		orders.marker = createMarker( -535.865234, -501.860352, 25.517845, nil, nil, 255, 0, 0 )

		addEventHandler( "onClientMarkerHit", orders.marker, function(player)
			if localPlayer ~= player then return end

			destroyElement( orders.marker )
			destroyElement( orders.blip )
		end)
	else
		if isElement(ordersData.window) then orders.hide() end
		ordersData.window = guiCreateWindow((screenX - 389) / 2, (screenY - 341) / 2, 389, 341, "Dostarczanie paczek", false)
		ordersData.list = data

		showCursor( true )

		guiWindowSetSizable(ordersData.window, false)

		ordersData.gridlist = guiCreateGridList(0.03, 0.07, 0.95, 0.78, true, ordersData.window)
		guiGridListAddColumn(ordersData.gridlist, "UID", 0.15)
		guiGridListAddColumn(ordersData.gridlist, "Nazwa grupy", 0.55)
		guiGridListAddColumn(ordersData.gridlist, "Wynagrodzenie", 0.2)
		guiGridListSetSortingEnabled( ordersData.gridlist, false )

		for i, v in ipairs(ordersData.list) do
			local row = guiGridListAddRow( ordersData.gridlist )
			guiGridListSetItemText( ordersData.gridlist, row, 1, v.id, false, false )
			guiGridListSetItemText( ordersData.gridlist, row, 2, v.gName, false, false )
			guiGridListSetItemText( ordersData.gridlist, row, 3, v.shippment, false, false )
		end

		ordersData.button = {}
		ordersData.button[1] = guiCreateButton(17, 303, 157, 24, "Przyjmij zlecenie", false, ordersData.window)
		ordersData.button[2] = guiCreateButton(212, 303, 157, 24, "Zamknij", false, ordersData.window)

		addEventHandler( "onClientGUIClick", ordersData.button[2], orders.hide, false )
		addEventHandler( "onClientGUIClick", ordersData.button[1], orders.accept, false )
	end
end

addEvent( 'showOrders', true)
addEventHandler( 'showOrders', root, orders.show )

local road = {}
road.blip = false
road.marker = false

function road.show(id, pX, pY, pZ)
	if getElementData( localPlayer, "player:activeOrder") and isElement(road.marker) then return end

	road.blip = createBlip( pX, pY, pZ )
	road.marker = createMarker( pX, pY, pZ, nil, nil, 255, 0, 0 )

	addEventHandler( "onClientMarkerHit", road.marker, function()
		triggerServerEvent( "completeOrder", localPlayer )
		destroyElement( road.blip )
		destroyElement( road.marker )
	end)

	orders.hide()

	exports.sarp_notify:addNotify("Zgłoszenie zostało przyjęte. Udaj się w zaznaczony na mapie punkt, aby dostarczyć paczke.")
end

addEvent( 'roadOrder', true)
addEventHandler( 'roadOrder', root, road.show )