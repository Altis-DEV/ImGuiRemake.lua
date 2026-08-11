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
        Tab = Color3.fromRGB(35, 35, 35),
        TabHighlight = Color3.fromRGB(40, 90, 175),
        -- Button
        Button = Color3.fromRGB(40, 90, 175),
        ButtonHighlight = Color3.fromRGB(60, 110, 220),
        ButtonText = Color3.fromRGB(255, 255, 255)
    }
}

function Theme:CreateTheme(themeName, colorTable)
    self.Themes[themeName] = colorTable
end

function Theme:GetTheme(themeName)
    return self.Themes[themeName] or self.Themes["Default"]
end

return Theme
