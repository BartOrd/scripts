local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local LogService = game:GetService("LogService")

local SCRIPT_ID = "14c3027c345f"
local KEY_FILE = "l6velhub_key"
local DISCORD = "https://discord.gg/5F9x5JrYwV"
local GET_KEY_URL = "https://luasec.org/getkey/1d1d5620a28f"
local LUA_SEC_URL = "https://luasec.org/library.lua"

local LOADERS = {
    [87634018924518] = "https://api.luasec.org/loader/4791ff33779c",
    [118637423917462] = "https://api.luasec.org/loader/93ca75435555"
}

local BLACK = Color3.fromRGB(10, 10, 12)
local PANEL = Color3.fromRGB(22, 22, 25)
local FIELD = Color3.fromRGB(32, 32, 36)
local WHITE = Color3.fromRGB(245, 245, 245)
local MUTED = Color3.fromRGB(160, 160, 165)
local BLUE = Color3.fromRGB(75, 75, 82)
local LIGHT_BLUE = Color3.fromRGB(190, 190, 195)
local RED = Color3.fromRGB(180, 180, 185)
local GREEN = Color3.fromRGB(130, 210, 150)
local ORANGE = Color3.fromRGB(190, 180, 150)

local gameName = "Unknown Game"
local executorName = "Unknown"
local keyValue = ""
local luasec = nil
local checking = false
local launching = false

local forceRunValue = nil
pcall(function()
    if type(getgenv) == "function" then
        forceRunValue = getgenv().force_run
    end
end)

if forceRunValue == nil then
    forceRunValue = rawget(_G, "force_run")
end

local forceRunPlaceId = nil
if forceRunValue ~= nil then
    forceRunPlaceId = tonumber(tostring(forceRunValue):match("%d+"))
end

pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

pcall(function()
    if identifyexecutor then
        executorName = identifyexecutor()
    end
end)

local fileSupported =
    type(writefile) == "function"
    and type(readfile) == "function"
    and type(isfile) == "function"

if fileSupported then
    pcall(function()
        if isfile(KEY_FILE) then
            keyValue = readfile(KEY_FILE)
        end
    end)
end

local parent = CoreGui

pcall(function()
    if type(gethui) == "function" then
        parent = gethui()
    end
end)

local old = parent:FindFirstChild("L6velHub")
if old then
    old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "L6velHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parent

local function create(class, props, target)
    local object = Instance.new(class)

    for key, value in pairs(props) do
        object[key] = value
    end

    object.Parent = target
    return object
end

local function round(object, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, object)
end

local function outline(object, color, transparency)
    create("UIStroke", {
        Color = color,
        Thickness = 1,
        Transparency = transparency or 0
    }, object)
end

local function label(target, text, position, size, textSize, color, bold)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = color or WHITE,
        TextSize = textSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, target)
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

local function getGameIcon()
    local universeId = game.GameId

    if not universeId or universeId == 0 then
        return ""
    end

    return "rbxthumb://type=GameIcon&id="
        .. tostring(universeId)
        .. "&w=150&h=150"
end

local function setClipboard(value)
    if type(setclipboard) == "function" then
        local success = pcall(setclipboard, tostring(value))
        return success
    end

    return false
end

local function createHeader(main)
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundTransparency = 1
    }, main)

    label(
        header,
        "L6VEL",
        UDim2.fromOffset(28, 5),
        UDim2.fromOffset(150, 34),
        27,
        WHITE,
        true
    )

    label(
        header,
        "H U B",
        UDim2.fromOffset(30, 37),
        UDim2.fromOffset(120, 18),
        11,
        MUTED,
        true
    )

    local close = create("TextButton", {
        Position = UDim2.new(1, -45, 0, 17),
        Size = UDim2.fromOffset(29, 29),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamBold
    }, header)

    round(close, 8)

    close.Activated:Connect(function()
        ScreenGui:Destroy()
    end)

    return header
end

local function makeMain(size)
    local main = create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        BackgroundColor3 = BLACK,
        BorderSizePixel = 0
    }, ScreenGui)

    round(main, 14)
    outline(main, Color3.fromRGB(65, 65, 72), 0.2)

    local header = createHeader(main)
    makeDraggable(main, header)

    return main
end

local function showLaunchError(errorText)
    local oldError = ScreenGui:FindFirstChild("LaunchError")
    if oldError then
        oldError:Destroy()
    end

    local errorFrame = create("Frame", {
        Name = "LaunchError",
        Size = UDim2.fromOffset(480, 270),
        Position = UDim2.new(0.5, -240, 0.5, -135),
        BackgroundColor3 = BLACK,
        BorderSizePixel = 0,
        ZIndex = 10
    }, ScreenGui)

    round(errorFrame, 15)
    outline(errorFrame, Color3.fromRGB(65, 65, 72), 0.25)

    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundTransparency = 1,
        ZIndex = 11
    }, errorFrame)

    label(
        header,
        "L6VEL",
        UDim2.fromOffset(22, 5),
        UDim2.fromOffset(150, 34),
        25,
        WHITE,
        true
    ).ZIndex = 12

    label(
        header,
        "H U B",
        UDim2.fromOffset(24, 36),
        UDim2.fromOffset(120, 17),
        10,
        MUTED,
        true
    ).ZIndex = 12

    local closeButton = create("TextButton", {
        Position = UDim2.new(1, -42, 0, 17),
        Size = UDim2.fromOffset(27, 27),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    }, header)

    round(closeButton, 8)

    closeButton.Activated:Connect(function()
        errorFrame:Destroy()
    end)

    create("Frame", {
        Position = UDim2.fromOffset(20, 65),
        Size = UDim2.new(1, -40, 0, 1),
        BackgroundColor3 = Color3.fromRGB(48, 48, 53),
        BorderSizePixel = 0,
        ZIndex = 11
    }, errorFrame)

    label(
        errorFrame,
        "LAUNCH ERROR",
        UDim2.fromOffset(22, 76),
        UDim2.fromOffset(400, 24),
        13,
        LIGHT_BLUE,
        true
    ).ZIndex = 12

    label(
        errorFrame,
        "Something went wrong while loading the script.",
        UDim2.fromOffset(22, 99),
        UDim2.fromOffset(430, 18),
        10,
        MUTED,
        false
    ).ZIndex = 12

    local errorBox = create("TextBox", {
        Position = UDim2.fromOffset(20, 126),
        Size = UDim2.fromOffset(440, 85),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = tostring(errorText),
        TextColor3 = Color3.fromRGB(215, 215, 220),
        TextSize = 11,
        Font = Enum.Font.Code,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextEditable = true,
        ZIndex = 12
    }, errorFrame)

    round(errorBox, 9)
    outline(errorBox, Color3.fromRGB(48, 48, 53), 0.2)

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 8)
    }, errorBox)

    local copyButton = create("TextButton", {
        Position = UDim2.fromOffset(20, 224),
        Size = UDim2.fromOffset(212, 32),
        BackgroundColor3 = BLUE,
        BorderSizePixel = 0,
        Text = "COPY ERROR",
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    }, errorFrame)

    round(copyButton, 8)

    copyButton.Activated:Connect(function()
        if setClipboard(errorText) then
            copyButton.Text = "COPIED!"
        else
            errorBox:CaptureFocus()
            errorBox.SelectionStart = 1
            errorBox.CursorPosition = #errorBox.Text + 1
            copyButton.Text = "SELECTED - COPY"
        end
    end)

    local closeBottom = create("TextButton", {
        Position = UDim2.fromOffset(248, 224),
        Size = UDim2.fromOffset(212, 32),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "CLOSE",
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    }, errorFrame)

    round(closeBottom, 8)

    closeBottom.Activated:Connect(function()
        errorFrame:Destroy()
    end)

    makeDraggable(errorFrame, header)
end

local function showHub(licenseData)
    local oldMain = ScreenGui:FindFirstChild("Main")
    if oldMain then
        oldMain:Destroy()
    end

    local main = makeMain(UDim2.fromOffset(680, 370))

    label(
        main,
        "CURRENT GAME",
        UDim2.fromOffset(28, 77),
        UDim2.fromOffset(290, 24),
        12,
        MUTED,
        true
    )

    label(
        main,
        "LICENSE INFORMATION",
        UDim2.fromOffset(360, 77),
        UDim2.fromOffset(285, 24),
        12,
        MUTED,
        true
    )

    local gameCard = create("Frame", {
        Position = UDim2.fromOffset(28, 110),
        Size = UDim2.fromOffset(305, 220),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, main)

    round(gameCard, 10)
    outline(gameCard, Color3.fromRGB(65, 65, 72), 0.5)

    local icon = create("ImageLabel", {
        Position = UDim2.fromOffset(16, 16),
        Size = UDim2.fromOffset(58, 58),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Image = getGameIcon(),
        ScaleType = Enum.ScaleType.Crop
    }, gameCard)

    round(icon, 9)

    label(
        gameCard,
        gameName,
        UDim2.fromOffset(88, 18),
        UDim2.fromOffset(200, 27),
        16,
        WHITE,
        true
    )

    label(
        gameCard,
        "Place ID: " .. tostring(forceRunPlaceId or game.PlaceId),
        UDim2.fromOffset(88, 47),
        UDim2.fromOffset(200, 20),
        10,
        MUTED,
        false
    )

    local targetPlaceId = forceRunPlaceId or game.PlaceId
    local loaderUrl = LOADERS[targetPlaceId]
    local targetGameName = gameName

    if forceRunPlaceId then
        pcall(function()
            targetGameName = MarketplaceService:GetProductInfo(targetPlaceId).Name
        end)
    end

    local gameNameLabel = gameCard:FindFirstChildWhichIsA("TextLabel")
    if gameNameLabel then
        gameNameLabel.Text = targetGameName
    end

    local placeIdLabel = gameCard:FindFirstChildWhichIsA("TextLabel")
    if placeIdLabel then
        placeIdLabel.Text = "Place ID: " .. tostring(targetPlaceId)
    end

    local launchButton = create("TextButton", {
        Position = UDim2.fromOffset(16, 157),
        Size = UDim2.fromOffset(273, 45),
        BackgroundColor3 = loaderUrl and BLUE or FIELD,
        BorderSizePixel = 0,
        Text = loaderUrl and "LAUNCH" or "UNAVAILABLE",
        TextColor3 = loaderUrl and WHITE or MUTED,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = loaderUrl ~= nil
    }, gameCard)

    round(launchButton, 8)

    local licenseCard = create("Frame", {
        Position = UDim2.fromOffset(360, 110),
        Size = UDim2.fromOffset(292, 220),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, main)

    round(licenseCard, 10)
    outline(licenseCard, Color3.fromRGB(65, 65, 72), 0.5)

    label(
        licenseCard,
        "LICENSE ACTIVE",
        UDim2.fromOffset(18, 17),
        UDim2.fromOffset(255, 23),
        12,
        GREEN,
        true
    )

    label(
        licenseCard,
        "L6vel Hub",
        UDim2.fromOffset(18, 41),
        UDim2.fromOffset(255, 18),
        10,
        MUTED,
        false
    )

    create("Frame", {
        Position = UDim2.fromOffset(16, 72),
        Size = UDim2.fromOffset(260, 1),
        BackgroundColor3 = Color3.fromRGB(48, 48, 53),
        BorderSizePixel = 0
    }, licenseCard)

    local function licenseRow(name, value, y, valueColor)
        label(
            licenseCard,
            name,
            UDim2.fromOffset(18, y),
            UDim2.fromOffset(115, 22),
            11,
            MUTED,
            false
        )

        local valueLabel = label(
            licenseCard,
            tostring(value),
            UDim2.fromOffset(133, y),
            UDim2.fromOffset(140, 22),
            11,
            valueColor or WHITE,
            true
        )

        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    end

    local expires = licenseData.auth_expire

    if tostring(expires) == "-1" then
        expires = "Never"
    elseif expires == nil then
        expires = "Unknown"
    else
        expires = tostring(expires)
    end

    licenseRow("STATUS", "Verified", 85, GREEN)
    licenseRow("EXPIRES", expires, 113)
    licenseRow("EXECUTIONS", licenseData.total_executions or "Unknown", 141)
    licenseRow("PREMIUM", licenseData.premium and "Yes" or "No", 169)

    launchButton.Activated:Connect(function()
        if launching or not loaderUrl then
            return
        end

        launching = true
        launchButton.Text = "LOADING"
        launchButton.BackgroundColor3 = FIELD
        launchButton.AutoButtonColor = false

        task.spawn(function()
            local detectedErrors = {}
            local executionError = nil
            local errorConnection

            errorConnection = LogService.MessageOut:Connect(function(message, messageType)
                if messageType == Enum.MessageType.MessageError then
                    table.insert(detectedErrors, tostring(message))
                end
            end)

            task.spawn(function()
                local success, result = pcall(function()
                    if type(getgenv) == "function" then
                        getgenv().script_key = keyValue
                    else
                        script_key = keyValue
                    end

                    local source = game:HttpGet(loaderUrl)

                    if type(source) ~= "string" or source == "" then
                        error("Loader returned an empty response.")
                    end

                    local compiled, compileError = loadstring(source)

                    if type(compiled) ~= "function" then
                        error(compileError or "Could not compile loader.")
                    end

                    compiled()
                end)

                if not success then
                    executionError = tostring(result)
                end
            end)

            task.wait(2)

            if errorConnection then
                errorConnection:Disconnect()
            end

            local finalError = ""

            if executionError then
                finalError = executionError
            end

            if #detectedErrors > 0 then
                if finalError ~= "" then
                    finalError = finalError .. "\n\n"
                end

                finalError = finalError .. table.concat(detectedErrors, "\n\n")
            end

            if finalError == "" then
                ScreenGui:Destroy()
                return
            end

            launching = false

            local mainPanel = ScreenGui:FindFirstChild("Main")
            if mainPanel then
                mainPanel:Destroy()
            end

            showLaunchError(finalError)
        end)
    end)

    if forceRunPlaceId then
        if loaderUrl then
            task.defer(function()
                if launchButton and launchButton.Parent then
                    launchButton:Activate()
                end
            end)
        else
            task.defer(function()
                local mainPanel = ScreenGui:FindFirstChild("Main")
                if mainPanel then
                    mainPanel:Destroy()
                end
                showLaunchError("Unsupported force_run PlaceId: " .. tostring(forceRunPlaceId))
            end)
        end
    end
end

local Main = makeMain(UDim2.fromOffset(680, 370))

create("Frame", {
    Position = UDim2.fromOffset(335, 78),
    Size = UDim2.new(0, 1, 1, -105),
    BackgroundColor3 = Color3.fromRGB(48, 48, 53),
    BorderSizePixel = 0
}, Main)

local Left = create("Frame", {
    Position = UDim2.fromOffset(28, 85),
    Size = UDim2.fromOffset(275, 250),
    BackgroundTransparency = 1
}, Main)

local Right = create("Frame", {
    Position = UDim2.fromOffset(360, 85),
    Size = UDim2.fromOffset(285, 250),
    BackgroundTransparency = 1
}, Main)

label(
    Left,
    "LICENSE KEY",
    UDim2.fromOffset(0, 0),
    UDim2.fromOffset(270, 25),
    12,
    MUTED,
    true
)

local KeyBox = create("TextBox", {
    Position = UDim2.fromOffset(0, 34),
    Size = UDim2.fromOffset(275, 47),
    BackgroundColor3 = FIELD,
    BorderSizePixel = 0,
    PlaceholderText = "Paste your license key here",
    PlaceholderColor3 = MUTED,
    Text = keyValue,
    TextColor3 = WHITE,
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, Left)

round(KeyBox, 8)
outline(KeyBox, Color3.fromRGB(65, 65, 72), 0.3)

create("UIPadding", {
    PaddingLeft = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 10)
}, KeyBox)

local Submit = create("TextButton", {
    Position = UDim2.fromOffset(0, 94),
    Size = UDim2.fromOffset(145, 43),
    BackgroundColor3 = BLUE,
    BorderSizePixel = 0,
    Text = "SUBMIT",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold
}, Left)

round(Submit, 8)

local GetKey = create("TextButton", {
    Position = UDim2.fromOffset(155, 94),
    Size = UDim2.fromOffset(120, 43),
    BackgroundColor3 = FIELD,
    BorderSizePixel = 0,
    Text = "GET A KEY",
    TextColor3 = WHITE,
    TextSize = 12,
    Font = Enum.Font.GothamBold
}, Left)

round(GetKey, 8)
outline(GetKey, Color3.fromRGB(65, 65, 72), 0.4)

local Message = label(
    Left,
    "Connecting to LuaSec...",
    UDim2.fromOffset(0, 155),
    UDim2.fromOffset(275, 55),
    11,
    MUTED,
    false
)

Message.TextWrapped = true
Message.TextYAlignment = Enum.TextYAlignment.Top

label(
    Right,
    "DETECTED GAME",
    UDim2.fromOffset(0, 0),
    UDim2.fromOffset(270, 23),
    12,
    MUTED,
    true
)

local GameCard = create("Frame", {
    Position = UDim2.fromOffset(0, 30),
    Size = UDim2.fromOffset(285, 62),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, Right)

round(GameCard, 9)
outline(GameCard, Color3.fromRGB(65, 65, 72), 0.5)

label(
    GameCard,
    gameName,
    UDim2.fromOffset(15, 8),
    UDim2.fromOffset(255, 24),
    14,
    WHITE,
    true
)

label(
    GameCard,
    "Place ID: " .. tostring(game.PlaceId),
    UDim2.fromOffset(15, 34),
    UDim2.fromOffset(255, 18),
    10,
    MUTED,
    false
)

label(
    Right,
    "EXECUTOR",
    UDim2.fromOffset(0, 105),
    UDim2.fromOffset(110, 23),
    11,
    MUTED,
    true
)

local ExecutorValue = label(
    Right,
    executorName,
    UDim2.fromOffset(110, 105),
    UDim2.fromOffset(175, 23),
    12,
    WHITE,
    false
)

ExecutorValue.TextXAlignment = Enum.TextXAlignment.Right

label(
    Right,
    "KEY STATUS",
    UDim2.fromOffset(0, 135),
    UDim2.fromOffset(110, 23),
    11,
    MUTED,
    true
)

local KeyStatus = label(
    Right,
    keyValue ~= "" and "Not verified" or "Key required",
    UDim2.fromOffset(110, 135),
    UDim2.fromOffset(175, 23),
    12,
    keyValue ~= "" and LIGHT_BLUE or ORANGE,
    true
)

KeyStatus.TextXAlignment = Enum.TextXAlignment.Right

create("Frame", {
    Position = UDim2.fromOffset(0, 169),
    Size = UDim2.fromOffset(285, 1),
    BackgroundColor3 = Color3.fromRGB(48, 48, 53),
    BorderSizePixel = 0
}, Right)

local DiscordCard = create("TextButton", {
    Position = UDim2.fromOffset(0, 184),
    Size = UDim2.fromOffset(285, 48),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = true
}, Right)

round(DiscordCard, 8)
outline(DiscordCard, Color3.fromRGB(65, 65, 72), 0.5)

label(
    DiscordCard,
    "DISCORD",
    UDim2.fromOffset(14, 3),
    UDim2.fromOffset(250, 22),
    13,
    WHITE,
    true
)

label(
    DiscordCard,
    "discord.gg/5F9x5JrYwV",
    UDim2.fromOffset(14, 24),
    UDim2.fromOffset(250, 18),
    10,
    MUTED,
    false
)

local function setMessage(message, color)
    Message.Text = message
    Message.TextColor3 = color or MUTED
end

local function setKeyStatus(message, color)
    KeyStatus.Text = message
    KeyStatus.TextColor3 = color or MUTED
end

local statusMessages = {
    SEC_BAD_KEY = "Invalid or deleted key",
    SEC_DEVICE_LOCKED = "Key belongs to another device",
    SEC_BLOCKED = "Key has been blocked",
    SEC_LAPSED = "Key has expired",
    SEC_HELD = "Key is paused",
    SEC_NO_KEY = "Please enter your key",
    SEC_MALFORMED = "Invalid key format",
    SEC_SCRIPT_OFFLINE = "Script is offline",
    SEC_NO_SCRIPT = "Unknown script ID",
    SEC_THROTTLED = "Too many attempts. Wait.",
    SEC_NETWORK_FAIL = "Connection failed",
    SEC_NO_SCRIPT_ID = "Script ID is missing"
}

local function initializeLuaSec()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(LUA_SEC_URL))()
    end)

    if not success or type(result) ~= "table" then
        setMessage("LuaSec connection failed.", RED)
        setKeyStatus("Connection error", RED)
        return false
    end

    luasec = result
    luasec.script_id = SCRIPT_ID

    setMessage("LuaSec connected. Ready to verify.", LIGHT_BLUE)
    return true
end

local function verifyKey(key)
    if checking then
        return false
    end

    key = tostring(key or ""):match("^%s*(.-)%s*$")

    if key == "" then
        setMessage("Please enter your license key.", RED)
        setKeyStatus("Key required", ORANGE)
        return false
    end

    if not luasec then
        if not initializeLuaSec() then
            return false
        end
    end

    checking = true
    Submit.Text = "CHECKING..."
    setMessage("Checking your license...", LIGHT_BLUE)
    setKeyStatus("Checking...", LIGHT_BLUE)

    local callSuccess, result = pcall(function()
        return luasec.check_key(key)
    end)

    checking = false
    Submit.Text = "SUBMIT"

    if not callSuccess then
        setMessage("Verification error.", RED)
        setKeyStatus("Check failed", RED)
        return false
    end

    if type(result) ~= "table" then
        setMessage("Unexpected response from LuaSec.", RED)
        setKeyStatus("Unknown response", RED)
        return false
    end

    local code = result.code or "UNKNOWN"

    if code == "SEC_GRANTED" then
        setMessage("SUCCESS! Your license is valid.", GREEN)
        setKeyStatus("Key verified", GREEN)

        task.wait(0.35)
        showHub(result.data or {})
        return true
    end

    local message = statusMessages[code]
        or result.message
        or ("Verification failed: " .. tostring(code))

    setMessage(tostring(message), RED)
    setKeyStatus("Invalid key", RED)

    return false
end

local function saveAndVerify()
    if checking then
        return
    end

    local enteredKey = KeyBox.Text:match("^%s*(.-)%s*$")

    if enteredKey == "" then
        setMessage("Please enter your license key.", RED)
        setKeyStatus("Key required", ORANGE)
        return
    end

    keyValue = enteredKey

    if fileSupported then
        pcall(function()
            writefile(KEY_FILE, enteredKey)
        end)
    else
        setMessage("File saving is unavailable.", ORANGE)
    end

    verifyKey(enteredKey)
end

Submit.Activated:Connect(saveAndVerify)

GetKey.Activated:Connect(function()
    local success = pcall(function()
        GuiService:OpenBrowserWindow(GET_KEY_URL)
    end)

    if success then
        setMessage("Get key page opened.", LIGHT_BLUE)
    elseif setClipboard(GET_KEY_URL) then
        setMessage("Get key link copied.", LIGHT_BLUE)
    else
        setMessage("Could not open or copy the link.", RED)
    end
end)

DiscordCard.Activated:Connect(function()
    if setClipboard(DISCORD) then
        setMessage("Discord invite copied.", LIGHT_BLUE)
    else
        setMessage("Clipboard unavailable.", RED)
    end
end)

if initializeLuaSec() and keyValue ~= "" then
    task.spawn(function()
        task.wait(0.5)
        verifyKey(keyValue)
    end)
elseif keyValue == "" then
    setMessage("Enter your key and press SUBMIT.", MUTED)
end
