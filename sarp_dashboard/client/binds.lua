--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local bind = {}
bind.list = {}

function bind.load()
	local file = xmlLoadFile( "bind.xml" )
	if not file then return end
	local child = xmlNodeGetChildren(file)

	for i, v in pairs(child) do
		local key, text = xmlNodeGetAttribute(v,"key"), xmlNodeGetAttribute(v,"text")
		table.insert(bind.list, {key, text})
		bind.bindKey(true, key, text)
	end
	xmlUnloadFile(file)
end

addEventHandler( "onClientResourceStart", resourceRoot, bind.load )

function bind.stop()
	for i, v in ipairs(bind.list) do
		bind.bindKey(false, v[1], v[2])
	end
end

addEventHandler( "onClientResourceStop", resourceRoot, bind.stop )

function bind.remove()
	local id = guiGridListGetSelectedItem ( bind.gridlist ) + 1
	local file = xmlLoadFile("bind.xml")
	if not file then return end
	local child = xmlNodeGetChildren(file)

	for i, v in pairs(child) do
		if i == id then
			xmlDestroyNode( v )
			xmlSaveFile( file )
			bind.bindKey(false, bind.list[i][1], bind.list[i][2])
			table.remove(bind.list, i)
			break
		end
	end
	xmlUnloadFile(file)
	bind.refreshTable()
end

function bind.create()
	local key, text = bind.key, guiGetText( bind.memoCreate )
	local file = xmlLoadFile("bind.xml")

	if not key or string.len(text) < 2 then
		return exports.sarp_notify:addNotify("Musisz uzupełnić wszystkie pola!")
	end

	if not file then
		file = xmlCreateFile( "bind.xml", "bindList" )
	end
	local child = xmlCreateChild( file, "bind" )
	xmlNodeSetAttribute( child, "key", key )
	xmlNodeSetAttribute( child, "text", text )
	xmlSaveFile( file )
	table.insert(bind.list, {key, text})
	bind.bindKey(true, key, text)
	xmlUnloadFile( file )
	bind.createHide()
	showBindWindow()
end

function bind.bindKey(unbind, key, text)
	text = string.sub(text, 1, #text - 1)
	local isCMD = string.find(text, "/", 1, 1)

	if isCMD then
		local cmd, more
		cmd = string.sub(text, 2)
		more = string.find(text, " ", 1)
		if more then
			cmd = string.sub(text, 2, more - 1)
			more = split(string.sub(text, more), " ")
		end
		if unbind then
			if type(more) == 'table' then
				bindKey(key, "down", cmd, unpack(more))
			else
				bindKey(key, "down", cmd)
			end
		else
			if type(more) == 'table' then
				unbindKey(key, "down", cmd, unpack(more))
			else
				unbindKey(key, "down", cmd)
			end
		end
	else
		if unbind then
			bindKey(key, "down", "say", text)
		else
			unbindKey( key, "down", "say", text)
		end
	end
end

function bind.createHide()
	if not bind.activeCreate then return end
	bind.activeCreate = false
	destroyElement( bind.windowCreate )
end

function bind.newKey()
	if bind.changeKey then
		bind.changeKey = false
		guiSetText( bind.buttonCreate[1], bind.key )
		removeEventHandler( "onClientKey", root, bind.clickKey )
	else
		bind.changeKey = true
		guiSetText( bind.buttonCreate[1], "Naciśnij teraz klawisz..." )
		addEventHandler( "onClientKey", root, bind.clickKey )
	end
end

function bind.createWindow()
	if bind.activeCreate then return end
	bind.activeCreate = true
	hideBind()

	bind.windowCreate = guiCreateWindow((screenX - 236) / 2, (screenY - 191) / 2, 236, 191, "Tworzenie binda", false)
  guiWindowSetSizable(bind.windowCreate, false)

  bind.labelCreate = {}
  bind.labelCreate[1] = guiCreateLabel(0.06, 0.14, 0.90, 0.10, "Tekst binda:", true, bind.windowCreate)
  bind.memoCreate = guiCreateMemo(0.06, 0.24, 0.86, 0.25, "", true, bind.windowCreate)
  bind.labelCreate[2] = guiCreateLabel(0.06, 0.54, 0.90, 0.10, "Przypisany klawisz:", true, bind.windowCreate)
  bind.buttonCreate = {}
  bind.buttonCreate[1] = guiCreateButton(0.06, 0.67, 0.86, 0.13, "Brak", true, bind.windowCreate)
  guiSetProperty(bind.buttonCreate[1], "NormalTextColour", "FFFFFFFF")
  bind.buttonCreate[2] = guiCreateButton(0.05, 0.83, 0.40, 0.12, "Stwórz", true, bind.windowCreate)
  bind.buttonCreate[3] = guiCreateButton(0.52, 0.83, 0.40, 0.12, "Anuluj", true, bind.windowCreate)

  addEventHandler( "onClientGUIClick", bind.buttonCreate[1], bind.newKey, false )
  addEventHandler( "onClientGUIClick", bind.buttonCreate[2], bind.create, false )
  addEventHandler( "onClientGUIClick", bind.buttonCreate[3], bind.createHide, false )
end

function bind.clickKey(key, state)
	if state == true and key ~= "mouse1" and key ~= "mouse2" and key ~= "mouse3" and key ~= "mouse_wheel_up" and key ~= "mouse_wheel_down" then
		bind.key = key
		bind.newKey()
	end
end

function hideBind()
	removeEventHandler( "onClientGUIClick", bind.button[2], hideBind )
	destroyElement( bind.window )
	bind.active = false
end

function showBindWindow()
	if bind.active then return end
	bind.active = true

	bind.window = guiCreateWindow((screenX - 285) / 2, (screenY - 329) / 2, 285, 329, "Bindy", false)
	guiWindowSetSizable(bind.window, false)

	bind.gridlist = guiCreateGridList(0.03, 0.07, 0.93, 0.78, true, bind.window)
	guiGridListAddColumn(bind.gridlist, "Tekst", 0.5)
	guiGridListAddColumn(bind.gridlist, "Klawisz", 0.3)
	bind.button = {}
	bind.button[1] = guiCreateButton(0.06, 0.89, 0.25, 0.09, "Stwórz", true, bind.window)
	bind.button[2] = guiCreateButton(0.34, 0.89, 0.31, 0.08, "Zamknij", true, bind.window)
	bind.button[3] = guiCreateButton(0.68, 0.89, 0.25, 0.08, "Usuń", true, bind.window)

	bind.refreshTable()

	addEventHandler( "onClientGUIClick", bind.button[1], bind.createWindow, false )
	addEventHandler( "onClientGUIClick", bind.button[2], hideBind, false )
	addEventHandler( "onClientGUIClick", bind.button[3], bind.remove, false )
end

function bind.refreshTable()
	guiGridListClear( bind.gridlist )
	for i, v in ipairs(bind.list) do
		local row = guiGridListAddRow( bind.gridlist )
		guiGridListSetItemText ( bind.gridlist, row, 1, v[2], false, false )
		guiGridListSetItemText ( bind.gridlist, row, 2, v[1], false, false )
	end
end