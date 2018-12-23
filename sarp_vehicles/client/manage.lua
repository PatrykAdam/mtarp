--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)

local manage = {}
manage.W, manage.H = 717 * scaleX, 461 * scaleY
manage.X, manage.Y = (screenX - manage.W)/2, (screenY - manage.H)/2
manage.scrollW, manage.scrollH = 10 * scaleX, manage.H
manage.scrollX, manage.scrollY = manage.X - manage.scrollW, manage.Y
manage.imageW, manage.imageH = 204 * scaleX, 125 * scaleY
manage.lineW, manage.lineH = manage.W - 40 * scaleX, 1
manage.font = {}
manage.font[1] = dxCreateFont( "assets/HelveticaNeue-Bold.ttf", 16 * scaleX )
manage.font[2] = dxCreateFont( "assets/HelveticaNeue-Bold.ttf", 12 * scaleX )
manage.font[3] = dxCreateFont( "assets/HelveticaNeue-Bold.ttf", 13 * scaleX )
manage.fontSize = {}
manage.clickTick = getTickCount()
manage.fontSize[1] = dxGetFontHeight( 1.0, manage.font[1] )
manage.fontSize[2] = dxGetFontHeight( 1.0, manage.font[2] )
manage.fontSize[3] = dxGetFontHeight( 1.0, manage.font[3] )
manage.fontSize[4] = dxGetTextWidth("INFORMACJE", 1.0, manage.font[3])
manage.buttons = {
	{"INFORMACJE", manage.X + manage.W - manage.fontSize[4] - 10 * scaleX, 15 * scaleX},
	{"SPAWN", manage.X + manage.W - manage.fontSize[4] - 10 * scaleX, 15 * scaleX + manage.fontSize[3]},
	{"NAMIERZ", manage.X + manage.W - manage.fontSize[4] - 10 * scaleX, 15 * scaleX + manage.fontSize[3] * 2},
	{"OFERUJ", manage.X + manage.W - manage.fontSize[4] - 10 * scaleX, 15 * scaleX + manage.fontSize[3] * 3},
	{"DODATKI", manage.X + manage.W - manage.fontSize[4] - 10 * scaleX, 15 * scaleX + manage.fontSize[3] * 4},
	{"UDOSTĘPNIJ", manage.X + manage.W - manage.fontSize[4] - 10 * scaleX, 15 * scaleX + manage.fontSize[3] * 5}
}
manage.active = false
manage.lastTick = 0
manage.scroll = 1
manage.animTime = 500

function manage.onRender()
	--animacja
	local Y
	local progress = (getTickCount() - manage.lastTick) / manage.animTime
	if manage.active == true then
		Y = interpolateBetween( screenY + manage.H, 0, 0,
									 manage.Y, 0, 0,
									 progress, "Linear" )

		if progress > 1 then
			showCursor( true )
		end

	else
		Y = interpolateBetween( manage.Y, 0, 0,
									 screenY + manage.H, 0, 0,
									 progress, "Linear" )

		if progress > 1 then
			removeEventHandler( "onClientRender", root, manage.onRender )
			removeEventHandler( "onClientClick", root, manage.onClick )
			removeEventHandler( "onClientKey", root, manage.onKey )
			manage.list = nil
			return
		end
	end

	dxDrawRectangle( manage.X, Y, manage.W, manage.H, tocolor(37, 37, 37, 150))
	
	if #manage.list > 3 then
		dxDrawRectangle( manage.scrollX, Y, manage.scrollW, manage.scrollH, tocolor( 163, 162, 160, 255 ) )
		local H = manage.scrollH - 5 * scaleX
		dxDrawRectangle( manage.scrollX + 2.5 * scaleX, Y + 2.5 * scaleX + H * (((#manage.list - 3) / #manage.list) * ((manage.scroll - 1) / (#manage.list - 3))), manage.scrollW - 5 * scaleX, (#manage.list > 3) and H - (H * ((#manage.list - 3) / #manage.list)) or H, tocolor( 64, 64, 64, 255 ) )
	end

	--rysujemy pojazdy
	for i = 0, 2 do
		local id = manage.scroll + i
		if manage.list[id] then
			dxDrawImage( manage.X + 20 * scaleX, Y + 15 * scaleX + (30 * scaleY + manage.imageH) * i, manage.imageW, manage.imageH, "assets/"..manage.list[id].model..".jpg" )
			dxDrawText( getVehicleNameFromModel(manage.list[id].model), manage.X + manage.imageW + 30 * scaleX, Y + 15 * scaleX + (30 * scaleY + manage.imageH) * i, 0, 0, tocolor( 128, 47, 53 ), 1.0, manage.font[1] )
			dxDrawText( string.format("UID: %d", manage.list[id].id), manage.X + manage.imageW + 30 * scaleX, Y + 15 * scaleX + manage.fontSize[1] + (30 * scaleY + manage.imageH) * i, 0, 0, tocolor( 255, 255, 255 ), 1.0, manage.font[2] )
			dxDrawText( string.format("Stan pojazdu: %dHP\nPaliwo: %dL\nZespawnowany: %s", manage.list[id].hp, manage.list[id].fuel, isElement(manage.list[id].mtaID) and "Tak" or "Nie"), manage.X + manage.imageW + 30 * scaleX, Y + 30 * scaleX + manage.fontSize[1] + manage.fontSize[2] + (30 * scaleY + manage.imageH) * i, 0, manage.Y + 22 * scaleX + manage.imageH, tocolor( 158, 158, 155 ), 1.0, manage.font[2] )

			for j, g in ipairs(manage.buttons) do
				local name, bX, bY = unpack(g)
				dxDrawText( name, bX, Y + bY + (30 * scaleY + manage.imageH) * i, 0, 0, tocolor( 255, 255, 255 ), 1.0, manage.font[3] )
			end

			if i ~= 0 then
				dxDrawRectangle( manage.X + 20 * scaleX, Y + (15 * scaleX + 15 * scaleY + manage.imageH) * i, manage.lineW, manage.lineH, tocolor(163, 162, 160))
			end
		end
	end
end

function manage.hide()
	manage.lastTick = getTickCount()
	manage.active = false

	if isElement(manage.window) then
		destroyElement( manage.window )
	end

	showCursor( false )
end

function manage.show(vehicle, update)
	if (getTickCount() - manage.lastTick) < manage.animTime then return end

	manage.list = vehicle

	if manage.active and not update then
		manage.hide()
	elseif not manage.active then
		manage.lastTick = getTickCount()
		manage.active = true
		addEventHandler( "onClientRender", root, manage.onRender )
		addEventHandler( "onClientClick", root, manage.onClick )
		addEventHandler( "onClientKey", root, manage.onKey )
	end
end

addEvent("playerVehicle", true)
addEventHandler( "playerVehicle", localPlayer, manage.show )

function manage.onClick(button, state, X, Y)
	if manage.clickTick + 1000 > getTickCount() then return end

	if state == "down" then
		if button == "left" then
			for j = 0, 2 do
				for k, g in ipairs(manage.buttons) do
					local W = dxGetTextWidth( g[1], 1.0, manage.font[3] )
					if X >= g[2] and X <= g[2] + W and Y >= manage.Y + g[3] + (30 * scaleY + manage.imageH) * j and Y <= manage.Y + g[3] + manage.fontSize[3] + (30 * scaleY + manage.imageH) * j then
						local id = manage.scroll + j
						if k == 1 then
							manage.info(manage.list[id], true)
						elseif k == 2 then
							triggerServerEvent( "vehlist:spawn", localPlayer, manage.list[id].id )
						elseif k == 3 then
							local vehicle = manage.list[id]
							if not manage.blip then
								if not vehicle.mtaID then
									return exports.sarp_notify:addNotify("Najpierw musisz zespawnować pojazd, aby go namierzyć.")
								end

								local X, Y, Z = getElementPosition( vehicle.mtaID )
								manage.blip = createBlip( X, Y, Z, 55 )
								exports.sarp_notify:addNotify("Twój pojazd został zaznaczony na radarze.")
							else
								destroyElement( manage.blip )
								manage.blip = false
								exports.sarp_notify:addNotify("Namierzanie pojazdu zostało wyłączone.")
							end
						elseif k == 4 then
							return exports.sarp_notify:addNotify("Użyj: /o [ID gracza] pojazd (będąc w pojeździe)")
						elseif k == 5 then
							triggerServerEvent( "vehicleTuning", localPlayer, manage.list[id].id)
						elseif k == 6 then
							triggerServerEvent( "showPlayerDynamicGroup", localPlayer, 1, manage.list[id].id)
						end

						manage.clickTick = getTickCount()
					end
				end
			end
		end
	end
end

function manage.onKey(button, press)
	if press == true then
		if button == 'mouse_wheel_down' then
			if manage.scroll <= #manage.list - 3 then
				manage.scroll = manage.scroll + 1
			end
		end
		if button == 'mouse_wheel_up' then
			if manage.scroll > 1 then
				manage.scroll = manage.scroll - 1
			end
		end
	end
end

local info = {}

function manage.hideInfo(cursor)
	removeEventHandler( "onClientGUIClick", info.button, manage.hideInfo )
	destroyElement( info.window )
	showCursor( cursor )
	info.active = false
end

function manage.info(vehicle, cursor)
	if info.active then return end
	info.active = true
	showCursor( true )
	info.window = guiCreateWindow ( screenX/2 - 216, screenY/2 - 225, 432, 450, "Informacje o pojeździe", false )
	guiWindowSetSizable ( info.window, false )
	info.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.87, true, info.window )
	guiGridListSetSelectionMode ( info.gridlist, 0 )
	guiGridListAddColumn ( info.gridlist, "Nazwa", 0.425 )
	guiGridListAddColumn ( info.gridlist, "Wartość", 0.425 )
	info.button = guiCreateButton ( 0.0, 0.93, 1.0, 0.07, "Zamknij", true, info.window )

	info.column = {}
	info.column[1] = {}
	info.column[1].name = "UID pojazdu:"
	info.column[1].value = vehicle.id
	info.column[2] = {}
	info.column[2].name = "Model pojazdu:"
	info.column[2].value = string.format("%s (%d)", getVehicleNameFromModel( vehicle.model ), vehicle.model)
	info.column[3] = {}
	info.column[3].name = "Przebieg:"
	info.column[3].value = string.format("%d KM", isElement(vehicle.mtaID) and getElementData(vehicle.mtaID, "vehicle:mileage") or vehicle.mileage)
	info.column[4] = {}
	info.column[4].name = "Kolor 1:"
	info.column[4].value = string.format("rgb(%d, %d, %d)", unpack(vehicle.color1))
	info.column[5] = {}
	info.column[5].name = "Kolor 2:"
	info.column[5].value = string.format("rgb(%d, %d, %d)", unpack(vehicle.color2))
	info.column[6] = {}
	info.column[6].name = "Typ właściciela:"
	if vehicle.ownerType == 0 then
		info.column[6].value = "Żaden"
	elseif vehicle.ownerType == 1 then
		info.column[6].value = "Gracz"
	else
		info.column[6].value = "Grupa"
	end
	info.column[7] = {}
	info.column[7].name = "Właściciel:"
	if vehicle.ownerType == 0 then
		info.column[7].value = "Żaden"
	elseif vehicle.ownerType == 1 then
		info.column[7].value = vehicle.ownerID
	else
		info.column[7].value = vehicle.groupName
	end
	info.column[8] = {}
	info.column[8].name = "Tablica rejestracyjna:"
	info.column[8].value = vehicle.plate
	info.column[9] = {}
	info.column[9].name = "HP pojazdu:"
	info.column[9].value = string.format("%0.1f", isElement(vehicle.mtaID) and getElementHealth( vehicle.mtaID ) or vehicle.hp)
	info.column[10] = {}
	info.column[10].name = "Paliwo:"
	info.column[10].value = string.format("%d/%d", vehicle.fuel, getVehicleMaxFuel( vehicle.model))


	for i, v in ipairs(info.column) do
		local row = guiGridListAddRow ( info.gridlist )
		guiGridListSetItemText ( info.gridlist, row, 1, info.column[i].name, false, false )
		guiGridListSetItemText ( info.gridlist, row, 2, info.column[i].value, false, false )
	end
	addEventHandler ( "onClientGUIClick", info.button, function() manage.hideInfo(cursor) end, false )
end

addEvent('vehicle:info', true)
addEventHandler( 'vehicle:info', localPlayer, manage.info )

function manage.tuning(model, tuning)
	if isElement(manage.window) then return end
	manage.window = guiCreateWindow((screenX - 340) / 2, (screenY - 292) / 2, 340, 292, string.format("Wyposażenie pojazdu %s", getVehicleNameFromModel( model )), false)
  guiWindowSetSizable(manage.window, false)

  manage.gridlist = guiCreateGridList(0.03, 0.09, 0.94, 0.81, true, manage.window)
  guiGridListAddColumn(manage.gridlist, "Nazwa", 0.9)
  manage.button = guiCreateButton(0.06, 0.90, 0.89, 0.06, "Zamknij", true, manage.window)

  addEventHandler( "onClientGUIClick", manage.button, function()
  	if isElement(manage.window) then
  		destroyElement( manage.window )
  	end
  end)

  for i, v in ipairs(tuning) do
  	local row = guiGridListAddRow( manage.gridlist )
  	guiGridListSetItemText( manage.gridlist, row, 1, v.name, false, false )
  end
end

addEvent('vehicleTuning', true)
addEventHandler( 'vehicleTuning', root, manage.tuning )

local tuning = {}

function manage.tuningSelect(playerid2, vehicle)
	if isElement(tuning.window) or not isElement(vehicle) then return end
	showCursor( true )
	tuning.window = guiCreateWindow((screenX - 300) / 2, (screenY - 221) / 2, 300, 221, string.format("Wyposażenie pojazdu %s", getVehicleNameFromModel( getElementModel( vehicle ) )), false)
  guiWindowSetSizable(tuning.window, false)

  tuning.gridlist = guiCreateGridList(0.04, 0.11, 0.91, 0.73, true, tuning.window)
  guiGridListAddColumn(tuning.gridlist, "Nazwa", 0.9)
  tuning.button = {}
  tuning.button[1] = guiCreateButton(0.08, 0.86, 0.37, 0.09, "Demontaż części", true, tuning.window)
  tuning.button[2] = guiCreateButton(0.56, 0.86, 0.37, 0.09, "Zamknij", true, tuning.window)

  local tuningSel = getElementData(vehicle, "vehicle:tuning")
  for i, v in ipairs(tuningSel) do
  	local row = guiGridListAddRow( tuning.gridlist )
  	guiGridListSetItemText( tuning.gridlist, row, 1, v.name, false, false )
  end

  addEventHandler( "onClientGUIClick", tuning.button[2], function()
  	if isElement(tuning.window) then
  		destroyElement( tuning.window )
  		showCursor( false )
  	end
  end)

  addEventHandler( "onClientGUIClick", tuning.button[1], function()
  	if isElement(tuning.window) then
  		local id = guiGridListGetSelectedItem ( tuning.gridlist ) + 1

  		if not tuningSel[id] then
  			return exports.sarp_notify:addNotify("Musisz coś zaznaczyć.")
  		end

  		triggerServerEvent( "createOffer", resourceRoot, localPlayer, playerid2, 15, 50, {groupid = getElementData(localPlayer, "player:duty"), vehid = vehicle, tune_id = id})
  		destroyElement( tuning.window )
  		showCursor( false )
  	end
  end)
end

addEvent('vehicleTuningSelect', true)
addEventHandler( 'vehicleTuningSelect', root, manage.tuningSelect )