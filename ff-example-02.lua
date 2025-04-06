#!/usr/bin/env luajit
local ffi = require("ffi")
local FF_EXAMPLE_02 = {}

--- Ok, so tutorials/examples are fun and all but I need to dig deeper to
--- understand what all this means. I would like to do so without the
--- distraction of ffi's metatype. I shouldn't be focusing on metatypes just
--- quite yet. So lets start with `ffi.cdef`.
---
--- The docs say the following ...
---
--- > Adds multiple C declarations for types or external symbols (named
---   variables or functions). The arg `def` must be a Lua string. It's
---   recommended to use the syntactic sugar for string arguments (e.g. [[]]).
---
---   The contents of the string must be a sequence of C declarations,
---   separated by semicolons.
---
--- This is alot and sparks so more questions. Lets get these questions out of
--- the way first.
---
--- - What is implied by 'multiple C declaration'? I'm only specifying one in
---   my code. Does it mean I can technically pass several?
---
---     > Yes, I can pass multiple declarations in a single call to `ffi.cdef`
---       An example of doing so ...
---
---@usage >lua
---         ffi.cdef([[
---             typedef struct { int x; float y; } foo_t;
---             typedef struct { int a; int b; } bar_t;
---             int do_stuff(int x, float y);
---             int do_more(int a, int b);
---         ]])
--- <
---
--- - What is happening here with my declarations? What does it do with it?
---
---     > When I call `ffi.cdef`, LuaJIT parses the C declaration I provided.
---       It adds them to a internal C type registry. LuaJIT then allows me to
---       use those types for allocating memory `ffi.new`, casting pointers 
---       `ffi.cast` and calling external C functions via a library `ffi.load`
---     >
---     > It does not generate any actual code though or memory. It only is 
---       declaring types, function signatures and external symbols. I can 
---       think of it like providing LuaJIT a little .h file saying "Yo,
---       here's the stuff I want to work, please recognize it."
---
--- Ok, not too bad. So if we can register C declarations now why use the 
--- method `ffi.typeof(type)`. Didn't I just tell LuaJIT to recognize that
--- type?
---
---     > `ffi.cdef` registers a type globally so LuaJIT knows what it is. Now
---       `ffi.typeof() creates a handle to that type that I can use 
---       efficiently in Lua. 
--- 
--- Cool, so it gives me a Lua object I can treat like a constructor then. But
--- hold up, what does `ffi.new` do? Am I not suppose to use it too? What am I
--- missing?
---
---     > So after `ffi.cdef` it's stored in LuaJIT's memory or registry but
---       I'm not using it yet. Ah, `ffi.typeof` is a shortcut for making more
---       of these structures. So `ffi.typeof` is giving me a typed
---       constructor function or "handle" which is just a reusable helper for
---       making a thing. So what is `ffi.new` then?
---     >
---     > It turns out `ffi.new` is kind of the same thing as `ffi.typeof` but
---       it must first lookup the type every time. I see now why the shortcut
---       option is more friendly especially I want to create several of them.
---
---@usage >lua
---         -- why do this ...
---         local a = ffi.new("Point_t")
---         local b = ffi.new("Point_t")
---
---         -- when I can do this
---         local Point = ffi.typeof("Point_t")
---         local x = Point()
---         local y = Point()
--- <
---
--- So we return this typed constructor function (i.e. handle) so as to avoid
--- looking up the type by string every time, slightly faster less overhead,
--- and it's cleaner.
---
--- Lastly, I feel like i'm repeating myself by passing in "type". It's in the
--- "def" already. This goes against DRY (Don't Repeat Yourself). However, it
--- would add complexity requiring parsing. This gives no real gain in time
--- nor space in fact it would make it worse. So, I feel justified in leaving
--- it the way it is.

function FF_EXAMPLE_02.new(def, type)
    ffi.cdef(def)
    return ffi.typeof(type)
end

local def = [[
typedef struct {
    uint8_t x;
    uint8_t y;
} Point_t;
]]

local Point = FF_EXAMPLE_02.new(def, 'Point_t')
local a = Point({x=1, y=2})
print(string.format("(%d, %d)", a.x, a.y))
