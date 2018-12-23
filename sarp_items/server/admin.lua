local cmd = {}

function cmd.ap(playerid, cmd, cmd2, ...)
	if not exports.sarp_admin:getPlayerPermission(playerid, 1024) then return end

	local more = {...}
	if cmd2 == 'stworz' then
		local type, val1, val2, flag, name, playerUID = tonumber(more[1]), tonumber(more[2]), tonumber(more[3]), tonumber(more[4]), tostring(table.concat( more, " ", 5, #more )), getElementData(playerid, "player:id")
		if name == '' then
			return outputChatBox( "Użyj: /ap stworz [type] [val1] [val2] [flaga] [name]", playerid )
		end

		createItem(playerUID, 1, name, type, val1, val2, flag)
		outputChatBox( "Stworzyłeś przedmiot o nazwie: ".. name .. " (type: ".. type .. ")", playerid )
	elseif cmd2 == 'lista' then
		outputChatBox( "LISTA PRZEDMIOTÓW:", playerid )
		for i, v in pairs(itemsData) do
			outputChatBox( itemsData[i].id .. ". ".. itemsData[i].name, playerid )
		end
	elseif cmd2 == 'usun' then
		local id = tonumber(more[1])

		if not id then
			return outputChatBox( "Użyj: /ap usun [id przedmiotu]", playerid )
		end

		if not itemsData[id] then
			return outputChatBox( "Przedmiot o podanym ID nie istnieje!", playerid )
		end

		deleteItem(id)
		outputChatBox( "Usunięto grupę o UID ".. id .."." )
	else
		outputChatBox( "Użyj: /ap [stworz | lista | usun]", playerid )
	end
end

addCommandHandler( "ap", cmd.ap )