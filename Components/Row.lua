-- File: ImGuiRemake.lua/Components/Row.lua

local Row = {}
Row.__index = Row

local TweenService =
    game:GetService("TweenService")

local GAP = 5
local DEFAULT_WIDTH = 100
local LAYOUT_ANIMATION_TIME = 0.22

------------------------------------------------------------
-- GET ELEMENT ROOT
------------------------------------------------------------

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

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Row.new(
    parent,
    options
)

    options =
        options or {}

    local self =
        setmetatable(
            {},
            Row
        )

    self.Parent =
        parent

    self.Window =
        parent.Window

    self.Elements = {}
    self.Slots = {}

    self.Destroyed =
        false

    --------------------------------------------------------
    -- AUTOFILL IS THE ONLY ROW MODE
    --------------------------------------------------------

    self.AutoFill =
        options.AutoFill ~= false

    self._Relayouting =
        false

    self._LastWidth =
        0

    --------------------------------------------------------
    -- ROOT
    --------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        "Row"

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.Container.Parent =
        parent.ContentFrame

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    self.ContentFrame =
        Instance.new("Frame")

    self.ContentFrame.Name =
        "ContentFrame"

    self.ContentFrame.BackgroundTransparency =
        1

    self.ContentFrame.BorderSizePixel =
        0

    self.ContentFrame.ClipsDescendants =
        false

    self.ContentFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.ContentFrame.Parent =
        self.Container

    --------------------------------------------------------
    -- WATCH ONLY ROW WIDTH
    --------------------------------------------------------

    self.Container:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(
        function()

            if self.Destroyed then
                return
            end

            local width =
                self.Container.AbsoluteSize.X

            if width ~= self._LastWidth then

                self._LastWidth =
                    width

                self:_Relayout(
                    false
                )
            end
        end
    )

    --------------------------------------------------------
    -- REGISTER
    --------------------------------------------------------

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CREATE SLOT
------------------------------------------------------------

function Row:_CreateSlot()

    local container =
        Instance.new("Frame")

    container.Name =
        "RowElementContainer_"
        .. tostring(
            #self.Slots + 1
        )

    container.BackgroundTransparency =
        1

    container.BorderSizePixel =
        0

    container.ClipsDescendants =
        false

    container.AutomaticSize =
        Enum.AutomaticSize.Y

    container.Parent =
        self.ContentFrame

    local slot = {
        Container = container,
        Element = nil,
        Width = DEFAULT_WIDTH,
        Height = 0,
    }

    table.insert(
        self.Slots,
        slot
    )

    return slot
end

------------------------------------------------------------
-- GET NATURAL WIDTH
------------------------------------------------------------

function Row:_GetNaturalWidth(
    element,
    instance
)

    if element.WidthAtRow then
        return nil
    end

    local width =
        instance.AbsoluteSize.X

    if width > 0 then
        return width
    end

    local size =
        instance.Size

    if size.X.Scale ~= 0 then

        width =
            self.Container.AbsoluteSize.X
            * size.X.Scale
            + size.X.Offset

    else

        width =
            size.X.Offset
    end

    if width <= 0 then
        width =
            DEFAULT_WIDTH
    end

    return width
end

------------------------------------------------------------
-- ATTACH ELEMENT
------------------------------------------------------------

function Row:_AttachElement(
    element
)

    local instance =
        getElementInstance(
            element
        )

    if not instance then
        return false
    end

    element._NaturalRowWidth =
        self:_GetNaturalWidth(
            element,
            instance
        )

    --------------------------------------------------------
    -- SLOT
    --------------------------------------------------------

    local slot =
        self:_CreateSlot()

    slot.Element =
        element

    element._InRow =
        true

    --------------------------------------------------------
    -- MOVE ELEMENT
    --------------------------------------------------------

    instance.Parent =
        slot.Container

    instance.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    --------------------------------------------------------
    -- FILL SLOT WIDTH
    --
    -- Y remains controlled by element itself.
    --------------------------------------------------------

    instance.Size =
        UDim2.new(
            1,
            0,
            instance.Size.Y.Scale,
            instance.Size.Y.Offset
        )

    slot.Width =
        element._NaturalRowWidth
        or DEFAULT_WIDTH

    return true
end

------------------------------------------------------------
-- GET SLOT HEIGHT
------------------------------------------------------------

function Row:_GetSlotHeight(
    slot
)

    local element =
        slot.Element

    --------------------------------------------------------
    -- Temporary layout override.
    --
    -- Dropdown / Section use this while animating.
    --------------------------------------------------------

    if element
        and element._RowLayoutHeight
        and element._RowLayoutHeight > 0 then

        return element._RowLayoutHeight
    end

    --------------------------------------------------------
    -- Actual slot height.
    --------------------------------------------------------

    local height =
        slot.Container.AbsoluteSize.Y

    if height > 0 then
        return height
    end

    --------------------------------------------------------
    -- Element fallback.
    --------------------------------------------------------

    local instance =
        getElementInstance(
            element
        )

    if instance then

        height =
            instance.AbsoluteSize.Y

        if height > 0 then
            return height
        end
    end

    if element
        and element.Height
        and tonumber(element.Height) then

        return math.max(
            1,
            tonumber(element.Height)
        )
    end

    return 1
end

------------------------------------------------------------
-- APPLY SLOT
------------------------------------------------------------

function Row:_ApplySlot(
    slot,
    x,
    y,
    width,
    animated
)

    local container =
        slot.Container

    local targetPosition =
        UDim2.new(
            0,
            math.floor(
                x + 0.5
            ),
            0,
            math.floor(
                y + 0.5
            )
        )

    --------------------------------------------------------
    -- Slot keeps AutomaticSize.Y.
    -- Only position is animated.
    --------------------------------------------------------

    container.AutomaticSize =
        Enum.AutomaticSize.Y

    container.Size =
        UDim2.new(
            0,
            math.max(
                1,
                math.floor(
                    width + 0.5
                )
            ),
            0,
            0
        )

    if animated then

        TweenService:Create(
            container,
            TweenInfo.new(
                LAYOUT_ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Position =
                    targetPosition
            }
        ):Play()

    else

        container.Position =
            targetPosition
    end

    --------------------------------------------------------
    -- ELEMENT
    --------------------------------------------------------

    local instance =
        getElementInstance(
            slot.Element
        )

    if instance then

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
    end
end

------------------------------------------------------------
-- CALCULATE TOTAL HEIGHT
------------------------------------------------------------

function Row:_GetTargetHeight()

    local height =
        0

    for _, slot in ipairs(
        self.Slots
    ) do

        local y =
            slot.TargetY
            or slot.Container.Position.Y.Offset

        local slotHeight =
            self:_GetSlotHeight(
                slot
            )

        height =
            math.max(
                height,
                y + slotHeight
            )
    end

    return height
end

------------------------------------------------------------
-- UPDATE ROW HEIGHT
------------------------------------------------------------

function Row:_UpdateHeight(
    animated
)

    local targetHeight =
        self:_GetTargetHeight()

    local targetSize =
        UDim2.new(
            1,
            0,
            0,
            math.max(
                0,
                targetHeight
            )
        )

    if animated then

        TweenService:Create(
            self.ContentFrame,
            TweenInfo.new(
                LAYOUT_ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    targetSize
            }
        ):Play()

        TweenService:Create(
            self.Container,
            TweenInfo.new(
                LAYOUT_ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    targetSize
            }
        ):Play()

    else

        self.ContentFrame.Size =
            targetSize

        self.Container.Size =
            targetSize
    end
end

------------------------------------------------------------
-- RELAYOUT
------------------------------------------------------------

function Row:_Relayout(
    animated
)

    if self.Destroyed
        or self._Relayouting then

        return
    end

    self._Relayouting =
        true

    local rowWidth =
        self.Container.AbsoluteSize.X

    if rowWidth <= 0 then

        self._Relayouting =
            false

        return
    end

    --------------------------------------------------------
    -- AUTOFILL
    --------------------------------------------------------

    local count =
        #self.Slots

    if count == 0 then

        self.ContentFrame.Size =
            UDim2.new(
                1,
                0,
                0,
                0
            )

        self.Container.Size =
            UDim2.new(
                1,
                0,
                0,
                0
            )

        self._Relayouting =
            false

        return
    end

    local totalGap =
        GAP *
        math.max(
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

    local x =
        0

    --------------------------------------------------------
    -- LAYOUT ALL SLOTS
    --------------------------------------------------------

    for _, slot in ipairs(
        self.Slots
    ) do

        slot.Width =
            width

        slot.TargetX =
            x

        slot.TargetY =
            0

        self:_ApplySlot(
            slot,
            x,
            0,
            width,
            animated == true
        )

        x =
            x
            + width
            + GAP
    end

    --------------------------------------------------------
    -- HEIGHT
    --------------------------------------------------------

    self:_UpdateHeight(
        animated == true
    )

    self._Relayouting =
        false
end

------------------------------------------------------------
-- ADD ELEMENT
------------------------------------------------------------

function Row:_AddElement(
    element
)

    if self.Destroyed then
        return nil
    end

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

    self:_Relayout(
        false
    )

    return element
end

------------------------------------------------------------
-- FACTORY
------------------------------------------------------------

function Row:_CreateAndAdd(
    module,
    options
)

    if not module then
        return nil
    end

    local element =
        module.new(
            self,
            options or {}
        )

    if not element then
        return nil
    end

    return self:_AddElement(
        element
    )
end

------------------------------------------------------------
-- ELEMENT METHODS
------------------------------------------------------------

function Row:Button(options)

    if not self.Window.ButtonModule then
        warn("ButtonModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.ButtonModule,
        options
    )
end

function Row:Toggle(options)

    if not self.Window.ToggleModule then
        warn("ToggleModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.ToggleModule,
        options
    )
end

function Row:Slider(options)

    if not self.Window.SliderModule then
        warn("SliderModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.SliderModule,
        options
    )
end

function Row:Dropdown(options)

    if not self.Window.DropdownModule then
        warn("DropdownModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.DropdownModule,
        options
    )
end

function Row:TextBox(options)

    if not self.Window.TextBoxModule then
        warn("TextBoxModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.TextBoxModule,
        options
    )
end

function Row:TextInput(options)

    if not self.Window.TextInputModule then
        warn("TextInputModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.TextInputModule,
        options
    )
end

function Row:Console(options)

    if not self.Window.ConsoleModule then
        warn("ConsoleModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.ConsoleModule,
        options
    )
end

function Row:Paragraph(options)

    if not self.Window.ParagraphModule then
        warn("ParagraphModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.ParagraphModule,
        options
    )
end

function Row:Label(options)

    if not self.Window.LabelModule then
        warn("LabelModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.LabelModule,
        options
    )
end

function Row:Color(options)

    if not self.Window.ColorModule then
        warn("ColorModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.ColorModule,
        options
    )
end

function Row:Divider(options)

    if not self.Window.DividerModule then
        warn("DividerModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.DividerModule,
        options
    )
end

function Row:Image(options)

    if not self.Window.ImageModule then
        warn("ImageModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.ImageModule,
        options
    )
end

function Row:Section(options)

    if not self.Window.SectionModule then
        warn("SectionModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.SectionModule,
        options
    )
end

function Row:Row(options)

    if not self.Window.RowModule then
        warn("RowModule chưa được load!")
        return nil
    end

    return self:_CreateAndAdd(
        self.Window.RowModule,
        options
    )
end

------------------------------------------------------------
-- REFRESH HEIGHT
------------------------------------------------------------

function Row:_RefreshHeight()

    if self.Destroyed then
        return
    end

    self:_Relayout(
        false
    )
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Row:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    for _, element in ipairs(
        self.Elements
    ) do

        if element
            and element.UpdateTheme then

            pcall(
                function()

                    element:UpdateTheme(
                        theme
                    )
                end
            )
        end
    end
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Row:SetFont(
    fontType
)

    if self.Destroyed then
        return
    end

    for _, element in ipairs(
        self.Elements
    ) do

        if element
            and element.SetFont then

            pcall(
                function()

                    element:SetFont(
                        fontType
                    )
                end
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

    self.Destroyed =
        true

    for i =
        #self.Elements,
        1,
        -1
    do

        local element =
            self.Elements[i]

        if element
            and element.Destroy then

            pcall(
                function()

                    element:Destroy()
                end
            )
        end
    end

    table.clear(
        self.Elements
    )

    for _, slot in ipairs(
        self.Slots
    ) do

        if slot.Container then
            slot.Container:Destroy()
        end
    end

    table.clear(
        self.Slots
    )

    if self.Container then

        self.Container:Destroy()
        self.Container = nil
    end

    if self.Parent
        and self.Parent.Elements then

        for i, item in ipairs(
            self.Parent.Elements
        ) do

            if item == self then

                table.remove(
                    self.Parent.Elements,
                    i
                )

                break
            end
        end
    end
end

return Row