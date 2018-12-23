--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local gamemodeText
local main = {}

function main.onStart()
	gamemodeText = guiCreateLabel(0,screenY-40, screenX - 5, 24, "MTA RolePlay v0.2", false)
	guiLabelSetVerticalAlign (gamemodeText,"bottom")
	guiLabelSetHorizontalAlign (gamemodeText,"right")
	guiSetAlpha(gamemodeText, 0.5)

	--dźwięki
	setWorldSoundEnabled( 0, 27, false )
	setWorldSoundEnabled( 0, 28, false )
end

addEventHandler( "onClientResourceStart", resourceRoot, main.onStart )

function main.onStop()
	destroyElement(gamemodeText)
end

addEventHandler( "onClientResourceStop", resourceRoot, main.onStop )

function getPlayerFromID(id)
	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData(v, "player:mtaID") == tonumber(id) then
			return v
		end
	end
	return false
end