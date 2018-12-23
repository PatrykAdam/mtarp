--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local playersData = {}

function setVehicleEngineStateEx(vehid, bool)
	if isTimer(playersData[source]) then return end
	local vehUID = getElementData(vehid, "vehicle:id")
	if not isVehicleOwner(source, vehUID) then
		return exports.sarp_notify:addNotify(source, 'Nie posiadasz kluczyków do tego pojazdu.')
	end
	if getElementHealth( vehid ) <= 300 then
		return exports.sarp_notify:addNotify(source, 'Nie możesz odpalić silnika z powodu uszkodzeń.')
	end

	if getElementData(vehid, "vehicle:fuel") <= 0 then
		return exports.sarp_notify:addNotify(source, 'Nie możesz odpalić silnika z powodu braku paliwa.')
	end

	if bool == true then
		playersData[source] = setTimer( function(vehid, bool, playerid)
			setVehicleEngineState(vehid, bool)
			killTimer( playersData[playerid] )
		end, 1000, 1, vehid, bool, source)
	else
		setVehicleEngineState( vehid, false )
	end
	vehiclesData[vehUID].engine = bool
end

addEvent("setVehicleEngineState", true)
addEventHandler( "setVehicleEngineState", root, setVehicleEngineStateEx )

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end