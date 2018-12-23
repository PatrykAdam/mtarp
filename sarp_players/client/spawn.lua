--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local spawn = {}

function getSpawnID()
	local type, id = guiComboBoxGetSelected( spawn.combobox ), guiGridListGetSelectedItem( spawn.gridlist ) + 1

	local index = 0
	for i, v in ipairs(spawn.list) do
		if v.type == type then
			index = index + 1
			if index == id then
				return i
			end
		end
	end
end

function spawn.save()
	local type, id = guiComboBoxGetSelected( spawn.combobox ), spawn.list[getSpawnID()].id

	if not type or not id then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego spawnu.")
	end

	triggerServerEvent( "setSpawn", localPlayer, type, id )
	spawn.hide()
end

function spawn.hide()
	destroyElement( spawn.window )
	showCursor( false )
end

function spawn.show(spawnList)
	if isElement(spawn.window) then return end
	spawn.list = spawnList
	showCursor( true )
	spawn.window = guiCreateWindow((screenX - 294) / 2, (screenY - 186) / 2, 294, 186, "Miejsce spawnu", false)
	guiWindowSetSizable(spawn.window, false)

	spawn.label = guiCreateLabel(0.03, 0.12, 0.31, 0.11, "Typ spawnu:", true, spawn.window)
	guiSetFont(spawn.label, "default-bold-small")
	guiLabelSetVerticalAlign(spawn.label, "center")
	spawn.combobox = guiCreateComboBox(0.28, 0.13, 0.69, 0.66, "", true, spawn.window)
	guiComboBoxAddItem( spawn.combobox, "Spawn główny" )
	guiComboBoxAddItem( spawn.combobox, "Hotel" )
	guiComboBoxAddItem( spawn.combobox, "Dom" )
	spawn.gridlist = guiCreateGridList(0.04, 0.32, 0.93, 0.47, true, spawn.window)
	guiGridListAddColumn(spawn.gridlist, "Nazwa", 0.9)
	spawn.button = {}
	spawn.button[1] = guiCreateButton(0.06, 0.84, 0.37, 0.11, "Zmień", true, spawn.window)
	spawn.button[2] = guiCreateButton(0.57, 0.84, 0.37, 0.10, "Zamknij", true, spawn.window)

	addEventHandler( "onClientGUIClick", spawn.combobox, function()
		local id = guiComboBoxGetSelected( spawn.combobox )

		guiGridListClear( spawn.gridlist )
		for i, v in ipairs(spawn.list) do
			if v.type == id then
				local row = guiGridListAddRow( spawn.gridlist )
				guiGridListSetItemText( spawn.gridlist, row, 1, v.name, false, false )
			end
		end
	end)
	addEventHandler( "onClientGUIClick", spawn.button[1], spawn.save, false )
	addEventHandler( "onClientGUIClick", spawn.button[2], spawn.hide, false )
end

addEvent("spawnGUI", true)
addEventHandler( "spawnGUI", root, spawn.show )