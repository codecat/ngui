local Box = require('ngui.widgets.box')
local Hbox = require('ngui.class'){ __includes = Box }

function Hbox:init()
	Box.init(self)

	self:setStyle('spacing', 0)
end

function Hbox:layout()
	local spacing = self:getStyle('spacing')

	local x = 0
	for _, child in ipairs(self.children) do
		local offset = child.x
		child.x = offset + x
		x = x + offset + child.width + spacing
	end

	Box.layout(self)
end

return Hbox
