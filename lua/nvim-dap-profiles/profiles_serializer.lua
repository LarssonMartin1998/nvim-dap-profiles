local profiles = require("nvim-dap-profiles.profiles")
local toml = require("nvim-dap-profiles.toml")

local M = {}

local profiles_file_name = ".nvim-dap-profiles.toml"

-- This function is mainly intended to streamline testing
local function get_file_name(profiles_file_override)
    return profiles_file_override or profiles_file_name
end

local function profiles_file_exists(profiles_file_override)
    local file = io.open(get_file_name(profiles_file_override), "r")
    if file == nil then
        return false
    end

    io.close(file)
    return true
end

function M.serialize_profiles(profiles_file_override)
    local table_to_serialize = {
        all_profiles = profiles.get_all_profiles(),
    }

    if profiles.is_active_profile_set() then
        table_to_serialize.active_profile = profiles.get_active_profile().name
    end

    toml.encode_to_file(get_file_name(profiles_file_override), table_to_serialize)
end

function M.deserialize_profiles(profiles_file_override)
    if not profiles_file_exists(profiles_file_override) then
        return
    end

    local data = toml.decode_from_file(get_file_name(profiles_file_override))
    if not data then
        return
    end

    if not data.all_profiles then
        return
    end

    local names = {}
    local binary_paths = {}
    local run_dir_paths = {}
    for _, profile in pairs(data.all_profiles) do
        local valid_name = profile.name and profile.name ~= ""
        local valid_path = profile.binary_path and profile.binary_path ~= ""
        if valid_name and valid_path then
            table.insert(names, profile.name)
            table.insert(binary_paths, profile.binary_path)

            local valid_run_dir = profile.run_dir_path and profile.run_dir_path ~= ""
            if valid_run_dir then
                table.insert(run_dir_paths, profile.run_dir_path)
            else
                table.insert(run_dir_paths, nil)
            end
        end
    end

    if #names == 0 or #binary_paths == 0 then
        return
    end

    local profile_to_activate = nil
    if data.active_profile ~= nil then
        profile_to_activate = data.active_profile
    end

    profiles.create_profiles(names, binary_paths, run_dir_paths, profile_to_activate)
end

return M
