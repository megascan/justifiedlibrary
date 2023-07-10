--  Name:       fonts.lua
--  Realm:      Client
--  Purpose:    Allows to Dynamically Cache fonts in a simple and fast way.
--  Date:       07/03/2021 - 1:52 PM
local FONTS = {}
FONTS.Index = {}
local surface_CreateFont = CLIENT and surface.CreateFont
local surface_SetFont = CLIENT and surface.SetFont
local surface_GetTextSize = CLIENT and surface.GetTextSize

function FONTS.Font(font_size, font_family, font_weight, custom)
    font_weight = font_weight or 500
    local id = "jlib." .. font_size .. font_family .. font_weight
    if FONTS.Index[id] then return id end

    local font_data = {
        font = font_family,
        size = font_size,
        weight = font_weight or 500,
        antialias = true
    }

    if istable(custom) then
        for key, value in pairs(custom) do
            font_data[key] = value
        end
    end

    surface_CreateFont(id, font_data)
    FONTS.Index[id] = true

    return id
end

function FONTS.FontSurface(text, font)
    surface_SetFont(font)

    return surface_GetTextSize(text)
end

hook.Add("OnScreenSizeChanged", "jlib.fonts.ClearCacheOnResolutionChange", function()
    FONTS.Index = {}
end)

jlib.fonts = FONTS