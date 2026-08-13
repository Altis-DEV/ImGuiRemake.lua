-- File: ImGuiRemake.lua/Components/ColorPreview.lua

local ColorPreview = {}
ColorPreview.__index = ColorPreview

local ELEMENT_HEIGHT = 30
local WIDTH_SCALE = 0.5

local PADDING_X = 8
local PADDING_Y = 5
local INPUT_GAP = 5

local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255)
local DEFAULT_PLACEHOLDER = Color3.fromRGB(150, 150, 150)

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

local function formatColor3(color)
    return string.format(
        "%.3f, %.3f, %.3f",
        color.R,
        color.G,
        color.B
    )
end

local function formatHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.round(color.R * 255),
        math.round(color.G * 255),
        math.round(color.B * 255)
    )
end

------------------------------------------------------------
-- HEX PARSER
------------------------------------------------------------

local function parseHex(text)
    if type(text) ~= "string" then
        return nil
    end

    text = string.gsub(text, "%s+", "")
    text = string.upper(text)

    if string.sub(text, 1, 1) ~= "#" then
        text = "#" .. text
    end

    -- #RGB
    if string.match(text, "^#%x%x%x$") then
        local hex = string.sub(text, 2)

        local r = tonumber(
            string.sub(hex, 1, 1) .. string.sub(hex, 1, 1),
            16
        )

        local g = tonumber(
            string.sub(hex, 2, 2) .. string.sub(hex, 2, 2),
            16
        )

        local b = tonumber(
            string.sub(hex, 3, 3) .. string.sub(hex, 3, 3),
            16
        )

        return Color3.fromRGB(r, g, b)
    end

    -- #RRGGBB
    if string.match(text, "^#%x%x%x%x%x%x$") then
        local hex = string.sub(text, 2)

        local r = tonumber(string.sub(hex, 1, 2), 16)
        local g = tonumber(string.sub(hex, 3, 4), 16)
        local b = tonumber(string.sub(hex, 5, 6), 16)

        return Color3.fromRGB(r, g, b)
    end

    return nil
end

------------------------------------------------------------
-- COLOR3 PARSER
------------------------------------------------------------

local function parseColor3(text)
    if type(text) ~= "string" then
        return nil
    end

    local values = {}

    for number in string.gmatch(
        text,
        "[-+]?%d*%.?%d+"
    ) do
        table.insert(
            values,
            tonumber(number)
        )
    end

    if #values ~= 3 then
        return nil
    end

    return Color3.new(
        clamp01(values[1]),
        clamp01(values[2]),
        clamp01(values[3])
    )
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

    local self = setmetatable({}, ColorPreview)

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(options.Title)

    self.Color =
        typeof(options.Color) == "Color3"
        and options.Color
        or DEFAULT_COLOR

    self.Destroyed = false

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- OUTER CONTAINER
    ------------------------------------------------------------

    self.Container = Instance.new("Frame")
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

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- TITLE FRAME
    ------------------------------------------------------------

    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Name = "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.TitleFrame.BackgroundColor3 =
        theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleFrame.BorderSizePixel = 1
    self.TitleFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE LABEL
    ------------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

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

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.RichText = true

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.TitleFrame

    ------------------------------------------------------------
    -- BODY
    ------------------------------------------------------------

    self.Body = Instance.new("Frame")
    self.Body.Name = "Body"

    self.Body.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT * 2 + INPUT_GAP
        )

    self.Body.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Body.BackgroundTransparency = 1
    self.Body.BorderSizePixel = 0
    self.Body.Parent =
        self.Container

    ------------------------------------------------------------
    -- LEFT INPUT FRAME
    ------------------------------------------------------------

    self.InputFrame = Instance.new("Frame")
    self.InputFrame.Name =
        "InputFrame"

    self.InputFrame.Size =
        UDim2.new(
            WIDTH_SCALE,
            -4,
            0,
            ELEMENT_HEIGHT * 2 + INPUT_GAP
        )

    self.InputFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.InputFrame.BackgroundTransparency = 1
    self.InputFrame.BorderSizePixel = 0
    self.InputFrame.Parent =
        self.Body

    ------------------------------------------------------------
    -- COLOR3 TEXTBOX
    ------------------------------------------------------------

    self.Color3Box = Instance.new("TextBox")
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
            0
        )

    self.Color3Box.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background

    self.Color3Box.BorderColor3 =
        theme.Border

    self.Color3Box.BorderSizePixel = 1

    self.Color3Box.TextColor3 =
        theme.Text

    self.Color3Box.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER

    self.Color3Box.PlaceholderText =
        "Color3: 1, 0.5, 0"

    self.Color3Box.TextSize = 13
    self.Color3Box.Font =
        self.Window.CurrentFont

    self.Color3Box.TextXAlignment =
        Enum.TextXAlignment.Center

    self.Color3Box.TextYAlignment =
        Enum.TextYAlignment.Center

    self.Color3Box.ClearTextOnFocus = false
    self.Color3Box.Parent =
        self.InputFrame

    ------------------------------------------------------------
    -- HEX TEXTBOX
    ------------------------------------------------------------

    self.HexBox = Instance.new("TextBox")
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
            ELEMENT_HEIGHT + INPUT_GAP
        )

    self.HexBox.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background

    self.HexBox.BorderColor3 =
        theme.Border

    self.HexBox.BorderSizePixel = 1

    self.HexBox.TextColor3 =
        theme.Text

    self.HexBox.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER

    self.HexBox.PlaceholderText =
        "#FFFFFF"

    self.HexBox.TextSize = 13
    self.HexBox.Font =
        self.Window.CurrentFont

    self.HexBox.TextXAlignment =
        Enum.TextXAlignment.Center

    self.HexBox.TextYAlignment =
        Enum.TextYAlignment.Center

    self.HexBox.ClearTextOnFocus = false
    self.HexBox.Parent =
        self.InputFrame

    ------------------------------------------------------------
    -- SEPARATOR
    ------------------------------------------------------------

    self.Separator = Instance.new("Frame")
    self.Separator.Name =
        "Separator"

    self.Separator.Size =
        UDim2.new(
            0,
            1,
            1,
            0
        )

    self.Separator.Position =
        UDim2.new(
            WIDTH_SCALE,
            0,
            0,
            0
        )

    self.Separator.BackgroundColor3 =
        theme.Border

    self.Separator.BorderSizePixel = 0
    self.Separator.Parent =
        self.Body

    ------------------------------------------------------------
    -- RIGHT PREVIEW
    ------------------------------------------------------------

    self.PreviewFrame = Instance.new("Frame")
    self.PreviewFrame.Name =
        "PreviewFrame"

    self.PreviewFrame.Size =
        UDim2.new(
            WIDTH_SCALE,
            -4,
            0,
            ELEMENT_HEIGHT * 2 + INPUT_GAP
        )

    self.PreviewFrame.Position =
        UDim2.new(
            WIDTH_SCALE,
            4,
            0,
            0
        )

    self.PreviewFrame.BackgroundColor3 =
        self.Color

    self.PreviewFrame.BorderColor3 =
        theme.Border

    self.PreviewFrame.BorderSizePixel = 1
    self.PreviewFrame.Parent =
        self.Body

    ------------------------------------------------------------
    -- INITIAL VALUES
    ------------------------------------------------------------

    self:_UpdateTextBoxes()

    ------------------------------------------------------------
    -- COLOR3 INPUT
    ------------------------------------------------------------

    self.Color3Box.FocusLost:Connect(function()
        if self.Destroyed then
            return
        end

        local color =
            parseColor3(
                self.Color3Box.Text
            )

        if color then
            self:SetColor(
                color,
                true
            )
        else
            self:_UpdateColor3Text()
        end
    end)

    ------------------------------------------------------------
    -- HEX INPUT
    ------------------------------------------------------------

    self.HexBox.FocusLost:Connect(function()
        if self.Destroyed then
            return
        end

        local color =
            parseHex(
                self.HexBox.Text
            )

        if color then
            self:SetColor(
                color,
                true
            )
        else
            self:_UpdateHexText()
        end
    end)

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
-- UPDATE COLOR3 TEXT
------------------------------------------------------------

function ColorPreview:_UpdateColor3Text()
    self.Color3Box.Text =
        formatColor3(
            self.Color
        )
end

------------------------------------------------------------
-- UPDATE HEX TEXT
------------------------------------------------------------

function ColorPreview:_UpdateHexText()
    self.HexBox.Text =
        formatHex(
            self.Color
        )
end

------------------------------------------------------------
-- UPDATE BOTH TEXTBOXES
------------------------------------------------------------

function ColorPreview:_UpdateTextBoxes()
    self:_UpdateColor3Text()
    self:_UpdateHexText()
end

------------------------------------------------------------
-- SET COLOR
------------------------------------------------------------

function ColorPreview:SetColor(
    color,
    fromInput
)
    if self.Destroyed then
        return
    end

    if typeof(color) ~= "Color3" then
        return
    end

    self.Color =
        Color3.new(
            color.R,
            color.G,
            color.B
        )

    self.PreviewFrame.BackgroundColor3 =
        self.Color

    self:_UpdateTextBoxes()

    if not fromInput then
        task.spawn(function()
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
        end)
    else
        task.spawn(function()
            pcall(
                self.Callback,
                self.Color
            )
        end)
    end
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
        self.Title .. "_ColorPreview"

    self.TitleLabel.Text =
        self.Title
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
        theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text

    --------------------------------------------------------
    -- INPUTS
    --------------------------------------------------------

    local inputBackground =
        theme.ColorPickerInput
        or theme.Background

    local placeholder =
        theme.ColorPickerPlaceholder
        or DEFAULT_PLACEHOLDER

    self.Color3Box.BackgroundColor3 =
        inputBackground

    self.Color3Box.BorderColor3 =
        theme.Border

    self.Color3Box.TextColor3 =
        theme.Text

    self.Color3Box.PlaceholderColor3 =
        placeholder

    self.HexBox.BackgroundColor3 =
        inputBackground

    self.HexBox.BorderColor3 =
        theme.Border

    self.HexBox.TextColor3 =
        theme.Text

    self.HexBox.PlaceholderColor3 =
        placeholder

    --------------------------------------------------------
    -- SEPARATOR
    --------------------------------------------------------

    self.Separator.BackgroundColor3 =
        theme.Border

    --------------------------------------------------------
    -- PREVIEW
    --------------------------------------------------------

    self.PreviewFrame.BorderColor3 =
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
