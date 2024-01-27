local Patch = require('ngui.class')()

local ImageBank = require('ngui.banks.imagebank')
local ShaderBank = require('ngui.banks.shaderbank')

function Patch:init(path)
	self.path = path
	self.image, self.quad, self.imagedata = ImageBank.get(path)
	self.shader = ShaderBank.get('ngui/shaders/patch.glsl')

	local w, h = self.imagedata:getDimensions()
	local sx, sy, sw, sh = -1, -1, -1, -1

	for x = 0, w - 1 do
		local _, _, _, a = self.imagedata:getPixel(x, 0)
		if sx == -1 and a == 1 then
			sx = x
		elseif sx ~= -1 and sw == -1 and a == 0 then
			sw = x - sx
			break
		end
	end
	if sw == -1 then
		sw = w - sx
	end

	for y = 0, h - 1 do
		local _, _, _, a = self.imagedata:getPixel(0, y)
		if sy == -1 and a == 1 then
			sy = y
		elseif sy ~= -1 and sh == -1 and a == 0 then
			sh = y - sy
			break
		end
	end
	if sh == -1 then
		sh = h - sy
	end

	self.middle = { sx / w, sy / h, (sx + sw) / w, (sy + sh) / h }
end

function Patch:draw(x, y, w, h)
	local prevShader = love.graphics.getShader()

	love.graphics.push()
	love.graphics.translate(math.floor(x), math.floor(y))
	love.graphics.setShader(self.shader)

	self.shader:send('middle', self.middle)
	self.shader:send('dest_size', {
		(w + 1) / self.image:getWidth(),
		(h + 1) / self.image:getHeight(),
	})
	self.quad:setViewport(1, 1, w, h, self.image:getDimensions())
	love.graphics.draw(self.image, self.quad)

	love.graphics.setShader(prevShader)
	love.graphics.pop()
end

return Patch
