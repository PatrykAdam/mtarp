--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local penalty = {}
penalty.W, penalty.H = 499 * scaleX, 187 * scaleY
penalty.showed = false

function penalty.onRender()
	if penalty.show then
		local X
		if penalty.state == 'start' then
			local progress = (getTickCount() - penalty.lastTick) / 500
			X = interpolateBetween( -penalty.W, 0, 0, 0, 0, 0, progress, 'Linear' )

			if progress > 8 then
				penalty.lastTick = getTickCount()
				penalty.state = 'end'
			end
		elseif penalty.state == 'end' then
			local progress = (getTickCount() - penalty.lastTick) / 500
			X = interpolateBetween( 0, 0, 0, -penalty.W, 0, 0, progress, 'Linear' )

			if progress > 1 then
				if penalty.next then
					penalty.showed = true
					penalty.lastTick = getTickCount()
					penalty.playerid = penalty.next['playerid']
					penalty.type = penalty.next['type']
					penalty.admin = penalty.next['admin']
					penalty.reason = penalty.next['reason']
					penalty.state = 'start'
					penalty.value = penalty.next['value']
					penalty.next = false
				else
					penalty.showed = false
					removeEventHandler( "onClientRender", root, penalty.onRender )
				end
				return
			end
		end

		local pen
		if penalty.type == 1 then
			pen = string.format('AdminJain (%d min)', penalty.value)
		elseif penalty.type == 2 then
			pen = string.format('GameScore (%d pkt)', penalty.value)
		elseif penalty.type == 3 then
			pen = 'Kick'
		elseif penalty.type == 4 then
			pen = string.format('Ban (%d dni)', penalty.value)
		elseif penalty.type == 5 then
			pen = 'Blokada postaci'
		end

		dxDrawImage( X, screenY/2, penalty.W, penalty.H, "assets/penalty.png" )
		dxDrawText( string.format("Kara: #FFFFFF%s", pen), X + 87 * scaleX, screenY/2 + 31 * scaleY, X + 87 * scaleX, screenY/2 + 31 * scaleY, tocolor(66, 134, 244), 1.0, "default-bold", "left", "top", false, false, false, true)
		dxDrawText( string.format("Nadawca: #FFFFFF%s", penalty.admin), X + 87 * scaleX, screenY/2 + 65 * scaleY, X + 87 * scaleX, screenY/2 + 65 * scaleY, tocolor(66, 134, 244), 1.0, "default-bold", "left", "top", false, false, false, true)
		dxDrawText( string.format("Odbiorca: #FFFFFF%s", penalty.playerid), X + 87 * scaleX, screenY/2 + 100 * scaleY, X + 87 * scaleX, screenY/2 + 100 * scaleY, tocolor(66, 134, 244), 1.0, "default-bold", "left", "top", false, false, false, true)
		dxDrawText( string.format("Powód: #FFFFFF%s", penalty.reason), X + 87 * scaleX, screenY/2 + 135 * scaleY, X + 87 * scaleX, screenY/2 + 135 * scaleY, tocolor(66, 134, 244), 1.0, "default-bold", "left", "top", false, false, false, true)


	end
end

function penalty.show(player, type, admin, reason, value)
	if penalty.showed then
		penalty.next = {playerid = player, type = type, admin = admin, reason = reason,  value = value}
		return
	end

	penalty.showed = true
	penalty.lastTick = getTickCount()
	penalty.playerid = player
	penalty.type = type
	penalty.admin = admin
	penalty.reason = reason
	penalty.state = 'start'
	penalty.value = value
	addEventHandler( "onClientRender", root, penalty.onRender )
end

addEvent('penalty:show', true)
addEventHandler( "penalty:show", root, penalty.show )