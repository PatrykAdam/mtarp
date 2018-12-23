--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function getDistanceToElement(element1, element2)
	local eX, eY, eZ = getElementPosition( element1 )
	local e2X, e2Y, e2Z = getElementPosition( element2 )
	local distance = getDistanceBetweenPoints3D( eX, eY, eZ, e2X, e2Y, e2Z )
	return distance
end