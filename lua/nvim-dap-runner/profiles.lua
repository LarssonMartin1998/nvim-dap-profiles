local util = require("nvim-dap-runner.util")

local M = {}

--[[
A profile contains the path to the binary and a name for the profile:
{
    name = "profile_name",
    path = "/path/to/binary"
}
--]]
local all_profiles = {}
local active_profile = nil

function M.is_profile_valid(profile_name)
    assert(profile_name ~= nil and profile_name ~= "", "Profile name is nil or empty")
    assert(M.profile_exists(profile_name), "Profile does not exist: " .. profile_name)

    local function valid_check(test_str)
        return test_str ~= nil and test_str ~= ""
    end

    local profile = M.get_profile(profile_name)
    return valid_check(profile.name) and valid_check(profile.path)
end

function M.profile_exists(profile_name)
    assert(profile_name ~= nil and profile_name ~= "", "Profile name is nil or empty")
    return all_profiles[profile_name] ~= nil
end

function M.set_active_profile(profile_name)
    assert(profile_name ~= nil and profile_name ~= "", "Profile name is nil or empty")
    assert(M.profile_exists(profile_name), "Profile does not exist: " .. profile_name)
    assert(M.is_profile_valid(profile_name), "Profile is not valid: " .. profile_name)
    assert(active_profile ~= profile_name, "Active profile already set: " .. profile_name)

    active_profile = profile_name

    assert(M.get_active_profile() == M.get_profile(active_profile), "Active profile was not set correctly")
    assert(M.is_profile_valid(active_profile), "Profile is not valid: " .. active_profile)
end

function M.get_active_profile()
    return M.get_profile(active_profile)
end

function M.get_profile(profile_name)
    assert(profile_name ~= nil and profile_name ~= "", "Profile name is nil or empty")
    return all_profiles[profile_name]
end

function M.create_profiles(names, paths, profile_to_activate)
    assert(names ~= nil and #names > 0, "Names is nil or empty")
    assert(paths ~= nil and #paths > 0, "Paths is nil or empty")
    assert(#paths == #names, "Paths and names are not the same length")

    for i, path in ipairs(paths) do
        assert(names[i] ~= nil and names[i] ~= "", "Name is nil or empty")
        assert(path ~= nil and path ~= "", "Path is nil or empty")

        M.create_profile(path, names[i], names[i] == profile_to_activate)
    end
end

function M.create_profile(path, name, activate)
    assert(path ~= nil and path ~= "", "Path is nil or empty")
    assert(name ~= nil and name ~= "", "Name is nil or empty")
    assert(not M.profile_exists(name), "Profile already exists: " .. name)

    local prev_tot_profiles = util.table_len(all_profiles)
    if prev_tot_profiles == 0 then
        activate = true
    end

    all_profiles[name] = {
        name = name,
        path = path
    }

    if activate then
        M.set_active_profile(name)
    end

    assert(prev_tot_profiles + 1 == util.table_len(all_profiles), "Profile was not added to all_profiles")
    assert(M.profile_exists(name), "Profile does not exist after trying to create it: " .. name)
    assert((activate and M.get_active_profile().name == name) or (not activate and active_profile ~= name),
        "Active profile was not set correctly")
end

function M.delete_profiles(profile_names)
    assert(profile_names ~= nil and #profile_names > 0, "Profile names is nil or empty")

    local prev_tot_profiles = util.table_len(all_profiles)
    for _, name in ipairs(profile_names) do
        assert(name ~= nil and name ~= "", "Name is nil or empty")
        assert(M.profile_exists(name), "Profile does not exist: " .. name)

        M.delete_profile(name)
    end

    assert(prev_tot_profiles - #profile_names == util.table_len(all_profiles), "Profiles were not deleted")
end

function M.delete_profile(profile_name)
    assert(profile_name ~= nil and profile_name ~= "", "Profile name is nil or empty")
    assert(M.profile_exists(profile_name), "Profile does not exist: " .. profile_name)

    local prev_tot_profiles = util.table_len(all_profiles)
    all_profiles[profile_name] = nil
    if active_profile == profile_name then
        active_profile = nil
    end

    assert(prev_tot_profiles - 1 == util.table_len(all_profiles), "Profile was not deleted from all_profiles")
    assert(not M.profile_exists(profile_name), "Profile still exists after trying to delete it: " .. profile_name)
    assert(active_profile ~= profile_name, "Active profile was not unset")
end

function M.delete_all_profiles()
    all_profiles = {}
    active_profile = nil

    -- TODO: Update the Toml file
end

function M.get_num_profiles()
    return util.table_len(all_profiles)
end

function M.get_all_profiles()
    return all_profiles
end

return M
