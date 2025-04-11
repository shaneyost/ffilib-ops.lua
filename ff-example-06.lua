#!/usr/bin/env luajit
local ffi = require("ffi")
local FF06 = {}

--- Say I wanted to simplify io such as create table files, logging or just
--- simple hex dumps. What makes sense and what doesn't? How could I leverage
--- metatables to implement my idea?
---
--- We will want the ability to add behavior to our cdata type constructor for
--- methods and behaviors. Because we're using FFI library we use the method
--- called `ffi.metatype` here NOT `setmetatable`.
---
--- Right away I know that I will represent the metamethod __index as a table.
--- I would like to wrap ffi methods a bit but only what makes sense. So a
--- method like `size` would be nice. Another method for returning a lua
--- immutable string (raw byte array really) would also be nice for file i/o.
---
--- Ok so that takes care of alot but what about logging/dumping the raw data?
--- I think __tostring metamethod makes the most sense here. Later I might
--- choose too implement a separate dumping function for just dumpting the raw
--- data and make __tostring the more elaborate dump with custom string
--- formatting.
---
---@usage Lua >
---     -- Easy file i/o
---     file:write(p:to_byte_string())
---     -- Printable/Resuable
---     print(p)
---     print(p:size())
--- <
---
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
function FF06.new(cdef, type)
    ffi.cdef(cdef)
    return ffi.metatype(ffi.typeof(type), {
        __index = {
            to_byte_string = function(self)
                return ffi.string(self.raw, self:size())
            end,
            size = function(self)
                return ffi.sizeof(self)
            end,
        },
        __tostring = function(self)
            local out = {}
            for i = 0, self:size() - 1 do
                local fmt = string.format("%02X", self.raw[i])
                table.insert(out, fmt)
            end
            return table.concat(out, " ")
        end,
    })
end

local cdef = [[
typedef union
{
    struct
    {
        uint8_t x;
        uint8_t y;
    };
    uint8_t raw[2];
} __attribute__((__packed__)) Point_u;
]]
---minidoc_afterlines_end

local Point = FF06.new(cdef, "Point_u")
local p = Point({ x = 1 })
print(p)
print(p:size())

local file = assert(io.open("table.bin", "wb"))
file:write(p:to_byte_string())
file:close()
