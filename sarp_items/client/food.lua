local food = {}
food.lastTick = 0

function food.onKey(button, press)
	if press == true then
		if button == "mouse1" then
			if food.lastTick + 5000 < getTickCount() then
				toggleControl( "fire", false )
				triggerServerEvent( "eatFood", localPlayer )
				food.lastTick = getTickCount()
			end
		end
		if button == "mouse2" then
			triggerServerEvent( "putFood", localPlayer, localPlayer )
		end
	end
end

function food.stopUse()
	removeEventHandler( "onClientKey", root, food.onKey)
end

addEvent('endFood', true)
addEventHandler( 'endFood', localPlayer, food.stopUse )

function food.use()
	addEventHandler( "onClientKey", root, food.onKey)
end

addEvent("useFood", true)
addEventHandler( "useFood", localPlayer, food.use ) 