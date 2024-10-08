local serializer = require("nvim-dap-profiles.profiles_serializer")
local profiles = require("nvim-dap-profiles.profiles")
local event_dispatcher = require("nvim-dap-profiles.event_dispatcher")
local events = require("nvim-dap-profiles.events")
local dap = require("dap")

local M = {}

local function profiles_run()
    local original_run = dap.run
    dap.run = function(config, opts)
        -- Make sure to always deserialize profiles before running, otherwise, we risk not using
        -- the latest profiles if the user updated the file directly.
        -- This should not be an issue as long as the profiles are serialized after any changes.
        -- Otherwise, we would risk running with outdated profiles.
        serializer.deserialize_profiles()

        local profile = nil
        local cwd = vim.fn.getcwd()
        local original_cwd = cwd
        if profiles.is_active_profile_set() then
            profile = profiles.get_active_profile()
            if cwd:sub(-1) ~= "/" then
                cwd = cwd .. "/"
            end

            local binary_path = profile.binary_path
            if binary_path:sub(1, 1) == "/" then
                binary_path = binary_path:sub(2)
            end

            local run_dir_path = profile.run_dir_path
            if run_dir_path ~= nil and run_dir_path ~= "" then
                if run_dir_path:sub(-1) ~= "/" then
                    run_dir_path = run_dir_path .. "/"
                end

                if run_dir_path:sub(1, 1) == "/" then
                    run_dir_path = run_dir_path:sub(2)
                end

                cwd = cwd .. run_dir_path
            end

            config.program = cwd .. binary_path
        end

        event_dispatcher.fire_callbacks(events.PRE_DAP_RUN, profile, cwd)
        original_run(config, opts)
        event_dispatcher.fire_callbacks(events.POST_DAP_RUN, profile, original_cwd)
    end
end

local function profile_has_run_dir(profile)
    return profile ~= nil and profile.run_dir_path ~= nil and profile.run_dir_path ~= ""
end

local function change_cwd_if_run_dir(profile, path)
    if not profile_has_run_dir(profile) then
        return
    end

    vim.api.nvim_set_current_dir(path)
end

local function change_cwd_to_run_dir(profile, cwd)
    change_cwd_if_run_dir(profile, cwd)
end

local function change_cwd_to_original_dir(profile, original_cwd)
    change_cwd_if_run_dir(profile, original_cwd)
end

local function setup_hooks()
    profiles_run()

    local callbacks = {
        [events.PRE_DAP_RUN] = {
            change_cwd_to_run_dir,
        },
        [events.POST_DAP_RUN] = {
            change_cwd_to_original_dir,
        },
    }

    for event, event_callbacks in pairs(callbacks) do
        for _, callback in pairs(event_callbacks) do
            event_dispatcher.add_callback(event, callback)
        end
    end
end

function M.run()
    for _, event in pairs(events) do
        event_dispatcher.add_event_group(event)
    end

    serializer.deserialize_profiles()
    setup_hooks()
end

return M
