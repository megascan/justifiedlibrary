--  Name:       fonts.lua
--  Realm:      Client
--  Purpose:    Allows to Dynamically Cache fonts in a simple and fast way.
--  Date:       07/03/2021 - 1:52 PM
local math_Round = math.Round
local FONTS = {}
FONTS.Index = {}
FONTS.Scaled = {}
local surface_CreateFont = CLIENT and surface.CreateFont
local surface_SetFont = CLIENT and surface.SetFont
local surface_GetTextSize = CLIENT and surface.GetTextSize

function FONTS.Font(font_size, font_family, font_weight, custom, scaled)
    font_weight = font_weight or 500
    local old_size = font_size

    if scaled then
        font_size = math_Round(jlib.utils.Scale(font_size), 2)
    end

    local id = "jlib." .. old_size .. font_family .. font_weight .. (scaled and "SCALED" or "")
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
    if scaled then
        FONTS.Scaled[id] = {
            old_size = old_size,
            font_size = font_size,
            font_family = font_family,
            font_weight = font_weight,
            custom = custom or nil
        }
    end

    return id
end

function FONTS.FontSurface(text, font)
    surface_SetFont(font)

    return surface_GetTextSize(text)
end

hook.Add("OnScreenSizeChanged", "jlib.fonts.ClearCacheOnResolutionChange", function()
    FONTS.Index = {}
    for k, v in pairs(FONTS.Scaled) do
        local fontData = v
        FONTS.Scaled[k] = nil
        FONTS.Font(fontData.old_size, fontData.font_family, fontData.font_weight, fontData.custom or nil, true)
    end
end)

jlib.fonts = FONTS