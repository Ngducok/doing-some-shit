local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local COLORS = {
    primary = Color3.fromRGB(255, 182, 193),
    secondary = Color3.fromRGB(255, 218, 224),
    background = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(75, 75, 75),
    accent = Color3.fromRGB(255, 140, 160),
    highlight = Color3.fromRGB(255, 192, 203)
}

local function formatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    end
    return tostring(number)
end

local function createStatsUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local oldGui = playerGui:FindFirstChild("BocchiWorldUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BocchiWorldUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.BackgroundColor3 = COLORS.background
    mainContainer.BackgroundTransparency = 0.6
    mainContainer.BorderSizePixel = 0
    mainContainer.Size = UDim2.new(0, 400, 0, 200)
    mainContainer.Position = UDim2.new(0.5, 0, 0, 20)
    mainContainer.AnchorPoint = Vector2.new(0.5, 0)
    mainContainer.Parent = screenGui
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = COLORS.primary
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = mainContainer
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainContainer
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.background),
        ColorSequenceKeypoint.new(1, COLORS.secondary)
    })
    gradient.Rotation = 45
    gradient.Parent = mainContainer
    
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.BackgroundColor3 = COLORS.primary
    titleContainer.BackgroundTransparency = 0.5
    titleContainer.Size = UDim2.new(1, -20, 0, 40)
    titleContainer.Position = UDim2.new(0, 10, 0, 10)
    titleContainer.Parent = mainContainer
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleContainer
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.Text = "BOCCHI WORLD"
    titleText.TextColor3 = COLORS.text
    titleText.TextSize = 24
    titleText.Parent = titleContainer
    
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.BackgroundTransparency = 1
    statsContainer.Size = UDim2.new(1, -20, 0, 120)
    statsContainer.Position = UDim2.new(0, 10, 0, 60)
    statsContainer.Parent = mainContainer
    
    local function createResourceDisplay(name, icon, position)
        local container = Instance.new("Frame")
        container.Name = name .. "Container"
        container.BackgroundColor3 = COLORS.secondary
        container.BackgroundTransparency = 0.5
        container.Size = UDim2.new(0.48, 0, 0, 35)
        container.Position = position
        container.Parent = statsContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = container
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.BackgroundTransparency = 1
        iconLabel.Size = UDim2.new(0, 25, 1, 0)
        iconLabel.Position = UDim2.new(0, 10, 0, 0)
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Text = icon
        iconLabel.TextColor3 = COLORS.text
        iconLabel.TextSize = 18
        iconLabel.Parent = container
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.new(1, -50, 1, 0)
        valueLabel.Position = UDim2.new(0, 40, 0, 0)
        valueLabel.Font = Enum.Font.GothamSemibold
        valueLabel.Text = "0"
        valueLabel.TextColor3 = COLORS.text
        valueLabel.TextSize = 16
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Parent = container
        
        container.MouseEnter:Connect(function()
            TweenService:Create(container, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
        end)
        
        container.MouseLeave:Connect(function()
            TweenService:Create(container, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
        end)
        
        return valueLabel
    end
    
    local gemDisplay = createResourceDisplay("Gems", "💎", UDim2.new(0, 0, 0, 0))
    local goldDisplay = createResourceDisplay("Gold", "🏆", UDim2.new(0.52, 0, 0, 0))
    local legacyDisplay = createResourceDisplay("Legacy", "⭐", UDim2.new(0, 0, 0, 40))
    local candyDisplay = createResourceDisplay("Candy", "🍬", UDim2.new(0.52, 0, 0, 40))
    local starsDisplay = createResourceDisplay("Stars", "✨", UDim2.new(0, 0, 0, 80))
    local fpsDisplay = createResourceDisplay("FPS", "📊", UDim2.new(0.52, 0, 0, 80))
    
    local discordLink = Instance.new("TextButton")
    discordLink.Name = "DiscordLink"
    discordLink.BackgroundTransparency = 1
    discordLink.Position = UDim2.new(0, 0, 1, -25)
    discordLink.Size = UDim2.new(1, 0, 0, 20)
    discordLink.Font = Enum.Font.GothamMedium
    discordLink.Text = "discord.gg/9jjw973u"
    discordLink.TextColor3 = COLORS.accent
    discordLink.TextSize = 14
    discordLink.Parent = mainContainer
    
    discordLink.MouseEnter:Connect(function()
        TweenService:Create(discordLink, TweenInfo.new(0.3), {TextColor3 = COLORS.highlight}):Play()
    end)
    
    discordLink.MouseLeave:Connect(function()
        TweenService:Create(discordLink, TweenInfo.new(0.3), {TextColor3 = COLORS.accent}):Play()
    end)
    
    local player = Players.LocalPlayer
    local lastUpdate = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        if tick() - lastUpdate >= 1 then
            local fps = frameCount / (tick() - lastUpdate)
            local stats = player:FindFirstChild("_stats")
            
            if stats then
                local gem = stats:FindFirstChild("gem_amount") and stats.gem_amount.Value or 0
                local gold = stats:FindFirstChild("gold_amount") and stats.gold_amount.Value or 0
                local gemLegacy = stats:FindFirstChild("_resourceGemsLegacy") and stats._resourceGemsLegacy.Value or 0
                local candy = stats:FindFirstChild("_resourceCandies") and stats._resourceCandies.Value or 0
                local holidayStars = stats:FindFirstChild("_resourceHolidayStars") and stats._resourceHolidayStars.Value or 0
                
                gemDisplay.Text = formatNumber(gem)
                goldDisplay.Text = formatNumber(gold)
                legacyDisplay.Text = formatNumber(gemLegacy)
                candyDisplay.Text = formatNumber(candy)
                starsDisplay.Text = formatNumber(holidayStars)
                fpsDisplay.Text = string.format("%.1f", fps)
            end
            
            lastUpdate = tick()
            frameCount = 0
        end
    end)
    
    local UserInputService = game:GetService("UserInputService")
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    
    mainContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
        end
    end)
    
    mainContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging and dragStart and startPos then
            local delta = UserInputService:GetMouseLocation() - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            mainContainer.Position = newPosition
        end
    end)
    
    return screenGui
end

createStatsUI()
