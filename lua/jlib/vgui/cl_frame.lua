local ScreenScale = ScreenScale
local vgui = vgui
local draw = draw
local timer = timer

do
    local PANEL = {}

    function PANEL:Init()
        self.create_time = CurTime()
        self:SetAlpha(0)
        self.rounding = ScreenScale(1)
        self.movable = true
        self.header = vgui.Create("jlib.Panel", self)
        self.header:Dock(TOP)
        self.header:SetTall(jlib.utils.ScaleH(8))
        self.draw_blur = false
        self.header.bg_color = jlib.theme.frame_header_color

        self.header.Think = function(s)
            if self.movable then
                jlib.utils.PerformDrag(self, s)
            end
        end

        self.header.title = vgui.Create("DLabel", self.header)
        self.header.title:Dock(LEFT)
        self.header.title:DockMargin(self.rounding + ScreenScale(1), 0, 0, 0)
        self.header.title:SetFont(jlib.fonts.Font(self.header:GetTall() * 0.8, jlib.theme.font_bold, 200))
        self.header.title:SetTextColor(jlib.theme.frame_title_color)
        self.header.title:SetText("JLIB Frame")
        self.header.title:SizeToContents()
        self.header.title:SetContentAlignment(4)
        self.header.closeBtn = vgui.Create("DButton", self.header)
        self.header.closeBtn:Dock(RIGHT)
        self.header.closeBtn:SetWide(self.header:GetTall())
        self.header.closeBtn:SetFont(jlib.fonts.Font(self.header.closeBtn:GetTall() * 0.8, jlib.theme.font, 200))
        self.header.closeBtn:SetText("")
        self.header.closeBtn:SetTextColor(jlib.theme.frame_close_icon_color)

        self.header.closeBtn.Paint = function(s, w, h)
            if s:IsHovered() then
                draw.RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.frame_close_color)
            end

            surface.SetMaterial(jlib.materials.Material("frame_close"))
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        self.header.closeBtn.DoClick = function()
            self:Close()
        end

        self.inner = vgui.Create("jlib.Panel", self)
        self.inner:Dock(FILL)
        self.inner:DockMargin(4, 4, 4, 4)

        self.inner.Paint = function(s, w, h)
            draw.RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.frame_content_color)
        end

        self:AlphaTo(255, 0.1, 0, nil)
    end

    function PANEL:Close()
        if not self.closing then
            self:AlphaTo(0, 0.1, 0, function()
                if self and IsValid(self) then
                    self:Remove()
                end
            end)

            self.closing = true
        else
            self:Remove()
        end
    end

    function PANEL:SetTitle(text)
        self.header.title:SetText(text)
        self.header.title:SizeToContents()
    end

    function PANEL:SetMovable(state)
        self.movable = state
    end

    function PANEL:Paint(w, h)
        if self.draw_blur then
            Derma_DrawBackgroundBlur(self, self.create_time)
        end

        local x, y = jlib.shadows.offsetLocation(self)
        jlib.shadows.BeginShadow()
        draw.RoundedBox(self.rounding, x, y, w, h, jlib.theme.frame_base_color)
        jlib.shadows.EndShadow(1, 2, 2)
    end

    function PANEL:SetRounding(amount)
        self.rounding = amount
    end

    function PANEL:GetRounding(amount)
        return self.rounding
    end

    function PANEL:Add(element)
        return vgui.Create(element, self.inner)
    end

    vgui.Register("jlib.Frame", PANEL, "EditablePanel")
end

do
    local PANEL = {}

    function PANEL:Init()
        if IsValid(EvolutionGangs.Promt) then
            EvolutionGangs.Promt:Remove()
        end

        self.start = SysTime()
        self:SetTitle("Promt")
        self.movable = false
        self:SetSize(jlib.utils.ScaleH(150), jlib.utils.ScaleH(32))
        EvolutionGangs.Promt = self
        self.text = self:Add("DLabel")
        self.text:SetFont(jlib.fonts.Font(jlib.utils.ScaleH(8), jlib.theme.font))
        self.text:Dock(TOP)
        self.text:SetContentAlignment(8)
        self.actions = self:Add("DPanel")
        self.actions:Dock(FILL)
        self.actions:SetPaintBackground(false)
        self.actions.confirm = vgui.Create("jlib.Button", self.actions)
        self.actions.confirm:Dock(RIGHT)
        self.actions.confirm:DockMargin(5, 5, 5, 5)
        self.actions.confirm:SetText("Confirm")

        self.actions.confirm.DoClick = function(s)
            jlib.utils.Click()
            self:OnPromtSubmit(s:GetText())
            self:Close()
        end

        self.actions.deny = vgui.Create("jlib.Button", self.actions)
        self.actions.deny:Dock(FILL)
        self.actions.deny:DockMargin(5, 5, 0, 5)
        self.actions.deny:SetText("Cancel")

        self.actions.deny.DoClick = function(s)
            jlib.utils.Click()
            self:OnPromtSubmit(s:GetText())
            self:Close()
        end

        self.header.closeBtn:Remove()
        self:Center()
        local op = self.Paint

        self.Paint = function(s, w, h)
            Derma_DrawBackgroundBlur(self, self.start)
            op(s, w, h)
        end

        self:MakePopup()
    end

    function PANEL:PerformLayout(w, h)
        self.actions.confirm:SetWide(w / 2 - 10)
    end

    function PANEL:OnPromtSubmit(response)
    end

    function PANEL:SetText(txt)
        self.text:SetText(txt)
        self.text:SizeToContents()
        local w, h = jlib.fonts.FontSurface(txt, self.text:GetFont())
        self:SetWide(w * 1.1)
        self:Center()
    end

    vgui.Register("jlib.ButtonPromt", PANEL, "jlib.Frame")
end

hook.Add("jlib.downloadResources", "jlib.frame.resources", function()
    jlib.materials.CreateMaterial("frame_close", "jlib", "https://i.imgur.com/fAR9Bxv.png")
end)