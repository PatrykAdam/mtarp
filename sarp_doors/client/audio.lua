--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local doorAudio
local audioData = {}
local audio = {}

function audio.doorOff()
	if not isElement(doorAudio) then return end
	stopSound( doorAudio )
end

addEvent('doorSoundOff', true)
addEventHandler( 'doorSoundOff', root, audio.doorOff )

function audio.doorSound(soundURL)
	if isElement(doorAudio) then audio.doorOff() end
	doorAudio = playSound( soundURL, true )
	setSoundVolume( doorAudio, 0.5 )
end

addEvent('doorSound', true)
addEventHandler( 'doorSound', root, audio.doorSound )

function audio.load(pickup)
	if not getElementData(pickup, "doors:url") then return end
	for i, v in ipairs(audioData) do
		if v.doorid == source then
			exports.sarp_sounds:destroy3DSound( v.index )
		end
	end

	local pX, pY, pZ = getElementPosition( pickup )
	table.insert(audioData, {doorid = pickup, index = exports.sarp_sounds:create3DSound( getElementData(pickup, "doors:url"), true, Vector3(pX, pY, pZ), {"i3dl2reverb", "chorus"}, 5, 5, 1.0, pickup, getElementInterior( pickup ), getElementDimension( pickup ), nil)})
end

function audio.onChange(keyName, oldValue)
	if getElementType( source ) == 'marker' and keyName == 'doors:url' then
		audio.load( source )
	end
end

addEventHandler( "onClientElementDataChange", root, audio.onChange )

function audio.onStart()
	for i, v in ipairs(getElementsByType("marker")) do
		if getElementData(v, "type:doors") then
			audio.load( v )
		end
	end
end

addEventHandler( "onClientResourceStart", resourceRoot, audio.onStart )

function audio.onStop()
	for i, v in ipairs(audioData) do
		exports.sarp_sounds:destroy3DSound( v.index )
	end
end

addEventHandler( "onClientResourceStop", resourceRoot, audio.onStop )