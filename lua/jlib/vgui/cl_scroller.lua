local getMousePos = input.GetCursorPos
local setMousePos = input.SetCursorPos
local ScreenScale = ScreenScale
local draw = draw
local math = math
local vgui = vgui

do
    local PANEL = {}

    function PANEL:Init()
        local sbar = self:GetVBar()
        sbar:SetWide(ScreenScale(3))
        sbar:SetHideButtons(true)
        self.snappy = false

        function sbar:Paint(w, h)
            surface.SetDrawColor(jlib.theme.scroller_base_color)
            surface.DrawRect(0, 0, w, h)
        end

        function sbar.btnGrip:Paint(w, h)
            surface.SetDrawColor(jlib.theme.scroller_grip_color)
            surface.DrawRect(0, 0, w, h)
        end

        self.bar = sbar
    end

    function PANEL:Think()
        if (self.bar.btnGrip:IsHovered() or self.bar:IsHovered()) and self.snappy then
            local x, y = self.bar.btnGrip:GetPos()
            local wx, wy = self.bar.btnGrip:LocalToScreen(x, y)
            local _, my = getMousePos()
            setMousePos(wx + self.bar.btnGrip:GetWide() / 2, my)
        end
    end

    vgui.Register("jlib.Scroller", PANEL, "DScrollPanel")
end