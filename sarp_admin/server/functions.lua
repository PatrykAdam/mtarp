--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function teleportP1toP2(playerid, playerid2)
	local pX, pY, pZ = getElementPosition( playerid2 )
	local interior, dimension = getElementInterior( playerid2 ), getElementDimension( playerid2 )
	local interior2, dimension2 = getElementInterior( playerid ), getElementDimension( playerid )
	removePedFromVehicle(playerid)
	setElementPosition( playerid, pX, pY, pZ )
	setElementInterior( playerid, interior )
	setElementDimension( playerid, dimension )
	if dimension ~= dimension2 or interior ~= interior2 then
		triggerEvent( "objects:load", root, playerid, dimension, interior )
	end
end