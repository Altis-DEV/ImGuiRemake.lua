-- File: ImGuiRemake.lua/Components/Paragraph.lua

local Paragraph = {}
Paragraph.__index = Paragraph

local PADDING_X = 8
local PADDING_Y = 6
local DEFAULT_TEXT_SIZE = 13

local DEFAULT_BACKGROUND =
    Color3.fromRGB(32, 32, 32)

local DEFAULT_TEXT_BACKGROUND =
    Color3.fromRGB(26, 26, 26)

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(255, 255, 255)

local function setFont(instance, fontType)
    if typeof(fontType) == "string"
        and string.find(
            string.lower(fontType),
            "rbxassetid",
            1,
            true
        ) then

        local ok, customFont = pcall(function()
            return Font.new(fontType)
        end)

        if ok and customFont then
            instance.FontFace = customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        instance.Font = fontType
    end
end

function Paragraph.new(tab, options)
    options = options or {}

    ------------------------------------------------------------
    -- TITLE IS REQUIRED
    ------------------------------------------------------------

    if options.Title == nil then
        error(
            "Paragraph requires a Title",
            2
        )
    end

    local self = setmetatable({}, Paragraph)

    self.Tab = tab
    self.Window = tab.Window
    self.WidthAtRow = options.WidthAtRow

    self.Title = tostring(options.Title)

    -- Text is optional
    self.HasText = options.Text ~= nil

    self.Text = self.HasText
        and tostring(options.Text)
        or ""

    self.Destroyed = false

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- OUTER CONTAINER
    ------------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name = "Paragraph"

    self.Container.Size =
        UDim2.new(1, 0, 0, 0)

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- INNER CONTENT CONTAINER
    ------------------------------------------------------------

    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name =
        "ContentContainer"

    self.ContentContainer.Size =
        UDim2.new(1, 0, 0, 0)

    self.ContentContainer.AutomaticSize =
        Enum.AutomaticSize.Y

    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE FRAME
    ------------------------------------------------------------

    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Name =
        "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(1, 0, 0, 0)

    self.TitleFrame.AutomaticSize =
        Enum.AutomaticSize.Y

    self.TitleFrame.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.TitleFrame.BorderSizePixel = 1
    self.TitleFrame.LayoutOrder = 1
    self.TitleFrame.Parent =
        self.ContentContainer

    ------------------------------------------------------------
    -- TITLE LABEL
    ------------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -(PADDING_X * 2),
            0,
            0
        )

    self.TitleLabel.AutomaticSize =
        Enum.AutomaticSize.Y

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.RichText = true
    self.TitleLabel.TextWrapped = true

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.TextSize =
        DEFAULT_TEXT_SIZE

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.TitleLabel.Parent =
        self.TitleFrame

    ------------------------------------------------------------
    -- TITLE PADDING
    ------------------------------------------------------------

    local titlePadding =
        Instance.new("UIPadding")

    titlePadding.PaddingTop =
        UDim.new(0, PADDING_Y)

    titlePadding.PaddingBottom =
        UDim.new(0, PADDING_Y)

    titlePadding.PaddingLeft =
        UDim.new(0, PADDING_X)

    titlePadding.PaddingRight =
        UDim.new(0, PADDING_X)

    titlePadding.Parent =
        self.TitleFrame

    ------------------------------------------------------------
    -- TEXT FRAME
    -- Only created when Text exists.
    ------------------------------------------------------------

    if self.HasText then

        self.TextFrame = Instance.new("Frame")
        self.TextFrame.Name =
            "TextFrame"

        self.TextFrame.Size =
            UDim2.new(1, 0, 0, 0)

        self.TextFrame.AutomaticSize =
            Enum.AutomaticSize.Y

        self.TextFrame.BackgroundColor3 =
            theme.ParagraphTextFrame
            or theme.ElementContainer
            or DEFAULT_TEXT_BACKGROUND

        self.TextFrame.BorderColor3 =
            theme.Border
            or Color3.fromRGB(60, 60, 60)

        self.TextFrame.BorderSizePixel = 1
        self.TextFrame.LayoutOrder = 2
        self.TextFrame.Parent =
            self.ContentContainer

        --------------------------------------------------------
        -- TEXT LABEL
        --------------------------------------------------------

        self.TextLabel = Instance.new("TextLabel")
        self.TextLabel.Name =
            "Text"

        self.TextLabel.Size =
            UDim2.new(
                1,
                -(PADDING_X * 2),
                0,
                0
            )

        self.TextLabel.AutomaticSize =
            Enum.AutomaticSize.Y

        self.TextLabel.BackgroundTransparency = 1

        self.TextLabel.Text =
            self.Text

        self.TextLabel.RichText = true
        self.TextLabel.TextWrapped = true

        self.TextLabel.TextXAlignment =
            Enum.TextXAlignment.Left

        self.TextLabel.TextYAlignment =
            Enum.TextYAlignment.Center

        self.TextLabel.TextSize =
            DEFAULT_TEXT_SIZE

        self.TextLabel.Font =
            self.Window.CurrentFont

        self.TextLabel.TextColor3 =
            theme.Text
            or DEFAULT_TEXT_COLOR

        self.TextLabel.Parent =
            self.TextFrame

        --------------------------------------------------------
        -- TEXT PADDING
        --------------------------------------------------------

        local textPadding =
            Instance.new("UIPadding")

        textPadding.PaddingTop =
            UDim.new(0, PADDING_Y)

        textPadding.PaddingBottom =
            UDim.new(0, PADDING_Y)

        textPadding.PaddingLeft =
            UDim.new(0, PADDING_X)

        textPadding.PaddingRight =
            UDim.new(0, PADDING_X)

        textPadding.Parent =
            self.TextFrame
    end

    ------------------------------------------------------------
    -- LAYOUT
    ------------------------------------------------------------

    local contentLayout =
        Instance.new("UIListLayout")

    contentLayout.Name =
        "ParagraphLayout"

    contentLayout.FillDirection =
        Enum.FillDirection.Vertical

    contentLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    -- Overlap the two borders by 1px.
    contentLayout.Padding =
        UDim.new(0, -1)

    contentLayout.Parent =
        self.ContentContainer

    ------------------------------------------------------------
    -- FONT
    ------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    ------------------------------------------------------------
    -- REGISTER
    ------------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function Paragraph:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    if newTitle == nil then
        return
    end

    self.Title =
        tostring(newTitle)

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET TEXT
------------------------------------------------------------

function Paragraph:SetText(newText)
    if self.Destroyed then
        return
    end

    if newText == nil then
        return
    end

    -- If Text didn't exist during construction,
    -- create the TextFrame now.
    if not self.HasText then
        self.HasText = true

        local theme = self.Window.ThemeData

        self.TextFrame = Instance.new("Frame")
        self.TextFrame.Name = "TextFrame"

        self.TextFrame.Size =
            UDim2.new(1, 0, 0, 0)

        self.TextFrame.AutomaticSize =
            Enum.AutomaticSize.Y

        self.TextFrame.BackgroundColor3 =
            theme.ParagraphTextFrame
            or theme.ElementContainer
            or DEFAULT_TEXT_BACKGROUND

        self.TextFrame.BorderColor3 =
            theme.Border
            or Color3.fromRGB(60, 60, 60)

        self.TextFrame.BorderSizePixel = 1
        self.TextFrame.LayoutOrder = 2
        self.TextFrame.Parent =
            self.ContentContainer

        self.TextLabel = Instance.new("TextLabel")
        self.TextLabel.Name = "Text"

        self.TextLabel.Size =
            UDim2.new(
                1,
                -(PADDING_X * 2),
                0,
                0
            )

        self.TextLabel.AutomaticSize =
            Enum.AutomaticSize.Y

        self.TextLabel.BackgroundTransparency = 1
        self.TextLabel.RichText = true
        self.TextLabel.TextWrapped = true

        self.TextLabel.TextXAlignment =
            Enum.TextXAlignment.Left

        self.TextLabel.TextYAlignment =
            Enum.TextYAlignment.Center

        self.TextLabel.TextSize =
            DEFAULT_TEXT_SIZE

        self.TextLabel.Font =
            self.Window.CurrentFont

        self.TextLabel.TextColor3 =
            theme.Text
            or DEFAULT_TEXT_COLOR

        self.TextLabel.Parent =
            self.TextFrame

        local textPadding =
            Instance.new("UIPadding")

        textPadding.PaddingTop =
            UDim.new(0, PADDING_Y)

        textPadding.PaddingBottom =
            UDim.new(0, PADDING_Y)

        textPadding.PaddingLeft =
            UDim.new(0, PADDING_X)

        textPadding.PaddingRight =
            UDim.new(0, PADDING_X)

        textPadding.Parent =
            self.TextFrame
    end

    self.Text =
        tostring(newText)

    self.TextLabel.Text =
        self.Text
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Paragraph:SetFont(fontType)
    if self.Destroyed then
        return
    end

    setFont(
        self.TitleLabel,
        fontType
    )

    if self.TextLabel then
        setFont(
            self.TextLabel,
            fontType
        )
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Paragraph:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleFrame.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    if self.TextFrame then

        self.TextFrame.BackgroundColor3 =
            theme.ParagraphTextFrame
            or theme.ElementContainer
            or DEFAULT_TEXT_BACKGROUND

        self.TextFrame.BorderColor3 =
            theme.Border
            or Color3.fromRGB(60, 60, 60)

    end

    if self.TextLabel then
        self.TextLabel.TextColor3 =
            theme.Text
            or DEFAULT_TEXT_COLOR
    end

    --------------------------------------------------------
    -- FONT
    --------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Paragraph:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end

    for i, element in ipairs(
        self.Tab.Elements
    ) do

        if element == self then
            table.remove(
                self.Tab.Elements,
                i
            )
            break
        end

    end
end

return Paragraph
