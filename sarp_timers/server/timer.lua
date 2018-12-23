--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local function minute()
	local hour, minute = getRealTime().hour, getRealTime().minute
	--timer graczy
	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData(v, "player:logged") then
			local minutes, hours, score = getElementData(v, "player:minutes"), getElementData( v, "player:hours" ), getElementData( v, "global:score" )
			
			local duty = getElementData(v, "player:duty")

			if not getElementData(v, "player:afk") then
				if duty then
					for j = 1, 3 do
							if getElementData(v, "group_".. j ..":id") == duty then
								setElementData(v, "group_".. j ..":duty_time", getElementData(v, "group_".. j ..":duty_time") + 1)
							end
					end
				end
			end

			setElementData(v, "player:online_today", getElementData(v, "player:online_today") + 1)

			if getElementData(v, "player:online_today") == 30 then
				local work = false

				for j = 1, 3 do
					if getElementData(v, "group_".. j ..":id") then
						work = true
						break
					end
				end

				if not work then
					exports.sarp_notify:addNotify(v, "Otrzymujesz 70$ dziennego zasiłku dla bezrobotnych.")
					setElementData(v, "player:bank", getElementData(v, "player:bank") + 70)
				end
			end

			if minutes <= 60 then
				setElementData(v, "player:minutes", minutes+1)
			else
				setElementData(v, "player:minutes", 0)
				setElementData(v, "player:hours", hours+1)

				setElementData(v, "global:score", score+1)
			end
		end
	end
end

setTimer( minute, 60000, 0 )

function second()
	for i, v in ipairs(getElementsByType( "player")) do
		if getElementData(v, "player:logged") then
			local bw = getElementData(v, "player:bw")
			if bw and bw > 0 then
				setElementData(v, "player:bw", bw - 1)
			end
			local aj = getElementData(v, "player:aj")
			if aj and aj > 0 then
				setElementData(v, "player:aj", aj - 1)
			end
		end
	end
	for i, v in ipairs(getElementsByType( "vehicle" )) do
		local playerid = getVehicleOccupant( v )
		if getVehicleEngineState(v) == true then
			if getElementHealth( v ) <= 300 then
				if isElement(playerid) then
					exports.sarp_notify:addNotify(playerid, "Silnik zgasł z powodu uszkodzeń silnika.")
				end
				setVehicleEngineState( v, false )
				exports.sarp_vehicles:setVehicleData(v, "engine", false)
			end

			local speed = getElementSpeed(v, 0)
			local fuel = getElementData(v, "vehicle:fuel")
			if fuel <= 0 then
				if isElement(playerid) then
					exports.sarp_notify:addNotify(v, "Silnik zgasł z powodu braku paliwa.")
				end
				setVehicleEngineState( v, false )
			end

			local useFuel = 0

			if speed < 10 then
				useFuel = 0.001
			elseif speed < 20 then
				useFuel = 0.002
			elseif speed < 40 then
				useFuel = 0.005
			elseif speed < 80 then
				useFuel = 0.01
			elseif speed < 140 then
				useFuel = 0.012
			elseif speed < 180 then
				useFuel = 0.015
			else
				useFuel = 0.02
			end

			setElementData(v, "vehicle:fuel", fuel - useFuel)
			setElementData(v, "vehicle:mileage", getElementData(v, "vehicle:mileage") + (speed * 0.001))
		end

		local repairTime = getElementData(v, "vehicle:repairTime")

		if repairTime then
			if not (isElement(getElementData(v, "vehicle:repairMechanic")) or isElement(getElementData(v, "vehicle:repairOwner"))) then
				removeElementData( v, "vehicle:repairTime" )
				triggerEvent('cancelRepair', root, v)
			end

			if repairTime > 0 then
				setElementData(v, "vehicle:repairTime", repairTime - 1)
			else
				removeElementData( v, "vehicle:repairTime")
				triggerEvent("repairFinish", root, v)
			end
		end
	end
end

setTimer( second, 1000, 0 )

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end