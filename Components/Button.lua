-- File: ImGuiRemake.lua/Components/Button.lua
local Button = {}
Button.__index = Button

local TweenService = game:GetService("TweenService")

function Button.new(tab, options)
    local self = setmetatable({}, Button)
    
    options = options or {}
    self.Tab = tab
    self.Title = options.Title or "Button"
    self.Type = options.Type or "Default"
    self.Callback = options.Callback or function() end
    
    -- 1. Tạo Nút (TextButton)
    self.Instance = Instance.new("TextButton")
    self.Instance.Name = "Button_" .. self.Title
    self.Instance.Text = self.Title
    self.Instance.TextColor3 = self.Tab.Window.ThemeData.ButtonText or Color3.fromRGB(255, 255, 255)
    self.Instance.BackgroundColor3 = self.Tab.Window.ThemeData.Button or Color3.fromRGB(40, 90, 175)
    self.Instance.BorderColor3 = self.Tab.Window.ThemeData.Border or Color3.fromRGB(60, 60, 60)
    self.Instance.BorderSizePixel = 1
    self.Instance.Font = self.Tab.Window.CurrentFont
    self.Instance.TextSize = 13
    
    -- Xử lý Kích thước theo Type
    if self.Type == "Full" then
        self.Instance.Size = UDim2.new(1, -12, 0, 30)
    else
        self.Instance.Size = UDim2.new(0, 0, 0, 30)
        self.Instance.AutomaticSize = Enum.AutomaticSize.X
        
        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, 15)
        btnPadding.PaddingRight = UDim.new(0, 15)
        btnPadding.Parent = self.Instance
    end
    
    self.Instance.Parent = self.Tab.ContentFrame
    table.insert(self.Tab.Elements, self)

    -- 2. Hiệu ứng Hover & Click Highlight
    self.Instance.MouseEnter:Connect(function()
        local highlightColor = self.Tab.Window.ThemeData.ButtonHighlight or Color3.fromRGB(60, 110, 220)
        TweenService:Create(self.Instance, TweenInfo.new(0.2), {BackgroundColor3 = highlightColor}):Play()
    end)
    
    self.Instance.MouseLeave:Connect(function()
        local normalColor = self.Tab.Window.ThemeData.Button or Color3.fromRGB(40, 90, 175)
        TweenService:Create(self.Instance, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
    
    self.Instance.MouseButton1Down:Connect(function()
        local highlightColor = self.Tab.Window.ThemeData.ButtonHighlight or Color3.fromRGB(60, 110, 220)
        self.Instance.BackgroundColor3 = highlightColor
    end)
    
    self.Instance.MouseButton1Up:Connect(function()
        local normalColor = self.Tab.Window.ThemeData.Button or Color3.fromRGB(40, 90, 175)
        self.Instance.BackgroundColor3 = normalColor
    end)

    -- 3. Gọi Callback khi Click
    self.Instance.MouseButton1Click:Connect(function()
        pcall(self.Callback)
    end)

    return self
end

function Button:SetTitle(newTitle)
    self.Title = tostring(newTitle)
    self.Instance.Text = self.Title
end

function Button:Destroy()
    self.Instance:Destroy()
    for i, element in ipairs(self.Tab.Elements) do
        if element == self then
            table.remove(self.Tab.Elements, i)
            break
        end
    end
end

function Button:UpdateTheme(theme)
    self.Instance.TextColor3 = theme.ButtonText or Color3.fromRGB(255, 255, 255)
    self.Instance.BackgroundColor3 = theme.Button or Color3.fromRGB(40, 90, 175)
    self.Instance.BorderColor3 = theme.Border or Color3.fromRGB(60, 60, 60)
    self.Instance.Font = self.Tab.Window.CurrentFont
end

return Button

