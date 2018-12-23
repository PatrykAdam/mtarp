--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

--[[
	FLAG_DEPARTMENT                 1 // Czat departamentowy
	FLAG_MEGAPHONE                  2 // Megafon
	FLAG_NICK                       4 // Kolorowy nick-name
	FLAG_OUT                        8 // Opuszczanie grupy
	FLAG_CASH                       16 // Wypłacanie gotówki z konta grupy
	FLAG_DB                         32 // Drive By
	FLAG_BLOCK                      64 // Stawianie blokad
	FLAG_DETENTION                  128 // Przetrzymywanie
	FLAG_ITEM                       256 // Zabieranie przedmiotów
	FLAG_CALL_911                   512 // Telefon alarmowy
	FLAG_REPORTS                    1024 // Zgłoszenia grupowe
	FLAG_GPS                        2048 // GPS w pojazdach
	FLAG_KOGUT                      4096 // Kogut

	PERM_INVITE         8192 // Zapraszanie ludzi
	PERM_WITHDRAW       4096 // Wyciąganie z magazynu
	PERM_ORDER          2048 // Zamawianie produktów
	PERM_OBJECTS        1024 // Tworzenie obiektów
	PERM_OOC            512 // Dostęp do czatu OOC
	PERM_VEH            128 // Dostęp do pojazdów
	PERM_DOOR           16    // Zarządzanie drzwiami
	PERM_AV             8    // Zarządzanie pojazdami
	PERM_P              1    // Zarządzanie pracownikami

	TYPY GRUP:
	1		Government
  2		Police
  3		Medical
  4		Gang
  5		Ściganci
  6		Mafia
  7		Gastronomia
  8		Taxi
  9		Workshop
  10		Ochrona
  11		Siłownia
  12 		News
  13		FBI
  14		Club
  15		Logistic
  16		Casino
  17		Lambard
  18		Family
  19		24/7
  20		Hotel
  21		Odzieżowy
	22		Bank

--]]

groupsData = {}
groupsLVL = {}
local groups = {}


function groups.load()
	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_groups`")

	for i, v in ipairs(query) do
		local id = query[i].id
		groupsData[id] = {}
		groupsData[id].id = id
		groupsData[id].name = query[i].name
		groupsData[id].leader = query[i].leader
		groupsData[id].tag = query[i].tag
		groupsData[id].color = split(query[i].color, ", ")
		groupsData[id].flags = query[i].flags
		groupsData[id].type = query[i].type
		groupsData[id].bank = query[i].bank
		groupsData[id].payday = query[i].payday
		groupsData[id].level = query[i].level
	end
	outputDebugString( "Wczytano ".. #query .." grup z bazy danych." )
end

addEventHandler( "onResourceStart", resourceRoot, groups.load )

function groups.loadLevels()
	local file = xmlLoadFile( ":sarp_groups/server/level.xml" )
	local groups = xmlNodeGetChildren( file )

	for i, v in ipairs(groups) do
		local id = tonumber(xmlNodeGetAttribute( v, "id" ))
		local levels = xmlNodeGetChildren( v )

		groupsLVL[id] = {}

		for i, v in ipairs(levels) do
			local levelID = tonumber(xmlNodeGetAttribute( v, "value" ))
			local attributes = xmlNodeGetChildren( v )

			groupsLVL[id][levelID] = {}

			for i, v in ipairs(attributes) do
				local name = xmlNodeGetName( v )
				groupsLVL[id][levelID][name] = xmlNodeGetValue( v )
			end
		end
	end

	outputDebugString( "Załadowano poziomy grup." )
end

addEventHandler( "onResourceStart", resourceRoot, groups.loadLevels )

function groups.onPlayerQuit()
	local interview = getElementData(source, "player:interview")
	if interview then
		local playerid = exports.sarp_main:getPlayerFromID(interview)

		if playerid then
			updateNewsMessage()
			removeElementData( playerid, "player:interview" )
			exports.sarp_notify:addNotify(playerid, "Wywiad został zakończony. Gracz opuścił serwer.")
		end
	end
end

addEventHandler( "onPlayerQuit", root, groups.onPlayerQuit )