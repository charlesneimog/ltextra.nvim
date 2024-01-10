local M = {}

local json = require("ltextra.json")
local lsp = require("ltextra.lsp")

local function ltex_configs(config)
	local newconfig = {
		ltex = {
			language = "en-US",
			checkFrequency = "save",
		},
	}
	if config == nil then
		return newconfig
	end

	if config.language ~= nil then
		newconfig.ltex.language = config.language
	end

	if config.checkFrequency ~= nil then
		newconfig.checkFrequency = config.checkFrequency
	end
	return newconfig
end

function create_file()
	local config = vim.g.ltex_config
	vim.notify(vim.inspect(config))
	vim.ui.input({
		prompt = ".ltex-ls file does not exist. Create it? (y/n): ",
	}, function(answer)
		if answer == "y" then
			local default = ltex_configs(config)
			local workspace = vim.fn.getcwd()
			local file, err, code = assert(io.open(workspace .. "/.ltex-ls", "wb"))
			if err then
				vim.notify("Error to create file: " .. err)
				return
			end
			file:write(vim.json.encode(default))
			file:close()
			json.format()
			lsp._ltex_setup()
		end
	end)
end

function M.setup(config)
	local fileExists = json.fileexits()
	vim.g.ltex_config = config
	if not fileExists then
		vim.defer_fn(function()
			create_file()
		end, 3000)
	else
		lsp._ltex_setup()
	end
end

return M
