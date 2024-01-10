local M = {} -- M stands for module, a naming convention

local vim = vim

-- ===============================
function M.fileexits()
	local file = vim.fn.getcwd() .. "/.ltex-ls"
	if vim.fn.filereadable(file) == 1 then
		return true
	end
	return false
end

-- ===============================
function M.read()
	local workspace = vim.fn.getcwd()
	local file = io.open(workspace .. "/.ltex-ls", "rb")
	local jsonString = file:read("*a")
	file:close()
	local success, result = pcall(vim.json.decode, jsonString)
	if not success then
		vim.notify("Failed to read .ltex-ls file")
		return nil
	end
	return result
end

-- ===============================
function M.write(result)
	local workspace = vim.fn.getcwd()
	local encoded_result = vim.fn.json_encode(result)
	local file = io.open(workspace .. "/.ltex-ls", "w")
	file:write(encoded_result)
	file:close()
	M.format()
end

-- ===============================
function M.add_config(newconfig)
	local jsonResult = M.read()
	table.insert(jsonResult.ltex, newconfig)
	M.write(jsonResult)
end

-- ===============================
function M.format()
	local workspace = vim.fn.getcwd()
	local success, _ = pcall(
		vim.fn.system,
		"jq . "
			.. workspace
			.. "/.ltex-ls >> "
			.. workspace
			.. "/.tmp-ltex-ls && mv "
			.. workspace
			.. "/.tmp-ltex-ls "
			.. workspace
			.. "/.ltex-ls"
	)

	if not success then
		vim.notify("Failed to format .ltex-ls file")
	end
end

return M
