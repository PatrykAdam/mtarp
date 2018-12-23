--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local door = {}
door.active = false

function door.hide()
  removeEventHandler( "onClientGUIClick", door.button[1], door.save, false )
  removeEventHandler( "onClientGUIClick", door.button[2], door.savePos, false )
  removeEventHandler( "onClientGUIClick", door.button[3], door.buyObjects, false )
  removeEventHandler( "onClientGUIClick", door.button[4], door.hide, false )
	destroyElement( door.window )
	showCursor( false )
	door.active = false
end

function door.save()
	local name, description, garage, entry = tostring(guiGetText( door.edit[1] )), tostring( guiGetText( door.memo )), guiCheckBoxGetSelected( door.checkbox ), tonumber( guiGetText(door.edit[2]) )

	if string.len(name) > 28 then
		return exports.sarp_notify:addNotify("Za długa nazwa drzwi.")
	end

	if string.len(description) > 48 then
		return exports.sarp_notify:addNotify("Za długi opis drzwi.")
	end

	outputDebugString( guiCheckBoxGetSelected( door.checkbox ) )
	triggerServerEvent( "saveDoor", localPlayer, door.id, name, description, garage, entry )
end
 
function door.savePos()
	triggerServerEvent( "saveDoorExit", localPlayer, door.id )
	door.hide()
end

function door.sendBuy()
	triggerServerEvent( "buyDoorObjects", localPlayer, door.id, door.objectCount)
	door.hideBuy()
end

function door.hideBuy()
	removeEventHandler( "onClientGUIClick", door.button[5], door.sendBuy, false )
  removeEventHandler( "onClientGUIClick", door.button[6], door.hideBuy, false )
	destroyElement( door.buyWindow )
	door.activeBuy = false
end

function door.buyObjects()
	door.objectCount = tonumber(guiGetText( door.edit[3] ))
	if door.objectCount < 0 then
		return door.hideBuy()
	end

	door.buyWindow = guiCreateWindow((screenX - 332) / 2, (screenY - 96) / 2, 332, 96, "Zakup obiektów", false)
  guiWindowSetSizable(door.buyWindow, false)
  door.label[8] = guiCreateLabel(0.03, 0.26, 0.92, 0.35, string.format("Czy na pewno chcesz kupić %d obiektów za kwotę %d$?", door.objectCount, door.objectCount * 200), true, door.buyWindow)
  guiLabelSetHorizontalAlign(door.label[8], "left", true)
  door.button[5] = guiCreateButton(0.06, 0.67, 0.35, 0.23, "Tak", true, door.buyWindow)
  door.button[6] = guiCreateButton(0.57, 0.67, 0.35, 0.23, "Nie", true, door.buyWindow)    

  addEventHandler( "onClientGUIClick", door.button[5], door.sendBuy, false )
  addEventHandler( "onClientGUIClick", door.button[6], door.hideBuy, false )
end

function door.buyAudio()
  triggerServerEvent( "buyDoorAudio", localPlayer, door.id)
  removeEventHandler( "onClientGUIClick", door.button[8], door.buyAudio, false )
  door.hide()
end

function door.changeURL()
  local url = tostring(guiGetText( door.edit[4] ))

  if not (string.sub(url, -4):lower() == ".mp3" or string.sub(url, -4):lower() == ".wav" or string.sub(url , -4) == ".ogg" or string.sub(url, -4) == ".pls" or string.sub(url, -4) == ".m3u") then
      return exports.sarp_notify:addNotify("Nieprawidłowy format URL.")
  end

  removeEventHandler( "onClientGUIClick", door.button[7], door.changeURL, false )
  triggerServerEvent( "changeDoorURL", localPlayer, door.id, url)
  door.hide()
end

function door.show(element, doorData)
	if door.active then door.hide() end
	showCursor( true )
	door.id = getElementData( element, "doors:id")
	door.active = true
	door.window = guiCreateWindow((screenX - 363) / 2, (screenY - 418) / 2, 363, 418, string.format("Drzwi (UID: %d)", door.id), false)
  guiWindowSetSizable(door.window, false)

  door.tabpanel = guiCreateTabPanel(0.02, 0.06, 0.95, 0.87, true, door.window)

  door.tab = {}
  door.tab[1] = guiCreateTab("Informacje ogólne", door.tabpanel)

  door.gridlist = guiCreateGridList(0.03, 0.03, 0.94, 0.94, true, door.tab[1])
  guiGridListAddColumn(door.gridlist, "Nazwa", 0.4)
  guiGridListAddColumn(door.gridlist, "Wartość", 0.5)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 0, 1, "Nazwa drzwi:", false, false)
  guiGridListSetItemText(door.gridlist, 0, 2, getElementData( element, "doors:name"), false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 1, 1, "Pozycja wejścia:", false, false)
  guiGridListSetItemText(door.gridlist, 1, 2, string.format("%d, %d, %d", getElementPosition( element )), false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 2, 1, "Pozycja wyjścia:", false, false)
  guiGridListSetItemText(door.gridlist, 2, 2, string.format("%d, %d, %d", getElementPosition( getElementData( element, "doors:parent") )), false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 3, 1, "Typ właściciela:", false, false)
  guiGridListSetItemText(door.gridlist, 3, 2, getElementData( element, "doors:ownerType") == 2 and "Grupa" or "Gracz", false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 4, 1, "Właściciel:", false, false)
  guiGridListSetItemText(door.gridlist, 4, 2, string.format("%s", doorData.owner), false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 5, 1, "UID właściciela:", false, false)
  guiGridListSetItemText(door.gridlist, 5, 2, string.format("%d", getElementData( element, "doors:ownerID")), false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 6, 1, "ID pickupa:", false, false)
  guiGridListSetItemText(door.gridlist, 6, 2, getElementModel( element ), false, false)
  guiGridListAddRow(door.gridlist)
  guiGridListSetItemText(door.gridlist, 7, 1, "Wykupione obiekty:", false, false)
  guiGridListSetItemText(door.gridlist, 7, 2, getElementData( element, "doors:objects"), false, false)

  door.tab[2] = guiCreateTab("Ustawienia", door.tabpanel)

  door.label = {}
  door.label[1] = guiCreateLabel(0.03, 0.04, 0.25, 0.06, "Nazwa drzwi:", true, door.tab[2])
  guiLabelSetVerticalAlign(door.label[1], "center")
  door.edit = {}
  door.edit[1] = guiCreateEdit(0.27, 0.04, 0.67, 0.07, getElementData( element, "doors:name"), true, door.tab[2])
  door.label[2] = guiCreateLabel(0.03, 0.14, 0.25, 0.06, "Opis drzwi:", true, door.tab[2])
  guiLabelSetVerticalAlign(door.label[2], "center")
  door.memo = guiCreateMemo(0.27, 0.14, 0.67, 0.19, getElementData( element, "doors:description"), true, door.tab[2])
  door.button = {}
  door.button[1] = guiCreateButton(0.29, 0.53, 0.41, 0.08, "Zapisz zmiany", true, door.tab[2])
  door.label[3] = guiCreateLabel(0.03, 0.36, 0.35, 0.06, "Przejazd pojazdami:", true, door.tab[2])
  guiLabelSetVerticalAlign(door.label[3], "center")
  door.checkbox = guiCreateCheckBox(0.35, 0.37, 0.04, 0.05, "", getElementData( element, "doors:garage") == 1 and true or false, true, door.tab[2])
  door.label[4] = guiCreateLabel(0.03, 0.45, 0.35, 0.06, "Opłata za wejście:", true, door.tab[2])
  guiLabelSetVerticalAlign(door.label[4], "center")
  door.edit[2] = guiCreateEdit(0.38, 0.45, 0.24, 0.06, getElementData( element, "doors:entry"), true, door.tab[2])
  door.label[5] = guiCreateLabel(0.32, 0.45, 0.06, 0.06, "$", true, door.tab[2])
  guiLabelSetHorizontalAlign(door.label[5], "center", false)
  guiLabelSetVerticalAlign(door.label[5], "center")
  door.button[2] = guiCreateButton(0.17, 0.88, 0.67, 0.08, "Ustaw pozycje wyjścia w tym miejscu", true, door.tab[2])
  guiSetProperty(door.button[2], "NormalTextColour", "FFFFFFFF")
  door.label[6] = guiCreateLabel(0.03, 0.63, 0.35, 0.06, "Liczba obiektów:", true, door.tab[2])
  guiLabelSetVerticalAlign(door.label[6], "center")
  door.edit[3] = guiCreateEdit(0.32, 0.63, 0.24, 0.06, "", true, door.tab[2])
  door.label[7] = guiCreateLabel(0.03, 0.72, 0.48, 0.07, "1 obiekt = 200$", true, door.tab[2])
  guiLabelSetVerticalAlign(door.label[7], "center")
  door.button[3] = guiCreateButton(0.60, 0.63, 0.29, 0.07, "Kup obiekty", true, door.tab[2])
  door.button[4] = guiCreateButton(0.05, 0.94, 0.89, 0.04, "Zamknij", true, door.window)

  door.tab[3] = guiCreateTab("Wyposażenie", door.tabpanel)

  door.label[8] = guiCreateLabel(0.03, 0.04, 0.25, 0.06, "System audio:", true, door.tab[3])
  if doorData.audio then
    door.edit[4] = guiCreateEdit(0.3, 0.04, 0.4, 0.06, getElementData( element, "doors:url"), true, door.tab[3])
    door.button[7] = guiCreateButton(0.72, 0.04, 0.2, 0.06, "Zmień", true, door.tab[3])
    addEventHandler( "onClientGUIClick", door.button[7], door.changeURL, false )
  else
    door.button[8] = guiCreateButton(0.3, 0.04, 0.4, 0.06, "Zakup za 2000$", true, door.tab[3])
    addEventHandler( "onClientGUIClick", door.button[8], door.buyAudio, false )
  end

  addEventHandler( "onClientGUIClick", door.button[1], door.save, false )
  addEventHandler( "onClientGUIClick", door.button[2], door.savePos, false )
  addEventHandler( "onClientGUIClick", door.button[3], door.buyObjects, false )
  addEventHandler( "onClientGUIClick", door.button[4], door.hide, false )
end

addEvent('doorManage', true)
addEventHandler( 'doorManage', localPlayer, door.show )