-- File: ImGuiRemake.lua/Components/Toggle.lua
local TweenService = game:GetService("TweenService")

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, options)
    local self = setmetatable({}, Toggle)
    
    self.Tab = tab
    self.Window = tab.Window
    
    self.Title = options.Title or "Toggle"
    self.StateValue = options.State or false
    self.Callback = options.Callback or function() end
    
    -- [1] TẠO CONTAINER BAO BỌC (Khung chứa Toggle)
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Title .. "_Toggle"
    self.Container.Size = UDim2.new(1, 0, 0, 24)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = self.Tab.ContentFrame
    
    -- Nút bấm tàng hình phủ lên toàn bộ Container để dễ tương tác
    self.InteractBtn = Instance.new("TextButton")
    self.InteractBtn.Size = UDim2.new(1, 0, 1, 0)
    self.InteractBtn.BackgroundTransparency = 1
    self.InteractBtn.Text = ""
    self.InteractBtn.ZIndex = 2
    self.InteractBtn.Parent = self.Container
    
    -- Layout xếp ngang (Checkbox bên trái, Title bên phải)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8) -- Khoảng cách giữa checkbox và chữ
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self.Container
    
    -- [2] TẠO CHECKBOX (Hình vuông có viền)
    self.CheckboxOuter = Instance.new("Frame")
    self.CheckboxOuter.Name = "Checkbox"
    self.CheckboxOuter.Size = UDim2.new(0, 16, 0, 16)
    self.CheckboxOuter.BackgroundColor3 = self.Window.ThemeData.Background
    self.CheckboxOuter.BorderColor3 = self.Window.ThemeData.Border
    self.CheckboxOuter.BorderSizePixel = 1
    self.CheckboxOuter.LayoutOrder = 1 -- Đặt ở bên trái
    self.CheckboxOuter.Parent = self.Container
    
    -- [3] TẠO HÌNH VUÔNG NHỎ BÊN TRONG (Cho Animation)
    self.InnerBox = Instance.new("Frame")
    self.InnerBox.Name = "Inner"
    -- Nếu mặc định là true thì size = 10, false thì size = 0
    local initialSize = self.StateValue and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0)
    self.InnerBox.Size = initialSize
    self.InnerBox.AnchorPoint = Vector2.new(0.5, 0.5)
    self.InnerBox.Position = UDim2.new(0.5, 0, 0.5, 0) -- Căn giữa tuyệt đối
    -- Ưu tiên lấy thuộc tính Checkbox trong theme, nếu chưa có thì dùng Accent
    self.InnerBox.BackgroundColor3 = self.Window.ThemeData.Checkbox or self.Window.ThemeData.Accent
    self.InnerBox.BorderSizePixel = 0
    self.InnerBox.Parent = self.CheckboxOuter
    
    -- [4] TẠO TIÊU ĐỀ (Title)
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -24, 1, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = self.Window.ThemeData.Text
    self.TitleLabel.Font = self.Window.CurrentFont
    self.TitleLabel.TextSize = 13
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.LayoutOrder = 2 -- Nằm bên phải Checkbox
    self.TitleLabel.Parent = self.Container
    
    -- [5] LOGIC HOẠT ĐỘNG VÀ ANIMATION
    self.InteractBtn.MouseButton1Click:Connect(function()
        self:State(not self.StateValue)
    end)
    
    table.insert(self.Tab.Elements, self)
    
    return self
end

-- METHOD 1: Bật/Tắt Toggle kèm Animation
function Toggle:State(newState)
    if newState == nil then return end
    self.StateValue = newState
    
    -- Xử lý Animation phóng to/thu nhỏ
    local targetSize = self.StateValue and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0)
    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.InnerBox, tweenInfo, { Size = targetSize })
    tween:Play()
    
    -- Gọi Callback
    task.spawn(function()
        self.Callback(self.StateValue)
    end)
end

-- METHOD 2: Đổi tên Toggle
function Toggle:SetTitle(newTitle)
    self.Title = tostring(newTitle)
    self.TitleLabel.Text = self.Title
end

-- METHOD 3: Xóa Toggle
function Toggle:Destroy()
    if self.Container then
        self.Container:Destroy()
    end
end

-- UPDATE THEME: Cập nhật màu sắc khi đổi Theme
function Toggle:UpdateTheme(theme)
    self.CheckboxOuter.BackgroundColor3 = theme.Background
    self.CheckboxOuter.BorderColor3 = theme.Border
    -- Hỗ trợ màu Checkbox độc lập, fallback về Accent
    self.InnerBox.BackgroundColor3 = theme.Checkbox or theme.Accent
    self.TitleLabel.TextColor3 = theme.Text
    self.TitleLabel.Font = self.Window.CurrentFont
end

return Toggle

