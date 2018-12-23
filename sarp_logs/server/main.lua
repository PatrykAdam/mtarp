--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local logs = {}
logs.waiting = {}
logs.inQuery = {}

function removeLog(id)
	logs.inQuery[id] = ''
end

function logResult(out)
	if type(out) == 'string' then
		return removeLog(out)
	end
end

function createLog(type, message, group)
	local id = 0

	for i, v in ipairs(logs.waiting) do
		id = i + 1
		if not logs.waiting[i] then
			id = i
			break
		end
	end

	local time = getRealTime()
	message = string.format("[%02d.%02d.%d %02d:%02d] %s", time.monthday, time.month, 1900 + time.year, time.hour, time.minute, message)

	table.insert(logs.waiting, {type = type, message = message})
end

setTimer(function()
	local resend = false
	for i, v in pairs(logs.inQuery) do
		if string.len(v) ~= 0 then
			callRemote("localhost/logs.php", logResult, i, v)
			resend = true
		end
	end

	if resend then return end

	while #logs.waiting ~= 0 do
		local type = logs.waiting[1].type
		for i, v in ipairs(logs.waiting) do
			if type == v.type then
				if logs.inQuery[type] == nil then
					logs.inQuery[type] = ''
				end

				if string.len(logs.inQuery[type]) + string.len(v.message) > 2000 then
					return
				end

				logs.inQuery[type] = string.format("%s%s\n", logs.inQuery[type], v.message)
				table.remove(logs.waiting, i)
			end
		end
		callRemote("localhost/logs.php", logResult, type, logs.inQuery[type])
	end
end, 2000, 0)