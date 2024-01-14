local M = {} -- M stands for module, a naming convention

local json = require("ltextra.json")
local vim = vim

-- ===============================
function M._updateLsp()
	local jsonConfig = json.read()
	local newConfig = jsonConfig.ltex
	local clients = vim.lsp.buf_get_clients(0)
	for _, client in pairs(clients) do
		local clientName = client.name
		if clientName == "ltex" then
			local ltex_settings = client.config.settings
			ltex_settings.ltex = newConfig
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
