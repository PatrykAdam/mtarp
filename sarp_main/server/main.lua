--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]
function onStart()
	--[[exports.sarp_mysql:mysql_create('sarp_characters', {'`player_id` INT AUTO_INCREMENT PRIMARY KEY',
													'`global_id` int NOT NULL',
												   '`skin` int NOT NULL',
												   '`lastskin` int NOT NULL',
												   '`name` varchar(16) NOT NULL',
												   '`surname` varchar(16) NOT NULL',
												   '`money` int NOT NULL',
												   '`bank` int NOT NULL',
												   '`posX` float NOT NULL',
												   '`posY` float NOT NULL',
												   '`posZ` float NOT NULL',
												   '`qs` bigint NOT NULL',
												   '`hp` float NOT NULL',
												   '`bw` int NOT NULL',
												   '`age` int NOT NULL',
												   '`sex` int NOT NULL',
												   '`hours` int NOT NULL',
												   '`minutes` int NOT NULL',
												   '`block` int DEFAULT 0',
												   '`walking` int DEFAULT 0',
												   '`aj` int NOT NULL',
												   '`online` int NOT NULL',
												   '`online_today` int NOT NULL',
												   '`last` int NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_vehicles', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
												 '`model` int NOT NULL',
												 '`ownerID` int NOT NULL',
												 '`ownerType` int NOT NULL',
												 '`posX` float NOT NULL',
												 '`posY` float NOT NULL',
												 '`posZ` float NOT NULL',
												 '`rotX` float NOT NULL',
												 '`rotY` float NOT NULL',
												 '`rotZ` float NOT NULL',
												 '`interior` int NOT NULL',
												 '`dimension` int NOT NULL',
												 '`hp` float DEFAULT 1000.0',
												 '`mileage` float NOT NULL',
												 '`panels` varchar(32) DEFAULT "0, 0, 0, 0, 0, 0, 0"',
												 '`doors` varchar(32) DEFAULT "0, 0, 0, 0, 0, 0"',
												 '`lights` varchar(32) DEFAULT "0, 0, 0, 0"',
												 '`wheels` varchar(32) DEFAULT "0, 0, 0, 0"',
												 '`color1` varchar(32) DEFAULT "0, 0, 0"',
												 '`color2` varchar(32) DEFAULT "0, 0, 0"',
												 '`plate` varchar(8) NOT NULL',
												 '`fuel` float NOT NULL',})

	exports.sarp_mysql:mysql_create('sarp_groups', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
												 '`name` varchar(64) NOT NULL',
												 '`tag` varchar(8) NOT NULL',
												 '`leader` int NOT NULL',
												 '`color` varchar(64) NOT NULL',
												 '`flags` int NOT NULL',
												 '`type` int NOT NULL',
												 '`bank` int NOT NULL',
												 '`payday` int NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_group_member', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`group_id` int NOT NULL',
														'`player_id` int NOT NULL',
														'`rank` varchar(16) NOT NULL',
														'`perm` int DEFAULT 0',
														'`skin` int DEFAULT -1',
														'`duty_time` int DEFAULT 0',
														'`payday` int NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_doors', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`posX` float NOT NULL',
														'`posY` float NOT NULL',
														'`posZ` float NOT NULL',
														'`posRot` float NOT NULL',
														'`interior` int NOT NULL',
														'`dimension` int NOT NULL',
														'`exitX` float NOT NULL',
														'`exitY` float NOT NULL',
														'`exitZ` float NOT NULL',
														'`exitRot` float NOT NULL',
														'`exitinterior` int NOT NULL',
														'`exitdimension` int NOT NULL',
														'`ownerType` int NOT NULL',
														'`ownerID` int NOT NULL',
														'`name` varchar(36) NOT NULL',
														'`description` varchar(64) NOT NULL',
														'`garage` int NOT NULL',
														'`lock` int NOT NULL',
														'`pickup` int NOT NULL',
														'`objects` int NOT NULL',
														'`entry` int NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_objects', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`ownerType` int NOT NULL',
														'`ownerID` int NOT NULL',
														'`model` int NOT NULL',
														'`posX` float NOT NULL',
														'`posY` float NOT NULL',
														'`posZ` float NOT NULL',
														'`rotX` float NOT NULL',
														'`rotY` float NOT NULL',
														'`rotZ` float NOT NULL',
														'`interior` int NOT NULL',
														'`dimension` int NOT NULL',
														'`gate` int NOT NULL',
														'`gateX` float NOT NULL',
														'`gateY` float NOT NULL',
														'`gateZ` float NOT NULL',
														'`gaterotX` float NOT NULL',
														'`gaterotY` float NOT NULL',
														'`gaterotZ` float NOT NULL',
														'`easing` int NOT NULL',
														'`texture` varchar(500)'})

	exports.sarp_mysql:mysql_create('sarp_penalty', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`player_id` int NOT NULL',
														'`global_id` int NOT NULL',
														'`type` int NOT NULL',
														'`value` bigint DEFAULT 0',
														'`date` bigint NOT NULL',
														'`admin` int NOT NULL',
														'`expired` bigint NOT NULL',
														'`serial` varchar(64) NOT NULL',
														'`reason` varchar(64) NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_items', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`ownerType` int NOT NULL',
														'`ownerID` int NOT NULL',
														'`name` varchar(64) NOT NULL',
														'`type` int NOT NULL',
														'`value1` int NOT NULL',
														'`value2` int NOT NULL',
														'`price` int NOT NULL',
														'`posX` float NOT NULL',
														'`posY` float NOT NULL',
														'`posZ` float NOT NULL',
														'`interior` int NOT NULL',
														'`dimension` int NOT NULL',
														'`flag` int NOT NULL',
														'`lastupdate` int NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_desc', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`char_id` int NOT NULL',
														'`title` varchar(64) NOT NULL',
														'`opis` varchar(256) NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_disc', {'`id` INT AUTO_INCREMENT PRIMARY KEY',
														'`url` varchar(64) NOT NULL',
														'`itemid` int NOT NULL'})

	exports.sarp_mysql:mysql_create('sarp_magazine', {'`uid` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY',
  '`groupid` int(11) NOT NULL',
  '`item_name` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL',
  '`item_value1` int(11) NOT NULL',
  '`item_value2` int(11) NOT NULL',
  '`item_type` int(11) NOT NULL',
  '`item_count` int(11) NOT NULL',
  '`price` int(11) NOT NULL'})

  exports.sarp_mysql:mysql_create('sarp_products', {'`uid` int(11) NOT NULL AUTO_INCREMENT  PRIMARY KEY',
  '`price` int(11) NOT NULL',
  '`grouptype` int(11) NOT NULL',
  '`type` int(11) NOT NULL',
  '`value1` int(11) NOT NULL',
  '`value2` int(11) NOT NULL',
  '`name` varchar(32)'})]]

	local realtime = getRealTime()
 
  setTime(realtime.hour, realtime.minute)
  setMinuteDuration(60000)
  setFPSLimit( 75 )
  setHeatHaze ( 0 )
  setFarClipDistance( 2000 )
  setMapName( "Los Santos" )
  setGameType( "MTA-RP.PL v.0.1" )
  setRuleValue("Gamemode", "mtarp")
  setRuleValue("WWW", "https://mta-rp.pl")

  for i, v in ipairs( getElementsByType( "player" )) do
  	setElementData(v, "player:logged", false)
  end
 removeWorldModel( 1297, 5, 1297, 1316, -1713, 15 )
end

addEventHandler( "onResourceStart", resourceRoot, onStart )

function securityEvent(name, old)
	if (name ~= 'objects:loading' and name ~= 'superman:takingOff' and name ~= 'superman:flying' and name ~='busTravel'
		and name ~= 'i:left' and name ~= 'i:right' and name ~= 'i:emergency' and name ~= 'lookAt' and name ~= 'drunkLevel' and name ~= 'chatWrite'
		and name ~= 'player:afk' and name ~= 'siren:state' and name ~= 'sirens:now' and name ~= 'turnSiren') and client then
		kickPlayer( client )
		-- restore the old data
		if isElement( source ) then
			if old == nil then
				removeElementData( source, name )
			else
				setElementData( source, name, old )
			end
		end
		cancelEvent()
	end
end
addEventHandler("onElementDataChange", root, securityEvent)
