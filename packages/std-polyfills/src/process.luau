--[=[
    @class Std.Process
]=]

local Process = {}

setmetatable(Process, { __index = if (zune) then zune.process else require("@lune/process") })

return Process
