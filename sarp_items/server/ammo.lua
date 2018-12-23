local ammo = {}
ammo.timer = {}

function ammo.save(weaponID)
	if source ~= client then return end

	for i, v in pairs(itemsData) do
		if isItemOwner(source, v.id) and v.type == 1 and v.value1 == weaponID and v.used then
			v.value2 = v.value2 - 1

			if v.value2 <= 0 then
				takeWeapon( source, v.value1 )
				v.used = false

				if v.type == 1 then
					if isItemHandgun(v.value1) then
						setElementData( source, "weapon:handgun", false )
					else
						setElementData(source, "weapon:long", false)
					end
				end
			end

			if isTimer( ammo.timer[source] ) then
				killTimer( ammo.timer[source] )
			end

			ammo.timer[source] = setTimer(function(value2, id)
				exports.sarp_mysql:mysql_change("UPDATE `sarp_items` SET `value2` = ? WHERE `id` = ?", value2, id)
			end, 20000, 1, v.value2, v.id)
		end
	end
end

addEvent("saveAmmo", true)
addEventHandler( "saveAmmo", root, ammo.save )

function loadAmmo(weaponid, magazineid)
	weaponid = tonumber(weaponid)
	magazineid = tonumber(magazineid)
	if itemsData[weaponid].value1 == itemsData[magazineid].value1 then
		if itemsData[weaponid].used == true then
			return exports.sarp_notify:addNotify(source, "Ta broń jest aktualnie w użyciu.")
		end
		itemsData[weaponid].value2 = itemsData[weaponid].value2 + itemsData[magazineid].value2
		triggerEvent( "main:me", source, string.format("przeładowuje %s.", itemsData[weaponid].name))
		saveItem(weaponid, 'other')
		deleteItem(magazineid)

		-- refreshujemy liste przedmiotów
		triggerEvent( "onItemsUpdate", root, source )
	end
end
addEvent("loadWeaponAmmo", true)
addEventHandler( "loadWeaponAmmo", root, loadAmmo )