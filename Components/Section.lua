-- File: ImGuiRemake.lua/Components/Section.lua

local Section = {}
Section.__index = Section

local TweenService =
    game:GetService("TweenService")

local HEADER_HEIGHT = 30
local INDENT = 10

local PADDING_TOP = 5
local PADDING_BOTTOM = 5
local PADDING_RIGHT = 5

local ELEMENT_GAP = 5
local ANIMATION_TIME = 0.22

local CLOSED_ROTATION = -90
local OPEN_ROTATION = 0

------------------------------------------------------------
-- REQUEST PARENT ROW RELAYOUT
------------------------------------------------------------

local function requestParentRelayout(
    self,
    animated
)

    local parent =
        self.Parent

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

function Section.new(
    parent,
    options
)

    options = options or {}

    local self =
        setmetatable(
            {},
            Section
        )

    self.Parent =
        parent

    self.Window =
        parent.Window

    self.WidthAtRow =
        options.WidthAtRow

    self.Title =
        tostring(
            options.Title
            or "Section"
        )

    self.Opened =
        options.Open == true

    self.Destroyed =
        false

    self.Elements =
        {}

    self._RowLayoutHeight =
        HEADER_HEIGHT

    --------------------------------------------------------
    -- ROOT
    --------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        self.Title
        .. "_Section"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            HEADER_HEIGHT
        )

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Parent =
        parent.ContentFrame

    --------------------------------------------------------
    -- SECTION LAYOUT
    --------------------------------------------------------

    self.SectionLayout =
        Instance.new("UIListLayout")

    self.SectionLayout.Name =
        "SectionLayout"

    self.SectionLayout.FillDirection =
        Enum.FillDirection.Vertical

    self.SectionLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.SectionLayout.Padding =
        UDim.new(
            0,
            -1
        )

    self.SectionLayout.Parent =
        self.Container

    --------------------------------------------------------
    -- TITLE FRAME
    --------------------------------------------------------

    self.TitleFrame =
        Instance.new("Frame")

    self.TitleFrame.Name =
        "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            HEADER_HEIGHT
        )

    self.TitleFrame.BackgroundColor3 =
        self.Window.ThemeData.SectionTitleFrame
        or self.Window.ThemeData.Background

    self.TitleFrame.BorderColor3 =
        self.Window.ThemeData.Border

    self.TitleFrame.BorderSizePixel =
        1

    self.TitleFrame.LayoutOrder =
        1

    self.TitleFrame.Parent =
        self.Container

    --------------------------------------------------------
    -- TOGGLE
    --------------------------------------------------------

    self.ToggleButton =
        Instance.new("TextButton")

    self.ToggleButton.Name =
        "ToggleButton"

    self.ToggleButton.Size =
        UDim2.new(
            0,
            HEADER_HEIGHT,
            1,
            0
        )

    self.ToggleButton.BackgroundTransparency =
        1

    self.ToggleButton.BorderSizePixel =
        0

    self.ToggleButton.Text =
        "▼"

    self.ToggleButton.Rotation =
        self.Opened
        and OPEN_ROTATION
        or CLOSED_ROTATION

    self.ToggleButton.TextColor3 =
        self.Window.ThemeData.Text

    self.ToggleButton.TextSize =
        14

    self.ToggleButton.Font =
        self.Window.CurrentFont

    self.ToggleButton.AutoButtonColor =
        false

    self.ToggleButton.Parent =
        self.TitleFrame

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleLabel =
        Instance.new("TextLabel")

    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -HEADER_HEIGHT - 8,
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            0,
            HEADER_HEIGHT + 8,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency =
        1

    self.TitleLabel.RichText =
        false

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        self.Window.ThemeData.Text

    self.TitleLabel.TextSize =
        13

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.TitleFrame

    --------------------------------------------------------
    -- ELEMENT CONTAINER
    --------------------------------------------------------

    self.ElementContainer =
        Instance.new("Frame")

    self.ElementContainer.Name =
        "ElementContainer"

    self.ElementContainer.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.ElementContainer.BackgroundColor3 =
        self.Window.ThemeData.SectionElementContainer
        or self.Window.ThemeData.ElementContainer

    self.ElementContainer.BorderColor3 =
        self.Window.ThemeData.Border

    self.ElementContainer.BorderSizePixel =
        1

    self.ElementContainer.ClipsDescendants =
        true

    self.ElementContainer.LayoutOrder =
        2

    self.ElementContainer.Parent =
        self.Container

    self.ContentFrame =
        self.ElementContainer

    --------------------------------------------------------
    -- ELEMENT LAYOUT
    --------------------------------------------------------

    self.ElementLayout =
        Instance.new("UIListLayout")

    self.ElementLayout.Name =
        "ElementLayout"

    self.ElementLayout.FillDirection =
        Enum.FillDirection.Vertical

    self.ElementLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.ElementLayout.Padding =
        UDim.new(
            0,
            ELEMENT_GAP
        )

    self.ElementLayout.Parent =
        self.ElementContainer

    --------------------------------------------------------
    -- PADDING
    --------------------------------------------------------

    self.ContentPadding =
        Instance.new("UIPadding")

    self.ContentPadding.Name =
        "ContentPadding"

    self.ContentPadding.PaddingLeft =
        UDim.new(
            0,
            INDENT
        )

    self.ContentPadding.PaddingRight =
        UDim.new(
            0,
            PADDING_RIGHT
        )

    self.ContentPadding.PaddingTop =
        UDim.new(
            0,
            PADDING_TOP
        )

    self.ContentPadding.PaddingBottom =
        UDim.new(
            0,
            PADDING_BOTTOM
        )

    self.ContentPadding.Parent =
        self.ElementContainer

    self.ElementContainer.Visible =
        self.Opened

    --------------------------------------------------------
    -- CONTENT CHANGED
    --------------------------------------------------------

    self.ElementLayout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(
        function()

            if self.Destroyed then
                return
            end

            if self.Opened then

                local targetHeight =
                    self:_GetContentHeight()

                self._RowLayoutHeight =
                    HEADER_HEIGHT
                    + targetHeight
                    - 1

                self:_RefreshHeight(
                    false
                )

                requestParentRelayout(
                    self,
                    false
                )
            end
        end
    )

    --------------------------------------------------------
    -- TOGGLE
    --------------------------------------------------------

    self.ToggleButton.MouseButton1Click:Connect(
        function()

            if self.Destroyed then
                return
            end

            if self.Opened then
                self:Close()
            else
                self:Open()
            end
        end
    )

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CONTENT HEIGHT
------------------------------------------------------------

function Section:_GetContentHeight()

    if self.Destroyed then
        return 0
    end

    return
        self.ElementLayout.AbsoluteContentSize.Y
        + PADDING_TOP
        + PADDING_BOTTOM
end

------------------------------------------------------------
-- REFRESH HEIGHT
------------------------------------------------------------

function Section:_RefreshHeight(
    animated
)

    if self.Destroyed
        or not self.Opened then
        return
    end

    local targetHeight =
        self:_GetContentHeight()

    local targetSize =
        UDim2.new(
            1,
            0,
            0,
            targetHeight
        )

    self._RowLayoutHeight =
        HEADER_HEIGHT
        + targetHeight
        - 1

    if animated then

        TweenService:Create(
            self.ElementContainer,
            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    targetSize
            }
        ):Play()

    else

        self.ElementContainer.Size =
            targetSize
    end

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            self._RowLayoutHeight
        )
end

------------------------------------------------------------
-- OPEN
------------------------------------------------------------

function Section:Open()

    if self.Destroyed then
        return
    end

    if self.Opened then

        self:_RefreshHeight(
            true
        )

        requestParentRelayout(
            self,
            true
        )

        return
    end

    self.Opened =
        true

    self.ElementContainer.Visible =
        true

    self.ElementContainer.Size =
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
            HEADER_HEIGHT
        )

    local targetHeight =
        self:_GetContentHeight()

    self._RowLayoutHeight =
        HEADER_HEIGHT
        + targetHeight
        - 1

    TweenService:Create(
        self.ToggleButton,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Rotation =
                OPEN_ROTATION
        }
    ):Play()

    TweenService:Create(
        self.ElementContainer,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    targetHeight
                )
        }
    ):Play()

    TweenService:Create(
        self.Container,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    self._RowLayoutHeight
                )
        }
    ):Play()

    requestParentRelayout(
        self,
        true
    )
end

------------------------------------------------------------
-- CLOSE
------------------------------------------------------------

function Section:Close()

    if self.Destroyed
        or not self.Opened then
        return
    end

    self.Opened =
        false

    self._RowLayoutHeight =
        HEADER_HEIGHT

    TweenService:Create(
        self.ToggleButton,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Rotation =
                CLOSED_ROTATION
        }
    ):Play()

    local contentTween =
        TweenService:Create(
            self.ElementContainer,
            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        0
                    )
            }
        )

    contentTween:Play()

    TweenService:Create(
        self.Container,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    HEADER_HEIGHT
                )
        }
    ):Play()

    requestParentRelayout(
        self,
        true
    )

    contentTween.Completed:Connect(
        function()

            if self.Destroyed then
                return
            end

            if not self.Opened then

                self.ElementContainer.Visible =
                    false

                requestParentRelayout(
                    self,
                    false
                )
            end
        end
    )
end

------------------------------------------------------------
-- SET OPEN
------------------------------------------------------------

function Section:SetOpen(
    state
)

    if state == true then
        self:Open()
    else
        self:Close()
    end
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function Section:SetTitle(
    newTitle
)

    if self.Destroyed then
        return
    end

    self.Title =
        tostring(
            newTitle
        )

    self.Container.Name =
        self.Title
        .. "_Section"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Section:SetFont(
    fontType
)

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
            pcall(
                function()
                    return Font.new(
                        fontType
                    )
                end
            )

        if ok and customFont then

            self.ToggleButton.FontFace =
                customFont

            self.TitleLabel.FontFace =
                customFont
        end

    elseif typeof(fontType) == "EnumItem"
        and fontType.EnumType ==
            Enum.Font then

        self.ToggleButton.Font =
            fontType

        self.TitleLabel.Font =
            fontType
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
-- UPDATE THEME
------------------------------------------------------------

function Section:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    self.TitleFrame.BackgroundColor3 =
        theme.SectionTitleFrame
        or theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.ElementContainer.BackgroundColor3 =
        theme.SectionElementContainer
        or theme.ElementContainer

    self.ElementContainer.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text

    self.ToggleButton.TextColor3 =
        theme.Text

    self:SetFont(
        self.Window.CurrentFont
    )

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

    if self.Opened then

        self:_RefreshHeight(
            false
        )
    end

    requestParentRelayout(
        self,
        false
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Section:Destroy()

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

            element:Destroy()
        end
    end

    table.clear(
        self.Elements
    )

    if self.Container then

        self.Container:Destroy()
        self.Container = nil
    end

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
-- FACTORIES
------------------------------------------------------------

function Section:Button(options)
    if not self.Window.ButtonModule then
        warn("ButtonModule chưa được load!")
        return nil
    end

    return self.Window.ButtonModule.new(
        self,
        options or {}
    )
end

function Section:Toggle(options)
    if not self.Window.ToggleModule then
        warn("ToggleModule chưa được load!")
        return nil
    end

    return self.Window.ToggleModule.new(
        self,
        options or {}
    )
end

function Section:Slider(options)
    if not self.Window.SliderModule then
        warn("SliderModule chưa được load!")
        return nil
    end

    return self.Window.SliderModule.new(
        self,
        options or {}
    )
end

function Section:Dropdown(options)
    if not self.Window.DropdownModule then
        warn("DropdownModule chưa được load!")
        return nil
    end

    return self.Window.DropdownModule.new(
        self,
        options or {}
    )
end

function Section:TextBox(options)
    if not self.Window.TextBoxModule then
        warn("TextBoxModule chưa được load!")
        return nil
    end

    return self.Window.TextBoxModule.new(
        self,
        options or {}
    )
end

function Section:TextInput(options)
    if not self.Window.TextInputModule then
        warn("TextInputModule chưa được load!")
        return nil
    end

    return self.Window.TextInputModule.new(
        self,
        options or {}
    )
end

function Section:Console(options)
    if not self.Window.ConsoleModule then
        warn("ConsoleModule chưa được load!")
        return nil
    end

    return self.Window.ConsoleModule.new(
        self,
        options or {}
    )
end

function Section:Paragraph(options)
    if not self.Window.ParagraphModule then
        warn("ParagraphModule chưa được load!")
        return nil
    end

    return self.Window.ParagraphModule.new(
        self,
        options or {}
    )
end

function Section:Label(options)
    if not self.Window.LabelModule then
        warn("LabelModule chưa được load!")
        return nil
    end

    return self.Window.LabelModule.new(
        self,
        options or {}
    )
end

function Section:Color(options)
    if not self.Window.ColorModule then
        warn("ColorModule chưa được load!")
        return nil
    end

    return self.Window.ColorModule.new(
        self,
        options or {}
    )
end

function Section:Divider(options)
    if not self.Window.DividerModule then
        warn("DividerModule chưa được load!")
        return nil
    end

    return self.Window.DividerModule.new(
        self,
        options or {}
    )
end

function Section:Image(options)
    if not self.Window.ImageModule then
        warn("ImageModule chưa được load!")
        return nil
    end

    return self.Window.ImageModule.new(
        self,
        options or {}
    )
end

function Section:Row(options)
    if not self.Window.RowModule then
        warn("RowModule chưa được load!")
        return nil
    end

    return self.Window.RowModule.new(
        self,
        options or {}
    )
end

function Section:Section(options)
    if not self.Window.SectionModule then
        warn("SectionModule chưa được load!")
        return nil
    end

    return self.Window.SectionModule.new(
        self,
        options or {}
    )
end

return Section