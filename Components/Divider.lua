-- File: ImGuiRemake.lua/Components/Divider.lua

local Divider = {}
Divider.__index = Divider

function Divider.new(tab, options)
    options = options or {}

    local self = setmetatable({}, Divider)

    self.Tab = tab
    self.Window = tab.Window
    self.Destroyed = false

    local theme = self.Window.ThemeData

    ------------------------------------------------------------
    -- DIVIDER
    ------------------------------------------------------------

    self.Instance = Instance.new("Frame")
    self.Instance.Name = "Divider"

    self.Instance.Size =
        UDim2.new(
            1,
            0,
            0,
            1
        )

    self.Instance.BackgroundColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)

    self.Instance.BorderSizePixel = 0

    self.Instance.Parent =
        self.Tab.ContentFrame

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
-- UPDATE THEME
------------------------------------------------------------

function Divider:UpdateTheme(theme)
    if self.Destroyed then
        return
    end

    self.Instance.BackgroundColor3 =
        theme.Border
        or Color3.fromRGB(60, 60, 60)
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Divider:Destroy()
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

return Divider
