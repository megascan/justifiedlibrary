--  Name:       sv_notifications.lua
--  Realm:      Server
--  Purpose:    Allows convinient networking of messages from server to client.
--  Date:       07/03/2021 - 1:44 PM
local util_AddNetworkString = SERVER and util.AddNetworkString
local FindMetaTable = FindMetaTable
local net_Start = net.Start
local net_WriteTable = net.WriteTable
local net_Send = SERVER and net.Send
local net_Broadcast = SERVER and net.Broadcast
util_AddNetworkString("jlib.notifications")
local meta = FindMetaTable("Player")

function meta:jlib_message(...)
    net_Start("jlib.notifications")

    net_WriteTable({...} or {""})

    net_Send(self)
end

function jlib.broadcast(...)
    net_Start("jlib.notifications")

    net_WriteTable({...} or {""})

    net_Broadcast()
end