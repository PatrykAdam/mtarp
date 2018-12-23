--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = (screenX / 1920), (screenY / 1080)
local chat = {}
chat.active = false
chat.disable = true
chat.message = {}
chat.height = dxGetFontHeight( getChatboxLayout().text_scale, "Default-bold" ) * getChatboxLayout().chat_lines

function chat.onRender()
	if not chat.active or chat.disable or getElementData(localPlayer, "busTravel") then return end

	local chatX, chatY = 30 * scaleX, (65 * scaleY) + chat.height
	dxDrawText("Czat OOC (/b)", chatX + 1, chatY + 1, 1, 1, tocolor(0, 0, 0), 1.0, "default-bold")
	dxDrawText("Czat OOC (/b)", chatX, chatY, 0, 0, tocolor(230, 230, 230), 1.0, "default-bold")

	local value = 0
	for i, v in ipairs(chat.message) do
		local textY = chatY + 15 + value
		dxDrawText(v[1], chatX + 1, textY + 1, chatX + 1, 1, tocolor(0, 0, 0), 1.0, "default-bold", "left", "top")
		dxDrawText(v[1], chatX, textY, chatX + 400, 0, tocolor(v[2],v[3],v[4]), 1.0, "default-bold", "left", "top")
		value = value + 15 + (v[5] >= 1 and v[5] or 0) * 15
	end

end

addEventHandler( "onClientRender", root, chat.onRender )

function chat.addMessage(message, r, g, b)
	if #chat.message > 6 then
		table.remove(chat.message, 1)
	end

	local msg, space = wordBreak(message, 400, false, 1.0, "default-bold")
	table.insert(chat.message, {msg, r, g, b, space})
	outputConsole( msg )
end

addEvent("addPlayerOOCMessage", true)
addEventHandler( "addPlayerOOCMessage", localPlayer, chat.addMessage )

function chat.showChatOOC(boolean, show)
	if not getElementData( localPlayer, "player:logged" ) then return end
		chat.active = boolean
		chat.disable = show
end

addEvent('showChatOOC', true)
addEventHandler( 'showChatOOC', localPlayer, chat.showChatOOC )

function chat.onStart()
	bindKey( "F10", "down", function(playerid)
		local status = isChatVisible()

		chat.showChatOOC( not status, chat.disable )

		showChat( not status )
	end)
end

addEventHandler( "onClientResourceStart", resourceRoot, chat.onStart )

function chat.onStop()
	unbindKey( "F10", "down" )
end

addEventHandler( "onClientResourceStop", resourceRoot, chat.onStop )