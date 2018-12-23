screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)
local anim = {}

local anim_startingPos = 0.2900
local anim_startingPosbg = 355
local animListVisible = false
local animListGlobal
local chosenAnim = 0

local animCategories = {
	{"Leżenie", true},
	{"Postać", false},
	{"Barowe", false},
	{"Stack", false}
}
local category_chosen = 1
local categoriesPos = 0.3000
local startAnim = 0

function renderAnimList()
	anim.W, anim.H = 460 * scaleX, 550 * scaleY
	anim.posX, anim.posY = (screenX - anim.W)/2, (screenY - anim.H)/2
	dxDrawImage(anim.posX, anim.posY, anim.W, anim.H, "assets/bg.png", 0, 0, 0, tocolor(255, 255, 255, 209), false)
    dxDrawLine(screenX * 0.4631, screenY * 0.2844, screenX * 0.4631, screenY * 0.6822, tocolor(255, 255, 255, 255), 1, false)
    
    for _,cat in ipairs(animCategories) do
    	if cat[2] == true then
    		dxDrawText(cat[1], screenX * 0.3944, screenY * categoriesPos, screenX * 0.4612, screenY * (categoriesPos + 0.0350), tocolor(178, 233, 255, 255), 1.00, "default", "left", "center", false, false, false, false, false)
    	else
    		dxDrawText(cat[1], screenX * 0.3944, screenY * categoriesPos, screenX * 0.4612, screenY * (categoriesPos + 0.0350), tocolor(255, 255, 255, 255), 1.00, "default", "left", "center", false, false, false, false, false)
    	end
    	categoriesPos = categoriesPos + 0.0300
    end
    categoriesPos = 0.3000

    dxDrawText("Lista animacji", screenX * 0.3944, screenY * 0.2800, screenX * 0.4612, screenY * 0.3056, tocolor(255, 255, 255, 255), 1.00, "default", "left", "center", false, false, false, false, false)

	local found = false
	local firstAnim
	local countVisible = 0
	local count = 1
	for i, anims in ipairs(animListGlobal) do
		if anims[7] == animCategories[category_chosen][1] and countVisible <= 10 then
			if i >= chosenAnim then
				if not firstAnim then
					firstAnim = i
				end
				if chosenAnim == i then
					found = true
				end

				if chosenAnim == i then
					dxDrawRectangle(screenX * 0.4694, screenY * anim_startingPos, screenX * 0.08, 25, tocolor(255, 255, 255, 20), false)
				end

				dxDrawText(anims[1], screenX * 0.4694, screenY * anim_startingPos, screenX * 0.5450, screenY * (anim_startingPos + 0.02167), tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false)

				anim_startingPos = anim_startingPos + 0.0300
				countVisible = countVisible + 1
			end
			count = count + 1
		end
	end

	if not found then
		chosenAnim = firstAnim
	end

	anim_startingPos = 0.2900
	anim_startingPosbg = 0.2850

	dxDrawRectangle(screenX * 0.5531, screenY * 0.6787, screenX * 0.0380, screenY * 0.0231, tocolor(12, 77, 6, 254), false)
	dxDrawText("Ustaw", screenX * 0.5791, screenY * 0.6977, screenX * 0.5681, screenY * 0.6887, tocolor(255, 255, 255, 255), 1.00, "default", "center", "center", false, false, false, false, false)
end

local countAnims = 1
function animKey(button, pressed)
	if pressed == true and animListVisible then
		if button == "mouse_wheel_down" then
			if chosenAnim + 1 <= #animListGlobal and animListGlobal[chosenAnim + 1][7] == animCategories[category_chosen][1] then
				chosenAnim = chosenAnim + 1
				if countAnims < 10 then
					countAnims = countAnims + 1
				end
			end
		elseif button == "mouse_wheel_up" then
			if chosenAnim - 1 >= 1 and animListGlobal[chosenAnim - 1][7] == animCategories[category_chosen][1] then
				chosenAnim = chosenAnim - 1
				if countAnims >= 1 then
					countAnims = countAnims - 1
				end
			end
		end
	end
end

function isCursorOnElement(x,y,w,h)
	local mx,my = getCursorPosition()
	local fullx,fully = guiGetScreenSize()

	cursorx, cursory = mx * fullx, my * fully

	if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
		return true
	else
		return false
	end
end

function onClickedAnim(button, state, x, y)
	if animListVisible and state == "up" then
		local cat_startPos = 0.3000
		for i,cat in ipairs(animCategories) do
			local width, height = dxGetTextWidth(cat[1]), dxGetFontHeight()
			if isCursorOnElement(screenX * 0.3900, screenY * cat_startPos, width, height + 20) then
				for _,cat2 in ipairs(animCategories) do
					cat2[2] = false
				end
				animCategories[i][2] = true
				category_chosen = i
				countAnims = 1
				chosenAnim = 0
			end
			cat_startPos = cat_startPos + 0.0300
		end

		if chosenAnim and isCursorOnElement(screenX * 0.5531, screenY * 0.6787, screenX * 0.0380, screenY * 0.0231) then
			triggerServerEvent( "setPlayerAnim", localPlayer, chosenAnim )
			showAnimationsHandler(animListGlobal)
		end
	end
end

addEventHandler( "onClientKey", root, animKey )

function showAnimationsHandler(animList)
	if not animListVisible then
		animListVisible = true
		animListGlobal = animList
		showCursor( true )
		addEventHandler("onClientRender", root, renderAnimList)
		addEventHandler( "onClientClick", root, onClickedAnim )
	else
		removeEventHandler( "onClientRender", root, renderAnimList)
		removeEventHandler( "onClientClick", root, onClickedAnim )
	
		animListVisible = false
		showCursor( false )
	end
end
addEvent( "showAnimationsList", true )
addEventHandler( "showAnimationsList", localPlayer, showAnimationsHandler )