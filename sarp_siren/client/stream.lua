--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

Siren = {}
Siren.data = {}
Siren.__index = Siren

function Siren:save(vehicle, value)
	local data = {}
	for i,v in ipairs(Siren.data[vehicle]) do
		table.insert(data, v.action)
	end
	vehicle:setData("sirens:now", data)
end

function Siren:isUse(vehicle, value)
	if vehicle and value then
		if Siren.data[vehicle] ~= nil and type(Siren.data[vehicle]) == "table" then
			for i,v in ipairs(Siren.data[vehicle]) do
				if v.action == value then
					return true
				end
			end
		end
		return false
	end
end

function Siren:Disabled(vehicle, value)
	if Siren:isUse(vehicle, value) then
		for i,v in ipairs(Siren.data[vehicle]) do
			if not value then
				exports["sarp_sounds"]:destroy3DSound(v.id)
				Siren.data[vehicle] = {}
			elseif value and v.action == value and tonumber(v.id) then
				exports["sarp_sounds"]:destroy3DSound(v.id)
				Siren.data[vehicle][i] = nil
			end
		end
		setElementData( vehicle ,"siren:state", false)
		Siren:save(vehicle, value)
	end
end

function Siren:Enabled(vehicle, loop, subType, value, not_save)
	if isElementStreamedIn(vehicle) and value then
		if not loop then
			local sirenData = _Sirens[tonumber(subType)][tonumber(value)].src
			if sirenData then
				exports["sarp_sounds"]:create3DSound(":sarp_siren/"..sirenData, false, nil, nil, 100, 50, 1.0, vehicle, nil, nil, _Sirens[tonumber(subType)][tonumber(value)].time)
			end
		else
			if Siren:isUse(vehicle, value) then
				return
			end
			if not Siren.data[vehicle] or type(Siren.data[vehicle]) ~= "table" then
				Siren.data[vehicle] = {}
			end

			local sirenData = _Sirens[tonumber(subType)][tonumber(value)].src
			if sirenData then
				local sirenID = exports["sarp_sounds"]:create3DSound(":sarp_siren/"..sirenData, true, nil, nil, 100, 50, 1.0, vehicle, nil, nil, nil)
				table.insert(Siren.data[vehicle], {id = sirenID, action = value} )
				if not not_save then
					setElementData( vehicle ,"siren:state", true)
					Siren:save(vehicle, value)
				end
			end
		end
	end
end

function Siren:toggle(vehicle, subType, value)
	if Siren:isUse(vehicle, value) then
		Siren:Disabled(vehicle, value)
		vehicle:setData("turnSiren", false)
	else
		local sirenData = _Sirens[tonumber(subType)][tonumber(value)]
		if sirenData then
			if subType and not sirenData.loop or ( sirenData.loop and not vehicle:getData("siren:state") ) then
				SirenEnabled(vehicle, sirenData.loop, subType, value)
				vehicle:setData("turnSiren", true)
			end
		end
	end
end

function Siren:onClientElementDataChange(dataName)
	if source:getType() == "vehicle" then
		if dataName == "turnSiren" then
			if source:getData("turnSiren") then
				if isElementStreamedIn(source) then
					if source:getData("sirens:now") then
						for i,v in ipairs( source:getData("sirens:now") ) do
							SirenEnabled(source, true, source:getData("subType"), v, true )
						end
					end
				end
			else
				SirenDisabled(source, source:getData("sirens") )
				return
			end
		elseif dataName == "vehicle:subType" then
			SirenDisabled( source )
		end
	end
end

function Siren:onClientStreamElementIn(player)
	if player:getType() == "vehicle" then
		if player:getData("turnSiren") then
			if player:getData("sirens:now") then
				for i,v in ipairs( player:getData("sirens:now") ) do
					SirenEnabled(player, true, player:getData("vehicle:subType"), v, true )
				end
			end
		end
	end
end

function Siren:onClientElementStreamOut(player)
	local source = player
	if source:getType() == "vehicle" then
		SirenDisabled(source)
		return
	end
end

function Siren:onClientKey(button, press)
	if press then
		if localPlayer:isInVehicle() and (localPlayer:getOccupiedVehicleSeat() == 0 or localPlayer:getOccupiedVehicleSeat() == 1) then
			if getKeyState("lshift") or getKeyState("rshift") then
				local vehicle = localPlayer:getOccupiedVehicle()
				local subType = vehicle:getData("vehicle:subType")
				if subType and tonumber(button) and _Sirens[subType][tonumber(button)] and _Sirens[subType][tonumber(button)].src then
					if _Sirens[subType][tonumber(button)].vehicle and _Sirens[subType][tonumber(button)].vehicle ~= getElementModel(vehicle) then
						return
					end
					Siren:toggle(vehicle, subType, button )
				end
			end
		end
	end
end

function Siren:onClientResourceStop(resource)
	for i,v in ipairs(getElementsByType("vehicle")) do
		if isElementStreamable( v ) then
			if Siren.data[v] then
				for i,data in pairs(Siren.data[v] ) do
					if tonumber(data.id) then
						exports["sarp_sounds"]:destroy3DSound(data.id)
					end
				end
			end
		end
	end
end

SirenOnClientResourceStop = function(resource) Siren:onClientResourceStop(resource) end
SirenDisabled = function(vehicle, value) Siren:Disabled(vehicle, value) end
SirenEnabled = function(vehicle, loop, subType, value, not_save) Siren:Enabled(vehicle, loop, subType, value, not_save) end
SirenOnClientKey = function(button, press) Siren:onClientKey(button, press) end
SirenOnClientElementIn = function() Siren:onClientStreamElementIn(source) end
SirenonClientElementOut = function() Siren:onClientElementStreamOut(source) end
SirenonClientElementDataChange = function(dataName) Siren:onClientElementDataChange(dataName) end


addEvent("sirenDisabled", true)
addEvent("sirenEnable", true)
addEventHandler("sirenDisabled", root, SirenDisabled)
addEventHandler("sirenEnable", root, SirenEnabled)
addEventHandler("onClientKey", root, SirenOnClientKey)
addEventHandler("onClientElementStreamIn", root, SirenOnClientElementIn)
addEventHandler("onClientElementStreamOut", root, SirenonClientElementOut)
addEventHandler("onClientElementDataChange", root, SirenonClientElementDataChange)
addEventHandler( "onClientResourceStop", getResourceRootElement(getThisResource()), SirenOnClientResourceStop)