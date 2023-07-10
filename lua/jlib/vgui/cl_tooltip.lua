local draw_RoundedBox = draw.RoundedBox
local vgui_Register = vgui.Register

do
    local PANEL = {}

    function PANEL:Paint(w, h)
        draw_RoundedBox(jlib.utils.ScaleH(3), 0, 0, w, h, jlib.theme.frame_header_color)
        draw_RoundedBox(jlib.utils.ScaleH(3), 1, 1, w - 2, h - 2, jlib.theme.frame_secondary_color)
        self:SetFont(jlib.fonts.Font(jlib.utils.ScaleH(8), jlib.theme.font))
        self:SetTextColor(jlib.theme.text_color)
    end

    --draw_RoundedBox(self.rounding, 0, 0, w, h, self.bg_color or jlib.theme.frame_content_color)
    vgui_Register("jlib.ToolTip", PANEL, "DTooltip")
end