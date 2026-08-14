-- File: ImGuiRemake.lua/Components/Modal.lua

local Modal = {}
Modal.__index = Modal

local TweenService = game:GetService("TweenService")

local MODAL_WIDTH = 420

local PADDING_X = 8
local PADDING_Y = 6
local DEFAULT_TEXT_SIZE = 13

local BUTTON_HEIGHT = 32
local BUTTON_PADDING_X = 6
local BUTTON_PADDING_Y = 6
local BUTTON_GAP = 5

local ANIMATION_TIME = 0.22

local DEFAULT_BACKGROUND =
    Color3.fromRGB(22, 22, 22)

local DEFAULT_TITLE_BACKGROUND =
    Color3.fromRGB(32, 32, 32)

local DEFAULT_TEXT_BACKGROUND =
    Color3.fromRGB(26, 26, 26)

local DEFAULT_BUTTON_BACKGROUND =
    Color3.fromRGB(40, 90, 175)

local DEFAULT_BUTTON_HIGHLIGHT =
    Color3.fromRGB(60, 110, 220)

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(255, 255, 255)

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
            instance.FontFace = customFont
        end

        return
    end

    if typeof(fontType) == "EnumItem"
        and fontType.EnumType == Enum.Font then

        instance.Font = fontType
    end
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Modal.new(tab, options)
    options = options or {}

    if options.Title == nil then
        error(
            "Modal requires a Title",
            2
        )
    end

    local self =
        setmetatable({}, Modal)

    self.Tab = tab
    self.Window = tab.Window

    self.Title =
        tostring(options.Title)

    self.HasText =
        options.Text ~= nil

    self.Text =
        self.HasText
        and tostring(options.Text)
        or ""

    self.Buttons =
        type(options.Buttons) == "table"
        and options.Buttons
        or {}

    self.Destroyed = false
    self.Opened = true
    self.ButtonObjects = {}

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- OVERLAY
    ------------------------------------------------------------

    self.Overlay =
        Instance.new("Frame")

    self.Overlay.Name =
        "ModalOverlay"

    self.Overlay.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    self.Overlay.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.Overlay.BackgroundColor3 =
        theme.ModalOverlay
        or Color3.fromRGB(
            0,
            0,
            0
        )

    self.Overlay.BackgroundTransparency =
        theme.ModalOverlayTransparency ~= nil
        and theme.ModalOverlayTransparency
        or 0.45

    self.Overlay.BorderSizePixel =
        0

    self.Overlay.ZIndex =
        500

    self.Overlay.Parent =
        self.Window.ScreenGui

    ------------------------------------------------------------
    -- MODAL FRAME
    --
    -- X FIXED
    -- Y AUTOMATIC
    ------------------------------------------------------------

    self.ModalFrame =
        Instance.new("Frame")

    self.ModalFrame.Name =
        "ModalFrame"

    self.ModalFrame.Size =
        UDim2.new(
            0,
            MODAL_WIDTH,
            0,
            0
        )

    self.ModalFrame.AutomaticSize =
        Enum.AutomaticSize.Y

    self.ModalFrame.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    self.ModalFrame.Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            0
        )

    self.ModalFrame.BackgroundColor3 =
        theme.ModalFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.ModalFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(
            60,
            60,
            60
        )

    self.ModalFrame.BorderSizePixel =
        1

    self.ModalFrame.ClipsDescendants =
        true

    self.ModalFrame.ZIndex =
        501

    self.ModalFrame.Parent =
        self.Overlay

    ------------------------------------------------------------
    -- UI SCALE
    ------------------------------------------------------------

    self.UIScale =
        Instance.new("UIScale")

    self.UIScale.Name =
        "ModalScale"

    self.UIScale.Scale =
        0

    self.UIScale.Parent =
        self.ModalFrame

    ------------------------------------------------------------
    -- CONTENT CONTAINER
    ------------------------------------------------------------

    self.ContentContainer =
        Instance.new("Frame")

    self.ContentContainer.Name =
        "ContentContainer"

    self.ContentContainer.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    self.ContentContainer.AutomaticSize =
        Enum.AutomaticSize.Y

    self.ContentContainer.BackgroundTransparency =
        1

    self.ContentContainer.BorderSizePixel =
        0

    self.ContentContainer.Parent =
        self.ModalFrame

    ------------------------------------------------------------
    -- TITLE FRAME
    ------------------------------------------------------------

    self.TitleFrame =
        Instance.new("Frame")

    self.TitleFrame.Name =
        "TitleFrame"

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
        theme.ModalTitleFrame
        or theme.Background
        or DEFAULT_TITLE_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(
            60,
            60,
            60
        )

    self.TitleFrame.BorderSizePixel =
        1

    self.TitleFrame.LayoutOrder =
        1

    self.TitleFrame.Parent =
        self.ContentContainer

    ------------------------------------------------------------
    -- TITLE LABEL
    ------------------------------------------------------------

    self.TitleLabel =
        Instance.new("TextLabel")

    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -(PADDING_X * 2),
            0,
            0
        )

    self.TitleLabel.AutomaticSize =
        Enum.AutomaticSize.Y

    self.TitleLabel.BackgroundTransparency =
        1

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.RichText =
        true

    self.TitleLabel.TextWrapped =
        true

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
        UDim.new(
            0,
            PADDING_Y
        )

    titlePadding.PaddingBottom =
        UDim.new(
            0,
            PADDING_Y
        )

    titlePadding.PaddingLeft =
        UDim.new(
            0,
            PADDING_X
        )

    titlePadding.PaddingRight =
        UDim.new(
            0,
            PADDING_X
        )

    titlePadding.Parent =
        self.TitleFrame

    ------------------------------------------------------------
    -- TEXT FRAME
    ------------------------------------------------------------

    if self.HasText then

        self.TextFrame =
            Instance.new("Frame")

        self.TextFrame.Name =
            "TextFrame"

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
            theme.ModalTextFrame
            or theme.ElementContainer
            or DEFAULT_TEXT_BACKGROUND

        self.TextFrame.BorderColor3 =
            theme.Border
            or Color3.fromRGB(
                60,
                60,
                60
            )

        self.TextFrame.BorderSizePixel =
            1

        self.TextFrame.LayoutOrder =
            2

        self.TextFrame.Parent =
            self.ContentContainer

        --------------------------------------------------------
        -- TEXT LABEL
        --------------------------------------------------------

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

        self.TextLabel.AutomaticSize =
            Enum.AutomaticSize.Y

        self.TextLabel.BackgroundTransparency =
            1

        self.TextLabel.Text =
            self.Text

        self.TextLabel.RichText =
            true

        self.TextLabel.TextWrapped =
            true

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
            UDim.new(
                0,
                PADDING_Y
            )

        textPadding.PaddingBottom =
            UDim.new(
                0,
                PADDING_Y
            )

        textPadding.PaddingLeft =
            UDim.new(
                0,
                PADDING_X
            )

        textPadding.PaddingRight =
            UDim.new(
                0,
                PADDING_X
            )

        textPadding.Parent =
            self.TextFrame
    end

    ------------------------------------------------------------
    -- BUTTON FRAME
    ------------------------------------------------------------

    self.ButtonFrame =
        Instance.new("Frame")

    self.ButtonFrame.Name =
        "ButtonFrame"

    self.ButtonFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            BUTTON_HEIGHT
            + BUTTON_PADDING_Y * 2
        )

    self.ButtonFrame.BackgroundColor3 =
        theme.ModalButtonFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.ButtonFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(
            60,
            60,
            60
        )

    self.ButtonFrame.BorderSizePixel =
        1

    self.ButtonFrame.LayoutOrder =
        3

    self.ButtonFrame.Parent =
        self.ContentContainer

    ------------------------------------------------------------
    -- BUTTON PADDING
    ------------------------------------------------------------

    local buttonPadding =
        Instance.new("UIPadding")

    buttonPadding.PaddingTop =
        UDim.new(
            0,
            BUTTON_PADDING_Y
        )

    buttonPadding.PaddingBottom =
        UDim.new(
            0,
            BUTTON_PADDING_Y
        )

    buttonPadding.PaddingLeft =
        UDim.new(
            0,
            BUTTON_PADDING_X
        )

    buttonPadding.PaddingRight =
        UDim.new(
            0,
            BUTTON_PADDING_X
        )

    buttonPadding.Parent =
        self.ButtonFrame

    ------------------------------------------------------------
    -- BUTTON LAYOUT
    ------------------------------------------------------------

    self.ButtonLayout =
        Instance.new("UIListLayout")

    self.ButtonLayout.Name =
        "ButtonLayout"

    self.ButtonLayout.FillDirection =
        Enum.FillDirection.Horizontal

    self.ButtonLayout.HorizontalAlignment =
        Enum.HorizontalAlignment.Left

    self.ButtonLayout.VerticalAlignment =
        Enum.VerticalAlignment.Center

    self.ButtonLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.ButtonLayout.Padding =
        UDim.new(
            0,
            BUTTON_GAP
        )

    self.ButtonLayout.Parent =
        self.ButtonFrame

    ------------------------------------------------------------
    -- CONTENT LAYOUT
    ------------------------------------------------------------

    local contentLayout =
        Instance.new("UIListLayout")

    contentLayout.Name =
        "ModalLayout"

    contentLayout.FillDirection =
        Enum.FillDirection.Vertical

    contentLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    -- Border overlap
    contentLayout.Padding =
        UDim.new(
            0,
            -1
        )

    contentLayout.Parent =
        self.ContentContainer

    ------------------------------------------------------------
    -- BUILD BUTTONS
    ------------------------------------------------------------

    self:_BuildButtons()

    ------------------------------------------------------------
    -- REGISTER
    ------------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    ------------------------------------------------------------
    -- BUTTON WIDTH UPDATE
    ------------------------------------------------------------

    self.Window.ScreenGui:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(function()

        if self.Destroyed then
            return
        end

        self:_RefreshButtonSizes()
    end)

    ------------------------------------------------------------
    -- OPEN ANIMATION
    ------------------------------------------------------------

    task.defer(function()

        if self.Destroyed then
            return
        end

        self:_RefreshButtonSizes()

        TweenService:Create(
            self.UIScale,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            ),

            {
                Scale = 1
            }
        ):Play()
    end)

    return self
end

------------------------------------------------------------
-- BUTTON SIZE
------------------------------------------------------------

function Modal:_RefreshButtonSizes()

    if self.Destroyed then
        return
    end

    local count =
        #self.ButtonObjects

    if count <= 0 then
        return
    end

    --------------------------------------------------------
    -- IMPORTANT:
    -- Modal width is FIXED at MODAL_WIDTH.
    --------------------------------------------------------

    local totalGap =
        BUTTON_GAP
        * math.max(
            count - 1,
            0
        )

    local availableWidth =
        MODAL_WIDTH
        - (BUTTON_PADDING_X * 2)
        - totalGap

    local buttonWidth =
        availableWidth / count

    for _, button in ipairs(
        self.ButtonObjects
    ) do

        button.Size =
            UDim2.new(
                0,
                math.max(
                    0,
                    buttonWidth
                ),
                0,
                BUTTON_HEIGHT
            )
    end
end

------------------------------------------------------------
-- BUILD BUTTONS
------------------------------------------------------------

function Modal:_BuildButtons()

    for _, button in ipairs(
        self.ButtonObjects
    ) do

        if button then
            button:Destroy()
        end
    end

    table.clear(
        self.ButtonObjects
    )

    for index, data in ipairs(
        self.Buttons
    ) do

        if type(data) ~= "table" then
            continue
        end

        local button =
            Instance.new("TextButton")

        button.Name =
            "Button_"
            .. tostring(
                data.Title
                or index
            )

        button.Size =
            UDim2.new(
                0,
                0,
                0,
                BUTTON_HEIGHT
            )

        button.Text =
            tostring(
                data.Title
                or "Button"
            )

        button.TextSize =
            DEFAULT_TEXT_SIZE

        button.Font =
            self.Window.CurrentFont

        button.TextColor3 =
            data.TextColor
            or self.Window.ThemeData.ModalButtonText
            or self.Window.ThemeData.ButtonText
            or DEFAULT_TEXT_COLOR

        button.BackgroundColor3 =
            data.Color
            or self.Window.ThemeData.ModalButton
            or self.Window.ThemeData.Button
            or DEFAULT_BUTTON_BACKGROUND

        button.BorderColor3 =
            data.BorderColor
            or self.Window.ThemeData.Border
            or Color3.fromRGB(
                60,
                60,
                60
            )

        button.BorderSizePixel =
            1

        button.AutoButtonColor =
            false

        button.LayoutOrder =
            index

        button.ZIndex =
            503

        button.Parent =
            self.ButtonFrame

        table.insert(
            self.ButtonObjects,
            button
        )

        ----------------------------------------------------
        -- HOVER
        ----------------------------------------------------

        button.MouseEnter:Connect(
            function()

                if self.Destroyed then
                    return
                end

                button.BackgroundColor3 =
                    data.HighlightColor
                    or self.Window.ThemeData.ModalButtonHighlight
                    or self.Window.ThemeData.ButtonHighlight
                    or DEFAULT_BUTTON_HIGHLIGHT
            end
        )

        button.MouseLeave:Connect(
            function()

                if self.Destroyed then
                    return
                end

                button.BackgroundColor3 =
                    data.Color
                    or self.Window.ThemeData.ModalButton
                    or self.Window.ThemeData.Button
                    or DEFAULT_BUTTON_BACKGROUND
            end
        )

        ----------------------------------------------------
        -- CALLBACK
        ----------------------------------------------------

        button.MouseButton1Click:Connect(
            function()

                if self.Destroyed then
                    return
                end

                local callback =
                    type(data.Callback)
                    == "function"
                    and data.Callback
                    or nil

                if not callback then
                    return
                end

                task.spawn(function()

                    local ok, err =
                        pcall(
                            callback
                        )

                    if not ok then
                        warn(
                            "Modal button callback error:",
                            err
                        )
                    end
                end)
            end
        )
    end

    self:_RefreshButtonSizes()
end

------------------------------------------------------------
-- FONT
------------------------------------------------------------

function Modal:SetFont(fontType)

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

    for _, button in ipairs(
        self.ButtonObjects
    ) do

        setFont(
            button,
            fontType
        )
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Modal:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- OVERLAY
    --------------------------------------------------------

    self.Overlay.BackgroundColor3 =
        theme.ModalOverlay
        or Color3.fromRGB(
            0,
            0,
            0
        )

    self.Overlay.BackgroundTransparency =
        theme.ModalOverlayTransparency ~= nil
        and theme.ModalOverlayTransparency
        or 0.45

    --------------------------------------------------------
    -- MODAL
    --------------------------------------------------------

    self.ModalFrame.BackgroundColor3 =
        theme.ModalFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.ModalFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleFrame.BackgroundColor3 =
        theme.ModalTitleFrame
        or theme.Background
        or DEFAULT_TITLE_BACKGROUND

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text
        or DEFAULT_TEXT_COLOR

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    if self.TextFrame then

        self.TextFrame.BackgroundColor3 =
            theme.ModalTextFrame
            or theme.ElementContainer
            or DEFAULT_TEXT_BACKGROUND

        self.TextFrame.BorderColor3 =
            theme.Border

    end

    if self.TextLabel then

        self.TextLabel.TextColor3 =
            theme.Text
            or DEFAULT_TEXT_COLOR
    end

    --------------------------------------------------------
    -- BUTTON FRAME
    --------------------------------------------------------

    self.ButtonFrame.BackgroundColor3 =
        theme.ModalButtonFrame
        or theme.Background
        or DEFAULT_BACKGROUND

    self.ButtonFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- BUTTONS
    --------------------------------------------------------

    for index, button in ipairs(
        self.ButtonObjects
    ) do

        local data =
            self.Buttons[index]
            or {}

        button.TextColor3 =
            data.TextColor
            or theme.ModalButtonText
            or theme.ButtonText
            or DEFAULT_TEXT_COLOR

        button.BackgroundColor3 =
            data.Color
            or theme.ModalButton
            or theme.Button
            or DEFAULT_BUTTON_BACKGROUND

        button.BorderColor3 =
            data.BorderColor
            or theme.Border
    end

    self:SetFont(
        self.Window.CurrentFont
    )

    self:_RefreshButtonSizes()
end

------------------------------------------------------------
-- CLOSE
------------------------------------------------------------

function Modal:Close()

    if self.Destroyed then
        return
    end

    if not self.Opened then
        return
    end

    self.Opened = false

    --------------------------------------------------------
    -- SCALE DOWN
    --------------------------------------------------------

    local scaleTween =
        TweenService:Create(
            self.UIScale,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ),

            {
                Scale = 0
            }
        )

    --------------------------------------------------------
    -- OVERLAY
    --------------------------------------------------------

    local overlayTween =
        TweenService:Create(
            self.Overlay,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ),

            {
                BackgroundTransparency = 1
            }
        )

    scaleTween:Play()
    overlayTween:Play()

    scaleTween.Completed:Connect(
        function()

            if self.Destroyed then
                return
            end

            if not self.Opened then
                self:Destroy()
            end
        end
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Modal:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true
    self.Opened = false

    if self.Overlay then

        self.Overlay:Destroy()
        self.Overlay = nil

    end

    self.ModalFrame = nil
    self.UIScale = nil
    self.ContentContainer = nil

    self.TitleFrame = nil
    self.TextFrame = nil
    self.ButtonFrame = nil

    self.TitleLabel = nil
    self.TextLabel = nil

    table.clear(
        self.ButtonObjects
    )

    --------------------------------------------------------
    -- REMOVE FROM TAB
    --------------------------------------------------------

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

return Modal
