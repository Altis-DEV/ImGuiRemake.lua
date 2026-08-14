-- File: ImGuiRemake.lua/Components/Toggle.lua

local TweenService = game:GetService("TweenService")

local Toggle = {}
Toggle.__index = Toggle

local CHECKBOX_SIZE = 30
local ROW_HEIGHT = 30
local TITLE_SIZE = 13

function Toggle.new(tab, options)
    local self = setmetatable({}, Toggle)

    options = options or {}

    self.Tab = tab
    self.Window = tab.Window
    self.WidthAtRow = options.WidthAtRow

    self.Title = tostring(options.Title or "Toggle")
    self.StateValue = options.State == true

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    self.Destroyed = false

    local theme = self.Window.ThemeData

    ----------------------------------------------------------------
    -- ROW / INTERACTION BUTTON
    ----------------------------------------------------------------

    -- Chính Container là TextButton.
    -- Nhờ vậy UIListLayout của ContentFrame xử lý nó như một element
    -- bình thường và không có InteractBtn thứ ba đẩy layout sang phải.

    self.Container = Instance.new("TextButton")
    self.Container.Name = self.Title .. "_Toggle"
    self.Container.Size = UDim2.new(1, -12, 0, ROW_HEIGHT)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Text = ""
    self.Container.AutoButtonColor = false
    self.Container.LayoutOrder = 0
    self.Container.Parent = self.Tab.ContentFrame

    ----------------------------------------------------------------
    -- HORIZONTAL LAYOUT
    ----------------------------------------------------------------

    local layout = Instance.new("UIListLayout")
    layout.Name = "ToggleLayout"
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.Container

    ----------------------------------------------------------------
    -- CHECKBOX
    ----------------------------------------------------------------

    self.CheckboxOuter = Instance.new("Frame")
    self.CheckboxOuter.Name = "Checkbox"
    self.CheckboxOuter.Size =
        UDim2.new(0, CHECKBOX_SIZE, 0, CHECKBOX_SIZE)

    self.CheckboxOuter.BackgroundColor3 =
        theme.Background

    self.CheckboxOuter.BorderColor3 =
        theme.Border

    self.CheckboxOuter.BorderSizePixel = 1
    self.CheckboxOuter.LayoutOrder = 1
    self.CheckboxOuter.Parent = self.Container

    ----------------------------------------------------------------
    -- INNER CHECKBOX
    ----------------------------------------------------------------

    -- INNER CHECKBOX
self.InnerBox = Instance.new("Frame")
self.InnerBox.Name = "Inner"

self.InnerBox.Size =
    self.StateValue
    and UDim2.new(1, 0, 1, 0)
    or UDim2.new(0, 0, 0, 0)

self.InnerBox.AnchorPoint = Vector2.new(0.5, 0.5)
self.InnerBox.Position = UDim2.new(0.5, 0, 0.5, 0)

self.InnerBox.BackgroundColor3 =
    theme.Checkbox or theme.Accent

self.InnerBox.BorderSizePixel = 0
self.InnerBox.Parent = self.CheckboxOuter
    ----------------------------------------------------------------
    -- TITLE
    ----------------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    self.TitleLabel.Size =
        UDim2.new(1, -(CHECKBOX_SIZE + 8), 1, 0)

    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextSize =
        TITLE_SIZE

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.LayoutOrder = 2
    self.TitleLabel.Parent = self.Container

    ----------------------------------------------------------------
    -- CLICK
    ----------------------------------------------------------------

    self.Container.MouseButton1Click:Connect(function()
        if self.Destroyed then
            return
        end

        self:State(not self.StateValue)
    end)

    ----------------------------------------------------------------
    -- REGISTER
    ----------------------------------------------------------------

    table.insert(self.Tab.Elements, self)

    return self
end

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
function Toggle:State(newState)
    if self.Destroyed then
        return self.StateValue
    end

    if type(newState) ~= "boolean" then
        return self.StateValue
    end

    self.StateValue = newState

    local targetSize =
        self.StateValue
        and UDim2.new(1, 0, 1, 0)
        or UDim2.new(0, 0, 0, 0)

    local tween = TweenService:Create(
        self.InnerBox,
        TweenInfo.new(
            0.15,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = targetSize
        }
    )

    tween:Play()

    task.spawn(function()
        local ok, err = pcall(
            self.Callback,
            self.StateValue
        )

        if not ok then
            warn("Toggle callback error:", err)
        end
    end)

    return self.StateValue
end
----------------------------------------------------------------
-- TITLE
----------------------------------------------------------------

function Toggle:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title .. "_Toggle"

    self.TitleLabel.Text =
        self.Title
end

----------------------------------------------------------------
-- FONT
----------------------------------------------------------------

function Toggle:SetFont(fontType)
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
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.TitleLabel.Font =
            fontType
    end
end

----------------------------------------------------------------
-- DESTROY
----------------------------------------------------------------

function Toggle:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

    for i, element in ipairs(self.Tab.Elements) do
        if element == self then
            table.remove(self.Tab.Elements, i)
            break
        end
    end
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

function Toggle:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    self.CheckboxOuter.BackgroundColor3 =
        theme.Background

    self.CheckboxOuter.BorderColor3 =
        theme.Border

    self.InnerBox.BackgroundColor3 =
        theme.Checkbox or theme.Accent

    -- FIX: title luôn lấy text từ Theme
    self.TitleLabel.TextColor3 =
        theme.Text

    self:SetFont(
        self.Window.CurrentFont
    )
end

return Toggle
