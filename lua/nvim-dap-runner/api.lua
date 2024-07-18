local profiles = require("nvim-dap-runner.profiles")
local dap = require("dap")

local M = {}

local function is_profile_name_invalid(profile_name)
    if profile_name == nil or profile_name == "" then
        print("Profile name is nil or empty")
        return true
    end

    if not profiles.profile_exists(profile_name) then
        print("Profile does not exist: " .. profile_name)
        return true
    end

    return false
end

function M.create_profile(path, name)
    if path == nil or path == "" then
        print("Path is nil or empty")
        return
    end

    if name == nil or name == "" then
        print("Name is nil or empty")
        return
    end

    profiles.create_profile(path, name)
end

function M.switch_to_profile(profile_name)
    if is_profile_name_invalid(profile_name) then
        return
    end

    profiles.set_active_profile(profile_name)
end

function M.delete_profile(profile_name)
    if is_profile_name_invalid(profile_name) then
        return
    end

    profiles.delete_profile(profile_name)
end

function M.get_profiles()
    return profiles.get_all_profiles()
end

function M.get_active_profile()
    return profiles.get_active_profile()
end

return M
