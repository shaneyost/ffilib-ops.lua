#!/usr/bin/env luajit
local ffi = require("ffi")
local FF07 = {}

--- What would it look like if we created a union on all C structures that 
--- come through our table tool. This would simplify I/O operations for both
--- writing table files and displaying to console would it not?

--- Lets start by creating a function that takes a ctype definition and a
--- type as input. Lets go ahead and setup a metatable.

function FF07.new(cdef, type)
    ffi.cdef(cdef)
    return ffi.metatype(ffi.typeof(type), {
        __index = {
            to_byte_string = function (self)
                return ffi.string(self.raw, ffi.sizeof(self))
            end,
            size = function (self)
                return ffi.sizeof(self)
            end,
        },
        __tostring = function (self)
            local out = {}
            for i = 0, self:size() - 1 do
                table.insert(out, string.format("%02X", self.raw[i]))
            end
            return table.concat(out, " ")
        end,
    })
end

--- Cool, so now let me create the actual definition which we will specify a
--- union in there too. 

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

--- Now lets create the type constructor and then create a point (p).

local Point = FF07.new(cdef, 'Point_u');
local p = Point({x=1})
print(p)
print(p:size())

--- Lastly, need to test out our new fancy method to create table

local file = assert(io.open("table.bin", "wb"))
file:write(p:to_byte_string())
file:close()
