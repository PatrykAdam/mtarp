--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function getPlayerPermission(playerid, what)
	if not getElementData(playerid, "player:logged") then return false end

	local flags = getElementData(playerid, "global:flags")
	
	if exports.sarp_main:bitAND(flags, what) == 0 then
		return false
	else
		return true
	end
end