-- File: ImGuiRemake.lua/Components/ColorPreview.lua

local ColorPreview = {}
ColorPreview.__index = ColorPreview

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local ROW_HEIGHT = 30
local PREVIEW_WIDTH = 0.5

local PADDING = 6
local GAP = 6

local DEFAULT_TEXT_SIZE = 13
local DEFAULT_PLACEHOLDER =
    Color3.fromRGB(150, 150, 150)

local DEFAULT_BACKGROUND =
    Color3.fromRGB(30, 30, 30)

local DEFAULT_COLOR =
    Color3.fromRGB(255, 255, 255)

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

local function clamp255(value)
    return math.clamp(
        math.floor(
            tonumber(value) or 0
            + 0.5
        ),
        0,
        255
    )
end

local function color3ToHex(color)
    local r = math.floor(color.R * 255 + 0.5)
    local g = math.floor(color.G * 255 + 0.5)
    local b = math.floor(color.B * 255 + 0.5)

    return string.format(
        "#%02X%02X%02X",
        r,
        g,
        b
    )
end

local function color3ToString(color)
    return string.format(
        "%.3f, %.3f, %.3f",
        color.R,
        color.G,
        color.B
    )
end

local function parseHex(text)
    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("%s+", "")
    text = text:upper()

    if text:sub(1, 1) ~= "#" then
        text = "#" .. text
    end

    --------------------------------------------------------
    -- #RRGGBB
    --------------------------------------------------------

    if text:match("^#%x%x%x%x%x%x$") then
        local hex = text:sub(2)

        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)

        return Color3.fromRGB(r, g, b)
    end

    --------------------------------------------------------
    -- #RGB
    --------------------------------------------------------

    if text:match("^#%x%x%x$") then
        local hex = text:sub(2)

        local r = tonumber(
            hex:sub(1, 1) .. hex:sub(1, 1),
            16
        )

        local g = tonumber(
            hex:sub(2, 2) .. hex:sub(2, 2),
            16
        )

        local b = tonumber(
            hex:sub(3, 3) .. hex:sub(3, 3),
            16
        )

        return Color3.fromRGB(r, g, b)
    end

    return nil
end

local function parseColor3(text)
    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("%s+", "")

    --------------------------------------------------------
    -- Supported:
    -- 1,0.5,0
    -- 1, 0.5, 0
    --------------------------------------------------------

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

    return Color3.new(
        math.clamp(r, 0, 1),
        math.clamp(g, 0, 1),
        math.clamp(b, 0, 1)
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

    --------------------------------------------------------
    -- MAIN CONTAINER
    --------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name =
        self.Title .. "_ColorPreview"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT + 2 * ROW_HEIGHT + GAP + 12
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent =
        self.Tab.ContentFrame

    --------------------------------------------------------
    -- TITLE FRAME
    --------------------------------------------------------

    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Name =
        "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        )

    self.TitleFrame.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleFrame.BorderSizePixel = 1
    self.TitleFrame.Parent =
        self.Container

    --------------------------------------------------------
    -- TITLE LABEL
    --------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -(PADDING * 2),
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            0,
            PADDING,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.RichText = true

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize =
        DEFAULT_TEXT_SIZE

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.TitleFrame

    --------------------------------------------------------
    -- BODY
    --------------------------------------------------------

    self.Body = Instance.new("Frame")
    self.Body.Name = "Body"

    self.Body.Size =
        UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT * 2 + GAP
        )

    self.Body.Position =
        UDim2.new(
            0,
            0,
            0,
            ROW_HEIGHT
        )

    self.Body.BackgroundTransparency = 1
    self.Body.BorderSizePixel = 0
    self.Body.Parent =
        self.Container

    --------------------------------------------------------
    -- PREVIEW FRAME
    --------------------------------------------------------

    self.PreviewFrame = Instance.new("Frame")
    self.PreviewFrame.Name =
        "PreviewFrame"

    self.PreviewFrame.Size =
        UDim2.new(
            PREVIEW_WIDTH,
            -GAP / 2,
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

    self.PreviewFrame.BorderSizePixel = 1
    self.PreviewFrame.Parent =
        self.Body

    --------------------------------------------------------
    -- RIGHT SIDE PANEL
    --------------------------------------------------------

    self.InputPanel = Instance.new("Frame")
    self.InputPanel.Name =
        "InputPanel"

    self.InputPanel.Size =
        UDim2.new(
            PREVIEW_WIDTH,
            -GAP / 2,
            1,
            0
        )

    self.InputPanel.Position =
        UDim2.new(
            PREVIEW_WIDTH,
            GAP / 2,
            0,
            0
        )

    self.InputPanel.BackgroundTransparency = 1
    self.InputPanel.BorderSizePixel = 0
    self.InputPanel.Parent =
        self.Body

    --------------------------------------------------------
    -- COLOR3 INPUT
    --------------------------------------------------------

    self.Color3Box = Instance.new("TextBox")
    self.Color3Box.Name =
        "Color3"

    self.Color3Box.Size =
        UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        )

    self.Color3Box.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.Color3Box.BackgroundColor3 =
        theme.TextBoxFrame
        or DEFAULT_BACKGROUND

    self.Color3Box.BorderColor3 =
        theme.Border

    self.Color3Box.BorderSizePixel = 1

    self.Color3Box.Text =
        color3ToString(self.Color)

    self.Color3Box.PlaceholderText =
        "1, 0.5, 0"

    self.Color3Box.PlaceholderColor3 =
        theme.TextBoxText
        or DEFAULT_PLACEHOLDER

    self.Color3Box.TextColor3 =
        theme.Text

    self.Color3Box.TextSize =
        DEFAULT_TEXT_SIZE

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

    --------------------------------------------------------
    -- SEPARATOR
    --------------------------------------------------------

    self.Separator = Instance.new("Frame")
    self.Separator.Name =
        "Separator"

    self.Separator.Size =
        UDim2.new(
            1,
            0,
            0,
            1
        )

    self.Separator.Position =
        UDim2.new(
            0,
            0,
            0,
            ROW_HEIGHT
        )

    self.Separator.BackgroundColor3 =
        theme.Border

    self.Separator.BorderSizePixel = 0
    self.Separator.Parent =
        self.InputPanel

    --------------------------------------------------------
    -- HEX INPUT
    --------------------------------------------------------

    self.HexBox = Instance.new("TextBox")
    self.HexBox.Name =
        "Hex"

    self.HexBox.Size =
        UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        )

    self.HexBox.Position =
        UDim2.new(
            0,
            0,
            0,
            ROW_HEIGHT + GAP
        )

    self.HexBox.BackgroundColor3 =
        theme.TextBoxFrame
        or DEFAULT_BACKGROUND

    self.HexBox.BorderColor3 =
        theme.Border

    self.HexBox.BorderSizePixel = 1

    self.HexBox.Text =
        color3ToHex(self.Color)

    self.HexBox.PlaceholderText =
        "#FFFFFF"

    self.HexBox.PlaceholderColor3 =
        theme.TextBoxText
        or DEFAULT_PLACEHOLDER

    self.HexBox.TextColor3 =
        theme.Text

    self.HexBox.TextSize =
        DEFAULT_TEXT_SIZE

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

    --------------------------------------------------------
    -- COLOR3 INPUT LOGIC
    --------------------------------------------------------

    self.Color3Box.FocusLost:Connect(
        function()
            if self.Destroyed then
                return
            end

            local color =
                parseColor3(
                    self.Color3Box.Text
                )

            if color then
                self:SetColor(color)
            else
                self:_SyncInputs()
            end
        end
    )

    --------------------------------------------------------
    -- HEX INPUT LOGIC
    --------------------------------------------------------

    self.HexBox.FocusLost:Connect(
        function()
            if self.Destroyed then
                return
            end

            local color =
                parseHex(
                    self.HexBox.Text
                )

            if color then
                self:SetColor(color)
            else
                self:_SyncInputs()
            end
        end
    )

    --------------------------------------------------------
    -- REGISTER
    --------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- SYNC INPUTS
------------------------------------------------------------

function ColorPreview:_SyncInputs()
    if self.Destroyed then
        return
    end

    self.Color3Box.Text =
        color3ToString(
            self.Color
        )

    self.HexBox.Text =
        color3ToHex(
            self.Color
        )
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

    self.PreviewFrame.BackgroundColor3 =
        self.Color

    self:_SyncInputs()

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
        self.Title .. "_ColorPreview"

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
        or DEFAULT_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text

    --------------------------------------------------------
    -- PREVIEW
    --------------------------------------------------------

    self.PreviewFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- COLOR3 INPUT
    --------------------------------------------------------

    self.Color3Box.BackgroundColor3 =
        theme.TextBoxFrame
        or DEFAULT_BACKGROUND

    self.Color3Box.BorderColor3 =
        theme.Border

    self.Color3Box.TextColor3 =
        theme.Text

    self.Color3Box.PlaceholderColor3 =
        theme.TextBoxText
        or DEFAULT_PLACEHOLDER

    --------------------------------------------------------
    -- SEPARATOR
    --------------------------------------------------------

    self.Separator.BackgroundColor3 =
        theme.Border

    --------------------------------------------------------
    -- HEX INPUT
    --------------------------------------------------------

    self.HexBox.BackgroundColor3 =
        theme.TextBoxFrame
        or DEFAULT_BACKGROUND

    self.HexBox.BorderColor3 =
        theme.Border

    self.HexBox.TextColor3 =
        theme.Text

    self.HexBox.PlaceholderColor3 =
        theme.TextBoxText
        or DEFAULT_PLACEHOLDER

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
