local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local COLORS = {
    primary = Color3.fromRGB(255, 192, 203),
    secondary = Color3.fromRGB(255, 218, 224),
    accent = Color3.fromRGB(255, 140, 160),
    accent_light = Color3.fromRGB(255, 182, 193),
    background = Color3.fromRGB(255, 255, 255),
    text_primary = Color3.fromRGB(75, 75, 75),
    text_secondary = Color3.fromRGB(120, 120, 120),
    success = Color3.fromRGB(46, 204, 113),
    error = Color3.fromRGB(231, 76, 60),
    warning = Color3.fromRGB(241, 196, 15),
    divider = Color3.fromRGB(240, 240, 240)
}

local function formatNumber(number)
    if number >= 1000000 then return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then return string.format("%.1fK", number / 1000)
    end
    return tostring(number)
end

local function createStatsUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BocchiWorldUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.BackgroundColor3 = COLORS.background
    mainContainer.BorderSizePixel = 0
    mainContainer.Size = UDim2.new(0, 380, 0, 280)
    mainContainer.Position = UDim2.new(1, -390, 0, 10)
    mainContainer.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = mainContainer
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = COLORS.accent
    containerStroke.Transparency = 0.8
    containerStroke.Thickness = 1
    containerStroke.Parent = mainContainer

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = COLORS.primary
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Parent = mainContainer
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "BOCCHI WORLD STATS"
    title.TextColor3 = COLORS.text_primary
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
    
    local function createStatItem(name, icon, position)
        local container = Instance.new("Frame")
        container.Name = name
        container.BackgroundColor3 = COLORS.secondary
        container.Size = UDim2.new(0.48, 0, 0, 38)
        container.Position = position
        container.Parent = statsContainer
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 8)
        itemCorner.Parent = container
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.BackgroundTransparency = 1
        iconLabel.Size = UDim2.new(0, 30, 1, -10)
        iconLabel.Position = UDim2.new(0, 10, 0, 5)
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Text = icon
        iconLabel.TextColor3 = COLORS.text_primary
        iconLabel.TextSize = 16
        iconLabel.Parent = container
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(0, 60, 0, 16)
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
        valueLabel.TextColor3 = COLORS.text_primary
        valueLabel.TextSize = 14
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Parent = container
        
        return valueLabel
    end
    
    local gemDisplay = createStatItem("Gems", "💎", UDim2.new(0, 0, 0, 0))
    local goldDisplay = createStatItem("Gold", "🏆", UDim2.new(0.52, 0, 0, 0))
    local legacyDisplay = createStatItem("Legacy", "⭐", UDim2.new(0, 0, 0, 44))
    local candyDisplay = createStatItem("Candy", "🍬", UDim2.new(0.52, 0, 0, 44))
    local starsDisplay = createStatItem("Stars", "✨", UDim2.new(0, 0, 0, 88))
    local winrateDisplay = createStatItem("Winrate", "📈", UDim2.new(0.52, 0, 0, 88))
    local gamesDisplay = createStatItem("Games", "🎮", UDim2.new(0, 0, 0, 132))
    local fpsDisplay = createStatItem("FPS", "⚡", UDim2.new(0.52, 0, 0, 132))
    local historyDisplay = createStatItem("History", "📊", UDim2.new(0, 0, 0, 176))
    
    local totalGames = 0
    local wins = 0
    local resultHistory = ""
    
    local function updatePickcardStatus(isEnabled)
        TweenService:Create(statusDot, TweenInfo.new(0.3), {
            BackgroundColor3 = isEnabled and COLORS.success or COLORS.error
        }):Play()
    end
    
    local function addGameResult(isWin)
        totalGames = totalGames + 1
        if isWin then wins = wins + 1 end
        resultHistory = (isWin and "✓" or "×") .. resultHistory
        if #resultHistory > 10 then resultHistory = resultHistory:sub(1, 10) end
        historyDisplay.Text = resultHistory
    end
    
    RunService.RenderStepped:Connect(function()
        local stats = Players.LocalPlayer:FindFirstChild("_stats")
        if stats then
            gemDisplay.Text = formatNumber(stats:FindFirstChild("gem_amount") and stats.gem_amount.Value or 0)
            goldDisplay.Text = formatNumber(stats:FindFirstChild("gold_amount") and stats.gold_amount.Value or 0)
            legacyDisplay.Text = formatNumber(stats:FindFirstChild("_resourceGemsLegacy") and stats._resourceGemsLegacy.Value or 0)
            candyDisplay.Text = formatNumber(stats:FindFirstChild("_resourceCandies") and stats._resourceCandies.Value or 0)
            starsDisplay.Text = formatNumber(stats:FindFirstChild("_resourceHolidayStars") and stats._resourceHolidayStars.Value or 0)
            winrateDisplay.Text = string.format("%.1f%%", totalGames > 0 and (wins/totalGames*100) or 0)
            gamesDisplay.Text = formatNumber(totalGames)
            fpsDisplay.Text = tostring(math.floor(1/RunService.RenderStepped:Wait()))
        end
    end)
    
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragStart, startPos
    
    local function onDragStart(input)
        dragging = true
        dragStart = input.Position
        startPos = mainContainer.Position
    end
    
    local function onDragEnd()
        dragging = false
    end
    
    local function onDragUpdate()
        if dragging and dragStart then
            local delta = UserInputService:GetMouseLocation() - dragStart
            mainContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    
    mainContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragStart(input)
        end
    end)
    
    mainContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragEnd()
        end
    end)
    
    RunService:BindToRenderStep("DragUpdate", Enum.RenderPriority.Camera.Value, onDragUpdate)
    
    return screenGui, updatePickcardStatus, addGameResult
end

local gui, updateStatus, addResult = createStatsUI()
_G.updatePickcardStatus = updateStatus
_G.addGameResult = addResult
