--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local door = {}

function door.save(id, name, description, garage, entry)
	local element = getDoorElement(id)
	if isElement(element) and isDoorOwner(source, element, true) then
		setElementData(element, "doors:name", name)
		setElementData(element, "doors:description", description)
		setElementData(element, "doors:garage", garage and 1 or 0)
		setElementData(element, "doors:entry", math.floor(entry))

		saveDoor(id, 'other')
		exports.sarp_notify:addNotify(source, "Ustawienia drzwi zostały zapisane.")
	end
end

addEvent( 'saveDoor', true)
addEventHandler( 'saveDoor', root, door.save)

function door.savePos(id)
	local element = getDoorElement(id)
	if isElement(element) and isDoorOwner(source, element, true) then
		local playerDoor = getElementData(source, "player:door")
		if not isElement(playerDoor) or playerDoor ~= element then
			return exports.sarp_notify:addNotify(source, "Nie znajdujesz się w odpowiednich drzwiach.")
		end

		local pX, pY, pZ = getElementPosition( source )
		setElementPosition( getElementData( element, "doors:parent"), pX, pY, pZ )
		setElementData( getElementData( element, "doors:exitRot", getElementRotation( source )[3]))

		saveDoor(id, 'pos')
		exports.sarp_notify:addNotify(source, "Pozycja wyjścia w drzwiach została zmieniona.")
	end
end

addEvent( 'saveDoorExit', true)
addEventHandler( 'saveDoorExit', root, door.savePos)

function door.buyObjects(id, count)
	local element = getDoorElement(id)
	if isElement(element) and isDoorOwner(source, element, true) then
		local playerDoor = getElementData(source, "player:door")
		if not playerDoor or playerDoor ~= element then
			return exports.sarp_notify:addNotify(source, "Nie znajdujesz się w odpowiednich drzwiach.")
		end

		local price = count * 200
		if getElementData(source, "player:money") < price then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz przy sobie odpowiedniej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(source, - price)
		setElementData( element, "doors:objects", getElementData( element, "doors:objects") + count)
		saveDoor(id, 'other')
		exports.sarp_notify:addNotify(source, string.format("Zakupiłeś %d obiektów do swojego budynku.", count))
	end
end

addEvent( 'buyDoorObjects', true)
addEventHandler( 'buyDoorObjects', root, door.buyObjects )

function door.access(mainID, uid)
	local element = getDoorElement(uid)

	if not isDoorOwner(source, element, true) then
			return exports.sarp_notify:addNotify(source, "Nie jesteś właścicielem tego budynku.")
		end

		setElementData(element, "doors:accessGroup", mainID)
		saveDoor(uid, 'owner')
		exports.sarp_notify:addNotify(source, string.format("Zmieniono udostępnianie budynku o UID %d.", uid))
end

addEvent("accessDoorDynamicGroup", true)
addEventHandler( "accessDoorDynamicGroup", root, door.access )

function lockDoor(playerid)
	local pDimension = getElementDimension( playerid )
	for i, v in ipairs(getElementsByType( "marker" )) do
		local dX, dY, dZ = getElementPosition( v )
		if getElementData( v, "type:doors") and getDistanceBetweenPoints3D( dX, dY, dZ, getElementPosition( playerid ) ) <= 1.0 and getElementDimension( v ) == getElementDimension( playerid ) and getElementInterior( v ) == getElementInterior( playerid ) then
			local element = getElementData( v, "doors:exit") and getElementData( v, "doors:parent") or v

			if not isDoorOwner(playerid, element, false) then
				return exports.sarp_notify:addNotify(playerid, "Nie posiadasz uprawnień do otwierania tych drzwi.")
			end

			if getElementData( element, "doors:lock") == 1 then
				setElementData(element, "doors:lock", 0)
				setMarkerColor( element, 0, 255, 0, 0 )
				exports.sarp_notify:addNotify(playerid, "Drzwi w budynku zostały otwarte.")
				setPedAnimation( playerid, "BD_Fire", "wash_up", 1200, false, false, false, false )
				saveDoor(getElementData( element, "doors:id"), 'pos')
			else
				setElementData(element, "doors:lock", 1)
				setMarkerColor( element, 255, 0, 0, 0)
				exports.sarp_notify:addNotify(playerid, "Drzwi w budynku zostały zamknięte.")
				setPedAnimation( playerid, "BD_Fire", "wash_up", 1200, false, false, false, false )
				saveDoor(getElementData( element, "doors:id"), 'pos')
			end
			break
		end
	end
end

addEvent( "door:lock", true)
addEventHandler( "door:lock", root, lockDoor)

function breakDoor( id )
	local element = getDoorElement(id)
	if isElement(element) then
		setElementData( element, "doors:lock", 0)
		exports.sarp_notify:addNotify(source, "Drzwi w budynku zostały wyważone.")
		saveDoor(id, 'pos')
	end
end

addEvent( "breakDoor")
addEventHandler( "breakDoor", root, breakDoor )

function buyDoorAudio( id )
	local element = getDoorElement(id)
	if isElement(element) and isDoorOwner(source, element, true) then
		local playerDoor = getElementData(source, "player:door")
		if not playerDoor or playerDoor ~= element then
			return exports.sarp_notify:addNotify(source, "Nie znajdujesz się w odpowiednich drzwiach.")
		end

		if haveDoorEquipment(id, 1) then return end

		if getElementData(source, "player:money") < 2000 then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz przy sobie odpowiedniej ilości gotówki.")
		end

		exports.sarp_main:givePlayerCash(source, - 2000)
		setElementData( element, "doors:url", '')
		setElementData( element, "doors:equipment", getElementData( element, "doors:equipment") + 1)
		saveDoor(id, 'other')
		exports.sarp_notify:addNotify(source, "System audio został zakupiony do budynku.")
	end
end

addEvent('buyDoorAudio', true)
addEventHandler( 'buyDoorAudio', root, buyDoorAudio )

function changeDoorURL(id, url)
	local element = getDoorElement(id)
	if isElement(element) and isDoorOwner(source, element, true) then
		local playerDoor = getElementData(source, "player:door")
		if not playerDoor or playerDoor ~= element then
			return exports.sarp_notify:addNotify(source, "Nie znajdujesz się w odpowiednich drzwiach.")
		end

		if not haveDoorEquipment(id, 1) then return end

		setElementData( element, "doors:url", url)
		saveDoor(id, 'other')
		for i, v in ipairs(getElementsByType( "player" )) do
			if getElementData(v, "player:door") == element then
				triggerClientEvent(v, "doorSound", v, url)
			end
		end
	end
end

addEvent('changeDoorURL', true)
addEventHandler( 'changeDoorURL', root, changeDoorURL )

--posession
local posession = {}

function posession.add(id, playerid)
	local element = getDoorElement(id)
	if not exports.sarp_main:isPlayerLogged(playerid) or not element then return end

	if not havePosessionPermission(source, id, 1) and not getElementData( element, "doors:ownerID") == getElementData(source, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień na dodawania ludzi do tej posiadłości.")
	end
	
	local query = exports.sarp_mysql:mysql_result("SELECT COUNT(*) AS isMember FROM `sarp_doors_members` WHERE `doorid` = ? AND `player_id` = ?", id, getElementData(playerid, "player:id"))

	if query[1].isMember > 0 then
		return exports.sarp_notify:addNotify(source, "Gracz o podanym ID posiada już klucze do tej posiadłości.")
	end

	if getElementData( element, "doors:ownerID") == getElementData(playerid, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie można zaprosić właściciela posiadłości.")
	end

	exports.sarp_mysql:mysql_change("INSERT INTO `sarp_doors_members` SET `player_id` = ?, `doorid` = ?", getElementData(playerid, "player:id"), id)
end

addEvent("posessionAdd", true)
addEventHandler( "posessionAdd", root, posession.add )

function posession.remove(id, playerid)
	local element = getDoorElement(id)
	if not exports.sarp_main:isPlayerLogged(playerid) or not element then return end

	if not havePosessionPermission(source, id, 1) and not getElementData( element, "doors:ownerID") == getElementData(source, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz uprawnień do wyrzucania ludzi z tej posiadłości.")
	end

	local query = exports.sarp_mysql:mysql_result("SELECT COUNT(*) AS isMember FROM `sarp_doors_members` WHERE `doorid` = ? AND `player_id` = ?", id, getElementData(playerid, "player:id"))

	if query[1].isMember == 0 and getElementData( element, "doors:ownerID") ~= getElementData(playerid, "player:id") then
		return exports.sarp_notify:addNotify(source, "Ten gracz nie posiada kluczy do tej posiadłości.")
	end

	if getElementData( element, "doors:ownerID") == getElementData(playerid, "player:id") then
		return exports.sarp_notify:addNotify(source, "Nie można wyrzucić właściciela z posiadłości.")
	end

	exports.sarp_mysql:mysql_change("DELETE FROM `sarp_doors_members` WHERE `player_id` = ? AND `doorid` = ?", getElementData(playerid, "player:id"), id)
end

addEvent("posessionRemove", true)
addEventHandler( "posessionRemove", root, posession.remove )