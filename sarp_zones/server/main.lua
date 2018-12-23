--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

--[[
	1 = gracz
	2 = grupa

	1 = stawianie obiektów
	2 = komenda /tankuj (stacja benzynowa)
	4 = zablokowanie boomboxów
	8 = gang uliczny (?)
	16 = używanie komend grupy

]]

local zones = {}

function zones.onStart()
	local query = exports.sarp_mysql:mysql_result( "SELECT * FROM `sarp_zones`" )

	for i, v in ipairs(query) do
		local element = createColCuboid( v.posX, v.posY, v.posZ, v.width, v.depth, v.height )
		setElementData(element, "isZone", true)
		setElementData(element, "zoneID", v.id)
		setElementData(element, "zoneOwnerType", v.ownerType)
		setElementData(element, "zoneOwner", v.ownerID)
		setElementData(element, "zonePermission", v.permission)
	end

	outputDebugString( string.format("Wczytano %d stref z bazy danych.", #query) )
end

addEventHandler( "onResourceStart", resourceRoot, zones.onStart )