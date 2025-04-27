#!/usr/bin/env luajit
local ffi = require("ffi")
local FF07 = {}

function FF07.new(cdef, type)
    ffi.cdef(cdef)
    print("type: ", type)
    print("size: ", ffi.sizeof(type))
    print("cdef: ", cdef)
    return ffi.metatype(ffi.typeof(type), {
        __index = {
            size = function (self) return ffi.sizeof(self) end
        }
    })
end

local cdef1 = [[
typedef struct
{
    uint32_t x;
    uint32_t y;
    uint8_t  c;
} __attribute__((__packed__)) X_t;
]]


local X = FF07.new(cdef1, 'X_t')
local x = X()
print("X_t: ", ffi.sizeof('X_t'))
print(x:size())
