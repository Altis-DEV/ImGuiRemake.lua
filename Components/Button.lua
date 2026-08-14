-- File: ImGuiRemake.lua/Components/Button.lua

local Button = {}
Button.__index = Button

local TweenService = game:GetService("TweenService")

local DEFAULT_HEIGHT = 30
local DEFAULT_HORIZONTAL_PADDING = 15

function Button.new(tab, options)
    local self = setmetatable({}, Button)

    options = options or {}

    self.Tab = tab
    self.Window = tab.Window
    self.WidthAtRow = options.WidthAtRow

    self.Title = tostring(
        options.Title or "Button"
    )

    self.Type = options.Type or "Default"

    self.Callback =
        type(options.Callback) == "function"
        and options.Callback
        or function() end

    ------------------------------------------------------------
    -- CUSTOM COLORS
    --
    -- Nếu nil:
    --   Color          -> theme.Button
    --   HighlightColor -> theme.ButtonHighlight
    ------------------------------------------------------------

    self.Color = options.Color
    self.HighlightColor = options.HighlightColor

    self.Destroyed = false

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- BUTTON
    ------------------------------------------------------------

    self.Instance = Instance.new("TextButton")

    self.Instance.Name =
        "Button_" .. self.Title

    self.Instance.Text =
        self.Title

    self.Instance.TextColor3 =
        theme.ButtonText

    self.Instance.BackgroundColor3 =
        self.Color
        or theme.Button

    self.Instance.BorderColor3 =
        theme.Border

    self.Instance.BorderSizePixel = 1
    self.Instance.TextSize = 13
    self.Instance.AutoButtonColor = false

    ------------------------------------------------------------
    -- SIZE
    ------------------------------------------------------------

    if self.Type == "Full" then

        -- Full width của parent hiện tại.
        --
        -- Section đã có UIPadding bên trong
        -- ElementContainer, nên không cần -12.
        self.Instance.Size =
            UDim2.new(
                1,
                0,
                0,
                DEFAULT_HEIGHT
            )

        self.Instance.AutomaticSize =
            Enum.AutomaticSize.None

    else

        self.Instance.Size =
            UDim2.new(
                0,
                0,
                0,
                DEFAULT_HEIGHT
            )

        self.Instance.AutomaticSize =
            Enum.AutomaticSize.X

        local btnPadding =
            Instance.new("UIPadding")

        btnPadding.PaddingLeft =
            UDim.new(
                0,
                DEFAULT_HORIZONTAL_PADDING
            )

        btnPadding.PaddingRight =
            UDim.new(
                0,
                DEFAULT_HORIZONTAL_PADDING
            )

        btnPadding.Parent =
            self.Instance
    end

    ------------------------------------------------------------
    -- PARENT
    ------------------------------------------------------------

    self.Instance.Parent =
        self.Tab.ContentFrame

    table.insert(
        self.Tab.Elements,
        self
    )

    ------------------------------------------------------------
    -- INITIAL FONT
    ------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    ------------------------------------------------------------
    -- HOVER
    ------------------------------------------------------------

    self.Instance.MouseEnter:Connect(
        function()

            if self.Destroyed then
                return
            end

            TweenService:Create(
                self.Instance,
                TweenInfo.new(0.2),
                {
                    BackgroundColor3 =
                        self.HighlightColor
                        or self.Window.ThemeData.ButtonHighlight
                }
            ):Play()
        end
    )

    ------------------------------------------------------------
    -- LEAVE
    ------------------------------------------------------------

    self.Instance.MouseLeave:Connect(
        function()

            if self.Destroyed then
                return
            end

            TweenService:Create(
                self.Instance,
                TweenInfo.new(0.2),
                {
                    BackgroundColor3 =
                        self.Color
                        or self.Window.ThemeData.Button
                }
            ):Play()
        end
    )

    ------------------------------------------------------------
    -- MOUSE DOWN
    ------------------------------------------------------------

    self.Instance.MouseButton1Down:Connect(
        function()

            if self.Destroyed then
                return
            end

            self.Instance.BackgroundColor3 =
                self.HighlightColor
                or self.Window.ThemeData.ButtonHighlight
        end
    )

    ------------------------------------------------------------
    -- MOUSE UP
    ------------------------------------------------------------

    self.Instance.MouseButton1Up:Connect(
        function()

            if self.Destroyed then
                return
            end

            self.Instance.BackgroundColor3 =
                self.Color
                or self.Window.ThemeData.Button
        end
    )

    ------------------------------------------------------------
    -- CALLBACK
    ------------------------------------------------------------

    self.Instance.MouseButton1Click:Connect(
        function()

            if self.Destroyed then
                return
            end

            task.spawn(
                function()

                    local ok, err =
                        pcall(
                            self.Callback
                        )

                    if not ok then
                        warn(
                            "Button callback error:",
                            err
                        )
                    end

                end
            )
        end
    )

    return self
end

------------------------------------------------------------
-- SET TITLE
------------------------------------------------------------

function Button:SetTitle(newTitle)

    if self.Destroyed then
        return
    end

    self.Title =
        tostring(newTitle)

    self.Instance.Name =
        "Button_" .. self.Title

    self.Instance.Text =
        self.Title
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Button:SetFont(fontType)

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
                    return Font.new(fontType)
                end
            )

        if ok and customFont then

            self.Instance.FontFace =
                customFont

        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        self.Instance.Font =
            fontType
    end
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Button:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.Instance then

        self.Instance:Destroy()
        self.Instance = nil

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

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Button:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    ------------------------------------------------------------
    -- TEXT
    ------------------------------------------------------------

    self.Instance.TextColor3 =
        theme.ButtonText

    ------------------------------------------------------------
    -- BACKGROUND
    --
    -- Custom Color được giữ nguyên.
    ------------------------------------------------------------

    self.Instance.BackgroundColor3 =
        self.Color
        or theme.Button

    ------------------------------------------------------------
    -- BORDER
    ------------------------------------------------------------

    self.Instance.BorderColor3 =
        theme.Border

    ------------------------------------------------------------
    -- FONT
    ------------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )
end

return Button
