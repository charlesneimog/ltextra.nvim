local M = {} -- M stands for module, a naming convention

local lsp = require("ltextra.lsp")
local json = require("ltextra.json")

function M.disable_rule()
	-- function to add rules to ignore list
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			-- get error under cursor
			local errorsInLine = vim.lsp.diagnostic.get_line_diagnostics()
			local cursorLine, cursorChar = unpack(vim.api.nvim_win_get_cursor(0))
			for _, error in ipairs(errorsInLine) do
				errorStart = error.range.start
				errorEnd = error.range["end"]
				if errorStart.character <= cursorChar and errorEnd.character >= cursorChar then
					vim.notify("Adding " .. error.code .. " to ignore list")
				end
			end
		end
	end
end

-- ============================
function M.update_dictionary()
	local workspace = vim.fn.getcwd()
	local file = io.open(workspace .. "/.ltex-ls", "rwb")
	if not file then
		vim.notify("There is no .ltex-ls file")
		return nil
	end
	local jsonString = file:read("*a")
	file:close()
	local success, result = pcall(vim.fn.json_decode, jsonString)
	if not success then
		vim.notify("There is no .ltex-ls file")
		return nil
	end
	local wordUnderCursor = vim.fn.expand("<cword>")
	local language = result.ltex.language
	vim.notify("Adding " .. wordUnderCursor .. " to dictionary")

	if result.ltex.dictionary == nil then
		result.ltex.dictionary = {}
	end

	if result.ltex.dictionary[language] == nil then
		result.ltex.dictionary[language] = {}
	end

	if type(result.ltex.dictionary[language]) == "table" then
		local wordAlreadyExists = false
		for _, existingWord in ipairs(result.ltex.dictionary[language]) do
			if existingWord == wordUnderCursor then
				wordAlreadyExists = true
				vim.notify("Word already exists in dictionary")
				break
			end
		end
		if not wordAlreadyExists then
			table.insert(result.ltex.dictionary[language], wordUnderCursor)
			vim.notify("Word added to dictionary")
		end
	else
		result.ltex.dictionary[language] = { wordUnderCursor }
	end

	-- format the json to get new lines, indentation, etc
	local formattedJson = vim.fn.json_encode(result)
	file = io.open(workspace .. "/.ltex-ls", "w")
	file:write(vim.fn.json_encode(result))
	file:close()

	local sucess = json.format()
	if not sucess then
		return nil
	end

	lsp._updateWordsLsp()
	return true
end

function M.open_reference()
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			-- get error under cursor
			local errorsInLine = vim.lsp.diagnostic.get_line_diagnostics()
			local cursorLine, cursorChar = unpack(vim.api.nvim_win_get_cursor(0))
			for _, error in ipairs(errorsInLine) do
				errorStart = error.range.start
				errorEnd = error.range["end"]
				if errorStart.character <= cursorChar and errorEnd.character >= cursorChar then
					vim.notify(error.codeDescription.href)
				end
			end
		end
	end
end

-- ===================
function M.add_word()
	local workspace = vim.fn.getcwd()
	local result = json.read()
	local wordUnderCursor = vim.fn.expand("<cword>")
	local language = result.ltex.language
	vim.notify("Adding " .. wordUnderCursor .. " to dictionary")

	if result.ltex.dictionary == nil then
		result.ltex.dictionary = {}
	end

	if result.ltex.dictionary[language] == nil then
		result.ltex.dictionary[language] = {}
	end

	if type(result.ltex.dictionary[language]) == "table" then
		local wordAlreadyExists = false
		for _, existingWord in ipairs(result.ltex.dictionary[language]) do
			if existingWord == wordUnderCursor then
				wordAlreadyExists = true
				break
			end
		end
		if not wordAlreadyExists then
			table.insert(result.ltex.dictionary[language], wordUnderCursor)
		end
	else
		result.ltex.dictionary[language] = { wordUnderCursor }
	end

	-- format the json to get new lines, indentation, etc
	json.write(result)
end

return M
