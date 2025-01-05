local function clearOldGUI()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local oldGui = playerGui:FindFirstChild("CustomGUI")
    if oldGui then
        oldGui:Destroy()
    end
end
local function createGUI()
    clearOldGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomGUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 380, 0, 130)
    frame.Position = UDim2.new(0.5, 0, 0.5, -190)

    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, -20)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 20
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = frame
    local runService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local lastUpdate = tick()
    local frameCount = 0

    runService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastUpdate >= 1 then
            local fps = frameCount / (tick() - lastUpdate)
            local gem = player:FindFirstChild("_stats"):FindFirstChild("gem_amount") and player._stats.gem_amount.Value or 0
            local gold = player:FindFirstChild("_stats"):FindFirstChild("gold_amount") and player._stats.gold_amount.Value or 0
            local gemLegacy = player:FindFirstChild("_stats"):FindFirstChild("_resourceGemsLegacy") and player._stats._resourceGemsLegacy.Value or 0
            local candy = player:FindFirstChild("_stats"):FindFirstChild("_resourceCandies") and player._stats._resourceCandies.Value or 0
            local holidayStars = player:FindFirstChild("_stats"):FindFirstChild("_resourceHolidayStars") and player._stats._resourceHolidayStars.Value or 0

            textLabel.Text = string.format(
                "Bocchi World\ndiscord.gg/4bmwn5E3Gw\nGem: %d  Gold: %d  Gem Legacy: %d\nCandy: %d  Holiday Stars: %d\nFPS: %.1f",
                gem, gold, gemLegacy, candy, holidayStars, fps
            )

            lastUpdate = tick()
            frameCount = 0
        end
    end)
end
createGUI()
