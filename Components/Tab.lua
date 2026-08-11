-- File: ImGuiRemake.lua/Components/Tab.lua
local Tab = {}
Tab.__index = Tab

local TweenService = game:GetService("TweenService")

function Tab.new(window, options)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.TitleText = options.Title or "New Tab"
    
    -- 1. Nút Tab (nằm trong TabContainer của Window)
    self.Button = Instance.new("TextButton")
    self.Button.Name = self.TitleText .. "_Tab"
    self.Button.Size = UDim2.new(0, 0, 1, 0) -- Chiều cao full TabContainer, ngang 0 để tự scale
    self.Button.AutomaticSize = Enum.AutomaticSize.X -- Tự co giãn ngang theo Text
    self.Button.BackgroundColor3 = window.ThemeData.Tab
    self.Button.BorderSizePixel = 0
    self.Button.Text = self.TitleText
    self.Button.TextColor3 = window.ThemeData.Text
    self.Button.Font = window.CurrentFont
    self.Button.TextSize = 14
    self.Button.Parent = window.TabContainer

    -- Padding để chữ không bị sát lề nút
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)
    Padding.Parent = self.Button

    -- 2. Tab Container (Khung chứa Element cho riêng tab này)
    -- Thay vì bỏ thẳng vào ElementContainer, ta bỏ vào 1 Frame trung gian để dễ ẩn/hiện
    self.Container = Instance.new("Frame")
    self.Container.Name = self.TitleText .. "_Container"
    self.Container.Size = UDim2.new(1, 0, 0, 0)
    self.Container.AutomaticSize = Enum.AutomaticSize.Y -- Tự co giãn dọc để ElementContainer cuộn
    self.Container.BackgroundTransparency = 1
    self.Container.Visible = false -- Mặc định ẩn
    self.Container.Parent = window.ElementContainer

    -- ListLayout cho các element bên trong Tab
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = self.Container

    -- Đưa tab vào danh sách quản lý của Window
    table.insert(window.Tabs, self)

    -- Logic khi nhấn vào Tab
    self.Button.MouseButton1Click:Connect(function()
        self:Select()
    end)

    -- Tự động Select nếu đây là tab đầu tiên
    if #window.Tabs == 1 then
        self:Select()
    end

    return self
end

function Tab:SetTitle(newTitle)
    self.TitleText = tostring(newTitle)
    self.Button.Text = self.TitleText
    self.Button.Name = self.TitleText .. "_Tab"
    self.Container.Name = self.TitleText .. "_Container"
end

function Tab:Select()
    -- 1. Bỏ chọn tất cả các Tab khác
    for _, otherTab in ipairs(self.Window.Tabs) do
        otherTab.Container.Visible = false
        TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Window.ThemeData.Tab
        }):Play()
    end

    -- 2. Chọn Tab này
    self.Container.Visible = true
    TweenService:Create(self.Button, TweenInfo.new(0.2), {
        BackgroundColor3 = self.Window.ThemeData.TabHighlight
    }):Play()
end

-- Hàm nội bộ: Dùng để Window gọi khi đổi Theme (Window:Theme(...))
function Tab:UpdateTheme(theme)
    self.Button.TextColor3 = theme.Text
    if self.Container.Visible then
        self.Button.BackgroundColor3 = theme.TabHighlight
    else
        self.Button.BackgroundColor3 = theme.Tab
    end
end

return Tab

