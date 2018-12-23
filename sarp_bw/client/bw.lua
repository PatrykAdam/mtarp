--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = (screenX / 1920), (screenY / 1080)
local bw = {}

function bw.onRender()
	local bwTime = getElementData( localPlayer, "player:bw" )

	local m, s = tonumber(bwTime/60), bwTime % 60

	local bwText = string.format("Do końca BW: %d min %d sec", m, s)
	dxDrawRectangle( 0, 0, screenX, screenY, tocolor(255, 0, 0, 120) )
	dxDrawText( bwText, screenX/2, screenY/2, screenX/2, screenY/2, tocolor(255, 255, 255), 2, "default-bold", "center", "center")

	if bwTime == 0 then
		removeEventHandler( "onClientRender", root, bw.onRender )
		triggerServerEvent( "bw:endTime", localPlayer )
	end
end

function bw.start()
	addEventHandler( "onClientRender", root, bw.onRender )
end

addEvent( "bwStart", true )
addEventHandler( "bwStart", resourceRoot, bw.start )

function bw.onSpawn()
	if not getElementData(localPlayer, "player:logged") then return end
	if getElementData(localPlayer, "player:bw") > 0 then
		setElementHealth( localPlayer, 0 )
		addEventHandler( "onClientRender", root, bw.onRender )
		local x, y, z = getElementPosition( localPlayer )
		setCameraMatrix( x, y, z + 5, x, y, z )
		setTimer( function() outputChatBox( "Aby uśmiercić swoją postać wpisz /akceptujsmierc.", 255, 255, 255) end, 1000, 1 )
	end
end

addEventHandler( "onClientPlayerSpawn", root, bw.onSpawn )
addEventHandler( "onClientResourceStart", root, bw.onSpawn )

function bw.onStop()
	if getElementData(localPlayer, "player:bw") then
		removeEventHandler( "onClientRender", root, bw.onRender )
	end
end

addEventHandler( "onClientResourceStop", root, bw.onStop )

function bw.playerDeath(killer, weaponid, bodypart)
	if not (source == localPlayer) then return end

	local bwPoints = 0
	if bodypart == 3 or bodypart == 4 then
		bwPoints = 7
	elseif bodypart == 5 or bodypart == 6 then
		bwPoints = 5
	elseif bodypart == 7 or bodypart == 8 then
		bwPoints = 8
	else
		bwPoints = 12
	end
	
	triggerServerEvent( "bw:startTime", localPlayer, bwPoints * 60 )
	local x, y, z = getElementPosition( localPlayer )
	setCameraMatrix( x, y, z + 5, x, y, z )
	outputChatBox( "Aby uśmiercić swoją postać wpisz /akceptujsmierc.", 255, 255, 255)

end

addEventHandler( "onClientPlayerWasted", root, bw.playerDeath )