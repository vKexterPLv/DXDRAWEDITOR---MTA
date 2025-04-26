local FontPicker = {}
FontPicker.__index = FontPicker

function FontPicker:new()
	local instance = {}
	setmetatable(instance,FontPicker)
	if instance:constructor() then
		return instance
	end
	return false
end

function FontPicker:constructor()
	self.showing = false
	self.callback = false

	self.func = {}
	self.func.destroy = function() self:clearUp() end
	return true
end

function FontPicker:clearUp()
	self.browserGrid:destroy()
	destroyElement(self.browserWarning)
	destroyElement(self.browser)
	
	self.showing = false
end

function FontPicker:buildUp()
	self.browser = guiCreateWindow((gScreen.x - 250) / 2, (gScreen.y - 300) / 2, 250, 300, "Font picker", false)
	self.browserGrid = ExpandingGridList:create(5, 23, 240, 220, false, self.browser)
	self.browserGrid:addColumn("Resource fonts")
	guiGridListAddRow(self.browserGrid.gridlist)
	guiGridListSetItemText(self.browserGrid.gridlist, 0, 1, "Loading...", true, false)
	
	self.browserWarning = guiCreateLabel(5, 240, 240, 60, "", false, self.browser)
	guiLabelSetHorizontalAlign(self.browserWarning, "center")
	guiLabelSetVerticalAlign(self.browserWarning, "center")
	guiSetFont(self.browserWarning, "default-bold-small")
	guiSetColour(self.browserWarning, unpack(gColours.primary))
	
	guiWindowTitlebarButtonAdd(self.browser, "Close", "right", self.func.destroy)

	guiWindowTitlebarButtonAdd(self.browser, "Reload", "left", function() 
		if not self.reloading then
			self.reloading = true	
			triggerServerEvent("guieditor:server_getFonts", localPlayer)
		end
	end)			
	
	self.browserGrid.onRowClick = function(row, col, text, resource)
		self.current = nil
		
		if fileExists(":" .. resource .. "/" .. text) then
			self.current = {
				row = row,
				col = col,
				text = text,
				resource = resource
			}
		else
			self.current = {
				resource = resource
			}
		end
	end	
		
	self.browserGrid.onHeaderClick = function()
		self.current = nil
	end
	
	self.browserGrid.onRowDoubleClick = function(row, col, text, resource)
		if row and col and resource and text and fileExists(":" .. resource .. "/" .. text) then
			self:clearUp()
			-- iprint(resource)
			self.callback(":"..resource.."/"..self.current.text,true)
		else
			guiSetText(self.browserWarning, "Please start the resource\n'"..resource.."'\nto use this font")
		end
	end
	
	guiFocus(self.browser)
end

function FontPicker:show(callback)
	if self.showing then return end
	self:buildUp()
	self.showing = true
	self.callback = callback
	triggerServerEvent("guieditor:server_getFonts", localPlayer)
end

fontPicker = FontPicker:new()

addEvent("guieditor:client_getFonts", true)
addEventHandler("guieditor:client_getFonts", root, 
	function(files, permission)
		if files then
			local sortable = {}
			
			for name,_ in pairs(files) do
				sortable[#sortable + 1] = name
			end
								
			table.sort(sortable)
					
			fontPicker.browserData = {files = files, sorted = sortable}
			
			local permissionWarning = ""
			
			if isBool(permission) and not permission then
				permissionWarning = "\n\n(Access to general.ModifyOtherObjects is needed to request fonts)"
			end
			
			if guiGetVisible(fontPicker.browser) then
				if fontPicker.browser then
					fontPicker.browserGrid:setData(files, sortable)
				end
			end
				
			if fontPicker.reloading then			
				local m
				if #sortable > 0 then
					m = MessageBox_Info:create("Font Picker Refresh", "Font list successfully updated from the server.")
				else
					m = MessageBox_Info:create("Font Picker Refresh", "Could not get font list from the server.\n\nPlease check ACL permissions" .. permissionWarning)				
				end
				
				guiSetProperty(m.window, "AlwaysOnTop", "True")
			else
				if #sortable == 0 then				
					local m = MessageBox_Info:create("Font Picker Refresh", "Could not get font list from the server.\n\nPlease check ACL permissions" .. permissionWarning)
					guiSetProperty(m.window, "AlwaysOnTop", "True")					
				end
			end
		else
			if fontPicker.reloading then
				local m = MessageBox_Info:create("Font Picker Refresh", "Font list could not be updated from the server (request limit reached).\n\nTry again later.")
				guiSetProperty(m.window, "AlwaysOnTop", "True")
			end
		end
		
		fontPicker.reloading = nil
end)	