local smoke = {}

function smoke.eat()
	if not objectData[source].smoke then return end
	setPedAnimation( source, "gangs", "smkcig_prtl", 3000, false, true, false, false )

	if objectData[source].smoke['drug'] then
		objectData[source].smoke['bite'] = objectData[source].smoke['bite'] + 1
		
		if objectData[source].smoke['bite'] == objectData[source].smoke['maxBite'] then
			if objectData[source].smoke['drug'] == 1 then
				setElementData( source, "player:drugUse", 1)

				if getElementData(source, "player:drugLevel") < 15 and getElementData(source, "player:drugLevel") > 0 then 
					setElementData( source, "player:health", getElementData( source, "player:maxHealth") + 15)
				end
				setTimer( smoke.put, 3000, 1, source)
			elseif objectData[source].smoke['drug'] == 2 then
				setElementData( source, "player:drugUse", 2)

				if getElementData(source, "player:drugLevel") < 40 and getElementData(source, "player:drugLevel") > 15 then 
					setElementData( source, "player:health", getElementData( source, "player:maxHealth") + 25)
				end
				setTimer( smoke.put, 3000, 1, source)
			end
		end
	end
end

addEvent( "eatSmoke", true )
addEventHandler( "eatSmoke", root, smoke.eat )

function smoke.put(playerid)
	destroyElement( objectData[playerid].smoke['objectid'] )
	if isTimer( objectData[playerid].smoke['timer'] ) then
		killTimer( objectData[playerid].smoke['timer'] )
	end

	objectData[playerid].smoke = nil
	triggerClientEvent( 'endSmoke', playerid )
	toggleControl( playerid, "fire", true )
	setPedAnimation( playerid )
	setPedAnimation( playerid )
end

addEvent( "putSmoke", true)
addEventHandler( "putSmoke", root, smoke.put )

function smoke.drugEnd()
	if getElementData( source, "player:health") > getElementData( source, "player:maxHealth" ) then
		setElementData( source, "player:health", getElementData( source, "player:maxHealth"))
	end

	removeElementData( source, "player:drugUse" )
end

addEvent( 'drugEnd', true)
addEventHandler( 'drugEnd', root, smoke.drugEnd )