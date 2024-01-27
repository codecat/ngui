local Utils = {}

function Utils.color(color)
	if color == nil then
		return 0, 0, 0, 0
	end

	if type(color) == 'table' then
		return color[1], color[2], color[3], color[4]
	end

	if type(color) == 'string' then
		return Utils.hexcolor(color)
	end

	if type(color) == 'number' then
		local r = bit.rshift(bit.band(color, 0xff000000), 24) / 255
		local g = bit.rshift(bit.band(color, 0xff0000), 16) / 255
		local b = bit.rshift(bit.band(color, 0xff00), 8) / 255
		local a = bit.band(color, 0xff) / 255
		return r, g, b, a
	end

	return 0, 0, 0, 0
end

function Utils.hexcolor(hex)
	if hex:match('^#') then
		hex = hex:sub(2)
	end

	if #hex == 8 then
		local r = tonumber(hex:sub(1, 2), 16) / 255
		local g = tonumber(hex:sub(3, 4), 16) / 255
		local b = tonumber(hex:sub(5, 6), 16) / 255
		local a = tonumber(hex:sub(7, 8), 16) / 255
		return r, g, b, a
	elseif #hex == 6 then
		local r = tonumber(hex:sub(1, 2), 16) / 255
		local g = tonumber(hex:sub(3, 4), 16) / 255
		local b = tonumber(hex:sub(5, 6), 16) / 255
		return r, g, b, 1
	elseif #hex == 3 then
		local r = tonumber(hex:sub(1, 1), 16) / 15
		local g = tonumber(hex:sub(2, 2), 16) / 15
		local b = tonumber(hex:sub(3, 3), 16) / 15
		return r, g, b, 1
	elseif #hex == 4 then
		local r = tonumber(hex:sub(1, 1), 16) / 15
		local g = tonumber(hex:sub(2, 2), 16) / 15
		local b = tonumber(hex:sub(3, 3), 16) / 15
		local a = tonumber(hex:sub(4, 4), 16) / 15
		return r, g, b, a
	end

	return 0, 0, 0, 0
end

function Utils.vec(str)
	local ret = {}
	for m in str:gmatch('[%-%d]+') do
		table.insert(ret, tonumber(m))
	end
	return unpack(ret)
end

function Utils.vec2(value)
	if type(value) == 'string' then
		return Utils.vec(value)
	end
	return value, value
end

function Utils.vec4(value)
	if type(value) == 'string' then
		return Utils.vec(value)
	end
	return value, value, value, value
end

return Utils
