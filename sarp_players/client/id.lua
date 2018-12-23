--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local id = {}
id.active = false

function id.hide()
	removeEventHandler( "onClientGUIClick", id.button, id.hide, false )
	showCursor( false )
	destroyElement( id.window )
	id.active = false
end

function id.update(playerList)
	guiGridListClear( id.gridlist )
	for i, v in ipairs(playerList) do
  	local row = guiGridListAddRow ( id.gridlist )
		guiGridListSetItemText ( id.gridlist, row, 1, v[1], false, false )
		guiGridListSetItemText ( id.gridlist, row, 2, v[2], false, false )
	end
end

function id.show(playerList)
	if id.active then return id.update(playerList) end
	id.active = true
	showCursor( true )
	id.window = guiCreateWindow((screenX - 284) / 2, (screenY - 274) / 2, 284, 274, "Wynik wyszukiwania", false)
  guiWindowSetSizable(id.window, false)

  id.gridlist = guiCreateGridList(0.03, 0.08, 0.93, 0.78, true, id.window)
  guiGridListAddColumn(id.gridlist, "ID", 0.2)
  guiGridListAddColumn(id.gridlist, "Imie i nazwisko", 0.6)
  id.button = guiCreateButton(0.04, 0.90, 0.92, 0.06, "Zamknij", true, id.window)

  addEventHandler ( "onClientGUIClick", id.button, id.hide, false )

  id.update(playerList)
end

function id.cmd(cmd, ...)
	local string = table.concat({...}, " ")

	if #string == 0 then
		return exports.sarp_notify:addNotify("Użyj: /id [id gracza lub nazwa]")
	end
	local isNumber = tonumber(string)

	local playerList = {}
	if isNumber then
		for i, v in ipairs( getElementsByType( "player" )) do
			if getElementData(v, "player:mtaID") == isNumber and not getElementData(v, "player:mask") and getElementData(v, "player:visible") == 0 then
				local id, username = getElementData(v, "player:mtaID"), getElementData(v, "player:username")
				table.insert(playerList, {id, username})
			end
		end
	else
		for i, v in ipairs( getElementsByType( "player" )) do
			if not getElementData(v, "player:mask") and string.find( getElementData(v, "player:username"):upper(), string:upper()) ~= nil and getElementData(v, "player:visible") == 0 then
				local id, username = getElementData(v, "player:mtaID"), getElementData(v, "player:username")
				table.insert(playerList, {id, username})
			end
		end
	end

	if #playerList == 0 then
		return exports.sarp_notify:addNotify("Nie znaleziono żadnego gracza.")
	end

	for i, v in ipairs(playerList) do
		id.show(playerList)
	end
end

addCommandHandler( "id", id.cmd )