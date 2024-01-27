local TextWidget = require('ngui.widgets.text')
local Label = require('ngui.class'){ __includes = TextWidget }

function Label:layout()
	TextWidget.layout(self)

	self.width = self.drawable:getWidth()
	self.height = self.drawable:getHeight()
end

function Label:draw()
	TextWidget.draw(self)

	local x, y = unpack(self:getStyle('padding') or { 0, 0 })
	self:drawText(x, y)
end

return Label
