-- File: ImGuiRemake.lua/Components/ColorPicker.lua

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local UserInputService = game:GetService("UserInputService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local ELEMENT_HEIGHT = 30
local WIDTH_SCALE = 0.5

local SLIDER_HEIGHT = 30
local PREVIEW_HEIGHT = SLIDER_HEIGHT * 2
local INPUT_HEIGHT = SLIDER_HEIGHT

local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255)

------------------------------------------------------------
-- UTILITY
------------------------------------------------------------

local function clamp(value, minValue, maxValue)
    return math.clamp(value, minValue, maxValue)
end

local function round(value)
    return math.floor(value + 0.5)
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function ColorPicker.new(tab, options)

    options = options or {}

    local self = setmetatable({}, ColorPicker)

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(options.Title or "Color Picker")
    self.Color = options.Color or DEFAULT_COLOR

    self.Destroyed = false

    --------------------------------------------------------
    -- CALLBACK
    --------------------------------------------------------

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    --------------------------------------------------------
    -- INITIAL RGB
    --------------------------------------------------------

    local r, g, b = self.Color.R, self.Color.G, self.Color.B

    self.RedValue = round(r * 255)
    self.GreenValue = round(g * 255)
    self.BlueValue = round(b * 255)

    --------------------------------------------------------
    -- MAIN CONTAINER
    --------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name = self.Title .. "_ColorPicker"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            PREVIEW_HEIGHT + INPUT_HEIGHT + 12
        )

    self.Container.AutomaticSize = Enum.AutomaticSize.Y
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Tab.ContentFrame

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title

    self.TitleLabel.TextColor3 =
        self.Window.ThemeData.Text
        or Color3.fromRGB(255, 255, 255)

    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent = self.Container

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"

    self.Content.Size =
        UDim2.new(
            1,
            0,
            0,
            PREVIEW_HEIGHT + INPUT_HEIGHT + 6
        )

    self.Content.BackgroundTransparency = 1
    self.Content.BorderSizePixel = 0
    self.Content.Parent = self.Container

    --------------------------------------------------------
    -- RGB AREA
    --------------------------------------------------------

    self.RGBFrame = Instance.new("Frame")
    self.RGBFrame.Name = "RGB"

    self.RGBFrame.Size =
        UDim2.new(
            WIDTH_SCALE,
            -6,
            0,
            PREVIEW_HEIGHT
        )

    self.RGBFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.RGBFrame.BackgroundTransparency = 1
    self.RGBFrame.BorderSizePixel = 0
    self.RGBFrame.Parent = self.Content

    --------------------------------------------------------
    -- PREVIEW AREA
    --------------------------------------------------------

    self.Preview = Instance.new("Frame")
    self.Preview.Name = "Preview"

    self.Preview.Size =
        UDim2.new(
            WIDTH_SCALE,
            -6,
            0,
            PREVIEW_HEIGHT
        )

    self.Preview.Position =
        UDim2.new(
            WIDTH_SCALE,
            6,
            0,
            0
        )

    self.Preview.BackgroundColor3 = self.Color

    self.Preview.BorderColor3 =
        self.Window.ThemeData.Border
        or Color3.fromRGB(60, 60, 60)

    self.Preview.BorderSizePixel = 1
    self.Preview.Parent = self.Content

    --------------------------------------------------------
    -- HEX INPUT
    --------------------------------------------------------

    self.HexBox = Instance.new("TextBox")
    self.HexBox.Name = "ColorInput"

    self.HexBox.Size =
        UDim2.new(
            WIDTH_SCALE,
            -6,
            0,
            INPUT_HEIGHT
        )

    self.HexBox.Position =
        UDim2.new(
            WIDTH_SCALE,
            6,
            0,
            PREVIEW_HEIGHT + 6
        )

    self.HexBox.BackgroundColor3 =
        self.Window.ThemeData.ColorPickerInput
        or self.Window.ThemeData.Background
        or Color3.fromRGB(30, 30, 30)

    self.HexBox.BorderColor3 =
        self.Window.ThemeData.Border
        or Color3.fromRGB(60, 60, 60)

    self.HexBox.BorderSizePixel = 1

    self.HexBox.TextColor3 =
        self.Window.ThemeData.Text
        or Color3.fromRGB(255, 255, 255)

    self.HexBox.PlaceholderColor3 =
        self.Window.ThemeData.ColorPickerPlaceholder
        or Color3.fromRGB(150, 150, 150)

    self.HexBox.TextSize = 13
    self.HexBox.Font = self.Window.CurrentFont

    self.HexBox.TextXAlignment =
        Enum.TextXAlignment.Center

    self.HexBox.TextYAlignment =
        Enum.TextYAlignment.Center

    self.HexBox.ClearTextOnFocus = false
    self.HexBox.PlaceholderText = "#FFFFFF"

    self.HexBox.Parent = self.Content

    --------------------------------------------------------
    -- CREATE RGB SLIDERS
    --------------------------------------------------------

    self.RedSlider =
        self:_CreateSlider(
            "R",
            0,
            self.RedValue,
            Color3.fromRGB(255, 80, 80)
        )

    self.GreenSlider =
        self:_CreateSlider(
            "G",
            SLIDER_HEIGHT,
            self.GreenValue,
            Color3.fromRGB(80, 255, 80)
        )

    self.BlueSlider =
        self:_CreateSlider(
            "B",
            SLIDER_HEIGHT * 2,
            self.BlueValue,
            Color3.fromRGB(80, 140, 255)
        )

    --------------------------------------------------------
    -- INITIAL TEXT
    --------------------------------------------------------

    self:_UpdateHex()
    self:_UpdatePreview()

    --------------------------------------------------------
    -- HEX INPUT
    --------------------------------------------------------

    self.HexBox.FocusLost:Connect(function()
        if self.Destroyed then
            return
        end

        self:_ApplyHex(self.HexBox.Text)
    end)

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
-- CREATE RGB SLIDER
------------------------------------------------------------

function ColorPicker:_CreateSlider(
    name,
    y,
    initialValue,
    fillColor
)

    local slider = {}

    slider.Value = initialValue or 0
    slider.Min = 0
    slider.Max = 255

    --------------------------------------------------------
    -- FRAME
    --------------------------------------------------------

    slider.Frame = Instance.new("Frame")
    slider.Frame.Name = name .. "Slider"

    slider.Frame.Size =
        UDim2.new(
            1,
            0,
            0,
            SLIDER_HEIGHT
        )

    slider.Frame.Position =
        UDim2.new(
            0,
            0,
            0,
            y
        )

    slider.Frame.BackgroundColor3 =
        self.Window.ThemeData.ColorPickerSlider
        or self.Window.ThemeData.Border
        or Color3.fromRGB(60, 60, 60)

    slider.Frame.BorderColor3 =
        self.Window.ThemeData.Border
        or Color3.fromRGB(60, 60, 60)

    slider.Frame.BorderSizePixel = 1
    slider.Frame.Parent = self.RGBFrame

    --------------------------------------------------------
    -- LABEL
    --------------------------------------------------------

    slider.Label = Instance.new("TextLabel")
    slider.Label.Name = "Label"

    slider.Label.Size =
        UDim2.new(
            0,
            25,
            1,
            0
        )

    slider.Label.BackgroundTransparency = 1
    slider.Label.Text = name

    slider.Label.TextColor3 =
        self.Window.ThemeData.Text
        or Color3.fromRGB(255, 255, 255)

    slider.Label.TextSize = 13
    slider.Label.Font = self.Window.CurrentFont

    slider.Label.TextXAlignment =
        Enum.TextXAlignment.Center

    slider.Label.TextYAlignment =
        Enum.TextYAlignment.Center

    slider.Label.ZIndex = 3
    slider.Label.Parent = slider.Frame

    --------------------------------------------------------
    -- BAR
    --------------------------------------------------------

    slider.Bar = Instance.new("Frame")
    slider.Bar.Name = "Bar"

    slider.Bar.Size =
        UDim2.new(
            1,
            -55,
            0,
            6
        )

    slider.Bar.Position =
        UDim2.new(
            0,
            32,
            0.5,
            -3
        )

    slider.Bar.BackgroundColor3 =
        self.Window.ThemeData.ColorPickerBar
        or Color3.fromRGB(100, 100, 100)

    slider.Bar.BorderSizePixel = 0
    slider.Bar.Parent = slider.Frame

    --------------------------------------------------------
    -- FILL
    --------------------------------------------------------

    slider.Fill = Instance.new("Frame")
    slider.Fill.Name = "Fill"

    slider.Fill.Size =
        UDim2.new(
            initialValue / 255,
            0,
            1,
            0
        )

    slider.Fill.BackgroundColor3 = fillColor
    slider.Fill.BorderSizePixel = 0
    slider.Fill.Parent = slider.Bar

    --------------------------------------------------------
    -- VALUE
    --------------------------------------------------------

    slider.ValueLabel = Instance.new("TextLabel")
    slider.ValueLabel.Name = "Value"

    slider.ValueLabel.Size =
        UDim2.new(
            0,
            40,
            1,
            0
        )

    slider.ValueLabel.Position =
        UDim2.new(
            1,
            -45,
            0,
            0
        )

    slider.ValueLabel.BackgroundTransparency = 1
    slider.ValueLabel.Text = tostring(initialValue)

    slider.ValueLabel.TextColor3 =
        self.Window.ThemeData.Text
        or Color3.fromRGB(255, 255, 255)

    slider.ValueLabel.TextSize = 13
    slider.ValueLabel.Font = self.Window.CurrentFont

    slider.ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    slider.ValueLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    slider.ValueLabel.ZIndex = 3
    slider.ValueLabel.Parent = slider.Frame

    --------------------------------------------------------
    -- INTERACTION
    --------------------------------------------------------

    slider.Interact = Instance.new("TextButton")

    slider.Interact.Name = "Interact"
    slider.Interact.Size = UDim2.new(1, 0, 1, 0)

    slider.Interact.BackgroundTransparency = 1
    slider.Interact.Text = ""
    slider.Interact.AutoButtonColor = false
    slider.Interact.ZIndex = 5
    slider.Interact.Parent = slider.Frame

    --------------------------------------------------------
    -- SET VALUE
    --------------------------------------------------------

    function slider:SetValue(value)

        value = tonumber(value) or 0
        value = clamp(
            round(value),
            0,
            255
        )

        self.Value = value

        self.Fill.Size =
            UDim2.new(
                value / 255,
                0,
                1,
                0
            )

        self.ValueLabel.Text =
            tostring(value)
    end

    --------------------------------------------------------
    -- GET VALUE FROM INPUT
    --------------------------------------------------------

    local function updateFromInput(input)

        local absolutePosition =
            slider.Bar.AbsolutePosition

        local absoluteSize =
            slider.Bar.AbsoluteSize

        local x =
            input.Position.X
            - absolutePosition.X

        local percent =
            clamp(
                x / absoluteSize.X,
                0,
                1
            )

        slider:SetValue(
            round(percent * 255)
        )

        self:_RGBChanged()
    end

    --------------------------------------------------------
    -- MOUSE / TOUCH
    --------------------------------------------------------

    local dragging = false

    slider.Interact.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = true
            updateFromInput(input)

        end
    end)

    slider.Interact.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = false

        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            updateFromInput(input)

        end
    end)

    return slider
end

------------------------------------------------------------
-- RGB CHANGED
------------------------------------------------------------

function ColorPicker:_RGBChanged()

    if self.Destroyed then
        return
    end

    self.RedValue =
        self.RedSlider.Value

    self.GreenValue =
        self.GreenSlider.Value

    self.BlueValue =
        self.BlueSlider.Value

    self.Color =
        Color3.fromRGB(
            self.RedValue,
            self.GreenValue,
            self.BlueValue
        )

    self:_UpdatePreview()
    self:_UpdateHex()

    task.spawn(function()

        pcall(
            self.Callback,
            self.Color
        )

    end)
end

------------------------------------------------------------
-- UPDATE PREVIEW
------------------------------------------------------------

function ColorPicker:_UpdatePreview()

    self.Preview.BackgroundColor3 =
        self.Color
end

------------------------------------------------------------
-- UPDATE HEX
------------------------------------------------------------

function ColorPicker:_UpdateHex()

    local hex =
        string.format(
            "#%02X%02X%02X",
            self.RedValue,
            self.GreenValue,
            self.BlueValue
        )

    self.HexBox.Text = hex
end

------------------------------------------------------------
-- APPLY HEX
------------------------------------------------------------

function ColorPicker:_ApplyHex(text)

    if type(text) ~= "string" then
        return false
    end

    text =
        string.gsub(
            text,
            "%s+",
            ""
        )

    text =
        string.upper(text)

    if string.sub(text, 1, 1) ~= "#" then
        text = "#" .. text
    end

    --------------------------------------------------------
    -- #RRGGBB
    --------------------------------------------------------

    if string.match(
        text,
        "^#%x%x%x%x%x%x$"
    ) then

        local hex =
            string.sub(text, 2)

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

        self.RedSlider:SetValue(r)
        self.GreenSlider:SetValue(g)
        self.BlueSlider:SetValue(b)

        self:_RGBChanged()

        return true
    end

    --------------------------------------------------------
    -- #RGB
    --------------------------------------------------------

    if string.match(
        text,
        "^#%x%x%x$"
    ) then

        local hex =
            string.sub(text, 2)

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

        self.RedSlider:SetValue(r)
        self.GreenSlider:SetValue(g)
        self.BlueSlider:SetValue(b)

        self:_RGBChanged()

        return true
    end

    --------------------------------------------------------
    -- INVALID
    --------------------------------------------------------

    self:_UpdateHex()

    return false
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function ColorPicker:SetTitle(newTitle)

    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title .. "_ColorPicker"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET COLOR
------------------------------------------------------------

function ColorPicker:SetColor(color)

    if self.Destroyed then
        return
    end

    if typeof(color) ~= "Color3" then
        return
    end

    self.Color = color

    local r, g, b =
        color.R,
        color.G,
        color.B

    self.RedSlider:SetValue(
        round(r * 255)
    )

    self.GreenSlider:SetValue(
        round(g * 255)
    )

    self.BlueSlider:SetValue(
        round(b * 255)
    )

    self.RedValue =
        self.RedSlider.Value

    self.GreenValue =
        self.GreenSlider.Value

    self.BlueValue =
        self.BlueSlider.Value

    self:_UpdatePreview()
    self:_UpdateHex()

    task.spawn(function()

        pcall(
            self.Callback,
            self.Color
        )

    end)
end

------------------------------------------------------------
-- GET COLOR
------------------------------------------------------------

function ColorPicker:GetColor()

    return self.Color

end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function ColorPicker:SetFont(fontType)

    if self.Destroyed then
        return
    end

    self.Window.CurrentFont =
        fontType

    local instances = {
        self.TitleLabel,
        self.HexBox,

        self.RedSlider.Label,
        self.RedSlider.ValueLabel,

        self.GreenSlider.Label,
        self.GreenSlider.ValueLabel,

        self.BlueSlider.Label,
        self.BlueSlider.ValueLabel,
    }

    for _, instance in ipairs(instances) do

        if typeof(fontType) == "EnumItem"
            and fontType.EnumType == Enum.Font then

            instance.Font = fontType

        elseif typeof(fontType) == "string"
            and string.find(
                string.lower(fontType),
                "rbxassetid",
                1,
                true
            ) then

            local ok, fontFace =
                pcall(function()
                    return Font.new(fontType)
                end)

            if ok and fontFace then
                instance.FontFace = fontFace
            end

        end

    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function ColorPicker:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    --------------------------------------------------------
    -- PREVIEW
    --------------------------------------------------------

    self.Preview.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    --------------------------------------------------------
    -- HEX INPUT
    --------------------------------------------------------

    self.HexBox.BackgroundColor3 =
        theme.ColorPickerInput
        or theme.Background
        or Color3.fromRGB(30, 30, 30)

    self.HexBox.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.HexBox.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.HexBox.PlaceholderColor3 =
        theme.ColorPickerPlaceholder
        or Color3.fromRGB(150, 150, 150)

    --------------------------------------------------------
    -- SLIDERS
    --------------------------------------------------------

    local sliders = {
        self.RedSlider,
        self.GreenSlider,
        self.BlueSlider
    }

    for _, slider in ipairs(sliders) do

        slider.Frame.BackgroundColor3 =
            theme.ColorPickerSlider
            or theme.Border
            or Color3.fromRGB(60, 60, 60)

        slider.Frame.BorderColor3 =
            theme.Border
            or Color3.fromRGB(60, 60, 60)

        slider.Bar.BackgroundColor3 =
            theme.ColorPickerBar
            or Color3.fromRGB(100, 100, 100)

        slider.Label.TextColor3 =
            theme.Text
            or Color3.fromRGB(255, 255, 255)

        slider.ValueLabel.TextColor3 =
            theme.Text
            or Color3.fromRGB(255, 255, 255)

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

function ColorPicker:Destroy()

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

return ColorPicker
