-- File: ImGuiRemake.lua/Components/Console.lua

local Console = {}
Console.__index = Console

local DEFAULT_SIZE =
    UDim2.new(1, -12, 0, 180)

local DEFAULT_MAX_LOG = 100
local DEFAULT_TEXT_SIZE = 13

local PADDING = 6
local LOG_GAP = 2
local SCROLLBAR_THICKNESS = 4

local DEFAULT_TEXT_COLOR =
    Color3.fromRGB(255, 255, 255)

function Console.new(tab, options)
    options = options or {}

    local self =
        setmetatable({}, Console)

    self.Tab = tab
    self.Window = tab.Window
    self.WidthAtRow = options.WidthAtRow

    self.Size =
        options.Size
        or DEFAULT_SIZE

    self.MaxLog =
        tonumber(
            options.MaxLog
        )
        or DEFAULT_MAX_LOG

    if self.MaxLog < 1 then
        self.MaxLog = 1
    end

    self.AutoScroll =
        options.AutoScroll ~= false

    self.Time =
        options.Time == true

    self.Destroyed = false
    self.Logs = {}

    local theme =
        self.Window.ThemeData

    ------------------------------------------------------------
    -- CONTAINER
    ------------------------------------------------------------

    self.Container =
        Instance.new("ScrollingFrame")

    self.Container.Name =
        "Console"

    self.Container.Size =
        self.Size

    self.Container.BackgroundColor3 =
        theme.ConsoleFrame

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
    -- LOG LAYOUT
    ------------------------------------------------------------

    self.Layout =
        Instance.new("UIListLayout")

    self.Layout.Name =
        "ConsoleLayout"

    self.Layout.FillDirection =
        Enum.FillDirection.Vertical

    self.Layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    self.Layout.Padding =
        UDim.new(
            0,
            LOG_GAP
        )

    self.Layout.Parent =
        self.Container

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
-- LOG
------------------------------------------------------------

function Console:Log(text)
    if self.Destroyed then
        return
    end

    local logText =
        tostring(
            text
            or ""
        )

    --------------------------------------------------------
    -- TIMESTAMP
    --------------------------------------------------------

    if self.Time then
        logText =
            "["
            .. os.date("%H:%M:%S")
            .. "] "
            .. logText
    end

    --------------------------------------------------------
    -- LOG LABEL
    --------------------------------------------------------

    local label =
        Instance.new("TextLabel")

    label.Name =
        "Log_" ..
        tostring(
            #self.Logs + 1
        )

    label.Size =
        UDim2.new(
            1,
            -(PADDING * 2),
            0,
            0
        )

    label.AutomaticSize =
        Enum.AutomaticSize.Y

    label.BackgroundTransparency =
        1

    label.BorderSizePixel =
        0

    label.Text =
        logText

    label.RichText =
        true

    label.TextWrapped =
        true

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.TextYAlignment =
        Enum.TextYAlignment.Top

    label.TextSize =
        DEFAULT_TEXT_SIZE

    label.Font =
        self.Window.CurrentFont

    label.TextColor3 =
        self.Window.ThemeData.ConsoleText
        or self.Window.ThemeData.Text
        or DEFAULT_TEXT_COLOR

    label.LayoutOrder =
        #self.Logs + 1

    label.Parent =
        self.Container

    table.insert(
        self.Logs,
        label
    )

    --------------------------------------------------------
    -- MAX LOG
    --------------------------------------------------------

    while #self.Logs > self.MaxLog do

        local oldest =
            table.remove(
                self.Logs,
                1
            )

        if oldest then
            oldest:Destroy()
        end
    end

    --------------------------------------------------------
    -- AUTO SCROLL
    --------------------------------------------------------

    if self.AutoScroll then

        task.defer(
            function()

                if self.Destroyed then
                    return
                end

                self.Container.CanvasPosition =
                    Vector2.new(
                        0,
                        math.max(
                            0,
                            self.Container.AbsoluteCanvasSize.Y
                            - self.Container.AbsoluteWindowSize.Y
                        )
                    )
            end
        )
    end
end

------------------------------------------------------------
-- CLEAR
------------------------------------------------------------

function Console:Clear()
    if self.Destroyed then
        return
    end

    for _, log in ipairs(
        self.Logs
    ) do

        if log then
            log:Destroy()
        end
    end

    table.clear(
        self.Logs
    )

    self.Container.CanvasPosition =
        Vector2.new(
            0,
            0
        )
end

------------------------------------------------------------
-- SET FONT
------------------------------------------------------------

function Console:SetFont(fontType)
    if self.Destroyed then
        return
    end

    for _, log in ipairs(
        self.Logs
    ) do

        if typeof(fontType) == "string"
            and string.find(
                string.lower(fontType),
                "rbxassetid",
                1,
                true
            ) then

            local ok, customFont =
                pcall(function()
                    return Font.new(
                        fontType
                    )
                end)

            if ok and customFont then
                log.FontFace =
                    customFont
            end

        elseif typeof(fontType)
            == "EnumItem"
            and fontType.EnumType
                == Enum.Font then

            log.Font =
                fontType
        end
    end
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Console:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    self.Container.BackgroundColor3 =
        theme.ConsoleFrame

    self.Container.BorderColor3 =
        theme.Border

    for _, log in ipairs(
        self.Logs
    ) do

        log.TextColor3 =
            theme.ConsoleText
            or theme.Text
    end

    self:SetFont(
        self.Window.CurrentFont
    )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Console:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    table.clear(
        self.Logs
    )

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

return Console
