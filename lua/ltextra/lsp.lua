local M = {} -- M stands for module, a naming convention

local json = require("ltextra.json")
local vim = vim

-- ===============================
function M._updateWordsLsp()
	local result = json.read()
	local dicts = result.ltex.dictionary
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

-- ===============================
function M._updateDisableRulesLsp()
	local result = json.read()
	local newConfig = result.ltex.disabledRules
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			local ltex_settings = client.config.settings
			ltex_settings.ltex.disabledRules = newConfig
			client.notify("workspace/didChangeConfiguration", { settings = ltex_settings })
		end
	end
end

-- ===============================
function M._ltex_config()
	return json.read() or {}
end

-- ===============================
function M._ltex_setup()
	require("lspconfig").ltex.setup({
		capabilities = capabilities,
		on_attach = on_attach, --
		settings = M._ltex_config(),
	})
end

return M
