--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local dashboard = {}
dashboard.follow = {}

function dashboard.getInfo()
	local data = {}
	
	data.vehicles = exports.sarp_vehicles:getPlayerVehicles(source)
	data.follow = dashboard.follow[source]

	for i, v in ipairs(dashboard.follow[source]) do
		fetchRemote( "http://localhost/niktniewie/uploads/"..v.pp_main_photo, function(new, info, playerid)

			triggerClientEvent( playerid, "dashboard:avatar", root, {index = i, image = new} )
		end, "", false, source)
	end

	triggerClientEvent( "dashboard:open", source, data)
end

addEvent('dashboard:getInfo', true)
addEventHandler( 'dashboard:getInfo', root, dashboard.getInfo )

function dashboard.loadFollow()
	dashboard.follow[source] = exports.sarp_mysql:mysql_result("SELECT m.`pp_main_photo`, m.`member_id` FROM `core_members` m, `core_follow` f WHERE f.`follow_member_id` = ? AND f.`follow_rel_id` = m.`member_id`", getElementData(source, "global:id"))
	for i, v in ipairs(dashboard.follow[source]) do
		local isOnline = exports.sarp_mysql:mysql_result("SELECT `online`, `name`, `surname` FROM `sarp_characters` WHERE `global_id` = ? AND `online` = 1 LIMIT 1", v.member_id)

		if #isOnline > 0 then
			dashboard.follow[source][i].username = isOnline[1].name.." "..isOnline[1].surname
			isOnline = true
		else
			isOnline = false
		end

		dashboard.follow[source][i].online = isOnline
	end

	for i, v in pairs(dashboard.follow) do
		for j, g in ipairs(dashboard.follow[i]) do
			if g.member_id == getElementData(source, "global_id") then
				dashboard.follow[i][j].online = true
			end
		end
	end
end

addEvent('loadPlayerFollow', true)
addEventHandler( 'loadPlayerFollow', root, dashboard.loadFollow )

function dashboard.onStart()
	for i, v in ipairs(getElementsByType( "player" )) do
		triggerEvent('loadPlayerFollow', v)
	end
end

addEventHandler( "onResourceStart", root, dashboard.onStart )

function dashboard.onQuit()
	for i, v in pairs(dashboard.follow) do
		for j, g in ipairs(dashboard.follow[i]) do
			if g.member_id == getElementData(source, "global_id") then
				dashboard.follow[i][j].online = false
			end
		end
	end

	if dashboard.follow[source] then
		dashboard.follow[source] = nil
	end
end

addEventHandler( "onPlayerQuit", root, dashboard.onQuit )

function dashboard.setOption(option, value)
	if type(value) ~= 'boolean' then return end

	if option == 1 then
		setElementData(source, "radar:gtaV", value)
	elseif option == 2 then
		setElementData(source, "chatOOC", value)
	elseif option == 3 then
		setElementData( source, "blockPW", value)
	end
end

addEvent('setGraphicOption', true)
addEventHandler( "setGraphicOption", root, dashboard.setOption )