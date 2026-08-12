-- File: ImGuiRemake.lua/Components/ColorPreview.lua

local ColorPreview = {}
ColorPreview.__index = ColorPreview

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local ELEMENT_HEIGHT = 30
local PADDING_X = 8
local PADDING_Y = 5

local PREVIEW_WIDTH = 0.5
local INPUT_WIDTH = 1 - PREVIEW_WIDTH

local DEFAULT_COLOR =
    Color3.fromRGB(255, 255, 255)

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(255, 255, 255)

local DEFAULT_PLACEHOLDER_COLOR =
    Color3.fromRGB(150, 150, 150)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function clamp(value, minValue, maxValue)
    return math.clamp(value, minValue, maxValue)
end

local function toByte(value)
    return math.floor(
        clamp(value * 255, 0, 255) + 0.5
    )
end

local function colorToHex(color)
    return string.format(
        "#%02X%02X%02X",
        toByte(color.R),
        toByte(color.G),
        toByte(color.B)
    )
end

local function colorToColor3Text(color)
    return string.format(
        "%.3f, %.3f, %.3f",
        color.R,
        color.G,
        color.B
    )
end

------------------------------------------------------------
-- PARSE HEX
------------------------------------------------------------

local function parseHex(text)

    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("%s+", "")
    text = text:upper()

    if text:sub(1, 1) == "#" then
        text = text:sub(2)
    end

    --------------------------------------------------------
    -- RRGGBB
    --------------------------------------------------------

    if #text == 6
        and text:match("^[%x]+$") then

        local r =
            tonumber(
                text:sub(1, 2),
                16
            )

        local g =
            tonumber(
                text:sub(3, 4),
                16
            )

        local b =
            tonumber(
                text:sub(5, 6),
                16
            )

        if r and g and b then
            return Color3.fromRGB(
                r,
                g,
                b
            )
        end
    end

    --------------------------------------------------------
    -- RGB SHORT HEX
    --
    -- #FFF -> #FFFFFF
    --------------------------------------------------------

    if #text == 3
        and text:match("^[%x]+$") then

        local r =
            tonumber(
                text:sub(1, 1) .. text:sub(1, 1),
                16
            )

        local g =
            tonumber(
                text:sub(2, 2) .. text:sub(2, 2),
                16
            )

        local b =
            tonumber(
                text:sub(3, 3) .. text:sub(3, 3),
                16
            )

        if r and g and b then
            return Color3.fromRGB(
                r,
                g,
                b
            )
        end
    end

    return nil
end

------------------------------------------------------------
-- PARSE COLOR3
------------------------------------------------------------

local function parseColor3(text)

    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("%s+", "")

    local r, g, b =
        text:match(
            "^([%+%-]?[%d%.]+),([%+%-]?[%d%.]+),([%+%-]?[%d%.]+)$"
        )

    if not r then
        return nil
    end

    r = tonumber(r)
    g = tonumber(g)
    b = tonumber(b)

    if not r or not g or not b then
        return nil
    end

    --------------------------------------------------------
    -- Color3 values are expected to be 0 -> 1
    --------------------------------------------------------

    r = clamp(r, 0, 1)
    g = clamp(g, 0, 1)
    b = clamp(b, 0, 1)

    return Color3.new(
        r,
        g,
        b
    )
end

------------------------------------------------------------
-- FONT HELPER
------------------------------------------------------------

local function setFont(instance, fontType)

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
            instance.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        instance.Font =
            fontType
    end
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function ColorPreview.new(tab, options)

    options = options or {}

    if options.Title == nil then
        error(
            "ColorPreview requires a Title",
            2
        )
    end

    local self =
        setmetatable({}, ColorPreview)

    self.Tab = tab
    self.Window = tab.Window

    self.Title =
        tostring(options.Title)

    self.Color =
        typeof(options.Color) == "Color3"
        and options.Color
        or DEFAULT_COLOR

    self.Destroyed = false

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- OUTER CONTAINER
    ------------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        self.Title .. "_ColorPreview"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- TITLE FRAME
    ------------------------------------------------------------

    self.TitleFrame =
        Instance.new("Frame")

    self.TitleFrame.Name =
        "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.TitleFrame.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background
        or Color3.fromRGB(20, 20, 20)

    self.TitleFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.TitleFrame.BorderSizePixel =
        1

    self.TitleFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE LABEL
    ------------------------------------------------------------

    self.TitleLabel =
        Instance.new("TextLabel")

    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -(PADDING_X * 2),
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            0,
            PADDING_X,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency =
        1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.RichText =
        true

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.TitleLabel.TextSize =
        13

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.TitleFrame

    ------------------------------------------------------------
    -- CONTENT CONTAINER
    ------------------------------------------------------------

    self.Content =
        Instance.new("Frame")

    self.Content.Name =
        "Content"

    self.Content.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT * 2 + PADDING_Y * 2
        )

    self.Content.BackgroundTransparency =
        1

    self.Content.BorderSizePixel =
        0

    self.Content.Parent =
        self.Container

    ------------------------------------------------------------
    -- PREVIEW FRAME
    ------------------------------------------------------------

    self.Preview =
        Instance.new("Frame")

    self.Preview.Name =
        "Preview"

    self.Preview.Size =
        UDim2.new(
            PREVIEW_WIDTH,
            -4,
            1,
            0
        )

    self.Preview.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.Preview.BackgroundColor3 =
        self.Color

    self.Preview.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.Preview.BorderSizePixel =
        1

    self.Preview.Parent =
        self.Content

    ------------------------------------------------------------
    -- INPUT PANEL
    ------------------------------------------------------------

    self.InputPanel =
        Instance.new("Frame")

    self.InputPanel.Name =
        "InputPanel"

    self.InputPanel.Size =
        UDim2.new(
            INPUT_WIDTH,
            -4,
            1,
            0
        )

    self.InputPanel.Position =
        UDim2.new(
            PREVIEW_WIDTH,
            8,
            0,
            0
        )

    self.InputPanel.BackgroundTransparency =
        1

    self.InputPanel.BorderSizePixel =
        0

    self.InputPanel.Parent =
        self.Content

    ------------------------------------------------------------
    -- DIVIDER
    ------------------------------------------------------------

    self.Divider =
        Instance.new("Frame")

    self.Divider.Name =
        "Divider"

    self.Divider.Size =
        UDim2.new(
            0,
            1,
            1,
            0
        )

    self.Divider.Position =
        UDim2.new(
            PREVIEW_WIDTH,
            3,
            0,
            0
        )

    self.Divider.BackgroundColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.Divider.BorderSizePixel =
        0

    self.Divider.Parent =
        self.Content

    ------------------------------------------------------------
    -- COLOR3 LABEL
    ------------------------------------------------------------

    self.Color3Label =
        Instance.new("TextLabel")

    self.Color3Label.Name =
        "Color3Label"

    self.Color3Label.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.Color3Label.BackgroundTransparency =
        1

    self.Color3Label.Text =
        "Color3"

    self.Color3Label.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.Color3Label.TextSize =
        12

    self.Color3Label.Font =
        self.Window.CurrentFont

    self.Color3Label.TextXAlignment =
        Enum.TextXAlignment.Left

    self.Color3Label.TextYAlignment =
        Enum.TextYAlignment.Center

    self.Color3Label.Parent =
        self.InputPanel

    ------------------------------------------------------------
    -- COLOR3 INPUT
    ------------------------------------------------------------

    self.Color3Box =
        Instance.new("TextBox")

    self.Color3Box.Name =
        "Color3"

    self.Color3Box.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.Color3Box.Position =
        UDim2.new(
            0,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.Color3Box.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background
        or Color3.fromRGB(30, 30, 30)

    self.Color3Box.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.Color3Box.BorderSizePixel =
        1

    self.Color3Box.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.Color3Box.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.Color3Box.PlaceholderText =
        "1, 0.5, 0"

    self.Color3Box.TextSize =
        12

    self.Color3Box.Font =
        self.Window.CurrentFont

    self.Color3Box.TextXAlignment =
        Enum.TextXAlignment.Center

    self.Color3Box.TextYAlignment =
        Enum.TextYAlignment.Center

    self.Color3Box.ClearTextOnFocus =
        false

    self.Color3Box.Parent =
        self.InputPanel

    ------------------------------------------------------------
    -- HEX LABEL
    ------------------------------------------------------------

    self.HexLabel =
        Instance.new("TextLabel")

    self.HexLabel.Name =
        "HexLabel"

    self.HexLabel.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.HexLabel.Position =
        UDim2.new(
            0,
            0,
            0,
            ELEMENT_HEIGHT * 2 + PADDING_Y
        )

    self.HexLabel.BackgroundTransparency =
        1

    self.HexLabel.Text =
        "Hex"

    self.HexLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.HexLabel.TextSize =
        12

    self.HexLabel.Font =
        self.Window.CurrentFont

    self.HexLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.HexLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.HexLabel.Parent =
        self.InputPanel

    ------------------------------------------------------------
    -- HEX INPUT
    ------------------------------------------------------------

    self.HexBox =
        Instance.new("TextBox")

    self.HexBox.Name =
        "Hex"

    self.HexBox.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.HexBox.Position =
        UDim2.new(
            0,
            0,
            0,
            ELEMENT_HEIGHT * 3 + PADDING_Y
        )

    self.HexBox.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background
        or Color3.fromRGB(30, 30, 30)

    self.HexBox.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.HexBox.BorderSizePixel =
        1

    self.HexBox.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.HexBox.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.HexBox.PlaceholderText =
        "#FFFFFF"

    self.HexBox.TextSize =
        12

    self.HexBox.Font =
        self.Window.CurrentFont

    self.HexBox.TextXAlignment =
        Enum.TextXAlignment.Center

    self.HexBox.TextYAlignment =
        Enum.TextYAlignment.Center

    self.HexBox.ClearTextOnFocus =
        false

    self.HexBox.Parent =
        self.InputPanel

    ------------------------------------------------------------
    -- UPDATE INITIAL TEXT
    ------------------------------------------------------------

    self:_UpdateText()

    ------------------------------------------------------------
    -- COLOR3 INPUT
    ------------------------------------------------------------

    self.Color3Box.FocusLost:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:_ApplyColor3Text(
                self.Color3Box.Text
            )
        end
    )

    ------------------------------------------------------------
    -- HEX INPUT
    ------------------------------------------------------------

    self.HexBox.FocusLost:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:_ApplyHex(
                self.HexBox.Text
            )
        end
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
-- UPDATE DISPLAY TEXT
------------------------------------------------------------

function ColorPreview:_UpdateText()

    if self.Destroyed then
        return
    end

    self.Color3Box.Text =
        colorToColor3Text(
            self.Color
        )

    self.HexBox.Text =
        colorToHex(
            self.Color
        )
end

------------------------------------------------------------
-- UPDATE PREVIEW
------------------------------------------------------------

function ColorPreview:_UpdatePreview()

    self.Preview.BackgroundColor3 =
        self.Color
end

------------------------------------------------------------
-- SET COLOR
------------------------------------------------------------

function ColorPreview:SetColor(color)

    if self.Destroyed then
        return
    end

    if typeof(color) ~= "Color3" then
        warn(
            "ColorPreview:SetColor() expects Color3"
        )

        return
    end

    self.Color =
        color

    self:_UpdatePreview()
    self:_UpdateText()

    task.spawn(
        function()
            local ok, err =
                pcall(
                    self.Callback,
                    self.Color
                )

            if not ok then
                warn(
                    "ColorPreview callback error:",
                    err
                )
            end
        end
    )
end

------------------------------------------------------------
-- APPLY COLOR3 TEXT
------------------------------------------------------------

function ColorPreview:_ApplyColor3Text(text)

    local color =
        parseColor3(text)

    if not color then
        self:_UpdateText()
        return false
    end

    self:SetColor(color)

    return true
end

------------------------------------------------------------
-- APPLY HEX
------------------------------------------------------------

function ColorPreview:_ApplyHex(text)

    local color =
        parseHex(text)

    if not color then
        self:_UpdateText()
        return false
    end

    self:SetColor(color)

    return true
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function ColorPreview:SetTitle(newTitle)

    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title
        .. "_ColorPreview"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function ColorPreview:SetFont(fontType)

    if self.Destroyed then
        return
    end

    local instances = {
        self.TitleLabel,

        self.Color3Label,
        self.Color3Box,

        self.HexLabel,
        self.HexBox,
    }

    for _, instance in ipairs(instances) do
        setFont(
            instance,
            fontType
        )
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function ColorPreview:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleFrame.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    --------------------------------------------------------
    -- PREVIEW
    --------------------------------------------------------

    self.Preview.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- DIVIDER
    --------------------------------------------------------

    self.Divider.BackgroundColor3 =
        theme.Border

    --------------------------------------------------------
    -- INPUTS
    --------------------------------------------------------

    local inputs = {
        self.Color3Box,
        self.HexBox,
    }

    for _, input in ipairs(inputs) do

        input.BackgroundColor3 =
            theme.ColorPickerInput
            or theme.Background

        input.BorderColor3 =
            theme.Border

        input.TextColor3 =
            theme.Text
            or DEFAULT_TEXT_COLOR

        input.PlaceholderColor3 =
            theme.ColorPickerPlaceholder
            or DEFAULT_PLACEHOLDER_COLOR
    end

    self.Color3Label.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.HexLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function ColorPreview:Destroy()

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

return ColorPreview
