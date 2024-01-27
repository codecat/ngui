local TextWidget = require('ngui.widgets.text')
local Icon = require('ngui.class'){ __includes = TextWidget }

local ForkAwesome = require('ngui.tools.fork-awesome')

function Icon:init()
	TextWidget.init(self)

	self:setStyle('font', 'ngui/assets/fa.ttf')
	self:setStyle('fontsize', 18)
end

function Icon:content(text)
	self:setIcon(text)
end

function Icon:setIcon(id)
	local icon = ForkAwesome[id]
	if icon ~= nil then
		self.text = icon
	end
end

function Icon:layout()
	TextWidget.layout(self)

	self.width = self.drawable:getWidth()
	self.height = self.drawable:getHeight()
end

function Icon:draw()
	TextWidget.draw(self)

	local x, y = unpack(self:getStyle('padding') or { 0, 0 })
	self:drawText(x, y)
end

return Icon
