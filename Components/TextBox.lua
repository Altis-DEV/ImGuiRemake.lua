-- File: ImGuiRemake.lua/Components/TextBox.lua

local TextBox = {}
TextBox.__index = TextBox

local UserInputService = game:GetService("UserInputService")

local ELEMENT_HEIGHT = 30
local TEXTBOX_WIDTH_SCALE = 0.5
local ELEMENT_GAP = 8

function TextBox.new(tab, options)
    options = options or {}

    local self = setmetatable({}, TextBox)

    self.Tab = tab
    self.Window = tab.Window

    self.Title = tostring(
        options.Title or "TextBox"
    )

    self.Subtitle = tostring(
        options.Subtitle or ""
    )

    self.ClearOnFocus =
        options.ClearOnFocus == true
        or options.ClearOnfocus == true

    self.Text = tostring(
        options.Text or ""
    )

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    self.Destroyed = false
    self.HasFocusedOnce = false

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- CONTAINER
    ------------------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Name =
        self.Title .. "_TextBox"

    self.Container.Size =
        UDim2.new(
            1,
            -12,
            0,
            ELEMENT_HEIGHT
        )

    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- TEXTBOX FRAME
    ------------------------------------------------------------

    self.TextBoxFrame = Instance.new("Frame")
    self.TextBoxFrame.Name =
        "TextBoxFrame"

    self.TextBoxFrame.Size =
        UDim2.new(
            TEXTBOX_WIDTH_SCALE,
            0,
            0,
            ELEMENT_HEIGHT
        )

    self.TextBoxFrame.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.TextBoxFrame.BackgroundColor3 =
        theme.TextBoxFrame
        or theme.Border
        or Color3.fromRGB(38, 38, 38)

    self.TextBoxFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.TextBoxFrame.BorderSizePixel = 1

    self.TextBoxFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- ROBLOX TEXTBOX
    ------------------------------------------------------------

    self.Input = Instance.new("TextBox")
    self.Input.Name =
        "Input"

    self.Input.Size =
        UDim2.new(
            1,
            -12,
            1,
            0
        )

    self.Input.Position =
        UDim2.new(
            0,
            6,
            0,
            0
        )

    self.Input.BackgroundTransparency = 1

    self.Input.Text =
        self.Text

    self.Input.PlaceholderText =
        self.Subtitle

    self.Input.PlaceholderColor3 =
        theme.TextBoxText
        or theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.Input.TextColor3 =
        theme.TextBoxText
        or theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.Input.TextSize = 13
    self.Input.Font =
        self.Window.CurrentFont

    self.Input.TextXAlignment =
        Enum.TextXAlignment.Center

    self.Input.TextYAlignment =
        Enum.TextYAlignment.Center

    self.Input.ClearTextOnFocus =
        false

    self.Input.TextWrapped = false

    self.Input.Parent =
        self.TextBoxFrame

    ------------------------------------------------------------
    -- TITLE
    ------------------------------------------------------------

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1 - TEXTBOX_WIDTH_SCALE,
            -ELEMENT_GAP,
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            TEXTBOX_WIDTH_SCALE,
            ELEMENT_GAP,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.Parent =
        self.Container

    ------------------------------------------------------------
    -- FOCUS
    ------------------------------------------------------------

    self.Input.Focused:Connect(function()

        if self.Destroyed then
            return
        end

        if self.ClearOnFocus
            and not self.HasFocusedOnce then

            self.HasFocusedOnce = true

            self.Input.Text = ""
            self.Text = ""

        end
    end)

    ------------------------------------------------------------
    -- TEXT CHANGED
    ------------------------------------------------------------

    self.Input:GetPropertyChangedSignal(
        "Text"
    ):Connect(function()

        if self.Destroyed then
            return
        end

        self.Text =
            self.Input.Text

        task.spawn(function()

            local ok, err =
                pcall(
                    self.Callback,
                    self.Text
                )

            if not ok then
                warn(
                    "TextBox callback error:",
                    err
                )
            end

        end)
    end)

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

function TextBox:SetText(text)
    if self.Destroyed then
        return
    end

    self.Text =
        tostring(text)

    self.Input.Text =
        self.Text
end

------------------------------------------------------------
-- CLEAR
------------------------------------------------------------

function TextBox:Clear()
    if self.Destroyed then
        return
    end

    self.Text = ""
    self.Input.Text = ""
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function TextBox:SetTitle(newTitle)
    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Container.Name =
        self.Title .. "_TextBox"

    self.TitleLabel.Text =
        self.Title
end

------------------------------------------------------------
-- SET SUBTITLE
------------------------------------------------------------

function TextBox:SetSubtitle(newSubtitle)
    if self.Destroyed then
        return
    end

    self.Subtitle =
        tostring(newSubtitle)

    self.Input.PlaceholderText =
        self.Subtitle
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function TextBox:SetFont(fontType)
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

            self.TitleLabel.FontFace =
                customFont

        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.Input.Font =
            fontType

        self.TitleLabel.Font =
            fontType

    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function TextBox:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    self.TextBoxFrame.BackgroundColor3 =
        theme.TextBoxFrame
        or theme.Border
        or Color3.fromRGB(38, 38, 38)

    self.TextBoxFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.Input.TextColor3 =
        theme.TextBoxText
        or theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.Input.PlaceholderColor3 =
        theme.TextBoxText
        or theme.Text
        or Color3.fromRGB(255, 255, 255)

    self.TitleLabel.TextColor3 =
        theme.Text
        or Color3.fromRGB(255, 255, 255)

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function TextBox:Destroy()
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

return TextBox
