--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

BlockedWeapons = {
	[38] = true,
}

function getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function onClientRenderAntyCheat()
	if isPedInVehicle( localPlayer ) then
		local vehicle = getPedOccupiedVehicle( localPlayer )
		if isElement(vehicle) and isVehicleOnGround ( vehicle ) and getElementSpeed(vehicle) > 300 then
			triggerServerEvent( "kickPlayer", localPlayer )
		end
	end
end

function onClientPlayerVehicleEnterAntyCheat(_, seat)
	if seat == 0 then
		addEventHandler( "onClientRender", root, onClientRenderAntyCheat )
	end
end
addEventHandler("onClientPlayerVehicleEnter",getRootElement(), onClientPlayerVehicleEnterAntyCheat)


function onClientPlayerVehicleExitAntyCheat(_, seat)
	if seat == 0 then
		removeEventHandler( "onClientRender", root, onClientRenderAntyCheat )
	end
end
addEventHandler("onClientPlayerVehicleStartExit",getRootElement(), onClientPlayerVehicleExitAntyCheat)

function onClientPlayerWeaponSwitchAntyCheat( prevSlot, newSlot )
	if BlockedWeapons[getPedWeapon(localPlayer, newSlot)]  then
		setPedWeaponSlot( localPlayer, 0 )
	end
end
addEventHandler ( "onClientPlayerWeaponSwitch", getRootElement(), onClientPlayerWeaponSwitchAntyCheat )