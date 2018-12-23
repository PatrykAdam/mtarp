local boombox = {}

function boombox.use(disc, itemid)
	local url = exports.sarp_mysql:mysql_result("SELECT `url` FROM `sarp_disc` WHERE `itemid` = ?", disc)[1].url
	if url and isItemOwner(source, itemid) and isItemOwner(source, disc) then
		itemsData[itemid].used = true
		local object = createObject( 2226, 0, 0, 0 )
		objectData[source].boombox = {itemid = itemid, objectid = object, url = url}
		setElementCollisionsEnabled(object, false)
		exports["bone_attach"]:attachElementToBone(object, source, 12, 0, 0, 0.39, 0, 180, 0)

		triggerClientEvent( "boomboxStart", source, url)
		exports.sarp_notify:addNotify(source, "Boombox został odpalony.")
	end
end

addEvent("boomboxPlayer", true)
addEventHandler( "boomboxPlayer", root, boombox.use )

function boombox.playerQuit()
	local boombox = objectData[source].boombox
	if boombox then
		itemsData[boombox.itemid].used = false

		if isElement( boombox['objectid'] ) then
			destroyElement( boombox['objectid'] )
			objectData[source].boombox = nil
		end
		triggerClientEvent( "boomboxStop", source )
	end
end

addEventHandler( "onPlayerQuit", root, boombox.playerQuit )