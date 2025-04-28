Editbox = inherit(Shape)

function Editbox:constructor()
	self.defSizeW = scaleImage(200)
	self.defSizeH = scaleImage(50)
	
	self.id = 0
	self.type = "EDITBOX"
	
	self.w = self.defSizeW
	self.h = self.defSizeH
	
	self.x = scr.x/2-self.w/2
	self.y = scr.y/2-self.h/2
	
	self.editboxElement = exports["u-dx"]:createEditbox("Editbox",self.x,self.y,self.w,self.h)
	
	exports["u-dx"]:showEditbox(self.editboxElement)
	
	self.attributes = {
		[1] = {name="Color",value=tocolor(36,36,36,200),action=function(self)
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
	}
	
	self:setUpResizePoints()
end

function Editbox:setUpResizePoints()
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

function Editbox:drawShape()
	exports["u-dx"]:setEditboxPosition(self.editboxElement,"x",self.x)
	exports["u-dx"]:setEditboxPosition(self.editboxElement,"y",self.y)
	exports["u-dx"]:setEditboxSize(self.editboxElement,"w",self.w)
	exports["u-dx"]:setEditboxSize(self.editboxElement,"h",self.h)
	dxDrawRectangle(self.x,self.y,self.w,self.h,self.attributes[1].value,self.attributes[2].value)
end

function Editbox:output()
	local anchorX,anchorY = getAnchorPoint(self.x,self.y,self.w,self.h)
	local x, y = returnScaleXString(self.x,anchorX),returnScaleYString(self.y,anchorY)
	return string.format("dxDrawRectangle(%s,%s,%d/zoom,%d/zoom,%d,%s)",x,y,self.w*zoom,self.h*zoom,self.attributes[1].value,tostring(self.attributes[2].value))
end

function Editbox:destroyWholeShit()
	exports["u-dx"]:destroyEditbox(self.editboxElement)
	self = nil
end