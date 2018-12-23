--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)
local admin = {}
admin.createStep = 0
admin.window = {}
admin.button = {}

function admin.confirmDepth()
	local depth = tonumber(guiGetText( admin.edit ))

	if not depth or depth < 0 then
		return exports.sarp_notify:addNotify("Nic nie wpisałeś w wyznaczone pole.")
	end

	admin.pDepth = depth
	removeEventHandler( "onClientGUIClick", admin.button[1], admin.confirmDepth, false )
	destroyElement( admin.window[1] )
	showCursor( false )
	local pX, pY, pZ, pW, pD, pH = admin.pStart[1], admin.pStart[2], admin.pStart[3] - 1.0, admin.pEnd[1] - admin.pStart[1], admin.pEnd[2] - admin.pStart[2], admin.pDepth
	if admin.pStart[1] > admin.pEnd[1] then
		pX = admin.pEnd[1]
		pW = admin.pStart[1] - admin.pEnd[1]
	end

	if admin.pStart[2] > admin.pEnd[2] then
		pY = admin.pEnd[2]
		pD = admin.pStart[2] - admin.pEnd[2]
	end

	local dimension = getElementDimension( localPlayer )
	local interior = getElementInterior( localPlayer )

	admin.cords = {pX, pY, pZ, dimension, interior, pW, pD, pH}

	admin.element = createColCuboid( pX, pY, pZ, pW, pD, pH )
	setElementDimension( admin.element, dimension )
	setElementInterior( admin.element, interior )
	admin.createStep = 3
end

function admin.createDepth()
	showCursor( true )
	admin.window[1] = guiCreateWindow((screenX - 215) / 2, (screenY - 82) / 2, 215, 82, "Tworzenie strefy", false)
  guiWindowSetSizable(admin.window[1], false)

  admin.label = guiCreateLabel(0.04, 0.33, 0.93, 0.28, "Wysokość strefy:", true, admin.window[1])
  admin.edit = guiCreateEdit(0.50, 0.33, 0.46, 0.23, "", true, admin.window[1])
  admin.button[1] = guiCreateButton(0.06, 0.68, 0.87, 0.20, "Dalej", true, admin.window[1])

  addEventHandler( "onClientGUIClick", admin.button[1], admin.confirmDepth, false )
end

function admin.createRender()
	if admin.createStep == 1 then
		dxDrawText( "Naciśnij Enter w miejscu gdzie ma być początek strefy.", 0, screenY - 100 * scaleY, screenX, 0, tocolor( 255, 255, 255 ), 1.0, "default-bold", "center", "top" )
	elseif admin.createStep == 2 then
		dxDrawText( "Naciśnij Enter w miejscu gdzie ma być koniec strefy.", 0, screenY - 100 * scaleY, screenX, 0, tocolor( 255, 255, 255 ), 1.0, "default-bold", "center", "top" )
	elseif admin.createStep == 3 then
		dxDrawText( "Utworzona została strefa widoczna tylko dla Ciebie. (/showcol) Aby ją zatwierdzić naciśnij 'Enter'.", 0, screenY - 100 * scaleY, screenX, 0, tocolor( 255, 255, 255 ), 1.0, "default-bold", "center", "top" )
	end
end

function admin.createKey(button, press)
	if press == true then
		if button == 'enter' then
			if admin.createStep == 1 then
				admin.pStart = {getElementPosition( localPlayer )}
				admin.createStep = 2
			elseif admin.createStep == 2 then
				admin.pEnd = {getElementPosition( localPlayer )}
				admin.createDepth()
			elseif admin.createStep == 3 then
				destroyElement( admin.element )
				triggerServerEvent( "confirmZone", localPlayer, admin.cords )
				admin.createStep = 0
				removeEventHandler( "onClientRender", root, admin.createRender )
				removeEventHandler( "onClientKey", root, admin.createKey )
			end
		end
	end
end

function admin.create()
	if admin.createStep ~= 0 then return end
	addEventHandler( "onClientRender", root, admin.createRender )
	addEventHandler( "onClientKey", root, admin.createKey )
	admin.createStep = 1
end

addEvent('createZone', true)
addEventHandler( 'createZone', root, admin.create )

function admin.findZone()
	local findList = {}
	for i, v in ipairs(getElementsByType( "colshape", nil, true )) do
		if getElementType(v, "isZone") and isElementWithinColShape( localPlayer, v ) then
			table.insert(findList, getElementData(v, "zoneID"))
		end
	end

	if #findList == 0 then
		return exports.sarp_notify:addNotify("Nie znaleziono żadnej strefy w pobliżu.")
	end

	exports.sarp_notify:addNotify("Strefy, w których aktualnie się znajdujesz mają ID: "..table.concat(findList, ", "))
end

addEvent('findZone', true)
addEventHandler( 'findZone', root, admin.findZone )

function admin.editHide()
	removeEventHandler( "onClientGUIClick", admin.button[2], admin.editSave, false )
  removeEventHandler( "onClientGUIClick", admin.button[3], admin.editHide, false )
	admin.editactive = false
	destroyElement( admin.window[2] )
	showCursor( false )
end

function admin.editSave()
	local perm = 0

	perm = perm + (guiCheckBoxGetSelected( admin.checkbox[1] ) and 1 or 0)
	perm = perm + (guiCheckBoxGetSelected( admin.checkbox[2] ) and 2 or 0)
	perm = perm + (guiCheckBoxGetSelected( admin.checkbox[3] ) and 4 or 0)
	perm = perm + (guiCheckBoxGetSelected( admin.checkbox[4] ) and 8 or 0)
	perm = perm + (guiCheckBoxGetSelected( admin.checkbox[5] ) and 16 or 0)

	triggerServerEvent( "saveZone", localPlayer, admin.zoneID, perm)
	admin.editHide()
end

function admin.editEx(zoneID, perm)
	if admin.editactive then admin.editHide() end
	admin.editactive = true
	showCursor( true )
	admin.zoneID = zoneID
	admin.window[2] = guiCreateWindow((screenX- 350) / 2, (screenY - 162) / 2, 350, 162, "Edycja strefy (UID: ".. zoneID ..")", false)
  guiWindowSetSizable(admin.window[2], false)
  admin.scrollpane = guiCreateScrollPane(10, 26, 330, 107, false, admin.window[2])
  admin.checkbox = {}
  admin.checkbox[1] = guiCreateCheckBox(6, 7, 314, 22, "Tworzenie obiektów", exports.sarp_main:bitAND(perm, 1) ~= 0 and true or false, false, admin.scrollpane)
  admin.checkbox[2] = guiCreateCheckBox(6, 29, 314, 22, "Stacja benzynowa (/tankuj)", exports.sarp_main:bitAND(perm, 2) ~= 0 and true or false, false, admin.scrollpane)
  admin.checkbox[3] = guiCreateCheckBox(6, 51, 314, 22, "Zablokowanie boomboxów", exports.sarp_main:bitAND(perm, 4) ~= 0 and true or false, false, admin.scrollpane)
  admin.checkbox[4] = guiCreateCheckBox(6, 73, 314, 22, "Teren gangu", exports.sarp_main:bitAND(perm, 8) ~= 0 and true or false, false, admin.scrollpane)
  admin.checkbox[5] = guiCreateCheckBox(6, 95, 314, 22, "Komendy grupowe", exports.sarp_main:bitAND(perm, 16) ~= 0 and true or false, false, admin.scrollpane)
  admin.button[2] = guiCreateButton(18, 136, 138, 16, "Zapisz strefę", false, admin.window[2])
  admin.button[3] = guiCreateButton(192, 137, 138, 15, "Anuluj edycje", false, admin.window[2])

  addEventHandler( "onClientGUIClick", admin.button[2], admin.editSave, false )
  addEventHandler( "onClientGUIClick", admin.button[3], admin.editHide, false )
end

addEvent('permZone', true)
addEventHandler( 'permZone', root, admin.editEx )