--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local buy = {}
buy.selected = 1
buy.active = false
buy.height = dxGetFontHeight( 1.2, "default-bold" )

function buy.acceptHide()
	removeEventHandler( "onClientGUIClick", buy.button[1], buy.confirm, false )
  removeEventHandler( "onClientGUIClick", buy.button[2], buy.acceptHide, false )
  destroyElement( buy.window )
  showCursor( false )
  buy.active = false
end

function buy.confirm()
	triggerServerEvent( "buyClothes", localPlayer, buy.selected )
	buy.acceptHide()
	buy.cancel()
end

function buy.cancel()
	toggleAllControls( true )
	removeEventHandler( "onClientKey", root, buy.onKey )
	removeEventHandler( "onClientRender", root, buy.onRender )
	setElementModel( localPlayer, getElementData(localPlayer, "player:lastskin") )
end

function buy.acceptButton()
	if buy.active then return end
	buy.active = true
	showCursor( true )
	buy.window = guiCreateWindow((screenX - 285) / 2, (screenY - 103) / 2, 285, 103, "Zakup ubrania", false)
  guiWindowSetSizable(buy.window, false)
  buy.label = guiCreateLabel(0.04, 0.30, 0.93, 0.38, "Czy na pewno chcesz zakupić skin o ID 160 za kwotę 150$?", true, buy.window)
  guiLabelSetHorizontalAlign(buy.label, "left", true)
  buy.button = {}
  buy.button[1] = guiCreateButton(0.07, 0.68, 0.33, 0.21, "Tak", true, buy.window)
  buy.button[2] = guiCreateButton(0.60, 0.68, 0.33, 0.21, "Nie", true, buy.window)

  addEventHandler( "onClientGUIClick", buy.button[1], buy.confirm, false )
  addEventHandler( "onClientGUIClick", buy.button[2], buy.acceptHide, false )
end

function buy.onKey(button, press)
	if not press then return end

	if button == 'a' then
		if buy.selected == buy.clothesMAX then
			buy.selected = 1
		else
			buy.selected = buy.selected + 1
		end
		setElementModel( localPlayer, getClothesID(buy.selected, buy.sex) )
	elseif button == 'd' then
		if buy.selected == 1 then
			buy.selected = buy.clothesMAX
		else
			buy.selected = buy.selected - 1
		end
		setElementModel( localPlayer, getClothesID(buy.selected, buy.sex) )
	elseif button == 'enter' then
		buy.acceptButton()
	elseif button == 'rshift' then
		buy.cancel()
	end
end

function buy.onRender()
	dxDrawText( "Naciskaj a, d aby zmieniać ubranie. Aby zatwierdzić naciśnij Enter.", 1, screenY - 99 * scaleY, screenX + 1, 1, tocolor(0, 0, 0), 1.2, "default-bold", "center", "top" )
	dxDrawText( "Naciskaj a, d aby zmieniać ubranie. Aby zatwierdzić naciśnij #FF0000Enter#FFFFFF.", 0, screenY - 100 * scaleY, screenX, 0, tocolor(255, 255, 255), 1.2, "default-bold", "center", "top", false, false, false, true )
	
	dxDrawText( string.format("Cena: $%d, shift aby anulować.", getClothesPrize(buy.selected, buy.sex)), 1, screenY - 89 * scaleY + buy.height, screenX + 1, 1, tocolor(0, 0, 0), 1.2, "default-bold", "center", "top" )
	dxDrawText( string.format("Cena: $%d, shift aby anulować.", getClothesPrize(buy.selected, buy.sex)), 0, screenY - 90 * scaleY + buy.height, screenX, 0, tocolor(255, 255, 255), 1.2, "default-bold", "center", "top" )
end

function buy.show()
	buy.sex = getElementData(localPlayer, "player:sex") and "women" or "men"
	buy.clothesMAX = getClothesMAX(buy.sex)
	toggleAllControls( false, true, false)
	addEventHandler( "onClientKey", root, buy.onKey )
	addEventHandler( "onClientRender", root, buy.onRender )
	setElementModel( localPlayer, getClothesID(buy.selected, buy.sex) )
end

addEvent("buySkin", true)
addEventHandler( "buySkin", localPlayer, buy.show )