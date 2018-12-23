--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local news = {}
local newsData = {}

function news.onDataChange(dataName, oldValue)
	if dataName == 'newsBar' then
		triggerClientEvent(source, "showNews", source, getElementData(source, dataName))
	end
end

addEventHandler( "onElementDataChange", root, news.onDataChange )

function news.onPlayerJoin()
	if isElement(newsData.playerid) then
		triggerClientEvent( source, "newsUpdate", source, newsData.message, newsData.playerid, newsData.type )
	end
end

addEventHandler( "onPlayerJoin", root, news.onPlayerJoin )

function updateNewsMessage(message, playerid, type)
	if not message then newsData = {} end
	newsData.message = message
	newsData.playerid = playerid
	newsData.type = type

	if newsData.message then
		triggerClientEvent( "newsUpdate", root, newsData.message, newsData.playerid, newsData.type )
	else
		triggerClientEvent( "newsUpdate", root)
	end
end

addEvent('updateNewsMessage', true)
addEventHandler( 'updateNewsMessage', root, updateNewsMessage )

function news.onStart()
	for i, v in ipairs(newsData) do
		if getElementData(v, "newsBar") then
			triggerClientEvent( source, "newsUpdate", source, newsData.message, newsData.playerid, newsData.type )
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot, news.onStart )

function news.onPlayerQuit()
	if newsData.playerid == source then
		newsData = {}
		updateNewsMessage()
	end
end

addEventHandler( "onPlayerQuit", root, news.onPlayerQuit )