--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]


local Settings = {
	maxDistance = 300.0,
	updateTime = 300.0,
	updateLimit = 10,
	noBreakable = {
		2942, 1425, 3578, 1282, 1228, 1434, 1424, 1437, 14449
	}
}

objects = {}
local streamObjects = {}

function onStart()
	setTimer( updateObjects, Settings.updateTime, 0 )

	triggerServerEvent( "objects:load", root, localPlayer, getElementDimension( localPlayer ), getElementInterior( localPlayer ) )
end
addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function freeIndex()
	local id = 1
	for i, v in ipairs(objects) do
		id = i + 1
		if not objects[i] then
			id = i
			break
		end
	end
	return id
end

function getNearestObjects(distance)
	local pX, pY, pZ = getElementPosition( localPlayer )
	local objectsList = {}
	for i, v in ipairs(objects) do
		if v.streamed then
			if getDistanceBetweenPoints3D( pX, pY, pZ, v.posX, v.posY, v.posZ) < distance then
				table.insert(objectsList, v)
			end
		end
	end

	if #objectsList <= 0 then return false end
	return objectsList
end

function getPlayerObjectID(id)
	local pID = 0
	for i, v in pairs(objects) do
		if v.id == id then
			pID = i
			break
		end
	end
	return pID
end

function objects_changed(objectid, data)
	local id = getPlayerObjectID(objectid)
	
	if tonumber(id) == 0 then
		id = freeIndex()
	end

	if objects[id] and isElement(objects[id].mtaID) then
		destroyElement( objects[id].mtaID )
	end

	objects[id] = data
end

addEvent("objects:changed", true)
addEventHandler( "objects:changed", localPlayer, objects_changed )

function objects_update(data)
	for i, v in ipairs(objects) do
		if isElement(v.mtaID) then
			deleteAllObjectTexture( v.id )
			destroyElement( v.mtaID )
			v.streamed = false
		end
	end
	objects = {}
	for i, v in ipairs(data) do
		local id = freeIndex()
		objects[id] = v
	end
end

addEvent("objects:update", true)
addEventHandler( "objects:update", localPlayer, objects_update )

function updateObjects()
	--aktualizujemy obiekty widoczne
	for i, v in ipairs(objects) do
		if isElementInRange(localPlayer, v.posX, v.posY, v.posZ, Settings.maxDistance) then
			if not isElement(v.mtaID) and not v.streamed then
				table.insert(streamObjects, v)
				
				v.streamed = true
			end
		elseif isElement(v.mtaID) then
			deleteAllObjectTexture( v.id )
			destroyElement( v.mtaID )

			v.streamed = false
		end
	end
	--tworzymy obiekty
	if getElementData(localPlayer, "objects:loading") and #streamObjects == 0 then
		setElementFrozen(localPlayer, false )
		setElementData(localPlayer, "objects:loading", false)
	end

	local count = 0
	for i, v in ipairs(streamObjects) do
		count = count + 1
		v.mtaID = createObject( v.model, v.posX, v.posY, v.posZ, v.rotX, v.rotY, v.rotZ )

		if v.mtaID == false then return end

		setElementData(v.mtaID, "object:id", v.id, false)

		if v.id == -1 then
			setElementCollisionsEnabled(v.mtaID, false)
		end

		for j, k in ipairs(Settings.noBreakable) do
			if v.model == k then
				setObjectBreakable( v.mtaID, false )
				setElementFrozen( v.mtaID, true )
			end
		end

		setElementDimension( v.mtaID, v.dimension )
		setElementInterior( v.mtaID, v.interior )

		if v.gate and v.gateOpened then
			setElementPosition( v.mtaID, v.gateX, v.gateY, v.gateZ )
			setElementRotation( v.mtaID, v.gaterotX, v.gaterotY, v.gaterotZ )
		end

		table.remove( streamObjects, i )

		--nakładamy teksture
		if type(v.texture) == 'table' then
			for j, k in ipairs(v.texture) do
				setObjectTexture(v.mtaID, k.texName, k.texID)
			end
		end

		if count >= Settings.updateLimit then break end
	end
end

function isElementInRange(ele, x, y, z, range)
   if isElement(ele) and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(range) == "number" then
      return getDistanceBetweenPoints3D(x, y, z, getElementPosition(ele)) <= range -- returns true if it the range of the element to the main point is smaller than (or as big as) the maximum range.
   end
   return false
end

function damageObject()
	if getElementModel( source ) == 2942 then
		cancelEvent()
	end
end

addEventHandler( "onClientObjectDamage", root, damageObject )

function barrierDestroy()
	local pX, pY, pZ = getElementPosition( localPlayer )

	local objectsList = getNearestObjects( 5.0 )

	local lastDistance = 5.0
	local barrierID = nil

	for i, v in ipairs(objectsList) do
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, v.posX, v.posY, v.posZ )

		if v.ownerID == getElementData(localPlayer, "player:duty") and v.ownerType == 4 and v.isObject == false then
			if lastDistance > distance then
				lastDistance = distance
				barrierID = v.id
			end
		end
	end

	if barrierID == nil then return exports.sarp_notify:addNotify("Nie znaleziono w pobliżu żadnej bariery.") end

	triggerServerEvent( "objects:destroy", localPlayer, barrierID )
	exports.sarp_notify:addNotify(string.format("Bariera o ID: %d została usunięta.", barrierID))
end

addEvent("barrierDestroy", true)
addEventHandler( "barrierDestroy", root,  barrierDestroy)