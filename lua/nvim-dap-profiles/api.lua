local misc = require("nvim-dap-profiles.misc")
local profiles = require("nvim-dap-profiles.profiles")
local async = require("plenary.async")
local serializer = require("nvim-dap-profiles.profiles_serializer")

local M = {}

-- TODO
function M.prompt_create_profile()
end

function M.create_profile(name, binary_path, run_dir_path)
    async.run(function()
        if binary_path == nil or binary_path == "" then
            print("Path is nil or empty")
            return
        end

        if name == nil or name == "" then
            print("Name is nil or empty")
            return
        end

        if misc.xpcallargs(profiles.create_profile, name, binary_path, run_dir_path) then
            serializer.serialize_profiles()
        end
    end)
end

function M.switch_to_profile(name)
    async.run(function()
        if misc.is_profile_name_invalid(name) then
            return
        end

        if misc.xpcallargs(profiles.set_active_profile, name) then
            serializer.serialize_profiles()
        end
    end)
end

function M.delete_profile(name)
    async.run(function()
        if misc.is_profile_name_invalid(name) then
            return
        end

        if misc.xpcallargs(profiles.delete_profile, name) then
            serializer.serialize_profiles()
        end
    end)
end

function M.add_pre_run_callback(callback)
    misc.xpcallargs(app.add_pre_run_callback, callback)
end

function M.add_post_run_callback(callback)

end

return M
