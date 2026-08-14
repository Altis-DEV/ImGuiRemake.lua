-- File: ImGuiRemake.lua/Components/Divider.lua

local Divider = {}
Divider.__index = Divider

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local DIVIDER_HEIGHT = 20
local LINE_HEIGHT = 1
local TITLE_GAP = 10

local DEFAULT_TEXT_SIZE = 13

------------------------------------------------------------
-- FONT
------------------------------------------------------------

local function setFont(instance, fontType)
    if not instance then
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
            pcall(function()
                return Font.new(fontType)
            end)

        if ok and customFont then
            instance.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        instance.Font =
            fontType
    end
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Divider.new(tab, options)

    options = options or {}

    local self =
        setmetatable(
            {},
            Divider
        )

    self.Tab = tab
    self.Window = tab.Window

    self.Destroyed = false

    ------------------------------------------------------------
    -- TITLE OPTIONAL
    ------------------------------------------------------------

    self.HasTitle =
        options.Title ~= nil

    self.Title =
        self.HasTitle
        and tostring(options.Title)
        or ""

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- OUTER CONTAINER
    --
    -- Chiều cao 20px để tạo khoảng cách giữa
    -- element bên trên và bên dưới.
    ------------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        "Divider"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            DIVIDER_HEIGHT
        )

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- LEFT LINE
    ------------------------------------------------------------

    self.LeftLine =
        Instance.new("Frame")

    self.LeftLine.Name =
        "LeftLine"

    self.LeftLine.Size =
        UDim2.new(
            self.HasTitle and 0.5 or 1,
            self.HasTitle
                and -(TITLE_GAP / 2)
                or 0,
            0,
            LINE_HEIGHT
        )

    self.LeftLine.AnchorPoint =
        Vector2.new(
            0,
            0.5
        )

    self.LeftLine.Position =
        UDim2.new(
            0,
            0,
            0.5,
            0
        )

    self.LeftLine.BackgroundColor3 =
        theme.Border

    self.LeftLine.BorderSizePixel =
        0

    self.LeftLine.Parent =
        self.Container

    ------------------------------------------------------------
    -- RIGHT LINE
    ------------------------------------------------------------

    self.RightLine =
        Instance.new("Frame")

    self.RightLine.Name =
        "RightLine"

    self.RightLine.Size =
        UDim2.new(
            self.HasTitle and 0.5 or 0,
            self.HasTitle
                and -(TITLE_GAP / 2)
                or 0,
            0,
            LINE_HEIGHT
        )

    self.RightLine.AnchorPoint =
        Vector2.new(
            1,
            0.5
        )

    self.RightLine.Position =
        UDim2.new(
            1,
            0,
            0.5,
            0
        )

    self.RightLine.BackgroundColor3 =
        theme.Border

    self.RightLine.BorderSizePixel =
        0

    self.RightLine.Parent =
        self.Container

    ------------------------------------------------------------
    -- TITLE
    ------------------------------------------------------------

    if self.HasTitle then

        self.TitleLabel =
            Instance.new("TextLabel")

        self.TitleLabel.Name =
            "Title"

        self.TitleLabel.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

        self.TitleLabel.Position =
            UDim2.new(
                0.5,
                0,
                0.5,
                0
            )

        self.TitleLabel.Size =
            UDim2.new(
                0,
                0,
                1,
                0
            )

        self.TitleLabel.AutomaticSize =
            Enum.AutomaticSize.X

        self.TitleLabel.BackgroundColor3 =
            theme.ElementContainer

        self.TitleLabel.BackgroundTransparency =
            0

        self.TitleLabel.BorderSizePixel =
            0

        self.TitleLabel.Text =
            self.Title

        self.TitleLabel.TextColor3 =
            theme.Text

        self.TitleLabel.TextSize =
            DEFAULT_TEXT_SIZE

        self.TitleLabel.Font =
            self.Window.CurrentFont

        self.TitleLabel.TextXAlignment =
            Enum.TextXAlignment.Center

        self.TitleLabel.TextYAlignment =
            Enum.TextYAlignment.Center

        self.TitleLabel.Parent =
            self.Container

        --------------------------------------------------------
        -- TITLE PADDING
        --
        -- 10px khoảng trống hai bên title.
        --------------------------------------------------------

        local titlePadding =
            Instance.new("UIPadding")

        titlePadding.PaddingLeft =
            UDim.new(
                0,
                TITLE_GAP
            )

        titlePadding.PaddingRight =
            UDim.new(
                0,
                TITLE_GAP
            )

        titlePadding.Parent =
            self.TitleLabel
    end

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

function Divider:SetTitle(
    newTitle
)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- REMOVE TITLE
    --------------------------------------------------------

    if newTitle == nil
        or tostring(newTitle) == "" then

        self.HasTitle = false
        self.Title = ""

        if self.TitleLabel then

            self.TitleLabel:Destroy()
            self.TitleLabel = nil

        end

        ----------------------------------------------------
        -- FULL LINE
        ----------------------------------------------------

        self.LeftLine.Size =
            UDim2.new(
                1,
                0,
                0,
                LINE_HEIGHT
            )

        self.LeftLine.Position =
            UDim2.new(
                0,
                0,
                0.5,
                0
            )

        self.RightLine.Size =
            UDim2.new(
                0,
                0,
                0,
                0
            )

        return
    end

    --------------------------------------------------------
    -- CREATE TITLE IF NEEDED
    --------------------------------------------------------

    self.HasTitle = true
    self.Title =
        tostring(newTitle)

    if not self.TitleLabel then

        local theme =
            self.Window.ThemeData

        self.TitleLabel =
            Instance.new("TextLabel")

        self.TitleLabel.Name =
            "Title"

        self.TitleLabel.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

        self.TitleLabel.Position =
            UDim2.new(
                0.5,
                0,
                0.5,
                0
            )

        self.TitleLabel.Size =
            UDim2.new(
                0,
                0,
                1,
                0
            )

        self.TitleLabel.AutomaticSize =
            Enum.AutomaticSize.X

        self.TitleLabel.BackgroundColor3 =
            theme.ElementContainer

        self.TitleLabel.BackgroundTransparency =
            0

        self.TitleLabel.BorderSizePixel =
            0

        self.TitleLabel.TextColor3 =
            theme.Text

        self.TitleLabel.TextSize =
            DEFAULT_TEXT_SIZE

        self.TitleLabel.Font =
            self.Window.CurrentFont

        self.TitleLabel.TextXAlignment =
            Enum.TextXAlignment.Center

        self.TitleLabel.TextYAlignment =
            Enum.TextYAlignment.Center

        self.TitleLabel.Parent =
            self.Container

        local titlePadding =
            Instance.new("UIPadding")

        titlePadding.PaddingLeft =
            UDim.new(
                0,
                TITLE_GAP
            )

        titlePadding.PaddingRight =
            UDim.new(
                0,
                TITLE_GAP
            )

        titlePadding.Parent =
            self.TitleLabel
    end

    self.TitleLabel.Text =
        self.Title

    --------------------------------------------------------
    -- SPLIT LINE AGAIN
    --------------------------------------------------------

    self.LeftLine.Size =
        UDim2.new(
            0.5,
            -(TITLE_GAP / 2),
            0,
            LINE_HEIGHT
        )

    self.RightLine.Size =
        UDim2.new(
            0.5,
            -(TITLE_GAP / 2),
            0,
            LINE_HEIGHT
        )

    self.RightLine.Position =
        UDim2.new(
            1,
            0,
            0.5,
            0
        )
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Divider:SetFont(
    fontType
)

    if self.Destroyed then
        return
    end

    if self.TitleLabel then

        setFont(
            self.TitleLabel,
            fontType
        )

    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Divider:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- LINE
    --------------------------------------------------------

    self.LeftLine.BackgroundColor3 =
        theme.Border

    self.RightLine.BackgroundColor3 =
        theme.Border

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    if self.TitleLabel then

        self.TitleLabel.BackgroundColor3 =
            theme.ElementContainer

        self.TitleLabel.TextColor3 =
            theme.Text

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

function Divider:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed =
        true

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

return Divider
