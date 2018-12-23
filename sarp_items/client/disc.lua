local disc = {}
disc.active = false

function disc.hide()
	removeEventHandler ( "onClientGUIClick", disc.button[1], disc.hide, false )
	removeEventHandler ( "onClientGUIClick", disc.button[2], disc.hide, false )
	disc.active = false
	showCursor( false )
	destroyElement( disc.window )
end

function disc.show(itemid)
	if disc.active then return end
	disc.active = true
	showCursor( true )
	disc.window = guiCreateWindow((screenX - 361) / 2, (screenY - 135) / 2, 361, 135, "Wypalanie płyty", false)
	guiWindowSetSizable(disc.window, false)

	disc.label = {}
	disc.label[1] = guiCreateLabel(0.03, 0.22, 0.21, 0.21, "Nazwa płyty:", true, disc.window)
	guiLabelSetVerticalAlign(disc.label[1], "center")
	disc.label[2] = guiCreateLabel(0.03, 0.50, 0.44, 0.21, "Adres URL do muzyki:", true, disc.window)
	guiLabelSetVerticalAlign(disc.label[2], "center")
	disc.edit = {}
	disc.edit[1] = guiCreateEdit(0.25, 0.25, 0.67, 0.18, "", true, disc.window)
	disc.edit[2] = guiCreateEdit(0.36, 0.53, 0.59, 0.18, "", true, disc.window)
	disc.button = {}
	disc.button[1] = guiCreateButton(0.53, 0.79, 0.39, 0.15, "Zamknij", true, disc.window)
	disc.button[2] = guiCreateButton(0.06, 0.79, 0.39, 0.15, "Wypal płyte", true, disc.window)
	addEventHandler ( "onClientGUIClick", disc.button[1], disc.hide, false )
	addEventHandler ( "onClientGUIClick", disc.button[2], function()
		local name, url = guiGetText( disc.edit[1] ), guiGetText( disc.edit[2] )

		if string.len(name) > 10 then
			return exports.sarp_notify:addNotify("Nazwa musi mieć od 3 do 10 znaków.")
		end

		if not (string.sub(url, -4):lower() == ".mp3" or string.sub(url, -4):lower() == ".wav" or string.sub(url , -4) == ".ogg" or string.sub(url, -4) == ".pls" or string.sub(url, -4) == ".m3u") then
			return exports.sarp_notify:addNotify("Nieprawidłowy format URL.")
		end
		disc.hide()
		triggerServerEvent( "discBurn", localPlayer, itemid, name, url )
	end, false )
end

addEvent("discURL", true)
addEventHandler( "discURL", localPlayer, disc.show )