function bitAND(a, b)
	a = tonumber(a)
	b = tonumber(b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function wordBreak(text, textWidth, remHTML, scale, font)
	if not scale then scale = 1.0 end
	if not font then font = 'default' end

	textWidth = math['floor'](textWidth)
	if remHTML then
		local HTMLcode = string.find(text, "#")
		while HTMLcode ~= nil do
			for i = HTMLcode, HTMLcode + 6 do
				local letter = string.sub(text, i, i)
				if letter == '' or letter == ' ' or HTMLcode + 6 == i then
					local first = string.sub(text, 1, HTMLcode - 1)
					text = string.format("%s%s", first, string.sub(text, i + 1))
					break
				end
			end
		end
	end

	local i = 1
	local space = 0
	local lastSpace = 0
	local num = 0
	while i <= string.len(text) do
		local letter = string.sub(text, i, i)

		if letter == ' ' then
			space = i
		end

		if letter == '#' then
			for j = i, i + 6 do
				local html = string.sub(text, j, j)
				if html == '' or html == ' ' or i + 6 == j then
					num = num + dxGetTextWidth( string.sub(text, i, j), scale, font )
					i = j
					space = i
					break
				end
			end
		end
		if dxGetTextWidth( string.sub(text, lastSpace, i), scale, font ) > textWidth + num then
			local isSpace = false
			if space > lastSpace and i > space then
				isSpace = space
			end

			if isSpace then
				local first = string.sub(text, 1, isSpace)
				text = string.format("%s\n%s", first, string.sub(text, isSpace + 1))
				lastSpace = isSpace + 2
			else
				local first = string.sub(text, 1, i)
				text = string.format("%s\n%s", first, string.sub(text, i))
				lastSpace = i + 2
			end
			num = 0
		end
		i = i + 1
	end
	local _, spaceCount = string.gsub(text, "\n", "\n")
	return text, spaceCount
end

function getPlayerRealName(playerid)
	local name
	if getElementData( playerid, "admin:duty") then
		name = getElementData( playerid, "global:name" )
	elseif type(getElementData( playerid, "player:mask")) == 'string' then
		name = "Nieznajomy "..getElementData( playerid, "player:mask")
	else
		name = getElementData(playerid, "player:username")
	end
	return name
end
