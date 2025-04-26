Circle = inherit(Shape)

function Circle:constructor()	
	self.id = 0
	self.type = "CIRCLE"
	
	self.w = 0
	self.h = 0
	self.x = scr.x/2
	self.y = scr.y/2
	
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
		[3] = {name="Radius",value=50,action=function(self)
			local function setValue(value)
				self.attributes[3].value = 500*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
		[4] = {name="Start angle",value=0,action=function(self)
			local function setValue(value)
				self.attributes[4].value = 360*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
		[5] = {name="End angle",value=360,action=function(self)
			local function setValue(value)
				self.attributes[5].value = 360*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
		[6] = {name="Center color",value=tocolor(255,255,255,255),action=function(self)
			if menuKontekstowe.colorPickerCreated then return end
			openPicker("Color","#ffffff","Color")
			guied.customizing = true
			addEventHandler("onColorPickerChange",root,function(id, hex, r, g, b)
				self.attributes[6].value = tocolor(r,g,b)
			end)
			addEventHandler("onColorPickerOK",root,function(id,hex,r,g,b)
				self.attributes[6].value = tocolor(r,g,b)
				menuKontekstowe.colorPickerCreated = false
				guied.customizing = false
			end)
			menuKontekstowe.colorPickerCreated = true
		end},
		[7] = {name="Circle segments",value=32,action=function(self)
			local function setValue(value)
				self.attributes[7].value = 35*value/100
			end
			cgui:createCGUI(3,setValue)
		end},
	}
	
end

function Circle:drawShape()
	dxDrawCircle(self.x,self.y,self.attributes[3].value,self.attributes[4].value,self.attributes[5].value,self.attributes[1].value,self.attributes[6].value,self.attributes[7].value,1,self.attributes[2].value)
end

function Circle:output()
	local anchorX,anchorY = getAnchorPoint(self.x,self.y,self.w,self.h)
	local x, y = returnScaleXString(self.x,anchorX),returnScaleYString(self.y,anchorY)
	return string.format("dxDrawCircle(%s,%s,%d/zoom,%d,%d,%d,%d,%d,1,%s)",
		x,
		y,
		self.attributes[3].value*zoom,
		self.attributes[4].value,
		self.attributes[5].value,
		self.attributes[1].value,
		self.attributes[6].value,
		self.attributes[7].value,
		tostring(self.attributes[2].value)
	)
end

function Circle:destroyWholeShit()
	self = nil
end