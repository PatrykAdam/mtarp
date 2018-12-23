--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

--[[
	1 = dowod
	2 = prawojazdy
]]

function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function havePlayerDocument(playerid, document)
	local docs = getElementData(playerid, "player:documents")
	if bitAND(docs, document) == 0 then
		return false
	end
	return true
end

function getPlayerFromID(id)
	id = tonumber(id)
	if playerID[id] then
		return playerID[id]
	else
		return false
	end
end

function sendMessage(playerid, message)
	outputChatBox( message, playerid, 255, 255, 255, true )
end