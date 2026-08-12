-- File: ImGuiRemake.lua/Components/Paragraph.lua

local Paragraph = {}
Paragraph.__index = Paragraph

local PADDING_X = 8
local PADDING_Y = 6
local ELEMENT_GAP = 0

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

    local self = setmetatable({}, Paragraph)

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(
        options.Title or ""
    )

    self.Text = tostring(
        options.Text or ""
    )

    self.Destroyed = false

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- MAIN CONTAINER
    ------------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name = "Paragraph"

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
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- TITLE FRAME
    ------------------------------------------------------------

    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Name = "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

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

    self.TitleFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE LABEL
    ------------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            0,
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

    -- Căn trái + giữa theo chiều dọc
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
    -- SEPARATOR / BORDER
    ------------------------------------------------------------

    self.Separator = Instance.new("Frame")
    self.Separator.Name = "Separator"

    self.Separator.Size =
        UDim2.new(
            1,
            0,
            0,
            1
        )

    self.Separator.BackgroundColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.Separator.BorderSizePixel = 0
    self.Separator.Parent =
        self.Container

    ------------------------------------------------------------
    -- TEXT FRAME
    ------------------------------------------------------------

    self.TextFrame = Instance.new("Frame")
    self.TextFrame.Name = "TextFrame"

    self.TextFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

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

    self.TextFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- TEXT LABEL
    ------------------------------------------------------------

    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Name = "Text"

    self.TextLabel.Size =
        UDim2.new(
            1,
            0,
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

    -- Căn trái + giữa theo chiều dọc
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

    ------------------------------------------------------------
    -- TEXT PADDING
    ------------------------------------------------------------

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

    setFont(
        self.TextLabel,
        fontType
    )
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Paragraph:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TITLE FRAME
    --------------------------------------------------------

    self.TitleFrame.BackgroundColor3 =
        theme.ParagraphTitleFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    --------------------------------------------------------
    -- SEPARATOR
    --------------------------------------------------------

    self.Separator.BackgroundColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    --------------------------------------------------------
    -- TEXT FRAME
    --------------------------------------------------------

    self.TextFrame.BackgroundColor3 =
        theme.ParagraphTextFrame
        or theme.ElementContainer
        or DEFAULT_TEXT_BACKGROUND

    self.TextFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    --------------------------------------------------------
    -- TEXT COLOR
    --------------------------------------------------------

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self.TextLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

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
