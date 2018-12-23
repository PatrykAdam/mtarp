
local animationsList = {}
local anim = {}
animationsList = {}

function loadAnimCommands()
	local count = 0
	for i, v in ipairs(animationsList) do
		addCommandHandler( v[1], function(playerid, cmd)
			anim.apply(playerid, v[2], v[3], v[4], v[5], v[6])
		end)
		count = count + 1
	end
	outputDebugString( string.format("Wczytano %d animacji (komend)", count) )
end

function anim.onStart()
	local count = 1
	local meta = xmlLoadFile("assets/animlist.xml")
	if meta then
    	local xmlNodes = xmlNodeGetChildren( meta )
	    for _,node in ipairs(xmlNodes) do 
	        local name = xmlNodeGetAttribute( node, "name" ) 
	        local block = xmlNodeGetAttribute( node, "block" )
	        local anim = xmlNodeGetAttribute( node, "anim" )
	        local time = xmlNodeGetAttribute( node, "duration" )
	        local loop = xmlNodeGetAttribute( node, "isLoop" )
	        local updatePos = xmlNodeGetAttribute( node, "upgradePos" )
	        local category = xmlNodeGetAttribute( node, "category" )
	        local id = xmlNodeGetAttribute( node, "id" )

	        animationsList[count] = {}
	        animationsList[count][1] = name
	        animationsList[count][2] = block
	        animationsList[count][3] = anim
	        animationsList[count][4] = time
	        if loop == 'false' then
	        	animationsList[count][5] = false
	        else
	        	animationsList[count][5] = true
	        end
	        if updatePos == 'false' then
	        	animationsList[count][6] = false
	        else
	        	animationsList[count][6] = true
	        end
	        animationsList[count][7] = category
	        animationsList[count][8] = id

	        count = count + 1
	    end 
	end
	xmlUnloadFile(meta)
	outputDebugString( string.format("Wczytano %d animacje.", count - 1) )
	loadAnimCommands()
end

addEventHandler( "onResourceStart", resourceRoot, anim.onStart )

function anim.stop(playerid)
	toggleAllControls(playerid, true, true, false)
	setPedAnimation(playerid)
	unbindKey( playerid, "space", "down", anim.stop )
	local pos = getElementData(playerid, "player:anim")
	setElementPosition( playerid,  pos[1], pos[2], pos[3])
	setElementData(playerid, "player:anim", false)
	setElementCollisionsEnabled( playerid, true )

end

function anim.apply(playerid, block, name, time, loop, updatePosition)
	if not exports.sarp_main:isPlayerLogged(playerid) then return end
	if isPedInVehicle( playerid ) then
		return exports.sarp_notify:addNotify(playerid, "Tej animacji nie można używać w pojeździe.")
	end

	if getElementData(playerid, "player:earnStrength") then
		return exports.sarp_notify:addNotify(playerid, "Nie możesz teraz używać animacji.")
	end
	toggleAllControls( playerid, false, true, false )
	
	setPedAnimation( playerid, block, name, time, loop, updatePosition, false )
	setElementCollisionsEnabled( playerid, false )
	if not isKeyBound( playerid, "space", "down", anim.stop ) then
		bindKey(playerid, "space", "down", anim.stop)
	end

	if not getElementData(playerid, "player:anim") then
		setElementData(playerid, "player:anim", {getElementPosition( playerid )})
	end
end

function animListHandler(playerid, cmd)
	triggerClientEvent( "showAnimationsList", playerid, animationsList )
end
addCommandHandler( "anim", animListHandler )


function onPlayerSetAnim( animid )
	anim.apply(source, animationsList[animid][2], animationsList[animid][3], animationsList[animid][4], animationsList[animid][5], animationsList[animid][6] )
end
addEvent( "setPlayerAnim", true )
addEventHandler( "setPlayerAnim", root, onPlayerSetAnim )