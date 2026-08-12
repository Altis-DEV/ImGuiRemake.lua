-- File: ImGuiRemake.lua/Components/Button.lua

local Button = {}
Button.__index = Button

local TweenService = game:GetService("TweenService")

function Button.new(tab, options)
    local self = setmetatable({}, Button)

    options = options or {}

    self.Tab = tab
    self.Window = tab.Window
    self.Title = tostring(options.Title or "Button")
    self.Type = options.Type or "Default"
    self.Callback = type(options.Callback) == "function"
        and options.Callback
        or function() end

    local theme = self.Window.ThemeData

    self.Instance = Instance.new("TextButton")
    self.Instance.Name = "Button_" .. self.Title
    self.Instance.Text = self.Title
    self.Instance.TextColor3 = theme.ButtonText or Color3.fromRGB(255, 255, 255)
    self.Instance.BackgroundColor3 = theme.Button or Color3.fromRGB(40, 90, 175)
    self.Instance.BorderColor3 = theme.Border or Color3.fromRGB(60, 60, 60)
    self.Instance.BorderSizePixel = 1
    self.Instance.Font = self.Window.CurrentFont
    self.Instance.TextSize = 13

    if self.Type == "Full" then
        self.Instance.Size = UDim2.new(1, -12, 0, 30)
    else
        self.Instance.Size = UDim2.new(0, 0, 0, 30)
        self.Instance.AutomaticSize = Enum.AutomaticSize.X

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.PaddingRight = UDim.new(0, 15)
        padding.Parent = self.Instance
    end

    self.Instance.Parent = self.Tab.ContentFrame

    table.insert(self.Tab.Elements, self)

    self.Instance.MouseEnter:Connect(function()
        if self.Destroyed then return end

        TweenService:Create(
            self.Instance,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 =
                    self.Window.ThemeData.ButtonHighlight
                    or Color3.fromRGB(60, 110, 220)
            }
        ):Play()
    end)

    self.Instance.MouseLeave:Connect(function()
        if self.Destroyed then return end

        TweenService:Create(
            self.Instance,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 =
                    self.Window.ThemeData.Button
                    or Color3.fromRGB(40, 90, 175)
            }
        ):Play()
    end)

    self.Instance.MouseButton1Down:Connect(function()
        if self.Destroyed then return end

        self.Instance.BackgroundColor3 =
            self.Window.ThemeData.ButtonHighlight
            or Color3.fromRGB(60, 110, 220)
    end)

    self.Instance.MouseButton1Up:Connect(function()
        if self.Destroyed then return end

        self.Instance.BackgroundColor3 =
            self.Window.ThemeData.Button
            or Color3.fromRGB(40, 90, 175)
    end)

    self.Instance.MouseButton1Click:Connect(function()
        if self.Destroyed then return end

        task.spawn(function()
            local ok, err = pcall(self.Callback)

            if not ok then
                warn("Button callback error:", err)
            end
        end)
    end)

    return self
end

function Button:SetTitle(newTitle)
    if self.Destroyed then return end

    self.Title = tostring(newTitle)
    self.Instance.Name = "Button_" .. self.Title
    self.Instance.Text = self.Title
end

function Button:Destroy()
    if self.Destroyed then return end

    self.Destroyed = true

    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end

    for i, element in ipairs(self.Tab.Elements) do
        if element == self then
            table.remove(self.Tab.Elements, i)
            break
        end
    end
end

function Button:UpdateTheme(theme)
    if self.Destroyed then return end

    self.Instance.TextColor3 =
        theme.ButtonText or Color3.fromRGB(255, 255, 255)

    self.Instance.BackgroundColor3 =
        theme.Button or Color3.fromRGB(40, 90, 175)

    self.Instance.BorderColor3 =
        theme.Border or Color3.fromRGB(60, 60, 60)

    self.Instance.Font = self.Window.CurrentFont
end

return Button
