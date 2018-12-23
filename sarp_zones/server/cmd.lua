--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local cmd = {}
local fuel = {}

function fuel.buy(fuel)
	local vehicle = getPedOccupiedVehicle( source )

	if not vehicle or getVehicleOccupant( vehicle ) ~= source then
		return exports.sarp_notify:addNotify(source, "Nie znajdujesz się w pojeździe na miejscu kierowcy.")
	end

	if getElementData(vehicle, "vehicle:fuel") + fuel > exports.sarp_vehicles:getVehicleMaxFuel(getElementModel(vehicle)) then
		return exports.sarp_notify:addNotify(source, "Nie możesz dodać takiej ilości paliwa do tego pojazdu.")
	end

	if getVehicleEngineState( vehicle ) then
		return exports.sarp_notify:addNotify(source, "Musisz mieć zgaszony silnik podczas zakupu!")
	end

	if getElementData(source, "player:money") < fuel * 5 or fuel < 0 then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz wystarczającej ilości gotówki na zakup paliwa.")
	end

	exports.sarp_main:givePlayerCash(source, -(fuel * 5))
	setElementData(vehicle, "vehicle:fuel", getElementData(vehicle, "vehicle:fuel") + fuel)
	exports.sarp_notify:addNotify(source, "Paliwo zostało dodane do twojego baku pojazdu.")
end

addEvent('buyFuel', true)
addEventHandler( 'buyFuel', root, fuel.buy )

function cmd.tankuj(playerid, cmd)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end

	local vehicle = getPedOccupiedVehicle( playerid )

	if not vehicle or getVehicleOccupant( vehicle ) ~= playerid then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się w pojeździe na miejscu kierowcy.")
	end

	if not haveZonePermission(playerid, 2, false) then
		return exports.sarp_notify:addNotify(playerid, "Nie znajdujesz się na stacji benzynowej.")
	end

	if getVehicleEngineState( vehicle ) then
		return exports.sarp_notify:addNotify(playerid, "Musisz mieć zgaszny silnik aby użyć tej komendy.")
	end

	triggerClientEvent( playerid, "fuelStation", playerid )
end

addCommandHandler( "tankuj", cmd.tankuj )