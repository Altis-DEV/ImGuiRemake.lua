-- File: ImGuiRemake.lua/Components/Row.lua

local Row = {}
Row.__index = Row

local PADDING_LEFT = 0
local PADDING_RIGHT = 0
local PADDING_TOP = 0
local PADDING_BOTTOM = 0

local ELEMENT_GAP = 5

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Row.new(parent, options)
    options = options or {}

    local self = setmetatable({}, Row)

    self.Parent = parent
    self.Window = parent.Window

    self.Elements = {}
    self.Destroyed = false

    --------------------------------------------------------
    -- MAIN CONTAINER
    --
    -- Row itself = 1 element of Parent
    --------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name = "Row"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0

    self.Container.Parent =
        parent.ContentFrame

    --------------------------------------------------------
    -- CONTENT FRAME
    --
    -- Existing components use:
    -- parent.ContentFrame
    --------------------------------------------------------

    self.ContentFrame =
        Instance.new("Frame")

    self.ContentFrame.Name =
        "ContentFrame"

    self.ContentFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.ContentFrame.AutomaticSize =
        Enum.AutomaticSize.Y

    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0

    self.ContentFrame.Parent =
        self.Container

    --------------------------------------------------------
    -- PADDING
    --------------------------------------------------------

    self.Padding =
        Instance.new("UIPadding")

    self.Padding.Name =
        "RowPadding"

    self.Padding.PaddingLeft =
        UDim.new(
            0,
            PADDING_LEFT
        )

    self.Padding.PaddingRight =
        UDim.new(
            0,
            PADDING_RIGHT
        )

    self.Padding.PaddingTop =
        UDim.new(
            0,
            PADDING_TOP
        )

    self.Padding.PaddingBottom =
        UDim.new(
            0,
            PADDING_BOTTOM
        )

    self.Padding.Parent =
        self.ContentFrame

    --------------------------------------------------------
    -- HORIZONTAL LAYOUT
    --------------------------------------------------------

    self.Layout =
        Instance.new("UIListLayout")

    self.Layout.Name =
        "RowLayout"

    self.Layout.FillDirection =
        Enum.FillDirection.Horizontal

    self.Layout.HorizontalAlignment =
        Enum.HorizontalAlignment.Left

    self.Layout.VerticalAlignment =
        Enum.VerticalAlignment.Center

    self.Layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.Layout.Padding =
        UDim.new(
            0,
            ELEMENT_GAP
        )

    self.Layout.Parent =
        self.ContentFrame

    --------------------------------------------------------
    -- REGISTER ROW AS ONE ELEMENT
    --------------------------------------------------------

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- REFRESH SIZE
------------------------------------------------------------

function Row:_RefreshSize()
    if self.Destroyed then
        return
    end

    local height =
        self.Layout.AbsoluteContentSize.Y

    self.ContentFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            height
        )
end

------------------------------------------------------------
-- CHILD CREATION
------------------------------------------------------------

function Row:Button(options)

    if not self.Window.ButtonModule then
        warn(
            "ButtonModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.ButtonModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Toggle(options)

    if not self.Window.ToggleModule then
        warn(
            "ToggleModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.ToggleModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Slider(options)

    if not self.Window.SliderModule then
        warn(
            "SliderModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.SliderModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Dropdown(options)

    if not self.Window.DropdownModule then
        warn(
            "DropdownModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.DropdownModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:TextBox(options)

    if not self.Window.TextBoxModule then
        warn(
            "TextBoxModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.TextBoxModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Paragraph(options)

    if not self.Window.ParagraphModule then
        warn(
            "ParagraphModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.ParagraphModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Label(options)

    if not self.Window.LabelModule then
        warn(
            "LabelModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.LabelModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Divider(options)

    if not self.Window.DividerModule then
        warn(
            "DividerModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.DividerModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

function Row:Image(options)

    if not self.Window.ImageModule then
        warn(
            "ImageModule chưa được load!"
        )
        return nil
    end

    local element =
        self.Window.ImageModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return element
end

------------------------------------------------------------
-- NESTED ROW
------------------------------------------------------------

function Row:Row(options)

    if not self.Window.RowModule then
        warn(
            "RowModule chưa được load!"
        )
        return nil
    end

    local row =
        self.Window.RowModule.new(
            self,
            options or {}
        )

    self:_RefreshSize()

    return row
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Row:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true

    --------------------------------------------------------
    -- DESTROY CHILD ELEMENTS
    --------------------------------------------------------

    for i = #self.Elements, 1, -1 do

        local element =
            self.Elements[i]

        if element
            and element.Destroy then

            element:Destroy()

        end
    end

    table.clear(
        self.Elements
    )

    --------------------------------------------------------
    -- DESTROY INSTANCE
    --------------------------------------------------------

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

    --------------------------------------------------------
    -- REMOVE FROM PARENT
    --------------------------------------------------------

    for i, element in ipairs(
        self.Parent.Elements
    ) do

        if element == self then

            table.remove(
                self.Parent.Elements,
                i
            )

            break
        end
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Row:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    for _, element in ipairs(
        self.Elements
    ) do

        if element.UpdateTheme then
            element:UpdateTheme(theme)
        end

    end
end

------------------------------------------------------------
-- UPDATE FONT
------------------------------------------------------------

function Row:SetFont(fontType)

    if self.Destroyed then
        return
    end

    for _, element in ipairs(
        self.Elements
    ) do

        if element.SetFont then
            element:SetFont(fontType)
        end

    end
end

return Row
