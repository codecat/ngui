local Anchor = require('ngui.class')()

function Anchor:init(value)
	self.x = -1
	self.y = -1

	for v in value:gmatch('%w') do
		if v == 't' then
			self.y = -1
		elseif v == 'b' then
			self.y = 1
		elseif v == 'm' then
			self.y = 0
		elseif v == 'l' then
			self.x = -1
		elseif v == 'r' then
			self.x = 1
		elseif v == 'c' then
			self.x = 0
		end
	end
end

function Anchor:fit(w, h, cw, ch, x, y)
	x = x or 0
	y = y or 0

	if self.x == 1 then
		x = cw - w
	elseif self.x == 0 then
		x = cw / 2 - w / 2
	end

	if self.y == 1 then
		y = ch - h
	elseif self.y == 0 then
		y = ch / 2 - h / 2
	end

	return x, y
end

return Anchor
