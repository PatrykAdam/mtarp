--------------------------------------------------------------------------------------------------
-- Distributed under the Creative Commons Attribution-NonCommercial 4.0 International license	--
-- Version:				(release) 1.0.0															--
-- Original author: 	Kacper "MrTasty (aka Addon)" Stasiak									--
-- Special thanks to: 	Doomed_Space_Marine (useful functions)									--
--						robhol (useful functions)												--
--------------------------------------------------------------------------------------------------

--Features
local enableBlips = true
local renderNorthBlip = true
local alwaysRenderMap = false --true = always render map, false = only render when in interior world 0 (radar will stay, only the map will stop rendering)

--Dimensions & Sizes
local worldW, worldH = 3072, 3072 --map image dimensions - if map image changed, please edit appropriately
local blip = 12 --Blip size, pixels relative to 1366x768 resolution




------------------------------------------------------------------------------------
--Do not modify anything below unless you're absolutely sure of what you're doing.--
------------------------------------------------------------------------------------

local sx, sy = guiGetScreenSize()
local rt = dxCreateRenderTarget(290, 175)
local xFactor, yFactor = sx/1366, sy/768
local yFactor = xFactor --otherwise the radar looses it's 2:3 ratio.
local isActive = false



-- Useful functions --
function findRotation(x1,y1,x2,y2) --Author: Doomed_Space_Marine & robhol
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
end
function getPointFromDistanceRotation(x, y, dist, angle) --Author: robhol
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function drawRadar()
	if (not isPlayerMapVisible() and isActive and getElementData(localPlayer, "player:logged") and not getElementData(localPlayer, "busTravel")) then
		local mW, mH = dxGetMaterialSize(rt)
		local x, y = getElementPosition(localPlayer)
		local X, Y = mW/2 -(x/(6000/worldW)), mH/2 +(y/(6000/worldH))
		local camX,camY,camZ = getElementRotation(getCamera())
		dxSetRenderTarget(rt, true)
		if alwaysRenderMap or getElementInterior(localPlayer) == 0 then
			dxDrawRectangle(0, 0, mW, mH, 0xFF7CA7D1) --render background
			dxDrawImage(X - worldW/2, mH/5 + (Y - worldH/2), worldW, worldH, "image/world.jpg", camZ, (x/(6000/worldW)), -(y/(6000/worldH)), tocolor(255, 255, 255, 255))
		end
		dxSetRenderTarget()
		dxDrawRectangle((20)*xFactor, sy-((220+10))*yFactor, (300)*xFactor, (185)*yFactor, tocolor(0, 0, 0, 175))
		dxDrawImage((20+5)*xFactor, sy-((220+5))*yFactor, (300-10)*xFactor, (175)*yFactor, rt, 0, 0, 0, tocolor(255, 255, 255, 150))
		local r, g, b
		local rx, ry, rz = getElementRotation(localPlayer)
		local lB = (25)*xFactor
		local rB = (25+290)*xFactor
		local tB = sy-(225)*yFactor
		local bB = tB + (175)*yFactor
		local cX, cY = (rB+lB)/2, (tB+bB)/2 +(35)*yFactor
		local toLeft, toTop, toRight, toBottom = cX-lB, cY-tB, rB-cX, bB-cY
		for k, v in ipairs(getElementsByType("blip")) do
			local bx, by = getElementPosition(v)
			local actualDist = getDistanceBetweenPoints2D(x, y, bx, by)
			local maxDist = getBlipVisibleDistance(v)
			if actualDist <= maxDist and getElementDimension(v)==getElementDimension(localPlayer) and getElementInterior(v)==getElementInterior(localPlayer) then
				local dist = actualDist/(6000/((worldW+worldH)/2))
				local rot = findRotation(bx, by, x, y)-camZ
				local bpx, bpy = getPointFromDistanceRotation(cX, cY, math.min(dist, math.sqrt(toTop^2 + toRight^2)), rot)
				local bpx = math.max(lB, math.min(rB, bpx))
				local bpy = math.max(tB, math.min(bB, bpy))
				local bid = getElementData(v, "customIcon") or getBlipIcon(v)
				local _, _, _, bcA = getBlipColor(v)
				local bcR, bcG, bcB = 255, 255, 255
				if getBlipIcon(v) == 0 then
					bcR, bcG, bcB = getBlipColor(v)
				end
				local bS = getBlipSize(v)
				dxDrawImage(bpx -(blip*bS)*xFactor/2, bpy -(blip*bS)*yFactor/2, (blip*bS)*xFactor, (blip*bS)*yFactor, "image/blip/"..bid..".png", 0, 0, 0, tocolor(bcR, bcG, bcB, bcA))
			end
		end
		if renderNorthBlip then
			local rot = -camZ+180
			local bpx, bpy = getPointFromDistanceRotation(cX, cY, math.sqrt(toTop^2 + toRight^2), rot) --get position
			local bpx = math.max(lB, math.min(rB, bpx))
			local bpy = math.max(tB, math.min(bB, bpy)) --cap position to screen
			local dist = getDistanceBetweenPoints2D(cX, cY, bpx, bpy) --get distance to the capped position
			local bpx, bpy = getPointFromDistanceRotation(cX, cY, dist, rot) --re-calculate position based on new distance
			if bpx and bpy then --if position was obtained successfully
				local bpx = math.max(lB, math.min(rB, bpx))
				local bpy = math.max(tB, math.min(bB, bpy)) --cap position just in case
				dxDrawImage(bpx -(blip*2)/2, bpy -(blip*2)/2, blip*2, blip*2, "image/blip/4.png", 0, 0, 0) --draw north (4) blip
			end
		end
		dxDrawImage(cX -(blip*2)*xFactor/2, cY -(blip*2)*yFactor/2, (blip*2)*xFactor, (blip*2)*yFactor, "image/player.png", camZ-rz, 0, 0)
	end
end
addEventHandler("onClientRender", root, drawRadar)

function showRadar(boolean)
	if type(boolean) == 'boolean' then
		isActive = boolean
		return
	end
	
	isActive = false
end

addEvent('showRadar', true)
addEventHandler( 'showRadar', root, showRadar )