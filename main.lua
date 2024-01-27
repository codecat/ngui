local ngui = require('ngui')

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	ngui.init()

	local ui
	local clicked = 0

	ui = ngui.load('assets/cstrike.ngui', {
		count = function()
			clicked = clicked + 1
			ui:select('#count'):setText('Current count: ' .. clicked)
		end,
	})
	ui:setLiveReload(true)
end

function love.update(dt)
	ngui.update(dt)
end

local num = 0
local function drawFunBackground()
	love.graphics.clear(0/255, 41/255, 107/255)
	love.graphics.setColor(0/255, 63/255, 136/255)

	num = num + love.timer.getDelta()

	local spacing = 70
	local radius = 30

	for x = -2, 11 do
		for y = -2, 11 do
			local offsetX = (num * 20) % (spacing * 2)
			local offsetY = (num * 10) % (spacing * 2)
			love.graphics.circle(
				'fill',
				x * spacing + offsetX,
				(x % 2) * (spacing / 2) + y * spacing + offsetY,
				radius
			)
		end
	end
end

function love.draw()
	drawFunBackground()

	local startTime = love.timer.getTime()
	ngui.draw()
	local endTime = love.timer.getTime()
	local time = (endTime - startTime) * 1000

	local stats = love.graphics.getStats()

	if time >= 7 then
		love.graphics.setColor(1, 0, 0)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.print(string.format('FPS: %d (%.3f ms) (%d draw calls, %d batched)', love.timer.getFPS(), time, stats.drawcalls, stats.drawcallsbatched), 0, love.graphics.getHeight() - 16)
end
