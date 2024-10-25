---@class PNPM_CATALOG_LENS_CONSTANTS
local M = {
	NAME = "pnpm-catalog-lens",
	PNPM_WORKSPACE = "pnpm-workspace.yaml",
	CATALOG_PREFIX = "catalog:",
	PACKAGE_JSON = "package.json",
}

-- Global variable for display option
vim.g.pnpm_catalog_display = "diagnostics" -- options: "diagnostics" or "overlay"

return M
