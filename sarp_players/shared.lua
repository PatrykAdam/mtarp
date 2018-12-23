--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local skinsList = {
	women = {
	{105, 150},
	{135, 150},
	{136, 150}
	},
	men = {
	{153, 150},
	{124, 150},
	{154, 150}
	}
}

function getClothesPrize(id, sex)
	if skinsList[sex][id] then
		return skinsList[sex][id][2]
	end
end

function getClothesID(id, sex)
	if skinsList[sex][id] then
		return skinsList[sex][id][1]
	end
end

function getClothesMAX(sex)
	return #skinsList[sex]
end