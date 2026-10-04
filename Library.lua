local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local LogService = cloneref(game:GetService("LogService"))
local MarketplaceService: MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local Stats = cloneref(game:GetService("Stats"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    SearchQuery = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},
    SidebarSections = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    MaxNotifications = 6, -- oldest notifications are dismissed past this amount (0 = unlimited)
    GroupNotifications = true, -- identical notifications stack into one with an "xN" counter
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,

    --// Copy Text: <c>text</c> \\--
    CopyTextColor = Color3.fromRGB(88, 166, 255),
    CopyTextIcon = "rbxassetid://85387882337161",
    NotifyOnCopy = false,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    GroupboxDrag = true, -- drag a groupbox header to float it (Library:SetGroupboxDrag)
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 10,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(13, 13, 17),
        MainColor = Color3.fromRGB(23, 23, 30),
        AccentColor = Color3.fromRGB(110, 103, 255),
        OutlineColor = Color3.fromRGB(37, 37, 47),
        FontColor = Color3.fromRGB(240, 240, 246),
        Font = Font.fromEnum(Enum.Font.BuilderSansMedium),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        AccentLine = true, -- thin accent line along the top of the window
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.new(0, 180, 1, 0),
        SearchbarCollapsible = true, -- collapses to an icon while unfocused and empty
        SearchbarCollapsedWidth = 32,
        GlobalSearch = false,

        CornerRadius = 10,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Toolbar = true, -- top center controller (true | false | { Offset, ButtonSize, IconSize, Draggable, Visible, DefaultButtons })
        Watermark = false, -- true | { Title, Icon, ShowFPS, ShowPing, ShowPlayer, ShowGame, ShowTime, Segments, ... }

        Font = Enum.Font.BuilderSansMedium,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Height = 40, -- tab button height
            TextSize = 16, -- tab button text size
            Gap = 2,
            Padding = 6,
            CornerRadius = 6,
            Indicator = true,
            IndicatorWidth = 3,
            IndicatorHeight = 18,
        },

        --// Sub Pages \\--
        SubPageStyle = {
            Style = "Pill", -- "Pill" | "Underline" | "Flat"
            Gap = 4,
            Height = 26,
            PaddingX = 10,
            TextSize = 14,
            -- CornerRadius = 4, (optional, follows the window corner radius when omitted)
            ShowStroke = true,
            IndicatorHeight = 2,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Card = {
        Title = "Card",
        Description = nil,
        Footer = nil,
        Tag = nil, -- small pill on the top right

        Icon = nil,
        Image = nil, -- background image
        ImageTransparency = 0.5,
        ImageScaleType = Enum.ScaleType.Crop,

        BackgroundColor = nil, -- Color3 or scheme key ("MainColor")
        BackgroundTransparency = 0,
        CornerRadius = nil,
        Height = 0, -- minimum height

        Buttons = {}, -- { { Text = "Open", Variant = "Primary", Callback = function(Card) end } }
        Callback = nil, -- makes the whole card clickable

        TitleSize = 16,
        DescriptionSize = 14,
        Visible = true,
    },
    Toolbar = {
        Offset = 6,
        ButtonSize = 30,
        IconSize = 18,
        Draggable = true,
        Visible = true,
        DefaultButtons = true,
    },
    Watermark = {
        Title = "Octo",
        Icon = "chart-column",

        ShowGame = false,
        ShowPlayer = false,
        ShowFPS = true,
        ShowPing = true,
        ShowTime = false,

        Segments = {}, -- extra segments: { Text or function }
        Separator = "·",

        Position = nil, -- UDim2 (anchored top right by default)
        Draggable = true,
        Visible = true,
        Interval = 0.25,
    },
    List = {
        Values = {},
        DisabledValues = {},

        Multi = false,
        Rows = 6, -- visible rows
        Searchable = false, -- search box above the list
        -- ModalButton = true, (button that opens the values in a popup grid)
        ModalColumns = 3,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    RangeSlider = {
        Text = "Range",
        Default = { 0, 100 }, -- { Low, High }
        Min = 0,
        Max = 100,
        Rounding = 0,
        MinRange = 0, -- minimum distance between the two handles

        Prefix = "",
        Suffix = "",

        Callback = function() end, -- (Low, High)
        Changed = function() end, -- (Low, High)

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true, -- right click / double tap and type "low, high"
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,
        KeepDisabledValuePosition = false,

        -- ModalButton = true, (button that opens the values in a popup grid, defaults to true for Multi dropdowns)
        ModalColumns = 3,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
    full = 3, -- spans both columns (room for 3 buttons / 3 dropdowns in a row)
    wide = 3,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Rich Text \\--
local RichEntities = { lt = "<", gt = ">", amp = "&", quot = '"', apos = "'", nbsp = " " }
local RichCharPattern = "^" .. utf8.charpattern

local function EscapeRichText(Text: any): string
    return (tostring(Text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end

--// Splits a rich text string into tags (<b>, </font>, ...) and visible characters (entities count as one character) \\--
local function TokenizeRichText(Text: string)
    local Tokens = {}
    local Index = 1
    local Length = #Text

    while Index <= Length do
        local Char = Text:sub(Index, Index)

        if Char == "<" then
            local TagEnd = Text:find(">", Index + 1, true)
            local NextOpen = Text:find("<", Index + 1, true)

            if TagEnd and (not NextOpen or NextOpen > TagEnd) then
                table.insert(Tokens, { Tag = true, Raw = Text:sub(Index, TagEnd) })
                Index = TagEnd + 1
                continue
            end
        elseif Char == "&" then
            local Entity = Text:match("^&(#?%w+);", Index)

            if Entity then
                local Decoded = RichEntities[Entity]
                if not Decoded and Entity:sub(1, 1) == "#" then
                    local Code
                    if Entity:sub(2, 2):lower() == "x" then
                        Code = tonumber(Entity:sub(3), 16)
                    else
                        Code = tonumber(Entity:sub(2))
                    end

                    local Ok, Result = pcall(utf8.char, Code or 63)
                    Decoded = Ok and Result or "?"
                end

                table.insert(Tokens, { Raw = Text:sub(Index, Index + #Entity + 1), Char = Decoded or "?" })
                Index += #Entity + 2
                continue
            end
        end

        local Match = Text:match(RichCharPattern, Index) or Char
        table.insert(Tokens, { Raw = Match, Char = Match })
        Index += #Match
    end

    return Tokens
end

local function StripRichText(Text: string): string
    if not Text:find("[<&]") then
        return Text
    end

    local Out = {}
    for _, Token in TokenizeRichText(Text) do
        if not Token.Tag then
            table.insert(Out, Token.Char)
        end
    end

    return table.concat(Out)
end

--// Truncates visible characters only, keeps the markup valid by closing every tag that is still open \\--
local function TruncateRichText(Text: string, Max: number, Keep: number): string
    if not Text:find("[<&]") then
        local Len = utf8.len(Text) or #Text
        if Len <= Max then
            return Text
        end

        local Cut = utf8.offset(Text, Keep + 1)
        return Text:sub(1, (Cut or (Keep + 1)) - 1) .. "..."
    end

    local Tokens = TokenizeRichText(Text)
    local Count = 0
    for _, Token in Tokens do
        if not Token.Tag then
            Count += 1
        end
    end
    if Count <= Max then
        return Text
    end

    local Out, Open, Visible = {}, {}, 0
    for _, Token in Tokens do
        if Token.Tag then
            table.insert(Out, Token.Raw)

            local Closing = Token.Raw:match("^</(%w+)")
            local Opening = Token.Raw:match("^<(%w+)")
            if Closing then
                for Index = #Open, 1, -1 do
                    if Open[Index] == Closing then
                        table.remove(Open, Index)
                        break
                    end
                end
            elseif Opening and not Token.Raw:find("/>$") then
                table.insert(Open, Opening)
            end
        else
            if Visible >= Keep then
                break
            end

            table.insert(Out, Token.Raw)
            Visible += 1
        end
    end

    table.insert(Out, "...")
    for Index = #Open, 1, -1 do
        table.insert(Out, "</" .. Open[Index] .. ">")
    end

    return table.concat(Out)
end

function Library:EscapeRichText(Text: any): string
    return EscapeRichText(Text)
end

function Library:StripRichText(Text: string): string
    return StripRichText(Text)
end

--// Search Highlight \\--
local function IsBoundaryChar(Char: string): boolean
    return Char:match("^[%s%p_]$") ~= nil
end

--// Finds the best alignment of `Search` inside `Text` (word starts and consecutive runs win over scattered letters) \\--
local function BuildHighlightedText(Text: any, Search: string): string?
    if typeof(Text) ~= "string" or Text == "" or Search == "" then
        return nil
    end

    local Tokens = TokenizeRichText(Text)
    local Plain = {}
    for _, Token in Tokens do
        if not Token.Tag then
            table.insert(Plain, Token)
        end
    end
    if #Plain == 0 then
        return nil
    end

    local Lowered, StartBytes, ByteToIndex, Cursor = {}, {}, {}, 1
    for Index, Token in Plain do
        local Lower = Token.Char:lower()
        Lowered[Index] = Lower
        StartBytes[Index] = Cursor
        ByteToIndex[Cursor] = Index
        Cursor += #Lower
    end
    local Joined = table.concat(Lowered)

    local function AtBoundary(Index: number): boolean
        return Index == 1 or IsBoundaryChar(Plain[Index - 1].Char)
    end

    local Matched = {}

    --// 1) Literal match: prefer the occurrence that starts a word, otherwise the first one \\--
    local BestStart
    local SearchFrom = 1
    while true do
        local Found = Joined:find(Search, SearchFrom, true)
        if not Found then
            break
        end

        local CharIndex = ByteToIndex[Found]
        if CharIndex then
            BestStart = BestStart or Found
            if AtBoundary(CharIndex) then
                BestStart = Found
                break
            end
        end

        SearchFrom = Found + 1
    end

    if BestStart then
        local BestEnd = BestStart + #Search - 1
        for Index = 1, #Plain do
            if StartBytes[Index] >= BestStart and StartBytes[Index] <= BestEnd then
                Matched[Index] = true
            end
        end
    else
        --// 2) Fuzzy match: best scoring in-order alignment (dynamic programming) \\--
        local SearchChars = {}
        for Char in Search:gmatch(utf8.charpattern) do
            table.insert(SearchChars, Char)
        end

        local N, M = #Plain, #SearchChars
        if M == 0 or M > N then
            return nil
        end

        local NEG = -math.huge
        local Prev, Parents = {}, {}
        for I = 1, N do
            Prev[I] = (Lowered[I] == SearchChars[1]) and (1 + (AtBoundary(I) and 6 or 0)) or NEG
        end

        for J = 2, M do
            local Cur, Par = {}, {}
            local BestBefore, BestBeforeIdx = NEG, nil

            for I = 1, N do
                if I - 2 >= 1 and Prev[I - 2] > BestBefore then
                    BestBefore = Prev[I - 2]
                    BestBeforeIdx = I - 2
                end

                Cur[I] = NEG
                if Lowered[I] == SearchChars[J] then
                    local Cand, From = NEG, nil
                    if BestBeforeIdx then
                        Cand = BestBefore - (I - BestBeforeIdx - 1) * 0.05
                        From = BestBeforeIdx
                    end
                    if I - 1 >= 1 and Prev[I - 1] > NEG and Prev[I - 1] + 3 >= Cand then
                        Cand = Prev[I - 1] + 3
                        From = I - 1
                    end

                    if From then
                        Cur[I] = Cand + 1 + (AtBoundary(I) and 6 or 0)
                        Par[I] = From
                    end
                end
            end

            Parents[J] = Par
            Prev = Cur
        end

        local BestI, BestScore = nil, NEG
        for I = 1, N do
            if Prev[I] > BestScore then
                BestScore = Prev[I]
                BestI = I
            end
        end
        if not BestI then
            return nil
        end

        local I = BestI
        for J = M, 1, -1 do
            Matched[I] = true
            if J > 1 then
                I = Parents[J][I]
            end
        end
    end

    local OpenTag = string.format('<mark color="#%s" transparency="0.6">', Library.Scheme.AccentColor:ToHex())
    local Out, PlainIndex, IsOpen = {}, 0, false

    for _, Token in Tokens do
        if Token.Tag then
            if IsOpen then
                table.insert(Out, "</mark>")
                IsOpen = false
            end

            table.insert(Out, Token.Raw)
        else
            PlainIndex += 1

            if Matched[PlainIndex] then
                if not IsOpen then
                    table.insert(Out, OpenTag)
                    IsOpen = true
                end
            elseif IsOpen then
                table.insert(Out, "</mark>")
                IsOpen = false
            end

            table.insert(Out, Token.Raw)
        end
    end

    if IsOpen then
        table.insert(Out, "</mark>")
    end

    return table.concat(Out)
end

--// Target = anything with `HighlightLabel` and (`Text` or `Name`) \\--
local function ClearHighlight(Target)
    if not Target or not Target.Highlighted then
        return
    end

    Target.Highlighted = false

    local Label = Target.HighlightLabel
    if Label and Label.Parent then
        local Source = Target.Text
        if typeof(Source) ~= "string" then
            Source = Target.Name
        end

        Label.Text = typeof(Source) == "string" and Source or ""
    end
end

local function ClearElementHighlight(ElementInfo)
    ClearHighlight(ElementInfo)
    if ElementInfo.SubButton then
        ClearHighlight(ElementInfo.SubButton)
    end
end

local function HighlightTarget(Target, Search: string)
    if not Target then
        return
    end

    local Label = Target.HighlightLabel
    if not (Label and Label.Parent) then
        return
    end

    local Source = Target.Text
    if typeof(Source) ~= "string" then
        Source = Target.Name
    end

    local Highlighted = BuildHighlightedText(Source, Search)
    if Highlighted then
        Label.Text = Highlighted
        Target.Highlighted = true
    else
        ClearHighlight(Target)
    end
end

local function HighlightElements(Elements, DependencyBoxes, Search: string)
    for _, ElementInfo in Elements do
        if ElementInfo.Type == "Divider" or not (ElementInfo.Holder and ElementInfo.Holder.Visible) then
            continue
        end

        HighlightTarget(ElementInfo, Search)
        if ElementInfo.SubButton then
            HighlightTarget(ElementInfo.SubButton, Search)
        end
    end

    for _, Depbox in DependencyBoxes or {} do
        if Depbox.Visible then
            HighlightElements(Depbox.Elements, Depbox.DependencyBoxes, Search)
        end
    end
end

local function HighlightTab(Tab, Search: string)
    HighlightTarget(Tab, Search)

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false or not Groupbox.BoxHolder.Visible then
            continue
        end

        HighlightTarget(Groupbox, Search)
        HighlightTarget(Groupbox.DescriptionTarget, Search)
        HighlightElements(Groupbox.Elements, Groupbox.DependencyBoxes, Search)
    end

    for _, Tabbox in Tab.Tabboxes do
        if not Tabbox.BoxHolder.Visible then
            continue
        end

        for _, SubTab in Tabbox.Tabs do
            HighlightTarget(SubTab, Search)
            HighlightElements(SubTab.Elements, SubTab.DependencyBoxes, Search)
        end
    end
end

--// Fuzzy Search \\--
local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextLen, SearchLen = Text:len(), Search:len()
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
            local PrevChar = TextIdx > 1 and Text:sub(TextIdx - 1, TextIdx - 1) or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): (boolean, number)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end

    return FuzzyScore(StripRichText(Text):lower(), Search)
end

local function FuzzyMatchScore(Text: any, Search: string): number
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end

    local Normalized = NormalizeSearch(StripRichText(Text):lower())
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end

    if Normalized == Search then
        Score += 1000
    end

    return Score
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    if not Parent or not Parent.Addons then
        return
    end

    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ClearElementHighlight(ElementInfo)
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function DimPopOutClone(Root: GuiObject)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)
    local ScreenMax = math.max(0, Available / Library.DPIScale - Reserved)

    local CustomMax = Box.PopOutMaxHeight
    if typeof(CustomMax) == "number" then
        return math.min(ScreenMax, math.max(0, CustomMax))
    end

    return ScreenMax
end

--// Search
local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return false, 0
    end

    local HasVisible = false
    local BestScore = 0

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end

            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    --// If the active sub page has no results, jump to one that does \\--
    if HasVisible and Tab.SubPages and #Tab.SubPages > 0 then
        local function SubPageHasVisible(SubPage)
            for _, Box in Tab.Groupboxes do
                if Box.SubPage == SubPage and Box.BoxHolder.Visible then
                    return true
                end
            end

            for _, Box in Tab.Tabboxes do
                if Box.SubPage == SubPage and Box.BoxHolder.Visible then
                    return true
                end
            end

            return false
        end

        if not (Tab.ActiveSubPage and SubPageHasVisible(Tab.ActiveSubPage)) then
            for _, SubPage in Tab.SubPages do
                if SubPageHasVisible(SubPage) then
                    SubPage:Show()
                    break
                end
            end
        end
    end

    return HasVisible, BestScore
end
local function ResetTab(Tab)
    if not Tab then
        return
    end

    ClearHighlight(Tab)

    for _, Groupbox in Tab.Groupboxes do
        ClearHighlight(Groupbox)
        ClearHighlight(Groupbox.DescriptionTarget)

        for _, ElementInfo in Groupbox.Elements do
            ClearElementHighlight(ElementInfo)
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            ClearHighlight(SubTab)

            for _, ElementInfo in SubTab.Elements do
                ClearElementHighlight(ElementInfo)
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab then
            table.insert(TabsToSearch, Tab)
        end
    end

    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(SearchText:lower())
    Library.SearchQuery = Trim(Search) == "" and "" or Search
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end

        HighlightTab(Tab, Search)

        if Tab == Library.ActiveTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end

            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        elseif Option.Type == "List" then
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string)
    if not FetchIcons or not Icons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end

    return Icon
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:ApplyLucideIcon(ImageGui: any, Icon: any, Rotation: number?)
    if not ImageGui or not Icon then
        return
    end

    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then
        return
    end

    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset 
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
    ImageGui.Rotation = Rotation or ImageGui.Rotation
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

--// Assigned below (copy text system) \\--
local SetupCopyLabel
local SetupCopyButton

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    if ClassName == "TextLabel" and SetupCopyLabel then
        SetupCopyLabel(Instance)
    elseif ClassName == "TextButton" and SetupCopyButton then
        SetupCopyButton(Instance)
    end

    return Instance
end

--// Copy Text: <c>text</c> -> blue text + a copy icon, click to copy (works for footers, labels, notifications, ...) \\--
local CopyNBSP = "\u{00A0}"
local CopyStates = setmetatable({}, { __mode = "k" })

--// Converts <c> markup. Returns: converted text, spans ({ Start, End, Copy } in visible character indexes), visible characters \\--
local function ConvertCopyMarkup(Text: string, WithSpacer: boolean)
    local Out, Chars, Spans = {}, {}, {}
    local Color = Library.CopyTextColor:ToHex()
    local Current

    local function CloseSpan()
        table.insert(Spans, { Start = Current.Start, End = #Chars, Copy = table.concat(Current.Parts) })
        table.insert(Out, "</font>")
        Current = nil

        if WithSpacer then
            for _ = 1, 3 do
                table.insert(Out, CopyNBSP)
                table.insert(Chars, CopyNBSP)
            end
        end
    end

    for _, Token in TokenizeRichText(Text) do
        if Token.Tag then
            local Name = Token.Raw:lower()
            if Name == "<c>" and not Current then
                Current = { Start = #Chars + 1, Parts = {} }
                table.insert(Out, string.format('<font color="#%s">', Color))
            elseif Name == "</c>" and Current then
                CloseSpan()
            else
                table.insert(Out, Token.Raw)
            end
        else
            table.insert(Out, Token.Raw)
            table.insert(Chars, Token.Char)
            if Current then
                table.insert(Current.Parts, Token.Char)
            end
        end
    end

    if Current then
        CloseSpan()
    end

    return table.concat(Out), Spans, Chars
end

local function ClearCopyIcons(State)
    for _, Object in State.Objects do
        if Object.Parent then
            Object:Destroy()
        end
    end
    table.clear(State.Objects)
end

local function CopyToClipboard(Text: string, Icon: GuiObject?)
    local Ok = false
    if setclipboard then
        Ok = pcall(setclipboard, Text)
    end

    if Icon and Icon.Parent then
        Icon.ImageColor3 = Ok and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(255, 80, 80)
        task.delay(0.8, function()
            if Icon.Parent then
                Icon.ImageColor3 = Library.CopyTextColor
            end
        end)
    end

    if Library.NotifyOnCopy and Library.Notify then
        Library:Notify({
            Title = Ok and "Copied" or "Clipboard unavailable",
            Description = EscapeRichText(Text),
            Time = 2,
        })
    end
end

--// Measures where every <c> span ends and places the icon right after it (supports wrapping, new lines and text alignment) \\--
local function LayoutCopyLabel(Label)
    local State = CopyStates[Label]
    if not State then
        return
    end

    State.Token = (State.Token or 0) + 1
    local Token = State.Token

    task.spawn(function()
        for _ = 1, 30 do
            if State.Token ~= Token then
                return
            end
            if Label.AbsoluteSize.X > 0 and Label:IsDescendantOf(game) then
                break
            end

            RunService.RenderStepped:Wait()
        end
        if State.Token ~= Token or not Label:IsDescendantOf(game) then
            return
        end

        ClearCopyIcons(State)
        if Label.TextScaled or #State.Chars == 0 then
            return
        end

        --// Labels laid out by a UIListLayout (label addons) can't host overlays, so the whole label copies instead \\--
        if Label:FindFirstChildOfClass("UIListLayout") then
            if not State.SimpleConnected then
                State.SimpleConnected = true
                Label.InputBegan:Connect(function(Input: InputObject)
                    if not IsClickInput(Input) then
                        return
                    end

                    local Span = State.Spans[1]
                    if Span then
                        CopyToClipboard(Span.Copy)
                    end
                end)
            end

            return
        end

        local Scale = Library.DPIScale
        local Size = Label.AbsoluteSize
        local Pad = Label:FindFirstChildOfClass("UIPadding")
        local function PadPx(Dim: UDim, Axis: number): number
            return Dim.Scale * Axis / Scale + Dim.Offset
        end

        local PadL = Pad and PadPx(Pad.PaddingLeft, Size.X) or 0
        local PadR = Pad and PadPx(Pad.PaddingRight, Size.X) or 0
        local PadT = Pad and PadPx(Pad.PaddingTop, Size.Y) or 0
        local PadB = Pad and PadPx(Pad.PaddingBottom, Size.Y) or 0

        local Width = Size.X / Scale - PadL - PadR
        local Height = Size.Y / Scale - PadT - PadB
        local WrapWidth = Label.TextWrapped and Width or nil

        local Cache = {}
        local function Measure(Text: string, Wrap: number?): (number, number)
            local Key = (Wrap and tostring(Wrap) or "n") .. "|" .. Text
            local Hit = Cache[Key]
            if Hit then
                return Hit[1], Hit[2]
            end

            local Params = Instance.new("GetTextBoundsParams")
            Params.Text = Text
            Params.RichText = false
            Params.Font = Label.FontFace
            Params.Size = Label.TextSize * Scale
            Params.Width = (Wrap or 100000) * Scale

            local X, Y = 0, 0
            local Ok, Bounds = pcall(TextService.GetTextBoundsAsync, TextService, Params)
            if Ok then
                X, Y = Bounds.X / Scale, Bounds.Y / Scale
            end

            Cache[Key] = { X, Y }
            return X, Y
        end

        local Chars = State.Chars
        local function Slice(A: number, B: number): string
            if B < A then
                return ""
            end

            return table.concat(Chars, "", A, B)
        end
        local function IsSpace(Char: string?): boolean
            return Char == " " or Char == "\t"
        end

        local _, LineHeight = Measure("A", nil)
        if LineHeight <= 0 then
            return
        end

        local Paragraphs, ParagraphStart = {}, 1
        for Index = 1, #Chars + 1 do
            if Index == #Chars + 1 or Chars[Index] == "\n" then
                table.insert(Paragraphs, { S = ParagraphStart, E = Index - 1 })
                ParagraphStart = Index + 1
            end
        end

        local function LinesIn(S: number, E: number): number
            if E < S then
                return 1
            end

            local _, H = Measure(Slice(S, E), WrapWidth)
            return math.max(1, math.floor(H / LineHeight + 0.5))
        end

        local Before, TotalLines = {}, 0
        for Index, Paragraph in Paragraphs do
            Before[Index] = TotalLines
            Paragraph.Lines = LinesIn(Paragraph.S, Paragraph.E)
            TotalLines += Paragraph.Lines
        end

        local BaseY = 0
        local TotalHeight = TotalLines * LineHeight
        if Label.TextYAlignment == Enum.TextYAlignment.Center then
            BaseY = (Height - TotalHeight) / 2
        elseif Label.TextYAlignment == Enum.TextYAlignment.Bottom then
            BaseY = Height - TotalHeight
        end

        --// Returns the visual line (1-based) and the X position of the caret placed right after character N \\--
        local function Locate(N: number): (number, number)
            local ParaIndex = #Paragraphs
            for Index, Paragraph in Paragraphs do
                if N >= Paragraph.S and N <= Paragraph.E then
                    ParaIndex = Index
                    break
                end
            end

            local Para = Paragraphs[ParaIndex]
            N = math.clamp(N, Para.S, math.max(Para.S, Para.E))

            local L = LinesIn(Para.S, N)
            local LineStart = Para.S
            if L > 1 then
                local Lo, Hi = Para.S, N
                while Lo < Hi do
                    local Mid = (Lo + Hi) // 2
                    if LinesIn(Para.S, Mid) >= L then
                        Hi = Mid
                    else
                        Lo = Mid + 1
                    end
                end

                local K = Lo
                local WordStart = K
                while WordStart > Para.S and not IsSpace(Chars[WordStart - 1]) do
                    WordStart -= 1
                end

                LineStart = K
                if WordStart < K and (Measure(Slice(WordStart, K), nil)) <= Width then
                    LineStart = WordStart
                end
            end

            local LineEnd = Para.E
            if L < Para.Lines then
                local Lo, Hi = N + 1, Para.E
                while Lo < Hi do
                    local Mid = (Lo + Hi) // 2
                    if LinesIn(Para.S, Mid) > L then
                        Hi = Mid
                    else
                        Lo = Mid + 1
                    end
                end

                local K = Lo
                local WordStart = K
                while WordStart > LineStart and not IsSpace(Chars[WordStart - 1]) do
                    WordStart -= 1
                end

                LineEnd = K - 1
                if WordStart < K and (Measure(Slice(WordStart, K), nil)) <= Width then
                    LineEnd = WordStart - 1
                end
            end

            LineEnd = math.max(LineEnd, N)
            while LineEnd > N and IsSpace(Chars[LineEnd]) do
                LineEnd -= 1
            end

            local LineWidth = (Measure(Slice(LineStart, LineEnd), nil))
            local CaretX = (Measure(Slice(LineStart, N), nil))

            local AlignX = 0
            if Label.TextXAlignment == Enum.TextXAlignment.Center then
                AlignX = (Width - LineWidth) / 2
            elseif Label.TextXAlignment == Enum.TextXAlignment.Right then
                AlignX = Width - LineWidth
            end

            return Before[ParaIndex] + L, AlignX + CaretX
        end

        local function LineTop(Line: number): number
            return BaseY + (Line - 1) * LineHeight
        end

        local SpacerWidth = (Measure(CopyNBSP, nil)) * 3
        local IconSize = math.clamp(math.floor(math.min(Label.TextSize, SpacerWidth - 2)), 8, 28)

        for _, Span in State.Spans do
            local EndLine, EndX = Locate(Span.End)
            local StartLine, StartCaret = Locate(Span.Start)
            local StartX = StartCaret - (Measure(Chars[Span.Start], nil))

            local Icon = New("ImageButton", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = Library.CopyTextIcon,
                ImageColor3 = Library.CopyTextColor,
                ImageTransparency = 0.15,
                Position = UDim2.fromOffset(EndX + 3, LineTop(EndLine) + LineHeight / 2),
                Size = UDim2.fromOffset(IconSize, IconSize),
                ZIndex = Label.ZIndex + 2,
                Parent = Label,
            })
            table.insert(State.Objects, Icon)

            Icon.MouseButton1Click:Connect(function()
                CopyToClipboard(Span.Copy, Icon)
            end)
            Icon.MouseEnter:Connect(function()
                Icon.ImageTransparency = 0
            end)
            Icon.MouseLeave:Connect(function()
                Icon.ImageTransparency = 0.15
            end)

            --// The text itself is clickable too when the span fits on one line \\--
            if StartLine == EndLine and EndX > StartX then
                local Hit = New("TextButton", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(StartX, LineTop(StartLine)),
                    Size = UDim2.fromOffset(EndX - StartX, LineHeight),
                    Text = "",
                    ZIndex = Label.ZIndex + 1,
                    Parent = Label,
                })
                table.insert(State.Objects, Hit)

                Hit.MouseButton1Click:Connect(function()
                    CopyToClipboard(Span.Copy, Icon)
                end)
                Hit.MouseEnter:Connect(function()
                    Icon.ImageTransparency = 0
                end)
                Hit.MouseLeave:Connect(function()
                    Icon.ImageTransparency = 0.15
                end)
            end
        end
    end)
end

local function ProcessCopyLabel(Label)
    local State = CopyStates[Label]
    local Text = Label.Text

    if State and Text == State.Converted then
        return --// our own write
    end

    if not Text:find("<[cC]>") then
        if State then
            State.Token += 1
            ClearCopyIcons(State)
            CopyStates[Label] = nil
        end

        return
    end

    local Converted, Spans, Chars = ConvertCopyMarkup(Text, true)

    if not State then
        State = { Objects = {}, Token = 0 }
        CopyStates[Label] = State

        for _, Property in { "AbsoluteSize", "TextSize", "FontFace", "TextWrapped", "TextXAlignment", "TextYAlignment" } do
            Label:GetPropertyChangedSignal(Property):Connect(function()
                LayoutCopyLabel(Label)
            end)
        end
    end

    State.Converted, State.Spans, State.Chars = Converted, Spans, Chars
    Label.Text = Converted
    LayoutCopyLabel(Label)
end

SetupCopyLabel = function(Label)
    Label:GetPropertyChangedSignal("Text"):Connect(function()
        ProcessCopyLabel(Label)
    end)

    ProcessCopyLabel(Label)
end

--// Buttons only get the blue color (clicking them already has another meaning) \\--
SetupCopyButton = function(Button)
    local function Process()
        local Text = Button.Text
        if Text:find("<[cC]>") then
            Button.Text = (ConvertCopyMarkup(Text, false))
        end
    end

    Button:GetPropertyChangedSignal("Text"):Connect(Process)
    Process()
end

--// Wraps dynamic text so it becomes click-to-copy: Label:SetText(Library:Copyable(UserId)) \\--
function Library:Copyable(Text: any): string
    return "<c>" .. EscapeRichText(Text) .. "</c>"
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    if not Gui then
        return
    end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor
local CursorCross
local InnerCross = {}
local CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(1, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    CursorCross = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -2, 0, 1),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 1, 1, -2),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    pcall(function() 
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
        RunService.RenderStepped:Wait()
    end)

    UserInputService.MouseIconEnabled = Library.OriginalMouseIconEnabled
    if Cursor then Cursor.Visible = false end
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
local NotifyGroups = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Icons \\--
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon
function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
if OnlineFetchIcons and OnlineIcons then
    Library:SetIconModule(OnlineIcons)
end

--// Lib Functions \\--
Library.Cursor = {}

function Library.Cursor:ResetCross()
    for _, Inner in InnerCross do
        Library.Registry[Inner].BackgroundColor3 = "WhiteColor"
        Inner.BackgroundColor3 = Library.Scheme.WhiteColor
    end
end

function Library.Cursor:ResetIcon()
    CursorCross.Visible = true
    CursorCustomImage.Visible = false
    CursorCustomImage.ImageColor3 = Color3.new(1, 1, 1)
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library.Cursor:ResetCursor()
    Library.Cursor:ResetCross()
    Library.Cursor:ResetIcon()
end

function Library.Cursor:ChangeCrossColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    for _, Inner in InnerCross do
        Inner.BackgroundColor3 = Color
        Library.Registry[Inner].BackgroundColor3 = nil
    end
end

function Library.Cursor:ChangeIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library.Cursor:ResetIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCross.Visible = false
    CursorCustomImage.Visible = true
    Library:ApplyLucideIcon(CursorCustomImage, Icon)
end

function Library.Cursor:ChangeIconColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    CursorCustomImage.ImageColor3 = Color
end

function Library.Cursor:ChangeIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

--// DEPRECATED
function Library:ChangeCursorCrossColor(Color: Color3)
    warn("Obsidian:ChangeCursorCrossColor is deprecated, please use Obsidian.Cursor:ChangeCrossColor instead.")
    Library.Cursor:ChangeCrossColor(Color)
end

--// DEPRECATED
function Library:ResetCursorCross()
    warn("Obsidian:ResetCursorCross is deprecated, please use Obsidian.Cursor:ResetCross instead.")
    Library.Cursor:ResetCross()
end

--// DEPRECATED
function Library:ChangeCursorIcon(ImageId: string)
    warn("Obsidian:ChangeCursorIcon is deprecated, please use Obsidian.Cursor:ChangeIcon instead.")
    Library.Cursor:ChangeIcon(ImageId)
end

--// DEPRECATED
function Library:ChangeCursorIconColor(Color: Color3)
    warn("Obsidian:ChangeCursorIconColor is deprecated, please use Obsidian.Cursor:ChangeIconColor instead.")
    Library.Cursor:ChangeIconColor(Color)
end

--// DEPRECATED
function Library:ChangeCursorIconSize(Size: UDim2)
    warn("Obsidian:ChangeCursorIconSize is deprecated, please use Obsidian.Cursor:ChangeIconSize instead.")
    Library.Cursor:ChangeIconSize(Size)
end

--// DEPRECATED
function Library:ResetCursorIcon()
    warn("Obsidian:ResetCursorIcon is deprecated, please use Obsidian.Cursor:ResetIcon instead.")
    Library.Cursor:ResetIcon()
end

--// Colors \\--
function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Scale = Library.DPIScale
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size * Scale
    if Width then
        Params.Width = Width * Scale
    else
        Params.Width = workspace.CurrentCamera.ViewportSize.X - 32
    end

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        Transparency = 0.7,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing: boolean, OnComplete: (() -> ())?)
    if type(Tab) ~= "table" or not Tab.Container then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local TabContainer = Tab.Container :: Frame
    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        if SwipeFrom == "auto" and Library.PreviousTab then
            local CurrentOrder = Tab.Button.LayoutOrder
            local PreviousOrder = Library.PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder then -- this may be unnecessary but oh well
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom -- bigger order means its under the current button
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else -- bottom (Default)
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
    MaxPopOutHeight: number?,
    PopOutWidth: number?,
})
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil
    Box.PopOutMaxHeight = if typeof(Options.MaxPopOutHeight) == "number" then Options.MaxPopOutHeight else nil
    Box.PopOutWidth = if typeof(Options.PopOutWidth) == "number" then Options.PopOutWidth else nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2) end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        function Box:SetMaxPopOutHeight(_Height: number?) end
        function Box:SetPopOutWidth(_Width: number?) end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function GetPopOutWidth(): number
        if typeof(Box.PopOutWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutWidth + 0.5))
        end

        if typeof(Box.PopOutDockedWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutDockedWidth + 0.5))
        end

        local Width = Holder.AbsoluteSize.X / Library.DPIScale
        if Width < 50 then
            Width = 200
        end

        return math.max(50, math.floor(Width + 0.5))
    end

    local function ApplyPopOutWidth()
        if not (Box.PoppedOut and Float) then
            return
        end

        Float.Size = UDim2.fromOffset(GetPopOutWidth(), Float.Size.Y.Offset)
        if Box.Resize then
            Box:Resize()
        end
    end

    local function RaiseFloat()
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = New("ImageButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            })
            Library:ApplyLucideIcon(PlaceholderDockIcon, PopOutIcon)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local DockedWidth = Holder.AbsoluteSize.X / Library.DPIScale
            if DockedWidth < 50 then
                DockedWidth = 200
            end
            Box.PopOutDockedWidth = math.max(50, math.floor(DockedWidth + 0.5))

            local Width = GetPopOutWidth()

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        
        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PopOutDockedWidth = nil
        Box.PoppedOut = false

        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    function Box:SetMaxPopOutHeight(Height: number?)
        if Height ~= nil then
            assert(typeof(Height) == "number", "Height must be a number or nil")
            assert(Height >= 0, "Height must be higher than 0")
        end

        Box.PopOutMaxHeight = Height
        if Box.PoppedOut and Box.Resize then
            Box:Resize()
        end
    end

    function Box:SetPopOutWidth(Width: number?)
        if Width ~= nil then
            assert(typeof(Width) == "number", "Width must be a number or nil")
            assert(Width >= 0, "Width must be higher than 0")
        end

        Box.PopOutWidth = Width
        ApplyPopOutWidth()
    end

    --// Drag Handler
    local function StopDrag()
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        if DragState ~= "Idle" or Box.Destroyed or not Library.GroupboxDrag or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Turns groupbox dragging (pop out) on / off. Turning it off docks every floating groupbox again \\--
function Library:SetGroupboxDrag(Enabled: boolean)
    Library.GroupboxDrag = Enabled == true
    if Library.GroupboxDrag then
        return
    end

    for _, Tab in Library.Tabs do
        if typeof(Tab) ~= "table" then
            continue
        end

        for _, Box in Tab.Groupboxes or {} do
            if Box.PoppedOut and Box.SetPoppedOut then
                Box:SetPoppedOut(false)
            end
        end
        for _, Box in Tab.Tabboxes or {} do
            if Box.PoppedOut and Box.SetPoppedOut then
                Box:SetPoppedOut(false)
            end
        end
    end
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })

            Library:ApplyLucideIcon(IconImage, CustomIcon)
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableImageButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Library.WindowContainer ~= nil and Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        Table.Active = false
        CurrentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if CurrentMenu == Table then
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)

local TooltipMeasureId = 0
local LastTooltipText = ""
local LastTooltipMaxWidth = 0

local function UpdateTooltipSize(Force: boolean?)
    if Library.Unloaded or not TooltipLabel.Visible then
        return
    end

    local MaxWidth = math.max(
        40,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    if
        not Force
        and TooltipLabel.Text == LastTooltipText
        and math.abs(MaxWidth - LastTooltipMaxWidth) < 1
        and TooltipLabel.Size.X.Offset > 0
    then
        return
    end

    TooltipMeasureId += 1
    local MeasureId = TooltipMeasureId
    local Text = TooltipLabel.Text

    local X, Y = Library:GetTextBounds(Text, TooltipLabel.FontFace, TooltipLabel.TextSize, MaxWidth)
    if MeasureId ~= TooltipMeasureId or TooltipLabel.Text ~= Text then
        return
    end

    LastTooltipText = Text
    LastTooltipMaxWidth = MaxWidth
    TooltipLabel.Size = UDim2.fromOffset(X + 8, Y + 4)
end

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateTooltipSize(false)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        local TooltipText = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        if Library.Searching and Library.SearchQuery ~= "" then
            TooltipText = BuildHighlightedText(TooltipText, Library.SearchQuery) or TooltipText
        end
        TooltipLabel.Text = TooltipText
        TooltipLabel.Position = UDim2.fromOffset(
            Mouse.X + (Library.ShowCustomCursor and 8 or 14),
            Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
        )
        TooltipLabel.Visible = true
        UpdateTooltipSize(true)

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

--// Grid popup shared by dropdowns and lists (Object needs Values, Value, Display, RunChanged, ...) \\--
local function OpenValueModal(Object, Info, Idx)
    if Object.Disabled or Object.Destroyed then
        return
    end

    local Window = Library.Window
    if not (Window and Window.AddDialog) or Library.ActiveDialog then
        return
    end

    if Object.BeforeModalOpen then
        Object.BeforeModalOpen()
    end

    local Columns = math.max(1, math.floor(tonumber(Info.ModalColumns) or 3))
    local CellHeight, CellGap = 26, 6

    local Dialog
    local GridScroll
    local Cells = {}
    local Query = ""

    local function GetEntries()
        local Entries = {}
        local Values = Object.Values
        local IsDictionary = not IsSequentialArray(Values)

        for Key, RawValue in Values do
            local Value = IsDictionary and Key or RawValue
            local Text = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

            if Query ~= "" then
                local Matched = FuzzyScore(StripRichText(Text):lower(), Query)
                if not Matched then
                    continue
                end
            end

            local IsDisabled = table.find(Object.DisabledValues, Value) ~= nil
                or (RawValue ~= nil and RawValue ~= Value and table.find(Object.DisabledValues, RawValue) ~= nil)

            table.insert(Entries, { Key = Key, Value = Value, Text = Text, Disabled = IsDisabled })
        end

        if IsDictionary then
            table.sort(Entries, function(A, B)
                return StripRichText(A.Text):lower() < StripRichText(B.Text):lower()
            end)
        else
            table.sort(Entries, function(A, B)
                return A.Key < B.Key
            end)
        end

        return Entries
    end

    local function IsSelected(Value)
        if Info.Multi then
            return Object.Value[Value] == true
        end

        return Object.Value == Value
    end

    local function UpdateDescription()
        if not Dialog or Dialog.Destroyed then
            return
        end

        if Info.Multi then
            Dialog:SetDescription(string.format("%d / %d selected", Object:GetActiveValues(true), GetTableSize(Object.Values)))
        end
    end

    local function UpdateCell(Cell)
        local Selected = IsSelected(Cell.Entry.Value)

        Cell.Label.TextTransparency = Cell.Entry.Disabled and 0.8 or (Selected and 0 or 0.5)
        Cell.Button.BackgroundTransparency = Selected and 0.75 or 0

        local ButtonRegistry = Library.Registry[Cell.Button]
        if ButtonRegistry then
            ButtonRegistry.BackgroundColor3 = Selected and "AccentColor" or "MainColor"
        end
        Cell.Button.BackgroundColor3 = Selected and Library.Scheme.AccentColor or Library.Scheme.MainColor

        local StrokeRegistry = Library.Registry[Cell.Stroke]
        if StrokeRegistry then
            StrokeRegistry.Color = Selected and "AccentColor" or "OutlineColor"
        end
        Cell.Stroke.Color = Selected and Library.Scheme.AccentColor or Library.Scheme.OutlineColor
    end

    local function Commit()
        Object:Display() --// refreshes the cells through ModalRefresh
        if Object.AfterModalCommit then
            Object.AfterModalCommit()
        end

        Library:UpdateDependencyBoxes()
        Object:RunChanged()
    end

    local function ToggleEntry(Entry)
        if Entry.Disabled then
            return
        end

        if Info.Multi then
            local Selected = Object.Value[Entry.Value]
            if Selected and Object:GetActiveValues(true) == 1 and not Info.AllowNull then
                return
            end

            Object.Value[Entry.Value] = (not Selected) and true or nil
            Commit()
            return
        end

        if Object.Value == Entry.Value then
            if Info.AllowNull then
                Object.Value = nil
                Commit()
            end
        else
            Object.Value = Entry.Value
            Commit()
        end

        Dialog:Dismiss()
    end

    --// Applies to the values currently shown (so it respects the search box) and never touches disabled values \\--
    local function Bulk(Mode: string)
        if Info.Multi then
            local Before = table.clone(Object.Value)

            for _, Entry in GetEntries() do
                if Entry.Disabled then
                    continue
                end

                if Mode == "all" then
                    Object.Value[Entry.Value] = true
                elseif Mode == "none" then
                    Object.Value[Entry.Value] = nil
                elseif Mode == "invert" then
                    Object.Value[Entry.Value] = (not Object.Value[Entry.Value]) and true or nil
                end
            end

            if not Info.AllowNull and GetTableSize(Object.Value) == 0 then
                local Keep = Mode == "none" and next(Before) or nil
                Object.Value = Keep ~= nil and { [Keep] = true } or Before
            end
        elseif Mode == "none" and Info.AllowNull then
            Object.Value = nil
        end

        Commit()
    end

    local function Rebuild()
        for _, Cell in Cells do
            Cell.Button:Destroy()
        end
        table.clear(Cells)

        for Index, Entry in GetEntries() do
            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                LayoutOrder = Index,
                Text = "",
                Parent = GridScroll,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Button,
            })
            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })

            local Label = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = Entry.Text,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = Button,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                Parent = Label,
            })

            local Cell = { Button = Button, Label = Label, Stroke = Stroke, Entry = Entry }
            Button.MouseButton1Click:Connect(function()
                ToggleEntry(Entry)
            end)

            table.insert(Cells, Cell)
            UpdateCell(Cell)
        end
    end

    --// Dialog \\--
    local Footer = {}
    if Info.Multi then
        table.insert(Footer, { Id = "SelectAll", Title = "Select all", Variant = "Secondary", Order = 1, Callback = function() Bulk("all") end })
        table.insert(Footer, { Id = "DeselectAll", Title = "Deselect all", Variant = "Secondary", Order = 2, Callback = function() Bulk("none") end })
        table.insert(Footer, { Id = "Invert", Title = "Invert", Variant = "Secondary", Order = 3, Callback = function() Bulk("invert") end })
    elseif Info.AllowNull then
        table.insert(Footer, { Id = "Clear", Title = "Clear", Variant = "Secondary", Order = 1, Callback = function() Bulk("none") end })
    end
    table.insert(Footer, {
        Id = "Done",
        Title = "Done",
        Variant = "Primary",
        Order = 10,
        Callback = function(Dlg)
            Dlg:Dismiss()
        end,
    })

    Dialog = Window:AddDialog("DropdownModal_" .. tostring(Idx), {
        Title = Object.Text or "Select",
        Description = Info.Multi and "Select one or more values" or "Select a value",
        AutoDismiss = false,
        OutsideClickDismiss = true,
        FooterButtons = Footer,
    })
    Object.Modal = Dialog

    local TotalValues = GetTableSize(Object.Values)
    if Info.Searchable or TotalValues > 12 then
        local SearchInput = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            LayoutOrder = 1,
            PlaceholderText = "Search...",
            Size = UDim2.new(1, 0, 0, 22),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Dialog.Container,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = SearchInput,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = SearchInput,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchInput,
        })

        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            Query = NormalizeSearch(SearchInput.Text:lower())
            Rebuild()
        end)
    end

    local Rows = math.max(1, math.ceil(TotalValues / Columns))
    local GridHeight = math.clamp(
        Rows * CellHeight + (Rows - 1) * CellGap + 8,
        CellHeight + 8,
        8 * CellHeight + 7 * CellGap + 8
    )

    GridScroll = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        CanvasSize = UDim2.fromOffset(0, 0),
        LayoutOrder = 2,
        ScrollBarImageColor3 = "OutlineColor",
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.new(1, 0, 0, GridHeight),
        Parent = Dialog.Container,
    })
    New("UIGridLayout", {
        CellPadding = UDim2.fromOffset(CellGap, CellGap),
        CellSize = UDim2.new(1 / Columns, -math.ceil(CellGap * (Columns - 1) / Columns) - 1, 0, CellHeight),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = GridScroll,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 3),
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 3),
        Parent = GridScroll,
    })

    Object.ModalRefresh = function()
        if Dialog.Destroyed then
            Object.Modal, Object.ModalRefresh, Object.ModalRebuild = nil, nil, nil
            return
        end

        for _, Cell in Cells do
            UpdateCell(Cell)
        end
        UpdateDescription()
    end
    Object.ModalRebuild = function()
        if Dialog.Destroyed then
            Object.Modal, Object.ModalRefresh, Object.ModalRebuild = nil, nil, nil
            return
        end

        Rebuild()
        UpdateDescription()
    end

    Dialog:Resize()
    Rebuild()
    UpdateDescription()
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            MenuVisible = Info.NoUI ~= true,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil

        local function ApplyPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil

            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)

            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()

            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })
            if CheckIcon then
                Library:ApplyLucideIcon(CheckImage, CheckIcon)
            end

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            table.insert(KeyPicker.Connections, Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        local SetPickingState = function(State, SkipUpdate: boolean?)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            if SkipUpdate ~= true then
                (KeyPicker :: any):Update()
            end
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end

                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end

                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X / Library.DPIScale
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            local Disabled = ParentObj.Disabled == true

            if Disabled and Picking then
                SetPickingState(false, true)
            end

            KeyPicker:Display()

            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)

            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if Info.NoUI then
                return
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(KeyPicker.MenuVisible ~= false)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking or ParentObj.Disabled then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if ParentObj.Disabled then
                return
            end

            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        function KeyPicker:SetMenuVisibility(Visible: boolean)
            assert(typeof(Visible) == "boolean", "Visible must be a boolean")

            KeyPicker.MenuVisible = Visible
            KeyPicker:Update()
        end

        table.insert(KeyPicker.Connections, Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if HoldingKey then
                if KeyPicker.Mode == "Toggle" then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Hold" then
                    InputChanged = Input.Changed:Connect(function()
                        if KeyPicker:GetState() then
                            return
                        end

                        KeyPicker:Update()
                        if InputChanged and InputChanged.Connected then
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end

                KeyPicker:Update()
            end
        end))

        KeyPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, KeyPicker)

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            local ResizeGrabberIcon = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })
            if ResizeIcon then
                Library:ApplyLucideIcon(ResizeGrabberIcon, ResizeIcon)
            end

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                table.insert(ColorPicker.Connections, Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))

                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))

                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled: boolean)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0

            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            if ParentObj.Disabled then
                return
            end

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)

            if Disabled then
                if ColorMenu.Active then
                    ColorMenu:Close()
                end

                if ContextMenu.Active then
                    ContextMenu:Close()
                end
            end

            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, ColorPicker)

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then
            return nil
        end

        local Params = select(1, ...)
        local Text
        local MarginTop, MarginBottom = 0, 0
        local Thickness = 1

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
            Thickness = math.max(1, tonumber(Params.Thickness) or 1)
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, (Text and 16 or 8) + MarginTop + MarginBottom),
            Parent = Container,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, MarginBottom),
            PaddingTop = UDim.new(0, MarginTop),
            Parent = Holder,
        })

        local Inner = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = Inner,
        })

        --// Lines fade out towards the edges (and towards the text) instead of a flat 2px bar \\--
        local function CreateLine(Order: number, Points)
            local Line = New("Frame", {
                BackgroundColor3 = "OutlineColor",
                LayoutOrder = Order,
                Size = UDim2.new(0, 0, 0, Thickness),
                Parent = Inner,
            })
            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Grow,
                Parent = Line,
            })

            local Keypoints = {}
            for _, Point in Points do
                table.insert(Keypoints, NumberSequenceKeypoint.new(Point[1], Point[2]))
            end
            New("UIGradient", {
                Transparency = NumberSequence.new(Keypoints),
                Parent = Line,
            })

            return Line
        end

        if Text then
            CreateLine(1, { { 0, 1 }, { 0.7, 0.15 }, { 1, 0 } })
            New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.new(0, 0, 1, 0),
                Text = Text,
                TextSize = 13,
                TextTransparency = 0.45,
                Parent = Inner,
            })
            CreateLine(3, { { 0, 0 }, { 0.3, 0.15 }, { 1, 1 } })
        else
            CreateLine(1, { { 0, 1 }, { 0.2, 0.05 }, { 0.8, 0.05 }, { 1, 1 } })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",

            Parent = Groupbox,
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",

            Parent = Groupbox,
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X / Library.DPIScale
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            table.insert(Label.Connections, TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end))
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        Label.HighlightLabel = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick
                Info.Icon = Params.Icon or Params.IconName

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false
                Info.Icon = nil

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,
            Icon = Info.Icon,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Locked = false,

            Base = nil,
            Stroke = nil,
            Content = nil,
            Label = nil,
            IconImage = nil,

            Tween = nil,
            Type = "Button",

            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function ApplyButtonIcon(Button, IconName)
            local Content = Button.Content
            if not Content then
                return
            end

            local ParsedIcon = Library:GetCustomIcon(IconName)
            if ParsedIcon then
                local ColorKey = Button.Risky and "RedColor" or (ParsedIcon.Custom and "WhiteColor" or "FontColor")

                if not Button.IconImage then
                    Button.IconImage = New("ImageLabel", {
                        BackgroundTransparency = 1,
                        ImageColor3 = ColorKey,
                        LayoutOrder = 0,
                        Size = UDim2.fromOffset(14, 14),
                        Parent = Content,
                    })
                else
                    Button.IconImage.ImageColor3 = Library.Scheme[ColorKey]
                    Library.Registry[Button.IconImage].ImageColor3 = ColorKey
                end

                Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
                Button.IconImage.Visible = true
                Library:ApplyLucideIcon(Button.IconImage, ParsedIcon)
            elseif Button.IconImage then
                Button.IconImage.Visible = false
            end
        end

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            local Content = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, 16),
                Parent = Base,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Content,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Content,
            })

            Button.Content = Content
            Button.Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 16),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = Button.Disabled and 0.8 or 0.4,
                Parent = Content,
            })

            if Button.Risky then
                Button.Label.TextColor3 = Library.Scheme.RedColor
                Library.Registry[Button.Label].TextColor3 = "RedColor"
            end

            ApplyButtonIcon(Button, Button.Icon)

            return Base, Stroke
        end

        local function InitEvents(Button)
            table.insert(Button.Connections, Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()
                TweenService:Create(Button.Base, Library.TweenInfo, {
                    BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 5),
                }):Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenService:Create(Button.IconImage, Library.TweenInfo, {
                        ImageTransparency = 0,
                    }):Play()
                end
            end))
            table.insert(Button.Connections, Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()
                TweenService:Create(Button.Base, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.MainColor,
                }):Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenService:Create(Button.IconImage, Library.TweenInfo, {
                        ImageTransparency = 0.4,
                    }):Play()
                end
            end))

            table.insert(Button.Connections, Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    local IconWasVisible = false
                    if Button.IconImage then
                        IconWasVisible = Button.IconImage.Visible
                        Button.IconImage.Visible = false
                    end

                    Button.Label.Text = "Are you sure?"
                    Button.Label.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Label].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Label.Text = Button.Text
                    Button.Label.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Label].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Button.IconImage then
                        Button.IconImage.Visible = IconWasVisible
                    end

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait()
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end))
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        Button.HighlightLabel = Button.Label
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,
                Icon = Info.Icon,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,
                Locked = false,

                Base = nil,
                Stroke = nil,
                Content = nil,
                Label = nil,
                IconImage = nil,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            SubButton.HighlightLabel = SubButton.Label
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
                SubButton.Label.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                if SubButton.IconImage and SubButton.IconImage.Visible then
                    SubButton.IconImage.ImageTransparency = SubButton.Disabled and 0.8 or 0.4
                end

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
                Library:UpdateAddons(SubButton)
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Label.Text = Text
            end

            function SubButton:SetIcon(Icon: string?)
                SubButton.Icon = Icon
                ApplyButtonIcon(SubButton, Icon)
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.Connections then
                    for _, Connection in SubButton.Connections do
                        Connection:Disconnect()
                    end
                end

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Button.Label.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            if Button.IconImage and Button.IconImage.Visible then
                Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
            end

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
            Library:UpdateAddons(Button)
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Label.Text = Text
        end

        function Button:SetIcon(Icon: string?)
            Button.Icon = Icon
            ApplyButtonIcon(Button, Icon)
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker

        function Button:Destroy()
            Button.Destroyed = true

            if Button.Connections then
                for _, Connection in Button.Connections do
                    Connection:Disconnect()
                end
            end

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })
        if CheckIcon then
            Library:ApplyLucideIcon(CheckImage, CheckIcon)
        end

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.HighlightLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.HighlightLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
            BoxStroke.Transparency = Input.Disabled and 0.5 or 0

            Box.BackgroundColor3 = Input.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Box].BackgroundColor3 = Input.Disabled and "BackgroundColor" or "MainColor"
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            if Input.Disabled then
                return
            end

            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            Input:RunChanged()
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        Input.HighlightLabel = Label
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Input:UpdateColors()
        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        --// Compact: value text inside a 15px bar. Default: value on the title row + thin pill track with a round thumb \\--
        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = Info.Compact and 0 or 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 18),
            Text = "",
            Parent = Holder,
        })

        local Track = Bar
        if Info.Compact then
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Bar,
            })
        else
            Track = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 6),
                Parent = Bar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Track,
            })
        end

        local TextParent = Info.Compact and Bar or Holder
        local TextAnchor = Info.Compact and Vector2.new(0, 0) or Vector2.new(1, 0)
        local TextPosition = Info.Compact and UDim2.fromScale(0, 0) or UDim2.fromScale(1, 0)
        local TextBoxSize = Info.Compact and UDim2.fromScale(1, 1) or UDim2.new(0.6, 0, 0, 14)
        local TextAlignment = Info.Compact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Right

        local DisplayLabel = New("TextLabel", {
            AnchorPoint = TextAnchor,
            BackgroundTransparency = 1,
            Position = TextPosition,
            Size = TextBoxSize,
            Text = "",
            TextSize = 14,
            TextXAlignment = TextAlignment,
            ZIndex = Bar.ZIndex + 2,
            Parent = TextParent,
        })
        if Info.Compact then
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = DisplayLabel,
            })
        end

        local InputTextBox
        local InputTextBoxStroke
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                AnchorPoint = TextAnchor,
                BackgroundTransparency = 1,
                Position = TextPosition,
                Size = TextBoxSize,
                Text = "",
                TextSize = 14,
                TextXAlignment = TextAlignment,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = TextParent,
            })
            InputTextBoxStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Track.ZIndex + 1,
            Parent = Track,
        })

        local Thumb
        if Info.Compact then
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Bar,
                })
            )
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Fill,
                })
            )
        else
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Fill,
            })

            Thumb = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "FontColor",
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = Track.ZIndex + 2,
                Parent = Track,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Thumb,
            })
            New("UIStroke", {
                Color = "DarkColor",
                Thickness = 2,
                Transparency = 0.7,
                Parent = Thumb,
            })
        end

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
            if Thumb then
                Thumb.BackgroundTransparency = Slider.Disabled and 0.7 or 0
            end
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
            if Thumb then
                Thumb.Position = UDim2.fromScale(X, 0.5)
            end
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text

                    if AsNum then
                        if AsNum > Slider.Max then
                            InputTextBox.Text = tostring(Slider.Max)
                        elseif AsNum < Slider.Min then
                            InputTextBox.Text = tostring(Slider.Min)
                        end
                    end
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))

            table.insert(Slider.Connections, InputTextBox.Focused:Connect(function()
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "AccentColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "DarkColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.DarkColor,
                }):Play()
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        Slider.HighlightLabel = SliderLabel
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddRangeSlider(Idx, Info)
        if self.Destroyed then
            return nil
        end

        Info = Library:Validate(Info, Templates.RangeSlider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Default = typeof(Info.Default) == "table" and Info.Default or { Info.Min, Info.Max }
        local StartLow = math.clamp(tonumber(Default[1]) or Info.Min, Info.Min, Info.Max)
        local StartHigh = math.clamp(tonumber(Default[2]) or Info.Max, StartLow, Info.Max)

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Low = StartLow,
            High = StartHigh,
            Value = { StartLow, StartHigh },

            Min = Info.Min,
            Max = Info.Max,
            MinRange = math.max(0, tonumber(Info.MinRange) or 0),

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "RangeSlider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        --// Compact: value text inside a 15px bar. Default: value on the title row + thin pill track \\--
        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = Info.Compact and 0 or 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 18),
            Text = "",
            Parent = Holder,
        })

        local Track = Bar
        if Info.Compact then
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Bar,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Bar,
                })
            )
        else
            Track = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 6),
                Parent = Bar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Track,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Track.ZIndex + 1,
            Parent = Track,
        })
        if Info.Compact then
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Fill,
                })
            )
        else
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Fill,
            })
        end

        local function CreateHandle()
            local Handle = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "FontColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = Info.Compact and UDim2.new(0, 4, 1, 4) or UDim2.fromOffset(14, 14),
                ZIndex = Track.ZIndex + 2,
                Parent = Track,
            })
            New("UIStroke", {
                Color = "DarkColor",
                Parent = Handle,
            })
            if Info.Compact then
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                        Parent = Handle,
                    })
                )
            else
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Handle,
                })
            end

            return Handle
        end
        local LowHandle = CreateHandle()
        local HighHandle = CreateHandle()

        local TextParent = Info.Compact and Bar or Holder
        local TextAnchor = Info.Compact and Vector2.new(0, 0) or Vector2.new(1, 0)
        local TextPosition = Info.Compact and UDim2.fromScale(0, 0) or UDim2.fromScale(1, 0)
        local TextSize = Info.Compact and UDim2.fromScale(1, 1) or UDim2.new(0.6, 0, 0, 14)
        local TextAlignment = Info.Compact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Right

        local DisplayLabel = New("TextLabel", {
            AnchorPoint = TextAnchor,
            BackgroundTransparency = 1,
            Position = TextPosition,
            Size = TextSize,
            Text = "",
            TextSize = 14,
            TextXAlignment = TextAlignment,
            ZIndex = Bar.ZIndex + 3,
            Parent = TextParent,
        })
        if Info.Compact then
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = DisplayLabel,
            })
        end

        local InputTextBox
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                AnchorPoint = TextAnchor,
                BackgroundTransparency = 1,
                ClearTextOnFocus = false,
                Position = TextPosition,
                Size = TextSize,
                Text = "",
                TextSize = 14,
                TextXAlignment = TextAlignment,
                Visible = false,
                ZIndex = Bar.ZIndex + 4,
                Parent = TextParent,
            })
            if Info.Compact then
                New("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                    Color = "DarkColor",
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Parent = InputTextBox,
                })
            end
        end

        local function ToScale(Value: number): number
            if Slider.Max == Slider.Min then
                return 0
            end

            return (Value - Slider.Min) / (Slider.Max - Slider.Min)
        end

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            if InputTextBox then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            LowHandle.BackgroundTransparency = Slider.Disabled and 0.7 or 0
            HighHandle.BackgroundTransparency = Slider.Disabled and 0.7 or 0

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomText = nil
            if Info.FormatDisplayValue then
                CustomText = Info.FormatDisplayValue(Slider, Slider.Low, Slider.High)
            end

            if CustomText then
                DisplayLabel.Text = tostring(CustomText)
            else
                local Range = string.format(
                    "%s%s%s - %s%s%s",
                    Slider.Prefix,
                    Slider.Low,
                    Slider.Suffix,
                    Slider.Prefix,
                    Slider.High,
                    Slider.Suffix
                )

                DisplayLabel.Text = Info.Compact and string.format("%s: %s", Slider.Text, Range) or Range
            end

            local LowScale, HighScale = ToScale(Slider.Low), ToScale(Slider.High)
            Fill.Position = UDim2.fromScale(LowScale, 0)
            Fill.Size = UDim2.fromScale(HighScale - LowScale, 1)
            LowHandle.Position = UDim2.fromScale(LowScale, 0.5)
            HighHandle.Position = UDim2.fromScale(HighScale, 0.5)

            Slider.Value = { Slider.Low, Slider.High }
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Low, Slider.High)
            Library:SafeCallback(Slider.Changed, Slider.Low, Slider.High)
        end

        --// SetValue(Low, High) or SetValue({ Low, High }) \\--
        function Slider:SetValue(LowOrTable, HighValue)
            local NewLow, NewHigh = LowOrTable, HighValue
            if typeof(LowOrTable) == "table" then
                NewLow, NewHigh = LowOrTable[1], LowOrTable[2]
            end

            NewLow = math.clamp(Round(tonumber(NewLow) or Slider.Low, Slider.Rounding), Slider.Min, Slider.Max)
            NewHigh = math.clamp(Round(tonumber(NewHigh) or Slider.High, Slider.Rounding), Slider.Min, Slider.Max)

            if NewHigh < NewLow then
                NewLow, NewHigh = NewHigh, NewLow
            end
            if NewHigh - NewLow < Slider.MinRange then
                NewHigh = math.min(Slider.Max, NewLow + Slider.MinRange)
                NewLow = math.max(Slider.Min, NewHigh - Slider.MinRange)
            end

            if NewLow == Slider.Low and NewHigh == Slider.High then
                return
            end

            Slider.Low, Slider.High = NewLow, NewHigh
            Slider:Display()
            Slider:RunChanged()
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider.Max = Value
            Slider.Low, Slider.High = math.min(Slider.Low, Value), math.min(Slider.High, Value)
            Slider:Display()
            Slider:RunChanged()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider.Min = Value
            Slider.Low, Slider.High = math.max(Slider.Low, Value), math.max(Slider.High, Value)
            Slider:Display()
            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end

            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Numbers = {}
                for Token in InputTextBox.Text:gmatch("[^,;%s]+") do
                    local Number = tonumber(Token)
                    if Number then
                        table.insert(Numbers, Number)
                    end
                end

                if #Numbers >= 2 then
                    Slider:SetValue(Numbers[1], Numbers[2])
                end
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = string.format("%s, %s", Slider.Low, Slider.High)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            --// Pick the handle closest to where the press happened \\--
            local function GetScale(): number
                return math.clamp((Mouse.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            end

            local PressScale = GetScale()
            local LowDistance = math.abs(PressScale - ToScale(Slider.Low))
            local HighDistance = math.abs(PressScale - ToScale(Slider.High))

            local Dragging
            if LowDistance == HighDistance then
                Dragging = PressScale < ToScale(Slider.Low) and "Low" or "High"
            else
                Dragging = LowDistance < HighDistance and "Low" or "High"
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end
            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * GetScale()), Slider.Rounding)

                local OldLow, OldHigh = Slider.Low, Slider.High
                if Dragging == "Low" then
                    Slider.Low = math.clamp(Value, Slider.Min, Slider.High - Slider.MinRange)
                else
                    Slider.High = math.clamp(Value, Slider.Low + Slider.MinRange, Slider.Max)
                end

                Slider:Display()
                if Slider.Low ~= OldLow or Slider.High ~= OldHigh then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end
            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        Slider.HighlightLabel = SliderLabel
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = { Slider.Low, Slider.High }

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    --// List: like a dropdown, but the values are always visible (scrollable) and a button opens the grid popup \\--
    function Funcs:AddList(Idx, Info)
        if self.Destroyed then
            return nil
        end

        Info = Library:Validate(Info, Templates.List)

        local Groupbox = self
        local Container = Groupbox.Container

        local List = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,

            Multi = Info.Multi,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "List",
        }

        local ModalEnabled = Info.ModalButton ~= false
        local ItemHeight = 22
        local Rows = math.max(1, math.floor(tonumber(Info.Rows) or 6))
        local PoolSize = Rows + 2
        local Query = ""
        local Entries = {}
        local Pool = {}

        local Holder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = List.Visible,
            Parent = Container,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = Holder,
        })

        local Header = New("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Visible = List.Text ~= nil or ModalEnabled,
            Parent = Holder,
        })
        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, ModalEnabled and -22 or 0, 1, 0),
            Text = List.Text or "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })

        local ModalButton
        if ModalEnabled then
            ModalButton = New("ImageButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.fromOffset(14, 14),
                Parent = Header,
            })

            local GridIcon = Library:GetIcon("layout-grid")
            if GridIcon then
                Library:ApplyLucideIcon(ModalButton, GridIcon)
            else
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "::",
                    TextSize = 14,
                    Parent = ModalButton,
                })
            end

            table.insert(List.Connections, ModalButton.MouseEnter:Connect(function()
                if not List.Disabled then
                    TweenService:Create(ModalButton, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                end
            end))
            table.insert(List.Connections, ModalButton.MouseLeave:Connect(function()
                if not List.Disabled then
                    TweenService:Create(ModalButton, Library.TweenInfo, { ImageTransparency = 0.5 }):Play()
                end
            end))
            table.insert(List.Connections, ModalButton.MouseButton1Click:Connect(function()
                List:OpenModal()
            end))
        end

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundColor3 = "MainColor",
                ClearTextOnFocus = false,
                LayoutOrder = 2,
                PlaceholderText = "Search...",
                Size = UDim2.new(1, 0, 0, 22),
                Text = "",
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = SearchBox,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = SearchBox,
                })
            )
            local SearchStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = SearchBox,
            })

            table.insert(List.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[SearchStroke].Color = "AccentColor"
                TweenService:Create(SearchStroke, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
            end))
            table.insert(List.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[SearchStroke].Color = "OutlineColor"
                TweenService:Create(SearchStroke, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
            end))
        end

        local ListBox = New("Frame", {
            BackgroundColor3 = "MainColor",
            ClipsDescendants = true,
            LayoutOrder = 3,
            Size = UDim2.new(1, 0, 0, Rows * ItemHeight + 6),
            Parent = Holder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = ListBox,
            })
        )
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = ListBox,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3),
            PaddingTop = UDim.new(0, 3),
            Parent = ListBox,
        })

        local Items = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Size = UDim2.fromScale(1, 1),
            Parent = ListBox,
        })

        local function IsSelected(Value: any): boolean
            if List.Multi then
                return List.Value[Value] == true
            end

            return List.Value == Value
        end

        local function BuildEntries()
            table.clear(Entries)

            local Values = List.Values
            local IsDictionary = not IsSequentialArray(Values)

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue
                local Text = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local Score = 0
                if Query ~= "" then
                    local Matched, MatchScore = FuzzyScore(StripRichText(Text):lower(), Query)
                    if not Matched then
                        continue
                    end

                    Score = MatchScore
                end

                local IsDisabled = table.find(List.DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(List.DisabledValues, RawValue) ~= nil)

                table.insert(Entries, { Key = Key, Value = Value, Text = Text, Disabled = IsDisabled, Score = Score })
            end

            table.sort(Entries, function(A, B)
                if Query ~= "" and A.Score ~= B.Score then
                    return A.Score > B.Score
                end

                if IsDictionary then
                    return StripRichText(A.Text):lower() < StripRichText(B.Text):lower()
                end

                return A.Key < B.Key
            end)
        end

        local function CreateRow()
            local Row = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                Visible = false,
                Parent = Items,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            local Bar = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "AccentColor",
                Position = UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.fromOffset(2, 12),
                Visible = false,
                Parent = Button,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Bar,
            })

            local RowLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Button,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 6),
                Parent = RowLabel,
            })

            Row.Button, Row.Label, Row.Bar = Button, RowLabel, Bar

            function Row:Update()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected = IsSelected(Entry.Value)
                Row.Selected = Selected

                Button.Active = not List.Disabled
                Button.BackgroundTransparency = Selected and 0.82 or 1
                Bar.Visible = Selected
                RowLabel.TextTransparency = (Entry.Disabled or List.Disabled) and 0.8 or (Selected and 0 or 0.45)
            end

            table.insert(List.Connections, Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if Entry and not Entry.Disabled and not List.Disabled and not Row.Selected then
                    TweenService:Create(Button, Library.TweenInfo, { BackgroundTransparency = 0.93 }):Play()
                    TweenService:Create(RowLabel, Library.TweenInfo, { TextTransparency = 0.2 }):Play()
                end
            end))
            table.insert(List.Connections, Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if Entry and not Entry.Disabled and not List.Disabled and not Row.Selected then
                    TweenService:Create(Button, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(RowLabel, Library.TweenInfo, { TextTransparency = 0.45 }):Play()
                end
            end))

            table.insert(List.Connections, Button.MouseButton1Click:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.Disabled or List.Disabled then
                    return
                end

                local Selected = IsSelected(Entry.Value)
                if List.Multi then
                    if Selected and List:GetActiveValues(true) == 1 and not Info.AllowNull then
                        return
                    end

                    List.Value[Entry.Value] = (not Selected) and true or nil
                elseif Selected then
                    if not Info.AllowNull then
                        return
                    end

                    List.Value = nil
                else
                    List.Value = Entry.Value
                end

                List:Display()
                Library:UpdateDependencyBoxes()
                List:RunChanged()
            end))

            return Row
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreateRow())
        end

        function List:RefreshPool()
            local Total = #Entries
            local First = 1
            if Total > PoolSize then
                local ScrollY = Items.CanvasPosition.Y / Library.DPIScale
                First = math.clamp(math.floor(ScrollY / ItemHeight) + 1, 1, Total - PoolSize + 1)
            end

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = Entries[DataIndex]

                Row.Entry = Entry
                if not Entry then
                    Row.Button.Visible = false
                    continue
                end

                Row.Button.Visible = true
                Row.Button.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)
                Row.Label.Text = Entry.Text
                Row:Update()
            end
        end

        function List:BuildList()
            BuildEntries()
            Items.CanvasSize = UDim2.fromOffset(0, #Entries * ItemHeight)
            List:RefreshPool()

            if List.ModalRebuild then
                List.ModalRebuild()
            end
        end

        function List:Display()
            if Library.Unloaded then
                return
            end

            for _, Row in Pool do
                Row:Update()
            end

            if List.ModalRefresh then
                List.ModalRefresh()
            end
        end

        function List:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = List.Disabled and 0.8 or 0
            if ModalButton then
                ModalButton.ImageTransparency = List.Disabled and 0.8 or 0.5
            end

            for _, Row in Pool do
                Row:Update()
            end
        end

        function List:OnChanged(Func)
            List.Changed = Func
        end

        function List:RunChanged()
            if List.Disabled then
                return
            end

            Library:SafeCallback(List.Callback, List.Value)
            Library:SafeCallback(List.Changed, List.Value)
        end

        function List:GetActiveValues(ReturnCount)
            local Table = {}

            if List.Multi then
                for Value in List.Value do
                    table.insert(Table, Value)
                end
            elseif List.Value ~= nil then
                table.insert(Table, List.Value)
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local function ValueExists(Value: any): boolean
            if IsSequentialArray(List.Values) then
                return table.find(List.Values, Value) ~= nil
            end

            return List.Values[Value] ~= nil
        end

        function List:SetValue(Value)
            if List.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}
                for Item, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Item) then
                        Table[Item] = true
                    end
                end

                List.Value = Table
            elseif ValueExists(Value) then
                List.Value = Value
            elseif not Value then
                List.Value = nil
            end

            List:Display()
            if not List.Disabled then
                Library:UpdateDependencyBoxes()
            end

            List:RunChanged()
        end

        function List:SetValues(Values)
            List.Values = Values

            local Changed = false
            if List.Multi then
                for Value in List.Value do
                    if not ValueExists(Value) then
                        List.Value[Value] = nil
                        Changed = true
                    end
                end
            elseif List.Value ~= nil and not ValueExists(List.Value) then
                List.Value = nil
                Changed = true
            end

            List:BuildList()
            List:Display()

            if Changed then
                if not List.Disabled then
                    Library:UpdateDependencyBoxes()
                end

                List:RunChanged()
            end
        end

        function List:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            if not IsSequentialArray(List.Values) then
                if typeof(Values) == "string" then
                    List.Values[Values] = Values
                elseif IsSequentialArray(Values) then
                    for _, Item in Values do
                        List.Values[Item] = Item
                    end
                else
                    for Key, Item in Values do
                        List.Values[Key] = Item
                    end
                end
            elseif typeof(Values) == "table" then
                for _, Item in Values do
                    table.insert(List.Values, Item)
                end
            else
                table.insert(List.Values, Values)
            end

            List:BuildList()
        end

        function List:SetDisabledValues(DisabledValues)
            List.DisabledValues = DisabledValues
            List:BuildList()
        end

        function List:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, Item in DisabledValues do
                    table.insert(List.DisabledValues, Item)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(List.DisabledValues, DisabledValues)
            else
                return
            end

            List:BuildList()
        end

        function List:SetDisabled(Disabled: boolean)
            List.Disabled = Disabled

            if List.TooltipTable then
                List.TooltipTable.Disabled = List.Disabled
            end
            if Disabled then
                List:CloseModal()
            end

            List:UpdateColors()
            Library:UpdateDependencyBoxes()
        end

        function List:SetVisible(Visible: boolean)
            List.Visible = Visible

            Holder.Visible = List.Visible
            Groupbox:Resize()
        end

        function List:SetText(Text: string?)
            List.Text = Text
            Label.Text = Text or ""
            Header.Visible = Text ~= nil or ModalEnabled
        end

        function List:OpenModal()
            OpenValueModal(List, Info, Idx)
        end

        function List:CloseModal()
            local Modal = List.Modal
            if Modal and not Modal.Destroyed then
                Modal:Dismiss()
            end

            List.Modal = nil
            List.ModalRefresh = nil
            List.ModalRebuild = nil
        end

        table.insert(List.Connections, Items:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            List:RefreshPool()
        end))

        if SearchBox then
            table.insert(List.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                Query = NormalizeSearch(SearchBox.Text:lower())
                Items.CanvasPosition = Vector2.zero
                List:BuildList()
            end))
        end

        --// Defaults \\--
        local Defaults = {}
        do
            local Default = Info.Default
            local IsDictionary = not IsSequentialArray(List.Values)

            local function ResolveOne(Candidate)
                if IsDictionary then
                    return List.Values[Candidate] ~= nil and Candidate or nil
                end

                return table.find(List.Values, Candidate) ~= nil and Candidate or nil
            end

            if typeof(Default) == "table" then
                for _, Candidate in Default do
                    local Resolved = ResolveOne(Candidate)
                    if Resolved ~= nil then
                        table.insert(Defaults, Resolved)
                    end
                end
            elseif Default ~= nil then
                local Resolved = ResolveOne(Default)
                if Resolved ~= nil then
                    table.insert(Defaults, Resolved)
                end
            end
        end

        for _, Value in Defaults do
            if List.Multi then
                List.Value[Value] = true
            else
                List.Value = Value
                break
            end
        end

        if typeof(List.Tooltip) == "string" or typeof(List.DisabledTooltip) == "string" then
            List.TooltipTable = Library:AddTooltip(List.Tooltip, List.DisabledTooltip, ListBox)
            List.TooltipTable.Disabled = List.Disabled
        end

        List:BuildList()
        List:UpdateColors()
        Groupbox:Resize()

        List.Holder = Holder
        List.HighlightLabel = List.Text and Label or nil
        table.insert(Groupbox.Elements, List)

        List.Default = Defaults
        Options[Idx] = List

        function List:Destroy()
            List.Destroyed = true

            List:CloseModal()

            for _, Connection in List.Connections do
                Connection:Disconnect()
            end

            if List.TooltipTable then
                List.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, List)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return List
    end

    function Funcs:AddDropdown(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,
            KeepDisabledValuePosition = Info.KeepDisabledValuePosition == true,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local ModalEnabled = Info.ModalButton
        if ModalEnabled == nil then
            ModalEnabled = Info.Multi == true
        end
        local ModalReserve = ModalEnabled and 34 or 0

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = 3,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = New("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = DisplayContainer,
        })
        if ArrowIcon then
            Library:ApplyLucideIcon(ArrowImage, ArrowIcon)
        end

        local ModalButton
        if ModalEnabled then
            ModalButton = New("ImageButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.new(1, -18, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 4,
                Parent = DisplayContainer,
            })

            local GridIcon = Library:GetIcon("layout-grid")
            if GridIcon then
                Library:ApplyLucideIcon(ModalButton, GridIcon)
            else
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "::",
                    TextSize = 14,
                    ZIndex = 5,
                    Parent = ModalButton,
                })
            end

            table.insert(Dropdown.Connections, ModalButton.MouseEnter:Connect(function()
                if not Dropdown.Disabled then
                    TweenService:Create(ModalButton, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                end
            end))
            table.insert(Dropdown.Connections, ModalButton.MouseLeave:Connect(function()
                if not Dropdown.Disabled then
                    TweenService:Create(ModalButton, Library.TweenInfo, { ImageTransparency = 0.5 }):Play()
                end
            end))
            table.insert(Dropdown.Connections, ModalButton.MouseButton1Click:Connect(function()
                Dropdown:OpenModal()
            end))
        end

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), 0)
            end,
            function()
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                ArrowImage.ImageTransparency = Active and 0 or 0.5
                ArrowImage.Rotation = Active and 180 or 0

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = Active and Zero or Half
                DropdownCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Zero
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = 21
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or #FilteredEntries
            local Y = math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayImage.ImageTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
            if ModalButton then
                ModalButton.ImageTransparency = Dropdown.Disabled and 0.8 or 0.5
            end
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            Str = TruncateRichText(Str, 25, 22)

            DisplayButton.Text = (Str == "" and "---" or Str)

            if ValueImage then
                Library:ApplyLucideIcon(DisplayImage, ValueImage)
                DisplayImage.ImageTransparency = 0
            else
                DisplayImage.Image = ""
                DisplayImage.ImageTransparency = 1
            end

            DisplayButton.Size = ValueImage and UDim2.new(1, -8 - ModalReserve, 0, 21) or UDim2.new(1, -ModalReserve, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)

            if Dropdown.ModalRefresh then
                Dropdown.ModalRefresh()
            end
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            local Table = {}

            if Info.Multi then
                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function RecomputeFilteredEntries()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(SearchBox.Text:lower()) or ""
            local IsSearching = SearchQuery ~= ""

            local EnabledList, DisabledList = {}, {}
            local Pending = {}

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(StripRichText(FormattedValue):lower(), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    SortKey = Key,
                    MatchScore = MatchScore,
                    Order = #Pending + 1,
                }

                table.insert(Pending, Entry)
            end

            if IsSearching then
                --// Best matches first; ties fall back to original order \\--
                table.sort(Pending, function(A, B)
                    if A.MatchScore ~= B.MatchScore then
                        return A.MatchScore > B.MatchScore
                    end
                    return A.Order < B.Order
                end)
            elseif not IsDictionary then
                table.sort(Pending, function(A, B)
                    return A.SortKey < B.SortKey
                end)
            end

            table.clear(FilteredEntries)

            if Dropdown.KeepDisabledValuePosition then
                for _, Entry in Pending do
                    table.insert(FilteredEntries, Entry)
                end
                return
            end

            for _, Entry in Pending do
                if Entry.IsDisabled then
                    table.insert(DisabledList, Entry)
                else
                    table.insert(EnabledList, Entry)
                end
            end

            for _, Entry in EnabledList do
                table.insert(FilteredEntries, Entry)
            end
            for _, Entry in DisabledList do
                table.insert(FilteredEntries, Entry)
            end
        end

        local function GetFirstVisibleIndex()
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = MenuTable.Menu.CanvasPosition.Y / Library.DPIScale
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    continue
                end

                Row.Container.Visible = true
                Row.Container.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue

                if Entry.ValueImage then
                    Row.Image.Visible = true
                    Library:ApplyLucideIcon(Row.Image, Entry.ValueImage)
                    Row.Button.Size = UDim2.new(1, -18, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(0, 0)
                end

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            if Dropdown.Disabled then
                return
            end

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        local function StopDragSelect()
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button

            function Row:UpdateButton()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    Image.ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5
                end
            end

            table.insert(Dropdown.Connections, Button.MouseButton1Click:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end))

            table.insert(Dropdown.Connections, Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.25,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.5,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.InputBegan:Connect(function(StartInput)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end))

            return Row
        end

        function Dropdown:BuildDropdownList()
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)

            if Dropdown.ModalRebuild then
                Dropdown.ModalRebuild()
            end
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            Dropdown:RunChanged()
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if Changed then
                Dropdown:RunChanged()
            end
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            if Disabled then
                Dropdown:CloseModal()
            end
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()

            Library:UpdateDependencyBoxes()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        function Dropdown:SetDragSelect(Value: boolean)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        --// Modal popup: every value as a grid cell, with select all / deselect all / invert \\--
        function Dropdown:CloseModal()
            local Modal = Dropdown.Modal
            if Modal and not Modal.Destroyed then
                Modal:Dismiss()
            end

            Dropdown.Modal = nil
            Dropdown.ModalRefresh = nil
            Dropdown.ModalRebuild = nil
        end

        function Dropdown:OpenModal()
            OpenValueModal(Dropdown, Info, Idx)
        end

        Dropdown.BeforeModalOpen = function()
            MenuTable:Close()
        end
        Dropdown.AfterModalCommit = function()
            for _, Row in Pool do
                Row:UpdateButton()
            end
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, DisplayContainer.MouseButton1Click:Connect(ToggleDropdown))
        table.insert(Dropdown.Connections, DisplayButton.MouseButton1Click:Connect(ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        Dropdown.HighlightLabel = Dropdown.Text and Label or nil
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            Dropdown.Destroyed = true

            Dropdown:CloseModal()
            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = (Viewport.Object :: PVInstance):GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            Library:ApplyLucideIcon(ImageLabel, Icon)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    --// Multi-column rows: Groupbox:AddRow():AddToggle(...) / :AddDropdown(...) share one line (equal widths) \\--
    function Funcs:AddRow(Info)
        if self.Destroyed then
            return nil
        end

        Info = typeof(Info) == "table" and Info or {}

        local Groupbox = self
        local Container = Groupbox.Container

        local VerticalAlignment = Info.VerticalAlignment
        if typeof(VerticalAlignment) == "string" then
            VerticalAlignment = Enum.VerticalAlignment[VerticalAlignment]
        end

        local RowFrame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = Container,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            VerticalAlignment = VerticalAlignment or Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, tonumber(Info.Padding) or 8),
            Parent = RowFrame,
        })

        --// Behaves like a groupbox, but every element it creates lives in the row and is registered in the parent box \\--
        local Row = {
            Type = "Row",

            Connections = {},
            Destroyed = false,

            Holder = RowFrame,
            Container = RowFrame,

            Elements = Groupbox.Elements,
            DependencyBoxes = Groupbox.DependencyBoxes,

            Tab = Groupbox.Tab,
            IsKeyTab = Groupbox.IsKeyTab,

            Parent = Groupbox,
        }

        function Row:Resize()
            Groupbox:Resize()
        end

        local function RefreshVisible()
            if Row.Destroyed then
                return
            end

            local Any = false
            for _, Child in RowFrame:GetChildren() do
                if Child:IsA("GuiObject") and Child.Visible then
                    Any = true
                    break
                end
            end

            if RowFrame.Visible ~= Any then
                RowFrame.Visible = Any
                Groupbox:Resize()
            end
        end

        table.insert(Row.Connections, RowFrame.ChildAdded:Connect(function(Child)
            if not Child:IsA("GuiObject") then
                return
            end

            table.insert(Row.Connections, Child:GetPropertyChangedSignal("Visible"):Connect(RefreshVisible))
            RefreshVisible()
        end))
        table.insert(Row.Connections, RowFrame.ChildRemoved:Connect(function()
            task.defer(RefreshVisible)
        end))

        function Row:Destroy()
            Row.Destroyed = true

            local Members = {}
            for _, Element in Row.Elements do
                if Element.Holder and Element.Holder.Parent == RowFrame then
                    table.insert(Members, Element)
                end
            end
            for _, Element in Members do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, Connection in Row.Connections do
                Connection:Disconnect()
            end

            RowFrame:Destroy()
            Groupbox:Resize()
        end

        --// Lets the parent box clean the row's signals up when it gets destroyed \\--
        if Groupbox.Connections then
            table.insert(Groupbox.Connections, {
                Disconnect = function()
                    for _, Connection in Row.Connections do
                        Connection:Disconnect()
                    end
                end,
            })
        end

        setmetatable(Row, BaseGroupbox)
        return Row
    end

    --// Card: background (color / image), icon, title, description, tag, footer and buttons \\--
    -- Groupbox:AddCard({ Title = "Update", Description = "...", Image = 123, Buttons = { { Text = "Open", Variant = "Primary" } } })
    function Funcs:AddCard(...)
        if self.Destroyed then
            return nil
        end

        local First, Second = select(1, ...), select(2, ...)
        local Idx, Info
        if typeof(First) == "table" then
            Info = First
        else
            Idx, Info = First, Second
        end

        Info = Library:Validate(Info, Templates.Card)

        local Groupbox = self
        local Container = Groupbox.Container

        local Card = {
            Connections = {},
            Destroyed = false,

            Text = Info.Title,
            Title = Info.Title,
            Description = Info.Description,
            Footer = Info.Footer,
            Tag = Info.Tag,
            Tooltip = Info.Description, --// makes the description searchable

            Buttons = {},
            Callback = Info.Callback,

            Visible = Info.Visible,
            Type = "Card",
        }

        local Holder = New("Frame", {
            BackgroundColor3 = Info.BackgroundColor or "MainColor",
            BackgroundTransparency = Info.BackgroundTransparency,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, math.max(Info.Height, 40)),
            Visible = Card.Visible,
            Parent = Container,
        })
        local HolderCorner = New("UICorner", {
            CornerRadius = UDim.new(0, Info.CornerRadius or (Library.CornerRadius / 2)),
            Parent = Holder,
        })
        if Info.CornerRadius == nil then
            table.insert(Library.Corners, HolderCorner)
        end
        local HolderStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Holder,
        })

        --// Background image + readability overlay \\--
        local Background = New("ImageLabel", {
            BackgroundTransparency = 1,
            ImageTransparency = Info.ImageTransparency,
            ScaleType = Info.ImageScaleType,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            ZIndex = 1,
            Parent = Holder,
        })
        local Overlay = New("Frame", {
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            ZIndex = 2,
            Parent = Holder,
        })
        New("UIGradient", {
            Rotation = 0,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(1, 0.75),
            }),
            Parent = Overlay,
        })

        local ClickButton = New("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Visible = Info.Callback ~= nil,
            ZIndex = 3,
            Parent = Holder,
        })

        local Content = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 4,
            Parent = Holder,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = Content,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            Parent = Content,
        })

        --// Header: icon, title, tag \\--
        local Header = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 4,
            Parent = Content,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = Header,
        })

        local IconImage = New("ImageLabel", {
            ImageColor3 = "AccentColor",
            LayoutOrder = 1,
            Size = UDim2.fromOffset(Info.TitleSize + 4, Info.TitleSize + 4),
            Visible = false,
            ZIndex = 4,
            Parent = Header,
        })
        local TitleLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.new(0, 0, 0, 0),
            Text = Info.Title,
            TextSize = Info.TitleSize,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4,
            Parent = Header,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = TitleLabel,
        })

        local TagFrame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = "AccentColor",
            LayoutOrder = 3,
            Size = UDim2.fromOffset(0, 16),
            Visible = false,
            ZIndex = 4,
            Parent = Header,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = TagFrame,
        })
        local TagLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 16),
            Text = "",
            TextColor3 = "WhiteColor",
            TextSize = 11,
            ZIndex = 4,
            Parent = TagFrame,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = TagLabel,
        })

        local DescriptionLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 0),
            Text = Info.Description or "",
            TextSize = Info.DescriptionSize,
            TextTransparency = 0.25,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Visible = Info.Description ~= nil and Info.Description ~= "",
            ZIndex = 4,
            Parent = Content,
        })

        local ButtonsRow = New("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            Size = UDim2.new(1, 0, 0, 24),
            Visible = false,
            ZIndex = 4,
            Parent = Content,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ButtonsRow,
        })

        local FooterLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 4,
            Size = UDim2.new(1, 0, 0, 0),
            Text = Info.Footer or "",
            TextSize = 12,
            TextTransparency = 0.5,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = Info.Footer ~= nil and Info.Footer ~= "",
            ZIndex = 4,
            Parent = Content,
        })

        --// The card grows with its content (wrapped description, buttons, ...) \\--
        local function SyncHeight()
            if Card.Destroyed then
                return
            end

            local Height = math.ceil(math.max(Info.Height, 40, Content.AbsoluteSize.Y / Library.DPIScale))
            if Holder.Size.Y.Offset ~= Height then
                Holder.Size = UDim2.new(1, 0, 0, Height)
                Groupbox:Resize()
            end
        end
        table.insert(Card.Connections, Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(SyncHeight))

        --// Setters \\--
        function Card:SetTitle(Text: string)
            Card.Title, Card.Text = Text, Text
            TitleLabel.Text = Text
        end

        function Card:SetDescription(Text: string?)
            Card.Description, Card.Tooltip = Text, Text
            DescriptionLabel.Text = Text or ""
            DescriptionLabel.Visible = Text ~= nil and Text ~= ""
        end

        function Card:SetFooter(Text: string?)
            Card.Footer = Text
            FooterLabel.Text = Text or ""
            FooterLabel.Visible = Text ~= nil and Text ~= ""
        end

        function Card:SetTag(Text: string?)
            Card.Tag = Text
            TagLabel.Text = Text and tostring(Text) or ""
            TagFrame.Visible = Text ~= nil and tostring(Text) ~= ""
        end

        function Card:SetIcon(Icon: string?)
            local Parsed = Icon and Library:GetCustomIcon(Icon)
            IconImage.Visible = Parsed ~= nil
            if Parsed then
                Library:ApplyLucideIcon(IconImage, Parsed)
            end
        end

        function Card:SetImage(Image: string | number | nil)
            local Parsed = Image and Library:GetCustomIcon(Image)
            Background.Visible = Parsed ~= nil
            Overlay.Visible = Parsed ~= nil

            if Parsed then
                Library:ApplyLucideIcon(Background, Parsed)
            else
                Background.Image = ""
            end
        end

        function Card:SetImageTransparency(Transparency: number)
            Background.ImageTransparency = Transparency
        end

        function Card:SetBackgroundColor(Color: Color3 | string)
            Library.Registry[Holder] = Library.Registry[Holder] or {}

            if typeof(Color) == "string" then
                Library.Registry[Holder].BackgroundColor3 = Color
                Holder.BackgroundColor3 = Library.Scheme[Color] or Holder.BackgroundColor3
            else
                Library.Registry[Holder].BackgroundColor3 = nil
                Holder.BackgroundColor3 = Color
            end
        end

        function Card:SetBackgroundTransparency(Transparency: number)
            Holder.BackgroundTransparency = Transparency
        end

        function Card:SetHeight(Height: number)
            Info.Height = Height
            SyncHeight()
        end

        function Card:SetVisible(Visible: boolean)
            Card.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end

        function Card:OnClick(Func)
            Card.Callback = Func
            ClickButton.Visible = Func ~= nil
        end

        --// Buttons: { Text, Callback / Func, Variant = "Secondary" | "Primary" | "Destructive" | "Ghost", Disabled, Tooltip } \\--
        function Card:AddButton(ButtonInfo)
            ButtonInfo = typeof(ButtonInfo) == "table" and ButtonInfo or { Text = tostring(ButtonInfo) }

            local Button = {
                Text = ButtonInfo.Text or "Button",
                Func = ButtonInfo.Func or ButtonInfo.Callback,
                Variant = ButtonInfo.Variant or "Secondary",
                Disabled = ButtonInfo.Disabled == true,
                Visible = ButtonInfo.Visible ~= false,
                Type = "CardButton",
            }

            local BackgroundKey, TextKey = "MainColor", "FontColor"
            if Button.Variant == "Primary" then
                BackgroundKey, TextKey = "AccentColor", "WhiteColor"
            elseif Button.Variant == "Destructive" then
                BackgroundKey, TextKey = "DestructiveColor", "WhiteColor"
            end

            local Base = New("TextButton", {
                BackgroundColor3 = BackgroundKey,
                BackgroundTransparency = Button.Variant == "Ghost" and 1 or 0,
                LayoutOrder = #Card.Buttons + 1,
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextColor3 = TextKey,
                TextSize = 14,
                TextTransparency = 0.2,
                Visible = Button.Visible,
                ZIndex = 4,
                Parent = ButtonsRow,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Base,
            })

            local function Paint()
                Base.Active = not Button.Disabled
                Base.TextTransparency = Button.Disabled and 0.8 or 0.2
            end
            Paint()

            Base.MouseEnter:Connect(function()
                if not Button.Disabled then
                    TweenService:Create(Base, Library.TweenInfo, { TextTransparency = 0 }):Play()
                end
            end)
            Base.MouseLeave:Connect(function()
                if not Button.Disabled then
                    TweenService:Create(Base, Library.TweenInfo, { TextTransparency = 0.2 }):Play()
                end
            end)
            Base.MouseButton1Click:Connect(function()
                if not Button.Disabled then
                    Library:SafeCallback(Button.Func, Card)
                end
            end)

            if typeof(ButtonInfo.Tooltip) == "string" then
                Button.TooltipTable = Library:AddTooltip(ButtonInfo.Tooltip, nil, Base)
            end

            function Button:SetText(Text: string)
                Button.Text = Text
                Base.Text = Text
            end

            function Button:SetDisabled(Disabled: boolean)
                Button.Disabled = Disabled
                Paint()
            end

            function Button:SetVisible(Visible: boolean)
                Button.Visible = Visible
                Base.Visible = Visible
            end

            function Button:Destroy()
                if Button.TooltipTable then
                    Button.TooltipTable:Destroy()
                end
                Base:Destroy()

                local Index = table.find(Card.Buttons, Button)
                if Index then
                    table.remove(Card.Buttons, Index)
                end
                ButtonsRow.Visible = #Card.Buttons > 0
            end

            Button.Base = Base
            table.insert(Card.Buttons, Button)
            ButtonsRow.Visible = true

            return Button
        end

        function Card:ClearButtons()
            for Index = #Card.Buttons, 1, -1 do
                Card.Buttons[Index]:Destroy()
            end
        end

        --// Click on the whole card \\--
        table.insert(Card.Connections, ClickButton.MouseButton1Click:Connect(function()
            Library:SafeCallback(Card.Callback, Card)
        end))
        table.insert(Card.Connections, ClickButton.MouseEnter:Connect(function()
            Library.Registry[HolderStroke].Color = "AccentColor"
            TweenService:Create(HolderStroke, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
        end))
        table.insert(Card.Connections, ClickButton.MouseLeave:Connect(function()
            Library.Registry[HolderStroke].Color = "OutlineColor"
            TweenService:Create(HolderStroke, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
        end))

        --// Initial state \\--
        Card:SetIcon(Info.Icon)
        Card:SetImage(Info.Image)
        Card:SetTag(Info.Tag)
        for _, ButtonInfo in Info.Buttons do
            Card:AddButton(ButtonInfo)
        end

        if typeof(Info.BackgroundColor) == "Color3" then
            Library.Registry[Holder] = Library.Registry[Holder] or {}
        end

        Groupbox:Resize()
        task.defer(SyncHeight)

        Card.Holder = Holder
        Card.HighlightLabel = TitleLabel
        table.insert(Groupbox.Elements, Card)

        if Idx ~= nil then
            Options[Idx] = Card
        end

        function Card:Destroy()
            Card.Destroyed = true

            for _, Connection in Card.Connections do
                Connection:Disconnect()
            end

            for _, Button in Card.Buttons do
                if Button.TooltipTable then
                    Button.TooltipTable:Destroy()
                end
            end

            local CornerIdx = table.find(Library.Corners, HolderCorner)
            if CornerIdx then
                table.remove(Library.Corners, CornerIdx)
            end

            Holder:Destroy()

            local ElemIdx = table.find(Groupbox.Elements, Card)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            if Idx ~= nil then
                Options[Idx] = nil
            end
        end

        return Card
    end

    function Funcs:AddDependencyBox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" or Element.Type == "List" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        table.insert(Depbox.Connections, DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end))

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        table.insert(Depbox.Connections, DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end))

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 10),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 24)
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" or Element.Type == "List" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft = Library.NotifySide:lower() == "left"
    local XScale = IsLeft and 0 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, 0, RunningY)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y / Library.DPIScale + 8
    end
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local IsLeft = Side:lower() == "left"
    if IsLeft then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = if IsLeft then Vector2.new(0, 0) else Vector2.new(1, 0)
    end

    if Library.UpdateNotificationPositions then
        Library:UpdateNotificationPositions(true)
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = Info.Title ~= nil and tostring(Info.Title) or nil
        Data.TitleColor = Info.TitleColor

        Data.Description = Info.Description ~= nil and tostring(Info.Description) or nil
        Data.DescriptionColor = Info.DescriptionColor

        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist

        Data.Actions = Info.Actions -- { { Text = "Undo", Callback = function(Notification) end, Variant = "Primary", Dismiss = true } }
        Data.Progress = Info.Progress -- 0..1, makes a progress notification (Data:SetProgress)
        Data.AutoClose = Info.AutoClose
        Data.CloseDelay = Info.CloseDelay

        Data.Callback = typeof(Info.Callback) == "function" and Info.Callback or nil
        Data.Closable = Info.Closable == true

        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor

        Data.Volume = tonumber(Info.Volume) or 3
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
        Data.Volume = select(4, ...) or 3
    end
    Data.Destroyed = false
    Data.Count = 1
    Data.TimerToken = 0

    if Data.Progress ~= nil then
        Data.Progress = math.clamp(tonumber(Data.Progress) or 0, 0, 1)
        Data.Persist = true
    end

    --// Identical notifications stack instead of spamming the screen \--
    local GroupKey
    local WantsGroup = Library.GroupNotifications == true and not (typeof(Info) == "table" and Info.Group == false)
    if
        WantsGroup
        and not Data.Persist
        and Data.Actions == nil
        and Data.Steps == nil
        and typeof(Data.Time) ~= "Instance"
    then
        GroupKey = tostring(Data.Title) .. "\0" .. tostring(Data.Description)

        local Existing = NotifyGroups[GroupKey]
        if Existing and not Existing.Destroyed then
            Existing.Count += 1
            Existing:UpdateCount()
            Existing:StartTimer()

            return Existing
        end
    end

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local FakeBackground = New("Frame", {
        AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local ContentHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = ContentHolder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = ContentHolder,
    })

    local CloseButton
    if Data.Closable then
        CloseButton = New("ImageButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = CloseIcon and CloseIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = CloseIcon and CloseIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CloseIcon and CloseIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 6,
            Parent = Holder,
        })

        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                ImageTransparency = 0,
            }):Play()
        end)
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                ImageTransparency = 0.5,
            }):Play()
        end)
        CloseButton.MouseButton1Click:Connect(function()
            Data:Destroy("user")
        end)
    end

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentHolder,
    })

    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = Data.IconColor or "AccentColor",
                Parent = ContentContainer,
            })
            Library:ApplyLucideIcon(BigIconLabel, ParsedIcon)
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })

    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                ImageColor3 = Data.IconColor or "FontColor",
                Parent = TitleContainer,
            })
            Library:ApplyLucideIcon(IconLabel, ParsedIcon)
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (IconLabel and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextColor3 = Data.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextColor3 = Data.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    --// Action buttons \\--
    local ActionsWidth = 0
    if typeof(Data.Actions) == "table" and #Data.Actions > 0 then
        local ActionsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = ActionsHolder,
        })

        for Index, Action in Data.Actions do
            local Variant = Action.Variant or "Secondary"
            local BackgroundKey = "MainColor"
            local TextKey = "FontColor"
            if Variant == "Primary" then
                BackgroundKey, TextKey = "AccentColor", "WhiteColor"
            elseif Variant == "Destructive" then
                BackgroundKey, TextKey = "DestructiveColor", "WhiteColor"
            end

            local ActionText = tostring(Action.Text or Action.Title or ("Action " .. Index))
            local TextX = Library:GetTextBounds(ActionText, Library.Scheme.Font, 14)
            local ButtonWidth = TextX + 20

            local ActionButton = New("TextButton", {
                BackgroundColor3 = BackgroundKey,
                LayoutOrder = Index,
                Size = UDim2.fromOffset(ButtonWidth, 22),
                Text = ActionText,
                TextColor3 = TextKey,
                TextSize = 14,
                Parent = ActionsHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = ActionButton,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = ActionButton,
            })

            ActionsWidth += ButtonWidth + (Index > 1 and 6 or 0)

            ActionButton.MouseButton1Click:Connect(function()
                Library:SafeCallback(Action.Callback, Data)
                if Action.Dismiss ~= false then
                    Data:Destroy("action")
                end
            end)
        end
    end

    --// "xN" counter for stacked notifications \\--
    local CountBadge = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = "AccentColor",
        Position = UDim2.new(1, Data.Closable and -28 or -8, 0, 8),
        Size = UDim2.fromOffset(0, 16),
        Text = "x1",
        TextColor3 = "WhiteColor",
        TextSize = 12,
        Visible = false,
        ZIndex = 6,
        Parent = Holder,
    })
    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CountBadge,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = CountBadge,
    })

    function Data:UpdateCount()
        if Data.Destroyed then
            return
        end

        CountBadge.Text = "x" .. Data.Count
        CountBadge.Visible = Data.Count > 1
        Data:Resize()
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0
        local CloseWidth = (Data.Closable and 20 or 0) + (Data.Count > 1 and 34 or 0)
        local MaxTextWidth = math.max(
            40,
            (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - CloseWidth
        )

        if Title then
            local X, Y = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, MaxTextWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y = Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, MaxTextWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX, ActionsWidth) + 24 + ExtraWidth + CloseWidth, 0)

        if Library.Notifications[FakeBackground] then
            task.defer(function()
                if Data.Destroyed or not FakeBackground.Parent then
                    return
                end

                if FakeBackground.AbsoluteSize.Y <= 0 then
                    task.defer(function()
                        if Data.Destroyed or not FakeBackground.Parent then
                            return
                        end

                        Library:UpdateNotificationPositions(true)
                    end)
                    return
                end

                Library:UpdateNotificationPositions(true)
            end)
        end
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    --// Progress notifications: Library:Notify({ Title = "Loading", Progress = 0 }) then Data:SetProgress(0.5, "Half way") \\--
    function Data:SetProgress(Value, NewDescription)
        if Data.Destroyed or Data.Progress == nil then
            return
        end

        Value = math.clamp(tonumber(Value) or 0, 0, 1)
        Data.Progress = Value

        TweenService:Create(TimerFill, Library.TweenInfo, {
            Size = UDim2.fromScale(Value, 1),
        }):Play()

        if NewDescription ~= nil then
            Data:ChangeDescription(NewDescription)
        end

        if Value >= 1 and Data.AutoClose ~= false then
            task.delay(tonumber(Data.CloseDelay) or 1.5, function()
                Data:Destroy("complete")
            end)
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy(Reason)
        if Data.Destroyed then
            return
        end

        Reason = Reason or "script"
        Data.Destroyed = true

        if GroupKey and NotifyGroups[GroupKey] == Data then
            NotifyGroups[GroupKey] = nil
        end

        if Data.Callback then
            pcall(Data.Callback, Reason)
        end

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        if FakeBackground then
            local Idx = table.find(NotifyOrder, FakeBackground)
            if Idx then
                table.remove(NotifyOrder, Idx)
            end
        end

        Library:UpdateNotificationPositions()

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number" or Data.Progress ~= nil,
        Parent = ContentHolder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.Progress ~= nil then
        TimerFill.Size = UDim2.fromScale(Data.Progress, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = tonumber(Data.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Data.Holder = Holder

    if GroupKey then
        NotifyGroups[GroupKey] = Data
    end

    table.insert(NotifyOrder, FakeBackground)
    Library.Notifications[FakeBackground] = Data

    --// Stack limit: dismiss the oldest non-persistent notifications \\--
    local MaxNotifications = Library.MaxNotifications
    if typeof(MaxNotifications) == "number" and MaxNotifications > 0 then
        local Index, Guard = 1, 0
        while #NotifyOrder > MaxNotifications and Index <= #NotifyOrder and Guard < 100 do
            Guard += 1

            local Old = Library.Notifications[NotifyOrder[Index]]
            if Old and Old ~= Data and not Old.Persist and not Old.Destroyed then
                Old:Destroy("overflow") --// removes itself from NotifyOrder
            else
                Index += 1
            end
        end
    end

    Data:Resize()

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.defer(function()
        if not Data.Destroyed then
            Library:UpdateNotificationPositions(true)
        end
    end)

    --// (Re)starts the countdown, stacked notifications call this again \\--
    function Data:StartTimer()
        Data.TimerToken += 1
        local Token = Data.TimerToken

        if Data.TimerTween then
            StopTween(Data.TimerTween, true)
            Data.TimerTween = nil
        end

        if Data.Persist or Data.Destroyed then
            return
        end

        if typeof(Data.Time) == "Instance" then
            task.spawn(function()
                repeat
                    task.wait()
                until DeletedInstance or Data.Destroyed or Data.TimerToken ~= Token

                if Data.TimerToken == Token then
                    Data:Destroy("timer")
                end
            end)

            return
        end

        TimerFill.Size = UDim2.fromScale(1, 1)
        Data.TimerTween = TweenService:Create(
            TimerFill,
            TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            { Size = UDim2.fromScale(0, 1) }
        )
        Data.TimerTween:Play()

        task.delay(Data.Time, function()
            if Data.TimerToken == Token and not Data.Destroyed then
                Data:Destroy("timer")
            end
        end)
    end

    task.delay(Library.NotifyTweenInfo.Time, function()
        if not Data.Destroyed then
            Data:StartTimer()
        end
    end)

    return Data
end

--// Toolbar: top center controller (show / hide UI, keybind list, watermark, ... and your own buttons) \\--
function Library:CreateToolbar(Info)
    if Library.Toolbar then
        return Library.Toolbar
    end

    Info = Library:Validate(typeof(Info) == "table" and Info or {}, Templates.Toolbar)

    local Holder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(0.5, 0, 0, Info.Offset),
        Size = UDim2.fromOffset(0, 0),
        Visible = Info.Visible,
        ZIndex = 15,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local HolderScale = New("UIScale", {
        Parent = Holder,
    })
    table.insert(Library.Scales, HolderScale)
    HolderScale.Scale = Library.DPIScale

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 5),
        Parent = Holder,
    })

    local Toolbar = {
        Holder = Holder,
        Buttons = {},
        Destroyed = false,
    }
    local Order = 0

    function Toolbar:AddSeparator()
        Order += 1

        return New("Frame", {
            BackgroundColor3 = "OutlineColor",
            LayoutOrder = Order,
            Size = UDim2.fromOffset(1, Info.ButtonSize - 10),
            Parent = Holder,
        })
    end

    --// Info: Icon, Tooltip, Toggle (stays active), Active, Callback(Active), Visible, Order \\--
    function Toolbar:AddButton(ButtonInfo)
        ButtonInfo = typeof(ButtonInfo) == "table" and ButtonInfo or {}
        Order += 1

        local Button = {
            Type = "ToolbarButton",
            Destroyed = false,

            Active = ButtonInfo.Active == true,
            Toggle = ButtonInfo.Toggle == true,
            Callback = ButtonInfo.Callback,
            Visible = ButtonInfo.Visible ~= false,
            Tooltip = ButtonInfo.Tooltip,
            TooltipTable = nil,
        }

        local Base = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            LayoutOrder = tonumber(ButtonInfo.Order) or Order,
            Size = UDim2.fromOffset(Info.ButtonSize, Info.ButtonSize),
            Text = "",
            Visible = Button.Visible,
            Parent = Holder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Base,
            })
        )

        local Parsed = Library:GetCustomIcon(ButtonInfo.Icon)
        local Icon
        if Parsed then
            Icon = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageColor3 = Parsed.Custom and "WhiteColor" or "FontColor",
                ImageTransparency = 0.4,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(Info.IconSize, Info.IconSize),
                Parent = Base,
            })
            Library:ApplyLucideIcon(Icon, Parsed)
        else
            Icon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = tostring(ButtonInfo.Icon or "?"),
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Base,
            })
        end

        local function Paint()
            local Key = Button.Active and "AccentColor" or "FontColor"
            local Transparency = Button.Active and 0 or 0.4
            local Registry = Library.Registry[Icon]

            if Icon:IsA("ImageLabel") then
                if not (Parsed and Parsed.Custom) then
                    Icon.ImageColor3 = Library.Scheme[Key]
                    if Registry then
                        Registry.ImageColor3 = Key
                    end
                end

                TweenService:Create(Icon, Library.TweenInfo, { ImageTransparency = Transparency }):Play()
            else
                Icon.TextColor3 = Library.Scheme[Key]
                if Registry then
                    Registry.TextColor3 = Key
                end

                TweenService:Create(Icon, Library.TweenInfo, { TextTransparency = Transparency }):Play()
            end
        end
        Paint()

        function Button:SetActive(State: boolean, Silent: boolean?)
            Button.Active = State == true
            Paint()

            if not Silent then
                Library:SafeCallback(Button.Callback, Button.Active)
            end
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible
            Base.Visible = Visible
        end

        function Button:SetTooltip(Text: string?)
            Button.Tooltip = Text
            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
                Button.TooltipTable = nil
            end
            if typeof(Text) == "string" then
                Button.TooltipTable = Library:AddTooltip(Text, nil, Base)
            end
        end

        function Button:Destroy()
            Button.Destroyed = true

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end
            Base:Destroy()

            local Idx = table.find(Toolbar.Buttons, Button)
            if Idx then
                table.remove(Toolbar.Buttons, Idx)
            end
        end

        Base.MouseEnter:Connect(function()
            TweenService:Create(Base, Library.TweenInfo, { BackgroundTransparency = 0.7 }):Play()
        end)
        Base.MouseLeave:Connect(function()
            TweenService:Create(Base, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
        end)
        Base.MouseButton1Click:Connect(function()
            if Button.Toggle then
                Button:SetActive(not Button.Active)
            else
                Library:SafeCallback(Button.Callback)
            end
        end)

        Button:SetTooltip(Button.Tooltip)
        Button.Base = Base
        table.insert(Toolbar.Buttons, Button)

        return Button
    end

    function Toolbar:SetVisible(Visible: boolean)
        Holder.Visible = Visible
    end

    function Toolbar:Destroy()
        Toolbar.Destroyed = true
        Holder:Destroy()
        Library.Toolbar = nil
    end

    if Info.Draggable then
        Library:MakeDraggable(Holder, Holder, true)
    end

    Library.Toolbar = Toolbar
    return Toolbar
end

function Library:SetKeybindListVisible(Visible: boolean)
    if Library.KeybindFrame then
        Library.KeybindFrame.Visible = Visible
    end

    if Library.Toolbar and Library.Toolbar.KeybindButton then
        Library.Toolbar.KeybindButton:SetActive(Visible, true)
    end
end

--// Watermark: icon + title + dot separated segments (game, player, fps, ping, time and your own) \\--
function Library:CreateWatermark(Info)
    if Library.Watermark then
        return Library.Watermark
    end

    Info = Library:Validate(typeof(Info) == "table" and Info or {}, Templates.Watermark)

    local Holder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = "BackgroundColor",
        Position = typeof(Info.Position) == "UDim2" and Info.Position or UDim2.new(1, -6, 0, 6),
        Size = UDim2.fromOffset(0, 26),
        Visible = Info.Visible,
        ZIndex = 14,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local HolderScale = New("UIScale", {
        Parent = Holder,
    })
    table.insert(Library.Scales, HolderScale)
    HolderScale.Scale = Library.DPIScale

    local Inner = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = Holder,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = Inner,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = Inner,
    })

    --// Thin accent line on top that fades out on both sides \\--
    local TopLine = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 16,
        Parent = Holder,
    })
    New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, 0.1),
            NumberSequenceKeypoint.new(0.75, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = TopLine,
    })

    local IconImage = New("ImageLabel", {
        ImageColor3 = "AccentColor",
        LayoutOrder = 1,
        Size = UDim2.fromOffset(16, 16),
        Visible = false,
        Parent = Inner,
    })
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        Text = "",
        TextSize = 14,
        Parent = Inner,
    })

    local Watermark = {
        Holder = Holder,
        Label = Label,

        Title = Info.Title,
        Separator = Info.Separator,
        Segments = {},

        FPS = 60,
        Ping = 0,
        GameName = nil,

        Destroyed = false,
    }

    local function FindSegment(Id: string)
        for Index, Segment in Watermark.Segments do
            if Segment.Id == Id then
                return Segment, Index
            end
        end

        return nil, nil
    end

    function Watermark:Refresh()
        if Watermark.Destroyed then
            return
        end

        local Accent = Library.Scheme.AccentColor:ToHex()
        local Dim = Library:GetDarkerColor(Library.Scheme.FontColor):ToHex()

        local Parts = { string.format('<b><font color="#%s">%s</font></b>', Accent, tostring(Watermark.Title)) }
        for _, Segment in Watermark.Segments do
            if Segment.Visible == false then
                continue
            end

            local Text = Segment.Text
            if typeof(Text) == "function" then
                local Ok, Result = pcall(Text, Watermark)
                Text = Ok and Result or nil
            end

            if Text ~= nil and tostring(Text) ~= "" then
                table.insert(Parts, tostring(Text))
            end
        end

        Label.Text = table.concat(Parts, string.format(' <font color="#%s">%s</font> ', Dim, Watermark.Separator))
    end

    --// AddSegment("Id", "text" | function(Watermark) return "text" end) \\--
    function Watermark:AddSegment(Id: string, Text: any, Visible: boolean?)
        local Existing = FindSegment(Id)
        if Existing then
            Existing.Text = Text
            if Visible ~= nil then
                Existing.Visible = Visible
            end
        else
            table.insert(Watermark.Segments, { Id = Id, Text = Text, Visible = Visible ~= false })
        end

        Watermark:Refresh()
    end

    function Watermark:RemoveSegment(Id: string)
        local _, Index = FindSegment(Id)
        if Index then
            table.remove(Watermark.Segments, Index)
            Watermark:Refresh()
        end
    end

    function Watermark:SetSegmentVisible(Id: string, Visible: boolean)
        local Segment = FindSegment(Id)
        if Segment then
            Segment.Visible = Visible
            Watermark:Refresh()
        end
    end

    function Watermark:SetTitle(Title: string)
        Watermark.Title = Title
        Watermark:Refresh()
    end

    function Watermark:SetIcon(Icon: string?)
        local Parsed = Icon and Library:GetCustomIcon(Icon)
        IconImage.Visible = Parsed ~= nil
        if Parsed then
            Library:ApplyLucideIcon(IconImage, Parsed)
        end
    end

    function Watermark:SetVisible(Visible: boolean)
        Holder.Visible = Visible
        if Visible then
            Watermark:Refresh()
        end

        if Library.Toolbar and Library.Toolbar.WatermarkButton then
            Library.Toolbar.WatermarkButton:SetActive(Visible, true)
        end
    end

    function Watermark:SetPosition(Position: UDim2)
        Holder.Position = Position
    end

    function Watermark:Destroy()
        Watermark.Destroyed = true
        Holder:Destroy()
        Library.Watermark = nil
    end

    --// Built-in segments (toggle them with Watermark:SetSegmentVisible) \\--
    Watermark:AddSegment("game", function(Self)
        return Self.GameName
    end, Info.ShowGame)
    Watermark:AddSegment("player", function()
        return Library.LocalPlayer.DisplayName
    end, Info.ShowPlayer)
    Watermark:AddSegment("fps", function(Self)
        return string.format("%d fps", Self.FPS)
    end, Info.ShowFPS)
    Watermark:AddSegment("ping", function(Self)
        return string.format("%d ms", Self.Ping)
    end, Info.ShowPing)
    Watermark:AddSegment("time", function()
        return os.date("%H:%M")
    end, Info.ShowTime)

    for Index, Segment in Info.Segments do
        if typeof(Segment) == "table" then
            Watermark:AddSegment(Segment.Id or ("custom_" .. Index), Segment.Text, Segment.Visible)
        else
            Watermark:AddSegment("custom_" .. Index, Segment)
        end
    end

    task.spawn(function()
        local Ok, Product = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)

        Watermark.GameName = Ok and Product and Product.Name or game.Name
        Watermark:Refresh()
    end)

    local Frames, LastUpdate = 0, os.clock()
    Library:GiveSignal(RunService.Heartbeat:Connect(function()
        Frames += 1

        local Now = os.clock()
        if Now - LastUpdate < Info.Interval then
            return
        end

        Watermark.FPS = math.floor(Frames / (Now - LastUpdate) + 0.5)
        Frames, LastUpdate = 0, Now

        local Ok, Ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        Watermark.Ping = Ok and math.floor(Ping + 0.5) or 0

        if Holder.Visible then
            Watermark:Refresh()
        end
    end))

    Watermark:SetIcon(Info.Icon)
    Watermark:Refresh()

    if Info.Draggable then
        Library:MakeDraggable(Holder, Holder, true)
    end

    Library.Watermark = Watermark
    return Watermark
end

--// Console: built-in output window. Library.Console:Print() / Warn() / Error() / Success() / Debug() / Log(level, ...) \\--
function Library:CreateConsole(Info)
    if Library.Console then
        return Library.Console
    end

    Info = typeof(Info) == "table" and Info or {}

    local Folder = tostring(Info.Folder or "Octo")
    local SettingsPath = Folder .. "/console.json"
    local LogFolder = Folder .. "/logs"

    local HasFS = typeof(writefile) == "function"
        and typeof(readfile) == "function"
        and typeof(isfile) == "function"
        and typeof(isfolder) == "function"
        and typeof(makefolder) == "function"

    local StartClock = os.clock()

    local Levels = {
        info = {
            Tag = "INFO",
            Name = "Info",
            Color = function()
                return Library.Scheme.FontColor
            end,
        },
        warn = { Tag = "WARN", Name = "Warn", Color = Color3.fromRGB(255, 176, 46) },
        error = { Tag = "ERROR", Name = "Error", Color = Color3.fromRGB(255, 90, 90) },
        success = { Tag = "OK", Name = "Success", Color = Color3.fromRGB(80, 220, 120) },
        debug = { Tag = "DEBUG", Name = "Debug", Color = Color3.fromRGB(135, 145, 180) },
    }
    local LevelOrder = { "info", "warn", "error", "success", "debug" }

    local StackModes = { "Off", "Consecutive", "All" }
    local StampModes = { "Off", "Time", "Time + ms", "Uptime" }

    --// Settings (remembered between sessions) \\--
    local Defaults = {
        Stack = "Consecutive",
        AutoScroll = true,
        Timestamps = "Time",
        ShowTag = true,
        Wrap = true,
        TextSize = 14,
        MaxLines = 400,
        Capture = false,
        Mirror = false,
        ClickCopy = false,
    }
    local Settings = {}
    for Key, Value in Defaults do
        Settings[Key] = Value
    end
    Settings.Levels = { info = true, warn = true, error = true, success = true, debug = true }

    if HasFS and isfile(SettingsPath) then
        local Ok, Data = pcall(function()
            return HttpService:JSONDecode(readfile(SettingsPath))
        end)

        if Ok and typeof(Data) == "table" then
            for Key, Default in Defaults do
                if typeof(Data[Key]) == typeof(Default) then
                    Settings[Key] = Data[Key]
                end
            end

            if typeof(Data.Levels) == "table" then
                for _, Name in LevelOrder do
                    Settings.Levels[Name] = table.find(Data.Levels, Name) ~= nil
                end
            end

            if not table.find(StackModes, Settings.Stack) then
                Settings.Stack = Defaults.Stack
            end
            if not table.find(StampModes, Settings.Timestamps) then
                Settings.Timestamps = Defaults.Timestamps
            end
            Settings.TextSize = math.clamp(Settings.TextSize, 10, 20)
            Settings.MaxLines = math.clamp(math.floor(Settings.MaxLines), 50, 2000)
        end
    end

    local SaveToken = 0
    local function SaveSettings()
        if not HasFS then
            return
        end

        SaveToken += 1
        local Token = SaveToken

        task.delay(0.6, function()
            if Token ~= SaveToken then
                return
            end

            local Data = {}
            for Key in Defaults do
                Data[Key] = Settings[Key]
            end

            Data.Levels = {}
            for _, Name in LevelOrder do
                if Settings.Levels[Name] then
                    table.insert(Data.Levels, Name)
                end
            end

            if not isfolder(Folder) then
                pcall(makefolder, Folder)
            end
            pcall(writefile, SettingsPath, HttpService:JSONEncode(Data))
        end)
    end

    --// State \\--
    local Entries = {}
    local ByKey = {}
    local IdCounter = 0
    local Query = ""

    local Console = {
        Entries = Entries,
        Settings = Settings,

        Visible = false,
        Paused = false,
        Destroyed = false,
    }

    local Built = false
    local Dirty = false
    local StatusDirty = false
    local Stick = true
    local ScrollQueued = false
    local Syncing = false

    local Frame, Output, SearchBox, StatusLabel, CountLabel, JumpButton
    local SettingsOverlay, PauseButton
    local ControlIds = {}

    --// Formatting \\--
    local function LevelHex(Name: string): string
        local Color = Levels[Name].Color
        if typeof(Color) == "function" then
            Color = Color()
        end

        return Color:ToHex()
    end

    local function FormatEntry(Entry, Rich: boolean): string
        local Parts = {}
        local DimHex = Library:GetDarkerColor(Library.Scheme.FontColor):ToHex()

        local Mode = Settings.Timestamps
        if Mode ~= "Off" then
            local Stamp
            if Mode == "Uptime" then
                Stamp = string.format("%.2fs", Entry.Clock - StartClock)
            else
                Stamp = os.date("%H:%M:%S", Entry.Time)
                if Mode == "Time + ms" then
                    Stamp ..= string.format(".%03d", math.floor((Entry.Clock % 1) * 1000))
                end
            end

            table.insert(Parts, Rich and string.format('<font color="#%s">%s</font>', DimHex, Stamp) or Stamp)
        end

        if Settings.ShowTag then
            local Tag = Levels[Entry.Level].Tag
            table.insert(Parts, Rich and string.format('<font color="#%s"><b>%s</b></font>', LevelHex(Entry.Level), Tag) or Tag)
        end

        local Message = Entry.Text
        if not Rich then
            Message = StripRichText(Message)
        elseif Entry.Level ~= "info" then
            Message = string.format('<font color="#%s">%s</font>', LevelHex(Entry.Level), Message)
        end
        table.insert(Parts, Message)

        local Text = table.concat(Parts, " ")
        if Entry.Count > 1 then
            if Rich then
                Text ..= string.format(' <font color="#%s"><b>x%d</b></font>', Library.Scheme.AccentColor:ToHex(), Entry.Count)
            else
                Text ..= " x" .. Entry.Count
            end
        end

        return Text
    end

    local function Passes(Entry): boolean
        if not Settings.Levels[Entry.Level] then
            return false
        end

        if Query ~= "" and not TryFuzzyMatch(FormatEntry(Entry, true), Query) then
            return false
        end

        return true
    end

    local function UpdateRow(Entry)
        local Row, Label = Entry.Row, Entry.Label
        if not (Row and Row.Parent) then
            return
        end

        local Text = FormatEntry(Entry, true)
        if Query ~= "" then
            Text = BuildHighlightedText(Text, Query) or Text
        end

        Label.Text = Text
        Label.TextSize = Settings.TextSize
        Label.TextWrapped = Settings.Wrap
        Label.TextTruncate = Settings.Wrap and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
        Row.Visible = Passes(Entry)
    end

    local function IsAtBottom(): boolean
        return Output.CanvasPosition.Y >= Output.AbsoluteCanvasSize.Y - Output.AbsoluteWindowSize.Y - 6
    end

    local function ScrollToBottom()
        if ScrollQueued or not Output then
            return
        end

        ScrollQueued = true
        task.spawn(function()
            RunService.RenderStepped:Wait() --// let the layout update first
            ScrollQueued = false

            if Output and Output.Parent then
                Output.CanvasPosition = Vector2.new(0, math.max(0, Output.AbsoluteCanvasSize.Y))
            end
        end)
    end

    local function CreateRow(Entry)
        local Row = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "FontColor",
            BackgroundTransparency = 1,
            LayoutOrder = Entry.Id,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = Output,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 3),
            Parent = Row,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 1),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 1),
            Parent = Row,
        })

        local Label = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Text = "",
            TextSize = Settings.TextSize,
            TextWrapped = Settings.Wrap,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = Row,
        })

        Row.MouseEnter:Connect(function()
            TweenService:Create(Row, Library.TweenInfo, { BackgroundTransparency = 0.94 }):Play()
        end)
        Row.MouseLeave:Connect(function()
            TweenService:Create(Row, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
        end)

        --// right click copies the line (left click too when "Click line to copy" is on) \\--
        Row.InputBegan:Connect(function(Input: InputObject)
            local RightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                and Input.UserInputState == Enum.UserInputState.Begin
            local LeftClick = Settings.ClickCopy and IsClickInput(Input)

            if RightClick or LeftClick then
                CopyToClipboard(FormatEntry(Entry, false))

                Row.BackgroundColor3 = Library.Scheme.AccentColor
                Row.BackgroundTransparency = 0.6
                TweenService:Create(Row, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                task.delay(0.45, function()
                    if Row.Parent then
                        Row.BackgroundColor3 = Library.Scheme.FontColor
                    end
                end)
            end
        end)

        Entry.Row, Entry.Label = Row, Label
        UpdateRow(Entry)
    end

    local function UpdateStatus()
        StatusDirty = false
        if not StatusLabel then
            return
        end

        local Hidden = 0
        for _, Entry in Entries do
            if Entry.Row and not Entry.Row.Visible then
                Hidden += 1
            end
        end

        StatusLabel.Text = string.format(
            "%d lines%s%s",
            #Entries,
            Hidden > 0 and string.format(" · %d hidden", Hidden) or "",
            Console.Paused and " · paused" or ""
        )
        CountLabel.Text = tostring(#Entries)
    end

    local function Flush()
        if not Built then
            return
        end

        local Start = 1
        for Index = #Entries, 1, -1 do
            if Entries[Index].Row then
                Start = Index + 1
                break
            end
        end

        local Created = 0
        for Index = Start, #Entries do
            if Created >= 120 then
                return --// keeps Dirty set, the rest follows next frame
            end

            CreateRow(Entries[Index])
            Created += 1
        end

        Dirty = false
        StatusDirty = true

        if Stick and Settings.AutoScroll then
            ScrollToBottom()
        end
    end

    local function Trim()
        while #Entries > Settings.MaxLines do
            local Old = table.remove(Entries, 1)
            if Old.Row then
                Old.Row:Destroy()
            end
            if ByKey[Old.Key] == Old then
                ByKey[Old.Key] = nil
            end
        end

        StatusDirty = true
    end

    function Console:Refresh()
        for _, Entry in Entries do
            if Entry.Row then
                UpdateRow(Entry)
            end
        end

        StatusDirty = true
    end

    --// Output API \\--
    function Console:Add(Level: string, Text: any)
        if Console.Destroyed then
            return nil
        end

        if not Levels[Level] then
            Level = "info"
        end
        Text = tostring(Text)

        local Key = Level .. "\0" .. Text
        local Existing
        if Settings.Stack == "Consecutive" then
            local Last = Entries[#Entries]
            if Last and Last.Key == Key then
                Existing = Last
            end
        elseif Settings.Stack == "All" then
            Existing = ByKey[Key]
        end

        if Settings.Mirror and not Settings.Capture then
            local Plain = StripRichText(Text)
            if Level == "warn" or Level == "error" then
                warn(Plain)
            else
                print(Plain)
            end
        end

        if Existing then
            Existing.Count += 1
            Existing.Time = os.time()
            Existing.Clock = os.clock()

            if Existing.Row then
                UpdateRow(Existing)
            end

            StatusDirty = true
            return Existing
        end

        IdCounter += 1
        local Entry = {
            Id = IdCounter,
            Level = Level,
            Text = Text,
            Key = Key,
            Count = 1,
            Time = os.time(),
            Clock = os.clock(),
        }

        table.insert(Entries, Entry)
        ByKey[Key] = Entry
        Trim()

        Dirty = true
        return Entry
    end

    local function Join(...): string
        local Packed = table.pack(...)
        local Out = {}

        for Index = 1, Packed.n do
            local Value = Packed[Index]
            if typeof(Value) == "string" then
                Out[Index] = Value --// strings keep their rich text / <c> markup
            elseif typeof(Value) == "table" then
                local Ok, Json = pcall(HttpService.JSONEncode, HttpService, Value)
                Out[Index] = EscapeRichText(Ok and Json or tostring(Value))
            else
                Out[Index] = EscapeRichText(tostring(Value))
            end
        end

        return table.concat(Out, " ")
    end

    function Console:Log(Level: string, ...)
        return Console:Add(Level, Join(...))
    end
    function Console:Print(...)
        return Console:Add("info", Join(...))
    end
    Console.Info = Console.Print
    function Console:Warn(...)
        return Console:Add("warn", Join(...))
    end
    function Console:Error(...)
        return Console:Add("error", Join(...))
    end
    function Console:Success(...)
        return Console:Add("success", Join(...))
    end
    function Console:Debug(...)
        return Console:Add("debug", Join(...))
    end

    function Console:Clear()
        for _, Entry in Entries do
            if Entry.Row then
                Entry.Row:Destroy()
            end
        end

        table.clear(Entries)
        table.clear(ByKey)
        StatusDirty = true
    end

    function Console:GetText(): string
        local Lines = {}
        for _, Entry in Entries do
            table.insert(Lines, FormatEntry(Entry, false))
        end

        return table.concat(Lines, "\n")
    end

    function Console:Copy()
        if not setclipboard then
            return Library:Notify({ Title = "Console", Description = "Your executor has no clipboard function.", Time = 3 })
        end

        setclipboard(Console:GetText())
        Library:Notify({ Title = "Console", Description = string.format("Copied %d lines.", #Entries), Time = 2 })
    end

    function Console:Save(): string?
        if not HasFS then
            Library:Notify({ Title = "Console", Description = "Your executor has no file functions.", Time = 3 })
            return nil
        end

        for _, Path in { Folder, LogFolder } do
            if not isfolder(Path) then
                pcall(makefolder, Path)
            end
        end

        local Path = string.format("%s/console_%s.txt", LogFolder, os.date("%Y%m%d_%H%M%S"))
        local Ok = pcall(writefile, Path, Console:GetText())
        Library:Notify({
            Title = "Console",
            Description = Ok and ("Saved to " .. Library:Copyable(Path)) or "Could not save the log.",
            Time = 4,
        })

        return Ok and Path or nil
    end

    --// Options \\--
    local CaptureConnection
    local function UpdateCapture()
        if Settings.Capture and not CaptureConnection then
            CaptureConnection = LogService.MessageOut:Connect(function(Message, MessageType)
                local Level = "info"
                if MessageType == Enum.MessageType.MessageWarning then
                    Level = "warn"
                elseif MessageType == Enum.MessageType.MessageError then
                    Level = "error"
                elseif MessageType == Enum.MessageType.MessageInfo then
                    Level = "debug"
                end

                Console:Add(Level, EscapeRichText(Message))
            end)
        elseif not Settings.Capture and CaptureConnection then
            CaptureConnection:Disconnect()
            CaptureConnection = nil
        end
    end

    local function SyncControl(Key: string)
        local Idx = ControlIds[Key]
        local Object = Idx and (Toggles[Idx] or Options[Idx])
        if not Object then
            return
        end

        local Value = Settings[Key]
        if Key == "Levels" then
            Value = {}
            for _, Name in LevelOrder do
                if Settings.Levels[Name] then
                    Value[Levels[Name].Name] = true
                end
            end
        end

        Syncing = true
        pcall(Object.SetValue, Object, Value)
        Syncing = false
    end

    function Console:SetOption(Key: string, Value: any)
        if Settings[Key] == nil then
            return
        end

        if Key == "Levels" then
            local Map = {}
            for _, Name in LevelOrder do
                Map[Name] = typeof(Value) == "table" and Value[Name] == true
            end
            Value = Map
        elseif Key == "Stack" then
            if not table.find(StackModes, Value) then
                return
            end
        elseif Key == "Timestamps" then
            if not table.find(StampModes, Value) then
                return
            end
        elseif Key == "TextSize" then
            Value = math.clamp(math.floor(tonumber(Value) or 14), 10, 20)
        elseif Key == "MaxLines" then
            Value = math.clamp(math.floor(tonumber(Value) or 400), 50, 2000)
        elseif typeof(Value) ~= typeof(Defaults[Key]) then
            return
        end

        Settings[Key] = Value

        if Key == "Timestamps" or Key == "ShowTag" or Key == "Levels" or Key == "Wrap" or Key == "TextSize" then
            Console:Refresh()
        elseif Key == "MaxLines" then
            Trim()
        elseif Key == "Capture" then
            UpdateCapture()
        elseif Key == "AutoScroll" and Value and Built then
            Stick = true
            ScrollToBottom()
        end

        SyncControl(Key)
        SaveSettings()
    end

    function Console:SetPaused(Paused: boolean)
        Console.Paused = Paused == true
        if not Console.Paused then
            Dirty = true
        end

        if PauseButton then
            local Icon = Library:GetIcon(Console.Paused and "play" or "pause")
            if Icon then
                Library:ApplyLucideIcon(PauseButton, Icon)
            end
            PauseButton.ImageColor3 = Console.Paused and Library.Scheme.AccentColor or Library.Scheme.FontColor
            Library.Registry[PauseButton].ImageColor3 = Console.Paused and "AccentColor" or "FontColor"
        end

        StatusDirty = true
    end

    --// Settings popup \\--
    local Panel
    local function BuildSettings()
        if Panel then
            return
        end

        local Card = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            AutoButtonColor = false,
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.new(0, 290, 1, -16),
            Text = "",
            Parent = SettingsOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Card,
            })
        )
        Library:AddOutline(Card)

        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -44, 0, 34),
            Text = "Console settings",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card,
        })
        local CloseSettings = New("ImageButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            ImageColor3 = "FontColor",
            ImageTransparency = 0.45,
            Position = UDim2.new(1, -10, 0, 17),
            Size = UDim2.fromOffset(16, 16),
            Parent = Card,
        })
        local CloseIconData = Library:GetIcon("x")
        if CloseIconData then
            Library:ApplyLucideIcon(CloseSettings, CloseIconData)
        end
        CloseSettings.MouseButton1Click:Connect(function()
            SettingsOverlay.Visible = false
        end)
        Library:MakeLine(Card, {
            Position = UDim2.fromOffset(0, 34),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local Body = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(0, 35),
            ScrollBarThickness = 0,
            Size = UDim2.new(1, 0, 1, -35),
            Parent = Card,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = Body,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            Parent = Body,
        })

        Panel = {
            Container = Body,
            Elements = {},
            DependencyBoxes = {},
            Destroyed = false,
            Resize = function() end,
        }
        setmetatable(Panel, BaseGroupbox)

        local function Toggle(Key: string, Text: string, Tooltip: string?)
            local Idx = "Octo_Console_" .. Key
            ControlIds[Key] = Idx

            Panel:AddToggle(Idx, {
                Text = Text,
                Tooltip = Tooltip,
                Default = Settings[Key],
                Callback = function(Value)
                    if not Syncing then
                        Console:SetOption(Key, Value)
                    end
                end,
            })
        end

        local function Dropdown(Key: string, Text: string, Values: { string })
            local Idx = "Octo_Console_" .. Key
            ControlIds[Key] = Idx

            Panel:AddDropdown(Idx, {
                Text = Text,
                Values = Values,
                Default = Settings[Key],
                Callback = function(Value)
                    if not Syncing and Value then
                        Console:SetOption(Key, Value)
                    end
                end,
            })
        end

        local function Slider(Key: string, Text: string, Min: number, Max: number, Suffix: string?)
            local Idx = "Octo_Console_" .. Key
            ControlIds[Key] = Idx

            Panel:AddSlider(Idx, {
                Text = Text,
                Default = Settings[Key],
                Min = Min,
                Max = Max,
                Rounding = 0,
                Suffix = Suffix or "",
                Callback = function(Value)
                    if not Syncing then
                        Console:SetOption(Key, Value)
                    end
                end,
            })
        end

        Panel:AddDivider("Output")
        Dropdown("Stack", "Stack identical output", StackModes)
        Dropdown("Timestamps", "Timestamps", StampModes)
        Toggle("ShowTag", "Show level tag")
        Toggle("Wrap", "Word wrap")
        Toggle("AutoScroll", "Auto-scroll to latest")
        Slider("TextSize", "Text size", 10, 20)
        Slider("MaxLines", "Max lines", 50, 2000)

        local LevelValues = {}
        local LevelDefaults = {}
        for _, Name in LevelOrder do
            table.insert(LevelValues, Levels[Name].Name)
            if Settings.Levels[Name] then
                table.insert(LevelDefaults, Levels[Name].Name)
            end
        end
        ControlIds.Levels = "Octo_Console_Levels"
        Panel:AddDropdown("Octo_Console_Levels", {
            Text = "Show levels",
            Values = LevelValues,
            Multi = true,
            AllowNull = true,
            Default = LevelDefaults,
            Callback = function(Value)
                if Syncing then
                    return
                end

                local Map = {}
                for _, Name in LevelOrder do
                    Map[Name] = Value[Levels[Name].Name] == true
                end
                Console:SetOption("Levels", Map)
            end,
        })

        Panel:AddDivider("Behavior")
        Toggle("ClickCopy", "Click a line to copy it", "Right click always copies a line")
        Toggle("Capture", "Capture Roblox output", "Shows print / warn / error messages of the game in this console")
        Toggle("Mirror", "Mirror to Roblox output", "Also prints console lines to the Roblox output (ignored while capturing)")

        Panel:AddDivider("Actions")
        local Row = Panel:AddRow()
        Row:AddButton({ Text = "Copy all", Func = function() Console:Copy() end })
        Row:AddButton({ Text = "Save log", Func = function() Console:Save() end })
        Panel:AddButton({
            Text = "Reset settings",
            DoubleClick = true,
            Func = function()
                for Key, Value in Defaults do
                    Console:SetOption(Key, Value)
                end
                Console:SetOption("Levels", { info = true, warn = true, error = true, success = true, debug = true })
            end,
        })
    end

    --// Window \\--
    local function CreateIconButton(Parent: GuiObject, Order: number, IconName: string, Fallback: string, Callback: () -> ())
        local Button = New("ImageButton", {
            BackgroundTransparency = 1,
            ImageColor3 = "FontColor",
            ImageTransparency = 0.45,
            LayoutOrder = Order,
            Size = UDim2.fromOffset(18, 18),
            Parent = Parent,
        })

        local Icon = Library:GetIcon(IconName)
        if Icon then
            Library:ApplyLucideIcon(Button, Icon)
        else
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = Fallback,
                TextSize = 14,
                Parent = Button,
            })
        end

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, Library.TweenInfo, { ImageTransparency = 0 }):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, Library.TweenInfo, { ImageTransparency = 0.45 }):Play()
        end)
        Button.MouseButton1Click:Connect(Callback)

        return Button
    end

    local function BuildUI()
        if Built then
            return
        end
        Built = true

        Frame = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Position = typeof(Info.Position) == "UDim2" and Info.Position or UDim2.fromOffset(60, 110),
            Size = UDim2.fromOffset(tonumber(Info.Width) or 540, tonumber(Info.Height) or 320),
            Visible = false,
            ZIndex = 16,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        local FrameScale = New("UIScale", {
            Parent = Frame,
        })
        table.insert(Library.Scales, FrameScale)
        FrameScale.Scale = Library.DPIScale

        --// Header \\--
        local Header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 38),
            Parent = Frame,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = Header,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 10),
            Parent = Header,
        })

        local TitleIcon = New("ImageLabel", {
            ImageColor3 = "AccentColor",
            LayoutOrder = 1,
            Size = UDim2.fromOffset(16, 16),
            Visible = false,
            Parent = Header,
        })
        local TerminalIcon = Library:GetIcon("terminal")
        if TerminalIcon then
            TitleIcon.Visible = true
            Library:ApplyLucideIcon(TitleIcon, TerminalIcon)
        end

        New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.new(0, 0, 1, 0),
            Text = "Console",
            TextSize = 15,
            Parent = Header,
        })
        CountLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            Size = UDim2.new(0, 0, 1, 0),
            Text = "0",
            TextSize = 13,
            TextTransparency = 0.55,
            Parent = Header,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            LayoutOrder = 4,
            PlaceholderText = "Search output...",
            Size = UDim2.new(0, 0, 0, 24),
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = SearchBox,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = SearchBox,
            })
        )
        local SearchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })
        SearchBox.Focused:Connect(function()
            Library.Registry[SearchStroke].Color = "AccentColor"
            TweenService:Create(SearchStroke, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
        end)
        SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchStroke].Color = "OutlineColor"
            TweenService:Create(SearchStroke, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
        end)

        local SearchToken = 0
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            SearchToken += 1
            local Token = SearchToken

            task.delay(0.12, function()
                if Token ~= SearchToken then
                    return
                end

                Query = NormalizeSearch(SearchBox.Text:lower())
                Console:Refresh()
            end)
        end)

        PauseButton = CreateIconButton(Header, 5, "pause", "||", function()
            Console:SetPaused(not Console.Paused)
        end)
        CreateIconButton(Header, 6, "settings-2", "S", function()
            BuildSettings()
            SettingsOverlay.Visible = not SettingsOverlay.Visible
        end)
        CreateIconButton(Header, 7, "trash-2", "C", function()
            Console:Clear()
        end)
        CreateIconButton(Header, 8, "x", "X", function()
            Console:SetVisible(false)
        end)

        Library:MakeLine(Frame, {
            Position = UDim2.fromOffset(0, 38),
            Size = UDim2.new(1, 0, 0, 1),
        })

        --// Output \\--
        Output = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(0, 39),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Size = UDim2.new(1, 0, 1, -61),
            Parent = Frame,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 1),
            Parent = Output,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 6),
            Parent = Output,
        })

        --// Footer \\--
        Library:MakeLine(Frame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -22),
            Size = UDim2.new(1, 0, 0, 1),
        })
        StatusLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, -30, 0, 22),
            Text = "0 lines",
            TextSize = 13,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            Parent = StatusLabel,
        })

        local Grabber = New("ImageButton", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -4, 1, -4),
            Size = UDim2.fromOffset(14, 14),
            Parent = Frame,
        })
        if ResizeIcon then
            Library:ApplyLucideIcon(Grabber, ResizeIcon)
        end
        Grabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
            local StartSize = Frame.Size

            while IsDragInput(Input) and not Console.Destroyed do
                local Delta = (Vector2.new(Mouse.X, Mouse.Y) - StartMouse) / Library.DPIScale
                Frame.Size = UDim2.fromOffset(
                    math.max(360, StartSize.X.Offset + Delta.X),
                    math.max(200, StartSize.Y.Offset + Delta.Y)
                )

                RunService.RenderStepped:Wait()
            end
        end)

        --// "Jump to latest" button \\--
        JumpButton = New("TextButton", {
            AnchorPoint = Vector2.new(1, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = "AccentColor",
            Position = UDim2.new(1, -16, 1, -30),
            Size = UDim2.fromOffset(0, 22),
            Text = "Jump to latest",
            TextColor3 = "WhiteColor",
            TextSize = 13,
            Visible = false,
            Parent = Frame,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = JumpButton,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = JumpButton,
        })
        JumpButton.MouseButton1Click:Connect(function()
            Stick = true
            JumpButton.Visible = false
            ScrollToBottom()
        end)

        local function UpdateJump()
            JumpButton.Visible = not IsAtBottom()
        end
        Output:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Stick = IsAtBottom()
            UpdateJump()
        end)
        Output:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
            if Stick and Settings.AutoScroll then
                ScrollToBottom()
            else
                UpdateJump()
            end
        end)
        Output:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
            if Stick and Settings.AutoScroll then
                ScrollToBottom()
            end
        end)

        --// Settings popup overlay (the card is built the first time it opens) \\--
        SettingsOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 0.45,
            Position = UDim2.fromOffset(0, 39),
            Size = UDim2.new(1, 0, 1, -39),
            Text = "",
            Visible = false,
            Parent = Frame,
        })
        SettingsOverlay.MouseButton1Click:Connect(function()
            SettingsOverlay.Visible = false
        end)

        Library:MakeDraggable(Frame, Header, true)
        table.insert(Library.DraggableElements, Frame)

        Dirty = true
    end

    function Console:SetVisible(Visible: boolean)
        Visible = Visible == true
        if Console.Destroyed then
            return
        end

        if Visible then
            BuildUI()
        end

        Console.Visible = Visible
        if Frame then
            Frame.Visible = Visible
        end

        if Visible then
            Stick = true
            Flush()
            Console:Refresh()
            ScrollToBottom()
        end

        if Library.Toolbar and Library.Toolbar.ConsoleButton then
            Library.Toolbar.ConsoleButton:SetActive(Visible, true)
        end

        --// keeps the mouse free while only the console is open \\--
        local WindowInfo = Library.Window and Library.Window.WindowInfo
        if not WindowInfo or WindowInfo.UnlockMouseWhileOpen ~= false then
            ModalElement.Modal = Visible or Library.Toggled == true
        end
    end

    function Console:Show()
        Console:SetVisible(true)
    end
    function Console:Hide()
        Console:SetVisible(false)
    end
    function Console:Toggle()
        Console:SetVisible(not Console.Visible)
    end

    function Console:Destroy()
        Console.Destroyed = true

        if CaptureConnection then
            CaptureConnection:Disconnect()
            CaptureConnection = nil
        end

        local Idx = table.find(Library.DraggableElements, Frame)
        if Idx then
            table.remove(Library.DraggableElements, Idx)
        end

        if Frame then
            Frame:Destroy()
        end
        Library.Console = nil
    end

    Library:GiveSignal(RunService.Heartbeat:Connect(function()
        if Console.Destroyed or not Console.Visible then
            return
        end

        if Dirty and not Console.Paused then
            Flush()
        end
        if StatusDirty then
            UpdateStatus()
        end
    end))

    UpdateCapture()
    Library.Console = Console
    return Console
end

Library:CreateConsole()

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)

    local TabButtonsStyle = WindowInfo.TabButtonsStyle

    local SubPageStyle = WindowInfo.SubPageStyle
    local function NormalizeSubPageStyle()
        local Style = string.lower(tostring(SubPageStyle.Style))
        if Style ~= "pill" and Style ~= "underline" and Style ~= "flat" then
            Style = "pill"
        end

        SubPageStyle.Style = Style
        SubPageStyle.Gap = math.max(0, tonumber(SubPageStyle.Gap) or 4)
        SubPageStyle.Height = math.max(16, tonumber(SubPageStyle.Height) or 26)
        SubPageStyle.PaddingX = math.max(0, tonumber(SubPageStyle.PaddingX) or 10)
        SubPageStyle.TextSize = math.max(8, tonumber(SubPageStyle.TextSize) or 14)
        SubPageStyle.IndicatorHeight = math.max(1, tonumber(SubPageStyle.IndicatorHeight) or 2)
        SubPageStyle.ShowStroke = SubPageStyle.ShowStroke ~= false
        if typeof(SubPageStyle.CornerRadius) ~= "number" then
            SubPageStyle.CornerRadius = nil
        end
    end
    NormalizeSubPageStyle()

    local function NormalizeTabButtonsStyle()
        TabButtonsStyle.Height = math.max(24, tonumber(TabButtonsStyle.Height) or 40)
        TabButtonsStyle.TextSize = math.max(8, tonumber(TabButtonsStyle.TextSize) or 16)
        TabButtonsStyle.Gap = math.max(0, tonumber(TabButtonsStyle.Gap) or 0)
        TabButtonsStyle.Padding = math.max(0, tonumber(TabButtonsStyle.Padding) or 0)
        TabButtonsStyle.CornerRadius = math.max(0, tonumber(TabButtonsStyle.CornerRadius) or 0)
    end
    NormalizeTabButtonsStyle()

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64 + TabButtonsStyle.Padding * 2, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local SubPageHolder
    local SubPageList
    local SearchCollapsed = false
    local SetSearchCollapsed
    local TabsLayout, TabsPadding
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local BottomBackgroundCorner
    local FooterLabel
    local TopBar
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    --// Tab button metrics (height / text size are configurable through TabButtonsStyle) \\--
    local function GetTabMetrics(Compact: boolean)
        local Height = TabButtonsStyle.Height
        local PadV = math.floor(Height * (Compact and 0.15 or 0.275) + 0.5)
        local PadH = Compact and 6 or 12

        return PadV, PadH, math.max(8, Height - PadV * 2) + 12
    end

    local function ApplyTabEntry(Entry)
        local Compact = IsCompact and Entry.Icon ~= nil
        local PadV, PadH, LabelOffset = GetTabMetrics(Compact)

        if Entry.Button then
            Entry.Button.Size = UDim2.new(1, 0, 0, TabButtonsStyle.Height)
        end
        if Entry.Corner then
            Entry.Corner.CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius)
        end

        Entry.Padding.PaddingBottom = UDim.new(0, PadV)
        Entry.Padding.PaddingTop = UDim.new(0, PadV)
        Entry.Padding.PaddingLeft = UDim.new(0, PadH)
        Entry.Padding.PaddingRight = UDim.new(0, PadH)

        Entry.Label.TextSize = TabButtonsStyle.TextSize
        Entry.Label.Position = UDim2.fromOffset(LabelOffset, 0)
        Entry.Label.Size = UDim2.new(1, -LabelOffset, 1, 0)

        if Entry.Icon then
            Entry.Label.Visible = not IsCompact
            Entry.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end

        if Entry.Indicator then
            Entry.Indicator.Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight)
        end
    end

    local function ApplySectionEntry(Entry)
        Entry.Label.Visible = not IsCompact
        if Entry.Arrow then
            Entry.Arrow.Visible = not IsCompact
        end

        Entry.Line.Visible = Entry.Divider or IsCompact
        Entry.Line.Position = IsCompact and UDim2.new(0, 6, 0.5, 0) or UDim2.new(0, 6, 0, 0)
        Entry.Holder.Size = UDim2.new(1, 0, 0, IsCompact and 10 or 28)
    end

    local function ApplyTabButtonsStyle()
        TabsLayout.Padding = UDim.new(0, TabButtonsStyle.Gap)

        local Pad = UDim.new(0, TabButtonsStyle.Padding)
        TabsPadding.PaddingBottom = Pad
        TabsPadding.PaddingLeft = Pad
        TabsPadding.PaddingRight = Pad
        TabsPadding.PaddingTop = Pad

        for _, Entry in Library.TabButtons do
            ApplyTabEntry(Entry)
        end
        for _, Entry in Library.SidebarSections do
            ApplySectionEntry(Entry)
        end

        WindowInfo.MinSidebarWidth = math.max(WindowInfo.MinSidebarWidth, 64 + TabButtonsStyle.Padding * 2)
        WindowInfo.SidebarCompactWidth = math.max(WindowInfo.SidebarCompactWidth, 40 + TabButtonsStyle.Padding * 2)
    end

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        if WindowInfo.AccentLine ~= false then
            local TopAccent = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = "AccentColor",
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.new(1, -WindowInfo.CornerRadius * 2, 0, 1),
                ZIndex = 5,
                Parent = MainFrame,
            })
            New("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.3, 0.15),
                    NumberSequenceKeypoint.new(0.7, 0.15),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TopAccent,
            })
        end

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        if BackgroundIcon then
            Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
        end

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (BackgroundImage and MainFrame) then
                return
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
            if Icon then
                Library:ApplyLucideIcon(WindowIcon, Icon)
            end
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local X = Library:GetTextBounds(
            WindowInfo.Title,
            Library.Scheme.Font,
            20,
            (TitleHolder.AbsoluteSize.X / Library.DPIScale) - (WindowInfo.Icon and WindowInfo.IconSize.X.Offset + 6 or 0) - 12
        )
        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, X, 1, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            Parent = TitleHolder,
        })

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 16 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            LayoutOrder = 0,
            Size = UDim2.fromScale(0, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        --// Sub Pages (shown on the left of the search bar) \\--
        --// Sub page strip: fills the free space on the left of the search bar, scrolls horizontally and shows arrows on overflow \\--
        local SubPageWrapper = New("Frame", {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            LayoutOrder = 1,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = SubPageWrapper,
        })

        SubPageHolder = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X,
            Size = UDim2.fromScale(1, 1),
            Parent = SubPageWrapper,
        })
        SubPageList = New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left, --// Switches to Right while a tab description is shown \\--
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, SubPageStyle.Gap),
            Parent = SubPageHolder,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = SubPageHolder,
        })

        local SubPageArrowLeft, SubPageArrowRight
        local function CreateSubPageArrow(IsRight: boolean)
            local Arrow = New("TextButton", {
                AnchorPoint = Vector2.new(IsRight and 1 or 0, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(IsRight and 1 or 0, 0),
                Size = UDim2.new(0, 28, 1, 0),
                Text = "",
                Visible = false,
                ZIndex = 5,
                Parent = SubPageWrapper,
            })

            local Fade = New("Frame", {
                BackgroundColor3 = function()
                    return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
                end,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 6,
                Parent = Arrow,
            })
            New("UIGradient", {
                Transparency = NumberSequence.new(if IsRight then {
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.4, 0.1),
                    NumberSequenceKeypoint.new(1, 0),
                } else {
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.6, 0.1),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = Fade,
            })

            local ArrowImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(IsRight and 1 or 0, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.3,
                Position = UDim2.new(IsRight and 1 or 0, IsRight and -4 or 4, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 7,
                Parent = Arrow,
            })
            if ArrowIcon then
                Library:ApplyLucideIcon(ArrowImage, ArrowIcon, IsRight and 90 or -90)
            else
                ArrowImage.Visible = false
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = IsRight and ">" or "<",
                    TextSize = 16,
                    TextTransparency = 0.3,
                    ZIndex = 7,
                    Parent = Arrow,
                })
            end

            Library:GiveSignal(Arrow.MouseButton1Click:Connect(function()
                local MaxScroll = math.max(0, SubPageHolder.AbsoluteCanvasSize.X - SubPageHolder.AbsoluteSize.X)
                local Step = SubPageHolder.AbsoluteSize.X * 0.6
                local Target = math.clamp(SubPageHolder.CanvasPosition.X + (IsRight and Step or -Step), 0, MaxScroll)

                TweenService:Create(SubPageHolder, Library.DropdownTransitionInfo, {
                    CanvasPosition = Vector2.new(Target, 0),
                }):Play()
            end))

            return Arrow
        end
        SubPageArrowLeft = CreateSubPageArrow(false)
        SubPageArrowRight = CreateSubPageArrow(true)

        local function UpdateSubPageArrows()
            local MaxScroll = SubPageHolder.AbsoluteCanvasSize.X - SubPageHolder.AbsoluteSize.X
            local Position = SubPageHolder.CanvasPosition.X

            SubPageArrowLeft.Visible = Position > 1
            SubPageArrowRight.Visible = Position < MaxScroll - 1
        end

        local function UpdateSubPageCanvas()
            local Scale = Library.DPIScale
            local ContentX = SubPageList.AbsoluteContentSize.X / Scale + 16 --// + side padding
            local ViewX = SubPageHolder.AbsoluteSize.X / Scale

            --// Canvas is never smaller than the view so the buttons can stay right-aligned (next to the search bar) \\--
            SubPageHolder.CanvasSize = UDim2.fromOffset(math.max(ContentX, ViewX), 0)
            UpdateSubPageArrows()
        end
        Library:GiveSignal(SubPageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSubPageCanvas))
        Library:GiveSignal(SubPageHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSubPageCanvas))
        Library:GiveSignal(SubPageHolder:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(UpdateSubPageArrows))
        Library:GiveSignal(SubPageHolder:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSubPageArrows))

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            LayoutOrder = 2,
            PlaceholderText = WindowInfo.SearchbarCollapsible and "" or "Search",
            Size = WindowInfo.SearchbarCollapsible and UDim2.new(0, WindowInfo.SearchbarCollapsedWidth, 1, 0) or WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            local SearchIconImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
            Library:ApplyLucideIcon(SearchIconImage, SearchIcon)
        end

        --// Search bar collapse (icon only while unfocused and empty) \\--
        SearchCollapsed = WindowInfo.SearchbarCollapsible == true
        if SearchCollapsed then
            SearchBox.BackgroundTransparency = 1
            SearchBoxStroke.Transparency = 1
        end
        local SearchTween
        SetSearchCollapsed = function(Collapsed: boolean)
            if WindowInfo.SearchbarCollapsible ~= true then
                Collapsed = false
            end
            if SearchCollapsed == Collapsed then
                return
            end

            SearchCollapsed = Collapsed
            StopTween(SearchTween, true)

            SearchBox.PlaceholderText = Collapsed and "" or "Search"
            SearchTween = TweenService:Create(SearchBox, Library.DropdownTransitionInfo, {
                Size = Collapsed and UDim2.new(0, WindowInfo.SearchbarCollapsedWidth, 1, 0) or WindowInfo.SearchbarSize,
            })
            SearchTween:Play()

            TweenService:Create(SearchBox, Library.DropdownTransitionInfo, {
                BackgroundTransparency = Collapsed and 1 or 0,
            }):Play()
            TweenService:Create(SearchBoxStroke, Library.DropdownTransitionInfo, {
                Transparency = Collapsed and 1 or 0,
            }):Play()
        end

        Library:GiveSignal(SearchBox.MouseEnter:Connect(function()
            if SearchCollapsed then
                TweenService:Create(SearchBox, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
            end
        end))
        Library:GiveSignal(SearchBox.MouseLeave:Connect(function()
            if SearchCollapsed then
                TweenService:Create(SearchBox, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            end
        end))

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            SetSearchCollapsed(false)
        end))
        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            if Trim(SearchBox.Text) == "" then
                SetSearchCollapsed(true)
            end
        end))

        --// Bottom Bar \\--
        local BottomClip = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 3,
            Parent = MainFrame,
        })

        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, math.max(20, WindowInfo.CornerRadius * 2)),
            ZIndex = 3,
            Parent = BottomClip,
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 3,
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 4,
            Parent = MainFrame,
        })
        BottomBackgroundCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
            BottomRightRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = BottomBackground,
        })

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        --// Resize Button \\--
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        local WindowResizeIcon = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })
        if ResizeIcon then
            Library:ApplyLucideIcon(WindowResizeIcon, ResizeIcon)
        end

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        TabsLayout = New("UIListLayout", {
            Padding = UDim.new(0, TabButtonsStyle.Gap),
            Parent = Tabs,
        })
        TabsPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, TabButtonsStyle.Padding),
            PaddingLeft = UDim.new(0, TabButtonsStyle.Padding),
            PaddingRight = UDim.new(0, TabButtonsStyle.Padding),
            PaddingTop = UDim.new(0, TabButtonsStyle.Padding),
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        Library.WindowContainer = Container
    end

    --// Window Table \\--
    local Window = {}
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
    end

    function Window:SetBackgroundImage(Image: string)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        BackgroundImage.Image = CustomImageManager.GetAsset(FileName)
                        BackgroundImage.ImageRectOffset = Vector2.zero
                        BackgroundImage.ImageRectSize = Vector2.zero
                    end
                end
            end
        end

        if not ValidIcon then
            BackgroundImage.Image = ""
            BackgroundImage.ImageRectOffset = Vector2.zero
            BackgroundImage.ImageRectSize = Vector2.zero
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 20)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        if ResizeButton then
            ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        end
        if BottomBackgroundCorner then
            BottomBackground.Size = UDim2.new(1, 0, 0, math.max(20, Radius * 2))
            BottomBackgroundCorner.BottomLeftRadius = RadiusUDim
            BottomBackgroundCorner.BottomRightRadius = RadiusUDim
        end

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then 
                        continue
                    end
   
                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Entry in Library.TabButtons do
            ApplyTabEntry(Entry)
        end
        for _, Entry in Library.SidebarSections do
            ApplySectionEntry(Entry)
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 16 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:SetSearchbarSize(Size: UDim2)
        assert(typeof(Size) == "UDim2", "Expected UDim2 for Size got: " .. typeof(Size))

        WindowInfo.SearchbarSize = Size
        if not SearchCollapsed then
            SearchBox.Size = Size
        end
    end

    function Window:SetSearchbarCollapsible(Enabled: boolean, CollapsedWidth: number?)
        WindowInfo.SearchbarCollapsible = Enabled == true
        if typeof(CollapsedWidth) == "number" then
            WindowInfo.SearchbarCollapsedWidth = math.max(24, CollapsedWidth)
        end

        if WindowInfo.SearchbarCollapsible and not SearchBox:IsFocused() and Trim(SearchBox.Text) == "" then
            SearchCollapsed = not WindowInfo.SearchbarCollapsible
            SetSearchCollapsed(true)
        else
            SetSearchCollapsed(false)
        end
    end

    function Window:SetTabButtonsStyle(NewStyle: { [string]: any })
        assert(typeof(NewStyle) == "table", "Expected table for TabButtonsStyle got: " .. typeof(NewStyle))

        for Key, Value in NewStyle do
            TabButtonsStyle[Key] = Value
        end
        NormalizeTabButtonsStyle()
        ApplyTabButtonsStyle()
    end

    --// Changes the height (and optionally the text size) of every tab button \--
    function Window:SetTabSize(Height: number, TextSize: number?)
        assert(typeof(Height) == "number", "Expected number for Height got: " .. typeof(Height))

        Window:SetTabButtonsStyle({ Height = Height, TextSize = TextSize or TabButtonsStyle.TextSize })
    end

    function Window:SetSubPageStyle(NewStyle: { [string]: any })
        assert(typeof(NewStyle) == "table", "Expected table for SubPageStyle got: " .. typeof(NewStyle))

        for Key, Value in NewStyle do
            SubPageStyle[Key] = Value
        end
        if NewStyle.CornerRadius == false then
            SubPageStyle.CornerRadius = nil
        end
        NormalizeSubPageStyle()

        SubPageList.Padding = UDim.new(0, SubPageStyle.Gap)
        for _, Tab in Library.Tabs do
            if typeof(Tab) == "table" and Tab.SubPages then
                for _, SubPage in Tab.SubPages do
                    SubPage:ApplyStyle()
                end
            end
        end
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        CurrentTabInfo.Visible = true
        SubPageList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    end

    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        SubPageList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    end

    --// Sidebar sections: a header (optionally collapsible) that groups the tabs created after it \\--
    function Window:AddSection(...)
        local Info = select(1, ...)
        local Name, Collapsible, Collapsed, Divider, Order

        if typeof(Info) == "table" then
            Name = Info.Name or "Section"
            Collapsible = Info.Collapsible ~= false
            Collapsed = Info.Collapsed == true
            Divider = Info.Divider
            Order = tonumber(Info.Order)
        else
            Name = Info or "Section"
            Collapsible = select(2, ...) ~= false
            Collapsed = select(3, ...) == true
        end

        if not Order then
            Order = #Tabs:GetChildren()
        end
        if Divider == nil then
            Divider = Order > 2
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = Order,
            Size = UDim2.new(1, 0, 0, IsCompact and 10 or 28),
            Parent = Tabs,
        })

        local HeaderButton = New("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Parent = Holder,
        })
        local Line = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(6, 0),
            Size = UDim2.new(1, -12, 0, 1),
            Parent = Holder,
        })
        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 4),
            Size = UDim2.new(1, -36, 1, -4),
            Text = Name,
            TextSize = 13,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Arrow
        if Collapsible then
            Arrow = New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.new(1, -10, 0.5, 2),
                Size = UDim2.fromOffset(14, 14),
                Parent = Holder,
            })
            if ArrowIcon then
                Library:ApplyLucideIcon(Arrow, ArrowIcon, 180)
            end
        end

        local Entry = { Holder = Holder, Label = Label, Arrow = Arrow, Line = Line, Divider = Divider }
        table.insert(Library.SidebarSections, Entry)
        ApplySectionEntry(Entry)

        local Section: any = {
            Type = "Section",
            Name = Name,

            Tabs = {},
            Collapsible = Collapsible,
            Collapsed = false,
            Visible = true,

            Holder = Holder,
            Order = Order,
        }

        function Section:SetCollapsed(Value: boolean)
            if not Section.Collapsible then
                Value = false
            end

            Section.Collapsed = Value == true
            if Arrow then
                TweenService:Create(Arrow, Library.TweenInfo, { Rotation = Section.Collapsed and 0 or 180 }):Play()
            end

            for _, Tab in Section.Tabs do
                if Tab.Button then
                    Tab.Button.Visible = Section.Visible and not Section.Collapsed and Tab.Visible ~= false
                end
            end
        end

        function Section:Toggle()
            Section:SetCollapsed(not Section.Collapsed)
        end

        function Section:SetName(NewName: string)
            Section.Name = NewName
            Label.Text = NewName
        end

        function Section:SetVisible(Visible: boolean)
            Section.Visible = Visible
            Holder.Visible = Visible
            Section:SetCollapsed(Section.Collapsed)
        end

        function Section:AddTab(...)
            local TabInfo = select(1, ...)
            if typeof(TabInfo) == "table" then
                TabInfo.Section = Section
                return Window:AddTab(TabInfo)
            end

            return Window:AddTab({
                Name = TabInfo,
                Icon = select(2, ...),
                Description = select(3, ...),
                Order = select(4, ...),
                Section = Section,
            })
        end

        function Section:Destroy()
            for _, Tab in Section.Tabs do
                Tab.Section = nil
                if Tab.Button then
                    Tab.Button.Visible = Tab.Visible ~= false
                end
            end
            table.clear(Section.Tabs)

            local Idx = table.find(Library.SidebarSections, Entry)
            if Idx then
                table.remove(Library.SidebarSections, Idx)
            end

            Holder:Destroy()
        end

        HeaderButton.MouseButton1Click:Connect(function()
            Section:Toggle()
        end)

        if Collapsed then
            Section:SetCollapsed(true)
        end

        return Section
    end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabSection = nil
        if select("#", ...) == 1 and typeof(...) == "table" then
            TabSection = (select(1, ...)).Section
        end

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight
        local TabWide

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, TabButtonsStyle.Height),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            local TabButtonCorner = New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local TabPadV, TabPadH, TabLabelOffset = GetTabMetrics(IsCompact)
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, TabPadV),
                PaddingLeft = UDim.new(0, TabPadH),
                PaddingRight = UDim.new(0, TabPadH),
                PaddingTop = UDim.new(0, TabPadV),
                Parent = ButtonHolder,
            })
            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(TabLabelOffset, 0),
                Size = UDim2.new(1, -TabLabelOffset, 1, 0),
                Text = Name,
                TextSize = TabButtonsStyle.TextSize,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Button = TabButton,
                Corner = TabButtonCorner,
                Indicator = TabIndicator,
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Full width area above both columns (Tab:AddFullGroupbox) \\--
        TabWide = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 0),
            Parent = TabContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = TabWide,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = TabWide,
        })

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,
            HighlightLabel = TabLabel,
            Section = TabSection,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Sides = {
                TabLeft,
                TabRight,
            },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 0,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            local WarningOffset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0

            --// the full width area sits under the warning box, the two columns start under the full width area \--
            local function Apply(Left, Right, Wide)
                local Offset = WarningOffset
                if Wide then
                    Wide.Position = UDim2.new(0, 0, 0, WarningOffset)
                    Offset += Wide.AbsoluteSize.Y / Library.DPIScale
                end

                for _, Side in { Left, Right } do
                    Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                    Side.Size = UDim2.new(0.5, -3, 1, -Offset)
                end
            end

            Apply(TabLeft, TabRight, TabWide)
            if Tab.SubPages then
                for _, SubPage in Tab.SubPages do
                    Apply(SubPage.Sides[1], SubPage.Sides[2], SubPage.Wide)
                end
            end
        end

        TabWide:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            Tab:RefreshSides()
        end)

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor((TabContainer.AbsoluteSize.Y / Library.DPIScale) / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X / Library.DPIScale
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        local function GetSideParent(Info)
            local SubSides = Info.SubPageSides
            if Info.Side == 3 then
                return Info.SubPageWide or TabWide
            end

            if Info.Side == 1 then
                return SubSides and SubSides[1] or TabLeft
            end

            return SubSides and SubSides[2] or TabRight
        end

        local function AddTabbox(self, Info)
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self
            local IsNested = ParentObj.Type == "Groupbox" or ParentObj.Type == "SubTab"

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if IsNested then ParentObj.Container else GetSideParent(Info),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},

                ParentBox = if IsNested then ParentObj else nil,
                SubPage = Info.SubPage,
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                    Library:ApplyLucideIcon(ButtonIcon, BoxIcon)
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 10),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 10),
                    Parent = Container,
                })

                local Tab = {
                    Type = "SubTab",
                    Name = Name,
                    HighlightLabel = ButtonLabel,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Tabbox = Tabbox,

                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0.5
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 20
                    if Tabbox.PoppedOut then
                        ContentSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, ContentSize + 35)
                    if IsNested then
                        ParentObj:Resize()
                    end
                end

                function Tab:UpdateCorners()
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                Tab.AddTabbox = AddTabbox
                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = TabboxButtons,
                Children = function()
                    return { TabboxHolder }
                end,

                After = function()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if IsNested then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:AddGroupbox(Info)
            Info = Library:Validate(Info, Templates.Groupbox)

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = GetSideParent(Info),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder)

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    local GroupboxHeaderIcon = New("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(18, 18),
                        Parent = GroupboxTop,
                    })
                    Library:ApplyLucideIcon(GroupboxHeaderIcon, BoxIcon)
                end

                local RightInset = if Info.DisableCollapsing ~= true then 20 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 22 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 22 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 15,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = New("ImageButton", {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(18, 18),
                    Parent = GroupboxTop,
                })
                if ArrowIcon then
                    Library:ApplyLucideIcon(GroupboxCollapseArrow, ArrowIcon, 180)
                end

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })
                New("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.12, 0.1),
                        NumberSequenceKeypoint.new(0.88, 0.1),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                    Parent = GroupboxLine,
                })

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    LayoutOrder = 2,
                    ScrollBarThickness = 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 10),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 10),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Type = "Groupbox",

                Name = Info.Name,
                Description = Info.Description,

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,

                Tab = Tab,
                SubPage = Info.SubPage,
                DependencyBoxes = {},
                Elements = {}
            }

            Groupbox.HighlightLabel = GroupboxLabel
            Groupbox.DescriptionTarget = { HighlightLabel = GroupboxDescription, Text = Info.Description or "" }

            local ResizeTween
            local CollapseArrowTween

            function Groupbox:Resize()
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContainerSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 20
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                end

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                end
            end

            table.insert(Groupbox.Connections, GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Groupbox.Visible == false or Groupbox.Destroyed then
                    return
                end

                Groupbox:Resize()
            end))

            function Groupbox:SetDescription(Description: string | nil)
                Groupbox.Description = Description
                Groupbox.DescriptionTarget.Text = Description or ""
                Groupbox.DescriptionTarget.Highlighted = false
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = GroupboxTop,
                Children = function()
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                GroupboxCollapseArrow.MouseButton1Click:Connect(function()
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Sub Pages \\--
        --// Groupbox that spans both columns: Tab:AddFullGroupbox({ Name = "Quick actions" }) \\--
        function Tab:AddFullGroupbox(GroupInfo)
            GroupInfo = typeof(GroupInfo) == "table" and GroupInfo or { Name = tostring(GroupInfo) }
            GroupInfo.Side = 3

            return Tab:AddGroupbox(GroupInfo)
        end

        function Tab:SetSubPageButtonsVisible(Visible: boolean)
            if not Tab.SubPages then
                return
            end

            for _, SubPage in Tab.SubPages do
                SubPage.Button.Visible = Visible and SubPage.Visible ~= false
            end
        end

        function Tab:AddSubPage(...)
            local SubName, SubIcon, SubTooltip
            if select("#", ...) == 1 and typeof(...) == "table" then
                local SubInfo = select(1, ...)
                SubName = SubInfo.Name or "Page"
                SubIcon = SubInfo.Icon
                SubTooltip = SubInfo.Tooltip
            else
                SubName = select(1, ...) or "Page"
                SubIcon = select(2, ...)
                SubTooltip = select(3, ...)
            end

            Tab.SubPages = Tab.SubPages or {}
            if #Tab.SubPages == 0 then
                --// Base sides are replaced by the sub pages' sides \\--
                TabLeft.Visible = false
                TabRight.Visible = false
            end

            local function CreateSide(Parent, IsRight)
                local Side = New("ScrollingFrame", {
                    AnchorPoint = IsRight and Vector2.new(1, 0) or Vector2.new(0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = IsRight and UDim2.fromScale(1, 0) or UDim2.fromScale(0, 0),
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    Size = UDim2.new(0.5, -3, 1, 0),
                    Parent = Parent,
                })
                New("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = Side,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    Parent = Side,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = Side,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = Side,
                })

                return Side
            end

            local SubContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = TabContainer,
            })
            local SubLeft = CreateSide(SubContainer, false)
            local SubRight = CreateSide(SubContainer, true)

            local SubWide = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.new(1, 0, 0, 0),
                Parent = SubContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = SubWide,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = SubWide,
            })
            SubWide:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                Tab:RefreshSides()
            end)

            --// Button (displayed on the left of the search bar) \\--
            local Style = SubPageStyle
            local ParsedIcon = Library:GetCustomIcon(SubIcon)

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                LayoutOrder = #Tab.SubPages + 1,
                Size = UDim2.fromOffset(0, Style.Height),
                Text = "",
                Visible = Library.ActiveTab == Tab,
                Parent = SubPageHolder,
            })
            local ButtonCorner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Button,
            })
            local CornerRegistered = false
            local ButtonStroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = 1,
                Parent = Button,
            })
            local Indicator = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 1, 0),
                Size = UDim2.new(1, -8, 0, Style.IndicatorHeight),
                Visible = false,
                Parent = Button,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Indicator,
            })

            local Content = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, Style.TextSize + 2),
                Parent = Button,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Content,
            })

            local ButtonIcon
            if ParsedIcon then
                ButtonIcon = New("ImageLabel", {
                    ImageColor3 = ParsedIcon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    LayoutOrder = 0,
                    Size = UDim2.fromOffset(Style.TextSize, Style.TextSize),
                    Parent = Content,
                })
                Library:ApplyLucideIcon(ButtonIcon, ParsedIcon)
            end

            local ButtonLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, Style.TextSize + 2),
                Text = SubName,
                TextSize = Style.TextSize,
                TextTransparency = 0.5,
                Parent = Content,
            })

            local SubPage: any = {
                Type = "SubPage",
                Name = SubName,

                Connections = {},
                Destroyed = false,
                Visible = true,

                Tab = Tab,
                Button = Button,
                Container = SubContainer,
                Sides = { SubLeft, SubRight },
                Wide = SubWide,
            }

            local function ApplyCorner()
                if Style.CornerRadius ~= nil then
                    ButtonCorner.CornerRadius = UDim.new(0, Style.CornerRadius)

                    if CornerRegistered then
                        local Idx = table.find(Library.Corners, ButtonCorner)
                        if Idx then
                            table.remove(Library.Corners, Idx)
                        end
                        CornerRegistered = false
                    end
                else
                    ButtonCorner.CornerRadius = UDim.new(0, Library.CornerRadius / 2)

                    if not CornerRegistered then
                        table.insert(Library.Corners, ButtonCorner)
                        CornerRegistered = true
                    end
                end
            end

            local function UpdateButtonSize()
                local X = Library:GetTextBounds(ButtonLabel.Text, Library.Scheme.Font, Style.TextSize)
                Button.Size = UDim2.fromOffset(
                    X + (ParsedIcon and (Style.TextSize + 6) or 0) + Style.PaddingX * 2,
                    Style.Height
                )
            end

            local function ApplyVisual(Active: boolean, Instant: boolean?)
                local IsPill = Style.Style == "pill"
                local Goals = {
                    [Button] = { BackgroundTransparency = (IsPill and Active) and 0 or 1 },
                    [ButtonStroke] = { Transparency = (IsPill and Style.ShowStroke and Active) and 0 or 1 },
                    [Indicator] = { BackgroundTransparency = Active and 0 or 1 },
                    [ButtonLabel] = { TextTransparency = Active and 0 or 0.5 },
                }
                if ButtonIcon then
                    Goals[ButtonIcon] = { ImageTransparency = Active and 0 or 0.5 }
                end

                for Object, Properties in Goals do
                    if Instant then
                        for Property, Value in Properties do
                            Object[Property] = Value
                        end
                    else
                        TweenService:Create(Object, Library.TweenInfo, Properties):Play()
                    end
                end
            end

            function SubPage:ApplyStyle()
                ButtonLabel.TextSize = Style.TextSize
                ButtonLabel.Size = UDim2.fromOffset(0, Style.TextSize + 2)
                Content.Size = UDim2.fromOffset(0, Style.TextSize + 2)
                if ButtonIcon then
                    ButtonIcon.Size = UDim2.fromOffset(Style.TextSize, Style.TextSize)
                end

                Indicator.Size = UDim2.new(1, -8, 0, Style.IndicatorHeight)
                Indicator.Visible = Style.Style == "underline"

                ApplyCorner()
                UpdateButtonSize()
                ApplyVisual(Tab.ActiveSubPage == SubPage, true)
            end

            function SubPage:Show()
                if Tab.ActiveSubPage == SubPage then
                    return
                end

                if Tab.ActiveSubPage then
                    Tab.ActiveSubPage:Hide()
                end

                ApplyVisual(true)
                SubContainer.Visible = true

                Tab.ActiveSubPage = SubPage
                Tab.Sides = SubPage.Sides
                Tab:RefreshSides()

                --// Keep the selected button inside the scrolling strip (clear of the overflow arrows) \\--
                task.defer(function()
                    if SubPage.Destroyed or not Button.Parent or not Button.Visible then
                        return
                    end

                    local Margin = 30
                    local Pos = SubPageHolder.CanvasPosition.X
                    local View = SubPageHolder.AbsoluteSize.X
                    local Left = Button.AbsolutePosition.X - SubPageHolder.AbsolutePosition.X + Pos
                    local Right = Left + Button.AbsoluteSize.X

                    if Left < Pos + Margin then
                        SubPageHolder.CanvasPosition = Vector2.new(math.max(0, Left - Margin), 0)
                    elseif Right > Pos + View - Margin then
                        SubPageHolder.CanvasPosition = Vector2.new(Right - View + Margin, 0)
                    end
                end)
            end

            function SubPage:Hide()
                ApplyVisual(false)
                SubContainer.Visible = false

                if Tab.ActiveSubPage == SubPage then
                    Tab.ActiveSubPage = nil
                end
            end

            function SubPage:SetText(Text: string)
                SubPage.Name = Text
                ButtonLabel.Text = Text
                UpdateButtonSize()
            end

            function SubPage:SetVisible(Visible: boolean)
                SubPage.Visible = Visible
                Button.Visible = Visible and Library.ActiveTab == Tab

                if not Visible and Tab.ActiveSubPage == SubPage then
                    SubPage:Hide()

                    for _, Other in Tab.SubPages do
                        if Other ~= SubPage and Other.Visible ~= false then
                            Other:Show()
                            break
                        end
                    end
                end
            end

            function SubPage:AddGroupbox(GroupInfo)
                GroupInfo = typeof(GroupInfo) == "table" and GroupInfo or { Name = tostring(GroupInfo) }
                GroupInfo.SubPage = SubPage
                GroupInfo.SubPageSides = SubPage.Sides
                GroupInfo.SubPageWide = SubPage.Wide

                return Tab:AddGroupbox(GroupInfo)
            end

            function SubPage:AddFullGroupbox(GroupInfo)
                GroupInfo = typeof(GroupInfo) == "table" and GroupInfo or { Name = tostring(GroupInfo) }
                GroupInfo.Side = 3

                return SubPage:AddGroupbox(GroupInfo)
            end

            function SubPage:AddTabbox(TabboxInfo)
                TabboxInfo = typeof(TabboxInfo) == "table" and TabboxInfo or {}
                TabboxInfo.SubPage = SubPage
                TabboxInfo.SubPageSides = SubPage.Sides
                TabboxInfo.SubPageWide = SubPage.Wide

                return AddTabbox(Tab, TabboxInfo)
            end

            function SubPage:Destroy()
                SubPage.Destroyed = true

                for Key, Groupbox in Tab.Groupboxes do
                    if Groupbox.SubPage == SubPage then
                        if Groupbox.Destroy then
                            Groupbox:Destroy()
                        end
                        Tab.Groupboxes[Key] = nil
                    end
                end

                for Key, Tabbox in Tab.Tabboxes do
                    if Tabbox.SubPage == SubPage then
                        if Tabbox.Destroy then
                            Tabbox:Destroy()
                        end
                        Tab.Tabboxes[Key] = nil
                    end
                end

                if SubPage.TooltipTable then
                    SubPage.TooltipTable:Destroy()
                end

                for _, Connection in SubPage.Connections do
                    Connection:Disconnect()
                end

                local CornerIdx = table.find(Library.Corners, ButtonCorner)
                if CornerIdx then
                    table.remove(Library.Corners, CornerIdx)
                end

                local WasActive = Tab.ActiveSubPage == SubPage
                if WasActive then
                    Tab.ActiveSubPage = nil
                end

                local Idx = table.find(Tab.SubPages, SubPage)
                if Idx then
                    table.remove(Tab.SubPages, Idx)
                end

                SubContainer:Destroy()
                Button:Destroy()

                if WasActive then
                    local Next = Tab.SubPages[1]
                    if Next then
                        Next:Show()
                    else
                        Tab.Sides = { TabLeft, TabRight }
                        TabLeft.Visible = true
                        TabRight.Visible = true
                        Tab:RefreshSides()
                    end
                end
            end

            table.insert(SubPage.Connections, Button.MouseButton1Click:Connect(function()
                SubPage:Show()
            end))
            table.insert(SubPage.Connections, Button.MouseEnter:Connect(function()
                if Tab.ActiveSubPage == SubPage then
                    return
                end

                TweenService:Create(ButtonLabel, Library.TweenInfo, { TextTransparency = 0.25 }):Play()
            end))
            table.insert(SubPage.Connections, Button.MouseLeave:Connect(function()
                if Tab.ActiveSubPage == SubPage then
                    return
                end

                TweenService:Create(ButtonLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
            end))

            if typeof(SubTooltip) == "string" then
                SubPage.TooltipTable = Library:AddTooltip(SubTooltip, nil, Button)
            end

            table.insert(Tab.SubPages, SubPage)
            SubPage:ApplyStyle()

            if not Tab.ActiveSubPage then
                SubPage:Show()
            end

            return SubPage
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library:PlayTabAnimation(Tab, true)
            Tab:RefreshSides()
            Tab:SetSubPageButtonsVisible(true)

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            Tab:SetSubPageButtonsVisible(false)

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            Tab.Visible = Visible ~= false
            TabButton.Visible = Tab.Visible and not (Tab.Section and Tab.Section.Collapsed)

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            if Tab.Section then
                local SectionIdx = table.find(Tab.Section.Tabs, Tab)
                if SectionIdx then
                    table.remove(Tab.Section.Tabs, SectionIdx)
                end
            end

            if Tab.SubPages then
                for Index = #Tab.SubPages, 1, -1 do
                    local SubPage = Tab.SubPages[Index]
                    if SubPage and SubPage.Destroy then
                        SubPage:Destroy()
                    end
                end
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        if TabSection then
            table.insert(TabSection.Tabs, Tab)
            TabButton.Visible = not TabSection.Collapsed and TabSection.Visible ~= false
        end

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, TabButtonsStyle.Height),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            local TabButtonCorner = New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local TabPadV, TabPadH, TabLabelOffset = GetTabMetrics(IsCompact)
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, TabPadV),
                PaddingLeft = UDim.new(0, TabPadH),
                PaddingRight = UDim.new(0, TabPadH),
                PaddingTop = UDim.new(0, TabPadV),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(TabLabelOffset, 0),
                Size = UDim2.new(1, -TabLabelOffset, 1, 0),
                Text = Name,
                TextSize = TabButtonsStyle.TextSize,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Button = TabButton,
                Corner = TabButtonCorner,
                Indicator = TabIndicator,
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Elements = {},

            Window = Window,
            Button = TabButton,
            Container = TabContainer
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            Tab.Visible = Visible ~= false
            TabButton.Visible = Tab.Visible and not (Tab.Section and Tab.Section.Collapsed)

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                local IconImg = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
                Library:ApplyLucideIcon(IconImg, ParsedIcon)
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            local MaxWidth = (MainFrame.AbsoluteSize.X / Library.DPIScale) * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    local GuiProperties = { "BackgroundTransparency" }
    local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
    local TextProperties = { "BackgroundTransparency", "TextTransparency" }
    local StrokeProperties = { "Transparency" }

    local function FadeInstance(Desc, Properties)
        local Cache = TransparencyCache[Desc]
        if not Cache then
            Cache = {}
            TransparencyCache[Desc] = Cache
        end

        for _, Prop in Properties do
            if not Library.Toggled then
                Cache[Prop] = Desc[Prop]
            end

            if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                TweenService:Create(Desc, Library.WindowAnimationInfo, {
                    [Prop] = Library.Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end
    end

    function Window:Toggle(Value: boolean?)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Animations and Library.Animations.ToggleWindow == true then
            local FadeTime = Library.WindowAnimationInfo.Time
            Fading = true

            if Library.Toggled then
                MainFrame.Visible = true
            end

            if Library.Toggled then
                FadeInstance(MainFrame, { "BackgroundTransparency" })
                task.wait(FadeTime / 2)
            else
                task.delay(FadeTime / 2, FadeInstance, MainFrame, { "BackgroundTransparency" })
            end

            for _, Instance in MainFrame:GetDescendants() do
                if Instance == TopBar then
                    continue
                end

                if Instance:IsA("GuiObject") then
                    local ClassName = Instance.ClassName
                    if ClassName == "ImageLabel" or ClassName == "ImageButton" then
                        FadeInstance(Instance, ImageProperties)
                    elseif ClassName == "TextLabel" or ClassName == "TextBox" or ClassName == "TextButton" then
                        FadeInstance(Instance, TextProperties)
                    else
                        FadeInstance(Instance, GuiProperties)
                    end
                elseif Instance.ClassName == "UIStroke" then
                    FadeInstance(Instance, StrokeProperties)
                end
            end

            task.delay(FadeTime, function()
                MainFrame.Visible = Library.Toggled
                Fading = false
            end)
        else
            MainFrame.Visible = Library.Toggled
        end

        if Library.Toolbar and Library.Toolbar.MenuButton then
            Library.Toolbar.MenuButton:SetActive(Library.Toggled, true)
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled or (Library.Console ~= nil and Library.Console.Visible == true)
        end

        if Library.Toggled and not Library.IsMobile then
            local ShowCursorBinding = Library.ShowCursorBinding
            Library.OriginalMouseIconEnabled = UserInputService.MouseIconEnabled

            pcall(function() RunService:UnbindFromRenderStep(ShowCursorBinding) end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    RestoreMouseIcon()
                end
            end)
        elseif not Library.Toggled then
            RestoreMouseIcon()
            TooltipLabel.Visible = false

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end, true, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    Window.MainFrame = MainFrame
    Window.WindowInfo = WindowInfo
    Library.Window = Window

    function Window:AddToolbarButton(ButtonInfo)
        return Library:CreateToolbar({}):AddButton(ButtonInfo)
    end

    function Window:AddWatermark(WatermarkInfo)
        return Library:CreateWatermark(WatermarkInfo)
    end

    function Window:SetSettingsTab(SettingsTab, SettingsInfo)
        return Library:SetSettingsTab(SettingsTab, SettingsInfo)
    end

    if WindowInfo.Watermark then
        local WatermarkInfo = typeof(WindowInfo.Watermark) == "table" and WindowInfo.Watermark or {}
        if WatermarkInfo.Title == nil then
            WatermarkInfo.Title = WindowInfo.Title
        end

        Library:CreateWatermark(WatermarkInfo)
    end

    if WindowInfo.Toolbar ~= false then
        local ToolbarInfo = typeof(WindowInfo.Toolbar) == "table" and WindowInfo.Toolbar or {}
        local Toolbar = Library:CreateToolbar(ToolbarInfo)

        if Toolbar.Holder and ToolbarInfo.DefaultButtons ~= false then
            Toolbar.MenuButton = Toolbar:AddButton({
                Icon = "house",
                Tooltip = "Show / hide the UI",
                Toggle = true,
                Active = Library.Toggled,
                Callback = function(Active)
                    Library:Toggle(Active)
                end,
            })

            Toolbar.KeybindButton = Toolbar:AddButton({
                Icon = "keyboard",
                Tooltip = "Keybind list",
                Toggle = true,
                Active = Library.KeybindFrame.Visible,
                Callback = function(Active)
                    Library.KeybindFrame.Visible = Active
                end,
            })

            Toolbar.WatermarkButton = Toolbar:AddButton({
                Icon = "layout-panel-top",
                Tooltip = "Watermark",
                Toggle = true,
                Active = Library.Watermark ~= nil and Library.Watermark.Holder.Visible,
                Callback = function(Active)
                    local Watermark = Library.Watermark or Library:CreateWatermark({ Title = WindowInfo.Title })
                    Watermark:SetVisible(Active)
                end,
            })

            Toolbar.ConsoleButton = Toolbar:AddButton({
                Icon = "terminal",
                Tooltip = "Console",
                Toggle = true,
                Active = Library.Console ~= nil and Library.Console.Visible,
                Callback = function(Active)
                    if Library.Console then
                        Library.Console:SetVisible(Active)
                    end
                end,
            })

            Toolbar.SettingsButton = Toolbar:AddButton({
                Icon = "settings",
                Tooltip = "Settings",
                Visible = Library.SettingsTab ~= nil,
                Callback = function()
                    if Library.SettingsTab then
                        Library:Toggle(true)
                        Library.SettingsTab.Tab:Show()
                    end
                end,
            })
        end
    end

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        task.defer(function()
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
        if Icon then
            Library:ApplyLucideIcon(_WindowIcon, Icon)
        end
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        (TitleHolder.AbsoluteSize.X / Library.DPIScale) - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })
    if LoaderIcon then
        Library:ApplyLucideIcon(LoadingIcon, LoaderIcon)
    end

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 0,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(LoadingIcon, IconData)
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

--// Built-in settings tab: Library:SetSettingsTab(Tab) / Window:SetSettingsTab(Tab) -> sub pages Config, Theme and UI \\--
-- Info: { Folder = "Octo", Config = true, Theme = true, UI = true, IgnoreIndexes = { "SomeIdx" } }
-- Call it after all of your elements exist, so the autoload config can be applied to them.
function Library:SetSettingsTab(Tab, Info)
    assert(typeof(Tab) == "table" and Tab.AddSubPage, "SetSettingsTab expects a tab created with Window:AddTab")

    if Library.SettingsTab then
        warn("The settings tab is already set.")
        return Library.SettingsTab
    end

    Info = typeof(Info) == "table" and Info or {}

    local Window = Library.Window
    local Folder = tostring(Info.Folder or "Octo")
    local ConfigFolder = Folder .. "/configs"
    local ThemeFolder = Folder .. "/themes"
    local UIPath = Folder .. "/ui.json"
    local IgnoreIndexes = typeof(Info.IgnoreIndexes) == "table" and Info.IgnoreIndexes or {}

    --// Files \\--
    local HasFS = typeof(writefile) == "function"
        and typeof(readfile) == "function"
        and typeof(isfile) == "function"
        and typeof(isfolder) == "function"
        and typeof(makefolder) == "function"
        and typeof(listfiles) == "function"

    if HasFS then
        for _, Path in { Folder, ConfigFolder, ThemeFolder } do
            if not isfolder(Path) then
                pcall(makefolder, Path)
            end
        end
    end

    local function Write(Path: string, Text: string): boolean
        return HasFS and pcall(writefile, Path, Text) or false
    end

    local function Read(Path: string): string?
        if not HasFS or not isfile(Path) then
            return nil
        end

        local Ok, Result = pcall(readfile, Path)
        return Ok and Result or nil
    end

    local function ReadJSON(Path: string): any
        local Text = Read(Path)
        if not Text then
            return nil
        end

        local Ok, Data = pcall(HttpService.JSONDecode, HttpService, Text)
        return Ok and Data or nil
    end

    local function ListNames(Path: string): { string }
        local Names = {}
        if not HasFS then
            return Names
        end

        local Ok, Files = pcall(listfiles, Path)
        if not Ok then
            return Names
        end

        for _, File in Files do
            local Name = tostring(File):match("([^/\\]+)%.json$")
            if Name then
                table.insert(Names, Name)
            end
        end
        table.sort(Names, function(A, B)
            return A:lower() < B:lower()
        end)

        return Names
    end

    local function SafeName(Name: any): string
        return (Trim(tostring(Name or "")):gsub("[^%w%-_ ]", ""))
    end

    local function Note(Title: string, Text: string)
        Library:Notify({ Title = Title, Description = Text, Time = 3 })
    end

    --// UI state (remembered between sessions) \\--
    local UIState = ReadJSON(UIPath) or {}
    local SaveToken = 0
    local function Remember(Key: string, Value: any)
        UIState[Key] = Value

        SaveToken += 1
        local Token = SaveToken
        task.delay(0.6, function()
            if Token == SaveToken then
                Write(UIPath, HttpService:JSONEncode(UIState))
            end
        end)
    end

    local Effects = {}
    local Defaults = {}
    local function Bind(Key: string, Default: any, Setter: (any) -> ())
        Effects[Key] = Setter
        Defaults[Key] = Default

        local Saved = UIState[Key]
        if Saved == nil then
            return Default
        end

        return Saved
    end
    local function Changed(Key: string)
        return function(Value)
            Effects[Key](Value)

            --// multi dropdowns arrive as { [value] = true } \\--
            if typeof(Value) == "table" and Value[1] == nil then
                local List = {}
                for Item, Active in Value do
                    if Active then
                        table.insert(List, Item)
                    end
                end
                Value = List
            end

            Remember(Key, Value)
        end
    end

    local Settings = {
        Tab = Tab,
        Pages = {},
        Folder = Folder,
    }
    Library.SettingsTab = Settings

    local function IsIgnored(Idx: any): boolean
        return typeof(Idx) ~= "string" or Idx:sub(1, 5) == "Octo_" or table.find(IgnoreIndexes, Idx) ~= nil
    end

    --// Config (de)serialisation \\--
    local function SerializeConfig()
        local Data = {}

        for Idx, Toggle in Toggles do
            if not IsIgnored(Idx) then
                Data[Idx] = { Type = "Toggle", Value = Toggle.Value }
            end
        end

        for Idx, Option in Options do
            if IsIgnored(Idx) then
                continue
            end

            local OptionType = Option.Type
            if OptionType == "Slider" or OptionType == "Input" then
                Data[Idx] = { Type = OptionType, Value = Option.Value }
            elseif OptionType == "RangeSlider" then
                Data[Idx] = { Type = OptionType, Low = Option.Low, High = Option.High }
            elseif (OptionType == "Dropdown" or OptionType == "List") and not Option.SpecialType then
                if Option.Multi then
                    local List = {}
                    for Value, Active in Option.Value do
                        if Active then
                            table.insert(List, Value)
                        end
                    end

                    Data[Idx] = { Type = OptionType, Multi = true, Value = List }
                else
                    Data[Idx] = { Type = OptionType, Value = Option.Value }
                end
            elseif OptionType == "KeyPicker" then
                Data[Idx] = { Type = OptionType, Key = Option.Value, Mode = Option.Mode, Modifiers = Option.Modifiers }
            elseif OptionType == "ColorPicker" then
                Data[Idx] = { Type = OptionType, Hex = Option.Value:ToHex(), Transparency = Option.Transparency }
            end
        end

        return Data
    end

    local function ApplyConfig(Data)
        if typeof(Data) ~= "table" then
            return
        end

        for Idx, Entry in Data do
            if IsIgnored(Idx) or typeof(Entry) ~= "table" then
                continue
            end

            local Object = if Entry.Type == "Toggle" then Toggles[Idx] else Options[Idx]
            if not Object or Object.Type ~= Entry.Type then
                continue
            end

            pcall(function()
                local EntryType = Entry.Type
                if EntryType == "Toggle" or EntryType == "Slider" or EntryType == "Input" then
                    Object:SetValue(Entry.Value)
                elseif EntryType == "RangeSlider" then
                    Object:SetValue(Entry.Low, Entry.High)
                elseif EntryType == "Dropdown" or EntryType == "List" then
                    if Entry.Multi then
                        local Map = {}
                        for _, Value in Entry.Value or {} do
                            Map[Value] = true
                        end

                        Object:SetValue(Map)
                    else
                        Object:SetValue(Entry.Value)
                    end
                elseif EntryType == "KeyPicker" then
                    Object:SetValue({ Entry.Key, Entry.Mode, Entry.Modifiers })
                elseif EntryType == "ColorPicker" then
                    Object:SetValueRGB(Color3.fromHex(Entry.Hex), Entry.Transparency)
                end
            end)
        end
    end

    local function ConfigPath(Name: string): string
        return ConfigFolder .. "/" .. Name .. ".json"
    end

    function Settings:SaveConfig(Name: string): boolean
        Name = SafeName(Name)
        if Name == "" then
            return false
        end

        return Write(ConfigPath(Name), HttpService:JSONEncode(SerializeConfig()))
    end

    function Settings:LoadConfig(Name: string): boolean
        local Data = ReadJSON(ConfigPath(SafeName(Name)))
        if not Data then
            return false
        end

        ApplyConfig(Data)
        return true
    end

    function Settings:LoadAutoload(): boolean
        local Name = Read(ConfigFolder .. "/autoload.txt")
        if not Name or Trim(Name) == "" then
            return false
        end

        return Settings:LoadConfig(Trim(Name))
    end

    --// Config page \\--
    if Info.Config ~= false then
        local Page = Tab:AddSubPage({ Name = "Config", Icon = "save", Tooltip = "Save and load your settings" })
        Settings.Pages.Config = Page

        local Box = Page:AddGroupbox({ Side = 1, Name = "Configs", IconName = "folder" })
        local ShareBox = Page:AddGroupbox({ Side = 2, Name = "Share", IconName = "share-2" })

        if not HasFS then
            Box:AddLabel("<font color=\"#ff6b6b\">Your executor has no file functions, configs can't be saved.</font>", true)
        end

        Box:AddInput("Octo_Cfg_Name", { Text = "Config name", Placeholder = "my config" })
        Box:AddDropdown("Octo_Cfg_List", {
            Text = "Config list",
            Values = ListNames(ConfigFolder),
            AllowNull = true,
            Searchable = true,
        })

        local AutoLabel
        local function RefreshList()
            Options.Octo_Cfg_List:SetValues(ListNames(ConfigFolder))
            Options.Octo_Cfg_List:SetValue(nil)
        end
        local function Selected(): string?
            local Name = Options.Octo_Cfg_List.Value
            if not Name then
                Note("Config", "Select a config first.")
            end

            return Name
        end

        Box:AddDivider()
        Box:AddButton({
            Text = "Create",
            Func = function()
                local Name = SafeName(Options.Octo_Cfg_Name.Value)
                if Name == "" then
                    return Note("Config", "Type a name first.")
                end
                if Read(ConfigPath(Name)) then
                    return Note("Config", string.format("%q already exists.", Name))
                end

                Note("Config", Settings:SaveConfig(Name) and string.format("Created %q.", Name) or "Could not save the file.")
                RefreshList()
            end,
        }):AddButton({
            Text = "Load",
            Func = function()
                local Name = Selected()
                if Name then
                    Note("Config", Settings:LoadConfig(Name) and string.format("Loaded %q.", Name) or "Could not read the file.")
                end
            end,
        })

        Box:AddButton({
            Text = "Overwrite",
            DoubleClick = true,
            Func = function()
                local Name = Selected()
                if Name then
                    Note("Config", Settings:SaveConfig(Name) and string.format("Saved %q.", Name) or "Could not save the file.")
                end
            end,
        }):AddButton({
            Text = "Delete",
            Risky = true,
            DoubleClick = true,
            Func = function()
                local Name = Selected()
                if Name and typeof(delfile) == "function" then
                    pcall(delfile, ConfigPath(Name))
                    Note("Config", string.format("Deleted %q.", Name))
                    RefreshList()
                end
            end,
        })

        Box:AddButton({ Text = "Refresh list", Func = RefreshList })
        Box:AddDivider("Autoload")

        Box:AddButton({
            Text = "Set as autoload",
            Func = function()
                local Name = Selected()
                if Name then
                    Write(ConfigFolder .. "/autoload.txt", Name)
                    AutoLabel:SetText("Autoload: " .. Library:Copyable(Name))
                end
            end,
        }):AddButton({
            Text = "Reset",
            Func = function()
                Write(ConfigFolder .. "/autoload.txt", "")
                AutoLabel:SetText("Autoload: none")
            end,
        })

        local CurrentAuto = Read(ConfigFolder .. "/autoload.txt")
        AutoLabel = Box:AddLabel(
            (CurrentAuto and Trim(CurrentAuto) ~= "") and ("Autoload: " .. Library:Copyable(Trim(CurrentAuto))) or "Autoload: none"
        )

        ShareBox:AddButton({
            Text = "Copy config to clipboard",
            Func = function()
                if not setclipboard then
                    return Note("Config", "Your executor has no clipboard function.")
                end

                setclipboard(HttpService:JSONEncode(SerializeConfig()))
                Note("Config", "Copied the current settings.")
            end,
        })
        ShareBox:AddDivider()
        ShareBox:AddInput("Octo_Cfg_Import", { Text = "Paste config JSON", Placeholder = "{ ... }", Finished = true })
        ShareBox:AddButton({
            Text = "Import pasted config",
            Func = function()
                local Ok, Data = pcall(HttpService.JSONDecode, HttpService, Options.Octo_Cfg_Import.Value)
                if not Ok or typeof(Data) ~= "table" then
                    return Note("Config", "That is not a valid config.")
                end

                ApplyConfig(Data)
                Note("Config", "Imported.")
            end,
        })
        ShareBox:AddDivider()
        ShareBox:AddLabel("Configs save every toggle, slider, dropdown, input, keybind and color picker that has an index.", true)
    end

    --// Theme page \\--
    if Info.Theme ~= false then
        local Page = Tab:AddSubPage({ Name = "Theme", Icon = "palette", Tooltip = "Colors, font and presets" })
        Settings.Pages.Theme = Page

        local ThemeKeys = {
            { "BackgroundColor", "Background" },
            { "MainColor", "Main" },
            { "AccentColor", "Accent" },
            { "OutlineColor", "Outline" },
            { "FontColor", "Text" },
        }
        local Presets = {
            Default = { BackgroundColor = "0d0d11", MainColor = "17171e", AccentColor = "6e67ff", OutlineColor = "25252f", FontColor = "f0f0f6" },
            Classic = { BackgroundColor = "0f0f0f", MainColor = "191919", AccentColor = "7d55ff", OutlineColor = "282828", FontColor = "ffffff" },
            Vitality = { BackgroundColor = "0e0b0d", MainColor = "181215", AccentColor = "e0284f", OutlineColor = "2a2024", FontColor = "ffffff" },
            Ocean = { BackgroundColor = "0b1218", MainColor = "111b24", AccentColor = "3aa0ff", OutlineColor = "1e2d3b", FontColor = "e8f3ff" },
            Mint = { BackgroundColor = "0c1210", MainColor = "131c18", AccentColor = "2ee6a6", OutlineColor = "1f2e28", FontColor = "eafff6" },
            Rose = { BackgroundColor = "140d12", MainColor = "1d1319", AccentColor = "ff6ba6", OutlineColor = "2e1f29", FontColor = "fff0f6" },
            Amber = { BackgroundColor = "130f0a", MainColor = "1c1610", AccentColor = "ffb02e", OutlineColor = "2d2418", FontColor = "fff6e5" },
            Light = { BackgroundColor = "f2f2f4", MainColor = "ffffff", AccentColor = "6d4aff", OutlineColor = "d4d4da", FontColor = "1b1b1f", Light = true },
        }
        local PresetNames = { "Default", "Classic", "Vitality", "Ocean", "Mint", "Rose", "Amber", "Light" }
        local FontNames = { "BuilderSansMedium", "BuilderSans", "GothamMedium", "Gotham", "Ubuntu", "Roboto", "SourceSans", "Arimo", "Nunito", "Code", "RobotoMono" }

        local Applying = true
        local FontName = "BuilderSansMedium"

        local function RefreshTheme()
            Library:UpdateColorsUsingRegistry()

            for _, Toggle in Toggles do
                if Toggle.UpdateColors then
                    pcall(Toggle.UpdateColors, Toggle)
                end
            end
            for _, Option in Options do
                if Option.UpdateColors then
                    pcall(Option.UpdateColors, Option)
                end
            end
            for _, Button in Buttons do
                if Button.UpdateColors then
                    pcall(Button.UpdateColors, Button)
                end
            end

            if Library.Watermark then
                Library.Watermark:Refresh()
            end
        end

        local ColorBox = Page:AddGroupbox({ Side = 1, Name = "Colors", IconName = "palette" })
        for _, Entry in ThemeKeys do
            local Key = Entry[1]
            ColorBox:AddLabel(Entry[2]):AddColorPicker("Octo_Theme_" .. Key, {
                Default = Library.Scheme[Key],
                Title = Entry[2],
                Callback = function(Color)
                    Library.Scheme[Key] = Color
                    if not Applying then
                        RefreshTheme()
                    end
                end,
            })
        end

        ColorBox:AddDivider()
        ColorBox:AddToggle("Octo_Theme_Light", {
            Text = "Light theme shading",
            Default = Library.IsLightTheme,
            Tooltip = "Changes how hover / highlight shades are calculated",
            Callback = function(Value)
                Library.IsLightTheme = Value
                if not Applying then
                    RefreshTheme()
                end
            end,
        })
        ColorBox:AddDropdown("Octo_Theme_Font", {
            Text = "Font",
            Values = FontNames,
            Default = FontName,
            Callback = function(Value)
                if Value and Enum.Font[Value] then
                    FontName = Value
                    Library:SetFont(Enum.Font[Value])
                end
            end,
        })
        ColorBox:AddSlider("Octo_Theme_Radius", {
            Text = "Corner radius",
            Default = Library.CornerRadius,
            Min = 0,
            Max = 20,
            Rounding = 0,
            Callback = function(Value)
                if Window then
                    Window:SetCornerRadius(Value)
                end
            end,
        })

        local function ApplyThemeData(Data)
            if typeof(Data) ~= "table" then
                return
            end

            Applying = true
            for _, Entry in ThemeKeys do
                local Hex = Data.Colors and Data.Colors[Entry[1]]
                if typeof(Hex) == "string" then
                    pcall(function()
                        Options["Octo_Theme_" .. Entry[1]]:SetValueRGB(Color3.fromHex(Hex))
                    end)
                end
            end

            if typeof(Data.Font) == "string" then
                Options.Octo_Theme_Font:SetValue(Data.Font)
            end
            if typeof(Data.CornerRadius) == "number" then
                Options.Octo_Theme_Radius:SetValue(Data.CornerRadius)
            end
            Toggles.Octo_Theme_Light:SetValue(Data.Light == true)

            Applying = false
            RefreshTheme()
        end

        local function GatherTheme()
            local Colors = {}
            for _, Entry in ThemeKeys do
                Colors[Entry[1]] = Library.Scheme[Entry[1]]:ToHex()
            end

            return { Colors = Colors, Font = FontName, Light = Library.IsLightTheme, CornerRadius = Library.CornerRadius }
        end

        local function ThemePath(Name: string): string
            return ThemeFolder .. "/" .. Name .. ".json"
        end

        local FileBox = Page:AddGroupbox({ Side = 2, Name = "Presets & files", IconName = "swatch-book" })
        FileBox:AddDropdown("Octo_Theme_Preset", {
            Text = "Preset",
            Values = PresetNames,
            AllowNull = true,
            Callback = function(Value)
                local Preset = Value and Presets[Value]
                if not Preset then
                    return
                end

                local Colors = {}
                for _, Entry in ThemeKeys do
                    Colors[Entry[1]] = Preset[Entry[1]]
                end

                ApplyThemeData({ Colors = Colors, Light = Preset.Light == true, Font = FontName, CornerRadius = Library.CornerRadius })
            end,
        })

        FileBox:AddDivider("Saved themes")
        FileBox:AddInput("Octo_Theme_Name", { Text = "Theme name", Placeholder = "my theme" })
        FileBox:AddDropdown("Octo_Theme_List", { Text = "Theme list", Values = ListNames(ThemeFolder), AllowNull = true })

        local DefaultLabel
        local function RefreshThemes()
            Options.Octo_Theme_List:SetValues(ListNames(ThemeFolder))
            Options.Octo_Theme_List:SetValue(nil)
        end
        local function SelectedTheme(): string?
            local Name = Options.Octo_Theme_List.Value
            if not Name then
                Note("Theme", "Select a theme first.")
            end

            return Name
        end

        FileBox:AddButton({
            Text = "Save",
            Func = function()
                local Name = SafeName(Options.Octo_Theme_Name.Value)
                if Name == "" then
                    Name = Options.Octo_Theme_List.Value or ""
                end
                if Name == "" then
                    return Note("Theme", "Type a name first.")
                end

                Note("Theme", Write(ThemePath(Name), HttpService:JSONEncode(GatherTheme())) and string.format("Saved %q.", Name) or "Could not save the file.")
                RefreshThemes()
            end,
        }):AddButton({
            Text = "Load",
            Func = function()
                local Name = SelectedTheme()
                if Name then
                    local Data = ReadJSON(ThemePath(Name))
                    if Data then
                        ApplyThemeData(Data)
                    else
                        Note("Theme", "Could not read the file.")
                    end
                end
            end,
        })

        FileBox:AddButton({
            Text = "Delete",
            Risky = true,
            DoubleClick = true,
            Func = function()
                local Name = SelectedTheme()
                if Name and typeof(delfile) == "function" then
                    pcall(delfile, ThemePath(Name))
                    RefreshThemes()
                end
            end,
        }):AddButton({
            Text = "Set default",
            Func = function()
                local Name = SelectedTheme()
                if Name then
                    Write(ThemeFolder .. "/default.txt", Name)
                    DefaultLabel:SetText("Default theme: " .. Library:Copyable(Name))
                end
            end,
        })

        local CurrentDefault = Read(ThemeFolder .. "/default.txt")
        DefaultLabel = FileBox:AddLabel(
            (CurrentDefault and Trim(CurrentDefault) ~= "") and ("Default theme: " .. Library:Copyable(Trim(CurrentDefault))) or "Default theme: none"
        )

        Applying = false
        if CurrentDefault and Trim(CurrentDefault) ~= "" then
            ApplyThemeData(ReadJSON(ThemePath(Trim(CurrentDefault))))
        end
    end

    --// UI page \\--
    if Info.UI ~= false then
        local Page = Tab:AddSubPage({ Name = "UI", Icon = "monitor", Tooltip = "Menu, layout and overlays" })
        Settings.Pages.UI = Page

        local function GetWatermark()
            return Library.Watermark
                or Library:CreateWatermark({ Title = Window and Window.WindowInfo and Window.WindowInfo.Title or "Octo" })
        end

        local Anim = { "ToggleWindow", "TabSwitch", "Groupbox", "Dropdown", "KeyPicker" }

        local Box = Page:AddGroupbox({ Side = 1, Name = "Interface", IconName = "app-window" })

        Box:AddLabel("Menu keybind"):AddKeyPicker("Octo_MenuKey", {
            Default = "RightControl",
            Mode = "Toggle",
            NoUI = true,
            Text = "Menu keybind",
        })
        Library.ToggleKeybind = Options.Octo_MenuKey

        Box:AddButton({
            Text = "Open console",
            Func = function()
                if Library.Console then
                    Library.Console:Show()
                end
            end,
        })
        Box:AddToggle("Octo_UI_Toolbar", {
            Text = "Top toolbar",
            Default = Bind("Octo_UI_Toolbar", true, function(Value)
                if Library.Toolbar then
                    Library.Toolbar:SetVisible(Value)
                end
            end),
            Callback = Changed("Octo_UI_Toolbar"),
        })
        Box:AddToggle("Octo_UI_Keybinds", {
            Text = "Keybind list",
            Default = Bind("Octo_UI_Keybinds", false, function(Value)
                Library:SetKeybindListVisible(Value)
            end),
            Callback = Changed("Octo_UI_Keybinds"),
        })
        Box:AddToggle("Octo_UI_Cursor", {
            Text = "Custom cursor",
            Default = Bind("Octo_UI_Cursor", Library.ShowCustomCursor, function(Value)
                Library.ShowCustomCursor = Value
            end),
            Callback = Changed("Octo_UI_Cursor"),
        })
        Box:AddToggle("Octo_UI_GroupDrag", {
            Text = "Groupbox drag (pop out)",
            Tooltip = "Drag a groupbox header to float it. Turning this off docks floating groupboxes again.",
            Default = Bind("Octo_UI_GroupDrag", Library.GroupboxDrag, function(Value)
                Library:SetGroupboxDrag(Value)
            end),
            Callback = Changed("Octo_UI_GroupDrag"),
        })
        Box:AddDropdown("Octo_UI_Animations", {
            Text = "Animations",
            Values = Anim,
            Multi = true,
            AllowNull = true,
            Default = Bind("Octo_UI_Animations", {}, function(Value)
                local Map = {}
                if typeof(Value) == "table" then
                    for Key, Item in Value do
                        if typeof(Key) == "number" then
                            Map[Item] = true
                        elseif Item then
                            Map[Key] = true
                        end
                    end
                end

                for _, Name in Anim do
                    Library.Animations[Name] = Map[Name] == true
                end
            end),
            Callback = Changed("Octo_UI_Animations"),
        })
        Box:AddDropdown("Octo_UI_DPIScale", {
            Text = "DPI scale",
            Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
            Default = Bind("Octo_UI_DPIScale", "100%", function(Value)
                local Percent = tonumber(tostring(Value):match("%d+"))
                if Percent then
                    Library:SetDPIScale(Percent)
                end
            end),
            Callback = Changed("Octo_UI_DPIScale"),
        })

        Box:AddDivider("Notifications")
        Box:AddDropdown("Octo_UI_NotifySide", {
            Text = "Side",
            Values = { "Left", "Right" },
            Default = Bind("Octo_UI_NotifySide", Library.NotifySide, function(Value)
                if Value then
                    Library:SetNotifySide(Value)
                end
            end),
            Callback = Changed("Octo_UI_NotifySide"),
        })
        Box:AddSlider("Octo_UI_MaxNotify", {
            Text = "Max on screen (0 = unlimited)",
            Default = Bind("Octo_UI_MaxNotify", Library.MaxNotifications, function(Value)
                Library.MaxNotifications = Value
            end),
            Min = 0,
            Max = 12,
            Rounding = 0,
            Callback = Changed("Octo_UI_MaxNotify"),
        })
        Box:AddToggle("Octo_UI_GroupNotify", {
            Text = "Stack identical notifications",
            Default = Bind("Octo_UI_GroupNotify", Library.GroupNotifications, function(Value)
                Library.GroupNotifications = Value
            end),
            Callback = Changed("Octo_UI_GroupNotify"),
        })
        Box:AddButton({
            Text = "Test notification",
            Func = function()
                Library:Notify({ Title = "Octo", Description = "This is a test notification.", Time = 3, Icon = "bell" })
            end,
        })

        local LayoutBox = Page:AddGroupbox({ Side = 2, Name = "Layout", IconName = "layout-dashboard" })
        LayoutBox:AddSlider("Octo_UI_TabHeight", {
            Text = "Tab button height",
            Default = Bind("Octo_UI_TabHeight", 40, function(Value)
                if Window then
                    Window:SetTabSize(Value)
                end
            end),
            Min = 28,
            Max = 64,
            Rounding = 0,
            Suffix = "px",
            Callback = Changed("Octo_UI_TabHeight"),
        })
        LayoutBox:AddSlider("Octo_UI_TabText", {
            Text = "Tab text size",
            Default = Bind("Octo_UI_TabText", 16, function(Value)
                if Window then
                    Window:SetTabButtonsStyle({ TextSize = Value })
                end
            end),
            Min = 10,
            Max = 24,
            Rounding = 0,
            Callback = Changed("Octo_UI_TabText"),
        })
        LayoutBox:AddDropdown("Octo_UI_SubPageStyle", {
            Text = "Sub page style",
            Values = { "Pill", "Underline", "Flat" },
            Default = Bind("Octo_UI_SubPageStyle", "Pill", function(Value)
                if Window and Value then
                    Window:SetSubPageStyle({ Style = Value })
                end
            end),
            Callback = Changed("Octo_UI_SubPageStyle"),
        })
        LayoutBox:AddToggle("Octo_UI_SearchCollapse", {
            Text = "Collapse search bar",
            Default = Bind("Octo_UI_SearchCollapse", true, function(Value)
                if Window then
                    Window:SetSearchbarCollapsible(Value)
                end
            end),
            Callback = Changed("Octo_UI_SearchCollapse"),
        })

        LayoutBox:AddDivider("Watermark")
        LayoutBox:AddToggle("Octo_UI_Watermark", {
            Text = "Show watermark",
            Default = Bind("Octo_UI_Watermark", Library.Watermark ~= nil and Library.Watermark.Holder.Visible or false, function(Value)
                GetWatermark():SetVisible(Value)
            end),
            Callback = Changed("Octo_UI_Watermark"),
        })

        local Segments = {
            { "fps", "FPS", true },
            { "ping", "Ping", true },
            { "player", "Player", false },
            { "game", "Game name", false },
            { "time", "Clock", false },
        }
        local WatermarkRow
        for Index, Segment in Segments do
            local Id = Segment[1]
            if Index % 2 == 1 then
                WatermarkRow = LayoutBox:AddRow()
            end

            WatermarkRow:AddToggle("Octo_UI_WM_" .. Id, {
                Text = Segment[2],
                Default = Bind("Octo_UI_WM_" .. Id, Segment[3], function(Value)
                    if Library.Watermark then
                        Library.Watermark:SetSegmentVisible(Id, Value)
                    end
                end),
                Callback = Changed("Octo_UI_WM_" .. Id),
            })
        end

        LayoutBox:AddDivider()
        LayoutBox:AddButton({
            Text = "Reset UI settings",
            DoubleClick = true,
            Tooltip = "Puts every option of this page back to its default",
            Func = function()
                for Key, Default in Defaults do
                    local Object = Toggles[Key] or Options[Key]
                    if Object then
                        pcall(function()
                            Object:SetValue(Default)
                        end)
                    end
                end

                if Options.Octo_MenuKey then
                    pcall(function()
                        Options.Octo_MenuKey:SetValue({ "RightControl", "Toggle", {} })
                    end)
                end

                --// forget the saved values (also cancels a pending save) \--
                SaveToken += 1
                table.clear(UIState)
                Write(UIPath, "{}")

                Note("UI", "UI settings were reset.")
            end,
        })
        LayoutBox:AddButton({
            Text = "Unload",
            Risky = true,
            DoubleClick = true,
            Func = function()
                Library:Unload()
            end,
        })

        --// apply the remembered values \\--
        for Key, Setter in Effects do
            if UIState[Key] ~= nil then
                pcall(Setter, UIState[Key])
            end
        end
    end

    if Library.Toolbar and Library.Toolbar.SettingsButton then
        Library.Toolbar.SettingsButton:SetVisible(true)
    end

    Settings:LoadAutoload()
    return Settings
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    Library.Unloaded = true

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if Library.Console then
        Library.Console:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(TransparencyCache)
    table.clear(NotifyGroups)
    table.clear(Library.SidebarSections)
    table.clear(ActiveTabTweens)

    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.Toolbar = nil
    Library.Watermark = nil
    Library.SettingsTab = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil

    getgenv().Library = nil
end

getgenv().Library = Library
return Library
