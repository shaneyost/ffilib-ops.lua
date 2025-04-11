#!/usr/bin/env luajit
local ffi = require("ffi")
local FF05 = {}

--- I know the answer to this question but I want to write it out. The
--- question is why would I pack C structures in my table tool. What issues
--- does packed 1-byte alignment fix?
---
--- If we don’t explicitly pack our C structures to 1-byte alignment, the
--- compiler or in our case, LuaJIT’s FFI subsystem may insert padding
--- between structure members to satisfy platform-specific alignment rules.
--- These rules align fields to their natural boundaries (e.g., `uint16_t` on
--- 2-byte boundaries, `uint32_t` on 4-byte boundaries), which helps optimize
--- memory access but alters the raw memory layout.
---
--- This implicit padding creates gaps between fields that can lead to binary
--- incompatibility when the structure is serialized (e.g., written to a file
--- or transmitted) and later interpreted by a C program expecting a
--- different layout. As a result, the binary layout may no longer perfectly
--- superimpose a corresponding C structure in a compiled target application,
--- causing ABI (Application Binary Interface) conflicts.
---
--- To avoid this, we pack our structures to 1-byte alignment, which
--- guarantees a deterministic, tightly packed memory layout with no padding.
--- This ensures that the generated binary representation is consistent and
--- interpretable by C code, regardless of how it was generated.
---
--- It’s important that our table tool can run on any host architecture (x86,
--- ARM, little-endian, big-endian) and still produce reliable, deterministic
--- output that is compatible with the target architecture's expectations.
--- Packing the structure removes alignment dependencies from the host system
--- making the tool's output portable and ABI-safe.

function FF05.new(cdef, type)
    ffi.cdef(cdef)
    return ffi.typeof(type)
end

function FF05.dsp(cdata)
    local ptr = ffi.cast("const uint8_t *", cdata)
    local size = ffi.sizeof(cdata)
    print(string.format("Size: %d (Bytes)", size))
    for i = 0, size - 1 do
        io.stdout:write(string.format("%02X ", ptr[i]))
    end
    io.stdout:write("\n")
end

local foo_cdef = [[
typedef struct
{
    uint8_t x;
    uint16_t y;
} Foo_t;
]]
local Foo_t = FF05.new(foo_cdef, "Foo_t")
local a = Foo_t({ x = 0x11, y = 0xDEAD })
FF05.dsp(a)

local foo_packed_cdef = [[
typedef struct
{
    uint8_t x;
    uint16_t y;
} __attribute__((__packed__)) FooPacked_t;
]]
local FooPacked_t = FF05.new(foo_packed_cdef, "FooPacked_t")
local b = FooPacked_t({ x = 0xFF, y = 0xDEAD })
FF05.dsp(b)
