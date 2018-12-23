--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)

--GUI panelu admina
local admin = {}
admin.active = false
admin.list = {}
admin.pg = {}

function getGroupID(id)
	local num = 0
	for i, v in pairs(admin.list) do
		num = num + 1
		if num == id then
			return i
		end
	end
	return false
end

function admin.create()
	local name, typ, tag, color, bank = guiGetText( admin.edit ), guiComboBoxGetSelected( admin.combobox ) + 1, guiGetText( admin.edit2 ), admin.createcol,  tonumber(guiGetText( admin.edit3 ))
	
	if name == '' or not typ or tag == '' or color == nil or bank == nil or bank < 0 then
		return exports.sarp_notify:addNotify("Musisz uzupełnić wszystkie pola!")
	end

	triggerServerEvent( "admin:group_create", localPlayer, name, typ, tag, admin.createcol, bank)
end

function admin.editFunc()
	local id = getGroupID(guiGridListGetSelectedItem ( admin.gridlist ) + 1)
	if not admin.list[id] then return end

	local data = {}
	data.name = guiGetText( admin.edit4 )
	data.tag = guiGetText( admin.edit5 )
	data.type = guiComboBoxGetSelected( admin.combobox2 ) + 1
	data.bank = guiGetText( admin.edit6 )
	data.leader = guiGetText( admin.edit7 )
	data.color = (admin.editcol) and admin.editcol or admin.list[id].color

	triggerServerEvent( "admin:group_edit", localPlayer, id, data )
end

function admin.delete()
	local id = getGroupID(guiGridListGetSelectedItem ( admin.gridlist ) + 1)
	if not admin.list[id] then return end
	showCursor( false )
	triggerServerEvent( "admin:group_delete", localPlayer, id )
end

function admin.info()
	local id = getGroupID(guiGridListGetSelectedItem ( admin.gridlist ) + 1)
	if not admin.list[id] then return end

	guiSetText( admin.edit4, admin.list[id].name )
	guiSetText( admin.edit5, admin.list[id].tag )
	guiComboBoxSetSelected( admin.combobox2, admin.list[id].type - 1 )
	guiSetText( admin.edit6, admin.list[id].bank )
	guiSetText( admin.edit7, admin.list[id].leader )
	guiSetProperty( admin.button3, "NormalTextColour", string.format("FF%.2X%.2X%.2X", admin.list[id].color[1], admin.list[id].color[2], admin.list[id].color[3]))
end

function admin.loadPlayersGroup()
	admin.pg = {}
	for i, v in ipairs(getElementsByType( "player" )) do
		local groupList = {}
		for j = 1, 3 do
			local groupid = getElementData(v, "group_"..j..":id")
			if groupid then
				local perm = getElementData(v, "group_"..j..":perm")
				table.insert(groupList, {id = groupid, perm = perm, name = getElementData(v, "group_"..j..":name")})
			end
		end
		table.insert(admin.pg, {group = groupList, player = {name = getElementData(v, "player:username"), UID = getElementData(v, "player:mtaID")}})
	end
end

function admin.playerGroups()
	local id = guiGridListGetSelectedItem ( admin.gridlist4 ) + 1
	if not admin.pg[id] then return end
	
	guiGridListClear( admin.gridlist3 )
	for i, v in pairs(admin.pg[id].group) do
		local group = admin.pg[id].group[i]
		local row = guiGridListAddRow( admin.gridlist3 )
		guiGridListSetItemText ( admin.gridlist3, row, 1, group.id, false, false )
		guiGridListSetItemText ( admin.gridlist3, row, 2, group.name, false, false )
	end
end

function admin.playerKick()
	local id, group = guiGridListGetSelectedItem ( admin.gridlist4 ) + 1, guiGridListGetSelectedItem ( admin.gridlist3 ) + 1
	if not admin.pg[id] then return end
	triggerServerEvent( "admin:group_playerKick", localPlayer, admin.pg[id]['player'].UID, admin.pg[id]['group'][group].id )
end

function admin.playerPerm()
	local id, group = guiGridListGetSelectedItem ( admin.gridlist4 ) + 1, guiGridListGetSelectedItem ( admin.gridlist3 ) + 1
	if not admin.pg[id] or not admin.pg[id]['group'][group] then return end

	outputDebugString( admin.pg[id]['group'][group].perm )
	guiCheckBoxSetSelected( admin.checkbox1, exports.sarp_main:bitAND(admin.pg[id]['group'][group].perm, 8) ~= 0 and true or false )
	guiCheckBoxSetSelected( admin.checkbox2, exports.sarp_main:bitAND(admin.pg[id]['group'][group].perm, 16) ~= 0 and true or false )
	guiCheckBoxSetSelected( admin.checkbox3, exports.sarp_main:bitAND(admin.pg[id]['group'][group].perm, 1024) ~= 0 and true or false )
	guiCheckBoxSetSelected( admin.checkbox4, exports.sarp_main:bitAND(admin.pg[id]['group'][group].perm, 1) ~= 0 and true or false )
	guiCheckBoxSetSelected( admin.checkbox5, exports.sarp_main:bitAND(admin.pg[id]['group'][group].perm, 128) ~= 0 and true or false )
end

function admin.playerSave()
	local id, group = guiGridListGetSelectedItem ( admin.gridlist4 ) + 1, guiGridListGetSelectedItem ( admin.gridlist3 ) + 1
	if not admin.pg[id] or not admin.pg[id]['group'][group] then return end

	local data = {}
	data.perm = 0
	outputDebugString( guiCheckBoxGetSelected(admin.checkbox1) )
	data.perm = data.perm + (guiCheckBoxGetSelected(admin.checkbox1) and 8 or 0)
	data.perm =	data.perm + (guiCheckBoxGetSelected(admin.checkbox2) and 16 or 0)
	data.perm = data.perm + (guiCheckBoxGetSelected(admin.checkbox3) and 1024 or 0)
	data.perm = data.perm + (guiCheckBoxGetSelected(admin.checkbox4) and 1 or 0)
	data.perm = data.perm + (guiCheckBoxGetSelected(admin.checkbox5) and 128 or 0)
	outputDebugString( data.perm )

	triggerServerEvent( "admin:group_playerSave", localPlayer, admin.pg[id]['player'].UID, admin.pg[id]['group'][group].id, data )
end

function admin.playerAdd()
	local id, groupid = guiGridListGetSelectedItem ( admin.gridlist4 ) + 1, guiComboBoxGetSelected( admin.combobox3 ) + 1
	if not admin.pg[id] or groupid == -1 then return end

	triggerServerEvent( "admin:group_playerAdd", localPlayer, admin.pg[id]['player'].UID, admin.list[groupid].id )
end

function admin.reload()
	if not admin.active then return end
		guiGridListClear( admin.gridlist )
		guiComboBoxClear( admin.combobox3 )
		for i, v in pairs(admin.list) do
			if v.name then
				local row = guiGridListAddRow( admin.gridlist )
				guiGridListSetItemText ( admin.gridlist, row, 1, v.id, false, false )
				guiGridListSetItemText ( admin.gridlist, row, 2, v.name, false, false )
				guiComboBoxAddItem(admin.combobox3, v.name)
			end
		end

		guiGridListClear( admin.gridlist3 )
		guiGridListClear( admin.gridlist4 )
		for i, v in ipairs(admin.pg) do
			if v['player'].UID then
				local row = guiGridListAddRow( admin.gridlist4 )
				guiGridListSetItemText ( admin.gridlist4, row, 1, v['player'].UID, false, false )
				guiGridListSetItemText ( admin.gridlist4, row, 2, v['player'].name, false, false )
			end
		end
end

function admin.hide()
	destroyElement( admin.window )
	admin.active = false
	showCursor( false )
end

function admin.show(list, pGroup)
	if not admin.active then
		admin.active = true
		admin.list = list
		admin.loadPlayersGroup()
		showCursor( true )

		admin.window = guiCreateWindow((screenX - 398) / 2, (screenY - 446) / 2, 398, 446, "Zarządzanie grupami", false)
	    guiWindowSetSizable(admin.window, false)

	    admin.tabpanel = guiCreateTabPanel(0.03, 0.05, 0.95, 0.85, true, admin.window)

	    admin.tab = guiCreateTab("Stwórz grupe", admin.tabpanel)

	    admin.label = guiCreateLabel(0.04, 0.06, 0.34, 0.08, "Nazwa:", true, admin.tab)
	    guiLabelSetHorizontalAlign(admin.label, "center", false)
	    guiLabelSetVerticalAlign(admin.label, "center")
	    admin.edit = guiCreateEdit(0.38, 0.07, 0.51, 0.08, "", true, admin.tab)
	    admin.label2 = guiCreateLabel(0.04, 0.29, 0.34, 0.08, "Typ:", true, admin.tab)
	    guiLabelSetHorizontalAlign(admin.label2, "center", false)
	    guiLabelSetVerticalAlign(admin.label2, "center")
	    admin.combobox = guiCreateComboBox(0.38, 0.30, 0.52, 0.51, "", true, admin.tab)
	    guiComboBoxAddItem(admin.combobox, "Government")
	    guiComboBoxAddItem(admin.combobox, "Police")
	    guiComboBoxAddItem(admin.combobox, "Medical")
	    guiComboBoxAddItem(admin.combobox, "Gang")
	    guiComboBoxAddItem(admin.combobox, "Ściganci")
	    guiComboBoxAddItem(admin.combobox, "Mafia")
	    guiComboBoxAddItem(admin.combobox, "Gastronomia")
	    guiComboBoxAddItem(admin.combobox, "Taxi")
	    guiComboBoxAddItem(admin.combobox, "Workshop")
	    guiComboBoxAddItem(admin.combobox, "Ochrona")
	    guiComboBoxAddItem(admin.combobox, "Siłownia")
	    guiComboBoxAddItem(admin.combobox, "News")
	    guiComboBoxAddItem(admin.combobox, "FBI")
	    guiComboBoxAddItem(admin.combobox, "Club")
	    guiComboBoxAddItem(admin.combobox, "Logistic")
	    guiComboBoxAddItem(admin.combobox, "Casino")
	    guiComboBoxAddItem(admin.combobox, "Lambard")
	    guiComboBoxAddItem(admin.combobox, "Family")
	    guiComboBoxAddItem(admin.combobox, "24/7")
	    guiComboBoxAddItem(admin.combobox, "Hotel")
	    guiComboBoxAddItem(admin.combobox, "Odzieżowy")
	    guiComboBoxAddItem(admin.combobox, "Bank")
	    admin.label3 = guiCreateLabel(0.04, 0.17, 0.34, 0.08, "Tag:", true, admin.tab)
	    guiLabelSetHorizontalAlign(admin.label3, "center", false)
	    guiLabelSetVerticalAlign(admin.label3, "center")
	    admin.edit2 = guiCreateEdit(0.38, 0.18, 0.51, 0.08, "", true, admin.tab)
	    admin.label4 = guiCreateLabel(0.04, 0.40, 0.34, 0.08, "Kolor:", true, admin.tab)
	    guiLabelSetHorizontalAlign(admin.label4, "center", false)
	    guiLabelSetVerticalAlign(admin.label4, "center")
	    admin.button = guiCreateButton(0.38, 0.40, 0.52, 0.08, "Naciśnij aby zmienić.", true, admin.tab)
	    guiSetProperty(admin.button, "NormalTextColour", "FFFEF9FB")
	    admin.label5 = guiCreateLabel(0.04, 0.51, 0.34, 0.08, "Pieniądze w banku:", true, admin.tab)
	    guiLabelSetHorizontalAlign(admin.label5, "center", false)
	    guiLabelSetVerticalAlign(admin.label5, "center")
	    admin.edit3 = guiCreateEdit(0.38, 0.52, 0.51, 0.08, "", true, admin.tab)
	    admin.button2 = guiCreateButton(0.31, 0.66, 0.42, 0.10, "Stwórz grupe", true, admin.tab)
	    admin.label6 = guiCreateLabel(42, -103, 128, 30, "Nazwa:", false, admin.tab)
	    guiLabelSetHorizontalAlign(admin.label6, "center", false)
	    guiLabelSetVerticalAlign(admin.label6, "center")

	    admin.tab2 = guiCreateTab("Edytuj grupe", admin.tabpanel)

	    admin.gridlist = guiCreateGridList(0.03, 0.03, 0.94, 0.26, true, admin.tab2)
	    guiGridListAddColumn(admin.gridlist, "ID", 0.1)
	    guiGridListAddColumn(admin.gridlist, "Nazwa", 0.7)
	    guiGridListSetSortingEnabled( admin.gridlist, false )

	    admin.label7 = guiCreateLabel(0.04, 0.32, 0.36, 0.09, "Nazwa:", true, admin.tab2)
	    guiLabelSetHorizontalAlign(admin.label7, "center", false)
	    guiLabelSetVerticalAlign(admin.label7, "center")
	    admin.label8 = guiCreateLabel(0.04, 0.41, 0.36, 0.09, "Tag:", true, admin.tab2)
	    guiLabelSetHorizontalAlign(admin.label8, "center", false)
	    guiLabelSetVerticalAlign(admin.label8, "center")
	    admin.label9 = guiCreateLabel(0.04, 0.50, 0.36, 0.09, "Typ:", true, admin.tab2)
	    guiLabelSetHorizontalAlign(admin.label9, "center", false)
	    guiLabelSetVerticalAlign(admin.label9, "center")
	    admin.label10 = guiCreateLabel(0.04, 0.59, 0.36, 0.09, "Kolor:", true, admin.tab2)
	    guiLabelSetHorizontalAlign(admin.label10, "center", false)
	    guiLabelSetVerticalAlign(admin.label10, "center")
	    admin.edit4 = guiCreateEdit(0.43, 0.33, 0.49, 0.06, "", true, admin.tab2)
	    admin.edit5 = guiCreateEdit(0.43, 0.42, 0.49, 0.06, "", true, admin.tab2)

	    admin.combobox2 = guiCreateComboBox(0.43, 0.51, 0.49, 0.26, "", true, admin.tab2)
	    guiComboBoxAddItem(admin.combobox2, "Government")
	    guiComboBoxAddItem(admin.combobox2, "Police")
	    guiComboBoxAddItem(admin.combobox2, "Medical")
	    guiComboBoxAddItem(admin.combobox2, "Gang")
	    guiComboBoxAddItem(admin.combobox2, "Ściganci")
	    guiComboBoxAddItem(admin.combobox2, "Mafia")
	    guiComboBoxAddItem(admin.combobox2, "Gastronomia")
	    guiComboBoxAddItem(admin.combobox2, "Taxi")
	    guiComboBoxAddItem(admin.combobox2, "Workshop")
	    guiComboBoxAddItem(admin.combobox2, "Ochrona")
	    guiComboBoxAddItem(admin.combobox2, "Siłownia")
	    guiComboBoxAddItem(admin.combobox2, "News")
	    guiComboBoxAddItem(admin.combobox2, "FBI")
	    guiComboBoxAddItem(admin.combobox2, "Club")
	    guiComboBoxAddItem(admin.combobox2, "Logistic")
	    guiComboBoxAddItem(admin.combobox2, "Casino")
	    guiComboBoxAddItem(admin.combobox2, "Lambard")
	    guiComboBoxAddItem(admin.combobox2, "Family")
	    guiComboBoxAddItem(admin.combobox2, "24/7")
	    guiComboBoxAddItem(admin.combobox2, "Hotel")
	    guiComboBoxAddItem(admin.combobox2, "Odzieżowy")
	    guiComboBoxAddItem(admin.combobox2, "Bank")

	    admin.button3 = guiCreateButton(0.43, 0.60, 0.49, 0.06, "Naciśnij aby zmienić.", true, admin.tab2)
	    admin.button4 = guiCreateButton(0.04, 0.91, 0.42, 0.06, "Zapisz zmiany", true, admin.tab2)
	    admin.button5 = guiCreateButton(0.56, 0.91, 0.42, 0.06, "Usuń grupe", true, admin.tab2)
	    admin.label11 = guiCreateLabel(0.04, 0.68, 0.36, 0.09, "Pieniądze w banku:", true, admin.tab2)
	    guiLabelSetHorizontalAlign(admin.label11, "center", false)
	    guiLabelSetVerticalAlign(admin.label11, "center")
	    admin.edit6 = guiCreateEdit(0.43, 0.71, 0.49, 0.06, "", true, admin.tab2)
	    admin.label12 = guiCreateLabel(0.04, 0.77, 0.36, 0.09, "Zmiana lidera: (mtaID)", true, admin.tab2)
	    guiLabelSetHorizontalAlign(admin.label12, "center", false)
	    guiLabelSetVerticalAlign(admin.label12, "center")
	    admin.edit7 = guiCreateEdit(0.43, 0.79, 0.49, 0.06, "", true, admin.tab2)

	    
	    admin.tab3 = guiCreateTab("Członkowie grupy", admin.tabpanel)

        admin.gridlist3 = guiCreateGridList(0.03, 0.31, 0.92, 0.22, true, admin.tab3)
        guiGridListAddColumn(admin.gridlist3, "ID", 0.1)
	    	guiGridListAddColumn(admin.gridlist3, "Nazwa", 0.7)
	    	guiGridListSetSortingEnabled( admin.gridlist3, false )

        admin.checkbox1 = guiCreateCheckBox(0.06, 0.66, 0.42, 0.05, "Zarządzanie pojazdami", false, true, admin.tab3)
        admin.checkbox2 = guiCreateCheckBox(0.06, 0.75, 0.42, 0.05, "Zarządzanie drzwiami", false, true, admin.tab3)
        admin.checkbox3 = guiCreateCheckBox(0.51, 0.66, 0.42, 0.05, "Zarządzanie obiektami", false, true, admin.tab3)
        admin.checkbox4 = guiCreateCheckBox(0.51, 0.75, 0.42, 0.05, "Zarządzanie pracownikami", false, true, admin.tab3)
        admin.checkbox5 = guiCreateCheckBox(0.06, 0.83, 0.42, 0.05, "Dostęp do pojazdów", false, true, admin.tab3)
        admin.gridlist4 = guiCreateGridList(0.03, 0.04, 0.92, 0.24, true, admin.tab3)
        guiGridListAddColumn(admin.gridlist4, "ID", 0.1)
	    	guiGridListAddColumn(admin.gridlist4, "Nazwa", 0.7)
	    	guiGridListSetSortingEnabled( admin.gridlist4, false )

        admin.button6 = guiCreateButton(0.03, 0.91, 0.41, 0.06, "Zapisz zmiany", true, admin.tab3)
        admin.button7 = guiCreateButton(0.56, 0.91, 0.41, 0.06, "Wyrzuć gracza", true, admin.tab3)
        admin.button8 = guiCreateButton(0.51, 0.55, 0.41, 0.06, "Dodaj do grupy", true, admin.tab3)
        admin.combobox3 = guiCreateComboBox(0.06, 0.56, 0.42, 0.26, "", true, admin.tab3)

	    admin.button9 = guiCreateButton(0.04, 0.93, 0.93, 0.05, "Zamknij", true, admin.window)

	    addEventHandler( "onClientGUIClick", admin.button, function()
	    	exports.colorpicker:openPicker('create', "#FFFFFF", "Wybierz kolor grupy")
	    end, false)
	    addEventHandler( "onClientGUIClick", admin.button2, admin.create, false)
	    addEventHandler( "onClientGUIClick", admin.button3, function()
	    	exports.colorpicker:openPicker('edit', "#FFFFFF", "Wybierz kolor grupy")
	    end, false)
	    addEventHandler( "onClientGUIClick", admin.button4, admin.editFunc, false)
	    addEventHandler( "onClientGUIClick", admin.gridlist, admin.info, false)
	    addEventHandler( "onClientGUIClick", admin.gridlist3, admin.playerPerm, false)
	    addEventHandler( "onClientGUIClick", admin.gridlist4, admin.playerGroups, false)
	    addEventHandler( "onClientGUIClick", admin.button5, admin.delete, false)
	    addEventHandler( "onClientGUIClick", admin.button6, admin.playerSave, false)
	    addEventHandler( "onClientGUIClick", admin.button7, admin.playerKick, false)
	    addEventHandler( "onClientGUIClick", admin.button8, admin.playerAdd, false)
	    addEventHandler( "onClientGUIClick", admin.button9, admin.hide, false)
	else
		admin.list = list
		admin.loadPlayersGroup()
	end
	admin.reload()
end

addEvent("admin:group", true)
addEventHandler("admin:group", localPlayer, admin.show)

function admin.picker(element, hex, r, g, b)
	if element == 'create' then
		admin.createcol = {r, g, b}
 		guiSetProperty( admin.button, "NormalTextColour", "FF".. string.sub(hex, 2, #hex ))
	end

	if element == 'edit' then
		admin.editcol = {r, g, b}
		guiSetProperty( admin.button3, "NormalTextColour", "FF".. string.sub(hex, 2, #hex ))
	end
end

addEventHandler("onColorPickerOK", root, admin.picker)

--GUI pomocy
local help = {}

function help.hide()
	removeEventHandler ( "onClientGUIClick", help.button, help.hide, false )
	destroyElement( help.window )
	showCursor( false )
	help.active = false
end

function help.show(groupType)
	if help.active then return help.hide() end
	showCursor( true )
	help.active = true
	help.window = guiCreateWindow((screenX - 390) / 2, (screenY - 146) / 2, 390, 146, "Komendy grupy", false)
	guiWindowSetSizable(help.window, false)
	help.button = guiCreateButton(0.03, 0.80, 0.94, 0.12, "Zamknij", true, help.window)
	
	local cmdList

	if groupType == 1 then
		cmdList = '/o [ID gracza] prawojazdy, /o [ID gracza] dowod, /o [ID gracza] rejestracja, /d\n\n@[SLOT GRUPY] - czat OOC grupy, ![SLOT GRUPY] - czat IC grupy (radio)'
	elseif groupType == 2 then
		cmdList = '/blokada, /skuj, /przeszukaj, /gps, /d\n\n@[SLOT GRUPY] - czat OOC grupy, ![SLOT GRUPY] - czat IC grupy (radio)'
	else
		return help.hide()
	end

	help.memo = guiCreateMemo(0.03, 0.18, 0.95, 0.57, cmdList, true, help.window)
	guiMemoSetReadOnly(help.memo, true)

	addEventHandler ( "onClientGUIClick", help.button, help.hide, false )
end

addEvent('groupHelp', true)
addEventHandler( 'groupHelp', localPlayer, help.show)


--GUI informacji o grupie
local info = {}
info.active = false

function info.hide()
	removeEventHandler( "onClientGUIClick", info.button, info.hide )
	destroyElement( info.window )
	showCursor( false )
	info.active = false
end

function info.show(slot, data)
	if info.active then return end

	info.active = true
	showCursor( true )
	info.window = guiCreateWindow ( screenX/2 - 216, screenY/2 - 225, 432, 450, "Informacje o grupie", false )
	guiWindowSetSizable ( info.window, false )
	info.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.87, true, info.window )
	guiGridListSetSelectionMode ( info.gridlist, 0 )
	guiGridListAddColumn ( info.gridlist, "Nazwa", 0.425 )
	guiGridListAddColumn ( info.gridlist, "Wartość", 0.425 )
	guiGridListSetSortingEnabled( info.gridlist, false )

	info.button = guiCreateButton ( 0.0, 0.93, 1.0, 0.07, "Zamknij", true, info.window )

	info.column = {}
	info.column[1] = {}
	info.column[1].name = "UID grupy:"
	info.column[1].value = data.id
	info.column[2] = {}
	info.column[2].name = "Nazwa:"
	info.column[2].value = data.name
	info.column[3] = {}
	info.column[3].name = "TAG:"
	info.column[3].value = data.tag
	info.column[4] = {}
	info.column[4].name = "Kolor:"
	info.column[4].value = string.format("(%d, %d, %d)", unpack(data.color))
	info.column[5] = {}
	info.column[5].name = "Typ:"
	info.column[5].value = getGroupType(data.type)
	info.column[6] = {}
	info.column[6].name = "W banku:"
	info.column[6].value = "$"..data.bank
	info.column[7] = {}
	info.column[7].name = "Flagi:"
	info.column[7].value = data.flags
	info.column[8] = {}
	info.column[8].name = " "
	info.column[8].value = " "
	info.column[9] = {}
	info.column[9].name = "Dzisiaj na służbie:"
	info.column[9].value = string.format("%dh %dmin", getElementData( localPlayer, "group_"..slot..":duty_time" ) / 60, getElementData( localPlayer, "group_"..slot..":duty_time" ))
	info.column[10] = {}
	info.column[10].name = "ID skina:"
	info.column[10].value = getElementData( localPlayer, "group_"..slot..":skin" ) == -1 and "Nie przydzielono" or getElementData( localPlayer, "group_"..slot..":skin" )
	info.column[11] = {}
	info.column[11].name = "Ranga:"
	info.column[11].value = (string.len(getElementData( localPlayer, "group_"..slot..":rank" )) == 0) and "Nie ustawiono." or getElementData( localPlayer, "group_"..slot..":rank" )
	info.column[12] = {}
	info.column[12].name = "Maska uprawnień:"
	info.column[12].value = getElementData( localPlayer, "group_"..slot..":perm" )


	for i, v in ipairs(info.column) do
		local row = guiGridListAddRow ( info.gridlist )
		guiGridListSetItemText ( info.gridlist, row, 1, info.column[i].name, false, false )
		guiGridListSetItemText ( info.gridlist, row, 2, info.column[i].value, false, false )
	end
	addEventHandler ( "onClientGUIClick", info.button, info.hide, false )
end

addEvent('showGroupInfo', true)
addEventHandler( 'showGroupInfo', localPlayer, info.show )

--GUI magazynu
local magazine = {}
magazine.active = false

function magazine.hide()
	removeEventHandler ( "onClientGUIClick", magazine.button[1], magazine.send, false )
  removeEventHandler ( "onClientGUIClick", magazine.button[2], magazine.hide, false )
  showCursor( false )
  destroyElement( magazine.window )
  magazine.active = false
end

function magazine.send()
	local id = guiGridListGetSelectedItem( magazine.gridlist ) + 1
	local amount = tonumber( guiGetText( magazine.edit ) )

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego przedmiotu")
	end

	if not amount or magazine.productList[id].item_count < amount then
		return exports.sarp_notify:addNotify("Błędna wartość ilości przedmiotów.")
	end

	triggerServerEvent( "magazinePull", localPlayer, magazine.productList[id].uid, amount, magazine.groupid )
	magazine.hide()
end

function magazine.list(product, groupid)
	if magazine.active then return end
	showCursor( true )
	magazine.productList = product
	magazine.groupid = groupid
	magazine.active = true
	magazine.window = guiCreateWindow((screenX - 313) / 2, (screenY - 321) / 2, 313, 321, "Magazyn grupy", false)
  guiWindowSetSizable(magazine.window, false)
  magazine.gridlist = guiCreateGridList(0.03, 0.07, 0.94, 0.73, true, magazine.window)
  guiGridListAddColumn(magazine.gridlist, "Nazwa przedmiotu", 0.5)
  guiGridListAddColumn(magazine.gridlist, "Ilość", 0.5)
  guiGridListSetSortingEnabled( magazine.gridlist, false )

  magazine.button = {}
  magazine.button[1] = guiCreateButton(0.03, 0.90, 0.43, 0.06, "Wyciągnij przedmiot", true, magazine.window)
  magazine.button[2] = guiCreateButton(0.54, 0.90, 0.43, 0.06, "Zamknij", true, magazine.window)
  magazine.edit = guiCreateEdit(0.25, 0.81, 0.43, 0.07, "", true, magazine.window)
  magazine.label = guiCreateLabel(0.04, 0.82, 0.24, 0.06, "Ilość sztuk:", true, magazine.window)
	magazine.update()

	addEventHandler ( "onClientGUIClick", magazine.button[1], magazine.send, false )
  addEventHandler ( "onClientGUIClick", magazine.button[2], magazine.hide, false )
end

addEvent("magazineShow", true)
addEventHandler( "magazineShow", localPlayer, magazine.list )

function magazine.update()
	guiGridListClear( magazine.gridlist )
	for i, v in ipairs(magazine.productList) do
		local row = guiGridListAddRow( magazine.gridlist )
		guiGridListSetItemText( magazine.gridlist, row, 1, v.item_name, false, false )
		guiGridListSetItemText( magazine.gridlist, row, 2, v.item_count, false, false )
	end
end


--GUI listy grup
local manage = {}
manage.active = false

function manage.hide()
	removeEventHandler ( "onClientGUIClick", manage.button, manage.hide )
	destroyElement( manage.window )
	showCursor( false )

	manage.active = false
end

function manage.show()
	local groupCount = 0

	for i = 1, 3 do
		local id = getElementData(localPlayer, "group_"..i..":id")
		if id then
			groupCount = groupCount + 1
		end
	end

	if groupCount == 0 then 
		return exports.sarp_notify:addNotify("Nie należysz do żadnej grupy.")
	else 
		exports.sarp_notify:addNotify("Użyj: /g [slot (1-3)] [info | duty | online | przebierz | pojazdy | zapros | wypros | opusc | magazyn | pomoc]") 
	end

	if manage.active then return end
	manage.active = true
	showCursor( true )
	local x, y = screenX/2 - 200, screenY/2 - 150
	manage.window = guiCreateWindow ( x, y, 400, 300, "Przynależność do grup", false )
	guiWindowSetSizable ( manage.window, false )
	manage.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.8, true, manage.window )
	guiGridListSetSelectionMode ( manage.gridlist, 0 )
	guiGridListAddColumn ( manage.gridlist, "Slot", 0.325 )
	guiGridListAddColumn ( manage.gridlist, "Nazwa", 0.525 )
	guiGridListSetSortingEnabled( manage.gridlist, false )

	manage.button = guiCreateButton ( 0.0, 0.9, 1.0, 0.1, "Zamknij", true, manage.window )
	addEventHandler ( "onClientGUIClick", manage.button, manage.hide, false )

	for i = 1, 3 do
		local name = getElementData(localPlayer, "group_"..i..":name")
		if name then
			local row = guiGridListAddRow ( manage.gridlist )
			guiGridListSetItemText ( manage.gridlist, row, 1, i, false, false )
			guiGridListSetItemText ( manage.gridlist, row, 2, name, false, false )
		end
	end
end

addEvent("showGroupList", true)
addEventHandler( "showGroupList", localPlayer, manage.show )

--GUI wynajmu hotelu
local motel = {}
motel.window = {}
local motelData = {}

function motel.hide()
	removeEventHandler ( "onClientGUIClick", motel.button[1], motel.checkOut, false )
	removeEventHandler ( "onClientGUIClick", motel.button[2], motel.checkIn, false )
	removeEventHandler ( "onClientGUIClick", motel.button[3], motel.hide, false )
	showCursor( false )
	destroyElement( motel.window[1] )

	if isElement(motel.window[2]) then
		motel.hideOut()
	end
end

function motel.hideOut()
	removeEventHandler ( "onClientGUIClick", motel.button[4], motel.checkOut, false )
	removeEventHandler ( "onClientGUIClick", motel.button[5], motel.hideOut, false )
	destroyElement( motel.window[2] )
end

function motel.checkOut()
	triggerServerEvent( "motelcheckOut", localPlayer, motelData.motelID )
	motel.hide()
end

function motel.checkIn()
	local day = tonumber(guiGetText( motel.edit ))

	if day <= 0 then
		return exports.sarp_notify:addNotify("Nieprawidłowa wartość ilości dni.")
	end

	triggerServerEvent( "motelcheckIn", localPlayer, motelData.motelID, day)
	motel.hide()
end

function motel.show(motelID, date)
	if isElement(motel.window[1]) then motel.hide() end
	showCursor( true )
	motel.window[1] = guiCreateWindow((screenX - 325) / 2, (screenY - 217) / 2, 325, 217, "Hotel", false)
	guiWindowSetSizable(motel.window[1], false)

	motelData.motelID = motelID
	motelData.date = date

	local status

	if motelData.date > getRealTime().timestamp then
		status = 1
	end

	local time = getRealTime( motelData.date )

	motel.label = {}
	motel.label[1] = guiCreateLabel(0.03, 0.12, 0.94, 0.12, status == 1 and string.format("Jesteś zameldowany w tym hotelu do %02d.%02d.%dr.", time.monthday, time.month, 1900 + time.year) or "Aktualnie nie jesteś zameldowany w tym hotelu.", true, motel.window[1])
	motel.button = {}
	motel.button[1] = guiCreateButton(0.05, 0.71, 0.90, 0.09, "Wymelduj się", true, motel.window[1])
	motel.button[2] = guiCreateButton(0.05, 0.57, 0.90, 0.09, status == 1 and "Przedłuż" or "Zamelduj się", true, motel.window[1])
	motel.button[3] = guiCreateButton(0.05, 0.84, 0.90, 0.09, "Zamknij", true, motel.window[1])
	motel.label[2] = guiCreateLabel(0.04, 0.27, 0.18, 0.10, "Ilość dni:", true, motel.window[1])
	guiSetFont(motel.label[2], "default-bold-small")
	guiLabelSetVerticalAlign(motel.label[2], "center")
	motel.edit = guiCreateEdit(0.22, 0.27, 0.18, 0.10, "1", true, motel.window[1])
	motel.label[3] = guiCreateLabel(0.05, 0.44, 0.57, 0.08, "Za 0 dni zapłacisz 0$.", true, motel.window[1])
	guiSetFont(motel.label[3], "default-bold-small")

	addEventHandler ( "onClientGUIClick", motel.button[1], function()
		local time = motelData.date

		if not time or time < getRealTime().timestamp then
			return exports.sarp_notify:addNotify("Nie jesteś zameldowany w tym hotelu.")
		end

		if isElement(motel.window[2]) then motel.hideOut() end

		motel.window[2] = guiCreateWindow((screenX - 305) / 2, (screenY - 93) / 2, 305, 93, "Wymeldowanie się", false)
	  guiWindowSetSizable(motel.window[2], false)

	  motel.label[4] = guiCreateLabel(0.03, 0.26, 0.97, 0.46, "Czy jesteś pewny, że chcesz wymeldować się z tego hotelu? Pieniądze nie zostaną tobie zwrócone.", true, motel.window[2])
	  guiLabelSetHorizontalAlign(motel.label[4], "left", true)
	  motel.button[4] = guiCreateButton(0.04, 0.71, 0.36, 0.18, "Tak", true, motel.window[2])
	  motel.button[5] = guiCreateButton(0.60, 0.72, 0.36, 0.17, "Nie", true, motel.window[2])

	  addEventHandler ( "onClientGUIClick", motel.button[4], motel.checkOut, false )
		addEventHandler ( "onClientGUIClick", motel.button[5], motel.hideOut, false )
	end, false )
	addEventHandler ( "onClientGUIClick", motel.button[2], motel.checkIn, false )
	addEventHandler ( "onClientGUIClick", motel.button[3], motel.hide, false )
	addEventHandler( "onClientGUIChanged", motel.edit, function()
		local day = tonumber(guiGetText( motel.edit )) or 0
		guiSetText( motel.label[3], string.format("Za %d dni zapłacisz %d$.", day, day * 14))
	end)
end

addEvent('showMotel', true)
addEventHandler( 'showMotel', root, motel.show )

--GUI listy graczy online
local online = {}
online.active = false

function online.hide()
	removeEventHandler( "onClientGUIClick", online.button, online.hide )
	destroyElement( online.window )
	showCursor( false )
	online.active = false
end

function online.show(groupid)
	if online.active then return end

	showCursor( true )
	online.active = true
	online.window = guiCreateWindow(screenX/2 - (429)/2, screenY/2 - (446)/2, 429, 446, "System grup - online", false)
  guiWindowSetSizable(online.window, false)
  online.gridlist = guiCreateGridList(0.02, 0.06, 0.96, 0.84, true, online.window)
  guiGridListSetSelectionMode ( online.gridlist, 0 )
	guiGridListAddColumn ( online.gridlist, "ID", 0.425 )
	guiGridListAddColumn ( online.gridlist, "Nick", 0.425 )
	guiGridListSetSortingEnabled( online.gridlist, false )

  online.button = guiCreateButton(0.02, 0.92, 0.96, 0.06, "Zamknij", true, online.window)

  for i, v in ipairs(getElementsByType( "player" )) do
  	for j = 1, 3 do
  		local pGroup = getElementData(v, "group_"..j..":id")
  		if pGroup and pGroup == groupid then
		  	local row = guiGridListAddRow ( online.gridlist )
				guiGridListSetItemText ( online.gridlist, row, 1, getElementData(v, "player:mtaID"), false, false )
				guiGridListSetItemText ( online.gridlist, row, 2, getElementData(v, "player:username"), false, false )
  		end
  	end
  end
  addEventHandler ( "onClientGUIClick", online.button, online.hide, false )
end

addEvent("showGroupOnline", true)
addEventHandler( "showGroupOnline", localPlayer, online.show )

--GUI pod /podaj
local podaj = {}
podaj.active = false

function podaj.hide()
	removeEventHandler ( "onClientGUIClick", podaj.button[1], podaj.send, false )
  removeEventHandler ( "onClientGUIClick", podaj.button[2], podaj.hide, false )
	showCursor( false )
	destroyElement( podaj.window )
	podaj.active = false
end

function podaj.send()
	local id = guiGridListGetSelectedItem( podaj.gridlist ) + 1
	local amount = tonumber( guiGetText( podaj.edit ) )

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego przedmiotu")
	end

	if not amount or podaj.productList[id].item_count < amount then
		return exports.sarp_notify:addNotify("Błędna wartość ilości przedmiotów.")
	end

	triggerServerEvent( "productOffer", localPlayer, podaj.productList[id].uid, amount, podaj.playerid )
	podaj.hide()
end

function podaj.list(productList, playerid)
	if podaj.active then return end
	showCursor( true )
	podaj.productList = productList
	podaj.playerid = playerid
	podaj.window = guiCreateWindow((screenX - 342) / 2, (screenY - 313) / 2, 342, 313, "Sprzedaż produktu", false)
  guiWindowSetSizable(podaj.window, false)

  podaj.gridlist = guiCreateGridList(0.03, 0.08, 0.95, 0.68, true, podaj.window)
  guiGridListAddColumn(podaj.gridlist, "Nazwa produktu", 0.3)
  guiGridListAddColumn(podaj.gridlist, "Ilość", 0.3)
  guiGridListAddColumn(podaj.gridlist, "Cena", 0.3)
  guiGridListSetSortingEnabled( podaj.gridlist, false )

  podaj.label = guiCreateLabel(0.04, 0.80, 0.20, 0.06, "Ilość sztuk:", true, podaj.window)
  guiLabelSetVerticalAlign(podaj.label, "center")
  podaj.edit = guiCreateEdit(0.23, 0.80, 0.34, 0.07, "1", true, podaj.window)
  podaj.button = {}
  podaj.button[1] = guiCreateButton(0.06, 0.91, 0.37, 0.06, "Wyślij oferte", true, podaj.window)
  podaj.button[2] = guiCreateButton(0.58, 0.91, 0.37, 0.06, "Zamknij", true, podaj.window)
  podaj.update()

  addEventHandler ( "onClientGUIClick", podaj.button[1], podaj.send, false )
  addEventHandler ( "onClientGUIClick", podaj.button[2], podaj.hide, false )
end

function podaj.update()
	guiGridListClear( podaj.gridlist )
	for i, v in ipairs(podaj.productList) do
		local row = guiGridListAddRow( podaj.gridlist )
		guiGridListSetItemText( podaj.gridlist, row, 1, v.item_name, false, false )
		guiGridListSetItemText( podaj.gridlist, row, 2, v.item_count, false, false )
		guiGridListSetItemText( podaj.gridlist, row, 3, v.price, false, false )
	end
end

addEvent("productSell", true)
addEventHandler( "productSell", localPlayer, podaj.list)

--GUI potwierdzenia nałożenia blokady na koła
local block = {}

function block.send()
	triggerServerEvent( "blockSubmit", localPlayer, block.information )
	block.hide()
end

function block.hide()
	removeEventHandler ( "onClientGUIClick", block.button[1], block.send, false )
  removeEventHandler ( "onClientGUIClick", block.button[2], block.hide, false )
	destroyElement( block.window )
	showCursor( false )
	block.active = false
end

function block.show(price)
	if block.active then block.hide() end
	block.active = true
	showCursor( true )
	block.information = {source, price}
	block.window = guiCreateWindow((screenX - 379) / 2, (screenY - 103) / 2, 379, 103, "Blokada na koła", false)
	guiWindowSetSizable(block.window, false)

	block.label = guiCreateLabel(0.03, 0.20, 0.96, 0.32, string.format("Czy na pewno chcesz nałożyć blokadę na pojazd %s (UID: %d) na kwotę %d$?", getVehicleNameFromModel( getElementModel(source)), getElementData(source, "vehicle:id"), price), true, block.window)
	guiLabelSetHorizontalAlign(block.label, "left", true)
	block.button = {}
	block.button[1] = guiCreateButton(0.03, 0.60, 0.43, 0.26, "Tak", true, block.window)
	guiSetProperty(block.button[1], "NormalTextColour", "FFFFFFFF")
	block.button[2] = guiCreateButton(0.53, 0.62, 0.43, 0.26, "Nie", true, block.window)
	guiSetProperty(block.button[2], "NormalTextColour", "FFFFFFFF")

	addEventHandler ( "onClientGUIClick", block.button[1], block.send, false )
  addEventHandler ( "onClientGUIClick", block.button[2], block.hide, false )
end

addEvent("blockAccept", true)
addEventHandler("blockAccept", root, block.show)

--GUI przeszukania pojazdu/gracza
local search = {}
search.active = false

function search.hide()
	removeEventHandler ( "onClientGUIClick", search.button, search.hide, false )
	destroyElement( search.window )
	showCursor( false )
	search.active = false
end

function search.show(list, elementID)
	if search.active then return end

	local title = getElementType( elementID ) == 'vehicle' and string.format("Przedmioty w pojeździe %s", getVehicleNameFromModel( getElementModel( elementID ))) or string.format("Przedmioty gracza o id: %d", getElementData(elementID, "player:mtaID"))

	search.active = true
	showCursor( true )
	search.window = guiCreateWindow((screenX - 322) / 2, (screenY - 375) / 2, 322, 375, title, false)
	guiWindowSetSizable(search.window, false)

	search.gridlist = guiCreateGridList(0.03, 0.07, 0.94, 0.84, true, search.window)
	guiGridListAddColumn(search.gridlist, "UID", 0.15)
	guiGridListAddColumn(search.gridlist, "Nazwa przedmiotu", 0.35)
	guiGridListAddColumn(search.gridlist, "Wartość 1", 0.2)
	guiGridListAddColumn(search.gridlist, "Wartość 2", 0.2)
	guiGridListSetSortingEnabled( search.gridlist, false )

	search.button = guiCreateButton(0.06, 0.93, 0.88, 0.05, "Zamknij", true, search.window)

	for i, v in ipairs(list) do
		local row = guiGridListAddRow ( search.gridlist )
		guiGridListSetItemText ( search.gridlist, row, 1, v.id, false, false )
		guiGridListSetItemText ( search.gridlist, row, 2, v.name, false, false )
		guiGridListSetItemText ( search.gridlist, row, 3, v.value1, false, false )
		guiGridListSetItemText ( search.gridlist, row, 4, v.value2, false, false )
	end

	addEventHandler ( "onClientGUIClick", search.button, search.hide, false )
end

addEvent( "searchElement", true )
addEventHandler( "searchElement", root, search.show )

--GUI listy pojazdów grupy
local vehicle = {}
vehicle.active = false
vehicle.blip = false
vehicle.list = false


function vehicle.hide()
	removeEventHandler ( "onClientGUIClick", vehicle.button, vehicle.hide )
	destroyElement( vehicle.window )
	showCursor( false )

	vehicle.active = false
end

function vehicle.spawn()
	local x = guiGridListGetSelectedItem ( vehicle.gridlist ) + 1
	if not vehicle.list[x] then return end
	triggerServerEvent( "group:spawnvehicle", localPlayer,  vehicle.list[x].id, vehicle.slot)
end

function vehicle.show(veh, slot)
	vehicle.list = veh
	if not vehicle.list[1] then return exports.sarp_notify:addNotify("Brak pojazdów przypisanych do tej grupy.") end
	if not vehicle.active then
		vehicle.active = true
		vehicle.slot = slot
		showCursor( true )
		local x, y = screenX/2 - 200, screenY/2 - 200
		vehicle.window = guiCreateWindow ( x, y, 400, 400, "Pojazdy grupy", false )
		guiWindowSetSizable ( vehicle.window, false )
		vehicle.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.8, true, vehicle.window )
		guiGridListSetSelectionMode ( vehicle.gridlist, 0 )
		guiGridListAddColumn ( vehicle.gridlist, "UID", 0.225 )
		guiGridListAddColumn ( vehicle.gridlist, "Nazwa", 0.425 )
		guiGridListAddColumn ( vehicle.gridlist, "HP", 0.2 )
		guiGridListSetSortingEnabled( vehicle.gridlist, false )


		vehicle.button = guiCreateButton ( 0.7, 0.9, 0.3, 0.1, "Zamknij", true, vehicle.window )
		vehicle.button2 = guiCreateButton ( 0.0, 0.9, 0.3, 0.1, "(Un)Spawn", true, vehicle.window )
		vehicle.button3 = guiCreateButton ( 0.35, 0.9, 0.3, 0.1, "Namierz", true, vehicle.window )
		addEventHandler ( "onClientGUIClick", vehicle.button, vehicle.hide, false )
		addEventHandler ( "onClientGUIClick", vehicle.button2, vehicle.spawn, false )
		addEventHandler ( "onClientGUIClick", vehicle.button3, function()
			local x = guiGridListGetSelectedItem ( vehicle.gridlist ) + 1
			local v = vehicle.list[x]
			if not v then return end
			if not vehicle.blip then
				if not v.mtaID then
					return exports.sarp_notify:addNotify("Najpierw musisz zespawnować pojazd, aby go namierzyć.")
				end

				local X, Y, Z = getElementPosition( v.mtaID )
				vehicle.blip = createBlip( X, Y, Z, 55 )
				exports.sarp_notify:addNotify("Twój pojazd został zaznaczony na radarze.")
			else
				destroyElement( vehicle.blip )
				vehicle.blip = false
				exports.sarp_notify:addNotify("Namierzanie pojazdu zostało wyłączone.")
			end
		end, false )

		for i, v in ipairs(veh) do
			local row = guiGridListAddRow ( vehicle.gridlist )
			guiGridListSetItemText ( vehicle.gridlist, row, 1, v.id, false, false )
			guiGridListSetItemText ( vehicle.gridlist, row, 2, getVehicleNameFromModel(v.model), false, false )
			guiGridListSetItemText ( vehicle.gridlist, row, 3, v.hp, false, false )
		end
	end
end

addEvent("group:showvehicle", true)
addEventHandler( "group:showvehicle", localPlayer, vehicle.show )

--PASEK SAN NEWS
local newsBar = {}
newsBar.active = false
newsBar.font = dxCreateFont( "assets/bebas-neue.ttf", 15 * scaleX )
newsBar.font2 = dxCreateFont( "assets/Lato-Bold.ttf", 15 * scaleX )

function newsBar.show()
	if newsBar.status == false then return end

	dxDrawRectangle( 0, screenY - (30 * newsBar.space) * scaleX, screenX, (30 * newsBar.space) * scaleX, tocolor( 0, 0, 0, 200 ) )
	dxDrawText( newsBar.title, 20 * scaleX, screenY - (30 * newsBar.space) * scaleX, 0, screenY, tocolor(140, 156, 48), 1.0, newsBar.font2, "left", "center" )
	dxDrawText( newsBar.message, 35 * scaleX + newsBar.titleW, screenY - (30 * newsBar.space) * scaleX, 0, screenY, tocolor(255, 255, 255), 1.0, newsBar.font2, "left", "center" )
end

function newsBar.update(message, playerid, type)
	if newsBar.active and not message or not (playerid and type)   then
		removeEventHandler( "onClientRender", root, newsBar.show )
		newsBar.active = false
	else
		if type == 1 then
			newsBar.title = string.format("%s (LIVE):", getElementData(playerid, "player:username"))
		elseif type == 2 then
			newsBar.title = string.format("%s (WYWIAD):", getElementData(playerid, "player:username"))
		elseif type == 3 then
			newsBar.title = string.format("%s (REKLAMA):", getElementData(playerid, "player:username"))
		end

		newsBar.titleW = dxGetTextWidth( newsBar.title, 1.0, newsBar.font2 )
		local newmessage, space = exports.sarp_main:wordBreak(message, screenX - newsBar.titleW - 20 * scaleX - 130, false, 1.0, newsBar.font2)
		newsBar.message = newmessage
		newsBar.type = type
		newsBar.space = space + 1

		if not newsBar.active then
			addEventHandler( "onClientRender", root, newsBar.show )
		end
		newsBar.active = true
	end
end

addEvent('newsUpdate', true)
addEventHandler('newsUpdate', root, newsBar.update)

function newsBar.setStatus(status)
	if type(status) ~= 'boolean' then return end
	newsBar.status = status
end

addEvent('showNews', true)
addEventHandler( 'showNews', root, newsBar.setStatus )