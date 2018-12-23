--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screen = Vector2( guiGetScreenSize() )
local streamPlayers = {}

local function onResStart()
	for k, v in ipairs(getElementsByType("player")) do
		if(isElementStreamedIn(v)) then
			streamPlayers[v] = true
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onResStart)

function onElementStreamInLookAt()
	if(getElementType(source) == "player") then
		if(not streamPlayers[source]) then
			streamPlayers[source] = true
		end
	end
end
addEventHandler("onClientElementStreamIn", root, onElementStreamInLookAt)

function onElementStreamOutLookAt()
	if(getElementType(source) == "player") then
		if(streamPlayers[source]) then
			streamPlayers[source] = false
		end
	end
end
addEventHandler("onClientElementStreamOut", root, onElementStreamOutLookAt)

function onElementQuit()
	streamPlayers[source] = nil
end

addEventHandler( "onClientPlayerQuit", root, onElementQuit )

setTimer(function()
	if getPedOccupiedVehicle(localPlayer) then return end
	local a=getPedAnimation(localPlayer)
	if (not a or a~="benchpress") then
		local tx, ty, tz = getWorldFromScreenPosition(screen.x / 2, screen.y / 2, 10)
		local lookAt = getElementData(localPlayer,"lookAt")
		if not(lookAt) then
			setElementData(localPlayer, "lookAt", { tx,ty,tz })
			lookAt = getElementData(localPlayer,"lookAt")
		end
		if lookAt[1] ~= tx or lookAt[2] ~= ty or  lookAt[3] ~= tz then
			local x,y,z = getPedBonePosition(localPlayer,8)
			setElementData(localPlayer, "lookAt", { tx,ty,tz })
			setPedAimTarget(localPlayer, lookAt[1], lookAt[2], lookAt[3])
			setPedLookAt(localPlayer,lookAt[1], lookAt[2], lookAt[3])
	  end
	end
	for v in pairs(streamPlayers) do
		if v ~= localPlayer and getElementDimension(localPlayer) == getElementDimension(v) and getElementInterior(localPlayer) == getElementInterior(v) then
			local lookAt = getElementData(v,"lookAt")
			local x,y,z = getPedBonePosition(v,8)
			setPedAimTarget(v, lookAt[1], lookAt[2], lookAt[3])
			setPedLookAt(v,lookAt[1], lookAt[2], lookAt[3])
		end
	end
end, 100, 0)