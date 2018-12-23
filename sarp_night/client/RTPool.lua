screen = Vector2( guiGetScreenSize(  ) )
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused(x, y)
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.x == x and info.y == y then
			info.bInUse = true
			return rt
		end
	end
	outputDebugString( "creating new RT " .. tostring(x) .. " x " .. tostring(y) )
	local rt = dxCreateRenderTarget( x, y )
	if rt then
		RTPool.list[rt] = { bInUse = true, x = x, y = y }
	end
	return rt
end

function RTPool.clear()
	for rt,info in pairs(RTPool.list) do
		destroyElement(rt)
	end
	RTPool.list = {}
end