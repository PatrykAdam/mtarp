--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()

local nametag = {}
nametag.active = true
local nameData = {}
local quitData = {}

local config = {
	elements = {'player', 'vehicle', 'ped'},
	maxPed = 20,
	maxVehicle = 10,
	font = dxCreateFont( "assets/Whitney-Medium.ttf", 12),
	fontH = dxGetFontHeight( 1.0, dxCreateFont( "assets/Whitney-Medium.ttf", 12) ),
	font2 = dxCreateFont( "assets/Whitney-Medium.ttf", 10 ),
	font2H = dxGetFontHeight( 1.0, dxCreateFont( "assets/Whitney-Medium.ttf", 10) )
}

function nametag.onStart()
	for i, v in ipairs(getElementsByType( "player" )) do
  	setPlayerNametagShowing( v, false )
  
  	if isElementStreamedIn( v ) and getElementData(v, "player:logged") then
  		nameData[v] = true
  		nametag.update( v )
  	end
  end
end

addEventHandler( "onClientResourceStart", resourceRoot, nametag.onStart )

function nametag.onRender()
	local mX, mY, mZ = getCameraMatrix()

	--PLAYER
	for i, v in pairs(nameData) do
		if isElement(i) and getElementDimension( i ) == getElementDimension( localPlayer ) and getElementInterior( i ) == getElementInterior( localPlayer ) and getElementAlpha( i ) ~= 0 then
			if getElementType( i ) == 'player' then
				local pX, pY, pZ = getPedBonePosition( i, 8 )
				
				local vehicle = getPedOccupiedVehicle( i )
				local myVehicle = getPedOccupiedVehicle( localPlayer )
				local maxDistance = config.maxPed
				if vehicle and nameData[vehicle] then
					local window = nameData[vehicle].darkWindow

					if myVehicle and window and myVehicle ~= vehicle then
						if window == 1 then
							maxDistance = config.maxPed/2
						elseif window == 2 then
							maxDistance = config.maxPed/4
						elseif window == 3 then
							maxDistance = 0
						end
					end
				end

				local distance = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)
				local progress = distance / config.maxPed
				local scale = interpolateBetween(1.0, 0, 0, 0.6, 0, 0, progress, "Linear")
				
				if maxDistance >= distance and isLineOfSightClear( pX, pY, pZ, mX, mY, mZ, true, true, false, true, false, false, true, getPedOccupiedVehicle( i )) then
					local sX, sY = getScreenFromWorldPosition(pX, pY, pZ+0.35)

					if sX then
						local _, line = string.gsub(v.name, '\n', '\n')
						for k, j  in ipairs(v.icons) do
							local size = 64 * scale
							dxDrawImage( sX + ((size * #v.icons)/2 - (size * k)), sY - ((config.fontH * scale) * (line + 1)) - size, size, size, j )
						end
						dxDrawText( v.name, sX, sY, sX, sY, nil, scale, config.font, "center", "bottom", false, false, false, true )
						if string.len(v.status) > 0 then
							dxDrawText( "["..v.status.."#FFFFFF]", sX, sY, sX, sY, nil, scale, config.font2, "center", "top", false, false, false, true )
						end
					end

					if v.desc then
						local pX2, pY2, pZ2 = getPedBonePosition( i, 3 )
						local sX2, sY2 = getScreenFromWorldPosition( pX2, pY2, pZ2 )
						if sX2 then
							dxDrawText( v.desc, sX2, sY2, sX2, sY2, tocolor( 178, 111, 232, 255 ), scale, "default-bold", "center", "center", false, false, false, true )
						end
					end
				end
			elseif getElementType( i ) == 'ped' then
				local pX, pY, pZ = getPedBonePosition( i, 8 )
				
				local myVehicle = getPedOccupiedVehicle( localPlayer )
				local maxDistance = config.maxPed

				local distance = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)
				local progress = distance / config.maxPed
				local scale = interpolateBetween(1.0, 0, 0, 0.6, 0, 0, progress, "Linear")
				
				if maxDistance >= distance and isLineOfSightClear( pX, pY, pZ, mX, mY, mZ, true, true, false, true, false, false, true, getPedOccupiedVehicle( i )) then
					local sX, sY = getScreenFromWorldPosition(pX, pY, pZ+0.35)

					if sX then
						local _, line = string.gsub(v.name, '\n', '\n')
						dxDrawText( v.name, sX, sY, sX, sY, tocolor(255, 255, 0), scale, config.font, "center", "bottom", false, false, false, true )
					end
				end
			elseif getElementType( i ) == 'vehicle' then
				local vX, vY, vZ = getElementPosition( i )
				local distance = getDistanceBetweenPoints3D( mX, mY, mZ, vX, vY, vZ )
				local progress = distance / config.maxVehicle
				local scale = interpolateBetween(1.2, 0, 0, 0.8, 0, 0, progress, "Linear")

				if config.maxVehicle >= distance and isLineOfSightClear( vX, vY, vZ, mX, mY, mZ, true, true, false, true, false, false, true, i) then
					local sX, sY = getScreenFromWorldPosition(vX, vY, vZ, 200)

					if sX then
						local repairTime = getElementData(i, "vehicle:repairTime")
						local repairType = getElementData(i, "vehicle:repairType")
						local desc = v.desc
						if repairTime then
							local repair
							if repairType == 1 then
								repair = 'naprawy karoserii'
							elseif repairType == 2 then
								repair = 'naprawy silnika'
							elseif repairType == 3 then
								repair = 'montażu części'
							elseif repairType == 4 then
								repair = 'demontażu części'
							end
							
							desc = string.format("#FFFFFFDo końca %s: %02d sekund", repair, repairTime)
						end

						if desc then
							dxDrawText( desc, sX, sY, sX, sY, tocolor( 178, 111, 232, 255 ), scale, "default-bold", "center", "center", false, false, false, true )
						end
					end
				end
			end
		end
	end

	--QUIT
	for i, v in pairs(quitData) do
		if quitData[i].dimension == getElementDimension( localPlayer ) and quitData[i].interior == getElementInterior( localPlayer ) then
			local maxDistance = 10.0

			local distance = getDistanceBetweenPoints3D(v.position, mX, mY, mZ)
			local progress = distance / maxDistance
			local scale = interpolateBetween(1.0, 0, 0, 0.6, 0, 0, progress, "Linear")
			
			if maxDistance >= distance and isLineOfSightClear( v.position, mX, mY, mZ, true, true, false, true, false, false, true) then
				local sX, sY = getScreenFromWorldPosition(v.position)

				if sX then
					dxDrawText( v.message, sX, sY, sX, sY, nil, scale, config.font, "center", "bottom", false, false, false, true )
				end
			end
		end

		if v.lastTick + 10000 < getTickCount() then
			quitData[i] = nil
		end
	end
end

addEventHandler( "onClientRender", root, nametag.onRender )

function nametag.onDamage(x, y, z, loss)
	if getElementType( source ) == "player" and nameData[source] then
		nameData[source].damage = true
		nametag.update( source )

		if nameData[source] and isTimer(nameData[source].timer) then
			killTimer( nameData[source].timer )
		end

		nameData[source].timer = setTimer(function(playerid)
			nameData[playerid].damage = false
			nametag.update( playerid )
		end, 2000, 1, source)
	end
end

addEventHandler( "onClientPlayerDamage", root, nametag.onDamage )

function nametag.onStreamIn()
	for i, v in ipairs(config.elements) do
		if getElementType( source ) == v then
			if getElementType( source ) == 'ped' and not getElementData(source, "ped:name") then return end

			nameData[source] = true
			nametag.update( source )
		end
	end
end

addEventHandler( "onClientElementStreamIn", root, nametag.onStreamIn )
addEvent("changeDescription", true)
addEventHandler( "changeDescription", root, nametag.onStreamIn)

function nametag.onStreamOut()
	for i, v in ipairs(config.elements) do
		if getElementType( source ) == v then
			nameData[source] = nil
		end
	end
end

addEventHandler( "onClientElementStreamOut", root, nametag.onStreamOut )

function nametag.update( element )
	if nameData[element] == true or type(nameData[element]) == 'table' then
		if nameData[element] == true then
			nameData[element] = {}
		end

		if getElementType(element) == 'player' then
			--NAME
			local nameColor = '#FFFFFF'
			local groupDuty = getElementData( element, "element:dutyInfo")
			local adminDuty = getElementData( element, "admin:duty")

			if getElementData(element, "global:premium") > getRealTime().timestamp then
				nameColor = "#ffd700"
			end

			if nameData[element].damage then
				nameColor = "#FF0000"
			end

			if adminDuty then
				nameData[element].name = string.format("%s%s\n#FFFFFF%s (%d)", getElementData(element, "global:color"), getElementData(element, "global:rank"), getElementData(element, "global:name"), getElementData(element, "player:mtaID"))
			elseif type(getElementData( element, "player:mask")) == 'string' then
				nameData[element].name = string.format("%sNieznajomy %s", nameColor, getElementData( element, "player:mask" ))
			else
				nameData[element].name = string.format("%s%s #FFFFFF(%d)", nameColor, getElementData(element, "player:username"), getElementData(element, "player:mtaID"))
			end
			

			--STATUS
			nameData[element].status = ''
			if getElementData(element, "player:strength") > 3200 then
				nameData[element].status = "Muskularny"
			elseif getElementData(element, "player:strength") > 3150 then
				nameData[element].status = "Umięśniony"
			end

			if getElementData(element, "player:bw") > 0 then
				if string.len(nameData[element].status) > 0 then
					nameData[element].status = string.format("%s, ", nameData[element].status)
				end
				nameData[element].status = string.format("%s%s", nameData[element].status, "nieprzytomny")
			end

			local drunk = (getElementData(element, "drunkLevel") or 0)
			if drunk > 0 then
				if string.len(nameData[element].status) > 0 then
						nameData[element].status = string.format("%s, ", nameData[element].status)
				end
				nameData[element].status = string.format("%s%s", nameData[element].status, "pijany")
			end

			local drug = getElementData(element, "player:drugUse")

			if drug then
				if string.len(nameData[element].status) > 0 then
						nameData[element].status = string.format("%s, ", nameData[element].status)
				end
				nameData[element].status = string.format("%s%s", nameData[element].status, "naćpany")
			end

			local knebel = getElementData(element, "player:muted")

			if knebel then
				if string.len(nameData[element].status) > 0 then
						nameData[element].status = string.format("%s, ", nameData[element].status)
				end
				nameData[element].status = string.format("%s%s", nameData[element].status, "knebel")
			end

			local dutyInfo = getElementData(element, "player:dutyInfo")
			if type(dutyInfo) == 'table' then
				if string.len(nameData[element].status) > 0 then
					nameData[element].status = string.format("%s, ", nameData[element].status)
				end
				nameData[element].status = string.format("%s%s%s", nameData[element].status, dutyInfo[1], dutyInfo[2])
			end

			--ENDSTATUS

			--IKONKI
			nameData[element].icons = {}
			if getElementData( element, "player:afk") then
				table.insert(nameData[element].icons, "assets/afk.png")
			end
			--ENDIKONKI

			local desc = getElementData(element, "player:desc")
			if desc then
				nameData[element].desc = exports.sarp_main:wordBreak(desc, 250, false, 1.0, "default-bold")
			end
		elseif getElementType( element ) == 'ped' then
				nameData[element].name = getElementData(element, "ped:name")
		elseif getElementType( element ) == 'vehicle' then
			local desc = getElementData(element, "vehicle:desc")
			if desc then
				nameData[element].desc = exports.sarp_main:wordBreak(desc, 250, false, 1.0, "default-bold")
			end

			local tuning = getElementData(element, "vehicle:tuning")

			local haveWindow = false

			if type(tuning) == 'table' then
				for i, v in ipairs(tuning) do
					if v.type == 5 then
						haveWindow = v.value
					end
				end
			end

			if haveWindow then
				nameData[element].darkWindow = haveWindow
			end
		end
	end
end

function nametag.onChanged(dataName, oldValue)
	local data = {
	'player:dutyInfo',
	'admin:duty',
	'player:strength',
	'player:mask',
	'player:afk',
	'player:bw',
	'drunkLevel',
	'vehicle:desc',
	'vehicle:repairTime',
	'vehicle:repairType',
	'player:muted',
	'ped:name',
	'player:drugUse'
}

	for i, v in ipairs(data) do
		if v == dataName then
			nametag.update( source )
		end
	end
end

addEventHandler( "onClientElementDataChange", root, nametag.onChanged )

function nametag.cmd(cmd)
	if nametag.active then
		nametag.active = false
		removeEventHandler( "onClientRender", root, nametag.onRender )
		exports.sarp_notify:addNotify("Nametagi zostały wyłaczone.")
	else
		nametag.active = true
		addEventHandler( "onClientRender", root, nametag.onRender )
		exports.sarp_notify:addNotify("Nametagi zostały włączone.")
	end
end

addCommandHandler( 'nametags', nametag.cmd  )

local write = {}

function write.onRender()
	if isChatBoxInputActive() then
		if getElementData(localPlayer, "chatWrite") == false then
			setElementData(localPlayer, "chatWrite", true)
		end
	else
		if getElementData(localPlayer, "chatWrite") == true then
			setElementData(localPlayer, "chatWrite", false)
		end
	end
end

addEventHandler( "onClientRender", root, write.onRender )

function write.newData(dataName)
	if not nameData[source] or dataName ~= 'chatWrite' then return end

	local state = getElementData(source, "chatWrite") or false

	if state == true then
		table.insert(nameData[source].icons, "assets/typing.png")
	else
		for i, v in ipairs(nameData[source].icons) do
			if v == 'assets/typing.png' then
				table.remove(nameData[source].icons, i)
			end
		end
	end
end

addEventHandler( "onClientElementDataChange", root, write.newData )

function nametag.onPlayerQuit(reason)
	if not getElementData(source, "player:logged") then return end

	if isElementStreamedIn( source ) then
		local time = getRealTime()
		quitData[source] = {}
		quitData[source].message = string.format("[%02d:%02d] %s [UID: %d] - %s", time.hour, time.minute, exports.sarp_main:getPlayerRealName(source), getElementData(source, "player:id"), reason)
		quitData[source].lastTick = getTickCount()
		quitData[source].dimension = getElementDimension( source )
		quitData[source].interior = getElementInterior( source )
		local pX, pY, pZ = getElementPosition( source )
		quitData[source].position = Vector3(pX, pY, pZ)
	end
end

addEventHandler( "onClientPlayerQuit", root, nametag.onPlayerQuit )