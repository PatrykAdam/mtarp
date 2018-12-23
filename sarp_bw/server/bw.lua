local bw = {}

function bw.endTime()
	local bwTime = getElementData(source, 'player:bw')
	local x, y, z = getElementPosition( source )
	spawnPlayer( source, x, y, z, 0, getElementModel( source ), getElementInterior( source ), getElementDimension( source ) )
	setElementHealth( source, 20 )
	setElementData( source, "player:health", 20)
	setCameraTarget( source, source )
end

addEvent("bw:endTime", true)
addEventHandler( "bw:endTime", root, bw.endTime )

function bw.startTime(time)
	local bwTime = getElementData(source, "player:bw")
	if bwTime > 0 then return end
	setElementData(source, "drunkLevel", 0)
	setElementData(source, 'player:bw', time)
	triggerClientEvent( source, "bwStart", resourceRoot )
end

addEvent('bw:startTime', true)
addEventHandler( 'bw:startTime', root, bw.startTime )

local function deathPlayer(reason)
	local bwTime = getElementData(source, "player:bw")

	if not bwTime or bwTime <= 0 then
		return exports.sarp_notify:addNotify(source, "Aby użyć tej komendy musisz być nieprzytomny.")
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `block` = 1 WHERE `player_id` = ?", getElementData(source, "player:id"))

	kickPlayer( source )
	--stworzenie ciała + wpis w logach z powodem
end

addEvent('deathPlayer', true)
addEventHandler( 'deathPlayer', root, deathPlayer )