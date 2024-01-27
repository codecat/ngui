local FontBank = {
	cache = {},
}

function FontBank.get(path, size)
	local key = path .. ':' .. size
	local font = FontBank.cache[key]

	if font ~= nil then
		return font
	end

	if path == '' then
		font = love.graphics.newFont(size)
	else
		font = love.graphics.newFont(path, size)
	end

	FontBank.cache[key] = font
	return font
end

return FontBank
