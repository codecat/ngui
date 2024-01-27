local Box = require('ngui.widgets.box')
local Vbox = require('ngui.class'){ __includes = Box }

function Vbox:init()
	Box.init(self)

	self:setStyle('spacing', 0)
end

function Vbox:layout()
	local spacing = self:getStyle('spacing')

	local y = 0
	for _, child in ipairs(self.children) do
		local offset = child.y
		child.y = offset + y
		y = y + offset + child.height + spacing
	end

	Box.layout(self)
end

return Vbox
