-- File: DepsoImGui/Components/Tab.lua
local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    -- SỬA LỖI: Ưu tiên lấy Title, nếu không có thì lấy Name, không có nữa thì là "New Tab"
    self.Name = options.Title or options.Name or "New Tab"
    self.Elements = {} 
    
    -- [1] FIX LỖI VỊ TRÍ & CANVAS (Ép CanvasSize Y về 0 để Center hoạt động chuẩn xác)
    self.Window.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local tabLayout = self.Window.TabContainer:FindFirstChildOfClass("UIListLayout")
    if tabLayout then
        tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    end

    if not self.Window.TabContainer:FindFirstChildOfClass("UIPadding") then
        local containerPadding = Instance.new("UIPadding")
        containerPadding.PaddingLeft = UDim.new(0, 6)
        containerPadding.PaddingRight = UDim.new(0, 6)
        containerPadding.Parent = self.Window.TabContainer
    end

    -- [2] TẠO NÚT TAB (Tab Button)
    self.TabBtn = Instance.new("TextButton")
    self.TabBtn.Name = self.Name .. "_TabBtn"
    self.TabBtn.Size = UDim2.new(0, 0, 0, 26) -- Kích thước nhỏ hơn TabContainer (35px)
    self.TabBtn.AutomaticSize = Enum.AutomaticSize.X 
    
    self.TabBtn.BackgroundColor3 = self.Window.ThemeData.Background
    self.TabBtn.BorderColor3 = self.Window.ThemeData.Border
    self.TabBtn.BorderSizePixel = 1 -- Viền cho Tab
    
    self.TabBtn.Text = self.Name -- Lấy tên ngay tại đây
    self.TabBtn.TextColor3 = self.Window.ThemeData.Text
    self.TabBtn.TextSize = 13
    self.TabBtn.Font = self.Window.CurrentFont
    self.TabBtn.Parent = self.Window.TabContainer
    
    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 12)
    btnPadding.PaddingRight = UDim.new(0, 12)
    btnPadding.Parent = self.TabBtn

    -- [3] TẠO KHUNG CHỨA NỘI DUNG (Content Frame)
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

    -- [4] LOGIC HOẠT ĐỘNG
    table.insert(self.Window.Tabs, self)
    
    self.TabBtn.MouseButton1Click:Connect(function()
        self:Select()
    end)
    
    if #self.Window.Tabs == 1 then
        self:Select()
    end
    
    return self
end

-- Chọn Tab
function Tab:Select()
    for _, tab in ipairs(self.Window.Tabs) do
        tab.ContentFrame.Visible = false
        tab.TabBtn.BackgroundColor3 = self.Window.ThemeData.Background
        tab.TabBtn.TextColor3 = self.Window.ThemeData.Text
    end
    
    self.ContentFrame.Visible = true
    self.TabBtn.BackgroundColor3 = self.Window.ThemeData.Accent
    self.TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
end

-- Cập nhật màu sắc khi đổi Theme
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
        if element.UpdateTheme then
            element:UpdateTheme(theme)
        end
    end
end

-- Đổi tên Tab (Vẫn giữ nguyên method này)
function Tab:SetTitle(newTitle)
    self.Name = tostring(newTitle)
    self.TabBtn.Text = self.Name
end

return Tab
