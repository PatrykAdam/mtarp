--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local workshop = {}

function workshop.onRender()
	local pX, pY, pZ = getElementPosition( localPlayer )
	for i, v in ipairs(getElementsByType( "vehicle", nil, true )) do
		local repairTime = getElementData(v, "vehicle:repairTime")
		if repairTime and repairTime > 0 and getElementData(v, "vehicle:repairMechanic") == localPlayer then
			local vX, vY, vZ = getElementPosition( v )
			if getDistanceBetweenPoints3D( pX, pY, pZ, vX, vY, vZ ) > 10.0 then
				triggerServerEvent( "cancelRepair", localPlayer, v)
			end
		end
	end
end

addEventHandler( "onClientRender", root, workshop.onRender )