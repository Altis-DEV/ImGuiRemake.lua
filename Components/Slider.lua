-- File: ImGuiRemake.lua/Components/Slider.lua

local Slider = {}
Slider.__index = Slider

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ROW_HEIGHT = 30
local SLIDER_WIDTH_SCALE = 0.25
local ELEMENT_GAP = 8

local function isPointerInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function roundToStep(value, minValue, step)
    if step <= 0 then
        return value
    end

    local steps = math.floor(
        ((value - minValue) / step) + 0.5
    )

    return minValue + steps * step
end

function Slider.new(tab, options)
    local self = setmetatable({}, Slider)

    options = options or {}

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(options.Title or "Slider")

    self.Min = tonumber(options.Min)
        or tonumber(options.Minimum)
        or 0

    self.Max = tonumber(options.Max)
        or tonumber(options.Maximum)
        or 100

    self.Step = tonumber(options.Step)
        or 1

    if self.Step <= 0 then
        self.Step = 1
    end

    if self.Max < self.Min then
        self.Min, self.Max =
            self.Max, self.Min
    end

    self.Value = tonumber(options.Value)

    if self.Value == nil then
        self.Value = self.Min
    end

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    self.Destroyed = false
    self.Dragging = false

    local theme = self.Window.ThemeData

    ----------------------------------------------------------------
    -- MAIN ROW
    ----------------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name =
        self.Title .. "_Slider"

    self.Container.Size =
        UDim2.new(1, -12, 0, ROW_HEIGHT)

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Tab.ContentFrame

    ----------------------------------------------------------------
    -- SLIDER FRAME
    ----------------------------------------------------------------

    self.SliderFrame = Instance.new("TextButton")
    self.SliderFrame.Name = "SliderFrame"

    self.SliderFrame.Size =
        UDim2.new(
            SLIDER_WIDTH_SCALE,
            0,
            1,
            0
        )

    self.SliderFrame.Position =
        UDim2.new(0, 0, 0, 0)

    self.SliderFrame.BackgroundColor3 =
        theme.SliderFrame
        or theme.Border
        or Color3.fromRGB(38, 38, 38)

    self.SliderFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.SliderFrame.BorderSizePixel = 1

    self.SliderFrame.Text = ""
    self.SliderFrame.AutoButtonColor = false

    self.SliderFrame.ClipsDescendants = true
    self.SliderFrame.Parent = self.Container

    ----------------------------------------------------------------
    -- SLIDER BAR
    ----------------------------------------------------------------

    self.SliderBar = Instance.new("Frame")
    self.SliderBar.Name = "SliderBar"

    self.SliderBar.Size =
        UDim2.new(0, 0, 1, 0)

    self.SliderBar.Position =
        UDim2.new(0, 0, 0, 0)

    self.SliderBar.BackgroundColor3 =
        theme.SliderBar
        or theme.Accent

    self.SliderBar.BorderSizePixel = 0

    self.SliderBar.ZIndex = 1
    self.SliderBar.Parent = self.SliderFrame

    ----------------------------------------------------------------
    -- VALUE TEXT
    ----------------------------------------------------------------

    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "Value"

    self.ValueLabel.Size =
        UDim2.new(1, 0, 1, 0)

    self.ValueLabel.Position =
        UDim2.new(0, 0, 0, 0)

    self.ValueLabel.BackgroundTransparency = 1

    self.ValueLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.ValueLabel.TextSize = 13
    self.ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    self.ValueLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.ValueLabel.ZIndex = 2
    self.ValueLabel.Parent = self.SliderFrame

    ----------------------------------------------------------------
    -- TITLE
    ----------------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1 - SLIDER_WIDTH_SCALE,
            -ELEMENT_GAP,
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            SLIDER_WIDTH_SCALE,
            ELEMENT_GAP,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.TitleLabel.TextSize = 13

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.Container

    ----------------------------------------------------------------
    -- FONT
    ----------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    ----------------------------------------------------------------
    -- INITIAL VALUE
    ----------------------------------------------------------------

    self:SetValue(
        self.Value,
        false
    )

    ----------------------------------------------------------------
    -- INPUT
    ----------------------------------------------------------------

    self.SliderFrame.MouseButton1Click:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:_SetFromPointer()
        end
    )

    self.SliderFrame.InputBegan:Connect(
        function(input)
            if self.Destroyed then
                return
            end

            if not isPointerInput(input) then
                return
            end

            self.Dragging = true

            self:_SetFromPointer()
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if self.Destroyed then
                return
            end

            if not self.Dragging then
                return
            end

            if input.UserInputType
                ~= Enum.UserInputType.MouseMovement
                and input.UserInputType
                ~= Enum.UserInputType.Touch then

                return
            end

            self:_SetFromPointer()
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType
                == Enum.UserInputType.MouseButton1
                or input.UserInputType
                == Enum.UserInputType.Touch then

                self.Dragging = false
            end
        end
    )

    ----------------------------------------------------------------
    -- REGISTER
    ----------------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

----------------------------------------------------------------
-- POINTER -> VALUE
----------------------------------------------------------------

function Slider:_SetFromPointer()
    if self.Destroyed then
        return
    end

    local absolutePosition =
        self.SliderFrame.AbsolutePosition

    local absoluteSize =
        self.SliderFrame.AbsoluteSize

    local mousePosition =
        UserInputService:GetMouseLocation()

    local relativeX =
        mousePosition.X
        - absolutePosition.X

    local percentage =
        math.clamp(
            relativeX / absoluteSize.X,
            0,
            1
        )

    local rawValue =
        self.Min
        + (
            self.Max - self.Min
        ) * percentage

    self:SetValue(
        rawValue
    )
end

----------------------------------------------------------------
-- VALUE
----------------------------------------------------------------

function Slider:SetValue(
    newValue,
    fireCallback
)
    if self.Destroyed then
        return self.Value
    end

    newValue = tonumber(newValue)

    if not newValue then
        return self.Value
    end

    newValue =
        math.clamp(
            newValue,
            self.Min,
            self.Max
        )

    newValue =
        roundToStep(
            newValue,
            self.Min,
            self.Step
        )

    newValue =
        math.clamp(
            newValue,
            self.Min,
            self.Max
        )

    local changed =
        self.Value ~= newValue

    self.Value =
        newValue

    local percentage

    if self.Max == self.Min then
        percentage = 0
    else
        percentage =
            (self.Value - self.Min)
            / (self.Max - self.Min)
    end

    percentage =
        math.clamp(
            percentage,
            0,
            1
        )

    ----------------------------------------------------------------
    -- UPDATE BAR
    ----------------------------------------------------------------

    TweenService:Create(
        self.SliderBar,
        TweenInfo.new(
            0.08,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size =
                UDim2.new(
                    percentage,
                    0,
                    1,
                    0
                )
        }
    ):Play()

    ----------------------------------------------------------------
    -- UPDATE TEXT
    ----------------------------------------------------------------

    self.ValueLabel.Text =
        self:_FormatValue(
            self.Value
        )

    if changed
        and fireCallback ~= false then

        task.spawn(function()
            local ok, err = pcall(
                self.Callback,
                self.Value
            )

            if not ok then
                warn(
                    "Slider callback error:",
                    err
                )
            end
        end)
    end

    return self.Value
end

----------------------------------------------------------------
-- FORMAT VALUE
----------------------------------------------------------------

function Slider:_FormatValue(value)
    if self.Step >= 1 then
        return tostring(
            math.floor(
                value + 0.5
            )
        )
    end

    local decimals = 0
    local step = self.Step

    while step < 1
        and decimals < 6 do

        step *= 10
        decimals += 1
    end

    return string.format(
        "%." .. decimals .. "f",
        value
    )
end

----------------------------------------------------------------
-- TITLE
----------------------------------------------------------------

function Slider:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title .. "_Slider"

    self.TitleLabel.Text =
        self.Title
end

----------------------------------------------------------------
-- MIN
----------------------------------------------------------------

function Slider:SetMin(newMin)
    if self.Destroyed then
        return self.Min
    end

    newMin = tonumber(newMin)

    if not newMin then
        return self.Min
    end

    self.Min = newMin

    if self.Max < self.Min then
        self.Max = self.Min
    end

    self:SetValue(
        self.Value
    )

    return self.Min
end

----------------------------------------------------------------
-- MAX
----------------------------------------------------------------

function Slider:SetMax(newMax)
    if self.Destroyed then
        return self.Max
    end

    newMax = tonumber(newMax)

    if not newMax then
        return self.Max
    end

    self.Max = newMax

    if self.Min > self.Max then
        self.Min = self.Max
    end

    self:SetValue(
        self.Value
    )

    return self.Max
end

----------------------------------------------------------------
-- FONT
----------------------------------------------------------------

function Slider:SetFont(fontType)
    if self.Destroyed then
        return
    end

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
            self.TitleLabel.FontFace =
                customFont

            self.ValueLabel.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.TitleLabel.Font =
            fontType

        self.ValueLabel.Font =
            fontType
    end
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

function Slider:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    self.SliderFrame.BackgroundColor3 =
        theme.SliderFrame
        or theme.Border
        or Color3.fromRGB(38, 38, 38)

    self.SliderFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.SliderBar.BackgroundColor3 =
        theme.SliderBar
        or theme.Accent
        or Color3.fromRGB(40, 90, 175)

    self.ValueLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.TitleLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self:SetFont(
        self.Window.CurrentFont
    )
end

----------------------------------------------------------------
-- DESTROY
----------------------------------------------------------------

function Slider:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true
    self.Dragging = false

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

return Slider
