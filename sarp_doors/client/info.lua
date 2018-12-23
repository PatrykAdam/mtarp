--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)
local pickup = false
local doorInfo = {}
doorInfo.W, doorInfo.H = 398 * scaleX, 157 * scaleY
doorInfo.X, doorInfo.Y = screenX/2 - doorInfo.W/2, screenY - doorInfo.H - 20 * scaleY
doorInfo.imagesize = 95 * scaleX
doorInfo.font = dxCreateFont( "assets/Lato-Regular.ttf", 8)

function renderDoorInfo()
	if not isElement( pickup ) then pickup = false end
	if pickup then
		dxDrawImage( doorInfo.X, doorInfo.Y, doorInfo.W, doorInfo.H, "assets/infobarGUI.png" )

		local lock = getElementData(pickup, "doors:lock")

		if lock == 1 then
			dxDrawImage( doorInfo.X + 11 * scaleX + (102* scaleX - doorInfo.imagesize)/2, doorInfo.Y + 28 * scaleY + (doorInfo.H - (48* scaleY) - doorInfo.imagesize)/2, doorInfo.imagesize, doorInfo.imagesize, "assets/locked.png" )
		else
			dxDrawImage( doorInfo.X + 11 * scaleX + (102* scaleX - doorInfo.imagesize)/2, doorInfo.Y + 28 * scaleY + (doorInfo.H - (48* scaleY) - doorInfo.imagesize)/2, doorInfo.imagesize, doorInfo.imagesize, "assets/house.png" )
		end

		dxDrawText( doorInfo.name.."\n\n"..doorInfo.description, doorInfo.X + 115 * scaleX, doorInfo.Y + 30 * scaleY, doorInfo.X + doorInfo.W - 10 * scaleX, doorInfo.Y + (doorInfo.H - 20 * scaleY), tocolor(255, 255, 255, 255), 1.0, doorInfo.font, "center", "top", false, false, false, true )
		dxDrawText( "Aby wejść do środka naciśnij #FFF000E#FFFFFF.", doorInfo.X + 115 * scaleX, doorInfo.Y + doorInfo.H - 30 * scaleY, doorInfo.X + doorInfo.W - 10 * scaleX, doorInfo.Y + (doorInfo.H - 20 * scaleY), tocolor(255, 255, 255, 255), 1.0, doorInfo.font, "center", "center", false, false, false, true )
	end
end

addEventHandler( "onClientRender", root, renderDoorInfo )

function pickupHit(player, dimension)
	if localPlayer ~= player or not dimension then return end

	if getElementData(source, "type:doors") then
		pickup = getElementData(source, "doors:exit") and getElementData(source, "doors:parent") or source
		local id = getElementData( pickup, "doors:id" )
		doorInfo.name = exports.sarp_main:wordBreak(getElementData( pickup, "doors:name" ) .. " (ID: ".. id .. ")", 250 * scaleX, false, 1.0, doorInfo.font)
		doorInfo.description = exports.sarp_main:wordBreak(getElementData( pickup, "doors:description" ), 250 * scaleX, false, 1.0, doorInfo.font)

		if getElementData( pickup, "doors:entry" ) > 0 then
			doorInfo.description = string.format("%s\nKoszt wstępu: #21d81e$%d", doorInfo.description, getElementData( pickup, "doors:entry" ))
		end
	end
end

function pickupLeave(player, dimension)
	if localPlayer ~= player or not dimension then return end

	if getElementData(source, "type:doors") then
		pickup = false
	end
end
addEventHandler( "onClientMarkerHit", root, pickupHit )

addEventHandler( "onClientMarkerLeave", root, pickupLeave )