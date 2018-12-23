--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)

local dashboard = {}

function dashboard.bind()
	if dashboard.lastTick + dashboard.animTime > getTickCount() then return end

	dashboard.lastTick = getTickCount()
	if dashboard.active then
		dashboard.active = false
		toggleControl( "change_camera", true )
		removeEventHandler( "onClientClick", root, dashboard.click )
	else
		toggleControl( "change_camera", false )
		triggerServerEvent( "dashboard:getInfo", localPlayer )
	end
end

function dashboard.open(data)
	--pobieranie avatarów


	exports.sarp_blur:setBlurStatus(true)
	dashboard.info = data
	dashboard.pressTAB = 1
	dashboard.info['doors'] = {}

	for i, v in ipairs(getElementsByType( "marker" )) do
		if getElementData( v, "type:doors") and not getElementData( v, "doors:exit") and getElementData( v, "doors:ownerType") == 1 and getElementData( v, "doors:ownerID") == getElementData( localPlayer, "player:id") then
			table.insert(dashboard.info['doors'], {id = getElementData( v, "doors:id"), name = getElementData( v, "doors:name")})
		end
	end
	addEventHandler( "onClientRender", root, dashboard.show)
	addEventHandler( "onClientClick", root, dashboard.click )
	dashboard.active = true
	showChat( false )
	showCursor( true )
end

addEvent('dashboard:open', true)
addEventHandler( "dashboard:open", localPlayer, dashboard.open )

function dashboard.avatar(avatar)
	if avatar.image then
		dashboard.info['follow'][avatar.index].avatar = dxCreateTexture( avatar.image )
	end
end

addEvent('dashboard:avatar', true)
addEventHandler( 'dashboard:avatar', localPlayer, dashboard.avatar )

function dashboard.graphicSettings(name)
	if name == "HDR" then
		triggerEvent( "switchContrast", resourceRoot, dashboard.Settings["HDR"] )
	elseif name == "GTAVRADAR" then
		triggerServerEvent( "setGraphicOption", localPlayer, 1, dashboard.Settings["GTAVRADAR"] )
		triggerEvent( 'showRadar', resourceRoot, dashboard.Settings["GTAVRADAR"] )
		setPlayerHudComponentVisible( "radar", not dashboard.Settings["GTAVRADAR"] )
	elseif name == "KAROSERIA" then
		triggerEvent( "switchCarPaintReflect", resourceRoot, dashboard.Settings["KAROSERIA"] )
	elseif name == "WATER" then
		triggerEvent( "switchWaterRef", resourceRoot, dashboard.Settings["WATER"])
	elseif name == "TEXTURE" then
		triggerEvent( "onClientSwitchDetail", resourceRoot, dashboard.Settings["TEXTURE"] )
	elseif name == "CHATOOC" then
		triggerServerEvent( "setGraphicOption", localPlayer, 2, dashboard.Settings["CHATOOC"] )
		triggerEvent( "showChatOOC", localPlayer, dashboard.Settings["CHATOOC"], not dashboard.Settings["CHATOOC"] )
	elseif name == "blockPW" then
		triggerServerEvent( "setGraphicOption", localPlayer, 3, dashboard.Settings["blockPW"] )
	elseif name == "NIGHT" then
		triggerEvent( "switchNightShader", resourceRoot, dashboard.Settings["NIGHT"])
	end
end

function dashboard.spawn()
	triggerServerEvent( 'playerSpawn', localPlayer, localPlayer )
end

function dashboard.start()
	dashboard.Settings = {["HDR"] = false,
												["GTAVRADAR"] = false,
												["KAROSERIA"] = false,
												["WATER"] = false,
												["TEXTURE"] = false,
												["CHATOOC"] = true,
												["blockPW"] = false,
												["NIGHT"] = false}

	dashboard.active = false
	dashboard.icons = {[1] = {'assets/dashboardHD_ikonka_domek.png', 80 * scaleX, 80 * scaleX, 'DASHBOARD'},
										 [2] = {'assets/dashboardHD_ikonka_osiagniecia.png', 85 * scaleX, 85 * scaleX, 'OSIĄGNIĘCIA'},
										 [3] = {'assets/dashboardHD_ikonka_ustawienia.png', 75 * scaleX, 75 * scaleX, 'USTAWIENIA'},
										 [4] = {'assets/dashboardHD_ikonka_znajomi.png', 75 * scaleX, 75 * scaleX, 'ZNAJOMI'}}

	dashboard.W, dashboard.H = 1262 * scaleX, 665 * scaleY
	dashboard.animTime = 500
	dashboard.lastTick = 0
	dashboard.checkboxW, dashboard.checkboxH = 65 * scaleX, 35 * scaleY
	dashboard.font = {}
	dashboard.font[1] = dxCreateFont( "assets/Lato-Regular.ttf", 18 * scaleX)
	dashboard.font[2] = dxCreateFont( "assets/Lato-Regular.ttf", 11 * scaleX)
	dashboard.font[3] = dxCreateFont( "assets/Lato-Regular.ttf", 15 * scaleX)
	dashboard.buttonW, dashboard.buttonH = 310 * scaleX, 142 * scaleY
	dashboard.X, dashboard.Y = (screenX - dashboard.W)/2, (screenY - dashboard.H - dashboard.buttonH)/2
	dashboard.buttonX, dashboard.buttonY = dashboard.X + 11 * scaleX, dashboard.Y + dashboard.H - 17.5 * scaleY
	dashboard.arrowW, dashboard.arrowH = 26 * scaleX, 36 * scaleY
	dashboard.arrow = {{X = dashboard.X + (dashboard.W - dashboard.arrowW)/2 - 30 * scaleX, Y = dashboard.Y + dashboard.H - 96 * scaleY},
										 {X = dashboard.X + (dashboard.W - dashboard.arrowW)/2 + 30 * scaleX, Y = dashboard.Y + dashboard.H - 96 * scaleY}}
	dashboard.pressTAB = 1
	dashboard.maxPage = 1
	dashboard.friendpage = 0
	dashboard.page = 0
	--																																																	napis, przycisk, przypisane ustawienie
	dashboard.effects = {[1] = {"BINDY", dashboard.X + (10 + 155) * scaleX, dashboard.Y + 200 * scaleY, showBindWindow, false},
											 [2] = {"HDR", dashboard.X + (10 + 472) * scaleX, dashboard.Y + 200 * scaleY, false, true, "HDR"},
											 [3] = {"RADAR Z GTA V", dashboard.X + (10 + 790) * scaleX, dashboard.Y + 200 * scaleY, false, true, "GTAVRADAR"},
											 [4] = {"LEPSZA KAROSERIA", dashboard.X + (10 + 155) * scaleX, dashboard.Y + 380 * scaleY, false, true, "KAROSERIA"},
											 [5] = {"TEKSTURA WODY", dashboard.X + (10 + 472) * scaleX, dashboard.Y + 380 * scaleY, false, true, "WATER"},
											 [6] = {"LEPSZA TEKSTURA", dashboard.X + (10 + 790) * scaleX, dashboard.Y + 380 * scaleY, false, true, "TEXTURE"},
											 [7] = {"CHAT OOC", dashboard.X + (10 + 155) * scaleX, dashboard.Y + 200 * scaleY, false, true, "CHATOOC"},
											 [8] = {"BLOKADA PW", dashboard.X + (10 + 472) * scaleX, dashboard.Y + 200 * scaleY, false, true, "blockPW"},
											 [9] = {"Miejsce spawnu", dashboard.X + (10 + 790) * scaleX, dashboard.Y + 200 * scaleY, dashboard.spawn, false},
											 [10] = {"Ciemniejsza noc", dashboard.X + (10 + 155) * scaleX, dashboard.Y + 380 * scaleY, false, true, "NIGHT"},}

	bindKey("home", "down", dashboard.bind)

	dashboard.loadSettings()
end

addEventHandler( "onClientResourceStart", resourceRoot, dashboard.start )

function dashboard.stop()
	unbindKey( "home", "down", dashboard.bind )
end

addEventHandler( "onClientResourceStop", resourceRoot, dashboard.stop )

function dashboard.show()
	local data = dashboard.info
	local groupCount = 0
	local progress = (getTickCount() - dashboard.lastTick) / dashboard.animTime

		alpha = interpolateBetween( dashboard.active == false and 255 or 0, 0, 0,
		                        dashboard.active == false and 0 or 255, 0, 0,
		                        progress, "Linear" )


	dxDrawImage( dashboard.X, dashboard.Y, dashboard.W, dashboard.H, "assets/dashboardHD_tlo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawImage( dashboard.X + 20 * scaleX, dashboard.Y + 10 * scaleY, 80 * scaleX, 50 * scaleY, "assets/dashboardHD_ikonka_dashboardgorai.png", 0, 0, 0, tocolor(255, 255, 255, alpha) )
	dxDrawText( "DASHBOARD", dashboard.X + 110 * scaleX, dashboard.Y + 10 * scaleY, 0, dashboard.Y + 60 * scaleY, tocolor(255, 255, 255, alpha), 1.0, dashboard.font[1], "left", "center" )
	
	for i = 0, 3 do
		local id = i + 1
		if dashboard.pressTAB ~= id then
			dxDrawRectangle( dashboard.buttonX + (dashboard.buttonW * i), dashboard.buttonY, dashboard.buttonW, dashboard.buttonH, tocolor(0, 0, 0, alpha * 0.8) )
		else
			dxDrawRectangle( dashboard.buttonX + (dashboard.buttonW * i), dashboard.buttonY, dashboard.buttonW, dashboard.buttonH, tocolor(218, 156, 6, alpha) )
		end

		dxDrawImage( dashboard.buttonX + (dashboard.buttonW * i) + (dashboard.buttonW - dashboard.icons[id][2])/2, dashboard.buttonY + (dashboard.buttonH/1.4 - dashboard.icons[id][3])/2, dashboard.icons[id][2], dashboard.icons[id][3], dashboard.icons[id][1], 0, 0, 0, tocolor(255, 255, 255, alpha) )
		dxDrawText( dashboard.icons[id][4], dashboard.buttonX + (dashboard.buttonW * i), dashboard.buttonY + 105 * scaleY, dashboard.buttonX + (dashboard.buttonW * id), dashboard.buttonY + 115 * scaleY, tocolor(255, 255, 255, alpha), 1.0, dashboard.font[1], "center", "center" )

		if i ~= 0 then
			dxDrawRectangle( dashboard.buttonX + (dashboard.buttonW * i), dashboard.buttonY, 1, 142 * scaleY, tocolor(220, 220, 220, alpha))
		end
	end

	if progress >= 1 and dashboard.active == false then
		removeEventHandler( "onClientRender", root, dashboard.show )
		exports.sarp_blur:setBlurStatus(false)
		showChat( true )
		showCursor( false )
	end

	if dashboard.pressTAB == 1 then
		dxDrawText( string.format("#c8c8c8Witaj, #FFFFFF%s!", getElementData(localPlayer, "global:name")), dashboard.X + (10 + 125) * scaleX, dashboard.Y + 180 * scaleY, 0, 0, tocolor(255, 255, 255, alpha), 1.0, dashboard.font[1], "left", "top", false, false, false, true )
		dxDrawText( "Aktualnie znajdujesz sie w dashboardzie. Znajdziesz tutaj podstawowe informacje o swojej postaci, jej przedmiotach i grupach. Zarzadzac rowniez mozesz znajomymi oraz zmieniac ustawienia gry.", dashboard.X + (10 + 125) * scaleX, dashboard.Y + 220 * scaleY, dashboard.X + 550 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
	end

	if dashboard.pressTAB == 1 then		
		dxDrawRectangle( dashboard.X + (10 + 125) * scaleX, dashboard.Y + (360 + 1) * scaleY, 1000 * scaleX, 2 * scaleY, tocolor( 117, 106, 92, alpha ) )

		dxDrawRectangle( dashboard.X + 602 * scaleX - 2, dashboard.Y + 182 * scaleY - 2, 104 * scaleX + 4, 104 * scaleX + 4, tocolor( 245, 192, 6, alpha ) )
		dxDrawImage( dashboard.X + 602 * scaleX, dashboard.Y + 182 * scaleY, 104 * scaleX, 104 * scaleX, "assets/"..getElementData(localPlayer, "player:skin")..".png", 0, 0, 0, tocolor( 255, 255, 255, alpha ) )

		dxDrawText( string.format("%s (UID: %d) %dh %dmin", getElementData(localPlayer, "player:username"), getElementData(localPlayer, "player:id"), getElementData(localPlayer, "player:hours"), getElementData(localPlayer, "player:minutes")), dashboard.X + 725 * scaleX, dashboard.Y + 175 * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[3], "left", "top", false, false, false, true )
		dxDrawText( string.format("#c8c8c8Wiek: #FFFFFF%d lat\n#c8c8c8Skin: #FFFFFF%d\n#c8c8c8Płeć: #FFFFFF%s\n#c8c8c8Stan zdrowia: #FFFFFF%dhp\n#c8c8c8Siła: #FFFFFF%dj", getElementData(localPlayer, "player:age"), getElementData(localPlayer, "player:skin"), getElementData(localPlayer, "player:sex") and "Kobieta" or "Mężczyzna", getElementHealth( localPlayer ), getElementData(localPlayer, "player:strength")), dashboard.X + 725 * scaleX, dashboard.Y + (175 + 30) * scaleY, 0, 0, tocolor(255, 255, 255, alpha), 1, dashboard.font[2], "left", "top", false, true, false, true )
		dxDrawText( string.format("#c8c8c8Gotówka: #FFFFFF$%d\n#c8c8c8W banku: #FFFFFF$%d\n#c8c8c8Premium: #FFFFFF%s\n#c8c8c8GameScore: #FFFFFF%d", getElementData(localPlayer, "player:money"), getElementData(localPlayer, "player:bank"), getElementData(localPlayer, "global:premium") > getRealTime().timestamp and "Aktywne" or "Brak", getElementData(localPlayer, "global:score")), dashboard.X + 955 * scaleX, dashboard.Y + (175 + 30) * scaleY, 0, 0, tocolor(255, 255, 255, alpha), 1, dashboard.font[2], "left", "top", false, true, false, true )


		dxDrawText( "GRUPY", dashboard.X + (10 + 125) * scaleX, dashboard.Y + 390 * scaleY, 0, 0, tocolor( 255, 255, 255, alpha), 1.0, dashboard.font[3], "left", "top", false, false, false, true )
		dxDrawText( "UID", dashboard.X + (10 + 125) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		dxDrawText( "NAZWA", dashboard.X + (10 + 205) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		for i = 1, 3 do
			local id = getElementData(localPlayer, "group_"..i..":id")
			if id then
				dxDrawText( id, dashboard.X + (10 + 125) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1.0, dashboard.font[2], "left", "top", false, false, false, true )
				dxDrawText( getElementData(localPlayer, "group_"..i..":name"), dashboard.X + (10 + 205) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1.0, dashboard.font[2], "left", "top", false, false, false, true )				groupCount = groupCount + 1
			end
		end

		dxDrawText( "POJAZDY", dashboard.X + (10 + 550) * scaleX, dashboard.Y + 390 * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[3], "left", "top", false, false, false, true )
		dxDrawText( "UID", dashboard.X + (10 + 550) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		dxDrawText( "NAZWA", dashboard.X + (10 + 630) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		dxDrawText( "HP", dashboard.X + (10 + 750) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )

		for i, v in pairs(data.vehicles) do
			dxDrawText( v.id, dashboard.X + (10 + 550) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1.0, dashboard.font[2], "left", "top", false, false, false, true )
			dxDrawText( getVehicleNameFromModel( v.model ), dashboard.X + (10 + 630) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1.0, dashboard.font[2], "left", "top", false, false, false, true )
			dxDrawText( v.hp.."HP", dashboard.X + (10 + 750) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1.0, dashboard.font[2], "left", "top", false, false, false, true )
		end

		dxDrawText( "BUDYNKI", dashboard.X + (10 + 860) * scaleX, dashboard.Y + 390 * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[3], "left", "top", false, false, false, true )
		dxDrawText( "UID", dashboard.X + (10 + 860) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		dxDrawText( "NAZWA", dashboard.X + (10 + 940) * scaleX, dashboard.Y + (390 + 30) * scaleY, 0, 0, tocolor( 255, 255, 255, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )

		for i, v in ipairs(data.doors) do
			dxDrawText( v.id, dashboard.X + (10 + 860) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
			dxDrawText( v.name, dashboard.X + (10 + 940) * scaleX, dashboard.Y + (410 + 10) * scaleY + (25 * scaleY) * i, 0, 0, tocolor( 200, 200, 200, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		end

		if groupCount == 0 then
			dxDrawText( "Nie należysz do żadnej grupy.", dashboard.X + (10 + 125) * scaleX, dashboard.Y + (435 + 10) * scaleY, 0, 0, tocolor( 200, 200, 200, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		end

		if #data.vehicles == 0 then
			dxDrawText( "Nie posiadasz żadnego pojazdu.", dashboard.X + (10 + 550) * scaleX, dashboard.Y + (435 + 10) * scaleY, 0, 0, tocolor( 200, 200, 200, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		end

		if #data.doors == 0 then
			dxDrawText( "Nie posiadasz żadnego budynku.", dashboard.X + (10 + 860) * scaleX, dashboard.Y + (435 + 10) * scaleY, 0, 0, tocolor( 200, 200, 200, alpha ), 1, dashboard.font[2], "left", "top", false, false, false, true )
		end

	end

	if dashboard.pressTAB == 4 then
		dxDrawText( "Obserwowane osoby", dashboard.X + (10 + 125) * scaleX, dashboard.Y + 250 * scaleY, 0, 0, tocolor(255, 255, 255, alpha), 1.0, dashboard.font[1], "left", "top", false, false, false, true )
		dxDrawText( "W tej zakładce możesz sprawdzić kto z obserwowanych przez forum osób jest aktualnie w grze.", dashboard.X + (10 + 125) * scaleX, dashboard.Y + 290 * scaleY, dashboard.X + 550 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
		for i = 1 + dashboard.friendpage, 4 + dashboard.friendpage do
			local id = i - dashboard.friendpage
			if dashboard['info'].follow[i] then
				if dashboard['info'].follow[i].online then
					dxDrawRectangle( dashboard.X + (546 + (106 * id)) * scaleX - 2, dashboard.Y + (200 + 30) * scaleY - 2, 86 * scaleX + 4, 86 * scaleX + 4, tocolor(0, 209, 10, alpha) )
				end

				if dashboard['info'].follow[i].avatar then
					dxDrawImage( dashboard.X + (546 + (106 * id)) * scaleX, dashboard.Y + (200 + 30) * scaleY, 86 * scaleX, 86 * scaleX, dashboard['info'].follow[i].avatar, 0, 0, 0, tocolor(255, 255, 255, alpha))
				else
					dxDrawImage( dashboard.X + (546 + (106 * id)) * scaleX, dashboard.Y + (200 + 30) * scaleY, 86 * scaleX, 86 * scaleX, "assets/Loading_icon.png", 0, 0, 0, tocolor(255, 255, 255, alpha) )
				end
			end
		end

		dxDrawRectangle( dashboard.X + 650 * scaleX, dashboard.Y + 400 * scaleY, 424 * scaleX, 1, tocolor( 205, 205, 205, alpha ) )
		dxDrawImage( dashboard.X + 720 * scaleX, dashboard.Y + 410 * scaleY, 26 * scaleX, 36 * scaleX, "assets/dashboardHD_arrow_left.png")
		dxDrawImage( dashboard.X + 978 * scaleX, dashboard.Y + 410 * scaleY, 26 * scaleX, 36 * scaleX, "assets/dashboardHD_arrow_right.png")
	end
	if dashboard.pressTAB == 3 then
		dxDrawImage( dashboard.arrow[1].X, dashboard.arrow[1].Y, dashboard.arrowW, dashboard.arrowH, "assets/dashboardHD_arrow_left.png", 0, 0, 0, tocolor( 255, 255, 255, alpha ) )
		dxDrawImage( dashboard.arrow[2].X, dashboard.arrow[2].Y, dashboard.arrowW, dashboard.arrowH, "assets/dashboardHD_arrow_right.png", 0, 0, 0, tocolor( 255, 255, 255, alpha ) )
		
		for i = 1 + 6 * dashboard.page, 6 * dashboard.page + 6 do
			local v = dashboard.effects[i]
			if v then
				dxDrawText( v[1], v[2], v[3], 0, 0, tocolor( 255, 255, 255, alpha ), 1.0, dashboard.font[1], "left", "top", false, false, false, true )
				
				if v[5] then
					local bW, bH = dxGetTextWidth( v[1], 1.4 * scaleY, dashboard.font[1] ), dxGetFontHeight( 1.0, dashboard.font[1] )
					dxDrawImage( v[2] + ((285 * scaleX)/2 - dashboard.checkboxW/2) , v[3] + 100 * scaleY, dashboard.checkboxW, dashboard.checkboxH, dashboard.Settings[v[6]] and "assets/dashboardHD_button_on.png" or "assets/dashboardHD_button_off.png", 0, 0, 0, tocolor( 255, 255, 255, alpha ))
				end
			end
		end
		if dashboard.page == 0 then
			dxDrawText( "Ustaw pod przycisk dowolny tekst lub komendę i zaoszczędź czas!", dashboard.X + (10 + 155) * scaleX, dashboard.Y + (200 + 30) * scaleY, dashboard.X + 450 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Wchodząc w ciemność automatycznie rozjaśnisz scenę i odwrotnie.", dashboard.X + (10 + 472) * scaleX, dashboard.Y + (200 + 30) * scaleY, dashboard.X + 757 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Radar podobny do tego z GTA V.", dashboard.X + (10 + 790) * scaleX, dashboard.Y + (200 + 30) * scaleY, dashboard.X + 1085 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Rozjaśnienie karoserii, widoczne cienie na pojazdach.", dashboard.X + (10 + 155) * scaleX, dashboard.Y + (380 + 30) * scaleY, dashboard.X + 450 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Zastąpienie standardowej tekstury wody na bardziej realistyczna.", dashboard.X + (10 + 472) * scaleX, dashboard.Y + (380 + 30) * scaleY, dashboard.X + 757 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Podmienienie tekstur niektórych elementów takich jak drogi, schody, ściany na bardziej realistyczne.", dashboard.X + (10 + 790) * scaleX, dashboard.Y + (380 + 30) * scaleY, dashboard.X + 1085 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
		elseif dashboard.page == 1 then
			dxDrawText( "Włącz lub wyłącz czat OOC.", dashboard.X + (10 + 155) * scaleX, dashboard.Y + (200 + 30) * scaleY, dashboard.X + 450 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Włączenie tej opcji uniemożliwi graczom pisanie do Ciebie wiadomości za pomocą /w.", dashboard.X + (10 + 472) * scaleX, dashboard.Y + (200 + 30) * scaleY, dashboard.X + 757 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
			dxDrawText( "Miejsce spawnu postaci.", dashboard.X + (10 + 790) * scaleX, dashboard.Y + (200 + 30) * scaleY, dashboard.X + 1085 * scaleX, 0, tocolor(200, 200, 200, alpha), 1, dashboard.font[2], "left", "top", false, true)
		end
	end

end

function dashboard.click(button, state, X, Y)
	if state == "down" then
		for i = 0, 3 do
			local id = i + 1
			--przewijanie
			if X >= dashboard.buttonX  + (dashboard.buttonW * i) and X <= dashboard.buttonX + (dashboard.buttonW * id) and Y >= dashboard.buttonY and Y <= dashboard.buttonY + dashboard.buttonH then
				dashboard.pressTAB = id
			end
		end

		for i, v in ipairs(dashboard.arrow) do
			if X >= v.X and X <= v.X + dashboard.arrowW and Y >= v.Y and Y <= v.Y + dashboard.arrowH then
				if i == 1 then
					if dashboard.page > 0 then
						dashboard.page = dashboard.page - 1
					end
				else
					if dashboard.page < dashboard.maxPage then
						dashboard.page = dashboard.page + 1
					end
				end
			end
		end

		if X >= dashboard.X + 720 * scaleX and X <= dashboard.X + 746 * scaleX and Y >= dashboard.Y + 410 * scaleY and Y <= dashboard.Y + 410 * scaleY + 36 * scaleX then
			dashboard.friendpage = dashboard.friendpage == 0 and dashboard.friendpage or dashboard.friendpage - 1
		end

		if X >= dashboard.X + 978 * scaleX and X <= dashboard.X + 1004 * scaleX and Y >= dashboard.Y + 410 * scaleY and Y <= dashboard.Y + 410 * scaleY + 36 * scaleX then
			dashboard.friendpage = dashboard.friendpage >= #dashboard['info'].follow - 4 and dashboard.friendpage or dashboard.friendpage + 1
		end


		for i = 1 + 6 * dashboard.page, 6 * dashboard.page + 6 do
			local v = dashboard.effects[i]
			if not v then return end
			local bW, bH = dxGetTextWidth( v[1], 1.0, dashboard.font[1] ), dxGetFontHeight( 1.0, dashboard.font[1] )
			if v[4] and X >= v[2] and X <= v[2] + bW and Y >= v[3] and Y <= v[3] + bH then
				v[4]()
			end

			if v[5] and X >= v[2] + ((285 * scaleX)/2 - dashboard.checkboxW/2) and X <= v[2] + ((285 * scaleX)/2 - dashboard.checkboxW/2) + dashboard.checkboxW and Y >= v[3] + 100 * scaleY and Y <= v[3] + 100 * scaleY + dashboard.checkboxH then
				dashboard.changeSettings(v[6])
			end
		end
	end
end

function dashboard.changeSettings(name)
	dashboard.Settings[name] = not dashboard.Settings[name]
	local file = xmlLoadFile("settings.xml")
	if not  file then
		file = xmlCreateFile("settings.xml","settings")
	end

	local child = xmlFindChild(file,name,0)
	if not child then
		child = xmlCreateChild(file,name)
	end
	xmlNodeSetValue(child,tostring(dashboard.Settings[name]))
	xmlSaveFile(file)
	xmlUnloadFile(file)
	dashboard.graphicSettings(name)
end

function dashboard.loadSettings()
	local file = xmlLoadFile( "settings.xml" )

	if not file then
		file = xmlCreateFile( "settings.xml", "settings" )
	end

	for i, v in pairs(dashboard.Settings) do
		local find = xmlFindChild( file, i, 0 )
		if find then
			if xmlNodeGetValue( find ) == "true" then
				dashboard.Settings[i] = true
			else
			 	dashboard.Settings[i] = false
			end
		end
		dashboard.graphicSettings(i)
	end
	xmlUnloadFile(file)
end