--[=[
    @class Std.Task
]=]

local Task = {}

setmetatable(Task, { __index = if (zune) then zune.task else require("@lune/task") })

return Task
