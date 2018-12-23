--[[
				MTA Role Play (mta-rp.pl)
				Autorzy poniższego kodu:
				- Patryk Adamowicz <patrykadam.dev@gmail.com> 
				  Discord: PatrykAdam#1293

		Link do githuba: https://github.com/PatrykAdam/mtarp
--]]

local textureList = {
  {url = 'assets/1.png'},
  {url = 'assets/2.png'},
  {url = 'assets/3.png'},
  {url = 'assets/4.png'},
  {url = 'assets/5.png'},
  {url = 'assets/6.png'},
  {url = 'assets/7.png'},
  {url = 'assets/8.png'},
  {url = 'assets/9.png'},
  {url = 'assets/10.png'},
  {url = 'assets/11.png'},
  {url = 'assets/12.png'},
  {url = 'assets/13.png'},
  {url = 'assets/14.png'},
  {url = 'assets/15.png'},
  {url = 'assets/16.png'},
  {url = 'assets/17.png'}
}

local texture = {}

function texture.start()
	for i, v in ipairs(textureList) do
  		v.shader = dxCreateShader('assets/texture.fx')
  		dxSetShaderValue(v.shader, 'tex', dxCreateTexture( v.url ))
	end
end

addEventHandler( "onClientResourceStart", root, texture.start )

function setObjectTexture(objectid, texIndex, texID)
	texID = tonumber(texID)
  texIndex = tonumber(texIndex)

  local texName = false
  for i, v in ipairs( engineGetModelTextureNames( tostring(getElementModel( objectid )) )) do
    if texIndex == i then
      texName = v
      break
    end
  end

  if texName == false then
    if texIndex == 0 then
      texName = '*'
    else
      return false
    end
  end

	if isElement(objectid) and textureList[texID] and textureList[texID].shader then
		engineApplyShaderToWorldTexture( textureList[texID].shader, texName, objectid)
	end
end

function deleteAllObjectTexture(objectid)
  local id = getPlayerObjectID(objectid)
  local mtaID = objects[id].mtaID
  if type(objects[id].texture) == 'table' then
    for j, k in ipairs(objects[id].texture) do
      if isElement(mtaID) and textureList[k.texID] and textureList[k.texID].shader then
        engineRemoveShaderFromWorldTexture ( textureList[k.texID].shader, k.texName, mtaID )
      end
    end
  end
end