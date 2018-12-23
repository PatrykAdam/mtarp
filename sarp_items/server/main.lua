--[[ 
	TYPY WŁAŚCICIELI PRZEDMIOTÓW:
	0 = ŚWIAT
	1 = GRACZ
	2 = GRUPA
	3 = POJAZD
	4 = TUNING POJAZDU


]]--

itemsData = {}
objectData = {}
local items = {}

function items.load()
	local count = 0
	local query = exports.sarp_mysql:mysql_result( "SELECT * FROM `sarp_items`" )

	for i, v in ipairs(query) do
		local id = query[i].id
		itemsData[id] = {}
		itemsData[id].id = id
		itemsData[id].ownerType = query[i].ownerType
		itemsData[id].ownerID = query[i].ownerID
		itemsData[id].type = query[i].type
		itemsData[id].value1 = query[i].value1
		itemsData[id].value2 = query[i].value2
		itemsData[id].posX = query[i].posX
		itemsData[id].posY = query[i].posY
		itemsData[id].posZ = query[i].posZ
		itemsData[id].interior = query[i].interior
		itemsData[id].dimension = query[i].dimension
		itemsData[id].used = false
		itemsData[id].name = query[i].name
		itemsData[id].flag = query[i].flag
		itemsData[id].lastupdate = query[i].lastupdate
		count = count + 1

		if itemsData[id].ownerType == 0 then
			local model, pX, pY, pZ, rX, rY, rZ = unpack(getItemWorldPosition(itemsData[id].type, itemsData[id].value1, itemsData[id].posX, itemsData[id].posY, itemsData[id].posZ))
			itemsData[id].objectid = exports.sarp_objects:createNoEditableObject(model, pX, pY, pZ, rX, rY, rZ, itemsData[id].dimension, itemsData[id].interior, -1, -1)
		end
	end

	for i, v in ipairs(getElementsByType( "player" )) do
		objectData[v] = {}
	end
	outputDebugString( "Wczytano ".. count .." przedmiotów z bazy danych." )
end

addEventHandler( "onResourceStart", resourceRoot, items.load )

function items.onJoin()
	objectData[source] = {}
end

addEventHandler( "onPlayerJoin", root, items.onJoin )

function items.quit()
	for i, v in ipairs(itemsData) do
		if v.ownerID == 0 and v.objectid then
			triggerEvent( "objects:destroy", source, v.objectid )
		end
	end

	for i, v in ipairs(getElementsByType( "player" )) do
		if getElementData(v, "weapon:handgun") then
			takeWeapon( v, getElementData(v, "weapon:handgun") )
		end

		if getElementData(v, "weapon:long") then
			takeWeapon( v, getElementData(v, "weapon:long") )
		end

		setElementData(v, "weapon:handgun", false)
		setElementData(v, "weapon:long", false)
		setElementData(v, "player:drugUse", false)
	end
end

addEventHandler( "onResourceStop", resourceRoot, items.quit )

function items.list()
	local item = {}
	for i, v in pairs(itemsData) do
		if itemsData[i] and itemsData[i].ownerType == 1 and itemsData[i].ownerID == getElementData(source, "player:id") then
			table.insert(item, itemsData[i])
		end
	end

	--sortowanie
	local ending = -1
	while ending ~= 0 do
		ending = 0
		for i = 1, #item -1 do
			if item[i].lastupdate > item[i + 1].lastupdate then
				local safe
				ending = ending + 1
				safe = item[i]
				item[i] = item[i + 1]
				item[i + 1] = safe
			end
		end
	end

	return triggerClientEvent( "showItems", source, item )
end

addEvent("items:list", true)
addEventHandler( "items:list", root, items.list )

function items.onQuit()
	if not exports.sarp_main:isPlayerLogged(source) then return end

	for i, v in pairs(itemsData) do
		if itemsData[i].ownerType == 1 and itemsData[i].ownerID == getElementData(source, "player:id") and itemsData[i].used then
			itemsData[i].used = false
		end
	end
end

addEventHandler( "onPlayerQuit", root, items.onQuit )