--[[
    Justified Rendering Core
    Written by Strange

    Special Thanks to:
    BullyHunter, Blue
    ]]
jlib = jlib or {}
local MsgC = MsgC
local Color = Color
local unpack = unpack
local file_Find = file.Find
local ipairs = ipairs
local string_find = string.find
local include = include
local AddCSLuaFile = AddCSLuaFile
local string_EndsWith = string.EndsWith
local table_insert = table.insert
local type = type
local string_match = string.match
local string_GetExtensionFromFilename = string.GetExtensionFromFilename
local resource_AddFile = SERVER and resource.AddFile
local concommand_Add = concommand.Add

function jlib.msg( ... )
    MsgC( Color( 0, 255, 234 ), "[/Justified Library/] ", Color( 235, 235, 235 ), unpack( { ... } ), "\n" )
end

jlib.content_extentions = {
    ["ttf"] = true,
    ["vmt"] = true,
    ["mdl"] = true,
    ["mp3"] = true,
    ["wav"] = true,
    ["ttf"] = true,
}

function jlib.search( dir, instance, filetype )
    local totalfiles = {}
    local files, directories = file_Find( dir .. "/*", instance )

    for _, f in ipairs( files ) do
        local path = dir .. "/" .. f

        if filetype then
            if string_EndsWith( f, filetype ) then
                table_insert( totalfiles, path )
                continue
            else
                continue
            end
        end

        table.insert(totalfiles, path)
    end

    for each, d in ipairs(directories) do
        local fs = jlib.search(dir .. "/" .. d, instance, filetype)

        if fs and type(fs) == "table" then
            for _, f in ipairs(fs) do
                table.insert(totalfiles, f)
            end
        end
    end

    return totalfiles
end

function jlib.import_content(dir)
    if string.match(dir, "/entities") then return end
    local files, directories = file.Find(dir .. "/*", "GAME")

    for each, file in ipairs(files) do
        local f_ = dir .. "/" .. file
        local extention = string.GetExtensionFromFilename(file)

        if f_ and jlib.content_extentions[extention] then
            jlib.msg("Adding Content '" .. f_ .. "'")
            resource.AddFile(f_)
        end
    end

    for each, d in ipairs(directories) do
        jlib.import_content(dir .. "/" .. d)
    end
end

function jlib.load_dir( dir )
    local files, directories = file_Find( dir .. "/*", "LUA" )

    for each, file in ipairs(files) do
        local f_ = dir .. "/" .. file

        if string_find(file, "sv_") or string_find(file, "sh_") then
            jlib.msg("Running [SV] '" .. f_ .. "'")
            include(f_)
        end

        local sh = string_find(file, "sh_")

        if string_find(file, "cl_") or sh then
            if CLIENT then
                jlib.msg( "Running [" .. ( sh and "SH" or "CL" ) .. "] '" .. f_ .. "'" )
                include( f_ )
            else
                jlib.msg( "Sending [SH] '" .. f_ .. "'" )
                AddCSLuaFile( f_ )
            end
        end
    end

    for _, d in ipairs( directories ) do
        jlib.load_dir( dir .. "/" .. d )
    end
end

local function init()
    jlib.msg( "[/Core/] Loading Justified Library..." )
    jlib.load_dir( "jlib" )
    jlib.msg( "[/Core/] Justified Library loaded.\n" )
    jlib.msg( "[/Resources/] Loading content..." )
    jlib.import_content( "addons/jlib" )
    jlib.msg( "[/Resources/] Loaded Library content." )
end

init()

concommand.Add("jlib_reload", function(ply)
    if ply and type(ply) == "Player" and not ply:IsSuperAdmin() then return end
    init()
end )