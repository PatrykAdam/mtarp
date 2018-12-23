--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

debugging = { func = {}, active = false }
debugging.elements = {"vehicle", "object"}
debugging.stream = {}
debugging.data = {}

function debugging.func.cmd()
	if not debugging.active then
		addEventHandler( "onClientRender", getRootElement(), debugging.func.onClientRender )
	else
		removeEventHandler( "onClientRender", getRootElement(), debugging.func.onClientRender )
	end
	debugging.active = not debugging.active
end
addCommandHandler( "dl", debugging.func.cmd )

function debugging.func.onClientRender()
	local mX, mY, mZ = getCameraMatrix()
	for _,index in ipairs(debugging.elements) do
		if type(debugging.stream[index]) == "table" then
			for element in pairs(debugging.stream[index]) do
				if isElement(element) and getElementDimension( element ) == getElementDimension( localPlayer ) and getElementInterior( element ) == getElementInterior( localPlayer ) then
					local elemType = getElementType( element )
					if elemType == "vehicle" then
						debugging.func.information(element, elemType, mX, mY, mZ)
					elseif elemType == "object" then
						debugging.func.information(element, elemType, mX, mY, mZ)
					end
				end
			end
		end
	end
end

function debugging.func.information(element, elemType, mX, mY, mZ)
	if elemType == "vehicle" then
		local eX, eY, eZ = getElementPosition( element )
		eZ = eZ-0.6
		local distance = getDistanceBetweenPoints3D(eX, eY, eZ, mX, mY, mZ)
		local progress = distance / 20
		local scale = interpolateBetween(1.2, 0, 0, 0.6, 0, 0, progress, "Linear")
		if 20 >= distance then
			local sX, sY = getScreenFromWorldPosition(eX, eY, eZ)
			if sX then
				debugging.func.updateData(element)
				dxDrawText(debugging.data[element].text , sX, sY, sX, sY, tocolor(80, 144, 191, 255), scale, "default-bold", "center", "bottom", false, false, false, true)
			end
		end
	elseif elemType == "object" then
		local eX, eY, eZ = getElementPosition( element )
		local distance = getDistanceBetweenPoints3D(eX, eY, eZ, mX, mY, mZ)
		local progress = distance / 20
		local scale = interpolateBetween(1.2, 0, 0, 0.6, 0, 0, progress, "Linear")
		if 20 >= distance then
			local sX, sY = getScreenFromWorldPosition(eX, eY, eZ)
			if sX then
				debugging.func.updateData(element)
				dxDrawText(debugging.data[element].text , sX, sY, sX, sY, tocolor(80, 144, 191, 255), scale, "default-bold", "center", "bottom", false, false, false, true)
			end
		end


	end
end

function debugging.func.updateData(element)
	if isElement( element ) and getElementType(element) and debugging.stream[getElementType(element)][element] then
		debugging.data[element] = {}
		if getElementType( element ) == "vehicle" then
			local x, y, z = getElementPosition( element )
			local rx, ry, rz = getElementRotation( element, "ZYX" )
			local interior, dimension = getElementInterior( element ), getElementDimension( element )
			local trailer = "0"
			if getVehicleTowingVehicle( element ) then
				trailer = inspect( getVehicleTowingVehicle( element ) )
			elseif getVehicleTowedByVehicle( element ) then
				trailer = "By "..inspect( getVehicleTowedByVehicle( element ) )
			end
			debugging.data[element].text = string.format("[mtaID: %s, model: %s subtype: %s Health: %0.1f preloaded: %s]", tostring( getElementData(element,"vehicle:id") ), tostring( getElementModel(element) ), getVehicleType(element), getElementHealth( element ), getElementID( getElementParent(element) ) )
			debugging.data[element].text = string.format("%s\nDistance: %0.2fm", debugging.data[element].text, getDistanceBetweenPoints3D( Vector3( getElementPosition( element ) ), Vector3( getElementPosition( localPlayer ) ) ) )
			debugging.data[element].text = string.format("%s\nPassengerSeats: %d", debugging.data[element].text,   getVehicleMaxPassengers( element ) )
			debugging.data[element].text = string.format("%s\ncRot: (x = %0.3f, y = %0.3f, z = %0.3f)", debugging.data[element].text, rx, ry, rz )
			debugging.data[element].text = string.format("%s\ncPos: (x = %0.3f, y = %0.3f, z = %0.3f, interior = %d, dimension = %d)", debugging.data[element].text, x, y, z, interior, dimension )
			if getElementData(element, "vehicle:spawnPosition") then
				local pos = getElementData(element, "vehicle:spawnPosition")
				debugging.data[element].text = string.format("%s\nsPos: (x = %0.3f, y = %0.3f, z = %0.3f, interior = %d, dimension = %d)", debugging.data[element].text, pos.x, pos.y, pos.z, pos.interior, pos.dimension )
			end
			debugging.data[element].text = string.format("%s\nTrailer: %s", debugging.data[element].text, trailer )
			debugging.data[element].text = string.format("%s\nResource: %s", debugging.data[element].text, getElementID( getElementParent( getElementParent(element) ) ) )
		elseif getElementType( element ) == "object" then
			local x, y, z = getElementPosition( element )
			local rx, ry, rz = getElementRotation( element )
			local interior, dimension = getElementInterior( element ), getElementDimension( element )
			debugging.data[element].text = string.format("[mtaID: %s, model: %s preloaded: %s]", tostring( getElementData(element,"object:id") ), tostring( getElementModel(element) ), getElementID( getElementParent(element) ) )
			debugging.data[element].text = string.format("%s\nDistance: %0.2fm", debugging.data[element].text, getDistanceBetweenPoints3D( Vector3( getElementPosition( element ) ), Vector3( getElementPosition( localPlayer ) ) ) )
			debugging.data[element].text = string.format("%s\ncRot: (x = %0.3f, y = %0.3f, z = %0.3f)", debugging.data[element].text, rx, ry, rz )
			debugging.data[element].text = string.format("%s\ncPos: (x = %0.3f, y = %0.3f, z = %0.3f, interior = %d, dimension = %d)", debugging.data[element].text, x, y, z, interior, dimension )
			debugging.data[element].text = string.format("%s\nResource: %s", debugging.data[element].text, getElementID( getElementParent( getElementParent(element) ) ) )
		end
	end
end


function debugging.func.onClientResourceStart()
	for _,index in ipairs(debugging.elements) do
		for _,element in ipairs( getElementsByType( index ) ) do
			if isElementStreamable( element ) then
				if type(debugging.stream[getElementType(element)]) ~= "table" then
					debugging.stream[getElementType(element)] = {} 
				end
				debugging.stream[getElementType(element)][element] = true
				debugging.func.updateData(element)
			end
		end
	end
	if isPedInVehicle( localPlayer ) then
		local element = getPedOccupiedVehicle( localPlayer )
		if type(debugging.stream[getElementType(element)]) ~= "table" then
			debugging.stream[getElementType(element)] = {} 
		end
		debugging.stream[getElementType(element)][element] = true
		debugging.func.updateData(element)
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, debugging.func.onClientResourceStart )

function debugging.func.onClientElementStreamIn()
	if type(debugging.stream[getElementType(source)]) ~= "table" then
		debugging.stream[getElementType(source)] = {} 
	end
	debugging.stream[getElementType(source)][source] = true
	debugging.func.updateData(element)
end
addEventHandler( "onClientElementStreamIn", root, debugging.func.onClientElementStreamIn )

function debugging.func.onClientElementStreamOut()
	if type(debugging.stream[getElementType(source)]) ~= "table" then
		debugging.stream[getElementType(source)] = {} 
	end
	if debugging.stream[getElementType(source)][source] then
		debugging.stream[getElementType(source)][source] = nil
	end
end
addEventHandler( "onClientElementStreamOut", root, debugging.func.onClientElementStreamOut )