--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local msel = {}
local editor = {}


function onStart()
	msel.active = false
	msel.W = 75
	msel.H = 50
	editor.startX = 0
	editor.startY = 0
	editor.endX = 0
	editor.obPosX = 0
	editor.obPosY = 0
	editor.obPosZ = 0
	editor.obRotX = 0
	editor.obRotY = 0
	editor.obRotZ = 0
	editor.position = 1
	editor.textureMax = 17
end

addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function editor.onClick(button, state, mX, mY)
	if button == 'left' and state == 'down' then
		if mX >= screenX - 340 and mX <= screenX - 10 and mY >= screenY - 230 and mY <= screenY - 30 then return end
		editor.startX = mX
		editor.startY = mY
		editor.endX = mX
	end
	if button == 'left' and state == 'up' then

		if editor.position == 1 then
			editor.obPosX = editor.obPosX + ((editor.startX - editor.endX)/screenX) * 10
		elseif editor.position == 2 then
			editor.obPosY = editor.obPosY + ((editor.startX - editor.endX)/screenX) * 10
		elseif editor.position == 3 then
			editor.obPosZ = editor.obPosZ + ((editor.startX - editor.endX)/screenX) * 10
		elseif editor.position == 4 then
			editor.obRotX = editor.obRotX + ((editor.startX - editor.endX)/screenX) * 10
		elseif editor.position == 5 then
			editor.obRotY = editor.obRotY + ((editor.startX - editor.endX)/screenX) * 10
		elseif editor.position == 6 then
			editor.obRotZ = editor.obRotZ + ((editor.startX - editor.endX)/screenX) * 10
		end

		editor.startX = 0
		editor.startY = 0
		editor.endX = 0
	end
	if button == 'right' and state == 'down' then
		if editor.position == 6 then
			editor.position = 1
		else
			editor.position = editor.position + 1
		end
	end
end

function editor.onRender()
	--chowanie/pokazywanie kursora
	if getKeyState( "lctrl" ) then
		if isCursorShowing( localPlayer ) then
			showCursor( false )
		end
	else
		if not isCursorShowing( localPlayer ) then
			showCursor( true )
		end
	end
	if editor.startX ~= 0 then
		dxDrawLine( editor.startX, editor.startY, editor.endX, editor.startY, tocolor( 255, 0, 0 ) )
	end
	local w, h = 100, 50
	local x, y = screenX/2 - w/2, 0.8 * screenY - h
	dxDrawRectangle( x, y, w, h, tocolor(112, 112, 112, 150) )
	dxDrawText( "X", x, y, x + w/3, y + h/2, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
	dxDrawText( "Y", x + w/3, y, x + (w/3) * 2, y + h/2, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
	dxDrawText( "Z", x + w/3 * 2, y, x + w, y + h/2, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
	dxDrawText( "rX", x, y + h/2, x + w/3, y + h, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
	dxDrawText( "rY", x + w/3, y + h/2, x + (w/3) * 2, y + h, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
	dxDrawText( "rZ", x + w/3 * 2, y + h/2, x + w, y + h, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
	dxDrawRectangle( x + (editor.position > 3 and editor.position - 4 or editor.position - 1) * w/3, y + (editor.position > 3 and h/2 or 0), w/3, h/2, tocolor(112, 112, 112, 150) )

	--linie pomocnicze
	if editor.position == 1 then
		local posX = editor.obPosX + ((editor.startX - editor.endX)/screenX) * 10
		dxDrawLine3D( posX - 1, editor.obPosY, editor.obPosZ, posX + 1, editor.obPosY, editor.obPosZ, tocolor(255, 0, 0), 5 )
	elseif editor.position == 2 then
		local posY = editor.obPosY + ((editor.startX - editor.endX)/screenX) * 10
		dxDrawLine3D( editor.obPosX, posY - 1, editor.obPosZ, editor.obPosX, posY + 1, editor.obPosZ, tocolor(255, 0, 0), 5 )
	elseif editor.position == 3 then
		local posZ = editor.obPosZ + ((editor.startX - editor.endX)/screenX) * 10
		dxDrawLine3D( editor.obPosX, editor.obPosY, posZ - 1, editor.obPosX, editor.obPosY, posZ + 1, tocolor(255, 0, 0), 5 )
	elseif editor.position == 4 then
		dxDrawLine3D( editor.obPosX - 1, editor.obPosY, editor.obPosZ, editor.obPosX + 1, editor.obPosY, editor.obPosZ, tocolor(255, 0, 0), 5 )
	elseif editor.position == 5 then
		dxDrawLine3D( editor.obPosX, editor.obPosY - 1, editor.obPosZ, editor.obPosX, editor.obPosY + 1, editor.obPosZ, tocolor(255, 0, 0), 5 )
	elseif editor.position == 6 then
		dxDrawLine3D( editor.obPosX, editor.obPosY, editor.obPosZ - 1, editor.obPosX, editor.obPosY, editor.obPosZ + 1, tocolor(255, 0, 0), 5 )
	end


end

function editor.refreshPos()
	local rotX, rotY, rotZ = guiGetText( editor.rotX ), guiGetText( editor.rotY ), guiGetText( editor.rotZ )
	editor.obRotX = tonumber(rotX)
	editor.obRotY = tonumber(rotY)
	editor.obRotZ = tonumber(rotZ)
	setElementRotation( objects[editor.objectid].mtaID, editor.obRotX, editor.obRotY, editor.obRotZ )
end

function editor.hide()
	if editor.gateActive then
		editor.gateHide()
	end
	toggleControl( "fire", true )
	removeEventHandler( "onClientRender", root, editor.onRender )
	removeEventHandler( "onClientClick", root, editor.onClick )
	removeEventHandler( "onClientCursorMove", root, editor.onMove )
	removeEventHandler( "onClientGUIClick", editor.button2, editor.refreshPos )
	removeEventHandler( "onClientGUIClick", editor.button4, editor.saveObject )
	destroyElement( editor.window )
	editor.active = false
	showCursor( false )
end

function editor.cancelSave()
	if isElement(objects[editor.objectid].mtaID) then
		local object = objects[editor.objectid]

		if object.newObject then
			destroyElement( object.mtaID )
			objects[editor.objectid] = nil
			return
		end

		setElementPosition( object.mtaID, object.posX, object.posY, object.posZ )
		setElementRotation( object.mtaID, object.rotX, object.rotY, object.rotZ )
	end
end

function editor.gateHide()
	destroyElement( editor.gateWindow )
	editor.gateActive = false
	showCursor( false )
end

function editor.saveObject()
	local zoneOut = true

	for i, v in ipairs(getElementsByType( "colshape", nil, true)) do
		if getElementData(v, "isZone") and objects[editor.objectid].ownerType == 3 and getElementData(v, "zoneID") == objects[editor.objectid].ownerID and isElementWithinColShape( objects[editor.objectid].mtaID, v ) then
			zoneOut = false
			break
		end
	end

	if zoneOut and objects[editor.objectid].ownerType == 3 then
		return exports.sarp_notify:addNotify("Wyszłeś obiektem poza strefę, nie możesz zapisać obiektu.")
	end

	local object = {}
	object.id = objects[editor.objectid].id
	object.posX = editor.obPosX
	object.posY = editor.obPosY
	object.posZ = editor.obPosZ
	object.rotX = editor.obRotX
	object.rotY = editor.obRotY
	object.rotZ = editor.obRotZ
	if objects[editor.objectid].newObject then
		if objects[editor.objectid].isObject then
			triggerServerEvent( "createPlayerObject", localPlayer, objects[editor.objectid].model, object.posX, object.posY, object.posZ, object.rotX, object.rotY, object.rotZ, objects[editor.objectid].dimension, objects[editor.objectid].interior, objects[editor.objectid].ownerID, objects[editor.objectid].ownerType)
		else
			triggerServerEvent( "createNoEditableObject", localPlayer, objects[editor.objectid].model, object.posX, object.posY, object.posZ, object.rotX, object.rotY, object.rotZ, objects[editor.objectid].dimension, objects[editor.objectid].interior, objects[editor.objectid].ownerID, objects[editor.objectid].ownerType)
		end
		if isElement(objects[editor.objectid].mtaID) then
			destroyElement( objects[editor.objectid].mtaID )
		end
		objects[editor.objectid] = nil
		exports.sarp_notify:addNotify("Obiekt został stworzony.")
	else
		triggerServerEvent( "objects:save", localPlayer, object)
		exports.sarp_notify:addNotify(string.format("Obiekt O ID: %d został zapisany.", object.id))
	end
	editor.hide()
end

function editor.onMove(x)
	if editor.startX ~= 0 then
		local objectid = editor.objectid
		editor.endX = x * screenX

		if not isElement(objects[objectid].mtaID) then
			editor.saveObject()
			return exports.sarp_notify:addNotify("Oddaliłeś się zbyt daleko. Twój obiekt został zapisany, a edycja przerwana.")
		end

		if editor.position == 1 then
			local posX = editor.obPosX + ((editor.startX - editor.endX)/screenX) * 10
			setElementPosition( objects[objectid].mtaID, posX, editor.obPosY, editor.obPosZ )
			guiSetText( editor.posX,  posX)
		elseif editor.position == 2 then
			local posY = editor.obPosY + ((editor.startX - editor.endX)/screenX) * 10
			setElementPosition( objects[objectid].mtaID, editor.obPosX, posY, editor.obPosZ )
			guiSetText( editor.posY,  posY)
		elseif editor.position == 3 then
			local posZ = editor.obPosZ + ((editor.startX - editor.endX)/screenX) * 10
			setElementPosition( objects[objectid].mtaID, editor.obPosX, editor.obPosY, posZ )
			guiSetText( editor.posZ,  posZ)
		elseif editor.position == 4 then
			local rotX = editor.obRotX + ((editor.startX - editor.endX)/screenX) * 10
			setElementRotation( objects[objectid].mtaID, rotX, editor.obRotY, editor.obRotZ )
			guiSetText( editor.rotX,  rotX)
		elseif editor.position == 5 then
			local rotY = editor.obRotY + ((editor.startX - editor.endX)/screenX) * 10
			setElementRotation( objects[objectid].mtaID, editor.obRotX, rotY, editor.obRotZ )
			guiSetText( editor.rotY,  rotY)
		elseif editor.position == 6 then
			local rotZ = editor.obRotZ + ((editor.startX - editor.endX)/screenX) * 10
			setElementRotation( objects[objectid].mtaID, editor.obRotX, editor.obRotY, rotZ )
			guiSetText( editor.rotZ,  rotZ)
		end
		
	end
end

function editor.createGate()
	local easing = guiComboBoxGetSelected( editor.gateCombo ) + 1
	if easing == -1 then
		return exports.sarp_notify:addNotify("Aby stworzyć brame musisz ustalić typ animacji.")
	end
	
	if objects[editor.objectid].id == -1 then
		return exports.sarp_notify:addNotify("Najpierw musisz zapisać nowo utworzony obiekt!")
	end

	local object = {}
	object.id = objects[editor.objectid].id
	object.posX = editor.obPosX
	object.posY = editor.obPosY
	object.posZ = editor.obPosZ
	object.rotX = editor.obRotX
	object.rotY = editor.obRotY
	object.rotZ = editor.obRotZ
	object.easing = easing
	triggerServerEvent( "objects:createGate", localPlayer, object)
	editor.hide()
	editor.cancelSave()
end

function editor.deleteGate()
	if not objects[editor.objectid].gate then
		return exports.sarp_notify:addNotify("Ten obiekt nie jest bramą.")
	end
	triggerServerEvent( "objects:deleteGate", localPlayer, objects[editor.objectid].id )
	editor.hide()
end

function editor.gateManager()
	if editor.gateActive then return editor.gateHide() end

	editor.gateActive = true

	local x, y = screenX - 10 - 330, screenY/2 - 250/2
	editor.gateWindow = guiCreateWindow ( x, y, 330, 250, "Tworzenie bramy", false )
	editor.gateMemo = guiCreateMemo( 0.0, 0.1, 1.0, 0.3, "Aby utworzyć brame musisz ustawić obiekt w pozycji zamkniętej, następnie po wybraniu animacji bramy nacisnąć przycisk 'Stwórz brame'.", true, editor.gateWindow )
	editor.gateCombo = guiCreateComboBox( 0.1, 0.5, 0.8, 0.4, "Typ animacji", true, editor.gateWindow )
	for i, v in ipairs(gateAnim) do
		guiComboBoxAddItem( editor.gateCombo, v )
	end
	editor.gateButton = guiCreateButton( 0.0, 0.8, 0.3, 0.15, "Stwórz brame", true, editor.gateWindow )
	editor.gateButton2 = guiCreateButton( 0.35, 0.8, 0.3, 0.15, "Usuń brame", true, editor.gateWindow )
	editor.gateButton3 = guiCreateButton( 0.7, 0.8, 0.3, 0.15, "Zamknij", true, editor.gateWindow )

	addEventHandler( "onClientGUIClick", editor.gateButton, editor.createGate, false)
	addEventHandler( "onClientGUIClick", editor.gateButton2, editor.deleteGate, false)
	addEventHandler( "onClientGUIClick", editor.gateButton3, editor.gateHide, false)
end

function editor.show(objectid)
	if msel.active then
		msel.hide()
	end
	editor.active = true
	toggleControl( "fire", false )

	--zapisujemy informacje dotyczące pozycji obiektu do przechowania
	editor.objectid = getPlayerObjectID(objectid)
	editor.obPosX = objects[editor.objectid].posX
	editor.obPosY = objects[editor.objectid].posY
	editor.obPosZ = objects[editor.objectid].posZ
	editor.obRotX = objects[editor.objectid].rotX
	editor.obRotY = objects[editor.objectid].rotY
	editor.obRotZ = objects[editor.objectid].rotZ
	editor.position = 1

	local x, y = screenX - 10 - 330, screenY - 230
	editor.window = guiCreateWindow ( x, y, 330, 200, string.format("Edycja obiektu o id: %d", objectid), false )
	guiWindowSetSizable ( editor.window, false )
	guiWindowSetMovable( editor.window, false )
	editor.button = guiCreateButton ( 0.0, 0.85, 0.3, 0.15, "Tworzenie bramy", true, editor.window )
	editor.button2 = guiCreateButton ( 0.35, 0.85, 0.3, 0.15, "Odśwież rotacje", true, editor.window )
	editor.button3 = guiCreateButton ( 0.0, 0.7, 1.0, 0.1, "Zamknij", true, editor.window )
	editor.button4 = guiCreateButton ( 0.7, 0.85, 0.3, 0.15, "Zapisz obiekt", true, editor.window )
	editor.posX = guiCreateEdit( 0.05, 0.1, 0.4, 0.15, editor.obPosX, true, editor.window )
	editor.rotX = guiCreateEdit( 0.52, 0.1, 0.4, 0.15, editor.obRotX, true, editor.window )
	editor.posY = guiCreateEdit( 0.05, 0.3, 0.4, 0.15, editor.obPosY, true, editor.window )
	editor.rotY = guiCreateEdit( 0.52, 0.3, 0.4, 0.15, editor.obRotY, true, editor.window )
	editor.posZ = guiCreateEdit( 0.05, 0.5, 0.4, 0.15, editor.obPosZ, true, editor.window )
	editor.rotZ = guiCreateEdit( 0.52, 0.5, 0.4, 0.15, editor.obRotZ, true, editor.window )
	guiEditSetReadOnly( editor.posX, true )
	guiEditSetReadOnly( editor.posY, true )
	guiEditSetReadOnly( editor.posZ, true )
	addEventHandler( "onClientRender", root, editor.onRender )
	addEventHandler( "onClientClick", root, editor.onClick )
	addEventHandler( "onClientCursorMove", root, editor.onMove )
	addEventHandler( "onClientGUIClick", editor.button2, editor.refreshPos, false)
	addEventHandler( "onClientGUIClick", editor.button3, function()
		editor.hide()
		editor.cancelSave()
		end, false)
	addEventHandler( "onClientGUIClick", editor.button4, editor.saveObject, false)
	addEventHandler( "onClientGUIClick", editor.button, editor.gateManager, false)
end

addEvent("objects:editor", true)
addEventHandler( "objects:editor", localPlayer, editor.show )

function editor.create(data)
	objects_changed(-1, data)
	local id = getPlayerObjectID(-1)
	objects[id].newObject = true
	editor.show(-1)
end

addEvent("objects:create", true)
addEventHandler( "objects:create", root, editor.create )

function msel.hide()
	msel.active = false
	showCursor( false )
	toggleControl( "fire", true )
	removeEventHandler( "onClientKey", root, msel.key )
	removeEventHandler( "onClientRender", root, msel.onRender )
	removeEventHandler( "onClientClick", root, msel.onClick )
end

addEvent('msel:hide', true)
addEventHandler("msel:hide", localPlayer, msel.hide)

function msel.onRender()
	if msel.active then
		local mX, mY, mZ = getCameraMatrix()
		--wyszukujemy obiektów w pobliżu
		local objectid = 0
		for i, v in ipairs(objects) do
			local distance = getDistanceBetweenPoints3D( v.posX, v.posY, v.posZ, mX, mY, mZ )
			if distance < 50.0 and v.isObject then
				local sX, sY = getScreenFromWorldPosition(v.posX, v.posY, v.posZ)
				if sX then
					dxDrawRectangle( sX - msel.W/2, sY - msel.H/2, msel.W, msel.H, tocolor(112, 112, 112, 150) )
					dxDrawText( string.format("ID: %d\nModel: %d",v.id, v.model), sX - msel.W/2, sY - msel.H/2, sX + msel.W/2, sY + msel.H/2, tocolor(230, 230, 250), 1, "default-bold", "center", "center", false, true )
				end
			end
		end
	end
end

function msel.onClick(x, x, cX, cY)
	for i, v in ipairs(objects) do
		local mX, mY, mZ = getCameraMatrix()
		if getDistanceBetweenPoints3D( v.posX, v.posY, v.posZ, mX, mY, mZ ) < 50.0 and v.isObject then
			local sX, sY = getScreenFromWorldPosition(v.posX, v.posY, v.posZ)
			if sX then
				if cX >= sX - msel.W/2 and cX <= sX + msel.W/2 and cY >= sY - msel.H/2 and cY <= sY + msel.H/2 then
					msel.hide()
					triggerServerEvent( "objects:edit", localPlayer, v.id )
					break
				end
			end
		end
	end
end

function msel.show()
	exports.sarp_notify:addNotify("Naciśnij na identyfikator obiektu który chcesz edytować.")
	msel.active = true
	showCursor( true )
	toggleControl( "fire", false )
	addEventHandler( "onClientKey", root, msel.key )
	addEventHandler( "onClientClick", root, msel.onClick )
	addEventHandler( "onClientRender", root, msel.onRender )
end

function msel.key(button, pressed)
	if button == 'lctrl' and pressed == true then
		if isCursorShowing( localPlayer ) then
			showCursor( false )
		else
			showCursor( true )
		end
	end
end

function msel.cmd(cmd, objectid)
	if editor.active then return end

	objectid = getPlayerObjectID(tonumber(objectid))
	if objectid == 0 then
		if not msel.active then
			msel.show()
		else
			msel.hide()
		end
	else
		if not objects[objectid] or not objects[objectid].isObject then
			return exports.sarp_notify:addNotify("Obiekt o podanym ID nie istnieje.")
		end

		if getDistanceBetweenPoints3D( objects[objectid].posX, objects[objectid].posY, objects[objectid].posZ, getElementPosition( localPlayer ) ) > 10.0 then
			return exports.sarp_notify:addNotify("Znajdujesz się zbyt daleko obiektu o podanym ID.")
		end

		triggerServerEvent( "objects:edit", localPlayer, objects[objectid].id )
	end
end
addCommandHandler( "msel", msel.cmd )


function cmd_mc(cmd, model)
	model = tonumber(model)

	if not model then
		return outputChatBox( "Użyj: /mc [id obiektu]" )
	end
	
	local object = createObject( model, 0, 0, 0 )

	if object == false then
		return exports.sarp_notify:addNotify("Obiekt o podanym modelu nie istnieje.")
	end

	destroyElement( object )

	triggerServerEvent( "objects:create", localPlayer, model, true)
	
end

addCommandHandler( "mc", cmd_mc )

function cmd_mcopy(cmd)
	if not editor.active or not editor.objectid or editor.objectid == -1 then return exports.sarp_notify:addNotify("Aktualnie nie edytujesz żadnego obiektu.") end

	editor.saveObject()
	setTimer( triggerServerEvent, 500, 1, "objects:copy", localPlayer, objects[editor.objectid].id )
end

addCommandHandler( "mcopy", cmd_mcopy )

function cmd_md(cmd)
	if not editor.active or not editor.objectid then return exports.sarp_notify:addNotify("Aktualnie nie edytujesz żadnego obiektu.") end

	if objects[editor.objectid].newObject then
		destroyElement( objects[editor.objectid].mtaID )
	else
		triggerServerEvent( "objects:destroy", localPlayer, objects[editor.objectid].id )
	end
	editor.hide()
end

addCommandHandler( "md", cmd_md )

function cmd_mmat(cmd, texIndex, texID)
	if not editor.active or not editor.objectid then return exports.sarp_notify:addNotify("Aktualnie nie edytujesz żadnego obiektu.") end
	local index, id = tonumber(texIndex), tonumber(texID)

	if not id or not index then
		return outputChatBox( "Użyj: /mmat [index id] [id nowej tekstury]" )
	end

	if id > editor.textureMax or 1 > id then
		return exports.sarp_notify:addNotify("Tekstura o takim ID nie istnieje. Informacje o teksturach znajdziesz na naszej stronie.")
	end

	triggerServerEvent( "objects:texture", localPlayer, objects[editor.objectid].id, index, id)
end

addCommandHandler( "mmat", cmd_mmat )