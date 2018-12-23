local ammo = {}
ammo.magazineid = nil
ammo.active = false

function ammo.onStart()
	setAmbientSoundEnabled( "gunfire", false )
end

addEventHandler( "onClientResourceStart", resourceRoot, ammo.onStart )

function ammo.event(weaponID)
	if localPlayer == source and getElementData(localPlayer, "player:logged") then
		triggerServerEvent( "saveAmmo", localPlayer, weaponID)
	end
end

addEventHandler( "onClientPlayerWeaponFire", root, ammo.event )

-- Przeładowywanie broni
function showWeaponsHandler(magid, weaponlist, weaponid)
	if ammo.active then return end
	ammo.active = true
	ammo.magazineid = magid
	ammo.items = weaponlist
	showCursor( true )
	local x, y = screenX/2 - 175, screenY/2 - 225
	ammo.window = guiCreateWindow ( x, y, 350, 450, "Wybierz broń, którą chcesz przeładować.", false )
	guiWindowSetSizable ( ammo.window, false )
	ammo.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.8, true, ammo.window )
	guiGridListSetSelectionMode ( ammo.gridlist, 1 )
	guiGridListAddColumn ( ammo.gridlist, "ID", 0.425 )
	guiGridListAddColumn ( ammo.gridlist, "Nazwa", 0.425 )
	ammo.button2 = guiCreateButton ( 0.0, 0.87, 1.0, 0.05, "Wybierz", true, ammo.window )
	ammo.button = guiCreateButton ( 0.0, 0.93, 1.0, 0.05, "Anuluj", true, ammo.window )
	for i, item in ipairs(ammo.items) do
		if item.value1 == weaponid then
			local row = guiGridListAddRow ( ammo.gridlist )
			guiGridListSetItemText ( ammo.gridlist, row, 1, item.id, false, false )
			guiGridListSetItemText ( ammo.gridlist, row, 2, item.name, false, false )
		end
	end
	addEventHandler ( "onClientGUIClick", ammo.button, ammo.hide, false )
	addEventHandler ( "onClientGUIClick", ammo.button2, ammo.load, false )
end

function ammo.hide()
	showCursor( false )
	ammo.active = false
	removeEventHandler ( "onClientGUIClick", ammo.button, ammo.hide, false )
	removeEventHandler ( "onClientGUIClick", ammo.button2, ammo.load, false )
	destroyElement( ammo.window )
end

function ammo.load()
	local itemid = guiGridListGetItemText(ammo.gridlist, guiGridListGetSelectedItem(ammo.gridlist))
	if ammo.magazineid ~= nil then
		ammo.hide()
		triggerServerEvent( "loadWeaponAmmo", localPlayer, itemid, ammo.magazineid )
	end
end
addEvent( "showAvailableWeapons", true )
addEventHandler( "showAvailableWeapons", localPlayer, showWeaponsHandler )

function ammo.block()
    cancelEvent()
end

addEventHandler("onClientPlayerStealthKill", localPlayer, ammo.block)

function ammo.damage( attacker, weapon )
	if weapon == 41 or weapon == 42 then
		cancelEvent()
	end
end
addEventHandler ( "onClientPedDamage", localPlayer, ammo.damage )