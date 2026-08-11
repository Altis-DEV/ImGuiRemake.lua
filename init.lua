-- File: DepsoImGui/init.lua
local ImGui = {}
local Theme = require(script.Theme)
local WindowModule = require(script.Components.Window)

-- Cho phép gọi hàm tạo Theme từ thẳng ImGui (rất tiện dụng)
function ImGui:CreateTheme(name, colors)
    Theme:CreateTheme(name, colors)
end

-- Khởi tạo Window chuẩn theo format yêu cầu
function ImGui:CreateWindow(options)
    -- Lấy theme mặc định hoặc theme được chỉ định
    local currentTheme = Theme:GetTheme("Default")
    
    -- Tạo object Window
    local newWindow = WindowModule.new(options, currentTheme)
    
    return newWindow
end

return ImGui
