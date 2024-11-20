--[=[
    @class Std.Net
]=]

local Net = {}

local function virtualNet()
    local net = zune.net;
    local serde = zune.serde;
    local task = zune.task;

    return {
        request = function(config)
            return net.request(config.url, config)
        end,
        socket = function(url)
            local queue: {string} = {};
            local waiting: {thread} = {};
            local self;
            local socket = net.websocket(url, {
                close = function(socket, code)
                    self.closeCode = code;
                end,
                message = function(socket, data)
                    if (#waiting > 0) then
                        local thread = table.remove(waiting, 1);
                        assert(thread, "No thread to resume");
                        task.spawn(thread, data);
                    else
                        table.insert(queue, data);
                    end
                end,
            })
            local self = {
                send = function(data)
                    socket:send(data)
                end,
                next = function()
                    local thread = coroutine.running();
                    if (#queue > 0) then
                        return table.remove(queue, 1);
                    else
                        table.insert(waiting, thread);
                        return coroutine.yield();
                    end
                end,
                close = function()
                    socket:close()
                end,
            };
            return self;
        end,
        jsonDecode = function(data: string): any
            return serde.json.decode(data);
        end,
        jsonEncode = function(data: any, pretty: boolean?)
            return serde.json.encode(data, if (pretty) then {
                prettyIndent = serde.json.Indents.Tabs,
            } else nil);
        end,
    };
end

local LuneNet = if (zune) then virtualNet() else require("@lune/net")

export type WebSocket = LuneNet.WebSocket
export type FetchResponse = LuneNet.FetchResponse
export type FetchParams = LuneNet.FetchParams
export type HttpMethod = LuneNet.HttpMethod
export type HttpHeaderMap = LuneNet.HttpHeaderMap

setmetatable(Net, { __index = LuneNet })

return Net
