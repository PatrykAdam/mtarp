--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screen = Vector2( guiGetScreenSize() )
local active = false
local position

function Vector6(...)
	return {x = arg[1], y = arg[2], z = arg[3], lx = arg[4], ly = arg[5], lz = arg[6] }
end

function playerInPosition(ts)
	local camera = Vector6( getCameraMatrix() )
	camera.lx = camera.lx-camera.x
 	camera.ly = camera.ly-camera.y
 	ts = ts*0.1
 	local x, y, z = getWorldFromScreenPosition(screen.x / 2, screen.y / 2, 10)
 	if isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() or isTransferBoxActive () then
 		 if isPedInVehicle ( localPlayer ) then	
			local vehicle = getPedOccupiedVehicle( localPlayer )
			setElementPosition(vehicle,position)
		else
 			setElementPosition(localPlayer, position )
 		end
 	else
 		if getKeyState("space") then ts = ts*4 end
 		if getKeyState("lshift") or getKeyState("rshift") then ts = ts*0.25 end
 		local mult = ts/math.sqrt(camera.lx*camera.lx+camera.ly*camera.ly)
 		camera.lx = camera.lx*mult
 		camera.ly = camera.ly*mult
 		if getKeyState("w") then 
 			position.x = position.x+camera.lx
 			position.y = position.y+camera.ly
 		end
 	 	if getKeyState("s") then 
 			position.x = position.x-camera.lx
 			position.y = position.y-camera.ly
 		end	
 	 	if getKeyState("d") then 
 			position.x = position.x+camera.ly
 			position.y = position.y-camera.lx
 		end	
 	 	if getKeyState("a") then 
			position.x = position.x-camera.ly
 			position.y = position.y+camera.lx
 		end
 		if getKeyState("mouse1") then position.z = position.z+ts end
 		if getKeyState("mouse2") then position.z = position.z-ts end

 		 local angle = getPedCameraRotation( localPlayer )
 		 if isPedInVehicle ( localPlayer ) then	
			local vehicle = getPedOccupiedVehicle( localPlayer )
			setElementPosition(vehicle,position)
			setElementRotation(vehicle, 0, 0, -angle)
    	else
			setElementRotation(localPlayer, 0, 0, angle)
			setElementPosition(localPlayer, position)
		end
 	end
end


function activatedFly()
	if not exports.sarp_admin:getPlayerPermission(localPlayer, 512) then return end

	active = not active
	if active then
		if isPedInVehicle ( localPlayer ) then
			local vehicle = getPedOccupiedVehicle( localPlayer )
			position = Vector3( getElementPosition(vehicle) )
			setElementCollisionsEnabled ( vehicle, false )
			setVehicleEngineState(vehicle, false )	
			setElementFrozen(vehicle,true)
			setElementAlpha(localPlayer, 0)
		else
			position = Vector3( getElementPosition(localPlayer) )
			setElementCollisionsEnabled ( localPlayer, false )
			toggleControl( "aim_weapon", false )
		end
		addEventHandler("onClientPreRender", root, playerInPosition)
	else
		if isPedInVehicle ( localPlayer ) then
			local vehicle = getPedOccupiedVehicle( localPlayer )
			position = Vector3( getElementPosition(vehicle) )
			setElementCollisionsEnabled ( vehicle, true )	
			setElementFrozen(vehicle, false)
			setElementAlpha(localPlayer, 255)
		else
			position = Vector3( getElementPosition(localPlayer) )
			setElementCollisionsEnabled ( localPlayer, true )
			toggleControl( "aim_weapon", true )
		end
		removeEventHandler("onClientPreRender", root, playerInPosition)
	end
end
bindKey("0","down", activatedFly)