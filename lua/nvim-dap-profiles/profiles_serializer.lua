local profiles = require("nvim-dap-profiles.profiles")
local toml = require("nvim-dap-profiles.toml")

local M = {}

local profiles_file_name = ".nvim-dap-profiles.toml"

local function profiles_file_exists()
    local file = io.open(profiles_file_name, "r")
    if file == nil then
        return false
    end

    io.close(file)
    return true
end

function M.serialize_profiles()
    local all_profiles = profiles.get_all_profiles()
    local active_profile = profiles.get_active_profile()

    local table_to_serialize = {
        all_profiles = all_profiles,
        active_profile = active_profile
    }

    toml.encode_to_file(profiles_file_name, table_to_serialize)
end

function M.deserialize_profiles()
    if not profiles_file_exists() then
        return
    end

    local data = toml.decode_from_file(profiles_file_name)
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

return M
