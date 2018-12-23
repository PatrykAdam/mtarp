local smoke = {}
smoke.lastTick = 0

function smoke.onKey(button, press)
	if press == true then
		if button == "mouse1" then
			if smoke.lastTick + 3000 < getTickCount() then
				toggleControl( "fire", false )
				triggerServerEvent( "eatSmoke", localPlayer )
				smoke.lastTick = getTickCount()
			end
		end
		if button == "mouse2" then
			triggerServerEvent( "putSmoke", localPlayer, localPlayer )
		end
	end
end

function smoke.stopUse()
	removeEventHandler( "onClientKey", root, smoke.onKey)
end

addEvent('endSmoke', true)
addEventHandler( 'endSmoke', localPlayer, smoke.stopUse )

function smoke.use()
	addEventHandler( "onClientKey", root, smoke.onKey)
end

addEvent("useSmoke", true)
addEventHandler( "useSmoke", localPlayer, smoke.use ) 