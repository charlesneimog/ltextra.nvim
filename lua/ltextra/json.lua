local M = {} -- M stands for module, a naming convention

local lsp = require("ltextra.lsp")

function M.format()
	local workspace = vim.fn.getcwd()
	local sucess, result = pcall(
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
end

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

function M.write(result)
	local workspace = vim.fn.getcwd()
	local formattedJson = vim.fn.json_encode(result)
	file = io.open(workspace .. "/.ltex-ls", "w")
	file:write(vim.fn.json_encode(result))
	file:close()
	lsp._updateWordsLsp()
	M.format()
end

function M.fileexits()
	local file = vim.fn.getcwd() .. "/.ltex-ls"
	if vim.fn.filereadable(file) == 1 then
		return true
	end
	return false
end

return M
