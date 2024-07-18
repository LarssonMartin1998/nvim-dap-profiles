package.path = package.path .. ";lua/?.lua"

describe("Util", function()
    local util = require("nvim-dap-profiles.util")

    it("Table length", function()
        local test_table = { foo = "bar", hello = "world" }
        assert.same(util.table_len(test_table), 2)

        test_table["john"] = "doe"
        assert.same(util.table_len(test_table), 3)

        test_table["jane"] = "doe"
        assert.same(util.table_len(test_table), 4)
    end)
end)
