--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local anim = {}
anim.lastTick = false
anim.rz = false

function anim.onRender()
	if getPedAnimation( localPlayer ) and getElementData(localPlayer, "player:anim") then
		if not getKeyState( "lshift") and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() and getKeyState( "w" ) then
			if not anim.lastTick then
				local px, py, pz, lx, ly, lz = getCameraMatrix()
				anim.lastTick = getTickCount()
				anim.rz = findRotation( px, py, lx, ly )
				local rx, ry, rz = getElementRotation( localPlayer )
				anim.oldrz = rz
			end
			local progress = (getTickCount() - anim.lastTick) / 500
			local newRot = interpolateBetween( anim.oldrz, 0, 0, anim.rz, 0, 0, progress, "Linear" )
			setElementRotation( localPlayer, 0, 0, newRot )
		elseif anim.lastTick then
			anim.lastTick = false
		end

		if not getKeyState( "lshift" ) then
			dxDrawText( "Naciśnij spacje aby anulować animacje.", screenX/2, screenY - 100, screenX/2, screenY, tocolor(255, 255, 255), 2, "default-bold", "center", "center" )
		else
			dxDrawText( "Użyj w,a,s,d oraz num + i - do poruszania.", screenX/2, screenY - 100, screenX/2, screenY, tocolor(255, 255, 255), 2, "default-bold", "center", "center" )
		
			local sPos = getElementData(localPlayer, "player:anim")
			if getKeyState( "w" ) then
				local x, y, z = getPositionFromElementOffset(localPlayer, 0, 0.01, 0)
				if getDistanceBetweenPoints3D( sPos[1], sPos[2], sPos[3], x, y, z ) < 2.0 then
					setElementPosition( localPlayer, x, y, z, false)
				end
			end
			if getKeyState( "s" ) then
				local x, y, z = getPositionFromElementOffset(localPlayer, 0, -0.01, 0)
				if getDistanceBetweenPoints3D( sPos[1], sPos[2], sPos[3], x, y, z ) < 2.0 then
					setElementPosition( localPlayer, x, y, z, false)
				end
			end
			if getKeyState( "a" ) then
				local x, y, z = getPositionFromElementOffset(localPlayer, -0.01, 0, 0)
				if getDistanceBetweenPoints3D( sPos[1], sPos[2], sPos[3], x, y, z ) < 2.0 then
					setElementPosition( localPlayer, x, y, z, false)
				end
			end
			if getKeyState( "d" ) then
				local x, y, z = getPositionFromElementOffset(localPlayer, 0.01, 0, 0)
				if getDistanceBetweenPoints3D( sPos[1], sPos[2], sPos[3], x, y, z ) < 2.0 then
					setElementPosition( localPlayer, x, y, z, false)
				end
			end
			if not getKeyState( "num_add" ) then
				local x, y, z = getElementPosition( localPlayer )
				if getDistanceBetweenPoints3D( sPos[1], sPos[2], sPos[3], x, y, z - 0.01 ) < 2.0 then
					setElementPosition( localPlayer, x, y, z  - 0.01, false)
				end
			end
			if not getKeyState( "num_sub" ) then
				local x, y, z = getElementPosition( localPlayer )
				if getDistanceBetweenPoints3D( sPos[1], sPos[2], sPos[3], x, y, z + 0.01 ) < 2.0 then
					setElementPosition( localPlayer, x, y, z + 0.01, false)
				end
			end
		end
	end
end

addEventHandler( "onClientRender", root, anim.onRender )

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end