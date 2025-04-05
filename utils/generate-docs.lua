if not package.loaded["mini.doc"] then
    require("mini.doc").setup()
end
require("mini.doc").generate({
    "ff-example-01.lua",
})
