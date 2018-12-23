--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)

local function onRender()
	local ajTime = getElementData( localPlayer, "player:aj" )
	
	if ajTime == 0 then
		removeEventHandler( "onClientRender", root, onRender )
		triggerServerEvent( "player:endaj", localPlayer )
	end
	local m, s = tonumber(ajTime/60), ajTime % 60

	local ajText = string.format("Do końca kary: %d min %d sec", m, s)
	dxDrawText( ajText, screenX - 20 * scaleX, screenY - 100 * scaleY, screenX - 20 * scaleX, screenY - 100 * scaleY, tocolor(255, 255, 255), 2, "default-bold", "right")
end

local function showTime()
	if not getElementData(localPlayer, "player:logged") then return end
	if getElementData(localPlayer, "player:aj") > 0 then
		addEventHandler( "onClientRender", root, onRender )
	end
end

addEvent( "player:aj", true )
addEventHandler( "player:aj", localPlayer, showTime )

addEventHandler( "onClientResourceStart", root, showTime )
addEventHandler( "onClientPlayerSpawn", root, showTime )