--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

--[[
 TYPY PRZEDMIOTÓW:	value1 | value2

 1 - BRONIE 		(id broni, amunicja)
 2 - JEDZENIE 		(nil, ilosć HP)
 3 - MEGAFON 		(nil, nil)
 4 - KOSTKA 		(nil, nil)
 5 - ZEGAREK 		(nil, nil)
 6 - MASKA 			(id grupy, nil)
 7 - UBRANIE 		(id skina, id grupy)
 8 - PAPIEROSY 		(nil, nil)
 9 - TUNING 		(rodzaj tuningu, wartość)
 10 - AMMO 			(id broni, ilość)
 11 - ALKOHOL 		()
 12 - KANISTER 		(ilosć, nil)
 13 - PŁYTA 		(nil, nil)
 14 - BOOMBOX 		(id płyty, nil)
 15 - MP3 			(nil, nil)
 16 - NARKOTYKI		()
]]

local items = {}

function items.playerUse(itemid)
	if not isItemOwner(source, itemid) then
		return exports.sarp_notify:addNotify(source, "Nie masz tego przedmiotu w ekwipunku.")
	end
	if getElementData(source, 'player:bw') > 0 then
		return exports.sarp_notify:addNotify(source, "Nie możesz tego zrobić podczas BW.")
	end

	if itemsData[itemid].flag ~= 0 and not exports.sarp_groups:isPlayerInGroup(source, itemsData[itemid].flag) then
		return exports.sarp_notify:addNotify(source, "Ten przedmiot jest oflagowany na grupę do której nie należysz.")
	end

	-- 1 - BRONIE 		(id broni, amunicja)
	if itemsData[itemid].type == 1 then
		if not itemsData[itemid].used then
			if itemsData[itemid].value2 == 0 and not noAmmo(itemsData[itemid].value1) then
				return exports.sarp_notify:addNotify(source, "Brak amunicji w broni.")
			end

			if isItemHandgun(itemsData[itemid].value1) then
				if getElementData(source, "weapon:handgun") then
					return exports.sarp_notify:addNotify(source, "Nie możesz wyciągnąć kolejnej broni krótkiej.")
				else
					setElementData(source, "weapon:handgun", itemsData[itemid].value1)
				end
			else
				if getElementData(source, "weapon:long") then
					return exports.sarp_notify:addNotify(source, "Nie możesz wyciągnąć kolejnej broni długiej.")
				else
					setElementData(source, "weapon:long", itemsData[itemid].value1)
				end
			end
			triggerEvent( "main:me", source, string.format("wyciąga %s.", itemsData[itemid].name))
			itemsData[itemid].used = true
			giveWeapon( source, itemsData[itemid].value1, itemsData[itemid].value2 )
		else
			if isItemHandgun(itemsData[itemid].value1) then
				setElementData( source, "weapon:handgun", false )
			else
				setElementData(source, "weapon:long", false)
			end
			triggerEvent( "main:me", source, string.format("chowa %s.", itemsData[itemid].name))
			itemsData[itemid].used = false
			takeWeapon( source, itemsData[itemid].value1 )
		end

	-- 2 - JEDZENIE 		(nil, ilosć HP)
	elseif itemsData[itemid].type == 2 then
		local object = createObject( 2880, 0, 0, 0)
		exports.bone_attach:attachElementToBone(object, source, 12, -0.1, 0.15, 0.1, 0, 0, -90)
		triggerClientEvent( "useFood", source )
		objectData[source].food = {playerid = source, addHealth = itemsData[itemid].value2, objectid = object, maxBite = 5, bite = 0}
		deleteItem(itemid)


	-- 3 - MEGAFON 		(nil, nil)
	elseif itemsData[itemid].type == 3 then
		triggerEvent( "main:me", source, itemsData[itemid].used and "chowa megafon." or "wyciąga megafon.")
		itemsData[itemid].used = not itemsData[itemid].used

	-- 4 - KOSTKA 		(nil, nil)
	elseif itemsData[itemid].type == 4 then
		triggerEvent( "main:me", source, string.format("rzuca kostką i wylosowuje %d oczek.", math.random(1, 6)))

	-- 5 - ZEGAREK 		(nil, nil)
	elseif itemsData[itemid].type == 5 then
		triggerEvent( "main:me", source, string.format("spogląda na zegarek marki %s.", itemsData[itemid].name))
		setPedAnimation( source, "COP_AMBIENT", "Coplook_watch", 2000, false, false, false, false )
		local hours, minutes = getTime()
		outputChatBox( string.format("Na zegarku widać godzinę %d:%d.", hours, minutes), source, 66, 134, 244 )

	-- 6 - MASKA 			(nil, nil)
	elseif itemsData[itemid].type == 6 then
		itemsData[itemid].used = not itemsData[itemid].used
		if itemsData[itemid].used then
			setElementData(source, "player:mask", generateCode(source))
		else
			setElementData(source, "player:mask", false)
		end

	-- 7 - UBRANIE 		(id skina, nil)
	elseif itemsData[itemid].type == 7 then

		itemsData[itemid].used = not itemsData[itemid].used
		if itemsData[itemid].used then
			setElementModel( source, itemsData[itemid].value1 )
		else
			setElementModel( source, getElementData( source, "player:skin" ))
		end

	-- 8 - PAPIEROSY 		(ilość sztuk, nil)
	elseif itemsData[itemid].type == 8 then
		local object = createObject( 1485, 0, 0, 0)
		exports.bone_attach:attachElementToBone(object, source, 12, -0.11,0.1,0.09,0,0,-40.11)
		triggerClientEvent( "useSmoke", source )
		objectData[source].smoke = {playerid = source, objectid = object, maxBite = itemsData[itemid].value1, bite = 0}
		itemsData[itemid].value1 = itemsData[itemid].value1 - 1

		if itemsData[itemid].value1 == 0 then
			deleteItem(itemid)
		end

	-- 9 - TUNING 		(rodzaj tuningu, wartość)
	elseif itemsData[itemid].type == 9 then
		exports.sarp_notify:addNotify(source, "Nie możesz użyć tego przedmiotu. Aby go zamontować odwiedź warsztat.")

	-- 10 - AMMO 			(id broni, ilość)
	elseif itemsData[itemid].type == 10 then
		-- Amunicja
		local weaponlist = getPlayerItemWeapons(source)

		local haveWeapon = false

		if type(weaponlist) == 'table' then
			for i, v in ipairs(weaponlist) do
				if v.value1 == itemsData[itemid].value1 then
					haveWeapon = true
				end
			end
		end

		if not haveWeapon then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz żadnej broni.")
		end

		triggerClientEvent( "showAvailableWeapons", source, itemid, weaponlist, itemsData[itemid].value1 )

	-- 11 - ALKOHOL 		()
	elseif itemsData[itemid].type == 11 then
		local object = createObject( 1486, 0, 0, 0)
		exports.bone_attach:attachElementToBone(object, source, 11, 0, 0.05, 0.1, 0, 90, 0)
		triggerClientEvent( "useAlcohol", source )
		objectData[source].alcohol = {playerid = source, objectid = object, timer = false, maxBite = itemsData[itemid].value1, bite = 0, percent = itemsData[itemid].value2}
		deleteItem(itemid)
	-- 12 - KANISTER 		(ilosć, nil)
	elseif itemsData[itemid].type == 12 then
		local vehid = getPedOccupiedVehicle( source )

		if not vehid then
			return exports.sarp_notify:addNotify(source, "Musisz znajdować się w pojeździe aby użyć tego przedmiotu.")
		end

		if getVehicleEngineState( vehid ) then
			return exports.sarp_notify:addNotify(source, "Musisz zgasić silnik aby wlać paliwa.")
		end

		if itemsData[itemid].value1 == 0 then
			return exports.sarp_notify:addNotify(source, "Kanister jest pusty!")
		end

		local vehicle, fuel = exports.sarp_vehicles, getElementData(vehid, "vehicle:fuel")
		if vehicle:getVehicleMaxFuel( getElementModel(vehid) ) < getElementData(vehid, "vehicle:fuel") + itemsData[itemid].value1 then
			exports.sarp_notify:addNotify(source, "W zbiornik pojazdu jest za dużo paliwa, dlatego nie możesz przelać paliwa z kanistra.")
		end

		setElementData(vehid, "vehicle:fuel", fuel + itemsData[itemid].value1)
		deleteItem(itemid)
		exports.sarp_notify:addNotify(source, "Paliwo zostało wlane do pojazdu.")
	
	-- 13 - PŁYTA 		(nil, nil)
	elseif itemsData[itemid].type == 13 then
		if itemsData[itemid].value1 ~= 0 then
			return exports.sarp_notify:addNotify(source, "Ta płyta jest już wypalona.")
		end

		triggerClientEvent( "discURL", source, itemid)
	
	-- 14 - BOOMBOX 		(id płyty, nil)
	elseif itemsData[itemid].type == 14 then
		if not itemsData[itemid].used then
			local disc = getPlayerDisc(source)
			if not disc then return exports.sarp_notify:addNotify(source, "Nie posiadasz żadnej płyty w ekwipunku.") end
			triggerClientEvent( source, "boomboxDisc", resourceRoot, disc, itemid)
		else
			itemsData[itemid].used = false
			exports.sarp_notify:addNotify(source, "Odtwarzanie muzyki z boomboxa zostało przerwane.")
			
			if isElement( objectData[source].boombox['objectid'] ) then
				destroyElement( objectData[source].boombox['objectid'] )
				objectData[source].boombox = nil
			end
			triggerClientEvent( "boomboxStop", source )
		end

	-- 15 - MP3 			(nil, nil)
	elseif itemsData[itemid].type == 15 then
		triggerClientEvent(source, "showPlayer", source )

	-- 16 NARKOTYKI			(typ, adaptacja)
	elseif itemsData[itemid].type == 16 then
		local drugLevel = getElementData(source, "player:drugLevel")

		if getElementData( source, "player:health") < 60 then
			return exports.sarp_notify:addNotify( source, "Posiadasz zbyt małą liczbę punktów życia aby zażyć narkotyk.")
		end

		if getElementData( source, "player:drugUse") then
			return exports.sarp_notify:addNotify( source, "Jesteś już pod pływem jakiegoś narkotyku.")
		end

		if itemsData[itemid].value1 == 1 then -- MARIHUANA
			local object = createObject( 1485, 0, 0, 0)
			exports.bone_attach:attachElementToBone(object, source, 12, -0.11,0.1,0.09,0,0,-40.11)
			triggerClientEvent( "useSmoke", source )
			objectData[source].smoke = {playerid = source, objectid = object, maxBite = 5, bite = 0, drug = 1}
		elseif itemsData[itemid].value1 == 2 then -- CRACK
			local object = createObject( 1485, 0, 0, 0)
			exports.bone_attach:attachElementToBone(object, source, 12, -0.11,0.1,0.09,0,0,-40.11)
			triggerClientEvent( "useSmoke", source )
			objectData[source].smoke = {playerid = source, objectid = object, maxBite = 5, bite = 0, drug = 2}
		elseif itemsData[itemid].value1 == 3 then -- METAMFETAMINA
			setElementData( source, "player:drugUse", 3)

			if getElementData(source, "player:drugLevel") < 55 and getElementData(source, "player:drugLevel") > 40 then 
				setElementData( source, "player:health", getElementData( source, "player:maxHealth") + 35)
			end
		elseif itemsData[itemid].value1 == 4 then -- AMFETAMINA
			setElementData( source, "player:drugUse", 4)

			if getElementData(source, "player:drugLevel") < 70 and getElementData(source, "player:drugLevel") > 55 then 
				setElementData( source, "player:health", getElementData( source, "player:maxHealth") + 50)
			end
		elseif itemsData[itemid].value1 == 5 then -- KOKAINA
			setElementData( source, "player:drugUse", 2)

			if getElementData(source, "player:drugLevel") < 100 and getElementData(source, "player:drugLevel") > 70 then 
				setElementData( source, "player:health", getElementData( source, "player:maxHealth") + 100)
			end
		end

		setElementData(source, "player:drugLevel", drugLevel + itemsData[itemid].value2)
	end

	--przeładowujemy przedmioty
	items.update(source)
end

addEvent('item:use', true)
addEventHandler( 'item:use', root, items.playerUse )

function items.onColShapeHit(hitElement, matchingDimension)
	if getElementType( hitElement ) == 'player' and matchingDimension then

	end
end

addEventHandler( "onColShapeHit", root, items.onColShapeHit )

function items.search(playerid)
	local item = {}

	local vehicle = getPedOccupiedVehicle( playerid )
	local vehUID = exports.sarp_vehicles:getVehicleUID( vehicle )
	
	if vehicle and not exports.sarp_vehicles:isVehicleOwner(playerid, vehUID, false) then
		return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do tego pojazdu lub nie jesteś jego właścicielem.")
	end
	for i, v in pairs(itemsData) do
		if itemsData[i] then
			local x, y, z = getElementPosition( playerid )
			if not vehicle and itemsData[i].ownerType == 0 and getDistanceBetweenPoints3D( itemsData[i].posX, itemsData[i].posY, itemsData[i].posZ, x, y, z) <= 3.0 and itemsData[i].dimension == getElementDimension( playerid ) and itemsData[i].interior == getElementInterior( playerid ) then
				table.insert(item, itemsData[i])
			elseif vehicle and itemsData[i].ownerType == 3 and itemsData[i].ownerID == vehUID and exports.sarp_vehicles:isVehicleOwner( playerid, vehUID ) then
				table.insert(item, itemsData[i])
			end
		end
	end
	if #item == 0 then return exports.sarp_notify:addNotify(playerid, "Nie znaleziono przedmiotów w okolicy.") end
	return triggerClientEvent( "items:search_result", playerid, item )
end

addEvent("items:search", true)
addEventHandler( "items:search", root, items.search )

function items.pick(item)
	if itemsData[item[1]].ownerType == 0 then
		if #item > 1 then
			triggerEvent( "main:me", source, "podnosi kilka przedmiotów z ziemi.")
		else
			triggerEvent( "main:me", source, "podnosi przedmiot z ziemi.")
		end

		for i, v in ipairs(item) do
			if itemsData[v].ownerType ~= 0 or getDistanceBetweenPoints3D( itemsData[v].posX, itemsData[v].posY, itemsData[v].posZ, getElementPosition( source ) ) >= 3.0 then return end

			if itemsData[v].objectid then
				triggerEvent( "objects:destroy", source, itemsData[v].objectid )
			end
			itemsData[v].lastupdate = getRealTime().timestamp
			itemsData[v].ownerType = 1
			itemsData[v].ownerID = getElementData(source, "player:id")
			saveItem(v, "owner")
		end

		setPedAnimation( source, "carry", "putdwn", 2000, false, false, false, false )
		setTimer(setPedAnimation, 2000, 1, source )
	elseif itemsData[item[1]].ownerType == 3 and isPedInVehicle( source ) then
		local vehicle = getPedOccupiedVehicle( source )
		local vehUID = exports.sarp_vehicles:getVehicleUID( vehicle )
		if vehicle and not exports.sarp_vehicles:isVehicleOwner(source, vehUID) then
			return exports.sarp_notify:addNotify("Nie posiadasz uprawnień do tego pojazdu lub nie jesteś jego właścicielem.")
		end

		if #item > 1 then
			triggerEvent( "main:me", source, string.format("podnosi kilka przedmiotów z pojazdu."))
		else
			triggerEvent( "main:me", source, string.format("podnosi przedmiot z pojazdu."))
		end

		for i, v in ipairs(item) do
			itemsData[v].ownerType = 1
			itemsData[v].ownerID = getElementData(source, "player:id")
			itemsData[v].lastupdate = getRealTime().timestamp
			saveItem(v, "owner")
		end

		setPedAnimation( source, "CAR_CHAT", "CAR_Sc4_FL", 3000, false, false, false, false )
		setTimer(setPedAnimation, 3000, 1, source )
	end
	items.update(source)
end

addEvent("items:searchpick", true)
addEventHandler( "items:searchpick", root, items.pick )

function items.put(itemid)
	--kiedy jest w pojeździe
	if itemsData[itemid].used then
		return exports.sarp_notify:addNotify(source, "Nie możesz odłożyć tego przedmiotu, gdyż jest on w użyciu.")
	end

	if not isPedOnGround( source ) and not isPedInVehicle( source ) then
		return exports.sarp_notify:addNotify(source, "Podczas odkładania przedmiotu nie możesz latać.")
	end

	if itemsData[itemid].ownerType ~= 1 or itemsData[itemid].ownerID ~= getElementData(source, "player:id") then return end
	itemsData[itemid].lastupdate = getRealTime().timestamp
	if isPedInVehicle( source ) then
		local vehicle = getPedOccupiedVehicle( source )
		itemsData[itemid].ownerID = exports.sarp_vehicles:getVehicleUID(vehicle)
		itemsData[itemid].ownerType = 3

		saveItem(itemid, 'owner')

		triggerEvent( "main:me", source, tostring("odkłada przedmiot do pojazdu."))
	else
		local pX, pY, pZ = getElementPosition( source )
		itemsData[itemid].ownerID = 0
		itemsData[itemid].ownerType = 0
		itemsData[itemid].posX = pX
		itemsData[itemid].posY = pY
		itemsData[itemid].posZ = pZ
		itemsData[itemid].dimension = getElementDimension( source )
		itemsData[itemid].interior = getElementInterior( source )

		local model, pX, pY, pZ, rX, rY, rZ = unpack(getItemWorldPosition(itemsData[itemid].type, itemsData[itemid].value1, pX, pY, pZ))
		itemsData[itemid].objectid = exports.sarp_objects:createNoEditableObject(model, pX, pY, pZ, rX, rY, rZ, itemsData[itemid].dimension, itemsData[itemid].interior)

		saveItem(itemid, 'owner')
		saveItem(itemid, 'pos')
		
		triggerEvent( "main:me", source, tostring("odkłada przedmiot na ziemię."))

		setPedAnimation( source, "carry", "putdwn", 2000, false, false, false, false )
		setTimer(setPedAnimation, 2000, 1, source )
	end
	items.update(source)
end

addEvent('item:put', true)
addEventHandler( 'item:put', root, items.put )

function items.update(playerid)
	local item = {}
	for i, v in pairs(itemsData) do
		if itemsData[i] and itemsData[i].ownerType == 1 and itemsData[i].ownerID == getElementData(playerid, "player:id") then
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

	if #item == 0 then
		triggerClientEvent( playerid, "onItemsShow", playerid )
	end

	return triggerClientEvent( "items:update", playerid, item )
end

addEvent( "onItemsUpdate", true )
addEventHandler( "onItemsUpdate", root, items.update )

function generateCode(playerid)
	local fullCode = string.sub(md5(getElementData(playerid, "player:id")), 1, 5)
	return fullCode
end

function items.clear()
	for i, v in pairs(itemsData) do
		if v.ownerType == 1 and v.ownerID == getElementData(source, "player:id") and v.used == true then
			v.used = false

			if v.type == 1 then
				if isItemHandgun(v.value1) then
					setElementData( source, "weapon:handgun", false )
				else
					setElementData(source, "weapon:long", false)
				end
			end

			items.update(source)
		end
	end
end

addEventHandler( "onPlayerWasted", root, items.clear )