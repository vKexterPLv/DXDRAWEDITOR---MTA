local ResizeAndDragModule = {}
ResizeAndDragModule.__index = ResizeAndDragModule

function ResizeAndDragModule:new()
	local instance = {}
	setmetatable(instance,ResizeAndDragModule)
	if instance:constructor() then
		return instance
	end
	return false
end

function ResizeAndDragModule:constructor()
	self.resizing = {id=0,bool=false,corner=""}
	self.moving = {id=0,bool=false}
	
	self.dragX = 0
	self.dragY = 0

	self.func = {}
	self.func.onClick = function(...) self:onClick(...) end
	self.func.renderResizeHandling = function() self:renderResizeHandling() end
	
	addEventHandler("onClientRender",root,self.func.renderResizeHandling)
	addEventHandler("onClientClick",root,self.func.onClick)
	return true
end

function ResizeAndDragModule:renderResizeHandling()
	if guied.resizeMode then
		if isCursorShowing() and self.resizing.bool and #guied.elements >= 1 then
			local v = guied.elements[self.resizing.id]
			local cx,cy = getCursorPosition()
			cx,cy = cx*scr.x,cy*scr.y
			
			if v then
				v:repositionLine(self.resizing.corner,cx,cy)
			end
			
			if v and v.type ~= "CIRCLE" and v.type ~= "LINE" then
				
				if self.resizing.corner == "top-center" then
					local newH = v.h + (v.y - cy)
					
					if newH >= v.defSizeH then
						v.h = newH
						v.y = cy
					end
				end
				
				if self.resizing.corner == "left-center" then
					local newW = v.w + (v.x - cx)
					
					if newW >= v.defSizeW then
						v.w = newW
						v.x = cx
					end
				end
				
				if self.resizing.corner == "right-center" then
					v.w = math.max(v.defSizeW, cx - v.x)
				end
				
				
				
				---------- NORMAL
				
				
				
				if self.resizing.corner == "down-center" then
					v.h = math.max(v.defSizeH, cy - v.y)
				end	
				
				if self.resizing.corner == "down-right" then
					v.w = math.max(v.defSizeW, cx - v.x)
					v.h = math.max(v.defSizeH, cy - v.y)
				end
			
				if self.resizing.corner == "down-left" then
					local newW = v.w + (v.x - cx)
					v.h = math.max(v.defSizeH, cy - v.y)
					
					if newW >= v.defSizeW then
						v.w = newW
						v.x = cx
					end
				end
			
				if self.resizing.corner == "top-right" then
					local newH = v.h + (v.y - cy)
					v.w = math.max(v.defSizeW, cx - v.x)
					
					if newH >= v.defSizeH then
						v.h = newH
						v.y = cy
					end
				end		
				if self.resizing.corner == "top-left" then
					local newW = v.w + (v.x - cx)
					local newH = v.h + (v.y - cy)
					
					if newW >= v.defSizeW then
						v.w = newW
						v.x = cx
					end
					if newH >= v.defSizeH then
						v.h = newH
						v.y = cy
					end
				end
				
				v:setUpResizePoints()
			end
		end
	end

	if isCursorShowing() and self.moving.bool and #guied.elements >= 1 then
		local v = guied.elements[self.moving.id]
		if v then
			local cx,cy = getCursorPosition()
			cx,cy = cx*scr.x,cy*scr.y
			v.x = cx-self.dragX
			v.y = cy-self.dragY
			
			
			if v.type ~= "CIRCLE" then
				v:setUpResizePoints()
			end
			if v.type == "LINE" then
				v.x2 = v.x+v.w
				v.y2 = v.y+v.h
			end
		end
	end
end

function ResizeAndDragModule:onClick(btn,state,x,y)
	if guied.customizing then return end
	if btn ~= "left" then return end
	if state == "down" then 
		for _,v in reverse_pairs(guied.elements) do
			if v then
				if v.type ~= "CIRCLE" and guied.resizeMode then
					for _,v1 in pairs(v.resizePoints) do
						if isMouseInPosition(v1.x,v1.y,v1.w,v1.h) then
							self.resizing.id = v.id
							self.resizing.bool = true
							self.resizing.corner = v1.corner			
							break
						end
					end
				else
					local isMouseIn = v.type == "CIRCLE" and isMouseInCircle(v.x,v.y,v.attributes[3].value) or isMouseInPosition(v.x,v.y,v.w,v.h)
					if isMouseIn then
						self.dragX = x-v.x
						self.dragY = y-v.y
						self.moving.id = v.id
						self.moving.bool = true
						break
					end
				end
			end
		end
	else
		self.resizing.id = 0
		self.resizing.bool = false
		self.resizing.corner = ""
		
		self.moving.id = 0
		self.bool = false
	end	
end

ResizeAndDragModule:new()