--  Name:       materials.lua
--  Realm:      Client
--  Purpose:    Allows creation of materials live using the HTTP lib.
--  Date:       07/08/2021 - 11:00 AM
local MATERIALS = {}
MATERIALS.queue = {}
local Material = Material
local string = string
local file = file
local http = http
MATERIALS.CreatedMaterialCache = {}
MATERIALS.Downloading = 0
local missing = Material("error")

function MATERIALS.Material(matName)
    return matName and MATERIALS.CreatedMaterialCache[string.lower(matName)] or missing
end

function MATERIALS.CreateMaterial(matName, addOn, matUrl, matArgs)
    matName = string.lower(matName)
    jlib.msg("[Materials] '" .. addOn .. "' requested Material instance named '" .. matName .. "'")
    local directory = string.format("jlib/%s/", addOn)
    local filename = directory .. "/" .. matName .. ".png"
    file.CreateDir(directory)

    if file.Exists(filename, "DATA") then
        local mmat = Material("data/" .. filename, matArgs or "smooth")

        if not mmat:IsError() then
            jlib.msg("[Materials] Loaded resource '" .. addOn .. "' from cache.")
            MATERIALS.CreatedMaterialCache[matName] = mmat

            return
        end
    end

    table.insert(MATERIALS.queue, {matName, addOn, matUrl, matArgs, filename})

    do
        local canContinue = true
        timer.Create("JustifiedLibrary.ProcessMaterialQueue", 0.1, 0, function()
            if table.Count(MATERIALS.queue) == 0 then timer.Remove("JustifiedLibrary.ProcessMaterialQueue") return end
            if not canContinue then return end
            local current = MATERIALS.queue[#MATERIALS.queue]
            canContinue = false
            local matName, addOn, matUrl, matArgs, filename = current[1], current[2], current[3], current[4], current[5]
            -- print("processing ",unpack(current))
            
            http.Fetch(matUrl, function(b, _, _, _)
                file.Write(filename, b)
                MATERIALS.CreatedMaterialCache[matName] = Material("data/" .. filename, "smooth")
                jlib.msg("[Materials] Downloaded Material '" .. matName .. "'")
                table.remove(MATERIALS.queue)
                canContinue = true
            end, function()
                jlib.msg("[Materials] Failed to Download Material '" .. matName .. "'")
                table.remove(MATERIALS.queue)
                canContinue = true
            end)
        end)
    end
end

local function requestResources()
    timer.Simple(0, function()
        jlib.msg("[Materials] Downloading Server Resources...")
        hook.Run("jlib.downloadResources")
    end)
end

local function clearResources()
    local res = jlib.search("jlib", "DATA")

    for _, f in ipairs(res) do
        jlib.msg("[Materials] Removing '" .. f .. "' ...")
        file.Delete(f)
    end
end

hook.Add("jlib.Authenticate", "jlib.Materials.Stub", function()
    timer.Simple(0, function()
        requestResources()
    end)
end)

concommand.Add("jlib_reloadresources", function()
    requestResources()
end)

concommand.Add("jlib_clearresources", function()
    table.Empty(MATERIALS.CreatedMaterialCache)
    clearResources()
end)

concommand.Add("jlib_forceredownload", function()
    clearResources()
    requestResources()
end)

jlib.materials = MATERIALS