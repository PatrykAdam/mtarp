--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local ware = {}
ware.config = {
	getPack = Vector3(1129.097656, -1467.645508, 14.730888),
	randPos = {
		Vector3(0, 0, 0),
		Vector3(0, 0, 0),
		Vector3(0, 0, 0),
	},
	maxCash = 150
}

ware.marker = false

ware.currentPack = false


function ware.onMarkerHit()
	if getElementData(localPlayer, "player:jobsCash") > ware.config['maxCash'] then
		return exports.sarp_notify:addNotify("Wyczerpałeś limit dzienny w pracach dorywczych, wróć ponownie jutro.")
	end

	if getElementData(localPlayer, "player:jobs") ~= 1 then
		return exports.sarp_notify:addNotify("Aby rozpocząć pracę jako Magazynier musisz udać się do urzędu pracy oraz wybrać podaną prace.")
	end

	local vehicle = getPedOccupiedVehicle( localPlayer )

	if not (vehicle and getElementData(vehicle, "vehicle:ownerType") == 3 and getElementData(vehicle, "vehicle:ownerID") == 1) then
		return exports.sarp_notify:addNotify("Aby rozpocząć tą prace, musisz znajdować się w pojeździe pracy dorywczej.")
	end

	--wybór wielkość paczki
	ware.currentPack = {ID = 3, marker = createMarker( ware.config['randPos'][Math.random(#ware.config['randPos'])], "cylinder", 2.0, 0, 255, 255, 130)} -- największa

end

function ware.onStart()
	ware.marker = createMarker( ware.config['getPack'], "cylinder", 3.0, 0, 255, 255, 130 )
	setElementDimension( ware.marker, 0 )
	setElementInterior( ware.marker, 0 )

	addEventHandler( "onClientMarkerHit", ware.marker, ware.onMarkerHit )
end

addEventHandler( "onClientResourceStart", resourceRoot, ware.onStart )