#!/usr/bin/env luajit
local ffi = require("ffi")
local FF_EXAMPLE_01 = {}

function FF_EXAMPLE_01.new(def, type)
    ffi.cdef(def)
    return ffi.metatype(ffi.typeof(type), {
        __index = {
            mag = function(self)
                return math.sqrt(self.x ^ 2 + self.y ^ 2)
            end,
        },
        __tostring = function(self)
            return string.format("(%d, %d)", self.x, self.y)
        end,
    })
end

local def = [[
typedef struct {
    uint8_t x;
    uint8_t y;
} Point_t;
]]

local Point = FF_EXAMPLE_01.new(def, "Point_t")
local a = Point({ x = 1, y = 2 })
print(a)
print(a:mag())
