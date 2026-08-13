-- File: ImGuiRemake.lua/Components/Section.lua

local Section = {}
Section.__index = Section

local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

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
-- CONSTRUCTOR
------------------------------------------------------------

function Section.new(parent, options)
    options = options or {}

    local self = setmetatable({}, Section)

    --------------------------------------------------------
    -- PARENT
    --------------------------------------------------------

    self.Parent = parent
    self.Window = parent.Window

    self.Title = tostring(
        options.Title or "Section"
    )

    -- Mặc định đóng
    self.Opened =
        options.Open == true

    self.Destroyed = false

    self.Elements = {}

    --------------------------------------------------------
    -- MAIN SECTION CONTAINER
    --
    -- Đây là 1 element của Parent.
    -- Không AutomaticSize.
    -- Chiều cao được Section tự quản lý.
    --------------------------------------------------------

    self.Container = Instance.new("Frame")

    self.Container.Name =
        self.Title .. "_Section"

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
    -- SECTION INTERNAL LAYOUT
    --------------------------------------------------------

    self.SectionLayout =
        Instance.new("UIListLayout")

    self.SectionLayout.Name =
        "SectionLayout"

    self.SectionLayout.FillDirection =
        Enum.FillDirection.Vertical

    self.SectionLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    -- Border của TitleFrame và ElementContainer
    -- chồng lên nhau 1px.
    self.SectionLayout.Padding =
        UDim.new(0, -1)

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
    -- TOGGLE BUTTON
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

    -- ▼
    --
    -- Closed = ▶
    -- Open   = ▼
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

    -- Section title không RichText
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
    --
    -- FULL WIDTH bằng TitleFrame
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

    --------------------------------------------------------
    -- IMPORTANT COMPATIBILITY
    --
    -- Các component hiện tại dùng:
    -- parent.ContentFrame
    --------------------------------------------------------

    self.ContentFrame =
        self.ElementContainer

    --------------------------------------------------------
    -- CHILD ELEMENT LAYOUT
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
    -- CHILD PADDING
    --
    -- Container full width.
    -- Chỉ nội dung bên trong thụt 10px.
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

    --------------------------------------------------------
    -- INITIAL STATE
    --------------------------------------------------------

    if self.Opened then

        self.ElementContainer.Visible =
            true

        self.ElementContainer.Size =
            UDim2.new(
                1,
                0,
                0,
                0
            )

    else

        self.ElementContainer.Visible =
            false

        self.ElementContainer.Size =
            UDim2.new(
                1,
                0,
                0,
                0
            )

    end

    --------------------------------------------------------
    -- WATCH CHILD CONTENT SIZE
    --------------------------------------------------------

    self.ElementLayout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(
        function()

            if self.Destroyed then
                return
            end

            ------------------------------------------------
            -- Nếu Section đang mở, cập nhật chiều cao
            -- của cả ElementContainer và Section.
            ------------------------------------------------

            if self.Opened then
                self:_RefreshHeight(false)
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

    --------------------------------------------------------
    -- REGISTER AS ONE ELEMENT
    --------------------------------------------------------

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- GET CHILD CONTENT HEIGHT
------------------------------------------------------------

function Section:_GetContentHeight()

    if self.Destroyed then
        return 0
    end

    local layoutHeight =
        self.ElementLayout.AbsoluteContentSize.Y

    return
        layoutHeight
        + PADDING_TOP
        + PADDING_BOTTOM
end

------------------------------------------------------------
-- UPDATE MAIN SECTION HEIGHT
------------------------------------------------------------

function Section:_UpdateContainerHeight()

    if self.Destroyed then
        return
    end

    local contentHeight = 0

    if self.Opened then
        contentHeight =
            self.ElementContainer.Size.Y.Offset
    end

    local totalHeight =
        HEADER_HEIGHT
        + contentHeight
        - 1

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            math.max(
                HEADER_HEIGHT,
                totalHeight
            )
        )
end

------------------------------------------------------------
-- REFRESH HEIGHT
------------------------------------------------------------

function Section:_RefreshHeight(animated)

    if self.Destroyed then
        return
    end

    if not self.Opened then
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

    if animated then

        local tween =
            TweenService:Create(

                self.ElementContainer,

                TweenInfo.new(
                    ANIMATION_TIME,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),

                {
                    Size = targetSize
                }
            )

        tween:Play()

    else

        self.ElementContainer.Size =
            targetSize

    end

    --------------------------------------------------------
    -- Section itself must also change size.
    --------------------------------------------------------

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            HEADER_HEIGHT
            + targetHeight
            - 1
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
        self:_RefreshHeight(true)
        return
    end

    self.Opened =
        true

    self.ElementContainer.Visible =
        true

    --------------------------------------------------------
    -- Start collapsed
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- Arrow
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- Animate content
    --------------------------------------------------------

    local targetHeight =
        self:_GetContentHeight()

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
                        targetHeight
                    )
            }
        )

    contentTween:Play()

    --------------------------------------------------------
    -- Animate Section itself
    --------------------------------------------------------

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
                    + targetHeight
                    - 1
                )
        }

    ):Play()
end

------------------------------------------------------------
-- CLOSE
------------------------------------------------------------

function Section:Close()

    if self.Destroyed then
        return
    end

    if not self.Opened then
        return
    end

    self.Opened =
        false

    --------------------------------------------------------
    -- Arrow
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- CLOSE CONTENT
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- CLOSE SECTION ITSELF
    --------------------------------------------------------

    local containerTween =
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
        )

    containerTween:Play()

    --------------------------------------------------------
    -- Hide after animation
    --------------------------------------------------------

    contentTween.Completed:Connect(
        function()

            if self.Destroyed then
                return
            end

            if not self.Opened then

                self.ElementContainer.Visible =
                    false

            end
        end
    )
end

------------------------------------------------------------
-- SET OPEN
------------------------------------------------------------

function Section:SetOpen(state)

    if state == true then
        self:Open()
    else
        self:Close()
    end

end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function Section:SetTitle(newTitle)

    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title .. "_Section"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Section:SetFont(fontType)

    if self.Destroyed then
        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.ToggleButton.Font =
            fontType

        self.TitleLabel.Font =
            fontType

    elseif typeof(fontType) == "string"
        and string.find(
            string.lower(fontType),
            "rbxassetid",
            1,
            true
        ) then

        local ok, customFont =
            pcall(
                function()
                    return Font.new(fontType)
                end
            )

        if ok and customFont then

            self.ToggleButton.FontFace =
                customFont

            self.TitleLabel.FontFace =
                customFont

        end
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Section:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TITLE FRAME
    --------------------------------------------------------

    self.TitleFrame.BackgroundColor3 =
        theme.SectionTitleFrame
        or theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- ELEMENT CONTAINER
    --------------------------------------------------------

    self.ElementContainer.BackgroundColor3 =
        theme.SectionElementContainer
        or theme.ElementContainer

    self.ElementContainer.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleLabel.TextColor3 =
        theme.Text

    self.ToggleButton.TextColor3 =
        theme.Text

    --------------------------------------------------------
    -- FONT
    --------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    --------------------------------------------------------
    -- CHILDREN
    --------------------------------------------------------

    for _, element in ipairs(
        self.Elements
    ) do

        if element.UpdateTheme then
            element:UpdateTheme(theme)
        end

    end

    --------------------------------------------------------
    -- REFRESH CURRENT HEIGHT
    --------------------------------------------------------

    if self.Opened then
        self:_RefreshHeight(false)
    end
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Section:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true

    --------------------------------------------------------
    -- DESTROY CHILDREN
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
    -- REMOVE INSTANCE
    --------------------------------------------------------

    if self.Container then

        self.Container:Destroy()

        self.Container =
            nil

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
-- CHILD ELEMENT FACTORIES
------------------------------------------------------------

function Section:Button(options)

    if not self.Window.ButtonModule then
        warn(
            "ButtonModule chưa được load!"
        )
        return nil
    end

    return self.Window.ButtonModule.new(
        self,
        options or {}
    )
end

function Section:Toggle(options)

    if not self.Window.ToggleModule then
        warn(
            "ToggleModule chưa được load!"
        )
        return nil
    end

    return self.Window.ToggleModule.new(
        self,
        options or {}
    )
end

function Section:Slider(options)

    if not self.Window.SliderModule then
        warn(
            "SliderModule chưa được load!"
        )
        return nil
    end

    return self.Window.SliderModule.new(
        self,
        options or {}
    )
end

function Section:Dropdown(options)

    if not self.Window.DropdownModule then
        warn(
            "DropdownModule chưa được load!"
        )
        return nil
    end

    return self.Window.DropdownModule.new(
        self,
        options or {}
    )
end

function Section:TextBox(options)

    if not self.Window.TextBoxModule then
        warn(
            "TextBoxModule chưa được load!"
        )
        return nil
    end

    return self.Window.TextBoxModule.new(
        self,
        options or {}
    )
end

function Section:Paragraph(options)

    if not self.Window.ParagraphModule then
        warn(
            "ParagraphModule chưa được load!"
        )
        return nil
    end

    return self.Window.ParagraphModule.new(
        self,
        options or {}
    )
end

function Section:Label(options)

    if not self.Window.LabelModule then
        warn(
            "LabelModule chưa được load!"
        )
        return nil
    end

    return self.Window.LabelModule.new(
        self,
        options or {}
    )
end

function Section:Divider(options)

    if not self.Window.DividerModule then
        warn(
            "DividerModule chưa được load!"
        )
        return nil
    end

    return self.Window.DividerModule.new(
        self,
        options or {}
    )
end

function Section:Image(options)

    if not self.Window.ImageModule then
        warn(
            "ImageModule chưa được load!"
        )
        return nil
    end

    return self.Window.ImageModule.new(
        self,
        options or {}
    )
end

------------------------------------------------------------
-- NESTED SECTION
------------------------------------------------------------

function Section:Section(options)

    if not self.Window.SectionModule then
        warn(
            "SectionModule chưa được load!"
        )
        return nil
    end

    return self.Window.SectionModule.new(
        self,
        options or {}
    )
end

return Section
