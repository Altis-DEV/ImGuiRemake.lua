-- File: ImGuiRemake.lua/init.lua

local ImGui = {}

local repo =
    "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"

------------------------------------------------------------
-- MODULE LOADER
------------------------------------------------------------

local function LoadModule(path)
    local okHttp, source = pcall(function()
        return game:HttpGet(repo .. path)
    end)

    if not okHttp then
        error(
            ("Không thể tải module %s:\n%s")
            :format(
                path,
                tostring(source)
            ),
            2
        )
    end

    if type(source) ~= "string"
        or source == "" then

        error(
            ("Module %s trả về source rỗng!")
            :format(path),
            2
        )
    end

    local chunk, compileError =
        loadstring(source)

    if not chunk then
        error(
            ("Không thể compile module %s:\n%s")
            :format(
                path,
                tostring(compileError)
            ),
            2
        )
    end

    local okRun, result =
        pcall(chunk)

    if not okRun then
        error(
            ("Lỗi khi chạy module %s:\n%s")
            :format(
                path,
                tostring(result)
            ),
            2
        )
    end

    if result == nil then
        error(
            ("Module %s trả về nil!")
            :format(path),
            2
        )
    end

    return result
end

------------------------------------------------------------
-- CORE MODULES
------------------------------------------------------------

local Theme =
    LoadModule("Theme.lua")

local WindowModule =
    LoadModule("Components/Window.lua")

local TabModule =
    LoadModule("Components/Tab.lua")

------------------------------------------------------------
-- COMPONENT MODULES
------------------------------------------------------------

local ButtonModule =
    LoadModule("Components/Button.lua")

local ToggleModule =
    LoadModule("Components/Toggle.lua")

local SliderModule =
    LoadModule("Components/Slider.lua")

local DropdownModule =
    LoadModule("Components/Dropdown.lua")

local TextBoxModule =
    LoadModule("Components/TextBox.lua")

local ParagraphModule =
    LoadModule("Components/Paragraph.lua")

local LabelModule =
    LoadModule("Components/Label.lua")

local DividerModule =
    LoadModule("Components/Divider.lua")

local ColorPickerModule =
    LoadModule("Components/ColorPicker.lua")

local ImageModule =
    LoadModule("Components/Image.lua")

------------------------------------------------------------
-- INJECT TAB MODULE
------------------------------------------------------------

WindowModule._TabModule =
    TabModule

------------------------------------------------------------
-- INJECT COMPONENT MODULES
------------------------------------------------------------

WindowModule.ButtonModule =
    ButtonModule

WindowModule.ToggleModule =
    ToggleModule

WindowModule.SliderModule =
    SliderModule

WindowModule.DropdownModule =
    DropdownModule

WindowModule.TextBoxModule =
    TextBoxModule

WindowModule.ParagraphModule =
    ParagraphModule

WindowModule.LabelModule =
    LabelModule

WindowModule.DividerModule =
    DividerModule

WindowModule.ColorPickerModule =
    ColorPickerModule

WindowModule.ImageModule =
    ImageModule

------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------

function ImGui:CreateWindow(options)
    return WindowModule.new(
        options or {},
        Theme:GetTheme("Default"),
        Theme
    )
end

------------------------------------------------------------
-- CREATE THEME
------------------------------------------------------------

function ImGui:CreateTheme(name, colors)
    return Theme:CreateTheme(
        name,
        colors
    )
end

------------------------------------------------------------
-- OPTIONAL: GET THEME
------------------------------------------------------------

function ImGui:GetTheme(name)
    return Theme:GetTheme(name)
end

------------------------------------------------------------
-- RETURN
------------------------------------------------------------

return ImGui
