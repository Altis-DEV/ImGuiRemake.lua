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
            :format(path, tostring(source)),
            2
        )
    end

    local chunk, compileError =
        loadstring(source)

    if not chunk then
        error(
            ("Không thể compile module %s:\n%s")
            :format(path, tostring(compileError)),
            2
        )
    end

    local okRun, result =
        pcall(chunk)

    if not okRun then
        error(
            ("Lỗi khi chạy module %s:\n%s")
            :format(path, tostring(result)),
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
-- LOAD MODULES
------------------------------------------------------------

local Theme =
    LoadModule("Theme.lua")

local WindowModule =
    LoadModule("Components/Window.lua")

local TabModule =
    LoadModule("Components/Tab.lua")

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
------------------------------------------------------------
-- INJECT COMPONENTS
------------------------------------------------------------

WindowModule._TabModule =
    TabModule

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

------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------

function ImGui:CreateWindow(options)
    return WindowModule.new(
        options,
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

return ImGui
