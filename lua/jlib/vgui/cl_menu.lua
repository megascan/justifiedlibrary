do
    local PANEL = {}

    function PANEL:Init()
        -- Create a scrollbar incase
        self.scroll = vgui.Create("jlib.Scroller", self)
        self.scroll:Dock(FILL)
        self.scroll:DockMargin(1, 1, 1, 1)
        self.rounding = 0
        local x, y = input.GetCursorPos()
        self:SetPos(x, y)
        self:SetSize(1, 2)
        self.widest = 1
        RegisterDermaMenuForClose(self)
    end

    function PANEL:GetDeleteSelf()
        return true
    end

    function PANEL:AddOption(text, exec)
        local option = self.scroll:Add("jlib.Button")
        option:Dock(TOP)
        option:SetText(text)
        option.DoClick = exec
        option:SetContentAlignment(5)
        option:SizeToContents()
        option:SetTextColor(jlib.theme.text_color)
        self:SetTall(self:GetTall() + option:GetTall())

        if option:GetWide() > self.widest then
            self.widest = option:GetWide() + jlib.utils.ScaleH(5)
            self:SetWide(self.widest)
        end

        return option
    end

    function PANEL:AddSpacer()
        local spacer = self.scroll:Add("jlib.Panel")
        spacer:Dock(TOP)
        spacer:SetTall(jlib.utils.ScaleH(0.8))
        -- option.bg_color = jlib.theme.accent
        self:SetTall(self:GetTall() + spacer:GetTall())

        return spacer
    end

    function PANEL:OnFocusChanged(gained)
        -- Close the menu if we lose focus
        if not gained then
            self:Remove()
        end
    end

    function PANEL:Open()
        self:MakePopup()
    end

    vgui_Register("jlib.Menu", PANEL, "jlib.Panel")

    function jlib.Menu()
        return vgui.Create("jlib.Menu")
    end
end