--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local cmd = {}

function cmd.drzwi(playerid, cmd, cmd2)
	if cmd2 == 'zamknij' then
		lockDoor(playerid)
	else
		exports.sarp_notify:addNotify(playerid, "Użyj: /drzwi [zamknij]")
		
		local playerDoor = getElementData(playerid, "player:door")
		local doorData = {}

		if playerDoor and isElement(playerDoor) and isDoorOwner(playerid, playerDoor, true) then
			if getElementData( playerDoor, "doors:ownerType") == 2 then
				doorData.owner = getElementData( playerDoor, "doors:name")
			elseif getElementData( playerDoor, "doors:ownerID") == 1 then
				local username = exports.sarp_mysql:mysql_result("SELECT `name`, `surname` FROM `sarp_characters` WHERE `player_id` = ?", doorData.ownerID)
				doorData.owner = username[1].name.." "..username[1].surname
			else
				doorData.owner = "Brak"
			end

			if haveDoorEquipment(getElementData(playerDoor, "doors:id"), 1) then
				doorData.audio = true
			end
			
			triggerClientEvent( playerid, "doorManage", playerid, playerDoor, doorData)
		end
	end
end

addCommandHandler( "drzwi", cmd.drzwi)

function cmd.dom(playerid, cmd, cmd2)
	local posessionList = {}
	local query = exports.sarp_mysql:mysql_result("SELECT `doorid` FROM `sarp_doors_members` WHERE `player_id` = ?", getElementData(playerid, "player:id"))
	
	for i, v in ipairs(query) do
		local element = getDoorElement(v.doorid)
		if v.doorid then
			table.insert(posessionList, {id = v.doorid, name = getElementData( element, "doors:name"), rank = 'Mieszkaniec'})
		end
	end

	for i, v in pairs(getElementsByType( "marker" )) do
		if getElementData( v, "type:doors") and not getElementData( v, "doors:exit") and getElementData( v, "doors:ownerType") == 1 and getElementData( v, "doors:ownerID") == getElementData(playerid, "player:id") then
			table.insert(posessionList, {id = getElementData( v, "doors:id"), name = getElementData( v, "doors:name"), rank = 'Właściciel'})
		end
	end

	if #posessionList == 0 then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz dostępu do żadnej posiadłości.")
	end

	triggerClientEvent(playerid, "posessionManage", playerid, posessionList )
end

addCommandHandler( "dom", cmd.dom)