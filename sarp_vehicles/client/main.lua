--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local vehicles = {}

vehicles.last = false

function vehicles.onEnter(playerid, seat)
	setRadioChannel(0) 
  addEventHandler('onClientPlayerRadioSwitch', root, function() cancelEvent() end )

  if playerid == localPlayer and seat == 0 then
		setTimer(function()
			backCar()
			bindKey("brake_reverse", "down", backCar)
		end, 100, 1)
	end
end

addEventHandler( "onClientVehicleEnter", root, vehicles.onEnter )

function vehicles.onStartExit(playerid, seat)
	if playerid == localPlayer and seat == 0 then

	end
end

addEventHandler( "onClientVehicleStartExit", root, vehicles.onStartExit )

function vehicles.onExit(playerid, seat)
	if playerid == localPlayer and seat == 0 then
		unbindKey("brake_reverse", "down", backCar)
	end
end

addEventHandler( "onClientVehicleExit", root, vehicles.onExit )

function backCar()
	local vehicle = getPedOccupiedVehicle( localPlayer )
	if not vehicle then return end
	local engine = getVehicleEngineState( vehicle )

		toggleControl( "brake_reverse", engine )
end

local vehicleColor = {}

function vehicles.admcolor(UID)
	vehicleColor.uid = UID
	exports.colorpicker:openPicker('color1', "#FFFFFF", "Wybierz kolor 1")
end

addEvent("vehicle:admcolor", true)
addEventHandler( "vehicle:admcolor", localPlayer, vehicles.admcolor )

function vehicles.picker(element, hex, r, g, b)

	if element == 'color1' then
		vehicleColor.col1 = {r, g, b}
		exports.colorpicker:openPicker('color2', "#FFFFFF", "Wybierz kolor 2")
	end

	if element == 'color2' then
		vehicleColor.col2 = {r, g, b}
		triggerServerEvent( "vehicle:changecolor", localPlayer, vehicleColor.uid, vehicleColor.col1, vehicleColor.col2)
		vehicleColor = {}
	end
end

addEventHandler("onColorPickerOK", root, vehicles.picker)

addEventHandler ( "onClientVehicleExplode", getRootElement(), cancelEvent )