-- File: ImGuiRemake.lua/Components/Tab.lua
local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = options.Name or "New Tab"
    self.Elements = {} -- Mảng lưu trữ các element (Button, Toggle, Slider...) bên trong Tab này
    
    -- [1] FIX LỖI LAYOUT CHO WINDOW (Căn giữa các Tab theo chiều dọc)
    local tabLayout = self.Window.TabContainer:FindFirstChildOfClass("UIListLayout")
    if tabLayout then
        tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    end

    -- Thêm Padding 2 đầu cho TabContainer để các tab không bị dính chặt vào lề trái
    if not self.Window.TabContainer:FindFirstChildOfClass("UIPadding") then
        local containerPadding = Instance.new("UIPadding")
        containerPadding.PaddingLeft = UDim.new(0, 6)
        containerPadding.PaddingRight = UDim.new(0, 6)
        containerPadding.Parent = self.Window.TabContainer
    end

    -- [2] TẠO NÚT TAB (Tab Button)
    self.TabBtn = Instance.new("TextButton")
    self.TabBtn.Name = self.Name .. "_TabBtn"
    -- Chiều cao 26px (Nhỏ hơn TabContainer 35px một chút)
    self.TabBtn.Size = UDim2.new(0, 0, 0, 26) 
    self.TabBtn.AutomaticSize = Enum.AutomaticSize.X -- Tự động mở rộng chiều ngang theo Text
    
    self.TabBtn.BackgroundColor3 = self.Window.ThemeData.Background
    self.TabBtn.BorderColor3 = self.Window.ThemeData.Border
    self.TabBtn.BorderSizePixel = 1 -- THÊM BORDER
    
    self.TabBtn.Text = self.Name
    self.TabBtn.TextColor3 = self.Window.ThemeData.Text
    self.TabBtn.TextSize = 13
    self.TabBtn.Font = self.Window.CurrentFont
    self.TabBtn.Parent = self.Window.TabContainer
    
    -- Padding cho Text bên trong Tab (tạo khoảng trống 2 bên viền)
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
    self.ContentFrame.Visible = false -- Ẩn mặc định
    self.ContentFrame.Parent = self.Window.ElementContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 5) -- Khoảng cách giữa các Element
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
    
    -- Nếu đây là Tab đầu tiên được tạo, tự động chọn nó
    if #self.Window.Tabs == 1 then
        self:Select()
    end
    
    return self
end

-- Hàm Kích hoạt/Chọn Tab này
function Tab:Select()
    -- Ẩn toàn bộ Tab khác và reset màu
    for _, tab in ipairs(self.Window.Tabs) do
        tab.ContentFrame.Visible = false
        tab.TabBtn.BackgroundColor3 = self.Window.ThemeData.Background
        tab.TabBtn.TextColor3 = self.Window.ThemeData.Text
    end
    
    -- Hiện Tab này và Highlight màu (Sử dụng màu Accent)
    self.ContentFrame.Visible = true
    self.TabBtn.BackgroundColor3 = self.Window.ThemeData.Accent
    -- Đổi màu chữ thành trắng hoặc đen tùy thuộc vào độ sáng của màu Accent (ở đây set mặc định là trắng cho đẹp)
    self.TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
end

-- Hàm cập nhật màu sắc khi Window đổi Theme
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
    
    -- Cập nhật theme cho các Elements bên trong (nếu có)
    for _, element in ipairs(self.Elements) do
        if element.UpdateTheme then
            element:UpdateTheme(theme)
        end
    end
end

return Tab
