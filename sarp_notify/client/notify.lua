--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = math.max(0.6, (screenX / 1920)), math.max(0.6, (screenY / 1080))

local notify = {}
notify.waiting = {}
notify.W, notify.H = 344 * scaleX, 104 * scaleX
notify.font = dxCreateFont( "assets/Lato-Regular.ttf", 11 * scaleX )
notify.noLimit = {}

function addNotify(message, time)
	if not time then
		time = (dxGetTextWidth( message, 1.0, "default" )/100) * 1000
		if time < 2000 then
			time = 2000
		end 
	end

	if string.len(message) > 51 then
		if #notify.noLimit == 2 then table.remove(notify.noLimit, 2) end
		local message, space = exports.sarp_main:wordBreak(message, 405 * scaleX, false, 1.0, notify.font)
		
		table.insert(notify.noLimit, {
			time = time,
			state = 0,
			height = (space + 1) * dxGetFontHeight( 1.0, notify.font ),
			message = message
			})
	
		if #notify.noLimit == 1 then
			addEventHandler( "onClientRender", root, notify.noLimitRender)
		end
	else
		if #notify.waiting > 10 then table.remove(notify.waiting, 10) end
		table.insert(notify.waiting, {
			time = time,
			state = 0,
			message = exports.sarp_main:wordBreak(message, 210 * scaleX, false, 1.0, notify.font)
		})

		if #notify.waiting == 1 then
			addEventHandler( "onClientRender", root, notify.onRender)
		end
	end
end

addEvent("addNotify", true)
addEventHandler( "addNotify", root, addNotify )

function notify.onRender()
	for i = 1, 3 do
		local current = notify.waiting[i]
		if current then
			local X, alpha
			if current.state == 0 then
				if not current.startTick then
					current.startTick = getTickCount()
					local sound = playSound( "assets/sound.mp3" )
					setSoundVolume( sound, 0.5 )
				end

				local progress = (getTickCount() - current.startTick) / 500
				X, alpha = interpolateBetween( screenX + notify.W, 0, 0,
																					 screenX - notify.W, 255, 0,
																					 progress, "Linear" )
			
				if progress > 1 then
					current.startTick = getTickCount()
					current.state = 1
				end
			elseif current.state == 1 then
				X = screenX - notify.W
				alpha = 255

				if getTickCount() - current.startTick >= current.time then
					current.startTick = getTickCount()
					current.state = 2
				end
			elseif current.state == 2 then
			 local progress = (getTickCount() - current.startTick) / 500
				X, alpha = interpolateBetween( screenX - notify.W, 255, 0,
																				 screenX + notify.W, 0, 0,
																				 progress, "Linear" )

				if progress > 1 then
					table.remove(notify.waiting, i)

					if #notify.waiting == 0 then
						removeEventHandler( "onClientRender", root, notify.onRender)
					end
				end
			end

			dxDrawImage( X, 70 * scaleX + (90 * scaleX)*i, notify.W, notify.H, "assets/notificationGUI.png", 0, 0, 0, tocolor(255, 255, 255, alpha) )
			dxDrawText( current.message, X + 95 * scaleX, 70 * scaleX + (90 * scaleX)*i + 10 * scaleX, 0, 85 * scaleX + (90 * scaleX)*i + 85 * scaleX, tocolor(211, 211, 211, alpha), 1.0, notify.font, "left", "center", false, false, false, true )
		end
	end
end

function notify.noLimitRender()
	local current = notify.noLimit[1]

	local alpha
	if current then
		if current.state == 0 then
			if not current.startTick then
				current.startTick = getTickCount()
			end

			local progress = (getTickCount() - current.startTick) / 500
			alpha = interpolateBetween( 0, 0, 0,
																	255, 0, 0,
																	progress, "Linear" )
		
			if progress > 1 then
				current.startTick = getTickCount()
				current.state = 1
			end
		elseif current.state == 1 then
			alpha = 255

			if getTickCount() - current.startTick >= current.time then
				current.startTick = getTickCount()
				current.state = 2
			end
		elseif current.state == 2 then
			local progress = (getTickCount() - current.startTick) / 500
			alpha = interpolateBetween( 255, 0, 0,
																	0, 0, 0,
																	progress, "Linear" )

			if progress > 1 then
				table.remove(notify.noLimit, 1)

				if #notify.noLimit == 0 then
					removeEventHandler( "onClientRender", root, notify.noLimitRender)
				end
			end
		end

		local Y = getElementData(localPlayer, "radar:gtaV") and screenY - 340 * scaleX or screenY - 250
		dxDrawRectangle( 28 * scaleX, Y - current.height, 421.7 * scaleX, current.height + 10 * scaleY, tocolor(0, 0, 0, 180, alpha) )
		dxDrawText( current.message, 35 * scaleX, Y - current.height + 5 * scaleY, 0, Y + 5 * scaleY, tocolor(211, 211, 211, alpha), 1.0, notify.font, "left", "center", false, false, false, true )
	end
end

