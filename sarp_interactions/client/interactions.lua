--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = math.max(0.7, (screenX / 1920)), math.max(0.7, (screenY / 1080))

local interaction = {}

interaction.hexagonW, interaction.hexagonH = 150 * scaleX, 171 * scaleX
interaction.hexagonX, interaction.hexagonY = (screenX - interaction.hexagonW)/2, (screenY - interaction.hexagonH)/2
interaction.font = dxCreateFont( "assets/Lato-Regular.ttf", 14 * scaleX )
interaction.list = {}
interaction.select = 1
interaction.element = false
interaction.inVehicle = false
interaction.type = false
interaction.maxDistance = 7.0

interaction.icons = {
	{W = 9, H = 11},
	{W = 91 * scaleX, H = 91 * scaleX},
	{W = 96 * scaleX, H = 96 * scaleX},
	{W = 130 * scaleX, H = 75 * scaleX},
	{W = 86 * scaleX, H = 86 * scaleX},
	{W = 76 * scaleX, H = 76 * scaleX},
	{W = 79 * scaleX, H = 71 * scaleX},
	{W = 91 * scaleX, H = 81 * scaleX},
	{W = 89 * scaleX, H = 89 * scaleX},
	{W = 62 * scaleX, H = 85 * scaleX},
	{W = 71 * scaleX, H = 71 * scaleX},
	{W = 89 * scaleX, H = 71 * scaleX},
}

interaction.position = {
	{interaction.hexagonX - 73 * scaleX, interaction.hexagonY - 126 * scaleX},
	{interaction.hexagonX + 73 * scaleX, interaction.hexagonY - 126 * scaleX},
	{interaction.hexagonX + interaction.hexagonW - 5 * scaleX, interaction.hexagonY},
	{interaction.hexagonX + 73 * scaleX, interaction.hexagonY + interaction.hexagonH - 45 * scaleX},
	{interaction.hexagonX - 73 * scaleX, interaction.hexagonY + interaction.hexagonH - 45 * scaleX},
	{interaction.hexagonX - interaction.hexagonW + 5 * scaleX, interaction.hexagonY},
}


function interaction.onRender()
	if not (getKeyState( "lshift" ) and getKeyState( "rshift" )) and getKeyState( "1" ) and not isChatBoxInputActive() and not isMainMenuActive() and not isCursorShowing() then
		dxDrawImage( (screenX - interaction.icons[1].W)/2, 380 * scaleY, interaction.icons[1].W, interaction.icons[1].H, "assets/celownik.png" )
	elseif interaction.searchElement then
		local mX, mY, mZ = getCameraMatrix()
		local wX, wY, wZ = getWorldFromScreenPosition( (screenX - interaction.icons[1].W)/2, 380 * scaleY, interaction.maxDistance )

		local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(mX, mY, mZ, wX, wY, wZ, false, true, true, true, false, false, false)

		if hitElement and hitElement ~= localPlayer then
			interaction.element = hitElement
			interaction.inVehicle = false
			toggleControl ( "fire", false )
			toggleControl ( "next_weapon", false )
			toggleControl ( "previous_weapon", false )

			interaction.list = {}
			if getElementType( interaction.element ) == 'vehicle' then
				interaction.type = {icon = 3, src = "assets/aktywne/active_pojazdopcje.png", text = 'Pojazd'}
				table.insert(interaction.list, {active = "assets/aktywne/active_carlock.png", inactive = "assets/nieaktywne/inactive_carlock.png", type = 2, icon = 3})
				
				local vehicleType = getVehicleType( interaction.element )

				if vehicleType == 'Automobile' then
					table.insert(interaction.list, {active = "assets/aktywne/active_carmask.png", inactive = "assets/nieaktywne/inactive_carmask.png", type = 1, icon = 4})
					table.insert(interaction.list, {active = "assets/aktywne/active_cartrunk.png", inactive = "assets/nieaktywne/inactive_cartrunk.png", type = 5, icon = 4})
				end

				if isDutyInGroupType({2}) then
					if getVehicleDoorOpenRatio( interaction.element, 1 ) == 1 and getElementData(interaction.element, "vehicle:ownerType") == 2 and getElementData(interaction.element, "vehicle:ownerID") == getElementData(localPlayer, "player:duty") then
						table.insert(interaction.list, {active = "assets/aktywne/active_barrier.png", inactive = "assets/nieaktywne/inactive_barrier.png", type = 20, icon = 12})					
						table.insert(interaction.list, {active = "assets/aktywne/active_trafficbarrier.png", inactive = "assets/nieaktywne/inactive_trafficbarrier.png", type = 21, icon = 9})					
					end
				end
			elseif getElementType( interaction.element ) == 'object' and tonumber(getElementModel( interaction.element )) == 2942 then
				interaction.type = {icon = 10, src = "assets/aktywne/active_atm.png", text = 'Bankomat'}
				table.insert(interaction.list, {active = "assets/aktywne/active_atm.png", inactive = "assets/nieaktywne/inactive_atm.png", type = 11, icon = 10})
				table.insert(interaction.list, {active = "assets/aktywne/active_cashin.png", inactive = "assets/nieaktywne/inactive_cashin.png", type = 12, icon = 6})
				table.insert(interaction.list, {active = "assets/aktywne/active_cashout.png", inactive = "assets/nieaktywne/inactive_cashout.png", type = 13, icon = 6})
			elseif getElementType( interaction.element) == 'player' then
				interaction.type = {icon = 3, src = "assets/aktywne/active_postacopcje.png", text = 'Gracz'}
				table.insert(interaction.list, {active = "assets/aktywne/active_hey.png", inactive = "assets/nieaktywne/inactive_hey.png", type = 18, icon = 4})
				table.insert(interaction.list, {active = "assets/aktywne/active_givecash.png", inactive = "assets/nieaktywne/inactive_givecash.png", type = 7, icon = 3})
				table.insert(interaction.list, {active = "assets/aktywne/active_vcard.png", inactive = "assets/nieaktywne/inactive_vcard.png", type = 8, icon = 4})
			
			 	if isDutyInGroupType({2}) then
					table.insert(interaction.list, {active = "assets/aktywne/active_cuff.png", inactive = "assets/nieaktywne/inactive_cuff.png", type = 9, icon = 7})
					table.insert(interaction.list, {active = "assets/aktywne/active_search.png", inactive = "assets/nieaktywne/inactive_search.png", type = 10, icon = 2})
				end
			end
		elseif not hit then
			for i, v in ipairs( getElementsByType( "marker", root, true )) do
				local X, Y, Z = getElementPosition( v )
				local pX, pY, pZ = getElementPosition( localPlayer )
				if getDistanceBetweenPoints3D( X, Y, Z, pX, pY, pZ ) < 1.0 and getElementData(v, "type:doors") then
					interaction.element = v
					interaction.inVehicle = false
					toggleControl ( "fire", false )
					toggleControl ( "next_weapon", false )
					toggleControl ( "previous_weapon", false )
					interaction.list = {}
					interaction.type = {icon = 11, src = "assets/aktywne/active_drzwiopcje.png", text = 'Drzwi'}
					table.insert(interaction.list, {active = "assets/aktywne/active_drzwiopcje.png", inactive = "assets/nieaktywne/inactive_opendoor.png", type = 15, icon = 11})
					table.insert(interaction.list, {active = "assets/aktywne/active_knockdoor.png", inactive = "assets/nieaktywne/inactive_knockdoor.png", type = 16, icon = 2})				

					if isDutyInGroupType({2}) then
						table.insert(interaction.list, {active = "assets/aktywne/active_kickdoor.png", inactive = "assets/nieaktywne/inactive_kickdoor.png", type = 17, icon = 2})
					end
					break
				end
			end
		end

		interaction.lastTick = getTickCount()
		interaction.searchElement = false
	elseif isElement(interaction.element) then
		if interaction.type then
			if not getPedOccupiedVehicle( localPlayer ) and interaction.inVehicle then return interaction.hide() end
			--rodzaj interakcji
			local progress = (getTickCount() - interaction.lastTick) / 300
			local alpha = interpolateBetween( 50, 0, 0,
																			  255, 0, 0,
																			  progress, "Linear")
			local id = interaction.type['icon']
			dxDrawImage( interaction.hexagonX, interaction.hexagonY, interaction.hexagonW, interaction.hexagonH, "assets/active_hex.png", 0, 0, 0, tocolor(255, 255, 255, alpha == 255 and 255 or 0) )
			dxDrawImage( interaction.hexagonX + (interaction.hexagonW - interaction.icons[id].W)/2, interaction.hexagonY + (105 * scaleX - interaction.icons[id].H), interaction.icons[id].W, interaction.icons[id].H, interaction.type['src'], 0, 0, 0, tocolor(255, 255, 255, alpha == 255 and 255 or 0 ))
			dxDrawText( interaction.type['text'], interaction.hexagonX, interaction.hexagonY + 105 * scaleX, interaction.hexagonX + interaction.hexagonW, 0, tocolor( 62, 62, 62, alpha == 255 and 255 or 0), 1.0, interaction.font, "center", "top", false, true )

			for i, v in ipairs(interaction.list) do
				local posX, posY = interpolateBetween( interaction.hexagonX, interaction.hexagonY, 0,
																							 interaction.position[i][1], interaction.position[i][2], 0,
																							 progress, "Linear")

				dxDrawImage( posX, posY, interaction.hexagonW, interaction.hexagonH, interaction.select == i and "assets/active_hex.png" or "assets/inactive_hex.png", 0, 0, 0, tocolor( 255, 255, 255, alpha ) )
				dxDrawImage( posX + (interaction.hexagonW - interaction.icons[v.icon].W)/2, posY + (105 * scaleX - interaction.icons[v.icon].H), interaction.icons[v.icon].W, interaction.icons[v.icon].H, interaction.select == i and v.active or v.inactive, 0, 0, 0, tocolor(255, 255, 255, alpha))
				dxDrawText( interaction.messageType(interaction.element, v.type), posX + 5 * scaleX, posY + 105 * scaleX, posX + interaction.hexagonW - 5 * scaleX, 0, interaction.select == i and tocolor(62, 62, 62, alpha) or tocolor( 140, 103, 35, alpha), 1.0, interaction.font, "center", "top", false, true )	
			end
		else
			interaction.hide()
		end
	end
end

addEventHandler( "onClientRender", root, interaction.onRender )

function interaction.messageType(element, type)
	if type == 1 then
		if getVehicleDoorOpenRatio( element, 0 ) == 1 then
			return "Zamknij maske"
		else
			return "Otwórz maske"
		end
	elseif type == 2 then
		if isVehicleLocked( element ) then
			return "Otwórz pojazd"
		else
			return "Zamknij pojazd"
		end
	elseif type == 3 then
		if getVehicleEngineState( element ) then
			return "Zgaś silnik"
		else
			return "Odpal silnik"
		end
	elseif type == 4 then
		if getVehicleOverrideLights( element ) ~= 2 then
			return "Włącz światła"
		else
			return "Wyłącz światła"
		end
	elseif type == 5 then
		if getVehicleDoorOpenRatio( element, 1 ) ~= 1 then
			return "Otwórz bagażnik"
		else
			return "Zamknij bagażnik"
		end
	elseif type == 6 then
		if getElementData( element, "vehicle:window") then
			return "Zamknij szyby"
		else
			return "Otwórz szyby"
		end
	elseif type == 7 then
		return "Przekaż gotówke"
	elseif type == 8 then
		return "Wyślij v-card"
	elseif type == 9 then
		return "Skuj"
	elseif type == 10 then
		return "Przeszukaj"
	elseif type == 11 then
		return "Stan konta"
	elseif type == 12 then
		return "Wpłać gotówke"
	elseif type == 13 then
		return "Wypłać gotówke"
	elseif type == 14 then
		return "Przeszukaj pojazd"
	elseif type == 15 then
		if getElementData(element, "doors:lock") == 1 then
			return "Otwórz drzwi"
		else
			return "Zamknij drzwi"
		end
	elseif type == 16 then
		return "Zapukaj"
	elseif type == 17 then
		return "Wyważ drzwi"
	elseif type == 18 then
		return "Przywitaj się"
	elseif type == 19 then
		if getElementData(element, "vehicle:manual") then
			return "Odciągnij hamulec"
		else
			return "Zaciągnij hamulec"
		end
	elseif type == 20 then
		return "Wyjmij bariere"
	elseif type == 21 then
		return "Wyjmij stożek ruchu"
	else
		return "--"
	end
end

function interaction.triggerEvent()
	if not isElement(interaction.element) then return end
	local getType = interaction.list[interaction.select].type

	local X, Y, Z = getElementPosition( localPlayer )
	local iX, iY, iZ = getElementPosition( interaction.element )
	if getDistanceBetweenPoints3D( X, Y, Z, iX, iY, iZ ) > interaction.maxDistance then
		exports.sarp_notify:addNotify("Oddaliłeś się zbyt daleko.")
		interaction.hide()
		return
	end


	triggerServerEvent( "interactionEvent", localPlayer, getElementType(interaction.element) == 'object' and 0 or interaction.element, getType )
	interaction.hide()
end

function interaction.onKey(button, press)
	if press then
		if interaction.element and button == 'mouse_wheel_up' then
			interaction.select = interaction.select - 1

			if interaction.select == 0 then
				interaction.select = #interaction.list
			end
		end
		if interaction.element and button == 'mouse_wheel_down' then
			interaction.select = interaction.select + 1

			if interaction.select == #interaction.list + 1 then
				interaction.select = 1
			end
		end
		if interaction.element and button == 'mouse1' then
			cancelEvent()
			interaction.triggerEvent()
		end
		if not (getKeyState( "lshift" ) and getKeyState( "rshift" )) and button == '1' and not isChatBoxInputActive() and not isMainMenuActive() and not isCursorShowing() then
			if not interaction.element then
				interaction.searchElement = true
				interaction.element = false
				interaction.select = 1

				local vehicle = getPedOccupiedVehicle( localPlayer )

				if vehicle and getVehicleOccupant( vehicle ) == localPlayer then
					interaction.searchElement = false
					interaction.inVehicle = true
					interaction.element = vehicle
					interaction.list = {}
					interaction.type = {icon = 3, src = "assets/aktywne/active_pojazdopcje.png", text = 'Pojazd'}
					table.insert(interaction.list, {active = "assets/aktywne/active_carlock.png", inactive = "assets/nieaktywne/inactive_carlock.png", type = 2, icon = 3})
					table.insert(interaction.list, {active = "assets/aktywne/active_engine.png", inactive = "assets/nieaktywne/inactive_engine.png", type = 3, icon = 4})
					table.insert(interaction.list, {active = "assets/aktywne/active_handbrake.png", inactive = "assets/nieaktywne/inactive_handbrake.png", type = 19, icon = 8})
					table.insert(interaction.list, {active = "assets/aktywne/active_lights.png", inactive = "assets/nieaktywne/inactive_lights.png", type = 4, icon = 4})
					for i, v in ipairs({'Automobile', 'Monster Truck'}) do
						if getVehicleType( interaction.element ) == v then
							table.insert(interaction.list, {active = "assets/aktywne/active_windows.png", inactive = "assets/nieaktywne/inactive_windows.png", type = 6, icon = 4})
							break
						end
					end
					if isDutyInGroupType({2}) then
						table.insert(interaction.list, {active = "assets/aktywne/active_search.png", inactive = "assets/nieaktywne/inactive_search.png", type = 14, icon = 2})
					end

					interaction.lastTick = getTickCount()
				end
			else
				interaction.hide()
			end
		end
	end
end

addEventHandler( "onClientKey", root, interaction.onKey )

function interaction.hide()
	interaction.element = false
	interaction.type = false
	toggleControl ( "fire", true )
	toggleControl ( "next_weapon", true )
	toggleControl ( "previous_weapon", true )
end

function isDutyInGroupType(groupType)
	local duty = getElementData(localPlayer, "player:duty")
	if not duty then return false end

	if type(groupType) == 'table' then
		for i, v in ipairs(groupType) do
			if getElementData(localPlayer, "group:type") == v then
				return true
			end
		end
	else
		if getElementData(localPlayer, "group:type") == groupType then
			return true
		end
	end
	return false
end