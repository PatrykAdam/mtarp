local alcohol = {}

function alcohol.eat()
	if not objectData[source].alcohol or objectData[source].alcohol['bite'] >= objectData[source].alcohol['maxBite'] then return end
	setPedAnimation( source, "vending", "vend_drink2_p", 1500, false, false, nil, false )

	objectData[source].alcohol['bite'] = objectData[source].alcohol['bite'] + 1

	local percent = (1 / objectData[source].alcohol['maxBite']) * objectData[source].alcohol['percent']
	setElementData(source, "drunkLevel", (getElementData(source, "drunkLevel") or 0) + percent)

	if objectData[source].alcohol['bite'] == objectData[source].alcohol['maxBite'] then
		setTimer( alcohol.put, 1000, 1, source)
	end
end

addEvent( "eatAlcohol", true )
addEventHandler( "eatAlcohol", root, alcohol.eat )

function alcohol.put(playerid)
	destroyElement( objectData[playerid].alcohol['objectid'] )
	if isTimer( objectData[playerid].alcohol['timer'] ) then
		killTimer( objectData[playerid].alcohol['timer'] )
	end

	objectData[playerid].alcohol = nil
	triggerClientEvent( 'endAlcohol', playerid )
	toggleControl( playerid, "fire", true )
	setTimer(setPedAnimation, 500, 1, playerid )
end

addEvent( "putAlcohol", true)
addEventHandler( "putAlcohol", root, alcohol.put )

function setDrunkWalkStyle()
	setPedWalkingStyle ( source, 126 )
end
addEvent ( "setDrunkWalkStyle", true )
addEventHandler ( "setDrunkWalkStyle", getRootElement(), setDrunkWalkStyle )

function FallDrunkAnimation(stop)
	if not stop then
		setPedAnimation( source, "GYMNASIUM", "gym_jog_falloff" )
	else
		setPedAnimation( source, false)
	end
end
addEvent ( "FallDrunkAnimation", true )
addEventHandler ( "FallDrunkAnimation", getRootElement(), FallDrunkAnimation )