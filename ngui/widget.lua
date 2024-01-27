local Widget = require('ngui.class')()

local ImageBank = require('ngui.banks.imagebank')

function Widget:init()
	self.host = nil
	self.parent = nil
	self.children = {}

	self.name = ''
	self.id = ''
	self.className = ''

	self.x = 0
	self.y = 0
	self.width = 0
	self.height = 0

	self.style = {
		normal = {},
		hover = {},
		active = {},
	}

	self.stylemap = {
		alignment = require('ngui.styles.anchor'),

		offset = require('ngui.styles.vec2'),
		padding = require('ngui.styles.vec2'),

		background = require('ngui.styles.color'),
		background_image_color = require('ngui.styles.color'),
		background_anchor = require('ngui.styles.anchor'),

		border = require('ngui.styles.color'),
		border_radius = require('ngui.styles.vec2'),
	}

	self.states = {}

	self.drawqueue = {}
end

function Widget:select(selector, mustBeTable)
	local ret = {}

	local name = selector:match('^([%w_]+)')
	local id = selector:match('#([%w_]+)')
	local className = selector:match('%.([%w_]+)')

	local function append(found)
		for _, item in ipairs(found) do
			table.insert(ret, item)
		end
	end

	local function filter(f)
		for i = #ret, 1, -1 do
			if not f(ret[i]) then
				table.remove(ret, i)
			end
		end
	end

	local stopAppending = false

	if name ~= nil then
		if not stopAppending then
			append(self:findByName(name))
		end
		stopAppending = true
	end

	if id ~= nil then
		if not stopAppending then
			local found = self:findById(id)
			if found ~= nil then
				table.insert(ret, found)
			end
			stopAppending = true
		end
		filter(function(item) return item.id == id end)
	end

	if className ~= nil then
		if not stopAppending then
			append(self:findByClassName(className))
			stopAppending = true
		end
		filter(function(item) return item.className == className end)
	end

	if not mustBeTable and id ~= nil then
		return ret[1]
	end
	return ret
end

function Widget:findById(id)
	if self.id == id then
		return self
	end

	for _, child in ipairs(self.children) do
		local ret = child:findById(id)
		if ret ~= nil then
			return ret
		end
	end

	return nil
end

function Widget:findByClassName(className)
	local ret = {}

	if self.className == className then
		table.insert(ret, self)
	end

	for _, child in ipairs(self.children) do
		local childRet = child:findByClassName(className)
		for _, c in ipairs(childRet) do
			table.insert(ret, c)
		end
	end

	return ret
end

function Widget:findByName(name)
	local ret = {}

	if self.name == name then
		table.insert(ret, self)
	end

	for _, child in ipairs(self.children) do
		local childRet = child:findByName(name)
		for _, c in ipairs(childRet) do
			table.insert(ret, c)
		end
	end

	return ret
end

function Widget:stateIndex(state)
	for i, s in ipairs(self.states) do
		if s == state then
			return i
		end
	end
	return 0
end

function Widget:addState(state)
	if self:stateIndex(state) ~= 0 then
		error('State is already added: "' .. state .. '"')
		return
	end

	table.insert(self.states, state)

	self:stateChanged()
end

function Widget:removeState(state)
	local index = self:stateIndex(state)
	if index == 0 then
		return
	end

	table.remove(self.states, index)

	self:stateChanged()
end

function Widget:stateChanged()
	-- current we just always invalidate. this should be
	-- optimized later so that it doesn't do that
	--
	-- for example, we don't need to invalidate if we're only
	-- changing the background color, but invalidation is
	-- required if anything related to the layout changes
	-- (eg. size, padding, spacing[vbox/hbox], etc.)
	--
	-- when a check like the above gets implemented, this
	-- invalidate() call should probably go somewhere else
	-- because we override this stateChanged function in
	-- a couple places
	self:invalidate()
end

function Widget:mapStyle(key, style)
	self.stylemap[key] = style
end

function Widget:getStyle(key)
	for i = #self.states, 1, -1 do
		local state = self.states[i]
		local stateStyle = self.style[state]
		if stateStyle ~= nil then
			local v = stateStyle[key]
			if v ~= nil then
				return v
			end
		end
	end

	return self.style.normal[key]
end

function Widget:setStyle(key, value, state)
	state = state or 'normal'

	local mapping = self.stylemap[key]
	if mapping ~= nil then
		value = mapping(value)
	else
		local styleExists, styleModule = pcall(require, 'ngui.styles.' .. key)
		if styleExists then
			value = styleModule(value)
		end
	end

	if self.style[state] == nil then
		self.style[state] = {
			[key] = value,
		}
	else
		self.style[state][key] = value
	end
end

function Widget:applyStyle(node)
	local modifier = node.fullName:match(':([%w_]+)') or 'normal'

	for _, style in ipairs(node.children) do
		local key = style.name
		local value = style.content

		if #style.children > 0 then
			local children = self:select(style.fullName, true)
			for _, child in ipairs(children) do
				child:applyStyle(style)
			end
		else
			self:setStyle(key, value, modifier)
		end
	end
end

function Widget:parseAttributes(attrs)
	local keymatch = '([@:$]?)([%w_]+)='

	for m, k, v in attrs:gmatch(keymatch .. '"([^"]*)"') do
		self:attr(m, k, v)
	end

	for m, k, v in attrs:gmatch(keymatch .. '([^"]%S*)') do
		self:attr(m, k, tonumber(v))
	end
end

function Widget:attr(modifier, key, value)
	if modifier == '@' then
		key = 'on_' .. key
	elseif modifier == '$' then
		self:setStyle(key, value)
		return
	end

	if self[key] ~= nil then
		self[key] = value
	end
end

function Widget:content(text)
end

function Widget:activate()
	for _, child in ipairs(self.children) do
		child:activate()
	end
end

function Widget:invalidate()
	self.host.invalidated = true
end

function Widget:layoutInternal()
	local offset = self:getStyle('offset') or { 0, 0 }

	self.x = offset[1]
	self.y = offset[2]
	self.width = self:getStyle('width') or 0
	self.height = self:getStyle('height') or 0

	local padding = self:getStyle('padding') or { 0, 0 }

	for _, child in ipairs(self.children) do
		child:layoutInternal()
	end

	self:layout()

	for _, child in ipairs(self.children) do
		child:layoutSize()

		child.x = child.x + padding[1]
		child.y = child.y + padding[2]
	end

	self.width = self.width + padding[1] * 2
	self.height = self.height + padding[2] * 2
end

function Widget:layout()
end

function Widget:layoutSize()
	local parentWidth, parentHeight
	local anchor

	if self.parent ~= nil then
		parentWidth = self.parent.width
		parentHeight = self.parent.height
		anchor = self.parent:getStyle('alignment')
	else
		parentWidth = self.host:getWidth()
		parentHeight = self.host:getHeight()
	end

	anchor = anchor or self:getStyle('anchor')

	if anchor ~= nil then
		self.x, self.y = anchor:fit(self.width, self.height, parentWidth, parentHeight, self.x, self.y)
	end
end

function Widget:update(dt)
	for _, child in ipairs(self.children) do
		child:update(dt)
	end
end

function Widget:mouseDown(x, y, button)
end

function Widget:mouseUp(x, y, button)
end

function Widget:drawInternal()
	love.graphics.push()
	love.graphics.translate(math.floor(self.x), math.floor(self.y))

	self:drawBackground()
	self:draw()
	self:drawForeground()

	for _, child in ipairs(self.children) do
		child:drawInternal()
	end

	love.graphics.pop()
end

function Widget:drawBackground()
	local borderRadius = self:getStyle('border_radius') or { 0, 0 }

	local backgroundColor = self:getStyle('background')
	if backgroundColor ~= nil and backgroundColor[4] > 0 then
		love.graphics.setColor(backgroundColor)
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, borderRadius[1], borderRadius[2])
	end

	local backgroundImage = self:getStyle('background_image')
	if backgroundImage ~= nil then
		local img, quad = ImageBank.get(backgroundImage)
		local x, y = 0, 0

		local backgroundAnchor = self:getStyle('background_anchor')
		if backgroundAnchor ~= nil then
			x, y = backgroundAnchor:fit(img:getWidth(), img:getHeight(), self.width, self.height)
		end

		local backgroundRepeat = self:getStyle('background_repeat') or ''
		local backgroundSize = self:getStyle('background_size') or ''

		local vw, vh = 0, 0
		local vsw, vsh = 0, 0

		if backgroundRepeat == '' then
			vw = math.min(self.width, img:getWidth())
			vh = math.min(self.height, img:getHeight())
		elseif backgroundRepeat == 'repeat-x' then
			vw = self.width
			vh = img:getHeight()
		elseif backgroundRepeat == 'repeat-y' then
			vw = img:getWidth()
			vh = self.height
		elseif backgroundRepeat == 'repeat' then
			vw = self.width
			vh = self.height
		end

		if backgroundSize == '' then
			vsw, vsh = img:getDimensions()
		elseif backgroundSize == 'cover' then
			local iw, ih = img:getDimensions()
			local ir = ih / iw
			local vr = vh / vw
			if vr > ir then
				vsh = vh
				vsw = vh / ir
			else
				vsw = vw
				vsh = vw * ir
			end
			if backgroundAnchor ~= nil then
				x, y = backgroundAnchor:fit(vsw, vsh, self.width, self.height)
			end
		end

		quad:setViewport(-x, -y, vw, vh, vsw, vsh)

		love.graphics.setColor(self:getStyle('background_image_color') or { 1, 1, 1 })
		love.graphics.draw(img, quad)
	end

	local backgroundPatch = self:getStyle('patch')
	if backgroundPatch ~= nil then
		love.graphics.setColor(1, 1, 1, 1)
		backgroundPatch:draw(0, 0, self.width, self.height)
	end
end

function Widget:draw()
	if #self.drawqueue > 0 then
		for _, f in ipairs(self.drawqueue) do
			f()
		end
		self.drawqueue = {}
	end
end

function Widget:drawForeground()
	local borderRadius = self:getStyle('border_radius') or { 0, 0 }

	local border = self:getStyle('border')
	if border ~= nil then
		love.graphics.setColor(border)
		love.graphics.setLineWidth(self:getStyle('border_width') or 1)
		love.graphics.rectangle('line', 0.5, 0.5, self.width, self.height, borderRadius[1], borderRadius[2])
	end
end

return Widget
