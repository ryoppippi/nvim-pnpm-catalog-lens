---@diagnostic disable: redefined-local

local api = vim.api
local uv = vim.uv
local yaml = require("pnpm_catalog_lens.yaml")

---@class PNPM_CATALOG_LENS_CONSTANTS
local constants = require("pnpm_catalog_lens.constants")

local M = {}

-- read file
---@param path string
local readFile = function(path)
	local fd = assert(uv.fs_open(path, "r", 438))
	local stat = assert(uv.fs_fstat(fd))
	local data = assert(uv.fs_read(fd, stat.size, 0))
	assert(uv.fs_close(fd))
	return data
end

M.find_pnpm_workspace = function()
	local cwd = vim.fn.getcwd()
	local root_dir = vim.fs.root(cwd, vim.iter({ ".git", constants.PNPM_WORKSPACE }):flatten(math.huge):totable())

	-- check if target is PNPM_WORKSPACE file
	local pnpm_workspace_path = vim.fs.joinpath(root_dir, constants.PNPM_WORKSPACE)
	if root_dir ~= nil and vim.uv.fs_stat(pnpm_workspace_path) ~= nil then
		return pnpm_workspace_path
	end

	return nil
end

-- parse pnpm-workspace.yaml and return catalogs
---@return table<string, string> | nil
M.get_catalogs_from_pnpm_workspace_yaml = function()
	local workspace_path = M.find_pnpm_workspace()
	if workspace_path == nil then
		return nil
	end

	local data = readFile(workspace_path)
	vim.print(data)

	local yaml_data = yaml.eval(data)

	local catalog = yaml_data.catalog

	if catalog == nil then
		return nil
	end

	return catalog
end

---@alias CatalogDependency {line: number, col: number}

-- parse the currrent buffer and return the keys/line/col which value is `:catalog`
---@param bufnr number buffer number
---@return table<string, CatalogDependency> | nil
M.extract_catalog_dependencies_from_package_json = function(bufnr)
	local result = {}
	for i, line in ipairs(api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		if line:find(constants.CATALOG_PREFIX) then
			-- chekc if the line includes constant.CATALOG_PREFIX
			local catalog_col = line:find(constants.CATALOG_PREFIX)
			if catalog_col ~= nil then
				-- get catalog key (ex. "zod": "catalog:" -> "zod")
				---@type string | nil
				local catalog_pkg = line:match('"(.-)"')
				if catalog_pkg ~= nil then
					result[catalog_pkg] = { line = i - 1, col = catalog_col }
				end
			end
		end
	end
	return result
end

return M
