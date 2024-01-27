local Parser = {}

function Parser.load(path)
	local fh = love.filesystem.newFile(path)
	if fh == nil then
		error('Unable to open file ' .. path)
	end

	local stack = {}
	local currentIndent = -1
	local previousNode = nil
	local lineNumber = 0
	local roots = {}

	for line in fh:lines() do
		lineNumber = lineNumber + 1

		local data = line:match('^%s*(.*)')

		if data ~= nil then
			data = data:match('^(.*)//.*') or data
		end

		if data ~= nil and data ~= '' then
			local textContents = data:match('^"(.+)"')
			if textContents ~= nil then
				if previousNode ~= nil then
					if previousNode.content == nil then
						previousNode.content = textContents
					elseif type(previousNode.content) == 'number' then
						previousNode.content = tostring(previousNode.content) .. textContents
					else
						previousNode.content = previousNode.content .. textContents
					end
				else
					error('Found content without a node in ' .. path .. ' on line ' .. lineNumber)
				end
			else
				local indent = line:match('^(\t*)'):len()
				local fullName = data:match('^([^%s]+)')

				local name = fullName:match('^(!?[%w_]+)')
				local attrs = data:sub(#fullName + 1)

				if indent > currentIndent and previousNode ~= nil then
					table.insert(stack, previousNode)
				elseif indent < currentIndent then
					for _ = 1, currentIndent - indent do
						table.remove(stack)
					end
				end
				currentIndent = indent

				if indent > 0 and indent > #stack then
					error('Excessive indentation (encountered ' .. indent .. ' but expected ' .. #stack .. ') in ' .. path .. ' on line ' .. lineNumber)
				end

				local contentText = attrs:match('%s"([^"]*)"')
				local contentNumber = attrs:match('%s(0[xX][0-9a-fA-F]+)') or attrs:match('%s([%d%.]+)')

				if contentNumber ~= nil then
					contentNumber = tonumber(contentNumber)
				end

				if name == '!include' then
					if contentText == path then
						error('Recursive include in ' .. path .. ' on line ' .. lineNumber)
					end
					local includedRoots = Parser.load(contentText)

					if indent > 0 then
						for _, includedRoot in ipairs(includedRoots) do
							table.insert(stack[indent].children, includedRoot)
						end
					else
						for _, includedRoot in ipairs(includedRoots) do
							table.insert(roots, includedRoot)
						end
					end

					if #includedRoots > 0 then
						previousNode = includedRoots[#includedRoots]
					end
				else
					local id = fullName:match('#([%w_]+)')
					local className = fullName:match('%.([%w_]+)')
					local modifier = fullName:match(':([%w_]+)')

					local node = {
						data = data,
						dataAttrs = attrs,

						fullName = fullName,

						parent = stack[#stack],
						children = {},
						lineNumber = lineNumber,

						content = contentText or contentNumber,
						name = name or '',
						id = id or '',
						className = className or '',
						modifier = modifier or '',
					}

					if indent > 0 then
						table.insert(stack[indent].children, node)
					else
						table.insert(roots, node)
					end

					previousNode = node
				end
			end
		end
	end

	fh:close()

	return roots
end

return Parser
