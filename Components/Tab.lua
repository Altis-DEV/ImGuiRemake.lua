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
        local containerPadding = Instance.new("UIPadding")
        containerPadding.PaddingLeft = UDim.new(0, 6)
        containerPadding.PaddingRight = UDim.new(0, 6)
        containerPadding.Parent = container
    end

    ----------------------------------------------------------------
    -- TAB BUTTON
    ----------------------------------------------------------------

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
    self.TabBtn.AutoButtonColor = false
    self.TabBtn.Parent = container

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 12)
    btnPadding.PaddingRight = UDim.new(0, 12)
    btnPadding.Parent = self.TabBtn

    ----------------------------------------------------------------
    -- CONTENT
    ----------------------------------------------------------------

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

    ----------------------------------------------------------------
    -- REGISTER
    ----------------------------------------------------------------

    table.insert(self.Window.Tabs, self)

    self.TabBtn.MouseButton1Click:Connect(function()
        if not self.Destroyed then
            self:Select()
        end
    end)

    if #self.Window.Tabs == 1 then
        self:Select()
    end

    return self
end

----------------------------------------------------------------
-- BUTTON
----------------------------------------------------------------

function Tab:Button(options)
    if not self.Window.ButtonModule then
        warn("ButtonModule chưa được load!")
        return nil
    end

    return self.Window.ButtonModule.new(
        self,
        options or {}
    )
end

----------------------------------------------------------------
-- TOGGLE
----------------------------------------------------------------

function Tab:Toggle(options)
    if not self.Window.ToggleModule then
        warn("ToggleModule chưa được load!")
        return nil
    end

    return self.Window.ToggleModule.new(
        self,
        options or {}
    )
end

function Tab:Slider(options)
    if not self.Window.SliderModule then
        warn("SliderModule chưa được load!")
        return nil
    end

    return self.Window.SliderModule.new(
        self,
        options or {}
    )
end

function Tab:Dropdown(options)
    if not self.Window.DropdownModule then
        warn("DropdownModule chưa được load!")
        return nil
    end

    return self.Window.DropdownModule.new(
        self,
        options or {}
    )
end

function Tab:TextBox(options)
    if not self.Window.TextBoxModule then
        warn("TextBoxModule chưa được load!")
        return nil
    end

    return self.Window.TextBoxModule.new(
        self,
        options or {}
    )
end

function Tab:Paragraph(options)
    if not self.Window.ParagraphModule then
        warn("ParagraphModule chưa được load!")
        return nil
    end

    return self.Window.ParagraphModule.new(
        self,
        options or {}
    )
end

function Tab:Label(options)
    if not self.Window.LabelModule then
        warn("LabelModule chưa được load!")
        return nil
    end

    return self.Window.LabelModule.new(
        self,
        options or {}
    )
end

function Tab:Divider(options)
    if not self.Window.DividerModule then
        warn("DividerModule chưa được load!")
        return nil
    end

    return self.Window.DividerModule.new(
        self,
        options or {}
    )
end

function Tab:Image(options)
    if not self.Window.ImageModule then
        warn(
            "ImageModule chưa được load " ..
            "(Kiểm tra lại file init.lua)!"
        )

        return nil
    end

    return self.Window.ImageModule.new(
        self,
        options or {}
    )
end
----------------------------------------------------------------
-- SELECT
----------------------------------------------------------------

function Tab:Select()
    if self.Destroyed then
        return
    end

    for _, tab in ipairs(self.Window.Tabs) do
        if tab.ContentFrame and tab.TabBtn then
            tab.ContentFrame.Visible = false
            tab.TabBtn.BackgroundColor3 =
                self.Window.ThemeData.Background
            tab.TabBtn.TextColor3 =
                self.Window.ThemeData.Text
        end
    end

    self.ContentFrame.Visible = true

    self.TabBtn.BackgroundColor3 =
        self.Window.ThemeData.Accent

    self.TabBtn.TextColor3 =
        Color3.fromRGB(255, 255, 255)
end

----------------------------------------------------------------
-- FONT
----------------------------------------------------------------

function Tab:SetFont(fontType)
    if self.Destroyed then
        return
    end

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
            self.TabBtn.FontFace = customFont

            for _, element in ipairs(self.Elements) do
                if element and element.SetFont then
                    element:SetFont(fontType)
                end
            end
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.TabBtn.Font = fontType

        for _, element in ipairs(self.Elements) do
            if element and element.SetFont then
                element:SetFont(fontType)
            end
        end
    end
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

function Tab:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    if self.ContentFrame.Visible then
        self.TabBtn.BackgroundColor3 = theme.Accent
        self.TabBtn.TextColor3 =
            Color3.fromRGB(255, 255, 255)
    else
        self.TabBtn.BackgroundColor3 =
            theme.Background

        self.TabBtn.TextColor3 =
            theme.Text
    end

    self.TabBtn.BorderColor3 =
        theme.Border

    self:SetFont(self.Window.CurrentFont)

    for _, element in ipairs(self.Elements) do
        if element and element.UpdateTheme then
            local ok, err = pcall(function()
                element:UpdateTheme(theme)
            end)

            if not ok then
                warn("Element theme update failed:", err)
            end
        end
    end
end

----------------------------------------------------------------
-- TITLE
----------------------------------------------------------------

function Tab:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    self.Name = tostring(newTitle)

    self.TabBtn.Name =
        self.Name .. "_TabBtn"

    self.TabBtn.Text =
        self.Name

    self.ContentFrame.Name =
        self.Name .. "_Content"
end

return Tab
