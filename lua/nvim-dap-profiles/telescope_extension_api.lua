local misc = require("nvim-dap-profiles.misc")
local profiles = require("nvim-dap-profiles.profiles")
local serializer = require("nvim-dap-profiles.profiles_serializer")

local async = require("plenary.async")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local custom_picker = function(title, include_active_profile, cb)
    local active_profile_name = nil
    if profiles.is_active_profile_set() then
        active_profile_name = profiles.get_active_profile().name
    end

    local all_profiles = profiles.get_all_profiles()
    local selectable_options = {}
    local active_profile_visualizer = " (Active profile)"
    for name, _ in pairs(all_profiles) do
        local is_profile_active = active_profile_name ~= nil and name == active_profile_name
        if is_profile_active then
            name = name .. active_profile_visualizer
        end

        if not is_profile_active or include_active_profile then
            table.insert(selectable_options, name)
        end
    end

    pickers.new({}, {
        prompt_title = title,
        finder = finders.new_table({
            results = selectable_options,
        }),
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(_, map)
            actions.select_default:replace(function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                cb(selection[1])
            end)
            return true
        end,
    }):find()
end
local M = {}

-- TODO: Create pickers for these API functions.
-- This way the user can use telescope to select which profile to switch to or delete
function M.ts_switch_to_profile()
    async.run(function()
        custom_picker("Switch Profile", false, function(profile_name)
            if misc.is_profile_name_invalid(profile_name) then
                return
            end

            if misc.xpcallargs(profiles.set_active_profile, profile_name) then
                serializer.serialize_profiles()
            end
        end)
    end)
end

function M.ts_delete_profile()
    async.run(function()
        custom_picker("Delete Profile", true, function(profile_name)
            if misc.is_profile_name_invalid(profile_name) then
                return
            end

            if misc.xpcallargs(profiles.delete_profile, profile_name) then
                serializer.serialize_profiles()
            end
        end)
    end)
end

return M
