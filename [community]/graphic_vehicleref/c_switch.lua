function switchCarPaintReflect( cprOn )
	if cprOn then
		startCarPaintReflect()
	else
		stopCarPaintReflect()
	end
end

addEvent( "switchCarPaintReflect", true )
addEventHandler( "switchCarPaintReflect", root, switchCarPaintReflect )
