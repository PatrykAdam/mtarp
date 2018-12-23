--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local audio = {}
local soundElement = false

function audio.onEnter(player)
	if player == localPlayer then
		if getElementData(source, "vehicle:audio") then
			soundElement = playSound( getElementData(source, "vehicle:url"), true)
			setSoundVolume( soundElement, 0.5 )
		end
	end
end

addEventHandler( "onClientVehicleEnter", root, audio.onEnter )

function audio.onExit(player)
	if player == localPlayer then
		if isElement(soundElement) then
			stopSound( soundElement )
		end
	end
end

addEventHandler( "onClientVehicleExit", root, audio.onExit )

function audio.update(URL)
	audio.onExit(localPlayer)
	triggerEvent( "onClientVehicleEnter", getPedOccupiedVehicle( localPlayer ), localPlayer )
end

addEvent('updateVehicleURL', true)
addEventHandler( 'updateVehicleURL', root, audio.update )

function audio.hide()
	removeEventHandler( "onClientGUIClick", audio.button[1], audio.changeURL, false)
	removeEventHandler( "onClientGUIClick", audio.button[2], audio.hide, false)
	showCursor( false )
	destroyElement( audio.window )
end

function audio.changeURL()
	local url = tostring(guiGetText( audio.edit ))
	triggerServerEvent( 'newVehicleURL', localPlayer, audio.vehicle, url )
	audio.hide()
end

function audio.show(vehUID, url)
	if isElement(audio.window) then audio.hide() end
	audio.vehicle = vehUID
	showCursor( true )
	audio.window = guiCreateWindow((screenX - 283) / 2, (screenY - 102) / 2, 283, 102, "System audio", false)
  guiWindowSetSizable(audio.window, false)

  audio.label = guiCreateLabel(10, 24, 205, 24, "Adres do muzyki:", false, audio.window)
  guiSetFont(audio.label, "default-bold-small")
  audio.edit = guiCreateEdit(11, 44, 262, 20, url, false, audio.window)
  audio.button = {}
  audio.button[1] = guiCreateButton(19, 70, 104, 22, "Zmień", false, audio.window)
  audio.button[2] = guiCreateButton(159, 70, 104, 22, "Anuluj", false, audio.window)

  addEventHandler( "onClientGUIClick", audio.button[1], audio.changeURL, false)
	addEventHandler( "onClientGUIClick", audio.button[2], audio.hide, false)
end

addEvent('changeVehicleURL', true)
addEventHandler( 'changeVehicleURL', root, audio.show )