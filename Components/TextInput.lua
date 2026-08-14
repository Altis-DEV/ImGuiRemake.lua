-- File: ImGuiRemake.lua/Components/TextInput.lua

local TextInput = {}
TextInput.__index = TextInput

local DEFAULT_SIZE =
    UDim2.new(1, -12, 0, 150)

local DEFAULT_TEXT_SIZE = 13
local PADDING = 8
local SCROLLBAR_THICKNESS = 4

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(255, 255, 255)

local DEFAULT_PLACEHOLDER_COLOR =
    Color3.fromRGB(150, 150, 150)

function TextInput.new(tab, options)
    options = options or {}

    local self =
        setmetatable(
            {},
            TextInput
        )

    self.Tab = tab
    self.Window = tab.Window

    ------------------------------------------------------------
    -- PROPERTIES
    ------------------------------------------------------------

    self.Size =
        options.Size
        or DEFAULT_SIZE

    self.Text =
        tostring(
            options.Text
                or ""
        )

    self.Placeholder =
        tostring(
            options.Placeholder
                or ""
        )

    self.Destroyed =
        false

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- SCROLLING FRAME
    ------------------------------------------------------------

    self.Container =
        Instance.new("ScrollingFrame")

    self.Container.Name =
        "TextInput"

    self.Container.Size =
        self.Size

    self.Container.BackgroundColor3 =
        theme.TextInputFrame

    self.Container.BorderColor3 =
        theme.Border

    self.Container.BorderSizePixel =
        1

    self.Container.ScrollBarThickness =
        SCROLLBAR_THICKNESS

    self.Container.ScrollingDirection =
        Enum.ScrollingDirection.Y

    self.Container.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    self.Container.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.Container.ScrollingEnabled =
        true

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- PADDING
    ------------------------------------------------------------

    self.Padding =
        Instance.new("UIPadding")

    self.Padding.PaddingTop =
        UDim.new(
            0,
            PADDING
        )

    self.Padding.PaddingBottom =
        UDim.new(
            0,
            PADDING
        )

    self.Padding.PaddingLeft =
        UDim.new(
            0,
            PADDING
        )

    self.Padding.PaddingRight =
        UDim.new(
            0,
            PADDING
        )

    self.Padding.Parent =
        self.Container

    ------------------------------------------------------------
    -- INPUT
    ------------------------------------------------------------

    self.Input =
        Instance.new("TextBox")

    self.Input.Name =
        "Input"

    self.Input.Size =
        UDim2.new(
            1,
            -(PADDING * 2),
            0,
            0
        )

    self.Input.AutomaticSize =
        Enum.AutomaticSize.Y

    self.Input.BackgroundTransparency =
        1

    self.Input.BorderSizePixel =
        0

    self.Input.ClearTextOnFocus =
        false

    self.Input.MultiLine =
        true

    self.Input.TextWrapped =
        true

    self.Input.TextXAlignment =
        Enum.TextXAlignment.Left

    self.Input.TextYAlignment =
        Enum.TextYAlignment.Top

    self.Input.TextSize =
        DEFAULT_TEXT_SIZE

    self.Input.Font =
        self.Window.CurrentFont

    ------------------------------------------------------------
    -- TEXT
    ------------------------------------------------------------

    self.Input.TextColor3 =
        theme.TextInputText
        or theme.Text
        or DEFAULT_TEXT_COLOR

    self.Input.Text =
        self.Text

    ------------------------------------------------------------
    -- PLACEHOLDER
    ------------------------------------------------------------

    self.Input.PlaceholderText =
        self.Placeholder

    self.Input.PlaceholderColor3 =
        theme.TextInputPlaceholder
        or theme.Placeholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.Input.Parent =
        self.Container

    ------------------------------------------------------------
    -- UPDATE INTERNAL TEXT
    ------------------------------------------------------------

    self.Input:GetPropertyChangedSignal(
        "Text"
    ):Connect(
        function()

            if self.Destroyed then
                return
            end

            self.Text =
                self.Input.Text
        end
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
-- SET TEXT
------------------------------------------------------------

function TextInput:SetText(text)

    if self.Destroyed then
        return
    end

    self.Text =
        tostring(
            text
                or ""
        )

    self.Input.Text =
        self.Text

    self.Container.CanvasPosition =
        Vector2.new(
            0,
            math.huge
        )
end

------------------------------------------------------------
-- CLEAR
------------------------------------------------------------

function TextInput:Clear()

    if self.Destroyed then
        return
    end

    self.Text = ""

    self.Input.Text = ""

    self.Container.CanvasPosition =
        Vector2.new(
            0,
            0
        )
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function TextInput:SetFont(fontType)

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
            self.Input.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType
            == Enum.Font then

        self.Input.Font =
            fontType
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function TextInput:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    ------------------------------------------------------------
    -- FRAME
    ------------------------------------------------------------

    self.Container.BackgroundColor3 =
        theme.TextInputFrame

    self.Container.BorderColor3 =
        theme.Border

    ------------------------------------------------------------
    -- TEXT
    ------------------------------------------------------------

    self.Input.TextColor3 =
        theme.TextInputText
        or theme.Text

    ------------------------------------------------------------
    -- PLACEHOLDER
    ------------------------------------------------------------

    self.Input.PlaceholderColor3 =
        theme.TextInputPlaceholder
        or theme.Placeholder
        or DEFAULT_PLACEHOLDER_COLOR

    ------------------------------------------------------------
    -- FONT
    ------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function TextInput:Destroy()

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

return TextInput
