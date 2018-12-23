--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local function endaj()
	if getElementData(source, 'player:aj') == 0 then
		local x, y, z, rotation, interior, dimension = exports.sarp_main:getSpawnPosition( source )

		setElementPosition( source, x, y, z )
		setElementRotation( source, 0, 0, rotation )
		setElementInterior( source, interior )
		setElementDimension( source, dimension )
		exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `aj` = ? WHERE `player_id` = ?", 0, getElementData(source, 'player:id'))
	end
end

addEvent("player:endaj", true)
addEventHandler( "player:endaj", root, endaj )