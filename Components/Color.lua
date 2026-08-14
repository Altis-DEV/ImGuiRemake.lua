-- File: ImGuiRemake.lua/Components/Color.lua

local Color = {}
Color.__index = Color

local ELEMENT_HEIGHT = 30
local TITLE_GAP = 8

local DEFAULT_COLOR =
    Color3.fromRGB(255, 255, 255)

local function setFont(instance, fontType)
    if not instance then
        return
    end

    if typeof(fontType) == "string"
        and string.find(
            string.lower(fontType),
            "rbxassetid",
            1,
            true
        ) then

        local ok, customFont =
            pcall(function()
                return Font.new(fontType)
            end)

        if ok and customFont then
            instance.FontFace = customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        instance.Font = fontType
    end
end

function Color.new(tab, options)
    options = options or {}

    local self =
        setmetatable({}, Color)

    self.Tab = tab
    self.Window = tab.Window

    self.HasTitle =
        options.Title ~= nil
        and tostring(options.Title) ~= ""

    self.Title =
        self.HasTitle
        and tostring(options.Title)
        or ""

    self.Color =
        typeof(options.Color) == "Color3"
        and options.Color
        or self.Window.ThemeData.Accent
        or DEFAULT_COLOR

    self.Destroyed = false

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- CONTAINER
    ------------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        self.HasTitle
        and self.Title .. "_Color"
        or "Color"

    self.Container.Size =
        UDim2.new(
            1,
            -12,
            0,
            ELEMENT_HEIGHT
        )

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- COLOR FRAME
    ------------------------------------------------------------

    self.ColorFrame =
        Instance.new("Frame")

    self.ColorFrame.Name =
        "ColorFrame"

    self.ColorFrame.Size =
        UDim2.new(
            0,
            ELEMENT_HEIGHT,
            0,
            ELEMENT_HEIGHT
        )

    self.ColorFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.ColorFrame.BackgroundColor3 =
        self.Color

    self.ColorFrame.BorderColor3 =
        theme.Border

    self.ColorFrame.BorderSizePixel =
        1

    self.ColorFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE
    ------------------------------------------------------------

    if self.HasTitle then
        self:_CreateTitleLabel(theme)
    end

    ------------------------------------------------------------
    -- FONT
    ------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    ------------------------------------------------------------
    -- REGISTER
    ------------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CREATE TITLE
------------------------------------------------------------

function Color:_CreateTitleLabel(theme)
    if self.TitleLabel then
        return
    end

    self.TitleLabel =
        Instance.new("TextLabel")

    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -(ELEMENT_HEIGHT + TITLE_GAP),
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            0,
            ELEMENT_HEIGHT + TITLE_GAP,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency =
        1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize =
        13

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.Container
end

------------------------------------------------------------
-- SET COLOR
------------------------------------------------------------

function Color:SetColor(newColor)
    if self.Destroyed then
        return
    end

    if typeof(newColor) ~= "Color3" then
        return
    end

    self.Color =
        newColor

    self.ColorFrame.BackgroundColor3 =
        self.Color
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function Color:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    if newTitle == nil
        or tostring(newTitle) == "" then

        self.HasTitle = false
        self.Title = ""

        if self.TitleLabel then
            self.TitleLabel:Destroy()
            self.TitleLabel = nil
        end

        self.Container.Name =
            "Color"

        return
    end

    self.HasTitle = true
    self.Title =
        tostring(newTitle)

    if not self.TitleLabel then
        self:_CreateTitleLabel(
            self.Window.ThemeData
        )
    end

    self.Container.Name =
        self.Title .. "_Color"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Color:SetFont(fontType)
    if self.Destroyed then
        return
    end

    if self.TitleLabel then
        setFont(
            self.TitleLabel,
            fontType
        )
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Color:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- COLOR FRAME
    --
    -- Background remains the user's selected Color.
    --------------------------------------------------------

    self.ColorFrame.BackgroundColor3 =
        self.Color

    self.ColorFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    if self.TitleLabel then
        self.TitleLabel.TextColor3 =
            theme.Text
    end

    --------------------------------------------------------
    -- FONT
    --------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Color:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

    for i, element in ipairs(
        self.Tab.Elements
    ) do

        if element == self then
            table.remove(
                self.Tab.Elements,
                i
            )

            break
        end
    end
end

return Color
