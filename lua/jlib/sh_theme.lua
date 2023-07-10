jlib = jlib or {}
local THEME = {}
THEME.font = "Montserrat"
THEME.accent = Color(200, 47, 104)
--[[
    Frame
]]
THEME.frame_header_color = Color(32, 32, 35)
THEME.frame_base_color = Color(28, 28, 31)
THEME.frame_secondary_color = Color(26, 26, 26)
THEME.frame_content_color = Color(23, 23, 26)
THEME.frame_close_color = Color(184, 52, 52)
THEME.frame_close_icon_color = Color(220, 220, 220)
THEME.frame_title_color = Color(233, 233, 233)
THEME.frame_title_secondarycolor = Color(192, 192, 192)
--[[
    Text Color
]]
THEME.text_color = Color(220, 220, 220)
--[[
    TextEntry
]]
THEME.textentry_base_color = Color(30, 30, 33)
THEME.textentry_text_color = Color(220, 220, 220)
THEME.textentry_placeholder_color = Color(175, 175, 175)
THEME.textentry_cursor_color = Color(19, 19, 19)
--[[
    Button
]]
THEME.button_base_color = Color(30, 30, 33)
THEME.button_hover_color = Color(37, 37, 40)
THEME.button_click_color = Color(65, 65, 68)
THEME.button_hover_alternative = Color(35, 35, 38)
THEME.button_text_color = Color(220, 220, 220)
--[[
    Scroller
]]
THEME.scroller_base_color = Color(20, 20, 23)
THEME.scroller_grip_color = Color(26, 26, 30)
--[[
    ComboBox
]]
THEME.combobox_base_color = Color(22, 22, 25)
THEME.combobox_click_color = Color(35, 35, 38)
THEME.error = Color(184, 64, 64)
THEME.success = Color(64, 184, 144)
--[[
    Loading
]]
THEME.loading_background = Color(22, 22, 25)
THEME.loading_inside = Color(0, 119, 255)
jlib.theme = THEME