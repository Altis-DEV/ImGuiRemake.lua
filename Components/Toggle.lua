-- File: ImGuiRemake.lua/Components/Toggle.lua

local TweenService = game:GetService("TweenService")

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, options)
    local self = setmetatable({}, Toggle)

    options = options or {}

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(options.Title or "Toggle")
    self.StateValue = options.State == true
    self.Callback = type(options.Callback) == "function"
        and options.Callback
        or function() end

    self.Destroyed = false

    local theme = self.Window.ThemeData

    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Title .. "_Toggle"
    self.Container.Size = UDim2.new(1, 0, 0, 24)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = self.Tab.ContentFrame

    -- Interaction
    self.InteractBtn = Instance.new("TextButton")
    self.InteractBtn.Size = UDim2.new(1, 0, 1, 0)
    self.InteractBtn.BackgroundTransparency = 1
    self.InteractBtn.Text = ""
    self.InteractBtn.ZIndex = 2
    self.InteractBtn.Parent = self.Container

    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.Container

    -- Outer checkbox
    self.CheckboxOuter = Instance.new("Frame")
    self.CheckboxOuter.Name = "Checkbox"
    self.CheckboxOuter.Size = UDim2.new(0, 16, 0, 16)
    self.CheckboxOuter.BackgroundColor3 =
        theme.Background

    self.CheckboxOuter.BorderColor3 =
        theme.Border

    self.CheckboxOuter.BorderSizePixel = 1
    self.CheckboxOuter.LayoutOrder = 1
    self.CheckboxOuter.Parent = self.Container

    -- Inner checkbox
    self.InnerBox = Instance.new("Frame")
    self.InnerBox.Name = "Inner"

    self.InnerBox.Size =
        self.StateValue
        and UDim2.new(0, 10, 0, 10)
        or UDim2.new(0, 0, 0, 0)

    self.InnerBox.AnchorPoint = Vector2.new(0.5, 0.5)
    self.InnerBox.Position = UDim2.new(0.5, 0, 0.5, 0)

    self.InnerBox.BackgroundColor3 =
        theme.Checkbox or theme.Accent

    self.InnerBox.BorderSizePixel = 0
    self.InnerBox.Parent = self.CheckboxOuter

    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -24, 1, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = theme.Text
    self.TitleLabel.Font = self.Window.CurrentFont
    self.TitleLabel.TextSize = 13
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.LayoutOrder = 2
    self.TitleLabel.Parent = self.Container

    -- Click
    self.InteractBtn.MouseButton1Click:Connect(function()
        if self.Destroyed then return end

        self:State(not self.StateValue)
    end)

    table.insert(self.Tab.Elements, self)

    return self
end

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
        and UDim2.new(0, 10, 0, 10)
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

function Toggle:SetTitle(newTitle)
    if self.Destroyed then return end

    self.Title = tostring(newTitle)

    self.Container.Name = self.Title .. "_Toggle"
    self.TitleLabel.Text = self.Title
end

function Toggle:Destroy()
    if self.Destroyed then return end

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

function Toggle:UpdateTheme(theme)
    if self.Destroyed then return end

    self.CheckboxOuter.BackgroundColor3 =
        theme.Background

    self.CheckboxOuter.BorderColor3 =
        theme.Border

    self.InnerBox.BackgroundColor3 =
        theme.Checkbox or theme.Accent

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.Font =
        self.Window.CurrentFont
end

return Toggle
