do
    local PANEL = {}

    function PANEL:Init()
    end

    function PANEL:Show()
        self:SetVisible(true)
        self:SetAlpha(0)
        self:AlphaTo(255, 0.1, 0)
    end

    function PANEL:Hide()
        self:SetAlpha(255)
        self:SetVisible(true)

        self:AlphaTo(255, 0.1, 0, function()
            self:SetVisible(false)
        end)
    end

    function PANEL:Paint(w, h)
        draw.NoTexture()
        surface.SetDrawColor(jlib.theme.loading_background)
        jlib.draw_extras.DrawRing(w / 2, h / 2, jlib.utils.ScaleW(25), jlib.utils.ScaleW(4), 0, 360)
        surface.SetDrawColor(jlib.theme.loading_inside)
        local animtime = CurTime() * 255
        jlib.draw_extras.DrawRing(w / 2, h / 2, jlib.utils.ScaleW(24), jlib.utils.ScaleW(2), animtime, animtime + 80)
    end

    vgui.Register("jlib.Loading", PANEL, "EditablePanel")
end