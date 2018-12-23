--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function interactionEvent(element, type)
	if type == 1 then
		if isVehicleLocked( element ) then
			return exports.sarp_notify:addNotify(source, "Pojazd jest zamknięty.")
		end

		if getVehicleDoorOpenRatio( element, 0 ) == 1 then
			setVehicleDoorOpenRatio( element, 0, 0, 2000 )
			exports.sarp_notify:addNotify(source, 'Maska w pojeździe została zamknięta.')
		else
			setVehicleDoorOpenRatio( element, 0, 1, 2000 )
			exports.sarp_notify:addNotify(source, 'Maska w pojeździe została otwarta.')
		end
	elseif type == 2 then
		if not exports.sarp_vehicles:isVehicleOwner(source, getElementData(element, 'vehicle:id'), false, false) then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz kluczyków do tego pojazdu.")
		end

		if isVehicleLocked( element ) then
			setVehicleLocked( element, false )
			exports.sarp_notify:addNotify(source, "Otworzyłeś pojazd za pomocą kluczyków.")
		else
			setVehicleLocked( element, true )
			exports.sarp_notify:addNotify(source, "Zamknąłeś pojazd za pomocą kluczyków.")
		end

		if not isPedInVehicle( source ) then
			setPedAnimation( source, "int_house", "wash_up", 1000, false, false, false, false )
			setTimer(setPedAnimation, 1000, 1, source )
		end
	elseif type == 3 then
			triggerEvent( "setVehicleEngineState", source, element, not getVehicleEngineState( element ) )
	elseif type == 4 then
		if getVehicleOverrideLights( element ) ~= 2 then
			setVehicleOverrideLights( element, 2 )
			exports.sarp_notify:addNotify(source, 'Światła w pojeździe zostały zapalone.')
		else
			setVehicleOverrideLights( element, 1 )
			exports.sarp_notify:addNotify(source, 'Światła w pojeździe zostały zgaszone.')
		end
	elseif type == 5 then
		if getVehicleDoorOpenRatio( element, 1 ) == 1 then
			setVehicleDoorOpenRatio( element, 1, 0, 2000 )
			exports.sarp_notify:addNotify(source, 'Bagaznik w pojeździe został zamknięty.')
		else
			setVehicleDoorOpenRatio( element, 1, 1, 2000 )
			exports.sarp_notify:addNotify(source, 'Bagaznik w pojeździe został otwarty.')
		end
	elseif type == 6 then
		if getElementData( element, "vehicle:window") then
			setElementData( element, "vehicle:window", false)
			exports.sarp_notify:addNotify(source, 'Okna w pojeździe zostały zamknięte.')
		else
			setElementData( element, "vehicle:window", true)
			exports.sarp_notify:addNotify(source, 'Okna w pojeździe zostały otwarte.')
		end
	elseif type == 7 then
		triggerClientEvent(source, "transactionShow", source, 3, element )
	elseif type == 8 then
		--event odnoszący się do systemu przedmiotów gdzie zostaną wykonane kolejne instrukcje
	elseif type == 9 then
		triggerEvent('cuffPlayer', source, source, element)
	elseif type == 10 then
		local itemsList = exports.sarp_items:getItemsData(1, tonumber(getElementData(element, "player:id")))

		triggerEvent( "main:me", source, string.format("przeszukuje gracza %s.", exports.sarp_main:getPlayerRealName(element)))
		if #itemsList == 0 then
			return exports.sarp_notify:addNotify(source, "Gracz o podanym ID nie posiada żadnego przedmiotu przy sobie.")
		end

		--wyświetlamy przedmioty w GUI
		triggerClientEvent( source, "searchElement", source, itemsList, element )
	elseif type == 11 then
		local bank = getElementData(source, "player:bank")
		exports.sarp_notify:addNotify(source, string.format("Stan konta: %d$", bank))
	elseif type == 12 then
		triggerClientEvent(source, "transactionShow", source, 1 )
	elseif type == 13 then
		triggerClientEvent(source, "transactionShow", source, 2 )
	elseif type == 14 then
		local itemsList = exports.sarp_items:getItemsData(3, getElementData(element, "vehicle:id"))

		triggerEvent( "main:me", source, "przeszukuje pojazd.")

		if #itemsList == 0 then
			return exports.sarp_notify:addNotify(source, "W pojeździe nie znaleziono żadnego przedmiotu.")
		end

		--wyświetlamy przedmioty w GUI
		triggerClientEvent( source, "searchElement", source, itemsList, element )
	elseif type == 15 then
		triggerEvent( "door:lock", source, source )
	elseif type == 16 then
		for i, v in ipairs( getElementsByType( "player" )) do
			if getElementData(v, "player:door") ~= false and getElementData(v, "player:door") == getElementData(element, "doors:id") then
				outputChatBox( "** Słychać pukanie do drzwi budynku. **", v, 150, 150, 200)
			end
		end
		triggerEvent( "main:me", source, "puka w drzwi." )
	elseif type == 17 then
		if not getElementData( element, "doors:lock" ) then
			return exports.sarp_notify:addNotify(source, "Drzwi w tym budynku są już otwarte!")
		end

		triggerEvent( "breakDoor", source, getElementData( element, "doors:id" ) )
		triggerEvent( "main:me", source, "wyważa drzwi." )
		setPedAnimation ( source, "POLICE", "Door_Kick", 1000, false, false, false, false )
		setTimer(setPedAnimation, 1500, 1, source )

	elseif type == 18 then
		triggerEvent('createOffer', source, source, element, 11, 0)
	elseif type == 19 then
		if getElementSpeed(element, 1) > 5 or isElementInWater(element) then
			return exports.sarp_notify:addNotify(source, 'Aby zaciągnąć ręczny musisz się zatrzymać.')
		end

		if getElementData( element, "vehicle:manual") then
			setElementData( element, "vehicle:manual", false)

			if getElementData(element, "vehicle:policeBlock") == 0 then
				setElementFrozen( element, false )
			end
			exports.sarp_notify:addNotify(source, 'Hamulec ręczny został odciągnięty.')
		else
			setElementData( element, "vehicle:manual", true)
			setElementFrozen( element, true )
			exports.sarp_notify:addNotify(source, 'Hamulec ręczny został zaciągnięty.')
		end
		triggerEvent( "setPlayerHandbrake", source, source, element )
	elseif type == 20 then
		triggerEvent( "objects:create", source,  1228, false)
	elseif type == 21 then
		triggerEvent( "objects:create", source,  1238, false)
	end
end

addEvent( "interactionEvent", true )
addEventHandler( "interactionEvent", root, interactionEvent )

function transactionSubmit(type, playerid, price)
	price = math.floor(price)

	if type == 1 then
		if price <= 0 or getElementData( source, "player:money" ) < price then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz tyle gotówki!")
		end

		setElementData( source, "player:money", getElementData( source, "player:money" ) - price )
		setElementData( source, "player:bank", getElementData(source, "player:bank") + price )
		triggerEvent( "savePlayer", source, source)
		exports.sarp_notify:addNotify(source, "Gotówki została wpłacona do banku.")
	elseif type == 2 then
		if price <= 0 or getElementData(source, "player:bank") < price then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz tyle gotówki!")
		end

		setElementData( source, "player:money", getElementData( source, "player:money" ) + price )
		setElementData( source, "player:bank", getElementData(source, "player:bank") - price )
		exports.sarp_notify:addNotify(source, "Wypłaciłeś pieniądze z bankomatu.")
		triggerEvent( "savePlayer", source, source)
	elseif type == 3 then
		if price <= 0 or getElementData( source, "player:money" ) < price then
			return exports.sarp_notify:addNotify(source, "Nie posiadasz tyle gotówki!")
		end

		setElementData( source, "player:money", getElementData( source, "player:money" ) - price )
		setElementData( playerid, "player:money", getElementData( playerid, "player:money" ) + price )
		triggerEvent( "savePlayer", source, source)
		triggerEvent( "savePlayer", playerid, playerid)
		exports.sarp_notify:addNotify(source, string.format("Przekazałeś pieniądze dla gracza %s.",exports.sarp_main:getPlayerRealName(playerid)))
		exports.sarp_notify:addNotify(playerid, string.format("Otrzymałeś pieniądze od gracza %s.",exports.sarp_main:getPlayerRealName(source)))
		triggerEvent("main:me", source, string.format("przekazuje gotówkę dla %s.", exports.sarp_main:getPlayerRealName(playerid)))
	end
end

addEvent( 'transactionSubmit', true)
addEventHandler( 'transactionSubmit', root, transactionSubmit )

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end