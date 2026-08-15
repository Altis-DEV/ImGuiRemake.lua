-- File: ImGuiRemake.lua/Components/Row.lua

local Row = {}
Row.__index = Row


local GAP = 5
local DEFAULT_WIDTH = 100


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
-- UDim WIDTH
------------------------------------------------------------

local function getUDimWidth(
    udim,
    parentWidth
)

    if not udim then
        return nil
    end


    return
        parentWidth * udim.X.Scale
        + udim.X.Offset
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


    self.Elements =
        {}


    self.Slots =
        {}


    self.Destroyed =
        false


    self.AutoFill =
        options.AutoFill == true


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
    -- WIDTH LISTENER
    --
    -- Only Row resize.
    -- No element resize listener.
    --------------------------------------------------------

    self.Container:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(function()

        if self.Destroyed then
            return
        end


        local width =
            self.Container.AbsoluteSize.X


        if width ~= self._LastWidth then

            self._LastWidth =
                width


            self:_Relayout()
        end
    end)



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

    local slot =
        Instance.new("Frame")


    slot.Name =
        "RowElementContainer_"
        ..
        tostring(
            #self.Slots + 1
        )


    slot.BackgroundTransparency =
        1


    slot.BorderSizePixel =
        0


    slot.Parent =
        self.ContentFrame



    local data =
    {
        Container = slot,

        Element = nil,

        Width = DEFAULT_WIDTH,
    }



    table.insert(
        self.Slots,
        data
    )


    return data
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
            *
            size.X.Scale
            +
            size.X.Offset

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
-- GET SLOT WIDTH
------------------------------------------------------------

function Row:_GetSlotWidth(
    element,
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



    return
        element._NaturalRowWidth
        or DEFAULT_WIDTH
end





------------------------------------------------------------
-- ATTACH ELEMENT INTO SLOT
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



    --------------------------------------------------------
    -- STORE ORIGINAL SIZE
    --------------------------------------------------------

    element._NaturalRowWidth =
        self:_GetNaturalWidth(
            element,
            instance
        )



    --------------------------------------------------------
    -- CREATE SLOT
    --------------------------------------------------------

    local slot =
        self:_CreateSlot()



    slot.Element =
        element



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
    -- ELEMENT FILL SLOT
    --------------------------------------------------------

    instance.Size =
        UDim2.new(
            1,
            0,
            instance.Size.Y.Scale,
            instance.Size.Y.Offset
        )



    --------------------------------------------------------
    -- INITIAL SLOT WIDTH
    --------------------------------------------------------

    slot.Width =
        element._NaturalRowWidth
        or DEFAULT_WIDTH



    self:_Relayout()



    return true
end





------------------------------------------------------------
-- APPLY SLOT
------------------------------------------------------------

function Row:_ApplySlot(
    slot,
    x,
    y,
    width
)

    local frame =
        slot.Container



    frame.Position =
        UDim2.new(
            0,
            x,
            0,
            y
        )



    frame.Size =
        UDim2.new(
            0,
            width,
            0,
            0
        )



    frame.AutomaticSize =
        Enum.AutomaticSize.Y



    local instance =
        getElementInstance(
            slot.Element
        )


    if instance then

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
-- RELAYOUT
------------------------------------------------------------

function Row:_Relayout()

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

    if self.AutoFill then


        local count =
            #self.Slots



        if count == 0 then

            self._Relayouting =
                false

            return
        end



        local width =
        (
            rowWidth
            -
            GAP *
            (count - 1)
        )
        /
        count



        local x =
            0



        for _, slot in ipairs(
            self.Slots
        ) do


            slot.Width =
                width



            self:_ApplySlot(
                slot,
                x,
                0,
                width
            )


            x =
                x
                +
                width
                +
                GAP

        end


    else

        ----------------------------------------------------
        -- WRAPPING
        ----------------------------------------------------

        local x =
            0


        local y =
            0


        local lineHeight =
            0



        for _, slot in ipairs(
            self.Slots
        ) do


            local width =
                self:_GetSlotWidth(
                    slot.Element,
                    rowWidth
                )



            if x > 0
                and x + width > rowWidth then


                x =
                    0


                y =
                    y
                    +
                    lineHeight
                    +
                    GAP


                lineHeight =
                    0

            end



            slot.Width =
                width



            self:_ApplySlot(
                slot,
                x,
                y,
                width
            )



            lineHeight =
                math.max(
                    lineHeight,
                    slot.Container.AbsoluteSize.Y
                )



            x =
                x
                +
                width
                +
                GAP

        end
    end



    --------------------------------------------------------
    -- HEIGHT UPDATE
    --------------------------------------------------------

    task.defer(function()

        if self.Destroyed then
            return
        end


        local height = 0


        for _, slot in ipairs(
            self.Slots
        ) do

            local bottom =
                slot.Container.Position.Y.Offset
                +
                slot.Container.AbsoluteSize.Y



            height =
                math.max(
                    height,
                    bottom
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


        self._Relayouting =
            false

    end)
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


    self:_Relayout()


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
-- BUTTON
------------------------------------------------------------

function Row:Button(
    options
)

    if not self.Window.ButtonModule then

        warn(
            "ButtonModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.ButtonModule,
        options
    )
end





------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

function Row:Toggle(
    options
)

    if not self.Window.ToggleModule then

        warn(
            "ToggleModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.ToggleModule,
        options
    )
end





------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

function Row:Slider(
    options
)

    if not self.Window.SliderModule then

        warn(
            "SliderModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.SliderModule,
        options
    )
end





------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

function Row:Dropdown(
    options
)

    if not self.Window.DropdownModule then

        warn(
            "DropdownModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.DropdownModule,
        options
    )
end





------------------------------------------------------------
-- TEXTBOX
------------------------------------------------------------

function Row:TextBox(
    options
)

    if not self.Window.TextBoxModule then

        warn(
            "TextBoxModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.TextBoxModule,
        options
    )
end





------------------------------------------------------------
-- TEXT INPUT
------------------------------------------------------------

function Row:TextInput(
    options
)

    if not self.Window.TextInputModule then

        warn(
            "TextInputModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.TextInputModule,
        options
    )
end





------------------------------------------------------------
-- CONSOLE
------------------------------------------------------------

function Row:Console(
    options
)

    if not self.Window.ConsoleModule then

        warn(
            "ConsoleModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.ConsoleModule,
        options
    )
end





------------------------------------------------------------
-- PARAGRAPH
------------------------------------------------------------

function Row:Paragraph(
    options
)

    if not self.Window.ParagraphModule then

        warn(
            "ParagraphModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.ParagraphModule,
        options
    )
end





------------------------------------------------------------
-- LABEL
------------------------------------------------------------

function Row:Label(
    options
)

    if not self.Window.LabelModule then

        warn(
            "LabelModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.LabelModule,
        options
    )
end





------------------------------------------------------------
-- COLOR
------------------------------------------------------------

function Row:Color(
    options
)

    if not self.Window.ColorModule then

        warn(
            "ColorModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.ColorModule,
        options
    )
end





------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

function Row:Divider(
    options
)

    if not self.Window.DividerModule then

        warn(
            "DividerModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.DividerModule,
        options
    )
end





------------------------------------------------------------
-- IMAGE
------------------------------------------------------------

function Row:Image(
    options
)

    if not self.Window.ImageModule then

        warn(
            "ImageModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.ImageModule,
        options
    )
end





------------------------------------------------------------
-- SECTION
------------------------------------------------------------

function Row:Section(
    options
)

    if not self.Window.SectionModule then

        warn(
            "SectionModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.SectionModule,
        options
    )
end





------------------------------------------------------------
-- NESTED ROW
------------------------------------------------------------

function Row:Row(
    options
)

    if not self.Window.RowModule then

        warn(
            "RowModule chưa được load!"
        )

        return nil
    end



    return self:_CreateAndAdd(
        self.Window.RowModule,
        options
    )
end

------------------------------------------------------------
-- SET AUTOFILL
------------------------------------------------------------

function Row:SetAutoFill(
    state
)

    if self.Destroyed then
        return
    end


    self.AutoFill =
        state == true


    self:_Relayout()
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


            local ok, err =
                pcall(
                    function()

                        element:UpdateTheme(
                            theme
                        )

                    end
                )


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


            local ok, err =
                pcall(
                    function()

                        element:SetFont(
                            fontType
                        )

                    end
                )


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



    self.Destroyed =
        true



    --------------------------------------------------------
    -- DESTROY CHILD ELEMENTS
    --------------------------------------------------------

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





    --------------------------------------------------------
    -- CLEAR ELEMENT DATA
    --------------------------------------------------------

    table.clear(
        self.Elements
    )





    --------------------------------------------------------
    -- DESTROY SLOTS
    --------------------------------------------------------

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





    --------------------------------------------------------
    -- DESTROY ROOT
    --------------------------------------------------------

    if self.Container then

        self.Container:Destroy()

        self.Container =
            nil

    end





    --------------------------------------------------------
    -- REMOVE FROM PARENT
    --------------------------------------------------------

    if self.Parent
        and self.Parent.Elements then


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
end





------------------------------------------------------------
-- RETURN
------------------------------------------------------------

return Row
