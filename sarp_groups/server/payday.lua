--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local payday = {}

function payday.run()
	local hour = getRealTime().hour

	if hour >= 4 and hour <= 6 then
		for i, v in ipairs(getElementsByType( "player" )) do
			kickPlayer( v, "Dzienny restart serwera!" )
		end

		exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `online_today` = 0")
		local payday = exports.sarp_mysql:mysql_result('SELECT * FROM `sarp_group_member`')

		for i, v in ipairs(payday) do
			local reward = 0

			if v.overtime == 0 then
				reward = (v.duty_time/30) >= 1 and v.payday or 0
			else
				local count = (v.duty_time/30)

				if count == 1 then
					reward = count * v.payday
				elseif count == 2 then
					reward = v.payday * 1.5
				elseif count == 3 then
					reward = v.payday * 1.75
				else
					reward = v.payday * (1.75 + (0.1 * (count - 3)))
				end
			end

			exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` c, `sarp_group_member` m SET c.`bank` = c.`bank` + ?, m.`duty_time` = 0, m.`overtime` = 0  WHERE c.`player_id` = ? AND m.`player_id` = ? AND m.`group_id` = ?", reward, v.player_id, v.player_id, v.group_id)
		end
	end
end

addEventHandler( "onResourceStop", root, payday.run )