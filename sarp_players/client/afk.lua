--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local afk = {}
afk.lastCords = {}
afk.count = 0
afk.W, afk.H = 496 * scaleX, 191 * scaleY
afk.font = dxCreateFont( "assets/Lato-Regular.ttf", 12 * scaleX )
afk.fontH = dxGetFontHeight( 1.0, afk.font )
afk.X, afk.Y = screenX/2 - afk.W/2, screenY/2 - afk.H/2
afk.iconW, afk.iconH = 57 * scaleX, 50 * scaleX

function afk.showMessage()
	local x, y, z = getCameraMatrix()

	if afk.lastCords[1] ~= x or afk.lastCords[2] ~= y or afk.lastCords[3] ~= z then
		setElementData( localPlayer, "player:afk", false )
		afk.count = 0
		exports.sarp_blur:setBlurStatus(false)
		removeEventHandler( "onClientRender", root, afk.showMessage )
	end

	dxDrawRectangle( afk.X, afk.Y, afk.W, afk.H, tocolor(0, 0, 0, 150) )
	dxDrawLine( afk.X, afk.Y, afk.X, afk.Y + afk.H, tocolor( 163, 162, 160 ) )
	dxDrawLine( afk.X, afk.Y, afk.X + afk.W, afk.Y, tocolor( 163, 162, 160 ) )
	dxDrawLine( afk.X + afk.W, afk.Y, afk.X + afk.W, afk.Y + afk.H, tocolor( 163, 162, 160 ) )
	dxDrawLine( afk.X, afk.Y + afk.H, afk.X + afk.W, afk.Y + afk.H, tocolor( 163, 162, 160 ) )
	dxDrawText( "AWAY FROM KEYBOARD", afk.X, afk.Y + 10 * scaleY, afk.X + afk.W, 0, tocolor( 255, 255, 255, 255 ), 2 * scaleX, "default", "center", "top" )

	local fontH = dxGetFontHeight( 2 * scaleX, "default" )

	dxDrawImage( afk.X + afk.W/2 - afk.iconW/2, afk.Y + 10 * scaleY + fontH, afk.iconW, afk.iconH, "assets/afkikonka.png" )

	dxDrawText( "Aktualnie posiadasz status AFK ponieważ Twoja postać nie wykazała aktywności - powrót do gry poprzez poruszenie myszki usunie status. Inni gracze również zostali o tym poinformowani po przez małą ikonkę nad Twoją postacią.", afk.X + 10 * scaleX, afk.Y + 15 * scaleY + fontH + afk.iconH, afk.X + afk.W - 10 * scaleX, 0, tocolor( 255, 255, 255, 255 ), 1.0, afk.font, "center", "top", false, true )
end

function afk.checkCamera()
	if getElementData(localPlayer, "player:afk") or not getElementData(localPlayer, "player:logged") then return end

	local x, y, z = getCameraMatrix()

	if afk.count == 4 then
		setElementData( localPlayer, "player:afk", true )
		exports.sarp_blur:setBlurStatus(true)
		addEventHandler( "onClientRender", root, afk.showMessage )
	end

	if afk.lastCords[1] == x and afk.lastCords[2] == y and afk.lastCords[3] == z then
		afk.count = afk.count + 1
		return
	end

	afk.lastCords = {x, y, z}
	afk.count = 0
end

function afk.onMove()
	if afk.count >= 3 then
		setElementData( localPlayer, "player:afk", false )
		afk.count = 0
		exports.sarp_blur:setBlurStatus(false)
		removeEventHandler( "onClientRender", root, afk.showMessage )
	end
end

addEventHandler( "onClientCursorMove", root, afk.onMove )

function afk.onStart()
	setTimer( afk.checkCamera, 15000, 0 )
end

addEventHandler( "onClientResourceStart", resourceRoot, afk.onStart )

function afk.onMinimalize()
	setElementData( localPlayer, "player:afk", true )
end

addEventHandler( "onClientMinimize", root, afk.onMinimalize )

function afk.onRestore()
	setElementData( localPlayer, "player:afk", false )
end

addEventHandler( "onClientRestore", root, afk.onRestore )