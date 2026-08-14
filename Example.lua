--==============================================================
-- ImGuiRemake.lua
-- COMPLETE API / ELEMENT / METHOD TEST
--
-- Mục tiêu:
--   1. Test toàn bộ element.
--   2. Test toàn bộ method public của từng element.
--   3. Test theme / font propagation.
--   4. Test Section / nested Section.
--   5. Test Row / nested Row.
--   6. Test Modal / Console / TextInput.
--   7. Test multi-window.
--   8. Test dynamic SetTitle / SetText / SetValue...
--
-- LƯU Ý:
--   File này được thiết kế để làm example.lua public.
--==============================================================


--==============================================================
-- LOAD LIBRARY
--==============================================================

local ImGui = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Altis-DEV/ImGuiRemake.lua/refs/heads/main/init.lua"
))()


--==============================================================
-- MAIN WINDOW
--==============================================================

local Window = ImGui:CreateWindow({
    Title = "ImGuiRemake.lua - Complete Test",
    Size = UDim2.new(0, 300, 0, 300),
    MinSize = Vector2.new(300, 300),
    MaxSize = Vector2.new(1000, 800),
    Font = Enum.Font.RobotoMono,
})


--==============================================================
-- HELPER
--==============================================================

local function safePrint(...)
    print("[ImGuiRemake Example]", ...)
end


local function separator(tab, title)
    tab:Divider({
        Title = title
    })
end


--==============================================================
-- 01. BUTTON
--==============================================================

local ButtonTab = Window:Tab({
    Title = "Button",
})

ButtonTab:Label({
    Title = "<b>Button</b> - Complete Method Test"
})

ButtonTab:Paragraph({
    Title = "Overview",
    Text = "Tests normal Button, Full Button, SetTitle(), custom Color, custom HighlightColor and Destroy()."
})


--------------------------------------------------------------
-- NORMAL BUTTON
--------------------------------------------------------------

local NormalButton = ButtonTab:Button({
    Title = "Normal Button",
    Callback = function()
        safePrint("Normal Button callback")
    end,
})


--------------------------------------------------------------
-- SET TITLE
--------------------------------------------------------------

ButtonTab:Button({
    Title = "Button:SetTitle()",
    Callback = function()
        NormalButton:SetTitle(
            "Renamed Button"
        )
    end,
})


--------------------------------------------------------------
-- FULL BUTTON
--------------------------------------------------------------

ButtonTab:Button({
    Title = "Full Width Button",
    Type = "Full",
    Callback = function()
        safePrint("Full Button callback")
    end,
})


--------------------------------------------------------------
-- CUSTOM COLOR
--------------------------------------------------------------

ButtonTab:Button({
    Title = "Custom Red",
    Color = Color3.fromRGB(180, 50, 50),
    HighlightColor = Color3.fromRGB(220, 70, 70),

    Callback = function()
        safePrint("Custom red clicked")
    end,
})


ButtonTab:Button({
    Title = "Custom Green",
    Color = Color3.fromRGB(45, 170, 90),
    HighlightColor = Color3.fromRGB(60, 200, 110),

    Callback = function()
        safePrint("Custom green clicked")
    end,
})


--------------------------------------------------------------
-- DESTROY BUTTON
--------------------------------------------------------------

local DestroyTestButton = ButtonTab:Button({
    Title = "Destroy Me",
})

ButtonTab:Button({
    Title = "Button:Destroy()",
    Callback = function()
        DestroyTestButton:Destroy()
    end,
})


--==============================================================
-- 02. TOGGLE
--==============================================================

local ToggleTab = Window:Tab({
    Title = "Toggle",
})

ToggleTab:Label({
    Title = "<b>Toggle</b> - Complete Method Test"
})

ToggleTab:Paragraph({
    Title = "Overview",
    Text = "Tests Toggle creation, callback, title update and destruction."
})


local TestToggle = ToggleTab:Toggle({
    Title = "Test Toggle",
    Callback = function(value)
        safePrint("Toggle value:", value)
    end,
})


ToggleTab:Button({
    Title = "Toggle:SetTitle()",
    Callback = function()
        TestToggle:SetTitle(
            "Renamed Toggle"
        )
    end,
})


ToggleTab:Button({
    Title = "Toggle:SetValue(true)",
    Callback = function()
        TestToggle:State(true)
    end,
})


ToggleTab:Button({
    Title = "Toggle:SetValue(false)",
    Callback = function()
        TestToggle:State(false)
    end,
})


local DestroyToggle = ToggleTab:Toggle({
    Title = "Destroy Test Toggle"
})


ToggleTab:Button({
    Title = "Toggle:Destroy()",
    Callback = function()
        DestroyToggle:Destroy()
    end,
})


--==============================================================
-- 03. SLIDER
--==============================================================

local SliderTab = Window:Tab({
    Title = "Slider",
})

SliderTab:Label({
    Title = "<b>Slider</b> - Complete Method Test"
})

SliderTab:Paragraph({
    Title = "Numeric Slider",
    Text = "Tests negative values, decimal values, Format, SetValue(), SetMin(), SetMax(), SetFormat(), SetTitle(), Drag, SetDrag() and Destroy()."
})

--------------------------------------------------------------
-- BASIC SLIDER
--------------------------------------------------------------

local TestSlider = SliderTab:Slider({
    Title = "Value",
    Min = -100,
    Max = 100,
    Step = 1,
    Value = 25,
    Format = "{value}",
    Drag = true,

    Callback = function(value)
        safePrint("Slider value:", value)
    end,
})

--------------------------------------------------------------
-- SET VALUE
--------------------------------------------------------------

SliderTab:Button({
    Title = "Slider:SetValue(-50)",
    Callback = function()
        TestSlider:SetValue(-50)
    end,
})

SliderTab:Button({
    Title = "Slider:SetValue(100)",
    Callback = function()
        TestSlider:SetValue(100)
    end,
})

--------------------------------------------------------------
-- FORMAT
--------------------------------------------------------------

SliderTab:Button({
    Title = "Slider:SetFormat()",
    Callback = function()
        TestSlider:SetFormat("{value} Y")
    end,
})

SliderTab:Button({
    Title = "Slider:SetFormat(Stud)",
    Callback = function()
        TestSlider:SetFormat("{value} Stud")
    end,
})

SliderTab:Button({
    Title = "Slider:SetFormat(Percent)",
    Callback = function()
        TestSlider:SetFormat("{value}%")
    end,
})

SliderTab:Button({
    Title = "Slider:SetFormat(Default)",
    Callback = function()
        TestSlider:SetFormat("{value}")
    end,
})

--------------------------------------------------------------
-- TITLE
--------------------------------------------------------------

SliderTab:Button({
    Title = "Slider:SetTitle()",
    Callback = function()
        TestSlider:SetTitle("Height")
    end,
})

SliderTab:Button({
    Title = "Slider:SetTitle(nil)",
    Callback = function()
        TestSlider:SetTitle(nil)
    end,
})

--------------------------------------------------------------
-- DRAG
--------------------------------------------------------------

SliderTab:Button({
    Title = "Slider:SetDrag(false)",
    Callback = function()
        TestSlider:SetDrag(false)
    end,
})

SliderTab:Button({
    Title = "Slider:SetDrag(true)",
    Callback = function()
        TestSlider:SetDrag(true)
    end,
})

--------------------------------------------------------------
-- MIN / MAX
--------------------------------------------------------------

SliderTab:Button({
    Title = "Slider:SetMin(-250)",
    Callback = function()
        TestSlider:SetMin(-250)
    end,
})

SliderTab:Button({
    Title = "Slider:SetMax(250)",
    Callback = function()
        TestSlider:SetMax(250)
    end,
})

--------------------------------------------------------------
-- DECIMAL SLIDER
--------------------------------------------------------------

SliderTab:Slider({
    Title = "Decimal",
    Min = 0,
    Max = 10,
    Step = 0.1,
    Value = 2.5,
    Format = "{value} Stud",
    Drag = true,
})

--------------------------------------------------------------
-- TITLE OPTIONAL
--------------------------------------------------------------

SliderTab:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = 125,
    Format = "{value}",
    Drag = true,
})

--------------------------------------------------------------
-- PROGRESS BAR TEST
--------------------------------------------------------------

separator(
    SliderTab,
    "Progress Bar"
)

SliderTab:Paragraph({
    Title = "Drag = false",
    Text = "When Drag is false, the Slider becomes a non-interactive progress bar. SetValue() can still update it normally."
})

local ProgressBar = SliderTab:Slider({
    Title = "Progress",
    Min = 0,
    Max = 100,
    Step = 1,
    Value = 65,
    Format = "{value}%",
    Drag = false,
})

--------------------------------------------------------------
-- PROGRESS BAR VALUE
--------------------------------------------------------------

SliderTab:Button({
    Title = "Progress:SetValue(25)",
    Callback = function()
        ProgressBar:SetValue(25)
    end,
})

SliderTab:Button({
    Title = "Progress:SetValue(50)",
    Callback = function()
        ProgressBar:SetValue(50)
    end,
})

SliderTab:Button({
    Title = "Progress:SetValue(75)",
    Callback = function()
        ProgressBar:SetValue(75)
    end,
})

SliderTab:Button({
    Title = "Progress:SetValue(100)",
    Callback = function()
        ProgressBar:SetValue(100)
    end,
})

--------------------------------------------------------------
-- SWITCH PROGRESS -> SLIDER
--------------------------------------------------------------

SliderTab:Button({
    Title = "Progress:SetDrag(true)",
    Callback = function()
        ProgressBar:SetDrag(true)
    end,
})

--------------------------------------------------------------
-- SWITCH SLIDER -> PROGRESS
--------------------------------------------------------------

SliderTab:Button({
    Title = "Progress:SetDrag(false)",
    Callback = function()
        ProgressBar:SetDrag(false)
    end,
})

--------------------------------------------------------------
-- AUDIO / VIDEO STYLE PROGRESS BAR
--------------------------------------------------------------

separator(
    SliderTab,
    "Media Progress Test"
)

local MediaProgress = SliderTab:Slider({
    Title = "Media",
    Min = 0,
    Max = 215,
    Step = 1,
    Value = 102,
    Format = "{value}",
    Drag = false,
})

SliderTab:Button({
    Title = "Media:SetValue(0)",
    Callback = function()
        MediaProgress:SetValue(0)
    end,
})

SliderTab:Button({
    Title = "Media:SetValue(60)",
    Callback = function()
        MediaProgress:SetValue(60)
    end,
})

SliderTab:Button({
    Title = "Media:SetValue(120)",
    Callback = function()
        MediaProgress:SetValue(120)
    end,
})

SliderTab:Button({
    Title = "Media:SetValue(215)",
    Callback = function()
        MediaProgress:SetValue(215)
    end,
})

--------------------------------------------------------------
-- MEDIA DRAG ENABLE / DISABLE
--------------------------------------------------------------

SliderTab:Button({
    Title = "Media:SetDrag(true)",
    Callback = function()
        MediaProgress:SetDrag(true)
    end,
})

SliderTab:Button({
    Title = "Media:SetDrag(false)",
    Callback = function()
        MediaProgress:SetDrag(false)
    end,
})

--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroySlider = SliderTab:Slider({
    Title = "Destroy Test",
    Min = 0,
    Max = 10,
    Drag = true,
})

SliderTab:Button({
    Title = "Slider:Destroy()",
    Callback = function()
        DestroySlider:Destroy()
    end,
})

--------------------------------------------------------------
-- RGB COMPOSITION TEST
-- Row + 3 Slider + Color
--------------------------------------------------------------

separator(
    SliderTab,
    "RGB Color Picker"
)

local InitialColor =
    Color3.fromRGB(
        40,
        90,
        175
    )

local PreviewColor = SliderTab:Color({
    Title = "Preview",
    Color = InitialColor,
})

local RGBRow = SliderTab:Row()

local RedSlider
local GreenSlider
local BlueSlider

local function updateRGB()

    if not RedSlider
        or not GreenSlider
        or not BlueSlider then
        return
    end

    PreviewColor:SetColor(
        Color3.fromRGB(
            RedSlider.Value,
            GreenSlider.Value,
            BlueSlider.Value
        )
    )
end

RedSlider = RGBRow:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = math.floor(
        InitialColor.R * 255 + 0.5
    ),
    Format = "R: {value}",
    Drag = true,
    Callback = updateRGB,
})

GreenSlider = RGBRow:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = math.floor(
        InitialColor.G * 255 + 0.5
    ),
    Format = "G: {value}",
    Drag = true,
    Callback = updateRGB,
})

BlueSlider = RGBRow:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = math.floor(
        InitialColor.B * 255 + 0.5
    ),
    Format = "B: {value}",
    Drag = true,
    Callback = updateRGB,
})

--------------------------------------------------------------
-- LOOPED PROGRESS BAR
--------------------------------------------------------------

separator(
    SliderTab,
    "Looped Progress Bar"
)

local LoopedProgressBar = SliderTab:Slider({
    Title = "Loading",
    Min = 0,
    Max = 100,
    Step = 1,
    Value = 0,
    Format = "{value}%",
    Drag = false,
})

local RunService = game:GetService("RunService")
local LoopDuration = 5
local LoopStart = os.clock()

RunService.Heartbeat:Connect(function()
    if not LoopedProgressBar
        or LoopedProgressBar.Destroyed then
        return
    end

    local elapsed =
        os.clock() - LoopStart

    local progress =
        (elapsed % LoopDuration)
        / LoopDuration
        * 100

    LoopedProgressBar:SetValue(
        progress,
        false
    )
end)

--==============================================================
-- 04. DROPDOWN
--==============================================================

local DropdownTab = Window:Tab({
    Title = "Dropdown",
})

DropdownTab:Label({
    Title = "<b>Dropdown</b> - Complete Method Test"
})


DropdownTab:Paragraph({
    Title = "Dropdown API",
    Text = "Tests Selected, Multi, SetOpen(), SetTitle(), Add(), Delete(), Refresh(), Refesh(), GetSelected(), SetFont(), UpdateTheme() and Destroy()."
})


--------------------------------------------------------------
-- SELECTED / HIGHLIGHT TEST
--------------------------------------------------------------

local TestDropdown = DropdownTab:Dropdown({
    Title = "Fruit",
    Value = {
        "Apple",
        "Banana",
        "Orange",
        "Mango",
    },

    Selected = {
        "Apple",
    },

    Callback = function(
        selected,
        clicked
    )

        safePrint(
            "Selected:",
            table.concat(
                selected,
                ", "
            ),
            "Clicked:",
            tostring(clicked)
        )
    end,
})


--------------------------------------------------------------
-- SET OPEN
--------------------------------------------------------------

DropdownTab:Button({
    Title = "Dropdown:SetOpen(true)",
    Callback = function()
        TestDropdown:SetOpen(true)
    end,
})


DropdownTab:Button({
    Title = "Dropdown:SetOpen(false)",
    Callback = function()
        TestDropdown:SetOpen(false)
    end,
})


--------------------------------------------------------------
-- SET TITLE
--------------------------------------------------------------

DropdownTab:Button({
    Title = "Dropdown:SetTitle()",
    Callback = function()
        TestDropdown:SetTitle(
            "Fruit List"
        )
    end,
})


DropdownTab:Button({
    Title = "Dropdown:SetTitle(nil)",
    Callback = function()
        TestDropdown:SetTitle(nil)
    end,
})


--------------------------------------------------------------
-- ADD
--------------------------------------------------------------

DropdownTab:Button({
    Title = "Dropdown:Add(single)",
    Callback = function()
        TestDropdown:Add(
            "Watermelon"
        )
    end,
})


DropdownTab:Button({
    Title = "Dropdown:Add(table)",
    Callback = function()
        TestDropdown:Add({
            "Pear",
            "Peach",
            "Lemon",
        })
    end,
})


--------------------------------------------------------------
-- DELETE
--------------------------------------------------------------

DropdownTab:Button({
    Title = "Dropdown:Delete()",
    Callback = function()
        TestDropdown:Delete(
            "Banana"
        )
    end,
})


--------------------------------------------------------------
-- REFRESH
--------------------------------------------------------------

DropdownTab:Button({
    Title = "Dropdown:Refresh()",
    Callback = function()

        TestDropdown:Refresh({
            "One",
            "Two",
            "Three",
            "Four",
        })
    end,
})


DropdownTab:Button({
    Title = "Dropdown:Refesh() Alias",
    Callback = function()

        TestDropdown:Refesh({
            "A",
            "B",
            "C",
        })
    end,
})


--------------------------------------------------------------
-- GET SELECTED
--------------------------------------------------------------

DropdownTab:Button({
    Title = "Dropdown:GetSelected()",
    Callback = function()

        local values =
            TestDropdown:GetSelected()

        safePrint(
            "GetSelected:",
            table.concat(
                values,
                ", "
            )
        )
    end,
})


--------------------------------------------------------------
-- MULTI SELECT
--------------------------------------------------------------

DropdownTab:Dropdown({
    Title = "Multi Select",
    Multi = true,

    Value = {
        "Red",
        "Green",
        "Blue",
        "Yellow",
    },

    Selected = {
        "Red",
        "Blue",
    },

    Callback = function(selected)
        safePrint(
            "Multi selected:",
            table.concat(
                selected,
                ", "
            )
        )
    end,
})


--------------------------------------------------------------
-- OPTIONAL TITLE
--------------------------------------------------------------

DropdownTab:Dropdown({
    Value = {
        "Option A",
        "Option B",
        "Option C",
    },

    Selected = "Option B",
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyDropdown =
    DropdownTab:Dropdown({
        Title = "Destroy Test",
        Value = {
            "A",
            "B",
        },
    })


DropdownTab:Button({
    Title = "Dropdown:Destroy()",
    Callback = function()
        DestroyDropdown:Destroy()
    end,
})


--==============================================================
-- 05. TEXTBOX
--==============================================================

local TextBoxTab = Window:Tab({
    Title = "TextBox",
})

TextBoxTab:Label({
    Title = "<b>TextBox</b> - Complete Method Test"
})


TextBoxTab:Paragraph({
    Title = "Roblox-style TextBox",
    Text = "Tests Text, Placeholder, ClearTextOnFocus, SetText(), Clear(), SetTitle(), SetPlaceholder(), SetClearTextOnFocus() and Destroy()."
})


local TestTextBox = TextBoxTab:TextBox({
    Title = "Username",
    Placeholder = "Enter username...",
    Text = "Clone",
    ClearTextOnFocus = false,

    Callback = function(text)
        safePrint(
            "TextBox:",
            text
        )
    end,
})


--------------------------------------------------------------
-- SET TEXT
--------------------------------------------------------------

TextBoxTab:Button({
    Title = "TextBox:SetText()",
    Callback = function()
        TestTextBox:SetText(
            "Hello from TextBox"
        )
    end,
})


--------------------------------------------------------------
-- CLEAR
--------------------------------------------------------------

TextBoxTab:Button({
    Title = "TextBox:Clear()",
    Callback = function()
        TestTextBox:Clear()
    end,
})


--------------------------------------------------------------
-- TITLE
--------------------------------------------------------------

TextBoxTab:Button({
    Title = "TextBox:SetTitle()",
    Callback = function()
        TestTextBox:SetTitle(
            "Player Name"
        )
    end,
})


TextBoxTab:Button({
    Title = "TextBox:SetTitle(nil)",
    Callback = function()
        TestTextBox:SetTitle(nil)
    end,
})


--------------------------------------------------------------
-- PLACEHOLDER
--------------------------------------------------------------

TextBoxTab:Button({
    Title = "TextBox:SetPlaceholder()",
    Callback = function()
        TestTextBox:SetPlaceholder(
            "New Placeholder"
        )
    end,
})


--------------------------------------------------------------
-- CLEAR ON FOCUS
--------------------------------------------------------------

TextBoxTab:Button({
    Title = "ClearTextOnFocus = true",
    Callback = function()
        TestTextBox:SetClearTextOnFocus(
            true
        )
    end,
})


TextBoxTab:Button({
    Title = "ClearTextOnFocus = false",
    Callback = function()
        TestTextBox:SetClearTextOnFocus(
            false
        )
    end,
})


--------------------------------------------------------------
-- TITLE OPTIONAL
--------------------------------------------------------------

TextBoxTab:TextBox({
    Placeholder = "No title TextBox",
    ClearTextOnFocus = true,
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyTextBox =
    TextBoxTab:TextBox({
        Title = "Destroy Test",
        Placeholder = "Destroy me",
    })


TextBoxTab:Button({
    Title = "TextBox:Destroy()",
    Callback = function()
        DestroyTextBox:Destroy()
    end,
})


--==============================================================
-- 06. PARAGRAPH
--==============================================================

local ParagraphTab = Window:Tab({
    Title = "Paragraph",
})

ParagraphTab:Label({
    Title = "<b>Paragraph</b> - Complete Method Test"
})


local TestParagraph =
    ParagraphTab:Paragraph({
        Title =
            '<font color="#55AAFF" size="18"><b>RichText Title</b></font>',

        Text =
            'This is <b>RichText</b> text with <font color="#55FF55">colors</font>.'
    })


--------------------------------------------------------------
-- SET TITLE
--------------------------------------------------------------

ParagraphTab:Button({
    Title = "Paragraph:SetTitle()",
    Callback = function()
        TestParagraph:SetTitle(
            '<font color="#FFAA55"><b>New Title</b></font>'
        )
    end,
})


--------------------------------------------------------------
-- SET TEXT
--------------------------------------------------------------

ParagraphTab:Button({
    Title = "Paragraph:SetText()",
    Callback = function()

        TestParagraph:SetText(
            '<font color="#55AAFF"><b>New RichText Content</b></font>\n'
            .. "The text automatically wraps and expands."
        )
    end,
})


--------------------------------------------------------------
-- TITLE ONLY
--------------------------------------------------------------

ParagraphTab:Paragraph({
    Title =
        '<font color="#FFAA55">Title Only Paragraph</font>',
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyParagraph =
    ParagraphTab:Paragraph({
        Title = "Destroy Test",
        Text = "Destroy me.",
    })


ParagraphTab:Button({
    Title = "Paragraph:Destroy()",
    Callback = function()
        DestroyParagraph:Destroy()
    end,
})


--==============================================================
-- 07. LABEL
--==============================================================

local LabelTab = Window:Tab({
    Title = "Label",
})

LabelTab:Label({
    Title = "<b>Label</b> - Complete Method Test"
})


local TestLabel =
    LabelTab:Label({
        Title = "Original Label",
    })


LabelTab:Button({
    Title = "Label:SetTitle()",
    Callback = function()
        TestLabel:SetTitle(
            '<font color="#55AAFF"><b>Updated Label</b></font>'
        )
    end,
})


local DestroyLabel =
    LabelTab:Label({
        Title = "Destroy Test",
    })


LabelTab:Button({
    Title = "Label:Destroy()",
    Callback = function()
        DestroyLabel:Destroy()
    end,
})

--------------------------------------------------------------
-- LIVE TIME LABEL
--------------------------------------------------------------

local TimeLabel = LabelTab:Label({
    Title = "Time: --:--:--",
})

local RunService = game:GetService("RunService")
local LastUpdate = 0

RunService.Heartbeat:Connect(function()
    local now = os.clock()

    if now - LastUpdate < 1 then
        return
    end

    LastUpdate = now

    if not TimeLabel
        or TimeLabel.Destroyed then
        return
    end

    TimeLabel:SetTitle(
        "Time: "
            .. os.date("%H:%M:%S")
    )
end)

--==============================================================
-- 08. DIVIDER
--==============================================================

local DividerTab = Window:Tab({
    Title = "Divider",
})

DividerTab:Label({
    Title = "<b>Divider</b> - Complete Method Test"
})


DividerTab:Divider()


DividerTab:Label({
    Title = "Element Above",
})


local TestDivider =
    DividerTab:Divider({
        Title = "Original Divider",
    })


DividerTab:Label({
    Title = "Element Below",
})


--------------------------------------------------------------
-- SET TITLE
--------------------------------------------------------------

DividerTab:Button({
    Title = "Divider:SetTitle()",
    Callback = function()
        TestDivider:SetTitle(
            "Updated Divider"
        )
    end,
})


DividerTab:Button({
    Title = "Divider:SetTitle(nil)",
    Callback = function()
        TestDivider:SetTitle(nil)
    end,
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyDivider =
    DividerTab:Divider({
        Title = "Destroy Test",
    })


DividerTab:Button({
    Title = "Divider:Destroy()",
    Callback = function()
        DestroyDivider:Destroy()
    end,
})


--==============================================================
-- 09. COLOR
--==============================================================

local ColorTab = Window:Tab({
    Title = "Color",
})

ColorTab:Label({
    Title = "<b>Color</b> - Complete Method Test"
})


local TestColor =
    ColorTab:Color({
        Title = "Preview",
        Color = Color3.fromRGB(
            40,
            90,
            175
        ),
    })


--------------------------------------------------------------
-- SET COLOR
--------------------------------------------------------------

ColorTab:Button({
    Title = "Color:SetColor(Red)",
    Callback = function()

        TestColor:SetColor(
            Color3.fromRGB(
                255,
                70,
                70
            )
        )
    end,
})


ColorTab:Button({
    Title = "Color:SetColor(Green)",
    Callback = function()

        TestColor:SetColor(
            Color3.fromRGB(
                60,
                200,
                110
            )
        )
    end,
})


--------------------------------------------------------------
-- SET TITLE
--------------------------------------------------------------

ColorTab:Button({
    Title = "Color:SetTitle()",
    Callback = function()
        TestColor:SetTitle(
            "Updated Color"
        )
    end,
})


ColorTab:Button({
    Title = "Color:SetTitle(nil)",
    Callback = function()
        TestColor:SetTitle(nil)
    end,
})


--------------------------------------------------------------
-- NO TITLE COLOR
--------------------------------------------------------------

ColorTab:Color({
    Color = Color3.fromRGB(
        255,
        210,
        60
    ),
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyColor =
    ColorTab:Color({
        Title = "Destroy Test",
        Color = Color3.fromRGB(
            255,
            0,
            255
        ),
    })


ColorTab:Button({
    Title = "Color:Destroy()",
    Callback = function()
        DestroyColor:Destroy()
    end,
})


--==============================================================
-- 10. IMAGE
--==============================================================

local ImageTab = Window:Tab({
    Title = "Image",
})

ImageTab:Label({
    Title = "<b>Image</b> - Complete Method Test"
})


local TestImage =
    ImageTab:Image({
        Image =
            "rbxassetid://137021248562867",

        Size =
            UDim2.new(
                0,
                150,
                0,
                150
            ),
})


ImageTab:Button({
    Title = "Image:SetImage() - JPG",
    Callback = function()

        TestImage:SetImage(
            "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/rickroll.jpg"
        )
    end,
})


ImageTab:Button({
    Title = "Image:SetImage() - PNG",
    Callback = function()

        TestImage:SetImage(
            "https://raw.githubusercontent.com/Altis-DEV/File/refs/heads/main/Kaguya_converted.png"
        )
    end,
})


ImageTab:Button({
    Title = "Image:SetImage() - Asset",
    Callback = function()

        TestImage:SetImage(
            "rbxassetid://137021248562867"
        )
    end,
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyImage =
    ImageTab:Image({
        Image =
            "rbxassetid://137021248562867",

        Size =
            UDim2.new(
                0,
                100,
                0,
                100
            ),
    })


ImageTab:Button({
    Title = "Image:Destroy()",
    Callback = function()
        DestroyImage:Destroy()
    end,
})


--==============================================================
-- 11. SECTION
--==============================================================

local SectionTab = Window:Tab({
    Title = "Section",
})

SectionTab:Label({
    Title = "<b>Section</b> - Complete Method Test"
})


--------------------------------------------------------------
-- OPEN SECTION
--------------------------------------------------------------

local TestSection =
    SectionTab:Section({
        Title = "Main Section",
        Open = false,
    })


TestSection:Label({
    Title = "Element inside Section",
})


TestSection:Button({
    Title = "Section Button",
})


--------------------------------------------------------------
-- OPEN
--------------------------------------------------------------

SectionTab:Button({
    Title = "Section:Open()",
    Callback = function()
        TestSection:Open()
    end,
})


--------------------------------------------------------------
-- CLOSE
--------------------------------------------------------------

SectionTab:Button({
    Title = "Section:Close()",
    Callback = function()
        TestSection:Close()
    end,
})


--------------------------------------------------------------
-- SET OPEN
--------------------------------------------------------------

SectionTab:Button({
    Title = "Section:SetOpen(true)",
    Callback = function()
        TestSection:SetOpen(true)
    end,
})


SectionTab:Button({
    Title = "Section:SetOpen(false)",
    Callback = function()
        TestSection:SetOpen(false)
    end,
})


--------------------------------------------------------------
-- TITLE
--------------------------------------------------------------

SectionTab:Button({
    Title = "Section:SetTitle()",
    Callback = function()
        TestSection:SetTitle(
            "Updated Section"
        )
    end,
})


--------------------------------------------------------------
-- NESTED SECTION
--------------------------------------------------------------

local Nested =
    TestSection:Section({
        Title = "Nested Section",
        Open = false,
    })


Nested:Label({
    Title = "Nested element"
})


Nested:Button({
    Title = "Nested Button",
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroySection =
    SectionTab:Section({
        Title = "Destroy Test",
        Open = true,
    })


DestroySection:Label({
    Title = "This section can be destroyed."
})


SectionTab:Button({
    Title = "Section:Destroy()",
    Callback = function()
        DestroySection:Destroy()
    end,
})


--==============================================================
-- 12. ROW
--==============================================================

--==============================================================
-- ROW TAB - MEGA TEST
--==============================================================

local RowTab = Window:Tab({
    Title = "Row",
})

RowTab:Label({
    Title = "<b>Row</b> - Mega Layout Test",
})

RowTab:Paragraph({
    Title = "Row System",
    Text = "This tab stress-tests equal cell sizing, mixed elements, optional titles, nested Rows, deep nesting, Row inside Section and Section inside Row.",
})

--==============================================================
-- 01. BASIC 2-WAY ROW
--==============================================================

separator(
    RowTab,
    "Basic 2-Way Row"
)

local BasicRow = RowTab:Row()

BasicRow:Button({
    Title = "Left",
})

BasicRow:Button({
    Title = "Right",
})

--==============================================================
-- 02. BASIC 3-WAY ROW
--==============================================================

separator(
    RowTab,
    "Basic 3-Way Row"
)

local ThreeRow = RowTab:Row()

ThreeRow:Button({
    Title = "One",
})

ThreeRow:Button({
    Title = "Two",
})

ThreeRow:Button({
    Title = "Three",
})

--==============================================================
-- 03. FOUR-WAY MIXED ROW
--==============================================================

separator(
    RowTab,
    "Four-Way Mixed Row"
)

local MixedRow = RowTab:Row()

MixedRow:Button({
    Title = "Button",
})

MixedRow:Toggle({
    Title = "Toggle",
})

MixedRow:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
    Format = "{value}%",
})

MixedRow:Color({
    Title = "Color",
    Color = Color3.fromRGB(
        80,
        160,
        240
    ),
})

--==============================================================
-- 04. OPTIONAL TITLE ROW
--==============================================================

separator(
    RowTab,
    "Optional Title Elements"
)

RowTab:Paragraph({
    Title = "No-title elements should fill their Row cell cleanly.",
})

local OptionalTitleRow = RowTab:Row()

OptionalTitleRow:Slider({
    Min = 0,
    Max = 100,
    Value = 25,
    Format = "{value}%",
})

OptionalTitleRow:Dropdown({
    Value = {
        "Option A",
        "Option B",
        "Option C",
    },
    Selected = "Option B",
})

OptionalTitleRow:TextBox({
    Placeholder = "Text input...",
})

--==============================================================
-- 05. TITLE + NO TITLE MIX
--==============================================================

separator(
    RowTab,
    "Title + No Title"
)

local TitleMixRow = RowTab:Row()

TitleMixRow:Slider({
    Title = "Volume",
    Min = 0,
    Max = 100,
    Value = 75,
    Format = "{value}%",
})

TitleMixRow:Slider({
    Min = 0,
    Max = 255,
    Value = 128,
    Format = "{value}",
})

TitleMixRow:TextBox({
    Title = "Name",
    Placeholder = "Player",
})

TitleMixRow:Dropdown({
    Value = {
        "Low",
        "Medium",
        "High",
    },
    Selected = "Medium",
})

--==============================================================
-- 06. FIVE-ELEMENT STRESS TEST
--==============================================================

separator(
    RowTab,
    "Five Element Stress Test"
)

local FiveRow = RowTab:Row()

FiveRow:Button({
    Title = "A",
})

FiveRow:Button({
    Title = "B",
})

FiveRow:Button({
    Title = "C",
})

FiveRow:Button({
    Title = "D",
})

FiveRow:Button({
    Title = "E",
})

--==============================================================
-- 07. NESTED ROW - 2 + 1
--==============================================================

separator(
    RowTab,
    "Nested Row - 2 + 1"
)

local ParentRow21 = RowTab:Row()

local ChildRow21 = ParentRow21:Row()

ChildRow21:Button({
    Title = "Small A",
})

ChildRow21:Button({
    Title = "Small B",
})

ParentRow21:Button({
    Title = "Large",
})

-- Expected:
-- Small A = 25%
-- Small B = 25%
-- Large   = 50%

--==============================================================
-- 08. NESTED ROW - 3 + 1
--==============================================================

separator(
    RowTab,
    "Nested Row - 3 + 1"
)

local ParentRow31 = RowTab:Row()

local ChildRow31 = ParentRow31:Row()

ChildRow31:Button({
    Title = "A",
})

ChildRow31:Button({
    Title = "B",
})

ChildRow31:Button({
    Title = "C",
})

ParentRow31:Button({
    Title = "Large",
})

-- Expected:
-- A = 16.66%
-- B = 16.66%
-- C = 16.66%
-- Large = 50%

--==============================================================
-- 09. NESTED ROW - 1 + 3
--==============================================================

separator(
    RowTab,
    "Nested Row - 1 + 3"
)

local ParentRow13 = RowTab:Row()

ParentRow13:Button({
    Title = "Large",
})

local ChildRow13 = ParentRow13:Row()

ChildRow13:Button({
    Title = "A",
})

ChildRow13:Button({
    Title = "B",
})

ChildRow13:Button({
    Title = "C",
})

--==============================================================
-- 10. DEEP NESTING
--==============================================================

separator(
    RowTab,
    "Deep Nested Row"
)

local Level1 = RowTab:Row()

local Level2 = Level1:Row()

local Level3 = Level2:Row()

Level3:Button({
    Title = "Level 3A",
})

Level3:Button({
    Title = "Level 3B",
})

Level2:Button({
    Title = "Level 2",
})

Level1:Button({
    Title = "Level 1",
})

--==============================================================
-- 11. NESTED MIXED ELEMENTS
--==============================================================

separator(
    RowTab,
    "Nested Mixed Elements"
)

local MixedParent = RowTab:Row()

local MixedChild = MixedParent:Row()

MixedChild:Slider({
    Min = 0,
    Max = 100,
    Value = 60,
    Format = "{value}%",
})

MixedChild:Dropdown({
    Value = {
        "A",
        "B",
        "C",
    },
    Selected = "A",
})

MixedParent:TextBox({
    Placeholder = "Large input",
})

--==============================================================
-- 12. ROW + COLOR RGB
--==============================================================

separator(
    RowTab,
    "Nested RGB Composition"
)

local RGBPreview =
    RowTab:Color({
        Title = "Preview",
        Color = Color3.fromRGB(
            40,
            90,
            175
        ),
    })

local RGBParent = RowTab:Row()

local RGBNested = RGBParent:Row()

local RGBRed
local RGBGreen
local RGBBlue

local function UpdateNestedRGB()
    if not RGBRed
        or not RGBGreen
        or not RGBBlue then
        return
    end

    RGBPreview:SetColor(
        Color3.fromRGB(
            RGBRed.Value,
            RGBGreen.Value,
            RGBBlue.Value
        )
    )
end

RGBRed = RGBNested:Slider({
    Min = 0,
    Max = 255,
    Value = 40,
    Format = "R:{value}",
    Callback = UpdateNestedRGB,
})

RGBGreen = RGBNested:Slider({
    Min = 0,
    Max = 255,
    Value = 90,
    Format = "G:{value}",
    Callback = UpdateNestedRGB,
})

RGBBlue = RGBNested:Slider({
    Min = 0,
    Max = 255,
    Value = 175,
    Format = "B:{value}",
    Callback = UpdateNestedRGB,
})

RGBParent:Button({
    Title = "Extra Element",
})

--==============================================================
-- 13. ROW INSIDE SECTION
--==============================================================

separator(
    RowTab,
    "Row Inside Section"
)

local RowSection = RowTab:Section({
    Title = "Section With Rows",
    Open = true,
})

local SectionRow1 =
    RowSection:Row()

SectionRow1:Button({
    Title = "A",
})

SectionRow1:Button({
    Title = "B",
})

SectionRow1:Button({
    Title = "C",
})

local SectionRow2 =
    RowSection:Row()

SectionRow2:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
    Format = "{value}%",
})

SectionRow2:Dropdown({
    Value = {
        "Normal",
        "Hard",
        "Extreme",
    },
    Selected = "Hard",
})

--==============================================================
-- 14. NESTED ROW INSIDE SECTION
--==============================================================

local SectionNestedRow =
    RowSection:Row()

local SectionDeepRow =
    SectionNestedRow:Row()

SectionDeepRow:Button({
    Title = "Deep A",
})

SectionDeepRow:Button({
    Title = "Deep B",
})

SectionNestedRow:Button({
    Title = "Section Element",
})

--==============================================================
-- 15. SECTION INSIDE ROW
--==============================================================

separator(
    RowTab,
    "Section Inside Row"
)

local SectionRowContainer =
    RowTab:Row()

local SmallSection =
    SectionRowContainer:Section({
        Title = "Small Section",
        Open = true,
    })

SmallSection:Button({
    Title = "Inside Section",
})

SectionRowContainer:Button({
    Title = "Outside Section",
})

--==============================================================
-- 16. MULTI-LEVEL SECTION + ROW
--==============================================================

separator(
    RowTab,
    "Complex Nested Layout"
)

local ComplexSection =
    RowTab:Section({
        Title = "Complex Layout",
        Open = true,
    })

local ComplexRow =
    ComplexSection:Row()

ComplexRow:Button({
    Title = "Button",
})

local ComplexNestedRow =
    ComplexRow:Row()

ComplexNestedRow:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
    Format = "{value}%",
})

ComplexNestedRow:TextBox({
    Placeholder = "Input",
})

local ComplexRow2 =
    ComplexSection:Row()

ComplexRow2:Dropdown({
    Value = {
        "One",
        "Two",
        "Three",
    },
    Selected = "Two",
})

ComplexRow2:Color({
    Title = "Color",
    Color = Color3.fromRGB(
        120,
        80,
        220
    ),
})

--==============================================================
-- 17. ROW FONT TEST
--==============================================================

separator(
    RowTab,
    "Row Font Propagation"
)

local FontTestRow =
    RowTab:Row()

local FontButton =
    FontTestRow:Button({
        Title = "Button",
    })

local FontSlider =
    FontTestRow:Slider({
        Min = 0,
        Max = 100,
        Value = 50,
    })

local FontDropdown =
    FontTestRow:Dropdown({
        Value = {
            "A",
            "B",
        },
        Selected = "A",
    })

local FontTextBox =
    FontTestRow:TextBox({
        Placeholder = "Text",
    })

RowTab:Button({
    Title = "Row:SetFont(RobotoMono)",
    Callback = function()
        FontTestRow:SetFont(
            Enum.Font.RobotoMono
        )
    end,
})

RowTab:Button({
    Title = "Row:SetFont(FredokaOne)",
    Callback = function()
        FontTestRow:SetFont(
            Enum.Font.FredokaOne
        )
    end,
})

--==============================================================
-- 18. ROW THEME TEST
--==============================================================

separator(
    RowTab,
    "Row Theme Propagation"
)

local ThemeTestRow =
    RowTab:Row()

ThemeTestRow:Button({
    Title = "Button",
})

ThemeTestRow:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
})

ThemeTestRow:Dropdown({
    Value = {
        "A",
        "B",
    },
    Selected = "A",
})

ThemeTestRow:TextBox({
    Placeholder = "Input",
})

RowTab:Button({
    Title = "Row:UpdateTheme(Current)",
    Callback = function()
        ThemeTestRow:UpdateTheme(
            Window.ThemeData
        )
    end,
})

--==============================================================
-- 19. METHOD TESTS INSIDE ROW
--==============================================================

separator(
    RowTab,
    "Element Methods Inside Row"
)

local MethodRow =
    RowTab:Row()

local MethodSlider =
    MethodRow:Slider({
        Min = 0,
        Max = 100,
        Value = 25,
        Format = "{value}%",
    })

local MethodDropdown =
    MethodRow:Dropdown({
        Value = {
            "One",
            "Two",
            "Three",
        },
        Selected = "One",
    })

local MethodTextBox =
    MethodRow:TextBox({
        Placeholder = "Original",
    })

RowTab:Button({
    Title = "SetValue(75)",
    Callback = function()
        MethodSlider:SetValue(
            75
        )
    end,
})

RowTab:Button({
    Title = "Dropdown:Add()",
    Callback = function()
        MethodDropdown:Add(
            "Four"
        )
    end,
})

RowTab:Button({
    Title = "TextBox:SetText()",
    Callback = function()
        MethodTextBox:SetText(
            "Updated"
        )
    end,
})

--==============================================================
-- 20. ROW DESTROY TEST
--==============================================================

separator(
    RowTab,
    "Destroy Test"
)

local DestroyRow =
    RowTab:Row()

DestroyRow:Button({
    Title = "A",
})

DestroyRow:Button({
    Title = "B",
})

DestroyRow:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
})

RowTab:Button({
    Title = "Row:Destroy()",
    Callback = function()
        DestroyRow:Destroy()
    end,
})

--==============================================================
-- 21. MANY ROWS STRESS TEST
--==============================================================

separator(
    RowTab,
    "Many Rows Stress Test"
)

for i = 1, 8 do

    local StressRow =
        RowTab:Row()

    StressRow:Button({
        Title = "Row " .. i .. " A",
    })

    StressRow:Button({
        Title = "Row " .. i .. " B",
    })

    StressRow:Button({
        Title = "Row " .. i .. " C",
    })

end

--==============================================================
-- 22. MEDIA STYLE ROW
--==============================================================

separator(
    RowTab,
    "Media Style Row"
)

local MediaRow =
    RowTab:Row()

MediaRow:Button({
    Title = "▶",
})

MediaRow:Slider({
    Min = 0,
    Max = 100,
    Value = 65,
    Format = "{value}%",
    Drag = false,
})

MediaRow:Label({
    Title = "01:42 / 03:35",
})

--==============================================================
-- 23. FINAL MEGA NEST
--==============================================================

separator(
    RowTab,
    "Final Mega Nest"
)

local MegaSection =
    RowTab:Section({
        Title = "Mega Section",
        Open = true,
    })

local MegaRow1 =
    MegaSection:Row()

MegaRow1:Button({
    Title = "Main",
})

local MegaRow2 =
    MegaRow1:Row()

MegaRow2:Button({
    Title = "Nested A",
})

local MegaRow3 =
    MegaRow2:Row()

MegaRow3:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
    Format = "{value}%",
})

MegaRow3:Color({
    Title = "Color",
    Color = Color3.fromRGB(
        80,
        160,
        240
    ),
})

MegaRow2:Dropdown({
    Value = {
        "Low",
        "Medium",
        "High",
    },
    Selected = "Medium",
})

MegaRow1:TextBox({
    Placeholder = "Main input",
})

--==============================================================
-- END
--==============================================================

RowTab:Paragraph({
    Title = "Mega Row Test Complete",
    Text = "The Row tab now tests equal-width cells, optional-title controls, nested Rows, nested Sections, deep nesting, method propagation, theme/font propagation, destruction and stress layouts.",
})

--==============================================================
-- 13. TEXT INPUT
--==============================================================

local TextInputTab = Window:Tab({
    Title = "TextInput",
})

TextInputTab:Label({
    Title = "<b>TextInput</b> - Complete Method Test"
})


TextInputTab:Paragraph({
    Title = "Multiline Editor",
    Text = "Tests SetText(), Clear(), automatic vertical growth and scrolling."
})


local Editor =
    TextInputTab:TextInput({
        Size =
            UDim2.new(
                1,
                -12,
                0,
                220
            ),

        Text =
            "Line 1\nLine 2\nLine 3",
        Placeholder = 
            "Write something here...",
        ClearTextOnFocus = true,
    })


--------------------------------------------------------------
-- SET TEXT
--------------------------------------------------------------

TextInputTab:Button({
    Title = "TextInput:SetText()",
    Callback = function()

        Editor:SetText(
            "New text\n"
            .. "Second line\n"
            .. "Third line\n"
            .. "Fourth line\n"
            .. "Fifth line"
        )
    end,
})


--------------------------------------------------------------
-- CLEAR
--------------------------------------------------------------

TextInputTab:Button({
    Title = "TextInput:Clear()",
    Callback = function()
        Editor:Clear()
    end,
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyEditor =
    TextInputTab:TextInput({
        Size =
            UDim2.new(
                1,
                -12,
                0,
                100
            ),

        Text =
            "Destroy me.",
        Placeholder = 
            "Write something here...",
        ClearTextOnFocus = true,
    })


TextInputTab:Button({
    Title = "TextInput:Destroy()",
    Callback = function()
        DestroyEditor:Destroy()
    end,
})


--==============================================================
-- 14. CONSOLE
--==============================================================

local ConsoleTab = Window:Tab({
    Title = "Console",
})

ConsoleTab:Label({
    Title = "<b>Console</b> - Complete Method Test"
})


local TestConsole =
    ConsoleTab:Console({
        Size =
            UDim2.new(
                1,
                -12,
                0,
                220
            ),

        MaxLog = 10,

        AutoScroll = true,

        Time = true,
    })


--------------------------------------------------------------
-- LOG
--------------------------------------------------------------

TestConsole:Log(
    "Console initialized."
)


TestConsole:Log(
    '<font color="#55AAFF"><b>Blue RichText log.</b></font>'
)


TestConsole:Log(
    '<font color="#55FF55">Green RichText log.</font>'
)


TestConsole:Log(
    '<font color="#FF5555"><b>Red RichText log.</b></font>'
)


--------------------------------------------------------------
-- MORE LOGS
--------------------------------------------------------------

ConsoleTab:Button({
    Title = "Console:Log()",
    Callback = function()

        TestConsole:Log(
            '<font color="#FFD75F"><b>New test log created.</b></font>'
        )
    end,
})


ConsoleTab:Button({
    Title = "Console:Log(Long)",
    Callback = function()

        TestConsole:Log(
            "This is a very long log message designed to test automatic wrapping, vertical growth and scrolling inside the Console element."
        )
    end,
})


--------------------------------------------------------------
-- CLEAR
--------------------------------------------------------------

ConsoleTab:Button({
    Title = "Console:Clear()",
    Callback = function()
        TestConsole:Clear()
    end,
})


--------------------------------------------------------------
-- DESTROY
--------------------------------------------------------------

local DestroyConsole =
    ConsoleTab:Console({
        Size =
            UDim2.new(
                1,
                -12,
                0,
                100
            ),

        MaxLog = 5,

        AutoScroll = false,

        Time = false,
    })


DestroyConsole:Log(
    "Destroy test console."
)


ConsoleTab:Button({
    Title = "Console:Destroy()",
    Callback = function()
        DestroyConsole:Destroy()
    end,
})


--==============================================================
-- 15. COLOR PREVIEW / RGB COMPOSITION
--==============================================================

local CompositionTab = Window:Tab({
    Title = "Composition",
})

CompositionTab:Label({
    Title = "<b>Composition</b>"
})


CompositionTab:Paragraph({
    Title = "Element Composition",
    Text = "This tab demonstrates how simple ImGui elements can be combined to create more advanced controls without a dedicated element module."
})


local CompositionPreview =
    CompositionTab:Color({
        Title = "RGB Preview",
        Color = Color3.fromRGB(
            120,
            80,
            220
        ),
    })


local CompositionRow =
    CompositionTab:Row()


local CR
local CG
local CB


local function updateCompositionColor()

    CompositionPreview:SetColor(
        Color3.fromRGB(
            CR.Value,
            CG.Value,
            CB.Value
        )
    )
end


CR = CompositionRow:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = 120,
    Format = "R: {value}",
    Callback = updateCompositionColor,
})


CG = CompositionRow:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = 80,
    Format = "G: {value}",
    Callback = updateCompositionColor,
})


CB = CompositionRow:Slider({
    Min = 0,
    Max = 255,
    Step = 1,
    Value = 220,
    Format = "B: {value}",
    Callback = updateCompositionColor,
})


--==============================================================
-- 16. MODAL
--==============================================================

local ModalTab = Window:Tab({
    Title = "Modal",
})

ModalTab:Label({
    Title = "<b>Modal</b> - Complete Test"
})


ModalTab:Paragraph({
    Title = "Modal Tests",
    Text = "Tests normal Modal, long RichText Modal, custom button colors and Window:Destroy()."
})


--------------------------------------------------------------
-- NORMAL MODAL
--------------------------------------------------------------

local function createNormalModal()

    local Modal

    Modal =
        ModalTab:Modal({
            Title =
                "<b>Normal Modal</b>",

            Text =
                "This is a normal modal used to test basic layout and UIScale animation.",

            Buttons = {
                {
                    Title = "Cancel",

                    Callback = function()
                        safePrint(
                            "Normal Modal: Cancel"
                        )

                        Modal:Close()
                    end,
                },

                {
                    Title = "Confirm",

                    Callback = function()
                        safePrint(
                            "Normal Modal: Confirm"
                        )

                        Modal:Close()
                    end,
                },
            },
        })
end


ModalTab:Button({
    Title = "Open Normal Modal",
    Type = "Full",
    Callback = createNormalModal,
})


--------------------------------------------------------------
-- LONG MODAL
--------------------------------------------------------------

local function createLongModal()

    local Modal

    Modal =
        ModalTab:Modal({
            Title =
                '<font color="#55AAFF" size="20"><b>Extremely Long Modal Title</b></font>',

            Text =
                '<font color="#FFFFFF">This is a very long Modal text designed to test automatic wrapping and dynamic TextFrame expansion. '
                .. "The button frame should remain underneath the text, and the entire modal should remain centered on the screen.</font>\n\n"
                .. '<font color="#55FF55"><b>RichText section.</b></font>\n\n'
                .. '<font color="#FFD75F">Another long section to make the modal taller.</font>',

            Buttons = {
                {
                    Title = "Close",

                    Callback = function()
                        Modal:Close()
                    end,
                },

                {
                    Title = "Continue",

                    Color =
                        Color3.fromRGB(
                            45,
                            170,
                            90
                        ),

                    HighlightColor =
                        Color3.fromRGB(
                            60,
                            200,
                            110
                        ),

                    Callback = function()
                        safePrint(
                            "Long Modal Continue"
                        )

                        Modal:Close()
                    end,
                },
            },
        })
end


ModalTab:Button({
    Title = "Open Long Modal",
    Type = "Full",
    Callback = createLongModal,
})


--------------------------------------------------------------
-- DESTROY WINDOW MODAL
--------------------------------------------------------------

local function createDestroyModal()

    local Modal

    Modal =
        ModalTab:Modal({
            Title =
                '<font color="#FF5555" size="18"><b>Destroy Window</b></font>',

            Text =
                "Do You Want To Destroy The Window?",

            Buttons = {
                {
                    Title = "No",

                    Callback = function()
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

    Callback = createDestroyModal,
})


--==============================================================
-- 17. WINDOW
--==============================================================

local WindowTab = Window:Tab({
    Title = "Window",
})

WindowTab:Label({
    Title = "<b>Window</b> - Complete API Test"
})


WindowTab:Paragraph({
    Title = "Window Methods",
    Text = "Tests title, visibility, position, size, center, open/close, focus, theme and multi-window behavior."
})


--------------------------------------------------------------
-- SET TITLE
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:SetTitle()",
    Callback = function()
        Window:SetTitle(
            "Renamed ImGuiRemake Window"
        )
    end,
})


--------------------------------------------------------------
-- CENTER
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:Center()",
    Callback = function()
        Window:Center()
    end,
})


--------------------------------------------------------------
-- GET SIZE
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:GetSize()",
    Callback = function()

        local size =
            Window:GetSize()

        if size then
            safePrint(
                "Window Size:",
                size.X.Offset,
                size.Y.Offset
            )
        end
    end,
})


--------------------------------------------------------------
-- GET POSITION
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:GetPosition()",
    Callback = function()

        local position =
            Window:GetPosition()

        if position then
            safePrint(
                "Window Position:",
                position.X.Offset,
                position.Y.Offset
            )
        end
    end,
})


--------------------------------------------------------------
-- VISIBILITY
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:SetVisible(false)",
    Callback = function()
        Window:SetVisible(false)
    end,
})


WindowTab:Button({
    Title = "Window:SetVisible(true)",
    Callback = function()
        Window:SetVisible(true)
        Window:Focus()
    end,
})


--------------------------------------------------------------
-- IS VISIBLE
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:IsVisible()",
    Callback = function()

        safePrint(
            "IsVisible:",
            Window:IsVisible()
        )
    end,
})


--------------------------------------------------------------
-- IS OPEN
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:IsOpen()",
    Callback = function()

        safePrint(
            "IsOpen:",
            Window:IsOpen()
        )
    end,
})


--------------------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:Close()",
    Callback = function()
        Window:Close()
    end,
})


WindowTab:Button({
    Title = "Window:Open()",
    Callback = function()
        Window:Open()
    end,
})


--------------------------------------------------------------
-- FOCUS
--------------------------------------------------------------

WindowTab:Button({
    Title = "Window:Focus()",
    Callback = function()
        Window:Focus()
    end,
})


WindowTab:Button({
    Title = "Window:BringToFront()",
    Callback = function()
        Window:BringToFront()
    end,
})


--==============================================================
-- 18. MULTI WINDOW
--==============================================================

separator(
    WindowTab,
    "Multi Window Test"
)


WindowTab:Button({
    Title = "Create Second Window",
    Callback = function()

        local SecondWindow =
            ImGui:CreateWindow({
                Title = "Second Window",

                Size =
                    UDim2.new(
                        0,
                        450,
                        0,
                        350
                    ),

                MinSize =
                    Vector2.new(
                        300,
                        250
                    ),

                MaxSize =
                    Vector2.new(
                        900,
                        700
                    ),
            })


        local SecondTab =
            SecondWindow:Tab({
                Title = "Test",
            })


        SecondTab:Label({
            Title =
                "<b>Second Window</b>",
        })


        SecondTab:Paragraph({
            Title = "Multi Window",
            Text = "Click this window to bring it to the front.",
        })


        SecondTab:Button({
            Title = "Focus",
            Callback = function()
                SecondWindow:Focus()
            end,
        })


        SecondTab:Button({
            Title = "Close",
            Callback = function()
                SecondWindow:Close()
            end,
        })


        SecondTab:Button({
            Title = "Destroy",
            Callback = function()
                SecondWindow:Destroy()
            end,
        })
    end,
})


--==============================================================
-- 19. FONT TEST
--==============================================================

local FontTab = Window:Tab({
    Title = "Font",
})

FontTab:Label({
    Title = "<b>Font Propagation</b>"
})


FontTab:Paragraph({
    Title = "All Element Fonts",
    Text = "Changing the Window font should propagate through Tabs, Sections, Rows and nested elements."
})


FontTab:Button({
    Title = "RobotoMono",
    Callback = function()
        Window:SetFont(
            Enum.Font.RobotoMono
        )
    end,
})


FontTab:Button({
    Title = "FredokaOne",
    Callback = function()
        Window:SetFont(
            Enum.Font.FredokaOne
        )
    end,
})


--==============================================================
-- 20. THEME TEST
--==============================================================

local ThemeTab = Window:Tab({
    Title = "Theme",
})

ThemeTab:Label({
    Title = "<b>Theme Propagation</b>"
})


ThemeTab:Paragraph({
    Title = "Theme",
    Text = "This tab exists to verify that theme changes propagate to every currently existing element."
})

ThemeTab:Divider({
    Title = "Available Themes",
})

ThemeTab:Button({
    Title = "Default",
    Type = "Full",
    Callback = function()
        Window:Theme("Default")
    end,
})

ThemeTab:Button({
    Title = "Snowy",
    Type = "Full",
    Callback = function()
        Window:Theme("Snowy")
    end,
})

ThemeTab:Button({
    Title = "Midnight",
    Type = "Full",
    Callback = function()
        Window:Theme("Midnight")
    end,
})

ThemeTab:Button({
    Title = "Sakura",
    Type = "Full",
    Callback = function()
        Window:Theme("Sakura")
    end,
})

ThemeTab:Button({
    Title = "Forest",
    Type = "Full",
    Callback = function()
        Window:Theme("Forest")
    end,
})

ThemeTab:Button({
    Title = "Ocean",
    Type = "Full",
    Callback = function()
        Window:Theme("Ocean")
    end,
})

ThemeTab:Button({
    Title = "Amethyst",
    Type = "Full",
    Callback = function()
        Window:Theme("Amethyst")
    end,
})

ThemeTab:Button({
    Title = "Volcanic",
    Type = "Full",
    Callback = function()
        Window:Theme("Volcanic")
    end,
})

ThemeTab:Button({
    Title = "Sunset",
    Type = "Full",
    Callback = function()
        Window:Theme("Sunset")
    end,
})

ThemeTab:Button({
    Title = "Matcha",
    Type = "Full",
    Callback = function()
        Window:Theme("Matcha")
    end,
})

ThemeTab:Button({
    Title = "Arctic",
    Type = "Full",
    Callback = function()
        Window:Theme("Arctic")
    end,
})

ThemeTab:Button({
    Title = "Void",
    Type = "Full",
    Callback = function()
        Window:Theme("Void")
    end,
})

ThemeTab:Button({
    Title = "Coffee",
    Type = "Full",
    Callback = function()
        Window:Theme("Coffee")
    end,
})


--==============================================================
-- 21. FINAL SECTION / NESTED COMPOSITION
--==============================================================

local FinalTab = Window:Tab({
    Title = "Final",
})


FinalTab:Label({
    Title =
        "<font color=\"#55AAFF\" size=\"18\"><b>Final Composition Test</b></font>"
})


FinalTab:Paragraph({
    Title = "Everything Together",
    Text = "This final section combines Section, Row, Slider, Dropdown, TextBox, Color, Button and nested layouts.",
})


local FinalSection =
    FinalTab:Section({
        Title = "Configuration",
        Open = true,
    })


FinalSection:Label({
    Title = "Visual Settings",
})


local FinalRow =
    FinalSection:Row()


FinalRow:Slider({
    Min = 0,
    Max = 100,
    Value = 75,
    Format = "Volume: {value}",
})


FinalRow:Slider({
    Min = 0,
    Max = 100,
    Value = 50,
    Format = "Opacity: {value}",
})


local FinalRow2 =
    FinalSection:Row()


FinalRow2:Dropdown({
    Value = {
        "Low",
        "Medium",
        "High",
    },

    Selected = "High",
})


FinalRow2:TextBox({
    Placeholder = "Configuration name",
})


local FinalNestedSection =
    FinalSection:Section({
        Title = "Advanced",
        Open = true,
    })


FinalNestedSection:Toggle({
    Title = "Advanced Mode",
})


FinalNestedSection:Color({
    Title = "Theme Color",
    Color = Color3.fromRGB(
        40,
        90,
        175
    ),
})


FinalNestedSection:Button({
    Title = "Apply",
    Type = "Full",
})


--==============================================================
-- FINISH
--==============================================================

safePrint(
    "Complete ImGuiRemake.lua example loaded."
)

safePrint(
    "All test tabs have been initialized."
)

safePrint(
    "Use this file as the public example.lua."
)