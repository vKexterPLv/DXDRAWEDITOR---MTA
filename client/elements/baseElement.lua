Shape = {}
resizeAreaSize = scaleImage(10)

function Shape:new(...)
    return new(self, ...)
end

function Shape:delete(...)
    return delete(self, ...)
end

function Shape:draw()
	self:drawShape()
end

function Shape:destructor()
	self:destroyWholeShit()
	self = nil
end

-- Item.__call = Item.new
-- setmetatable(Item, {__call = Item.__call})