--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local event = {}
local gymData = {}

function event.buyClothes(id)
	local sex = getElementData(source, "player:sex") and "women" or "men"
	local skin, cash = getClothesID(id, sex), getClothesPrize(id, sex)

	setElementModel( source, getElementModel( source ) + 1 )
	setElementModel( source, getElementData(source, "player:lastskin") )
	if getPlayerMoney( source ) < cash then
		return exports.sarp_notify:addNotify(source, "Nie posiadasz wystarczającej ilości gotówki")
	end

	exports.sarp_main:givePlayerCash(source, - cash)
	exports.sarp_items:createItem(getElementData(source, "player:id"), 1, string.format("Ubranie (%d)", skin), 7, skin, 0, 0)
	exports.sarp_notify:addNotify(source, "Ubranie zostało zakupione oraz dodane do twojego ekwipunku")
end

addEvent('buyClothes', true)
addEventHandler( 'buyClothes', root, event.buyClothes )

function event.setPedAnimation(block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime, progress)
	setPedAnimation( source, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime )
	if type(progress) == 'number' then
		setTimer(triggerClientEvent, 50, 1, "setPedAnimationProgress", source, anim, progress)
	end
end

addEvent('setPedAnimation', true)
addEventHandler( 'setPedAnimation', root, event.setPedAnimation )

function event.attachWeight(type)
	local dimension, interior = getElementDimension( source ), getElementInterior( source )
	
	if type == 1 then
		local object = createObject( 2913, 0, 0, 0 )
		setElementInterior( object, interior )
		setElementDimension( object, dimension )
		gymData[source] = object
		exports.bone_attach:attachElementToBone(gymData[source],source, 12,-0.8,-0.02,0.1,6,87.4, 0.8)
	else
		local object = createObject( 2915, 0, 0, 0 )
		setElementInterior( object, interior )
		setElementDimension( object, dimension )
		gymData[source] = object
		exports.bone_attach:attachElementToBone(gymData[source],source, 12,0.47,0.0,0.05,0,0, -5)
	end
end

addEvent('attachWeight', true)
addEventHandler( 'attachWeight', root, event.attachWeight )

function event.detachWeight()
	if gymData[source] and isElement(gymData[source]) then
		exports.bone_attach:detachElementFromBone(gymData[source])
		destroyElement( gymData[source] )
	end
end

addEvent('detachWeight', true)
addEventHandler( 'detachWeight', root, event.detachWeight )

function event.addStrength()
	local doorid = getElementData(source, "player:door")

	if not doorid or not exports.sarp_doors:isDoorGroupType(doorid, 11) then
		return exports.sarp_notify:addNotify(source, "Wystąpił poważny błąd - zgłoś to Administracji.") -- xdd
	end

	exports.sarp_mysql:mysql_change("UPDATE `sarp_gym` SET `earnPoints` = `earnPoints` + 1 WHERE `group_id` = ? AND `player_id` = ? AND `date` > ? AND `type` = 1", exports.sarp_doors:getDoorData(doorid, "ownerID"), getElementData(source, "player:id"), getRealTime().timestamp - 84600)
	local query = exports.sarp_mysql:mysql_result("SELECT * FROM `sarp_gym` WHERE `group_id` = ? AND `player_id` = ? AND `date` > ? AND `type` = 1", exports.sarp_doors:getDoorData(doorid, "ownerID"), getElementData(source, "player:id"), getRealTime().timestamp - 84600)

	if query[1] and query[1].earnPoints > 6 then
		triggerClientEvent( "stopEarnStrength", source )
		removeElementData( source, "player:earnStrength" )
		return exports.sarp_notify:addNotify(source, "Limit ćwiczeń z karnetu został wykorzystany.")
	end

	local strength = getElementData(source, "player:strength")
	setElementData(source, "player:strength", strength + 1)
	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `strength` = ? WHERE `player_id` = ?", getElementData(source, "player:strength"), getElementData(source, "player:id"))
end

addEvent('addStrength', true)
addEventHandler( 'addStrength', root, event.addStrength)

function event.setSpawn(type, id)
	setElementData(source, "player:spawn", {type, id})
	exports.sarp_mysql:mysql_change("UPDATE `sarp_characters` SET `spawnType` = ?, `spawnID` = ? WHERE `player_id` = ?", type, id, getElementData(source, "player:id"))
	exports.sarp_notify:addNotify(source, "Miejsce spawnu zostało zmienione.")
end

addEvent('setSpawn', true)
addEventHandler( 'setSpawn', root, event.setSpawn )

local object = {}

function boneCreate(playerid, cmd)
	local dimension, interior = getElementDimension( playerid ), getElementInterior( playerid )
	object[playerid] = createObject( 1486, 0, 0, 0 )
	setElementInterior( object[playerid], interior )
	setElementDimension( object[playerid], dimension )
	triggerEvent("setPedAnimation", playerid, "vending", "vend_drink2_p", -1, false, false)
	exports.bone_attach:attachElementToBone(object[playerid],playerid, 11, 0, 0, 0, 0, 0, 0)
end

addCommandHandler( "stworz", boneCreate )

function boneX(playerid, cmd, add)
	local no, no, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object[playerid])
	x = x + add
	exports.bone_attach:setElementBonePositionOffset(object[playerid], x, y, z)
end

addCommandHandler( "bx", boneX )

function boneY(playerid, cmd, add)
	local no, no, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object[playerid])
	y = y + add
	exports.bone_attach:setElementBonePositionOffset(object[playerid], x, y, z)
end

addCommandHandler( "by", boneY )

function boneZ(playerid, cmd, add)
	local no, no, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object[playerid])
	z = z + add
	exports.bone_attach:setElementBonePositionOffset(object[playerid], x, y, z)
end

addCommandHandler( "bz", boneZ )

function boneRX(playerid, cmd, add)
	local no, no, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object[playerid])
	rx = rx + add
	exports.bone_attach:setElementBoneRotationOffset(object[playerid], rx, ry, rz)
end

addCommandHandler( "rx", boneRX )

function boneRY(playerid, cmd, add)
	local no, no, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object[playerid])
	ry = ry + add
	exports.bone_attach:setElementBoneRotationOffset(object[playerid], rx, ry, rz)
end

addCommandHandler( "ry", boneRY )

function boneRZ(playerid, cmd, add)
	local no, no, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object[playerid])
	rz = rz + add
	exports.bone_attach:setElementBoneRotationOffset(object[playerid], rx, ry, rz)
end

addCommandHandler( "rz", boneRZ )

function bonePOS(playerid, cmd, add)
	iprint(exports.bone_attach:getElementBoneAttachmentDetails(object[playerid]))
	
end

addCommandHandler( "bpos", bonePOS )