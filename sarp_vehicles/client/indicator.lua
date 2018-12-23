--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local indicator = {}
indicatorData = {}

function indicator.switch( direction )
	local vehicle = getPedOccupiedVehicle( localPlayer )

	if vehicle and getVehicleOccupant( vehicle ) == localPlayer then
		if getElementData(vehicle, "i:left") or getElementData(vehicle, "i:right") or getElementData(vehicle, "i:emergency") then
			setElementData(vehicle, "i:left", false)
			setElementData(vehicle, "i:right", false)
			setElementData(vehicle, "i:emergency", false)
			return
		end
		setElementData(vehicle, string.format("i:%s", direction), true)
	end
end

function indicator.turnOff(element)
	for i = 0, 3 do
		setVehicleLightState( element, i, 0)
	end
end

function indicator.haveActive(vehicle)
	if getElementData(vehicle, "i:left") or getElementData(vehicle, "i:right") or getElementData(vehicle, "i:emergency") then
		table.insert(indicatorData, {element = vehicle, state = 0})
	else
		for i, v in ipairs(indicatorData) do
			if v.element == vehicle then
				indicator.turnOff(v.element)
				table.remove(indicatorData, i)
			end
		end
	end
end

function indicator.onStreamIn()
	if getElementType(source) == 'vehicle' then
		indicator.haveActive(source)
	end
end

addEventHandler( "onClientElementStreamIn", root, indicator.onStreamIn )

function indicator.onStreamOut()
	if getElementType(source) == 'vehicle' then
		for i, v in ipairs(indicatorData) do
			if v.element == source then
				indicator.turnOff(v.element)
				table.remove(indicatorData, i)
			end
		end
	end
end

addEventHandler( "onClientElementStreamOut", root, indicator.onStreamOut )

function indicator.onDataChange(dataName, oldValue)
	if getElementType( source ) == 'vehicle' then
		if dataName == 'i:left' or dataName == 'i:right' or dataName == 'i:emergency' then
			indicator.haveActive(source)
		end
	end
end

addEventHandler( "onClientElementDataChange", root, indicator.onDataChange )

function getIndicatorID(vehicle)
	for i, v in ipairs(indicatorData) do
		if v.element == vehicle then
			return i
		end
	end
end

function indicator.bind(key, state)
	if key == '[' then
		indicator.switch('left')
	elseif key == ']' then
		indicator.switch('right')
	elseif key == ';' then
		indicator.switch('emergency')
	end
end

function indicator.onStart()
	bindKey("[", "down", indicator.bind)
	bindKey("]", "down", indicator.bind)
	bindKey(";", "down", indicator.bind)

	setTimer(function()
		for i, v in ipairs(indicatorData) do
			if not isElement(v.element) then
				table.remove(indicatorData, i)
			else
				if getElementData(v.element, "i:left") then
					setVehicleLightState( v.element, 0, v.state)
					setVehicleLightState( v.element, 3, v.state)
				elseif getElementData(v.element, "i:right") then
					setVehicleLightState( v.element, 1, v.state)
					setVehicleLightState( v.element, 2, v.state)
				elseif getElementData(v.element, "i:emergency") then
					setVehicleLightState( v.element, 0, v.state)
					setVehicleLightState( v.element, 3, v.state)
					setVehicleLightState( v.element, 1, v.state)
					setVehicleLightState( v.element, 2, v.state)
				end
				indicatorData[i].state = v.state == 1 and 0 or 1
			end
		end
	end, 500, 0)
end

addEventHandler( "onClientResourceStart", resourceRoot, indicator.onStart)