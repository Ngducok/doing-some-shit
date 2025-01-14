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

local function formatNumber(v1)
    if v1 >= 1000000 then return string.format("%.1fM", v1 / 1000000) end
    if v1 >= 1000 then return string.format("%.1fK", v1 / 1000) end
    return tostring(v1)
end

local function createStatItem(v1, v2, v3, v4)
    local v5 = Instance.new("Frame")
    v5.Name = v2
    v5.BackgroundColor3 = COLORS.secondary
    v5.Size = UDim2.new(0.48, 0, 0, 38)
    v5.Position = v4
    v5.Parent = v1

    local v6 = Instance.new("UICorner")
    v6.CornerRadius = UDim.new(0, 12)
    v6.Parent = v5

    local v7 = Instance.new("TextLabel")
    v7.BackgroundTransparency = 1
    v7.Size = UDim2.new(0, 30, 1, -10)
    v7.Position = UDim2.new(0, 10, 0, 5)
    v7.Font = Enum.Font.GothamBold
    v7.Text = v3
    v7.TextColor3 = COLORS.text
    v7.TextSize = 16
    v7.Parent = v5

    local v8 = Instance.new("TextLabel")
    v8.BackgroundTransparency = 1
    v8.Size = UDim2.new(0, 100, 0, 16)
    v8.Position = UDim2.new(0, 45, 0, 5)
    v8.Font = Enum.Font.GothamMedium
    v8.Text = v2
    v8.TextColor3 = COLORS.text_secondary
    v8.TextSize = 12
    v8.TextXAlignment = Enum.TextXAlignment.Left
    v8.Parent = v5

    local v9 = Instance.new("TextLabel")
    v9.BackgroundTransparency = 1
    v9.Size = UDim2.new(1, -55, 0, 16)
    v9.Position = UDim2.new(0, 45, 0, 20)
    v9.Font = Enum.Font.GothamSemibold
    v9.Text = "0"
    v9.TextColor3 = COLORS.text
    v9.TextSize = 14
    v9.TextXAlignment = Enum.TextXAlignment.Left
    v9.Parent = v5

    return v9
end

local function createStatsUI()
    local v1 = Instance.new("ScreenGui")
    v1.Name = "BocchiWorldUI"
    v1.ResetOnSpawn = false
    v1.IgnoreGuiInset = true
    v1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    v1.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local v2 = Instance.new("ImageButton")
    v2.Name = "BocchiToggle"
    v2.Image = "rbxassetid://15914181359"
    v2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    v2.BackgroundTransparency = 0.5
    v2.Size = UDim2.new(0, 50, 0, 50)
    v2.Position = UDim2.new(0, 10, 0.5, -25)
    v2.SizeConstraint = Enum.SizeConstraint.RelativeXY
    v2.ZIndex = 10

    local v3 = Instance.new("UICorner")
    v3.CornerRadius = UDim.new(0.5, 0)
    v3.Parent = v2
    v2.Parent = v1

    local v4 = Instance.new("Frame")
    v4.Name = "MainContainer"
    v4.BackgroundColor3 = COLORS.background
    v4.BorderSizePixel = 0
    v4.Size = UDim2.new(0, 380, 0, 320)
    v4.Position = UDim2.new(1, -390, 0.5, -160)
    v4.Visible = false
    v4.Parent = v1

    local v5 = Instance.new("UICorner")
    v5.CornerRadius = UDim.new(0, 20)
    v5.Parent = v4

    local v6 = Instance.new("Frame")
    v6.Name = "Header"
    v6.BackgroundColor3 = COLORS.primary
    v6.Size = UDim2.new(1, 0, 0, 50)
    v6.Parent = v4

    local v7 = Instance.new("UICorner")
    v7.CornerRadius = UDim.new(0, 20)
    v7.Parent = v6

    local v8 = Instance.new("TextLabel")
    v8.BackgroundTransparency = 1
    v8.Font = Enum.Font.GothamBlack
    v8.Text = "BOCCHI WORLD STATS"
    v8.TextColor3 = COLORS.text
    v8.TextSize = 20
    v8.Size = UDim2.new(1, -20, 1, 0)
    v8.Position = UDim2.new(0, 20, 0, 0)
    v8.TextXAlignment = Enum.TextXAlignment.Left
    v8.Parent = v6

    local v9 = Instance.new("Frame")
    v9.Name = "StatusDot"
    v9.Size = UDim2.new(0, 10, 0, 10)
    v9.Position = UDim2.new(1, -20, 0.5, 0)
    v9.AnchorPoint = Vector2.new(0, 0.5)
    v9.BackgroundColor3 = COLORS.error
    v9.Parent = v6

    local v10 = Instance.new("UICorner")
    v10.CornerRadius = UDim.new(1, 0)
    v10.Parent = v9

    local v11 = Instance.new("Frame")
    v11.Name = "StatsContainer"
    v11.BackgroundTransparency = 1
    v11.Size = UDim2.new(1, -40, 1, -70)
    v11.Position = UDim2.new(0, 20, 0, 60)
    v11.Parent = v4

    local v12 = {
        gem = createStatItem(v11, "Gems", "💎", UDim2.new(0, 0, 0, 0)),
        gold = createStatItem(v11, "Gold", "🏆", UDim2.new(0.52, 0, 0, 0)),
        legacy = createStatItem(v11, "Legacy", "⭐", UDim2.new(0, 0, 0, 44)),
        candy = createStatItem(v11, "Candy", "🍬", UDim2.new(0.52, 0, 0, 44)),
        stars = createStatItem(v11, "Stars", "✨", UDim2.new(0, 0, 0, 88)),
        winrate = createStatItem(v11, "Winrate", "📈", UDim2.new(0.52, 0, 0, 88)),
        games = createStatItem(v11, "Games", "🎮", UDim2.new(0, 0, 0, 132)),
        fps = createStatItem(v11, "FPS", "⚡", UDim2.new(0.52, 0, 0, 132)),
        history = createStatItem(v11, "History", "📊", UDim2.new(0, 0, 0, 176)),
        portal = createStatItem(v11, "Portal", "🌀", UDim2.new(0.52, 0, 0, 176))
    }

    local v13 = {
        totalGames = 0,
        wins = 0,
        resultHistory = "",
        lastTime = tick(),
        frameCount = 0,
        portalCount = 0
    }

    local function watchResultsUI()
        local v14 = Players.LocalPlayer:WaitForChild("PlayerGui")
        v14.ChildAdded:Connect(function(v15)
            if v15.Name == "ResultsUI" then
                task.wait(1)
                local v16 = v15:FindFirstChild("Background"):FindFirstChild("Result", true)
                if v16 and v16:IsA("TextLabel") then
                    v13.totalGames = v13.totalGames + 1
                    local v17 = v16.Text:lower():find("victory") ~= nil
                    if v17 then v13.wins = v13.wins + 1 end
                    v13.resultHistory = (v17 and "✓" or "×") .. v13.resultHistory
                    if #v13.resultHistory > 10 then v13.resultHistory = v13.resultHistory:sub(1, 10) end
                    v12.history.Text = v13.resultHistory
                    v12.games.Text = formatNumber(v13.totalGames)
                    v12.winrate.Text = string.format("%.1f%%", (v13.wins / v13.totalGames * 100))
                end
            end
        end)
    end

    v2.MouseButton1Click:Connect(function()
        v4.Visible = not v4.Visible
    end)

    if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
        UserInputService.InputBegan:Connect(function(v18, v19)
            if not v19 and v18.KeyCode == Enum.KeyCode.LeftControl then
                v4.Visible = not v4.Visible
            end
        end)
    end

    -- Drag functionality for both button and container
    local dragging = false
    local dragStart
    local startPos

    local function updateDrag(input, target)
        local delta = input.Position - dragStart
        target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function startDrag(input, target)
        dragging = true
        dragStart = input.Position
        startPos = target.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    -- Drag for the button
    v2.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input, v2)
        end
    end)

    v2.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input, v2)
        end
    end)

    -- Drag for the container
    v6.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input, v4)
        end
    end)

    v6.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input, v4)
        end
    end)

    RunService.RenderStepped:Connect(function()
        v13.frameCount = v13.frameCount + 1
        local v26 = tick()

        if v26 - v13.lastTime >= 1 then
            v12.fps.Text = tostring(math.floor(v13.frameCount / (v26 - v13.lastTime)))
            v13.frameCount = 0
            v13.lastTime = v26
        end

        local v27 = Players.LocalPlayer:FindFirstChild("_stats")
        if v27 then
            v12.gem.Text = formatNumber(v27:FindFirstChild("gem_amount") and v27.gem_amount.Value or 0)
            v12.gold.Text = formatNumber(v27:FindFirstChild("gold_amount") and v27.gold_amount.Value or 0)
            v12.legacy.Text = formatNumber(v27:FindFirstChild("_resourceGemsLegacy") and v27._resourceGemsLegacy.Value or 0)
            v12.candy.Text = formatNumber(v27:FindFirstChild("_resourceCandies") and v27._resourceCandies.Value or 0)
            v12.stars.Text = formatNumber(v27:FindFirstChild("_resourceHolidayStars") and v27._resourceHolidayStars.Value or 0)
        end
    end)

    local function updatePickcardStatus(v28)
        TweenService:Create(v9, TweenInfo.new(0.3), {
            BackgroundColor3 = v28 and COLORS.success or COLORS.error
        }):Play()
    end

    local function addGameResult(v29)
        v13.totalGames = v13.totalGames + 1
        if v29 then v13.wins = v13.wins + 1 end
        v13.resultHistory = (v29 and "✓" or "×") .. v13.resultHistory
        if #v13.resultHistory > 10 then v13.resultHistory = v13.resultHistory:sub(1, 10) end
        v12.history.Text = v13.resultHistory
    end

    local function incrementPortal()
        v13.portalCount = v13.portalCount + 1
        v12.portal.Text = tostring(v13.portalCount)
    end

    watchResultsUI()

    return v1, updatePickcardStatus, addGameResult, incrementPortal
end

local v30, v31, v32, v33 = createStatsUI()
_G.updatePickcardStatus = v31
_G.addGameResult = v32
_G.incrementPortal = v33
