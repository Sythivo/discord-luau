--[=[
    @class Std.DateTime
]=]

local DateTime = {}

local LuneDateTime = if (zune) then zune.datetime else require("@lune/datetime")

export type DateTime = LuneDateTime.DateTime

setmetatable(DateTime, { __index = LuneDateTime })

return DateTime
