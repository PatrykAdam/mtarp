--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local description = {}
description.active = false

function description.hide()
	removeEventHandler( "onClientGUIClick", description.button[1], description.hide, false )
	removeEventHandler( "onClientGUIClick", description.button[2], description.delete, false )
	removeEventHandler( "onClientGUIClick", description.button[3], description.editEx, false )
	removeEventHandler( "onClientGUIClick", description.button[4], description.new, false )
	removeEventHandler( "onClientGUIClick", description.button[5], description.setChar, false )
	removeEventHandler( "onClientGUIClick", description.button[6], description.setVehicle, false )
	showCursor( false )
	description.active = false
	destroyElement( description.window )
end

function description.delete()
	local id = guiGridListGetSelectedItem( description.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego opisu.")
	end

	triggerServerEvent( "deleteDescription", localPlayer, description.list[id].id )
end

function description.edithide()
	removeEventHandler( "onClientGUIClick", description.editbutton, description.editSave, false )
	description.editactive = false
	destroyElement( description.editWindow )
end

function description.editSave()
	local title, desc = tostring( guiGetText( description.editedit ) ), tostring( guiGetText( description.editmemo ) )

	if string.len(title) == 0 or string.len(desc) == 1 or string.len(title) < 3 or string.len(desc) < 4 then
		return exports.sarp_notify:addNotify("Musisz uzupełnić wszystkie pola - minimum 3 znaki.")
	end

	triggerServerEvent( "editDescription", localPlayer, description.editID, title, desc )
	description.edithide()
end

function description.editEx()
	local id = guiGridListGetSelectedItem( description.gridlist ) + 1

	if id == 0 then
		return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego opisu.")
	end

	if description.editactive then return description.edithide() end
	description.editID = description.list[id].id
	description.editactive = true
	description.editWindow = guiCreateWindow((screenX - 384) / 2, (screenY - 231) / 2, 384, 231, "Edycja opisu", false)
  guiWindowSetSizable(description.editWindow, false)   
  description.editlabel = {}
	description.editlabel[1] = guiCreateLabel(0.02, 0.12, 0.12, 0.11, "Tytuł:", true, description.editWindow)
	guiSetFont(description.editlabel[1], "default-bold-small")
	guiLabelSetHorizontalAlign(description.editlabel[1], "center", false)
	guiLabelSetVerticalAlign(description.editlabel[1], "center")
	description.editedit = guiCreateEdit(0.16, 0.12, 0.55, 0.10, "", true, description.editWindow)
	description.editlabel[2] = guiCreateLabel(0.03, 0.29, 0.23, 0.13, "Treść opisu:", true, description.editWindow)
	guiSetFont(description.editlabel[2], "default-bold-small")
	guiLabelSetHorizontalAlign(description.editlabel[2], "center", false)
	guiLabelSetVerticalAlign(description.editlabel[2], "center")
	description.editmemo = guiCreateMemo(0.25, 0.29, 0.72, 0.56, "", true, description.editWindow)
	description.editbutton = guiCreateButton(0.35, 0.87, 0.30, 0.09, "Zapisz opis", true, description.editWindow)
	guiSetText( description.editedit, description.list[id].title )
	guiSetText( description.editmemo, description.list[id].description )
	addEventHandler( "onClientGUIClick", description.editbutton, description.editSave, false )
end

function description.new()
	local title, desc = tostring( guiGetText( description.edit ) ), tostring( guiGetText( description.memo ) )

	if string.len(title) == 0 or string.len(desc) == 1 or string.len(title) < 3 or string.len(desc) < 4 then
		return exports.sarp_notify:addNotify("Musisz uzupełnić wszystkie pola - minimum 3 znaki.")
	end

	triggerServerEvent( "newDescription", localPlayer, title, desc )
end

function description.setChar()
	local tab = guiGetSelectedTab( description.tabpanel )
	
	local desc = ''
	if tab == description.tab[1] then
		local id = guiGridListGetSelectedItem( description.gridlist ) + 1
		if id == 0 then
			return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego opisu.")
		end

		desc = description.list[id].description
	elseif tab == description.tab[2] then
		desc = tostring( guiGetText( description.memo ) )
	end
	triggerServerEvent( "charDescription", localPlayer, desc )
end

function description.setVehicle()
	if not getPedOccupiedVehicle( localPlayer ) then return exports.sarp_notify:addNotify("Nie znajdujesz się w żadnym pojeździe.") end

	local tab = guiGetSelectedTab( description.tabpanel )
	
	local desc = ''
	if tab == description.tab[1] then
		local id = guiGridListGetSelectedItem( description.gridlist ) + 1
		if id == 0 then
			return exports.sarp_notify:addNotify("Nie zaznaczyłeś żadnego opisu.")
		end

		desc = description.list[id]['description']
	elseif tab == description.tab[2] then
		desc = tostring( guiGetText( description.memo ) )
	end
	triggerServerEvent( "vehicleDescription", localPlayer, desc )
end

function description.update()
	guiSetSelectedTab( description.tabpanel, description.tab[1] )
	guiSetText( description.edit, "" )
	guiSetText( description.memo, "" )
	guiGridListClear( description.gridlist )
	for i, v in ipairs(description.list) do
		local row = guiGridListAddRow( description.gridlist )
		guiGridListSetItemText ( description.gridlist, row, 1, v.title, false, false )
	end
end

function description.show(descriptionList)
	if description.active then description.list = descriptionList return description.update() end
	description.list = descriptionList
	description.active = true
	showCursor( true )
	description.window = guiCreateWindow((screenX - 402) / 2, (screenY - 372) / 2, 402, 372, "System opisów", false)
	guiWindowSetSizable(description.window, false)

	description.button = {}
	description.button[1] = guiCreateButton(0.03, 0.92, 0.95, 0.05, "Zamknij", true, description.window)
	description.tabpanel = guiCreateTabPanel(0.02, 0.07, 0.95, 0.69, true, description.window)

	description.tab = {}
	description.tab[1] = guiCreateTab("Zapisane opisy", description.tabpanel)

	description.gridlist = guiCreateGridList(0.03, 0.04, 0.94, 0.79, true, description.tab[1])
	guiGridListAddColumn(description.gridlist, "Tytuł", 0.9)
	description.button[2] = guiCreateButton(0.05, 0.88, 0.37, 0.07, "Usuń opis", true, description.tab[1])
	description.button[3] = guiCreateButton(0.57, 0.88, 0.37, 0.07, "Edytuj opis", true, description.tab[1])

	description.tab[2] = guiCreateTab("Nowy opis", description.tabpanel)

	description.label = {}
	description.label[1] = guiCreateLabel(0.02, 0.06, 0.12, 0.11, "Tytuł:", true, description.tab[2])
	guiSetFont(description.label[1], "default-bold-small")
	guiLabelSetHorizontalAlign(description.label[1], "center", false)
	guiLabelSetVerticalAlign(description.label[1], "center")
	description.edit = guiCreateEdit(0.16, 0.07, 0.55, 0.10, "", true, description.tab[2])
	description.label[2] = guiCreateLabel(0.03, 0.24, 0.23, 0.13, "Treść opisu:", true, description.tab[2])
	guiSetFont(description.label[2], "default-bold-small")
	guiLabelSetHorizontalAlign(description.label[2], "center", false)
	guiLabelSetVerticalAlign(description.label[2], "center")
	description.memo = guiCreateMemo(0.25, 0.24, 0.72, 0.56, "", true, description.tab[2])
	description.button[4] = guiCreateButton(0.35, 0.87, 0.30, 0.09, "Zapisz opis", true, description.tab[2])


	description.button[5] = guiCreateButton(0.03, 0.85, 0.95, 0.05, "Ustaw opis w pojeździe", true, description.window)
	description.button[6] = guiCreateButton(0.03, 0.78, 0.95, 0.05, "Ustaw opis na postaci", true, description.window)    

	description.update()
	addEventHandler( "onClientGUIClick", description.button[1], description.hide, false )
	addEventHandler( "onClientGUIClick", description.button[2], description.delete, false )
	addEventHandler( "onClientGUIClick", description.button[3], description.editEx, false )
	addEventHandler( "onClientGUIClick", description.button[4], description.new, false )
	addEventHandler( "onClientGUIClick", description.button[5], description.setVehicle, false )
	addEventHandler( "onClientGUIClick", description.button[6], description.setChar, false )
end

addEvent('showDescription', true)
addEventHandler( 'showDescription', localPlayer, description.show )