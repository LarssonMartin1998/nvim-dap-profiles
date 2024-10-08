package.path = package.path .. ";lua/?.lua"

describe("Event Dispatcher", function()
    local events = require("nvim-dap-profiles.events")
    local event_dispatcher = require("nvim-dap-profiles.event_dispatcher")

    it("Adds event group", function()
        event_dispatcher.add_event_group(events.PRE_DAP_RUN)

        local did_callback_run = false
        local callback_id = event_dispatcher.add_callback(events.PRE_DAP_RUN, function()
            did_callback_run = true
        end)

        assert.is_false(did_callback_run)
        event_dispatcher.fire(events.PRE_DAP_RUN)
        assert.is_true(did_callback_run)

        did_callback_run = false
        event_dispatcher.remove_callback(events.PRE_DAP_RUN, callback_id)
        event_dispatcher.fire(events.PRE_DAP_RUN)
        assert.is_false(did_callback_run)
    end)
end)
