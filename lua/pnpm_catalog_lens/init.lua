local api = vim.api
local ns = api.nvim_create_namespace("pnpm_catalog_lens")

---@class PNPM_CATALOG_LENS_API
local pnpm_catalog_lens_api = require("pnpm_catalog_lens.api")

---@class PNPM_CATALOG_LENS_CONSTANTS
local constants = require("pnpm_catalog_lens.constants")

local M = {}

-- This function is called when the user leaves insert mode or changes the text
M.set_diagnostics = function()
	local bufnr = api.nvim_get_current_buf()

	local catalogs = pnpm_catalog_lens_api.get_catalogs_from_pnpm_workspace_yaml()

	if catalogs == nil then
		return
	end

	local catalog_deps = pnpm_catalog_lens_api.extract_catalog_dependencies_from_package_json(bufnr)

	if catalog_deps == nil then
		return
	end

	local diagnostics = {}
	-- Clear existing diagnostics
	vim.diagnostic.reset(ns, bufnr) -- Start fresh
	for catalog, _ in pairs(catalog_deps) do
		local catalog_dep_info = catalogs[catalog]
		if catalog_dep_info ~= nil then
			table.insert(diagnostics, {
				bufnr = bufnr,
				lnum = catalog_deps[catalog].line,
				col = catalog_deps[catalog].col,
				message = catalogs[catalog],
				severity = vim.diagnostic.severity.HINT,
			})
		end
	end

	vim.diagnostic.set(ns, bufnr, diagnostics)
end

M.hide_lens = function()
	local bufnr = api.nvim_get_current_buf()
	vim.diagnostic.reset(ns, bufnr)
end

M.enable = function()
	vim.print("enable")
	M.augroup = api.nvim_create_augroup("pnpm-catalog-lens", { clear = true })

	local bufnr = api.nvim_get_current_buf()
	api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
		group = M.augroup,
		buffer = bufnr,
		callback = M.set_diagnostics,
		desc = "Set explanations when leaving insert mode or changing the text",
	})

	api.nvim_create_autocmd({ "InsertEnter" }, {
		group = M.augroup,
		buffer = bufnr,
		callback = M.hide_lens,
		desc = "Hide explanations when entering insert mode",
	})

	vim.schedule(M.set_diagnostics)
end

M.disable = function()
	local bufnr = api.nvim_get_current_buf()

	vim.diagnostic.reset(ns, bufnr)
	pcall(function()
		api.nvim_del_augroup_by_id(M.augroup)
	end)
end

M.setup = function()
	api.nvim_create_user_command(
		"PnpmCatalogLensEnable",
		M.enable,
		{ nargs = 0, desc = "Enable the pnpm catalog lens" }
	)

	api.nvim_create_user_command(
		"PnpmCatalogLensDisable",
		M.disable,
		{ nargs = 0, desc = "Disable the pnpm catalog lens" }
	)

	api.nvim_create_autocmd({ "BufEnter" }, {
		group = M.augroup,
		pattern = constants.PACKAGE_JSON,
		callback = M.enable,
		desc = "Enable the pnpm catalog lens when opening package.json",
	})
end

return M
