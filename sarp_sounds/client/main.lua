--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

soundStreamer = {}
soundStreamer.debug = false
soundStreamer.func = {}
soundStreamer.table = {}
soundStreamer.cache = {}

--[[
- string file/element sound -- (file/url)/ playSound
- int looped 			-- czy dźwięk jest zapętlony
- Vector3 pos 			-- pozycja dźwięku
- table effect 		-- efekty w tablicy
- float streamDistance 	-- zasięg streamowania
- float hearDistance 	-- zasięg słyszenia
- float volume			-- głośność dźwięku (0.0 - 1.0)
- element attach 		-- attach dzwieku
- int interior			-- interior
- int dimension 		-- virtualworld
- int lenght            -- dlugosc dzwieku
]]

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function soundStreamer.func.getFreeSoundStreamerID()
	local i = 1
	while true do
		if type(soundStreamer.table[i]) ~= "table" then return i end
		i = i + 1
	end
end

function soundStreamer.func.create3DSound(data, loop, vPos, eff, streamDist, hearDist, vol, par, int, dim, length)
	local index = soundStreamer.func.getFreeSoundStreamerID()
	if isElement(par) then
		vPos = par:getPosition()
	end
	soundStreamer.table[index] =
	{
		ID = index,
		sound = nil,
		pos = vPos,
		effect = eff,
		file = data,
		streamDistance = streamDist or 25.0,
		hearDistance = hearDist or 10.0,
		volume = vol or 1.0,
		parent = par,
		looped = loop or true,
		interior = int or 0, 
		dimension = dim or 0,
		isAudioCreated = false,
		activeEffect = {},
		disabledEffect = {},
	}
	if length then
		if not tonumber(length) then
			local sound = playSound(soundStreamer.table[index].file)
			setSoundVolume(sound, 0.0 )
			local length = getSoundLength(sound)
			if isElement(sound) then destroyElement(sound) end
			soundStreamer.table[index].stopTimer = setTimer(soundStreamer.func.destroy3DSound, length*1000, 1, index)
		else
			soundStreamer.table[index].stopTimer = setTimer(soundStreamer.func.destroy3DSound, length, 1, index)
		end
	end
	if soundStreamer.debug then
		outputDebugString(string.format("[MTARP Sounds] [INFO] Dźwięk o ID %d został stworzony.", index))
	end
	soundStreamer.func.streamPosition()
	return index
end

function soundStreamer.func.destroy3DSound(index)
	if type(soundStreamer.table[index]) == "table" then
		if isTimer(soundStreamer.table[index].stopTimer) then killTimer(soundStreamer.table[index].stopTimer) end
		if isElement(soundStreamer.table[index].sound) then destroyElement(soundStreamer.table[index].sound) end
		outputDebugString(string.format("[MTARP Sounds] [INFO] Dźwięk o ID %d został usunięty.", index))
		soundStreamer.table[index] = nil
		return true
	end
	return false
end

function soundStreamer.func.stop3DSound(index)
	if type(soundStreamer.table[index]) == "table" then
		if isTimer(soundStreamer.table[index].stopTimer) then killTimer(soundStreamer.table[index].stopTimer) end
		if isElement(soundStreamer.table[index].sound) then destroyElement(soundStreamer.table[index].sound) end
		soundStreamer.table[index].isAudioCreated = false
		soundStreamer.table[index].activeEffect = {}
		if soundStreamer.debug then
			outputDebugString(string.format("[MTARP Sounds] [INFO] Dźwięk o ID %d został zatrzymany.", index))
		end
		return true
	end
	return false
end

function soundStreamer.func.streamPosition()
	local playerPos = localPlayer:getPosition()
	local dimension = localPlayer:getDimension()
	local interior = localPlayer:getInterior()
	for k, v in pairs(soundStreamer.table) do
		if v and type(v) == "table" then
			local interiorAndDimension = false
			if isElement(v.parent) then
				if v.parent:getInterior() == interior and v.parent:getDimension() == dimension then interiorAndDimension = true end
			else
				if v.interior == interior and v.dimension == dimension then interiorAndDimension = true end
			end
			if getDistanceBetweenPoints3D(playerPos, v.pos) > v.streamDistance or not interiorAndDimension then
				if soundStreamer.table[k] then
					if isElement(v.sound) then destroyElement(v.sound) end
				end
			else
				if not soundStreamer.table[k] then
					soundStreamer.table[k] = true
				end
			end
		end
	end
end

function soundStreamer.func.debuging(data)
	local playerPos = localPlayer:getPosition()
	local soundPos = data.sound:getPosition()
    local distance = getDistanceBetweenPoints3D ( playerPos, data.pos ) 
    if distance <= data.streamDistance then 
        local sx,sy = getScreenFromWorldPosition ( data.pos.x, data.pos.y, data.pos.z+0.95, 0.06 ) 
        if not sx then return end
        local progress = (data.hearDistance - distance) / data.hearDistance
		if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end
		local volume = progress * data.volume
        local text = string.format("(%d m) Dźwięk ID %d\nPlik/Url: %s\nStream Distance: %d m\nGłosność: %f", distance, data.ID, data.file, data.streamDistance, volume)
        if type(data.effect) == "table" then
        	text = string.format("%s\nEffects: %s", text, table.concat(data.effect,", ") )
        end
        if data.parent then
        	text = string.format("%s\nAttach: %s", text, inspect(data.parent) )
        end

        local scale = 1/(0.3 * (distance / data.streamDistance)) 
        dxDrawText (text, sx, sy - 30, sx, sy - 30, tocolor(255,255,255,255), math.min ( 0.4*(150/distance)*1.4,2), "default-bold", "center", "bottom", false, false, false ) 
    end 
end

function soundStreamer.func.setCanal(playerPos, playerRot, k)
	local camX, camY, camZ = getCameraMatrix()
	soundStreamer.table[k].canal = "L - R"
end

function soundStreamer.func.streamSound()
	local playerPos = localPlayer:getPosition()
	local playerRot = localPlayer:getRotation()
	for k, v in pairs(soundStreamer.table) do
		if k and v then
			if type(soundStreamer.table[k]) == "table" and soundStreamer.table[k].file then
				if not isElement(soundStreamer.table[k].sound) then
					if not soundStreamer.table[k].isAudioCreated then
						if not soundStreamer.table[k].file then return end
						local distance = getDistanceBetweenPoints3D(playerPos, soundStreamer.table[k].pos)
						if distance < soundStreamer.table[k].streamDistance then
							soundStreamer.table[k].sound = playSound(soundStreamer.table[k].file, soundStreamer.table[k].looped)
							if soundStreamer.debug then
								outputDebugString(string.format("[MTARP Sounds] [INFO] Dźwięk o ID %d został streamowany.", k))
							end
						end
						if isElement(soundStreamer.table[k].sound) then
							soundStreamer.table[k].isAudioCreated = true
							if type(soundStreamer.table[k].effect) == "table" then
								for i = 1, #soundStreamer.table[k].effect do
									if not soundStreamer.table[k].activeEffect[i] then
										setSoundEffectEnabled(soundStreamer.table[k].sound, soundStreamer.table[k].effect[i], true)
										table.insert(soundStreamer.table[k].activeEffect, {effect = soundStreamer.table[k].effect[i], active = nil} )
									end
								end
							end
							if not soundStreamer.table[k].parent then
								setElementInterior(soundStreamer.table[k].sound, soundStreamer.table[k].interior)
								setElementDimension(soundStreamer.table[k].sound, soundStreamer.table[k].dimension)
							end
							local distance = getDistanceBetweenPoints3D(playerPos, soundStreamer.table[k].pos)
							local progress = (soundStreamer.table[k].hearDistance - distance) / soundStreamer.table[k].hearDistance
							if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end
							setSoundVolume(soundStreamer.table[k].sound, progress * soundStreamer.table[k].volume)
						end
					else
						soundStreamer.func.stop3DSound(k)
					end
				else
					if type(soundStreamer.table[k].effect) == "table" and #soundStreamer.table[k].activeEffect > 0 then
						for i = 1, #soundStreamer.table[k].effect do
							if soundStreamer.table[k].activeEffect[i].active == false then
								setSoundEffectEnabled(soundStreamer.table[k].sound, soundStreamer.table[k].activeEffect[i].effect, false)
								soundStreamer.table[k].effect[i] = nil
								soundStreamer.table[k].activeEffect[i] = nil
							elseif soundStreamer.table[k].activeEffect[i].active == true then
								local name = soundStreamer.table[k].activeEffect[i].effect
								setSoundEffectEnabled(soundStreamer.table[k].sound, name, true)
								soundStreamer.table[k].activeEffect[i].active = nil
							end
						end
					end
					local distance = getDistanceBetweenPoints3D(playerPos, soundStreamer.table[k].pos)
					local progress = (soundStreamer.table[k].hearDistance - distance) / soundStreamer.table[k].hearDistance
					if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end
					soundStreamer.func.setCanal(playerPos, playerRot, k);
					setSoundVolume(soundStreamer.table[k].sound, progress * soundStreamer.table[k].volume)
					if soundStreamer.debug then
						soundStreamer.func.debuging(soundStreamer.table[k])
					end
					if soundStreamer.table[k].parent then
						if isElement(soundStreamer.table[k].parent) then
							soundStreamer.table[k].pos = soundStreamer.table[k].parent:getPosition()
							setElementInterior(soundStreamer.table[k].sound, soundStreamer.table[k].parent:getInterior())
							setElementDimension(soundStreamer.table[k].sound, soundStreamer.table[k].parent:getDimension())
						else
							soundStreamer.func.stop3DSound(k)
						end
					end
				end
			end
		end
	end
end

function soundStreamer.func.setEffect3DSound(index, nameEffect, enabled) 
	if index ~= nil and soundStreamer.table[index] and nameEffect then
		if not enabled then
			for i=1,#soundStreamer.table[index].activeEffect do
				if soundStreamer.table[index].activeEffect[i].effect == nameEffect then
					soundStreamer.table[index].activeEffect[i].active = enabled
					return true
				end
			end
		elseif enabled then
			local i = #soundStreamer.table[index].activeEffect
			if not soundStreamer.table[index].effect then
				soundStreamer.table[index].effect = {}
			else
				for i=1,#soundStreamer.table[index].activeEffect do
					if soundStreamer.table[index].activeEffect[i].effect == nameEffect then
						return false
					end
				end
			end
			local i2 = #soundStreamer.table[index].effect
			soundStreamer.table[index].effect[i2+1] = nameEffect
			soundStreamer.table[index].activeEffect[i+1] = {effect = nameEffect, active = enabled}
			return true
		end
	end
end

function soundStreamer.func.getEffect3DSound(index)
	if index ~= nil and soundStreamer.table[index] then
		return soundStreamer.table[index].effect, soundStreamer.table[index].activeEffect
	else
		return false
	end
end

function soundStreamer.func.setPosition3DSound(index, x, y, z)
	if index ~= nil and soundStreamer.table[index] and soundStreamer.table[index].parent == nil then
		soundStreamer.table[index].pos = Vector3(x, y, z)
		soundStreamer.func.stop3DSound(index)
		return true
	else
		return false
	end
end

function soundStreamer.func.getPosition3DSound(index)
	if index ~= nil and soundStreamer.table[index] and soundStreamer.table[index].parent == nil then
		return soundStreamer.table[index].pos
	else
		return false
	end
end

function soundStreamer.func.setInterior3DSound(index, interior)
	if index ~= nil and soundStreamer.table[index] and soundStreamer.table[index].parent == nil then
		soundStreamer.table[index].interior = interior
		soundStreamer.func.stop3DSound(index)
		return true
	else
		return false
	end
end

function soundStreamer.func.getInterior3DSound(index)
	if index ~= nil and soundStreamer.table[index] and soundStreamer.table[index].parent == nil then
		return soundStreamer.table[index].interior
	else
		return false
	end
end

function soundStreamer.func.setDimension3DSound(index, dimension)
	if index ~= nil and soundStreamer.table[index] and soundStreamer.table[index].parent == nil then
		soundStreamer.table[index].dimension = dimension
		soundStreamer.func.stop3DSound(index)
		return true
	else
		return false
	end
end

function soundStreamer.func.getDimension3DSound(index)
	if index ~= nil and soundStreamer.table[index] and soundStreamer.table[index].parent == nil then
		return soundStreamer.table[index].dimension
	else
		return false
	end
end

function soundStreamer.func.onClientRender()
	soundStreamer.func.streamPosition();
	soundStreamer.func.streamSound();
end
addEventHandler ( "onClientRender", root, soundStreamer.func.onClientRender )


create3DSound = soundStreamer.func.create3DSound
destroy3DSound = soundStreamer.func.destroy3DSound

setSound3DEffect = soundStreamer.func.setEffect3DSound
getSound3DEffects = soundStreamer.func.getEffect3DSound 

setSound3DPosition = soundStreamer.func.setPosition3DSound
getSound3DPosition = soundStreamer.func.getPosition3DSound

setSound3DInterior = soundStreamer.func.setInterior3DSound
getSound3DInterior = soundStreamer.func.getInterior3DSound

setSound3DDimension = soundStreamer.func.setDimension3DSound
getSound3DDimension = soundStreamer.func.getDimension3DSound


--[[ Example:
local index = create3DSound("https://files.kusmierz.be/rmf/maxxx.m3u", false, Vector3(-1444.75, -13.79, 14.15), {"i3dl2reverb", "chorus"}, 50, 50, 1.0, nil, nil, nil, nil)
--]]