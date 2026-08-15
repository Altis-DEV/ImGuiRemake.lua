-- File: ImGuiRemake.lua/Components/Viewport.lua

local Viewport = {}
Viewport.__index = Viewport

local UserInputService =
    game:GetService("UserInputService")

local RunService =
    game:GetService("RunService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local DEFAULT_SIZE =
    UDim2.new(
        1,
        -12,
        0,
        220
    )

local DEFAULT_DISTANCE = 8

local MIN_DISTANCE = 2
local MAX_DISTANCE = 30

local ROTATION_SPEED = 0.35
local ZOOM_SPEED = 1

local MOBILE_PINCH_SPEED = 0.02

local BACKGROUND_COLOR =
    Color3.fromRGB(
        20,
        20,
        20
    )

------------------------------------------------------------
-- INPUT HELPERS
------------------------------------------------------------

local function isMouseDragInput(input)

    return
        input.UserInputType
        == Enum.UserInputType.MouseButton1
end

local function isTouchInput(input)

    return
        input.UserInputType
        == Enum.UserInputType.Touch
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Viewport.new(
    tab,
    options
)

    options =
        options or {}

    local self =
        setmetatable(
            {},
            Viewport
        )

    --------------------------------------------------------
    -- BASIC
    --------------------------------------------------------

    self.Tab =
        tab

    self.Window =
        tab.Window

    self.WidthAtRow =
        options.WidthAtRow

    self.Size =
        options.Size
        or DEFAULT_SIZE

    self.Drag =
        options.Drag ~= false

    self.Zoom =
        options.Zoom ~= false

    self.Destroyed =
        false

    --------------------------------------------------------
    -- CAMERA STATE
    --------------------------------------------------------

    self.Distance =
        tonumber(
            options.Distance
        )
        or DEFAULT_DISTANCE

    self.Distance =
        math.clamp(
            self.Distance,
            MIN_DISTANCE,
            MAX_DISTANCE
        )

    self.Yaw =
        tonumber(
            options.Yaw
        )
        or 0

    self.Pitch =
        tonumber(
            options.Pitch
        )
        or -10

    self.Pitch =
        math.clamp(
            self.Pitch,
            -89,
            89
        )

    --------------------------------------------------------
    -- VIEWPORT TARGET
    --------------------------------------------------------

    self.ViewportObject =
        nil

    self.ViewportModel =
        nil

    --------------------------------------------------------
    -- INPUT STATE
    --------------------------------------------------------

    self.MouseDragging =
        false

    self.ActiveTouch =
        nil

    self.TouchStartPosition =
        nil

    self.TouchLastPosition =
        nil

    self.SecondTouch =
        nil

    self.SecondTouchLastPosition =
        nil

    self.LastPinchDistance =
        nil

    --------------------------------------------------------
    -- THEME
    --------------------------------------------------------

    local theme =
        self.Window.ThemeData

    --------------------------------------------------------
    -- CONTAINER
    --------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        "Viewport"

    self.Container.Size =
        self.Size

    self.Container.BackgroundTransparency =
        0

    self.Container.BackgroundColor3 =
        theme.ViewportBackground
        or theme.Background
        or BACKGROUND_COLOR

    self.Container.BorderColor3 =
        theme.Border
        or Color3.fromRGB(
            60,
            60,
            60
        )

    self.Container.BorderSizePixel =
        1

    self.Container.ClipsDescendants =
        true

    self.Container.Parent =
        self.Tab.ContentFrame

    --------------------------------------------------------
    -- VIEWPORT FRAME
    --------------------------------------------------------

    self.Instance =
        Instance.new(
            "ViewportFrame"
        )

    self.Instance.Name =
        "ViewportFrame"

    self.Instance.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    self.Instance.Position =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    self.Instance.BackgroundTransparency =
        1

    self.Instance.BorderSizePixel =
        0

    self.Instance.Ambient =
        Color3.fromRGB(
            200,
            200,
            200
        )

    self.Instance.LightColor =
        Color3.fromRGB(
            255,
            255,
            255
        )

    self.Instance.LightDirection =
        Vector3.new(
            -1,
            -1,
            -1
        )

    self.Instance.Parent =
        self.Container

    --------------------------------------------------------
    -- WORLD MODEL
    --------------------------------------------------------

    self.WorldModel =
        Instance.new(
            "WorldModel"
        )

    self.WorldModel.Name =
        "WorldModel"

    self.WorldModel.Parent =
        self.Instance

    --------------------------------------------------------
    -- CAMERA
    --------------------------------------------------------

    self.Camera =
        Instance.new(
            "Camera"
        )

    self.Camera.Name =
        "ViewportCamera"

    self.Camera.FieldOfView =
        tonumber(
            options.FieldOfView
        )
        or 70

    self.Camera.Parent =
        self.Instance

    self.Instance.CurrentCamera =
        self.Camera

    --------------------------------------------------------
    -- INITIAL OBJECT
    --------------------------------------------------------

    if options.Viewport ~= nil then

        self:SetViewport(
            options.Viewport
        )

    elseif options.Model ~= nil then

        self:SetViewport(
            options.Model
        )
    end

    --------------------------------------------------------
    -- CAMERA UPDATE
    --------------------------------------------------------

    self:_UpdateCamera()

    --------------------------------------------------------
    -- INPUT
    --------------------------------------------------------

    self:_InitInput()

    --------------------------------------------------------
    -- REGISTER
    --------------------------------------------------------

    table.insert(
        self.Tab.Elements,
        self
    )

    return self
end

------------------------------------------------------------
-- GET TARGET INSTANCE
------------------------------------------------------------

function Viewport:_GetRenderableRoot(
    object
)

    if not object then
        return nil
    end

    if object:IsA("Model")
        or object:IsA("BasePart")
        or object:IsA("Folder")
        or object:IsA("WorldModel") then

        return object
    end

    return nil
end

------------------------------------------------------------
-- CLEAR VIEWPORT
------------------------------------------------------------

function Viewport:_ClearViewport()

    if self.Destroyed then
        return
    end

    for _, child in ipairs(
        self.WorldModel:GetChildren()
    ) do

        child:Destroy()
    end

    self.ViewportModel =
        nil
end

------------------------------------------------------------
-- CLONE VIEWPORT OBJECT
------------------------------------------------------------

function Viewport:_CloneObject(
    object
)

    if not object then
        return nil
    end

    local ok, clone =
        pcall(
            function()
                return object:Clone()
            end
        )

    if not ok
        or not clone then

        return nil
    end

    return clone
end

------------------------------------------------------------
-- GET MODEL BOUNDS
------------------------------------------------------------

function Viewport:_GetBounds()

    if not self.ViewportModel then

        return
            Vector3.zero,
            Vector3.one
    end

    if self.ViewportModel:IsA(
        "Model"
    ) then

        local ok, cf, size =
            pcall(
                function()

                    return
                        self.ViewportModel:
                            GetBoundingBox()
                end
            )

        if ok
            and cf
            and size then

            return
                cf.Position,
                size
        end
    end

    if self.ViewportModel:IsA(
        "BasePart"
    ) then

        return
            self.ViewportModel.Position,
            self.ViewportModel.Size
    end

    --------------------------------------------------------
    -- FALLBACK: inspect BaseParts
    --------------------------------------------------------

    local minVector =
        Vector3.new(
            math.huge,
            math.huge,
            math.huge
        )

    local maxVector =
        Vector3.new(
            -math.huge,
            -math.huge,
            -math.huge
        )

    local found =
        false

    for _, descendant in ipairs(
        self.ViewportModel:
            GetDescendants()
    ) do

        if descendant:IsA(
            "BasePart"
        ) then

            found =
                true

            local position =
                descendant.Position

            local half =
                descendant.Size / 2

            local min =
                position - half

            local max =
                position + half

            minVector =
                Vector3.new(
                    math.min(
                        minVector.X,
                        min.X
                    ),
                    math.min(
                        minVector.Y,
                        min.Y
                    ),
                    math.min(
                        minVector.Z,
                        min.Z
                    )
                )

            maxVector =
                Vector3.new(
                    math.max(
                        maxVector.X,
                        max.X
                    ),
                    math.max(
                        maxVector.Y,
                        max.Y
                    ),
                    math.max(
                        maxVector.Z,
                        max.Z
                    )
                )
        end
    end

    if not found then

        return
            Vector3.zero,
            Vector3.one
    end

    return
        (minVector + maxVector) / 2,
        maxVector - minVector
end

------------------------------------------------------------
-- UPDATE CAMERA
------------------------------------------------------------

function Viewport:_UpdateCamera()

    if self.Destroyed
        or not self.Camera then

        return
    end

    local center, size =
        self:_GetBounds()

    local largest =
        math.max(
            size.X,
            size.Y,
            size.Z
        )

    if largest <= 0 then
        largest = 1
    end

    local targetDistance =
        math.max(
            self.Distance,
            largest * 1.5
        )

    local yawRadians =
        math.rad(
            self.Yaw
        )

    local pitchRadians =
        math.rad(
            self.Pitch
        )

    local horizontalDistance =
        targetDistance
        * math.cos(
            pitchRadians
        )

    local offset =
        Vector3.new(
            math.sin(
                yawRadians
            )
            * horizontalDistance,

            math.sin(
                pitchRadians
            )
            * targetDistance,

            math.cos(
                yawRadians
            )
            * horizontalDistance
        )

    local cameraPosition =
        center
        + offset

    self.Camera.CFrame =
        CFrame.lookAt(
            cameraPosition,
            center
        )
end

------------------------------------------------------------
-- INITIALIZE INPUT
------------------------------------------------------------

function Viewport:_InitInput()

    --------------------------------------------------------
    -- MOUSE / TOUCH BEGIN
    --------------------------------------------------------

    self.Container.InputBegan:Connect(
        function(input)

            if self.Destroyed then
                return
            end

            ------------------------------------------------
            -- MOUSE
            ------------------------------------------------

            if isMouseDragInput(
                input
            ) then

                if not self.Drag then
                    return
                end

                self.MouseDragging =
                    true

                return
            end

            ------------------------------------------------
            -- TOUCH
            ------------------------------------------------

            if isTouchInput(
                input
            ) then

                if self.ActiveTouch
                    == nil then

                    self.ActiveTouch =
                        input

                    self.TouchStartPosition =
                        input.Position

                    self.TouchLastPosition =
                        input.Position

                elseif self.SecondTouch
                    == nil then

                    self.SecondTouch =
                        input

                    self.SecondTouchLastPosition =
                        input.Position

                    self.LastPinchDistance =
                        (
                            self.ActiveTouch.Position
                            - self.SecondTouch.Position
                        ).Magnitude
                end
            end
        end
    )

    --------------------------------------------------------
    -- MOUSE MOVE / TOUCH MOVE
    --------------------------------------------------------

    UserInputService.InputChanged:Connect(
        function(input)

            if self.Destroyed then
                return
            end

            ------------------------------------------------
            -- MOUSE
            ------------------------------------------------

            if input.UserInputType
                == Enum.UserInputType.MouseMovement then

                if not self.MouseDragging
                    or not self.Drag then

                    return
                end

                local delta =
                    input.Delta

                self.Yaw =
                    self.Yaw
                    - delta.X
                        * ROTATION_SPEED

                self.Pitch =
                    math.clamp(
                        self.Pitch
                        - delta.Y
                            * ROTATION_SPEED,

                        -89,
                        89
                    )

                self:_UpdateCamera()

                return
            end

            ------------------------------------------------
            -- TOUCH
            ------------------------------------------------

            if input.UserInputType
                ~= Enum.UserInputType.Touch then

                return
            end

            ------------------------------------------------
            -- ONE FINGER DRAG
            ------------------------------------------------

            if self.ActiveTouch == input
                and not self.SecondTouch then

                if not self.Drag then
                    return
                end

                local current =
                    input.Position

                local last =
                    self.TouchLastPosition
                    or current

                local delta =
                    current - last

                self.TouchLastPosition =
                    current

                self.Yaw =
                    self.Yaw
                    - delta.X
                        * ROTATION_SPEED

                self.Pitch =
                    math.clamp(
                        self.Pitch
                        - delta.Y
                            * ROTATION_SPEED,

                        -89,
                        89
                    )

                self:_UpdateCamera()

                return
            end

            ------------------------------------------------
            -- PINCH
            ------------------------------------------------

            if self.ActiveTouch
                and self.SecondTouch then

                if not self.Zoom then
                    return
                end

                local first =
                    self.ActiveTouch.Position

                local second =
                    self.SecondTouch.Position

                local distance =
                    (
                        first - second
                    ).Magnitude

                if self.LastPinchDistance then

                    local delta =
                        distance
                        - self.LastPinchDistance

                    self.Distance =
                        math.clamp(
                            self.Distance
                            - delta
                                * MOBILE_PINCH_SPEED,

                            MIN_DISTANCE,
                            MAX_DISTANCE
                        )

                    self:_UpdateCamera()
                end

                self.LastPinchDistance =
                    distance
            end
        end
    )

    --------------------------------------------------------
    -- MOUSE WHEEL
    --------------------------------------------------------

    UserInputService.InputChanged:Connect(
        function(input)

            if self.Destroyed
                or not self.Zoom then

                return
            end

            if input.UserInputType
                ~= Enum.UserInputType.MouseWheel then

                return
            end

            local position =
                UserInputService:GetMouseLocation()

            local containerPosition =
                self.Container.AbsolutePosition

            local containerSize =
                self.Container.AbsoluteSize

            local inside =
                position.X >=
                    containerPosition.X

                and position.X <=
                    containerPosition.X
                    + containerSize.X

                and position.Y >=
                    containerPosition.Y

                and position.Y <=
                    containerPosition.Y
                    + containerSize.Y

            if not inside then
                return
            end

            local wheel =
                input.Position.Z

            self.Distance =
                math.clamp(
                    self.Distance
                    - wheel
                        * ZOOM_SPEED,

                    MIN_DISTANCE,
                    MAX_DISTANCE
                )

            self:_UpdateCamera()
        end
    )

    --------------------------------------------------------
    -- INPUT END
    --------------------------------------------------------

    UserInputService.InputEnded:Connect(
        function(input)

            if self.Destroyed then
                return
            end

            if isMouseDragInput(
                input
            ) then

                self.MouseDragging =
                    false

                return
            end

            if not isTouchInput(
                input
            ) then

                return
            end

            ------------------------------------------------
            -- SECOND TOUCH RELEASED
            ------------------------------------------------

            if self.SecondTouch == input then

                self.SecondTouch =
                    nil

                self.SecondTouchLastPosition =
                    nil

                self.LastPinchDistance =
                    nil

                if self.ActiveTouch then

                    self.TouchLastPosition =
                        self.ActiveTouch.Position
                end

                return
            end

            ------------------------------------------------
            -- FIRST TOUCH RELEASED
            ------------------------------------------------

            if self.ActiveTouch == input then

                self.ActiveTouch =
                    self.SecondTouch

                self.TouchStartPosition =
                    self.ActiveTouch
                    and self.ActiveTouch.Position
                    or nil

                self.TouchLastPosition =
                    self.ActiveTouch
                    and self.ActiveTouch.Position
                    or nil

                self.SecondTouch =
                    nil

                self.SecondTouchLastPosition =
                    nil

                self.LastPinchDistance =
                    nil
            end
        end
    )
end

------------------------------------------------------------
-- SET VIEWPORT
------------------------------------------------------------

function Viewport:SetViewport(
    object
)

    if self.Destroyed then
        return false
    end

    if object == nil then

        self:_ClearViewport()

        self:_UpdateCamera()

        return true
    end

    local root =
        self:_GetRenderableRoot(
            object
        )

    if not root then

        warn(
            "Viewport:SetViewport(): " ..
            "expected Model, BasePart, Folder or WorldModel."
        )

        return false
    end

    local clone =
        self:_CloneObject(
            root
        )

    if not clone then

        warn(
            "Viewport:SetViewport(): " ..
            "failed to clone object."
        )

        return false
    end

    self:_ClearViewport()

    clone.Parent =
        self.WorldModel

    self.ViewportModel =
        clone

    self.Distance =
        DEFAULT_DISTANCE

    self:_UpdateCamera()

    return true
end

------------------------------------------------------------
-- SET DRAG
------------------------------------------------------------

function Viewport:SetDrag(
    state
)

    if self.Destroyed then
        return
    end

    self.Drag =
        state == true

    if not self.Drag then
        self.MouseDragging =
            false
    end
end

------------------------------------------------------------
-- SET ZOOM
------------------------------------------------------------

function Viewport:SetZoom(
    state
)

    if self.Destroyed then
        return
    end

    self.Zoom =
        state == true

    if not self.Zoom then

        self.LastPinchDistance =
            nil
    end
end

------------------------------------------------------------
-- SET SIZE
------------------------------------------------------------

function Viewport:SetSize(
    size
)

    if self.Destroyed then
        return
    end

    if typeof(size) ~= "UDim2" then
        return
    end

    self.Size =
        size

    self.Container.Size =
        size
end

------------------------------------------------------------
-- SET DISTANCE
------------------------------------------------------------

function Viewport:SetDistance(
    distance
)

    if self.Destroyed then
        return
    end

    distance =
        tonumber(
            distance
        )

    if not distance then
        return
    end

    self.Distance =
        math.clamp(
            distance,
            MIN_DISTANCE,
            MAX_DISTANCE
        )

    self:_UpdateCamera()
end

------------------------------------------------------------
-- SET ROTATION
------------------------------------------------------------

function Viewport:SetRotation(
    yaw,
    pitch
)

    if self.Destroyed then
        return
    end

    yaw =
        tonumber(
            yaw
        )
        or self.Yaw

    pitch =
        tonumber(
            pitch
        )
        or self.Pitch

    self.Yaw =
        yaw

    self.Pitch =
        math.clamp(
            pitch,
            -89,
            89
        )

    self:_UpdateCamera()
end

------------------------------------------------------------
-- SET FIELD OF VIEW
------------------------------------------------------------

function Viewport:SetFieldOfView(
    fieldOfView
)

    if self.Destroyed then
        return
    end

    fieldOfView =
        tonumber(
            fieldOfView
        )

    if not fieldOfView then
        return
    end

    self.Camera.FieldOfView =
        math.clamp(
            fieldOfView,
            1,
            120
        )
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Viewport:UpdateTheme(
    theme
)

    if self.Destroyed then
        return
    end

    self.Container.BackgroundColor3 =
        theme.ViewportBackground
        or theme.Background
        or BACKGROUND_COLOR

    self.Container.BorderColor3 =
        theme.Border
        or Color3.fromRGB(
            60,
            60,
            60
        )

    self.Instance.Ambient =
        theme.ViewportAmbient
        or Color3.fromRGB(
            200,
            200,
            200
        )

    self.Instance.LightColor =
        theme.ViewportLight
        or Color3.fromRGB(
            255,
            255,
            255
        )

    self.Instance.LightDirection =
        theme.ViewportLightDirection
        or Vector3.new(
            -1,
            -1,
            -1
        )
end

------------------------------------------------------------
-- SET FONT
--
-- Viewport has no text, so this exists only for
-- compatibility with Row / Section propagation.
------------------------------------------------------------

function Viewport:SetFont()
    return
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Viewport:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed =
        true

    self.MouseDragging =
        false

    self.ActiveTouch =
        nil

    self.SecondTouch =
        nil

    self.TouchStartPosition =
        nil

    self.TouchLastPosition =
        nil

    self.SecondTouchLastPosition =
        nil

    self.LastPinchDistance =
        nil

    self.ViewportModel =
        nil

    if self.Container then

        self.Container:Destroy()

        self.Container =
            nil
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

return Viewport
