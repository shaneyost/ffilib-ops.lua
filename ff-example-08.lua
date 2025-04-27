#!/usr/bin/env luajit
local clk = os.clock
local N = 10
-- local N = 1024 * 1024
local function loop1()
    local start = clk()
    local out = {}
    -- local n = 0
    for i=1, N do
        -- n = n + 1
        -- out[n] = i
        out[#out+1] = i
    end
    print("loop1: ", clk() - start)
end
local function loop2()
    local start = clk()
    local out = {}
    for i=1, N do
        table.insert(out, i)
    end
    print("loop2: ", clk() - start)
end
loop1()
loop2()
local t = {}
for i=1,1000000 do
    t[i] = i
end
t[1000000] = nil
print(#t)

