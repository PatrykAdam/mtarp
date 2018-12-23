--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local kup = {}
kup.active = false

function kup.send()
	local id = guiGridListGetSelectedItem( kup.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego przedmiotu")
	end

	triggerServerEvent( "playerBuy", localPlayer, kup.productList[id].uid )
	kup.hide()
end

function kup.hide()
	showCursor( false )
  destroyElement( kup.window )
  kup.active = false
  kup.productList = nil
end

function kup.show(productList)
	if kup.active then return end
	showCursor( true )
	kup.active = true
	kup.productList = productList
	kup.window = guiCreateWindow((screenX - 367) / 2, (screenY - 397) / 2, 367, 397, "Produkty w sklepie", false)
	guiWindowSetSizable(kup.window, false)

	kup.gridlist = guiCreateGridList(0.02, 0.07, 0.95, 0.84, true, kup.window)
	guiGridListAddColumn(kup.gridlist, "Nazwa przedmiotu", 0.6)
	guiGridListAddColumn(kup.gridlist, "Cena", 0.2)
	kup.button = {}
	kup.button[1] = guiCreateButton(0.05, 0.92, 0.38, 0.06, "Zakup przedmiot", true, kup.window)
	kup.button[2] = guiCreateButton(0.57, 0.92, 0.38, 0.05, "Zamknij", true, kup.window)

	addEventHandler ( "onClientGUIClick", kup.button[1], kup.send, false )
  addEventHandler ( "onClientGUIClick", kup.button[2], kup.hide, false )
  kup.update()
end

addEvent("buyList", true)
addEventHandler( "buyList", root, kup.show )

function kup.update()
	guiGridListClear( kup.gridlist )
	for i, v in ipairs(kup.productList) do
		local row = guiGridListAddRow( kup.gridlist )
		guiGridListSetItemText( kup.gridlist, row, 1, v.item_name, false, false )
		guiGridListSetItemText( kup.gridlist, row, 2, v.price, false, false )
	end
end
