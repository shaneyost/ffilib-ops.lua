#!/usr/bin/env luajit
local ffi = require("ffi")
local FF04 = {}

--- If I call `type(ffi.typeof(type)` this tells me very little. It just tells
--- me `cdata`. This is actually a cdata constructor object which is callable.
---
--- If I wanted to know that (a) is of type (Point) I could call something
--- like the following. This is about it from what I can gather.
---
---@usage Lua >
---     print(ffi.istype(Point, a))
--- <
---
--- It's important to know that (a) is a cdata struct, and LuaJIT stores it in
--- FFI-managed memory by value. So (a) contains the full struct itself. This
--- is all out of the FFI documentation.
---
--- One little side note. If happened to type ffi.typeof(a) then it will
--- return its concrete FFI type being a cdata object. However, if I register
--- a type with ffi.cdef it call it on that ffi.typeof('Point_t') then it will
--- return a type constructor. So if I called ffi.typeof(Point) it would give
--- me a concrete FFI type not a type constructor.
function FF04.new(def, type)
    ffi.cdef(def)
    return ffi.typeof(type)
end

local def = [[
typedef struct {
    uint8_t x;
    uint8_t y;
} __attribute__((__packed__)) Point_t;
]]

local Point = FF04.new(def, "Point_t")
local a = Point({ x = 1, y = 2 })

--- This is an example where it would not give me a type constructor and just
--- give me the FFI concrete type.
print("FFI concrete type: ", tostring(ffi.typeof(Point)))

print(tostring(Point))
print(ffi.istype(Point, a))
print("type(Point): ", type(Point))
print("type(a):     ", type(a))
print("ffi.typeof(Point): ", ffi.typeof(Point))
print("ffi.typeof(a):     ", ffi.typeof(a))
