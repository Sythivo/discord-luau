--[[
	Imports a Standard runtime library, in this case we're using Lune - but if we wanted to hop into another Runtime..
		theoretically, we could - we'd just need to emulate the lune runtime.
]]

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

return setmetatable({}, {
	__index = if (zune) then virtualSerde() else require("@lune/serde"),
})
