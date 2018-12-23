function switchWaterRef( wrOn )
	if (wrOn) then
		enableWaterRef()
	else
		disableWaterRef()
	end
end

addEvent( "switchWaterRef", true )
addEventHandler( "switchWaterRef", root, switchWaterRef )
