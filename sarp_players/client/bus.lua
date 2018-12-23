--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local bus  = {}
local busList = {}

function bus.load()
	local file = xmlLoadFile( "busList.xml" )
	if not file then return end
	local child = xmlNodeGetChildren(file)

	for i, v in ipairs(child) do
		local pX, pY, pZ, name = xmlNodeGetAttribute( v, "posX" ), xmlNodeGetAttribute( v, "posY" ), xmlNodeGetAttribute( v, "posZ" ), xmlNodeGetValue( v )
		table.insert(busList, {posX = pX, posY = pY, posZ = pZ, name = name})
	end
	xmlUnloadFile(file)
end

addEventHandler( "onClientResourceStart", resourceRoot, bus.load )

function bus.searchStation()
	local pX, pY, pZ = getElementPosition( localPlayer )
	for i, v in ipairs(busList) do
		if getDistanceBetweenPoints3D( pX, pY, pZ, v.posX, v.posY, v.posZ ) < 5.0 then
			return i
		end
	end
	return false
end

function bus.calcDistance(busID, target)
	local distance = getDistanceBetweenPoints2D( busList[busID].posX, busList[busID].posY, busList[target].posX, busList[target].posY ) + 100
	local price = math['floor'](distance/100)
	local time = math['floor'](string.format("%.02f", distance/600) * 60)

	if time < 30 then
		time = 60
	end

	return price, time
end

function bus.hide()
	removeEventHandler( "onClientGUIClick", bus.button[1], bus.buyTicket, false )
	removeEventHandler( "onClientGUIClick", bus.button[2], bus.hide, false )
	bus.active = false
	destroyElement( bus.window )
	showCursor( false )
end

function bus.onRender()
	dxDrawImage( 0, 0, screenX, screenY, "assets/background.jpg" )
	dxDrawText( string.format("Do końca podróży pozostało: %d min i %d sekund", bus.time/60, bus.time % 60), 1, 80 * scaleY + 1, screenX+1, screenY+1, tocolor(0, 0, 0), 2.0, "default-bold", "center", "top" )
	dxDrawText( string.format("Do końca podróży pozostało: %d min i %d sekund", bus.time/60, bus.time % 60), 0, 80 * scaleY, screenX, screenY, tocolor(255, 255, 255), 2.0, "default-bold", "center", "top" )
end

function bus.startTravel(busID, target)
	local price, time = bus.calcDistance(busID, target)
	bus.travel = true
	bus.time = time
	setElementData(localPlayer, "busTravel", true)
	setElementInterior( localPlayer, 1 )
	setCameraMatrix( 0, 0, 0 )
	showChat( false )
	triggerServerEvent( "main:me", localPlayer, "wsiada do autobusu." )
	addEventHandler( "onClientRender", root, bus.onRender )

	bus.timer = setTimer(function(target)
		bus.time = bus.time - 1
		if bus.time <= 0 then
			fadeCamera( true )
			showChat( true )
			removeEventHandler( "onClientRender", root, bus.onRender )
			setElementData(localPlayer, "busTravel", false)
			setCameraTarget( localPlayer )
			killTimer( bus.timer )
			setElementInterior( localPlayer, 0 )
			setElementPosition( localPlayer, busList[target].posX, busList[target].posY, busList[target].posZ )
			triggerServerEvent( "main:me", localPlayer, "wysiada z autobusu." )
		end
	end, 1000, 0, target)
end

function bus.buyTicket()
	local id = guiGridListGetItemData( bus.gridlist, guiGridListGetSelectedItem( bus.gridlist ), 1 )

	if not id then
		return exports.sarp_notify:addNotify("Nie wybrałeś żadnego przystanku.")
	end

	local price = bus.calcDistance(bus.busID, id)
	
	if getElementData(localPlayer, "player:money") < price then
		return exports.sarp_notify:addNotify("Nie posiadasz wystarczającej ilości gotówki na zakup biletu.")
	end

	triggerServerEvent( "buyTicket", localPlayer, price )
	bus.startTravel(bus.busID, id)
	bus.hide()
end

function bus.cmd()
	if not getElementData(localPlayer, "player:logged") then return end

	local busID = bus.searchStation()

	if not busID then
		return exports.sarp_notify:addNotify("Nie znaleziono żadnego przystanku w pobliżu.")
	end

	if #busList <= 1 then
		return exports.sarp_notify:addNotify("Wczytane zostało zbyt mało przystanków, zgłoś to administracji.")
	end

	if bus.active then bus.hide() end
	showCursor( true )
	bus.active = true
	bus.busID = busID
	bus.window = guiCreateWindow((screenX - 316) / 2, (screenY - 281) / 2, 316, 281, "Przystanek autobusowy", false)
  guiWindowSetSizable(bus.window, false)

  bus.gridlist = guiCreateGridList(0.03, 0.09, 0.94, 0.75, true, bus.window)
  guiGridListAddColumn(bus.gridlist, "Nazwa", 0.4)
  guiGridListAddColumn(bus.gridlist, "Cena", 0.2)
  guiGridListAddColumn(bus.gridlist, "Czas podróży", 0.3)
  bus.button = {}
  bus.button[1] = guiCreateButton(0.05, 0.88, 0.36, 0.06, "Kup bilet", true, bus.window)
  bus.button[2] = guiCreateButton(0.59, 0.88, 0.36, 0.06, "Anuluj", true, bus.window) 

  for i, v in ipairs(busList) do
  	if i ~= busID then
	  	local row = guiGridListAddRow( bus.gridlist )
	  	local price, time = bus.calcDistance(busID, i)
	  	guiGridListSetItemText( bus.gridlist, row, 1, v.name, false, false )
	  	guiGridListSetItemText( bus.gridlist, row, 2, price.."$", false, false )
	  	guiGridListSetItemText( bus.gridlist, row, 3, string.format("%02d:%02d", time/60, time % 60), false, false )
	  	guiGridListSetItemData( bus.gridlist, row, 1, i )
	  end
	end

	addEventHandler( "onClientGUIClick", bus.button[1], bus.buyTicket, false )
	addEventHandler( "onClientGUIClick", bus.button[2], bus.hide, false )
end

addCommandHandler( "bus", bus.cmd )