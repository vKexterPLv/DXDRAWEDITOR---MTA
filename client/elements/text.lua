TextShape = inherit(Shape)

function TextShape:constructor()
	self.defSizeW = scaleImage(100)
	self.defSizeH = scaleImage(50)
	
	self.id = 0
	self.type = "TEXT"
	
	self.w = self.defSizeW
	self.h = self.defSizeH
	
	self.rotation = 0
	
	self.customFont = {element=false,path=false,id=0}
	
	-- iprint(self.w)
	
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
		[2] = {name="Text scale",value=1,action=function(self)
			local function setValue(value)
				if isElement(self.customFont.element) then
					self.attributes[2].value = 1*value/100
					return
				end
				self.attributes[2].value = 50*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
		[3] = {name="Align X",value="center",action=function(self)
			local function setValue(value)
				self.attributes[3].value = value
			end
			cgui:createCGUI(2,setValue,{"left","center","right"})
		end},
		[4] = {name="Align Y",value="center",action=function(self)
			local function setValue(value)
				self.attributes[4].value = value
			end
			cgui:createCGUI(2,setValue,{"top","center","bottom"})
		end},
		[5] = {name="Text",value="Hello World",action=function(self)
			local function setValue(value)
				self.attributes[5].value = value
			end
			cgui:createCGUI(1,setValue)
		end},
		[6] = {name="Font",value="default-bold",action=function(self)
			local function setValue(value,fromPicker)
				if fromPicker then
					if isElement(self.customFont.element) then fontsID:separateID(self.customFont.id); destroyElement(self.customFont.element) end
					self.customFont.element = dxCreateFont(value,100,false,"cleartype_natural")
					self.customFont.path = value
					self.attributes[2].value = 1
					local index = fontsID:assignID(self.customFont)
					fontsID.tbl[index].id = index
					self.customFont.id = index
					return
				end
				self.attributes[6].value = value
				if isElement(self.customFont.element) then fontsID:separateID(self.customFont.id); destroyElement(self.customFont.element) end
			end
			cgui:createCGUI(2,setValue,{"default","default-bold","clear","arial","sans","pricedown","bankgothic","diploma","beckett","unifont"},true)
		end},
		[7] = {name="Clip",value=false,action=function(self)
			self.attributes[7].value = not self.attributes[7].value
		end},
		[8] = {name="Wordbreak",value=false,action=function(self)
			self.attributes[8].value = not self.attributes[8].value
		end},
		[9] = {name="Post GUI",value=false,action=function(self)
			self.attributes[9].value = not self.attributes[9].value
		end},
		[10] = {name="Color coded",value=false,action=function(self)
			self.attributes[10].value = not self.attributes[10].value
		end},
		[11] = {name="Rotation",value=0,action=function(self)
			local function setValue(value)
				self.rotation = tonumber(value)
			end
			cgui:createCGUI(1,setValue)
		end},
	}

	-- dx
	
	self:setUpResizePoints()
end

function TextShape:setUpResizePoints()
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

function TextShape:drawShape()
	dxDrawText(self.attributes[5].value,self.x,self.y,self.x+self.w,self.y+self.h,self.attributes[1].value,self.attributes[2].value,self.customFont.element or self.attributes[6].value,self.attributes[3].value,self.attributes[4].value,self.attributes[7].value,self.attributes[8].value,self.attributes[9].value,self.attributes[10].value,false,self.rotation)
end

function TextShape:output()
	local anchorX,anchorY = getAnchorPoint(self.x,self.y,self.w,self.h)
	local x, y = returnScaleXString(self.x,anchorX),returnScaleYString(self.y,anchorY)
	local fontSize = tostring(self.attributes[2].value*zoom)
	return string.format("dxDrawText('%s',%s,%s,(%s)+(%d/zoom),(%s)+(%d/zoom),%s,%s/zoom,%s,'%s','%s',%s,%s,%s,%s,false,%d)",
		self.attributes[5].value,
		x,
		y,
		x,
		self.w*zoom,
		y,
		self.h*zoom,
		self.attributes[1].value,
		fontSize == tostring(zoom) and 1 or fontSize,
		self.customFont.element and "fonts["..self.customFont.id.."]" or "'"..self.attributes[6].value.."'",
		self.attributes[3].value,
		self.attributes[4].value,
		tostring(self.attributes[7].value),
		tostring(self.attributes[8].value),
		tostring(self.attributes[9].value),
		tostring(self.attributes[10].value),
		self.rotation
	)
end

function TextShape:destroyWholeShit()
	if isElement(self.customFont.element) then fontsID:separateID(self.customFont.id); destroyElement(self.customFont.element) end
	iprint(fontsID.tbl)
	self = nil
end