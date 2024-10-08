local type = require("nvim-dap-profiles.type")

local M = {}

local all_callbacks = {}

function M.clear_events()
    all_callbacks = {}
end

function M.add_event_group(event)
    assert(type.get(event) == "event", "Event must be an event type")
    assert(all_callbacks[event] == nil, "Event group already exists")

    all_callbacks[event] = {}
end

-- Use returned index to remove callback
function M.add_callback(event, callback)
    assert(event, "Event cannot be nil")
    assert(callback, "Callback cannot be nil")
    assert(type.get(event) == "event", "Event must be an event type")
    assert(type.get(callback) == "function", "Callback must be a function")

    table.insert(all_callbacks[event], callback)
    return #all_callbacks[event]
end

-- We could create a system that tracks which indices are empty
-- and reuse them when adding new callbacks, but that would be
-- overkill for this use case
function M.remove_callback(event, index)
    assert(event, "Event cannot be nil")
    assert(type.get(event) == "event", "Event must be an event type")
    assert(type.get(index) == "number", "Index must be a number")
    assert(all_callbacks[event][index], "Index is not valid, callback doesn't exist")

    -- We have to make sure that the indices for the remaining
    -- callbacks are not affected by the removal, so removing
    -- should leave a hole in the table
    all_callbacks[event][index] = nil
end

function M.fire(event, ...)
    assert(event, "Event cannot be nil")
    assert(type.get(event) == "event", "Event must be an event type")

    for _, callback in ipairs(all_callbacks[event]) do
        -- Expected behavior to have nil callbacks if they were removed
        if callback then
            callback(...)
        end
    end
end

return M
