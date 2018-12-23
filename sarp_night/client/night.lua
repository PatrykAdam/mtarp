--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

Night = { func = {} }
Night.data = {}
Night.effects = {}
Night.settings = {}
Night.settings.remove = {"fist","Brassknuckleicon","Golfclubicon","Nightstickicon","Knifeicon","Baticon","Shovelicon","Poolstickicon","Katanaicon","Chainsawicon","Dildoicon","Dildoicon","Vibratoricon","Vibratoricon","Flowericon","Caneicon","Grenadeicon","Teargasicon","Molotovicon","Rocketicon","Rocketicon","Freefall Bombicon","Colt 45icon","Silencedicon","Deagleicon","Shotgunicon","Sawed-officon","Combat Shotgunicon","Uziicon","MP5icon","AK-47icon","M4icon","Tec-9icon","Rifleicon","Snipericon","Rocket Launchericon","Rocket Launcher HSicon","Flamethrowericon","Minigunicon","Satchelicon","Bombicon","Spraycanicon","Fire Extinguishericon","Cameraicon","Nightvisionicon","Infraredicon","Parachuteicon",'tx*','coronastar','shad_exp*', 'weapon*','radar*','*icon','font*','grass','lampost_16clr','headlight','vehiclegeneric256'}
Night.settings.light = 1.0
Night.settings.maxLight = 0.15
Night.settings.speed = 0.005
Night.settings.hours = {
	[0] = {fade = true, max = 0.50},
	[1] = {fade = true, max = 0.15},
	[2] = {fade = true, max = 0.15},
	[3] = {fade = true, max = 0.15},
	[4] = {fade = true, max = 0.19},
	[5] = {fade = true, max = 0.20},
	[6] = {fade = true, max = 0.40},
	[7] = {fade = true, max = 0.70},
	[8] = {fade = true, max = 1.0},
	[9] = {fade = false},
	[10] = {fade = false},
	[11] = {fade = false},
	[12] = {fade = false},
	[13] = {fade = false},
	[14] = {fade = false},
	[15] = {fade = false},
	[16] = {fade = false},
	[17] = {fade = false},
	[18] = {fade = false},
	[19] = {fade = false},
	[21] = {fade = false},
	[22] = {fade = true, max = 0.85},
	[23] = {fade = true, max = 0.65},
}

function Night.func.isNight()
	local hours, minutes = getTime()
	if Night.settings.hours[tonumber(hours)] then
		Night.settings.fade = Night.settings.hours[hours].fade or false
		if Night.settings.hours[hours].max then
			Night.settings.maxLight = Night.settings.hours[hours].max
		end
	end
end


function Night.func.enabled()
	if Night.data.enable then return end
	Night.data.list = {}
	for color=65,96 do
		shader = dxCreateShader( 'client/fx/night.fx', 0.0, 0.0, false, "all" )
		engineApplyShaderToWorldTexture(shader, string.format('%c*', color + 32) )
		for i,v in pairs(Night.settings.remove) do
			engineRemoveShaderFromWorldTexture(shader, v)
		end
		table.insert(Night.data.list, shader)
	end
	addEventHandler('onClientHUDRender', root, Night.func.onClientHUDRender)
	Night.data.enable = not Night.data.enable
end

function Night.func.disabled()
	if not Night.data.enable then return end
	removeEventHandler('onClientHUDRender', root, Night.func.onClientHUDRender)
	for i,shader in pairs(Night.data.list) do
		destroyElement( shader )
	end
	Night.settings.fade = false
	Night.data.enable = not Night.data.enable
end

function Night.func.onClientHUDRender()
	if Night.data.enable then
		Night.func.isNight()
		local interior, dimension = getElementInterior(localPlayer), getElementDimension(localPlayer)
		if Night.settings.fade then
			if Night.settings.light > Night.settings.maxLight then
				Night.settings.light = Night.settings.light - Night.settings.speed
			elseif Night.settings.light <= Night.settings.maxLight then
				Night.settings.light = Night.settings.maxLight
			end
		else
			if Night.settings.light < 1.0 then
				Night.settings.light = Night.settings.light + Night.settings.speed
			elseif Night.settings.light >= 1.0 then
				Night.settings.lightb = 1.0
			end
		end
		for _,shader in ipairs(Night.data.list) do
			if interior == 0 and dimension == 0 then
				dxSetShaderValue(shader, 'NIGHT', Night.settings.light, Night.settings.light, Night.settings.light)
			else
				dxSetShaderValue(shader, 'NIGHT', 1.0, 1.0, 1.0)
			end
		end
	end
end

--[[
Testing = {}
Testing.lasttick = getTickCount(  )
Testing.tick = getTickCount(  )
setTime( 21, 0 )
function Night.func.debugShader()
if getTickCount(  )-Testing.lasttick > 100 and getKeyState( "n" ) then
	if Night.data.enable then
		Night.func.disabled()
	else
		Night.func.enabled()
	end
	Testing.lasttick = getTickCount(  )
end
if getTickCount(  )-Testing.tick > 5000 then
	local hours, minutes = getTime()
	if minutes > 60 then
		minutes = 0
		hours = hours+1
		Testing.tick = getTickCount(  )
	else
		minutes = minutes+1
	end
	setTime( hours, minutes )
else
	local hours, minutes = getTime()
	setTime( hours, minutes )
end
	dxDrawText("Shader night: "..(Night.data.enable and "#00ff00Enabled" or "#FF0000Disabled"), 0, 0, 100, 100, tocolor(255, 175, 0, 255), 2.0, "default-bold", "left", "top", false, false, false, true)
	dxDrawText(string.format("{light = %0.3f, maxLight = %0.3f, speedLight = %0.3f}",Night.settings.light, Night.settings.maxLight, Night.settings.speed), 0, 120, 100, 100, tocolor(255, 175, 0, 255), 2.0, "default-bold", "left", "top", false, false, false, true)	
	dxDrawText("(GTA:SA) Light: "..(not Night.settings.fade and "#00ff00Enabled" or "#FF0000Disabled"), 0, 30, 100, 100, tocolor(255, 175, 0, 255), 2.0, "default-bold", "left", "top", false, false, false, true)	
	dxDrawText("(Shader) Light: "..(Night.settings.fade and "#00ff00Enabled" or "#FF0000Disabled"), 0, 60, 100, 100, tocolor(255, 175, 0, 255), 2.0, "default-bold", "left", "top", false, false, false, true)	
end
--]]