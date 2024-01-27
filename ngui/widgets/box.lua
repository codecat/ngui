local Widget = require('ngui.widget')
local Box = require('ngui.class'){ __includes = Widget }

function Box:layout()
	Widget.layout(self)

	local width = 0
	local height = 0

	for _, child in ipairs(self.children) do
		local right = child.x + child.width
		if right > width then
			width = right
		end

		local bottom = child.y + child.height
		if bottom > height then
			height = bottom
		end
	end

	self.width = self:getStyle('width') or width
	self.height = self:getStyle('height') or height
end

return Box
