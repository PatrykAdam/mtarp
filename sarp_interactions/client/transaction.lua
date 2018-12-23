--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local transaction = {}
transaction.active = false

function transaction.hide()
	removeEventHandler ( "onClientGUIClick", transaction.button[1], transaction.submit, false )
  removeEventHandler ( "onClientGUIClick", transaction.button[2], transaction.hide, false )
	destroyElement( transaction.window)
	transaction.active = false
	showCursor( false )
end

function transaction.submit()
	local price = tonumber(guiGetText( transaction.edit ))

	if not price then
		return exports.sarp_notify:addNotify("Nie wpisano żadnej wartości.")
	end

	triggerServerEvent( "transactionSubmit", localPlayer, transaction.type, transaction.playerid, price)
	transaction.hide()
end

function transaction.show(type, playerid)
	if transaction.active then transaction.hide() end
	transaction.active = true
	transaction.type = type
	transaction.playerid = playerid
	showCursor( true )

	local title = nil
	if transaction.type == 1 then
		title = "Wpłata gotówki"
	elseif transaction.type == 2 then
		title = "Wypłata gotówki"
	elseif transaction.type == 3 then
		title = string.format("Przekazanie pieniędzy %s", getElementData(transaction.playerid, "player:username"))
	end

	transaction.window = guiCreateWindow((screenX - 266) / 2, (screenY - 89) / 2, 266, 89, title, false)
	guiWindowSetSizable(transaction.window, false)

	transaction.edit = guiCreateEdit(0.04, 0.25, 0.80, 0.27, "", true, transaction.window)
	transaction.button = {}
	transaction.button[1] = guiCreateButton(0.04, 0.64, 0.41, 0.22, "Zatwierdź", true, transaction.window)
	transaction.button[2] = guiCreateButton(0.52, 0.64, 0.41, 0.22, "Zamknij", true, transaction.window)
	transaction.label = guiCreateLabel(0.84, 0.27, 0.09, 0.25, "$", true, transaction.window)
	guiLabelSetHorizontalAlign(transaction.label, "center", false)

	addEventHandler ( "onClientGUIClick", transaction.button[1], transaction.submit, false )
  addEventHandler ( "onClientGUIClick", transaction.button[2], transaction.hide, false )
end

addEvent("transactionShow", true)
addEventHandler( "transactionShow", root, transaction.show )