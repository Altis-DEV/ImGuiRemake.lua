-- File: DepsoImGui/Theme.lua
local Theme = {}

Theme.Themes = {
    ["Default"] = {
        Accent = Color3.fromRGB(40, 90, 175),       -- Màu chủ đạo (Topbar, Resize corner)
        Background = Color3.fromRGB(20, 20, 20),    -- Nền window
        TabContainer = Color3.fromRGB(30, 30, 30),  -- Nền khu vực Tab
        ElementContainer = Color3.fromRGB(25, 25, 25), -- Nền khu vực Element
        Text = Color3.fromRGB(255, 255, 255),       -- Màu chữ chính
        CloseBtn = Color3.fromRGB(235, 70, 70),     -- Màu nút X khi hover
        Border = Color3.fromRGB(60, 60, 60)         -- Màu viền
    },
    ["DarkRed"] = {
        Accent = Color3.fromRGB(175, 40, 40),
        Background = Color3.fromRGB(15, 15, 15),
        TabContainer = Color3.fromRGB(25, 25, 25),
        ElementContainer = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(240, 240, 240),
        CloseBtn = Color3.fromRGB(255, 50, 50),
        Border = Color3.fromRGB(45, 45, 45)
    }
}

-- Hàm cho phép người dùng tự tạo theme mới
function Theme:CreateTheme(themeName, colorTable)
    self.Themes[themeName] = colorTable
end

function Theme:GetTheme(themeName)
    return self.Themes[themeName] or self.Themes["Default"]
end

return Theme

