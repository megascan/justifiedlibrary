do
    local PANEL = {}

    function PANEL:ShowLoading()
        self:SetVisible(true)
    end

    function PANEL:HideLoading()
        self:SetVisible(false)
    end

    function PANEL:Paint(w, h)
        local smaller = math.min(w, h)
        surface.SetDrawColor(ColorAlpha(jlib.theme.frame_base_color, 200))
        surface.DrawRect(0, 0, w, h)
        draw.NoTexture()
        surface.SetDrawColor(jlib.theme.loading_background)
        jlib.draw_extras.DrawRing(w / 2, h / 2, smaller * 0.2 + jlib.utils.ScaleW(1), jlib.utils.ScaleW(4), 0, 360)
        surface.SetDrawColor(jlib.theme.loading_inside)
        local animtime = CurTime() * 255
        jlib.draw_extras.DrawRing(w / 2, h / 2, smaller * 0.2, jlib.utils.ScaleW(2), animtime, animtime + 80)
        self:MoveToFront()
    end

    vgui.Register("jlib.Loading", PANEL, "EditablePanel")
end