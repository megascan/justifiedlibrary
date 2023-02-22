local math_random = math.random
local bNetReceive = net.Receive
local bNetReadString = net.ReadString
local bNetStart = net.Start
local bNetWriteString = net.WriteString
local bNetWriteInt = net.WriteInt
local bNetReadInt = net.ReadInt
local bNetReadData = net.ReadData
local bNetWriteData = net.WriteData
local bNetSendToServer = net.SendToServer
local bNetReadBool = net.ReadBool
local bNetWriteBool = net.WriteBool
local istable = istable
local Decompress = util.Decompress
local bNetWriteFloat = net.WriteFloat
local signature = CurTime
jlib.net = jlib.net or {}
jlib.net.registry = jlib.net.registry or {}
jlib.net.promise_registry = jlib.net.promise_registry or {}
local util = util
local jnet = jlib.net

jnet.subscribe = function(networkName, callback)
    if not callback then return end

    jlib.net.registry[networkName] = function(len)
        local bufferSize = bNetReadInt(32)
        if not bufferSize then return end --[[ malformed/invalid network received ]]
        local rawBuffer = bNetReadData(bufferSize)
        if not rawBuffer then return end
        local bufferData = util.JSONToTable(Decompress(rawBuffer))
        callback(bufferData, len - 0xD8)
    end
end

bNetReceive("jNet.NetworkChannel", function(len)
    local id = bNetReadString()
    local ispromise = bNetReadBool()

    if ispromise then
        local promise_id = bNetReadString()
        timer.Remove(promise_id)

        if jlib.net.promise_registry[promise_id] then
            jlib.net.promise_registry[promise_id]()
            jlib.net.promise_registry[promise_id] = nil

            return
        end

        return
    end

    local registry = jlib.net.registry[id]
    if not registry then return end
    registry(len)
end)

jnet.send = function(networkName, rawBuffer)
    local empty = false

    if not rawBuffer or not istable(rawBuffer) then
        empty = true
        rawBuffer = {}
    end

    local processedBuffer = not empty and util.Compress(util.TableToJSON(rawBuffer))
    local bufferSize = not empty and #processedBuffer
    bNetStart("jNet.NetworkChannel")
    bNetWriteString(networkName)

    if not empty then
        bNetWriteInt(bufferSize, 32)
        bNetWriteData(processedBuffer, bufferSize)
    end

    bNetWriteFloat(signature(), 32)
    bNetSendToServer()
end

jnet.promise = function(networkName, callback, rawBuffer, timeout)
    local promise_id = "jNet.Promise." .. signature() + math_random() * 9e9

    jlib.net.promise_registry[promise_id] = function()
        local bufferSize = bNetReadInt(32)
        if not bufferSize then return end --[[ malformed/invalid network received ]]
        local rawBuffer = bNetReadData(bufferSize)
        if not rawBuffer then return end
        local bufferData = util.JSONToTable(Decompress(rawBuffer))
        callback(bufferData)
    end

    if timeout then
        timer.Create(promise_id, timeout, 1, function()
            jlib.msg(string.format("[jNet] Warning! Promise ID: %s has expired!", promise_id))
            jlib.net.promise_registry[promise_id] = nil
        end)
    end

    local empty = false

    if not rawBuffer or not istable(rawBuffer) then
        empty = true
        rawBuffer = {}
    end

    local processedBuffer = not empty and util.Compress(util.TableToJSON(rawBuffer))
    local bufferSize = not empty and #processedBuffer
    bNetStart("jNet.NetworkChannel")
    bNetWriteString(networkName)
    bNetWriteBool(true)
    bNetWriteString(promise_id)

    if not empty then
        bNetWriteInt(bufferSize, 32)
        bNetWriteData(processedBuffer, bufferSize)
    end

    bNetWriteFloat(signature(), 32)
    bNetSendToServer()
end

_G["jnet"] = jnet
hook.Call("jnet.Init")