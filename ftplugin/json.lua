local api = vim.api

---@class PNPM_CATALOG_LENS_CONSTANTS
local constants = require("pnpm_catalog_lens.constants")

---@class PNPM_CATALOG_LENS_INIT
local M = require("pnpm_catalog_lens")

local bufnr = api.nvim_get_current_buf()
local filename = api.nvim_buf_get_name(bufnr)

if filename:sub(-#constants.PACKAGE_JSON) ~= constants.PACKAGE_JSON then
	return
end

api.nvim_buf_create_user_command(
	bufnr,
	"PnpmCatalogLensEnable",
	M.enable,
	{ nargs = 0, desc = "Enable the pnpm catalog lens" }
)

api.nvim_buf_create_user_command(
	bufnr,
	"PnpmCatalogLensDisable",
	M.disable,
	{ nargs = 0, desc = "Disable the pnpm catalog lens" }
)

M.enable()
