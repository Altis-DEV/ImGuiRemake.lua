--[[
    ImGuiRemake.lua
    PUBLIC EXAMPLE
    ============================================================
    Core:
      Window / Tab / Section / Row / Modal

    Elements:
      Button / Toggle / Slider / Dropdown / TextBox
      Paragraph / Label / Divider / Image

    Window:
      Center / SetTitle / SetVisible / SetFont / Theme
      Open / Close / Destroy / MinSize / MaxSize

    Section:
      Open / Close / SetOpen / SetTitle / Destroy
      Nested Section

    Row:
      Tab:Row() / Section:Row() / Row:Row()

    Modal:
      RichText Title / RichText Text
      Multiple Buttons / Custom Button Colors
      Close()

    Image:
      rbxassetid / Raw JPG / Raw PNG
      Size / Ratio / SetImage()

    TextBox:
      Text / Placeholder / ClearTextOnFocus
      SetText / Clear / SetTitle / SetPlaceholder
      SetClearTextOnFocus
]]




------------------------------------------------------------
-- LOAD
------------------------------------------------------------

local Repo = "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/"
local ImGui = loadstring(game:HttpGet(Repo .. "init.lua"))()

------------------------------------------------------------
-- THEMES
------------------------------------------------------------

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
    ModalOverlay = Color3.fromRGB(0, 0, 0),
    ModalOverlayTransparency = 0.45,
    ModalFrame = Color3.fromRGB(22, 22, 22),
    ModalTitleFrame = Color3.fromRGB(45, 25, 25),
    ModalTextFrame = Color3.fromRGB(35, 25, 25),
    ModalButtonFrame = Color3.fromRGB(30, 30, 30),
    ModalButton = Color3.fromRGB(180, 50, 50),
    ModalButtonHighlight = Color3.fromRGB(220, 70, 70),
    ModalButtonText = Color3.fromRGB(255, 255, 255),
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
    ModalOverlay = Color3.fromRGB(0, 0, 0),
    ModalOverlayTransparency = 0.45,
    ModalFrame = Color3.fromRGB(22, 22, 22),
    ModalTitleFrame = Color3.fromRGB(25, 45, 30),
    ModalTextFrame = Color3.fromRGB(22, 35, 25),
    ModalButtonFrame = Color3.fromRGB(30, 30, 30),
    ModalButton = Color3.fromRGB(45, 170, 90),
    ModalButtonHighlight = Color3.fromRGB(60, 200, 110),
    ModalButtonText = Color3.fromRGB(255, 255, 255),
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
    ModalOverlay = Color3.fromRGB(0, 0, 0),
    ModalOverlayTransparency = 0.45,
    ModalFrame = Color3.fromRGB(22, 22, 22),
    ModalTitleFrame = Color3.fromRGB(35, 25, 45),
    ModalTextFrame = Color3.fromRGB(28, 23, 35),
    ModalButtonFrame = Color3.fromRGB(30, 30, 30),
    ModalButton = Color3.fromRGB(130, 70, 190),
    ModalButtonHighlight = Color3.fromRGB(160, 90, 220),
    ModalButtonText = Color3.fromRGB(255, 255, 255),
})

------------------------------------------------------------
-- WINDOW
------------------------------------------------------------

local Window = ImGui:CreateWindow({
    Title = "ImGuiRemake.lua | Public Example",
    Size = UDim2.new(0, 300, 0, 300),
    MinSize = Vector2.new(300, 300),
    MaxSize = Vector2.new(1000, 800),
    Font = Enum.Font.RobotoMono,
})

Window:Center()

------------------------------------------------------------
-- INTRO
------------------------------------------------------------

local Intro = Window:Tab({Title = "Introduction"})

Intro:Paragraph({
    Title = "<b>ImGuiRemake.lua</b>",
    Text = "A Roblox ImGui-style UI library. This example demonstrates the current public API and layout system.",
})

Intro:Label({Title = "Window → Tab → Section → Row → Elements"})
Intro:Label({Title = "Button • Toggle • Slider • Dropdown • TextBox"})
Intro:Label({Title = "Paragraph • Label • Divider • Image • Modal"})
Intro:Divider()

Intro:Button({
    Title = "Center Window",
    Callback = function() Window:Center() end,
})

------------------------------------------------------------
-- BUTTON
------------------------------------------------------------

local ButtonTab = Window:Tab({Title = "Button"})

ButtonTab:Label({Title = "<b>Button</b>"})

ButtonTab:Button({
    Title = "Normal Button",
    Callback = function() print("[Button] Normal clicked") end,
})

ButtonTab:Button({
    Title = "Full Width Button",
    Type = "Full",
    Callback = function() print("[Button] Full clicked") end,
})

local RenameButton = ButtonTab:Button({Title = "Rename Me"})

ButtonTab:Button({
    Title = "SetTitle()",
    Callback = function() RenameButton:SetTitle("Renamed Button") end,
})

ButtonTab:Divider()

------------------------------------------------------------
-- BUTTON CUSTOM COLOR TEST
------------------------------------------------------------

local DangerButton = ButtonTab:Button({
    Title = "Danger Button",
    Color = Color3.fromRGB(180, 50, 50),
    HighlightColor = Color3.fromRGB(220, 70, 70),

    Callback = function()
        print("[Button] Danger clicked")
    end,
})

ButtonTab:Button({
    Title = "Custom Green",
    Color = Color3.fromRGB(45, 170, 90),
    HighlightColor = Color3.fromRGB(60, 200, 110),

    Callback = function()
        print("[Button] Green clicked")
    end,
})

ButtonTab:Button({
    Title = "Custom Purple",
    Color = Color3.fromRGB(130, 70, 190),
    HighlightColor = Color3.fromRGB(160, 90, 220),

    Callback = function()
        print("[Button] Purple clicked")
    end,
})

ButtonTab:Label({
    Title = "Buttons support hover,custom color,click highlighting and callbacks.",
})

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local ToggleTab = Window:Tab({Title = "Toggle"})

local MainToggle = ToggleTab:Toggle({
    Title = "Enable Feature",
    State = false,
    Callback = function(state) print("[Toggle]", state) end,
})

ToggleTab:Toggle({
    Title = "Default Enabled",
    State = true,
})

ToggleTab:Button({
    Title = "State(true)",
    Callback = function() MainToggle:State(true) end,
})

ToggleTab:Button({
    Title = "State(false)",
    Callback = function() MainToggle:State(false) end,
})

ToggleTab:Button({
    Title = "SetTitle()",
    Callback = function() MainToggle:SetTitle("Renamed Toggle") end,
})

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

local SliderTab = Window:Tab({Title = "Slider"})

local Volume = SliderTab:Slider({
    Title = "Volume",
    Min = 0,
    Max = 100,
    Step = 1,
    Value = 50,
    Callback = function(value) print("[Slider] Volume:", value) end,
})

local Speed = SliderTab:Slider({
    Title = "Speed",
    Min = 0,
    Max = 10,
    Step = 0.1,
    Value = 5,
})

SliderTab:Button({
    Title = "SetValue(75)",
    Callback = function() Volume:SetValue(75) end,
})

SliderTab:Button({
    Title = "SetMin(20)",
    Callback = function() Volume:SetMin(20) end,
})

SliderTab:Button({
    Title = "SetMax(80)",
    Callback = function() Volume:SetMax(80) end,
})

SliderTab:Button({
    Title = "SetTitle()",
    Callback = function() Volume:SetTitle("Master Volume") end,
})

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

local DropdownTab = Window:Tab({Title = "Dropdown"})

local Fruit = DropdownTab:Dropdown({
    Title = "Fruit",
    Value = {"Apple", "Banana", "Orange", "Mango", "Watermelon"},
    Multi = false,
    Selected = {"Apple"},
    Callback = function(selected, changed)
        print("[Dropdown]", changed, selected[1])
    end,
})

local Features = DropdownTab:Dropdown({
    Title = "Features",
    Value = {"Combat", "Visual", "Movement", "Utility"},
    Multi = true,
    Selected = {"Visual", "Utility"},
})

DropdownTab:Button({
    Title = "Add Fruit",
    Callback = function() Fruit:Add("Dragon Fruit") end,
})

DropdownTab:Button({
    Title = "Delete Banana",
    Callback = function() Fruit:Delete("Banana") end,
})

DropdownTab:Button({
    Title = "Refresh",
    Callback = function() Fruit:Refresh({"Apple", "Pear", "Peach", "Cherry"}) end,
})

DropdownTab:Button({
    Title = "Refesh() Alias",
    Callback = function() Fruit:Refesh({"Alpha", "Beta", "Gamma"}) end,
})

DropdownTab:Button({
    Title = "SetTitle()",
    Callback = function() Fruit:SetTitle("Favorite Fruit") end,
})

------------------------------------------------------------
-- TEXTBOX
------------------------------------------------------------

local TextBoxTab = Window:Tab({Title = "TextBox"})

local Username = TextBoxTab:TextBox({
    Title = "Username",
    Placeholder = "Enter username...",
    Text = "Player",
    ClearTextOnFocus = false,
    Callback = function(text) print("[TextBox]", text) end,
})

local Search = TextBoxTab:TextBox({
    Title = "Search",
    Placeholder = "Search something...",
    ClearTextOnFocus = true,
})

TextBoxTab:Button({
    Title = "SetText()",
    Callback = function() Username:SetText("Clone") end,
})

TextBoxTab:Button({
    Title = "Clear()",
    Callback = function() Username:Clear() end,
})

TextBoxTab:Button({
    Title = "SetTitle()",
    Callback = function() Username:SetTitle("Player Name") end,
})

TextBoxTab:Button({
    Title = "SetPlaceholder()",
    Callback = function() Username:SetPlaceholder("Enter player name...") end,
})

TextBoxTab:Button({
    Title = "ClearTextOnFocus = true",
    Callback = function() Username:SetClearTextOnFocus(true) end,
})

------------------------------------------------------------
-- PARAGRAPH
------------------------------------------------------------

local ParagraphTab = Window:Tab({Title = "Paragraph"})

ParagraphTab:Paragraph({
    Title = "<b>Paragraph</b>",
    Text = "Paragraph supports RichText, wrapping and automatic height.",
})

ParagraphTab:Paragraph({
    Title = '<font color="#55AAFF" size="20"><b>RichText</b></font>',
    Text = '<font color="#FFFFFF">Normal text\n<font color="#55FF55"><b>Green</b></font>\n<font color="#FF5555"><b>Red</b></font>\n<font color="#FFD75F" size="18">Large Yellow</font></font>',
})

local EditableParagraph = ParagraphTab:Paragraph({
    Title = "<b>Editable Paragraph</b>",
    Text = "Original text.",
})

ParagraphTab:Button({
    Title = "SetTitle()",
    Callback = function() EditableParagraph:SetTitle("<b>New Paragraph Title</b>") end,
})

ParagraphTab:Button({
    Title = "SetText()",
    Callback = function() EditableParagraph:SetText("Text changed dynamically.") end,
})

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

local LabelTab = Window:Tab({Title = "Label"})

LabelTab:Label({Title = "Normal Label"})
LabelTab:Label({Title = '<font color="#55AAFF" size="18"><b>RichText Label</b></font>'})

local DynamicLabel = LabelTab:Label({Title = "Rename Me"})

LabelTab:Button({
    Title = "SetTitle()",
    Callback = function() DynamicLabel:SetTitle("<b>Renamed Label</b>") end,
})

------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

local DividerTab = Window:Tab({Title = "Divider"})

DividerTab:Label({Title = "Above Divider"})
DividerTab:Divider()
DividerTab:Label({Title = "Below Divider"})
DividerTab:Divider()
DividerTab:Label({Title = "Divider is a simple separator."})

------------------------------------------------------------
-- IMAGE
------------------------------------------------------------

local ImageTab = Window:Tab({Title = "Image"})

ImageTab:Label({Title = "<b>Image</b>"})

local AssetImage = ImageTab:Image({
    Image = "rbxassetid://137021248562867",
    Size = UDim2.new(0.5, 0, 0, 180),
})

ImageTab:Label({Title = "Roblox Asset ID"})
ImageTab:Divider()

local RemoteImage = ImageTab:Image({
    Image = "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/rickroll.jpg",
    Ratio = 1,
})

ImageTab:Label({Title = "Raw JPG + Ratio"})
ImageTab:Divider()

ImageTab:Image({
    Image = "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/Kaguya_converted.png",
    Size = UDim2.new(0.5, 0, 0, 180),
})

ImageTab:Label({Title = "Raw PNG + Size"})
ImageTab:Divider()

ImageTab:Image({
    Image = "rbxassetid://137021248562867",
    Size = UDim2.new(1, 0, 0, 220),
    Ratio = 1,
})

ImageTab:Label({Title = "Size + Ratio"})

ImageTab:Button({
    Title = "SetImage -> Kaguya",
    Callback = function()
        RemoteImage:SetImage("https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/Kaguya_converted.png")
    end,
})

ImageTab:Button({
    Title = "SetImage -> Rickroll",
    Callback = function()
        RemoteImage:SetImage("https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/rickroll.jpg")
    end,
})

------------------------------------------------------------
-- SECTION
------------------------------------------------------------

local SectionTab = Window:Tab({Title = "Section"})

SectionTab:Label({
    Title = "Sections have their own ElementContainer and can be nested.",
})

local Settings = SectionTab:Section({
    Title = "Settings",
    Open = true,
})

Settings:Label({
    Title = "Elements inside Sections are indented.",
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
    Value = {"Easy", "Normal", "Hard"},
    Multi = false,
    Selected = {"Normal"},
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
    Image = "rbxassetid://137021248562867",
    Size = UDim2.new(0.5, 0, 0, 120),
})

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

local Debug = Advanced:Section({
    Title = "Debug",
    Open = false,
})

Debug:Label({
    Title = "Nested Section",
})

Debug:Button({
    Title = "Print Debug",
    Callback = function() print("[Section] Debug") end,
})

SectionTab:Button({
    Title = "Settings:Close()",
    Callback = function() Settings:Close() end,
})

SectionTab:Button({
    Title = "Settings:Open()",
    Callback = function() Settings:Open() end,
})

SectionTab:Button({
    Title = "Debug:SetOpen(true)",
    Callback = function() Debug:SetOpen(true) end,
})

SectionTab:Button({
    Title = "Settings:SetTitle()",
    Callback = function() Settings:SetTitle("General Settings") end,
})

------------------------------------------------------------
-- ROW
------------------------------------------------------------

local RowTab = Window:Tab({Title = "Row"})

RowTab:Paragraph({
    Title = "<b>Row</b>",
    Text = "Row places multiple elements on the same horizontal line and can be nested.",
})

local Row1 = RowTab:Row()
Row1:Button({Title = "One"})
Row1:Button({Title = "Two"})
Row1:Button({Title = "Three"})

RowTab:Divider()

local Row2 = RowTab:Row()
Row2:Button({Title = "Action"})
Row2:Toggle({Title = "Auto", State = false})
Row2:Label({Title = "Enabled"})

RowTab:Divider()

local Row3 = RowTab:Row()
Row3:Slider({Title = "Value", Min = 0, Max = 100, Step = 1, Value = 50})
Row3:Button({Title = "Apply"})

RowTab:Divider()

local Row4 = RowTab:Row()
Row4:Dropdown({
    Title = "Mode",
    Value = {"Low", "Medium", "High"},
    Multi = false,
    Selected = {"Medium"},
})
Row4:Button({Title = "Confirm"})

RowTab:Divider()

local Row5 = RowTab:Row()
Row5:TextBox({
    Title = "Name",
    Placeholder = "Enter name...",
    ClearTextOnFocus = true,
})
Row5:Button({Title = "Submit"})

RowTab:Divider()

local ParentRow = RowTab:Row()
ParentRow:Button({Title = "Parent"})

local ChildRow = ParentRow:Row()
ChildRow:Button({Title = "Nested A"})
ChildRow:Button({Title = "Nested B"})

RowTab:Divider()

local RowSection = RowTab:Section({
    Title = "Section + Row",
    Open = true,
})

local SectionRow = RowSection:Row()
SectionRow:Button({Title = "Save"})
SectionRow:Button({Title = "Load"})
SectionRow:Toggle({Title = "Auto", State = true})

------------------------------------------------------------
-- MODAL
------------------------------------------------------------

local ModalTab = Window:Tab({Title = "Modal"})

ModalTab:Label({
    Title = "Modal appears above the entire Window as an overlay.",
})

ModalTab:Label({
    Title = "<b>Modal Test</b>",
})

ModalTab:Paragraph({
    Title = "<b>About Modal</b>",
    Text = "Modal appears above the entire window, supports RichText, automatically expands with its content, uses UIScale for open/close animation, and allows multiple equally-sized buttons.",
})

------------------------------------------------------------
-- NORMAL MODAL
------------------------------------------------------------

local function OpenNormalModal()
    local Modal

    Modal = ModalTab:Modal({
        Title = "<b>Normal Modal</b>",
        Text = "This is a normal Modal used to test the basic layout and animation.",

        Buttons = {
            {
                Title = "No",

                Callback = function()
                    print("[Normal Modal] No")
                    Modal:Close()
                end,
            },

            {
                Title = "Yes",

                Callback = function()
                    print("[Normal Modal] Yes")
                    Modal:Close()
                end,
            },
        },
    })
end

ModalTab:Button({
    Title = "Open Normal Modal",
    Type = "Full",

    Callback = OpenNormalModal,
})

------------------------------------------------------------
-- VERY LONG MODAL
------------------------------------------------------------

local function OpenLongModal()
    local Modal

    Modal = ModalTab:Modal({
        Title =
            '<font color="#55AAFF" size="20"><b>This Is An Extremely Long Modal Title Designed To Test Automatic TitleFrame Expansion And RichText Wrapping</b></font>',

        Text =
            '<font color="#FFFFFF">This is an intentionally very long Modal text designed to test the complete automatic sizing system. The TextFrame should automatically expand when this paragraph wraps to multiple lines, and the ButtonFrame should always remain directly underneath it. The entire Modal should remain centered on the screen while the UIScale animation only changes its visual scale.</font>\n\n'
            .. '<font color="#55FF55"><b>This green section tests RichText inside the long Modal.</b></font>\n\n'
            .. '<font color="#FFD75F">This yellow section adds even more content so the Modal becomes significantly taller than a normal Modal.</font>',

        Buttons = {
            {
                Title = "Cancel",

                Callback = function()
                    print("[Long Modal] Cancel")
                    Modal:Close()
                end,
            },

            {
                Title = "Continue",

                Callback = function()
                    print("[Long Modal] Continue")
                    Modal:Close()
                end,
            },
        },
    })
end

ModalTab:Button({
    Title = "Open Very Long Modal",
    Type = "Full",

    Callback = OpenLongModal,
})

------------------------------------------------------------
-- DESTROY WINDOW MODAL
------------------------------------------------------------

local function OpenDestroyModal()
    local Modal

    Modal = ModalTab:Modal({
        Title =
            '<font color="#FF5555" size="18"><b>Destroy Window</b></font>',

        Text =
            "Do You Want To Destroy The Window?",

        Buttons = {
            {
                Title = "No",

                Callback = function()
                    print("[Destroy Modal] No")
                    Modal:Close()
                end,
            },

            {
                Title = "Yes",

                Color =
                    Color3.fromRGB(
                        180,
                        50,
                        50
                    ),

                HighlightColor =
                    Color3.fromRGB(
                        220,
                        70,
                        70
                    ),

                Callback = function()
                    print("[Destroy Modal] Yes")
                    Window:Destroy()
                end,
            },
        },
    })
end

ModalTab:Button({
    Title = "Window Destroy",
    Type = "Full",

    Color =
        Color3.fromRGB(
            180,
            50,
            50
        ),

    HighlightColor =
        Color3.fromRGB(
            220,
            70,
            70
        ),

    Callback = OpenDestroyModal,
})

ModalTab:Paragraph({
    Title = "<b>Modal Buttons</b>",
    Text = "Buttons are automatically distributed evenly across the ButtonFrame. Each button can optionally define Color and HighlightColor.",
})

------------------------------------------------------------
-- THEME / WINDOW
------------------------------------------------------------

local ThemeTab = Window:Tab({Title = "Theme"})

ThemeTab:Label({Title = "<b>Themes</b>"})

ThemeTab:Button({
    Title = "Default",
    Callback = function() Window:Theme("Default") end,
})

ThemeTab:Button({
    Title = "Red",
    Callback = function() Window:Theme("Red") end,
})

ThemeTab:Button({
    Title = "Green",
    Callback = function() Window:Theme("Green") end,
})

ThemeTab:Button({
    Title = "Purple",
    Callback = function() Window:Theme("Purple") end,
})

ThemeTab:Divider()

ThemeTab:Label({Title = "<b>Fonts</b>"})

ThemeTab:Button({
    Title = "RobotoMono",
    Callback = function() Window:SetFont(Enum.Font.RobotoMono) end,
})

ThemeTab:Button({
    Title = "Code",
    Callback = function() Window:SetFont(Enum.Font.Code) end,
})

ThemeTab:Button({
    Title = "FredokaOne",
    Callback = function() Window:SetFont(Enum.Font.FredokaOne) end,
})

ThemeTab:Divider()

ThemeTab:Label({Title = "<b>Window</b>"})

ThemeTab:Button({
    Title = "Center()",
    Callback = function() Window:Center() end,
})

ThemeTab:Button({
    Title = "SetTitle()",
    Callback = function()
        Window:SetTitle("ImGuiRemake.lua | Public Example")
    end,
})

ThemeTab:Button({
    Title = "Close()",
    Callback = function() Window:Close() end,
})

ThemeTab:Button({
    Title = "Open()",
    Callback = function() Window:Open() end,
})

ThemeTab:Button({
    Title = "Hide / Show",
    Callback = function()
        Window:SetVisible(false)
        task.delay(1, function()
            if not Window.IsDestroyed then
                Window:SetVisible(true)
            end
        end)
    end,
})

ThemeTab:Divider()

ThemeTab:Paragraph({
    Title = "<b>Window Limits</b>",
    Text = "This example uses MinSize = 300×300 and MaxSize = 1000×800. Resize using the bottom-right corner.",
})

------------------------------------------------------------
-- DONE
------------------------------------------------------------

print("======================================================")
print(" ImGuiRemake.lua public example loaded successfully.")
print("======================================================")
print("Window / Tab / Section / Row / Modal")
print("Button / Toggle / Slider / Dropdown / TextBox")
print("Paragraph / Label / Divider / Image")
print("Themes / Fonts / Resize / Nesting / RichText")
print("======================================================")
print("thanks for use the ui library❤️")
