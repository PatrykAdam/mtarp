

Ccontrol = { data = {}, active = false}
Ccontrol.type = { ["Automobile"] = true, ["Monster Truck"] = true, ["Bike"] = true, ["Quad"] = true, ["Boat"] = true, ["Train"] = true }

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function Ccontrol.controlSetSpeed()
	local speed 
	if getKeyState( "num_add" ) then
		speed = math.round(Ccontrol.data.speed)+1.0
		if speed > 120 then
			Ccontrol.data.speed = 120
		else
			Ccontrol.data.speed = speed
		end
		print("[add] Set speed "..speed)
	elseif getKeyState( "num_sub" ) then
		speed = math.round(Ccontrol.data.speed)-1.0
		if speed < 35 then
			Ccontrol.data.speed = 35
		else
			Ccontrol.data.speed = speed
		end
	end
end

function Ccontrol.getElementSpeed(element, unit)
    assert(isElement(element), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(element) .. ")")
    local elementType = getElementType(element)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    local unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(element)) * mult).length
end

function Ccontrol.setElementSpeed(element, unit, speed)
	assert(isElement(element), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(element) .. ")")
	local elementType = getElementType(element)
	assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
	assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
	local unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
	local speed = tonumber(speed) or 0
	local acSpeed = Ccontrol.getElementSpeed(element, unit)
	if (acSpeed) then
		local diff = speed/acSpeed
		if diff ~= diff then return false end
		local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end
	return false
end

function Ccontrol.onClientRender()
	if isElement( Ccontrol.data.vehicle ) and isPedInVehicle( localPlayer ) then
		local vehicle = getPedOccupiedVehicle( localPlayer )
		if Ccontrol.getElementSpeed(vehicle, "km/h") >= 30 then
			if Ccontrol.active then
				Ccontrol.controlSetSpeed()
				if getTickCount(  )-Ccontrol.data.tick > 1000 and ( getPedControlState(localPlayer, "accelerate") or getPedControlState(localPlayer, "brake_reverse") or getPedControlState(localPlayer, "handbrake") ) then
					Ccontrol.toggle()
				else
					Ccontrol.setElementSpeed(Ccontrol.data.vehicle, "km/h", Ccontrol.data.speed)
				end
			end
		else
			if Ccontrol.active then
				Ccontrol.toggle()
			end
		end
	else
		Ccontrol.toggle()
	end
end

function Ccontrol.onVehicleDamage()
	if isElement( source ) and isElement( Ccontrol.data.vehicle ) and Ccontrol.data.vehicle == source then
		Ccontrol.toggle()
	end
end

function Ccontrol.toggle()
	if Ccontrol.active then
		Ccontrol.data.tick = nil
		Ccontrol.data.speed = nil
		Ccontrol.data.vehicle = nil
		removeEventHandler( "onClientRender", getRootElement(), Ccontrol.onClientRender)
		removeEventHandler("onClientVehicleDamage", root, Ccontrol.onVehicleDamage)
		Ccontrol.active = not Ccontrol.active
	elseif isPedInVehicle( localPlayer ) and not Ccontrol.active and Ccontrol.type[ getVehicleType( getPedOccupiedVehicle( localPlayer ) ) ]
	and getElementData(getPedOccupiedVehicle( localPlayer ), "vehicle:Ccontrol") then
		Ccontrol.data.tick = getTickCount(  )
		Ccontrol.data.vehicle = getPedOccupiedVehicle( localPlayer )
		Ccontrol.data.speed = Ccontrol.getElementSpeed(Ccontrol.data.vehicle, "km/h")
		addEventHandler( "onClientRender", getRootElement(), Ccontrol.onClientRender)
		addEventHandler("onClientVehicleDamage", root, Ccontrol.onVehicleDamage)
		Ccontrol.active = not Ccontrol.active
	end
end

bindKey("j", "down", Ccontrol.toggle)