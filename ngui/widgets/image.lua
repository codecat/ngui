local Widget = require('ngui.widget')
local Image = require('ngui.class'){ __includes = Widget }

local ImageBank = require('ngui.banks.imagebank')

function Image:init()
	Widget.init(self)

	self:setStyle('rot', 0)
	self:setStyle('color', 0xFFFFFFFF)

	self:mapStyle('sprite', require('ngui.styles.vec4'))

	self.image = nil
	self.quad = love.graphics.newQuad(0, 0, 32, 32, 32, 32)
end

function Image:content(text)
	self.image = ImageBank.get(text)
end

function Image:layout()
	Widget.layout(self)

	local w, h = self.image:getDimensions()

	local sprite = self:getStyle('sprite')
	if sprite ~= nil then
		w = sprite[3]
		h = sprite[4]
	end

	self.width = self:getStyle('width') or w
	self.height = self:getStyle('height') or h
end

function Image:draw()
	Widget.draw(self)

	if self.image == nil then
		return
	end

	local w, h = self.image:getDimensions()

	local sprite = self:getStyle('sprite')
	if sprite ~= nil then
		w = sprite[3]
		h = sprite[4]
	end

	local rot = self:getStyle('rot') or 0
	local width = self:getStyle('width') or w
	local height = self:getStyle('height') or h

	local scaleX = width / w
	local scaleY = height / h

	love.graphics.setColor(self:getStyle('color'))

	local sprite = self:getStyle('sprite')
	if sprite ~= nil then
		self.quad:setViewport(sprite[1], sprite[2], sprite[3], sprite[4], self.image:getDimensions())
		love.graphics.draw(self.image, self.quad, 0, 0, rot, scaleX, scaleY)
	else
		love.graphics.draw(self.image, 0, 0, rot, scaleX, scaleY)
	end
end

return Image
