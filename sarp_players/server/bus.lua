--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local bus = {}

function bus.buyTicket(price)
	if getElementData(source, "player:money") > price and price > 0 then
		exports.sarp_main:givePlayerCash(source, - price)
	end
end

addEvent('buyTicket', true)
addEventHandler( 'buyTicket', root, bus.buyTicket )