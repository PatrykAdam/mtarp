--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

playerID = {}

local function onStart()
	playerID = {}
  for j, w in ipairs(getElementsByType( "player" )) do
  	local id = 1
		for i, v in ipairs(playerID) do
			id = i + 1

			if not playerID[i] then
				id = i
				break
			end
		end
		playerID[id] = w
		setElementData( w, "player:mtaID", id )
	end
end

addEventHandler( "onResourceStart", resourceRoot, onStart )

local function onQuit()
	playerID[getElementData(source, "player:mtaID")] = nil
	exports.sarp_logs:createLog('SESSION', string.format("[ID: %d] %s opuścił serwer. (Online: %d/%d)", getElementData(source, "player:mtaID"), getPlayerName( source ), getPlayerCount() - 1, getMaxPlayers()))

end

addEventHandler( "onPlayerQuit", root, onQuit )

local function onJoin()
	local id = 1
	for i, v in ipairs(playerID) do
		id = i + 1

		if not playerID[i] then
			id = i
			break
		end
	end
	playerID[id] = source
	setElementData( source, "player:mtaID", id )
	setPlayerNametagShowing( source, false )
	exports.sarp_logs:createLog('SESSION', string.format("[ID: %d] %s wszedł na serwer. (Online: %d/%d)", getElementData(source, "player:mtaID"), getPlayerName( source ), getPlayerCount(), getMaxPlayers()))

end

addEventHandler( "onPlayerJoin", root, onJoin )