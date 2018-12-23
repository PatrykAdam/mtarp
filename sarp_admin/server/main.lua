--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local main = {}

function main.onQuit()
	if getElementData(source, "admin:duty") then
		local time = (getRealTime().timestamp - getElementData(source, "admin:duty"))
		local minute, second = time / 60, time % 60
		if minute > 0 then
			exports.sarp_mysql:mysql_change("INSERT INTO `sarp_log` SET `log_date` = ?, `log_ip` = ?, `log_value` = ?, `log_type` = 5, `log_ownertype` = 1, `log_owner` = ?", getRealTime().timestamp, getPlayerIP( source ), minute, getElementData(source, "player:id"))
			exports.sarp_logs:createLog('adminDUTY', string.format('%s zszedł ze służby %sa. (%d min, %d sec)', getElementData(source, "global:name"), getElementData(source, "global:rank"), minute, second))
		end
	end
end

addEventHandler( "onPlayerQuit", root, main.onQuit )

function main.kickPlayer()
	kickPlayer( source )
end

addEvent('kickPlayer', true)
addEventHandler( 'kickPlayer', root, main.kickPlayer )