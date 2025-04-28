local GUIEditor = {}
GUIEditor.__index = GUIEditor

function GUIEditor:new()
	local instance = {}
	setmetatable(instance,GUIEditor)
	if instance:constructor() then
		return instance
	end
	return false
end

function GUIEditor:constructor()
	self.elements = {}
	
	self.func = {}
	self.func.draw = function() self:draw() end
	self.func.onKey = function(...) self:onKey(...) end
	
	self.resizeMode = false
	self.customizing = false
	self.rotating = false
	self.sizingWithKey = {startDistance=0,bool=false}
	
	self.selected = false
	
	addEventHandler("onClientRender",root,self.func.draw)
	addEventHandler("onClientKey",root,self.func.onKey)
	
	showCursor(true)
	return true
end

function GUIEditor:onKey(btn,state)
	if state and btn == "k" then 
		self.resizeMode = not self.resizeMode
	end
	
	if guiSelector.selected and guiSelector.selected.rotation and btn == "r" then 
		if not state then
			self.rotating = false
		else
			self.rotating = true
		end
	end

	if guiSelector.selected and btn == "s" then 
		if not state then
			self.sizingWithKey.bool = false
		else
			local element = guiSelector.selected
			local distance = getDistanceBetweenMouseAndElement2D(element)
			
			self.sizingWithKey.startDistance = math.max(1,distance)
			self.sizingWithKey.startW = element.w
			self.sizingWithKey.startH = element.h
			self.sizingWithKey.bool = true
		end
	end
end

function GUIEditor:draw()

	if self.rotating and guiSelector.selected and guiSelector.selected.rotation then
		local element = guiSelector.selected
		local mx, my = getCursorPosition ( )
		local mx, my = ( mx * scr.x ), ( my * scr.y )
		local centerX,centerY = element.x+element.w/2,element.y+element.h/2
		local deltaX,deltaY = mx-centerX,my-centerY
		local angle = math.deg(math.atan2(deltaY,deltaX))
		
		element.rotation = angle
	end
	
	if self.sizingWithKey.bool and guiSelector.selected then
		local element = guiSelector.selected
		local distance = getDistanceBetweenMouseAndElement2D(element)
		
		if self.sizingWithKey.bool and self.sizingWithKey.startDistance > 25 then
			local scale = distance / self.sizingWithKey.startDistance
			scale = math.max(0.1,math.min(scale,5))
			
			element.w = math.max(element.defSizeW,self.sizingWithKey.startW * scale)
			element.h = math.max(element.defSizeH,self.sizingWithKey.startH * scale)
		end
		
	end

	if guiSelector.selected then
		local element = guiSelector.selected
		local offset = scaleImage(5)
		
		if element.type ~= "CIRCLE" then
			local x = element.type == "LINE" and element.catchAreaX or element.x
			local y = element.type == "LINE" and element.catchAreaY or element.y
			dxDrawRectangle(x-offset,y-offset,element.w+(offset*2),element.h+(offset*2),tocolor(0,100,0,200))
		else
			local radius = element.attributes[3].value
			local size = radius*2
			dxDrawRectangle(element.x-radius,element.y-radius,size,size,tocolor(0,100,0,200))
		end
	end
	
	-- Rysowanie elementow
	for k,v in pairs(elementsID.tbl) do
		v:draw()
		
		if self.resizeMode and v.type ~= "CIRCLE" then
			for _,v1 in pairs(v.resizePoints) do
				dxDrawRectangle(v1.x,v1.y,v1.w,v1.h,tocolor(255,0,0))
			end
		end
	end
end

local IDSystem = {}
IDSystem.__index = IDSystem

function IDSystem:new()
	local instance = {}
	setmetatable(instance,IDSystem)
	if instance:constructor() then
		return instance
	end
	return false
end
function IDSystem:constructor()
	self.tbl = {}
	return true
end

function IDSystem:findFreeIndex()
  local i = 1
  while self.tbl[i] do
      i = i + 1
  end
  return i
end

function IDSystem:assignID(element)
  local index = self:findFreeIndex()
  self.tbl[index] = element
  return index
end

function IDSystem:separateID(index)
     if self.tbl[index] then
        self.tbl[index] = nil
        return true
    else
        return false
    end
end

function IDSystem:getID(index)
     if self.tbl[index] then
        return self.tbl[index]
    else
        return false
    end
end

fontsID = IDSystem:new()
elementsID = IDSystem:new()
guied = GUIEditor:new()