---@diagnostic disable: redefined-local

---@alias CatalogDependency {line: number, col: number, named: string|nil}
---@alias Catalog table<string, string>
---@alias Catalogs table<string, Catalog>

local api = vim.api
local uv = vim.uv
local fs = vim.fs
local yaml = require("pnpm_catalog_lens.yaml")

---@class PNPM_CATALOG_LENS_CONSTANTS
local constants = require("pnpm_catalog_lens.constants")

---@class PNPM_CATALOG_LENS_API
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
	local root_dir = fs.root(
		cwd,
		vim.iter({ ".git", constants.PNPM_WORKSPACE, constants.YARN_WORKSPACE }):flatten(math.huge):totable()
	)

	if root_dir ~= nil then
		local pnpm_workspace_path = fs.joinpath(root_dir or "", constants.PNPM_WORKSPACE)
		if uv.fs_stat(pnpm_workspace_path) ~= nil then
			return pnpm_workspace_path
		end

		local yarn_workspace_path = fs.joinpath(root_dir or "", constants.YARN_WORKSPACE)
		if uv.fs_stat(yarn_workspace_path) ~= nil then
			return yarn_workspace_path
		end
	end

	return nil
end

-- parse pnpm-workspace.yaml and return catalogs
---@return {catalogs: Catalogs|nil, catalog: Catalog|nil} | nil
M.get_catalog_and_catalogs_from_pnpm_workspace_yaml = function()
	local workspace_path = M.find_pnpm_workspace()
	if workspace_path == nil then
		return nil
	end

	local data = readFile(workspace_path)

	if data == nil or #data == 0 then
		return nil
	end

	-- delete blank lines
	data = data:gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n+", "\n")

	local yaml_data = yaml.eval(data)

	return {
		catalog = yaml_data.catalog,
		catalogs = yaml_data.catalogs,
	}
end

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

				--get named catalog (ex. "react": "catalog:react18" -> "react18")
				---@type string | nil
				local named = line:match("catalog:(%w+)")

				if catalog_pkg ~= nil then
					result[catalog_pkg] = { line = i - 1, col = catalog_col, named = named }
				end
			end
		end
	end
	return result
end

return M
