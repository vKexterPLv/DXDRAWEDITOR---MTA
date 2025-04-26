Image = inherit(Shape)

function Image:constructor()
	self.defSizeW = scaleImage(50)
	self.defSizeH = scaleImage(50)
	
	self.id = 0
	self.type = "IMAGE"
	
	self.w = self.defSizeW
	self.h = self.defSizeH
	
	self.x = scr.x/2-self.w/2
	self.y = scr.y/2-self.h/2
	
	self.attributes = {
		[1] = {name="Color",value=tocolor(255,255,255,255)},
		[2] = {name="Post GUI",value=false,action=function(self)
			self.attributes[2].value = not self.attributes[2].value
		end},
		[3] = {name="Select image",value="images/examples/mtalogo.png",action=function(self)
			local function setValue(_,_,path,resourcename,_,sizeTable)
				local path = resourcename == getResourceName(getThisResource()) and path or ":"..resourcename.."/"..path
				self.attributes[3].value = path
				self.w = sizeTable.width
				self.h = sizeTable.height
				guied.customizing = false
			end
			ImagePicker.open(nil,nil,setValue)
			guied.customizing = true
		end},
		[4] = {name="Rotation",value=0,action=function(self)
			local function setValue(value)
				self.attributes[4].value = 360*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
		[5] = {name="Rotation center X",value=0,action=function(self)
			local function setValue(value)
				self.attributes[5].value = 360*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
		[6] = {name="Rotation center Y",value=0,action=function(self)
			local function setValue(value)
				self.attributes[6].value = 360*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
	}
	
	self:setUpResizePoints()
end

function Image:setUpResizePoints()
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

function Image:drawShape()
	dxDrawImage(self.x,self.y,self.w,self.h,self.attributes[3].value,self.attributes[4].value,self.attributes[5].value,self.attributes[6].value,self.attributes[1].value,self.attributes[2].value)
end

function Image:output()
	local anchorX,anchorY = getAnchorPoint(self.x,self.y,self.w,self.h)
	local x, y = returnScaleXString(self.x,anchorX),returnScaleYString(self.y,anchorY)
	return string.format("dxDrawImage(%s,%s,%d/zoom,%d/zoom,'%s',%d,%d,%d,%d,%s)",x,y,self.w*zoom,self.h*zoom,self.attributes[3].value,self.attributes[4].value,self.attributes[5].value,self.attributes[6].value,self.attributes[1].value,tostring(self.attributes[2].value))
end

function Image:destroyWholeShit()
	self = nil
end