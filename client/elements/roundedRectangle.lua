RoundedRectangle = inherit(Shape)

function RoundedRectangle:constructor()
	self.defSizeW = scaleImage(50)
	self.defSizeH = scaleImage(50)
	
	self.id = 0
	self.type = "ROUNDEDRECT"
	
	self.w = self.defSizeW
	self.h = self.defSizeH
	
	self.x = scr.x/2-self.w/2
	self.y = scr.y/2-self.h/2
	
	self.attributes = {
		[1] = {name="Color",value=tocolor(255,255,255,255),action=function(self)
			if menuKontekstowe.colorPickerCreated then return end
			local element = openPicker("Color","#ffffff","Color")
			guied.customizing = true
			addEventHandler("onColorPickerChange",element,function(id, hex, r, g, b)
				self.attributes[1].value = tocolor(r,g,b)
			end)
			addEventHandler("onColorPickerOK",element,function(id,hex,r,g,b)
				self.attributes[1].value = tocolor(r,g,b)
				menuKontekstowe.colorPickerCreated = false
				guied.customizing = false
			end)
			menuKontekstowe.colorPickerCreated = true
		end},
		[2] = {name="Post GUI",value=false,action=function(self)
			self.attributes[2].value = not self.attributes[2].value
		end},
		[3] = {name="Radius",value=10,action=function(self)
			local function setValue(value)
				self.attributes[3].value = 25*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
	}
	
	self:setUpResizePoints()
end

function RoundedRectangle:setUpResizePoints()
	self.resizePoints = {}
	self.resizePoints[1] = {corner="top-left",x=self.x-resizeAreaSize/2,y=self.y-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	self.resizePoints[2] = {corner="top-right",x=(self.x+self.w)-resizeAreaSize/2,y=self.y-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	
	self.resizePoints[3] = {corner="down-left",x=self.x-resizeAreaSize/2,y=(self.y+self.h)-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	self.resizePoints[4] = {corner="down-right",x=(self.x+self.w)-resizeAreaSize/2,y=(self.y+self.h)-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}

	self.resizePoints[5] = {corner="top-center",x=(self.x+(self.w/2))-resizeAreaSize/2,y=self.y-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	self.resizePoints[6] = {corner="left-center",x=(self.x)-resizeAreaSize/2,y=(self.y+(self.h/2))-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	self.resizePoints[7] = {corner="down-center",x=(self.x+(self.w/2))-resizeAreaSize/2,y=(self.y+self.h)-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
	self.resizePoints[8] = {corner="right-center",x=(self.x+self.w)-resizeAreaSize/2,y=(self.y+(self.h/2))-resizeAreaSize/2,w=resizeAreaSize,h=resizeAreaSize}
end

function RoundedRectangle:drawShape()
	dxDrawRoundedRectangle(self.x,self.y,self.w,self.h,self.attributes[3].value,self.attributes[1].value,self.attributes[2].value)
end

function RoundedRectangle:output()
	local anchorX,anchorY = getAnchorPoint(self.x,self.y,self.w,self.h)
	local x, y = returnScaleXString(self.x,anchorX),returnScaleYString(self.y,anchorY)
	return string.format("dxDrawRoundedRectangle(%s,%s,%d/zoom,%d/zoom,%d,%d,%s)",x,y,self.w*zoom,self.h*zoom,self.attributes[3].value,self.attributes[1].value,tostring(self.attributes[2].value))
end

function RoundedRectangle:destroyWholeShit()
	self = nil
end