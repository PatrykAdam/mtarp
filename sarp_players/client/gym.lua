--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local gym = {}
gym.points = 0
gym.W, gym.H = 500 * scaleX, 150 * scaleX
gym.X, gym.Y = screenX - gym.W - 50 * scaleX, screenY - gym.H - 50 * scaleX
gym.keyBlock = 0
gym.lastKey = false

function gym.strengthRender()
	dxDrawRectangle( gym.X, gym.Y, gym.W, gym.H, tocolor( 0, 0, 0, 180 ))
	dxDrawText( string.format("Zdobyta siła: #FF0000%d\n#FFFFFFWyciśnięć: #FF0000%d\n\n#FFFFFFPrzytrzymaj #FFF000SPACE#FFFFFF aby unieść ciężar.", gym.points/gym.MAXpoints, gym.points), gym.X, gym.Y, gym.X + gym.W, gym.Y + gym.H, tocolor( 255, 255, 255, 255 ), 1.2, "default-bold", "center", "center", false, false, false, true )
end

function playerEarnStrength()
	local block, anim = getPedAnimation( localPlayer )

	if block ~= 'benchpress' then
		return false
	end
	return true
end

function gym.stopEarn()
	local block = getPedAnimation( localPlayer )
	if gym.machineType == 1 then
		if block == 'benchpress' then
			triggerServerEvent("setPedAnimation", localPlayer, "benchpress", "gym_bp_getoff", -1, false, false, false, false)
		end
		setTimer(triggerServerEvent, 2000, 1, "detachWeight", localPlayer)
		removeEventHandler( "onClientRender", root, gym.strengthRender )
		unbindKey("space", "both", gym.upBench)
		unbindKey("enter", "down", gym.stopEarn)
	elseif gym.machineType == 2 then
		if block == 'freeweights' then
			triggerServerEvent("setPedAnimation", localPlayer, "freeweights", "gym_free_putdown", -1, false, false, false, false)
		end
		setTimer(triggerServerEvent, 1000, 1, "detachWeight", localPlayer)
		removeEventHandler( "onClientRender", root, gym.strengthRender )
		unbindKey("space", "both", gym.upBarbell)
		unbindKey("enter", "down", gym.stopEarn)
	end
end

addEvent('stopEarnStrength', true)
addEventHandler( 'stopEarnStrength', root, gym.stopEarn )

function gym.upBench(key, state)
	if not playerEarnStrength then
		return gym.stopEarn()
	end

	if gym.keyBlock - 200 < getTickCount() then
		if gym.lastKey == state then return end
		if state == 'down' then
			gym.lastTick = getTickCount()
			triggerServerEvent("setPedAnimation", localPlayer, "benchpress", "gym_bp_up_A", -1, false, false)
			gym.timer = setTimer(function()
				gym.points = gym.points + 1
				
				if gym.points % gym.MAXpoints == 0 then
					triggerServerEvent( "addStrength", localPlayer )
				end
			end, 2500, 1)
		end
		if state == 'up' then
			if isTimer( gym.timer ) then
				killTimer( gym.timer )
			end
			local progress = math.min(math.max(1.0 - (getTickCount() - gym.lastTick)/2500, 0.0), 1.0)

			triggerServerEvent("setPedAnimation", localPlayer, "benchpress", "gym_bp_down", -1, false, false, nil, nil, nil, progress)
			
			gym.keyBlock = getTickCount() + ((1.0 - progress)* 1400)
		end
		gym.lastKey = state
	end
end

function gym.upBarbell(key, state)
	if not playerEarnStrength then
		return gym.stopEarn()
	end

	if gym.keyBlock - 200 < getTickCount() then
		if gym.lastKey == state then return end
		if state == 'down' then
			gym.lastTick = getTickCount()
			triggerServerEvent("setPedAnimation", localPlayer, "freeweights", "gym_free_a", -1, false, false)
			gym.timer = setTimer(function()
				gym.points = gym.points + 1
				
				if gym.points % gym.MAXpoints == 0 then
					triggerServerEvent( "addStrength", localPlayer )
				end
			end, 1500, 1)
		end
		if state == 'up' then
			if isTimer( gym.timer ) then
				killTimer( gym.timer )
			end
			local progress = math.min(math.max(1.0 - (getTickCount() - gym.lastTick)/1500, 0.0), 1.0)

			triggerServerEvent("setPedAnimation", localPlayer, "freeweights", "gym_free_down", -1, false, false, nil, nil, nil, progress)
			
			gym.keyBlock = getTickCount() + ((1.0 - progress)* 800)
		end
		gym.lastKey = state
	end
end

function gym.startBench(elementID)
	local oX, oY, oZ = getElementPosition( elementID )
	local oRX, oRY, oRZ = getElementRotation( elementID )

	local ran = math.rad(oRZ + 180)
	local pX, pY = oX + math.sin(-ran), oY + math.cos(-ran)
	setElementPosition( localPlayer, pX, pY, oZ + 1.0 )
	setElementRotation( localPlayer, 0, 0, oRZ )
	triggerServerEvent("setPedAnimation", localPlayer, "benchpress", "gym_bp_geton", -1, false, false)
	setTimer(triggerServerEvent, 4000, 1, "attachWeight", localPlayer, 1 )
	gym.keyBlock = getTickCount() + 4000
	bindKey("space", "both", gym.upBench)
	bindKey("enter", "down", gym.stopEarn)
	addEventHandler( "onClientRender", root, gym.strengthRender )
end

function gym.startBarbell(elementID)
	local oX, oY, oZ = getElementPosition( elementID )
	local oRX, oRY, oRZ = getElementRotation( elementID )
	local pX, pY, pZ = getElementPosition( localPlayer )

	local ran = math.rad(oRZ + 180)
	pX, pY = oX + math.sin(-ran), oY + math.cos(-ran)
	setElementPosition( localPlayer, pX, pY, pZ )
	setElementRotation( localPlayer, 0, 0, oRZ )
	triggerServerEvent("setPedAnimation", localPlayer, "freeweights", "gym_free_pickup", -1, false, false)
	setTimer(triggerServerEvent, 2000, 1, "attachWeight", localPlayer, 2 )
	gym.keyBlock = getTickCount() + 2000
	bindKey("space", "both", gym.upBarbell)
	bindKey("enter", "down", gym.stopEarn)
	addEventHandler( "onClientRender", root, gym.strengthRender )
end

function gym.earnStrength()
	local findMachine = gym.searchObject()

	if not findMachine or not isElement(findMachine) then
		return exports.sarp_notify:addNotify("Nie znaleziono w pobliżu maszyny do ćwiczeń.")
	end

	local oX, oY, oZ = getElementPosition( findMachine )
	local inUse = false

	for i, v in ipairs( getElementsByType( "player", nil, true )) do
		local pX, pY, pZ = getElementPosition( v )

		if localPlayer ~= v and getElementData(v, "player:earnStrength") == true and getDistanceBetweenPoints3D( oX, oY, oZ, pX, pY, pZ ) < 3.0 then
			inUse = true
			break
		end
	end

	if inUse then
		return exports.sarp_notify:addNotify("Ta maszyna do ćwiczeń jest już przez kogoś zajęta.")
	end

	gym.points = 0
	if getElementModel(findMachine) == 2629 then
		gym.MAXpoints = 10
		gym.machineType = 1
		gym.startBench(findMachine)
	elseif getElementModel(findMachine) == 2915 then
		gym.MAXpoints = 15
		gym.machineType = 2
		gym.startBarbell(findMachine)
	end
end

addEvent('earnStrength', true)
addEventHandler( 'earnStrength', root, gym.earnStrength)

function gym.searchObject()
	local findMachine = false

	local pX, pY, pZ = getElementPosition( localPlayer )
	local lastDistance = 3.0
	for i, v in ipairs(getElementsByType( "object", nil, true )) do
		local oX, oY, oZ = getElementPosition( v )
		if getDistanceBetweenPoints3D( oX, oY, oZ, pX, pY, pZ ) < lastDistance and (getElementModel( v ) == 2629 or getElementModel(v) == 2915) then
			findMachine = v
			lastDistance = getDistanceBetweenPoints3D( oX, oY, oZ, pX, pY, pZ )
		end
	end

	return findMachine
end

local function setPedAnimationProgressEx(anim, progress)
	if not isElement(source) or not isElementStreamedIn(source) then return end
	setPedAnimationProgress(source, anim, progress)
end

addEvent('setPedAnimationProgress', true)
addEventHandler( 'setPedAnimationProgress', root, setPedAnimationProgressEx )