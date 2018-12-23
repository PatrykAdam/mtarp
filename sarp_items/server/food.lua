local food = {}

function food.eat()
	if not objectData[source].food or objectData[source].food['bite'] >= objectData[source].food['maxBite'] then return end

	setPedAnimation( source, "food", "EAT_Burger", 0, false, true, true, true )
	setElementHealth( source, getElementHealth( source ) + objectData[source].food['addHealth']/objectData[source].food['maxBite'] )
	objectData[source].food['bite'] = objectData[source].food['bite'] + 1

	if objectData[source].food['bite'] == objectData[source].food['maxBite'] then
		setTimer( food.put, 4000, 1, source)
	end
end

addEvent( "eatFood", true )
addEventHandler( "eatFood", root, food.eat )

function food.put(playerid)
	destroyElement( objectData[playerid].food['objectid'] )
	objectData[playerid].food = nil
	triggerClientEvent( 'endFood', playerid )
	toggleControl( playerid, "fire", true )
	setPedAnimation( playerid )
	setPedAnimation( playerid )
end

addEvent( "putFood", true)
addEventHandler( "putFood", root, food.put )