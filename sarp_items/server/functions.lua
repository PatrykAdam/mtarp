function createItem(owner, ownerType, name, type, val1, val2, flag)
	local UID = 1
	for i, v in ipairs(itemsData) do
		UID = i + 1
		if not itemsData[i] then
			UID = i
			break
		end
	end
	itemsData[UID] = {}
	itemsData[UID].id = UID
	itemsData[UID].ownerType = ownerType
	itemsData[UID].ownerID = owner
	itemsData[UID].type = type
	itemsData[UID].value1 = val1
	itemsData[UID].value2 = val2
	itemsData[UID].flag = flag
	itemsData[UID].posX = 0
	itemsData[UID].posY = 0
	itemsData[UID].posZ = 0
	itemsData[UID].interior = 0
	itemsData[UID].dimension = 0
	itemsData[UID].used = false
	itemsData[UID].name = name
	itemsData[UID].lastupdate = getRealTime().timestamp
	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_items` SET `id` = ?, `ownerType` = ?, `ownerID` = ?, `type` = ?, `value1` = ?, `value2` = ?, `flag` = ?, `name` = ?, `lastupdate` = ?",
							itemsData[UID].id,
							itemsData[UID].ownerType,
							itemsData[UID].ownerID,
							itemsData[UID].type,
							itemsData[UID].value1,
							itemsData[UID].value2,
							itemsData[UID].flag,
							itemsData[UID].name,
							itemsData[UID].lastupdate)
	outputServerLog( "Utworzono przedmiot o UID: ".. UID )
end

function deleteItem(id)
	itemsData[id] = nil
	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_items` WHERE `id`= ?", id)
end

function saveItem(itemid, what)
	if what == 'owner' then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_items` SET `ownerID` = ?, `ownerType` = ?, `lastupdate` = ? WHERE `id` = ?",
							itemsData[itemid].ownerID,
							itemsData[itemid].ownerType,
							itemsData[itemid].lastupdate,
							itemid)
	elseif what == 'pos' then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_items` SET `posX` = ?, `posY` = ?, `posZ` = ?, `interior` = ?, `dimension` = ? WHERE `id` = ?",
							itemsData[itemid].posX,
							itemsData[itemid].posY,
							itemsData[itemid].posZ,
							itemsData[itemid].interior,
							itemsData[itemid].dimension,
							itemid)
	elseif what == 'other' then
		exports.sarp_mysql:mysql_change("UPDATE `sarp_items` SET `name` = ?, `type` = ?, `value1` = ?, `value2` = ? WHERE `id` = ?",
							itemsData[itemid].name,
							itemsData[itemid].type,
							itemsData[itemid].value1,
							itemsData[itemid].value2,
							itemid)
	end
end

function isItemOwner(playerid, itemid)
	if itemsData[itemid] and itemsData[itemid].ownerType == 1 and itemsData[itemid].ownerID == getElementData(playerid, "player:id") then
		return true
	end
	return false
end

function getItemsData(ownerType, ownerID)
	local items = {}
	for i, v in pairs(itemsData) do
		if v.ownerID == ownerID and v. ownerType == ownerType then
			table.insert(items, v)
		end
	end

	return items
end

function getItemData(id, data)
	if itemsData[id] then
		if type(data) == 'table' then
			local itemData = {}
			for i, v in ipairs(data) do
				itemData[v] = itemsData[id][v]
			end
			return itemData
		else
			return itemsData[id][data]
		end
	end
	return false
end

function setItemData(itemid, data, value, save)
	if itemsData[itemid] then
		if type(data) ~= 'table' then
			itemsData[itemid][data] = value
		else
			for i, v in pairs(data) do
				itemsData[itemid][i] = v
			end
		end
		saveItem(itemid, save)
		return true
	end
	return false
end

function isPlayerUseItem(playerid, type)
	for i, v in pairs(itemsData) do
		if v.used and v.type == type then
			return true
		end
	end
	return false
end

local handgunList = {0, 1, 2, 4, 8, 9, 10, 11, 12}

function isItemHandgun(weaponID)
	local slot = getSlotFromWeapon( weaponID )
	local isHandgun = false
	for i, v in ipairs(handgunList) do
		if slot == v then
			isHandgun = true
			break
		end
	end
	return isHandgun
end

function getPlayerItemWeapons(playerid)
	local weaponData = {}
	
	local id = getElementData(playerid, "player:id")
	for i, v in pairs(itemsData) do
		if v.ownerID == id and v.type == 1 and v.ownerType == 1 then
			table.insert(weaponData, v)
		end
	end

	if #weaponData == 0 then return false end

	return weaponData
end

function getPlayerBoneObjects(playerid)
	local objectList = {}
	if objectData[playerid] then
		for i, v in pairs(objectData[playerid]) do
			if v.objectid then
				table.insert(objectList, v.objectid)
			end
		end
		return objectList
	end
	return false
end


function getPlayerDisc(playerid)
	local discData = {}
	
	local id = getElementData(playerid, "player:id")
	for i, v in pairs(itemsData) do
		if v.ownerID == id and v.type == 13 and v.value1 == 1 then
			table.insert(discData, v)
		end
	end

	if #discData == 0 then return false end

	return discData
end

function noAmmo(weaponid)
	for i, v in ipairs({0, 1, 10, 11, 12}) do
		if getSlotFromWeapon( weaponid ) then
			return true
		end
	end
	return false
end

function getItemWorldPosition(type, value1, pX, pY, pZ, rX, rY, rZ)
	if type == 1 then
		if value1 == 1 then
			model = 331
		elseif value1 == 2 then
			model = 333
		elseif value1 == 3 then
			model = 334
		elseif value1 == 4 then
			model = 335
		elseif value1 == 5 then
			model = 336
		elseif value1 == 6 then
			model = 337
		elseif value1 == 7 then
			model = 338
		elseif value1 == 8 then
			model = 339
		elseif value1 == 9 then
			model = 341
		elseif value1 == 10 then
			model = 321
		elseif value1 == 11 then
			model = 322
		elseif value1 == 12 then
			model = 323
		elseif value1 == 14 then
			model = 325
		elseif value1 == 15 then
			model = 326
		elseif value1 == 16 then
			model = 342
		elseif value1 == 17 then
			model = 343
		elseif value1 == 18 then
			model = 344
		elseif value1 == 22 then
			model = 346
		elseif value1 == 23 then
			model = 347
		elseif value1 == 24 then
			model = 348
		elseif value1 == 25 then
			model = 349
		elseif value1 == 26 then
			model = 350
		elseif value1 == 27 then
			model = 351
		elseif value1 == 28 then
			model = 352
		elseif value1 == 29 then
			model = 353
		elseif value1 == 30 then
			model = 355
		elseif value1 == 31 then
			model = 356
		elseif value1 == 32 then
			model = 372
		elseif value1 == 33 then
			model = 357
		elseif value1 == 34 then
			model = 358
		elseif value1 == 35 then
			model = 359
		elseif value1 == 36 then
			model = 360
		elseif value1 == 37 then
			model = 361
		elseif value1 == 38 then
			model = 362
		elseif value1 == 39 then
			model = 363
		elseif value1 == 40 then
			model = 364
		elseif value1 == 41 then
			model = 365
		elseif value1 == 42 then
			model = 366
		elseif value1 == 43 then
			model = 367
		elseif value1 == 44 then
			model = 368
		elseif value1 == 45 then
			model = 369
		elseif value1 == 46 then
			model = 371
		end
		return {model, pX + 0, pY + 0, pZ - 1, 98, 55, -21}
	elseif type == 2 then
		return {2672, pX + 0, pY + 0, pZ - 0.75, 0, 0, 90}
	elseif type == 5 then
		return {2710, pX + 0, pY + 0, pZ - 0.9, 0, 0, 0}
	elseif type == 7 then
		return {2843, pX + 0, pY + 0, pZ - 1.0, 0, 0, 0}
	elseif type == 11 then
		return {1486, pX + 0, pY + 0, pZ - 0.8, 0, 0, 0}
	elseif type == 12 then
		return {1650, pX + 0, pY + 0, pZ - 1.0, 90, 0, 0}
	elseif type == 13 then
		return {1960, pX + 0, pY + 0, pZ - 1.0, 90, 0, 0}
	elseif type == 14 then
		return {2226, pX + 0, pY + 0, pZ - 1.0, 0, 0, 0}
	else
		return {328, pX + 0, pY + 0, pZ - 1, 90, 0, 0}
	end
end