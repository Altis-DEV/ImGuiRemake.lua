-- File: ImGuiRemake.lua/Components/Dropdown.lua

local Dropdown = {}
Dropdown.__index = Dropdown

local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local ELEMENT_HEIGHT = 30
local OPTION_HEIGHT = 30

local DROPDOWN_WIDTH_SCALE = 0.5
local MAX_VISIBLE_OPTIONS = 3

local ARROW_ROTATION_CLOSED = -90
local ARROW_ROTATION_OPEN = 0

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Dropdown.new(tab, options)
    options = options or {}

    local self = setmetatable({}, Dropdown)

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(
        options.Title or "Dropdown"
    )

    self.Multi = options.Multi == true

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    self.Values = {}
    self.Selected = {}

    self.Opened = false
    self.Destroyed = false

    --------------------------------------------------------
    -- LOAD VALUES
    --------------------------------------------------------

    if type(options.Value) == "table" then
        for _, value in ipairs(options.Value) do
            table.insert(
                self.Values,
                value
            )
        end
    end

    --------------------------------------------------------
    -- INITIAL SELECTED
    --------------------------------------------------------

    if type(options.Selected) == "table" then

        for _, value in ipairs(options.Selected) do

            if self:_ContainsValue(value) then
                self.Selected[value] = true
            end
        end

    elseif options.Selected ~= nil then

        if self:_ContainsValue(options.Selected) then
            self.Selected[options.Selected] = true
        end
    end

    local theme =
        self.Window.ThemeData

    --------------------------------------------------------
    -- MAIN CONTAINER
    --------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        self.Title .. "_Dropdown"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

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

    self.MainRow.BackgroundTransparency =
        1

    self.MainRow.BorderSizePixel =
        0

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
            DROPDOWN_WIDTH_SCALE,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.DropdownFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.DropdownFrame.BorderColor3 =
        theme.Border

    self.DropdownFrame.BorderSizePixel =
        1

    self.DropdownFrame.Parent =
        self.MainRow

    --------------------------------------------------------
    -- ARROW BUTTON
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

    self.ToggleButton.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.ToggleButton.BackgroundTransparency =
        1

    self.ToggleButton.BorderSizePixel =
        0

    self.ToggleButton.Text =
        "▼"

    self.ToggleButton.Rotation =
        ARROW_ROTATION_CLOSED

    self.ToggleButton.TextSize =
        14

    self.ToggleButton.Font =
        self.Window.CurrentFont

    self.ToggleButton.TextColor3 =
        theme.Text

    self.ToggleButton.AutoButtonColor =
        false

    self.ToggleButton.Parent =
        self.DropdownFrame

    --------------------------------------------------------
    -- SELECTED VALUE
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

    self.ValueLabel.BackgroundTransparency =
        1

    self.ValueLabel.TextColor3 =
        theme.Text

    self.ValueLabel.TextSize =
        13

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

    self.TitleLabel.BackgroundTransparency =
        1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize =
        13

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.MainRow

    --------------------------------------------------------
    -- OPTIONS FRAME
    --------------------------------------------------------

    self.OptionsFrame =
        Instance.new("ScrollingFrame")

    self.OptionsFrame.Name =
        "Options"

    self.OptionsFrame.Size =
        UDim2.new(
            DROPDOWN_WIDTH_SCALE,
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

    self.OptionsFrame.BorderSizePixel =
        1

    self.OptionsFrame.ScrollBarThickness =
        4

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
    -- OPTIONS LAYOUT
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
    -- INITIAL VALUE TEXT
    --------------------------------------------------------

    self:_UpdateValueText()

    --------------------------------------------------------
    -- BUILD OPTIONS
    --------------------------------------------------------

    self:_BuildOptions()

    --------------------------------------------------------
    -- OPEN / CLOSE
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

    --------------------------------------------------------
    -- REGISTER
    --------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CHECK VALUE
------------------------------------------------------------

function Dropdown:_ContainsValue(value)

    for _, item in ipairs(
        self.Values
    ) do

        if item == value then
            return true
        end

    end

    return false
end

------------------------------------------------------------
-- SELECTED TEXT
------------------------------------------------------------

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
-- CREATE OPTION
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

    --------------------------------------------------------
    -- STORE ACTUAL VALUE
    --
    -- Không dùng Name để xác định value nữa.
    --------------------------------------------------------

    option._DropdownValue =
        value

    option.Size =
        UDim2.new(
            1,
            -6,
            0,
            OPTION_HEIGHT
        )

    --------------------------------------------------------
    -- INITIAL COLOR
    --
    -- QUAN TRỌNG:
    -- áp dụng Selected ngay khi tạo.
    --------------------------------------------------------

    if self.Selected[value] then

        option.BackgroundColor3 =
            theme.DropdownOptionSelected

    else

        option.BackgroundColor3 =
            theme.DropdownOption
    end

    option.BorderSizePixel =
        0

    option.Text =
        tostring(value)

    option.TextSize =
        13

    option.Font =
        self.Window.CurrentFont

    option.TextColor3 =
        theme.Text

    option.TextXAlignment =
        Enum.TextXAlignment.Left

    option.TextYAlignment =
        Enum.TextYAlignment.Center

    option.AutoButtonColor =
        false

    option.LayoutOrder =
        index

    option.Parent =
        self.OptionsFrame

    --------------------------------------------------------
    -- PADDING
    --------------------------------------------------------

    local padding =
        Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(
            0,
            8
        )

    padding.PaddingRight =
        UDim.new(
            0,
            8
        )

    padding.Parent =
        option

    --------------------------------------------------------
    -- HOVER
    --------------------------------------------------------

    option.MouseEnter:Connect(
        function()

            if self.Destroyed then
                return
            end

            if not self.Selected[value] then

                option.BackgroundColor3 =
                    self.Window.ThemeData.DropdownOptionHover

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

    --------------------------------------------------------
    -- CLICK
    --------------------------------------------------------

    option.MouseButton1Click:Connect(
        function()

            if self.Destroyed then
                return
            end

            self:_SelectValue(
                value
            )
        end
    )

    return option
end

------------------------------------------------------------
-- BUILD OPTIONS
------------------------------------------------------------

function Dropdown:_BuildOptions()

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- REMOVE OLD OPTIONS
    --------------------------------------------------------

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then
            child:Destroy()
        end

    end

    --------------------------------------------------------
    -- BUILD NEW OPTIONS
    --------------------------------------------------------

    for index, value in ipairs(
        self.Values
    ) do

        local option =
            self:_CreateOption(
                value,
                index
            )

        ----------------------------------------------------
        -- IMPORTANT:
        -- Refresh color after creation too.
        ----------------------------------------------------

        self:_UpdateOptionColor(
            option,
            value
        )
    end

    self:_UpdateOptionsSize()
end

------------------------------------------------------------
-- OPTION COLOR
------------------------------------------------------------

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

    --------------------------------------------------------
    -- SELECTED
    --------------------------------------------------------

    if self.Selected[value] then

        option.BackgroundColor3 =
            theme.DropdownOptionSelected

    else

        option.BackgroundColor3 =
            theme.DropdownOption

    end

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    option.TextColor3 =
        theme.Text

    option.TextSize =
        13

    self:_SetInstanceFont(
        option,
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- REFRESH OPTION COLORS
------------------------------------------------------------

function Dropdown:_UpdateOptions()

    if self.Destroyed then
        return
    end

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            local value =
                child._DropdownValue

            if value ~= nil then

                self:_UpdateOptionColor(
                    child,
                    value
                )
            end
        end
    end
end

------------------------------------------------------------
-- UPDATE OPTIONS HEIGHT
------------------------------------------------------------

function Dropdown:_UpdateOptionsSize()

    local count =
        #self.Values

    local visible =
        math.min(
            count,
            MAX_VISIBLE_OPTIONS
        )

    self.OpenHeight =
        visible * OPTION_HEIGHT
end

------------------------------------------------------------
-- SELECT
------------------------------------------------------------

function Dropdown:_SelectValue(value)

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

    --------------------------------------------------------
    -- UPDATE DISPLAY
    --------------------------------------------------------

    self:_UpdateValueText()
    self:_UpdateOptions()

    --------------------------------------------------------
    -- CALLBACK
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- SINGLE SELECT CLOSE
    --------------------------------------------------------

    if not self.Multi then
        self:SetOpen(false)
    end
end

------------------------------------------------------------
-- GET SELECTED
------------------------------------------------------------

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

function Dropdown:SetOpen(state)

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

    --------------------------------------------------------
    -- ARROW
    --------------------------------------------------------

    local arrowRotation =
        state
        and ARROW_ROTATION_OPEN
        or ARROW_ROTATION_CLOSED

    TweenService:Create(
        self.ToggleButton,

        TweenInfo.new(
            0.2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),

        {
            Rotation =
                arrowRotation
        }
    ):Play()

    --------------------------------------------------------
    -- OPEN
    --------------------------------------------------------

    if state then

        self.OptionsFrame.Visible =
            true

        TweenService:Create(
            self.OptionsFrame,

            TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),

            {
                Size =
                    UDim2.new(
                        DROPDOWN_WIDTH_SCALE,
                        0,
                        0,
                        self.OpenHeight
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
                    Size =
                        UDim2.new(
                            DROPDOWN_WIDTH_SCALE,
                            0,
                            0,
                            0
                        )
                }
            )

        tween:Play()

        tween.Completed:Connect(
            function()

                if not self.Opened
                    and not self.Destroyed then

                    self.OptionsFrame.Visible =
                        false
                end
            end
        )
    end
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function Dropdown:SetTitle(
    newTitle
)

    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title
        .. "_Dropdown"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- ADD
------------------------------------------------------------

function Dropdown:Add(value)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TABLE
    --------------------------------------------------------

    if type(value) == "table" then

        for _, item in ipairs(
            value
        ) do

            if not self:_ContainsValue(item) then

                table.insert(
                    self.Values,
                    item
                )
            end
        end

    --------------------------------------------------------
    -- SINGLE VALUE
    --------------------------------------------------------

    else

        if not self:_ContainsValue(value) then

            table.insert(
                self.Values,
                value
            )
        end
    end

    --------------------------------------------------------
    -- REBUILD
    --
    -- Selected table is intentionally NOT cleared.
    --------------------------------------------------------

    self:_BuildOptions()
    self:_UpdateValueText()
    self:_UpdateOptions()
end

------------------------------------------------------------
-- DELETE
------------------------------------------------------------

function Dropdown:Delete(
    value
)

    if self.Destroyed then
        return
    end

    for i = #self.Values, 1, -1 do

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
end

------------------------------------------------------------
-- REFRESH
------------------------------------------------------------

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

    --------------------------------------------------------
    -- KEEP ONLY VALID SELECTIONS
    --------------------------------------------------------

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
end

------------------------------------------------------------
-- REFESH
------------------------------------------------------------

function Dropdown:Refesh(
    values
)

    self:Refresh(
        values
    )
end

------------------------------------------------------------
-- FONT HELPER
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
        and fontType.EnumType
            == Enum.Font then

        instance.Font =
            fontType
    end
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

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

    self:_SetInstanceFont(
        self.TitleLabel,
        fontType
    )

    for _, child in ipairs(
        self.OptionsFrame:GetChildren()
    ) do

        if child:IsA("TextButton") then

            self:_SetInstanceFont(
                child,
                fontType
            )

            child.TextSize =
                13
        end
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Dropdown:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- MAIN FRAME
    --------------------------------------------------------

    self.DropdownFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.DropdownFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- OPTIONS FRAME
    --------------------------------------------------------

    self.OptionsFrame.BackgroundColor3 =
        theme.DropdownFrame

    self.OptionsFrame.BorderColor3 =
        theme.Border

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
    -- FONT
    --------------------------------------------------------

    self.ToggleButton.TextSize =
        14

    self.ValueLabel.TextSize =
        13

    self.TitleLabel.TextSize =
        13

    self:SetFont(
        self.Window.CurrentFont
    )

    --------------------------------------------------------
    -- OPTIONS
    --------------------------------------------------------

    self:_UpdateOptions()
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Dropdown:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed =
        true

    self.Opened =
        false

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
