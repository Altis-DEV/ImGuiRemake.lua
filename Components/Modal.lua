-- File: ImGuiRemake.lua/Components/Modal.lua

local Modal = {}
Modal.__index = Modal

local TweenService =
    game:GetService("TweenService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local MODAL_WIDTH = 420
local MIN_MODAL_HEIGHT = 120

local TITLE_HEIGHT = 32
local BUTTON_HEIGHT = 32

local BUTTON_GAP = 5

local ANIMATION_TIME = 0.2

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function setFont(
    instance,
    fontType
)
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

function Modal.new(
    tab,
    options
)
    options = options or {}

    local self =
        setmetatable(
            {},
            Modal
        )

    self.Tab = tab
    self.Window = tab.Window

    self.Title =
        tostring(
            options.Title
            or "Modal"
        )

    self.Text =
        tostring(
            options.Text
            or ""
        )

    self.Buttons =
        type(options.Buttons) == "table"
        and options.Buttons
        or {}

    self.Destroyed = false
    self.Opened = true

    self.ButtonObjects = {}

    local theme =
        self.Window.ThemeData

    --------------------------------------------------------
    -- OVERLAY
    --------------------------------------------------------

    self.Overlay =
        Instance.new("Frame")

    self.Overlay.Name =
        self.Title
        .. "_ModalOverlay"

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
        theme.ModalOverlayTransparency
        or 0.45

    self.Overlay.BorderSizePixel =
        0

    self.Overlay.ZIndex =
        500

    self.Overlay.Parent =
        self.Window.ScreenGui

    --------------------------------------------------------
    -- MAIN MODAL FRAME
    --------------------------------------------------------

    self.ModalFrame =
        Instance.new("Frame")

    self.ModalFrame.Name =
        "ModalFrame"

    self.ModalFrame.Size =
        UDim2.new(
            0,
            MODAL_WIDTH,
            0,
            MIN_MODAL_HEIGHT
        )

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

    self.ModalFrame.BorderColor3 =
        theme.Border

    self.ModalFrame.BorderSizePixel =
        1

    self.ModalFrame.ZIndex =
        501

    self.ModalFrame.ClipsDescendants =
        true

    self.ModalFrame.Parent =
        self.Overlay

    --------------------------------------------------------
    -- INTERNAL VERTICAL LAYOUT
    --------------------------------------------------------

    self.Layout =
        Instance.new("UIListLayout")

    self.Layout.Name =
        "ModalLayout"

    self.Layout.FillDirection =
        Enum.FillDirection.Vertical

    self.Layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.Layout.Padding =
        UDim.new(
            0,
            -1
        )

    self.Layout.Parent =
        self.ModalFrame

    --------------------------------------------------------
    -- TITLE FRAME
    --------------------------------------------------------

    self.TitleFrame =
        Instance.new("Frame")

    self.TitleFrame.Name =
        "TitleFrame"

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            TITLE_HEIGHT
        )

    self.TitleFrame.BackgroundColor3 =
        theme.ModalTitleFrame
        or theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleFrame.BorderSizePixel =
        1

    self.TitleFrame.LayoutOrder =
        1

    self.TitleFrame.ZIndex =
        502

    self.TitleFrame.Parent =
        self.ModalFrame

    --------------------------------------------------------
    -- TITLE LABEL
    --------------------------------------------------------

    self.TitleLabel =
        Instance.new("TextLabel")

    self.TitleLabel.Name =
        "Title"

    self.TitleLabel.Size =
        UDim2.new(
            1,
            -16,
            1,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            0,
            8,
            0,
            0
        )

    self.TitleLabel.BackgroundTransparency =
        1

    self.TitleLabel.RichText =
        true

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize =
        14

    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.ZIndex =
        503

    self.TitleLabel.Parent =
        self.TitleFrame

    --------------------------------------------------------
    -- TEXT FRAME
    --------------------------------------------------------

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
        or theme.Background

    self.TextFrame.BorderColor3 =
        theme.Border

    self.TextFrame.BorderSizePixel =
        1

    self.TextFrame.LayoutOrder =
        2

    self.TextFrame.ZIndex =
        502

    self.TextFrame.Parent =
        self.ModalFrame

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
            -20,
            0,
            0
        )

    self.TextLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            8
        )

    self.TextLabel.AutomaticSize =
        Enum.AutomaticSize.Y

    self.TextLabel.BackgroundTransparency =
        1

    self.TextLabel.RichText =
        true

    self.TextLabel.TextWrapped =
        true

    self.TextLabel.Text =
        self.Text

    self.TextLabel.TextColor3 =
        theme.Text

    self.TextLabel.TextSize =
        13

    self.TextLabel.Font =
        self.Window.CurrentFont

    self.TextLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TextLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TextLabel.ZIndex =
        503

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
            8
        )

    textPadding.PaddingBottom =
        UDim.new(
            0,
            8
        )

    textPadding.Parent =
        self.TextFrame

    --------------------------------------------------------
    -- BUTTON FRAME
    --------------------------------------------------------

    self.ButtonFrame =
        Instance.new("Frame")

    self.ButtonFrame.Name =
        "ButtonFrame"

    self.ButtonFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            BUTTON_HEIGHT + 12
        )

    self.ButtonFrame.BackgroundColor3 =
        theme.ModalButtonFrame
        or theme.Background

    self.ButtonFrame.BorderColor3 =
        theme.Border

    self.ButtonFrame.BorderSizePixel =
        1

    self.ButtonFrame.LayoutOrder =
        3

    self.ButtonFrame.ZIndex =
        502

    self.ButtonFrame.Parent =
        self.ModalFrame

    --------------------------------------------------------
    -- BUTTON PADDING
    --------------------------------------------------------

    local buttonPadding =
        Instance.new("UIPadding")

    buttonPadding.PaddingLeft =
        UDim.new(
            0,
            6
        )

    buttonPadding.PaddingRight =
        UDim.new(
            0,
            6
        )

    buttonPadding.PaddingTop =
        UDim.new(
            0,
            6
        )

    buttonPadding.PaddingBottom =
        UDim.new(
            0,
            6
        )

    buttonPadding.Parent =
        self.ButtonFrame

    --------------------------------------------------------
    -- BUTTON LAYOUT
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- CREATE BUTTONS
    --------------------------------------------------------

    self:_BuildButtons()

    --------------------------------------------------------
    -- REGISTER
    --------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    --------------------------------------------------------
    -- INITIAL SIZE
    --------------------------------------------------------

    task.defer(
        function()

            if self.Destroyed then
                return
            end

            self:_RefreshSize()

            self.ModalFrame.Size =
                UDim2.new(
                    0,
                    MODAL_WIDTH,
                    0,
                    self.TargetHeight
                )

        end
    )

    return self
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

        button.Text =
            tostring(
                data.Title
                or "Button"
            )

        button.TextSize =
            13

        button.Font =
            self.Window.CurrentFont

        button.TextColor3 =
            data.TextColor
            or self.Window.ThemeData.ModalButtonText
            or self.Window.ThemeData.ButtonText
            or Color3.fromRGB(
                255,
                255,
                255
            )

        button.BackgroundColor3 =
            data.Color
            or self.Window.ThemeData.ModalButton
            or self.Window.ThemeData.Button
            or Color3.fromRGB(
                40,
                90,
                175
            )

        button.BorderColor3 =
            data.BorderColor
            or self.Window.ThemeData.Border

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
                    or Color3.fromRGB(
                        60,
                        110,
                        220
                    )
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
                    or Color3.fromRGB(
                        40,
                        90,
                        175
                    )
            end
        )

        ----------------------------------------------------
        -- CLICK
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

                if callback then

                    task.spawn(
                        function()

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
                        end
                    )
                end
            end
        )
    end

    --------------------------------------------------------
    -- EQUAL BUTTON WIDTH
    --------------------------------------------------------

    self:_RefreshButtonSizes()
end

------------------------------------------------------------
-- REFRESH BUTTON SIZES
------------------------------------------------------------

function Modal:_RefreshButtonSizes()

    local count =
        #self.ButtonObjects

    if count <= 0 then
        return
    end

    local gapTotal =
        BUTTON_GAP
        * math.max(
            count - 1,
            0
        )

    local horizontalPadding =
        12

    local availableWidth =
        MODAL_WIDTH
        - horizontalPadding
        - gapTotal

    local cellWidth =
        availableWidth
        / count

    for _, button in ipairs(
        self.ButtonObjects
    ) do

        button.Size =
            UDim2.new(
                0,
                cellWidth,
                0,
                BUTTON_HEIGHT
            )
    end
end

------------------------------------------------------------
-- REFRESH MODAL SIZE
------------------------------------------------------------

function Modal:_RefreshSize()

    if self.Destroyed then
        return
    end

    local textHeight =
        self.TextLabel.AbsoluteSize.Y
        + 16

    local targetHeight =
        TITLE_HEIGHT
        + textHeight
        + BUTTON_HEIGHT
        + 12

    self.TargetHeight =
        math.max(
            MIN_MODAL_HEIGHT,
            targetHeight
        )
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Modal:SetFont(fontType)

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
        theme.ModalOverlayTransparency
        or 0.45

    --------------------------------------------------------
    -- MAIN
    --------------------------------------------------------

    self.ModalFrame.BackgroundColor3 =
        theme.ModalFrame
        or theme.Background

    self.ModalFrame.BorderColor3 =
        theme.Border

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    self.TitleFrame.BackgroundColor3 =
        theme.ModalTitleFrame
        or theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleLabel.TextColor3 =
        theme.Text

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    self.TextFrame.BackgroundColor3 =
        theme.ModalTextFrame
        or theme.Background

    self.TextFrame.BorderColor3 =
        theme.Border

    self.TextLabel.TextColor3 =
        theme.Text

    --------------------------------------------------------
    -- BUTTON FRAME
    --------------------------------------------------------

    self.ButtonFrame.BackgroundColor3 =
        theme.ModalButtonFrame
        or theme.Background

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
            or Color3.fromRGB(
                255,
                255,
                255
            )

        button.BackgroundColor3 =
            data.Color
            or theme.ModalButton
            or theme.Button
            or Color3.fromRGB(
                40,
                90,
                175
            )

        button.BorderColor3 =
            data.BorderColor
            or theme.Border

        setFont(
            button,
            self.Window.CurrentFont
        )
    end

    --------------------------------------------------------
    -- FONT
    --------------------------------------------------------

    self:SetFont(
        self.Window.CurrentFont
    )

    self:_RefreshSize()
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

    self.Opened =
        false

    --------------------------------------------------------
    -- FADE OUT
    --------------------------------------------------------

    local overlayTween =
        TweenService:Create(
            self.Overlay,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),

            {
                BackgroundTransparency = 1
            }
        )

    overlayTween:Play()

    --------------------------------------------------------
    -- SHRINK MODAL
    --------------------------------------------------------

    local frameTween =
        TweenService:Create(
            self.ModalFrame,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),

            {
                Size =
                    UDim2.new(
                        0,
                        MODAL_WIDTH - 30,
                        0,
                        20
                    )
            }
        )

    frameTween:Play()

    frameTween.Completed:Connect(
        function()

            if self.Destroyed then
                return
            end

            if not self.Opened then
                self:_DestroyVisual()
            end
        end
    )
end

------------------------------------------------------------
-- DESTROY VISUAL
------------------------------------------------------------

function Modal:_DestroyVisual()

    if self.Overlay then
        self.Overlay:Destroy()
        self.Overlay = nil
    end

    self.ModalFrame = nil
    self.TitleFrame = nil
    self.TextFrame = nil
    self.ButtonFrame = nil
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Modal:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed =
        true

    self.Opened =
        false

    self:_DestroyVisual()

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
