--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = math.max(0.6, (screenX / 1920)), math.max(0.6, (screenY / 1080))
local hud = {}
local playerDamage = {}

function hud.start()
	hud.box = {}
	hud.box[1] = {W = 109 * scaleX, H = 94 * scaleX, X = screenX - 341 * scaleX, Y = 20 * scaleX, color = {37, 37, 37, 150}}
	hud.box[2] = {W = 216 * scaleX, H = 94 * scaleX, X = hud.box[1].X + hud.box[1].W + 1, Y = hud.box[1].Y, color = {37, 37, 37, 150}}
	hud.box[3] = {W = 73 * scaleX, H = 42 * scaleX, X = hud.box[1].X, Y = hud.box[1].Y + hud.box[1].H + 1, color = {37, 37, 37, 150}}
	hud.box[4] = {W = 73 * scaleX, H = 42 * scaleX, X = hud.box[3].X + hud.box[3].W + 1, Y = hud.box[3].Y, color = {37, 37, 37, 150}}
	hud.box[5] = {W = 177 * scaleX, H = 42 * scaleX, X = hud.box[4].X + hud.box[4].W + 1, Y = hud.box[3].Y, color = {37, 37, 37, 150}}
	hud.box[6] = {W = 2 * scaleX, H = 94 * scaleX, X = hud.box[1].X - 2 * scaleX, Y = hud.box[1].Y, color = {163, 162, 160, 255}}
	hud.box[7] = {W = 2 * scaleX, H = 42 * scaleX, X = hud.box[3].X - 2 * scaleX, Y = hud.box[3].Y, color = {163, 162, 160, 255}}
	hud.icon = {}
	hud.icon[1] = {W = 25 * scaleX, H = 24 * scaleX, X = hud.box[3].X + 5 * scaleX, Y = hud.box[3].Y + (hud.box[3].H - 24 * scaleX)/2, image = 'assets/hud_hp.png'}
	hud.icon[2] = {W = 28 * scaleX, H = 28 * scaleX, X = hud.box[4].X + 5 * scaleX, Y = hud.box[4].Y + (hud.box[4].H - 28 * scaleX)/2, image = 'assets/hud_armor.png'}
	hud.font = {}
	hud.font[1] = dxCreateFont( "assets/Lato-Light.ttf", 15 * scaleX )
	hud.font[2] = dxCreateFont( "assets/Lato-Light.ttf", 12 * scaleX )
	hud.active = getElementData(localPlayer, "player:logged")
end

addEventHandler( "onClientResourceStart", resourceRoot, hud.start )

function hud.draw()
	if hud.active and getElementData(localPlayer, "player:logged") and not getElementData(localPlayer, "busTravel") then

		for i, v in ipairs(hud.box) do
			dxDrawRectangle( v.X, v.Y, v.W, v.H, (playerDamage[localPlayer] and playerDamage[localPlayer] + 2000 > getTickCount() and i == 3)  and tocolor(255, 0, 0, 150) or tocolor(unpack(v.color)) )
		end

		for i, v in ipairs(hud.icon) do
			dxDrawImage( v.X, v.Y, v.W, v.H, v.image )
		end

		local handgun = getElementData(localPlayer, "weapon:handgun" )
		if handgun then
			local hslot = getSlotFromWeapon( handgun )
			if hslot then 
				dxDrawText( getPedAmmoInClip(localPlayer, hslot).."/"..getPedTotalAmmo(localPlayer, hslot) - getPedAmmoInClip(localPlayer, hslot), hud.box[1].X, hud.box[1].Y, hud.box[1].X + hud.box[1].W, hud.box[1].Y + 30 * scaleX, tocolor(163, 162, 160), 1.0, hud.font[1], "center", "bottom" )
			end
		end

		local long = getElementData(localPlayer, "weapon:long" )
		if long then
			local lslot = getSlotFromWeapon( long )
			if lslot then
				dxDrawText( getPedAmmoInClip(localPlayer, lslot).."/"..getPedTotalAmmo(localPlayer, lslot) - getPedAmmoInClip(localPlayer, lslot), hud.box[2].X, hud.box[2].Y, hud.box[2].X + hud.box[2].W, hud.box[2].Y + 30 * scaleX, tocolor(163, 162, 160), 1.0, hud.font[1], "center", "bottom" )
			end
		end

		dxDrawText( math.floor(getElementData( localPlayer, "player:health")), hud.box[3].X + hud.icon[1].W + 5 * scaleX, hud.box[3].Y, hud.box[3].X + hud.box[3].W, hud.box[3].Y + hud.box[3].H, tocolor(163, 162, 160), 1.0, hud.font[2], "center", "center" )
		dxDrawText( getPedArmor( localPlayer ), hud.box[4].X + hud.icon[2].W + 5 * scaleX, hud.box[4].Y, hud.box[4].X + hud.box[4].W, hud.box[4].Y + hud.box[4].H, tocolor(163, 162, 160), 1.0, hud.font[2], "center", "center" )
		dxDrawText( "$", hud.box[5].X + 5 * scaleX, hud.box[5].Y, 0, hud.box[5].Y + hud.box[5].H, tocolor(163, 162, 160), 1.0, hud.font[1], "left", "center" )
		dxDrawText( moneyFormat(getElementData(localPlayer, "player:money")), hud.box[5].X + 30 * scaleX, hud.box[5].Y, hud.box[5].X + hud.box[5].W, hud.box[5].Y + hud.box[5].H, tocolor(163, 162, 160), 1.0, hud.font[1], "center", "center")
		dxDrawImage( hud.box[1].X, hud.box[1].Y + 30 * scaleX - (handgun and 0 or 15 * scaleX), hud.box[1].W, hud.box[1].H - 30 * scaleX, "assets/".. (handgun == false and 0 or handgun) ..".png" )
		dxDrawImage( hud.box[2].X, hud.box[2].Y + 30 * scaleX - (long and 0 or 15 * scaleX), hud.box[2].W, hud.box[2].H - 30 * scaleX, "assets/".. (long == false and "0l" or long) ..".png" )
	end
end

addEventHandler( "onClientRender", root, hud.draw )

function showHUD(boolean)
	if type(boolean) == 'boolean' then
		hud.active = boolean
		return
	end
	
	hud.active = false
end

addEvent('showHUD', true)
addEventHandler( 'showHUD', localPlayer, showHUD )

function damage(x, y, z, loss)
	if loss < 1 then return end

	if getElementType( source ) == "player" then
		local time = getTickCount()
		playerDamage[source] = time
	end
end

addEventHandler( "onClientPlayerDamage", root, damage )

function moneyFormat(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end