--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local bots = {}

bots.pickup = {
	{x = 1128.815430, y = -1455.769531, z = 15.796875, dimension = 0, interior = 0, type = 1, element = false},
	{x = 1130.348633, y = -1454.077148, z = 15.796875, dimension = 0, interior = 0, type = 1, element = false}
}

bots.ped = {
	{x = 1128.881836, y = -1454.122070, z = 15.796875, rotate = 180, dimension = 0, interior = 0, skin = 150, type = 1, name = "Jessica Verter", element = false},
	{x = 1130.679688, y = -1452.016602, z = 15.796875, rotate = 180, dimension = 0, interior = 0, skin = 210, type = 1, name = "Mark Smith", element = false}
}

local botsData = {}

function bots.damage()
	cancelEvent()
end

function bots.run()
	for i, v in ipairs(bots.pickup) do
		v.element = createMarker( v.x, v.y, v.z, "corona", 1.0, 255, 255, 255, 0)
		setElementDimension( v.element, v.dimension )
		setElementInterior( v.element, v.interior)

		setElementData(v.element, "type:govBOT", true)
		setElementData(v.element, "guiType", v.type)
	end

	for i, v in ipairs(bots.ped) do
		v.element = createPed( v.skin, v.x, v.y, v.z )
		setElementRotation( v.element, 0, 0, v.rotate )
		setElementDimension( v.element, v.dimension )
		setElementInterior( v.element, v.interior)
		setElementData( v.element, "ped:name", v.name)
		setElementFrozen( v.element, true )
		addEventHandler( "onClientPedDamage", v.element, bots.damage )

		setElementData( v.element, "type:ped", true)
	end
end

addEvent('runGOVbots', true)
addEventHandler('runGOVbots', root, bots.run)


function bots.vehiclePLATE()
	botsData.window[2] = guiCreateWindow((screenX - 274) / 2, (screenY - 92) / 2, 274, 92, "Zarejestrowanie pojazdu", false)
    guiWindowSetSizable(botsData.window[2], false)

    botsData.label = guiCreateLabel(0.04, 0.30, 0.28, 0.20, "UID pojazdu:", true, botsData.window[2])
    botsData.edit = guiCreateEdit(0.31, 0.27, 0.45, 0.23, "", true, botsData.window[2])

    botsData.button[3] = guiCreateButton(0.03, 0.66, 0.39, 0.23, "Zatwierdź", true, botsData.window[2])
    botsData.button[4] = guiCreateButton(0.57, 0.66, 0.39, 0.23, "Anuluj", true, botsData.window[2])

    addEventHandler( "onClientGUIClick", botsData.button[3], function()
    	local uid = tonumber(guiGetText( botsData.edit ))

    	if not uid then
    		return exports.sarp_notify:addNotify("Nieprawidłowe UID pojazdu lub jego brak.")
    	end

    	triggerServerEvent( "documentGOV", localPlayer, 3, uid)
    	bots.hide()
    end, false)

    addEventHandler( "onClientGUIClick", botsData.button[4], function()
    	destroyElement( botsData.window[2] )
    end, false)
end

function bots.hide()
	if isElement(botsData.window[1]) then
		destroyElement( botsData.window[1] )

		if isElement(botsData.window[2]) then
			destroyElement( botsData.window[2] )
		end

		showCursor( false )
		botsData = {}
	end
end

function bots.showGUI(player, dimension)
	if player ~= localPlayer or not dimension then return end

	if getElementData(source, "type:govBOT") then
		if getElementData(source, "guiType") == 1 then
			if botsData.window and isElement(botsData.window[1]) then return end

			showCursor(true)
			botsData.window = {}
			botsData.window[1] = guiCreateWindow((screenX - 336) / 2, (screenY - 191) / 2, 336, 191, "Urzędnik", false)
		    guiWindowSetSizable(botsData.window[1], false)

		    botsData.gridlist = guiCreateGridList(0.03, 0.14, 0.94, 0.64, true, botsData.window[1])
		    guiGridListAddColumn(botsData.gridlist, "Usługa", 0.6)
		    guiGridListAddColumn(botsData.gridlist, "Cena", 0.3)
		    for i = 1, 3 do
		        guiGridListAddRow(botsData.gridlist)
		    end
		    guiGridListSetItemText(botsData.gridlist, 0, 1, "Prawo jazdy", false, false)
		    guiGridListSetItemText(botsData.gridlist, 0, 2, "400$", false, false)
		    guiGridListSetItemText(botsData.gridlist, 1, 1, "Dowód osobisty", false, false)
		    guiGridListSetItemText(botsData.gridlist, 1, 2, "100$", false, false)
		    guiGridListSetItemText(botsData.gridlist, 2, 1, "Rejestracja pojazdu", false, false)
		    guiGridListSetItemText(botsData.gridlist, 2, 2, "100$", false, false)
		    guiGridListSetSortingEnabled ( botsData.gridlist, false )

		    botsData.button = {}
		    botsData.button[1] = guiCreateButton(0.07, 0.83, 0.35, 0.12, "Wybierz", true, botsData.window[1])
		    botsData.button[2] = guiCreateButton(0.59, 0.83, 0.35, 0.12, "Zamknij", true, botsData.window[1])

		    addEventHandler( "onClientGUIClick", botsData.button[1], function()
		    	local id = guiGridListGetSelectedItem ( botsData.gridlist) + 1
		    	if id == 0 then return end

		    	if id == 3 then
		    		return bots.vehiclePLATE()
		    	end

		    	triggerServerEvent( "documentGOV", localPlayer, id )
		    	bots.hide()
		    end, false)

		    addEventHandler( "onClientGUIClick", botsData.button[2], bots.hide, false)

		elseif getElementData(source, "guiType") == 2 then
		
		end
	end
end

addEventHandler( "onClientMarkerHit", root, bots.showGUI )

function bots.disable()
	for i, v in ipairs(bots.pickup) do
		if v.type ~= 2 and isElement( v.element ) then
			destroyElement( v.element )
		end
	end

	for i, v in ipairs(bots.ped) do
		if v.type ~= 2 and isElement( v.element ) then
			removeEventHandler( "onClientPedDamage", v.element, bots.damage )
			destroyElement( v.element )
		end
	end
end

addEvent('disableGOVbots', true)
addEventHandler('disableGOVbots', root, bots.disable)