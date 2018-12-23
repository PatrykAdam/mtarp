--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function detectPlayerZone(playerid)
	local zoneList = {}

	for i, v in ipairs(getElementsByType( "colshape" )) do
		if getElementData(v, "isZone") == true and isElementWithinColShape( playerid, v ) then
			table.insert(zoneList, v)
		end
	end
	return zoneList
end