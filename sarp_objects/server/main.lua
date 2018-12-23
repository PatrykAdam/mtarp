--[[

				Perfect World Role Play
				Discord: Panda#1293, email: damianpatryk.company@gmail.com

--]]

local objects, gate = {}, {}
objectsData = {}

local resource = {"sarp_items"}

function objects.onStart()
	for i, v in ipairs(resource) do
		local name = getResourceFromName( v )
		if name then
			restartResource( name )
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot, objects.onStart )

function objects.load()
	local count = 0
	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_objects`")

	objectsData = {}
	for i, v in ipairs(query) do
		local id = v.id
		objectsData[id] = {}
		objectsData[id].id = id
		objectsData[id].ownerType = v.ownerType
		objectsData[id].ownerID = v.ownerID
		objectsData[id].model = v.model
		objectsData[id].posX = v.posX
		objectsData[id].posY = v.posY
		objectsData[id].posZ = v.posZ
		objectsData[id].rotX = v.rotX
		objectsData[id].rotY = v.rotY
		objectsData[id].rotZ = v.rotZ
		objectsData[id].interior = v.interior
		objectsData[id].dimension = v.dimension
		objectsData[id].gate = v.gate
		objectsData[id].gateX = v.gateX
		objectsData[id].gateY = v.gateY
		objectsData[id].gateZ = v.gateZ
		objectsData[id].gaterotX = v.gaterotX
		objectsData[id].gaterotY = v.gaterotY
		objectsData[id].gaterotZ = v.gaterotZ
		objectsData[id].easing = v.easing
		objectsData[id].texture = objects.toTable(v.texture)
		objectsData[id].gateOpened = false
		objectsData[id].isObject = true
		count = count + 1
	end
	outputDebugString( "Wczytano ".. count .." obiektów z bazy danych." )
end

addEventHandler( "onResourceStart", resourceRoot, objects.load )

function createNoEditableObject(objectid, posX, posY, posZ, rotX, rotY, rotZ, dimension, interior, ownerID, ownerType)
	local id = 1
	
	while objectsData[id] do
		id = id + 1
	end

	objectsData[id] = {}
	objectsData[id].id = id
	objectsData[id].ownerType = ownerType
	objectsData[id].ownerID = ownerID
	objectsData[id].model = objectid
	objectsData[id].posX = posX
	objectsData[id].posY = posY
	objectsData[id].posZ = posZ
	objectsData[id].rotX = rotX
	objectsData[id].rotY = rotY
	objectsData[id].rotZ = rotZ
	objectsData[id].interior = interior
	objectsData[id].dimension = dimension
	objectsData[id].gate = false
	objectsData[id].gateX = 0
	objectsData[id].gateY = 0
	objectsData[id].gateZ = 0
	objectsData[id].gaterotX = 0
	objectsData[id].gaterotY = 0
	objectsData[id].gaterotZ = 0
	objectsData[id].easing = 0
	objectsData[id].texture = {}
	objectsData[id].gateOpened = false
	objectsData[id].isObject = false

	objects.update(id, objectsData[id], objectsData[id].dimension, objectsData[id].interior)

	return id
end

addEvent("createNoEditableObject", true)
addEventHandler( "createNoEditableObject", root, createNoEditableObject )

function getObjectsCount(ownerType, ownerID)
	local objectsCount = 0
	for i, v in pairs(objectsData) do
		if ownerType == v.ownerType and ownerID == v.ownerID then
			objectsCount = objectsCount + 1
		end
	end
	return objectsCount
end

function objects.create(objectid, isObject)
	local doorid = getElementData(source, "player:door")
	local groupid = getElementData(doorid, "doors:ownerID") or false
	local ownerID, ownerType = 0, 0
	local zonePerm, zoneID, groupID = exports.sarp_zones:haveZonePermission(source, 1, true)

	if groupid and exports.sarp_groups:haveGroupPermission(source, groupid, 1024) then
		ownerType = 2
		ownerID = groupid
	elseif zonePerm == true and exports.sarp_groups:haveGroupPermission(source, groupID, 1024) then
		ownerType = 3
		ownerID = zoneID
	elseif doorid and exports.sarp_doors:isDoorOwner(source, doorid) == 2 then
		ownerType = 1
		ownerID = getElementData(source, "player:id")
	elseif isObject == false and getElementData(source, "player:duty") ~= false and exports.sarp_groups:haveGroupFlags(getElementData(source, "player:duty"), 64) then
		ownerType = 4
		ownerID = getElementData(source, "player:duty")
	elseif exports.sarp_admin:getPlayerPermission(source, 512) then
		ownerType = 0
		ownerID = getElementData(source, "player:id")
	else
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do tworzenia obiektów w tym miejscu.")
	end

	if ownerType == 2 or ownerType == 1 or ownerType == 3 then
		local maxObjects = exports.sarp_doors:getDoorData(doorid, "objects")

		if ownerType == 3 and getObjectsCount(ownerType, ownerID) >= 30 or maxObjects and getObjectsCount(ownerType, ownerID) >= maxObjects then
			return exports.sarp_notify:addNotify(source, "Wykorzystałeś już wszystkie wykupione obiekty. Aby dalej budować, musisz dokupić pod komendą /drzwi.")
		end
	end

	local posX, posY, posZ = getElementPosition( source )
	local rotX, rotY, rotZ = 0, 0, 0
	local dimension, interior = getElementDimension( source ), getElementInterior( source )

	triggerClientEvent(source, "objects:create", source, {id = -1, model = objectid, posX = posX, posY = posY, posZ = posZ, rotX = rotX, rotY = rotY, rotZ = rotZ, ownerID = ownerID, ownerType = ownerType, dimension = dimension, interior = interior, isObject = isObject} )
end

addEvent("objects:create", true)
addEventHandler( "objects:create", root, objects.create )

function createPlayerObject(objectid, posX, posY, posZ, rotX, rotY, rotZ, dimension, interior, ownerID, ownerType)
	local id = 1
	
	while objectsData[id] do
		id = id + 1
	end

	objectsData[id] = {}
	objectsData[id].id = id
	objectsData[id].ownerType = ownerType
	objectsData[id].ownerID = ownerID
	objectsData[id].model = objectid
	objectsData[id].posX = posX
	objectsData[id].posY = posY
	objectsData[id].posZ = posZ
	objectsData[id].rotX = rotX
	objectsData[id].rotY = rotY
	objectsData[id].rotZ = rotZ
	objectsData[id].interior = interior
	objectsData[id].dimension = dimension
	objectsData[id].gate = false
	objectsData[id].gateX = 0
	objectsData[id].gateY = 0
	objectsData[id].gateZ = 0
	objectsData[id].gaterotX = 0
	objectsData[id].gaterotY = 0
	objectsData[id].gaterotZ = 0
	objectsData[id].easing = 0
	objectsData[id].texture = {}
	objectsData[id].gateOpened = false
	objectsData[id].isObject = true

	objects.update(id, objectsData[id], objectsData[id].dimension, objectsData[id].interior)

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_objects` SET `id` = ?, `dimension` = ?, `interior` = ?, `model` = ?, `posX` = ?, `posY` = ?, `posZ` = ?, `rotX` = ?, `rotY` = ?, `rotZ` = ?, `ownerType` = ?, `ownerID` = ?",
					objectsData[id].id,
					objectsData[id].dimension,
					objectsData[id].interior,
					objectsData[id].model,
					objectsData[id].posX,
					objectsData[id].posY,
					objectsData[id].posZ,
					objectsData[id].rotX,
					objectsData[id].rotY,
					objectsData[id].rotZ,
					objectsData[id].ownerType,
					objectsData[id].ownerID)

	return id
end

addEvent("createPlayerObject", true)
addEventHandler( "createPlayerObject", root, createPlayerObject )

function loadPlayerObjects(playerid, dimension, interior)
	--przyczepalne
	local boneObject = exports.sarp_items:getPlayerBoneObjects(playerid)

	if boneObject and #boneObject ~= 0 then
		for i, v in ipairs(boneObject) do
			setElementDimension( v, dimension )
			setElementInterior( v, interior )
		end
	end
	--obiekty
	local data = {}
	for i, v in pairs(objectsData) do
		if v and v.dimension == dimension and v.interior == interior then
			table.insert(data, v)
		end
	end
	setElementFrozen( playerid, true )
	setElementData(playerid, "objects:loading", true)
	return triggerClientEvent( "objects:update", playerid, data )
end

addEvent("objects:load", true)
addEventHandler( "objects:load", root, loadPlayerObjects )

function objects.cmd(playerid, cmd)
	local dimension, interior = getElementDimension( playerid ), getElementInterior( playerid )
	triggerEvent("objects:load", root, playerid, dimension, interior)
	outputDebugString( "Przeładowane obiekty na tym świecie." )
end

addCommandHandler( "obj", objects.cmd )

function objects.edit(objectid)
	if not isObjectOwner(source, objectid) then
		triggerClientEvent( 'msel:hide', source )
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do edycji tego obiektu.")
	end
	triggerClientEvent( "objects:editor", source, objectid )
end

addEvent("objects:edit", true)
addEventHandler( "objects:edit", root, objects.edit )

function objects.copy(objectid)
	if not isObjectOwner(source, objectid) then
		return
	end

	local id = createPlayerObject(objectsData[objectid].model, objectsData[objectid].posX, objectsData[objectid].posY, objectsData[objectid].posZ, objectsData[objectid].rotX, objectsData[objectid].rotY, objectsData[objectid].rotZ, objectsData[objectid].dimension, objectsData[objectid].interior)
	objectsData[id].texture = objectsData[objectid].texture
	
	objects.save(id, 'pos')
	objects.update(id, objectsData[id], objectsData[id].dimension, objectsData[id].interior)
end

addEvent('objects:copy', true)
addEventHandler( "objects:copy", root, objects.copy )

function objects.editSave(data)
	local id = data.id
	if not isObjectOwner(source, id) then
		return
	end

	objectsData[id].posX = data.posX
	objectsData[id].posY = data.posY
	objectsData[id].posZ = data.posZ
	objectsData[id].rotX = data.rotX
	objectsData[id].rotY = data.rotY
	objectsData[id].rotZ = data.rotZ

	objects.update(id, objectsData[id], objectsData[id].dimension, objectsData[id].interior)
	objects.save(id, 'pos')
end

addEvent("objects:save", true)
addEventHandler( "objects:save", root, objects.editSave )

function destroyObject(objectid)
	if not objectsData[objectid] then return end

	objects.update(objectid, nil, objectsData[objectid].dimension, objectsData[objectid].interior)
	
	if objectsData[objectid].isObject then
		exports.sarp_mysql:mysql_change("DELETE FROM `sarp_objects` WHERE `id` = ?", objectid)
	end

	objectsData[objectid] = nil
end

addEvent("objects:destroy", true)
addEventHandler( "objects:destroy", root, destroyObject )

function objects.texture(objectid, texName, texID)
	local isTexture = 0
	if type(objectsData[objectid].texture) == 'table' then
		for i, v in ipairs(objectsData[objectid].texture) do
			if v.texName == texName and v.texID == texID then
				return
			end
			if v.texName == texName then
				isTexture = i
			end
		end
	else
		objectsData[objectid].texture = {}
	end
	
	if isTexture ~= 0 then
		objectsData[objectid].texture[isTexture].texID = texID
	else
		table.insert(objectsData[objectid].texture, {['texName'] = texName, ['texID'] = texID})
	end

	objects.save(objectid, 'pos')
	objects.update(objectid, objectsData[objectid], objectsData[objectid].dimension, objectsData[objectid].interior)
end

addEvent("objects:texture", true)
addEventHandler( "objects:texture", root, objects.texture )

function objects.createGate(data)
	local id = data.id
	objectsData[id].gate = 1
	objectsData[id].gateX = data.posX
	objectsData[id].gateY = data.posY
	objectsData[id].gateZ = data.posZ
	objectsData[id].gaterotX = data.rotX
	objectsData[id].gaterotY = data.rotY
	objectsData[id].gaterotZ = data.rotZ
	objectsData[id].easing = data.easing
	objects.save(id, 'gate')
	objects.update(id, objectsData[id], objectsData[id].dimension, objectsData[id].interior)
	exports.sarp_notify:addNotify(source, string.format("Stworzyłeś brame z obiektu o ID: %d.", id))
end

addEvent("objects:createGate", true)
addEventHandler( "objects:createGate", root, objects.createGate )

function objects.deleteGate(objectid)
	objectsData[objectid].gate = 0
	objects.save(objectid, 'gate')
	objects.update(objectid, objectsData[objectid], objectsData[objectid].dimension, objectsData[objectid].interior)
	exports.sarp_notify:addNotify(source, "Brama została zamieniona w zwykły obiekt.")
end

addEvent("objects:deleteGate", true)
addEventHandler( "objects:deleteGate", root, objects.deleteGate )

function objects.update(id, data, dimension, interior)
	for i, v in pairs(getElementsByType( "player" )) do
		local pDimension, pInterior = getElementDimension( v ), getElementInterior( v )
		if pDimension == dimension and pInterior == interior then
			triggerClientEvent( "objects:changed", v, id, data )
		end
	end
end

function gate.create(id, startPos, easing)
	local dimension, interior = objectsData[id].dimension, objectsData[id].interior
	for i, v in ipairs(getElementsByType( "player" )) do
		local pDimension, pInterior = getElementDimension( v ), getElementInterior( v )
		if pDimension == dimension and pInterior == interior then
			triggerClientEvent( "gate:create", v, id, startPos, easing )
		end
	end
end

function isObjectOwner(playerid, objectid)
	local zonePerm, zoneID, groupID = exports.sarp_zones:haveZonePermission(source, 1, true)
	if exports.sarp_admin:getPlayerPermission(playerid, 512) or
		objectsData[objectid].ownerType == 2 and exports.sarp_groups:haveGroupPermission(playerid, objectsData[objectid].ownerID, 1024) or
		objectsData[objectid].ownerType == 3 and zonePerm and exports.sarp_groups:haveGroupPermission(playerid, groupID, 1024) or
		objectsData[objectid].ownerType == 1 and objectsData[objectid].ownerID == getElementData(playerid, "player:id") then
		return true
	end
	return false
end

function isGateOwner(playerid, objectid)
	if exports.sarp_admin:getPlayerPermission(source, 512) or
		objectsData[objectid].ownerType == 2 and exports.sarp_groups:haveGroupPermission(playerid, objectsData[objectid].ownerID, 1024) or
		objectsData[objectid].ownerType == 1 and objectsData[objectid].ownerID == getElementData(playerid, "player:id") then
		return true
	end
	return false
end

function gate.toggle(id)
	local object = objectsData[id]
	if not object.gate then return end

	if not isGateOwner(source, id) then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do otwierania tej bramy.")
	end
	if object.gateOpened then
		object.gateOpened = false
		gate.create(id, {object.posX, object.posY, object.posZ, object.rotX, object.rotY, object.rotZ}, object.easing)
	else
		object.gateOpened = true
		gate.create(id, {object.gateX, object.gateY, object.gateZ, object.gaterotX, object.gaterotY, object.gaterotZ}, object.easing)
	end
end

addEvent("gate:toggle", true)
addEventHandler( "gate:toggle", root, gate.toggle )

function objects.save(objectid, what)
	if what == 'pos' then
	local texture = ''
	for i, v in ipairs(objectsData[objectid].texture) do
		texture = string.format('%s %s %d', texture, v.texName, v.texID)
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_objects` SET `posX` = ?, `posY` = ?, `posZ` = ?, `rotX` = ?, `rotY` = ?, `rotZ` = ?, `texture` = ? WHERE `id` = ?",
					objectsData[objectid].posX,
					objectsData[objectid].posY,
					objectsData[objectid].posZ,
					objectsData[objectid].rotX,
					objectsData[objectid].rotY,
					objectsData[objectid].rotZ,
					texture,
					objectid)

	elseif what == 'gate' then
	exports.sarp_mysql:mysql_change("UPDATE `sarp_objects` SET `gate` = ?, `gateX` = ?, `gateY` = ?, `gateZ` = ?, `gaterotX` = ?, `gaterotY` = ?, `gaterotZ` = ?, `easing` = ? WHERE `id` = ?",
					objectsData[objectid].gate,
					objectsData[objectid].gateX,
					objectsData[objectid].gateY,
					objectsData[objectid].gateZ,
					objectsData[objectid].gaterotX,
					objectsData[objectid].gaterotY,
					objectsData[objectid].gaterotZ,
					objectsData[objectid].easing,
					objectid)
	end
end

function objects.toTable(string)
	local newTab = {}
	if type(string) == "boolean" then return newTab end
	local table = split( string, " " )
	for i, v in ipairs(table) do
		if i%2 ~= 0 then
			newTab[i] = {}
			newTab[i].texName = v
		else
			newTab[i-1].texID = v
		end
	end
	return newTab
end