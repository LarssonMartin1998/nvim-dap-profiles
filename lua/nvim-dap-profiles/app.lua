local serializer = require("nvim-dap-profiles.profiles_serializer")
local profiles = require("nvim-dap-profiles.profiles")
local dap = require("dap")

local M = {}

local function intercept_run_fn_and_insert_program()
    local original_run = dap.run
    dap.run = function(config, opts)
        if not profiles.is_active_profile_set() then
            original_run(config, opts)
            return
        end

        local profile = profiles.get_active_profile()
        local cwd = vim.fn.getcwd()
        if cwd:sub(-1) ~= "/" then
            cwd = cwd .. "/"
        end

        local profile_path = profile.path
        if profile_path:sub(1, 1) == "/" then
            profile_path = profile_path:sub(2)
        end

        config.program = cwd .. profile_path
    end
end

function M.run()
    serializer.deserialize_profiles()
    intercept_run_fn_and_insert_program()
end

return M
