--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local fuel = {}
fuel.active = false

function fuel.hide()
	removeEventHandler( "onClientGUIClick", fuel.button[1], fuel.buy, false )
  removeEventHandler( "onClientGUIClick", fuel.button[2], fuel.hide, false )
  destroyElement( fuel.window )
  fuel.active = false
  showCursor( false )
end

function fuel.buy()
	local fuels = tonumber(guiGetText( fuel.edit ))

	if not fuels then
		return exports.sarp_notify:addNotify("Niepoprawna wartość paliwa.")
	end

	triggerServerEvent( "buyFuel", localPlayer, fuels )
	fuel.hide()
end

function fuel.show()
	if fuel.active then fuel.hide() end

	showCursor( true )
	fuel.active = true
	fuel.window = guiCreateWindow((screenX - 237) / 2, (screenY - 120) / 2, 237, 120, "Tankowanie pojazdu", false)
  guiWindowSetSizable(fuel.window, false)

  fuel.label = {}
  fuel.label[1] = guiCreateLabel(0.03, 0.21, 0.95, 0.15, "Ilość paliwa(w litrach):", true, fuel.window)
  guiLabelSetHorizontalAlign(fuel.label[1], "center", false)
  fuel.edit = guiCreateEdit(0.25, 0.36, 0.48, 0.18, "", true, fuel.window)
  fuel.label[2] = guiCreateLabel(0.04, 0.58, 0.75, 0.13, "Zapłacisz za to: 0$", true, fuel.window)
  guiSetFont(fuel.label[2], "default-bold-small")
  fuel.button = {}
  fuel.button[1] = guiCreateButton(0.07, 0.77, 0.41, 0.14, "Zapłać", true, fuel.window)
  fuel.button[2] = guiCreateButton(0.51, 0.77, 0.41, 0.14, "Anuluj", true, fuel.window)  


  addEventHandler( "onClientGUIClick", fuel.button[1], fuel.buy, false )
  addEventHandler( "onClientGUIClick", fuel.button[2], fuel.hide, false )
  addEventHandler( "onClientGUIChanged", fuel.edit, function()
  	guiSetText( fuel.label[2], string.format("Zapłacisz za to: %d$", 5 * tonumber(guiGetText( fuel.edit ))))
  end)
end

addEvent('fuelStation', true)
addEventHandler( 'fuelStation', root, fuel.show )