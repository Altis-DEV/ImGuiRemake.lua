-- File: ImGuiRemake.lua/Components/Section.lua

local Section = {}
Section.__index = Section

local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local HEADER_HEIGHT = 30
local INDENT = 10
local ANIMATION_TIME = 0.22

local CLOSED_ROTATION = -90
local OPEN_ROTATION = 0

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Section.new(parent, options)
    options = options or {}

    local self = setmetatable({}, Section)

    self.Parent = parent
    self.Window = parent.Window

    self.Title = tostring(
        options.Title or "Section"
    )

    -- MẶC ĐỊNH = ĐÓNG
    self.Opened = options.Open == true

    self.Destroyed = false
    self.Elements = {}

    --------------------------------------------------------
    -- SECTION = 1 ELEMENT OF PARENT
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

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0

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

    -- Border của 2 frame chồng nhau 1px
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

    self.TitleFrame.BorderSizePixel = 1
    self.TitleFrame.LayoutOrder = 1

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

    self.ToggleButton.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.ToggleButton.BackgroundTransparency = 1
    self.ToggleButton.BorderSizePixel = 0

    self.ToggleButton.Text = "▼"

    self.ToggleButton.Rotation =
        self.Opened
        and OPEN_ROTATION
        or CLOSED_ROTATION

    self.ToggleButton.TextColor3 =
        self.Window.ThemeData.Text

    self.ToggleButton.TextSize = 14
    self.ToggleButton.Font =
        self.Window.CurrentFont

    self.ToggleButton.AutoButtonColor = false

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

    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.RichText = false

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        self.Window.ThemeData.Text

    self.TitleLabel.TextSize = 13
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

    -- FULL WIDTH
    self.ElementContainer.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    -- QUAN TRỌNG:
    -- Không dùng AutomaticSize.Y.
    -- Chiều cao được Section tự tween.
    self.ElementContainer.AutomaticSize =
        Enum.AutomaticSize.None

    self.ElementContainer.BackgroundColor3 =
        self.Window.ThemeData.SectionElementContainer
        or self.Window.ThemeData.ElementContainer

    self.ElementContainer.BorderColor3 =
        self.Window.ThemeData.Border

    self.ElementContainer.BorderSizePixel = 1

    self.ElementContainer.ClipsDescendants = true
    self.ElementContainer.LayoutOrder = 2

    self.ElementContainer.Parent =
        self.Container

    --------------------------------------------------------
    -- COMPONENT COMPATIBILITY
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
        UDim.new(0, 5)

    self.ElementLayout.Parent =
        self.ElementContainer

    --------------------------------------------------------
    -- INNER PADDING
    --
    -- Container vẫn full width,
    -- element bên trong thụt 10px.
    --------------------------------------------------------

    self.ContentPadding =
        Instance.new("UIPadding")

    self.ContentPadding.Name =
        "ContentPadding"

    self.ContentPadding.PaddingLeft =
        UDim.new(0, INDENT)

    self.ContentPadding.PaddingRight =
        UDim.new(0, 5)

    self.ContentPadding.PaddingTop =
        UDim.new(0, 5)

    self.ContentPadding.PaddingBottom =
        UDim.new(0, 5)

    self.ContentPadding.Parent =
        self.ElementContainer

    --------------------------------------------------------
    -- INITIAL HEIGHT
    --------------------------------------------------------

    if self.Opened then
        self.ElementContainer.Visible = true

        -- Frame hiện tại chưa có element?
        -- Height sẽ được cập nhật ngay sau khi tạo element.
        self.ElementContainer.Size =
            UDim2.new(
                1,
                0,
                0,
                0
            )
    else
        self.ElementContainer.Visible = false

        self.ElementContainer.Size =
            UDim2.new(
                1,
                0,
                0,
                0
            )
    end

    --------------------------------------------------------
    -- TOGGLE BUTTON
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
    -- REGISTER
    --------------------------------------------------------

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- GET CONTENT HEIGHT
------------------------------------------------------------

function Section:_GetContentHeight()
    if self.Destroyed then
        return 0
    end

    -- AbsoluteContentSize đã bao gồm tổng element + spacing.
    local contentHeight =
        self.ElementLayout.AbsoluteContentSize.Y

    -- Top + Bottom padding
    local paddingHeight =
        10

    return contentHeight + paddingHeight
end

------------------------------------------------------------
-- REFRESH HEIGHT
------------------------------------------------------------

function Section:_RefreshOpenHeight(animated)
    if self.Destroyed or not self.Opened then
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
        ):Play()
    else
        self.ElementContainer.Size =
            targetSize
    end
end

------------------------------------------------------------
-- OPEN
------------------------------------------------------------

function Section:Open()
    if self.Destroyed then
        return
    end

    if self.Opened then
        -- Vẫn refresh chiều cao trong trường hợp
        -- element vừa được thêm sau khi mở.
        self:_RefreshOpenHeight(true)
        return
    end

    self.Opened = true
    self.ElementContainer.Visible = true

    --------------------------------------------------------
    -- ARROW
    --------------------------------------------------------

    TweenService:Create(
        self.ToggleButton,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Rotation = OPEN_ROTATION
        }
    ):Play()

    --------------------------------------------------------
    -- START FROM ZERO
    --------------------------------------------------------

    self.ElementContainer.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    --------------------------------------------------------
    -- EXPAND
    --------------------------------------------------------

    self:_RefreshOpenHeight(true)
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

    self.Opened = false

    --------------------------------------------------------
    -- ARROW
    --------------------------------------------------------

    TweenService:Create(
        self.ToggleButton,
        TweenInfo.new(
            ANIMATION_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Rotation = CLOSED_ROTATION
        }
    ):Play()

    --------------------------------------------------------
    -- COLLAPSE
    --------------------------------------------------------

    local tween =
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

    tween:Play()

    tween.Completed:Connect(
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
    if state then
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

    --------------------------------------------------------
    -- UPDATE CHILDREN
    --------------------------------------------------------

    for _, element in ipairs(self.Elements) do
        if element.UpdateTheme then
            element:UpdateTheme(theme)
        end
    end

    --------------------------------------------------------
    -- REFRESH OPEN HEIGHT
    --------------------------------------------------------

    if self.Opened then
        self:_RefreshOpenHeight(false)
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
-- CHILD ELEMENT FACTORIES
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

------------------------------------------------------------
-- NESTED SECTION
------------------------------------------------------------

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
