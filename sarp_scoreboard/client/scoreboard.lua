--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = (screenX / 1920), (screenY / 1080)
local scoreboard = {}
scoreboard.W, scoreboard.H = 700 * scaleX, 880 * scaleY
scoreboard.X, scoreboard.Y = screenX/2 - scoreboard.W/2, screenY/2 - scoreboard.H/2
scoreboard.maxlist = 27 * scaleY
scoreboard.namelistX, scoreboard.namelistY = scoreboard.X + (10 * scaleX), scoreboard.Y + (40 * scaleY)
scoreboard.scroll = 0
scoreboard.font = dxCreateFont( "assets/Whitney-Medium.ttf", 13 * scaleX )
scoreboard.font_bold = dxCreateFont( "assets/Whitney-Medium.ttf", 14 * scaleX, true )

local function scoreboardRender()
	if getElementData(localPlayer, "player:logged") then
		
		dxDrawImage( scoreboard.X, scoreboard.Y, scoreboard.W, scoreboard.H, "assets/ScorBoardHDtlo.png" )
		
		dxDrawText( "San Andreas Role Play", scoreboard.namelistX + (10 * scaleX), scoreboard.Y + 15 * scaleY, 0, scoreboard.namelistY, tocolor(255, 255, 255), 1.0, scoreboard.font_bold, "left", "center")
		dxDrawText( "Gracze online: ", scoreboard.namelistX + (390 * scaleX), scoreboard.Y + 15 * scaleY, scoreboard.namelistX + (550 * scaleX), scoreboard.namelistY, tocolor(255, 255, 255), 1.0, scoreboard.font_bold, "center", "center")
		dxDrawText( #getElementsByType( "player" ).."/100", scoreboard.namelistX + (550 * scaleX), scoreboard.Y + 15 * scaleY, scoreboard.namelistX + (680 * scaleX), scoreboard.namelistY, tocolor(255, 255, 255), 1.0, scoreboard.font_bold, "center", "center")


		dxDrawText( "ID", scoreboard.namelistX, scoreboard.namelistY, scoreboard.namelistX + (40 * scaleX), scoreboard.namelistY + (40 * scaleY), tocolor(255, 255, 255, 255), 1, scoreboard.font, "center", "center" )
		dxDrawText( "NICK", scoreboard.namelistX + (40 * scaleX), scoreboard.namelistY, scoreboard.namelistX + (390 * scaleX), scoreboard.namelistY + (40 * scaleY), tocolor(255, 255, 255, 255), 1, scoreboard.font, "center", "center" )
		dxDrawText( "SCORE", scoreboard.namelistX + (390 * scaleX), scoreboard.namelistY, scoreboard.namelistX + (550 * scaleX), scoreboard.namelistY + (40 * scaleY), tocolor(255, 255, 255, 255), 1, scoreboard.font, "center", "center" )
		dxDrawText( "PING", scoreboard.namelistX + (550 * scaleX), scoreboard.namelistY, scoreboard.namelistX + (680 * scaleX), scoreboard.namelistY + (40 * scaleY), tocolor(255, 255, 255, 255), 1, scoreboard.font, "center", "center" )

		local num = 1
		for i = 1 + scoreboard.scroll, 29 + scoreboard.scroll do
			if scoreboard.players[i] and isElement(scoreboard.players[i]) then

				local color = i == 1 and tocolor(234, 239, 86) or tocolor(255, 255, 255, 255)

				dxDrawText( getElementData( scoreboard.players[i], "player:mtaID"), scoreboard.namelistX, scoreboard.namelistY + ((40 * scaleY) * num), scoreboard.namelistX + (40 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num) + (40 * scaleY), color, 1, scoreboard.font, "center", "center" )
				
				local name, score
				if getElementData(scoreboard.players[i], "player:logged") then
					if type(getElementData(scoreboard.players[i], "player:mask")) == 'string' then
						name = "Nieznajomy "..getElementData(scoreboard.players[i], "player:mask")
						score = tostring("???")
					elseif getElementData(scoreboard.players[i], "player:visible") == 1 then
						name = tostring("Postać ukryta")
						score = tostring("???")
					else
						name = getElementData(scoreboard.players[i], "player:username")
						score = getElementData(scoreboard.players[i], "global:score")
					end
				dxDrawText( score, scoreboard.namelistX + (390 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num), scoreboard.namelistX + (550 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num) + (40 * scaleY), color, 1, scoreboard.font, "center", "center" )
				dxDrawText( name, scoreboard.namelistX + (40 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num), scoreboard.namelistX + (390 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num) + (40 * scaleY), color, 1, scoreboard.font, "center", "center" )

				elseif scoreboard.players[i] ~= nil then
					dxDrawText( "???", scoreboard.namelistX + (390 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num), scoreboard.namelistX + (550 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num) + (40 * scaleY), tocolor(0, 0, 0, 150), 1, scoreboard.font, "center", "center" )
					dxDrawText( getPlayerName( scoreboard.players[i] ), scoreboard.namelistX + (40 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num), scoreboard.namelistX + (390 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num) + (40 * scaleY), tocolor(255, 255, 255, 150), 1, scoreboard.font, "center", "center" )
				end
				
				dxDrawText( getPlayerPing( scoreboard.players[i] ), scoreboard.namelistX + (550 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num), scoreboard.namelistX + (680 * scaleX), scoreboard.namelistY + ((40 * scaleY) * num) + (40 * scaleY), color, 1, scoreboard.font, "center", "center" )
				num = num + 1
			end
		end
	end
end

function open(key, state)
	if state == "down" then
		addEventHandler( "onClientRender", root, scoreboardRender )
		addEventHandler( "onClientKey", root, scoreboardKey )
		addEventHandler( "onClientPlayerWeaponFire", root, scoreboardStopFire )
	end
	if state == "up" then
		removeEventHandler( "onClientRender", root, scoreboardRender )
		removeEventHandler( "onClientKey", root, scoreboardKey )
		removeEventHandler( "onClientPlayerWeaponFire", root, scoreboardStopFire )
	end
end

function scoreboardKey(key)
	if (getKeyState( "TAB" )) and getElementData(localPlayer, "player:logged") then
		if key == "mouse_wheel_up" and scoreboard.scroll > 0 then
			scoreboard.scroll = scoreboard.scroll + 1

		elseif key == "mouse_wheel_down" and scoreboard.scroll + 29 < #scoreboard.players then
			scoreboard.scroll = scoreboard.scroll - 1
		end
	end
end

function scoreboardStopFire()
	setPedWeaponSlot(localPlayer, 0 )
	cancelEvent(  )
end

function update()
		scoreboard.players = getElementsByType( "player" )

		for i, v in pairs(scoreboard.players) do
			for j = 1, i do
				if j == 1 then
					if getElementData(scoreboard.players[j], "player:mtaID") == getElementData(localPlayer, "player:mtaID") then
						local save = scoreboard.players[1]
						scoreboard.players[1] = scoreboard.players[j]
						scoreboard.players[j] = save
					end
					return
				end
				if getElementData(scoreboard.players[j], "player:mtaID") > getElementData(scoreboard.players[j + 1], "player:mtaID") then
					local save = scoreboard.players[j]
					scoreboard.players[j] = scoreboard.players[j + 1]
					scoreboard.players[j + 1] = save
				end
			end
		end
end

function start()
	bindKey("TAB", "both", open)
	update()
end

function stop()
	unbindKey( "TAB", "both", open)
end

addEventHandler( "onClientPlayerJoin", root, update )
addEventHandler( "onClientPlayerQuit", root, update )
addEventHandler( "onClientResourceStart", resourceRoot, start )
addEventHandler( "onClientResourceStop", resourceRoot, stop )
