--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

lastEditbox = -1
edit = {}
changepos = false
removechar = false

function dxCreateEdit(id, x, y, width, height, string, stringcolor, font, fontsize, maxlength, carret, carretColor, password, center, clip, wordBreak)
	if edit[id] == nil then
		edit[id] = {}
		edit[id].x = x
		edit[id].y = y
		edit[id].width = width
		edit[id].height = height
		edit[id].string = string
		edit[id].font = font
		edit[id].fontsize = fontsize
		edit[id].maxlength = maxlength
		edit[id].carret = carret
		edit[id].carretColor = carretColor
		edit[id].carretPosition = string.len(edit[id].string)
		edit[id].password = password
		edit[id].center = center
		edit[id].stringcolor = stringcolor
		edit[id].clip = clip
		edit[id].wordBreak = wordBreak
	end
end

function dxGetEditText(id)
	if edit[id] ~= nil then
		return tostring(edit[id].string)
	end
end

function dxDestroyEditbox(id)
	if edit[id] ~= nil then
		edit[id] = nil
	end
end

function clickEditbox(_, _, x, y)
	for i, v in pairs(edit) do
		if x >= edit[i].x and x <= edit[i].x + edit[i].width and y >= edit[i].y and y <= edit[i].y + edit[i].height then
			lastEditbox = i
			return
		end
	end
	lastEditbox = -1
	return
end

addEventHandler( "onClientClick", root, clickEditbox )

--[[function keyEditbox(button, pressed)
	local i = lastEditbox
	local string = ''
	if i == -1 then
		return
	end

	if pressed == true and isKey(button) and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
		if button == 'backspace' and #edit[i].string > 0 and edit[i].carretPosition >= 1 then
			string = string.sub(edit[i].string, 1, edit[i].carretPosition - 1 )
			edit[i].string = string .. string.sub(edit[i].string, edit[i].carretPosition + 1)
			edit[i].carretPosition = edit[i].carretPosition - 1
		elseif button == 'arrow_l' and edit[i].carretPosition >= 1 then
			edit[i].carretPosition = edit[i].carretPosition - 1
		elseif button == 'arrow_r' and edit[i].carretPosition < #edit[i].string then
			edit[i].carretPosition = edit[i].carretPosition + 1
		elseif button == 'delete' and edit[i].carretPosition < #edit[i].string then
			string = string.sub(edit[i].string, 1, edit[i].carretPosition )
			edit[i].string = string .. string.sub(edit[i].string, edit[i].carretPosition + 2 )
		elseif button ~= 'backspace' and button ~= 'delete' and button ~= 'arrow_l' and button ~= 'arrow_r' then
			if button == "space" then button = ' ' end
			edit[i].carretPosition = edit[i].carretPosition + 1
			string = string.sub(edit[i].string, 1, edit[i].carretPosition )
			edit[i].string = string .. button .. string.sub(edit[i].string, edit[i].carretPosition )
		end
	end
end
addEventHandler( "onClientKey", root, keyEditbox )
--]]

function renderEditbox()
	for i, v in pairs(edit) do
		--editbox
		if (#edit[i].string) > 0 then

			if edit[i].password then
				dxDrawText( string.rep( '*', string.len(edit[i].string)), edit[i].x, edit[i].y, edit[i].x + edit[i].width, edit[i].y + edit[i].height, edit[i].stringcolor, edit[i].fontsize, edit[i].font, edit[i].center, "center", edit[i].clip, edit[i].wordBreak )
			else
				dxDrawText( edit[i].string, edit[i].x, edit[i].y, edit[i].x + edit[i].width, edit[i].y + edit[i].height, edit[i].stringcolor, edit[i].fontsize, edit[i].font, edit[i].center, "center", edit[i].clip, edit[i].wordBreak )
			end

			if edit[i].center == 'center' then
				if edit[i].carret and dxGetTextWidth( edit[i].string, edit[i].fontsize, edit[i].font ) < edit[i].width and i == lastEditbox then
					local position, text = ''
					if edit[i].password then
						text = string.sub(string.rep( '*', #edit[i].string), 1, edit[i].carretPosition)
						position = dxGetTextWidth( text, edit[i].fontsize, edit[i].font )
						dxDrawRectangle( edit[i].x + (edit[i].width - dxGetTextWidth( string.rep( '*', #edit[i].string), edit[i].fontsize, edit[i].font ))/2 + position, edit[i].y  + (edit[i].height - (edit[i].height - edit[i].height/6)) /2, 1, edit[i].height - edit[i].height/6, edit[i].carretColor )
					else
						text = string.sub(edit[i].string, 1, edit[i].carretPosition )
						position =  dxGetTextWidth( text, edit[i].fontsize, edit[i].font )
						dxDrawRectangle( edit[i].x + (edit[i].width - dxGetTextWidth( edit[i].string, edit[i].fontsize, edit[i].font ))/2 + position, edit[i].y + (edit[i].height - (edit[i].height - edit[i].height/6)) /2, 1, edit[i].height - edit[i].height/6, edit[i].carretColor )
					end
				end
			else
				if edit[i].carret and dxGetTextWidth( edit[i].string, edit[i].fontsize, edit[i].font ) < edit[i].width and i == lastEditbox then
					local position, text = ''
					if edit[i].password then
						text = string.sub(string.rep( '*', #edit[i].string), 1, edit[i].carretPosition)
						position = dxGetTextWidth( text, edit[i].fontsize, edit[i].font )
						dxDrawRectangle( edit[i].x + position, edit[i].y  + (edit[i].height - (edit[i].height - edit[i].height/6)) /2, 1, edit[i].height - edit[i].height/6, edit[i].carretColor )
					else
						text = string.sub(edit[i].string, 1, edit[i].carretPosition )
						position =  dxGetTextWidth( text, edit[i].fontsize, edit[i].font )
						dxDrawRectangle( edit[i].x + position, edit[i].y + (edit[i].height - (edit[i].height - edit[i].height/6)) /2, 1, edit[i].height - edit[i].height/6, edit[i].carretColor )
					end
				end
			end

		end
	end

	--change carret pos
	local i = lastEditbox
	if i ~= -1 then
		lastTick = getTickCount()

		if (getKeyState( 'arrow_r' ) or getKeyState( 'arrow_l' )) and not changepos  then
			changepos = getTickCount()
		end

		if changepos and (lastTick - changepos) > 50 then
			changepos = false
			if getKeyState( 'arrow_r' ) and edit[i] and edit[i].carretPosition < #edit[i].string then
				edit[i].carretPosition = edit[i].carretPosition + 1
			elseif getKeyState( 'arrow_l') and edit[i] and edit[i].carretPosition >= 1 then
				edit[i].carretPosition = edit[i].carretPosition - 1
			end
		end

		--remove character
		if(getKeyState( 'backspace') or getKeyState( 'delete')) and not removechar then
			removechar = getTickCount()
		end

		if removechar and (lastTick - removechar) > 50 then
			removechar = false
			if string.len(edit[i].string) > 0 and getKeyState( 'backspace' ) and #edit[i].string > 0 and edit[i].carretPosition >= 1 then
				edit[i].string = string.sub(edit[i].string, 1, edit[i].carretPosition - 1 ) .. string.sub(edit[i].string, edit[i].carretPosition + 1)
				edit[i].carretPosition = edit[i].carretPosition - 1
			elseif getKeyState( 'delete') and edit[i].carretPosition < #edit[i].string then
				edit[i].string = string.sub(edit[i].string, 1, edit[i].carretPosition ) .. string.sub(edit[i].string, edit[i].carretPosition + 2 )
			end
		end
	end
end

function characterEditbox(char)
	local i = lastEditbox
	local string = ''

	if i == -1 or not edit[i] or not edit[i].string or edit[i].maxlength == #edit[i].string then
		return
	end

	if not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
		string = string.sub(edit[i].string, 1, edit[i].carretPosition )
		edit[i].string = string .. char .. string.sub(edit[i].string, edit[i].carretPosition + 1 )
		edit[i].carretPosition = edit[i].carretPosition + 1
	end
end

addEventHandler( "onClientCharacter", root, characterEditbox )