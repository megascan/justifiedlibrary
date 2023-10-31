jlib.SQL = jlib.SQL or {}
require("mysqloo")

local function init()
    -- Setup the sql connection
    jlib.SQL.DB = mysqloo.connect(jlib.SQL.Host, jlib.SQL.Username, jlib.SQL.Password, jlib.SQL.Database, jlib.SQL.Port)

    -- What to do if successfully connected
    jlib.SQL.DB.onConnected = function()
        print("[jlib MySQL] Database has connected!")
        hook.Run("jlib.SQL.CreateDatabases")
    end

    -- Print error to console if we fail
    jlib.SQL.DB.onConnectionFailed = function(db, err)
        print("[jlib MySQL] Connection to database failed! Error: " .. err)
    end

    -- Connect
    jlib.SQL.DB:connect()

    -- Here's our MySQL query function
    function jlib.SQL.Query(queryr, func, singleRow)
        local query = jlib.SQL.DB:query(queryr)

        if func then
            function query:onSuccess(data)
                if singleRow then
                    data = data[1]
                end

                func(data)
            end
        end

        function query:onError(err)
            local stack = debug.traceback()
            print("[jlib MySQL] An error occured while executing the query: " .. err .. "\nStack: " .. stack)
            print(queryr)
        end

        query:start()
    end

    function jlib.SQL.CreateTables(tableName, sqlLiteQuery, mySqlQuery)
        jlib.SQL.Query("CREATE TABLE IF NOT EXISTS " .. tableName .. " ( " .. (mySqlQuery or sqlLiteQuery) .. " );")
        print("[jlib MySQL] " .. tableName .. " table validated!")
    end

    function jlib.SQL.Escape(text)
        return jlib.SQL.DB:escape(text)
    end

    jQuery = jlib.SQL
end

-- Moved to a txt based Database System
-- read directly from the data folder to avoid re-typing the database parameters
-- When working across communities/servers
-- This practice is entirely safe, some poorly written addons may be exploited to read this file.
-- But that looks like a massive personal issue ngl.
if not file.Exists("jlib_database.txt", "DATA") then
    file.Write("jlib_database.txt", util.TableToJSON({
        host = "example",
        username = "user",
        password = "password",
        database = "",
        port = 3306
    }, true))
else
    local database = util.JSONToTable(file.Read("jlib_database.txt", "DATA"))
    jlib.SQL.Host = database.host
    jlib.SQL.Username = database.username
    jlib.SQL.Password = database.password
    jlib.SQL.Database = database.database
    jlib.SQL.Port = database.port
    init()
end