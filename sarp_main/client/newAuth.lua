--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local screenX, screenY = guiGetScreenSize()
local scaleX, scaleY = math.max(0.5, (screenX / 1920)), math.max(0.5, (screenY / 1080))

local auth = {}
auth.passwordKey = 'mtaRPplCODED'

function auth.onStart()

	setCameraMatrix( 1312.7109375, -1711.2041015625, 13.3828125, 1320.7490234375, -1706.4853515625, 14.0 )
	triggerServerEvent( "objects:load", root, localPlayer, 0, 0 )
	setPlayerHudComponentVisible( "all", false )
	fadeCamera( true )
	auth.music = playSound( "assets/music.mp3", true )
	setSoundPosition( auth.music, 16 )
	setSoundVolume( auth.music, 0.5 )
	showChat( false )
	setElementDimension( localPlayer, 1000 )

	auth.state = 1
	auth.lastTick = 0 
	auth.showInput = false
	auth.lastTick = getTickCount()
	auth.sceneElement = {}
	auth.charPed = {}
	auth.charPosition = {1320.7490234375, -1706.4853515625, 13.546875, 180}
	auth.cameraPosition = {1312.7109375, -1711.2041015625, 16}
	auth.lastChar = 1
	auth.chooseChar = 1
	auth.cameraTick = 0

	auth.nameID = 1
	auth.passwordID = 2

	auth.W, auth.H = 681, 312
	auth.X, auth.Y = (screenX - auth.W)/2, (screenY - auth.H)/2

	auth.buttonW, auth.buttonH = 80, 32
	auth.buttonX, auth.buttonY = auth.X + 307, auth.Y + 185

	auth.rememberW, auth.rememberH = 19, 19
	auth.rememberX, auth.rememberY = auth.X + 40, auth.Y + 250
	auth.remember = false

	auth.login = ''
	auth.password = ''
	loadPlayerPassword()

	auth.font = dxCreateFont( "assets/Lato-Regular.ttf", 9 )
	auth.font2 = dxCreateFont( "assets/Varela-Regular.ttf", 18 * scaleX )
	auth.font3 = dxCreateFont( "assets/Varela-Regular.ttf", 12 * scaleX )
	auth.font4 = dxCreateFont( "assets/Varela-Regular.ttf", 15 * scaleX )

	auth.newsW, auth.newsH = 170, 175
	auth.newsX, auth.newsY = auth.X + 460, auth.Y + 90

	auth.editW, auth.editH = 180, 38
	auth.nameX, auth.nameY = auth.X + 195, auth.Y + 90
	auth.passwordX, auth.passwordY = auth.X + 195, auth.Y + 138

	auth.charInfoW, auth.charInfoH = 447, 80
	auth.charInfoX, auth.charInfoY = screenX, screenY

	auth.charBlurW, auth.charBlurH = 319 * scaleX, 216 * scaleX
	auth.charBlurX, auth.charBlurY = 300 * scaleX, (screenY - auth.charBlurH)/2

	auth.charBlurW2, auth.charBlurH2 = 575 * scaleX, 522 * scaleX
	auth.charBlurX2, auth.charBlurY2 = screenX/2 + 100 * scaleX, (screenY - 522 * scaleY)/2 + 100 * scaleX


	addEventHandler( "onClientRender", root, auth.onRender )
end

addEventHandler( "onClientResourceStart", resourceRoot, auth.onStart )

function auth.onRender()
	if auth.state == 1 then
		local progress = (getTickCount() - auth.lastTick) / 3000
		local black = interpolateBetween( 255, 0, 0,
										 0, 0, 0,
										 progress, "Linear" )

		dxDrawImage( 0, 0, screenX, screenY, "assets/Wiki-background.jpg" )

		dxDrawRectangle( 0, 0, screenX, screenY, tocolor( 0, 0, 0, black ) )

		if progress > 1 then
			local alpha = interpolateBetween( 0, 0, 0,
										 255, 0, 0,
										 progress  - 1, "Linear" )
			dxDrawImage( auth.X, auth.Y, auth.W, auth.H, "assets/loginbackgorund.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
			dxDrawImage( auth.buttonX, auth.buttonY, auth.buttonW, auth.buttonH, "assets/button_login.png", 0, 0, 0, tocolor( 255, 255, 255, alpha ))
			dxDrawImage( auth.rememberX, auth.rememberY, auth.rememberW, auth.rememberH, auth.remember and "assets/active_zapamietajmnie.png" or "assets/inactive_zapamietajmnie.png", 0, 0, 0, tocolor( 255, 255, 255, alpha ))
			dxDrawText( "Tutaj będą jakieś tam newsy itp itd", auth.newsX, auth.newsY, auth.newsX + auth.newsW, auth.newsY + auth.newsH, tocolor( 255, 255, 255, alpha ), 1.0, auth.font, "left", "top", false, true )
		end

		if progress > 2 then
			renderEditbox()
			if auth.showInput == false then
				auth.showInput = true
				showCursor( true )
				addEventHandler ( "onClientClick", root, auth.loginClick )
				addEventHandler("onClientKey", root, auth.loginKey)
				auth.showInput = true
				dxCreateEdit(auth.nameID, auth.nameX, auth.nameY, auth.editW, auth.editH, auth.login, tocolor( 0, 0, 0, 255), auth.font, 1.0, 30, true, tocolor( 0, 0, 0, 255 ), false, 'left', true, false )
				dxCreateEdit(auth.passwordID, auth.passwordX, auth.passwordY, auth.editW, auth.editH, auth.password, tocolor( 0, 0, 0, 255 ), auth.font, 1.0, 30, true, tocolor( 0, 0, 0, 255 ), true, 'left', true, false )
			end
		end
	elseif auth.state == 2 then
		local progress = (getTickCount() - auth.cameraTick) / 4000
		local X, Y, Z = interpolateBetween( 1288.4091796875, -1711.8662109375, 20,
										 auth.cameraPosition[1], auth.cameraPosition[2], auth.cameraPosition[3],
										 progress, "Linear" )
		local lX, lY, lZ = interpolateBetween( 1310.5205078125, -1711.3837890625, 20,
										 auth.charPosition[1], auth.charPosition[2], auth.charPosition[3],
										 progress, "Linear" )

		setCameraMatrix( X, Y, Z, lX, lY, lZ )

		if progress > 1 then
			auth.state = 3
			addEventHandler("onClientKey", root, auth.charKey)
			for i, v in ipairs(auth.charPed) do
				if i ~= auth.chooseChar then
					setPedAnimation( v, "COP_AMBIENT", "Coplook_loop", -1, false, false)
				end
			end
		end
	elseif auth.state == 3 then
		local progress = (getTickCount() - auth.cameraTick) / 300
		local X, Y, Z = interpolateBetween( auth.cameraPosition[1], auth.cameraPosition[2] + (0.5 * (auth.lastChar-1)), auth.cameraPosition[3],
										 auth.cameraPosition[1], auth.cameraPosition[2] + (0.5 * (auth.chooseChar-1)), auth.cameraPosition[3],
										 progress, "Linear" )
		local lX, lY, lZ = interpolateBetween( auth.charPosition[1], auth.charPosition[2] + (0.5 * (auth.lastChar-1)), auth.charPosition[3],
										 auth.charPosition[1], auth.charPosition[2] + (0.5 * (auth.chooseChar-1)), auth.charPosition[3],
										 progress, "Linear" )
		local r1, r2 = interpolateBetween( 180, 125, 0,
																		 	 125, 180, 0,
																		 	 progress, "Linear" )

		setCameraMatrix( X, Y, Z, lX, lY, lZ )
		setElementRotation( auth.charPed[auth.lastChar], 0, 0, r2 )
		setElementRotation( auth.charPed[auth.chooseChar], 0, 0, r1 )


		dxDrawImage( auth.charInfoX, auth.charInfoY, auth.charInfoW, auth.charInfoH, "assets/chselect_info.png" )
		if progress > 1 then
			local char = auth.chooseChar
			dxDrawRectangle( auth.charBlurX, auth.charBlurY, auth.charBlurW, auth.charBlurH, tocolor(0, 0, 0, 200) )
			dxDrawRectangle( auth.charBlurX2, auth.charBlurY2, auth.charBlurW2, auth.charBlurH2, tocolor(0, 0, 0, 200) )

			dxDrawText( auth.characters[char].username, auth.charBlurX + 20 * scaleX, auth.charBlurY + 20 * scaleX, 0, 0, tocolor(255, 255, 255), 1.0, auth.font2, "left", "top" )
			
			dxDrawRectangle( auth.charBlurX + 20 * scaleX, auth.charBlurY + 80 * scaleX, auth.charBlurW - 40 * scaleX, 1, tocolor(63, 57, 56))
			dxDrawText( "UID:", auth.charBlurX + 20 * scaleX, auth.charBlurY + 85 * scaleX, 0, 0, tocolor(255, 255, 255), 1.0, auth.font3, "left", "top" )
			dxDrawText( auth.characters[char].id, 0, auth.charBlurY + 85 * scaleX, auth.charBlurX - 20 * scaleX + auth.charBlurW, 0, tocolor(255, 255, 255), 1.0, auth.font3, "right", "top" )
			
			dxDrawRectangle( auth.charBlurX + 20 * scaleX, auth.charBlurY + 110 * scaleX, auth.charBlurW - 40 * scaleX, 1, tocolor(63, 57, 56))
			dxDrawText( "WIEK:", auth.charBlurX + 20 * scaleX, auth.charBlurY + 115 * scaleX, 0, 0, tocolor(255, 255, 255), 1.0, auth.font3, "left", "top" )
			dxDrawText( auth.characters[char].age, 0, auth.charBlurY + 115 * scaleX, auth.charBlurX - 20 * scaleX + auth.charBlurW, 0, tocolor(255, 255, 255), 1.0, auth.font3, "right", "top" )
			
			dxDrawRectangle( auth.charBlurX + 20 * scaleX, auth.charBlurY + 140 * scaleX, auth.charBlurW - 40 * scaleX, 1, tocolor(63, 57, 56))
			dxDrawText( "PŁEĆ:", auth.charBlurX + 20 * scaleX, auth.charBlurY + 145 * scaleX, 0, 0, tocolor(255, 255, 255), 1.0, auth.font3, "left", "top" )
			dxDrawText( auth.characters[char].sex and "Kobieta" or "Mężczyzna", 0, auth.charBlurY + 145 * scaleX, auth.charBlurX - 20 * scaleX + auth.charBlurW, 0, tocolor(255, 255, 255), 1.0, auth.font3, "right", "top" )

			dxDrawRectangle( auth.charBlurX + 20 * scaleX, auth.charBlurY + 170 * scaleX, auth.charBlurW - 40 * scaleX, 1, tocolor(63, 57, 56))
			dxDrawText( "PRZEGRANY CZAS:", auth.charBlurX + 20 * scaleX, auth.charBlurY + 175 * scaleX, 0, 0, tocolor(255, 255, 255), 1.0, auth.font3, "left", "top" )
			dxDrawText( string.format("%dh %dm", auth.characters[char].hours, auth.characters[char].minutes), 0, auth.charBlurY + 175 * scaleX, auth.charBlurX - 20 * scaleX + auth.charBlurW, 0, tocolor(255, 255, 255), 1.0, auth.font3, "right", "top" )

			dxDrawText( "ZDROWIE", auth.charBlurX2, auth.charBlurY2 + 20 * scaleX, auth.charBlurX2 + auth.charBlurW2/3, 0, tocolor(201, 200, 200), 1.0, auth.font2, "center", "top" )
			dxDrawText( auth.characters[char].hp.."%", auth.charBlurX2, auth.charBlurY2 + 55 * scaleX, auth.charBlurX2 + auth.charBlurW2/3, 0, tocolor(255, 255, 255), 1.0, auth.font4, "center", "top" )

			dxDrawText( "GOTÓWKA", auth.charBlurX2 + auth.charBlurW2/3, auth.charBlurY2 + 20 * scaleX, auth.charBlurX2 + (auth.charBlurW2/3 * 2), 0, tocolor(201, 200, 200), 1.0, auth.font2, "center", "top" )
			dxDrawText( "$"..auth.characters[char].money, auth.charBlurX2 + auth.charBlurW2/3, auth.charBlurY2 + 55 * scaleX, auth.charBlurX2 + (auth.charBlurW2/3 * 2), 0, tocolor(255, 255, 255), 1.0, auth.font4, "center", "top" )


			dxDrawText( "W BANKU", auth.charBlurX2 + (auth.charBlurW2/3 * 2), auth.charBlurY2 + 20 * scaleX, auth.charBlurX2 + auth.charBlurW2, 0, tocolor(201, 200, 200), 1.0, auth.font2, "center", "top" )
			dxDrawText( "$"..auth.characters[char].bank, auth.charBlurX2 + (auth.charBlurW2/3 * 2), auth.charBlurY2 + 55 * scaleX, auth.charBlurX2 + auth.charBlurW2, 0, tocolor(255, 255, 255), 1.0, auth.font4, "center", "top" )

			dxDrawText( "GRUPY", auth.charBlurX2 + 40 * scaleX, auth.charBlurY2 + 130 * scaleX, 0, 0, tocolor(125, 122, 120), 1.0, auth.font3, "left", "top" )
			dxDrawImage( auth.charBlurX2 + 100 * scaleX, auth.charBlurY2 + 160 * scaleX, 125 * scaleX, 107 * scaleX, "assets/char_groups.png" )
			dxDrawText( auth.characters[char].groups, auth.charBlurX2 + 100 * scaleX, auth.charBlurY2 + 277 * scaleX, auth.charBlurX2 + 225 * scaleX, 0, tocolor(125, 122, 120), 1.0, auth.font3, "center", "top" )

			dxDrawText( "POJAZDY", auth.charBlurX2 + 290 * scaleX, auth.charBlurY2 + 130 * scaleX, 0, 0, tocolor(125, 122, 120), 1.0, auth.font3, "left", "top" )
			dxDrawImage( auth.charBlurX2 + 350 * scaleX, auth.charBlurY2 + 160 * scaleX, 125 * scaleX, 107 * scaleX, "assets/char_car.png" )
			dxDrawText( auth.characters[char].vehicles, auth.charBlurX2 + 350 * scaleX, auth.charBlurY2 + 277 * scaleX, auth.charBlurX2 + 475 * scaleX, 0, tocolor(125, 122, 120), 1.0, auth.font3, "center", "top" )

			dxDrawText( "PRZEDMIOTY", auth.charBlurX2 + 40 * scaleX, auth.charBlurY2 + 333 * scaleX, 0, 0, tocolor(125, 122, 120), 1.0, auth.font3, "left", "top" )
			dxDrawImage( auth.charBlurX2 + 100 * scaleX, auth.charBlurY2 + 363 * scaleX, 125 * scaleX, 107 * scaleX, "assets/char_items.png" )
			dxDrawText( auth.characters[char].items, auth.charBlurX2 + 100 * scaleX, auth.charBlurY2 + 480 * scaleX, auth.charBlurX2 + 225 * scaleX, 0, tocolor(125, 122, 120), 1.0, auth.font3, "center", "top" )

			dxDrawText( "OSIĄGNIĘCIA", auth.charBlurX2 + 290 * scaleX, auth.charBlurY2 + 333 * scaleX, 0, 0, tocolor(125, 122, 120), 1.0, auth.font3, "left", "top" )
			dxDrawImage( auth.charBlurX2 + 350 * scaleX, auth.charBlurY2 + 363 * scaleX, 125 * scaleX, 107 * scaleX, "assets/char_achi.png" )
			dxDrawText( "--", auth.charBlurX2 + 350 * scaleX, auth.charBlurY2 + 480 * scaleX, auth.charBlurX2 + 475 * scaleX, 0, tocolor(125, 122, 120), 1.0, auth.font3, "center", "top" )

		end
	end

	if auth.dark == 1 then
		local progress = (getTickCount() - auth.darkTick) / 2000
		local alpha = interpolateBetween( 0, 0, 0,
										255, 0, 0,
									 progress, "Linear" )
		dxDrawRectangle( 0, 0, screenX, screenY, tocolor(0, 0, 0, alpha) )
	elseif auth.dark == 2 then
		local progress = (getTickCount() - auth.darkTick) / 2000
		local alpha = interpolateBetween( 255, 0, 0,
										0, 0, 0,
									 progress, "Linear" )
		dxDrawRectangle( 0, 0, screenX, screenY, tocolor(0, 0, 0, alpha) )

		if progress > 1 then
			auth.dark = 0
			if auth.state == 0 then
  			removeEventHandler( "onClientRender", root, auth.onRender )
  		end
		end
	end
end

function auth.loginClick(_, state, x, y)
	if state == "down" then
		if x >= auth.buttonX and x <= auth.buttonX + auth.buttonW and y >= auth.buttonY and y <= auth.buttonY + auth.buttonH then
			auth.checkInput()

		elseif x >= auth.rememberX and x <= auth.rememberX + auth.rememberW and y >= auth.rememberY and y <= auth.rememberY + auth.rememberH then
			auth.remember = not auth.remember
		end
	end
end

function auth.loginKey(button, pressed)
	if button == 'enter' and pressed == true then
		auth.checkInput()
	end
end

function auth.checkInput()
	local name = dxGetEditText(auth.nameID)
	local password = dxGetEditText(auth.passwordID)
	if string.len(name) <= 3 then
		exports.sarp_notify:addNotify('Login musi zawierać przynajmniej 3 znaki.')
	elseif string.len(password) <= 3 or string.len(password) >= 32 then
		exports.sarp_notify:addNotify('Hasło musi zawierać od 3 do 32 znaków.')
	elseif not auth.pressed then
		if auth.remember then
			savePlayerPassword(name, password)
		else
			deletePlayerPassword()
		end

		auth.pressed = true
		triggerServerEvent( "checkLogin", localPlayer, name, password )
	end
end

function auth.loginStatus(status)
	auth.pressed = false
	if status == 'password' then
		return exports.sarp_notify:addNotify('Wpisane hasło jest nieprawidłowe.')
	elseif status == 'username' then
		return exports.sarp_notify:addNotify('Uzytkownik o takim nicku nie istnieje.')
	elseif status == 'nochar' then
		return exports.sarp_notify:addNotify('Nie posiadasz zadnej postaci, musisz zalozyc ją na stronie w panelu gracza.')
	elseif status == 'serial' then
		return exports.sarp_notify:addNotify('Twój serial jest zabanowany.')
	elseif status == 'ban' then
		return exports.sarp_notify:addNotify('Te konto jest zabanowane.')
	elseif status == 'success' then
		auth.darkTick = getTickCount()
		auth.dark = 1
		removeEventHandler( "onClientClick", root, auth.loginClick )
		removeEventHandler( "onClientKey", root, auth.loginKey )
		setPlayerHudComponentVisible( "radar", false )
		showCursor( false )
		dxDestroyEditbox(auth.nameID)
		dxDestroyEditbox(auth.passwordID)
		triggerServerEvent( "selectChar", localPlayer )
	end
end

addEvent ("loginStatus",true)
addEventHandler( "loginStatus", localPlayer, auth.loginStatus )

function auth.charKey(button, pressed)
	if pressed == true then
		if button == 'arrow_l' or button == 'a' then
			if auth.cameraTick + 300 > getTickCount() then return end

			auth.lastChar = auth.chooseChar
			if auth.chooseChar == #auth.characters then
				auth.chooseChar = 1
			else
				auth.chooseChar = auth.chooseChar + 1
			end
			auth.cameraTick = getTickCount()
			setPedAnimation( auth.charPed[auth.lastChar], "COP_AMBIENT", "Coplook_loop", -1, false, false)
			setPedAnimation( auth.charPed[auth.chooseChar] )
		elseif button == 'arrow_r' or button == 'd' then
			if auth.cameraTick + 300 > getTickCount() then return end

			auth.lastChar = auth.chooseChar
			if auth.chooseChar == 1 then
				auth.chooseChar = #auth.characters
			else
				auth.chooseChar = auth.chooseChar - 1
			end
			auth.cameraTick = getTickCount()
			setPedAnimation( auth.charPed[auth.lastChar], "COP_AMBIENT", "Coplook_loop", -1, false, false)
			setPedAnimation( auth.charPed[auth.chooseChar] )
		elseif button == 'enter' then
			auth.state = 0
			auth.darkTick = getTickCount()
			auth.dark = 1
			destroyElement( auth.music )
			removeEventHandler( "onClientKey", root, auth.charKey )
			triggerServerEvent( "spawnPlayer", localPlayer, auth.characters[auth.chooseChar].id )

			for i, v in ipairs(auth.sceneElement) do
				destroyElement( v )
			end

			local isSpawn = true

			local function isPlayerSpawned()
				if isSpawn then
					isSpawn = false
					auth.darkTick = getTickCount()
					auth.dark = 2
					for i, v in ipairs(auth.charPed) do
						destroyElement( v )
					end
					removeEventHandler( "onClientPlayerSpawn", root, isPlayerSpawned )
				end
			end
			addEventHandler( "onClientPlayerSpawn", root, isPlayerSpawned )
		end
	end
end

function auth.charShow(characters)
	auth.characters = characters
	auth.dark = 2
	auth.darkTick = getTickCount()
	auth.state = 2
	auth.cameraTick = getTickCount()

	for i, v in ipairs(auth.characters) do
		table.insert(auth.charPed, createPed( v.skin, auth.charPosition[1], auth.charPosition[2] + (0.5 * i), auth.charPosition[3], auth.charPosition[4] ))
	end

	for i, v in ipairs(auth.charPed) do
		setElementPosition( v, auth.charPosition[1], auth.charPosition[2] + (0.5 * i), auth.charPosition[3] )
		setElementFrozen( v, true )
	end

	table.insert(auth.sceneElement, createPed( 164, 1322.2041015625, -1707.9931640625, 13.546875, 90 ))
	table.insert(auth.sceneElement, createPed( 163, 1322.2041015625, -1710.7744140625, 13.546875, 90 ))
	table.insert(auth.sceneElement, createVehicle( 409, 1316.6533203125, -1701.6318359375, 13.260869979858, 0, 0, 0.21978759765625, "MTA-RP" ))
	table.insert(auth.sceneElement, createObject( 2773, 1320.06, -1708.28, 13.0608, 0, 0, 90 ))
	table.insert(auth.sceneElement, createObject( 2773, 1319.99, -1711.95, 13.0608, 0, 0, 90 ))

	for i, v in ipairs(auth.sceneElement) do
		setElementDimension( v, 1000 )
		if getElementType( v ) == 'vehicle' then
			setVehicleColor( v, 255, 255, 255 )
		end

		if getElementType( v ) == 'ped' then
			setPedAnimation( v, "ped", "IDLE_HBHB", 0, true, false )
		end
	end

	for i, v in ipairs(auth.charPed) do
		setElementDimension( v, 1000 )
	end

	setElementRotation( auth.charPed[auth.chooseChar], 0, 0, 125 )
	auth.darkTick = getTickCount()
	auth.dark = 2
end

addEvent ("showCharacters",true)
addEventHandler( "showCharacters", localPlayer, auth.charShow )

--zapisywanie haseł
function deletePlayerPassword()
	local file = xmlLoadFile( "@account.xml" )
	if not file then return end

	local child = xmlNodeGetChildren(file)

	for i, v in pairs(child) do
		xmlDestroyNode( v )
		xmlSaveFile( file )
	end
	xmlUnloadFile(file)
end

function loadPlayerPassword()
	local file = xmlLoadFile( "@account.xml" )
	if not file then return end

	local log = xmlFindChild( file, "login", 0 )
	if log then
		auth.login = xmlNodeGetValue( log )
	end

	local pass = xmlFindChild( file, "password", 0 )
	if pass then
		auth.password = teaDecode( xmlNodeGetValue( pass ), auth.passwordKey )
	end

	if log and pass then
		auth.remember = true
	end

	xmlUnloadFile(file)
end

function savePlayerPassword(name, password)
	password = teaEncode( password, auth.passwordKey )

	local file = xmlLoadFile("@account.xml")

	if not file then
		file = xmlCreateFile( "@account.xml", "account" )
	end

	if xmlFindChild( file, "login", 0 ) then
		xmlNodeSetValue( xmlFindChild( file, "login", 0 ), name )
	else
		local child = xmlCreateChild( file, "login" )
		xmlNodeSetValue( child, name )
	end

	if xmlFindChild( file, "password", 0 ) then
		xmlNodeSetValue( xmlFindChild( file, "password", 0 ), password )
	else
		local child = xmlCreateChild( file, "password" )
		xmlNodeSetValue( child, password )
	end

	xmlSaveFile( file )
	xmlUnloadFile(file)
end