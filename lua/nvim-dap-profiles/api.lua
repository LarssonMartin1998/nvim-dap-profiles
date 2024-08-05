local misc = require("nvim-dap-profiles.misc")
local profiles = require("nvim-dap-profiles.profiles")
local async = require("plenary.async")
local serializer = require("nvim-dap-profiles.profiles_serializer")

local M = {}

-- TODO
function M.prompt_create_profile()
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

        if misc.xpcallargs(profiles.create_profile, path, name) then
            serializer.serialize_profiles()
        end
    end)
end

function M.switch_to_profile(profile_name)
    async.run(function()
        if misc.is_profile_name_invalid(profile_name) then
            return
        end

        if misc.xpcallargs(profiles.set_active_profile, profile_name) then
            serializer.serialize_profiles()
        end
    end)
end

function M.delete_profile(profile_name)
    async.run(function()
        if misc.is_profile_name_invalid(profile_name) then
            return
        end

        if misc.xpcallargs(profiles.delete_profile, profile_name) then
            serializer.serialize_profiles()
        end
    end)
end

return M
