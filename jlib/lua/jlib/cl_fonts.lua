--  Name:       fonts.lua
--  Realm:      Client
--  Purpose:    Allows to Dynamically Cache fonts in a simple and fast way.
--  Date:       07/03/2021 - 1:52 PM
local self = {}
self.Index = {}
local surface_CreateFont = CLIENT and surface.CreateFont
local surface_SetFont = CLIENT and surface.SetFont
local surface_GetTextSize = CLIENT and surface.GetTextSize

function self.Font(fS, fF, fW)
    fW = fW or 500
    local id = "jlib." .. fS .. fF .. fW
    if self.Index[id] then return id end

    surface_CreateFont(id, {
        font = fF,
        size = fS,
        weight = fW or 500,
        antialias = true
    })

    self.Index[id] = true

    return id
end

function self.FontSurface(t, fI)
    surface_SetFont(fI)

    return surface_GetTextSize(t)
end

jlib.fonts = self