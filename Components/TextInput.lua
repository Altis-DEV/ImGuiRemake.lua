-- File: ImGuiRemake.lua/Components/TextInput.lua

local TextInput = {}
TextInput.__index = TextInput

local DEFAULT_SIZE = UDim2.new(1, -12, 0, 150)
local DEFAULT_TEXT_SIZE = 13
local PADDING = 8

local DEFAULT_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local DEFAULT_PLACEHOLDER_COLOR = Color3.fromRGB(150, 150, 150)

function TextInput.new(tab, options)
    options = options or {}

    local self = setmetatable({}, TextInput)

    self.Tab = tab
    self.Window = tab.Window
    self.WidthAtRow = options.WidthAtRow

    self.Size = options.Size or DEFAULT_SIZE
    self.Text = tostring(options.Text or "")
    self.Placeholder = tostring(options.Placeholder or "")
    self.ClearTextOnFocus = options.ClearTextOnFocus == true
    self.Destroyed = false

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- TEXTBOX
    ------------------------------------------------------------

    self.Input = Instance.new("TextBox")
    self.Input.Name = "TextInput"
    self.Input.Size = self.Size
    self.Input.BackgroundColor3 =
        theme.TextInputFrame
        or theme.Background
    self.Input.BorderColor3 =
        theme.Border
    self.Input.BorderSizePixel = 1
    self.Input.ClearTextOnFocus =
        self.ClearTextOnFocus
    self.Input.MultiLine = true
    self.Input.TextWrapped = true
    self.Input.TextTruncate =
        Enum.TextTruncate.AtEnd

    self.Input.TextXAlignment =
        Enum.TextXAlignment.Left
    self.Input.TextYAlignment =
        Enum.TextYAlignment.Top

    self.Input.TextSize = DEFAULT_TEXT_SIZE
    self.Input.Font = self.Window.CurrentFont
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

    self.Input.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- PADDING
    ------------------------------------------------------------

    self.Padding =
        Instance.new("UIPadding")

    self.Padding.PaddingTop =
        UDim.new(0, PADDING)

    self.Padding.PaddingBottom =
        UDim.new(0, PADDING)

    self.Padding.PaddingLeft =
        UDim.new(0, PADDING)

    self.Padding.PaddingRight =
        UDim.new(0, PADDING)

    self.Padding.Parent =
        self.Input

    ------------------------------------------------------------
    -- TEXT CHANGED
    ------------------------------------------------------------

    self.Input:GetPropertyChangedSignal("Text"):Connect(
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
        tostring(text or "")

    self.Input.Text =
        self.Text
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
            pcall(function()
                return Font.new(fontType)
            end)

        if ok and customFont then
            self.Input.FontFace =
                customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

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

    self.Input.BackgroundColor3 =
        theme.TextInputFrame
        or theme.Background

    self.Input.BorderColor3 =
        theme.Border

    self.Input.TextColor3 =
        theme.TextInputText
        or theme.Text
        or DEFAULT_TEXT_COLOR

    self.Input.PlaceholderColor3 =
        theme.TextInputPlaceholder
        or theme.Placeholder
        or DEFAULT_PLACEHOLDER_COLOR

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

    self.Destroyed = true

    if self.Input then
        self.Input:Destroy()
        self.Input = nil
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
