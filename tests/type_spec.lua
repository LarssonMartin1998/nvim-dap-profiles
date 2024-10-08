package.path = package.path .. ";lua/?.lua"

describe("Type", function()
    local type = require("nvim-dap-profiles.type")
    it("Type accuracy", function()
        local custom_types = {
            { {},    "event" },
            { {},    "test" },
            { "lol", "test2" },
            { 123,   "test3" },
        }

        local all_types = {
            { function() end, "function" },
            { "string",       "string" },
            { 123,            "number" },
            { true,           "boolean" },
            { {},             "table" },
            { nil,            "nil" },
        }

        for _, custom_type in pairs(custom_types) do
            local is_value_type = type.get(custom_type[1]) ~= "table"
            local value_copy = custom_type[1]

            custom_type[1] = type.create(unpack(custom_type))
            table.insert(all_types, custom_type)

            if is_value_type then
                assert.equals(tostring(value_copy), tostring(custom_type[1]))
            end
        end

        for _, test_type in pairs(all_types) do
            local a = type.get(test_type[1])
            local b = test_type[2]
            assert.equals(a, b)
        end
    end)
    it("Value changes", function()
        local custom1 = type.create("test", "event")
        assert.equals(tostring(custom1), "test")

        custom1 = "testvalue"
        assert.equals(tostring(custom1), "testvalue")

        local custom2 = type.create(123, "event")
        assert.equals(tostring(custom2), "123")

        custom2 = 456
        assert.equals(tostring(custom2), "456")
    end)
end)
