local player = {}
local playerData = {}
player.element = false
player.window = {}
player.label = {}
player.edit = {}

function player.hide()
	for i = 1, 3 do	
		if isElement(player.window[i]) then
			destroyElement( player.window[i] )
		end
	end

	showCursor( false )
end

function player.editor()
	local nazwa, url = tostring(guiGetText( player.edit[3] )), tostring(guiGetText( player.edit[4] ))

	if string.len(nazwa) < 3 or string.len(nazwa) > 18 then
		return exports.sarp_notify:addNotify("Nazwa musi posiadać od 3 do 18 znaków.")
	end

	player.editEx(nazwa, url)
	player.update()
	if isElement(player.window[3]) then
		destroyElement( player.window[3] )
	end
end

function player.volume()
	local volume = guiScrollBarGetScrollPosition( player.scrollbar )/100
	if isElement(player.element) then
		setSoundVolume( player.element, volume)
	end
end

function player.update()
	guiGridListClear( player.gridlist )
	for i, v in ipairs(playerData) do
		local row = guiGridListAddRow( player.gridlist )
		guiGridListSetItemText( player.gridlist, row, 1, v[1], false, false )
		guiGridListSetItemText( player.gridlist, row, 2, v[2], false, false )
	end
end

function player.delete()
	local id = guiGridListGetSelectedItem( player.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nic nie zaznaczyłeś z listy.")
	end

	player.del(id)
	player.update()
end

function player.add()
	local nazwa, url = tostring(guiGetText( player.edit[1] )), tostring(guiGetText( player.edit[2] ))

	if string.len(nazwa) < 3 or string.len(nazwa) > 18 then
		return exports.sarp_notify:addNotify("Nazwa musi posiadać od 3 do 18 znaków.")
	end

	player.create(nazwa, url)
	player.update()

	if isElement(player.window[2]) then
		destroyElement( player.window[2] )
	end
end

function player.start()
	if player.element and isElement(player.element) then
		stopSound( player.element )
	else
		local id = guiGridListGetSelectedItem( player.gridlist ) + 1
		local volume = guiScrollBarGetScrollPosition( player.scrollbar )/100
		if id == 0 then
			return exports.sarp_notify:addNotify("Nic nie zaznaczyłeś z listy.")
		end

		player.element = playSound( playerData[id][2] )
		setSoundVolume( player.element, volume)
	end
end

function player.show()
	if isElement(player.window[1]) then return player.hide() end
	showCursor( true )
	player.window[1] = guiCreateWindow((screenX - 323) / 2, (screenY - 365) / 2, 323, 365, "MP3", false)
	guiWindowSetSizable(player.window[1], false)

	player.gridlist = guiCreateGridList(0.03, 0.08, 0.94, 0.68, true, player.window[1])
	guiGridListAddColumn(player.gridlist, "Nazwa", 0.9)
	player.button = {}
	player.button[1] = guiCreateButton(0.06, 0.84, 0.25, 0.05, "Dodaj", true, player.window[1])
	player.button[2] = guiCreateButton(0.38, 0.84, 0.25, 0.05, "Edytuj", true, player.window[1])
	player.button[3] = guiCreateButton(0.67, 0.84, 0.25, 0.05, "Usuń", true, player.window[1])
	player.button[4] = guiCreateButton(0.53, 0.92, 0.39, 0.04, "Zamknij", true, player.window[1])
	player.scrollbar = guiCreateScrollBar(0.04, 0.77, 0.93, 0.05, true, true, player.window[1])
	guiScrollBarSetScrollPosition(player.scrollbar, 100.0)
	player.button[6] = guiCreateButton(0.06, 0.92, 0.39, 0.04, "Start/Stop", true, player.window[1])

	addEventHandler( "onClientGUIClick", player.button[1], function()
		if isElement(player.window[2]) then return destroyElement(player.window[2]) end
		player.window[2] = guiCreateWindow( (screenX - 243)/2, (screenY - 152)/2, 243, 152, "Dodawanie muzyki", false)
    guiWindowSetSizable(player.window[2], false)

    player.label[1] = guiCreateLabel(0.04, 0.15, 0.94, 0.12, "Nazwa:", true, player.window[2])
    guiSetFont(player.label[1], "default-bold-small")
    guiLabelSetHorizontalAlign(player.label[1], "center", false)
    player.edit[1] = guiCreateEdit(0.06, 0.29, 0.88, 0.14, "", true, player.window[2])
    player.label[2] = guiCreateLabel(0.04, 0.46, 0.94, 0.12, "Adres URL:", true, player.window[2])
    guiSetFont(player.label[2], "default-bold-small")
    guiLabelSetHorizontalAlign(player.label[2], "center", false)
    player.edit[2] = guiCreateEdit(0.06, 0.58, 0.88, 0.14, "", true, player.window[2])
    player.button[7] = guiCreateButton(0.08, 0.78, 0.32, 0.12, "Dodaj", true, player.window[2])
    player.button[8] = guiCreateButton(0.58, 0.78, 0.32, 0.12, "Zamknij", true, player.window[2])

    addEventHandler( "onClientGUIClick", player.button[7], player.add, false)
    addEventHandler( "onClientGUIClick", player.button[8], function()
    	removeEventHandler( "onClientGUIClick", player.button[7], player.add, false )
    	destroyElement( player.window[2] )
   	end, false)
	end, false)
	addEventHandler( "onClientGUIClick", player.button[2], function()
	if isElement(player.window[3]) then return destroyElement(player.window[3]) end
		local id = guiGridListGetSelectedItem( player.gridlist ) + 1

		if id  == 0 then
			return exports.sarp_notify:addNotify("Nic nie zaznaczyłeś z listy.")
		end

		player.index = id

		player.window[3] = guiCreateWindow(589, 378, 243, 152, "Edycja muzyki", false)
    guiWindowSetSizable(player.window[3], false)

    player.label[3] = guiCreateLabel(0.04, 0.15, 0.94, 0.12, "Nazwa:", true, player.window[3])
    guiSetFont(player.label[3], "default-bold-small")
    guiLabelSetHorizontalAlign(player.label[3], "center", false)
    player.edit[3] = guiCreateEdit(0.06, 0.29, 0.88, 0.14, playerData[id][1], true, player.window[3])
    player.label[4] = guiCreateLabel(0.04, 0.46, 0.94, 0.12, "Adres URL:", true, player.window[3])
    guiSetFont(player.label[4], "default-bold-small")
    guiLabelSetHorizontalAlign(player.label[4], "center", false)
    player.edit[4] = guiCreateEdit(0.06, 0.58, 0.88, 0.14, playerData[id][2], true, player.window[3])
    player.button[9] = guiCreateButton(0.08, 0.78, 0.32, 0.12, "Edytuj", true, player.window[3])
    player.button[10] = guiCreateButton(0.58, 0.78, 0.32, 0.12, "Zamknij", true, player.window[3])

    addEventHandler( "onClientGUIClick", player.button[9], player.editor, false)
    addEventHandler( "onClientGUIClick", player.button[10], function()
    	removeEventHandler( "onClientGUIClick", player.button[9], player.editor, false )
    	destroyElement( player.window[3] )
   	end, false)
   end, false)
	addEventHandler( "onClientGUIClick", player.button[3], player.delete )
	addEventHandler( "onClientGUIClick", player.button[4], player.hide )
	addEventHandler( "onClientGUIClick", player.button[6], player.start )
	addEventHandler( "onClientGUIScroll", player.scrollbar, player.volume )
	player.update()
end

addEvent('showPlayer', true)
addEventHandler( 'showPlayer', root, player.show )

function player.create(name, URL)
	local file = xmlLoadFile("mp3.xml")

	if not file then
		file = xmlCreateFile( "mp3.xml", "playerList" )
	end

	local child = xmlCreateChild( file, "mp3" )
	xmlNodeSetAttribute( child, "nazwa", name )
	xmlNodeSetAttribute( child, "url", URL )
	xmlSaveFile( file )
	xmlUnloadFile( file )
	table.insert(playerData, {name, URL})
end

function player.del(id)
	local file = xmlLoadFile("mp3.xml")
	if not file then return end
	local child = xmlNodeGetChildren(file)

	for i, v in pairs(child) do
		if i == id then
			xmlDestroyNode( v )
			xmlSaveFile( file )
			table.remove(playerData, i)
			break
		end
	end
	xmlUnloadFile(file)
end

function player.editEx(name, URL)
	local file = xmlLoadFile( "mp3.xml" )

	if not file then
		file = xmlCreateFile( "mp3.xml", "playerList" )
	end

	local child = xmlNodeGetChildren( file, player.index - 1 )
	xmlNodeSetAttribute( child, "nazwa", name )
	xmlNodeSetAttribute( child, "url", URL )
	xmlSaveFile( file )
	xmlUnloadFile(file)
	playerData[player.index] = {name, URL}
end

function player.loadXML()
	local file = xmlLoadFile( "mp3.xml" )
	if not file then return end
	local child = xmlNodeGetChildren(file)
	
	for i, v in pairs(child) do
		local nazwa, url = xmlNodeGetAttribute(v,"nazwa"), xmlNodeGetAttribute(v,"url")
		table.insert(playerData, {nazwa, url})
	end
	xmlUnloadFile(file)
end

addEventHandler( "onClientResourceStart", resourceRoot, player.loadXML )

function player.unLoadXML()
	for i, v in ipairs(playerData) do
		table.remove(playerData, i)
	end
end

addEventHandler( "onClientResourceStop", resourceRoot, player.unLoadXML )