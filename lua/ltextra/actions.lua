local M = {} -- M stands for module, a naming convention

local lsp = require("ltextra.lsp")
local json = require("ltextra.json")
local vim = vim

-- ===============================
function M.print_rule_under_cursor()
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			-- get error under cursor
			local errorsInLine = vim.lsp.diagnostic.get_line_diagnostics()
			local _, cursorChar = unpack(vim.api.nvim_win_get_cursor(0))
			for _, error in ipairs(errorsInLine) do
				local errorStart = error.range.start
				local errorEnd = error.range["end"]
				if errorStart.character <= cursorChar and errorEnd.character >= cursorChar then
					vim.notify(error.message)
				end
			end
		end
	end
end
-- ===============================
function M.ignore_command()
	local config = json.read()
	local wordUnderCursor = vim.fn.expand("<cword>")
	vim.notify(vim.inspect(wordUnderCursor))
end

-- ===============================
function M.disable_rule()
	-- function to add rules to ignore list
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			-- get error under cursor
			local errorsInLine = vim.lsp.diagnostic.get_line_diagnostics()
			local _, cursorChar = unpack(vim.api.nvim_win_get_cursor(0))
			for _, error in ipairs(errorsInLine) do
				local errorStart = error.range.start
				local errorEnd = error.range["end"]
				if errorStart.character <= cursorChar and errorEnd.character >= cursorChar then
					local href = error.codeDescription.href
					local language = href:sub(-5)
					local config = json.read()

					if config.ltex.disabledRules == nil then
						config.ltex.disabledRules = { [language] = { error.code } }
					else
						local existingRules = config.ltex.disabledRules[language]

						if existingRules == nil then
							config.ltex.disabledRules[language] = { error.code }
						else
							-- Check if the rule is not already in the list
							local ruleExists = false
							for _, rule in ipairs(existingRules) do
								if rule == error.code then
									ruleExists = true
									break
								end
							end

							-- If the rule is not in the list, add it
							if not ruleExists then
								table.insert(existingRules, error.code)
							end
						end
					end

					json.write(config)
					lsp._updateDisableRulesLsp()
				end
			end
		end
	end
end

-- ===============================
function M.open_reference()
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			-- get error under cursor
			local errorsInLine = vim.lsp.diagnostic.get_line_diagnostics()
			local _, cursorChar = unpack(vim.api.nvim_win_get_cursor(0))
			for _, error in ipairs(errorsInLine) do
				local errorStart = error.range.start
				local errorEnd = error.range["end"]
				if errorStart.character <= cursorChar and errorEnd.character >= cursorChar then
					vim.notify(error.codeDescription.href)
				end
			end
		end
	end
end

-- ===============================
function M.add_word()
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
	lsp._updateWordsLsp()
end

return M
