local ScreenScale = ScreenScale
local draw_RoundedBox = draw.RoundedBox
local vgui_Register = vgui.Register

do
    local PANEL = {}

    function PANEL:Init()
        self.rounding = ScreenScale(1)
    end

    function PANEL:Paint(w, h)
        draw_RoundedBox(self.rounding, 0, 0, w, h, self.bg_color or jlib.theme.frame_content_color)
    end

    function PANEL:SetBackgroundColor(color)
        self.bg_color = color
    end

    function PANEL:SetRounding(amount)
        self.rounding = amount
    end

    function PANEL:GetRounding()
        return self.rounding
    end

    vgui_Register("jlib.Panel", PANEL, "EditablePanel")
end