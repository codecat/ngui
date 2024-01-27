local TextWidget = require('ngui.widgets.text')
local Button = require('ngui.class'){ __includes = TextWidget }

function Button:init()
	TextWidget.init(self)

	self:setStyle('padding', '10 10')
	self:setStyle('align', 'left')
	self:setStyle('wrapwidth', 0)

	self:setStyle('color', 0xFFFFFFFF)
	self:setStyle('background', 0x4C1919FF)
	self:setStyle('background', 0x993333FF, 'hover')
	self:setStyle('background', 0x331414FF, 'active')

	self.on_click = ''
end

function Button:layout()
	TextWidget.layout(self)

	self.width = self:getStyle('width') or self.drawable:getWidth()
	self.height = self:getStyle('height') or self.drawable:getHeight()
end

function Button:draw()
	TextWidget.draw(self)

	local padding = self:getStyle('padding') or { 0, 0 }
	self:drawText(unpack(padding))
end

function Button:mouseUp(x, y, button)
	TextWidget.mouseUp(x, y, button)

	if self.on_click ~= '' then
		self.host:callback(self.on_click, self)
	end
end

return Button
