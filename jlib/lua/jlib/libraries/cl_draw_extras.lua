--[[
    Draw_Extras Library by Bullyhunter
    Link: https://github.com/BullyHunter32/gmod-draw-functions
]]
jlib = jlib or {}
local LIB_CONTENT = {}
local Lerp = Lerp
local surface_DrawLine = CLIENT and surface.DrawLine
local math_cos = math.cos
local math_rad = math.rad
local math_sin = math.sin
local surface_DrawPoly = CLIENT and surface.DrawPoly
local istable = istable
local draw = draw
local render_SetStencilWriteMask = CLIENT and render.SetStencilWriteMask
local render_SetStencilTestMask = CLIENT and render.SetStencilTestMask
local render_SetStencilReferenceValue = CLIENT and render.SetStencilReferenceValue
local render_SetStencilCompareFunction = CLIENT and render.SetStencilCompareFunction
local render_SetStencilPassOperation = CLIENT and render.SetStencilPassOperation
local render_SetStencilFailOperation = CLIENT and render.SetStencilFailOperation
local render_SetStencilZFailOperation = CLIENT and render.SetStencilZFailOperation
local render_ClearStencil = CLIENT and render.ClearStencil
local render_SetStencilEnable = CLIENT and render.SetStencilEnable
local Color = Color
local surface_SetDrawColor = CLIENT and surface.SetDrawColor
local surface_DrawRect = CLIENT and surface.DrawRect
local surface_DrawOutlinedRect = CLIENT and surface.DrawOutlinedRect
local surface_SetFont = CLIENT and surface.SetFont
local surface_SetTextColor = CLIENT and surface.SetTextColor
local surface_GetTextSize = CLIENT and surface.GetTextSize
local surface_SetTextPos = CLIENT and surface.SetTextPos
local CurTime = CurTime
local surface_DrawText = CLIENT and surface.DrawText

local function quadBezier(t, p0, p1, p2)
    local l1 = Lerp(t, p0, p1)
    local l2 = Lerp(t, p1, p2)
    local quad = Lerp(t, l1, l2)

    return quad
end

local function cubicBezier(t, p0, p1, p2, p3)
    local l1 = Lerp(t, p0, p1)
    local l2 = Lerp(t, p1, p2)
    local l3 = Lerp(t, p2, p3)
    local a = Lerp(t, l1, l2)
    local b = Lerp(t, l2, l3)
    local cubic = Lerp(t, a, b)

    return cubic
end

-- Bezier curves
function LIB_CONTENT.QuadBezier(p0, p1, p2, step)
    local old = p0
    step = step or 0.02

    for i = 0, 1, step do
        local pos = quadBezier(i, p0, p1, p2)
        surface_DrawLine(old.x, old.y, pos.x, pos.y)
        old = pos
    end
end

function LIB_CONTENT.CubicBezier(p0, p1, p2, p3, step)
    local old = p0
    step = step or 0.02

    for i = 0, 1, step do
        local pos = cubicBezier(i, p0, p1, p2, p3)
        surface_DrawLine(old.x, old.y, pos.x, pos.y)
        old = pos
    end
end

-- Draws a filled circle
function LIB_CONTENT.DrawCircle(iPosX, iPosY, iRadius, iVertices, bCache)
    iPosX = iPosX or 0
    iPosY = iPosY or 0
    iRadius = iRadius or 100
    iVertices = iVertices or 200 -- the more vertices, the better the quality
    local circle = {}
    local i = 0

    for ang = 1, 360, 360 / iVertices do
        i = i + 1

        circle[i] = {
            x = iPosX + math_cos(math_rad(ang)) * iRadius,
            y = iPosY + math_sin(math_rad(ang)) * iRadius,
        }
    end

    if bCache then return circle end
    surface_DrawPoly(circle)
end

-- Draws a filled circle but with an angle, like a cut pie
function LIB_CONTENT.DrawArc(iPosX, iPosY, iRadius, iStartAngle, iEndAngle, bCache)
    iPosX = iPosX or 0
    iPosY = iPosY or 0
    iRadius = iRadius or 100
    iStartAngle = iStartAngle or 0
    iEndAngle = iEndAngle or 360
    iEndAngle = iEndAngle - 90
    iStartAngle = iStartAngle - 90

    local circle = {
        {
            x = iPosX,
            y = iPosY
        }
    }

    local i = 1

    for ang = iStartAngle, iEndAngle do
        i = i + 1

        circle[i] = {
            x = iPosX + math_cos(math_rad(ang)) * iRadius,
            y = iPosY + math_sin(math_rad(ang)) * iRadius,
        }
    end

    if bCache then return circle end
    surface_DrawPoly(circle)
end

function LIB_CONTENT.DrawRing(iPosX, iPosY, iRadius, iThickness, iStartAngle, iEndAngle, tCachedCircle, tCachedRing)
    local tCircle
    local tRing

    if istable(iPosX) and istable(iPosY) then
        if not tCircle then
            tCircle = iPosX
        end

        if not tRing then
            tRing = iPosY
        end
    end

    if not tCircle then
        if tCachedCircle then
            tCircle = tCachedCircle
        else
            tCircle = LIB_CONTENT.DrawCircle(iPosX, iPosY, iRadius - iThickness, nil, true)
        end
    end

    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(0)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilReferenceValue(1)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    surface.DrawPoly(tCircle)
    render.SetStencilCompareFunction(STENCIL_NOTEQUAL)

    if tRing then
        surface.DrawPoly(tRing)
    elseif iStartAngle and iStartAngle ~= 0 or iEndAngle and iEndAngle ~= 0 then
        LIB_CONTENT.DrawArc(iPosX, iPosY, iRadius, iStartAngle, iEndAngle)
    else
        LIB_CONTENT.DrawCircle(iPosX, iPosY, iRadius)
    end

    render.SetStencilEnable(false)
end

local color_outline = Color(20, 20, 20, 100)

function LIB_CONTENT.DrawProgressBar(iPosX, iPosY, iWidth, iHeight, tColor, flRatio, tOutlineCol, bOutline)
    iPosX = iPosX or 0
    iPosY = iPosY or 0
    iWidth = iWidth or 100
    iHeight = iHeight or 100
    tColor = tColor or color_white
    flRatio = flRatio or 1
    tOutlineCol = tOutlineCol or color_outline
    surface_SetDrawColor(tColor)
    surface_DrawRect(iPosX, iPosY, iWidth * flRatio, iHeight)

    if bOutline then
        surface_SetDrawColor(tOutlineCol)
        surface_DrawOutlinedRect(iPosX, iPosY, iWidth, iHeight)
    end
end

jlib.draw_extras = LIB_CONTENT