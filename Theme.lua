-- File: ImGuiRemake.lua/Theme.lua
local Theme = {}

Theme.Themes = {
    ["Default"] = {
        Accent = Color3.fromRGB(40, 90, 175),
        Background = Color3.fromRGB(20, 20, 20),
        TabContainer = Color3.fromRGB(30, 30, 30),
        ElementContainer = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        CloseBtn = Color3.fromRGB(235, 70, 70),
        Border = Color3.fromRGB(60, 60, 60),
        -- THÊM 2 DÒNG NÀY:
        Tab = Color3.fromRGB(35, 35, 35),           -- Nền tab lúc chưa chọn
        TabHighlight = Color3.fromRGB(40, 90, 175)  -- Nền tab lúc được chọn
    },
    ["DarkRed"] = {
        Accent = Color3.fromRGB(175, 40, 40),
        Background = Color3.fromRGB(15, 15, 15),
        TabContainer = Color3.fromRGB(25, 25, 25),
        ElementContainer = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(240, 240, 240),
        CloseBtn = Color3.fromRGB(255, 50, 50),
        Border = Color3.fromRGB(45, 45, 45),
        -- THÊM 2 DÒNG NÀY:
        Tab = Color3.fromRGB(30, 30, 30),
        TabHighlight = Color3.fromRGB(175, 40, 40)
    }
}

function Theme:CreateTheme(themeName, colorTable)
    self.Themes[themeName] = colorTable
end

function Theme:GetTheme(themeName)
    return self.Themes[themeName] or self.Themes["Default"]
end

return Theme
