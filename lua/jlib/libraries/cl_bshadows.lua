--[[
    File: cl_bshadows.lua
    Description: Creates shadows around VGUI elements in real time.
    Credits: Created by CodeBlue (rest in peace), Modified version from sui by Srlion
]]
local function load()
    jlib = jlib or {}
    local shadows = {}
    jlib.shadows = shadows
    shadows.shadowscvar = CreateClientConVar("jlib_cl_enableshadows", "1", true, false)
    local GetRenderTarget = GetRenderTarget
    local ScrW = ScrW
    local ScrH = ScrH
    local CreateMaterial = CreateMaterial
    local render = render
    local cam = cam
    local math = math
    local ScrW = ScrW
    local ScrH = ScrH
    local sin = math.sin
    local cos = math.cos
    local rad = math.rad
    local ceil = math.ceil
    local Start2D = cam.Start2D
    local End2D = cam.End2D
    local PushRenderTarget = render.PushRenderTarget
    local OverrideAlphaWriteEnable = render.OverrideAlphaWriteEnable
    local Clear = render.Clear
    local CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
    local BlurRenderTarget = render.BlurRenderTarget
    local PopRenderTarget = render.PopRenderTarget
    local SetMaterial = render.SetMaterial
    local DrawScreenQuadEx = render.DrawScreenQuadEx
    local DrawScreenQuad = render.DrawScreenQuad
    local RenderTarget, RenderTarget2

    local load_render_targets = function()
        local w, h = ScrW(), ScrH()
        RenderTarget = GetRenderTarget("jlib_bshadows_original" .. w .. h, w, h)
        RenderTarget2 = GetRenderTarget("jlib_bshadows_shadow" .. w .. h, w, h)
    end

    load_render_targets()
    hook.Add("OnScreenSizeChanged", "jlib.BShadows", load_render_targets)

    local ShadowMaterial = CreateMaterial("jlib_bshadows", "UnlitGeneric", {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["alpha"] = 1
    })

    local ShadowMaterialGrayscale = CreateMaterial("jlib_bshadows_grayscale", "UnlitGeneric", {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$alpha"] = 1,
        ["$color"] = "0 0 0",
        ["$color2"] = "0 0 0"
    })

    local SetTexture = ShadowMaterial.SetTexture

    shadows.BeginShadow = function()
        if shadows and shadows.shadowscvar and not shadows.shadowscvar:GetBool() then return end
        PushRenderTarget(RenderTarget)
        OverrideAlphaWriteEnable(true, true)
        Clear(0, 0, 0, 0)
        OverrideAlphaWriteEnable(false, false)
        Start2D()
    end

    shadows.EndShadow = function(intensity, spread, blur, opacity, direction, distance, _shadowOnly)
        if shadows and shadows.shadowscvar and not shadows.shadowscvar:GetBool() then return end
        opacity = opacity or 255
        direction = direction or 0
        distance = distance or 0
        CopyRenderTargetToTexture(RenderTarget2)

        if blur > 0 then
            OverrideAlphaWriteEnable(true, true)
            BlurRenderTarget(RenderTarget2, spread, spread, blur)
            OverrideAlphaWriteEnable(false, false)
        end

        PopRenderTarget()
        SetTexture(ShadowMaterial, "$basetexture", RenderTarget)
        SetTexture(ShadowMaterialGrayscale, "$basetexture", RenderTarget2)
        local xOffset = sin(rad(direction)) * distance
        local yOffset = cos(rad(direction)) * distance
        SetMaterial(ShadowMaterialGrayscale)

        for i = 1, ceil(intensity) do
            DrawScreenQuadEx(xOffset, yOffset, ScrW(), ScrH())
        end

        if not _shadowOnly then
            SetTexture(ShadowMaterial, "$basetexture", RenderTarget)
            SetMaterial(ShadowMaterial)
            DrawScreenQuad()
        end

        End2D()
    end

    function shadows.offsetLocation(panel)
        if shadows and shadows.shadowscvar and shadows.shadowscvar:GetBool() then
            return panel:LocalToScreen(0, 0)
        else
            return 0, 0
        end
    end

    jlib.shadows = shadows
end

load()
hook.Add("Initialize", "jlib.bshadows", load)