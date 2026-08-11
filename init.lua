-- File: ImGuiRemake/init.lua
local ImGui = {}

local repo = "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"

local Theme = loadstring(game:HttpGet(repo .. "Theme.lua"))()
local WindowModule = loadstring(game:HttpGet(repo .. "Components/Window.lua"))()
local TabModule = loadstring(game:HttpGet(repo .. "Components/Tab.lua"))()

-- Inject TabModule vào WindowModule để Window có thể tạo tab
WindowModule._TabModule = TabModule

function ImGui:CreateTheme(name, colors)
    Theme:CreateTheme(name, colors)
end

function ImGui:CreateWindow(options)
    local currentTheme = Theme:GetTheme("Default")
    local newWindow = WindowModule.new(options, currentTheme, Theme)
    return newWindow
end

return ImGui
