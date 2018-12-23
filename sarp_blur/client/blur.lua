--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local myScreenSource = false
local blurVShader = false
local blurHShader = false

function onStart()
	myScreenSource = dxCreateScreenSource( screenX, screenY )
	blurVShader,tecName = dxCreateShader( "assets/blurV.fx" )
	blurHShader,tecName = dxCreateShader( "assets/blurH.fx" )
	status = false
	count = 0
end

addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function onStop()
	if count > 0 then
		showChat( true )
		removeEventHandler( "onClientRender", root, onRender )
	end
end

addEventHandler( "onClientResourceStop", resourceRoot, onStop )

function onRender()
	if myScreenSource and status then
		RTPool.frameStart()
		dxUpdateScreenSource( myScreenSource )
		local current = myScreenSource
		current = applyDownsample( current, 2.4 )
		current = applyGBlurH( current, 1.2 )
		current = applyGBlurV( current, 1.2 )
		dxSetRenderTarget()
		dxDrawImage( 0, 0, screenX, screenY, current, 0,0,0 )
	end
end

function setBlurStatus(bool)
		count = count + (bool and 1 or -1)

		if count < 0 then
			count = 0
		end
	
	if count <= 0 then
		status = false
	else
		status = true
	end

	if status == true then
		showChat(false)
		addEventHandler( "onClientRender", root, onRender )
	else
		showChat( true )
		removeEventHandler( "onClientRender", root, onRender )
	end
end

--[[
		BLUR FUNCTION
]]--
function applyDownsample( Src, amount )
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	return newRT
end

function applyGBlurH( Src, bloom )
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "tex0", Src )
	dxSetShaderValue( blurHShader, "tex0size", mx,my )
	dxSetShaderValue( blurHShader, "bloom", bloom )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	return newRT
end

function applyGBlurV( Src, bloom )
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "tex0", Src )
	dxSetShaderValue( blurVShader, "tex0size", mx,my )
	dxSetShaderValue( blurVShader, "bloom", bloom )
	dxDrawImage( 0, 0, mx,my, blurVShader )
	return newRT
end


-----------------------------------------------------------------------------------
-- Pool of render targets
-----------------------------------------------------------------------------------
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( mx, my )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.mx == mx and info.my == my then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	local rt = dxCreateRenderTarget( mx, my )
	if rt then
		RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
	end
	return rt
end