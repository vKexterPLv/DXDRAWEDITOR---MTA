-- skalowanie
local sclX, sclY = 1920, 1080
scr = Vector2(guiGetScreenSize())
zoom = scr.x < 2048 and math.min(2, 2048/scr.x) or 0.9;

function scaleX(posX)
    return (posX - (-sclX)) / (sclX - (-sclX)) * scr.x
end

function scaleY(posY)
    return (posY - (-sclY)) / (sclY - (-sclY)) * scr.y
end

-- odwrotne skalowanie (z pozycji ekranu na przestrzeń -1920 do 1920)
function unscaleX(screenX)
    return (screenX / scr.x) * (sclX - (-sclX)) + (-sclX)
end

function unscaleY(screenY)
    return (screenY / scr.y) * (sclY - (-sclY)) + (-sclY)
end

function scaleImage(value)
    return value/zoom
end 

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function getDistanceBetweenMouseAndElement2D(element)
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	local centerX,centerY = element.x+element.w/2,element.y+element.h/2
	
	-- if isMouseInPosition(element.x,element.y,element.w,element.h) then 
		-- cx,cy = cx+20,cy+20
	-- else
		-- cx,cy = cx+10,cy+10
	-- end
	
	
	local dx,dy = cx-centerX,cy-centerY
	
	return math.sqrt(dx*dx+dy*dy)
end

function getAnchorPoint(x,y,w,h)
	local anchorX,anchorY

	local centerX = x+w/2
	local centerY = y+h/2
	
	local leftLimit = sclX*0.25
	local rightLimit = sclX*0.75
	local topLimit = sclY*0.25
	local downLimit = sclY*0.75

	if centerX < leftLimit then
		anchorX = "left"
	elseif centerX > rightLimit then
		anchorX = "right"
	else
		anchorX = "center"
	end

	if centerY < topLimit then
		anchorY = "top"
	elseif centerY > downLimit then
		anchorY = "down"
	else
		anchorY = "center"
	end
	
	return anchorX,anchorY
end

-- scr.x/2-(self.x*zoom)/zoom

function returnScaleXString(x,anchorX)
	-- local x = x * zoom
	
	if anchorX == "left" then
		return (x*zoom).."/zoom"
	end
	if anchorX == "center" then
		return "scr.x/2 - ("..((scr.x/2-x)*zoom)..")/zoom"
	end
	if anchorX == "right" then
		return "scr.x - "..((scr.x-x)*zoom).."/zoom"
	end
end

function returnScaleYString(y,anchorY)

	if anchorY == "top" then
		return (y*zoom).."/zoom"
	end
	if anchorY == "center" then
		return "scr.y/2 - ("..((scr.y/2-y)*zoom)..")/zoom"
	end
	if anchorY == "down" then
		return "scr.y - "..((scr.y-y)*zoom).."/zoom"
	end
end

-- function reverse_pairs(t)
	-- local i = #t + 1
	-- return function()
		-- i = i - 1
		-- if i > 0 then
			-- local v = t[i]
			-- if v then
				-- return i, v
			-- end
		-- end
	-- end
-- end

function reverse_pairs(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys,k)
	end
	table.sort(keys, function(a,b) return a > b end)
	local i = 0
	return function()
		i = i + 1
		local key = keys[i]
		if key then
			return key, t[key]
		end
	end
end

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function isMouseInCircle(cx,cy,radius)
	if ( not isCursorShowing( ) ) then
		return false
	end
	local mx,my = getCursorPosition()
	local sx,sy = guiGetScreenSize()
	mx = mx*sx
	my = my*sy
	
	local dx = mx - cx
	local dy = my - cy
	local distance = math.sqrt(dx*dx + dy*dy)
	
	return distance <= radius
end


-- iprint(returnScaleYString(scr.y/2-20,40,"center"))

-- iprint(unscaleX(scr.x))