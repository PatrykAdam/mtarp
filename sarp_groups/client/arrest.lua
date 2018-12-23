--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local arrest = {}
arrest.time = false

function arrest.onRender()
	local time = arrest.time - getRealTime().timestamp

	local text = string.format("Do końca aresztu: %02d min i %02d sec.", time / 60, time % 60)
	dxDrawText( text, screenX/2 + 1, screenY - 51 * scaleX, screenX, 0, tocolor( 0, 0, 0 ), 1.0, "default", "center", "top" )
	dxDrawText( text, screenX/2, screenY - 50 * scaleX, screenX, 0, tocolor( 255, 255, 255 ), 1.0, "default", "center", "top" )

	if time < 0 then
		triggerServerEvent( "endArrest", localPlayer )
	end

end

function arrest.onDataChange(name, oldValue, newValue)
	if name == 'player:arrestTime' then
		arrest.time = newValue

		if newValue then
			addEventHandler( "onClientRender", root, arrest.onRender )
		else
			removeEventHandler( "onClientRender", root, arrest.onRender )
		end
	end
end

addEventHandler( "onClientElementDataChange", root, arrest.onDataChange )