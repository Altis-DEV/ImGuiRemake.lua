-- File: ImGuiRemake.lua/Components/Row.lua

local Row = {}
Row.__index = Row

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local GAP = 5

------------------------------------------------------------
-- GET ROOT INSTANCE OF ELEMENT
------------------------------------------------------------

local function getElementInstance(element)

    if not element then
        return nil
    end

    -- Button
    if element.Instance
        and element.Instance:IsA("GuiObject") then

        return element.Instance
    end

    -- Toggle / Paragraph / TextBox / Slider / Dropdown /
    -- Label / Image / Section / Row
    if element.Container
        and element.Container:IsA("GuiObject") then

        return element.Container
    end

    return nil
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Row.new(parent, options)

    options = options or {}

    local self = setmetatable({}, Row)

    self.Parent = parent
    self.Window = parent.Window

    self.Elements = {}
    self.Cells = {}

    self.Destroyed = false

    --------------------------------------------------------
    -- ROW CONTAINER
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
    -- CONTENT
    --------------------------------------------------------

    self.ContentFrame = Instance.new("Frame")

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
            GAP
        )

    self.Layout.Parent =
        self.ContentFrame

    --------------------------------------------------------
    -- WATCH HEIGHT
    --------------------------------------------------------

    self.Layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(
        function()

            if self.Destroyed then
                return
            end

            self:_RefreshHeight()

        end
    )

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
-- CREATE CELL
------------------------------------------------------------

function Row:_CreateCell()

    local cell =
        Instance.new("Frame")

    cell.Name =
        "Cell_" ..
        tostring(#self.Cells + 1)

    cell.BackgroundTransparency =
        1

    cell.BorderSizePixel =
        0

    cell.LayoutOrder =
        #self.Cells + 1

    cell.Parent =
        self.ContentFrame

    table.insert(
        self.Cells,
        cell
    )

    return cell
end

------------------------------------------------------------
-- UPDATE CELL SIZES
------------------------------------------------------------

function Row:_RefreshCellSizes()

    local count =
        #self.Cells

    if count == 0 then
        return
    end

    --------------------------------------------------------
    -- Total width consumed by gaps
    --------------------------------------------------------

    local totalGap =
        GAP * math.max(
            count - 1,
            0
        )

    --------------------------------------------------------
    -- Each cell gets equal width
    --------------------------------------------------------

    local scale =
        1 / count

    for _, cell in ipairs(
        self.Cells
    ) do

        cell.Size =
            UDim2.new(
                scale,
                -(
                    totalGap * scale
                ),
                0,
                0
            )

        cell.AutomaticSize =
            Enum.AutomaticSize.Y
    end
end

------------------------------------------------------------
-- PREPARE ELEMENT FOR ROW
------------------------------------------------------------

function Row:_AttachElement(element)

    local instance =
        getElementInstance(element)

    if not instance then
        return false
    end

    --------------------------------------------------------
    -- CREATE SLOT
    --------------------------------------------------------

    local cell =
        self:_CreateCell()

    --------------------------------------------------------
    -- MOVE ELEMENT INTO CELL
    --------------------------------------------------------

    instance.Parent =
        cell

    --------------------------------------------------------
    -- IMPORTANT:
    --
    -- Row controls horizontal size.
    -- Element controls its own vertical size.
    --------------------------------------------------------

    instance.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    instance.Size =
        UDim2.new(
            1,
            0,
            instance.Size.Y.Scale,
            instance.Size.Y.Offset
        )

    --------------------------------------------------------
    -- Disable horizontal AutomaticSize
    -- because Cell now controls width.
    --------------------------------------------------------

    if instance:IsA("GuiObject") then

        if instance.AutomaticSize ==
            Enum.AutomaticSize.X
            or instance.AutomaticSize ==
            Enum.AutomaticSize.XY then

            instance.AutomaticSize =
                Enum.AutomaticSize.Y

        end

    end

    self:_RefreshCellSizes()

    return true
end

------------------------------------------------------------
-- REFRESH HEIGHT
------------------------------------------------------------

function Row:_RefreshHeight()

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
-- GENERIC ADD
------------------------------------------------------------

function Row:_AddElement(element)

    if not element then
        return nil
    end

    table.insert(
        self.Elements,
        element
    )

    self:_AttachElement(
        element
    )

    self:_RefreshHeight()

    return element
end

------------------------------------------------------------
-- BUTTON
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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- TEXTBOX
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- PARAGRAPH
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

    return element
end

------------------------------------------------------------
-- IMAGE
------------------------------------------------------------

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

    self:_AddElement(
        element
    )

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

    local element =
        self.Window.RowModule.new(
            self,
            options or {}
        )

    self:_AddElement(
        element
    )

    return element
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
            element:UpdateTheme(
                theme
            )
        end

    end
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Row:SetFont(fontType)

    if self.Destroyed then
        return
    end

    for _, element in ipairs(
        self.Elements
    ) do

        if element.SetFont then
            element:SetFont(
                fontType
            )
        end

    end
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
    -- Destroy children
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

    table.clear(
        self.Cells
    )

    --------------------------------------------------------
    -- Destroy container
    --------------------------------------------------------

    if self.Container then

        self.Container:Destroy()

        self.Container =
            nil

    end

    --------------------------------------------------------
    -- Remove from parent
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

return Row
