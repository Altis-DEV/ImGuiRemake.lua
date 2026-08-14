-- File: ImGuiRemake.lua/Components/TextInput.lua

local TextInput = {}
TextInput.__index = TextInput

local DEFAULT_SIZE =
    UDim2.new(1, -12, 0, 150)

local DEFAULT_TEXT_SIZE = 13
local PADDING = 8

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

    self.ClearTextOnFocus =
        options.ClearTextOnFocus == true

    self.Destroyed =
        false

    self.Focused =
        false

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- MAIN TEXTBOX FRAME
    ------------------------------------------------------------

    self.Container =
        Instance.new("Frame")

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

    self.Container.ClipsDescendants =
        true

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- TEXT DISPLAY
    --
    -- Dùng khi TextInput không focus để hỗ trợ
    -- TextTruncate.AtEnd (...).
    ------------------------------------------------------------

    self.Display =
        Instance.new("TextLabel")

    self.Display.Name =
        "Display"

    self.Display.Size =
        UDim2.new(
            1,
            -(PADDING * 2),
            1,
            -(PADDING * 2)
        )

    self.Display.Position =
        UDim2.new(
            0,
            PADDING,
            0,
            PADDING
        )

    self.Display.BackgroundTransparency =
        1

    self.Display.TextWrapped =
        true

    self.Display.TextTruncate =
        Enum.TextTruncate.AtEnd

    self.Display.TextXAlignment =
        Enum.TextXAlignment.Left

    self.Display.TextYAlignment =
        Enum.TextYAlignment.Top

    self.Display.TextSize =
        DEFAULT_TEXT_SIZE

    self.Display.Font =
        self.Window.CurrentFont

    self.Display.TextColor3 =
        theme.TextInputText
        or theme.Text
        or DEFAULT_TEXT_COLOR

    self.Display.Text =
        self.Text

    self.Display.Visible =
        not self.Focused

    self.Display.Parent =
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
            1,
            -(PADDING * 2)
        )

    self.Input.Position =
        UDim2.new(
            0,
            PADDING,
            0,
            PADDING
        )

    self.Input.BackgroundTransparency =
        1

    self.Input.BorderSizePixel =
        0

    self.Input.ClearTextOnFocus =
        self.ClearTextOnFocus

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

    self.Input.TextColor3 =
        theme.TextInputText
        or theme.Text
        or DEFAULT_TEXT_COLOR

    self.Input.PlaceholderText =
        self.Placeholder

    self.Input.PlaceholderColor3 =
        theme.TextInputPlaceholder
        or theme.Placeholder
        or DEFAULT_PLACEHOLDER_COLOR

    self.Input.Text =
        self.Text

    self.Input.Visible =
        self.Focused

    self.Input.Parent =
        self.Container

    ------------------------------------------------------------
    -- FOCUS
    ------------------------------------------------------------

    self.Input.Focused:Connect(
        function()

            if self.Destroyed then
                return
            end

            self.Focused =
                true

            self.Display.Visible =
                false

            self.Input.Visible =
                true

            ------------------------------------------------
            -- Đồng bộ display sau khi Roblox xử lý
            -- ClearTextOnFocus.
            ------------------------------------------------

            task.defer(
                function()

                    if self.Destroyed then
                        return
                    end

                    self.Text =
                        self.Input.Text

                    self.Display.Text =
                        self.Text
                end
            )
        end
    )

    ------------------------------------------------------------
    -- FOCUS LOST
    ------------------------------------------------------------

    self.Input.FocusLost:Connect(
        function()

            if self.Destroyed then
                return
            end

            self.Focused =
                false

            self.Text =
                self.Input.Text

            self.Display.Text =
                self.Text

            self.Input.Visible =
                false

            self.Display.Visible =
                true
        end
    )

    ------------------------------------------------------------
    -- TEXT CHANGED
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

            self.Display.Text =
                self.Text
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

    self.Display.Text =
        self.Text
end

------------------------------------------------------------
-- CLEAR
------------------------------------------------------------

function TextInput:Clear()

    if self.Destroyed then
        return
    end

    self.Text =
        ""

    self.Input.Text =
        ""

    self.Display.Text =
        ""
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function TextInput:SetFont(fontType)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- CUSTOM FONT
    --------------------------------------------------------

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

            self.Display.FontFace =
                customFont
        end

        return
    end

    --------------------------------------------------------
    -- ENUM FONT
    --------------------------------------------------------

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType
            == Enum.Font then

        self.Input.Font =
            fontType

        self.Display.Font =
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

    --------------------------------------------------------
    -- FRAME
    --------------------------------------------------------

    self.Container.BackgroundColor3 =
        theme.TextInputFrame

    self.Container.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    local textColor =
        theme.TextInputText
        or theme.Text
        or DEFAULT_TEXT_COLOR

    self.Input.TextColor3 =
        textColor

    self.Display.TextColor3 =
        textColor

    --------------------------------------------------------
    -- PLACEHOLDER
    --------------------------------------------------------

    self.Input.PlaceholderColor3 =
        theme.TextInputPlaceholder
        or theme.Placeholder
        or DEFAULT_PLACEHOLDER_COLOR

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
