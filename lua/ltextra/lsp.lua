local M = {} -- M stands for module, a naming convention

function M._updateWordsLsp()
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

	local language = result.ltex.language
	local dicts = result.ltex.dictionary

	-- all clients attached to this buffer
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			local ltex_settings = client.config.settings
			ltex_settings.ltex.dictionary = dicts
			client.notify("workspace/didChangeConfiguration", { settings = ltex_settings })
		end
	end
end

function M._ltex_config()
	local workspace = vim.fn.getcwd()
	local file, err, code = assert(io.open(workspace .. "/.ltex-ls", "rb"))
	if err then
		print("Error to open file: " .. err)
		return {}
	end
	local jsonString = file:read("*a")
	file:close()
	local success, result = pcall(vim.json.decode, jsonString)
	if not success then
		vim.notify("Cannot decode ltex file, check .ltex-ls syntax", vim.log.levels.ERROR)
		return {}
	end
	return result
end

function M._ltex_setup()
	require("lspconfig").ltex.setup({
		capabilities = capabilities,
		on_attach = on_attach, --
		settings = M._ltex_config(),
	})
end

return M
