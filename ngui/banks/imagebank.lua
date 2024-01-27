local ImageBank = {
	cache = {},
}

function ImageBank.get(path)
	local item = ImageBank.cache[path]

	if item ~= nil then
		return item.image, item.quad, item.data
	end

	local data = love.image.newImageData(path)
	local image = love.graphics.newImage(data)
	image:setWrap('repeat', 'repeat')

	local w, h = image:getDimensions()
	local quad = love.graphics.newQuad(0, 0, w, h, w, h)

	ImageBank.cache[path] = {
		image = image,
		quad = quad,
		data = data,
	}
	return image, quad, data
end

return ImageBank
