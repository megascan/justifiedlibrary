--  Name:       cl_notifications.lua
--  Realm:      Client
--  Purpose:    Allows convenient networking of messages from server to client.
--  Date:       07/03/2021 - 1:44 PM
jnet.subscribe("jlib.notifications", function(buffer)
    chat.AddText(unpack(buffer.msg or {}))
end)