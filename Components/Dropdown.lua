-- File: ImGuiRemake.lua/Components/Dropdown.lua

local Dropdown = {}
Dropdown.__index = Dropdown

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ROW_HEIGHT = 30
local DROPDOWN_WIDTH_SCALE = 0.5
local ELEMENT_GAP = 8

local VISIBLE_OPTIONS = 3
local SCROLLBAR_THICKNESS = 4

local OPEN_SIZE =
    ROW_HEIGHT * VISIBLE_OPTIONS

local ARROW_OPEN = "▲"
local ARROW_CLOSE = "▼"

local function contains(tbl, value)
    for _, item in ipairs(tbl) do
        if item == value then
            return true
        end
    end

    return false
end

local function removeValue(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            table.remove(tbl, i)
            return true
        end
    end

    return false
end

local function normalizeValue(value)
    return tostring(value)
end

function Dropdown.new(tab, options)
    local self = setmetatable({}, Dropdown)

    options = options or {}

    self.Tab = tab
    self.Window = tab.Window

    self.Title =
        tostring(options.Title or "Dropdown")

    self.Multi =
        options.Multi == true

    -- Value = danh sách option
    self.Values = {}

    -- Selected = danh sách option đang chọn
    self.Selected = {}

    self.Opened = false
    self.Destroyed = false

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    ----------------------------------------------------------------
    -- LOAD VALUES
    ----------------------------------------------------------------

    if type(options.Value) == "table" then
        for _, value in ipairs(options.Value) do
            table.insert(
                self.Values,
                normalizeValue(value)
            )
        end
    elseif type(options.Values) == "table" then
        for _, value in ipairs(options.Values) do
            table.insert(
                self.Values,
                normalizeValue(value)
            )
        end
    end

    ----------------------------------------------------------------
    -- INITIAL SELECTED
    ----------------------------------------------------------------

    if type(options.Selected) == "table" then
        if self.Multi then
            for _, value in ipairs(options.Selected) do
                value = normalizeValue(value)

                if contains(self.Values, value)
                    and not contains(self.Selected, value) then

                    table.insert(
                        self.Selected,
                        value
                    )
                end
            end
        else
            local value =
                options.Selected[1]

            if value ~= nil then
                value = normalizeValue(value)

                if contains(self.Values, value) then
                    table.insert(
                        self.Selected,
                        value
                    )
                end
            end
        end
    end

    local theme = self.Window.ThemeData

    ----------------------------------------------------------------
    -- MAIN CONTAINER
    ----------------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name =
        self.Title .. "_Dropdown"

    self.Container.Size =
        UDim2.new(
            1,
            -12,
            0,
            ROW_HEIGHT
        )

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = false
    self.Container.Parent =
        self.Tab.ContentFrame

    ----------------------------------------------------------------
    -- DROPDOWN FRAME
    ----------------------------------------------------------------

    self.DropdownFrame = Instance.new("TextButton")
    self.DropdownFrame.Name =
        "DropdownFrame"

    self.DropdownFrame.Size =
        UDim2.new(
            DROPDOWN_WIDTH_SCALE,
            0,
            0,
            ROW_HEIGHT
        )

    self.DropdownFrame.Position =
        UDim2.new(0, 0, 0, 0)

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame
        or theme.Border
        or Color3.fromRGB(38, 38, 38)

    self.DropdownFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.DropdownFrame.BorderSizePixel = 1
    self.DropdownFrame.AutoButtonColor = false
    self.DropdownFrame.Text = ""
    self.DropdownFrame.ClipsDescendants = true

    self.DropdownFrame.Parent =
        self.Container

    ----------------------------------------------------------------
    -- OPEN / CLOSE BUTTON
    ----------------------------------------------------------------

    self.ToggleButton = Instance.new("TextButton")
    self.ToggleButton.Name =
        "ToggleButton"

    self.ToggleButton.Size =
        UDim2.new(
            0,
            ROW_HEIGHT,
            0,
            ROW_HEIGHT
        )

    self.ToggleButton.Position =
        UDim2.new(0, 0, 0, 0)

    self.ToggleButton.BackgroundTransparency = 1
    self.ToggleButton.BorderSizePixel = 0
    self.ToggleButton.Text =
        ARROW_CLOSE

    self.ToggleButton.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.ToggleButton.TextSize = 13
    self.ToggleButton.AutoButtonColor = false
    self.ToggleButton.ZIndex = 3

    self.ToggleButton.Parent =
        self.DropdownFrame

    ----------------------------------------------------------------
    -- SELECTED VALUE TEXT
    ----------------------------------------------------------------

    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name =
        "Value"

    self.ValueLabel.Size =
        UDim2.new(
            1,
            -ROW_HEIGHT,
            1,
            0
        )

    self.ValueLabel.Position =
        UDim2.new(
            0,
            ROW_HEIGHT,
            0,
            0
        )

    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.ValueLabel.TextSize = 13
    self.ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    self.ValueLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.ValueLabel.ZIndex = 2
    self.ValueLabel.Parent =
        self.DropdownFrame

    ----------------------------------------------------------------
    -- OPTIONS CONTAINER
    ----------------------------------------------------------------

    self.OptionsFrame = Instance.new("ScrollingFrame")
    self.OptionsFrame.Name =
        "Options"

    self.OptionsFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.OptionsFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            ROW_HEIGHT
        )

    self.OptionsFrame.BackgroundColor3 =
        theme.DropdownFrame
        or theme.Border

    self.OptionsFrame.BorderColor3 =
        theme.Border

    self.OptionsFrame.BorderSizePixel = 1

    self.OptionsFrame.ScrollBarThickness =
        SCROLLBAR_THICKNESS

    self.OptionsFrame.ScrollingDirection =
        Enum.ScrollingDirection.Y

    self.OptionsFrame.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    self.OptionsFrame.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    self.OptionsFrame.Visible = false
    self.OptionsFrame.ZIndex = 10

    self.OptionsFrame.Parent =
        self.Container

    ----------------------------------------------------------------
    -- OPTIONS LAYOUT
    ----------------------------------------------------------------

    self.OptionsLayout = Instance.new("UIListLayout")
    self.OptionsLayout.Name =
        "OptionsLayout"

    self.OptionsLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.OptionsLayout.Padding =
        UDim.new(0, 1)

    self.OptionsLayout.Parent =
        self.OptionsFrame

    ----------------------------------------------------------------
    -- FONT
    ----------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    ----------------------------------------------------------------
    -- BUILD
    ----------------------------------------------------------------

    self:_RebuildOptions()
    self:_UpdateValueText()

    ----------------------------------------------------------------
    -- OPEN / CLOSE
    ----------------------------------------------------------------

    self.ToggleButton.MouseButton1Click:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:SetOpen(
                not self.Opened
            )
        end
    )

    self.DropdownFrame.MouseButton1Click:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:SetOpen(
                not self.Opened
            )
        end
    )

    ----------------------------------------------------------------
    -- REGISTER
    ----------------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

----------------------------------------------------------------
-- FORMAT SELECTED TEXT
----------------------------------------------------------------

function Dropdown:_GetDisplayText()
    if #self.Selected == 0 then
        return "None"
    end

    if not self.Multi then
        return self.Selected[1]
    end

    return table.concat(
        self.Selected,
        ", "
    )
end

function Dropdown:_UpdateValueText()
    if self.Destroyed then
        return
    end

    self.ValueLabel.Text =
        self:_GetDisplayText()
end

----------------------------------------------------------------
-- SELECT VALUE
----------------------------------------------------------------

function Dropdown:_Select(value)
    value = normalizeValue(value)

    if not contains(self.Values, value) then
        return
    end

    if self.Multi then
        if contains(self.Selected, value) then
            removeValue(
                self.Selected,
                value
            )
        else
            table.insert(
                self.Selected,
                value
            )
        end
    else
        table.clear(self.Selected)

        table.insert(
            self.Selected,
            value
        )

        self:SetOpen(false)
    end

    self:_UpdateValueText()
    self:_RefreshOptionColors()

    task.spawn(function()
        local ok, err = pcall(
            self.Callback,
            self.Selected,
            value
        )

        if not ok then
            warn(
                "Dropdown callback error:",
                err
            )
        end
    end)
end

----------------------------------------------------------------
-- CREATE OPTION
----------------------------------------------------------------

function Dropdown:_CreateOption(value, index)
    local theme =
        self.Window.ThemeData

    local selected =
        contains(
            self.Selected,
            value
        )

    local option =
        Instance.new("TextButton")

    option.Name =
        "Option_" .. tostring(index)

    option.Size =
        UDim2.new(
            1,
            -SCROLLBAR_THICKNESS - 2,
            0,
            ROW_HEIGHT
        )

    option.BackgroundColor3 =
        selected
        and (
            theme.DropdownOptionSelected
            or theme.Accent
        )
        or (
            theme.DropdownOption
            or theme.Background
        )

    option.BorderColor3 =
        theme.Border

    option.BorderSizePixel = 0
    option.Text =
        value

    option.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    option.TextSize = 13
    option.TextXAlignment =
        Enum.TextXAlignment.Left

    option.TextYAlignment =
        Enum.TextYAlignment.Center

    option.AutoButtonColor = false
    option.LayoutOrder = index

    option.ZIndex = 11
    option.Parent =
        self.OptionsFrame

    local padding =
        Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(0, 8)

    padding.PaddingRight =
        UDim.new(0, 8)

    padding.Parent =
        option

    ----------------------------------------------------------------
    -- HOVER
    ----------------------------------------------------------------

    option.MouseEnter:Connect(
        function()
            if self.Destroyed then
                return
            end

            if not contains(
                self.Selected,
                value
            ) then

                option.BackgroundColor3 =
                    theme.DropdownOptionHover
                    or theme.Border
            end
        end
    )

    option.MouseLeave:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:_UpdateSingleOptionColor(
                option,
                value
            )
        end
    )

    ----------------------------------------------------------------
    -- SELECT
    ----------------------------------------------------------------

    option.MouseButton1Click:Connect(
        function()
            if self.Destroyed then
                return
            end

            self:_Select(value)
        end
    )

    return option
end

----------------------------------------------------------------
-- UPDATE OPTION COLOR
----------------------------------------------------------------

function Dropdown:_UpdateSingleOptionColor(
    option,
    value
)
    local theme =
        self.Window.ThemeData

    local selected =
        contains(
            self.Selected,
            value
        )

    option.BackgroundColor3 =
        selected
        and (
            theme.DropdownOptionSelected
            or theme.Accent
        )
        or (
            theme.DropdownOption
            or theme.Background
        )

    option.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    option.BorderColor3 =
        theme.Border
end

function Dropdown:_RefreshOptionColors()
    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do
        if child:IsA("TextButton") then
            local index =
                child.LayoutOrder

            local value =
                self.Values[index]

            if value then
                self:_UpdateSingleOptionColor(
                    child,
                    value
                )
            end
        end
    end
end

----------------------------------------------------------------
-- REBUILD OPTIONS
----------------------------------------------------------------

function Dropdown:_RebuildOptions()
    if self.Destroyed then
        return
    end

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for index, value in ipairs(
        self.Values
    ) do
        self:_CreateOption(
            value,
            index
        )
    end
end

----------------------------------------------------------------
-- OPEN / CLOSE
----------------------------------------------------------------

function Dropdown:SetOpen(state)
    if self.Destroyed then
        return
    end

    state = state == true

    if self.Opened == state then
        return
    end

    self.Opened = state

    local targetHeight =
        state
        and (
            ROW_HEIGHT
            + OPEN_SIZE
        )
        or ROW_HEIGHT

    local optionTargetHeight =
        state
        and OPEN_SIZE
        or 0

    self.ToggleButton.Text =
        state
        and ARROW_OPEN
        or ARROW_CLOSE

    if state then
        self.OptionsFrame.Visible = true
    end

    ----------------------------------------------------------------
    -- MAIN CONTAINER
    ----------------------------------------------------------------

    local containerTween =
        TweenService:Create(
            self.Container,
            TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    1,
                    -12,
                    0,
                    targetHeight
                )
            }
        )

    ----------------------------------------------------------------
    -- OPTIONS
    ----------------------------------------------------------------

    local optionsTween =
        TweenService:Create(
            self.OptionsFrame,
            TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    1,
                    0,
                    0,
                    optionTargetHeight
                )
            }
        )

    containerTween:Play()
    optionsTween:Play()

    if not state then
        task.delay(
            0.2,
            function()
                if not self.Destroyed
                    and not self.Opened then

                    self.OptionsFrame.Visible =
                        false
                end
            end
        )
    end
end

----------------------------------------------------------------
-- SET TITLE
----------------------------------------------------------------

function Dropdown:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title .. "_Dropdown"
end

----------------------------------------------------------------
-- ADD
----------------------------------------------------------------

function Dropdown:Add(value)
    if self.Destroyed then
        return
    end

    if type(value) == "table" then
        for _, item in ipairs(value) do
            item =
                normalizeValue(item)

            if not contains(
                self.Values,
                item
            ) then

                table.insert(
                    self.Values,
                    item
                )
            end
        end
    else
        value =
            normalizeValue(value)

        if not contains(
            self.Values,
            value
        ) then

            table.insert(
                self.Values,
                value
            )
        end
    end

    self:_RebuildOptions()
    self:_UpdateValueText()
end

----------------------------------------------------------------
-- DELETE
----------------------------------------------------------------

function Dropdown:Delete(value)
    if self.Destroyed then
        return
    end

    if value == nil then
        return
    end

    value =
        normalizeValue(value)

    removeValue(
        self.Values,
        value
    )

    removeValue(
        self.Selected,
        value
    )

    self:_RebuildOptions()
    self:_UpdateValueText()
end

----------------------------------------------------------------
-- REFRESH
----------------------------------------------------------------

function Dropdown:Refresh(values)
    if self.Destroyed then
        return
    end

    table.clear(
        self.Values
    )

    if type(values) == "table" then
        for _, value in ipairs(values) do
            table.insert(
                self.Values,
                normalizeValue(value)
            )
        end
    end

    -- Xóa selected không còn tồn tại
    for i = #self.Selected, 1, -1 do
        if not contains(
            self.Values,
            self.Selected[i]
        ) then

            table.remove(
                self.Selected,
                i
            )
        end
    end

    self:_RebuildOptions()
    self:_UpdateValueText()
end

----------------------------------------------------------------
-- TYPO-COMPATIBILITY
--
-- Người dùng có thể gọi Refesh() đúng như API ban đầu.
----------------------------------------------------------------

function Dropdown:Refesh(values)
    return self:Refresh(values)
end

----------------------------------------------------------------
-- FONT
----------------------------------------------------------------

function Dropdown:SetFont(fontType)
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

        local ok, customFont =
            pcall(function()
                return Font.new(fontType)
            end)

        if ok and customFont then
            self.ValueLabel.FontFace =
                customFont

            self.ToggleButton.FontFace =
                customFont

            for _, child in ipairs(
                self.OptionsFrame:GetChildren()
            ) do
                if child:IsA("TextButton") then
                    child.FontFace =
                        customFont
                end
            end
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.ValueLabel.Font =
            fontType

        self.ToggleButton.Font =
            fontType

        for _, child in ipairs(
            self.OptionsFrame:GetChildren()
        ) do
            if child:IsA("TextButton") then
                child.Font =
                    fontType
            end
        end
    end
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

function Dropdown:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame
        or theme.Border
        or Color3.fromRGB(38, 38, 38)

    self.DropdownFrame.BorderColor3 =
        theme.Border

    self.OptionsFrame.BackgroundColor3 =
        theme.DropdownFrame
        or theme.Border

    self.OptionsFrame.BorderColor3 =
        theme.Border

    self.ValueLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.ToggleButton.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self:_RefreshOptionColors()

    self:SetFont(
        self.Window.CurrentFont
    )
end

----------------------------------------------------------------
-- DESTROY
----------------------------------------------------------------

function Dropdown:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true
    self.Opened = false

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

    for i, element in ipairs(
        self.Tab.Elements
    ) do
        if element == self then
            table.remove(
                self.Tab.Elements,
                i
            )

            break
        end
    end
end

return Dropdown
