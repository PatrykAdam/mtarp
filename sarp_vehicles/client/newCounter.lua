--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = math.max(0.5, (screenX / 1920)), math.max(0.5, (screenY / 1080))
local counter = {}
counter.W, counter.H = 359 * scaleX, 295 * scaleX
counter.X, counter.Y = screenX - counter.W - 20 * scaleX, screenY - counter.H - 80 * scaleY
counter.tipW, counter.tipH = 147 * scaleX, 107 * scaleX
counter.tipX, counter.tipY = counter.X + counter.W/2 - counter.tipW + 16 * scaleX, counter.Y + 160 * scaleX
counter.minangle = -9
counter.iconW, counter.iconH = 38 * scaleX, 31 * scaleX
counter.engineX, counter.engineY = counter.X + (counter.W - counter.iconW * 4)/2, counter.Y + 125 * scaleX - counter.iconH/2
counter.handbrakeX, counter.handbrakeY = counter.engineX + counter.iconW, counter.engineY
counter.lightX, counter.lightY = counter.handbrakeX + counter.iconW, counter.handbrakeY
counter.emergencyX, counter.emergencyY = counter.lightX + counter.iconW, counter.lightY
counter.signW, counter.signH = 33 * scaleX, 27 * scaleX
counter.leftsignX, counter.leftsignY = counter.X + counter.W/2 - counter.signW - 5 * scaleX, counter.lightY + counter.signH
counter.rightsignX, counter.rightsignY = counter.X + counter.W/2 + 5 * scaleX, counter.lightY + counter.signH
counter.fuelX, counter.fuelY = counter.X + 225 * scaleX, counter.Y + 160 * scaleX
counter.numberW, counter.numberH = 132 * scaleX, 55 * scaleX
counter.numberX, counter.numberY = counter.X + 108 * scaleX, counter.Y + 233 * scaleX
counter.font = dxCreateFont( "assets/Speed-Crazy.ttf", 20 * scaleX )
counter.active = false

function counter.onRender()
	if not isPedInVehicle( localPlayer ) or getPedOccupiedVehicle( localPlayer ) == false then counter.active = false return removeEventHandler( "onClientRender", root, counter.onRender ) end
	local vehicle = getPedOccupiedVehicle( localPlayer )

	dxDrawImage( counter.X, counter.Y, counter.W, counter.H, "assets/licznik.png" )

	if getElementHealth( vehicle ) <= 300 then
		dxDrawImage( counter.engineX, counter.engineY, counter.iconW, counter.iconH, "assets/dmgsilnik.png" )
	else
		dxDrawImage( counter.engineX, counter.engineY, counter.iconW, counter.iconH, getVehicleEngineState( vehicle ) and "assets/onsilnik.png" or "assets/silnik.png" )
	end
	dxDrawImage( counter.handbrakeX, counter.handbrakeY, counter.iconW, counter.iconH, getElementData(vehicle, "vehicle:manual") and "assets/onreczny.png" or "assets/reczny.png" )
	dxDrawImage( counter.lightX, counter.lightY, counter.iconW, counter.iconH, getVehicleOverrideLights( vehicle ) == 2 and "assets/onswiatla.png" or "assets/swiatla.png" )

	local leftState, rightState, emergencyState = 0, 0, 0
	if getElementData(vehicle, "i:left") then
		leftState = indicatorData[getIndicatorID(vehicle)].state
	elseif getElementData(vehicle, "i:right") then
		rightState = indicatorData[getIndicatorID(vehicle)].state
	elseif getElementData(vehicle, "i:emergency") then
		emergencyState = indicatorData[getIndicatorID(vehicle)].state
	end
	dxDrawImage( counter.emergencyX, counter.emergencyY, counter.iconW, counter.iconH, emergencyState == 0 and "assets/awaryjne.png" or "assets/onawaryjne.png" )
	dxDrawImage( counter.leftsignX, counter.leftsignY, counter.signW, counter.signH, leftState == 0 and "assets/lewy.png" or "assets/onlewy.png" )
	dxDrawImage( counter.rightsignX, counter.rightsignY, counter.signW, counter.signH, rightState == 0 and "assets/prawy.png" or "assets/onprawy.png" )
	dxDrawImage( counter.fuelX, counter.fuelY, counter.iconW, counter.iconH, getElementData(vehicle, "vehicle:fuel") < 5.0 and "assets/onpaliwo.png" or "assets/paliwo.png" )

	dxDrawText( string.format("%012d", getElementData(vehicle, "vehicle:mileage")), counter.numberX, counter.numberY, counter.numberX + counter.numberW, counter.numberY + counter.numberH, tocolor(255, 255, 255), 1.0, counter.font, "center", "top" )
	dxDrawText( string.format("%d/%d L", getElementData(vehicle, "vehicle:fuel"), getVehicleMaxFuel(getElementModel(vehicle))), counter.numberX, counter.numberY + 27.5 * scaleX, counter.numberX + counter.numberW, 0, tocolor(255, 255, 255), 1.0, counter.font, "center", "top" )

	local speed = getElementSpeed(vehicle, 1)
	if speed > 260 then
		speed = 260
	end

	dxDrawImage( counter.tipX, counter.tipY, counter.tipW, counter.tipH, "assets/wskaznik.png", counter.minangle + (speed * 0.95), 56 * scaleX, -(38 * scaleX))
end

function counter.show(player, seat)
	if localPlayer ~= player then return end

	if getVehicleOccupant( getPedOccupiedVehicle( player ) ) and seat == 0 and not counter.active then
		addEventHandler( "onClientRender", root, counter.onRender )
		counter.active = true
	end
end

function counter.hide()
	if localPlayer ~= player then return end
	removeEventHandler( "onClientRender", root, counter.onRender )
	counter.active = false
end

addEventHandler( "onClientVehicleEnter", root, counter.show )
addEventHandler( "onClientVehicleExit", root, counter.hide )
addEventHandler( "onClientVehicleStartExit", root, counter.hide )
addEventHandler( "onClientPlayerVehicleExit", root, counter.hide )
addEventHandler( "onClientResourceStop", resourceRoot, counter.hide )