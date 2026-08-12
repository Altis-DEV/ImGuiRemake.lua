-- File: ImGuiRemake.lua/Components/Window.lua

local Window = {}
Window.__index = Window

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local DEFAULT_SIZE = UDim2.new(0, 500, 0, 450)
local DEFAULT_MIN_SIZE = Vector2.new(300, 250)
local DEFAULT_POSITION = UDim2.new(0.5, -250, 0.5, -225)

local TOPBAR_HEIGHT = 30
local TAB_HEIGHT = 35
local CONTENT_TOP = TOPBAR_HEIGHT + TAB_HEIGHT

local function isInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function safeDisconnect(connection)
    if connection then
        connection:Disconnect()
    end
end

function Window.new(options, themeData, themeManager)
    local self = setmetatable({}, Window)

    options = options or {}

    self.TitleText = tostring(options.Title or "ImGui Window")
    self.Size = options.Size or DEFAULT_SIZE
    self.MinSize = options.MinSize or DEFAULT_MIN_SIZE
    self.Position = options.Position or DEFAULT_POSITION

    self.ThemeData = themeData or {}
    self.ThemeManager = themeManager

    self.IsMinimized = false
    self.IsDestroyed = false
    self.CurrentFont = options.Font or Enum.Font.RobotoMono

    self.Tabs = {}
    self._Connections = {}
    self._CurrentTween = nil

    ----------------------------------------------------------------
    -- PARENT
    ----------------------------------------------------------------

    local targetParent

    if type(gethui) == "function" then
        local ok, result = pcall(gethui)

        if ok and result then
            targetParent = result
        end
    end

    if not targetParent then
        targetParent =
            CoreGui:FindFirstChild("RobloxGui")
            or CoreGui
    end

    ----------------------------------------------------------------
    -- SCREEN GUI
    ----------------------------------------------------------------

    self.ScreenGui = Instance.new("ScreenGui")

    self.ScreenGui.Name =
        "ImGuiRemake_" .. tostring(math.random(100000, 999999))

    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.Parent = targetParent

    ----------------------------------------------------------------
    -- MAIN FRAME
    ----------------------------------------------------------------

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = self.Position
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.Parent = self.ScreenGui

    ----------------------------------------------------------------
    -- TOPBAR
    ----------------------------------------------------------------

    self.Topbar = Instance.new("Frame")
    self.Topbar.Name = "Topbar"
    self.Topbar.Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT)
    self.Topbar.Position = UDim2.new(0, 0, 0, 0)
    self.Topbar.BorderSizePixel = 0
    self.Topbar.Parent = self.MainFrame

    ----------------------------------------------------------------
    -- COLLAPSE BUTTON
    ----------------------------------------------------------------

    self.CollapseBtn = Instance.new("TextButton")
    self.CollapseBtn.Name = "CollapseBtn"
    self.CollapseBtn.Size = UDim2.new(0, 38, 1, 0)
    self.CollapseBtn.Position = UDim2.new(0, 0, 0, 0)
    self.CollapseBtn.BackgroundTransparency = 1
    self.CollapseBtn.BorderSizePixel = 0
    self.CollapseBtn.Text = "▼"
    self.CollapseBtn.TextSize = 14
    self.CollapseBtn.AutoButtonColor = false
    self.CollapseBtn.Parent = self.Topbar

    ----------------------------------------------------------------
    -- TITLE
    ----------------------------------------------------------------

    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(1, -76, 1, 0)
    self.Title.Position = UDim2.new(0, 38, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.TitleText
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.TextYAlignment = Enum.TextYAlignment.Center
    self.Title.TextSize = 14
    self.Title.Parent = self.Topbar

    ----------------------------------------------------------------
    -- CLOSE BUTTON
    ----------------------------------------------------------------

    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Name = "CloseBtn"
    self.CloseBtn.Size = UDim2.new(0, 38, 1, 0)
    self.CloseBtn.Position = UDim2.new(1, -38, 0, 0)
    self.CloseBtn.BackgroundTransparency = 1
    self.CloseBtn.BorderSizePixel = 0
    self.CloseBtn.Text = "X"
    self.CloseBtn.TextSize = 15
    self.CloseBtn.AutoButtonColor = false
    self.CloseBtn.Parent = self.Topbar

    ----------------------------------------------------------------
    -- TAB CONTAINER
    ----------------------------------------------------------------

    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, TAB_HEIGHT)
    self.TabContainer.Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT)
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 2
    self.TabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    self.TabContainer.ScrollingEnabled = true
    self.TabContainer.Parent = self.MainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Name = "TabLayout"
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.TabContainer

    ----------------------------------------------------------------
    -- ELEMENT CONTAINER
    ----------------------------------------------------------------

    self.ElementContainer = Instance.new("ScrollingFrame")
    self.ElementContainer.Name = "ElementContainer"
    self.ElementContainer.Size = UDim2.new(
        1,
        0,
        1,
        -CONTENT_TOP
    )
    self.ElementContainer.Position = UDim2.new(
        0,
        0,
        0,
        CONTENT_TOP
    )
    self.ElementContainer.BorderSizePixel = 0
    self.ElementContainer.ScrollBarThickness = 4
    self.ElementContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ElementContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ElementContainer.ScrollingEnabled = true
    self.ElementContainer.Parent = self.MainFrame

    ----------------------------------------------------------------
    -- RESIZE CORNER
    ----------------------------------------------------------------

    self.ResizeCorner = Instance.new("TextButton")
    self.ResizeCorner.Name = "ResizeCorner"
    self.ResizeCorner.Size = UDim2.new(0, 35, 0, 35)
    self.ResizeCorner.Position = UDim2.new(1, -35, 1, -30)
    self.ResizeCorner.BackgroundTransparency = 1
    self.ResizeCorner.BorderSizePixel = 0
    self.ResizeCorner.Text = "◢"
    self.ResizeCorner.TextSize = 22
    self.ResizeCorner.TextXAlignment = Enum.TextXAlignment.Right
    self.ResizeCorner.TextYAlignment = Enum.TextYAlignment.Bottom
    self.ResizeCorner.AutoButtonColor = false
    self.ResizeCorner.ZIndex = 100
    self.ResizeCorner.Parent = self.MainFrame

    ----------------------------------------------------------------
    -- THEME / LOGIC
    ----------------------------------------------------------------

    self:ApplyTheme(self.ThemeData)
    self:InitLogic()

    return self
end

----------------------------------------------------------------
-- CONNECTION MANAGEMENT
----------------------------------------------------------------

function Window:_Connect(signal, callback)
    if self.IsDestroyed then
        return nil
    end

    local connection = signal:Connect(callback)
    table.insert(self._Connections, connection)

    return connection
end

function Window:_DisconnectAll()
    for _, connection in ipairs(self._Connections) do
        safeDisconnect(connection)
    end

    table.clear(self._Connections)
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

function Window:ApplyTheme(theme)
    if self.IsDestroyed then
        return
    end

    theme = theme or self.ThemeData or {}

    self.ThemeData = theme

    self.MainFrame.BackgroundColor3 =
        theme.Background or Color3.fromRGB(20, 20, 20)

    self.MainFrame.BorderColor3 =
        theme.Border or Color3.fromRGB(60, 60, 60)

    self.Topbar.BackgroundColor3 =
        theme.Accent or Color3.fromRGB(40, 90, 175)

    self.Title.TextColor3 =
        theme.Text or Color3.fromRGB(255, 255, 255)

    self.CloseBtn.TextColor3 =
        theme.Text or Color3.fromRGB(255, 255, 255)

    self.CollapseBtn.TextColor3 =
        theme.Text or Color3.fromRGB(255, 255, 255)

    self.TabContainer.BackgroundColor3 =
        theme.TabContainer or Color3.fromRGB(30, 30, 30)

    self.ElementContainer.BackgroundColor3 =
        theme.ElementContainer or Color3.fromRGB(25, 25, 25)

    self.ResizeCorner.TextColor3 =
        theme.Accent or Color3.fromRGB(40, 90, 175)

    self:Font(self.CurrentFont)

    for _, tab in ipairs(self.Tabs) do
        if tab and tab.UpdateTheme then
            local ok, err = pcall(function()
                tab:UpdateTheme(theme)
            end)

            if not ok then
                warn("Tab theme update failed:", err)
            end
        end
    end
end

----------------------------------------------------------------
-- INPUT / WINDOW LOGIC
----------------------------------------------------------------

function Window:InitLogic()
    ----------------------------------------------------------------
    -- MINIMIZE
    ----------------------------------------------------------------

    self:_Connect(
        self.CollapseBtn.MouseButton1Click,
        function()
            if self.IsDestroyed then
                return
            end

            if self.IsMinimized then
                self:Open()
            else
                self:Close()
            end
        end
    )

    ----------------------------------------------------------------
    -- CLOSE
    ----------------------------------------------------------------

    self:_Connect(
        self.CloseBtn.MouseButton1Click,
        function()
            self:Destroy()
        end
    )

    ----------------------------------------------------------------
    -- DRAG
    ----------------------------------------------------------------

    local isDragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil

    self:_Connect(
        self.Topbar.InputBegan,
        function(input)
            if not isInput(input) then
                return
            end

            if self.IsDestroyed then
                return
            end

            isDragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = self.MainFrame.Position
        end
    )

    self:_Connect(
        UserInputService.InputChanged,
        function(input)
            if self.IsDestroyed then
                return
            end

            if not isDragging or input ~= dragInput then
                return
            end

            local delta = input.Position - dragStart

            self.MainFrame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )

            self.Position = self.MainFrame.Position
        end
    )

    self:_Connect(
        UserInputService.InputEnded,
        function(input)
            if input == dragInput then
                isDragging = false
                dragInput = nil
                dragStart = nil
                startPosition = nil
            end
        end
    )

    ----------------------------------------------------------------
    -- RESIZE
    ----------------------------------------------------------------

    local isResizing = false
    local resizeInput = nil
    local resizeStart = nil
    local startSize = nil

    self:_Connect(
        self.ResizeCorner.InputBegan,
        function(input)
            if not isInput(input) then
                return
            end

            if self.IsDestroyed or self.IsMinimized then
                return
            end

            isResizing = true
            resizeInput = input
            resizeStart = input.Position
            startSize = self.MainFrame.AbsoluteSize
        end
    )

    self:_Connect(
        UserInputService.InputChanged,
        function(input)
            if self.IsDestroyed then
                return
            end

            if not isResizing or input ~= resizeInput then
                return
            end

            local delta = input.Position - resizeStart

            local newWidth = math.max(
                self.MinSize.X,
                startSize.X + delta.X
            )

            local newHeight = math.max(
                self.MinSize.Y,
                startSize.Y + delta.Y
            )

            self.MainFrame.Size = UDim2.new(
                0,
                newWidth,
                0,
                newHeight
            )

            self.Size = self.MainFrame.Size
        end
    )

    self:_Connect(
        UserInputService.InputEnded,
        function(input)
            if input == resizeInput then
                isResizing = false
                resizeInput = nil
                resizeStart = nil
                startSize = nil
            end
        end
    )
end

----------------------------------------------------------------
-- CENTER
----------------------------------------------------------------

function Window:Center()
    if self.IsDestroyed then
        return
    end

    local screenSize = self.ScreenGui.AbsoluteSize
    local frameSize = self.MainFrame.AbsoluteSize

    local x = math.max(
        0,
        (screenSize.X - frameSize.X) / 2
    )

    local y = math.max(
        0,
        (screenSize.Y - frameSize.Y) / 2
    )

    self.MainFrame.Position = UDim2.new(
        0,
        x,
        0,
        y
    )

    self.Position = self.MainFrame.Position
end

----------------------------------------------------------------
-- TITLE
----------------------------------------------------------------

function Window:SetTitle(newTitle)
    if self.IsDestroyed then
        return
    end

    self.TitleText = tostring(newTitle)
    self.Title.Text = self.TitleText
end

----------------------------------------------------------------
-- VISIBILITY
----------------------------------------------------------------

function Window:SetVisible(state)
    if self.IsDestroyed then
        return
    end

    self.ScreenGui.Enabled = state == true
end

----------------------------------------------------------------
-- CLOSE / MINIMIZE
----------------------------------------------------------------

function Window:Close()
    if self.IsDestroyed or self.IsMinimized then
        return
    end

    self.IsMinimized = true

    if self._CurrentTween then
        self._CurrentTween:Cancel()
        self._CurrentTween = nil
    end

    local currentWidth = self.MainFrame.AbsoluteSize.X

    self._CurrentTween = TweenService:Create(
        self.MainFrame,
        TweenInfo.new(
            0.3,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(
                0,
                currentWidth,
                0,
                TOPBAR_HEIGHT
            )
        }
    )

    self._CurrentTween:Play()

    TweenService:Create(
        self.CollapseBtn,
        TweenInfo.new(0.3),
        {
            Rotation = -90
        }
    ):Play()
end

----------------------------------------------------------------
-- OPEN
----------------------------------------------------------------

function Window:Open()
    if self.IsDestroyed or not self.IsMinimized then
        return
    end

    self.IsMinimized = false

    if self._CurrentTween then
        self._CurrentTween:Cancel()
        self._CurrentTween = nil
    end

    self._CurrentTween = TweenService:Create(
        self.MainFrame,
        TweenInfo.new(
            0.3,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        {
            Size = self.Size
        }
    )

    self._CurrentTween:Play()

    TweenService:Create(
        self.CollapseBtn,
        TweenInfo.new(0.3),
        {
            Rotation = 0
        }
    ):Play()
end

----------------------------------------------------------------
-- DESTROY
----------------------------------------------------------------

function Window:Destroy()
    if self.IsDestroyed then
        return
    end

    self.IsDestroyed = true

    if self._CurrentTween then
        self._CurrentTween:Cancel()
        self._CurrentTween = nil
    end

    self:_DisconnectAll()

    for _, tab in ipairs(self.Tabs) do
        if tab and tab.Elements then
            table.clear(tab.Elements)
        end
    end

    table.clear(self.Tabs)

    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end

    self.MainFrame = nil
    self.Topbar = nil
    self.TabContainer = nil
    self.ElementContainer = nil
    self.ResizeCorner = nil
    self.Title = nil
    self.CloseBtn = nil
    self.CollapseBtn = nil
end

----------------------------------------------------------------
-- FONT
----------------------------------------------------------------

function Window:Font(fontType)
    if self.IsDestroyed then
        return
    end

    if fontType == nil then
        return
    end

    self.CurrentFont = fontType

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
            self.Title.FontFace = customFont
            self.CloseBtn.FontFace = customFont
            self.CollapseBtn.FontFace = customFont
        else
            warn("Không thể tạo custom font:", fontType)
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.Title.Font = fontType
        self.CloseBtn.Font = fontType
        self.CollapseBtn.Font = fontType
    end
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

function Window:Theme(themeName)
    if self.IsDestroyed then
        return
    end

    if not self.ThemeManager then
        return
    end

    local newTheme = self.ThemeManager:GetTheme(themeName)

    if not newTheme then
        warn("Không tìm thấy theme:", themeName)
        return
    end

    self:ApplyTheme(newTheme)
end

----------------------------------------------------------------
-- TAB
----------------------------------------------------------------

function Window:Tab(options)
    if self.IsDestroyed then
        return nil
    end

    if not self._TabModule then
        warn(
            "TabModule chưa được load " ..
            "(Kiểm tra lại file init.lua)!"
        )

        return nil
    end

    return self._TabModule.new(
        self,
        options or {}
    )
end

----------------------------------------------------------------
-- GETTERS
----------------------------------------------------------------

function Window:GetSize()
    if self.IsDestroyed then
        return nil
    end

    return self.MainFrame.Size
end

function Window:GetPosition()
    if self.IsDestroyed then
        return nil
    end

    return self.MainFrame.Position
end

function Window:IsVisible()
    if self.IsDestroyed then
        return false
    end

    return self.ScreenGui.Enabled
end

function Window:IsOpen()
    return not self.IsMinimized
        and not self.IsDestroyed
end

----------------------------------------------------------------
-- RETURN
----------------------------------------------------------------

return Window
