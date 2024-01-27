local TextWidget = require('ngui.widgets.text')
local Checkbox = require('ngui.class'){ __includes = TextWidget }

function Checkbox:init()
	TextWidget.init(self)

	self:mapStyle('fill', require('ngui.styles.color'))
	self:mapStyle('checkborder', require('ngui.styles.color'))

	self:setStyle('checksize', 24)
	self:setStyle('fillsize', 0.8, 'checked')
	self:setStyle('spacing', 8)

	self:setStyle('checkborder', 0x4C1919FF)
	self:setStyle('checkborder', 0x993333FF, 'hover')

	self:setStyle('fill', 0x4C1919FF, 'checked')

	self.on_click = ''
end

function Checkbox:layout()
	TextWidget.layout(self)

	local checkSize = self:getStyle('checksize')
	local spacing = self:getStyle('spacing')

	self.width = checkSize + spacing + self.drawable:getWidth()
	self.height = checkSize
end

function Checkbox:isChecked()
	return self:stateIndex('checked') > 0
end

function Checkbox:setChecked(checked)
	if self:isChecked() == checked then
		return
	end

	if checked then
		self:addState('checked')
	else
		self:removeState('checked')
	end
end

function Checkbox:toggleChecked()
	if self:isChecked() then
		self:removeState('checked')
	else
		self:addState('checked')
	end
end

function Checkbox:mouseUp(x, y, button)
	TextWidget.mouseUp(x, y, button)

	self:toggleChecked()

	if self.on_click ~= '' then
		self.host:callback(self.on_click, self)
	end
end

function Checkbox:draw()
	TextWidget.draw(self)

	local checkSize = self:getStyle('checksize')
	local spacing = self:getStyle('spacing')
	local padding = self:getStyle('padding') or { 0, 0 }

	love.graphics.push()
	love.graphics.translate(unpack(padding))

	local fill = self:getStyle('fill')
	if fill ~= nil then
		love.graphics.setColor(fill)

		local fillSize = self:getStyle('fillsize')
		local fillWidth = math.floor(checkSize * fillSize + 0.5)
		local fillHeight = math.floor(checkSize * fillSize + 0.5)

		love.graphics.rectangle(
			'fill',
			math.floor(checkSize / 2 - fillWidth / 2 + 0.5),
			math.floor(checkSize / 2 - fillHeight / 2 + 0.5),
			fillWidth,
			fillHeight
		)
	end

	--TODO: This is separate from the existing 'border' style so it's
	--      kind of inconsistent as it doesn't share the same properties
	--      such as 'border_radius' and 'border_width'
	local border = self:getStyle('checkborder')
	if border ~= nil then
		love.graphics.setColor(border)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line', 0.5, 0.5, checkSize, checkSize)
	end

	self:drawText(
		checkSize + spacing,
		math.floor(checkSize / 2 - self.drawable:getHeight() / 2 + 0.5)
	)

	love.graphics.pop()
end

return Checkbox
