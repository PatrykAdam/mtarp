--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function cmd_szept(playerid, cmd, ...)
	local msg = {...}
	if #msg == 0 then
		return outputChatBox( "Uzyj: /s [tekst]", playerid )
	end

	if getElementData(playerid, "player:muted") then
		return exports.sarp_notify:addNotify(playerid, "Posiadasz nałożony knebel - nie możesz nic mówić.")
	end

	if getElementData(playerid, "player:bw") > 0 then
		return exports.sarp_notify:addNotify(playerid, "Podczas BW nie możesz używać tej komendy.")
	end

	local message = table.concat(msg, " ")

	if string.len(message) > 96 then
		return exports.sarp_notify:addNotify(playerid, "Przekroczono liczbę znaków.")
	end

	local rad = 5.0
	local name = getPlayerRealName( playerid )
	local pX, pY, pZ = getElementPosition( playerid )
	local pInterior, pDimension = getElementInterior( playerid ), getElementDimension( playerid )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )

	message = string.format("%s szepcze: %s", name, message)
	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		if distance < rad / 16 then
			local newmessage = findAction(message, "#b496d2", "#e6e6e6")
			outputChatBox( newmessage, v, 230, 230, 230, true)
		elseif distance < rad / 8 then
			local newmessage = findAction(message, "#9678b4", "#c8c8c8")
			outputChatBox( newmessage, v, 200, 200, 200, true)
		elseif distance < rad / 4 then
			local newmessage = findAction(message, "#9678b4", "#aaaaaa")
			outputChatBox( newmessage, v,  170, 170, 170, true)
		elseif distance < rad / 2 then
			local newmessage = findAction(message, "#785a96", "#8c8c8c")
			outputChatBox( newmessage, v,  140, 140, 140, true)
		else
			local newmessage = findAction(message, "#5a3c78", "#6e6e6e")
			outputChatBox( newmessage, v, 110, 110, 110, true)
		end
	end

	destroyElement( radius )
end

function cmd_do(playerid, cmd, ...)
	local msg = {...}
	if #msg == 0 then
		return outputChatBox( "Uzyj: /do [tekst]", playerid )
	end

	local message = table.concat(msg, " ")

	if string.len(message) > 96 then
		return exports.sarp_notify:addNotify(playerid, "Przekroczono liczbę znaków.")
	end

	local rad = 15.0
	local name = getPlayerRealName( playerid )
	local pX, pY, pZ = getElementPosition( playerid )
	local pInterior, pDimension = getElementInterior( playerid ), getElementDimension( playerid )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )

	message = string.format("** %s (( %s ))", message, name)
	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		if distance < rad / 16 then
			outputChatBox( message, v, 150, 150, 200)
		elseif distance < rad / 8 then
			outputChatBox( message, v, 120, 120, 170)
		elseif distance < rad / 4 then
			outputChatBox( message, v, 90, 90, 150)
		else
			outputChatBox( message, v, 60, 60, 120)
		end
	end

	destroyElement( radius )
end

function cmd_k(playerid, cmd, ...)
	local msg = {...}
	if #msg == 0 then
		return outputChatBox( "Uzyj: /k [tekst]", playerid )
	end

	if getElementData(playerid, "player:muted") then
		return exports.sarp_notify:addNotify(playerid, "Posiadasz nałożony knebel - nie możesz nic mówić.")
	end

	if getElementData(playerid, "player:bw") > 0 then
		return exports.sarp_notify:addNotify(playerid, "Podczas BW nie możesz używać tej komendy.")
	end

	local message = table.concat(msg, " ")

	if string.len(message) > 96 then
		return exports.sarp_notify:addNotify(playerid, "Przekroczono liczbę znaków.")
	end
	local rad = 25.0
	local name = getPlayerRealName( playerid )
	local pX, pY, pZ = getElementPosition( playerid )
	local pInterior, pDimension = getElementInterior( playerid ), getElementDimension( playerid )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )

	message = string.format("%s krzyczy: %s!", name, message)
	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		if distance < rad / 16 then
			local newmessage = findAction(message, "#b496d2", "#e6e6e6")
			outputChatBox( newmessage, v, 230, 230, 230, true)
		elseif distance < rad / 8 then
			local newmessage = findAction(message, "#9678b4", "#c8c8c8")
			outputChatBox( newmessage, v, 200, 200, 200, true)
		elseif distance < rad / 4 then
			local newmessage = findAction(message, "#9678b4", "#aaaaaa")
			outputChatBox( newmessage, v,  170, 170, 170, true)
		elseif distance < rad / 2 then
			local newmessage = findAction(message, "#785a96", "#8c8c8c")
			outputChatBox( newmessage, v,  140, 140, 140, true)
		else
			local newmessage = findAction(message, "#5a3c78", "#6e6e6e")
			outputChatBox( newmessage, v, 110, 110, 110, true)
		end
	end

	destroyElement( radius )
end

function cmd_b(playerid, cmd, ...)
	local msg = {...}
	if #msg == 0 then
		return outputChatBox( "Uzyj: /b [tekst]", playerid )
	end

	local message = table.concat(msg, " ")

	if string.len(message) > 96 then
		return exports.sarp_notify:addNotify(playerid, "Przekroczono liczbę znaków.")
	end
	local rad = 15.0
	local name = getPlayerRealName( playerid )
	local pX, pY, pZ = getElementPosition( playerid )
	local pInterior, pDimension = getElementInterior( playerid ), getElementDimension( playerid )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )
	local id = getElementData( playerid, "player:mtaID" )

	message = string.format("(( [%d] %s: %s ))", id, name, message)
	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		triggerClientEvent( "addPlayerOOCMessage", v, message, 230, 230, 230 )
	end
	exports.sarp_logs:createLog('chatOOC', message)
	destroyElement( radius )
end

function main_me(message)
	local rad = 10.0
	local name = getPlayerRealName( source )
	local pX, pY, pZ = getElementPosition( source )
	local pInterior, pDimension = getElementInterior( source ), getElementDimension( source )
	local radius = createColSphere( pX, pY, pZ, rad )
	local players = getElementsWithinColShape( radius, "player" )

	message = string.format("** %s %s", name, message)
	for i, v in ipairs(players) do
		local pX2, pY2, pZ2 = getElementPosition(v)
		local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
		local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

		if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

		if distance < rad / 12 then
			outputChatBox( message, v, 180, 150, 210)
		elseif distance < rad / 6 then
			outputChatBox( message, v, 150, 120, 180)
		elseif distance < rad / 3 then
			outputChatBox( message, v, 120, 90, 150)
		else
			outputChatBox( message, v, 90, 60, 120)
		end
	end

	destroyElement( radius )
end

addEvent("main:me", true)
addEventHandler( "main:me", root, main_me )

function playerSendMessage(message, msgtype)
	local radio = false

	cancelEvent()
	if not isPlayerLogged(source) then return end

	if msgtype == 0 then -- Zwykła rozmowa
		local rad = 25.0
		local name = getPlayerRealName( source )

		--admin chat
		if string.sub(message, 1, 1) == "#" then
			if string.sub(message, 2, 2) == ' ' then return end
			if exports.sarp_admin:getPlayerPermission(source, 512) then
				local message = string.format("[AC] %s: %s", getElementData(source, "global:name"), string.sub(message, 2))
				for i,player in ipairs( getElementsByType("player") ) do
					if exports.sarp_admin:getPlayerPermission(player, 512) then
						triggerClientEvent( "addPlayerOOCMessage", player, message, 66, 179, 244 )
					end
				end
				exports.sarp_logs:createLog('adminCHAT', message)
				return
			end
		end

		if string.sub(message, 1, 1) == "@" then
			local slot = tonumber(string.sub(message, 2, 2))

			if string.sub(message, 3, 3) ~= ' ' or not slot then
				return exports.sarp_notify:addNotify(source, "Użyj: @[id grupy] [tekst]")
			end

			if slot > 3 and slot < 1 then
				return exports.sarp_notify:addNotify(source, "Slot może być od 1 do 3.")
			end

			if string.len(string.sub(message, 4)) > 96 then
				return exports.sarp_notify:addNotify(source, "Przekroczono liczbę znaków.")
			end

			triggerEvent( "groups:chatOOC", source, slot, string.sub(message, 4))
			return
		end

		if getElementData(source, "player:muted") then
			return exports.sarp_notify:addNotify(source, "Posiadasz nałożony knebel - nie możesz nic mówić.")
		end

		if getElementData(source, "player:bw") > 0 then
			return exports.sarp_notify:addNotify(source, "Podczas BW nie możesz używać tej komendy.")
		end

		if string.sub(message, 1, 1) == "!" then
			local slot = tonumber(string.sub(message, 2, 2))

			if string.sub(message, 3, 3) ~= ' ' or not slot then
				return exports.sarp_notify:addNotify(source, "Użyj: ![id grupy] [tekst]")
			end

			if slot > 3 and slot < 1 then
				return exports.sarp_notify:addNotify(source, "Slot może być od 1 do 3.")
			end

			if string.len(string.sub(message, 4)) > 96 then
				return exports.sarp_notify:addNotify(source, "Przekroczono liczbę znaków.")
			end

			triggerEvent( "groups:chatIC", source, slot, string.sub(message, 4))
			message = name.. " mówi (przez radio): " ..string.sub(message, 4)
		elseif getElementData(source, "player:interview") then
			triggerEvent('updateNewsMessage', source, message, source, 2)
				message = name .. " mówi (mikrofon): ".. message
		else
			if string.len(message) > 96 then
				return exports.sarp_notify:addNotify(source, "Przekroczono liczbę znaków.")
			end

			message = name .. " mówi: ".. message
		end

		local pX, pY, pZ = getElementPosition( source )
		local pInterior, pDimension = getElementInterior( source ), getElementDimension( source )
		local radius = createColSphere( pX, pY, pZ, rad )
		local players = getElementsWithinColShape( radius, "player" )

		for i, v in ipairs(players) do
			local pX2, pY2, pZ2 = getElementPosition(v)
			local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pX2, pY2, pZ2 )
			local pInterior2, pDimension2 = getElementInterior( v ), getElementDimension( v )

			if pInterior ~= pInterior2 or pDimension ~= pDimension2 then return end

			local newmessage
			if distance < rad / 16 then
				newmessage = findAction(message, "#b496d2", "#e6e6e6")
				outputChatBox( newmessage, v, 230, 230, 230, true)
			elseif distance < rad / 8 then
				newmessage = findAction(message, "#9678b4", "#c8c8c8")
				outputChatBox( newmessage, v, 200, 200, 200, true)
			elseif distance < rad / 4 then
				newmessage = findAction(message, "#9678b4", "#aaaaaa")
				outputChatBox( newmessage, v,  170, 170, 170, true)
			elseif distance < rad / 2 then
				newmessage = findAction(message, "#785a96", "#8c8c8c")
				outputChatBox( newmessage, v,  140, 140, 140, true)
			else
				newmessage = findAction(message, "#5a3c78", "#6e6e6e")
				outputChatBox( newmessage, v, 110, 110, 110, true)
			end
		end

		destroyElement( radius )
	elseif msgtype == 1 then -- /me
		main_me(message)
	end
end

addCommandHandler( "do", cmd_do )
addCommandHandler( "krzycz", cmd_k )
addCommandHandler( "k", cmd_k )
addCommandHandler( "b", cmd_b )
addCommandHandler( "OOC", cmd_b )
addCommandHandler( "s", cmd_szept )
addCommandHandler( "c", cmd_szept )
addCommandHandler( "szept", cmd_szept )
addEventHandler( "onPlayerChat", root, playerSendMessage )

local function onJoin()
	unbindKey( source, "y" )
	bindKey( source, "b", "down", "chatbox", "OOC")
end

addEventHandler( "onPlayerJoin", root, onJoin )

function findAction(text, color1, color2)
	--najpierw blokujemy kolory wywołane przez graczy
	text = string.gsub(text, "#", "?")

	--zamiana emotek
	local emotions = {
		['%;%)'] = "puszcza oczko",
		['%:%)'] = "uśmiecha się",
		['%;%/'] = "krzywi się",
		['%:%/'] = "krzywi się",
		['%;%('] = "robi smutną mine",
		['%:%('] = "robi smutną mine",
		['%;%O'] = "robi zdziwioną mine",
		['%:%O'] = "robi zdziwioną mine",
		['xD'] = "wybucha śmiechem",
		['Xd'] = "wybucha śmiechem",
		['%;%*'] = "daje całusa",
		['%:%*'] = "daje całusa",
		['%:D'] = "śmieje się",
		['%;D'] = "śmieje się",
		['%;P'] = "wystawia język",
		['%:P'] = "wystawia język",

	}

	for i, v in pairs(emotions) do
		text = string.gsub(text, string.lower(i), string.format("*%s*", v))
		text = string.gsub(text, string.upper(i), string.format("*%s*", v))
		text = string.gsub(text, i, string.format("*%s*", v))
	end

	local action = true
	text = string.gsub(text, "(*)", function(text)
		action = not action
		if not action then
			return color1.."*"
		else
			return "*"..color2
		end
		end)
	return text
end