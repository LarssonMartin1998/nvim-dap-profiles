local M = {}

local has_run_setup = false

local function run()
    require("nvim-dap-profiles.app").run()
end

function M.setup(_)
    if has_run_setup then
        print("Trying to run nvim-dap-runner.setup() twice. Make sure to fix in your config.")
        return
    end

    require("plenary.async").run(run)
end

local function user_has_plugin(plugin_req_str)
    local result, plugin = pcall(require, plugin_req_str)
    return result and plugin
end

local function add_plugin_extension_api_to_index_table(index_table, plugin_extension)
    if not user_has_plugin(plugin_extension[1]) then
        return index_table
    end

    return vim.tbl_extend("force", index_table, require("nvim-dap-profiles." .. plugin_extension[2]))
end

local function build_index_table()
    local index_table = require("nvim-dap-profiles.api")
    assert(index_table, "Failed to initialize index_table with api table")

    local plugin_extensions = {
        { "telescope", "telescope_extension_api" }
    }

    for _, plugin in ipairs(plugin_extensions) do
        index_table = add_plugin_extension_api_to_index_table(index_table, plugin)
        assert(index_table, "Failed to add plugin extension to index table:" .. plugin[1] .. " | " .. plugin[2])
    end

    assert(index_table, "Failed to build index table")
    return index_table
end

local index_table = build_index_table()
return setmetatable(M, {
    __index = function(_, key)
        return index_table[key]
    end
})
