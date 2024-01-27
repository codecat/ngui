local Host = require('ngui.class')()

function Host:init(path, sink)
	self.path = path
	self.root = nil
	self.invalidated = false
	self.sink = sink

	self.livereload = false
	self.livereloadtime = 0
	self.livereloadchecktime = 0

	self.inputEnabled = true
	self.inputActiveWidget = nil

	self.scale = 1

	self.canvas = love.graphics.newCanvas()
	self.useCanvas = true
end

function Host:setLiveReload(livereload)
	local info = love.filesystem.getInfo(self.path)

	self.livereload = livereload
	self.livereloadtime = info.modtime
	self.livereloadchecktime = 1
end

function Host:setScale(scale)
	self.scale = scale
	self.invalidated = true
end

function Host:getWidth()
	return love.graphics.getWidth() / self.scale
end

function Host:getHeight()
	return love.graphics.getHeight() / self.scale
end

function Host:remove()
	local ngui = require('ngui')
	for i, host in ipairs(ngui.hosts) do
		if host == self then
			table.remove(ngui.hosts, i)
			break
		end
	end
end

function Host:activate()
	self.root:activate()
	self:layout()

	if self.useCanvas then
		self.invalidated = true
	end
end

function Host:applyStyle(style)
	for _, node in ipairs(style.children) do
		local widgets = self:select(node.fullName, true)
		for _, widget in ipairs(widgets) do
			widget:applyStyle(node)
		end
	end
end

function Host:layout()
	self.root:layoutInternal()
	self.root:layoutSize()
	self.invalidated = false
end

function Host:select(selector, mustBeTable)
	return self.root:select(selector, mustBeTable)
end

function Host:callback(id, ...)
	if self.sink == nil then
		return
	end

	if self.sink[id] == nil then
		print('WARNING: Non-existing callback "' .. id .. '" on host sink!')
		return
	end

	self.sink[id](...)
end

function Host:widgetsWithState(state)
	local ret = {}

	local function with(w)
		if w:stateIndex(state) ~= 0 then
			table.insert(ret, w)
		end
		for _, child in ipairs(w.children) do
			with(child)
		end
	end

	with(self.root)

	return ret
end

function Host:widgetsAt(x, y)
	local ret = {}

	local tx = 0
	local ty = 0

	local function at(w, x, y)
		local wx = tx + w.x
		local wy = ty + w.y

		if x >= wx and y >= wy and x < wx + w.width and y < wy + w.height then
			table.insert(ret, w)
		end

		tx = tx + w.x
		ty = ty + w.y

		for _, child in ipairs(w.children) do
			at(child, x, y)
		end

		tx = tx - w.x
		ty = ty - w.y
	end

	at(self.root, x, y)

	return ret
end

function Host:mouseDown(x, y, button)
	x = x / self.scale
	y = y / self.scale

	if not self.inputEnabled then
		return
	end

	if button == 1 then
		local widgets = self:widgetsAt(x, y)
		self.inputActiveWidget = widgets[#widgets]

		if self.inputActiveWidget ~= nil then
			self.inputActiveWidget:addState('active')
			self.inputActiveWidget:mouseDown(x, y, button)
		end
	end
end

function Host:mouseUp(x, y, button)
	x = x / self.scale
	y = y / self.scale

	if self.inputActiveWidget == nil then
		return
	end

	if button == 1 then
		self.inputActiveWidget:mouseUp(x, y, button)
		self.inputActiveWidget:removeState('active')
		self.inputActiveWidget = nil
	end
end

function Host:updateInput(dt)
	if self.inputActiveWidget == nil then
		local mouseX, mouseY = love.mouse.getPosition()
		mouseX = mouseX / self.scale
		mouseY = mouseY / self.scale

		local oldHovering = self:widgetsWithState('hover')
		local newHovering = self:widgetsAt(mouseX, mouseY)

		local function find(tbl, value)
			for i, v in ipairs(tbl) do
				if v == value then
					return i
				end
			end
			return 0
		end

		for _, w in ipairs(oldHovering) do
			local newIndex = find(newHovering, w)
			if newIndex == 0 then
				-- previously hovered widget is not hovering anymore
				w:removeState('hover')
			else
				-- previously hovered widget is still hovering
				table.remove(newHovering, newIndex)
			end
		end

		for _, w in ipairs(newHovering) do
			w:addState('hover')
		end
	end
end

function Host:update(dt)
	if self.livereload then
		self.livereloadchecktime = self.livereloadchecktime - dt
		if self.livereloadchecktime < 0 then
			self.livereloadchecktime = self.livereloadchecktime + 1

			local info = love.filesystem.getInfo(self.path)
			if info.modtime > self.livereloadtime then
				self.livereloadtime = info.modtime
				print('Change detect, reloading!', self.path)

				local ngui = require('ngui')
				self.root = nil
				self.inputActiveWidget = nil
				self:remove()
				ngui.load(self.path, self.sink, self)
			end
		end
	end

	if self.inputEnabled then
		self:updateInput(dt)
	end
	self.root:update(dt)
end

function Host:draw()
	if self.invalidated then
		self:layout()

		if self.useCanvas then
			love.graphics.setCanvas(self.canvas)
			love.graphics.clear()
			self:drawInternal()
			love.graphics.setCanvas()
		end
	end

	if self.useCanvas then
		love.graphics.setBlendMode('alpha', 'premultiplied')
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.canvas)
		love.graphics.setBlendMode('alpha')
	else
		self:drawInternal()
	end
end

function Host:drawInternal()
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.setColor(1, 1, 1, 1)
	self.root:drawInternal()
	love.graphics.pop()
end

return Host
