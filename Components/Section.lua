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

    --------------------------------------------------------
    -- PARENT
    --
    -- parent can be:
    --   Tab
    --   Section
    --------------------------------------------------------

    self.Parent = parent
    self.Window = parent.Window

    self.Title = tostring(
        options.Title or "Section"
    )

    self.Opened =
        options.Open ~= false

    self.Destroyed = false

    -- Giống Tab
    self.Elements = {}

    --------------------------------------------------------
    -- SECTION CONTAINER
    --
    -- Section itself = 1 element in parent
    --------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name =
        self.Title .. "_Section"

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

    -- Hai border chồng lên nhau 1px
    self.SectionLayout.Padding =
        UDim.new(0, -1)

    self.SectionLayout.Parent =
        self.Container

    --------------------------------------------------------
    -- TITLE FRAME
    --------------------------------------------------------

    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Name = "TitleFrame"

    -- FULL WIDTH
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
    -- TITLE LABEL
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

    -- Section title KHÔNG RichText
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
    --
    -- QUAN TRỌNG:
    -- Full width bằng TitleFrame.
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

    self.ElementContainer.AutomaticSize =
        Enum.AutomaticSize.Y

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
    -- CONTENT FRAME ALIAS
    --
    -- Các component hiện tại đều dùng:
    -- tab.ContentFrame
    --
    -- Vì vậy Section phải expose ContentFrame.
    --------------------------------------------------------

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
        UDim.new(0, 5)

    self.ElementLayout.Parent =
        self.ElementContainer

    --------------------------------------------------------
    -- INDENT CONTENT
    --
    -- ElementContainer vẫn full width,
    -- nhưng element bên trong thụt vào 10px.
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
    -- INITIAL STATE
    --------------------------------------------------------

    if self.Opened then

        self.ElementContainer.Visible = true

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
    -- REGISTER AS ONE PARENT ELEMENT
    --------------------------------------------------------

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- CALCULATE CONTENT HEIGHT
------------------------------------------------------------

function Section:_GetElementHeight()

    if self.Destroyed then
        return 0
    end

    return self.ElementLayout.AbsoluteContentSize.Y
        + 10
end

------------------------------------------------------------
-- OPEN
------------------------------------------------------------

function Section:Open()

    if self.Destroyed then
        return
    end

    if self.Opened then
        return
    end

    self.Opened = true

    self.ElementContainer.Visible = true

    --------------------------------------------------------
    -- Start from 0
    --------------------------------------------------------

    self.ElementContainer.Size =
        UDim2.new(
            1,
            0,
            0,
            0
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
            Rotation = OPEN_ROTATION
        }

    ):Play()

    --------------------------------------------------------
    -- Expand
    --------------------------------------------------------

    local height =
        self:_GetElementHeight()

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
                    height
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

    self.Opened = false

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
            Rotation = CLOSED_ROTATION
        }

    ):Play()

    --------------------------------------------------------
    -- Collapse
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
                self.ElementContainer.Visible = false
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
    -- TEXT
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
    -- CHILD ELEMENTS
    --------------------------------------------------------

    for _, element in ipairs(
        self.Elements
    ) do

        if element.UpdateTheme then
            element:UpdateTheme(theme)
        end

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
    -- DESTROY INSTANCE
    --------------------------------------------------------

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

    --------------------------------------------------------
    -- REMOVE FROM PARENT ELEMENT LIST
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
