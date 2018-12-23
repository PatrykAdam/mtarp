--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local MYSQL_HOST = "127.0.0.1"
local MYSQL_USER = "-"
local MYSQL_PASSWORD = "-"
local MYSQL_DATABASE = "-"

local MYSQL

local function connect()
	MYSQL = dbConnect( "mysql", "dbname="..MYSQL_DATABASE..";host="..MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, "share=1;charset=utf8" )

	if (not MYSQL) then
		outputServerLog( "Problem z polaczeniem bazy danych serwera - sprawdz konfiguracje" )
	else
		outputServerLog( "Prawidlowo polaczono z baza danych serwera." ) 
	end
end

addEventHandler( "onResourceStart", resourceRoot, connect )

function mysql_check(query)
	local result = dbQuery( MYSQL, query)
	if ( result ) then dbFree( result ) end
	return
end

function mysql_result(query, ...)
	if not {...} then return end
		dbExec( MYSQL,"SET NAMES utf8" )
    local query=dbQuery(MYSQL, dbPrepareString(MYSQL, query, unpack({...})))
    local result=dbPoll(query, -1) 
    dbFree( query )
    return result
end

function mysql_change(query, ...)
	dbExec( MYSQL,"SET NAMES utf8" )
	return dbExec( MYSQL, dbPrepareString(MYSQL, query, unpack({...})))
end

function mysql_create(name, ...)
	local names = {}
	local max = table.maxn(...)
	for key, a in pairs(...) do
		if not (key == max) then
			table.insert(names, a ..",")
		else
			table.insert(names, a)
		end
	end
	return dbExec(MYSQL, "CREATE TABLE IF NOT EXISTS `".. name .."` (".. table.concat(names, " ") ..")" )
end
