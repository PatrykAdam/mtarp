local force = {}
local fall = {}
local alcohol = {}

function randomChance(percent)
  assert(percent >= 0 and percent <= 100)
  return percent >= math.random(1, 100) 
end

function getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function forceClear()
	force.startTime = nil
	force.controlState = nil
end

function forceControlState(controlState, forceMultipler)
	if not force.startTime then
		force.controlState = controlState
		force.nowTime = getTickCount(  )
		force.startTime = getTickCount(  )
		if isPedInVehicle( localPlayer ) then
			force.endTime = force.startTime + (math.random(1,2)*1000)
		else
			force.endTime = force.startTime + (1*100)
		end
	end
	if force.controlState then
		local duration = force.endTime-force.startTime
		local now = getTickCount(  )-force.nowTime
		if isPedInVehicle( localPlayer ) then
			if now < duration then
				if randomChance(25+forceMultipler) and force.controlState ~= "brake_reverse" then
					setPedControlState( localPlayer, force.controlState, true)
				elseif force.controlState ~= "brake_reverse" then
					setPedControlState( localPlayer, force.controlState, false)
				else
					setPedControlState( localPlayer, force.controlState, true)
				end
			else
				setPedControlState( localPlayer, force.controlState, false)
				force.startTime = nil
				force.controlState = nil
			end
		else
			if now < duration then
				setPedControlState( localPlayer, force.controlState, true)
			else
				setPedControlState( localPlayer, force.controlState, false)
				force.startTime = nil
				force.controlState = nil	
			end
		end
	end
end

function onChangeControl()
	if getPedWalkingStyle ( localPlayer ) ~= 126 then
		triggerServerEvent( "setDrunkWalkStyle", localPlayer )
		return
	end
	alcohol.take();
	if isPedInVehicle( localPlayer ) then
		local vehicle = getPedOccupiedVehicle( localPlayer )
		local drunkLevel = getElementData(localPlayer,"drunkLevel") or 0.0;
		if isElement(vehicle) and getElementSpeed(vehicle, 1.0) > 0 then
			if getControlState( localPlayer, "accelerate" ) == true or getControlState( localPlayer, "brake_reverse" ) == true then
				if randomChance(5+drunkLevel) then
					if getControlState( localPlayer, "brake_reverse" ) then
						forceControlState("accelerate", drunkLevel)
					else
						forceControlState("brake_reverse", drunkLevel)
					end
				elseif randomChance(25+drunkLevel) then
					forceControlState("vehicle_left", drunkLevel)
				elseif randomChance(25+drunkLevel) then
					forceControlState("vehicle_right", drunkLevel)
				end
			end
		elseif isElement(vehicle) and getElementSpeed(vehicle, 1.0) <= 0 then
			forceClear()
		end
	else
		local drunkLevel = getElementData(localPlayer,"drunkLevel") or 0.0;
		if fall.time and getTickCount(  )-fall.time > 1000 then
			triggerServerEvent( "FallDrunkAnimation", localPlayer, true )
			fall.time = nil
		end
		if getPedMoveState ( localPlayer ) == "jump" then
			if randomChance(25+drunkLevel) then
				if not fall.time then
					fall.time = getTickCount(  )
					triggerServerEvent( "FallDrunkAnimation", localPlayer )
					setElementHealth( localPlayer, getElementHealth( localPlayer ) - math.random(1, 20) )
				end
			end
		elseif getControlState( localPlayer, "forwards" ) == true or getControlState( localPlayer, "backwards" ) == true or getControlState( localPlayer, "sprint" ) == true then
			if randomChance(15+drunkLevel) then
				local random = math.random(1,3)
				if random == 1 then
					forceControlState("left", drunkLevel)
				elseif random == 2 then
					forceControlState("right", drunkLevel)
				end
			end
		end
	end
end

--
alcohol.lastTick = 0

function alcohol.take()
	if not alcohol.startTime then
		alcohol.lastTickTake = getTickCount(  )
		alcohol.nowTime = getTickCount(  )
		alcohol.startTime = getTickCount(  )
		alcohol.endTime = alcohol.startTime + (math.random(2,4)*60000)
	end
	local duration = alcohol.endTime-alcohol.startTime
	local now = getTickCount(  )-alcohol.nowTime
	if now < duration then
		if getTickCount(  )-alcohol.lastTickTake > 1000 then
			local drunkLevel = getElementData(localPlayer,"drunkLevel");
			if drunkLevel > 0 then
				setElementData(localPlayer, "drunkLevel", drunkLevel-( math.random(1,5) )/100 )

				if drunkLevel-( math.random(1,5) )/100 < 0 then
					triggerServerEvent( "changeWalkingStyle", localPlayer, getElementData( localPlayer, "player:walkStyle" ) )
				end
			else
				setElementData(localPlayer, "drunkLevel", 0.0 )
				triggerServerEvent( "changeWalkingStyle", localPlayer, getElementData( localPlayer, "player:walkStyle" ) )
			end
			alcohol.lastTickTake = getTickCount(  )
		end
	else
		setElementData(localPlayer, "drunkLevel", 0.0)
		triggerServerEvent( "changeWalkingStyle", localPlayer, getElementData( localPlayer, "player:walkStyle" ) )
		alcohol.startTime = nil
	end
end


function alcohol.onKey(button, press)
	if press == true then
		if button == "mouse1" then
			if alcohol.lastTick + 2000 < getTickCount() then
				toggleControl( "fire", false )
				triggerServerEvent( "eatAlcohol", localPlayer )
				alcohol.lastTick = getTickCount()
			end
		end
		if button == "mouse2" then
			triggerServerEvent( "putAlcohol", localPlayer, localPlayer )
		end
	end
end

function alcohol.stopUse()
	removeEventHandler( "onClientKey", root, alcohol.onKey)
end

addEvent('endAlcohol', true)
addEventHandler( 'endAlcohol', localPlayer, alcohol.stopUse )

function alcohol.use()
	addEventHandler( "onClientKey", root, alcohol.onKey)
end

addEvent("useAlcohol", true)
addEventHandler( "useAlcohol", localPlayer, alcohol.use ) 