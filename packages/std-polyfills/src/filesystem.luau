--[=[
    @class Std.FileSystem
]=]

local FileSystem = {}

setmetatable(FileSystem, { __index = if (zune) then zune.fs else require("@lune/fs") })

return FileSystem
