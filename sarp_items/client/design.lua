screenX, screenY = guiGetScreenSize()
scaleX, scaleY = math.max(0.5, (screenX / 1920)), math.max(0.5, (screenY / 1080))

local items = {}
items.active = false
items.listW, items.listH = 450 * scaleX, 528 * scaleY
items.listX, items.listY = screenX - items.listW, screenY/2
items.menuW, items.menuH = 226 * scaleX, 100 * scaleY
items.chooseW, items.chooseH = 74 * scaleX, 85 * scaleX
items.lastTick = 0
items.choose = 1
items.scroll = 0
items.max = 0
items.select = 1
items.option = 1
items.pagemax = 22
items.font = dxCreateFont( "/assets/Lato-Regular.ttf", 12 * scaleX )
items.lastSearch = 0

function items.onRender()
	local progress, X = (getTickCount() - items.lastTick) / 500, false
	if items.active == true then
		X = interpolateBetween( screenX + items.listW, 0, 0,
									 items.listX, 0, 0,
									 progress, "Linear" )
	else
		X = interpolateBetween( items.listX, 0, 0,
									 screenX + items.listW, 0, 0,
									 progress, "Linear" )
 
		if progress > 1 then
			removeEventHandler( "onClientRender", root, items.onRender )
			toggleControl ( "fire", true )
			toggleControl ( "next_weapon", true )
			toggleControl ( "previous_weapon", true )
		end
	end

	--Tworzymy platformy
	local windowH = items.pagemax < #items.list and items.listH or #items.list * (20 * scaleY) + 70 * scaleY

	dxDrawRectangle(X, items.listY - windowH/2, items.listW, windowH, tocolor(0, 0, 0, 150), false)

	dxDrawText("Przedmioty", X + 4 * scaleX, items.listY - windowH/2 + 5 * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center", false, false, true, false, false)
  dxDrawText("Nazwa", X + 80 * scaleX, items.listY - windowH/2 + 30 * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, tocolor(255, 255, 255, 167), 1.0, items.font, "left", "top", false, false, true, false, false)
  dxDrawText("Wartość 1", X + 270 * scaleX, items.listY - windowH/2 + 30 * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, tocolor(255, 255, 255, 167), 1.0, items.font, "left", "top", false, false, true, false, false)
  dxDrawText("Wartość 2", X + 360 * scaleX, items.listY - windowH/2 + 30 * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, tocolor(255, 255, 255, 167), 1.0, items.font, "left", "top", false, false, true, false, false)
  dxDrawText("UID", X + 10 * scaleX, items.listY - windowH/2 + 30 * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, tocolor(255, 255, 255, 167), 1.0, items.font, "left", "top", false, false, true, false, false)

	local starty = 60
	local num = 0
	local shownum = 0
	for i, v in ipairs(items.list) do
		local item = items.list[i]
		num = num + 1

		local kolor = tocolor(255, 255, 255, 244)
		if item.used then
			kolor = tocolor(254, 67, 67, 244)
		end
		if 1 + items.scroll <= num and shownum <= items.pagemax then
			dxDrawText(item.name, X + 80 * scaleX, items.listY - windowH/2 + starty * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, kolor, 1.0, items.font, "left", "top", false, false, true, false, false)
		    dxDrawText(item.value1, X + 270 * scaleX, items.listY - windowH/2 + starty * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, kolor, 1.0, items.font, "left", "top", false, false, true, false, false)
		    dxDrawText(item.value2, X + 360 * scaleX, items.listY - windowH/2 + starty * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, kolor, 1.0, items.font, "left", "top", false, false, true, false, false)
		    dxDrawText(item.id, X + 10 * scaleX, items.listY - windowH/2 + starty * scaleY, X + items.listW + 5 * scaleX, items.listY - windowH/2 + 30 * scaleY, kolor, 1.0, items.font, "left", "top", false, false, true, false, false)
			if items.choose == num then
				dxDrawRectangle(X + 5 * scaleX, items.listY - windowH/2 + starty * scaleY, items.listW - 10 * scaleX, 18 * scaleY, tocolor(254, 254, 254, 38), true)
			end
			shownum = shownum + 1
			starty = starty + 20
		end
	end
 
	if items.max ~= num then
		items.max = num
	end

	if items.choose > items.max then
		items.choose = items.choose - 1

		if items.scroll > 0 then
			items.scroll = items.scroll - 1
		end
	end

	--jeżeli wybrał dany przedmiot tworzymy platforme z opcjami
	if items.select == 2 then

		local where = items.choose - items.scroll
		dxDrawRectangle( X - items.menuW, items.listY - windowH/2 + 35 * scaleY + (where * 20) * scaleY, items.menuW, items.menuH, tocolor(0, 0, 0, 130), false)
		dxDrawText( (items.option == 1 and "#f47a7a" or "#FFFFFF").."Użyj przedmiot", X - items.menuW + 10 * scaleX, items.listY - windowH/2 + 45 * scaleY + (where * 20) * scaleY, 0, 0, tocolor(255, 255, 255, 255), 1.0, items.font, "left", "top", false, false, false, true)
		dxDrawText( (items.option == 2 and "#f47a7a" or "#FFFFFF").."Odłóż przedmiot", X - items.menuW + 10 * scaleX, items.listY - windowH/2 + 65 * scaleY + (where * 20) * scaleY, 0, 0, tocolor(255, 255, 255, 255), 1.0, items.font, "left", "top", false, false, false, true)
		dxDrawText( (items.option == 3 and "#f47a7a" or "#FFFFFF").."Informacje o przedmiocie", X - items.menuW + 10 * scaleX, items.listY - windowH/2 + 85 * scaleY + (where * 20) * scaleY, 0, 0, tocolor(255, 255, 255, 255), 1.0, items.font, "left", "top", false, false, false, true)
		dxDrawText( (items.option == 4 and "#f47a7a" or "#FFFFFF").."Cofnij", X - items.menuW + 10 * scaleX, items.listY - windowH/2 + 105 * scaleY + (where * 20) * scaleY, 0, 0, tocolor(255, 255, 255, 255), 1.0, items.font, "left", "top", false, false, false, true)
	end
	
end

function getItemUID()
	local num = 0
	for i, v in ipairs(items.list) do
		num = num + 1
		if num == items.choose then
			return items.list[i].id
		end
	end
end

function items.show()
	if not getElementData(localPlayer, "player:logged") then return end

	if not items.active then
		if (getTickCount() - items.lastTick) < 500 then return end

		triggerServerEvent( "items:list", localPlayer)
	else
		items.select = 1
		items.active = false
		items.lastTick = getTickCount()
	end
end
addEvent( "onItemsShow", true )
addEventHandler( "onItemsShow", localPlayer, items.show )

function items.cmd(cmd, ...)
	local comm1 = table.concat({...}, " ")
	if not getElementData(localPlayer, "player:logged") then return end
	if comm1 == 'podnies' or comm1 == 'p' then
		if items.lastSearch + 5000 > getTickCount() then
			return exports.sarp_notify:addNotify("Musisz odczekać 5 sekund przed następnym użyciem tej komendy.")
		end

		items.lastSearch = getTickCount()
		triggerServerEvent( "items:search", resourceRoot, localPlayer )
	else
		items.show()
	end
end
addCommandHandler( "p", items.cmd )

local info = {}

function info.hide( )
	removeEventHandler( "onClientGUIClick", info.button, info.hide )
	destroyElement( info.window )
	showCursor( false )
	info.active = false
end

function info.show( itemid )
	info.active = true
	showCursor( true )
	setCursorPosition (screenX/2, screenY/2)
	info.window = guiCreateWindow ( screenX/2 - 216, screenY/2 - 225, 432, 450, "Informacje o przedmiocie", false )
	guiWindowSetSizable ( info.window, false )
	info.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.87, true, info.window )
	guiGridListSetSelectionMode ( info.gridlist, 0 )
	guiGridListAddColumn ( info.gridlist, "Nazwa", 0.425 )
	guiGridListAddColumn ( info.gridlist, "Wartość", 0.425 )
	info.button = guiCreateButton ( 0.0, 0.93, 1.0, 0.07, "Zamknij", true, info.window )

	info.column = {}
	info.column[1] = {}
	info.column[1].name = "Typ przedmiotu:"
	info.column[1].value = getItemName(items.list[itemid].type)
	info.column[2] = {}
	info.column[2].name = "Nazwa przedmiotu:"
	info.column[2].value = items.list[itemid].name
	info.column[3] = {}
	info.column[3].name = "Wartość 1:"
	info.column[3].value = items.list[itemid].value1
	info.column[4] = {}
	info.column[4].name = "Wartość 2:"
	info.column[4].value = items.list[itemid].value2
	info.column[5] = {}
	info.column[5].name = "W użyciu:"
	info.column[5].value = (items.list[itemid].used and "Tak" or "Nie")

	for i, v in ipairs(info.column) do
		local row = guiGridListAddRow ( info.gridlist )
		guiGridListSetItemText ( info.gridlist, row, 1, info.column[i].name, false, false )
		guiGridListSetItemText ( info.gridlist, row, 2, info.column[i].value, false, false )
	end
	addEventHandler ( "onClientGUIClick", info.button, info.hide, false )
	
end

function items.key(button, pressed)
	if not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() and pressed == true and items.active and not isCursorShowing( ) then
		if button == "mouse_wheel_up" then
			if items.select == 1 and items.choose > 1 then
				if items.scroll + 1 == items.choose then
					items.scroll = items.scroll - 1
				end
				items.choose = items.choose - 1
			end
			if items.option > 1 then
				items.option = items.option - 1
			end
		elseif button == "mouse_wheel_down" then
			if items.select == 1 and items.choose < items.max then
				if items.choose - items.scroll > items.pagemax then
					items.scroll = items.scroll + 1
				end
				items.choose = items.choose + 1
			end
			if items.option < 4 then
				items.option = items.option + 1
			end
		elseif button == "mouse1" and getItemUID() then
			if items.select == 1 then
				items.option = 1
				items.select = 2
			elseif items.select == 2 then
				if items.option == 1 then
					triggerServerEvent( "item:use", localPlayer, getItemUID() )
				elseif items.option == 2 then
					triggerServerEvent( "item:put", localPlayer, getItemUID() )
				elseif items.option == 3 then
					info.show(items.choose)
					items.select = 1
				elseif items.option == 4 then
					items.select = 1
				end
			end
		end
	end
end

addEventHandler( "onClientKey", root, items.key )

function items.listEv(item)
	if (getTickCount() - items.lastTick) < 500 then return end
	if not item[1] then return exports.sarp_notify:addNotify("Nie posiadasz żadnego przedmiotu.") end
	items.list = item
	items.select = 1
	items.option = 1
	if not items.active then
		addEventHandler( "onClientRender", root, items.onRender )
		toggleControl ( "fire", false )
		toggleControl ( "next_weapon", false )
		toggleControl ( "previous_weapon", false )
		items.lastTick = getTickCount()
		items.active = true
	end
end

addEvent("showItems", true)
addEventHandler( "showItems", localPlayer, items.listEv )

function items.update(item)
	if items.active then
		items.list = item
		items.select = 1
		items.option = 1
	end
end

addEvent("items:update", true)
addEventHandler( "items:update", localPlayer, items.update )

local search = {}

function search.hide()
	removeEventHandler( "onClientGUIClick", search.button, search.hide )
	destroyElement( search.window )
	showCursor( false )
	search.active = false
end

function search.pick()
	local selected = guiGridListGetSelectedItems( search.gridlist )
	local item = {}
	for i, v in ipairs(selected) do
		table.insert(item, search.items[v.row + 1].id)
	end
	if #item == 0 then return end
	
	triggerServerEvent( "items:searchpick", localPlayer, item )
	search.hide()
end

function search.result(items)
	search.items = items
	showCursor( true )
	local x, y = screenX/2 - 175, screenY/2 - 225
	search.window = guiCreateWindow ( x, y, 350, 450, "Przedmioty w okolicy", false )
	guiWindowSetSizable ( search.window, false )
	search.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.8, true, search.window )
	guiGridListSetSelectionMode ( search.gridlist, 1 )
	guiGridListAddColumn ( search.gridlist, "Nazwa", 0.95 )
	search.button2 = guiCreateButton ( 0.0, 0.87, 1.0, 0.05, "Podnieś", true, search.window )
	search.button = guiCreateButton ( 0.0, 0.93, 1.0, 0.05, "Zamknij", true, search.window )
	for i, v in ipairs(items) do
		local row = guiGridListAddRow ( search.gridlist )
		guiGridListSetItemText ( search.gridlist, row, 1, v.name, false, false )
	end
	addEventHandler ( "onClientGUIClick", search.button, search.hide, false )
	addEventHandler ( "onClientGUIClick", search.button2, search.pick, false )
end

addEvent("items:search_result", true)
addEventHandler( "items:search_result", localPlayer, search.result )

bindKey( "p", "down", items.show )
function items.stop()
	unbindKey( "p", "down", items.cmd )
end

addEventHandler( "onClientResourceStop", getResourceRootElement(), items.stop )