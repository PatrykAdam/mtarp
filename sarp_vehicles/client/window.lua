--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local window = {}
window.vehType = {'Automobile', 'Monster Truck'}

function window.update(element)
	if getElementType( element ) == 'vehicle' and isWindow(element) then
		local window = getElementData( element, "vehicle:window") or false

		for i = 2, 5 do
			setVehicleWindowOpen( element, i, window)
		end
	end
end

addEventHandler( "onClientElementStreamIn", root, function() window.update( source ) end )
addEventHandler( "onClientElementDataChange", root, function(keyName, oldValue)
	if keyName == 'vehicle:window' then
		window.update( source )
	end
end)

function isWindow( vehicle )
	for i, v in ipairs(window.vehType) do
		if v == getVehicleType( vehicle ) then
			return true
		end
	end
	return false
end