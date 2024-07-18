local profiles = require("nvim-dap-profiles.profiles")
local async = require("plenary.async")
local serializer = require("nvim-dap-profiles.profiles_serializer")

local M = {}

local function pcallargs(fn, ...)
    local args = { ... }
    local result, err = pcall(fn, unpack(args))
    if not result then
        print(err .. "\n" .. debug.traceback())
    end

    return result
end

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
    async.run(function()
        if path == nil or path == "" then
            print("Path is nil or empty")
            return
        end

        if name == nil or name == "" then
            print("Name is nil or empty")
            return
        end

        if pcallargs(profiles.create_profile, path, name) then
            serializer.serialize_profiles()
        end
    end)
end

function M.switch_to_profile(profile_name)
    async.run(function()
        if is_profile_name_invalid(profile_name) then
            return
        end

        if pcallargs(profiles.set_active_profile, profile_name) then
            serializer.serialize_profiles()
        end
    end)
end

function M.delete_profile(profile_name)
    async.run(function()
        if is_profile_name_invalid(profile_name) then
            return
        end

        if pcallargs(profiles.delete_profile, profile_name) then
            serializer.serialize_profiles()
        end
    end)
end

return M
