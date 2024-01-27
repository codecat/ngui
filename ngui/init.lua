local Host = require('ngui.host')
local Parser = require('ngui.parser')

local NGui = {
	initialized = false,
	hosts = {},
}

function NGui.init()
	NGui.mousepressed_orig = love.mousepressed
	love.mousepressed = NGui.mousepressed

	NGui.mousereleased_orig = love.mousereleased
	love.mousereleased = NGui.mousereleased

	NGui.initialized = true
end

function NGui.load(path, sink, host)
	if not NGui.initialized then
		error('NGui not initialized. Run NGui.init() first!')
	end

	host = host or Host(path, sink)
	local doc = Parser.load(path)
	local style = nil

	for _, node in ipairs(doc) do
		if node.name == 'style' then
			style = node
		elseif node.name == 'scale' then
			host.scale = node.content
		elseif node.name == 'livereload' then
			host:setLiveReload(true)
		else
			local function walk(node, parent)
				local widgetExists, widgetModule = pcall(require, 'ngui.widgets.' .. node.name)
				if not widgetExists then
					error('Could not find widget type ' .. node.name .. ' in ' .. path .. ' on line ' .. node.lineNumber)
				end

				local widget = widgetModule()
				widget.host = host
				widget.parent = parent
				widget.name = node.name
				widget.id = node.id
				widget.className = node.className

				if node.dataAttrs ~= nil then
					widget:parseAttributes(node.dataAttrs)
				end

				if node.content ~= nil then
					widget:content(node.content)
				end

				for _, child in ipairs(node.children) do
					table.insert(widget.children, walk(child, widget))
				end

				return widget
			end

			if host.root ~= nil then
				error('Found multiple root widgets in ' .. path .. ' on line ' .. node.lineNumber .. ', there can only be one')
			else
				host.root = walk(node)
			end
		end
	end

	if host.root == nil then
		error('Missing root widget in ' .. path)
	end

	table.insert(NGui.hosts, host)

	if style ~= nil then
		host:applyStyle(style)
	end

	host:activate()

	return host
end

function NGui.update(dt)
	for _, host in ipairs(NGui.hosts) do
		host:update(dt)
	end
end

function NGui.draw()
	for _, host in ipairs(NGui.hosts) do
		host:draw()
	end
end

function NGui.mousepressed(...)
	if NGui.mousepressed_orig ~= nil then
		NGui.mousepressed_orig(...)
	end

	local x = select(1, ...)
	local y = select(2, ...)
	local button = select(3, ...)

	for _, host in ipairs(NGui.hosts) do
		host:mouseDown(x, y, button)
	end
end

function NGui.mousereleased(...)
	if NGui.mousereleased_orig ~= nil then
		NGui.mousereleased_orig(...)
	end

	local x = select(1, ...)
	local y = select(2, ...)
	local button = select(3, ...)

	for _, host in ipairs(NGui.hosts) do
		host:mouseUp(x, y, button)
	end
end

return NGui
