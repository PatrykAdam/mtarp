--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local walk = {}
walk.lastTick = 0
walk.staminaMAX = 30.0
walk.stamina = 30.0
walk.key = {'forwards', 'walk', 'backwards', 'left', 'right', 'space'}

function walk.onFunc(button, pressed)
	if pressed == "down" then
		if getKeyState ( "space" ) then
			setControlState( "walk", false )
			setControlState( "sprint", false )
			setControlState( button, true )
		
			local time = getTickCount() - walk.lastTick

			if time <= 500 and walk.stamina > 0 and button == 'space' then
				if isTimer(walk.timer) then
					killTimer( walk.timer )
				end
				walk.stamina = walk.stamina - 1
				setControlState( "sprint", true )
				walk.timer = setTimer( setControlState, 500, 1, "sprint", false)
			end
			walk.lastTick = getTickCount()
		else
			setControlState( "walk", true )
		end

	end
	if pressed == 'up' then
			setControlState( button, false )
			if not getKeyState( "space" ) then
				setControlState( "walk", true )
			end
	end
end

function walk.onRender()
	if walk.lastTick + 1000 < getTickCount() and walk.stamina ~= 30 and not getControlState( "sprint" ) then
		walk.lastTick = getTickCount()
		walk.stamina = walk.stamina + 1

		--[[
		local block, anim = getPedAnimation( localPlayer )
		if walk.stamina <= 10 and block ~= 'ped' and anim ~= 'idle_tired' and not getControlState( "forwards" ) then
			triggerServerEvent("setPedAnimation", localPlayer, "ped", "idle_tired", -1, false, false, false, true )
		end

		if walk.stamina > 10 and block == 'ped' and anim == 'idle_tired' or getControlState( "forwards" ) then
		 triggerServerEvent("setPedAnimation", localPlayer )
		end]]
	end
end

addEventHandler( "onClientRender", root, walk.onRender )

function walk.onJoin()
	for i, v in ipairs(walk.key) do
		unbindKey( v )
		bindKey( v, "both", walk.onFunc )
	end
end

addEventHandler( "onClientResourceStart", resourceRoot, walk.onJoin )

function walk.onQuit()
	for i, v in ipairs(walk.key) do
		unbindKey( v, "both", walk.onFunc )
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, walk.onQuit )