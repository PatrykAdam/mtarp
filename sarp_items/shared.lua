--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

itemsType = {
	'Broń',
 	'Jedzenie',
 	'Megafon',
 	'Kostka',
 	'Zegarek',
 	'Maska',
 	'Ubranie',
 	'Papierosy',
 	'Część tuningowa',
 	'Amunicja',
 	'Alkohol',
 	'Kanister',
 	'Płyta CD',
 	'Boombox',
 	'MP3',
}

function getItemName(type)
	if itemsType[type] then
		return itemsType[type]
	end
	return false
end