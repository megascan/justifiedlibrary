local ScreenScale = ScreenScale
local draw_RoundedBox = draw.RoundedBox
local math_max = math.max
local Lerp = Lerp
local FrameTime = FrameTime
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectRotated = surface.DrawTexturedRectRotated
local vgui_Register = vgui.Register

do
    local PANEL = {}

    function PANEL:Init()
        self.rounding = ScreenScale(1)
        self.scalem = 0
    end

    function PANEL:SetRounding(amount)
        self.rounding = amount
    end

    function PANEL:GetRounding()
        return self.rounding
    end

    function PANEL:Paint(w, h)
        draw_RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.checkbox_background)
        jlib.utils.ClickingAnimationHandle(self, math_max(w, h), jlib.theme.checkbox_clicked)
        self.scalem = Lerp(FrameTime() * 10, self.scalem, self:GetChecked() and 1 or 0)
        surface_SetDrawColor(jlib.theme.accent)
        surface_SetMaterial(jlib.materials.Material("checkbox-check"))
        surface_DrawTexturedRectRotated(w / 2, h / 2, (w * 0.8) * self.scalem, (h * 0.8) * self.scalem, 0)
    end

    function PANEL:DoClick()
        jlib.utils.DoClickAnimation(self, 1)
        self:Toggle()
    end

    vgui_Register("jlib.CheckBox", PANEL, "DCheckBox")
end

hook.Add("jlib.downloadResources", "jlib.checkbox.resources", function()
    jlib.materials.CreateMaterial("checkbox-check", "jlib", "https://i.imgur.com/DUN9D5i.png")
end)