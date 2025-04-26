Line = inherit(Shape)

function Line:constructor()
	local offset = scaleImage(500)

	self.id = 0
	self.type = "LINE"
	
	self.w = 0
	self.h = 0
	
	self.x = scr.x/2
	self.y = offset
	self.x2 = self.x+scaleImage(200)
	self.y2 = scr.y-offset
	
	self.w = self.x2-self.x
	self.h = self.y2-self.y
	
	self.attributes = {
		[1] = {name="Color",value=tocolor(255,255,255,255),action=function(self)
			if menuKontekstowe.colorPickerCreated then return end
			openPicker("Color","#ffffff","Color")
			guied.customizing = true
			addEventHandler("onColorPickerChange",root,function(id, hex, r, g, b)
				self.attributes[1].value = tocolor(r,g,b)
			end)
			addEventHandler("onColorPickerOK",root,function(id,hex,r,g,b)
				self.attributes[1].value = tocolor(r,g,b)
				menuKontekstowe.colorPickerCreated = false
				guied.customizing = false
			end)
			menuKontekstowe.colorPickerCreated = true
		end},
		[2] = {name="Post GUI",value=false,action=function(self)
			self.attributes[2].value = not self.attributes[2].value
		end},
		[3] = {name="Line width",value=5,action=function(self)
			local function setValue(value)
				self.attributes[3].value = 50*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
	}
	
	self:setUpResizePoints()
end

function Line:setUpResizePoints()
	self.resizePoints = {}
	self.resizePoints[1] = {corner="down-right",x=self.x-resizeAreaSize/2,y=self.y-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	self.resizePoints[2] = {corner="top-left",x=self.x2-resizeAreaSize/2,y=self.y2-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
end

function Line:drawShape()
	dxDrawRectangle(self.x,self.y,self.w,self.h,tocolor(36,36,36,200))
	
	-- dxDrawRectangle(self.x2-self.w,self.y2-self.h,self.w,self.h,tocolor(255,36,255,255))

	dxDrawLine(self.x,self.y,self.x2,self.y2,self.attributes[1].value,self.attributes[3].value,self.attributes[2].value)
end

function Line:repositionLine(corner,cx,cy)
	if corner == "down-right" then
		self.x = cx
		self.y = cy
	end
	
	if corner == "top-left" then
		self.x2 = cx
		self.y2 = cy
	end
	
	self.w = self.x2-self.x
	self.h = self.y2-self.y
	
	self:setUpResizePoints()
end

function Line:output()
	local anchorX,anchorY = getAnchorPoint(self.x,self.y,self.w,self.h)
	local anchorX2,anchorY2 = getAnchorPoint(self.x,self.y,self.w,self.h)
	local x, y = returnScaleXString(self.x,anchorX),returnScaleYString(self.y,anchorY)
	local x2, y2 = returnScaleXString(self.x2,anchorX2),returnScaleYString(self.y2,anchorY2)
	return string.format("dxDrawLine(%s,%s,%s,%s,%d,%d,%s)",x,y,x2,y2,self.attributes[1].value,self.attributes[3].value,tostring(self.attributes[2].value))
end

function Line:destroyWholeShit()
	self = nil
end