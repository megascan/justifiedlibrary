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

        self.header.Paint = function(s, w, h)
            draw.RoundedBoxEx(self.rounding, 0, 0, w, h, jlib.theme.frame_header_color, true, true, false, false)
        end

        self.header.Think = function(s)
            if self.movable then
                jlib.utils.PerformDrag(self, s)
            end
        end

        self.header.title = vgui.Create("DLabel", self.header)
        self.header.title:Dock(LEFT)
        self.header.title:DockMargin(self.rounding + ScreenScale(1), 0, 0, 0)
        self.header.title:SetFont(jlib.fonts.Font(self.header:GetTall() * 0.8, jlib.theme.font, 200))
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

hook.Add("jlib.downloadResources", "jlib.frame.resources", function()
    jlib.materials.CreateMaterial("frame_close", "jlib", "https://i.imgur.com/fAR9Bxv.png")
end)