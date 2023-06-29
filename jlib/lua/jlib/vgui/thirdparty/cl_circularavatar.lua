--[[
    Name: cl_circularavatar.lua
    Description: Rounds player avatar
    Credits: https://github.com/cresterienvogel/gmod-misc/blob/master/circleavatar.lua
]]
local PANEL = {}
local cos, sin, rad = math.cos, math.sin, math.rad
local AccessorFunc = AccessorFunc
local vgui_Create = vgui.Create
local render_ClearStencil = render.ClearStencil
local render_SetStencilEnable = render.SetStencilEnable
local render_SetStencilWriteMask = render.SetStencilWriteMask
local render_SetStencilTestMask = render.SetStencilTestMask
local render_SetStencilFailOperation = render.SetStencilFailOperation
local render_SetStencilPassOperation = render.SetStencilPassOperation
local render_SetStencilZFailOperation = render.SetStencilZFailOperation
local render_SetStencilCompareFunction = render.SetStencilCompareFunction
local render_SetStencilReferenceValue = render.SetStencilReferenceValue
local draw_NoTexture = draw.NoTexture
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawPoly = surface.DrawPoly
local vgui_Register = vgui.Register
AccessorFunc(PANEL, "m_masksize", "MaskSize", FORCE_NUMBER)

function PANEL:Init()
    self.Avatar = vgui_Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)
    self:SetMaskSize(24)
end

function PANEL:Calculate(w, h)
    local circle, t = {}, 0
    local _m = self.m_masksize

    for i = 1, 360 do
        t = rad(i * 720) / 720

        circle[i] = {
            x = w / 2 + cos(t) * _m,
            y = h / 2 + sin(t) * _m
        }
    end

    self.circle = circle
end

function PANEL:PerformLayout()
    local w, h = self:GetWide(), self:GetTall()
    self.Avatar:SetSize(w, h)
    self:Calculate(w, h)
end

function PANEL:SetPlayer(id, size)
    self.Avatar:SetPlayer(id, size or self:GetWide())
end

function PANEL:SetSteamID(steamid, size)
    self.Avatar:SetSteamID(steamid, size)
end

function PANEL:Paint(w, h)
    if not self.circle then
        self:Calculate(w, h)
    end

    render_ClearStencil()
    render_SetStencilEnable(true)
    render_SetStencilWriteMask(1)
    render_SetStencilTestMask(1)
    render_SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render_SetStencilPassOperation(STENCILOPERATION_ZERO)
    render_SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render_SetStencilReferenceValue(1)
    local _m = self.m_masksize
    draw_NoTexture()
    surface_SetDrawColor(color_white)
    surface_DrawPoly(self.circle)
    render_SetStencilFailOperation(STENCILOPERATION_ZERO)
    render_SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render_SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render_SetStencilReferenceValue(1)
    self.Avatar:SetPaintedManually(false)
    self.Avatar:PaintManual()
    self.Avatar:SetPaintedManually(true)
    render_SetStencilEnable(false)
    render_ClearStencil()
end

vgui_Register("jlib.RoundedAvatar", PANEL)