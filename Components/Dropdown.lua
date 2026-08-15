-- File: ImGuiRemake.lua/Components/Dropdown.lua

local Dropdown = {}
Dropdown.__index = Dropdown

local TweenService =
    game:GetService("TweenService")

local ELEMENT_HEIGHT = 30
local OPTION_HEIGHT = 30

local DROPDOWN_WIDTH_SCALE = 0.5
local MAX_VISIBLE_OPTIONS = 3

local ARROW_ROTATION_CLOSED = -90
local ARROW_ROTATION_OPEN = 0

local ANIMATION_TIME = 0.2

------------------------------------------------------------
-- REQUEST PARENT ROW RELAYOUT
------------------------------------------------------------

local function requestParentRelayout(
    self,
    animated
)

    local parent =
        self.Tab

    if parent
        and not parent.Destroyed
        and type(parent._Relayout) == "function" then

        parent:_Relayout(
            animated == true
        )
    end
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Dropdown.new(
    tab,
    options
)

    options = options or {}

    local self =
        setmetatable(
            {},
            Dropdown
        )

    self.Tab = tab
    self.Window = tab.Window

    self.WidthAtRow =
        options.WidthAtRow

    self.HasTitle =
        options.Title ~= nil
        and tostring(options.Title) ~= ""

    self.Title =
        self.HasTitle
        and tostring(options.Title)
        or ""

    self.Multi =
        options.Multi == true

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    self.Values = {}
    self.Selected = {}

    self.OptionValues = {}

    self.Opened = false
    self.Destroyed = false

    self._RowLayoutHeight =
        ELEMENT_HEIGHT

    --------------------------------------------------------
    -- VALUES
    --------------------------------------------------------

    if type(options.Value) == "table" then

        for _, value in ipairs(
            options.Value
        ) do

            table.insert(
                self.Values,
                value
            )
        end
    end

    --------------------------------------------------------
    -- SELECTED
    --------------------------------------------------------

    if type(options.Selected) == "table" then

        for _, value in ipairs(
            options.Selected
        ) do

            if self:_ContainsValue(value) then

                self.Selected[value] =
                    true
            end
        end

    elseif options.Selected ~= nil then

        if self:_ContainsValue(
            options.Selected
        ) then

            self.Selected[
                options.Selected
            ] = true
        end
    end

    local theme =
        self.Window.ThemeData

    --------------------------------------------------------
    -- CONTAINER
    --------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        self.HasTitle
        and self.Title .. "_Dropdown"
        or "Dropdown"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent =
        self.Tab.ContentFrame

    --------------------------------------------------------
    -- MAIN ROW
    --------------------------------------------------------

    self.MainRow =
        Instance.new("Frame")

    self.MainRow.Name =
        "MainRow"

    self.MainRow.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.MainRow.BackgroundTransparency = 1
    self.MainRow.BorderSizePixel = 0
    self.MainRow.Parent =
        self.Container

    --------------------------------------------------------
    -- DROPDOWN FRAME
    --------------------------------------------------------

    self.DropdownFrame =
        Instance.new("Frame")

    self.DropdownFrame.Name =
        "DropdownFrame"

    self.DropdownFrame.Size =
        UDim2.new(
            self.HasTitle
            and DROPDOWN_WIDTH_SCALE
            or 1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.DropdownFrame.BorderColor3 =
        theme.Border

    self.DropdownFrame.BorderSizePixel = 1
    self.DropdownFrame.Parent =
        self.MainRow

    --------------------------------------------------------
    -- ARROW
    --------------------------------------------------------

    self.ToggleButton =
        Instance.new("TextButton")

    self.ToggleButton.Name =
        "ToggleButton"

    self.ToggleButton.Size =
        UDim2.new(
            0,
            ELEMENT_HEIGHT,
            1,
            0
        )

    self.ToggleButton.BackgroundTransparency = 1
    self.ToggleButton.BorderSizePixel = 0
    self.ToggleButton.Text = "▼"

    self.ToggleButton.Rotation =
        ARROW_ROTATION_CLOSED

    self.ToggleButton.TextSize = 14
    self.ToggleButton.Font =
        self.Window.CurrentFont

    self.ToggleButton.TextColor3 =
        theme.Text

    self.ToggleButton.AutoButtonColor = false
    self.ToggleButton.Parent =
        self.DropdownFrame

    --------------------------------------------------------
    -- VALUE
    --------------------------------------------------------

    self.ValueLabel =
        Instance.new("TextLabel")

    self.ValueLabel.Name =
        "Value"

    self.ValueLabel.Size =
        UDim2.new(
            1,
            -ELEMENT_HEIGHT,
            1,
            0
        )

    self.ValueLabel.Position =
        UDim2.new(
            0,
            ELEMENT_HEIGHT,
            0,
            0
        )

    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.TextColor3 =
        theme.Text

    self.ValueLabel.TextSize = 13
    self.ValueLabel.Font =
        self.Window.CurrentFont

    self.ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    self.ValueLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.ValueLabel.TextTruncate =
        Enum.TextTruncate.AtEnd

    self.ValueLabel.Parent =
        self.DropdownFrame

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    if self.HasTitle then
        self:_CreateTitleLabel(theme)
    end

    --------------------------------------------------------
    -- OPTIONS
    --------------------------------------------------------

    self.OptionsFrame =
        Instance.new("ScrollingFrame")

    self.OptionsFrame.Name =
        "Options"

    self.OptionsFrame.Size =
        UDim2.new(
            self.HasTitle
            and DROPDOWN_WIDTH_SCALE
            or 1,
            0,
            0,
            0
        )

    self.OptionsFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.OptionsFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.OptionsFrame.BorderColor3 =
        theme.Border

    self.OptionsFrame.BorderSizePixel = 1
    self.OptionsFrame.ScrollBarThickness = 4

    self.OptionsFrame.ScrollingDirection =
        Enum.ScrollingDirection.Y

    self.OptionsFrame.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    self.OptionsFrame.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.OptionsFrame.Visible =
        false

    self.OptionsFrame.Parent =
        self.Container

    --------------------------------------------------------
    -- OPTION LAYOUT
    --------------------------------------------------------

    self.OptionLayout =
        Instance.new("UIListLayout")

    self.OptionLayout.Name =
        "OptionLayout"

    self.OptionLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.OptionLayout.Padding =
        UDim.new(
            0,
            0
        )

    self.OptionLayout.Parent =
        self.OptionsFrame

    --------------------------------------------------------
    -- INITIAL
    --------------------------------------------------------

    self:_UpdateValueText()
    self:_BuildOptions()

    --------------------------------------------------------
    -- TOGGLE
    --------------------------------------------------------

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

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CREATE TITLE
------------------------------------------------------------

function Dropdown:_CreateTitleLabel(
    theme
)

    if self.TitleLabel then
        return
    end

    self.TitleLabel =
        Instance.new("TextLabel")

    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1 - DROPDOWN_WIDTH_SCALE,
            -8,
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            DROPDOWN_WIDTH_SCALE,
            8,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.MainRow
end

------------------------------------------------------------
-- VALUE
------------------------------------------------------------

function Dropdown:_ContainsValue(
    value
)

    for _, item in ipairs(
        self.Values
    ) do

        if item == value then
            return true
        end
    end

    return false
end

function Dropdown:_UpdateValueText()

    if self.Destroyed then
        return
    end

    local selected = {}

    for _, value in ipairs(
        self.Values
    ) do

        if self.Selected[value] then

            table.insert(
                selected,
                tostring(value)
            )
        end
    end

    if #selected == 0 then

        self.ValueLabel.Text =
            "None"

    else

        self.ValueLabel.Text =
            table.concat(
                selected,
                ", "
            )
    end
end

------------------------------------------------------------
-- OPTIONS
------------------------------------------------------------

function Dropdown:_CreateOption(
    value,
    index
)

    local theme =
        self.Window.ThemeData

    local option =
        Instance.new("TextButton")

    option.Name =
        "Option_" ..
        tostring(index)

    self.OptionValues[option] =
        value

    option.Size =
        UDim2.new(
            1,
            -6,
            0,
            OPTION_HEIGHT
        )

    option.BackgroundColor3 =
        self.Selected[value]
        and theme.DropdownOptionSelected
        or theme.DropdownOption

    option.BorderSizePixel = 0
    option.Text =
        tostring(value)

    option.TextSize = 13
    option.Font =
        self.Window.CurrentFont

    option.TextColor3 =
        theme.Text

    option.TextXAlignment =
        Enum.TextXAlignment.Left

    option.TextYAlignment =
        Enum.TextYAlignment.Center

    option.AutoButtonColor = false
    option.LayoutOrder = index
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

    option.MouseEnter:Connect(
        function()

            if self.Destroyed then
                return
            end

            if not self.Selected[value] then

                option.BackgroundColor3 =
                    self.Window.ThemeData
                        .DropdownOptionHover
            end
        end
    )

    option.MouseLeave:Connect(
        function()

            if self.Destroyed then
                return
            end

            self:_UpdateOptionColor(
                option,
                value
            )
        end
    )

    option.MouseButton1Click:Connect(
        function()

            if self.Destroyed then
                return
            end

            self:_SelectValue(value)
        end
    )

    return option
end

function Dropdown:_BuildOptions()

    if self.Destroyed then
        return
    end

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            self.OptionValues[child] =
                nil

            child:Destroy()
        end
    end

    for index, value in ipairs(
        self.Values
    ) do

        local option =
            self:_CreateOption(
                value,
                index
            )

        self:_UpdateOptionColor(
            option,
            value
        )
    end

    self:_UpdateOptionsSize()
end

function Dropdown:_UpdateOptionColor(
    option,
    value
)

    if not option
        or not option.Parent then
        return
    end

    local theme =
        self.Window.ThemeData

    option.BackgroundColor3 =
        self.Selected[value]
        and theme.DropdownOptionSelected
        or theme.DropdownOption

    option.TextColor3 =
        theme.Text

    option.TextSize = 13

    self:_SetInstanceFont(
        option,
        self.Window.CurrentFont
    )
end

function Dropdown:_UpdateOptions()

    if self.Destroyed then
        return
    end

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            local value =
                self.OptionValues[child]

            if value ~= nil then

                self:_UpdateOptionColor(
                    child,
                    value
                )
            end
        end
    end
end

function Dropdown:_UpdateOptionsSize()

    local count =
        #self.Values

    local visible =
        math.min(
            count,
            MAX_VISIBLE_OPTIONS
        )

    self.OpenHeight =
        visible
        * OPTION_HEIGHT

    if self.Opened then

        self._RowLayoutHeight =
            ELEMENT_HEIGHT
            + self.OpenHeight

        requestParentRelayout(
            self,
            false
        )
    end
end

------------------------------------------------------------
-- SELECT
------------------------------------------------------------

function Dropdown:_SelectValue(
    value
)

    if self.Destroyed then
        return
    end

    if not self.Multi then

        table.clear(
            self.Selected
        )

        self.Selected[value] =
            true

    else

        self.Selected[value] =
            not self.Selected[value]
    end

    self:_UpdateValueText()
    self:_UpdateOptions()

    task.spawn(
        function()

            local selected =
                self:GetSelected()

            local ok, err =
                pcall(
                    self.Callback,
                    selected,
                    value
                )

            if not ok then

                warn(
                    "Dropdown callback error:",
                    err
                )
            end
        end
    )

    if not self.Multi then

        self:SetOpen(
            false
        )
    end
end

function Dropdown:GetSelected()

    local result = {}

    for _, value in ipairs(
        self.Values
    ) do

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

function Dropdown:SetOpen(
    state
)

    if self.Destroyed then
        return
    end

    state =
        state == true

    if self.Opened == state then
        return
    end

    self.Opened =
        state

    local dropdownWidth =
        self.DropdownFrame.Size

    local optionWidth =
        UDim2.new(
            dropdownWidth.X.Scale,
            dropdownWidth.X.Offset,
            0,
            0
        )

    local openSize =
        UDim2.new(
            dropdownWidth.X.Scale,
            dropdownWidth.X.Offset,
            0,
            self.OpenHeight
        )

    local arrowRotation =
        state
        and ARROW_ROTATION_OPEN
        or ARROW_ROTATION_CLOSED

    TweenService:Create(
        self.ToggleButton,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Rotation =
                arrowRotation
        }
    ):Play()

    if state then

        self._RowLayoutHeight =
            ELEMENT_HEIGHT
            + self.OpenHeight

        self.OptionsFrame.Visible =
            true

        TweenService:Create(
            self.OptionsFrame,
            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    openSize
            }
        ):Play()

        requestParentRelayout(
            self,
            true
        )

    else

        self._RowLayoutHeight =
            ELEMENT_HEIGHT

        local tween =
            TweenService:Create(
                self.OptionsFrame,
                TweenInfo.new(
                    ANIMATION_TIME,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Size =
                        optionWidth
                }
            )

        tween:Play()

        requestParentRelayout(
            self,
            true
        )

        tween.Completed:Connect(
            function()

                if self.Destroyed then
                    return
                end

                if not self.Opened then

                    self.OptionsFrame.Visible =
                        false

                    self._RowLayoutHeight =
                        ELEMENT_HEIGHT

                    requestParentRelayout(
                        self,
                        false
                    )
                end
            end
        )
    end
end

------------------------------------------------------------
-- TITLE
------------------------------------------------------------

function Dropdown:SetTitle(
    newTitle
)

    if self.Destroyed then
        return
    end

    if newTitle == nil
        or tostring(newTitle) == "" then

        self.HasTitle =
            false

        self.Title =
            ""

        if self.TitleLabel then

            self.TitleLabel:Destroy()
            self.TitleLabel = nil
        end

        self.Container.Name =
            "Dropdown"

        self.DropdownFrame.Size =
            UDim2.new(
                1,
                0,
                0,
                ELEMENT_HEIGHT
            )

        self.OptionsFrame.Size =
            UDim2.new(
                1,
                0,
                0,
                self.Opened
                    and self.OpenHeight
                    or 0
            )

        requestParentRelayout(
            self,
            false
        )

        return
    end

    self.HasTitle =
        true

    self.Title =
        tostring(
            newTitle
        )

    if not self.TitleLabel then

        self:_CreateTitleLabel(
            self.Window.ThemeData
        )
    end

    self.Container.Name =
        self.Title
        .. "_Dropdown"

    self.TitleLabel.Text =
        self.Title

    self.DropdownFrame.Size =
        UDim2.new(
            DROPDOWN_WIDTH_SCALE,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.OptionsFrame.Size =
        UDim2.new(
            DROPDOWN_WIDTH_SCALE,
            0,
            0,
            self.Opened
                and self.OpenHeight
                or 0
        )

    requestParentRelayout(
        self,
        false
    )
end

------------------------------------------------------------
-- ADD / DELETE / REFRESH
------------------------------------------------------------

function Dropdown:Add(
    value
)

    if self.Destroyed then
        return
    end

    if type(value) == "table" then

        for _, item in ipairs(value) do

            if not self:_ContainsValue(
                item
            ) then

                table.insert(
                    self.Values,
                    item
                )
            end
        end

    else

        if not self:_ContainsValue(
            value
        ) then

            table.insert(
                self.Values,
                value
            )
        end
    end

    self:_BuildOptions()
    self:_UpdateValueText()
    self:_UpdateOptions()

    requestParentRelayout(
        self,
        false
    )
end

function Dropdown:Delete(
    value
)

    if self.Destroyed then
        return
    end

    for i =
        #self.Values,
        1,
        -1
    do

        if self.Values[i] == value then

            self.Selected[value] =
                nil

            table.remove(
                self.Values,
                i
            )
        end
    end

    self:_BuildOptions()
    self:_UpdateValueText()
    self:_UpdateOptions()

    requestParentRelayout(
        self,
        false
    )
end

function Dropdown:Refresh(
    values
)

    if self.Destroyed then
        return
    end

    self.Values =
        type(values) == "table"
        and values
        or {}

    local newSelected = {}

    for _, value in ipairs(
        self.Values
    ) do

        if self.Selected[value] then

            newSelected[value] =
                true
        end
    end

    self.Selected =
        newSelected

    self:_BuildOptions()
    self:_UpdateValueText()
    self:_UpdateOptions()

    requestParentRelayout(
        self,
        false
    )
end

function Dropdown:Refesh(
    values
)

    self:Refresh(
        values
    )
end

------------------------------------------------------------
-- FONT
------------------------------------------------------------

function Dropdown:_SetInstanceFont(
    instance,
    fontType
)

    if typeof(fontType) == "string"
        and string.find(
            string.lower(fontType),
            "rbxassetid",
            1,
            true
        ) then

        local ok, customFont =
            pcall(
                function()

                    return Font.new(
                        fontType
                    )
                end
            )

        if ok and customFont then

            instance.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType ==
            Enum.Font then

        instance.Font =
            fontType
    end
end

function Dropdown:SetFont(
    fontType
)

    if self.Destroyed then
        return
    end

    self:_SetInstanceFont(
        self.ToggleButton,
        fontType
    )

    self:_SetInstanceFont(
        self.ValueLabel,
        fontType
    )

    if self.TitleLabel then

        self:_SetInstanceFont(
            self.TitleLabel,
            fontType
        )
    end

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            self:_SetInstanceFont(
                child,
                fontType
            )

            child.TextSize = 13
        end
    end
end

------------------------------------------------------------
-- THEME
------------------------------------------------------------

function Dropdown:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.DropdownFrame.BorderColor3 =
        theme.Border

    self.OptionsFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.OptionsFrame.BorderColor3 =
        theme.Border

    self.ToggleButton.TextColor3 =
        theme.Text

    self.ValueLabel.TextColor3 =
        theme.Text

    if self.TitleLabel then

        self.TitleLabel.TextColor3 =
            theme.Text
    end

    self.ToggleButton.TextSize = 14
    self.ValueLabel.TextSize = 13

    if self.TitleLabel then
        self.TitleLabel.TextSize = 13
    end

    self:SetFont(
        self.Window.CurrentFont
    )

    self:_UpdateOptions()

    requestParentRelayout(
        self,
        false
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Dropdown:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true
    self.Opened = false
    self._RowLayoutHeight = 0

    table.clear(
        self.OptionValues
    )

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