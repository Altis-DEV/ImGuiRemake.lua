-- File: ImGuiRemake.lua/Components/Tab.lua

local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
    local self = setmetatable({}, Tab)

    options = options or {}

    self.Window = window
    self.Name = tostring(options.Title or options.Name or "New Tab")
    self.Elements = {}
    self.Destroyed = false

    local container = self.Window.TabContainer

    container.CanvasSize = UDim2.new(0, 0, 0, 0)

    local tabLayout = container:FindFirstChildOfClass("UIListLayout")

    if tabLayout then
        tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    end

    if not container:FindFirstChildOfClass("UIPadding") then
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.Parent = container
    end

    -- Tab button
    self.TabBtn = Instance.new("TextButton")
    self.TabBtn.Name = self.Name .. "_TabBtn"
    self.TabBtn.Size = UDim2.new(0, 0, 0, 26)
    self.TabBtn.AutomaticSize = Enum.AutomaticSize.X
    self.TabBtn.BackgroundColor3 = self.Window.ThemeData.Background
    self.TabBtn.BorderColor3 = self.Window.ThemeData.Border
    self.TabBtn.BorderSizePixel = 1
    self.TabBtn.Text = self.Name
    self.TabBtn.TextColor3 = self.Window.ThemeData.Text
    self.TabBtn.TextSize = 13
    self.TabBtn.Font = self.Window.CurrentFont
    self.TabBtn.Parent = container

    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingLeft = UDim.new(0, 12)
    buttonPadding.PaddingRight = UDim.new(0, 12)
    buttonPadding.Parent = self.TabBtn

    -- Content
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = self.Name .. "_Content"
    self.ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    self.ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.Visible = false
    self.ContentFrame.Parent = self.Window.ElementContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.Parent = self.ContentFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 6)
    contentPadding.PaddingBottom = UDim.new(0, 6)
    contentPadding.PaddingLeft = UDim.new(0, 6)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.Parent = self.ContentFrame

    table.insert(self.Window.Tabs, self)

    self.TabBtn.MouseButton1Click:Connect(function()
        self:Select()
    end)

    if #self.Window.Tabs == 1 then
        self:Select()
    end

    return self
end

function Tab:Button(options)
    if not self.Window.ButtonModule then
        warn("ButtonModule chưa được load!")
        return nil
    end

    return self.Window.ButtonModule.new(self, options)
end

function Tab:Toggle(options)
    if not self.Window.ToggleModule then
        warn("ToggleModule chưa được load!")
        return nil
    end

    return self.Window.ToggleModule.new(self, options)
end

function Tab:Select()
    for _, tab in ipairs(self.Window.Tabs) do
        if tab.ContentFrame and tab.TabBtn then
            tab.ContentFrame.Visible = false
            tab.TabBtn.BackgroundColor3 = self.Window.ThemeData.Background
            tab.TabBtn.TextColor3 = self.Window.ThemeData.Text
        end
    end

    self.ContentFrame.Visible = true
    self.TabBtn.BackgroundColor3 = self.Window.ThemeData.Accent
    self.TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

function Tab:UpdateTheme(theme)
    if self.ContentFrame.Visible then
        self.TabBtn.BackgroundColor3 = theme.Accent
        self.TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        self.TabBtn.BackgroundColor3 = theme.Background
        self.TabBtn.TextColor3 = theme.Text
    end

    self.TabBtn.BorderColor3 = theme.Border
    self.TabBtn.Font = self.Window.CurrentFont

    for _, element in ipairs(self.Elements) do
        if element and element.UpdateTheme then
            element:UpdateTheme(theme)
        end
    end
end

function Tab:SetTitle(newTitle)
    self.Name = tostring(newTitle)

    if self.TabBtn then
        self.TabBtn.Name = self.Name .. "_TabBtn"
        self.TabBtn.Text = self.Name
    end

    if self.ContentFrame then
        self.ContentFrame.Name = self.Name .. "_Content"
    end
end

return Tab
