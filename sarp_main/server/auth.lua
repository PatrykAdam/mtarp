--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local avatar = {}

function checkLogin(name, password)
	local query = exports.sarp_mysql:mysql_result('SELECT `members_pass_salt`, `members_pass_hash`, `member_id`, `name`, `score`, `flags`, `premium` FROM `core_members` WHERE `name` = ?', name)

	if not query[1] then
		return triggerClientEvent("loginStatus", client, 'username')
	end
	local ban = exports.sarp_mysql:mysql_result('SELECT `value`, `serial` FROM `sarp_penalty` WHERE `type` = 4 and `global_id` = ?', query[1].member_id)
	if ban[1] and ban[1].value > getRealTime().timestamp then
		return triggerClientEvent("loginStatus", client, 'ban')
	end
	if ban[1] and ban[1].serial == getPlayerSerial(client) then
		return triggerClientEvent("loginStatus", client, 'serial')
	end

	if not (passwordVerify(password, query[1].members_pass_hash)) then
		return triggerClientEvent("loginStatus", client, 'password')
	end
	local query2 = exports.sarp_mysql:mysql_result('SELECT * FROM `sarp_characters` WHERE `block` = 0 and global_id = ?', query[1].member_id)

	if not query2[1] then
		return triggerClientEvent("loginStatus", client, 'nochar')
	end

	setElementData( client, "global:id", query[1].member_id)
	setElementData( client, "global:name", query[1].name)
	setElementData( client, "global:score", query[1].score)
	setElementData( client, "global:flags", query[1].flags)
	setElementData( client, "global:premium", query[1].premium)

	triggerEvent('loadPlayerFollow', client)


	--pobieramy range z forum i zapisujemy do gracza
	local query = exports.sarp_mysql:mysql_result('SELECT (SELECT word_default FROM core_sys_lang_words where word_key like CONCAT("%core_group_", g.g_id) LIMIT 1) as "ranga", g.prefix FROM core_members c INNER JOIN core_groups g ON c.member_group_id = g.g_id WHERE member_id = ?', query[1].member_id)

	if query[1] then
		setElementData(client, "global:rank", query[1].ranga)

		local color = query[1].prefix
		local change = {"<span style='color:", "'>", "<strong>", "<b>"}
		for i, v in ipairs(change) do
			color = string.gsub(color, v, "")
		end
		setElementData(client, "global:color", color)
	end

	return triggerClientEvent("loginStatus", client, 'success')
end 

addEvent('checkLogin', true)
addEventHandler('checkLogin', root, checkLogin)

function selectChar()
	local query = exports.sarp_mysql:mysql_result('SELECT * FROM `sarp_characters` WHERE `block` = 0 and global_id = ?', getElementData(client, "global:id"))
	
	if not query[1] then
		return
	end

	local characters = {}
	local maxchar
	for i, a in ipairs(query) do
		if not query[i].lastskin then
			query[i].lastskin = query[i].skin
		end

		query[i].groups = exports.sarp_mysql:mysql_result('SELECT COUNT(*) AS count FROM `sarp_group_member` WHERE `player_id` = ?', query[i].player_id)[1].count
		query[i].vehicles = exports.sarp_mysql:mysql_result('SELECT COUNT(*) AS count FROM `sarp_vehicles` WHERE `ownerID` = ? AND `ownerType` = 1', query[i].player_id)[1].count
		query[i].items = exports.sarp_mysql:mysql_result('SELECT COUNT(*) AS count FROM `sarp_items` WHERE `ownerID` = ? AND `ownerType` = 1', query[i].player_id)[1].count

		characters[i] = {id = query[i].player_id, skin = query[i].lastskin, username = query[i].name.. " ".. query[i].surname,
										 age = query[i].age, money = moneyFormat(query[i].money), sex = query[i].sex, hours = query[i].hours,
										 minutes = query[i].minutes, bank = moneyFormat(query[i].bank), hp = query[i].hp, groups = query[i].groups,
										 items = query[i].items, vehicles = query[i].vehicles}
	end
	triggerClientEvent( "showCharacters", client, characters)
end
addEvent("selectChar", true)
addEventHandler( "selectChar", root, selectChar )

function moneyFormat(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end