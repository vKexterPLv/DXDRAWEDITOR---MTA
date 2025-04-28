local CGUI = {}
CGUI.__index = CGUI

function CGUI:new()
	local instance = {}
	setmetatable(instance,CGUI)
	if instance:constructor() then
		return instance
	end
	return false
end

function CGUI:constructor()
	self.areThereAnyGUIS = false
	
	self.window = false
	self.accept = false
	self.cancel = false
	
	self.cguiWith = ""
	self.fontPickerOpened = false
	
	self.func = {}
	self.func.accept = function(...) self:buttonAccept(source,...) end
	self.func.cancel = function(...) self:buttonCancel(source,...) end
	self.func.openPicker = function(...) self:buttonOpenPicker(source,...) end
	self.func.sliderMouseUP = function(...) self:sliderMouseUP(source,...) end
	
	return true
end

function CGUI:buttonOpenPicker(source,button,state)
	if button ~= "left" then return end
	if state ~= "up" then return end
	if source ~= self.openPicker then return end
	
	fontPicker:show(self.callback)
end

function CGUI:buttonAccept(source,button,state)
	if button ~= "left" then return end
	if state ~= "up" then return end
	if source ~= self.accept then return end
	
	if self.cguiWith == "editbox" then
		self.callback(guiGetText(self.chooser))
	end

	if self.cguiWith == "combobox" then
		self.callback(guiComboBoxGetItemText(self.chooser,guiComboBoxGetSelected(self.chooser)))
	end
	
	self:clearup()
end

function CGUI:buttonCancel(source,button,state)
	if button ~= "left" then return end
	if state ~= "up" then return end
	if source ~= self.cancel then return end
	self:clearup()
end

function CGUI:clearup()
	removeEventHandler("onClientGUIClick",self.accept,self.func.accept)
	removeEventHandler("onClientGUIClick",self.cancel,self.func.cancel)
	removeEventHandler("onClientGUIMouseUp",root,self.func.sliderMouseUP)
	if isElement(self.accept) then destroyElement(self.accept) end
	if isElement(self.cancel) then destroyElement(self.cancel) end
	if isElement(self.chooser) then destroyElement(self.chooser) end
	
	if isElement(self.openPicker) then 
		removeEventHandler("onClientGUIClick",self.openPicker,self.func.openPicker)
		destroyElement(self.openPicker) 
	end
	
	if isElement(self.window) then destroyElement(self.window) end
	
	
	self.areThereAnyGUIS = false
	guied.customizing = false
end

function CGUI:sliderMouseUP(source,button)
	if button ~= "left" then return end
	if source ~= self.chooser then return end
	self.callback(guiScrollBarGetScrollPosition(self.chooser))
end

function CGUI:initializeWindow(chooser,...)
	local w = 0.22
	local h = chooser == "combobox" and 0.35 or 0.15 
	local buttonW = 0.45
	local buttonH = 0.25
	local doWeNeedFontPicker = arg[2] or false
	
	self.window = guiCreateWindow(0.5-w/2,0.5-h/2,w,h,"Choose option",true)
	self.accept = guiCreateButton(0,1-buttonH-0.09,buttonW,buttonH,"ACCEPT",true,self.window)
	self.cancel = guiCreateButton(1-buttonW,1-buttonH-0.09,buttonW,buttonH,"CANCEL",true,self.window)
	
	addEventHandler("onClientGUIClick", self.accept, self.func.accept)
	addEventHandler("onClientGUIClick", self.cancel, self.func.cancel)
	
	if chooser == "editbox" then
		local editW = 1
		local editH = 0.4
		self.chooser = guiCreateEdit(0,0.2,editW,editH,"",true,self.window)
		self.cguiWith = "editbox"
	end
	
	if chooser == "slider" then
		local editW = 1
		local editH = 0.4
		self.chooser = guiCreateScrollBar(0,0.2,editW,editH,true,true,self.window)
		self.cguiWith = "slider"
		
		addEventHandler("onClientGUIMouseUp", root, self.func.sliderMouseUP)
	end
	
	if chooser == "combobox" then
		local comboW = 1
		local comboH = 0.5
		self.chooser = guiCreateComboBox(0,0.1,comboW,comboH,"Choose option",true,self.window)
		
		for k,v in pairs(arg[1]) do
			guiComboBoxAddItem(self.chooser,v)
		end
		
		if doWeNeedFontPicker then
			self.openPicker = guiCreateButton(0,0.45,1,0.2,"Open font picker",true,self.window)
			addEventHandler("onClientGUIClick", self.openPicker, self.func.openPicker)
		end
		
		self.cguiWith = "combobox"
	end
	
	guiFocus(self.window)
	
	self.areThereAnyGUIS = true
	guied.customizing = true
end

function CGUI:createCGUI(what,callback,...)
	if self.areThereAnyGUIS then return end
	if what == 1 then
		self:initializeWindow("editbox")
		self.callback = callback
	end
	if what == 2 then
		self:initializeWindow("combobox",...)
		self.callback = callback
	end
	if what == 3 then
		self:initializeWindow("slider")
		self.callback = callback
	end
end

cgui = CGUI:new()

-- cgui:createCGUI(3,function(val)
	-- iprint(val)
-- end)