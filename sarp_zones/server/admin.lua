--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local admin = {}

function admin.cmd(playerid, cmd, cmd2, ...)
	local params = {...}

	if not exports.sarp_admin:getPlayerPermission(playerid, 2048 ) then return end

	if cmd2 == 'stworz' then
		triggerClientEvent( playerid, "createZone", root )
	elseif cmd2 == 'znajdz' then
		triggerClientEvent( playerid, "findZone", root )
	elseif cmd2 == 'usun' then
		local id = tonumber(params[1])

		if not id then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /as usun [ID strefy]")
		end

		local i = getZoneID(id)
		if not isElement(i) then
			return exports.sarp_notify:addNotify(playerid, "Stefa o podanym ID nie istnieje.")
		end
			
		deleteZone(i)
		exports.sarp_notify:addNotify(playerid, string.format("Strefa o ID %d została usunięta.", id))
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s usunął strefę o ID: %d.", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), id))

	elseif cmd2 == 'opcje' then
		local id = tonumber(params[1])
		local i = getZoneID(id)

		if not id then
			return exports.sarp_notify:addNotify(playerid, "Użyj: /as opcje [ID strefy]")
		end

		if not isElement(i) then
			return exports.sarp_notify:addNotify(playerid, "Stefa o podanym ID nie istnieje.")
		end

		triggerClientEvent(playerid, "permZone", root, id, getElementData(i, "zonePermission"))
	elseif cmd2 == 'owner' then
		local zoneID, ownerType, ownerID = tonumber(params[1]), tonumber(params[2]), tonumber(params[3])

		if not ownerType or not ownerID or ownerType > 2 and ownerType < 0 then
			return exports.sarp_notify:addNotify(playerid, "Użyj /as owner [ID strefy] [TYP właściciela] [ID właściciela]")
		end

		local i = getZoneID(zoneID)

		if not isElement(i) then
			return exports.sarp_notify:addNotify(playerid, "Stefa o podanym ID nie istnieje.")
		end

		setElementData(i, "zoneOwnerType", ownerType)
		setElementData(i, "zoneOwner", ownerID)

		exports.sarp_mysql:mysql_change("UPDATE `sarp_zones` SET `ownerType` = ?, `ownerID` = ? WHERE `id` = ?", ownerType, ownerID, zoneID)
		exports.sarp_notify:addNotify(playerid, "Zmieniłeś właściciela strefy.")
		exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił właściciela strefy o ID: %d. (ownerType: %d, ownerID: %d)", getElementData(playerid, "global:rank"), getElementData(playerid, "global:name"), zoneID, ownerType, ownerID))
	else
		return exports.sarp_notify:addNotify(playerid, "Użyj: /as(trefa) [stworz, znajdz, usun, opcje, owner]")
	end
end

addCommandHandler( "as", admin.cmd)
addCommandHandler( "astrefa", admin.cmd)

function admin.confirmZone(cords)
	if not exports.sarp_admin:getPlayerPermission(source, 2048 ) then return end
	local id = createZone(cords[1], cords[2], cords[3], cords[4], cords[5], cords[6], cords[7], cords[8])
	exports.sarp_notify:addNotify(source, string.format("Strefa została utworzona poprawnie. (ID: %d) Aby nadać jej uprawnienia wpisz /as [ID strefy] opcje.", id))
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s utworzył nową strefe o ID: %d.", getElementData(source, "global:rank"), getElementData(source, "global:name"), id))
end

addEvent('confirmZone', true)
addEventHandler( 'confirmZone', root, admin.confirmZone )

function admin.saveZone(zoneID, perm)
	local i = getZoneID(zoneID)
	if not isElement(i) then return end

	setElementData(i, "zonePermission", perm)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_zones` SET `permission` = ? WHERE `id` = ?", getElementData(i, "zonePermission"), zoneID)
	exports.sarp_notify:addNotify(source, "Uprawnienia strefy zostały pomyślnie zaaktualizowane.")
	exports.sarp_logs:createLog('adminACTION', string.format("%s %s zmienił uprawnienia dla strefy o ID: %d.", getElementData(source, "global:rank"), getElementData(source, "global:name"), zoneID))
end

addEvent('saveZone', true)
addEventHandler( 'saveZone', root, admin.saveZone )