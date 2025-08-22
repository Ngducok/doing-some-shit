
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ShoukoClient = {
    version = "4.0",
    domain = "https://spyconcac.shoukov2.dev",
    status = "initializing",
    startTime = tick(),
    authenticated = false,
    sessionActive = false,
    lastHeartbeat = 0
}

local function safeNotify(title, text, duration)
    local success = pcall(function()
        if game:GetService("StarterGui") then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 3
            })
        end
    end)
    if not success then
        print("[" .. title .. "] " .. text)
    end
end

local function log(level, message)
    local timestamp = string.format("[%.2f]", tick() - ShoukoClient.startTime)
    local prefix = "[Shouko " .. level .. "]"
    print(timestamp .. " " .. prefix .. " " .. message)
end

local function generateLoaderName(key, discord)
    local combined = key .. discord .. "shouko.dev"
    local hash = 0
    for i = 1, #combined do
        hash = (hash * 31 + string.byte(combined, i)) % 1000000
    end
    return "loader_" .. tostring(hash) .. "_" .. string.sub(combined, 1, 8):gsub("%W", "")
end

local function validateCredentials()
    if not getgenv().key or getgenv().key == "" or getgenv().key == "YOUR_KEY_HERE" then
        log("ERROR", "Invalid or missing key")
        safeNotify("Shouko Auth", "Please set your key", 5)
        return false
    end

    if not getgenv().discordid or getgenv().discordid == "" or getgenv().discordid == "YOUR_DISCORD_ID_HERE" then
        log("ERROR", "Invalid or missing Discord ID")
        safeNotify("Shouko Auth", "Please set your Discord ID", 5)
        return false
    end

    if #getgenv().key < 3 then
        log("ERROR", "Key too short")
        return false
    end

    if #tostring(getgenv().discordid) < 17 or #tostring(getgenv().discordid) > 19 then
        log("ERROR", "Invalid Discord ID format")
        return false
    end

    return true
end

local function validateEnvironment()
    local checks = {
        {game, "Game object not found"},
        {game.PlaceId, "PlaceId not available"},
        {Players.LocalPlayer, "LocalPlayer not found"}
    }

    for i, check in ipairs(checks) do
        if not check[1] then
            log("ERROR", check[2])
            return false
        end
    end

    return true
end

local function displayInfo()
    log("INFO", "Shouko Authentication Client v" .. ShoukoClient.version)
    log("INFO", "User: " .. (Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"))
    log("INFO", "Place ID: " .. tostring(game.PlaceId))
    log("INFO", "Key: " .. string.sub(tostring(getgenv().key), 1, 3) .. "***")
    log("INFO", "Discord: " .. string.sub(tostring(getgenv().discordid), 1, 4) .. "***")

    local loaderName = generateLoaderName(getgenv().key, getgenv().discordid)
    log("INFO", "Your Loader: " .. loaderName)
    log("INFO", "CDN URL: " .. ShoukoClient.domain .. "/auth/" .. loaderName)
end

local function performAuthentication()
    ShoukoClient.status = "connecting"
    log("AUTH", "Connecting to Shouko servers...")

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = ShoukoClient.domain .. "/hidden",
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet",
                ["X-Shouko-Version"] = ShoukoClient.version,
                ["X-Shouko-Client"] = "Vitt"
            }
        })
    end)

    if not success then
        ShoukoClient.status = "network_error"
        log("ERROR", "Network connection failed")
        safeNotify("Shouko Auth", "Network error - Check connection", 5)
        return false
    end

    if not response.Success then
        ShoukoClient.status = "server_error"
        log("ERROR", "Server error: " .. tostring(response.StatusCode))
        safeNotify("Shouko Auth", "Server error: " .. tostring(response.StatusCode), 5)
        return false
    end

    if response.StatusCode ~= 200 then
        ShoukoClient.status = "http_error"
        log("ERROR", "HTTP error: " .. tostring(response.StatusCode))
        return false
    end

    if response.Body then
        if response.Body:find("error%(") then
            local errorMsg = response.Body:match("error%('([^']+)'%)") or "Parse error"
            ShoukoClient.status = "auth_error"
            log("ERROR", "Authentication error: " .. errorMsg)
            log("DEBUG", "Response body: " .. string.sub(response.Body, 1, 200))
            safeNotify("Shouko Auth", "Auth Error: " .. errorMsg, 5)
            return false
        end

        if response.Body:find("Access denied") or response.Body:find("Rate limit") then
            ShoukoClient.status = "access_denied"
            log("ERROR", "Access denied or rate limited")
            safeNotify("Shouko Auth", "Access denied", 5)
            return false
        end
    end

    ShoukoClient.status = "executing"
    log("AUTH", "Executing authentication loader...")

    local executeSuccess, executeError = pcall(function()
        loadstring(response.Body)()
    end)

    if executeSuccess then
        ShoukoClient.status = "loading"
        log("SUCCESS", "Authentication loader executed successfully")
        return true
    else
        ShoukoClient.status = "execution_error"
        log("ERROR", "Failed to execute authentication loader: " .. tostring(executeError))
        safeNotify("Shouko Auth", "Execution failed", 5)
        return false
    end
end

local function monitorAuthentication()
    local maxWaitTime = 30
    local waited = 0

    local function checkAuth()
        if getgenv().SHOUKO_AUTHENTICATED then
            ShoukoClient.authenticated = true
            ShoukoClient.status = "authenticated"
            log("SUCCESS", "Authentication completed successfully!")

            if getgenv().SHOUKO_SESSION then
                log("INFO", "Session ID: " .. tostring(getgenv().SHOUKO_SESSION))
            end

            if getgenv().SHOUKO_RUNTIME_TOKEN then
                log("INFO", "Runtime Token: Active")
            end

            if getgenv().E2EE_CLIENT then
                log("INFO", "E2EE Status: Ready")
            end

            safeNotify("Shouko Auth", "Authentication successful!", 3)
            return true
        end
        return false
    end

    while waited < maxWaitTime and not ShoukoClient.authenticated do
        if checkAuth() then
            break
        end

        pcall(function() wait(1) end)
        waited = waited + 1

        if waited % 5 == 0 then
            log("MONITOR", "Waiting for authentication... (" .. waited .. "s)")
        end
    end

    if not ShoukoClient.authenticated then
        ShoukoClient.status = "timeout"
        log("ERROR", "Authentication timeout after " .. maxWaitTime .. " seconds")
        safeNotify("Shouko Auth", "Authentication timeout", 5)
    end
end

local function startHeartbeat()
    local function sendHeartbeat()
        if not ShoukoClient.authenticated then
            return
        end

        local currentTime = tick()
        if currentTime - ShoukoClient.lastHeartbeat < 30 then
            return
        end

        ShoukoClient.lastHeartbeat = currentTime

        if getgenv().SHOUKO_SESSION_ACTIVE then
            log("HEARTBEAT", "Session active - Runtime: " .. (getgenv().SHOUKO_RUNTIME_TOKEN and "Valid" or "Invalid"))
            ShoukoClient.sessionActive = true
        else
            log("HEARTBEAT", "Session inactive")
            ShoukoClient.sessionActive = false

            if ShoukoClient.authenticated then
                log("WARNING", "Session lost - authentication may be required")
                ShoukoClient.authenticated = false
            end
        end
    end

    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        pcall(sendHeartbeat)

        if not ShoukoClient.authenticated and ShoukoClient.sessionActive then
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
            end
        end
    end)
end

local function startStatusMonitor()
    local lastStatus = ""

    local function updateStatus()
        if ShoukoClient.status ~= lastStatus then
            log("STATUS", "Status changed: " .. lastStatus .. " -> " .. ShoukoClient.status)
            lastStatus = ShoukoClient.status
        end
    end

    local statusConnection
    statusConnection = RunService.Heartbeat:Connect(function()
        pcall(updateStatus)
    end)

    pcall(function() wait(300) end)
    if statusConnection then
        statusConnection:Disconnect()
    end
end

local function initialize()
    log("INIT", "Starting Shouko Authentication Client...")

    if not validateEnvironment() then
        return
    end

    if not validateCredentials() then
        return
    end

    displayInfo()

    local authSuccess = performAuthentication()
    if not authSuccess then
        log("FAILED", "Authentication initialization failed")
        return
    end

    monitorAuthentication()

    spawn(function()
        pcall(function() wait(5) end)
        if ShoukoClient.authenticated then
            startHeartbeat()
        end
    end)

    spawn(startStatusMonitor)
end

local function handleShutdown()
    log("SHUTDOWN", "Client shutting down...")
    ShoukoClient.authenticated = false
    ShoukoClient.sessionActive = false
    if getgenv().SHOUKO_SESSION_ACTIVE then
        getgenv().SHOUKO_SESSION_ACTIVE = false
    end
end

local function safeInitialize()
    local success, error = pcall(initialize)
    if not success then
        log("CRITICAL", "Client initialization failed: " .. tostring(error))
        safeNotify("Shouko Auth", "Critical error occurred", 5)
        return false
    end
    return true
end

local function createSimpleGUI()
    local success = pcall(function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        if not player or not player:FindFirstChild("PlayerGui") then
            return
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ShoukoStatus"
        screenGui.Parent = player.PlayerGui
        screenGui.ResetOnSpawn = false

        local frame = Instance.new("Frame")
        frame.Name = "StatusFrame"
        frame.Parent = screenGui
        frame.Size = UDim2.new(0, 200, 0, 60)
        frame.Position = UDim2.new(0, 10, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0

        local corner = Instance.new("UICorner")
        corner.Parent = frame
        corner.CornerRadius = UDim.new(0, 8)

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusLabel"
        statusLabel.Parent = frame
        statusLabel.Size = UDim2.new(1, 0, 0.6, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Shouko: Initializing..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.TextScaled = true
        statusLabel.Font = Enum.Font.GothamBold

        local versionLabel = Instance.new("TextLabel")
        versionLabel.Name = "VersionLabel"
        versionLabel.Parent = frame
        versionLabel.Size = UDim2.new(1, 0, 0.4, 0)
        versionLabel.Position = UDim2.new(0, 0, 0.6, 0)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = "v" .. ShoukoClient.version
        versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        versionLabel.TextScaled = true
        versionLabel.Font = Enum.Font.Gotham

        local function updateGUI()
            local statusText = "Shouko: " .. ShoukoClient.status
            local statusColor = Color3.fromRGB(255, 255, 255)

            if ShoukoClient.status == "authenticated" then
                statusColor = Color3.fromRGB(0, 255, 0)
            elseif ShoukoClient.status:find("error") then
                statusColor = Color3.fromRGB(255, 0, 0)
            elseif ShoukoClient.status == "loading" then
                statusColor = Color3.fromRGB(255, 255, 0)
            end

            statusLabel.Text = statusText
            statusLabel.TextColor3 = statusColor
        end

        task.spawn(function()
            while screenGui.Parent do
                updateGUI()
                wait(1)
            end
        end)

        task.spawn(function()
            wait(60)
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    end)

    if not success then
        log("GUI", "Failed to create status GUI")
    end
end

if safeInitialize() then
    log("CLIENT", "Shouko Exploit Client loaded - Status: " .. ShoukoClient.status)

    task.spawn(function()
        wait(2)
        createSimpleGUI()
    end)

    task.spawn(function()
        while true do
            wait(30)
            if ShoukoClient.authenticated then
                log("ALIVE", "Client running - Session: " .. (ShoukoClient.sessionActive and "Active" or "Inactive"))
            end
        end
    end)
else
    warn("Shouko Client failed to initialize")
end
