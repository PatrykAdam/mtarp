--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local sounds = {}
local resource = {"sarp_items", "sarp_doors"}

function sounds.onStart()
	for i, v in ipairs(resource) do
		local name = getResourceFromName( v )
		if name then
			restartResource( name )
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot, sounds.onStart )