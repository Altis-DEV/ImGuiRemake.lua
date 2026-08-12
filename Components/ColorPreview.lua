-- File: ImGuiRemake.lua/Components/ColorPreview.lua

local ColorPreview = {}
ColorPreview.__index = ColorPreview

local UserInputService = game:GetService("UserInputService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local ELEMENT_HEIGHT = 30
local WIDTH_SCALE = 0.5

local PADDING_X = 8
local INPUT_HEIGHT = 30
local BODY_PADDING = 6

local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255)

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(255, 255, 255)

local DEFAULT_PLACEHOLDER_COLOR =
    Color3.fromRGB(150, 150, 150)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function setFont(instance, fontType)
    if typeof(fontType) == "string"
        and string.find(
            string.lower(fontType),
            "rbxassetid",
            1,
            true
        ) then

        local ok, customFont = pcall(function()
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

local function clamp01(value)
    return math.clamp(value, 0, 1)
end

------------------------------------------------------------
-- HEX -> COLOR3
------------------------------------------------------------

local function parseHex(value)
    if type(value) ~= "string" then
        return nil
    end

    value =
        string.gsub(
            value,
            "%s+",
            ""
        )

    value =
        string.upper(value)

    if string.sub(value, 1, 1) ~= "#" then
        value = "#" .. value
    end

    --------------------------------------------------------
    -- #RRGGBB
    --------------------------------------------------------

    if string.match(
        value,
        "^#%x%x%x%x%x%x$"
    ) then

        local hex =
            string.sub(value, 2)

        local r =
            tonumber(
                string.sub(hex, 1, 2),
                16
            )

        local g =
            tonumber(
                string.sub(hex, 3, 4),
                16
            )

        local b =
            tonumber(
                string.sub(hex, 5, 6),
                16
            )

        return Color3.fromRGB(
            r,
            g,
            b
        )
    end

    --------------------------------------------------------
    -- #RGB
    --------------------------------------------------------

    if string.match(
        value,
        "^#%x%x%x$"
    ) then

        local hex =
            string.sub(value, 2)

        local r =
            tonumber(
                string.sub(hex, 1, 1)
                    .. string.sub(hex, 1, 1),
                16
            )

        local g =
            tonumber(
                string.sub(hex, 2, 2)
                    .. string.sub(hex, 2, 2),
                16
            )

        local b =
            tonumber(
                string.sub(hex, 3, 3)
                    .. string.sub(hex, 3, 3),
                16
            )

        return Color3.fromRGB(
            r,
            g,
            b
        )
    end

    return nil
end

------------------------------------------------------------
-- COLOR3 STRING
------------------------------------------------------------

local function colorToString(color)
    return string.format(
        "%.3f, %.3f, %.3f",
        color.R,
        color.G,
        color.B
    )
end

------------------------------------------------------------
-- COLOR3 INPUT -> COLOR3
------------------------------------------------------------

local function parseColor3(value)
    if typeof(value) == "Color3" then
        return value
    end

    if type(value) ~= "string" then
        return nil
    end

    value =
        string.gsub(
            value,
            "%s+",
            ""
        )

    -- Cho phép:
    -- 1,0.5,0
    -- 0.1, 0.25, 1

    local r, g, b =
        string.match(
            value,
            "^([^,]+),([^,]+),([^,]+)$"
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

    r = clamp01(r)
    g = clamp01(g)
    b = clamp01(b)

    return Color3.new(
        r,
        g,
        b
    )
end

------------------------------------------------------------
-- HEX FORMAT
------------------------------------------------------------

local function colorToHex(color)
    local r =
        math.floor(
            color.R * 255 + 0.5
        )

    local g =
        math.floor(
            color.G * 255 + 0.5
        )

    local b =
        math.floor(
            color.B * 255 + 0.5
        )

    return string.format(
        "#%02X%02X%02X",
        r,
        g,
        b
    )
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function ColorPreview.new(tab, options)
    options = options or {}

    ------------------------------------------------------------
    -- TITLE REQUIRED
    ------------------------------------------------------------

    if options.Title == nil then
        error(
            "ColorPreview requires a Title",
            2
        )
    end

    local self =
        setmetatable(
            {},
            ColorPreview
        )

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

    self._UpdatingInput = false

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
            0
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
        or Color3.fromRGB(
            32,
            32,
            32
        )

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleFrame.BorderSizePixel =
        1

    self.TitleFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE
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

    self.TitleLabel.TextSize =
        13

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.TitleFrame

    ------------------------------------------------------------
    -- BODY
    ------------------------------------------------------------

    self.Body =
        Instance.new("Frame")

    self.Body.Name =
        "Body"

    self.Body.Size =
        UDim2.new(
            1,
            0,
            0,
            BODY_PADDING * 2
                + INPUT_HEIGHT * 2
        )

    self.Body.BackgroundTransparency =
        1

    self.Body.BorderSizePixel =
        0

    self.Body.Parent =
        self.Container

    ------------------------------------------------------------
    -- PREVIEW FRAME
    ------------------------------------------------------------

    self.PreviewFrame =
        Instance.new("Frame")

    self.PreviewFrame.Name =
        "Preview"

    self.PreviewFrame.Size =
        UDim2.new(
            WIDTH_SCALE,
            -BODY_PADDING,
            1,
            0
        )

    self.PreviewFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.PreviewFrame.BackgroundColor3 =
        self.Color

    self.PreviewFrame.BorderColor3 =
        theme.Border

    self.PreviewFrame.BorderSizePixel =
        1

    self.PreviewFrame.Parent =
        self.Body

    ------------------------------------------------------------
    -- INPUT PANEL
    ------------------------------------------------------------

    self.InputPanel =
        Instance.new("Frame")

    self.InputPanel.Name =
        "InputPanel"

    self.InputPanel.Size =
        UDim2.new(
            WIDTH_SCALE,
            -BODY_PADDING,
            1,
            0
        )

    self.InputPanel.Position =
        UDim2.new(
            WIDTH_SCALE,
            BODY_PADDING,
            0,
            0
        )

    self.InputPanel.BackgroundTransparency =
        1

    self.InputPanel.BorderSizePixel =
        0

    self.InputPanel.Parent =
        self.Body

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
            INPUT_HEIGHT
        )

    self.Color3Box.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.Color3Box.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background
        or Color3.fromRGB(
            30,
            30,
            30
        )

    self.Color3Box.BorderColor3 =
        theme.Border

    self.Color3Box.BorderSizePixel =
        1

    self.Color3Box.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.Color3Box.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.Color3Box.TextSize =
        13

    self.Color3Box.Font =
        self.Window.CurrentFont

    self.Color3Box.TextXAlignment =
        Enum.TextXAlignment.Center

    self.Color3Box.TextYAlignment =
        Enum.TextYAlignment.Center

    self.Color3Box.ClearTextOnFocus =
        false

    self.Color3Box.PlaceholderText =
        "1.000, 1.000, 1.000"

    self.Color3Box.Parent =
        self.InputPanel

    ------------------------------------------------------------
    -- DIVIDER
    ------------------------------------------------------------

    self.Divider =
        Instance.new("Frame")

    self.Divider.Name =
        "Divider"

    self.Divider.Size =
        UDim2.new(
            1,
            0,
            0,
            1
        )

    self.Divider.Position =
        UDim2.new(
            0,
            0,
            0,
            INPUT_HEIGHT
        )

    self.Divider.BackgroundColor3 =
        theme.Border

    self.Divider.BorderSizePixel =
        0

    self.Divider.Parent =
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
            INPUT_HEIGHT
        )

    self.HexBox.Position =
        UDim2.new(
            0,
            0,
            0,
            INPUT_HEIGHT + 1
        )

    self.HexBox.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background
        or Color3.fromRGB(
            30,
            30,
            30
        )

    self.HexBox.BorderColor3 =
        theme.Border

    self.HexBox.BorderSizePixel =
        1

    self.HexBox.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.HexBox.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.HexBox.TextSize =
        13

    self.HexBox.Font =
        self.Window.CurrentFont

    self.HexBox.TextXAlignment =
        Enum.TextXAlignment.Center

    self.HexBox.TextYAlignment =
        Enum.TextYAlignment.Center

    self.HexBox.ClearTextOnFocus =
        false

    self.HexBox.PlaceholderText =
        "#FFFFFF"

    self.HexBox.Parent =
        self.InputPanel

    ------------------------------------------------------------
    -- INITIAL VALUE
    ------------------------------------------------------------

    self:_UpdateDisplay()

    ------------------------------------------------------------
    -- COLOR3 INPUT
    ------------------------------------------------------------

    self.Color3Box.FocusLost:Connect(
        function()
            if self.Destroyed
                or self._UpdatingInput then
                return
            end

            local color =
                parseColor3(
                    self.Color3Box.Text
                )

            if color then
                self:SetColor(
                    color
                )
            else
                self:_UpdateDisplay()
            end
        end
    )

    ------------------------------------------------------------
    -- HEX INPUT
    ------------------------------------------------------------

    self.HexBox.FocusLost:Connect(
        function()
            if self.Destroyed
                or self._UpdatingInput then
                return
            end

            local color =
                parseHex(
                    self.HexBox.Text
                )

            if color then
                self:SetColor(
                    color
                )
            else
                self:_UpdateDisplay()
            end
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
-- UPDATE DISPLAY
------------------------------------------------------------

function ColorPreview:_UpdateDisplay()
    if self.Destroyed then
        return
    end

    self._UpdatingInput = true

    self.PreviewFrame.BackgroundColor3 =
        self.Color

    self.Color3Box.Text =
        colorToString(
            self.Color
        )

    self.HexBox.Text =
        colorToHex(
            self.Color
        )

    self._UpdatingInput = false
end

------------------------------------------------------------
-- SET COLOR
------------------------------------------------------------

function ColorPreview:SetColor(color)
    if self.Destroyed then
        return
    end

    if typeof(color) ~= "Color3" then
        return
    end

    self.Color =
        color

    self:_UpdateDisplay()

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
-- GET COLOR
------------------------------------------------------------

function ColorPreview:GetColor()
    if self.Destroyed then
        return nil
    end

    return self.Color
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

    setFont(
        self.TitleLabel,
        fontType
    )

    setFont(
        self.Color3Box,
        fontType
    )

    setFont(
        self.HexBox,
        fontType
    )
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
        or Color3.fromRGB(
            32,
            32,
            32
        )

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    --------------------------------------------------------
    -- PREVIEW
    --------------------------------------------------------

    self.PreviewFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- INPUT PANEL
    --------------------------------------------------------

    self.Color3Box.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background

    self.Color3Box.BorderColor3 =
        theme.Border

    self.Color3Box.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.Color3Box.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.HexBox.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background

    self.HexBox.BorderColor3 =
        theme.Border

    self.HexBox.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.HexBox.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.Divider.BackgroundColor3 =
        theme.Border

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
