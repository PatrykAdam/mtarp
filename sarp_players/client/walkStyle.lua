--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local walkStyle = {}
walkStyle.list = {
	{"Normalny", 54},
	{"Cywil", 118},
	{"Pijany", 126},
	{"Staruszek", 120},
	{"Gangster 1", 121},
	{"Gangster 2", 122},
	{"Dziwka", 132},
	{"Kobieta", 129}
}

function walkStyle.hide()
	removeEventHandler( "onClientGUIClick", walkStyle.button[1], walkStyle.set, false )
	removeEventHandler( "onClientGUIClick", walkStyle.button[2], walkStyle.hide, false )
	destroyElement( walkStyle.window )
	walkStyle.active = false
	showCursor( false )
end

function walkStyle.set()
	local id = guiGridListGetSelectedItem ( walkStyle.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego stylu chodzenia.")
	end

	triggerServerEvent( "changeWalkingStyle", localPlayer, walkStyle.list[id][2] )
	walkStyle.hide()
end

function walkStyle.show()
	if walkStyle.active then
		return walkStyle.hide()
	end

	showCursor( true )
	walkStyle.window = guiCreateWindow((screenX - 318) / 2, (screenY - 375) / 2, 318, 375, "Styl chodzenia", false)
	guiWindowSetSizable(walkStyle.window, false)

	walkStyle.gridlist = guiCreateGridList(0.03, 0.06, 0.94, 0.83, true, walkStyle.window)
	guiGridListAddColumn(walkStyle.gridlist, "Nazwa", 0.9)

	for i, v in ipairs(walkStyle.list) do
		local row = guiGridListAddRow( walkStyle.gridlist )
		guiGridListSetItemText ( walkStyle.gridlist, row, 1, v[1], false, false )
	end
	walkStyle.button = {}
	walkStyle.button[1] = guiCreateButton(0.06, 0.92, 0.42, 0.06, "Wybierz", true, walkStyle.window)
	walkStyle.button[2] = guiCreateButton(0.52, 0.92, 0.42, 0.06, "Zamknij", true, walkStyle.window)

	addEventHandler( "onClientGUIClick", walkStyle.button[1], walkStyle.set, false )
	addEventHandler( "onClientGUIClick", walkStyle.button[2], walkStyle.hide, false )
end

addCommandHandler( "styl", walkStyle.show )