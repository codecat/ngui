local ShaderBank = {
	cache = {},
}

function ShaderBank.get(path)
	local shader = ShaderBank.cache[path]

	if shader ~= nil then
		return shader
	end

	shader = love.graphics.newShader(path)
	ShaderBank.cache[path] = shader
	return shader
end

return ShaderBank
