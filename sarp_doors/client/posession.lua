--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local posession = {}

function posession.hide()
	removeEventHandler( "onClientGUIClick", posession.button[1], posession.hide, false )
	removeEventHandler( "onClientGUIClick", posession.button[2], posession.add, false )
	removeEventHandler( "onClientGUIClick", posession.button[2], posession.remove, false )
	posession.active = false
	destroyElement( posession.window )
	showCursor( false )
end

function posession.add()
	local id = guiGridListGetSelectedItem( posession.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnej posiadłości z listy.")
	end

	local mtaID = guiGetText( posession.edit )
	local playerid = exports.sarp_main:getPlayerFromID(mtaID)

	if not playerid then
		return exports.sarp_notify:addNotify("Nie znaleziono gracza o podanym id.")
	end

	triggerServerEvent( "posessionAdd", localPlayer, posession.list[id].id, playerid )
end

function posession.remove()
	local id = guiGridListGetSelectedItem( posession.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnej posiadłości z listy.")
	end

	local mtaID = guiGetText( posession.edit )
	local playerid = exports.sarp_main:getPlayerFromID(mtaID)

	if not playerid then
		return exports.sarp_notify:addNotify("Nie znaleziono gracza o podanym id.")
	end

	triggerServerEvent( "posessionRemove", localPlayer, posession.list[id].id, playerid )
end

function posession.access()
	local id = guiGridListGetSelectedItem( posession.gridlist ) + 1

	triggerServerEvent( "showPlayerDynamicGroup", localPlayer, 2, posession.list[id].id)
end

function posession.show(posessionList)
	if posession.active then posession.hide() end
	showCursor( true )
	posession.active = true
	posession.list = posessionList
	posession.window = guiCreateWindow((screenX - 405) / 2, (screenY - 241) / 2, 405, 241, "Posiadłości", false)
	guiWindowSetSizable(posession.window, false)

	posession.gridlist = guiCreateGridList(0.02, 0.10, 0.95, 0.58, true, posession.window)
	guiGridListAddColumn(posession.gridlist, "UID", 0.3)
	guiGridListAddColumn(posession.gridlist, "Nazwa drzwi", 0.3)
	guiGridListAddColumn(posession.gridlist, "Rola", 0.3)
	posession.button = {}
	posession.button[1] = guiCreateButton(0.53, 0.88, 0.40, 0.07, "Zamknij", true, posession.window)
	posession.label = guiCreateLabel(0.04, 0.71, 0.30, 0.10, "ID gracza:", true, posession.window)
	guiLabelSetVerticalAlign(posession.label, "center")
	posession.edit = guiCreateEdit(0.20, 0.71, 0.20, 0.10, "", true, posession.window)
	posession.button[2] = guiCreateButton(0.43, 0.71, 0.21, 0.09, "Zaproś", true, posession.window)
	posession.button[3] = guiCreateButton(0.67, 0.71, 0.21, 0.09, "Wyrzuć", true, posession.window)
	posession.button[4] = guiCreateButton(0.03, 0.88, 0.40, 0.07, "Udostępnij", true, posession.window)

	for i, v in ipairs(posession.list) do
		local row = guiGridListAddRow ( posession.gridlist )
		guiGridListSetItemText ( posession.gridlist, row, 1, v.id, false, false )
		guiGridListSetItemText ( posession.gridlist, row, 2, v.name, false, false )
		guiGridListSetItemText ( posession.gridlist, row, 3, v.rank, false, false )
	end

	addEventHandler( "onClientGUIClick", posession.button[1], posession.hide, false )
	addEventHandler( "onClientGUIClick", posession.button[2], posession.add, false )
	addEventHandler( "onClientGUIClick", posession.button[3], posession.remove, false )
	addEventHandler( "onClientGUIClick", posession.button[4], posession.access, false )
end

addEvent("posessionManage", true)
addEventHandler( "posessionManage", root, posession.show )