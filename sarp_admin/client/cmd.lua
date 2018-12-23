--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local cmd = {}

function cmd.devmode(cmd)
	if getElementData(localPlayer, "global:flags") >= 512 then
		setDevelopmentMode( not getDevelopmentMode() )
		exports.sarp_notify:addNotify(string.format("Tryb developerski został %s.", getDevelopmentMode() and "włączony" or "wyłączony"))
	end
end

addCommandHandler( "devmode", cmd.devmode)