--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local gate = {}
local gateTable = {}
gateAnim = { "Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve" }


function gate.cmd()
	local objectList = getNearestObjects(10.0)
	if not objectList or #objectList <= 0 then return end

	local gateCount = 0
	for i, v in ipairs(objectList) do
		if v.gate == 1 then
			gateCount = gateCount + 1
			triggerServerEvent( "gate:toggle", localPlayer, v.id )
		end
	end

	if gateCount <= 0 then
		return exports.sarp_notify:addNotify("Nie znaleziono żadnej bramy w pobliżu.")
	end
end

addCommandHandler( "brama", gate.cmd )

function gate.create(id, endPos, easing, time)
	if not time then time = 2000 end
	id = getPlayerObjectID(id)
	local object = objects[id]
	if not object then return end
	
	if object.gateOpened then
		objects[id].gateOpened = false
	else
		objects[id].gateOpened = true
	end
	
	if not object.mtaID then return end

	local isMoving = false
	for i, v in ipairs(gateTable) do
		if isElement(v.mtaID) then
			if v.mtaID == object.mtaID then
				local progress = (getTickCount() - v.startTick) / v.time
				local x, y, z = interpolateBetween( v.startPos[1], v.startPos[2], v.startPos[3], v.endPos[1], v.endPos[2], v.endPos[3], progress, v.easing )
				local rx, ry, rz = interpolateBetween( v.startPos[4], v.startPos[5], v.startPos[6], v.endPos[4], v.endPos[5], v.endPos[6], progress, v.easing )
				table.remove(gateTable, i)
				time = time - (time - time * progress)
				startPos = {x, y, z, rx, ry, rz}
				isMoving = true
			end
		end
	end

	if not isMoving then
		startPos = object.gateOpened and {object.posX, object.posY, object.posZ, object.rotX, object.rotY, object.rotZ} or {object.gateX, object.gateY, object.gateZ, object.gaterotX, object.gaterotY, object.gaterotZ}
	end

	table.insert(gateTable, {
		time = time,
		mtaID = object.mtaID,
		startPos = startPos,
		endPos = endPos,
		startTick = getTickCount(),
		easing = gateAnim[easing]
	})



end

addEvent("gate:create", true)
addEventHandler( "gate:create", localPlayer, gate.create )

function gate.onRender()
	for i, v in ipairs(gateTable) do
		if not isElement(v.mtaID) then return end
		local progress = (getTickCount() - v.startTick) / v.time
		local x, y, z = interpolateBetween( v.startPos[1], v.startPos[2], v.startPos[3], v.endPos[1], v.endPos[2], v.endPos[3], progress, v.easing )
		local rx, ry, rz = interpolateBetween( v.startPos[4], v.startPos[5], v.startPos[6], v.endPos[4], v.endPos[5], v.endPos[6], progress, v.easing )
		if progress > 1 then
			setElementPosition( v.mtaID, v.endPos[1], v.endPos[2], v.endPos[3] )
			setElementRotation( v.mtaID, v.endPos[4], v.endPos[5], v.endPos[6] )
			table.remove(gateTable, i)
		else
			setElementPosition( v.mtaID, x, y, z )
			setElementRotation( v.mtaID, rx, ry, rz )
		end
			
	end
end
addEventHandler( "onClientRender", root, gate.onRender )