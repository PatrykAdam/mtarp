local disc = {}

function disc.burn(itemid, name, url)
	if not itemsData[itemid] then return end

	if itemsData[itemid].ownerID == getElementData(source, "player:id") and itemsData[itemid].ownerType == 1 then
		itemsData[itemid].name = name
		itemsData[itemid].value1 = 1
		saveItem(itemid, 'other')
		exports.sarp_mysql:mysql_change("INSERT INTO `sarp_disc` SET `url` = ?, `itemid` = ?", url, itemid)
		exports.sarp_notify:addNotify(source, "Twoja płyta została wypalona!")
	end
end

addEvent("discBurn", true)
addEventHandler( "discBurn", root, disc.burn )