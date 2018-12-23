--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

screenX, screenY = guiGetScreenSize()
scaleX, scaleY = (screenX / 1920), (screenY / 1080)

local stats = {}
stats.active = false

function stats.hide()
	removeEventHandler( "onClientGUIClick", stats.button, stats.hide )
	destroyElement( stats.window )
	showCursor( false )
	stats.active = false
end

function stats.onShow(playerid)
	if stats.active then return stats.hide() end
	stats.active = true
	showCursor( true )
	stats.column = {}
	stats.window = guiCreateWindow ( screenX/2 - 216, screenY/2 - 225, 432, 450, "Statystyki", false )
	guiWindowSetSizable ( stats.window, false )
	stats.gridlist = guiCreateGridList ( 0.0, 0.05, 1.0, 0.87, true, stats.window )
	guiGridListSetSelectionMode ( stats.gridlist, 0 )
	guiGridListAddColumn ( stats.gridlist, "Nazwa", 0.425 )
	guiGridListAddColumn ( stats.gridlist, "Wartość", 0.425 )
	stats.button = guiCreateButton ( 0.0, 0.93, 1.0, 0.07, "Zamknij", true, stats.window )

	stats.column[1] = {}
	stats.column[1].name = tostring("ID postaci:")
	stats.column[1].value = getElementData(playerid, "player:mtaID")
	stats.column[2] = {}
	stats.column[2].name = tostring("Imię i nazwisko:")
	stats.column[2].value = getElementData(playerid, "player:username")
	stats.column[3] = {}
	stats.column[3].name = tostring("UID postaci:")
	stats.column[3].value = getElementData(playerid, "player:id")
	stats.column[4] = {}
	stats.column[4].name = tostring("Czas gry:")
	stats.column[4].value = string.format("%dh %dmin", getElementData(playerid, "player:hours"), getElementData(playerid, "player:minutes"))
	stats.column[5] = {}
	stats.column[5].name = tostring("Dzisiaj online:")
	stats.column[5].value = string.format("%dh %dmin", getElementData(playerid, "player:online_today")/60, getElementData(playerid, "player:online_today") % 60)
	stats.column[6] = {}
	stats.column[6].name = tostring("Płeć:")
	stats.column[6].value = tostring((getElementData(playerid, "player:sex") and "Kobieta" or "Mężczyzna"))
	stats.column[7] = {}
	stats.column[7].name = tostring("Zdrowie:")
	stats.column[7].value = getElementHealth( playerid )
	stats.column[8] = {}
	stats.column[8].name = tostring("Kamizelka:")
	stats.column[8].value = getPedArmor( playerid )
	stats.column[9] = {}
	stats.column[9].name = tostring("Siła")
	stats.column[9].value = getElementData(playerid, "player:strength").."j"
	stats.column[10] = {}
	stats.column[10].name = tostring("Domyślny skin:")
	stats.column[10].value = getElementData(playerid, "player:skin")
	stats.column[11] = {}
	stats.column[11].name = tostring("Wiek:")
	stats.column[11].value = getElementData(playerid, "player:age") .. " lat"
	stats.column[12] = {}
	stats.column[12].name = tostring("Gotówka:")
	stats.column[12].value = getElementData(playerid, "player:money") .. "$"
	stats.column[13] = {}
	stats.column[13].name = tostring("Bank:")
	stats.column[13].value = getElementData(playerid, "player:bank") .. "$"
	stats.column[14] = {}
	stats.column[14].name = tostring("Grupa 1:")
	if getElementData(playerid, "group_1:id") then
		stats.column[14].value = string.format("%s (%d)", getElementData(playerid, "group_1:name"), getElementData(playerid, "group_1:id"))
	else
		stats.column[14].value = "Brak"
	end
	stats.column[15] = {}
	stats.column[15].name = tostring("Grupa 2:")
	if getElementData(playerid, "group_2:id") then
		stats.column[15].value = string.format("%s (%d)", getElementData(playerid, "group_2:name"), getElementData(playerid, "group_2:id"))
	else
		stats.column[15].value = "Brak"
	end	
	stats.column[16] = {}
	stats.column[16].name = tostring("Grupa 3:")
	if getElementData(playerid, "group_3:id") then
		stats.column[16].value = string.format("%s (%d)", getElementData(playerid, "group_3:name"), getElementData(playerid, "group_3:id"))
	else
		stats.column[16].value = "Brak"
	end
	stats.column[17] = {}
	stats.column[17].name = tostring("BW:")
	stats.column[17].value = (getElementData(playerid, "player:bw") > 0 and string.format("%d min", getElementData(playerid, "player:bw")/60) or tostring("Brak"))
	stats.column[18] = {}
	stats.column[18].name = tostring("Uprawnienia:")
	stats.column[18].value = getElementData(playerid, "global:flags")
	stats.column[19] = {}
	stats.column[19].name = tostring("")
	stats.column[19].value = tostring("")
	stats.column[20] = {}
	stats.column[20].name = tostring("")
	stats.column[20].value = tostring("")
	stats.column[21] = {}
	stats.column[21].name = tostring("Konto globalne:")
	stats.column[21].value = getElementData(playerid, "global:name")
	stats.column[22] = {}
	stats.column[22].name = tostring("GID konta:")
	stats.column[22].value = getElementData(playerid, "global:id")
	stats.column[23] = {}
	stats.column[23].name = tostring("Score:")
	stats.column[23].value = getElementData(playerid, "global:score")
	stats.column[24] = {}
	stats.column[24].name = tostring("Konto premium:")
	stats.column[24].value = "Brak"
	stats.column[25] = {}
	stats.column[25].name = tostring("AdminJail:")
	stats.column[25].value = (getElementData(playerid, "player:aj") > 0 and string.format("%d min %d sec", getElementData(playerid, "player:aj")/60, getElementData(playerid, "player:aj")%60) or tostring("Brak"))

	for i, v in ipairs(stats.column) do
		local row = guiGridListAddRow ( stats.gridlist )
		guiGridListSetItemText ( stats.gridlist, row, 1, stats.column[i].name, false, false )
		guiGridListSetItemText ( stats.gridlist, row, 2, stats.column[i].value, false, false )
	end
	addEventHandler ( "onClientGUIClick", stats.button, stats.hide, false )
end

addEvent('stats:show', true)
addEventHandler( 'stats:show', localPlayer, stats.onShow )