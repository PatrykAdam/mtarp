local boombox = {}
local boomboxData = {}
boombox.active = false

function boombox.discSubmit()
	local itemid = guiGridListGetSelectedItem( boombox.gridlist ) + 1
	if not boombox.disc[itemid] then return end

	triggerServerEvent( "boomboxPlayer", localPlayer, boombox.disc[itemid].id, boombox.itemid )
	boombox.discHide()
end

function boombox.discHide()
	showCursor( false )
	removeEventHandler ( "onClientGUIClick", boombox.button[1], boombox.discSubmit, false )
  removeEventHandler ( "onClientGUIClick", boombox.button[2], boombox.discHide, false )
  destroyElement( boombox.window )
  boombox.active = false
  boombox.disc = false
end

function boombox.chooseDisc(disc, itemid) 
	if boombox.active then return end
	boombox.disc = disc
	boombox.itemid = itemid
	boombox.active = true
	showCursor( true )
	boombox.window = guiCreateWindow((screenX - 312) / 2, (screenY - 324) / 2, 312, 324, "Wybierz płytę", false)
  guiWindowSetSizable(boombox.window, false)

  boombox.gridlist = guiCreateGridList(0.04, 0.09, 0.93, 0.80, true, boombox.window)
  guiGridListAddColumn(boombox.gridlist, "Nazwa przedmiotu", 0.9)
  boombox.button = {}
  boombox.button[1] = guiCreateButton(0.07, 0.91, 0.38, 0.06, "Zatwierdź", true, boombox.window)
  boombox.button[2] = guiCreateButton(0.55, 0.91, 0.38, 0.06, "Zamknij", true, boombox.window) 

  addEventHandler ( "onClientGUIClick", boombox.button[1], boombox.discSubmit, false )
  addEventHandler ( "onClientGUIClick", boombox.button[2], boombox.discHide, false )

  for i, v in ipairs(disc) do
  	local row = guiGridListAddRow ( boombox.gridlist )
		guiGridListSetItemText ( boombox.gridlist, row, 1, v.name, false, false )
	end

end

addEvent("boomboxDisc", true)
addEventHandler( "boomboxDisc", resourceRoot, boombox.chooseDisc )

function boombox.stop()
	if not boomboxData[source] then return end

	exports.sarp_sounds:destroy3DSound( boomboxData[source] )
end

addEvent("boomboxStop", true)
addEventHandler( "boomboxStop", root, boombox.stop )


function boombox.start(url)
	boomboxData[source] = exports.sarp_sounds:create3DSound( url, true, Vector3(getElementPosition( source )), nil, 20, 20, 1.0, source, 0, 0, nil)
end

addEvent("boomboxStart", true)
addEventHandler( "boomboxStart", root, boombox.start )