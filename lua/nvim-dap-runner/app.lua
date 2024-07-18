local M = {}

local profiles_file_name = ".nvim-dap-runner_profiles.toml"
local function profiles_file_exists()
    local file = io.open(profiles_file_name, "r")
    if file == nil then
        return false
    end

    io.close(file)
    return true
end

local function set_profiles_from_serialized_data(profiles, data)
    if not data then
        return
    end

    if not data.all_profiles then
        return
    end

    local names = {}
    local paths = {}
    for _, profile in pairs(data.all_profiles) do
        local valid_name = profile.name and profile.name ~= ""
        local valid_path = profile.path and profile.path ~= ""
        if valid_name and valid_path then
            table.insert(names, profile.name)
            table.insert(paths, profile.path)
        end
    end

    if #names == 0 or #paths == 0 then
        return
    end

    local profile_to_activate = nil
    if data.active_profile ~= nil then
        profile_to_activate = data.active_profile
    end

    profiles.create_profiles(names, paths, profile_to_activate)
end

local function intercept_run_fn_and_insert_program(profiles)
    local dap = require("dap")
    local original_run = dap.run
    dap.run = function(config, opts)
        local profile = profiles.get_active_profile()
        config.program = vim.fn.getcwd() .. "/" .. profile.path
        original_run(config, opts)
    end
end

function M.run()
    if not profiles_file_exists() then
        return
    end

    local profiles = require("nvim-dap-runner.profiles")
    local toml = require("nvim-dap-runner.toml")

    local serialized_profiles = toml.decode_from_file(profiles_file_name)
    set_profiles_from_serialized_data(profiles, serialized_profiles)

    intercept_run_fn_and_insert_program(profiles)
end

return M
