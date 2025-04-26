local getImageTime = {}
local getFontTime = {}

local images = {
	routine,
	images = {},
	waiting = {},
}

local files = {}

local resourceName = getResourceName(getThisResource())

addEvent("guieditor:server_getImages", true)
addEventHandler("guieditor:server_getImages", root, function()
		-- stop people being able to spam this
		if getImageTime[client] then
			if getImageTime[client] > (getTickCount() - 30000) then
				triggerClientEvent(client, "guieditor:client_getImages", client, false)
				return
			end
		end
		
		getImageTime[client] = getTickCount()
		
		files.png = { waiting = {}, files = {}, routine}
		
		files.png.waiting[client] = true
		
		if not files.png.routine or coroutine.status(files.png.routine) == "dead" then
			files.png.routine = coroutine.create(findFilesByType)
			coroutine.resume(files.png.routine, "png", "client_getImages")
		end
	end
)


addEvent("guieditor:server_getFonts", true)
addEventHandler("guieditor:server_getFonts", root,
	function()
		-- stop people being able to spam this
		if getFontTime[client] then
			if getFontTime[client] > (getTickCount() - 30000) then
				triggerClientEvent(client, "guieditor:client_getFonts", client)
				return
			end
		end
		
		getFontTime[client] = getTickCount()
		
		files.ttf = { waiting = {}, files = {}, routine}
		
		files.ttf.waiting[client] = true
		
		if not files.ttf.routine or coroutine.status(files.ttf.routine) == "dead" then
			files.ttf.routine = coroutine.create(findFilesByType)
			coroutine.resume(files.ttf.routine, "ttf", "client_getFonts")
		end
	end
)

function findFilesByType(extension, event)
	files[extension].files = {}
	local tick = getTickCount() + 600
	local permission = true

	for i,res in ipairs(getResources()) do
		local resourceName = tostring(getResourceName(res))
			
		if hasObjectPermissionTo(resource, "general.ModifyOtherObjects") then
			if fileExists(":"..resourceName.."/meta.xml") then
				local root = xmlLoadFile(":"..resourceName.."/meta.xml")
					
				if root then
					local index = 0
					local node = xmlFindChild(root, "file", index)
					local count = 1
					
					while node do
						local src = xmlNodeGetAttribute(node, "src")
							
						if src and src:sub(-#extension) == extension then
							if not files[extension].files[resourceName] then
								files[extension].files[resourceName] = {}
							end

							files[extension].files[resourceName][count] = {text = src}
							count = count + 1
						end
						
						if getTickCount() > tick then
							setTimer(
								function()
									tick = getTickCount() + 600
									coroutine.resume(files[extension].routine)
								end
							, 400, 1)
						
							coroutine.yield(files[extension].routine)
						end
						
						index = index + 1
						node = xmlFindChild(root, "file", index)
					end
					
					xmlUnloadFile(root)
				end
			end
		else
			permission = false
		end
	end
	
	if not permission then
		outputDebugString("GUI Editor requires ACL permission: general.ModifyOtherObjects to get ."..tostring(extension).." file list")
	end

	for player in pairs(files[extension].waiting) do
		iprint(permission)
		triggerClientEvent(player, "guieditor:" .. event, player, files[extension].files, permission)
	end
end

function readFile(path)
    local file = fileOpen(path) -- attempt to open the file
    if not file then
        return false -- stop function on failure
    end
    local count = fileGetSize(file) -- get file's total size
    local data = fileRead(file, count) -- read whole file
    fileClose(file) -- close the file once we're done with it
    return data
end

function saveToFile(filename,data)
	local fileHandle = fileCreate("filesForSave/"..filename..".lua")             -- attempt to create a new file
	if fileHandle then                                    -- check if the creation succeeded
		fileWrite(fileHandle, data)     -- write a text line
		fileClose(fileHandle)                             -- close the file once you're done with it
	end
end

function saveRawGUI(filename,data)
	saveToFile(filename,readFile("filesForSave/baseplate.txt"))
	local file = fileOpen("filesForSave/"..filename..".lua")
	if file then
		fileSetPos(file,fileGetSize(file))
		for k,v in pairs(data) do
			fileWrite(file,v)
		end
		fileClose(file)
	end
end

addEvent("guieditor:server_saveFile", true)
addEventHandler("guieditor:server_saveFile", root, function(lines)
	local t = getRealTime()		
	local filename = string.format("%s_%d-%d-%d_%d-%d", "output", t.year + 1900, t.month + 1, t.monthday, t.hour, t.minute)
	saveRawGUI(filename,lines)
end)
