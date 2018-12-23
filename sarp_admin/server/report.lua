--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local report = {}
local reportData = {}

function report.new(category, playerid, text)
	local player = exports.sarp_main:getPlayerFromID(playerid)

	if not player then
		return exports.sarp_notify:addNotify(source, "Gracz o podanym ID nie jest zalogowany.")
	end

	table.insert(reportData, {id = report.newID(), category = category, playerid = player, message = text, sender = source, consider = nil})
	exports.sarp_notify:addNotify(source, "Zgłoszenie zostało wysłane. Pamiętaj, że nadmierne wysyłanie zgłoszeń może wiązać się z konsekwencjami.")
	for i, v in ipairs(getElementsByType( "player" )) do
		if getPlayerPermission(v, 512) then
			triggerClientEvent( "addPlayerOOCMessage", v, string.format("Otrzymano nowe zgłoszenie od %s. Osoba zgłaszana: %s.", getElementData(source, "player:username"), getElementData(player, "player:username")), 255, 0, 0 )
		end
	end
end

addEvent('sendReport', true)
addEventHandler( 'sendReport', root, report.new )

function report.newID()
	local id = 1
	local newID = false
	while newID == false do
		if not reportData[id] then
			newID = id
		end

		id = id + 1
	end
	return newID
end

function report.getID(id)
	for i, v in ipairs(reportData) do
		if v.id == id then
			return i
		end
	end
	return false
end

function report.showAll(playerid)
	if not getPlayerPermission(playerid, 512) then return end

	if #reportData == 0 then
		return exports.sarp_notify:addNotify(playerid, "Brak aktywnych zgłoszeń w panelu.")
	end

	local consider = false

	for i, v in ipairs(reportData) do
		if v.consider == playerid then
			consider = v.id
			break
		end
	end

	triggerClientEvent( 'showReports', playerid, consider, reportData )
end

addCommandHandler( "reporty", report.showAll )

function report.accept(id)
	if not getPlayerPermission(source, 512) or id == nil then return end
	id = report.getID(id)

	reportData[id].consider = source
	report.showAll(source)
	exports.sarp_notify:addNotify(source, "Zgłoszenie zostało przyjęte.")
end

addEvent('acceptReport', true)
addEventHandler( 'acceptReport', root, report.accept )

function report.ending(id)
	if not getPlayerPermission(source, 512) then return end
	id = report.getID(id)

	table.remove(reportData, id)
	report.showAll(source)
	exports.sarp_notify:addNotify(source, "Zgłoszenie zostało usunięte z listy.")
end

addEvent('endReport', true)
addEventHandler( 'endReport', root, report.ending )

function report.goto(id)
	if id == nil then return end
	id = report.getID(id)
	
	teleportP1toP2(source, reportData[id].playerid)

	exports.sarp_notify:addNotify(source, "Teleportowałeś się do zgłoszonego gracza.")
end

addEvent('gotoReport', true)
addEventHandler( 'gotoReport', root, report.goto )

function report.cancel(id)
	if not getPlayerPermission(source, 512) then return end
	id = report.getID(id)

	reportData[id].consider = nil
	report.showAll(source)
	exports.sarp_notify:addNotify(source, "Zgłoszenie zostało usunięte z twojej listy aktywnych.")
end

addEvent('cancelReport', true)
addEventHandler( 'cancelReport', root, report.cancel )

function report.playerQuit()
	for i, v in ipairs(reportData) do
		if v.consider == source then
			v = nil
		end
	end
end

addEventHandler( "onPlayerQuit", root, report.playerQuit )