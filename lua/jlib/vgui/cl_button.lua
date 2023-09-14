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
        self.rounding = 0
        self:SetFontScale(16)
        self.AnimAlpha = 0
        self.EnableHoverSfx = true
        self.Icon_Size = 5
        self:SetTextColor(jlib.theme.button_text_color)
        self.style = 1

        self.styles = {
            [1] = function(s, w, h)
                self.AnimAlpha = self:IsHovered() and Lerp(FrameTime() * 16, self.AnimAlpha, 255) or not self:IsHovered() and Lerp(FrameTime() * 16, self.AnimAlpha, 0)
                draw.RoundedBoxEx(self.rounding, 0, 0, w, h, jlib.theme.button_base_color, true, true, true, true)
                draw.RoundedBoxEx(self.rounding, 0, 0, w, h, ColorAlpha(jlib.theme.button_hover_color, self.AnimAlpha), true, true, true, true)
                jlib.utils.ClickingAnimationHandle(self, math.max(w, h), jlib.theme.button_click_color)

                if self.IconName then
                    local tWidth, tHeight = jlib.fonts.FontSurface(self:GetText(), self:GetFont())
                    surface.SetDrawColor(self:GetTextColor())
                    surface.SetMaterial(jlib.materials.Material(self.IconName))
                    surface.DrawTexturedRectRotated(w / 2 - tWidth / 2 - self.Icon_Size / 2, h / 2, self.Icon_Size, self.Icon_Size, 0)
                end
            end,
            [2] = function(s, w, h)
                self.AnimAlpha = self:IsHovered() and Lerp(FrameTime() * 16, self.AnimAlpha, 255) or not self:IsHovered() and Lerp(FrameTime() * 16, self.AnimAlpha, 0)
                draw.RoundedBoxEx(self.rounding, 0, 0, w, h, jlib.theme.button_base_color, true, true, true, true)
                draw.RoundedBoxEx(self.rounding, 0, 0, w, h, ColorAlpha(jlib.theme.button_hover_color, self.AnimAlpha), true, true, true, true)
                surface.SetDrawColor(jlib.theme.scroller_grip_color)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                jlib.utils.ClickingAnimationHandle(self, math.max(w, h), jlib.theme.button_click_color)

                if self.IconName then
                    local tWidth, tHeight = jlib.fonts.FontSurface(self:GetText(), self:GetFont())
                    surface.SetDrawColor(self:GetTextColor())
                    surface.SetMaterial(jlib.materials.Material(self.IconName))
                    surface.DrawTexturedRectRotated(w / 2 - tWidth / 2 - self.Icon_Size / 2, h / 2, self.Icon_Size, self.Icon_Size, 0)
                end
            end,
            [3] = function(s, w, h)
                surface.SetDrawColor(s:IsHovered() and jlib.utils.LerpColor(0.1, s.HoverColor or jlib.theme.button_hover_color, s.Accent or jlib.theme.text_color) or s.BaseColor or jlib.theme.button_base_color)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(s.Accent or jlib.theme.text_color)
                surface.DrawRect(0, h - 4, w, 4)
                jlib.utils.ClickingAnimationHandle(self, math.max(w, h), jlib.theme.button_click_color)

                if not s:IsHovered() then
                    surface.SetDrawColor(jlib.utils.LerpColor(0.1, jlib.theme.scroller_grip_color, s.Accent or jlib.theme.scroller_grip_color))
                end

                surface.DrawOutlinedRect(0, 0, w, h, s:IsHovered() and 2 or 1)
            end
        }
    end

    function PANEL:SetIcon(icon)
        self.IconName = icon
    end

    function PANEL:SetStyle(style)
        self.style = style
    end

    function PANEL:Paint(w, h)
        self.styles[self.style](self, w, h)
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
        jlib.utils.Click()

        if self.OnClick then
            self.OnClick(self)
        end
    end

    vgui.Register("jlib.Button", PANEL, "DButton")
end