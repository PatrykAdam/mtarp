local drug = {}
local shader = {}
local myScreenSource = dxCreateScreenSource(screenX, screenY)

function shader.onStart()
	shader.toonElement, toonTec = dxCreateShader("assets/toonShader.fx")
end

addEventHandler( "onClientResourceStart", resourceRoot, shader.onStart )

function drug.theEnd()
	setWeather( 0 )
	setCameraShakeLevel( 0 )

	if getElementData( localPlayer, 'player:drugUse') == 1 then
		removeEventHandler("onClientPreRender", root, shader.toon )
		destroyElement(shader.toonElement)
	end

	triggerServerEvent( "drugEnd", localPlayer, getElementData(localPlayer, "player:drugUse"))
end

function shader.toon()
	if (shader.toonElement) then
	  dxUpdateScreenSource(myScreenSource)
	  
	  dxSetShaderValue(shader.toonElement, "ScreenSource", myScreenSource)
		dxSetShaderValue(shader.toonElement, "ScreenWidth", screenX)
		dxSetShaderValue(shader.toonElement, "ScreenHeight", screenY)
	  dxSetShaderValue(shader.toonElement, "BitDepth", 16)
		dxSetShaderValue(shader.toonElement, "OutlineStrength", 0.2)

	  dxDrawImage(0, 0, screenX, screenY, shader.toonElement)
  end
end

function drug.use(id)
	if id == 1 then
		setWeather( 65 )
		setCameraShakeLevel( 150 )
		addEventHandler("onClientPreRender", root, shader.toon )
	elseif id == 2 then
		setWeather( 251 )
		setCameraShakeLevel( 150 )
	elseif id == 3 then
		setWeather( 2011 )
	elseif id == 4 then
		setWeather( -68 )
		setCameraShakeLevel( 255 )
	elseif id == 5 then
		setWeather( -53 )
	else
		setWeather( 63 )
	end
	setTimer( drug.theEnd, 10 * 60000, 1)
end

function drug.onDataChange(dataName, oldValue)
	if getElementType(source) == 'player' and dataName == 'player:drugUse' then
		drug.use(getElementData( source, 'player:drugUse'))
	end
end

addEventHandler( "onClientElementDataChange", localPlayer, drug.onDataChange )