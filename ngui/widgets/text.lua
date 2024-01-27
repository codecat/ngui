local Widget = require('ngui.widget')
local TextWidget = require('ngui.class'){ __includes = Widget }

local FontBank = require('ngui.banks.fontbank')

function TextWidget:init()
	Widget.init(self)

	self:setStyle('color', 0xFFFFFFFF)

	self.text = ''
end

function TextWidget:content(text)
	Widget.content(self, text)

	self.text = self.text .. text
end

function TextWidget:activate()
	Widget.activate(self)

	self:refresh()
end

function TextWidget:stateChanged()
	self:refresh()

	Widget.stateChanged(self)
end

function TextWidget:getFont()
	local fontPath = self:getStyle('font') or ''
	local fontSize = self:getStyle('fontsize') or 12
	return FontBank.get(fontPath, fontSize)
end

function TextWidget:drawText(x, y, batch)
	--TODO: We can't do this properly yet due to a missing LOVE feature: https://github.com/love2d/love/issues/1641
	--[[
	if (batch == nil or batch) and self.parent ~= nil then
		table.insert(self.parent.drawqueue, function()
			self:drawText(x, y, false)
		end)
		return
	end
	]]

	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(math.rad(self:getStyle('rot') or 0))
	love.graphics.setColor(self:getStyle('color'))
	love.graphics.draw(self.drawable)
	love.graphics.pop()
end

function TextWidget:setText(text)
	self.text = text
	self:refresh()
end

function TextWidget:refresh()
	self.drawable = love.graphics.newText(self:getFont())

	local wrapwidth = self:getStyle('wrapwidth') or 0
	local align = self:getStyle('align') or 'left'

	if wrapwidth > 0 then
		self.drawable:setf(self.text, wrapwidth, align)
	else
		self.drawable:set(self.text)
	end

	self:invalidate()
end

return TextWidget
