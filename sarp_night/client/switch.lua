--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

function switchNightShader(bool)
	if type(bool) ~= 'boolean' then bool = false end
	if bool then
		Night.func.enabled()
	else
		Night.func.disabled()
	end
end
addEvent( "switchNightShader", true )
addEventHandler( "switchNightShader", root, switchNightShader )