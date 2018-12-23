--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local death = {}
death.active = false

function death.hide()
	removeEventHandler( "onClientGUIClick", death.button[1], death.confirm, false )
  removeEventHandler( "onClientGUIClick", death.button[2], death.hide, false )
  showCursor( false )
  destroyElement( death.window )
  death.active = false
end

function death.confirm()
	local reason = tostring(guiGetText( death.label ))

	if string.len(reason) == 1 or string.len(reason) < 10 then
		return exports.sarp_notify:addNotify("Za mało znaków w powodzie zgonu.")
	end

	triggerServerEvent( "deathPlayer", localPlayer, reason )
end

function death.show()
	if death.active then return end
	showCursor( true )
	death.active = true
	death.window = guiCreateWindow((screenX - 309) / 2, (screenY - 138) / 2, 309, 138, "Uśmiercanie postaci", false)
  guiWindowSetSizable(death.window, false)

  death.label = guiCreateLabel(0.03, 0.16, 0.72, 0.12, "Powód zgonu:", true, death.window)
  guiSetFont(death.label, "default-bold-small")
  guiLabelSetVerticalAlign(death.label, "center")
  death.memo = guiCreateMemo(0.03, 0.28, 0.94, 0.44, "", true, death.window)
  death.button = {}
  death.button[1] = guiCreateButton(0.04, 0.79, 0.44, 0.14, "Zatwierdź", true, death.window)
  death.button[2] = guiCreateButton(0.53, 0.79, 0.44, 0.14, "Anuluj", true, death.window)

  addEventHandler( "onClientGUIClick", death.button[1], death.confirm, false )
  addEventHandler( "onClientGUIClick", death.button[2], death.hide, false )
end

addEvent('acceptDeath', true)
addEventHandler( 'acceptDeath', root, death.show )