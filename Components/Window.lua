-- File: Components/Window.lua
local Window = {}
Window.__index = Window

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function Window.new(options, themeData, themeManager)
    local self = setmetatable({}, Window)
    
    -- Khởi tạo thông số
    options = options or {}
    self.TitleText = options.Title or "ImGui Window"
    self.Size = options.Size or UDim2.new(0, 500, 0, 450)
    self.MinSize = options.MinSize or Vector2.new(300, 250)
    self.Position = options.Position or UDim2.new(0.5, -250, 0.5, -225)
    
    self.ThemeData = themeData
    self.ThemeManager = themeManager
    self.IsMinimized = false
    self.CurrentFont = Enum.Font.RobotoMono

    local targetParent = gethui and gethui() or (CoreGui:FindFirstChild("RobloxGui") or CoreGui)

    -- 1. ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "DepsoImGui"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = targetParent

    -- 2. Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = self.Position
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.Parent = self.ScreenGui

    -- 3. Topbar
    self.Topbar = Instance.new("Frame")
    self.Topbar.Name = "Topbar"
    self.Topbar.Size = UDim2.new(1, 0, 0, 30)
    self.Topbar.BorderSizePixel = 0
    self.Topbar.Parent = self.MainFrame

    -- [1] Nút Collapse/Minimize (Góc bên trái cùng)
    self.CollapseBtn = Instance.new("TextButton")
    self.CollapseBtn.Name = "CollapseBtn"
    self.CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
    self.CollapseBtn.Position = UDim2.new(0, 0, 0, 0)
    self.CollapseBtn.BackgroundTransparency = 1
    self.CollapseBtn.Text = "▼"
    self.CollapseBtn.TextSize = 12
    self.CollapseBtn.Parent = self.Topbar

    -- [2] Title Label (Nằm kế bên nút Minimize)
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(1, -60, 1, 0) -- Trừ 30px bên trái (Minimize) và 30px bên phải (Close)
    self.Title.Position = UDim2.new(0, 30, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.TitleText
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.TextSize = 14
    self.Title.Parent = self.Topbar

    -- [3] Nút Close (Góc bên phải cùng, dùng chữ 'X' chuẩn ASCII để tránh lỗi font)
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Name = "CloseBtn"
    self.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    self.CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    self.CloseBtn.BackgroundTransparency = 1
    self.CloseBtn.Text = "X"
    self.CloseBtn.TextSize = 13
    self.CloseBtn.Parent = self.Topbar

    -- 4. Tab Container (Scroll ngang)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 2
    self.TabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    self.TabContainer.Parent = self.MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = self.TabContainer

    -- 5. Element Container
    self.ElementContainer = Instance.new("ScrollingFrame")
    self.ElementContainer.Name = "ElementContainer"
    self.ElementContainer.Size = UDim2.new(1, 0, 1, -65)
    self.ElementContainer.Position = UDim2.new(0, 0, 0, 65)
    self.ElementContainer.BorderSizePixel = 0
    self.ElementContainer.ScrollBarThickness = 4
    self.ElementContainer.Parent = self.MainFrame

    -- 6. Resize Corner
    self.ResizeCorner = Instance.new("TextButton")
    self.ResizeCorner.Name = "ResizeCorner"
    self.ResizeCorner.Size = UDim2.new(0, 15, 0, 15)
    self.ResizeCorner.Position = UDim2.new(1, -15, 1, -15)
    self.ResizeCorner.Text = "◢"
    self.ResizeCorner.TextSize = 12
    self.ResizeCorner.BackgroundTransparency = 1
    self.ResizeCorner.Parent = self.MainFrame

    -- Áp dụng Theme & Khởi tạo Event
    self:ApplyTheme(self.ThemeData)
    self:InitLogic()

    return self
end

function Window:ApplyTheme(theme)
    self.ThemeData = theme
    self.MainFrame.BackgroundColor3 = theme.Background
    self.MainFrame.BorderColor3 = theme.Border
    self.Topbar.BackgroundColor3 = theme.Accent
    self.Title.TextColor3 = theme.Text
    self.CloseBtn.TextColor3 = theme.Text
    self.CollapseBtn.TextColor3 = theme.Text
    self.TabContainer.BackgroundColor3 = theme.TabContainer
    self.ElementContainer.BackgroundColor3 = theme.ElementContainer
    self.ResizeCorner.TextColor3 = theme.Accent
    self:Font(self.CurrentFont)
end

function Window:InitLogic()
    -- Mũi tên Toggle Minimize
    self.CollapseBtn.MouseButton1Click:Connect(function()
        if self.IsMinimized then
            self:Open()
        else
            self:Close()
        end
    end)

    -- Nút X (Destroy)
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    -- DRAG SYSTEM (Hỗ trợ PC + Mobile, Anti Multi-Touch, Khóa 1 nguồn chạm)
    local isDragging = false
    local dragInput, dragStart, startPos

    self.Topbar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not isDragging then
                isDragging = true
                dragInput = input
                dragStart = input.Position
                startPos = self.MainFrame.Position
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            isDragging = false
            dragInput = nil
        end
    end)

    -- RESIZE SYSTEM (Giới hạn bởi MinSize)
    local isResizing = false
    local resizeInput, resizeStart, startSize

    self.ResizeCorner.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not isResizing and not self.IsMinimized then
                isResizing = true
                resizeInput = input
                resizeStart = input.Position
                startSize = self.MainFrame.Size
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == resizeInput and isResizing then
            local delta = input.Position - resizeStart
            local newWidth = math.max(self.MinSize.X, startSize.X.Offset + delta.X)
            local newHeight = math.max(self.MinSize.Y, startSize.Y.Offset + delta.Y)
            self.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            self.Size = self.MainFrame.Size
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == resizeInput then
            isResizing = false
            resizeInput = nil
        end
    end)
end

-- ================= CÁC HÀM API DÀNH CHO WINDOW =================

function Window:Center()
    local screenSize = self.ScreenGui.AbsoluteSize
    local frameSize = self.MainFrame.AbsoluteSize
    self.MainFrame.Position = UDim2.new(0, (screenSize.X - frameSize.X)/2, 0, (screenSize.Y - frameSize.Y)/2)
end

function Window:SetTitle(newTitle)
    self.TitleText = tostring(newTitle)
    self.Title.Text = self.TitleText
end

function Window:SetVisible(state)
    self.ScreenGui.Enabled = state
end

function Window:Close()
    if self.IsMinimized then return end
    self.IsMinimized = true
    
    TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, self.MainFrame.Size.X.Offset, 0, 30)
    }):Play()
    
    TweenService:Create(self.CollapseBtn, TweenInfo.new(0.3), {Rotation = -90}):Play()
end

function Window:Open()
    if not self.IsMinimized then return end
    self.IsMinimized = false
    
    TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = self.Size
    }):Play()
    
    TweenService:Create(self.CollapseBtn, TweenInfo.new(0.3), {Rotation = 0}):Play()
end

function Window:Destroy()
    self.ScreenGui:Destroy()
end

function Window:Font(fontType)
    self.CurrentFont = fontType
    if typeof(fontType) == "string" and string.match(fontType, "rbxassetid") then
        local customFont = Font.new(fontType)
        self.Title.FontFace = customFont
        self.CloseBtn.FontFace = customFont
        self.CollapseBtn.FontFace = customFont
    else
        self.Title.Font = fontType
        self.CloseBtn.Font = fontType
        self.CollapseBtn.Font = fontType
    end
end

function Window:Theme(themeName)
    if self.ThemeManager then
        local newTheme = self.ThemeManager:GetTheme(themeName)
        self:ApplyTheme(newTheme)
    end
end

return Window

