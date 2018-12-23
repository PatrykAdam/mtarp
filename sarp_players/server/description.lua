--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local description = {}

function description.update(playerid)
	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_desc` WHERE `char_id` = ?", getElementData(playerid, "player:id"))
	triggerClientEvent(playerid, "showDescription", playerid, query)
end

function description.delete(id)
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_desc` WHERE `id` = ?", id)

	description.update(source)
	exports.sarp_notify:addNotify(source, "Opis został usunięty z listy.")
end

addEvent('deleteDescription', true)
addEventHandler( 'deleteDescription', root, description.delete )

function description.edit(id, title, desc)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_desc` SET `title` = ?, `description` = ? WHERE `id` = ?", title, desc, id)

	description.update(source)
	exports.sarp_notify:addNotify(source, "Opis został edytowany.")
end

addEvent('editDescription', true)
addEventHandler( 'editDescription', root, description.edit )

function description.new(title, desc)
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_desc` SET `title` = ?, `description` = ?, `char_id` = ?", title, desc, getElementData(source, "player:id"))

	description.update(source)
	exports.sarp_notify:addNotify(source, "Opis został zapisany.")
end

addEvent('newDescription', true)
addEventHandler( 'newDescription', root, description.new )

function description.setChar(desc)
	if not getElementData(source, "global:premium") then
		desc = string.gsub(desc, "#......", "")
	end

	setElementData(source, "player:desc", desc)
	triggerClientEvent( "changeDescription", source )
	exports.sarp_notify:addNotify(source, "Opis został ustawiony na twoją postać:"..desc)
end

addEvent('charDescription', true)
addEventHandler( 'charDescription', root, description.setChar )

function description.setVehicle(desc)
	local vehicle = getPedOccupiedVehicle( source )

	if vehicle and getVehicleOccupant( vehicle ) == source then
		local id = getElementData(vehicle, "vehicle:id")
		if not exports.sarp_vehicles:isVehicleOwner(source, id, true) then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do tego pojazdu.")
		end
		if not getElementData(source, "global:premium") then
			desc = string.gsub(desc, "#......", "")
		end

		setElementData(vehicle, "vehicle:desc", desc)
		triggerClientEvent( "changeDescription", vehicle )
		exports.sarp_notify:addNotify(source, "Opis został ustawiony na pojazd:\n"..desc)
		end
end

addEvent('vehicleDescription', true)
addEventHandler( 'vehicleDescription', root, description.setVehicle )