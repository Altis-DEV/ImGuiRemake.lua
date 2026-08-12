-- File: ImGuiRemake.lua/init.lua

local ImGui = {}

local repo =
    "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"

local function LoadModule(path)
    local source = game:HttpGet(repo .. path)
    local chunk, err = loadstring(source)

    if not chunk then
        error(("Failed to load %s:\n%s"):format(path, tostring(err)), 2)
    end

    local result = chunk()

    if result == nil then
        error(("Module %s returned nil"):format(path), 2)
    end

    return result
end

local Theme = LoadModule("Theme.lua")
local WindowModule = LoadModule("Components/Window.lua")
local TabModule = LoadModule("Components/Tab.lua")
local ButtonModule = LoadModule("Components/Button.lua")
local ToggleModule = LoadModule("Components/Toggle.lua")
local SliderModule = LoadModule("Components/Slider.lua")
local DropdownModule = LoadModule("Components/Dropdown.lua")
local TextBoxModule = LoadModule("Components/TextBox.lua")

WindowModule._TabModule = TabModule
WindowModule.ButtonModule = ButtonModule
WindowModule.ToggleModule = ToggleModule
WindowModule.SliderModule = SliderModule
WindowModule.TextBoxModule = TextBoxModule


function ImGui:CreateWindow(options)
    return WindowModule.new(
        options,
        Theme:GetTheme("Default"),
        Theme
    )
end

function ImGui:CreateTheme(name, colors)
    return Theme:CreateTheme(name, colors)
end

return ImGui
