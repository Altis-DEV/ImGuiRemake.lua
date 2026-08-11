-- File: ImGuiRemake.lua/init.lua
local ImGui = {}
local repo = "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"

local Theme = loadstring(game:HttpGet(repo .. "Theme.lua"))()
local WindowModule = loadstring(game:HttpGet(repo .. "Components/Window.lua"))()
local TabModule = loadstring(game:HttpGet(repo .. "Components/Tab.lua"))()
local ButtonModule = loadstring(game:HttpGet(repo .. "Components/Button.lua"))()

-- Inject các Module phụ thuộc vào Window
WindowModule._TabModule = TabModule
WindowModule.ButtonModule = ButtonModule

function ImGui:CreateWindow(options)
    return WindowModule.new(options, Theme:GetTheme("Default"), Theme)
end

function ImGui:CreateTheme(name, colors)
    Theme:CreateTheme(name, colors)
end

return ImGui
