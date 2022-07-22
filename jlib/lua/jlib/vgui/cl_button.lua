local ScreenScale = ScreenScale
local Lerp = Lerp
local FrameTime = FrameTime
local draw = draw
local ColorAlpha = ColorAlpha
local math = math
local vgui = vgui

do
    local PANEL = {}

    function PANEL:Init()
        self.rounding = ScreenScale(1)
        self:SetFontScale(16)
        self.AnimAlpha = 0
        self.EnableHoverSfx = true
        self.Icon_Size = 5
        self:SetTextColor(jlib.theme.button_text_color)
    end

    function PANEL:SetIcon(icon)
        self.IconName = icon
    end

    function PANEL:Paint(w, h)
        -- self. = Color(30,30,30)
        -- self.button_hover_color = Color(136, 33, 74)
        self.AnimAlpha = self:IsHovered() and Lerp(FrameTime() * 16, self.AnimAlpha, 255) or not self:IsHovered() and Lerp(FrameTime() * 16, self.AnimAlpha, 0)
        draw.RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.button_base_color)
        draw.RoundedBox(self.rounding, 0, 0, w, h, ColorAlpha(jlib.theme.button_hover_color, self.AnimAlpha))
        jlib.utils.ClickingAnimationHandle(self, math.max(w, h), jlib.theme.button_click_color)

        if self.IconName then
            local tWidth, tHeight = jlib.fonts.FontSurface(self:GetText(), self:GetFont())
            surface.SetDrawColor(self:GetTextColor())
            surface.SetMaterial(jlib.materials.Material(self.IconName))
            surface.DrawTexturedRectRotated((w / 2) - tWidth / 2 - (self.Icon_Size / 2), h / 2, self.Icon_Size, self.Icon_Size, 0)
        end
    end

    function PANEL:Think()
        jlib.utils.InteractSound(self:IsHovered(), self)
    end

    function PANEL:SetFontScale(scale)
        self:SetFont(jlib.fonts.Font(scale, jlib.theme.font, 200))
        self.Icon_Size = scale
    end

    function PANEL:DoClick()
        jlib.utils.DoClickAnimation(self, 1)

        if self.OnClick then
            self.OnClick(self)
        end
    end

    vgui.Register("jlib.Button", PANEL, "DButton")
end