--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local admin = {}
admin.category = {"Złamanie regulaminu", "Pytanie"}

function admin.apply()
	local selectID = guiGridListGetSelectedItem( admin.gridlist )
	local id = guiGridListGetItemData( admin.gridlist, selectID, 1 )

	admin.hide()
	triggerServerEvent( "acceptReport", localPlayer, id )
end

function admin.hide()
	if not ticket then
		removeEventHandler( "onClientGUIClick", admin.button[1], admin.apply, false)
		removeEventHandler( "onClientGUIClick", admin.button[2], admin.hide, false)
	else
		removeEventHandler( "onClientGUIClick", admin.button[1], admin.playerTP, false)
    removeEventHandler( "onClientGUIClick", admin.button[2], admin.hide, false)
		removeEventHandler( "onClientGUIClick", admin.button[3], admin.endReport, false)
		removeEventHandler( "onClientGUIClick", admin.button[4], admin.cancelReport, false)
		admin.ticket = false
	end
	destroyElement( admin.window )
	showCursor( false )
	admin.active = false
end

function admin.playerTP()
	if not admin.ticket then return end

	admin.hide()
	triggerServerEvent( "gotoReport", localPlayer, admin.ticket)
end

function admin.endReport()
	if not admin.ticket then return end

	admin.hide()
	triggerServerEvent( "endReport", localPlayer, admin.ticket)
end

function admin.cancelReport()
	if not admin.ticket then return end

	admin.hide()
	triggerServerEvent( "cancelReport", localPlayer, admin.ticket )
end

function admin.create(ticket, data)
	if admin.active then return admin.hide() end
	admin.active = true
	admin.ticket = ticket
	admin.data = data
	showCursor( true )

	if not ticket then
		admin.window = guiCreateWindow((screenX - 361) / 2, (screenY - 386) / 2, 361, 386, "Panel zgłoszeń", false)
	  guiWindowSetSizable(admin.window, false)

	  admin.gridlist = guiCreateGridList(9, 29, 342, 309, false, admin.window)
	  guiGridListAddColumn(admin.gridlist, "Kategoria", 0.4)
	  guiGridListAddColumn(admin.gridlist, "Gracz", 0.3)
	  guiGridListAddColumn(admin.gridlist, "Treść", 0.2)
	  admin.button = {}
	  admin.button[1] = guiCreateButton(21, 350, 133, 26, "Przyjmij zgłoszenie", false, admin.window)
	  admin.button[2] = guiCreateButton(208, 350, 133, 26, "Zamknij", false, admin.window)

	  addEventHandler( "onClientGUIClick", admin.button[1], admin.apply, false)
		addEventHandler( "onClientGUIClick", admin.button[2], admin.hide, false)
		admin.refreshTable()
	else
		admin.window = guiCreateWindow((screenX - 340) / 2, (screenY - 367) / 2, 340, 367, string.format("Zgłaszający: %s", getElementData(admin.data[ticket].sender, "player:username")), false)
    guiWindowSetSizable(admin.window, false)

    admin.label = {}
    admin.label[1] = guiCreateLabel(0.03, 0.08, 0.20, 0.07, "Kategoria:", true, admin.window)
    guiLabelSetVerticalAlign(admin.label[1], "center")
    admin.label[2] = guiCreateLabel(0.03, 0.15, 0.36, 0.07, "Osoba zgłoszona (ID):", true, admin.window)
    guiLabelSetVerticalAlign(admin.label[2], "center")
    admin.label[3] = guiCreateLabel(0.03, 0.22, 0.44, 0.07, "Dołączona wiadomość:", true, admin.window)
    guiLabelSetVerticalAlign(admin.label[3], "center")
    admin.memo = guiCreateMemo(0.03, 0.29, 0.94, 0.50, "", true, admin.window)
    guiSetText( admin.memo, admin.data[ticket].message )
    guiMemoSetReadOnly(admin.memo, true)
    admin.edit = {}
    admin.button = {}
    admin.edit[1] = guiCreateEdit(0.21, 0.10, 0.46, 0.05, "", true, admin.window)
    guiSetText( admin.edit[1], admin.category[admin.data[ticket].category] )
    guiEditSetReadOnly(admin.edit[1], true)
    admin.button[1] = guiCreateButton(0.03, 0.84, 0.29, 0.05, "Idź do gracza", true, admin.window)
    admin.edit[2] = guiCreateEdit(0.41, 0.16, 0.46, 0.05, "", true, admin.window)
    guiEditSetReadOnly(admin.edit[2], true)
    guiSetText( admin.edit[2], string.format("%s (%d)", getElementData(admin.data[ticket].playerid, "player:username"), getElementData(admin.data[ticket].playerid, "player:mtaID") ))
    admin.button[2] = guiCreateButton(0.03, 0.92, 0.94, 0.05, "Zamknij", true, admin.window)
    admin.button[3] = guiCreateButton(0.36, 0.84, 0.35, 0.05, "Zakończ zgłoszenie", true, admin.window)
    admin.button[4] = guiCreateButton(0.74, 0.84, 0.23, 0.05, "Anuluj", true, admin.window)

    addEventHandler( "onClientGUIClick", admin.button[1], admin.playerTP, false)
    addEventHandler( "onClientGUIClick", admin.button[2], admin.hide, false)
		addEventHandler( "onClientGUIClick", admin.button[3], admin.endReport, false)
		addEventHandler( "onClientGUIClick", admin.button[4], admin.cancelReport, false)
	end
end

addEvent('showReports', true)
addEventHandler( 'showReports', localPlayer, admin.create )

function admin.refreshTable()
	guiGridListClear( admin.gridlist )
	for i, v in ipairs(admin.data) do
		local row = guiGridListAddRow( admin.gridlist )
		guiGridListSetItemText ( admin.gridlist, row, 1, admin.category[v.category], false, false )
		guiGridListSetItemText ( admin.gridlist, row, 2, getElementData(v.playerid, "player:username").." ("..getElementData(v.playerid, "player:mtaID")..")", false, false )
		guiGridListSetItemText ( admin.gridlist, row, 3, v.message, false, false )
		guiGridListSetItemData( admin.gridlist, row, 1, v.id )
	end
end