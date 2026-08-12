-- File: ImGuiRemake.lua/Components/Dropdown.lua

local TweenService = game:GetService("TweenService")

local Dropdown = {}
Dropdown.__index = Dropdown

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local ELEMENT_HEIGHT = 30
local OPTION_HEIGHT = 30
local DROPDOWN_WIDTH_SCALE = 0.5
local MAX_VISIBLE_OPTIONS = 3

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Dropdown.new(tab, options)

    options = options or {}

    local self = setmetatable({}, Dropdown)

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(options.Title or "Dropdown")

    self.Values = options.Value or {}
    self.Multi = options.Multi == true

    self.Callback = options.Callback or function() end

    self.Selected = {}

    self.Opened = false

    --------------------------------------------------------
    -- CONTAINER
    --------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name = self.Title .. "_Dropdown"
    self.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
    self.Container.AutomaticSize = Enum.AutomaticSize.Y
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = self.Tab.ContentFrame

    --------------------------------------------------------
    -- TOP ROW
    --------------------------------------------------------

    self.MainRow = Instance.new("Frame")
    self.MainRow.Name = "MainRow"
    self.MainRow.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
    self.MainRow.BackgroundTransparency = 1
    self.MainRow.Parent = self.Container

    --------------------------------------------------------
    -- DROPDOWN FRAME
    --------------------------------------------------------

    self.DropdownFrame = Instance.new("Frame")
    self.DropdownFrame.Name = "DropdownFrame"

    -- 1/2 ElementsContainer
    self.DropdownFrame.Size =
        UDim2.new(DROPDOWN_WIDTH_SCALE, 0, 0, ELEMENT_HEIGHT)

    self.DropdownFrame.BackgroundColor3 =
        self.Window.ThemeData.DropdownFrame
        or self.Window.ThemeData.Border

    self.DropdownFrame.BorderColor3 =
        self.Window.ThemeData.Border

    self.DropdownFrame.BorderSizePixel = 1

    self.DropdownFrame.Parent = self.MainRow

    --------------------------------------------------------
    -- OPEN / CLOSE BUTTON
    --------------------------------------------------------

    self.ToggleButton = Instance.new("TextButton")
    self.ToggleButton.Name = "ToggleButton"

    self.ToggleButton.Size =
        UDim2.new(0, ELEMENT_HEIGHT, 1, 0)

    self.ToggleButton.Position =
        UDim2.new(0, 0, 0, 0)

    self.ToggleButton.BackgroundTransparency = 1

    self.ToggleButton.Text = "▼"

    self.ToggleButton.TextSize = 14
    self.ToggleButton.Font = self.Window.CurrentFont

    self.ToggleButton.TextColor3 =
        self.Window.ThemeData.Text

    self.ToggleButton.AutoButtonColor = false

    self.ToggleButton.Parent = self.DropdownFrame

    --------------------------------------------------------
    -- SELECTED VALUE LABEL
    --------------------------------------------------------

    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "Value"

    self.ValueLabel.Size =
        UDim2.new(1, -ELEMENT_HEIGHT, 1, 0)

    self.ValueLabel.Position =
        UDim2.new(0, ELEMENT_HEIGHT, 0, 0)

    self.ValueLabel.BackgroundTransparency = 1

    self.ValueLabel.Text = "None"

    self.ValueLabel.TextColor3 =
        self.Window.ThemeData.Text

    self.ValueLabel.TextSize = 13
    self.ValueLabel.Font = self.Window.CurrentFont

    self.ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    self.ValueLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.ValueLabel.TextTruncate =
        Enum.TextTruncate.AtEnd

    self.ValueLabel.Parent = self.DropdownFrame

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    -- Phần còn lại nằm bên phải Dropdown
    self.TitleLabel.Size =
        UDim2.new(1 - DROPDOWN_WIDTH_SCALE, -8, 1, 0)

    self.TitleLabel.Position =
        UDim2.new(DROPDOWN_WIDTH_SCALE, 8, 0, 0)

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.Text = self.Title

    self.TitleLabel.TextColor3 =
        self.Window.ThemeData.Text

    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent = self.MainRow

    --------------------------------------------------------
    -- OPTIONS CONTAINER
    --------------------------------------------------------

    self.OptionsFrame = Instance.new("ScrollingFrame")
    self.OptionsFrame.Name = "Options"

    -- Cũng chỉ rộng 1/2
    self.OptionsFrame.Size =
        UDim2.new(DROPDOWN_WIDTH_SCALE, 0, 0, 0)

    self.OptionsFrame.Position =
        UDim2.new(0, 0, 0, ELEMENT_HEIGHT)

    self.OptionsFrame.BackgroundColor3 =
        self.Window.ThemeData.DropdownFrame
        or self.Window.ThemeData.Border

    self.OptionsFrame.BorderColor3 =
        self.Window.ThemeData.Border

    self.OptionsFrame.BorderSizePixel = 1

    self.OptionsFrame.ScrollBarThickness = 4

    self.OptionsFrame.ScrollingDirection =
        Enum.ScrollingDirection.Y

    self.OptionsFrame.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    self.OptionsFrame.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    self.OptionsFrame.Visible = false

    self.OptionsFrame.Parent = self.Container

    --------------------------------------------------------
    -- OPTION LAYOUT
    --------------------------------------------------------

    self.OptionLayout = Instance.new("UIListLayout")
    self.OptionLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.OptionLayout.Padding =
        UDim.new(0, 0)

    self.OptionLayout.Parent =
        self.OptionsFrame

    --------------------------------------------------------
    -- INITIAL SELECTED VALUES
    --------------------------------------------------------

    if type(options.Selected) == "table" then

        for _, value in ipairs(options.Selected) do
            self.Selected[value] = true
        end

    elseif options.Selected ~= nil then

        self.Selected[options.Selected] = true

    end

    --------------------------------------------------------
    -- BUILD OPTIONS
    --------------------------------------------------------

    self:_BuildOptions()

    self:_UpdateValueText()

    --------------------------------------------------------
    -- OPEN / CLOSE
    --------------------------------------------------------

    self.ToggleButton.MouseButton1Click:Connect(function()
        self:SetOpen(not self.Opened)
    end)

    --------------------------------------------------------
    -- REGISTER ELEMENT
    --------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CREATE OPTION
------------------------------------------------------------

function Dropdown:_CreateOption(value, index)

    local option = Instance.new("TextButton")

    option.Name =
        "Option_" .. tostring(value)

    option.Size =
        UDim2.new(1, -6, 0, OPTION_HEIGHT)

    option.AutomaticSize =
        Enum.AutomaticSize.None

    option.BackgroundColor3 =
        self.Window.ThemeData.DropdownOption
        or self.Window.ThemeData.Background

    option.BorderSizePixel = 0

    option.Text =
        tostring(value)

    option.TextSize = 13
    option.Font = self.Window.CurrentFont

    option.TextColor3 =
        self.Window.ThemeData.Text

    option.TextXAlignment =
        Enum.TextXAlignment.Left

    option.AutoButtonColor = false

    option.LayoutOrder = index

    option.Parent = self.OptionsFrame

    --------------------------------------------------------
    -- OPTION PADDING
    --------------------------------------------------------

    local padding = Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(0, 8)

    padding.PaddingRight =
        UDim.new(0, 8)

    padding.Parent = option

    --------------------------------------------------------
    -- HOVER
    --------------------------------------------------------

    option.MouseEnter:Connect(function()

        if not self.Selected[value] then

            option.BackgroundColor3 =
                self.Window.ThemeData.DropdownOptionHover
                or self.Window.ThemeData.Background

        end

    end)

    option.MouseLeave:Connect(function()

        self:_UpdateOptionColor(
            option,
            value
        )

    end)

    --------------------------------------------------------
    -- CLICK
    --------------------------------------------------------

    option.MouseButton1Click:Connect(function()

        self:_SelectValue(value)

    end)

    return option
end

------------------------------------------------------------
-- BUILD ALL OPTIONS
------------------------------------------------------------

function Dropdown:_BuildOptions()

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then
            child:Destroy()
        end

    end

    for index, value in ipairs(self.Values) do

        self:_CreateOption(
            value,
            index
        )

    end

    self:_UpdateOptionsSize()
end

------------------------------------------------------------
-- UPDATE OPTION COLOR
------------------------------------------------------------

function Dropdown:_UpdateOptionColor(
    option,
    value
)

    if self.Selected[value] then

        option.BackgroundColor3 =
            self.Window.ThemeData.DropdownOptionSelected
            or self.Window.ThemeData.Accent

    else

        option.BackgroundColor3 =
            self.Window.ThemeData.DropdownOption
            or self.Window.ThemeData.Background

    end

    option.TextColor3 =
        self.Window.ThemeData.Text

    option.TextSize = 13
    option.Font = self.Window.CurrentFont
end

------------------------------------------------------------
-- UPDATE OPTIONS SIZE
------------------------------------------------------------

function Dropdown:_UpdateOptionsSize()

    local count = #self.Values

    local visibleCount =
        math.min(
            count,
            MAX_VISIBLE_OPTIONS
        )

    local targetHeight =
        visibleCount * OPTION_HEIGHT

    self.ClosedHeight = 0
    self.OpenHeight = targetHeight

end

------------------------------------------------------------
-- SELECT VALUE
------------------------------------------------------------

function Dropdown:_SelectValue(value)

    local changed = value

    if self.Multi then

        self.Selected[value] =
            not self.Selected[value]

    else

        self.Selected = {}

        self.Selected[value] = true

    end

    self:_UpdateValueText()
    self:_UpdateOptions()

    task.spawn(function()

        local selected =
            self:GetSelected()

        pcall(
            self.Callback,
            selected,
            changed
        )

    end)

end

------------------------------------------------------------
-- UPDATE OPTIONS
------------------------------------------------------------

function Dropdown:_UpdateOptions()

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            local value =
                string.gsub(
                    child.Name,
                    "^Option_",
                    ""
                )

            for _, originalValue in ipairs(
                self.Values
            ) do

                if tostring(originalValue) == value then

                    self:_UpdateOptionColor(
                        child,
                        originalValue
                    )

                    break
                end

            end

        end

    end

end

------------------------------------------------------------
-- UPDATE VALUE TEXT
------------------------------------------------------------

function Dropdown:_UpdateValueText()

    local selected = {}

    for _, value in ipairs(self.Values) do

        if self.Selected[value] then

            table.insert(
                selected,
                tostring(value)
            )

        end

    end

    if #selected == 0 then

        self.ValueLabel.Text = "None"

    else

        self.ValueLabel.Text =
            table.concat(
                selected,
                ", "
            )

    end

end

------------------------------------------------------------
-- GET SELECTED
------------------------------------------------------------

function Dropdown:GetSelected()

    local result = {}

    for _, value in ipairs(self.Values) do

        if self.Selected[value] then

            table.insert(
                result,
                value
            )

        end

    end

    return result
end

------------------------------------------------------------
-- OPEN / CLOSE
------------------------------------------------------------

function Dropdown:SetOpen(state)

    state = state == true

    if self.Opened == state then
        return
    end

    self.Opened = state

    --------------------------------------------------------
    -- ROTATE ARROW
    --------------------------------------------------------

    local arrowRotation =
        state and 180 or 0

    TweenService:Create(
        self.ToggleButton,
        TweenInfo.new(
            0.2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Rotation = arrowRotation
        }
    ):Play()

    --------------------------------------------------------
    -- OPEN
    --------------------------------------------------------

    if state then

        self.OptionsFrame.Visible = true

        local targetHeight =
            self.OpenHeight

        TweenService:Create(
            self.OptionsFrame,
            TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    DROPDOWN_WIDTH_SCALE,
                    0,
                    0,
                    targetHeight
                )
            }
        ):Play()

    --------------------------------------------------------
    -- CLOSE
    --------------------------------------------------------

    else

        local tween =
            TweenService:Create(
                self.OptionsFrame,
                TweenInfo.new(
                    0.2,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(
                        DROPDOWN_WIDTH_SCALE,
                        0,
                        0,
                        0
                    )
                }
            )

        tween:Play()

        tween.Completed:Connect(function()

            if not self.Opened then
                self.OptionsFrame.Visible = false
            end

        end)

    end

end

------------------------------------------------------------
-- METHOD: SetTitle
------------------------------------------------------------

function Dropdown:SetTitle(newTitle)

    self.Title =
        tostring(newTitle)

    self.TitleLabel.Text =
        self.Title

end

------------------------------------------------------------
-- METHOD: Add
------------------------------------------------------------

function Dropdown:Add(value)

    if type(value) == "table" then

        for _, item in ipairs(value) do
            table.insert(
                self.Values,
                item
            )
        end

    else

        table.insert(
            self.Values,
            value
        )

    end

    self:_BuildOptions()
    self:_UpdateValueText()

end

------------------------------------------------------------
-- METHOD: Delete
------------------------------------------------------------

function Dropdown:Delete(value)

    for i = #self.Values, 1, -1 do

        if self.Values[i] == value then

            self.Selected[value] = nil

            table.remove(
                self.Values,
                i
            )

        end

    end

    self:_BuildOptions()
    self:_UpdateValueText()

end

------------------------------------------------------------
-- METHOD: Refresh
------------------------------------------------------------

function Dropdown:Refresh(values)

    self.Values =
        values or {}

    self.Selected = {}

    self:_BuildOptions()
    self:_UpdateValueText()

end

------------------------------------------------------------
-- METHOD: Refesh
-- Giữ alias để tránh breaking code cũ
------------------------------------------------------------

function Dropdown:Refesh(values)

    self:Refresh(values)

end

------------------------------------------------------------
-- METHOD: UpdateTheme
------------------------------------------------------------

function Dropdown:UpdateTheme(theme)

    --------------------------------------------------------
    -- FRAME
    --------------------------------------------------------

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame
        or theme.Border

    self.DropdownFrame.BorderColor3 =
        theme.Border

    self.OptionsFrame.BackgroundColor3 =
        theme.DropdownFrame
        or theme.Border

    self.OptionsFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- FONT
    --------------------------------------------------------

    self.ToggleButton.Font =
        self.Window.CurrentFont

    self.ToggleButton.TextSize = 14

    self.ValueLabel.Font =
        self.Window.CurrentFont

    self.ValueLabel.TextSize = 13

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextSize = 13

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    self.ToggleButton.TextColor3 =
        theme.Text

    self.ValueLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextColor3 =
        theme.Text

    --------------------------------------------------------
    -- OPTIONS
    --------------------------------------------------------

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            child.Font =
                self.Window.CurrentFont

            child.TextSize = 13

            self:_UpdateOptionColor(
                child,
                string.gsub(
                    child.Name,
                    "^Option_",
                    ""
                )
            )

        end

    end

end

------------------------------------------------------------
-- METHOD: Destroy
------------------------------------------------------------

function Dropdown:Destroy()

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

    if self.Container then
        self.Container:Destroy()
    end

end

return Dropdown
