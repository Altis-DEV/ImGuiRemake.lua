-- File: ImGuiRemake.lua/Components/Section.lua

local Section = {}
Section.__index = Section

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local HEADER_HEIGHT = 30
local INDENT = 10

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

    self.Title =
        tostring(
            options.Title or "Section"
        )

    self.Opened =
        options.Open ~= false

    self.Destroyed = false

    self.Elements = {}

    --------------------------------------------------------
    -- CONTAINER
    --------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        self.Title .. "_Section"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            HEADER_HEIGHT
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Parent =
        parent.ContentFrame

    --------------------------------------------------------
    -- HEADER
    --
    -- Giống TitleFrame của Paragraph
    --------------------------------------------------------

    self.Header =
        Instance.new("Frame")

    self.Header.Name =
        "TitleFrame"

    self.Header.Size =
        UDim2.new(
            1,
            0,
            0,
            HEADER_HEIGHT
        )

    self.Header.BackgroundColor3 =
        self.Window.ThemeData.ParagraphTitleFrame
        or self.Window.ThemeData.Background

    self.Header.BorderColor3 =
        self.Window.ThemeData.Border

    self.Header.BorderSizePixel =
        1

    self.Header.Parent =
        self.Container

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

    self.ToggleButton.BackgroundTransparency =
        1

    self.ToggleButton.BorderSizePixel =
        0

    -- Luôn dùng ▼.
    -- Đóng = xoay -90° thành ▶
    -- Mở   = 0° thành ▼
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
        self.Header

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

    -- Section KHÔNG dùng RichText
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
        self.Header

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    self.ContentFrame =
        Instance.new("Frame")

    self.ContentFrame.Name =
        "Content"

    self.ContentFrame.Size =
        UDim2.new(
            1,
            -INDENT,
            0,
            0
        )

    self.ContentFrame.Position =
        UDim2.new(
            0,
            INDENT,
            0,
            0
        )

    self.ContentFrame.AutomaticSize =
        Enum.AutomaticSize.Y

    self.ContentFrame.BackgroundTransparency =
        1

    self.ContentFrame.BorderSizePixel =
        0

    self.ContentFrame.Visible =
        self.Opened

    self.ContentFrame.Parent =
        self.Container

    --------------------------------------------------------
    -- CONTENT LAYOUT
    --------------------------------------------------------

    self.Layout =
        Instance.new("UIListLayout")

    self.Layout.Name =
        "SectionLayout"

    self.Layout.FillDirection =
        Enum.FillDirection.Vertical

    self.Layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.Layout.Padding =
        UDim.new(0, 5)

    self.Layout.Parent =
        self.ContentFrame

    --------------------------------------------------------
    -- TOGGLE
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
    -- REGISTER IN PARENT
    --------------------------------------------------------

    table.insert(
        parent.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- OPEN / CLOSE
------------------------------------------------------------

function Section:SetOpen(state)

    if self.Destroyed then
        return
    end

    state =
        state == true

    self.Opened =
        state

    --------------------------------------------------------
    -- ARROW
    --------------------------------------------------------

    local rotation =
        state
        and OPEN_ROTATION
        or CLOSED_ROTATION

    local TweenService =
        game:GetService("TweenService")

    TweenService:Create(

        self.ToggleButton,

        TweenInfo.new(
            0.2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),

        {
            Rotation = rotation
        }

    ):Play()

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    self.ContentFrame.Visible =
        state
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

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    self.ToggleButton.TextSize =
        14

    self.TitleLabel.TextSize =
        13

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType ==
            Enum.Font then

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
            pcall(function()
                return Font.new(fontType)
            end)

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
    -- HEADER
    --------------------------------------------------------

    self.Header.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background

    self.Header.BorderColor3 =
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
    -- CHILDREN
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

    self.Destroyed =
        true

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
-- CHILD ELEMENT HELPERS
--
-- Section có thể sử dụng cùng API
-- với Tab.
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

    return Section.new(
        self,
        options or {}
    )
end

return Section
