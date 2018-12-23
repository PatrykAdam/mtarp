--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local offer = {}
offer.active = false
offer.W, offer.H = 465 * scaleX, 238 * scaleY
offer.X, offer.Y = (screenX - offer.W)/2, screenY - offer.H - 30 * scaleY
offer.line = {
	{W = 258 * scaleX, H = 1},
	{W = 351 * scaleX, H = 1}
}
offer.font = {
	{element = dxCreateFont( "assets/Lato-Regular.ttf", 14 * scaleX )},
	{element = dxCreateFont( "assets/Lato-Light.ttf", 14 * scaleX )},
}
offer.font[1].H = dxGetFontHeight( 1.0, offer.font[1].element )
offer.font[2].H = dxGetFontHeight( 1.0, offer.font[2].element )


offer.imgButtonW, offer.imgButtonH = 388 * scaleX, 36 * scaleY

function offer.onRender()
	local Y
	if offer.active then
		local progress = (getTickCount() - offer.lastTick) / 500
		Y = interpolateBetween( screenY + offer.H, 0, 0, offer.Y, 0, 0, progress, 'Linear' )
	else
		local progress = (getTickCount() - offer.lastTick) / 500
		Y = interpolateBetween( offer.Y, 0, 0, screenY + offer.H, 0, 0, progress, 'Linear' )

		if progress > 1 then
			removeEventHandler( "onClientRender", root, offer.onRender )
			offer.text = nil
			offer.title = nil
			return
		end
	end
	dxDrawRectangle( offer.X, Y, offer.W, offer.H, tocolor( 0, 0, 0, 153 ) )
	dxDrawText( offer.title, offer.X, Y + 20 * scaleY, offer.X + offer.W, 0, tocolor( 187, 187, 187 ), 1.0, offer.font[1].element, "center", "top", false, false, false, true )
	dxDrawRectangle( offer.X + (offer.W - offer.line[2].W)/2, Y + offer.H - offer.imgButtonH - 30 * scaleY, offer.line[2].W, offer.line[2].H, tocolor( 255, 255, 255, 153 ) )
	dxDrawRectangle( offer.X + (offer.W - offer.line[1].W)/2, Y + offer.font[1].H + 30 * scaleY, offer.line[1].W, offer.line[1].H, tocolor( 255, 255, 255, 153 ) )
	

	dxDrawText( offer.text, offer.X + 50 * scaleX, Y + offer.font[1].H + 50 * scaleY, offer.X + offer.W - 50 * scaleX, 0, tocolor( 187, 187, 187 ), 1.0, offer.font[2].element, "left", "top", false, false, false, true )



	dxDrawImage( offer.X + (offer.W - offer.imgButtonW)/2, Y + offer.H - offer.imgButtonH - 15 * scaleY, offer.imgButtonW, offer.imgButtonH, "assets/button_offer.png" )
end

function offer.disable()
	if not offer.active then return end
	offer.lastTick = getTickCount()
	offer.active = false
	removeEventHandler( "onClientKey", root, offer.key )
end

addEvent('offer:disable', true)
addEventHandler( 'offer:disable', localPlayer, offer.disable )

function offer.show(info)
	local main = exports.sarp_main
	offer.lastTick = getTickCount()
	offer.active = true
	offer.title = string.format("Oferta od: #FFFFFF%s %s", getElementData(info.seller, "player:username"), info.group and string.format("(#42aaf4%s#FFFFFF)", info.group) or '')
	offer.text = main:wordBreak(string.format("#FFFFFF%s#bbbbbb oferuje Ci #FFFFFF%s za %d$#bbbbbb. Aby zaakceptować jego ofertę wybierz sposób płatności, możesz też ją odrzucić klikając ostatni przycisk.", getElementData(info.seller, "player:username"), info.service, info.cost), (365 * scaleX), false)

	addEventHandler( "onClientRender", root, offer.onRender )
	addEventHandler( "onClientKey", root, offer.key )
end

addEvent('offer:show', true)
addEventHandler( 'offer:show', localPlayer, offer.show )

function offer.key(button, pressed)
	if pressed and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
		if button == '.' then
			triggerServerEvent( 'offer:accept', localPlayer, localPlayer, 1 )
			offer.disable()
		elseif button == ',' then
			triggerServerEvent( 'offer:accept', localPlayer, localPlayer, 2 )
			offer.disable()
		elseif button == '/' then
			triggerServerEvent( 'offer:disable', localPlayer, localPlayer )
			offer.disable()
		end
	end
end

--[[
function offer.onRender()
	local Y
	if offer.active then
		local progress = (getTickCount() - offer.lastTick) / 500
		Y = interpolateBetween( screenY + offer.H, 0, 0, screenY - offer.H - 20 * scaleY, 0, 0, progress, 'Linear' )
	else
		local progress = (getTickCount() - offer.lastTick) / 500
		Y = interpolateBetween( screenY - offer.H - 20 * scaleY, 0, 0, screenY + offer.H, 0, 0, progress, 'Linear' )

		if progress > 1 then
			removeEventHandler( "onClientRender", root, offer.onRender )
			offer.text = ''
		end
	end

	dxDrawImage( screenX/2 - offer.W/2, Y, offer.W, offer.H, "assets/offer.png" )
	dxDrawText( offer.text, screenX/2 - offer.W/2 + 50 * scaleX, Y, screenX/2 + offer.W/2 + 50 * scaleX, Y + offer.H, tocolor(66, 134, 244), 1.2, "default-bold", "left", "center", false, false, false, true )
end

function offer.disable()
	if not offer.active then return end
	offer.lastTick = getTickCount()
	offer.active = false
	removeEventHandler( "onClientKey", root, offer.key )
end

addEvent('offer:disable', true)
addEventHandler( 'offer:disable', localPlayer, offer.disable )

function offer.show(text)
	offer.lastTick = getTickCount()
	offer.active = true
	offer.text = text
	addEventHandler( "onClientRender", root, offer.onRender )
	addEventHandler( "onClientKey", root, offer.key )
end

addEvent('offer:show', true)
addEventHandler( 'offer:show', localPlayer, offer.show )

function offer.key(button, pressed)
	if pressed and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
		if button == 'z' then
			triggerServerEvent( 'offer:accept', localPlayer, localPlayer, 1 )
			offer.disable()
		elseif button == 'c' then
			triggerServerEvent( 'offer:accept', localPlayer, localPlayer, 2 )
			offer.disable()
		elseif button == 'x' then
			triggerServerEvent( 'offer:disable', localPlayer, localPlayer )
			offer.disable()
		end
	end
end]]