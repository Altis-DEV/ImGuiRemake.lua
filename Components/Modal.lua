-- File: ImGuiRemake.lua/Components/Modal.lua

local Modal = {}
Modal.__index = Modal

local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local MODAL_WIDTH = 420

local TITLE_PADDING_X = 10
local TITLE_PADDING_Y = 8

local TEXT_PADDING_X = 10
local TEXT_PADDING_Y = 8

local TITLE_MIN_HEIGHT = 32
local TEXT_MIN_HEIGHT = 42

local BUTTON_HEIGHT = 32
local BUTTON_PADDING_X = 6
local BUTTON_PADDING_Y = 6
local BUTTON_GAP = 5

local MIN_MODAL_HEIGHT = 110
local ANIMATION_TIME = 0.22

------------------------------------------------------------
-- FONT
------------------------------------------------------------

local function setFont(instance, fontType)

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

    local self =
        setmetatable({}, Modal)

    self.Tab = tab
    self.Window = tab.Window

    self.Title =
        tostring(options.Title or "Modal")

    self.Text =
        tostring(options.Text or "")

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
        "ModalOverlay"

    self.Overlay.Size =
        UDim2.new(1, 0, 1, 0)

    self.Overlay.Position =
        UDim2.new(0, 0, 0, 0)

    self.Overlay.BackgroundColor3 =
        theme.ModalOverlay
        or Color3.fromRGB(0, 0, 0)

    self.Overlay.BackgroundTransparency =
        theme.ModalOverlayTransparency ~= nil
        and theme.ModalOverlayTransparency
        or 0.45

    self.Overlay.BorderSizePixel = 0
    self.Overlay.ZIndex = 500
    self.Overlay.Parent =
        self.Window.ScreenGui

    --------------------------------------------------------
    -- MODAL FRAME
    --------------------------------------------------------

    self.ModalFrame =
        Instance.new("Frame")

    self.ModalFrame.Name =
        "ModalFrame"

    self.ModalFrame.AnchorPoint =
        Vector2.new(0.5, 0.5)

    self.ModalFrame.Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            0
        )

    self.ModalFrame.Size =
        UDim2.new(
            0,
            40,
            0,
            40
        )

    self.ModalFrame.BackgroundColor3 =
        theme.ModalFrame
        or theme.Background

    self.ModalFrame.BorderColor3 =
        theme.Border

    self.ModalFrame.BorderSizePixel = 1
    self.ModalFrame.ClipsDescendants = true
    self.ModalFrame.ZIndex = 501
    self.ModalFrame.Parent =
        self.Overlay

    --------------------------------------------------------
    -- LAYOUT
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
        UDim.new(0, -1)

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
            TITLE_MIN_HEIGHT
        )

    self.TitleFrame.BackgroundColor3 =
        theme.ModalTitleFrame
        or theme.Background

    self.TitleFrame.BorderColor3 =
        theme.Border

    self.TitleFrame.BorderSizePixel = 1
    self.TitleFrame.ClipsDescendants = true
    self.TitleFrame.LayoutOrder = 1
    self.TitleFrame.ZIndex = 502
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
            -(TITLE_PADDING_X * 2),
            0,
            0
        )

    self.TitleLabel.Position =
        UDim2.new(
            0,
            TITLE_PADDING_X,
            0,
            TITLE_PADDING_Y
        )

    self.TitleLabel.BackgroundTransparency = 1

    self.TitleLabel.RichText = true
    self.TitleLabel.TextWrapped = true

    self.TitleLabel.Text =
        self.Title

    self.TitleLabel.TextColor3 =
        theme.Text

    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font =
        self.Window.CurrentFont

    self.TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TitleLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TitleLabel.ZIndex = 503
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
            TEXT_MIN_HEIGHT
        )

    self.TextFrame.BackgroundColor3 =
        theme.ModalTextFrame
        or theme.Background

    self.TextFrame.BorderColor3 =
        theme.Border

    self.TextFrame.BorderSizePixel = 1
    self.TextFrame.ClipsDescendants = true
    self.TextFrame.LayoutOrder = 2
    self.TextFrame.ZIndex = 502
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
            -(TEXT_PADDING_X * 2),
            0,
            0
        )

    self.TextLabel.Position =
        UDim2.new(
            0,
            TEXT_PADDING_X,
            0,
            TEXT_PADDING_Y
        )

    self.TextLabel.BackgroundTransparency = 1

    self.TextLabel.RichText = true
    self.TextLabel.TextWrapped = true

    self.TextLabel.Text =
        self.Text

    self.TextLabel.TextColor3 =
        theme.Text

    self.TextLabel.TextSize = 13
    self.TextLabel.Font =
        self.Window.CurrentFont

    self.TextLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    self.TextLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    self.TextLabel.ZIndex = 503
    self.TextLabel.Parent =
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
            BUTTON_HEIGHT
            + BUTTON_PADDING_Y * 2
        )

    self.ButtonFrame.BackgroundColor3 =
        theme.ModalButtonFrame
        or theme.Background

    self.ButtonFrame.BorderColor3 =
        theme.Border

    self.ButtonFrame.BorderSizePixel = 1
    self.ButtonFrame.LayoutOrder = 3
    self.ButtonFrame.ZIndex = 502
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
            BUTTON_PADDING_X
        )

    buttonPadding.PaddingRight =
        UDim.new(
            0,
            BUTTON_PADDING_X
        )

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
    -- BUILD BUTTONS
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
    -- INITIAL BUILD
    --------------------------------------------------------

    task.defer(function()

        if self.Destroyed then
            return
        end

        -- TextBounds cần một frame đã có chiều rộng.
        self:_PrepareSize()

        local targetSize =
            UDim2.new(
                0,
                MODAL_WIDTH,
                0,
                self.TargetHeight
            )

        ----------------------------------------------------
        -- OPEN ANIMATION
        ----------------------------------------------------

        self.ModalFrame.Size =
            UDim2.new(
                0,
                40,
                0,
                40
            )

        self.Overlay.BackgroundTransparency =
            1

        TweenService:Create(
            self.ModalFrame,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),

            {
                Size = targetSize
            }
        ):Play()

        TweenService:Create(
            self.Overlay,

            TweenInfo.new(
                ANIMATION_TIME,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),

            {
                BackgroundTransparency =
                    theme.ModalOverlayTransparency ~= nil
                    and theme.ModalOverlayTransparency
                    or 0.45
            }
        ):Play()

    end)

    return self
end

------------------------------------------------------------
-- MEASURE TITLE
------------------------------------------------------------

function Modal:_MeasureTitle()

    --------------------------------------------------------
    -- Cho Roblox tính TextBounds của RichText.
    --
    -- TitleLabel đã TextWrapped + có width cố định.
    --------------------------------------------------------

    local width =
        MODAL_WIDTH
        - (TITLE_PADDING_X * 2)

    self.TitleLabel.Size =
        UDim2.new(
            0,
            width,
            0,
            10000
        )

    task.wait()

    local textHeight =
        self.TitleLabel.TextBounds.Y

    return math.max(
        TITLE_MIN_HEIGHT,
        textHeight
        + (TITLE_PADDING_Y * 2)
    )
end

------------------------------------------------------------
-- MEASURE TEXT
------------------------------------------------------------

function Modal:_MeasureText()

    local width =
        MODAL_WIDTH
        - (TEXT_PADDING_X * 2)

    self.TextLabel.Size =
        UDim2.new(
            0,
            width,
            0,
            10000
        )

    task.wait()

    local textHeight =
        self.TextLabel.TextBounds.Y

    return math.max(
        TEXT_MIN_HEIGHT,
        textHeight
        + (TEXT_PADDING_Y * 2)
    )
end

------------------------------------------------------------
-- PREPARE SIZE
------------------------------------------------------------

function Modal:_PrepareSize()

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    local titleHeight =
        self:_MeasureTitle()

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    local textHeight =
        self:_MeasureText()

    --------------------------------------------------------
    -- APPLY REAL FRAME HEIGHTS
    --------------------------------------------------------

    self.TitleFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            titleHeight
        )

    self.TextFrame.Size =
        UDim2.new(
            1,
            0,
            0,
            textHeight
        )

    --------------------------------------------------------
    -- BUTTONS
    --------------------------------------------------------

    self:_RefreshButtonSizes()

    local buttonHeight =
        BUTTON_HEIGHT
        + BUTTON_PADDING_Y * 2

    --------------------------------------------------------
    -- TOTAL
    --------------------------------------------------------

    self.TargetHeight =
        math.max(
            MIN_MODAL_HEIGHT,

            titleHeight
            + textHeight
            + buttonHeight
            - 2
        )
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
                data.Title or index
            )

        button.Text =
            tostring(
                data.Title
                or "Button"
            )

        button.TextSize = 13
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

        button.BorderSizePixel = 1
        button.AutoButtonColor = false
        button.LayoutOrder = index
        button.ZIndex = 503
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
        )
    end

    self:_RefreshButtonSizes()
end

------------------------------------------------------------
-- BUTTON SIZE
------------------------------------------------------------

function Modal:_RefreshButtonSizes()

    local count =
        #self.ButtonObjects

    if count == 0 then
        return
    end

    local availableWidth =
        MODAL_WIDTH
        - (BUTTON_PADDING_X * 2)

    local totalGap =
        BUTTON_GAP
        * math.max(
            count - 1,
            0
        )

    local buttonWidth =
        (
            availableWidth
            - totalGap
        ) / count

    for _, button in ipairs(
        self.ButtonObjects
    ) do

        button.Size =
            UDim2.new(
                0,
                buttonWidth,
                0,
                BUTTON_HEIGHT
            )
    end
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

    --------------------------------------------------------
    -- Font changes TextBounds
    --------------------------------------------------------

    self:_PrepareSize()
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

    --------------------------------------------------------
    -- MODAL
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

        button.BorderColor3 =
            data.BorderColor
            or theme.Border

        setFont(
            button,
            self.Window.CurrentFont
        )
    end

    self:SetFont(
        self.Window.CurrentFont
    )
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
    -- FADE OUT
    --------------------------------------------------------

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
    ):Play()

    --------------------------------------------------------
    -- SHRINK
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
                        40,
                        0,
                        40
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
    self.TitleFrame = nil
    self.TextFrame = nil
    self.ButtonFrame = nil

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
