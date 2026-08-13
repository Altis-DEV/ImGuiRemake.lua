--[[
    ImGuiRemake.lua
    ============================================================
    PUBLIC EXAMPLE
    ============================================================

    Core:
        Window
        Tab
        Section
        Row

    Elements:
        Button
        Toggle
        Slider
        Dropdown
        TextBox
        Paragraph
        Label
        Divider
        Image

    Window methods:
        Center()
        SetTitle()
        SetVisible()
        SetFont()
        Theme()
        Open()
        Close()
        Destroy()

    Section methods:
        Open()
        Close()
        SetOpen()
        SetTitle()
        Destroy()

    Row:
        Tab:Row()
        Section:Row()
        Row:Row()

    Image:
        rbxassetid://
        raw JPG / PNG
        Size
        Ratio
        SetImage()
        Destroy()

    TextBox:
        Text
        Placeholder
        ClearTextOnFocus
        SetText()
        Clear()
        SetTitle()
        SetPlaceholder()
        SetClearTextOnFocus()
        Destroy()
]]

--==============================================================
-- LOAD
--==============================================================

local Repo =
    "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"

local ImGui = loadstring(
    game:HttpGet(Repo .. "init.lua")
)()

--==============================================================
-- CUSTOM THEMES
--==============================================================
-- CreateTheme() automatically inherits missing values
-- from the Default theme.

ImGui:CreateTheme("Red", {
    Accent = Color3.fromRGB(180, 50, 50),

    Background = Color3.fromRGB(20, 20, 20),
    TabContainer = Color3.fromRGB(30, 30, 30),
    ElementContainer = Color3.fromRGB(25, 25, 25),

    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(75, 75, 75),

    Button = Color3.fromRGB(180, 50, 50),
    ButtonHighlight = Color3.fromRGB(220, 70, 70),
    ButtonText = Color3.fromRGB(255, 255, 255),

    Checkbox = Color3.fromRGB(255, 80, 80),

    SliderFrame = Color3.fromRGB(45, 45, 45),
    SliderBar = Color3.fromRGB(180, 50, 50),

    DropdownFrame = Color3.fromRGB(40, 40, 40),
    DropdownOption = Color3.fromRGB(30, 30, 30),
    DropdownOptionSelected = Color3.fromRGB(180, 50, 50),
    DropdownOptionHover = Color3.fromRGB(65, 40, 40),

    TextBoxFrame = Color3.fromRGB(40, 40, 40),
    Placeholder = Color3.fromRGB(150, 150, 150),

    ParagraphTitleFrame = Color3.fromRGB(45, 25, 25),
    ParagraphTextFrame = Color3.fromRGB(35, 25, 25),

    SectionTitleFrame = Color3.fromRGB(45, 25, 25),
    SectionElementContainer = Color3.fromRGB(35, 25, 25),
})

ImGui:CreateTheme("Green", {
    Accent = Color3.fromRGB(45, 170, 90),

    Background = Color3.fromRGB(20, 20, 20),
    TabContainer = Color3.fromRGB(30, 30, 30),
    ElementContainer = Color3.fromRGB(25, 25, 25),

    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(60, 60, 60),

    Button = Color3.fromRGB(45, 140, 75),
    ButtonHighlight = Color3.fromRGB(60, 180, 95),
    ButtonText = Color3.fromRGB(255, 255, 255),

    Checkbox = Color3.fromRGB(50, 220, 100),

    SliderFrame = Color3.fromRGB(40, 40, 40),
    SliderBar = Color3.fromRGB(45, 170, 90),

    DropdownFrame = Color3.fromRGB(40, 40, 40),
    DropdownOption = Color3.fromRGB(30, 30, 30),
    DropdownOptionSelected = Color3.fromRGB(45, 170, 90),
    DropdownOptionHover = Color3.fromRGB(60, 60, 60),

    TextBoxFrame = Color3.fromRGB(40, 40, 40),
    Placeholder = Color3.fromRGB(150, 150, 150),

    ParagraphTitleFrame = Color3.fromRGB(25, 45, 30),
    ParagraphTextFrame = Color3.fromRGB(22, 35, 25),

    SectionTitleFrame = Color3.fromRGB(25, 45, 30),
    SectionElementContainer = Color3.fromRGB(22, 35, 25),
})

ImGui:CreateTheme("Purple", {
    Accent = Color3.fromRGB(130, 70, 190),

    Background = Color3.fromRGB(20, 20, 20),
    TabContainer = Color3.fromRGB(30, 30, 30),
    ElementContainer = Color3.fromRGB(25, 25, 25),

    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(65, 65, 65),

    Button = Color3.fromRGB(120, 65, 180),
    ButtonHighlight = Color3.fromRGB(150, 85, 220),
    ButtonText = Color3.fromRGB(255, 255, 255),

    Checkbox = Color3.fromRGB(180, 100, 255),

    SliderFrame = Color3.fromRGB(40, 40, 40),
    SliderBar = Color3.fromRGB(130, 70, 190),

    DropdownFrame = Color3.fromRGB(40, 40, 40),
    DropdownOption = Color3.fromRGB(30, 30, 30),
    DropdownOptionSelected = Color3.fromRGB(130, 70, 190),
    DropdownOptionHover = Color3.fromRGB(60, 60, 60),

    TextBoxFrame = Color3.fromRGB(40, 40, 40),
    Placeholder = Color3.fromRGB(150, 150, 150),

    ParagraphTitleFrame = Color3.fromRGB(35, 25, 45),
    ParagraphTextFrame = Color3.fromRGB(28, 23, 35),

    SectionTitleFrame = Color3.fromRGB(35, 25, 45),
    SectionElementContainer = Color3.fromRGB(28, 23, 35),
})

--==============================================================
-- WINDOW
--==============================================================

local Window = ImGui:CreateWindow({
    Title = "ImGuiRemake.lua | Public Example",

    Size = UDim2.new(
        0,
        400,
        0,
        300
    ),

    MinSize = Vector2.new(
        300,
        250
    ),

    MaxSize = Vector2.new(
        1100,
        800
    ),

    Font = Enum.Font.RobotoMono,
})

Window:Center()

--==============================================================
-- TAB: INTRO
--==============================================================

local IntroTab = Window:Tab({
    Title = "Introduction",
})

IntroTab:Paragraph({
    Title = "<b>ImGuiRemake.lua</b>",
    Text =
        "A client-side Roblox ImGui-style UI library. "
        .. "This example demonstrates the complete public API "
        .. "of the current library.",
})

IntroTab:Label({
    Title =
        "Window supports drag, resize, minimize, themes and fonts.",
})

IntroTab:Divider()

IntroTab:Label({
    Title =
        "<b>Current Elements</b>",
})

IntroTab:Label({
    Title =
        "Button • Toggle • Slider • Dropdown • TextBox",
})

IntroTab:Label({
    Title =
        "Paragraph • Label • Divider • Image • Section • Row",
})

IntroTab:Divider()

IntroTab:Label({
    Title =
        "Try resizing the window to see the layout adapt.",
})

IntroTab:Button({
    Title = "Center Window",

    Callback = function()
        Window:Center()
    end,
})

--==============================================================
-- TAB: BUTTON
--==============================================================

local ButtonTab = Window:Tab({
    Title = "Button",
})

ButtonTab:Label({
    Title = "<b>Button</b>",
})

ButtonTab:Button({
    Title = "Normal Button",

    Callback = function()
        print("[ImGuiRemake] Normal button clicked")
    end,
})

ButtonTab:Button({
    Title = "Full Width Button",
    Type = "Full",

    Callback = function()
        print("[ImGuiRemake] Full button clicked")
    end,
})

local RenameButton = ButtonTab:Button({
    Title = "Rename Me",
})

ButtonTab:Button({
    Title = "SetTitle()",

    Callback = function()
        RenameButton:SetTitle(
            "Renamed Button"
        )
    end,
})

ButtonTab:Divider()

ButtonTab:Label({
    Title =
        "Buttons automatically support hover, click highlight and callbacks.",
})

--==============================================================
-- TAB: TOGGLE
--==============================================================

local ToggleTab = Window:Tab({
    Title = "Toggle",
})

ToggleTab:Label({
    Title = "<b>Toggle</b>",
})

local MainToggle = ToggleTab:Toggle({
    Title = "Enable Feature",

    State = false,

    Callback = function(state)
        print(
            "[Toggle] Enable Feature:",
            state
        )
    end,
})

ToggleTab:Toggle({
    Title = "Default Enabled",

    State = true,

    Callback = function(state)
        print(
            "[Toggle] Default Enabled:",
            state
        )
    end,
})

ToggleTab:Divider()

ToggleTab:Button({
    Title = "State(true)",

    Callback = function()
        MainToggle:State(true)
    end,
})

ToggleTab:Button({
    Title = "State(false)",

    Callback = function()
        MainToggle:State(false)
    end,
})

ToggleTab:Button({
    Title = "SetTitle()",

    Callback = function()
        MainToggle:SetTitle(
            "Renamed Toggle"
        )
    end,
})

--==============================================================
-- TAB: SLIDER
--==============================================================

local SliderTab = Window:Tab({
    Title = "Slider",
})

SliderTab:Label({
    Title = "<b>Slider</b>",
})

local Volume = SliderTab:Slider({
    Title = "Volume",

    Min = 0,
    Max = 100,
    Step = 1,
    Value = 50,

    Callback = function(value)
        print(
            "[Slider] Volume:",
            value
        )
    end,
})

local Speed = SliderTab:Slider({
    Title = "Speed",

    Min = 0,
    Max = 10,
    Step = 0.1,
    Value = 5,

    Callback = function(value)
        print(
            "[Slider] Speed:",
            value
        )
    end,
})

SliderTab:Divider()

SliderTab:Button({
    Title = "SetValue(75)",

    Callback = function()
        Volume:SetValue(75)
    end,
})

SliderTab:Button({
    Title = "SetMin(20)",

    Callback = function()
        Volume:SetMin(20)
    end,
})

SliderTab:Button({
    Title = "SetMax(80)",

    Callback = function()
        Volume:SetMax(80)
    end,
})

SliderTab:Button({
    Title = "SetTitle()",

    Callback = function()
        Volume:SetTitle(
            "Master Volume"
        )
    end,
})

--==============================================================
-- TAB: DROPDOWN
--==============================================================

local DropdownTab = Window:Tab({
    Title = "Dropdown",
})

DropdownTab:Label({
    Title = "<b>Dropdown</b>",
})

local Fruit = DropdownTab:Dropdown({
    Title = "Fruit",

    Value = {
        "Apple",
        "Banana",
        "Orange",
        "Mango",
        "Watermelon",
    },

    Multi = false,

    Selected = {
        "Apple",
    },

    Callback = function(selected, changed)
        print(
            "[Dropdown]",
            changed,
            selected[1]
        )
    end,
})

local Features = DropdownTab:Dropdown({
    Title = "Features",

    Value = {
        "Combat",
        "Visual",
        "Movement",
        "Utility",
    },

    Multi = true,

    Selected = {
        "Visual",
        "Utility",
    },

    Callback = function(selected)
        print(
            "[Dropdown] Selected:",
            table.concat(
                selected,
                ", "
            )
        )
    end,
})

DropdownTab:Divider()

DropdownTab:Button({
    Title = "Add Fruit",

    Callback = function()
        Fruit:Add("Dragon Fruit")
    end,
})

DropdownTab:Button({
    Title = "Delete Banana",

    Callback = function()
        Fruit:Delete("Banana")
    end,
})

DropdownTab:Button({
    Title = "Refresh Fruits",

    Callback = function()
        Fruit:Refresh({
            "Apple",
            "Pear",
            "Peach",
            "Cherry",
        })
    end,
})

DropdownTab:Button({
    Title = "Refesh() Alias",

    Callback = function()
        Fruit:Refesh({
            "Alpha",
            "Beta",
            "Gamma",
        })
    end,
})

DropdownTab:Button({
    Title = "SetTitle()",

    Callback = function()
        Fruit:SetTitle(
            "Favorite Fruit"
        )
    end,
})

--==============================================================
-- TAB: TEXTBOX
--==============================================================

local TextBoxTab = Window:Tab({
    Title = "TextBox",
})

TextBoxTab:Label({
    Title = "<b>TextBox</b>",
})

local Username = TextBoxTab:TextBox({
    Title = "Username",

    Placeholder = "Enter username...",

    Text = "Player",

    ClearTextOnFocus = false,

    Callback = function(text)
        print(
            "[TextBox] Username:",
            text
        )
    end,
})

local Search = TextBoxTab:TextBox({
    Title = "Search",

    Placeholder = "Search something...",

    ClearTextOnFocus = true,

    Callback = function(text)
        print(
            "[TextBox] Search:",
            text
        )
    end,
})

TextBoxTab:Divider()

TextBoxTab:Button({
    Title = "SetText()",

    Callback = function()
        Username:SetText(
            "Clone"
        )
    end,
})

TextBoxTab:Button({
    Title = "Clear()",

    Callback = function()
        Username:Clear()
    end,
})

TextBoxTab:Button({
    Title = "SetTitle()",

    Callback = function()
        Username:SetTitle(
            "Player Name"
        )
    end,
})

TextBoxTab:Button({
    Title = "SetPlaceholder()",

    Callback = function()
        Username:SetPlaceholder(
            "Enter your player name..."
        )
    end,
})

TextBoxTab:Button({
    Title = "ClearTextOnFocus = true",

    Callback = function()
        Username:SetClearTextOnFocus(
            true
        )
    end,
})

--==============================================================
-- TAB: PARAGRAPH
--==============================================================

local ParagraphTab = Window:Tab({
    Title = "Paragraph",
})

ParagraphTab:Paragraph({
    Title = "<b>Paragraph</b>",

    Text =
        "Paragraph supports RichText, TextWrapped and "
        .. "automatic height adjustment.",
})

ParagraphTab:Paragraph({
    Title =
        '<font color="#55AAFF" size="20">'
        .. "<b>RichText</b>"
        .. "</font>",

    Text =
        '<font color="#FFFFFF">'
        .. "Normal text\n"
        .. '<font color="#55FF55"><b>Green</b></font>\n'
        .. '<font color="#FF5555"><b>Red</b></font>\n'
        .. '<font color="#FFD75F" size="18">Large Yellow</font>'
        .. "</font>",
})

local EditableParagraph =
    ParagraphTab:Paragraph({
        Title = "<b>Editable</b>",
        Text = "Original paragraph text.",
    })

ParagraphTab:Button({
    Title = "SetTitle()",

    Callback = function()
        EditableParagraph:SetTitle(
            '<font color="#55AAFF">'
            .. "<b>New Title</b>"
            .. "</font>"
        )
    end,
})

ParagraphTab:Button({
    Title = "SetText()",

    Callback = function()
        EditableParagraph:SetText(
            "This text was changed dynamically."
        )
    end,
})

--==============================================================
-- TAB: LABEL
--==============================================================

local LabelTab = Window:Tab({
    Title = "Label",
})

LabelTab:Label({
    Title =
        "Label is a simple text element.",
})

LabelTab:Label({
    Title =
        '<font color="#55AAFF" size="18">'
        .. "<b>RichText Label</b>"
        .. "</font>",
})

local DynamicLabel = LabelTab:Label({
    Title = "Rename Me",
})

LabelTab:Button({
    Title = "SetTitle()",

    Callback = function()
        DynamicLabel:SetTitle(
            "<b>Renamed Label</b>"
        )
    end,
})

LabelTab:Divider()

LabelTab:Label({
    Title =
        "Long labels automatically wrap when the window is resized.",
})

--==============================================================
-- TAB: DIVIDER
--==============================================================

local DividerTab = Window:Tab({
    Title = "Divider",
})

DividerTab:Label({
    Title = "Element above divider",
})

DividerTab:Divider()

DividerTab:Label({
    Title = "Element below divider",
})

DividerTab:Divider()

DividerTab:Label({
    Title =
        "Divider is intentionally simple: it separates content.",
})

--==============================================================
-- TAB: IMAGE
--==============================================================

local ImageTab = Window:Tab({
    Title = "Image",
})

ImageTab:Label({
    Title = "<b>Image</b>",
})

-- Roblox asset
ImageTab:Image({
    Image =
        "rbxassetid://137021248562867",

    Size =
        UDim2.new(
            0.5,
            0,
            0,
            180
        ),
})

ImageTab:Label({
    Title =
        "Roblox Asset ID",
})

ImageTab:Divider()

-- Raw JPG
local RickImage = ImageTab:Image({
    Image =
        "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/rickroll.jpg",

    Ratio = 1,
})

ImageTab:Label({
    Title =
        "Raw JPG + Ratio",
})

ImageTab:Divider()

-- Raw PNG
ImageTab:Image({
    Image =
        "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/Kaguya_converted.png",

    Size =
        UDim2.new(
            0.5,
            0,
            0,
            180
        ),
})

ImageTab:Label({
    Title =
        "Raw PNG + Size",
})

ImageTab:Divider()

-- Size + Ratio
ImageTab:Image({
    Image =
        "rbxassetid://137021248562867",

    Size =
        UDim2.new(
            1,
            0,
            0,
            220
        ),

    Ratio = 1,
})

ImageTab:Label({
    Title =
        "Size + Ratio",
})

ImageTab:Divider()

ImageTab:Button({
    Title = "SetImage -> Kaguya",

    Callback = function()
        RickImage:SetImage(
            "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/Kaguya_converted.png"
        )
    end,
})

ImageTab:Button({
    Title = "SetImage -> Rickroll",

    Callback = function()
        RickImage:SetImage(
            "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/rickroll.jpg"
        )
    end,
})

--==============================================================
-- TAB: SECTION
--==============================================================

local SectionTab = Window:Tab({
    Title = "Section",
})

SectionTab:Label({
    Title =
        "Sections create their own element container and support nesting.",
})

-- Main section
local Settings = SectionTab:Section({
    Title = "Settings",
    Open = true,
})

Settings:Label({
    Title = "Elements inside a Section are indented.",
})

Settings:Toggle({
    Title = "Enable Feature",
    State = true,
})

Settings:Slider({
    Title = "Power",
    Min = 0,
    Max = 100,
    Step = 1,
    Value = 50,
})

Settings:Dropdown({
    Title = "Mode",

    Value = {
        "Easy",
        "Normal",
        "Hard",
    },

    Multi = false,

    Selected = {
        "Normal",
    },
})

Settings:TextBox({
    Title = "Name",
    Placeholder = "Enter name...",
    ClearTextOnFocus = true,
})

Settings:Paragraph({
    Title = "<b>Section Paragraph</b>",
    Text = "Paragraph inside Section.",
})

Settings:Divider()

Settings:Image({
    Image =
        "rbxassetid://137021248562867",

    Size =
        UDim2.new(
            0.5,
            0,
            0,
            120
        ),
})

-- Nested section
local Advanced = Settings:Section({
    Title = "Advanced",
    Open = true,
})

Advanced:Toggle({
    Title = "Experimental",
    State = false,
})

Advanced:Slider({
    Title = "Advanced Value",
    Min = 0,
    Max = 100,
    Step = 5,
    Value = 25,
})

-- Deep nested section
local Debug = Advanced:Section({
    Title = "Debug",
    Open = false,
})

Debug:Label({
    Title =
        "This Section is nested two levels deep.",
})

Debug:Button({
    Title = "Print Debug",

    Callback = function()
        print(
            "[ImGuiRemake] Debug button"
        )
    end,
})

SectionTab:Divider()

SectionTab:Button({
    Title = "Settings:Close()",

    Callback = function()
        Settings:Close()
    end,
})

SectionTab:Button({
    Title = "Settings:Open()",

    Callback = function()
        Settings:Open()
    end,
})

SectionTab:Button({
    Title = "Settings:SetTitle()",

    Callback = function()
        Settings:SetTitle(
            "General Settings"
        )
    end,
})

SectionTab:Button({
    Title = "Debug:SetOpen(true)",

    Callback = function()
        Debug:SetOpen(true)
    end,
})

--==============================================================
-- TAB: ROW
--==============================================================

local RowTab = Window:Tab({
    Title = "Row",
})

RowTab:Paragraph({
    Title = "<b>Row</b>",

    Text =
        "Row places multiple elements on the same horizontal line. "
        .. "It can also be nested and used inside Sections.",
})

-- Simple row
local Row1 = RowTab:Row()

Row1:Button({
    Title = "One",
})

Row1:Button({
    Title = "Two",
})

Row1:Button({
    Title = "Three",
})

RowTab:Divider()

-- Mixed row
local Row2 = RowTab:Row()

Row2:Button({
    Title = "Action",
})

Row2:Toggle({
    Title = "Auto",
    State = false,
})

Row2:Label({
    Title = "Enabled",
})

RowTab:Divider()

-- Long element row
local Row3 = RowTab:Row()

Row3:Slider({
    Title = "Value",
    Min = 0,
    Max = 100,
    Step = 1,
    Value = 50,
})

Row3:Button({
    Title = "Apply",
})

RowTab:Divider()

-- Dropdown + button
local Row4 = RowTab:Row()

Row4:Dropdown({
    Title = "Mode",

    Value = {
        "Low",
        "Medium",
        "High",
    },

    Multi = false,

    Selected = {
        "Medium",
    },
})

Row4:Button({
    Title = "Confirm",
})

RowTab:Divider()

-- TextBox + button
local Row5 = RowTab:Row()

Row5:TextBox({
    Title = "Name",

    Placeholder = "Enter name...",

    ClearTextOnFocus = true,
})

Row5:Button({
    Title = "Submit",
})

RowTab:Divider()

-- Nested Row
local ParentRow = RowTab:Row()

ParentRow:Button({
    Title = "Parent",
})

local ChildRow = ParentRow:Row()

ChildRow:Button({
    Title = "Nested A",
})

ChildRow:Button({
    Title = "Nested B",
})

RowTab:Divider()

-- Row inside Section
local RowSection = RowTab:Section({
    Title = "Section + Row",
    Open = true,
})

local SectionRow = RowSection:Row()

SectionRow:Button({
    Title = "Save",
})

SectionRow:Button({
    Title = "Load",
})

SectionRow:Toggle({
    Title = "Auto",
    State = true,
})

--==============================================================
-- TAB: THEME / WINDOW
--==============================================================

local ThemeTab = Window:Tab({
    Title = "Theme",
})

ThemeTab:Label({
    Title =
        "<b>Theme</b>",
})

ThemeTab:Button({
    Title = "Default",

    Callback = function()
        Window:Theme(
            "Default"
        )
    end,
})

ThemeTab:Button({
    Title = "Red",

    Callback = function()
        Window:Theme(
            "Red"
        )
    end,
})

ThemeTab:Button({
    Title = "Green",

    Callback = function()
        Window:Theme(
            "Green"
        )
    end,
})

ThemeTab:Button({
    Title = "Purple",

    Callback = function()
        Window:Theme(
            "Purple"
        )
    end,
})

ThemeTab:Divider()

ThemeTab:Label({
    Title =
        "<b>Fonts</b>",
})

ThemeTab:Button({
    Title = "RobotoMono",

    Callback = function()
        Window:SetFont(
            Enum.Font.RobotoMono
        )
    end,
})

ThemeTab:Button({
    Title = "Code",

    Callback = function()
        Window:SetFont(
            Enum.Font.Code
        )
    end,
})

ThemeTab:Button({
    Title = "FredokaOne",

    Callback = function()
        Window:SetFont(
            Enum.Font.FredokaOne
        )
    end,
})

ThemeTab:Divider()

ThemeTab:Label({
    Title =
        "<b>Window</b>",
})

ThemeTab:Button({
    Title = "Center()",

    Callback = function()
        Window:Center()
    end,
})

ThemeTab:Button({
    Title = "SetTitle()",

    Callback = function()
        Window:SetTitle(
            "ImGuiRemake.lua | Public Example"
        )
    end,
})

ThemeTab:Button({
    Title = "Close()",

    Callback = function()
        Window:Close()
    end,
})

ThemeTab:Button({
    Title = "Open()",

    Callback = function()
        Window:Open()
    end,
})

ThemeTab:Button({
    Title = "Hide / Show",

    Callback = function()
        Window:SetVisible(false)

        task.delay(
            1,
            function()
                if not Window.IsDestroyed then
                    Window:SetVisible(true)
                end
            end
        )
    end,
})

ThemeTab:Divider()

ThemeTab:Paragraph({
    Title = "<b>Window Size Limits</b>",

    Text =
        "Current example: MinSize = 450×320, "
        .. "MaxSize = 1100×800. "
        .. "Use the resize handle in the bottom-right corner.",
})

--==============================================================
-- DONE
--==============================================================

print("======================================================")
print(" ImGuiRemake.lua public example loaded successfully.")
print("======================================================")
print("Core:")
print("  Window / Tab / Section / Row")
print("")
print("Elements:")
print("  Button / Toggle / Slider / Dropdown")
print("  TextBox / Paragraph / Label / Divider / Image")
print("")
print("Features:")
print("  Themes")
print("  Fonts")
print("  Section nesting")
print("  Row nesting")
print("  Section animations")
print("  Window resize limits")
print("  Image Size / Ratio / SetImage")
print("  TextBox Placeholder / ClearTextOnFocus")
print("======================================================")
