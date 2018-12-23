local screen = Vector2( guiGetScreenSize(  ) )
local shader = dxCreateShader( "assets/alcohol.fx" )
local screenSource = dxCreateScreenSource( screen.x, screen.y )
local onClientRenderFunc = false
dxSetShaderValue( shader, "ScreenTexture", screenSource )
dxSetShaderValue( shader, "drunkLevel", 0 )

function onClientRenderManagerShader()
    onChangeControl();
    dxSetRenderTarget();
    local drunkLevel = getElementData(localPlayer,"drunkLevel")
    if drunkLevel > 5.0 then
        drunkLevel = 5.0
    end
    dxSetShaderValue( shader, "drunkLevel", tonumber(drunkLevel) );
    dxUpdateScreenSource(screenSource);
    dxDrawImage(0, 0, screen.x, screen.y, shader);
end

addEventHandler ( "onClientElementDataChange", getRootElement(), function (dataName, oldValue)
    if dataName == "drunkLevel" then
        local drunkLevel = getElementData(localPlayer,"drunkLevel") or 0;
        if tonumber( drunkLevel ) > 0 then
            if not onClientRenderFunc then
                addEventHandler( "onClientHUDRender", getRootElement( ), onClientRenderManagerShader );
                onClientRenderFunc = not onClientRenderFunc;
            end
        else
            if onClientRenderFunc then
                removeEventHandler( "onClientHUDRender", getRootElement( ), onClientRenderManagerShader );
                onClientRenderFunc = not onClientRenderFunc;
            end
        end
    end
end)