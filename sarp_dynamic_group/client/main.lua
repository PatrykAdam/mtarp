--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local panel = {}
local panelData = false

function panel.hide()
	showCursor( false )

	if isElement(panel.window) then
		destroyElement( panel.window )
	end
end

local newData = {}

function newData.hide()
	destroyElement( newData.window )
end

function newData.create()
	local name = tostring(guiGetText( newData.edit ))

	if string.len(name) > 32 or string.len(name) < 5 then
		return exports.sarp_notify:addNotify("Nazwa grupy musi mieć od 5 do 32 znaków.")
	end

	triggerServerEvent( "createDynamicGroup", localPlayer, name )
	newData.hide()
end

function panel.newGroup()
	if isElement(newData.window) then return end

	if #panelData >= 3 then
		return exports.sarp_notify:addNotify("Maksymalnie możesz przynależeć do 3 grup dynamicznych.")
	end


	newData.window = guiCreateWindow((screenX - 308) / 2, (screenY - 93) / 2, 308, 93, "Tworzenie grupy dynamicznej", false)
	guiWindowSetSizable(newData.window, false)

	newData.label = guiCreateLabel(0.05, 0.30, 0.33, 0.23, "Nazwa grupy:", true, newData.window)
	guiLabelSetVerticalAlign(newData.label, "center")
	newData.edit = guiCreateEdit(0.30, 0.30, 0.67, 0.23, "", true, newData.window)
	newData.button = {}
	newData.button[1] = guiCreateButton(0.06, 0.68, 0.37, 0.22, "Utwórz grupe", true, newData.window)
	newData.button[2] = guiCreateButton(0.56, 0.68, 0.37, 0.22, "Anuluj", true, newData.window)

	addEventHandler( "onClientGUIClick", newData.button[1], newData.create, false )
	addEventHandler( "onClientGUIClick", newData.button[2], newData.hide, false )

end

function panel.show(data, groupID, tabID)
	panelData = data

	for i, v in ipairs(panelData) do
		v.doors = {}
		for j, k in ipairs(getElementsByType( "marker" )) do
			if getElementData(k, "type:doors") and not getElementData(k, "doors:exit") and getElementData(k, "doors:accessGroup") == v.id then
				table.insert(v.doors, k)
			end
		end
	end
	if groupID then
		return panel.showDetail(groupID, tabID)
	end

	if isElement(panel.window) then panel.hide() end

	showCursor( true )

	panel.window = guiCreateWindow((screenX - 369) / 2, (screenY - 182) / 2, 369, 182, "Grupy dynamiczne", false)
	guiWindowSetSizable(panel.window, false)

	panel.button = {}
	panel.button[1] = guiCreateButton(0.53, 0.84, 0.45, 0.10, "Zamknij", true, panel.window)
	panel.button[2] = guiCreateButton(0.22, 0.62, 0.56, 0.17, "Utwórz nową grupe", true, panel.window)
	panel.gridlist = guiCreateGridList(0.03, 0.13, 0.95, 0.43, true, panel.window)
	guiGridListAddColumn(panel.gridlist, "Slot", 0.25)
	guiGridListAddColumn(panel.gridlist, "Nazwa", 0.7)
	guiGridListSetSortingEnabled( panel.gridlist, false )

	for i, v in ipairs(panelData) do
		local row = guiGridListAddRow( panel.gridlist )
		guiGridListSetItemText( panel.gridlist, row, 1, i, false, false )
		guiGridListSetItemText( panel.gridlist, row, 2, v.name, false, false )
	end

	panel.button[3] = guiCreateButton(0.03, 0.84, 0.45, 0.10, "Wybierz", true, panel.window)

	addEventHandler( "onClientGUIClick", panel.button[1], panel.hide, false )
	addEventHandler( "onClientGUIClick", panel.button[2], panel.newGroup, false )
	addEventHandler( "onClientGUIClick", panel.button[3], panel.showDetail, false )
end

addEvent("showDynamicGroup", true)
addEventHandler( "showDynamicGroup", root, panel.show )

local accessData = {}

function accessData.hide()
	destroyElement( accessData.window )
	accessData.shared = nil
	accessData.groupInfo = nil
end

function panel.showPlayer(groupInfo, data)
	accessData.shared = data
	accessData.groupInfo = groupInfo

	accessData.window = guiCreateWindow((screenX - 318) / 2, (screenY - 156) / 2, 318, 156, "Udostępnij grupie dynamicznej", false)
	guiWindowSetSizable(accessData.window, false)

	accessData.gridlist = guiCreateGridList(0.03, 0.15, 0.94, 0.60, true, accessData.window)
	guiGridListAddColumn(accessData.gridlist, "ID", 0.2)
	guiGridListAddColumn(accessData.gridlist, "Nazwa", 0.7)
	guiGridListSetSortingEnabled( accessData.gridlist, false )

	for i, v in ipairs(accessData.groupInfo) do
		local row = guiGridListAddRow( accessData.gridlist )
		guiGridListSetItemText( accessData.gridlist, row, 1, v.id, false, false )
		guiGridListSetItemText( accessData.gridlist, row, 2, v.name, false, false )
	end

	accessData.button = {}
	accessData.button[1] = guiCreateButton(0.05, 0.80, 0.36, 0.13, "Udostępnij", true, accessData.window)
	accessData.button[2] = guiCreateButton(0.58, 0.80, 0.36, 0.13, "Anuluj", true, accessData.window)

	addEventHandler( "onClientGUIClick", accessData.button[1], function()
		local id = guiGridListGetSelectedItem( accessData.gridlist ) + 1

		if id == 0 then
			return exports.sarp_notify:addNotify("Nie wybrałeś żadnej grupy dynamiczne z listy.")
		end

		if accessData.shared[1] == 1 then
			triggerServerEvent( "accessVehicleDynamicGroup", localPlayer, accessData.groupInfo[id].id, accessData.shared[2])
		else
			triggerServerEvent( "accessDoorDynamicGroup", localPlayer, accessData.groupInfo[id].id, accessData.shared[2])
		end
		accessData.hide()
	end, false)
	addEventHandler( "onClientGUIClick", accessData.button[2], accessData.hide )
end

addEvent("showPlayerDynamicGroup", true)
addEventHandler( "showPlayerDynamicGroup", root, panel.showPlayer )

local dynData = {}

function dynData.hide()
	destroyElement( dynData.window )
	showCursor( false )
	dynData.leaveHide()
end

function dynData.leaveHide()
	if not (dynData.leave and dynData.leave['window']) then return end
	destroyElement( dynData.leave['window'] )
end

function dynData.leaveGroup()
	--jeżeli właściciel to pytamy się czy chce usunąć grupe
	if panelData[dynData.id].owner == getElementData(localPlayer, "player:id") then
		exports.sarp_notify:addNotify("UWAGA! Opuszczenie grupy będzie skutkowało usunięciem jej całkowicie!")
	end

	if dynData.leave and isElement(dynData.leave['window']) then destroyElement(dynData.leave['window']) end

	dynData.leave = {}
	dynData.leave['window'] = guiCreateWindow((screenX - 307) / 2, (screenY - 93) / 2, 307, 93, "Opuszczenie grupy", false)
  guiWindowSetSizable(dynData.leave['window'], false)

  dynData.leave['label'] = guiCreateLabel(0.03, 0.30, 0.94, 0.40, "Czy na pewno chcesz opuścić grupę dynamiczną o nazwie \"".. panelData[dynData.id].name .."\"?", true, dynData.leave['window'])
  guiLabelSetHorizontalAlign(dynData.leave['label'], "left", true)
  dynData.leave['button'] = {}
  dynData.leave['button'][1] = guiCreateButton(0.04, 0.69, 0.35, 0.22, "Tak", true, dynData.leave['window'])
  dynData.leave['button'][2] = guiCreateButton(0.59, 0.69, 0.35, 0.22, "Nie", true, dynData.leave['window'])

  addEventHandler( "onClientGUIClick", dynData.leave['button'][2], dynData.leaveHide, false)
  addEventHandler( "onClientGUIClick", dynData.leave['button'][1], function()
  	triggerServerEvent( "leaveDynamicGroup", localPlayer, panelData[dynData.id].id )
  	dynData.hide()
  end, false)
end

function dynData.gNameHide()
	if not (dynData.gName and dynData.gName['window']) then return end
	destroyElement( dynData.gName['window'] )
end

function dynData.groupName()
	if dynData.gName and isElement(dynData.gName['window']) then destroyElement(dynData.gName['window']) end

	dynData.gName = {}
	dynData.gName['window'] = guiCreateWindow((screenX - 405) / 2, (screenY - 95) / 2, 405, 95, "Zmiana nazwy grupy", false)
	guiWindowSetSizable(dynData.gName['window'], false)

	dynData.gName['label'] = guiCreateLabel(0.02, 0.34, 0.46, 0.25, "Nowa nazwa grupy dynamicznej:", true, dynData.gName['window'])
	guiLabelSetVerticalAlign(dynData.gName['label'], "center")
	dynData.gName['edit'] = guiCreateEdit(0.48, 0.35, 0.49, 0.24, "", true, dynData.gName['window'])
	dynData.gName['button'] = {}
	dynData.gName['button'][1] = guiCreateButton(0.05, 0.68, 0.38, 0.21, "Zmień nazwe", true, dynData.gName['window'])
	dynData.gName['button'][2] = guiCreateButton(0.56, 0.69, 0.38, 0.21, "Anuluj", true, dynData.gName['window'])

	addEventHandler( "onClientGUIClick", dynData.gName['button'][2], dynData.gNameHide, false)
	addEventHandler( "onClientGUIClick", dynData.gName['button'][1], function()
		local name = tostring(guiGetText( dynData.gName['edit'] ))

		if string.len(name) > 32 or string.len(name) < 5 then
			return exports.sarp_notify:addNotify("Nazwa grupy musi mieć od 5 do 32 znaków.")
		end

		triggerServerEvent( "setNameDynamicGroup", localPlayer, panelData[dynData.id].id, name )
	end, false)
end

function dynData.memberKick()
	local id = guiGridListGetSelectedItem( dynData.gridlist[2] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnej osoby z listy.")
	end

	triggerServerEvent( "memberKickDynamicGroup", localPlayer, panelData[dynData.id].id, panelData[dynData.id].members[id].player_id )
end

function dynData.memberSave()
	local id = guiGridListGetSelectedItem( dynData.gridlist[2] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnej osoby z listy.")
	end

	local perm = 0
	perm = perm + (guiCheckBoxGetSelected( dynData.checkbox[1] ) and 1 or 0)
	perm = perm + (guiCheckBoxGetSelected( dynData.checkbox[2] ) and 2 or 0)
	perm = perm + (guiCheckBoxGetSelected( dynData.checkbox[3] ) and 4 or 0)

	triggerServerEvent( "memberSaveDynamicGroup", localPlayer, panelData[dynData.id].id, panelData[dynData.id].members[id].player_id, perm )
end

function dynData.vehicleSpawn()
	local id = guiGridListGetSelectedItem( dynData.gridlist[3] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego pojazdu z listy.")
	end

	triggerServerEvent( "vehicleSpawnDynamicGroup", localPlayer, panelData[dynData.id].id, panelData[dynData.id].vehicles[id].id )
end

function dynData.vehicleTarget()
	local id = guiGridListGetSelectedItem( dynData.gridlist[3] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego pojazdu z listy.")
	end

	local vehicle = panelData[dynData.id].vehicles[id].mtaID

	if not isElement(vehicle) then
		return exports.sarp_notify:addNotify("Aby to zrobić musisz zespawnować pojazd.")
	end

	if isElement(dynData.blip) then
		destroyElement( dynData.blip )
		exports.sarp_notify:addNotify("Namierzanie pojazdu zostało wyłączone.")
	else
		dynData.blip = createBlip( Vector3(getElementPosition(vehicle)) )
		exports.sarp_notify:addNotify("Namierzanie pojazdu zostało włączone.")
	end
end

function dynData.memberInvite()
	--sprawdzamy odległości
	local id = tonumber(guiGetText( dynData.edit[1] ))
	local x, y, z = getElementPosition( localPlayer )
	local playerid2 = false

	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData( v, "player:mtaID") == id then
			playerid2 = v
			if getDistanceBetweenPoints3D( Vector3(getElementPosition( v )), x, y, z ) > 3.0 then
				return exports.sarp_notify:addNotify("Znajdujesz się zbyt daleko wybranego gracza.")
			end
		end
	end

	triggerServerEvent( "createOffer", root, localPlayer, playerid2, 18, 0, {id = panelData[dynData.id].id, name = panelData[dynData.id].name})
end

function dynData.vehicleKick()
	local id = guiGridListGetSelectedItem( dynData.gridlist[3] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego pojazdu z listy.")
	end

	triggerServerEvent( "vehicleKickDynamicGroup", localPlayer, panelData[dynData.id].id, panelData[dynData.id].vehicles[id].id )
end

function dynData.doorKick()
	local id = guiGridListGetSelectedItem( dynData.gridlist[4] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego budynku z listy.")
	end

	triggerServerEvent( "doorKickDynamicGroup", localPlayer, panelData[dynData.id].id, getElementData(panelData[dynData.id].doors[id], "doors:id") )
end

function dynData.doorTarger()
	local id = guiGridListGetSelectedItem( dynData.gridlist[4] ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego budynku z listy.")
	end

	local door = panelData[dynData.id].doors[id]

	if not isElement(door) then
		return exports.sarp_notify:addNotify("Te drzwi nie istnieją.")
	end

	if isElement(dynData.doorBlip) then
		destroyElement( dynData.doorBlip )
		exports.sarp_notify:addNotify("Namierzanie budynku zostało wyłączone.")
	else
		dynData.doorBlip = createBlip( Vector3(getElementPosition(door)) )
		exports.sarp_notify:addNotify("Namierzanie budynku zostało włączone.")
	end
end

function panel.showDetail(groupID, tabID)
	local newID = false
	for i, v in ipairs(panelData) do
		if v.id == groupID then
			newID = i
			break
		end
	end

	local id = newID or guiGridListGetSelectedItem( panel.gridlist ) + 1
	if id == 0 then
		return exports.sarp_notify:addNotify("Nie wybrałeś żadnej grupy dynamicznej z listy.")
	end

	dynData.id = id

	if isElement(dynData.window) then dynData.hide() end
	panel.hide()

	showCursor( true )
	dynData.window = guiCreateWindow((screenX - 489) / 2, (screenY - 313) / 2, 489, 313, "Panel grupy dynamicznej", false)
	guiWindowSetSizable(dynData.window, false)

	dynData.tabpanel = guiCreateTabPanel(0.02, 0.08, 0.96, 0.80, true, dynData.window)

	dynData.tab = {}
	dynData.tab[1] = guiCreateTab("Informacje", dynData.tabpanel)

	dynData.gridlist = {}
	dynData.gridlist[1] = guiCreateGridList(0.02, 0.05, 0.96, 0.57, true, dynData.tab[1])
	guiGridListAddColumn(dynData.gridlist[1], "--", 0.4)
	guiGridListAddColumn(dynData.gridlist[1], "Wartość", 0.5)
	for i = 1, 6 do
	    guiGridListAddRow(dynData.gridlist[1])
	end
	guiGridListSetItemText(dynData.gridlist[1], 0, 1, "Liczba członków", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 0, 2, #panelData[id].members, false, false)
	guiGridListSetItemText(dynData.gridlist[1], 1, 1, "Nazwa grupy dynamicznej", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 1, 2, panelData[id].name, false, false)
	guiGridListSetItemText(dynData.gridlist[1], 2, 1, "Udostępnione budynki", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 2, 2, "0", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 3, 1, "Udostępnione pojazdy", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 3, 2, #panelData[id].vehicles, false, false)
	guiGridListSetItemText(dynData.gridlist[1], 4, 1, "W banku", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 4, 2, panelData[id].cash, false, false)
	guiGridListSetItemText(dynData.gridlist[1], 5, 1, "Właściciel", false, false)
	guiGridListSetItemText(dynData.gridlist[1], 5, 2, panelData[id].ownerName or "Brak", false, false)
	guiGridListSetSortingEnabled( dynData.gridlist[1], false )
	dynData.button = {}
	dynData.button[1] = guiCreateButton(0.67, 0.72, 0.29, 0.17, "Opuść grupę", true, dynData.tab[1])
	dynData.button[2] = guiCreateButton(0.04, 0.75, 0.30, 0.10, "Zmień nazwę grupy", true, dynData.tab[1])

	addEventHandler( "onClientGUIClick", dynData.button[1], dynData.leaveGroup, false )
	addEventHandler( "onClientGUIClick", dynData.button[2], dynData.groupName, false )

	dynData.tab[2] = guiCreateTab("Członkowie", dynData.tabpanel)

	dynData.gridlist[2] = guiCreateGridList(0.03, 0.06, 0.48, 0.43, true, dynData.tab[2])
	guiGridListSetSortingEnabled( dynData.gridlist[2], false )
	guiGridListAddColumn(dynData.gridlist[2], "Imię i nazwisko", 0.9)
	for i, v in ipairs(panelData[id].members) do
		local row = guiGridListAddRow(dynData.gridlist[2])
		guiGridListSetItemText(dynData.gridlist[2], row, 1, v.username, false, false)
		if v.mtaID and isElement(v.mtaID) then
			guiGridListSetItemColor ( dynData.gridlist[2], row, 1, 65, 244, 124 )
		end
	end
	dynData.button[3] = guiCreateButton(0.58, 0.07, 0.31, 0.11, "Wyrzuć gracza", true, dynData.tab[2])
	dynData.button[4] = guiCreateButton(0.80, 0.26, 0.15, 0.10, "Zaproś", true, dynData.tab[2])

	addEventHandler( "onClientGUIClick", dynData.button[3], dynData.memberKick, false )
	addEventHandler( "onClientGUIClick", dynData.button[4], dynData.memberInvite, false )

	dynData.label = {}
	dynData.label[1] = guiCreateLabel(0.52, 0.26, 0.12, 0.10, "ID gracza:", true, dynData.tab[2])
	guiLabelSetVerticalAlign(dynData.label[1], "center")
	dynData.edit = {}
	dynData.edit[1] = guiCreateEdit(0.65, 0.26, 0.14, 0.10, "", true, dynData.tab[2])
	dynData.label[2] = guiCreateLabel(16, 118, 221, 23, "Uprawnienia gracza -:", false, dynData.tab[2])
	guiLabelSetVerticalAlign(dynData.label[2], "center")
	dynData.checkbox = {}
	dynData.checkbox[1] = guiCreateCheckBox(0.03, 0.65, 0.68, 0.09, "Dostęp do pojazdów", false, true, dynData.tab[2])
	dynData.checkbox[2] = guiCreateCheckBox(0.03, 0.74, 0.68, 0.09, "Dostęp do budynków", false, true, dynData.tab[2])
	dynData.checkbox[3] = guiCreateCheckBox(0.03, 0.83, 0.68, 0.09, "Wypłacanie środków", false, true, dynData.tab[2])
	dynData.button[5] = guiCreateButton(0.57, 0.70, 0.32, 0.13, "Zapisz uprawnienia", true, dynData.tab[2])

	addEventHandler( "onClientGUIClick", dynData.button[5], dynData.memberSave, false )
	addEventHandler( "onClientGUIClick", dynData.gridlist[2], function()
		local id = guiGridListGetSelectedItem( dynData.gridlist[2] ) + 1

		if id ~= 0 then
			guiSetText( dynData.label[2], "Uprawnienia gracza ".. panelData[dynData.id].members[id].username..":")
			guiCheckBoxSetSelected( dynData.checkbox[1], getPlayerPermission(panelData[dynData.id].members[id].permissions, 1) )
			guiCheckBoxSetSelected( dynData.checkbox[2], getPlayerPermission(panelData[dynData.id].members[id].permissions, 2) )
			guiCheckBoxSetSelected( dynData.checkbox[3], getPlayerPermission(panelData[dynData.id].members[id].permissions, 4) )
		else
			guiSetText( dynData.label[2], "Uprawnienia gracza -:" )
			for i, v in ipairs(dynData.checkbox) do
				guiCheckBoxSetSelected( v, false )
			end
		end
	end, false )
	

	dynData.tab[3] = guiCreateTab("Pojazdy", dynData.tabpanel)

	dynData.gridlist[3] = guiCreateGridList(0.03, 0.05, 0.95, 0.69, true, dynData.tab[3])
	guiGridListSetSortingEnabled( dynData.gridlist[3], false )
	guiGridListAddColumn(dynData.gridlist[3], "Model", 0.2)
	guiGridListAddColumn(dynData.gridlist[3], "Zespawnowany", 0.2)
	guiGridListAddColumn(dynData.gridlist[3], "HP", 0.2)
	guiGridListAddColumn(dynData.gridlist[3], "Właściciel", 0.2)
	for i, v in ipairs(panelData[id].vehicles) do
		local row = guiGridListAddRow(dynData.gridlist[3])
		guiGridListSetItemText(dynData.gridlist[3], row, 1, getVehicleNameFromModel( v.model ), false, false)
		guiGridListSetItemText(dynData.gridlist[3], row, 2, isElement( v.mtaID ) and "Tak" or "Nie", false, false)
		guiGridListSetItemText(dynData.gridlist[3], row, 3, v.hp, false, false)
		guiGridListSetItemText(dynData.gridlist[3], row, 4, v.ownerName, false, false)
	end
	dynData.button[6] = guiCreateButton(0.05, 0.81, 0.30, 0.12, "(Un)Spawn", true, dynData.tab[3])
	dynData.button[7] = guiCreateButton(0.66, 0.81, 0.30, 0.12, "Odpisz od grupy", true, dynData.tab[3])
	dynData.button[8] = guiCreateButton(0.38, 0.81, 0.24, 0.12, "Namierz", true, dynData.tab[3])

	addEventHandler( "onClientGUIClick", dynData.button[6], dynData.vehicleSpawn, false )
	addEventHandler( "onClientGUIClick", dynData.button[7], dynData.vehicleKick, false )
	addEventHandler( "onClientGUIClick", dynData.button[8], dynData.vehicleTarget, false )

	dynData.tab[4] = guiCreateTab("Budynki", dynData.tabpanel)

	dynData.gridlist[4] = guiCreateGridList(0.03, 0.05, 0.95, 0.73, true, dynData.tab[4])
	guiGridListSetSortingEnabled( dynData.gridlist[4], false )
	guiGridListAddColumn(dynData.gridlist[4], "ID", 0.2)
	guiGridListAddColumn(dynData.gridlist[4], "Nazwa", 0.2)
	guiGridListAddColumn(dynData.gridlist[4], "Właściciel", 0.2)
	guiGridListAddColumn(dynData.gridlist[4], "Zamknięty", 0.2)
	
	for i, v in ipairs(panelData[id].doors) do
		local row = guiGridListAddRow(dynData.gridlist[4])
		guiGridListSetItemText(dynData.gridlist[4], row, 1, getElementData(v, "doors:id"), false, false)
		guiGridListSetItemText(dynData.gridlist[4], row, 2, getElementData(v, "doors:name"), false, false)
		guiGridListSetItemText(dynData.gridlist[4], row, 3, getElementData(v, "doors:ownerName"), false, false)
		guiGridListSetItemText(dynData.gridlist[4], row, 4, getElementData(v, "doors:lock") == 1 and "Tak" or "Nie", false, false)
	end

	dynData.button[9] = guiCreateButton(0.08, 0.83, 0.31, 0.11, "Namierz", true, dynData.tab[4])
	dynData.button[10] = guiCreateButton(0.59, 0.82, 0.31, 0.11, "Odpisz od grupy", true, dynData.tab[4])
	dynData.button[11] = guiCreateButton(0.03, 0.91, 0.93, 0.06, "Zamknij", true, dynData.window)

	addEventHandler( "onClientGUIClick", dynData.button[9], dynData.doorTarger, false )
	addEventHandler( "onClientGUIClick", dynData.button[10], dynData.doorKick, false )
	addEventHandler( "onClientGUIClick", dynData.button[11], dynData.hide, false )


	if type(tabID) == 'number' then
		guiSetSelectedTab( dynData.tabpanel, dynData.tab[tabID] )
	end
end

function getPlayerPermission(playerPerm, perm)
	if exports.sarp_main:bitAND(playerPerm, perm) ~= 0 then
		return true
	else
		return false
	end
end