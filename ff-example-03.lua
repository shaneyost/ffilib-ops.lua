#!/usr/bin/env luajit
local ffi = require("ffi")
local FF03 = {}

--- Some nuts to crack for next week. I should review the use of the following
--- functions `ffi.string`, `ffi.cast`. This example essentially reflects what
--- I will use in my table tool. These two functions I haven't really touched
--- on yet. Some initial questions to start thinking about for next week.
---
--- - Review again what (a) really represents and why we are casting it to a
---   `const char *`. Think about why you're doing this. For example, would
---   you do the same thing in C if you were going to write (a) to a file?
---
--- - We already know why we're deciding to pack everything to 1-byte
---   alignment. To solidfy our reasoning go over this again (i.e write it out
---   on why it's important for cross platform compatibility).
---
--- - Write a small response describing why we're using attributes here vs the
---   preprocessor statement `#pragma pack`. Refer to the warning statement in
---   the ffi documentation and quote that here so we remember "the why".
---
--- - If we could represent (a) not just as a struct but also as a raw byte
---   array it would make file i/o easier. For example, could implement a
---   union or similiar concept? See if you can use metatable to set this up.

function FF03.new(def, type)
    ffi.cdef(def)
    return ffi.typeof(type)
end

local def = [[
typedef struct {
    uint8_t x;
    uint8_t y;
} __attribute__((__packed__)) Point_t;
]]

local Point = FF03.new(def, "Point_t")
local a = Point({ x = 1, y = 2 })

local file = assert(io.open("table.bin", "wb"))
file:write(ffi.string(ffi.cast("const char *", a), ffi.sizeof(a)))
file:close()
