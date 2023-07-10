--[[
	Thanks to Brickwall for inspiring this code and allowing me to use it.
    - Craphead
--]]
jlib.SQL = jlib.SQL or {}
jlib.SQL.Host = ""
jlib.SQL.Username = ""
jlib.SQL.Password = ""
jlib.SQL.Database = ""
jlib.SQL.Port = 3306
require("mysqloo")
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
function jlib.SQL.Query(query, func, singleRow)
    local query = jlib.SQL.DB:query(query)

    if func then
        function query:onSuccess(data)
            if singleRow then
                data = data[1]
            end

            func(data)
        end
    end

    function query:onError(err)
        print("[jlib MySQL] An error occured while executing the query: " .. err)
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