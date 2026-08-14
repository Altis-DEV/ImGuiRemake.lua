-- File: ImGuiRemake.lua/Theme.lua

local Theme = {}

Theme.Themes = {
    Default = {
        Accent = Color3.fromRGB(40, 90, 175),

        Background = Color3.fromRGB(20, 20, 20),
        TabContainer = Color3.fromRGB(30, 30, 30),
        ElementContainer = Color3.fromRGB(25, 25, 25),

        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(60, 60, 60),

        CloseBtn = Color3.fromRGB(235, 70, 70),

        Tab = Color3.fromRGB(35, 35, 35),
        TabHighlight = Color3.fromRGB(40, 90, 175),

        Button = Color3.fromRGB(40, 90, 175),
        ButtonHighlight = Color3.fromRGB(60, 110, 220),
        ButtonText = Color3.fromRGB(255, 255, 255),

        Checkbox = Color3.fromRGB(0, 170, 255),

        SliderFrame = Color3.fromRGB(38, 38, 38),
        SliderBar = Color3.fromRGB(40, 90, 175),

        DropdownFrame = Color3.fromRGB(38, 38, 38),
        DropdownOption = Color3.fromRGB(30, 30, 30),
        DropdownOptionSelected = Color3.fromRGB(40, 90, 175),
        DropdownOptionHover = Color3.fromRGB(50, 50, 50),

        TextBoxFrame = Color3.fromRGB(38, 38, 38),
        Placeholder = Color3.fromRGB(150, 150, 150),

        ParagraphTitleFrame = Color3.fromRGB(32, 32, 32),
        ParagraphTextFrame = Color3.fromRGB(26, 26, 26),

        SectionTitleFrame = Color3.fromRGB(32, 32, 32),
        SectionElementContainer = Color3.fromRGB(25, 25, 25),

        ----------------------------------------------------
        -- MODAL
        ----------------------------------------------------

        ModalOverlay =
            Color3.fromRGB(0, 0, 0),

        ModalOverlayTransparency =
            0.45,

        ModalFrame =
            Color3.fromRGB(22, 22, 22),

        ModalTitleFrame =
            Color3.fromRGB(32, 32, 32),

        ModalTextFrame =
            Color3.fromRGB(26, 26, 26),

        ModalButtonFrame =
            Color3.fromRGB(30, 30, 30),

        ModalButton =
            Color3.fromRGB(40, 90, 175),

        ModalButtonHighlight =
            Color3.fromRGB(60, 110, 220),

        ModalButtonText =
            Color3.fromRGB(255, 255, 255),

        TextInputFrame =
    Color3.fromRGB(38, 38, 38),

        TextInputText =
    Color3.fromRGB(255, 255, 255),

        TextInputPlaceholder =
    Color3.fromRGB(150, 150, 150),

        ConsoleFrame =
    Color3.fromRGB(24, 24, 24),

        ConsoleText =
    Color3.fromRGB(220, 220, 220),
    }
}

function Theme:CreateTheme(
    themeName,
    colorTable
)
    assert(
        type(themeName) == "string",
        "Theme name must be a string"
    )

    assert(
        type(colorTable) == "table",
        "Theme colors must be a table"
    )

    local newTheme = {}

    for key, value in pairs(
        self.Themes.Default
    ) do
        newTheme[key] = value
    end

    for key, value in pairs(
        colorTable
    ) do
        newTheme[key] = value
    end

    self.Themes[themeName] =
        newTheme

    return newTheme
end

function Theme:GetTheme(themeName)
    return self.Themes[themeName]
        or self.Themes.Default
end

return Theme
