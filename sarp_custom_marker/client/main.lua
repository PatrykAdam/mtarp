--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local marker = {}
marker.maxDistance = 50
marker.texture = {}
marker.position = 0
marker.lastTick = getTickCount()
marker.time = 2000
markerData = {}
marker.font = dxCreateFont( "assets/Whitney-Medium.ttf", 12 )
table.insert(marker.texture, dxCreateTexture("assets/enter.png", "argb"))
table.insert(marker.texture, dxCreateTexture("assets/exit.png", "argb"))
table.insert(marker.texture, dxCreateTexture("assets/document.png", "argb"))
table.insert(marker.texture, dxCreateTexture("assets/jail.png", "argb"))

function marker.onStart()
	for i, v in ipairs(getElementsByType( "marker" )) do
  	if isElementStreamedIn( v ) then
  		markerData[v] = true
  		marker.update( v )
  	end
  end
end

addEventHandler( "onClientResourceStart", resourceRoot, marker.onStart )

function marker.onStreamOut()
	if getElementType( source ) == "marker" then
		markerData[source] = nil
	end
end

addEventHandler( "onClientElementStreamOut", root, marker.onStreamOut )

function marker.onStreamIn()
	if getElementType( source ) == "marker" then
		markerData[source] = true
		marker.update( source )
	end
end

addEventHandler( "onClientElementStreamIn", root, marker.onStreamIn )

function marker.update( element )
	if markerData[element] == true then
		markerData[element] = {}
	end

	if getElementData(element, "doors:arrest") == 1 then
		markerData[element].image = 4
		markerData[element].text = getElementData(element, "doors:name")
	elseif getElementData(element, "type:doors") then
		if getElementData(element, "doors:exit") then
			markerData[element].image = 2
			markerData[element].text = "Wyjście"
		else
			markerData[element].image = 1
			markerData[element].text = getElementData(element, "doors:name")
		end
	elseif getElementData(element, "type:govBOT") then
		if getElementData(element, "guiType") == 1 then
			markerData[element].image = 3
			markerData[element].text = "Wyrabianie dokumentów"
		end
	end
end

function marker.onRender()
	for i, v in pairs(markerData) do
		if not isElement( i ) then markerData[i] = nil return end

		local x, y, z = getElementPosition( i )
		local pX, pY, pZ = getElementPosition( localPlayer )
		local r, g, b, a = getMarkerColor( i )
		local position = 0

		if getDistanceBetweenPoints3D( x, y, z, pX, pY, pZ ) < marker.maxDistance and getElementDimension( localPlayer ) == getElementDimension( i ) and getElementInterior( localPlayer ) == getElementInterior( i ) then

			local progress = (getTickCount() - marker.lastTick) / marker.time
			if marker.position == 0 then
				position = math.floor(interpolateBetween(0, 0, 0, 200, 0, 0, progress, "InQuad"))

				if progress > 1 then
					marker.position = 1
					marker.lastTick = getTickCount()
				end
			elseif marker.position == 1 then
				position = math.floor(interpolateBetween(200, 0, 0, 0, 0, 0, progress, "OutQuad"))

				if progress > 1 then
					marker.position = 0
					marker.lastTick = getTickCount()
				end
			end

			dxDrawMaterialLine3D(x, y, z + 0.5 + (position/1000), x, y, z - 0.5 + (position/1000), marker.texture[v.image], 1, tocolor(r, g, b, 230))
			dxDraw3DText( v.text, x, y, z - 0.6, 1.0, marker.font, tocolor( 255, 255, 255 ))
		end	 
	end
end

addEventHandler( "onClientRender", root, marker.onRender )


--community
function dxDraw3DText(text, x, y, z, scale, font, color, maxDistance, colorCoded)
	if not (x and y and z) then
		outputDebugString("dxDraw3DText: One of the world coordinates is missing", 1);
		return false;
	end

	if not (scale) then
		scale = 2;
	end
	
	if not (font) then
		font = "default";
	end
	
	if not (color) then
		color = tocolor(255, 255, 255, 255);
	end
	
	if not (maxDistance) then
		maxDistance = 20;
	end
	
	if not (colorCoded) then
		colorCoded = false;
	end
	
	local pX, pY, pZ = getElementPosition( localPlayer );	
	local distance = getDistanceBetweenPoints3D(pX, pY, pZ, x, y, z);
	
	if (distance <= maxDistance and isLineOfSightClear( pX, pY, pZ, x, y, z, true, true, false, true, false, false, true, getPedOccupiedVehicle( localPlayer ))) then
		local x, y = getScreenFromWorldPosition(x, y, z);
		
		if (x and y) then
			local progress = distance / maxDistance
			scale = interpolateBetween(1.0, 0, 0, 0.6, 0, 0, progress, "Linear") * scale
		
			dxDrawText( text, x, y, _, _, color, scale, font, "center", "center", false, false, false, colorCoded);
			return true;
		end
	end
end