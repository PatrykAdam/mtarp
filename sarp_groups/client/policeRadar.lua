--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Dorian Nowakowski <burekssss3@gmail.com> 
				  Discord: Rick#0157

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

PoliceRadar = inherit(Singleton)

function PoliceRadar:constructor(...)
	return self:init(...)
end

function PoliceRadar:init(...)
	self.data = { rendering = {}, texture = {}, font = {}, show = false, vehicle }
    self.data.screen = Vector2( guiGetScreenSize(  ) )
    self.data.scale = Vector2( math.max(0.8, (self.data.screen.x / 1920)), math.max(0.8, (self.data.screen.y / 1080)) )    
    self.data.font.bold_up = dxCreateFont("assets/Lato-Bold.ttf", 15.0 * self.data.scale.x, false)
    self.data.font.bold_down = dxCreateFont("assets/Lato-Bold.ttf", 10.0 * self.data.scale.x, false)    
    self.data.rendering.screen = Vector2(self.data.screen.x/2, self.data.screen.y)
	
	local _, size = self:createTexture("assets/background.png")
	self.data.rendering.pos = {}
	self.data.rendering.text = {}
	self.data.rendering.pos["background"] = {w = size.x * self.data.scale.x, h = size.y * self.data.scale.y, x = self.data.screen.x/2 - (size.x/2 * self.data.scale.x),  y = self.data.screen.y - (size.y * self.data.scale.y) }
	self.data.rendering.pos["numberPlate"] = {x = self.data.rendering.pos["background"].x + (220*self.data.scale.x), y = self.data.rendering.pos["background"].y + (24*self.data.scale.y) }
	self.data.rendering.pos["speed"] = {x = self.data.rendering.pos["numberPlate"].x + (245*self.data.scale.x), y = self.data.rendering.pos["numberPlate"].y - (3.0*self.data.scale.y) }
	
	self.data.rendering.pos["owner"] = {x = self.data.rendering.pos["background"].x + (165*self.data.scale.x), y = self.data.rendering.pos["background"].y + (52*self.data.scale.y) }
	self.data.rendering.pos["wanted"] = {x = self.data.rendering.pos["owner"].x + (280*self.data.scale.x), y = self.data.rendering.pos["owner"].y - (3.0*self.data.scale.y) }


	self.data.rendering.pos["policeOfficer"] = {x = self.data.rendering.pos["background"].x + (110*self.data.scale.x), y = ( self.data.rendering.pos["background"].y + self.data.rendering.pos["background"].h ) - (15.0*self.data.scale.y)  }
	self.data.rendering.pos["policeVehicle"] = {x = self.data.rendering.pos["policeOfficer"].x + (180*self.data.scale.x), y = self.data.rendering.pos["policeOfficer"].y  }
	self.data.rendering.pos["dateTime"] = {x = self.data.rendering.pos["policeVehicle"].x + (155*self.data.scale.x), y = self.data.rendering.pos["policeVehicle"].y  }

	self.onClientRender = bind(PoliceRadar.onClientRender, self);
end

function PoliceRadar:setElement(...)
	self.data.element = arg[1]
end

function PoliceRadar:getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function PoliceRadar:createTexture(...)
	if not self.data.texture[arg[1]] then
		self.data.texture[arg[1]] = dxCreateTexture(arg[1])
	end
	local size = Vector2( dxGetMaterialSize( self.data.texture[arg[1]] ) )
	return self.data.texture[arg[1]], size
end

function PoliceRadar:toggle()
	if self.data.show then
		self.targetVehicle = nil
		self.data.speed = nil
		self.data.update = false
		self.data.lastTime = false
		removeEventHandler("onClientRender", getRootElement(), self.onClientRender);
	else
		addEventHandler("onClientRender", getRootElement(), self.onClientRender);
	end
	self.data.show = not self.data.show
	return self.data.show
end

function PoliceRadar:getColission()
	local x1, y1, z1, x2, y2, z2 = getElementBoundingBox( self.data.element )
	local matrix = self.data.element:getMatrix()
	local position = matrix:getPosition()
	local newMatrix = matrix:transformPosition(Vector3(0.0, (y2-y1)+20.0, 0))
	local newMatrix2 = matrix:transformPosition(Vector3(x2-x1, 0, 0))
	local tab = self:drawDirBend(position:getX(), position:getY(), newMatrix2.x, newMatrix2.y, newMatrix2.z, newMatrix.x, newMatrix.y, newMatrix.z, false)
	if tab and isElement(tab[5]) then
		return tab[5]
	end
	local newMatrix = matrix:transformPosition(Vector3(0.0, (y2-y1)+20.0, 0))
	local newMatrix2 = matrix:transformPosition(Vector3(x1-x2, 0, 0))
	local tab = self:drawDirBend(position:getX(), position:getY(), newMatrix2.x, newMatrix2.y, newMatrix2.z, newMatrix.x, newMatrix.y, newMatrix.z, false)
	if tab and isElement(tab[5]) then
		return tab[5]
	end
end

function PoliceRadar:drawDirBend(...)
	local tempTab = {}
	local matrixForward = (arg[5]+arg[8])*0.5
	if arg[9] then
		dxDrawLine3D(arg[1],arg[2],matrixForward,arg[3],arg[4],arg[5], tocolor(0,0,255,255) )
	end
	arg[3], arg[4], arg[5] = arg[3]-arg[1],arg[4]-arg[2],arg[5]-matrixForward
	arg[6], arg[7], arg[8] = arg[6]-arg[1],arg[7]-arg[2],arg[8]-matrixForward
	local delta = math.pi*0.125*0.125
	for i = 0,math.pi*0.5-delta*0.5,delta do
		local sin_a0,cos_a0 = math.sin(i),math.cos(i)
		local sin_a1,cos_a1 = math.sin(i+delta),math.cos(i+delta)
		local pathClear = isLineOfSightClear (arg[1]+sin_a0*arg[3]+cos_a0*arg[6],arg[2]+sin_a0*arg[4]+cos_a0*arg[7],matrixForward+sin_a0*arg[5]+cos_a0*arg[8],arg[1]+sin_a1*arg[3]+cos_a1*arg[6],arg[2]+sin_a1*arg[4]+cos_a1*arg[7],matrixForward+sin_a1*arg[5]+cos_a1*arg[8], false, true, false, false, false, false, false, self.data.element)
		if not pathClear then
			tempTab[#tempTab+1] = { processLineOfSight(arg[1]+sin_a0*arg[3]+cos_a0*arg[6],arg[2]+sin_a0*arg[4]+cos_a0*arg[7],matrixForward+sin_a0*arg[5]+cos_a0*arg[8],arg[1]+sin_a1*arg[3]+cos_a1*arg[6],arg[2]+sin_a1*arg[4]+cos_a1*arg[7],matrixForward+sin_a1*arg[5]+cos_a1*arg[8], false, true, false, false, false, false, false, false, self.data.element, false) }
		end
		if arg[9] then
			dxDrawLine3D(arg[1]+sin_a0*arg[3]+cos_a0*arg[6],arg[2]+sin_a0*arg[4]+cos_a0*arg[7],matrixForward+sin_a0*arg[5]+cos_a0*arg[8],arg[1]+sin_a1*arg[3]+cos_a1*arg[6],arg[2]+sin_a1*arg[4]+cos_a1*arg[7],matrixForward+sin_a1*arg[5]+cos_a1*arg[8], (pathClear == true and tocolor(255,0,0,255) or tocolor(255,175,0,255) ) )
		end
	end
	if #tempTab == 1 then
		return tempTab[1]
	else
		return false
	end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function PoliceRadar:clear()
	self.targetVehicle = nil
	self.data.speed = nil
	self.data.update = false
	self.data.lastTime = false
	removeEventHandler("onClientRender", getRootElement(), self.onClientRender);
end

function PoliceRadar:onClientRender()
	if not isElement( self.data.element ) or getPedOccupiedVehicle( localPlayer ) ~= self.data.element then
		self:toggle()
		return
	end
	local veh = self:getColission()
	if not self.targetVehicle or (veh ~= self.targetVehicle and isElement(veh) ) then
		self.targetVehicle = veh
	end
	local time = getRealTime( )
	local texture = self:createTexture("assets/background.png")
	dxDrawImage(self.data.rendering.pos["background"].x, self.data.rendering.pos["background"].y, self.data.rendering.pos["background"].w, self.data.rendering.pos["background"].h, texture)
	if isElement(self.targetVehicle) or self.data.rendering.text and self.data.rendering.text.plate ~= nil then
		if self.data.lastTime and self.data.lastTime + 10000 < getTickCount() then
			return PoliceRadar:clear()
		end
		if getDistanceBetweenPoints3D( Vector3( getElementPosition( self.targetVehicle ) ), Vector3( getElementPosition( self.data.element ) ) ) < 20.0 then
			self.data.rendering.textplate = getVehiclePlateText( self.targetVehicle )
			self.data.rendering.text.speed = round( PoliceRadar:getElementSpeed(self.targetVehicle, "km/h") ).." KM/H"
			self.data.rendering.text.owner = getElementData(self.targetVehicle, "vehicle:ownerName") or "--"
			self.data.lastTime = getTickCount()
		end
		local text = self.data.rendering.textplate or 'Brak'
		local height = dxGetFontHeight( 1.0, self.data.font.bold_up )
		self.data.rendering.pos["numberPlate"].w = dxGetTextWidth( text )
		dxDrawText( text, self.data.rendering.pos["numberPlate"].x, self.data.rendering.pos["numberPlate"].y, self.data.rendering.pos["numberPlate"].w, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_up )
		local text = self.data.rendering.text.speed
		local height = dxGetFontHeight( 1.0, self.data.font.bold_up )
		self.data.rendering.pos["speed"].w = dxGetTextWidth( text )
		dxDrawText( text, self.data.rendering.pos["speed"].x, self.data.rendering.pos["speed"].y, self.data.rendering.pos["speed"].w, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_up )
		local text = self.data.rendering.text.owner
		local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
		self.data.rendering.pos["owner"].w = dxGetTextWidth( text )
		dxDrawText( text, self.data.rendering.pos["owner"].x, self.data.rendering.pos["owner"].y, self.data.rendering.pos["owner"].w, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_down )
		
		local text = getElementData(self.targetVehicle, "wanted") == true and "Tak" or "Nie"
		local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
		self.data.rendering.pos["wanted"].w = dxGetTextWidth( text )
		dxDrawText( text, self.data.rendering.pos["wanted"].x, self.data.rendering.pos["wanted"].y, self.data.rendering.pos["wanted"].w, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_down )
	end
	local text = getElementData(localPlayer, "player:username"):gsub("_","")
	local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
	self.data.rendering.pos["policeOfficer"].w = dxGetTextWidth( text )
	dxDrawText( text, self.data.rendering.pos["policeOfficer"].x, self.data.rendering.pos["policeOfficer"].y - height, self.data.rendering.pos["policeOfficer"].w, height, tocolor(255, 255, 255, 255), 1.0, self.data.font.bold_down )
	local text = getVehiclePlateText( self.data.element )
	local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
	self.data.rendering.pos["policeVehicle"].w = dxGetTextWidth( text )
	dxDrawText( text, self.data.rendering.pos["policeVehicle"].x, self.data.rendering.pos["policeVehicle"].y - height, self.data.rendering.pos["policeVehicle"].w, height, tocolor(255, 255, 255, 255), 1.0, self.data.font.bold_down )
	local text = string.format("%02d.%02d.%04d %02d:%02d:%02d", time.monthday, time.month + 1.0, time.year + 1900, time.hour, time.minute, time.second)
	local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
	self.data.rendering.pos["dateTime"].w = dxGetTextWidth( text )
	dxDrawText( text, self.data.rendering.pos["dateTime"].x, self.data.rendering.pos["dateTime"].y - height, self.data.rendering.pos["policeVehicle"].w, height, tocolor(255, 255, 255, 255), 1.0, self.data.font.bold_down )
end

--[[
function PoliceRadar:onClientRender()
	if not isElement( self.data.element ) or getPedOccupiedVehicle( localPlayer ) ~= self.data.element then
		self:toggle()
	end
	local veh = self:getColission()
	if not self.targetVehicle or (veh ~= self.targetVehicle and isElement(veh) ) then
		self.targetVehicle = veh
	end
	local time = getRealTime( )
	local texture, size = self:createTexture("assets/background.png")
	local x, y = self.data.rendering.screen.x - size.x/2, self.data.rendering.screen.y - size.y
	dxDrawImage(x, y, size.x, size.y, texture)
	if isElement(self.targetVehicle) then
		if getDistanceBetweenPoints3D( Vector3( getElementPosition( self.targetVehicle ) ), Vector3( getElementPosition( self.data.element ) ) ) < 20.0 then
			self.data.update = true
			self.plateText = getVehiclePlateText( self.targetVehicle )
			self.data.speed = round( PoliceRadar:getElementSpeed(self.targetVehicle, "km/h") )
			self.data.owner = getElementData(self.targetVehicle, "owner") or "Nieznany"
		else
			self.data.update = false
		end
		if self.data.update then
			local height = dxGetFontHeight( 1.0, self.data.font.bold_up )
			dxDrawText( self.plateText, x+(225*self.data.scale.x), (y+height)-(2*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_up )
			dxDrawText( ( self.data.speed or 0 ).." KM/H" , x+(465*self.data.scale.x), (y+height)-(5*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_up )
			local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
			dxDrawText( self.data.owner, x+(165*self.data.scale.x), (y+height)+(35*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_down )
			dxDrawText( getElementData(self.targetVehicle, "wanted") == true and "Tak" or "Nie", x+(445*self.data.scale.x), (y+height)+(32*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_down )
		else
			local height = dxGetFontHeight( 1.0, self.data.font.bold_up )
			dxDrawText( self.plateText , x+(225*self.data.scale.x), (y+height)-(2*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_up )
			dxDrawText( ( self.data.speed or 0 ).." KM/H" , x+(465*self.data.scale.x), (y+height)-(5*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_up )
			local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
			dxDrawText( self.data.owner, x+(165*self.data.scale.x), (y+height)+(35*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_down )
			dxDrawText( getElementData(self.targetVehicle, "wanted") == true and "Tak" or "Nie", x+(445*self.data.scale.x), (y+height)+(32*self.data.scale.y), width, height, tocolor(255, 180, 0, 255), 1.0, self.data.font.bold_down )
		end
	end
	local height = dxGetFontHeight( 1.0, self.data.font.bold_down )
	local name 
	if getVehicleOccupant( self.data.element, 0 ) then
		name = getPlayerName( getVehicleOccupant( self.data.element, 0 )  )
	else
		name = ""
	end
	dxDrawText( name, x+(105*self.data.scale.x), (y+size.y-height)-(15*self.data.scale.y), width, height, tocolor(255, 255, 255, 255), 1.0, self.data.font.bold_down )
	dxDrawText(getVehiclePlateText( self.data.element ), x+(290*self.data.scale.x), (y+size.y-height)-(15*self.data.scale.y), width, height, tocolor(255, 255, 255, 255), 1.0, self.data.font.bold_down )
	dxDrawText( string.format("%02d.%02d.%04d %02d:%02d", time.monthday, time.month + 1.0, time.year + 1900, time.hour, time.minute), x+(440*self.data.scale.x), (y+size.y-height)-(15*self.data.scale.y), width, height, tocolor(255, 255, 255, 255), 1.0, self.data.font.bold_down )
end
--]]

Class = PoliceRadar:new()

function togglePoliceRadarManual(elem)
	local tog = Class:toggle()
	if tog and elem then
		Class:setElement( elem )
	end
end
addEvent ( "PoliceRadar:ToggleManual", true )
addEventHandler ( "PoliceRadar:ToggleManual", getRootElement(), togglePoliceRadarManual )