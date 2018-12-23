--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local admins = {}
admins.active = false

function admins.hide()
	destroyElement( admins.window )
	showCursor( false )
	admins.active = false
end

function admins.online()
	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData(v, "admin:duty") then
			return true
		end
	end
	return false
end

function admins.cmd(cmd)
	if admins.active then
		admins.hide()
	else
		if not admins.online() then
			return exports.sarp_notify:addNotify("Brak administratorów na służbie.")
		end

		admins.window = guiCreateWindow((screenX - 363) / 2, (screenY - 338) / 2, 363, 338, "Ekipa online", false)
    guiWindowSetSizable(admins.window, false)
    admins.gridlist = guiCreateGridList(0.02, 0.07, 0.95, 0.82, true, admins.window)
    guiGridListAddColumn(admins.gridlist, "ID", 0.3)
    guiGridListAddColumn(admins.gridlist, "Nick", 0.3)
    guiGridListAddColumn(admins.gridlist, "Ranga", 0.3)
    admins.button = guiCreateButton(0.04, 0.92, 0.90, 0.05, "Zamknij", true, admins.window)    
		showCursor( true )
		admins.active = true
		for i, v in ipairs(getElementsByType( "player" )) do
			if getElementData(v, "admin:duty") then
				local row = guiGridListAddRow ( admins.gridlist )
				guiGridListSetItemText ( admins.gridlist, row, 1, getElementData(v, "player:mtaID"), false, false )
				guiGridListSetItemText ( admins.gridlist, row, 2, getElementData(v, "global:name"), false, false )
				guiGridListSetItemText ( admins.gridlist, row, 3, getElementData(v, "global:rank"), false, false )
				local r, g, b = hexToRGB(getElementData(v, "global:color"))
				if b ~= nil then
					guiGridListSetItemColor ( admins.gridlist, row, 3, r, g, b )
				end
			end
		end
		addEventHandler ( "onClientGUIClick", admins.button, admins.hide, false )
	end
end

addCommandHandler( "admins", admins.cmd )
addCommandHandler( "a", admins.cmd )


--community
function hexToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end