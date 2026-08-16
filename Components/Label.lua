-- File: ImGuiRemake.lua/Components/Label.lua

local Label = {}
Label.__index = Label

local PADDING_X = 8
local PADDING_Y = 4
local DEFAULT_TEXT_SIZE = 13

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(
        255,
        255,
        255
    )

------------------------------------------------------------
-- TEXT ALIGNMENT
------------------------------------------------------------

local function getTextAlignment(
    alignment
)

    if typeof(alignment) == "EnumItem"
        and alignment.EnumType
            == Enum.TextXAlignment then

        return alignment
    end

    if type(alignment) == "string" then

        local normalized =
            string.lower(
                alignment
            )

        if normalized == "center" then

            return Enum.TextXAlignment.Center

        elseif normalized == "right" then

            return Enum.TextXAlignment.Right

        elseif normalized == "left" then

            return Enum.TextXAlignment.Left

        end
    end

    return Enum.TextXAlignment.Left
end

------------------------------------------------------------
-- FONT
------------------------------------------------------------

local function setFont(
    instance,
    fontType
)

    if typeof(fontType) == "string"
        and string.find(
            string.lower(
                fontType
            ),
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

            instance.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType
            == Enum.Font then

        instance.Font =
            fontType
    end
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Label.new(
    tab,
    options
)

    options =
        options
        or {}

    if options.Title == nil then

        error(
            "Label requires a Title",
            2
        )
    end

    local self =
        setmetatable(
            {},
            Label
        )

    self.Tab =
        tab

    self.Window =
        tab.Window

    self.WidthAtRow =
        options.WidthAtRow

    self.Title =
        tostring(
            options.Title
        )

    --------------------------------------------------------
    -- TEXT ALIGNMENT
    --
    -- Default:
    -- Left
    --
    -- Supported:
    -- "Left"
    -- "Center"
    -- "Right"
    --
    -- Enum.TextXAlignment is also accepted.
    --------------------------------------------------------

    self.TextAlignment =
        getTextAlignment(
            options.TextAlignment
        )

    self.Destroyed =
        false

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- CONTAINER
    ------------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        "Label"

    self.Container.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.Container.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- TEXT
    ------------------------------------------------------------

    self.TextLabel =
        Instance.new("TextLabel")

    self.TextLabel.Name =
        "Text"

    self.TextLabel.Size =
        UDim2.new(
            1,
            -(PADDING_X * 2),
            0,
            0
        )

    self.TextLabel.Position =
        UDim2.new(
            0,
            PADDING_X,
            0,
            0
        )

    self.TextLabel.AutomaticSize =
        Enum.AutomaticSize.Y

    self.TextLabel.BackgroundTransparency =
        1

    self.TextLabel.BorderSizePixel =
        0

    self.TextLabel.Text =
        self.Title

    --------------------------------------------------------
    -- RICHTEXT / WRAPPING
    --------------------------------------------------------

    self.TextLabel.RichText =
        true

    self.TextLabel.TextWrapped =
        true

    --------------------------------------------------------
    -- TEXT ALIGNMENT
    --------------------------------------------------------

    self.TextLabel.TextXAlignment =
        self.TextAlignment

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
        self.Container

    ------------------------------------------------------------
    -- PADDING
    ------------------------------------------------------------

    local padding =
        Instance.new("UIPadding")

    padding.PaddingTop =
        UDim.new(
            0,
            PADDING_Y
        )

    padding.PaddingBottom =
        UDim.new(
            0,
            PADDING_Y
        )

    padding.PaddingLeft =
        UDim.new(
            0,
            PADDING_X
        )

    padding.PaddingRight =
        UDim.new(
            0,
            PADDING_X
        )

    padding.Parent =
        self.Container

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

function Label:SetTitle(
    newTitle
)

    if self.Destroyed then
        return
    end

    if newTitle == nil then
        return
    end

    self.Title =
        tostring(
            newTitle
        )

    self.TextLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Label:SetFont(
    fontType
)

    if self.Destroyed then
        return
    end

    setFont(
        self.TextLabel,
        fontType
    )
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Label:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    self.TextLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Label:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed =
        true

    if self.Container then

        self.Container:Destroy()
        self.Container =
            nil
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

return Label
