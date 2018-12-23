function handleOnClientSwitchDetail( bOn )
	if bOn then
		enableDetail()
	else
		disableDetail()
	end
end

addEvent( "onClientSwitchDetail", true )
addEventHandler( "onClientSwitchDetail", root, handleOnClientSwitchDetail )
