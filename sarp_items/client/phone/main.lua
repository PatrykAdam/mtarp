local phone = {}
local phoneData = {}
phoneData.messages = {}
phoneData.news = {}

function phone.onStart()
	phone.active = false
	phone.overlap = 1

	phone.W, phone.H = 450 * scaleX, 700 * scaleX
	phone.X, phone.Y = screenX - phone.W - 10 * scaleX, screenY - phone.H - 20 * scaleX
	
	phone.backgroundW, phone.backgroundH = 271 * scaleX, 481 * scaleX
	phone.backgroundX, phone.backgroundY = phone.X + 97 * scaleX, phone.Y + 110 * scaleX
	phone.tabW, phone.tabH = 271 * scaleX, 50 * scaleX
	phone.tabX, phone.tabY = phone.backgroundX, phone.backgroundY + 22 * scaleX
	phone.sendW, phone.sendH = 30 * scaleX, 30 * scaleX
	phone.sendX, phone.sendY = phone.backgroundX + phone.backgroundW - phone.sendW - 10 * scaleX, phone.backgroundY + phone.backgroundH - 90 * scaleX
	
	--czcionka
	phone.fonts = {}
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Arial_Bold.ttf", 10 * scaleX, true ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 10 * scaleX ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 30 * scaleX, false ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 14 * scaleX, false ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 10 * scaleX ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 22 * scaleX ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 12 * scaleX, false ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Myriad_Pro_Regular.ttf", 8 * scaleX, false ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Roboto-Light.ttf", 28 * scaleX ))
	table.insert(phone.fonts, dxCreateFont( "assets/phone/Roboto-Light.ttf", 10 * scaleX ))
	
	phone.buttons = {
		{ --pierwsza karta
			{X = phone.backgroundX + 25 * scaleX, Y = phone.backgroundY + 320 * scaleX, W = 56 * scaleX, H = 70 * scaleX}, --1 Kontakty
			{X = phone.backgroundX + 95 * scaleX, Y = phone.backgroundY + 320 * scaleX, W = 70 * scaleX, H = 70 * scaleX}, --2 Wiadomości
			{X = phone.backgroundX + 178 * scaleX, Y = phone.backgroundY + 315 * scaleX, W = 58 * scaleX, H = 70 * scaleX}, --3 Ustawienia
		},
		{ -- druga karta
		},
		{ -- trzecia karta
		},
		{ -- czwarta karta
			{X = phone.tabX + 100 * scaleX, Y = phone.tabY, W = phone.tabW - 100 * scaleX, H = phone.tabH}
		},
		{ -- piąta karta
			{X = phone.tabX, Y = phone.tabY, W = 100 * scaleX, H = phone.tabH}
		}

	}

	phone.downButtons = {
		{X = phone.backgroundX + 20 * scaleX, Y = phone.backgroundY + phone.backgroundH - 45 * scaleX, W = 40 * scaleX, H = 40 * scaleX},
		{X = phone.backgroundX + phone.backgroundW - 60 * scaleX, Y = phone.backgroundY + phone.backgroundH - 45 * scaleX, W = 40 * scaleX, H = 40 * scaleX},
		{X = phone.backgroundX + 115 * scaleX, Y = phone.backgroundY + phone.backgroundH - 45 * scaleX, W = 40 * scaleX, H = 40 * scaleX},
	}
	--phone.show()
end

addEventHandler( "onClientResourceStart", resourceRoot, phone.onStart )

function phone.onClick(button, state, X, Y)
	if state ~= "down" then return end


	--przyciski zdefiniowane od razu
	if phone.buttons[phone.overlap] then
		for j, k in ipairs(phone.buttons[phone.overlap]) do
			if X >= k.X and X <= k.X + k.W and Y >= k.Y and Y <= k.Y + k.H then
				if phone.overlap == 1 then -- Strona główna
					if j == 1 then -- Kontakty
						phone.overlap = 4
					elseif j == 2 then -- Wiadomości
						phone.overlap = 2
					elseif j == 3 then -- Ustawienia
						return exports.sarp_notify:addNotify("Ustawienia w mtaPHONE zostały wyłączone.")
					end
				elseif phone.overlap == 4 then
					if j == 1 then
						phone.overlap = 5
					end
				elseif phone.overlap == 5 then
					if j == 1 then
						phone.overlap = 4
					end
				end
			end
		end
	end

	--dolny pasek
	for i, v in ipairs(phone.downButtons) do
		if X >= v.X and X <= v.X + v.W and Y >= v.Y and Y <= v.Y + v.H then
			phone.overlap = 1
		end
	end
end

function phone.render()
	local time = getRealTime()

	dxDrawImage( phone.X, phone.Y, phone.W, phone.H, "assets/phone/base.png" )

	--znaczek
	dxDrawText( "mtaPHONE", phone.X + 180 * scaleX, phone.Y + 85 * scaleX, phone.X + 290 * scaleX, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[1], "center", "top" )


	if phone.overlap < 2 then
		dxDrawImage( phone.backgroundX, phone.backgroundY, phone.backgroundW, phone.backgroundH, "assets/phone/background1.png" )
	end

	if phone.overlap == 1 then --Strona główna
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, 271 * scaleX, 22 * scaleX, tocolor( 0, 0, 0 ) )

		dxDrawText( string.format("%02d:%02d", time.hour, time.minute), phone.backgroundX + 15 * scaleX, phone.backgroundY + 70 * scaleX, 0, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[3], "left", "top")
		dxDrawText( string.format("%s, %02d.%02d", phone.weekday(time.weekday), time.monthday, time.month), phone.backgroundX + 15 * scaleX, phone.backgroundY + 110 * scaleX, 0, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[4], "left", "top")

		--[[if phone.buttons[phone.overlap] then
			for j, k in ipairs(phone.buttons[phone.overlap]) do
				dxDrawRectangle( k.X, k.Y, k.W, k.H )
			end
		end]]

		dxDrawImage( phone.backgroundX + 25 * scaleX, phone.backgroundY + 305 * scaleX, 56 * scaleX, 67 * scaleX, "assets/phone/icon_contact.png" )
		dxDrawText( "Kontakty", phone.backgroundX + 25 * scaleX, phone.backgroundY + 370 * scaleX, phone.backgroundX + 25 * scaleX + 56 * scaleX, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[5], "center", "top")

		dxDrawImage( phone.backgroundX + 105 * scaleX, phone.backgroundY + 305 * scaleX, 56 * scaleX, 67 * scaleX, "assets/phone/icon_message.png" )
		dxDrawText( "Wiadomości", phone.backgroundX + 105 * scaleX, phone.backgroundY + 370 * scaleX, phone.backgroundX + 105 * scaleX + 56 * scaleX, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[5], "center", "top")	
		
		dxDrawImage( phone.backgroundX + 180 * scaleX, phone.backgroundY + 305 * scaleX, 56 * scaleX, 67 * scaleX, "assets/phone/icon_settings.png" )
		dxDrawText( "Ustawienia", phone.backgroundX + 180 * scaleX, phone.backgroundY + 370 * scaleX, phone.backgroundX + 180 * scaleX + 56 * scaleX, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[5], "center", "top")	
	end

	if phone.overlap == 2 then --Lista wiadomości
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, phone.backgroundW, phone.backgroundH, tocolor( 245, 245, 245 ) )
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, 271 * scaleX, 22 * scaleX, tocolor( 76, 100, 111 ) )
		dxDrawRectangle( phone.tabX, phone.tabY, phone.tabW, phone.tabH, tocolor( 96, 125, 139 ) )
		dxDrawImage( phone.tabX + phone.tabW - 40 * scaleX, phone.tabY + 10 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_more.png" )

		dxDrawText( "Wiadomości", phone.tabX + 20 * scaleX, phone.tabY, 0, phone.tabY + phone.tabH, tocolor( 255, 255, 255 ), 1.0, phone.fonts[7], "left", "center" )
	
		for i, v in ipairs(phoneData.news) do
			dxDrawText( v.name, phone.tabX + 20 * scaleX, phone.tabY + phone.tabH + 10 * scaleX + (60 * scaleX) * i, 0, 0, tocolor(64, 64, 64), 1.0, phone.fonts[4], "left", "top" )
			dxDrawText( v.messages[#v.messages].text, phone.tabX + 20 * scaleX, phone.tabY + phone.tabH + 30 * scaleX + (60 * scaleX) * i, 0, 0, tocolor(64, 64, 64), 1.0, phone.fonts[7], "left", "top" )
			dxDrawText( v.messages[#v.messages].date, 0, phone.tabY + phone.tabH + 30 * scaleX + (60 * scaleX) * i, phone.tabX + phone.tabW - 20 * scaleX, 0, tocolor(168, 168, 168), 1.0, phone.fonts[7], "right", "top")
			dxDrawRectangle( phone.tabX + 20 * scaleX, phone.tabY + phone.tabH + 60 * scaleX + (60 * scaleX) * i, phone.tabW - 20 * scaleX, 1, tocolor(168, 168, 168) )
		end
	end

	if phone.overlap == 3 then --treść wiadomości
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, phone.backgroundW, phone.backgroundH, tocolor( 245, 245, 245 ) )
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, 271 * scaleX, 22 * scaleX, tocolor( 76, 100, 111 ) )
		dxDrawRectangle( phone.tabX, phone.tabY, phone.tabW, phone.tabH, tocolor( 96, 125, 139 ) )
		dxDrawImage( phone.tabX + phone.tabW - 40 * scaleX, phone.tabY + 10 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_more.png" )
		dxDrawImage( phone.tabX + 10 * scaleX, phone.tabY + 10 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_back2.png" )
		dxDrawText( "Magda", phone.tabX + 50 * scaleX, phone.tabY, 0, phone.tabY + phone.tabH, tocolor( 255, 255, 255 ), 1.0, phone.fonts[7], "left", "center" )
		dxDrawImage( phone.tabX + phone.tabW - 80 * scaleX, phone.tabY + 10 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_phone.png" )
	
		for i, v in ipairs(phoneData.news[phone.messageID]) do
			if v.ownerID == phoneData.id then
				dxDrawRoundedRectangle( phone.tabX + 10 * scaleX, phone.tabY + 20 * scaleX + (60 * scaleX) * i, 181 * scaleX, 30 * scaleX, tocolor(255, 255, 255), 10 * scaleX )
				dxDrawText( v.date, phone.tabX + 25 * scaleX, phone.tabY + 58 * scaleX, 0, 0, tocolor(0, 0, 0), 1.0, phone.fonts[2], "left", "top" )
				dxDrawText( v.text, phone.tabX + 20 * scaleX, phone.tabY + 87.5 * scaleX, 0, 0, tocolor( 0, 0, 0, 222 ), 1.0, phone.fonts[7], "left", "top" )
			else
				dxDrawRoundedRectangle( phone.tabX + phone.tabW - 181 * scaleX - 10 * scaleX, phone.tabY + 80 * scaleX * scaleX + (60 * scaleX) * i, 181 * scaleX, 30 * scaleX, tocolor(70, 209, 8), 10 * scaleX )
				dxDrawText( v.date, 0, phone.tabY + 118 * scaleX, phone.tabX + phone.tabW - 25 * scaleX, 0, tocolor(0, 0, 0), 1.0, phone.fonts[2], "right", "top" )
				dxDrawText( v.text, phone.tabX + phone.tabW - 181 * scaleX, phone.tabY + 147.5 * scaleX, 0, 0, tocolor( 0, 0, 0, 222 ), 1.0, phone.fonts[7], "left", "top" )
			end
		end

		--
		dxDrawRectangle( phone.backgroundX, phone.backgroundY + phone.backgroundH - 90 * scaleX, phone.backgroundW, 40 * scaleX, tocolor(255, 255, 255) )
		dxDrawRectangle( phone.backgroundX, phone.backgroundY + phone.backgroundH - 90 * scaleX, phone.backgroundW, 1, tocolor(230, 230, 230))
		dxDrawRectangle( phone.backgroundX + 50 * scaleX, phone.backgroundY + phone.backgroundH - 80 * scaleX, 1, 20 * scaleX, tocolor( 0, 0, 0, 50) )
		dxDrawImage( phone.backgroundX + 10 * scaleX, phone.backgroundY + phone.backgroundH - 85 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_add.png" )
		dxDrawText( "Treść wiadomości..", phone.backgroundX + 55 * scaleX, phone.backgroundY + phone.backgroundH - 80 * scaleX, 0, phone.backgroundY + phone.backgroundH - 60 * scaleX, tocolor( 0, 0, 0, 125 ), 1.0, phone.fonts[4], "left", "center")
		dxDrawImage( phone.sendX, phone.sendY, phone.sendW, phone.sendH, "assets/phone/icon_send.png")
		dxDrawText( "Wyślij", phone.sendX, phone.sendY + phone.sendH - 7 * scaleX, phone.sendX + phone.sendW, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[5], "center")
	end

	if phone.overlap == 4 or phone.overlap == 5 then -- kontakty i historia połączeń (góra)
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, phone.backgroundW, phone.backgroundH, tocolor( 245, 245, 245 ) )
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, 271 * scaleX, 22 * scaleX, tocolor( 0, 118, 191 ) )
		dxDrawRectangle( phone.tabX, phone.tabY, phone.tabW, phone.tabH, tocolor( 1, 154, 232 ) )

		dxDrawRectangle( phone.tabX + (phone.overlap == 4 and 0 or 100 * scaleX), phone.tabY + phone.tabH - 2, phone.overlap == 4 and 100 * scaleX or phone.tabW - 100 * scaleX, 2, tocolor( 4, 81, 121 ) )

		dxDrawText( "Kontakty", phone.tabX + 20 * scaleX, phone.tabY, 0, phone.tabY + phone.tabH, tocolor( 255, 255, 255 ), 1.0, phone.fonts[4], "left", "center" )
		dxDrawText( "Historia połączeń", 0, phone.tabY, phone.tabX + phone.tabW - 20 * scaleX, phone.tabY + phone.tabH, tocolor( 255, 255, 255 ), 1.0, phone.fonts[4], "right", "center" )
	end

	if phone.overlap == 4 then -- kontakty
		--kontakt 1
		dxDrawImage( phone.backgroundX, phone.backgroundY + 75 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/avatar.png" )
		dxDrawText( "Michael Wilson", phone.backgroundX + 40 * scaleX, phone.backgroundY + 75 * scaleX, 0, phone.backgroundY + 75 * scaleX + 40 * scaleX, tocolor( 0, 0, 0 ), 1.0, phone.fonts[7], "left", "center" )
		dxDrawImage( phone.backgroundX + phone.backgroundW - 50 * scaleX, phone.backgroundY + 75 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/call.png" )
		dxDrawImage( phone.backgroundX + phone.backgroundW - 100 * scaleX, phone.backgroundY + 75 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/message.png" )
		dxDrawRectangle( phone.backgroundX + 20 * scaleX, phone.backgroundY + 115 * scaleX, phone.backgroundW - 20 * scaleX, 1, tocolor(168, 168, 168) )

		--kontakt 2
		dxDrawImage( phone.backgroundX, phone.backgroundY + 120 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/avatar.png" )
		dxDrawText( "David Rosilcov", phone.backgroundX + 40 * scaleX, phone.backgroundY + 120 * scaleX, 0, phone.backgroundY + 120 * scaleX + 40 * scaleX, tocolor( 0, 0, 0 ), 1.0, phone.fonts[7], "left", "center" )
		dxDrawImage( phone.backgroundX + phone.backgroundW - 50 * scaleX, phone.backgroundY + 120 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/call.png" )
		dxDrawImage( phone.backgroundX + phone.backgroundW - 100 * scaleX, phone.backgroundY + 120 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/message.png" )
		dxDrawRectangle( phone.backgroundX + 20 * scaleX, phone.backgroundY + 160 * scaleX, phone.backgroundW - 20 * scaleX, 1, tocolor(168, 168, 168) )
	end

	if phone.overlap == 5 then -- historia połączeń
		--kontakt 1
		dxDrawImage( phone.backgroundX, phone.backgroundY + 75 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/avatar.png" )
		dxDrawText( "Michael Wilson", phone.backgroundX + 40 * scaleX, phone.backgroundY + 80 * scaleX, 0, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[7], "left", "top" )
		dxDrawText( "10:27 przychodzące", phone.backgroundX + 40 * scaleX, phone.backgroundY + 95 * scaleX, 0, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[2], "left", "top")
		dxDrawImage( phone.backgroundX + phone.backgroundW - 50 * scaleX, phone.backgroundY + 75 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/call.png" )
		dxDrawImage( phone.backgroundX + phone.backgroundW - 100 * scaleX, phone.backgroundY + 75 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/message.png" )
		dxDrawRectangle( phone.backgroundX + 20 * scaleX, phone.backgroundY + 115 * scaleX, phone.backgroundW - 20 * scaleX, 1, tocolor(168, 168, 168) )

		--kontakt 2
		dxDrawImage( phone.backgroundX, phone.backgroundY + 120 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/avatar.png" )
		dxDrawText( "Michael Wilson", phone.backgroundX + 40 * scaleX, phone.backgroundY + 120 * scaleX, 0, 0, tocolor( 214, 0, 0 ), 1.0, phone.fonts[7], "left", "top" )
		dxDrawText( "10:27 przychodzące", phone.backgroundX + 40 * scaleX, phone.backgroundY + 135 * scaleX, 0, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[2], "left", "top")
		dxDrawImage( phone.backgroundX + phone.backgroundW - 50 * scaleX, phone.backgroundY + 120 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/call.png" )
		dxDrawImage( phone.backgroundX + phone.backgroundW - 100 * scaleX, phone.backgroundY + 120 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/message.png" )
		dxDrawRectangle( phone.backgroundX + 20 * scaleX, phone.backgroundY + 160 * scaleX, phone.backgroundW - 20 * scaleX, 1, tocolor(168, 168, 168) )
	end

	if phone.overlap == 6 then -- dzwonienie
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, phone.backgroundW, phone.backgroundH, tocolor( 245, 245, 245 ) )
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, phone.backgroundW, 155 * scaleX, tocolor( 250, 250, 250 ) )
		dxDrawRectangle( phone.backgroundX, phone.backgroundY, 271 * scaleX, 22 * scaleX, tocolor( 0, 0, 0 ) )

		dxDrawImage( phone.backgroundX, phone.backgroundY + 25 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/add_contact.png" )
		dxDrawText( "Utwórz nowy kontakt", phone.backgroundX + 60 * scaleX, phone.backgroundY + 25 * scaleX, 0, phone.backgroundY + 65 * scaleX, tocolor(0, 0, 0), 1.0, phone.fonts[4], "left", "center")

		dxDrawImage( phone.backgroundX, phone.backgroundY + 70 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/send_message.png" )
		dxDrawText( "Wyślij wiadomość", phone.backgroundX + 60 * scaleX, phone.backgroundY + 70 * scaleX, 0, phone.backgroundY + 110 * scaleX, tocolor(0, 0, 0), 1.0, phone.fonts[4], "left", "center")

		dxDrawImage( phone.backgroundX, phone.backgroundY + 115 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/icon_more2.png" )
		dxDrawText( "605-402", phone.backgroundX + 40 * scaleX, phone.backgroundY + 115 * scaleX, phone.backgroundX + phone.backgroundW - 40 * scaleX, 0, tocolor(0, 0, 0), 1.0, phone.fonts[6], "center", "top")
		dxDrawImage( phone.backgroundX + phone.backgroundW - 40 * scaleX, phone.backgroundY + 115 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/icon_delete.png" )

		dxDrawText( "1", phone.backgroundX, phone.backgroundY + 155 * scaleX, phone.backgroundX + phone.backgroundW/3, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "2", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 155 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "ABC", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 195 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")
		dxDrawText( "3", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 155 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "DEF", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 195 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")

		dxDrawText( "4", phone.backgroundX, phone.backgroundY + 205 * scaleX, phone.backgroundX + phone.backgroundW/3, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "GHI", phone.backgroundX, phone.backgroundY + 245 * scaleX, phone.backgroundX + phone.backgroundW/3, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")
		dxDrawText( "5", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 205 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "JKL", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 245 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")
		dxDrawText( "6", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 205 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "MNO", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 245 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")


		dxDrawText( "7", phone.backgroundX, phone.backgroundY + 255 * scaleX, phone.backgroundX + phone.backgroundW/3, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "PQRS", phone.backgroundX, phone.backgroundY + 295 * scaleX, phone.backgroundX + phone.backgroundW/3, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")
		dxDrawText( "8", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 255 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "TUV", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 295 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")
		dxDrawText( "9", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 255 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "WXYZ", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 295 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")

		dxDrawText( "*", phone.backgroundX, phone.backgroundY + 305 * scaleX, phone.backgroundX + phone.backgroundW/3, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "0", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 305 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")
		dxDrawText( "+", phone.backgroundX + phone.backgroundW/3, phone.backgroundY + 345 * scaleX, phone.backgroundX + (phone.backgroundW/3) * 2, 0, tocolor( 0, 0, 0, 135 ), 1.0, phone.fonts[10], "center", "top")
		dxDrawText( "#", phone.backgroundX + (phone.backgroundW/3) * 2, phone.backgroundY + 305 * scaleX, phone.backgroundX + phone.backgroundW, 0, tocolor( 0, 0, 0 ), 1.0, phone.fonts[9], "center", "top")

		dxDrawImage( phone.backgroundX + phone.backgroundW/2 - 40 * scaleX, phone.backgroundY + 355 * scaleX, 80 * scaleX, 80 * scaleX, "assets/phone/call_accept.png" )

	end

	dxDrawText( string.format("%02d:%02d", time.hour, time.minute), phone.backgroundX + 225 * scaleX, phone.backgroundY + 3 * scaleX, phone.backgroundX + 267 * scaleX, 0, tocolor( 255, 255, 255 ), 1.0, phone.fonts[2], "center", "top")
	dxDrawImage( phone.backgroundX + 185 * scaleX, phone.backgroundY - 5 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_range.png" )
	dxDrawImage( phone.backgroundX + 205 * scaleX, phone.backgroundY - 5 * scaleX, 30 * scaleX, 30 * scaleX, "assets/phone/icon_battery.png" )

	dxDrawRectangle( phone.backgroundX, phone.backgroundY + phone.backgroundH - 50 * scaleX, 271 * scaleX, 50 * scaleX, tocolor( 0, 0, 0 ) )
	dxDrawImage( phone.backgroundX + 20 * scaleX, phone.backgroundY + phone.backgroundH - 45 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/icon_back.png" )
	dxDrawImage( phone.backgroundX + phone.backgroundW - 60 * scaleX, phone.backgroundY + phone.backgroundH - 45 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/icon_recent.png" )
	dxDrawImage( phone.backgroundX + 115 * scaleX, phone.backgroundY + phone.backgroundH - 45 * scaleX, 40 * scaleX, 40 * scaleX, "assets/phone/icon_home.png" )


	--[[for i, v in ipairs(phone.downButtons) do
		dxDrawRectangle( v.X, v.Y, v.W, v.H )
	end]]

end

function phone.show()
	phone.lastTick = getTickCount()

	if not phone.active then
		showCursor( true )
		addEventHandler( "onClientRender", root, phone.render )
		addEventHandler( "onClientClick", root, phone.onClick )
	end

	phone.active = not phone.active
end

function phone.weekday(day)
	if day == 1 then
		return "Pon"
	elseif day == 2 then
		return "Wt"
	elseif day == 3 then
		return "Śr"
	elseif day == 4 then
		return "Czw"
	elseif day == 5 then
		return "Pt"
	elseif day == 6 then
		return "Sob"
	elseif day == 7 then
		return "Niedz"
	end
end

addEvent("showPhoneV1", true)
addEventHandler( "showPhoneV1", root, phone.show )

function phone.updateData(data)
	phoneData = data
end

addEvent("updatePhoneData", true)
addEventHandler( "updatePhoneData", root, phone.updateData )

function dxDrawRoundedRectangle(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end