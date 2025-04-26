--[[--------------------------------------------------
	GUI Editor
	client
	image_picker.lua
	
	creates the image picker gui
--]]--------------------------------------------------

gScreen = Vector2(guiGetScreenSize())

ImagePicker = {
	gui = {},
	expanded,
	maxImageSize = 190,
	minImageSize = 5,
}


addEvent("guieditor:client_getImages", true)
addEventHandler("guieditor:client_getImages", root,
	function(images, permission)
		if images then
			local sortable = {}
			
			for name,_ in pairs(images) do
				sortable[#sortable + 1] = name
			end
			
			table.sort(sortable)
			
			ImagePicker.images = images
			ImagePicker.sorted = sortable
			local permissionWarning = ""
			
			if isBool(permission) and not permission then
				permissionWarning = "\n\n(Access to general.ModifyOtherObjects is needed to request images)"
			end
			
			if guiGetVisible(ImagePicker.gui.wndMain) then
				ImagePicker.gui.expandingGrid:setData(images, sortable, getResourceName(getThisResource()))

				if ImagePicker.reloading then
					if #sortable > 0 then
						MessageBox_Info:create("Image Picker Refresh", "Image list successfully updated from the server.")
					else
						MessageBox_Info:create("Image Picker Refresh", "Could not get the image list from the server.\n\nPlease check ACL permissions" .. permissionWarning)
					end
				else
					if #sortable == 0 then
						MessageBox_Info:create("Image Picker Refresh", "Could not get the image list from the server.\n\nPlease check ACL permissions" .. permissionWarning)
					end
				end
			end
		else
			if ImagePicker.reloading then
				MessageBox_Info:create("Image Picker Refresh", "Image list could not be updated from the server (request limit reached).\n\nTry again later.")
			end
		end
		
		ImagePicker.reloading = nil
	end
)


function ImagePicker.create()
	ImagePicker.gui.wndMain = guiCreateWindow((gScreen.x - 500) / 2, (gScreen.y - 400) / 2, 500, 400, "Image Picker", false)
	guiWindowSetSizable(ImagePicker.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(ImagePicker.gui.wndMain, "Close", "right", ImagePicker.close)

	guiWindowTitlebarButtonAdd(ImagePicker.gui.wndMain, "Select", "left", 
		function()
			if ImagePicker.current then
				ImagePicker.select(ImagePicker.current.row, ImagePicker.current.col, ImagePicker.current.text, ImagePicker.current.resource, ImagePicker.current.data)
			end
		end
	)
	
	guiWindowTitlebarButtonAdd(ImagePicker.gui.wndMain, "Reload List", "left", 
		function()
			ImagePicker.reloading = true
			
			triggerServerEvent("guieditor:server_getImages", localPlayer)
		end
	)	
	
	
	ImagePicker.gui.expandingGrid = ExpandingGridList:create(10, 20, 250, 370, false, ImagePicker.gui.wndMain)
	ImagePicker.gui.expandingGrid:addColumn("Resource images")
	
	guiGridListAddRow(ImagePicker.gui.expandingGrid.gridlist)
	guiGridListSetItemText(ImagePicker.gui.expandingGrid.gridlist, 0, 1, "Loading...", true, false)
	
	ImagePicker.gui.expandingGrid.onRowClick = ImagePicker.preview
	ImagePicker.gui.expandingGrid.onRowDoubleClick = ImagePicker.select
	ImagePicker.gui.expandingGrid.onHeaderClick = 
		function()
			ImagePicker.current = nil
		end
	
	ImagePicker.gui.lblDescription = guiCreateLabel(260, 25, 240, 75, "Preview:", false, ImagePicker.gui.wndMain)
	guiLabelSetVerticalAlign(ImagePicker.gui.lblDescription, "center")
	guiLabelSetHorizontalAlign(ImagePicker.gui.lblDescription, "center")
	
	ImagePicker.gui.imgPreview = guiCreateStaticImage(285, 105, 190, 190, "images/arrow_out.png", false, ImagePicker.gui.wndMain)
	guiSetSize(ImagePicker.gui.imgPreview, 0, 0, false)
	
	ImagePicker.gui.imgBorderTL = guiCreateStaticImage(285, 105, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderTR = guiCreateStaticImage(400, 105, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)				
	ImagePicker.gui.imgBorderBL = guiCreateStaticImage(285, 295, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderBR = guiCreateStaticImage(400, 295, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)
		
	ImagePicker.gui.imgBorderLT = guiCreateStaticImage(285, 105, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderLB = guiCreateStaticImage(285, 220, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderRT = guiCreateStaticImage(475, 105, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderRB = guiCreateStaticImage(475, 220, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	
	local colour = gAreaColours.secondary
		
	guiSetProperty(ImagePicker.gui.imgBorderTL, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderTR, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", colour, colour, colour, colour))	
	guiSetProperty(ImagePicker.gui.imgBorderBL, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderBR, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", colour, colour, colour, colour))	
	
	guiSetProperty(ImagePicker.gui.imgBorderLT, "ImageColours", string.format("tl:FF%s tr:FF%s bl:00%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderLB, "ImageColours", string.format("tl:00%s tr:00%s bl:FF%s br:FF%s", colour, colour, colour, colour))	
	guiSetProperty(ImagePicker.gui.imgBorderRT, "ImageColours", string.format("tl:FF%s tr:FF%s bl:00%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderRB, "ImageColours", string.format("tl:00%s tr:00%s bl:FF%s br:FF%s", colour, colour, colour, colour))	
	
	
	ImagePicker.gui.lblInstructions = guiCreateLabel(260, 300, 240, 70, "Please start the resource\n\nto use this image", false, ImagePicker.gui.wndMain)
	guiLabelSetVerticalAlign(ImagePicker.gui.lblInstructions, "center")
	guiLabelSetHorizontalAlign(ImagePicker.gui.lblInstructions, "center")	
	guiSetVisible(ImagePicker.gui.lblInstructions, false)
	guiSetColour(ImagePicker.gui.lblInstructions, unpack(gColours.primary))
	
	--ImagePicker.gui.btnStart = guiCreateButton(300, 370, 160, 20, "Start resource", false, ImagePicker.gui.wndMain)
	--guiSetEnabled(ImagePicker.gui.btnStart, false)
	--guiSetVisible(ImagePicker.gui.btnStart, false)
	
	guiSetVisible(ImagePicker.gui.wndMain, false)
	doOnChildren(ImagePicker.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end


function ImagePicker.open(images, sorted, callback, arguments)
	if not ImagePicker.gui.wndMain then
		ImagePicker.create()
	else
		if guiGetVisible(ImagePicker.gui.wndMain) then
			return false
		end
	end
	
	
	ImagePicker.onSelect = callback
	ImagePicker.onSelectArgs = selectArgs

	--if not ImagePicker.startPermission then
		--guiSetEnabled(ImagePicker.gui.btnStart, false)
	--else
		--guiSetEnabled(ImagePicker.gui.btnStart, true)
	--end	

	if images or sorted then
		ImagePicker.images = images
		ImagePicker.sorted = sorted
		
		ImagePicker.gui.expandingGrid:setData(images, sorted, getResourceName(getThisResource()))
	elseif ImagePicker.images or ImagePicker.sorted then
		ImagePicker.gui.expandingGrid:setData(ImagePicker.images, ImagePicker.sorted, getResourceName(getThisResource()))
	else
		triggerServerEvent("guieditor:server_getImages", localPlayer)
	end
	
	guiSetVisible(ImagePicker.gui.wndMain, true)
	guiBringToFront(ImagePicker.gui.wndMain)
	
	return true
end


function ImagePicker.openFromMenu(parent, select, selectArgs)
	if ImagePicker.open() then
		ImagePicker.guiParent = parent
		
		ImagePicker.onSelect = select
		ImagePicker.onSelectArgs = selectArgs
	end
end


function ImagePicker.close()
	guiSetVisible(ImagePicker.gui.wndMain, false)
	ImagePicker.reloading = nil
end


function ImagePicker.preview(row, col, text, resource, data)
	ImagePicker.current = nil

	if not fileExists(":" .. resource .. "/" .. text) or not guiStaticImageLoadImage(ImagePicker.gui.imgPreview, ":" .. resource .. "/" .. text) then
		guiSetVisible(ImagePicker.gui.imgPreview, false)

		guiSetText(ImagePicker.gui.lblInstructions, "Please start the resource\n'"..resource.."'\nto use this image")
		guiSetVisible(ImagePicker.gui.lblInstructions, true)
		--guiSetVisible(ImagePicker.gui.btnStart, true)
		
		guiSetText(ImagePicker.gui.lblDescription, "Preview:\n\n["..tostring(resource).."]\n"..tostring(text))
	else
		ImagePicker.current = {
			row = row,
			col = col,
			text = text,
			resource = resource,
			data = data
		}
	
		local imageWidth, imageHeight = getImageSize(":" .. resource .. "/" .. text)
		local width, height = imageWidth, imageHeight
		
		if width and height then
			if width >= height then
				if width > ImagePicker.maxImageSize then
					width = ImagePicker.maxImageSize
					
					height = height / (imageWidth / width)
				elseif height < ImagePicker.minImageSize then
					height = ImagePicker.minImageSize
					
					width = width * (height / imageHeight)
				end
			else
				if height > ImagePicker.maxImageSize then
					height = ImagePicker.maxImageSize
					
					width = width / (imageHeight / height)
				elseif width < ImagePicker.minImageSize then
					width = ImagePicker.minImageSize
					
					height = height * (width / imageWidth)
				end			
			end
			
			-- 285, 105
			guiSetPosition(ImagePicker.gui.imgPreview, 285 + ((ImagePicker.maxImageSize - width) / 2), 105 + ((ImagePicker.maxImageSize - height) / 2), false)
			guiSetSize(ImagePicker.gui.imgPreview, width, height, false)
			
			guiSetText(ImagePicker.gui.lblDescription, "Preview:\n\n["..tostring(resource).."]\n"..tostring(text).."\n"..tostring(imageWidth).." x "..tostring(imageHeight))
		else
			guiSetText(ImagePicker.gui.lblDescription, "Preview:\n\n["..tostring(resource).."]\n"..tostring(text))
			
			guiSetPosition(ImagePicker.gui.imgPreview, 285, 105, false)		
			guiSetSize(ImagePicker.gui.imgPreview, ImagePicker.maxImageSize, ImagePicker.maxImageSize, false)			
		end
	
	
		guiSetVisible(ImagePicker.gui.imgPreview, true)
		guiSetVisible(ImagePicker.gui.lblInstructions, false)
		--guiSetVisible(ImagePicker.gui.btnStart, false)
	end
end


function ImagePicker.select(row, col, text, resource)
	if text:find("png") and fileExists(":" .. resource .. "/" .. text) then
		-- create image
		if ImagePicker.onSelect then
			local width, height = getImageSize(":" .. resource .. "/" .. text)
		
			ImagePicker.onSelect(row, col, text, resource, ImagePicker.guiParent, {width = width, height = height}, unpack(ImagePicker.onSelectArgs or {}))
		end
		
		ImagePicker.close()
	end
end


-- png file format information:
-- http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html#C.IHDR
function getImageSize(path)
	if fileExists(path) then
		local file = fileOpen(path, true)
		
		if file then
			local width, height
			local data = fileRead(file, 100)
			local _,e = data:find("IHDR")

			if e then
				width = tonumber(string.format("%02X%02X%02X%02X", string.byte(data, e + 1, e + 4)), 16)
				height = tonumber(string.format("%02X%02X%02X%02X", string.byte(data, e + 5, e + 8)), 16)
			end
			
			fileClose(file)  
			
			return width, height
		end
	end
	
	return
end

function isBool(b)
	return b == true or b == false
end


function toBool(b)
	return b == "true" or b == "True" or b == true
end

gWindowTitlebarButtons = {
	defaultColour = {160, 160, 160},
	defaultDivider = "|",
}

gColours = {
	primary = {255, 69, 59, 255}, -- red
	secondary = {255, 118, 46, 255}, -- orange
	tertiary = {232, 42, 104, 255}, -- pink
	
	defaultLabel = {255, 255, 255},
	grey = {120, 120, 120},
	--primaryLight = {255, 153, 145, 255},
	primaryLight = {237, 126, 119, 255},
}

gAreaColours = {
	primary = "777777",
	secondary = "CCCCCC",
	
	dark = "000000",
}
gAreaColours.primaryPacked = {gAreaColours.primary, gAreaColours.primary, gAreaColours.primary, gAreaColours.primary}
gAreaColours.secondaryPacked = {gAreaColours.secondary, gAreaColours.secondary, gAreaColours.secondary, gAreaColours.secondary}
gAreaColours.darkPacked = {gAreaColours.dark, gAreaColours.dark, gAreaColours.dark, gAreaColours.dark}

function setRolloverColour(element, rollover, rolloff)
	setElementData(element, "guieditor:rollonColour", rollover)
	setElementData(element, "guieditor:rolloffColour", rolloff)

	-- addEventHandler("onClientMouseEnter", element, rollover_on, false)
	-- addEventHandler("onClientMouseLeave", element, rollover_off, false)
end

function guiWindowTitlebarButtonAdd(window, text, alignment, onClick, ...)
	local offset = getElementData(window, "guieditor:titlebarButton_"..alignment) or 5
	local w = guiGetSize(window, false)
	
	-- don't add a divider before the first item
	if offset > 10 then
		local width = dxGetTextWidth(gWindowTitlebarButtons.defaultDivider, 1, "default")
		local label	= guiCreateLabel(alignment == "left" and offset or w - offset - width, 2, width, 15, gWindowTitlebarButtons.defaultDivider, false, window)
		
		guiLabelSetColor(label, unpack(gWindowTitlebarButtons.defaultColour))
		guiLabelSetHorizontalAlign(label, "center", false)	
		guiSetProperty(label, "ClippedByParent", "False")
		guiSetProperty(label, "AlwaysOnTop", "True")
		
		-- if alignment == "right" then
			-- setElementData(label, "guiSnapTo", {[gGUISides.right or 0] = offset})
		-- end
		
		offset = offset + width + 5
	end
		
	local width = dxGetTextWidth(text, 1, "default")
	local label = guiCreateLabel(alignment == "left" and offset or w - offset - width, 2, width, 15, text, false, window)
	
	guiLabelSetColor(label, unpack(gWindowTitlebarButtons.defaultColour))
	guiLabelSetHorizontalAlign(label, "center", false)
	guiSetProperty(label, "ClippedByParent", "False")
	guiSetProperty(label, "AlwaysOnTop", "True")
	
	-- if alignment == "right" then
		-- setElementData(label, "guiSnapTo", {[0] = offset})
	-- end	
		
	offset = offset + width + 5
	
	local args = {...}
	
	for i,v in ipairs(args) do
		if v == "__self" then
			args[i] = label
		end
	end
	
	addEventHandler("onClientGUIClick", label, 
		function(button, state)
			if button == "left" and state == "up" then
				if onClick then 
					onClick(unpack(args or {})) 
				end 
			end
		end, 
	false)
	setRolloverColour(label, gColours.primary, gWindowTitlebarButtons.defaultColour)
	--addEventHandler("onClientMouseEnter", label, function() guiLabelSetColor(label, unpack(gColours.primary)) end, false)
	--addEventHandler("onClientMouseLeave", label, function() guiLabelSetColor(label, unpack(gWindowTitlebarButtons.defaultColour)) end, false)
	
	setElementData(window, "guieditor:titlebarButton_" .. alignment, offset)
end

ExpandingGridList = {
	parentExpandedPrefix = "- ",
	parentCollapsedPrefix = "+ ",
	childPrefix = "      ",
}

ExpandingGridList.__index = ExpandingGridList

function ExpandingGridList:create(x, y, w, h, relative, parent)
	local gridlist = guiCreateGridList(x, y, w, h, relative, parent)
	guiGridListSetSortingEnabled(gridlist, false)

	local new = setmetatable(
		{
			x = x,
			y = y,
			w = w,
			h = h,
			parent = parent,
			gridlist = gridlist,
		},
		ExpandingGridList
	)
	
	addEventHandler("onClientGUIDoubleClick", gridlist,
		function(button, state)
			if button == "left" and state == "up" then
				local row, col = guiGridListGetSelectedItem(source)
				
				if row and col and row ~= -1 and col ~= -1 then
					ExpandingGridList.doubleClickRowHandler(new, row, col)
				end
			end
		end
	, false)
	
	addEventHandler("onClientGUIClick", gridlist,
		function(button, state)
			if button == "left" and state == "up" then
				local row, col = guiGridListGetSelectedItem(source)
				
				if row and col and row ~= -1 and col ~= -1 then
					ExpandingGridList.clickRowHandler(new, row, col)
				end
			end
		end
	, false)
	
	doOnChildren(gridlist, setElementData, "guieditor.internal:noLoad", true)
	
	return new
end


function ExpandingGridList:addColumn(colName, width)
	guiGridListAddColumn(self.gridlist, colName, width or 2)
end

function ExpandingGridList:destroy()
	destroyElement(self.gridlist)
	self = nil
end

function ExpandingGridList:open()
	guiSetVisible(self.gridlist, true)
end


function ExpandingGridList:close()
	if self.expanded then
		self:collapseRow(self.expanded.row, self.expanded.col)
	end
	
	guiSetVisible(self.gridlist, false)
end


function ExpandingGridList:setData(data, sortedData, autoExpand)
	self.data = data
	
	self:populate(data, sortedData)
	
	if autoExpand then
		for i = 1, guiGridListGetRowCount(self.gridlist) do
			local text = guiGridListGetItemText(self.gridlist, i, 1)
			text = self:stripPrefix(text)
			
			if text == autoExpand then
				self:expandRow(i, 1)
				break
			end
		end
	end
end


function ExpandingGridList:populate(data, sortedData)
	guiGridListClear(self.gridlist)
	
	self.expanded = nil
	
	if sortedData then
		for _,text in ipairs(sortedData) do
			if not tonumber(self.maxRows) or guiGridListGetRowCount(self.gridlist) < tonumber(self.maxRows) then
				local row = guiGridListAddRow(self.gridlist)

				if self.data[text] then
					--guiGridListSetItemText(self.gridlist, row, 1, ExpandingGridList.parentCollapsedPrefix .. text, false, false)
					self:setRowText(row, 1, ExpandingGridList.parentCollapsedPrefix, text)
				else
					self:setRowText(row, 1, "", text)
					--guiGridListSetItemText(self.gridlist, row, 1, text, false, false)
				end
			end
		end
	else
		for text,_ in pairs(data) do
			if not tonumber(self.maxRows) or guiGridListGetRowCount(self.gridlist) < tonumber(self.maxRows) then
				local row = guiGridListAddRow(self.gridlist)
				
				if self.data[text.text or text] then
					self:setRowText(row, 1, ExpandingGridList.parentCollapsedPrefix, text.text or text)
					--guiGridListSetItemText(self.gridlist, row, 1, ExpandingGridList.parentCollapsedPrefix .. (text.text or text), false, false)
				else
					self:setRowText(row, 1, "", text.text or text)
					--guiGridListSetItemText(self.gridlist, row, 1, text.text or text, false, false)
				end
			end
		end	
	end
	
	if self.onPopulated then
		self.onPopulated()
	end
end


function ExpandingGridList:setRowText(row, col, prefix, text, data)
	if row and col and row ~= -1 and col ~= -1 then
		guiGridListSetItemText(self.gridlist, row, col, prefix .. text, false, false)
		
		text = self:stripPrefix(text)
		
		if self.onRowSetText then
			self.onRowSetText(row, col, text)
		end
		
		if data then
			guiGridListSetItemData(self.gridlist, row, col, data)
		end
	end
end


function ExpandingGridList:doubleClickRowHandler(row, col)
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)
	
	if self.data then
		if self.data[text] then
			self:expandRow(row, col)
		else
			self:doubleClickRow(row, col)
		end
	end
end


function ExpandingGridList:clickRowHandler(row, col)
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)
	
	if self.data then
		if self.data[text] then
			self:clickHeader(row, col)
		else
			self:clickRow(row, col)
		end
	end
end


function ExpandingGridList:expandRow(row, col)
	if self.expanded then
		local same = self.expanded.row == row
		
		if (self.expanded.row < row) then
			local text = guiGridListGetItemText(self.gridlist, self.expanded.row, self.expanded.col)
			text = self:stripPrefix(text)

			row = row - #self.data[text]
		end		
		
		self:collapseRow(self.expanded.row, self.expanded.col)
		
		if same then
			return
		end
	end
	
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)
	
	self:setRowText(row, col, ExpandingGridList.parentExpandedPrefix, text)
	--guiGridListSetItemText(self.gridlist, row, col, ExpandingGridList.parentExpandedPrefix .. text, false, false)
	
	self.expanded = {row = row, col = col}
	
	if not self.data then
		return
	end	
	
	for i,data in ipairs(self.data[text]) do
		guiGridListInsertRowAfter(self.gridlist, row + (i - 1))
		
		self:setRowText(row + i, col, ExpandingGridList.childPrefix, type(data) == "string" and data or tostring(data.text))
		--guiGridListSetItemText(self.gridlist, row + i, col, ExpandingGridList.childPrefix .. (type(data) == "string" and data or tostring(data.text)), false, false)
		guiGridListSetItemData(self.gridlist, row + i, col, data)
	end
	
	if self.onRowExpand then
		self.onRowExpand(row, col, text, self.onRowExpandArgs and unpack(self.onRowExpandArgs) or {})
	end
end


function ExpandingGridList:collapseRow(row, col)
	if not self.expanded then
		return
	end
	
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)
	
	self:setRowText(row, col, ExpandingGridList.parentCollapsedPrefix, text)
	--guiGridListSetItemText(self.gridlist, row, col, ExpandingGridList.parentCollapsedPrefix .. text, false, false)
	
	self.expanded = nil
	
	if not self.data then
		return
	end		
	
	for i = #self.data[text], 1, -1 do
		guiGridListRemoveRow(self.gridlist, row + i)
	end		
	
	if self.onRowCollapse then
		self.onRowCollapse(row, col, text, self.onRowCollapseArgs and unpack(self.onRowCollapseArgs) or {})
	end
end


function ExpandingGridList:doubleClickRow(row, col)
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)
	
	local resource
	
	if self.expanded then
		resource = guiGridListGetItemText(self.gridlist, self.expanded.row, self.expanded.col)
		resource = tostring(resource):sub(#ExpandingGridList.parentExpandedPrefix + 1)	
	end

	local data = guiGridListGetItemData(self.gridlist, row, col)
	
	if self.onRowDoubleClick then
		self.onRowDoubleClick(row, col, text, resource, data, self.onRowDoubleClickArgs and unpack(self.onRowDoubleClickArgs) or {})
	end
end


function ExpandingGridList:clickRow(row, col)
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)

	local resource
	
	if self.expanded then
		resource = guiGridListGetItemText(self.gridlist, self.expanded.row, self.expanded.col)
		resource = self:stripPrefix(resource)
	end
	
	local data = guiGridListGetItemData(self.gridlist, row, col)

	if self.onRowClick then
		self.onRowClick(row, col, text, resource, data, self.onRowClickArgs and unpack(self.onRowClickArgs) or {})
	end
end


function ExpandingGridList:clickHeader(row, col)
	local text = guiGridListGetItemText(self.gridlist, row, col)
	text = self:stripPrefix(text)
	
	if self.onHeaderClick then
		self.onHeaderClick(row, col, text, self.onHeaderClickArgs and unpack(self.onHeaderClickArgs) or {})
	end
end


function ExpandingGridList:stripPrefix(text)
	if not text then
		return ""
	end
	
	text = tostring(text)
	
	if text:sub(0, #ExpandingGridList.childPrefix) == ExpandingGridList.childPrefix then
		text = text:sub(#ExpandingGridList.childPrefix + 1)
	elseif text:sub(0, #ExpandingGridList.parentCollapsedPrefix) == ExpandingGridList.parentCollapsedPrefix then
		text = text:sub(#ExpandingGridList.parentCollapsedPrefix + 1)
	elseif text:sub(0, #ExpandingGridList.parentExpandedPrefix) == ExpandingGridList.parentExpandedPrefix then
		text = text:sub(#ExpandingGridList.parentExpandedPrefix + 1)
	end
	
	return text
end

function doOnChildren(element, func, ...)
	func(element, ...)

	for _,e in ipairs(getElementChildren(element)) do
		doOnChildren(e, func, ...)
	end
end

function guiSetColour(element, r, g, b, a)
	if exists(element) then
		local t = stripGUIPrefix(getElementType(element))
		
		if t == "label" then
			guiLabelSetColor(element, r, g, b)
		elseif t == "window" then
			guiSetProperty(element, "CaptionColour", rgbaToHex(r, g, b, a))
		elseif t == "staticimage" then
			local col = rgbaToHex(r, g, b, a)
			
			guiSetProperty(element, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col), tostring(col), tostring(col), tostring(col)))
		elseif t == "combobox" then
			guiSetProperty(element, "NormalEditTextColour", rgbaToHex(r, g, b, a))
		else
			guiSetProperty(element, "NormalTextColour", rgbaToHex(r, g, b, a))
		end
	end
end

function exists(e)
	return e and isElement(e)
end

function stripGUIPrefix(s)
	if type(s) == "string" then
		return s:sub(5)
	else
		--outputDebug("Invalid type "..type(s).." in stripGUIPrefix", "GENERAL")
		return ""
	end
end

--[[--------------------------------------------------
	GUI Editor
	client
	message_box.lua
	
	manages various types of generic message box
--]]--------------------------------------------------


MessageBox = {}
MessageBox.__index = MessageBox


function MessageBox:create(x, y, w, h)
	w = w or 300
	h = h or 150

	x = x or ((gScreen.x - w) / 2)
	y = y or ((gScreen.y - h) / 2)

	local new = setmetatable(
		{
			x = x,
			y = y,
			w = w,
			h = h,
			window = guiCreateWindow(x, y, w, h, "", false),
		},
		MessageBox
	)
	
	guiWindowSetSizable(new.window, false)
	guiWindowSetMovable(new.window, false)
	guiSetProperty(new.window, "AlwaysOnTop", "True")
	
	doOnChildren(new.window, setElementData, "guieditor.internal:noLoad", true)

	return new
end


function MessageBox:close()
	if self.onClose then
		self.onClose(unpack(self.onCloseArgs or {}))
	end
	
	if exists(self.window) then
		destroyElement(self.window)
	end
	
	self = nil
end



--[[----------------------------------------------

]]------------------------------------------------
MessageBox_Error = {}

setmetatable(MessageBox_Error, {__index = MessageBox})

function MessageBox_Error:create()
	local item = MessageBox:create()
	
	--item.blah = blah
	
	item = setmetatable(item, {__index = MessageBox_Error})
	
	return item
end



--[[----------------------------------------------
	A message box with affirmative and negative choices
]]------------------------------------------------
MessageBox_Continue = {}

setmetatable(MessageBox_Continue, {__index = MessageBox})

function MessageBox_Continue:create(message, yes, no)
	local item = MessageBox:create()
	
	item = setmetatable(item, {__index = MessageBox_Continue})
	
	guiSetText(item.window, "Warning")
	guiWindowSetMovable(item.window, true)
	
	item.description = guiCreateLabel(0.05, 0.15, 0.9, 0.6, tostring(message), true, item.window)
	guiLabelSetHorizontalAlign(item.description, "center", true)
	
	item.buttonYes = guiCreateButton(0.1, 0.8, 0.3, 0.15, yes or "Yes", true, item.window)
	item.buttonNo = guiCreateButton(0.6, 0.8, 0.3, 0.15, no or "No", true, item.window)
	--guiSetColour(item.buttonYes, unpack(gColours.secondary))
	--guiSetColour(item.buttonNo, unpack(gColours.secondary))
	
	addEventHandler("onClientGUIClick", item.buttonYes,
		function(button, state)
			if button == "left" and state == "up" then
				item:affirmative()
			end
		end
	, false)
	
	addEventHandler("onClientGUIClick", item.buttonNo,
		function(button, state)
			if button == "left" and state == "up" then
				item:negative()
			end
		end
	, false)	

	-- this doesn't work, maybe problem with passing custom metatables through bind args?
	--bindKey("enter", "down", item.affirmative, item)
	
	item.bindFunc = function() item:affirmative() end
	bindKey("enter", "down", item.bindFunc)

	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)
	
	return item
end


function MessageBox_Continue:affirmative()
	if self.onAffirmative then
		self.onAffirmative(unpack(self.onAffirmativeArgs or {}))
	end
	
	if self.bindFunc then
		unbindKey("enter", "down", self.bindFunc)
	end
	
	self:close()
end


function MessageBox_Continue:negative()
	if self.onNegative then
		self.onNegative(unpack(self.onNegativeArgs or {}))
	end
	
	if self.bindFunc then
		unbindKey("enter", "down", self.bindFunc)
	end
	
	self:close()
end



--[[----------------------------------------------
	message box with input area
]]------------------------------------------------
MessageBox_Input = {}

setmetatable(MessageBox_Input, {__index = MessageBox})

function MessageBox_Input:create(multiline, title, description, acceptText)
	local item = MessageBox:create(nil, nil, nil, 120)
	
	guiSetText(item.window, title or "Set Text")
	guiWindowTitlebarButtonAdd(item.window, "Close", "right", function() item:close() end)
	
	item.multiline = multiline
	
	if multiline then
		guiWindowTitlebarButtonAdd(item.window, "Multi-line", "left", 
			function()  
				local w,h  = guiGetSize(item.window, false)
				
				if guiGetVisible(item.inputMemo) then
					guiSetSize(item.window, w, 120, false)
					guiSetVisible(item.inputMemo, false)
					guiSetVisible(item.input, true)
					
					guiSetPosition(item.buttonChange, (item.w - 100) / 2, item.h - 30, false)
					
					guiSetText(item.input, string.gsub(guiGetText(item.inputMemo), "\n", "\\n"):sub(1, -3))
					guiBringToFront(item.input)
				else
					guiSetSize(item.window, w, 270, false)
					guiSetSize(item.inputMemo, w - 20, 180, false)
					guiSetVisible(item.inputMemo, true)
					guiSetVisible(item.input, false)
					
					guiSetPosition(item.buttonChange, (item.w - 100) / 2, 270 - 30, false)
					
					guiSetText(item.inputMemo, string.gsub(guiGetText(item.input), "\\n", "\n"))
					guiBringToFront(item.inputMemo)
				end
			end
		)
	end
	
	item.description = guiCreateLabel(10, 25, item.w - 20, 20, description or "Enter the new text:", false, item.window)
	guiLabelSetHorizontalAlign(item.description, "center", true)
	
	item.input = guiCreateEdit(10, item.h - 10 - 20 - 40, item.w - 20, 30, "", false, item.window)
	guiBringToFront(item.input)
	item.inputMemo = guiCreateMemo(10, 50, item.w - 20, 200, "", false, item.window)
	guiSetVisible(item.inputMemo, false)
	
	item.buttonChange = guiCreateButton((item.w - 100) / 2, item.h - 30, 100, 20, acceptText or "Update text", false, item.window)
	
	-- do this instead
	addEventHandler("onClientGUIAccepted", item.input,
		function() 
			item:updateText()
		end,
	false)	
	
	addEventHandler("onClientGUIClick", item.buttonChange,
		function(button, state)
			if button == "left" and state == "up" then
				item:updateText()
			end
		end
	, false)
	
	item = setmetatable(item, {__index = MessageBox_Input})
	
	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)
	
	return item
end


function MessageBox_Input:descriptionLines(lines)
	local more = lines * 15
	
	local w, h = guiGetSize(self.window, false)
	guiSetSize(self.window, w, h + more, false)
	self.h = self.h + more
	
	guiSetSize(self.description, self.w - 20, 20 + more, false)
	
	guiSetPosition(self.input, 10, self.h - 10 - 20 - 40, false)

	guiSetPosition(self.buttonChange, (self.w - 100) / 2, self.h - 30, false)
end


function MessageBox_Input:setText(text)
	guiSetText(self.input, text:gsub("\n", "\\n"))
	guiSetText(self.inputMemo, text)	
end


function MessageBox_Input:maxLength(length)
	guiSetProperty(self.input, "MaxTextLength", length)
	guiSetProperty(self.inputMemo, "MaxTextLength", length)
end

function MessageBox_Input:updateText()
	local text = guiGetText(self.input)
			
	if guiGetVisible(self.inputMemo) then
		text = guiGetText(self.inputMemo):sub(1, -2)
	end
	
	if self.onAccept then
		self.onAccept(text, unpack(self.onAcceptArgs or {}))
	else
		if self.element then
			if self.multiline then
				guiSetText(self.element, text:gsub("\\n","\n"))
			else
				guiSetText(self.element, text)
			end
			
			if self.onPostAccept then
				self.onPostAccept(unpack(self.onPostAcceptArgs or {}))
			end
		end
	end
	
	if self.bindFunc then
		unbindKey("enter", "down", self.bindFunc)
	end

	self:close()
end



--[[----------------------------------------------
	message box with double input area (ie: for x/y or w/h)
]]------------------------------------------------
MessageBox_InputDouble = {}

setmetatable(MessageBox_InputDouble, {__index = MessageBox})

function MessageBox_InputDouble:create(title, leftDesc, rightDesc, filter)
	local item = MessageBox:create(nil, nil, nil, 120)
	
	guiSetText(item.window, title or "Set Values")
	guiWindowTitlebarButtonAdd(item.window, "Close", "right", function() item:close() end)
		
	item.descriptionLeft = guiCreateLabel(10, 30, (item.w / 2) - 20, 25, leftDesc or "Value 1:", false, item.window)	
	guiLabelSetHorizontalAlign(item.descriptionLeft, "center", true)
	item.descriptionRight = guiCreateLabel((item.w / 2) + 10, 30, (item.w / 2) - 20, 25, rightDesc or "Value 2:", false, item.window)	
	guiLabelSetHorizontalAlign(item.descriptionRight, "center", true)
	
	item.inputLeft = guiCreateEdit(10, 55, (item.w / 2) - 20, 30, "", false, item.window)
	item.inputRight = guiCreateEdit((item.w / 2) + 10, 55, (item.w / 2) - 20, 30, "", false, item.window)
	setElementData(item.inputLeft, "guieditor:filter", filter)
	setElementData(item.inputRight, "guieditor:filter", filter)
	
	guiBringToFront(item.inputLeft)
	
	item.buttonChange = guiCreateButton((item.w - 100) / 2, item.h - 30, 100, 20, "Accept", false, item.window)
	
	item = setmetatable(item, {__index = MessageBox_InputDouble})
	
	addEventHandler("onClientGUIClick", item.buttonChange,
		function(button, state)
			if button == "left" and state == "up" then
				item:accept()
			end
		end
	, false)
	
	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)
	
	return item
end


function MessageBox_InputDouble:accept()
	if self.onAccept then
		local valueLeft = guiGetText(self.inputLeft)
		local valueRight = guiGetText(self.inputRight)
		
		self.onAccept(valueLeft, valueRight, unpack(self.onAcceptArgs or {}))
	end

	self:close()
end



--[[----------------------------------------------
	message box with information text and a single accept button
]]------------------------------------------------
MessageBox_Info = {}

setmetatable(MessageBox_Info, {__index = MessageBox})

function MessageBox_Info:create(title, information)
	local item = MessageBox:create()
	
	item = setmetatable(item, {__index = MessageBox_Info})
	
	guiSetText(item.window, title or "Information")
	guiWindowSetMovable(item.window, true)
	guiWindowTitlebarButtonAdd(item.window, "Close", "right", function() item:close() end)
	
	item.description = guiCreateLabel(0.05, 0.15, 0.9, 0.6, tostring(information), true, item.window)
	guiLabelSetHorizontalAlign(item.description, "center", true)
	guiLabelSetVerticalAlign(item.description, "center")
	
	item.accept = guiCreateButton(0.25, 0.8, 0.5, 0.15, "Ok", true, item.window)
	--guiSetColour(item.accept, unpack(gColours.secondary))
	
	guiBringToFront(item.window)
	
	addEventHandler("onClientGUIClick", item.accept,
		function(button, state)
			if button == "left" and state == "up" then
				item:close()
			end
		end
	, false)

	item.bindFunc = function() item:close() end
	bindKey("enter", "down", item.bindFunc)
	
	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)

	return item
end

