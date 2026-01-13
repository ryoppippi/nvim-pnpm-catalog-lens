---@class PNPM_CATALOG_LENS_CONSTANTS
local M = {
	NAME = "pnpm-catalog-lens",
	PNPM_WORKSPACE = "pnpm-workspace.yaml",
	CATALOG_PREFIX = "catalog:",
	PACKAGE_JSON = "package.json",
}

-- Global variable for display option
if vim.g.pnpm_catalog_display == nil then
	vim.g.pnpm_catalog_display = "diagnostics" -- options: "diagnostics", "overlay", or "inlay"
end

return M
