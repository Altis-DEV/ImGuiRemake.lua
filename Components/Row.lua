-- File: ImGuiRemake.lua/Components/Row.lua

local Row = {}
Row.__index = Row

local GAP = 5
local DEFAULT_WIDTH = 100

local function getElementInstance(element)
    if not element then
        return nil
    end

    if element.Instance
        and element.Instance:IsA("GuiObject") then
        return element.Instance
    end

    if element.Container
        and element.Container:IsA("GuiObject") then
        return element.Container
    end

    return nil
end

local function getUDimWidth(udim, parentWidth)
    if not udim then
        return nil
    end

    return
        parentWidth * udim.X.Scale
        + udim.X.Offset
end

function Row.new(parent, options)
    options = options or {}

    local self = setmetatable({}, Row)

    self.Parent = parent
    self.Window = parent.Window

    self.Elements = {}
    self.Cells = {}

    self.Destroyed = false
    self._AutoFill = options.AutoFill == true
    self._Relayouting = false
    self._LastWidth = 0

    ------------------------------------------------------------
    -- CONTAINER
    ------------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name = "Row"
    self.Container.Size = UDim2.new(1, 0, 0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = parent.ContentFrame

    ------------------------------------------------------------
    -- CONTENT
    ------------------------------------------------------------

    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ClipsDescendants = false
    self.ContentFrame.Parent = self.Container

    ------------------------------------------------------------
    -- CONTAINER WIDTH CHANGED
    ------------------------------------------------------------

    self.Container:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(function()
        if self.Destroyed then
            return
        end

        local width = self.Container.AbsoluteSize.X

        if width ~= self._LastWidth then
            self._LastWidth = width
            self:_Relayout()
        end
    end)

    table.insert(parent.Elements, self)

    return self
end

------------------------------------------------------------
-- CREATE CELL
------------------------------------------------------------

function Row:_CreateCell()
    local cell = Instance.new("Frame")

    cell.Name =
        "Cell_" ..
        tostring(#self.Cells + 1)

    cell.BackgroundTransparency = 1
    cell.BorderSizePixel = 0
    cell.AutomaticSize = Enum.AutomaticSize.Y
    cell.Parent = self.ContentFrame

    table.insert(self.Cells, cell)

    return cell
end

------------------------------------------------------------
-- GET NATURAL WIDTH
------------------------------------------------------------

function Row:_GetNaturalWidth(element, instance)
    if element.WidthAtRow then
        return nil
    end

    local width =
        instance.AbsoluteSize.X

    if width and width > 0 then
        return width
    end

    local size =
        instance.Size

    if size.X.Scale ~= 0 then
        local parentWidth =
            self.Container.AbsoluteSize.X

        width =
            parentWidth * size.X.Scale
            + size.X.Offset
    else
        width =
            size.X.Offset
    end

    if width <= 0 then
        width = DEFAULT_WIDTH
    end

    return width
end

------------------------------------------------------------
-- GET ELEMENT WIDTH
------------------------------------------------------------

function Row:_GetElementWidth(
    element,
    instance,
    rowWidth
)
    if element.WidthAtRow then
        local width =
            getUDimWidth(
                element.WidthAtRow,
                rowWidth
            )

        if width then
            return math.max(
                1,
                width
            )
        end
    end

    if element._NaturalRowWidth
        and element._NaturalRowWidth > 0 then

        return element._NaturalRowWidth
    end

    return math.max(
        1,
        self:_GetNaturalWidth(
            element,
            instance
        )
        or DEFAULT_WIDTH
    )
end

------------------------------------------------------------
-- APPLY ELEMENT LAYOUT
------------------------------------------------------------

function Row:_ApplyElementLayout(
    element,
    instance,
    width
)
    if not element
        or not instance then
        return
    end

    --------------------------------------------------------
    -- ROOT ELEMENT
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
    -- BUTTON
    --------------------------------------------------------

    if element.Instance == instance then
        instance.AutomaticSize =
            Enum.AutomaticSize.Y

        return
    end

    --------------------------------------------------------
    -- SLIDER
    --------------------------------------------------------

    if element.SliderFrame then

        if element.TitleLabel then

            element.SliderFrame.Size =
                UDim2.new(
                    0.5,
                    0,
                    1,
                    0
                )

        else

            element.SliderFrame.Size =
                UDim2.new(
                    1,
                    0,
                    1,
                    0
                )

        end

        return
    end

    --------------------------------------------------------
    -- DROPDOWN
    --------------------------------------------------------

    if element.DropdownFrame then

        local height =
            element.DropdownFrame.Size.Y.Offset

        if height <= 0 then
            height = 30
        end

        if element.TitleLabel then

            element.DropdownFrame.Size =
                UDim2.new(
                    0.5,
                    0,
                    0,
                    height
                )

        else

            element.DropdownFrame.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    height
                )

        end

        ----------------------------------------------------
        -- Options use actual dropdown width.
        ----------------------------------------------------

        if element.OptionsFrame then

            local optionHeight =
                element.OptionsFrame.Size.Y.Offset

            element.OptionsFrame.Size =
                UDim2.new(
                    element.DropdownFrame.Size.X.Scale,
                    element.DropdownFrame.Size.X.Offset,
                    0,
                    optionHeight
                )
        end

        return
    end

    --------------------------------------------------------
    -- TEXTBOX
    --------------------------------------------------------

    if element.TextBoxFrame then

        local height =
            element.TextBoxFrame.Size.Y.Offset

        if height <= 0 then
            height = 30
        end

        if element.TitleLabel then

            element.TextBoxFrame.Size =
                UDim2.new(
                    0.5,
                    0,
                    0,
                    height
                )

        else

            element.TextBoxFrame.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    height
                )

        end

        return
    end
end

------------------------------------------------------------
-- ATTACH ELEMENT
------------------------------------------------------------

function Row:_AttachElement(element)
    local instance =
        getElementInstance(element)

    if not instance then
        return false
    end

    --------------------------------------------------------
    -- CAPTURE NATURAL WIDTH
    --
    -- Done before moving the element into the cell.
    --------------------------------------------------------

    element._NaturalRowWidth =
        self:_GetNaturalWidth(
            element,
            instance
        )

    element._InRow = true

    --------------------------------------------------------
    -- CREATE CELL
    --------------------------------------------------------

    local cell =
        self:_CreateCell()

    --------------------------------------------------------
    -- MOVE ELEMENT
    --------------------------------------------------------

    instance.Parent =
        cell

    --------------------------------------------------------
    -- CELL WIDTH
    --
    -- Actual width is assigned by _Relayout().
    --------------------------------------------------------

    cell.Size =
        UDim2.new(
            0,
            element._NaturalRowWidth
                or DEFAULT_WIDTH,
            0,
            0
        )

    cell.AutomaticSize =
        Enum.AutomaticSize.Y

    --------------------------------------------------------
    -- INITIAL ELEMENT LAYOUT
    --------------------------------------------------------

    self:_ApplyElementLayout(
        element,
        instance,
        cell.AbsoluteSize.X
    )

    --------------------------------------------------------
    -- WATCH ELEMENT SIZE
    --
    -- Important for Paragraph, Label, nested Row,
    -- Section and other vertically auto-sized elements.
    --------------------------------------------------------

    instance:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(function()

        if self.Destroyed then
            return
        end

        if self._Relayouting then
            return
        end

        task.defer(function()
            if not self.Destroyed then
                self:_Relayout()
            end
        end)
    end)

    self:_Relayout()

    return true
end

------------------------------------------------------------
-- RELAYOUT
------------------------------------------------------------

function Row:_Relayout()
    if self.Destroyed
        or self._Relayouting then
        return
    end

    self._Relayouting = true

    local rowWidth =
        self.Container.AbsoluteSize.X

    if rowWidth <= 0 then
        self._Relayouting = false
        return
    end

    --------------------------------------------------------
    -- AUTO FILL
    --
    -- AutoFill disables wrapping.
    --------------------------------------------------------

    if self._AutoFill then

        local count =
            #self.Cells

        if count == 0 then
            self.Container.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    0
                )

            self._Relayouting = false
            return
        end

        local totalGap =
            GAP
            * math.max(
                count - 1,
                0
            )

        local width =
            math.max(
                1,
                (
                    rowWidth
                    - totalGap
                ) / count
            )

        local x = 0
        local maxHeight = 0

        for i, cell in ipairs(
            self.Cells
        ) do

            cell.Position =
                UDim2.new(
                    0,
                    x,
                    0,
                    0
                )

            cell.Size =
                UDim2.new(
                    0,
                    width,
                    0,
                    0
                )

            cell.AutomaticSize =
                Enum.AutomaticSize.Y

            local element =
                self.Elements[i]

            local instance =
                getElementInstance(
                    element
                )

            if instance then
                self:_ApplyElementLayout(
                    element,
                    instance,
                    width
                )
            end

            x =
                x
                + width
                + GAP

            maxHeight =
                math.max(
                    maxHeight,
                    cell.AbsoluteSize.Y
                )
        end

        task.defer(function()

            if self.Destroyed then
                return
            end

            local height = 0

            for _, cell in ipairs(
                self.Cells
            ) do
                height =
                    math.max(
                        height,
                        cell.AbsoluteSize.Y
                    )
            end

            self.ContentFrame.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    height
                )

            self.Container.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    height
                )

            self._Relayouting = false
        end)

        return
    end

    --------------------------------------------------------
    -- WRAPPING
    --
    -- Default Row behavior.
    --------------------------------------------------------

    local x = 0
    local y = 0
    local lineHeight = 0

    for i, cell in ipairs(
        self.Cells
    ) do

        local element =
            self.Elements[i]

        local instance =
            getElementInstance(
                element
            )

        local width =
            self:_GetElementWidth(
                element,
                instance,
                rowWidth
            )

        width =
            math.clamp(
                width,
                1,
                rowWidth
            )

        ----------------------------------------------------
        -- NEW LINE
        ----------------------------------------------------

        if x > 0
            and x + width > rowWidth then

            x = 0

            y =
                y
                + lineHeight
                + GAP

            lineHeight = 0
        end

        ----------------------------------------------------
        -- CELL
        ----------------------------------------------------

        cell.Position =
            UDim2.new(
                0,
                x,
                0,
                y
            )

        cell.Size =
            UDim2.new(
                0,
                width,
                0,
                0
            )

        cell.AutomaticSize =
            Enum.AutomaticSize.Y

        if instance then

            self:_ApplyElementLayout(
                element,
                instance,
                width
            )
        end

        ----------------------------------------------------
        -- UPDATE LINE HEIGHT
        ----------------------------------------------------

        local cellHeight =
            cell.AbsoluteSize.Y

        lineHeight =
            math.max(
                lineHeight,
                cellHeight
            )

        x =
            x
            + width
            + GAP
    end

    --------------------------------------------------------
    -- FINAL HEIGHT
    --------------------------------------------------------

    task.defer(function()

        if self.Destroyed then
            return
        end

        local height = 0
        local currentY = 0
        local currentLineHeight = 0
        local currentX = 0

        for i, cell in ipairs(
            self.Cells
        ) do

            local cellX =
                cell.Position.X.Offset

            local cellY =
                cell.Position.Y.Offset

            local cellHeight =
                cell.AbsoluteSize.Y

            if cellY ~= currentY then

                height =
                    math.max(
                        height,
                        currentY
                        + currentLineHeight
                    )

                currentY =
                    cellY

                currentLineHeight =
                    cellHeight

            else

                currentLineHeight =
                    math.max(
                        currentLineHeight,
                        cellHeight
                    )
            end

            currentX =
                math.max(
                    currentX,
                    cellX
                    + cell.AbsoluteSize.X
                )
        end

        height =
            math.max(
                height,
                currentY
                + currentLineHeight
            )

        self.ContentFrame.Size =
            UDim2.new(
                1,
                0,
                0,
                height
        )

        self.Container.Size =
            UDim2.new(
                1,
                0,
                0,
                height
            )

        self._Relayouting = false
    end)
end

------------------------------------------------------------
-- REFRESH HEIGHT
------------------------------------------------------------

function Row:_RefreshHeight()
    if self.Destroyed then
        return
    end

    self:_Relayout()
end

------------------------------------------------------------
-- AUTO FILL
------------------------------------------------------------

function Row:AutoFill(state)
    if self.Destroyed then
        return
    end

    self._AutoFill =
        state == true

    self:_Relayout()
end

------------------------------------------------------------
-- ADD ELEMENT
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

    self:_Relayout()

    return element
end

------------------------------------------------------------
-- BUTTON
------------------------------------------------------------

function Row:Button(options)
    if not self.Window.ButtonModule then
        warn("ButtonModule chưa được load!")
        return nil
    end

    local element =
        self.Window.ButtonModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

function Row:Toggle(options)
    if not self.Window.ToggleModule then
        warn("ToggleModule chưa được load!")
        return nil
    end

    local element =
        self.Window.ToggleModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

function Row:Slider(options)
    if not self.Window.SliderModule then
        warn("SliderModule chưa được load!")
        return nil
    end

    local element =
        self.Window.SliderModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

function Row:Dropdown(options)
    if not self.Window.DropdownModule then
        warn("DropdownModule chưa được load!")
        return nil
    end

    local element =
        self.Window.DropdownModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- TEXTBOX
------------------------------------------------------------

function Row:TextBox(options)
    if not self.Window.TextBoxModule then
        warn("TextBoxModule chưa được load!")
        return nil
    end

    local element =
        self.Window.TextBoxModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- TEXT INPUT
------------------------------------------------------------

function Row:TextInput(options)
    if not self.Window.TextInputModule then
        warn("TextInputModule chưa được load!")
        return nil
    end

    local element =
        self.Window.TextInputModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- CONSOLE
------------------------------------------------------------

function Row:Console(options)
    if not self.Window.ConsoleModule then
        warn("ConsoleModule chưa được load!")
        return nil
    end

    local element =
        self.Window.ConsoleModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- PARAGRAPH
------------------------------------------------------------

function Row:Paragraph(options)
    if not self.Window.ParagraphModule then
        warn("ParagraphModule chưa được load!")
        return nil
    end

    local element =
        self.Window.ParagraphModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

function Row:Label(options)
    if not self.Window.LabelModule then
        warn("LabelModule chưa được load!")
        return nil
    end

    local element =
        self.Window.LabelModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- COLOR
------------------------------------------------------------

function Row:Color(options)
    if not self.Window.ColorModule then
        warn("ColorModule chưa được load!")
        return nil
    end

    local element =
        self.Window.ColorModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

function Row:Divider(options)
    if not self.Window.DividerModule then
        warn("DividerModule chưa được load!")
        return nil
    end

    local element =
        self.Window.DividerModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- IMAGE
------------------------------------------------------------

function Row:Image(options)
    if not self.Window.ImageModule then
        warn("ImageModule chưa được load!")
        return nil
    end

    local element =
        self.Window.ImageModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- SECTION
------------------------------------------------------------

function Row:Section(options)
    if not self.Window.SectionModule then
        warn("SectionModule chưa được load!")
        return nil
    end

    local element =
        self.Window.SectionModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- NESTED ROW
------------------------------------------------------------

function Row:Row(options)
    if not self.Window.RowModule then
        warn("RowModule chưa được load!")
        return nil
    end

    local element =
        self.Window.RowModule.new(
            self,
            options or {}
        )

    return self:_AddElement(
        element
    )
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

        if element
            and element.UpdateTheme then

            local ok, err =
                pcall(function()
                    element:UpdateTheme(
                        theme
                    )
                end)

            if not ok then
                warn(
                    "Row child theme update failed:",
                    err
                )
            end
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

        if element
            and element.SetFont then

            local ok, err =
                pcall(function()
                    element:SetFont(
                        fontType
                    )
                end)

            if not ok then
                warn(
                    "Row child font update failed:",
                    err
                )
            end
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

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

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
