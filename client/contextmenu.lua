local ContextMenu = {}
ContextMenu.__index = ContextMenu

function ContextMenu:new()
	local instance = {}
	setmetatable(instance,ContextMenu)
	if instance:constructor() then
		return instance
	end
	return false
end

function ContextMenu:constructor()
	self.clickedOn = false
	self.contextMenuRevealed = false
	self.x,self.y = 0,0
	
	self.contextMenuElements = {}
	self.contextMenuSegments = {}
	
	self.origColor = tocolor(36,36,36,255)
	self.hoverColor = tocolor(100,100,100,255)
	
	self.colorPickerCreated = false

	self.func = {}
	self.func.onClick = function(...) self:onClick(...) end
	self.func.onClickContextSegment = function(...) self:onClickContextSegment(...) end
	self.func.onHover = function() self:onHover() end
	self.func.render = function() self:render() end
	self.func.scrollUP = function() self:scrollUP() end
	self.func.scrollDOWN = function() self:scrollDOWN() end
	
	bindKey("mouse_wheel_down", "both", self.func.scrollUP)
	bindKey("mouse_wheel_up", "both", self.func.scrollDOWN)
	
	self.row = 1
	self.maxRows = 7
	
	addEventHandler("onClientRender",root,self.func.render)
	addEventHandler("onClientClick",root,self.func.onClick)
	addEventHandler("onClientClick",root,self.func.onClickContextSegment)
	addEventHandler("onClientCursorMove",root,self.func.onHover)
	return true
end

function ContextMenu:scrollUP()
	if not self.contextMenuRevealed then return end
	if self.row < #self.contextMenuSegments-self.maxRows+1 then 
		self.row=self.row + 1
	end
end

function ContextMenu:scrollDOWN()
	if not self.contextMenuRevealed then return end
	if self.row > 1 then
		self.row = self.row-1
	end
end

function ContextMenu:onClickContextSegment(btn,state,x,y)
	if state ~= "down" then return end
	if btn ~= "left" then return end
	if not self.contextMenuRevealed then return end
	local clickedOnSegment = false
	
	local k = 1
	for i=self.row,self.row+(self.maxRows-1) do
		local segmentV = self.contextMenuSegments[i]
		if segmentV then
			local w = segmentV.w
			local h = segmentV.h
			local x = segmentV.x
			local y = self.y+((k-1)*h)
			if isMouseInPosition(x,y,w,h) then
				local element = self.contextMenuElements[i]
				clickedOnSegment = true
				
				if element.name == "USUN" then
					clickedOnSegment = false
					guied.elements[self.clickedOn.id] = nil
					self.clickedOn:delete()
				end
				
				if element.action then
					element.action(self.clickedOn)
					clickedOnSegment = false
				end		
				
				break
			end			
			k = k + 1
		end
	end
	
	self.contextMenuRevealed = clickedOnSegment
end

function ContextMenu:onClick(btn,state,x,y)
	if state ~= "down" then return end
	if btn ~= "right" then return end
	
	self.clickedOn = false
	self.contextMenuRevealed = false
	self.x,self.y = 0,0
	
	self.contextMenuElements = {}
	self.contextMenuSegments = {}
	
	for _,v in reverse_pairs(guied.elements) do
		self.contextMenuRevealed = false
		local isMouseIn = v.type == "CIRCLE" and isMouseInCircle(v.x,v.y,v.attributes[3].value) or isMouseInPosition(v.x,v.y,v.w,v.h)
		if isMouseIn then
			self.clickedOn = v
			self.x,self.y = x,y
			self.contextMenuElements[1] = {name="OPCJE DLA: "..v.type,value=0}
			
			local i = 2
			for k,v1 in pairs(v.attributes) do
				self.contextMenuElements[i] = v1
				self.contextMenuElements[i].originalAttributeIndex = k
				i = i + 1
			end
			
			self.contextMenuElements[i] = {name="Wysrodkuj w osi X",value=0,action=function(self)
				self.x = scr.x/2-self.w/2
				if self.type ~= "CIRCLE" then
					self:setUpResizePoints()
				end
			end}
			self.contextMenuElements[i+1] = {name="Wysrodkuj w osi Y",value=0,action=function(self)
				self.y = scr.y/2-self.h/2
				if self.type ~= "CIRCLE" then
					self:setUpResizePoints()
				end
			end}
			self.contextMenuElements[i+2] = {name="USUN",value=0}
			
			local i = 1
			for _,v1 in pairs(self.contextMenuElements) do
				local w = scaleImage(200)
				local h = scaleImage(50)
				local x = self.x
				self.contextMenuSegments[i] = {x=x,w=w,h=h,color=self.origColor}
				i = i + 1
			end
			
			self.contextMenuRevealed = true
			break
		end
	end
end

function ContextMenu:render()
	if not self.contextMenuRevealed then return end
	
	local k = 1
	for i=self.row,self.row+(self.maxRows-1) do
		local segmentV = self.contextMenuSegments[i]
		if segmentV then
			local w = segmentV.w
			local h = segmentV.h
			local x = segmentV.x
			local y = self.y+((k-1)*h)
			local v = self.contextMenuElements[i]
			
			dxDrawRectangle(x,y,w,h,segmentV.color,true)
			
			if type(v.value) == "boolean" then
				dxDrawText(v.name..": "..(v.value and "TAK" or "NIE"),x+scaleImage(10),y,x+w,y+h,white,1,"default-bold","left","center",false,false,true)
			else
				dxDrawText(v.name,x+scaleImage(10),y,x+w,y+h,white,1,"default-bold","left","center",false,false,true)
			end
			
			if string.find(string.lower(v.name), "color") and type(v.value) ~= "boolean" then
				local colorRectSize = scaleImage(25)
				dxDrawRectangle((x+w)-colorRectSize-scaleImage(10),y+(h/2)-(colorRectSize/2),colorRectSize,colorRectSize,v.value,true)
			end
			
			k = k + 1
		end
	end
	-- for k,v1 in pairs(self.contextMenuSegments) do
	-- end
end

function ContextMenu:onHover()
	local k = 1
	for i=self.row,self.row+(self.maxRows-1) do
		local segmentV = self.contextMenuSegments[i]
		if segmentV then
			segmentV.color = self.origColor
			local w = segmentV.w
			local h = segmentV.h
			local x = segmentV.x
			local y = self.y+((k-1)*h)
			if isMouseInPosition(x,y,w,h) then
				segmentV.color = self.hoverColor
			end
			
			k = k + 1
		end
	end
end

menuKontekstowe = ContextMenu:new()