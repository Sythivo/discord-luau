--[=[
    @class Std.Serde
]=]

local Serde = {}

local function virtualSerde()
    local serde = zune.serde;

    return {
        decode = function(encoding: string, data: string): any
            return serde[encoding].decode(data)
        end,
        encode = function(encoding: string, data: any): string
            return serde[encoding].encode(data)
        end,
        decompress = function(compression: string, data: string): string
            return serde[compression].decompress(data)
        end,
    }
end

setmetatable(Serde, { __index = if (zune) then virtualSerde() else require("@lune/serde") })

return Serde
