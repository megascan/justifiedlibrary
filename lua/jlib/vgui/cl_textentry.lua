local ScreenScale = ScreenScale
local draw = draw
local math = math
local vgui = vgui

do
    local PANEL = {}

    function PANEL:Init()
        self.rounding = ScreenScale(1)
        self.shadow_on = false
        self:SetFontScale(16)
    end

    function PANEL:InvokeError(err)
        self.invoke_error_text = err
        self.invoke_time = CurTime() + 1
    end

    function PANEL:EnableShadows(state)
        self.shadow_on = state
    end

    function PANEL:Paint(w, h)
        draw.RoundedBox(self.rounding, 0, 0, w, h, jlib.theme.textentry_base_color)

        if self.invoke_error_text and self.invoke_time > CurTime() then
            draw.RoundedBox(self.rounding, 0, h - 2, w, 2, jlib.theme.error)

            if self:IsMultiline() then
                draw.SimpleText(self.invoke_error_text, self:GetFont(), 2, 0, jlib.theme.textentry_placeholder_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                draw.SimpleText(self.invoke_error_text, self:GetFont(), 2, h / 2, jlib.theme.textentry_placeholder_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            return
        end

        surface.SetDrawColor(jlib.theme.scroller_grip_color)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        jlib.utils.ClickingAnimationHandle(self, math.max(w, h), jlib.theme.textentry_cursor_color)
        self:DrawTextEntryText(self:GetTextColor() or jlib.theme.textentry_text_color, jlib.theme.textentry_cursor_color, jlib.theme.textentry_text_color)
        local placeholder = self:GetPlaceholderText()

        if placeholder and placeholder ~= "" and self:GetText() == "" then
            if self:IsMultiline() then
                draw.SimpleText(placeholder, self:GetFont(), 2, 0, jlib.theme.textentry_placeholder_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                draw.SimpleText(placeholder, self:GetFont(), 2, h / 2, jlib.theme.textentry_placeholder_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    function PANEL:SetFontScale(scale)
        self:SetFont(jlib.fonts.Font(scale, jlib.theme.font, 200))
    end

    function PANEL:OnFocusChanged(state)
        if state then
            jlib.utils.DoClickAnimation(self, 0.3)
        end
    end

    vgui.Register("jlib.TextEntry", PANEL, "DTextEntry")
end