--[=[
    @class Std.stdio
]=]

local StdIO = {}

local function virtualStdio()
    local stdio = zune.stdio;
    return {
        style = stdio.style,
        color = function(color: string): string
            if (color == "reset") then
                return stdio.reset("color");
            end
            return stdio.color(color::any);
        end,
        style = function(style: string): string
            if (style == "reset") then
                return stdio.reset();
            end
            return stdio.style(style::any);
        end,
        ewrite = function(text: string)
            stdio.stderr:write(text);
        end,
        format = stdio.format,
    }
end


setmetatable(StdIO, { __index = if (zune) then virtualStdio() else require("@lune/stdio") })

return StdIO
