local api = vim.api
local ns = api.nvim_create_namespace("pnpm_catalog_lens")

---@class PNPM_CATALOG_LENS_API
local pnpm_catalog_lens_api = require("pnpm_catalog_lens.api")

---@class PNPM_CATALOG_LENS_CONSTANTS
local constants = require("pnpm_catalog_lens.constants")

---@class PNPM_CATALOG_LENS_INIT
local M = {}

-- This function is called when the user leaves insert mode or changes the text
M.set_diagnostics = function()
	local bufnr = api.nvim_get_current_buf()

	local cc = pnpm_catalog_lens_api.get_catalog_and_catalogs_from_pnpm_workspace_yaml()

	if cc == nil then
		return
	end

	local catalog_deps = pnpm_catalog_lens_api.extract_catalog_dependencies_from_package_json(bufnr)

	if catalog_deps == nil then
		return
	end

	local catalog = cc.catalog
	local catalogs = cc.catalogs

	local diagnostics = {}
	-- Clear existing diagnostics
	vim.diagnostic.reset(ns, bufnr) -- Start fresh
	for dep, dep_info in pairs(catalog_deps) do
		---@type string|nil
		local version = nil
		if dep_info.named ~= nil then
			local named_catalog = (catalogs or {})[dep_info.named]
			if named_catalog ~= nil then
				version = named_catalog[dep]
			end
		else
			version = (catalog or {})[dep]
		end

		if version ~= nil then
			table.insert(diagnostics, {
				bufnr = bufnr,
				lnum = dep_info.line,
				col = dep_info.col,
				message = version,
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

return M
