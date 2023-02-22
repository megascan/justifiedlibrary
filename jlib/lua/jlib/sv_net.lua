jlib.net = jlib.net or {}
jlib.net.registry = jlib.net.registry or {}
jlib.net.ratelimiting = {}
local registerNetworkChannel = util.AddNetworkString
local Decompress = util.Decompress
local registerNetworkChannel = registerNetworkChannel
local bNetReadInt = net.ReadInt
local bNetReadData = net.ReadData
local bNetWriteData = net.WriteData
local CurTime = CurTime
local istable = istable
local bNetStart = net.Start
local bNetWriteString = net.WriteString
local bNetWriteInt = net.WriteInt
local bNetReadInt = net.ReadInt
local bNetSend = net.Send
local bNetBroadcast = net.Broadcast
local bNetReceive = net.Receive
local bNetReadString = net.ReadString
local bNetWriteBool = net.WriteBool
local bNetReadBool = net.ReadBool
local bNetReadFloat = net.ReadFloat
local hAdd = hook.Add
local clean = table.Empty
local jnet = jlib.net
jnet.msgqueue = {}
jnet.lastprint = {}

function jnet.msg(...)
    MsgC(Color(217, 0, 255), "[/jNet/] ", Color(235, 235, 235), unpack({...}), "\n")
end

jnet.ratelimit = function(networkName, ply, time)
    local key = ply:SteamID64()
    if not networkName then return false end
    jlib.net.ratelimiting[key] = jlib.net.ratelimiting[key] or {}
    jlib.net.ratelimiting[key][networkName] = jlib.net.ratelimiting[key][networkName] or 0
    local within_limits = false

    if jlib.net.ratelimiting[key][networkName] > CurTime() then
        within_limits = true
    end

    jlib.net.ratelimiting[key][networkName] = CurTime() + time

    return within_limits
end

jnet.subscribe_promise = function(networkName, callback, ratelimitDelay, maxNetworkLength)
    if not callback then
        print("callback not found")

        return
    end

    jlib.net.registry[networkName] = function(len, ply)
        if maxNetworkLength and len > #networkName + maxNetworkLength then
            return
        elseif jnet.ratelimit(networkName, ply, ratelimitDelay) then
            if not jnet.ratelimit(networkName .. "_out", ply, 1) then
                local p_formatted = ply:Name() .. " [" .. ply:SteamID64() .. "]"
                jnet.msg(p_formatted .. " hit promise ratelimit " .. networkName .. " only accepts requests every " .. ratelimitDelay)
            end

            return
        end

        local is_promise = bNetReadBool()
        local promise_id = bNetReadString()
        local bufferSize = bNetReadInt(32)
        local rawBuffer = bNetReadData(bufferSize)
        local bufferData = util.JSONToTable(Decompress(rawBuffer))
        local request_time = bNetReadInt(32)
        print("received promise ", is_promise, promise_id, request_time, CurTime())

        callback(ply, bufferData, function(data)
            jnet.send(networkName, istable(data) and data or {data}, ply, true, promise_id)
        end)
    end
end

jnet.subscribe = function(networkName, callback, ratelimitDelay, maxNetworkLength)
    if not callback then return end

    jlib.net.registry[networkName] = function(len, ply)
        if maxNetworkLength and len > #networkName + maxNetworkLength then
            return
        elseif jnet.ratelimit(networkName, ply, ratelimitDelay) then
            if not jnet.ratelimit(networkName .. "_out", ply, 1) then
                local p_formatted = ply:Name() .. " [" .. ply:SteamID64() .. "]"
                jnet.msg(p_formatted .. " hit ratelimit " .. networkName .. " only accepts requests every " .. ratelimitDelay)
            end

            return
        end

        local bufferSize = bNetReadInt(32)
        local rawBuffer = bNetReadData(bufferSize)
        local bufferData = util.JSONToTable(Decompress(rawBuffer))
        local request_time = bNetReadFloat(32)
        if CurTime() - request_time > 1 then return end
        callback(ply, bufferData, len - #networkName)
    end
end

jnet.send = function(networkName, rawBuffer, recepients, promise, promise_id)
    local empty = false

    if not rawBuffer or not istable(rawBuffer) then
        empty = true
        rawBuffer = {}
    end

    local processedBuffer = not empty and util.Compress(util.TableToJSON(rawBuffer))
    local bufferSize = not empty and #processedBuffer
    bNetStart("jNet.NetworkChannel")
    bNetWriteString(networkName)
    bNetWriteBool(promise or false)

    if promise then
        bNetWriteString(promise_id)
    end

    if not empty then
        bNetWriteInt(bufferSize, 32)
        bNetWriteData(processedBuffer, bufferSize)
    end

    local recepient_type = type(recepients)

    if recepients and recepient_type == "Player" or recepient_type == "table" then
        bNetSend(recepients)
    else
        bNetBroadcast()
    end
end

bNetReceive("jNet.NetworkChannel", function(len, ply)
    local registry = jlib.net.registry[bNetReadString()]
    if not registry then return end
    registry(len, ply)
end)

hAdd("PlayerDisconnected", "jNet.CleanupGarbage", function(ply)
    if jlib.net.ratelimiting[ply:SteamID64()] then
        clean(jlib.net.ratelimiting[ply:SteamID64()])
    end
end)

registerNetworkChannel("jNet.NetworkChannel")
_G["jnet"] = jnet
hook.Call("jnet.Init")