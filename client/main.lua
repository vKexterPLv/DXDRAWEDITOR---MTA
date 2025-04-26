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
	
	addEventHandler("onClientRender",root,self.func.draw)
	addEventHandler("onClientKey",root,self.func.onKey)
	
	showCursor(true)
	return true
end

function GUIEditor:onKey(btn,state)
	if state then return end
	if btn == "k" then 
		self.resizeMode = not self.resizeMode
	end
end

function GUIEditor:draw()
	for k,v in pairs(self.elements) do
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

guied = GUIEditor:new()
fontsID = IDSystem:new()