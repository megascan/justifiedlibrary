local sfx = surface.PlaySound
local vgui_Create = vgui.Create
local input_IsMouseDown = input.IsMouseDown
local vgui_GetHoveredPanel = vgui.GetHoveredPanel
local Color = Color
local draw_SimpleText = draw.SimpleText
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectRotated = surface.DrawTexturedRectRotated
local Lerp = Lerp
local FrameTime = FrameTime
local surface_DrawRect = surface.DrawRect
local ColorAlpha = ColorAlpha
local IsValid = IsValid
local math_min = math.min
local ScrH = ScrH
local hook_Add = hook.Add
local ScreenScale = ScreenScale
local draw_RoundedBox = draw.RoundedBox
local math_max = math.max
local vgui_Register = vgui.Register

do
    local PANEL = {}

    function PANEL:Init()
        self.rounding = ScreenScale(1)
        self.shadow_on = false
        self:SetFontScale(16)
        self.placeholder = ""
        self:SetText("")
        self.SetText = nil
        self.state = false
        self.rotanim = 0
        self.expanded_panel = vgui_Create("jlib.Panel")
        self.expanded_panel:SetVisible(false)
        self.expanded_panel.scroller = vgui_Create("jlib.Scroller", self.expanded_panel)
        self.expanded_panel.scroller:Dock(FILL)
        self.expanded_panel:MakePopup()
        self.expanded_panel:SetFocusTopLevel(true)
        self.items = {}

        self.expanded_panel.Paint = function(s, w, h)
            draw_RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.combobox_base_color)
        end

        self.expanded_panel.Think = function(s)
            local down = input_IsMouseDown(MOUSE_LEFT)
            local hp = vgui_GetHoveredPanel()
            if self.expanded_panel:IsChildHovered() then return end

            if down ~= self.lastdown and not down and self.state then
                self:OnClick()
            end

            self.lastdown = down
        end

        self.canClickAgain = true
        self.item_size = jlib.utils.ScaleH(10)
    end

    function PANEL:SetPlaceholder(text)
        self.placeholder = text
    end

    function PANEL:GetPlaceholder(text)
        return self.placeholder
    end

    local gray = Color(186, 186, 186)

    function PANEL:Paint(w, h)
        draw_RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.combobox_base_color)

        if self.invoke_error_text and self.invoke_time > CurTime() then
            draw.RoundedBox(self.rounding, 0, h - 2, w, 2, jlib.theme.error)
            draw_SimpleText(self.invoke_error_text, jlib.fonts.Font(h * 0.8, jlib.theme.font, 500), h / 2, h / 2, gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            return
        end

        jlib.utils.ClickingAnimationHandle(self, math_max(w, h), jlib.theme.combobox_click_color)
        draw_SimpleText(self.selected and self.selected or self:GetPlaceholder() or "", jlib.fonts.Font(h * 0.8, jlib.theme.font, 500), h / 2, h / 2, gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface_SetDrawColor(gray)
        surface_SetMaterial(jlib.materials.Material("combo_down"))
        surface_DrawTexturedRectRotated(w - h / 2, h / 2, h * 0.8, h * 0.8, self.rotanim)

        if self.state then
            self.rotanim = Lerp(FrameTime() * 10, self.rotanim, 180)
        else
            self.rotanim = Lerp(FrameTime() * 10, self.rotanim, -360)
        end
    end

    function PANEL:InvokeError(err)
        self.invoke_error_text = err
        self.invoke_time = CurTime() + 1
    end

    function PANEL:SetFontScale(scale)
        self:SetFont(jlib.fonts.Font(scale, jlib.theme.font, 500))
    end

    function PANEL:OnSelect(index, value)
    end

    function PANEL:GetSelectedID()
        return self.selectedid
    end

    function PANEL:GetSelectedText()
        return self.selected
    end

    function PANEL:AddChoice(text)
        local option = self.expanded_panel.scroller:Add("jlib.Button")
        option:Dock(TOP)
        option:DockMargin(2, 2, 2, 0)
        option:SetTall(self.item_size)
        option:SetText(text)
        option.id = table.insert(self.items, option)
        option.halpha = 0

        option.OnClick = function(s, w, h)
            self.selected = s:GetText()
            self.selectedid = s.id
            self:OnSelect(s.id, s:GetText())
            self:OnClick()
        end

        option:SetFontScale(option:GetTall() * 0.8)

        option.Paint = function(s, w, h)
            if s:IsHovered() then
                s.halpha = Lerp(FrameTime() * 10, s.halpha, 255)
            else
                s.halpha = Lerp(FrameTime() * 10, s.halpha, 0)
            end

            surface_SetDrawColor(jlib.theme.frame_base_color)
            surface_DrawRect(0, 0, w, h)
            surface_SetDrawColor(ColorAlpha(jlib.theme.button_hover_color, s.halpha))
            surface_DrawRect(0, 0, w, h)
        end

        return option.id
    end

    function PANEL:OnRemove()
        if self.expanded_panel and IsValid(self.expanded_panel) then
            self.expanded_panel:Remove()
        end
    end

    function PANEL:OnClick()
        if not self.canClickAgain then return end
        self.state = not self.state
        self.canClickAgain = false
        sfx("jlib/click4.wav")

        if self.state then
            local x, y = self:LocalToScreen(0, 0)
            self.expanded_panel:SetPos(x, y + self:GetTall() - 2)
            self.expanded_panel:SetWide(self:GetWide())
            self.expanded_panel:MoveToFront()
            local height = math_min((self.item_size + 2) * #self.expanded_panel.scroller:GetCanvas():GetChildren(), ScrH() * 0.8 - y) + 2

            self.expanded_panel:SizeTo(self:GetWide(), height, 0.1, 0, -1, function()
                self.canClickAgain = true
            end)

            self.expanded_panel:MoveToFront()
            self.expanded_panel.storedz = self.expanded_panel:GetZPos()
            self.expanded_panel:SetVisible(true)
        else
            self.expanded_panel:SizeTo(self:GetWide(), 0, 0.1, 0, -1, function()
                self.canClickAgain = true
                self.expanded_panel:SetVisible(false)
            end)
        end
    end

    vgui_Register("jlib.ComboBox", PANEL, "jlib.Button")
end

hook_Add("jlib.downloadResources", "jlib.ComboBox.Resources", function()
    jlib.materials.CreateMaterial("combo_down", "jlib", "https://i.imgur.com/UdP4BTG.png")
end)
