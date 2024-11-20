--[[
    Imports a Standard runtime library, in this case we're using Lune - but if we wanted to hop into another Runtime..
        theoretically, we could - we'd just need to emulate the lune runtime.
]]

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

local net = if (zune) then virtualNet() else require("@lune/net")

--[[
    because 'udpSocket' is not actually apart of @lune/net, instead it was apart of a fork of @lune
        we don't want normal lune installs to error out - so I've implemented a generic/simple sandbox
        which simulates a 'udpSocket' but won't ever connect, send or recieve data.
]]

local udpSocket = (net :: any).udpSocket
local udpSocketClose = (net :: any).udpSocketClose

if not (net :: any).udpSocket then
    udpSocket = function()
        local self = {}

        self.send = function() end
        self.next = function()
            coroutine.yield()
        end
        self.connect = function() end

        return self
    end

    udpSocketClose = function() end
end

export type WebSocket = net.WebSocket
export type FetchResponse = net.FetchResponse

return setmetatable({
    udpSocket = udpSocket,
    udpSocketClose = udpSocketClose,
}, {
    __index = net,
})
