-- File: ImGuiRemake.lua/init.lua
local ImGui = {}

-- Đường dẫn gốc đến Repository của bạn
local repo = "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"

-- Tải các Module thông qua HTTPGet từ GitHub của bạn
local Theme = loadstring(game:HttpGet(repo .. "Theme.lua"))()
local WindowModule = loadstring(game:HttpGet(repo .. "Components/Window.lua"))()

-- Hàm tạo Theme mới
function ImGui:CreateTheme(name, colors)
    Theme:CreateTheme(name, colors)
end

-- Hàm tạo Cửa sổ chính
function ImGui:CreateWindow(options)
    local currentTheme = Theme:GetTheme("Default")
    
    -- Truyền ThemeManager (biến Theme) vào WindowModule để dùng cho phương thức Window:Theme()
    local newWindow = WindowModule.new(options, currentTheme, Theme)
    
    return newWindow
end

return ImGui
