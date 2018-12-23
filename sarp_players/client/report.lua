--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local report = {}
report.active = false

function report.send()
	local category = guiComboBoxGetSelected( report.combobox )
	local mtaID = guiGetText( report.edit )
	local text = guiGetText( report.memo )

	if category == -1 or category == 0 or string.len(text) == 1 or string.len(mtaID) == 0 then
		return exports.sarp_notify:addNotify("Uzupełnij wszystkie pola!")
	end

	if not exports.sarp_main:getPlayerFromID(tonumber(mtaID)) then
		return exports.sarp_notify:addNotify("Gracz o podanym ID nie jest zalogowany.")
	end

	triggerServerEvent( "sendReport", localPlayer, category, mtaID, text )
	report.hide()
end

function report.hide()
	removeEventHandler( "onClientGUIClick", report.button[1], report.send, false)
	removeEventHandler( "onClientGUIClick", report.button[2], report.hide, false)
	destroyElement( report.window )
	showCursor( false )
	report.active = false
end

function report.create()
	if report.active then return end
	report.active = true
	showCursor( true )
	report.window = guiCreateWindow((screenX - 316) / 2, (screenY - 295) / 2, 316, 295, "Zgłaszanie gracza", false)
	guiWindowSetSizable(report.window, false)

	report.label = {}
	report.label[1] = guiCreateLabel(0.03, 0.10, 0.18, 0.08, "Kategoria:", true, report.window)
	guiLabelSetVerticalAlign(report.label[1], "center")
	report.combobox = guiCreateComboBox(0.23, 0.10, 0.53, 0.32, "Brak", true, report.window)
	guiComboBoxAddItem(report.combobox, "Brak")
	guiComboBoxAddItem(report.combobox, "Złamanie regulaminu")
	guiComboBoxAddItem(report.combobox, "Pytanie")
	report.label[2] = guiCreateLabel(0.03, 0.18, 0.55, 0.09, "Identyfikator gracza(mtaID):", true, report.window)
	guiLabelSetVerticalAlign(report.label[2], "center")
	report.edit = guiCreateEdit(0.54, 0.20, 0.41, 0.07, "", true, report.window)
	report.memo = guiCreateMemo(0.03, 0.38, 0.92, 0.44, "", true, report.window)
	report.label[3] = guiCreateLabel(0.03, 0.28, 0.69, 0.08, "Wiadomość dołączona do reportu:", true, report.window)
	report.button = {}
	report.button[1] = guiCreateButton(0.04, 0.89, 0.41, 0.07, "Wyślij zgłoszenie", true, report.window)
	report.button[2] = guiCreateButton(0.51, 0.89, 0.41, 0.07, "Zamknij", true, report.window)

	addEventHandler( "onClientGUIClick", report.button[1], report.send, false)
	addEventHandler( "onClientGUIClick", report.button[2], report.hide, false)
end

addCommandHandler( "report", report.create )