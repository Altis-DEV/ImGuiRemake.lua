-- File: ImGuiRemake.lua/Components/Image.lua

local Image = {}
Image.__index = Image

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------

local HttpService = game:GetService("HttpService")

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

local DEFAULT_HEIGHT = 150

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function getExtension(url)
    local cleanUrl = string.match(
        url,
        "^[^%?]+"
    ) or url

    local extension =
        string.match(
            string.lower(cleanUrl),
            "%.([%a%d]+)$"
        )

    if extension == "jpg"
        or extension == "jpeg"
        or extension == "png" then

        return extension
    end

    return "png"
end

local function hashString(str)
    -- FNV-1a style lightweight hash.
    -- Không cần cryptographic security,
    -- chỉ cần tạo tên file ổn định cho cache.

    local hash = 2166136261

    for i = 1, #str do
        hash =
            bit32.bxor(
                hash,
                string.byte(str, i)
            )

        hash =
            (hash * 16777619)
            % 4294967296
    end

    return string.format(
        "%08x",
        hash
    )
end

local function isAssetId(value)
    if typeof(value) ~= "string" then
        return false
    end

    return string.match(
        value,
        "^rbxassetid://"
    ) ~= nil
    or string.match(
        value,
        "^%d+$"
    ) ~= nil
end

local function normalizeAssetId(value)
    value = tostring(value)

    if string.match(
        value,
        "^%d+$"
    ) then

        return "rbxassetid://" .. value
    end

    return value
end

local function canUseFilesystem()
    return type(writefile) == "function"
        and type(isfile) == "function"
        and type(getcustomasset) == "function"
end

------------------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------------------

function Image.new(tab, options)

    options = options or {}

    ------------------------------------------------------------
    -- REQUIRED IMAGE
    ------------------------------------------------------------

    if options.Image == nil then
        error(
            "Image requires an Image property",
            2
        )
    end

    ------------------------------------------------------------
    -- SIZE / RATIO REQUIRED
    ------------------------------------------------------------

    if options.Size == nil
        and options.Ratio == nil then

        error(
            "Image requires Size or Ratio",
            2
        )
    end

    if options.Ratio ~= nil then
        options.Ratio =
            tonumber(options.Ratio)

        if not options.Ratio
            or options.Ratio <= 0 then

            error(
                "Image Ratio must be a number greater than 0",
                2
            )
        end
    end

    local self =
        setmetatable({}, Image)

    self.Tab = tab
    self.Window = tab.Window

    self.Source =
        tostring(options.Image)

    self.Ratio =
        options.Ratio

    self.Destroyed = false

    ------------------------------------------------------------
    -- CONTAINER
    ------------------------------------------------------------

    self.Container =
        Instance.new("Frame")

    self.Container.Name =
        "Image"

    self.Container.BackgroundTransparency =
        1

    self.Container.BorderSizePixel =
        0

    self.Container.Size =
        options.Size
        or UDim2.new(
            1,
            0,
            0,
            DEFAULT_HEIGHT
        )

    self.Container.Parent =
        self.Tab.ContentFrame

    ------------------------------------------------------------
    -- IMAGE FRAME
    ------------------------------------------------------------

    self.ImageFrame =
        Instance.new("Frame")

    self.ImageFrame.Name =
        "ImageFrame"

    self.ImageFrame.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    self.ImageFrame.BackgroundColor3 =
        self.Window.ThemeData.Background

    -- Dùng border có sẵn của theme
    self.ImageFrame.BorderColor3 =
        self.Window.ThemeData.Border

    self.ImageFrame.BorderSizePixel =
        1

    self.ImageFrame.ClipsDescendants =
        true

    self.ImageFrame.Parent =
        self.Container

    ------------------------------------------------------------
    -- IMAGE LABEL
    ------------------------------------------------------------

    self.Instance =
        Instance.new("ImageLabel")

    self.Instance.Name =
        "Image"

    self.Instance.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    self.Instance.BackgroundTransparency =
        1

    self.Instance.BorderSizePixel =
        0

    self.Instance.ScaleType =
        Enum.ScaleType.Fit

    self.Instance.Parent =
        self.ImageFrame

    ------------------------------------------------------------
    -- RATIO
    ------------------------------------------------------------

    if self.Ratio then

        self.AspectRatio =
            Instance.new(
                "UIAspectRatioConstraint"
            )

        self.AspectRatio.Name =
            "AspectRatio"

        self.AspectRatio.AspectRatio =
            self.Ratio

        self.AspectRatio.DominantAxis =
            Enum.DominantAxis.Width

        self.AspectRatio.Parent =
            self.ImageFrame

    end

    ------------------------------------------------------------
    -- LOAD IMAGE
    ------------------------------------------------------------

    self:_LoadImage(
        self.Source
    )

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
-- LOAD IMAGE
------------------------------------------------------------

function Image:_LoadImage(source)

    if self.Destroyed then
        return
    end

    --------------------------------------------------------
    -- ROBLOX ASSET ID
    --------------------------------------------------------

    if isAssetId(source) then

        self.Instance.Image =
            normalizeAssetId(source)

        return
    end

    --------------------------------------------------------
    -- RAW URL
    --------------------------------------------------------

    local isHttp =
        string.match(
            string.lower(source),
            "^https?://"
        ) ~= nil

    if not isHttp then

        warn(
            "Image: Invalid image source:",
            source
        )

        return
    end

    --------------------------------------------------------
    -- FILESYSTEM CACHE
    --------------------------------------------------------

    if not canUseFilesystem() then

        warn(
            "Image: writefile/isfile/getcustomasset " ..
            "không khả dụng; không thể load raw URL."
        )

        return
    end

    local extension =
        getExtension(source)

    local hash =
        hashString(source)

    -- Không tạo folder.
    -- Cache trực tiếp vào filesystem của executor.
    local cachePath =
        "imgui_" ..
        hash ..
        "." ..
        extension

    --------------------------------------------------------
    -- EXISTING CACHE
    --------------------------------------------------------

    local okIsFile, exists =
        pcall(
            isfile,
            cachePath
        )

    if okIsFile
        and exists then

        local okAsset, asset =
            pcall(
                getcustomasset,
                cachePath
            )

        if okAsset
            and asset then

            self.Instance.Image =
                asset

            return
        end
    end

    --------------------------------------------------------
    -- DOWNLOAD
    --------------------------------------------------------

    local okHttp, data =
        pcall(
            function()
                return game:HttpGet(
                    source
                )
            end
        )

    if not okHttp
        or type(data) ~= "string"
        or #data == 0 then

        warn(
            "Image: Failed to download:",
            source
        )

        return
    end

    --------------------------------------------------------
    -- WRITE CACHE
    --------------------------------------------------------

    local okWrite, writeError =
        pcall(
            function()
                writefile(
                    cachePath,
                    data
                )
            end
        )

    if not okWrite then

        warn(
            "Image: Failed to cache image:",
            writeError
        )

        return
    end

    --------------------------------------------------------
    -- GET CUSTOM ASSET
    --------------------------------------------------------

    local okAsset, asset =
        pcall(
            getcustomasset,
            cachePath
        )

    if not okAsset
        or not asset then

        warn(
            "Image: getcustomasset failed:",
            cachePath
        )

        return
    end

    self.Instance.Image =
        asset
end

------------------------------------------------------------
-- SET IMAGE
------------------------------------------------------------

function Image:SetImage(newImage)

    if self.Destroyed then
        return
    end

    if newImage == nil then
        return
    end

    self.Source =
        tostring(newImage)

    self:_LoadImage(
        self.Source
    )
end

------------------------------------------------------------
-- UPDATE THEME
------------------------------------------------------------

function Image:UpdateTheme(theme)

    if self.Destroyed then
        return
    end

    self.ImageFrame.BackgroundColor3 =
        theme.Background
        or Color3.fromRGB(
            20,
            20,
            20
        )

    self.ImageFrame.BorderColor3 =
        theme.Border
        or Color3.fromRGB(
            60,
            60,
            60
        )
end

------------------------------------------------------------
-- DESTROY
------------------------------------------------------------

function Image:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true

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

return Image
