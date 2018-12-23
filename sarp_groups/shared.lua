--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local groupType = {}
groupType[1] = {name = 'Government'}
groupType[2] = {name = 'Police'}
groupType[3] = {name = 'Medical'}
groupType[4] = {name = 'Gang'}
groupType[5] = {name = 'Ściganci'}
groupType[6] = {name = 'Mafia'}
groupType[7] = {name = 'Gastronomia'}
groupType[8] = {name = 'Taxi'}
groupType[9] = {name = 'Workshop'}
groupType[10] = {name = 'Ochrona'}
groupType[11] = {name = 'Siłownia'}
groupType[12] = {name = 'News'}
groupType[13] = {name = 'FBI'}
groupType[14] = {name = 'Club'}
groupType[15] = {name = 'Logistic'}
groupType[16] = {name = 'Casino'}
groupType[17] = {name = 'Lambard'}
groupType[18] = {name = 'Family'}
groupType[19] = {name = 'Sklep'}
groupType[20] = {name = 'Hotel'}
groupType[21] = {name = 'Sklep odzieżowy'}
groupType[22] = {name = 'Bank'}

function getGroupType(type)
	if groupType[type] then
		return groupType[type].name
	end
end

function isPlayerInGroup(playerid, group)
	for i = 1, 3 do
		local groupid = getElementData(playerid, "group_"..i..":id")
		if groupid and groupid == group then
			return true
		end
	end
	return false
end