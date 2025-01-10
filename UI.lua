local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local COLORS = {
    primary = Color3.fromRGB(255, 192, 203),
    secondary = Color3.fromRGB(255, 218, 224),
    background = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(75, 75, 75),
    text_secondary = Color3.fromRGB(120, 120, 120),
    success = Color3.fromRGB(46, 204, 113),
    error = Color3.fromRGB(231, 76, 60)
}

local function formatNumber(number)
    if number >= 1000000 then return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then return string.format("%.1fK", number / 1000)
    end
    return tostring(number)
end

local function createStatItem(parent, name, icon, position)
    local container = Instance.new("Frame")
    container.Name = name
    container.BackgroundColor3 = COLORS.secondary
    container.Size = UDim2.new(0.48, 0, 0, 38)
    container.Position = position
    container.Parent = parent
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 12)
    itemCorner.Parent = container
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.BackgroundTransparency = 1
    iconLabel.Size = UDim2.new(0, 30, 1, -10)
    iconLabel.Position = UDim2.new(0, 10, 0, 5)
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = icon
    iconLabel.TextColor3 = COLORS.text
    iconLabel.TextSize = 16
    iconLabel.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0, 100, 0, 16)
    nameLabel.Position = UDim2.new(0, 45, 0, 5)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Text = name
    nameLabel.TextColor3 = COLORS.text_secondary
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, -55, 0, 16)
    valueLabel.Position = UDim2.new(0, 45, 0, 20)
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.Text = "0"
    valueLabel.TextColor3 = COLORS.text
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = container
    
    return valueLabel
end

local function createStatsUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BocchiWorldUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Name = "BocchiToggle"
    toggleButton.Image = "rbxassetid://15914181359"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BackgroundTransparency = 0.5
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 10, 0.5, -25)
    toggleButton.SizeConstraint = Enum.SizeConstraint.RelativeXY
    toggleButton.ZIndex = 10
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.5, 0)
    uiCorner.Parent = toggleButton
    
    toggleButton.Parent = screenGui
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.BackgroundColor3 = COLORS.background
    mainContainer.BorderSizePixel = 0
    mainContainer.Size = UDim2.new(0, 380, 0, 320)
    mainContainer.Position = UDim2.new(1, -390, 0.5, -160)
    mainContainer.Visible = false
    mainContainer.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 20)
    containerCorner.Parent = mainContainer

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = COLORS.primary
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Parent = mainContainer
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "BOCCHI WORLD STATS"
    title.TextColor3 = COLORS.text
    title.TextSize = 20
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(1, -20, 0.5, 0)
    statusDot.AnchorPoint = Vector2.new(0, 0.5)
    statusDot.BackgroundColor3 = COLORS.error
    statusDot.Parent = header
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusDot
    
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.BackgroundTransparency = 1
    statsContainer.Size = UDim2.new(1, -40, 1, -70)
    statsContainer.Position = UDim2.new(0, 20, 0, 60)
    statsContainer.Parent = mainContainer
    
    local displays = {
        gem = createStatItem(statsContainer, "Gems", "💎", UDim2.new(0, 0, 0, 0)),
        gold = createStatItem(statsContainer, "Gold", "🏆", UDim2.new(0.52, 0, 0, 0)),
        legacy = createStatItem(statsContainer, "Legacy", "⭐", UDim2.new(0, 0, 0, 44)),
        candy = createStatItem(statsContainer, "Candy", "🍬", UDim2.new(0.52, 0, 0, 44)),
        stars = createStatItem(statsContainer, "Stars", "✨", UDim2.new(0, 0, 0, 88)),
        winrate = createStatItem(statsContainer, "Winrate", "📈", UDim2.new(0.52, 0, 0, 88)),
        games = createStatItem(statsContainer, "Games", "🎮", UDim2.new(0, 0, 0, 132)),
        fps = createStatItem(statsContainer, "FPS", "⚡", UDim2.new(0.52, 0, 0, 132)),
        history = createStatItem(statsContainer, "History", "📊", UDim2.new(0, 0, 0, 176)),
        portal = createStatItem(statsContainer, "Portal", "🌀", UDim2.new(0.52, 0, 0, 176))
    }
    
    local stats = {
        totalGames = 0,
        wins = 0,
        resultHistory = "",
        lastTime = tick(),
        frameCount = 0,
        portalCount = 0
    }

    local function watchResultsUI()
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        playerGui.ChildAdded:Connect(function(child)
            if child.Name == "ResultsUI" then
                task.wait(1)
                local resultText = child:FindFirstChild("Background"):FindFirstChild("Result", true)
                if resultText and resultText:IsA("TextLabel") then
                    stats.totalGames = stats.totalGames + 1
                    local isWin = resultText.Text:lower():find("victory") ~= nil
                    if isWin then
                        stats.wins = stats.wins + 1
                    end
                    stats.resultHistory = (isWin and "✓" or "×") .. stats.resultHistory
                    if #stats.resultHistory > 10 then
                        stats.resultHistory = stats.resultHistory:sub(1, 10)
                    end
                    displays.history.Text = stats.resultHistory
                    displays.games.Text = formatNumber(stats.totalGames)
                    displays.winrate.Text = string.format("%.1f%%", (stats.wins/stats.totalGames*100))
                end
            end
        end)
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        mainContainer.Visible = not mainContainer.Visible
    end)
    
    if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
                mainContainer.Visible = not mainContainer.Visible
            end
        end)
    end
    
    local dragging, dragStart, startPos
    
    mainContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
        end
    end)
    
    mainContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    RunService:BindToRenderStep("DragUpdate", Enum.RenderPriority.Camera.Value, function()
        if dragging and dragStart then
            local delta = UserInputService:GetMouseLocation() - dragStart
            mainContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        stats.frameCount = stats.frameCount + 1
        local currentTime = tick()
        
        if currentTime - stats.lastTime >= 1 then
            displays.fps.Text = tostring(math.floor(stats.frameCount / (currentTime - stats.lastTime)))
            stats.frameCount = 0
            stats.lastTime = currentTime
        end
        
        local playerStats = Players.LocalPlayer:FindFirstChild("_stats")
        if playerStats then
            displays.gem.Text = formatNumber(playerStats:FindFirstChild("gem_amount") and playerStats.gem_amount.Value or 0)
            displays.gold.Text = formatNumber(playerStats:FindFirstChild("gold_amount") and playerStats.gold_amount.Value or 0)
            displays.legacy.Text = formatNumber(playerStats:FindFirstChild("_resourceGemsLegacy") and playerStats._resourceGemsLegacy.Value or 0)
            displays.candy.Text = formatNumber(playerStats:FindFirstChild("_resourceCandies") and playerStats._resourceCandies.Value or 0)
            displays.stars.Text = formatNumber(playerStats:FindFirstChild("_resourceHolidayStars") and playerStats._resourceHolidayStars.Value or 0)
        end
    end)
    
    local function updatePickcardStatus(isEnabled)
        TweenService:Create(statusDot, TweenInfo.new(0.3), {
            BackgroundColor3 = isEnabled and COLORS.success or COLORS.error
        }):Play()
    end
    
    local function addGameResult(isWin)
        stats.totalGames = stats.totalGames + 1
        if isWin then stats.wins = stats.wins + 1 end
        stats.resultHistory = (isWin and "✓" or "×") .. stats.resultHistory
        if #stats.resultHistory > 10 then stats.resultHistory = stats.resultHistory:sub(1, 10) end
        displays.history.Text = stats.resultHistory
    end
    
    local function incrementPortal()
        stats.portalCount = stats.portalCount + 1
        displays.portal.Text = tostring(stats.portalCount)
    end

    watchResultsUI()
    
    return screenGui, updatePickcardStatus, addGameResult, incrementPortal
end

local gui, updateStatus, addResult, addPortal = createStatsUI()
_G.updatePickcardStatus = updateStatus
_G.addGameResult = addResult
_G.incrementPortal = addPortal
