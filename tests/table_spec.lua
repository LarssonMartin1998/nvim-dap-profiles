package.path = package.path .. ";lua/?.lua"

describe("Table", function()
    local tbl = require("nvim-dap-profiles.table")

    it("Length", function()
        local test_table = { foo = "bar", hello = "world" }
        assert.same(tbl.len(test_table), 2)

        test_table["john"] = "doe"
        assert.same(tbl.len(test_table), 3)

        test_table["jane"] = "doe"
        assert.same(tbl.len(test_table), 4)
    end)
end)
