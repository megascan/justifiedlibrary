--  Name:       sv_notifications.lua
--  Realm:      Server
--  Purpose:    Allows convenient networking of messages from server to client.
--  Date:       07/03/2021 - 1:44 PM
local FindMetaTable = FindMetaTable
local meta = FindMetaTable("Player")

function meta:jlib_message(...)
    jnet.send("jlib.notifications", {
        msg = {...}
    }, self)
end

function jlib.broadcast(...)
    jnet.send("jlib.notifications", {
        msg = {...}
    })
end