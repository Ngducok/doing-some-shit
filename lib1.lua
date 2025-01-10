local Library = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Constants
local THEME = {
    Primary = Color3.fromRGB(32, 35, 37),
    Secondary = Color3.fromRGB(44, 47, 51),
    Accent = Color3.fromRGB(114, 137, 218),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(240, 71, 71),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(185, 187, 190)
}

local FONTS = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Text = Enum.Font.Gotham
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    return instance
end

local function Tween(object, duration, properties)
    return TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quart),
        properties
    ):Play()
end

function Library.new(title)
    local UI = {}
    
    -- Create Base GUI
    UI.ScreenGui = Create("ScreenGui", {
        Name = "EnhancedUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    })
    
    -- Create Loading Screen
    UI.LoadingScreen = Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = THEME.Primary,
        Parent = UI.ScreenGui
    })
    
    local loadingIcon = Create("ImageLabel", {
        Name = "LoadingIcon",
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0.5, -40, 0.5, -40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031251532",
        Parent = UI.LoadingScreen
    })
    
    -- Create Main Container
    UI.MainContainer = Create("Frame", {
        Name = "MainContainer",
        Size = UDim2.new(0, 850, 0, 500),
        Position = UDim2.new(0.5, -425, 0.5, -250),
        BackgroundColor3 = THEME.Primary,
        BackgroundTransparency = 0.1,
        Visible = false,
        Parent = UI.ScreenGui
    })
    
    -- Add Blur Effect
    local blur = Create("BlurEffect", {
        Size = 10,
        Parent = UI.MainContainer
    })
    
    -- Create TopBar
    UI.TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = THEME.Secondary,
        Parent = UI.MainContainer
    })
    
    -- Add Title
    UI.Title = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Enhanced UI",
        TextColor3 = THEME.Text,
        TextSize = 22,
        Font = FONTS.Title,
        Parent = UI.TopBar
    })
    
    -- Create Sidebar
    UI.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = THEME.Secondary,
        Parent = UI.MainContainer
    })
    
    -- Create Content Area
    UI.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -200, 1, -50),
        Position = UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = THEME.Primary,
        Parent = UI.MainContainer
    })
    
    -- Add Corners
    local function AddCorners(instance)
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = instance
        })
    end
    
    AddCorners(UI.MainContainer)
    AddCorners(UI.TopBar)
    AddCorners(UI.Sidebar)
    AddCorners(UI.ContentArea)
    
    -- Add Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 47, 1, 47),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        Parent = UI.MainContainer
    })
    
    -- Setup Dragging
    local dragging, dragStart, startPos = false, nil, nil
    
    UI.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = UI.MainContainer.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            UI.MainContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Tab System
    UI.Tabs = {}
    UI.ActiveTab = nil
    
    function UI:AddTab(name, icon)
        local tab = {
            Button = Create("TextButton", {
                Name = name,
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, #UI.Tabs * 50 + 10),
                BackgroundColor3 = THEME.Accent,
                BackgroundTransparency = 0.9,
                Text = name,
                TextColor3 = THEME.Text,
                TextSize = 14,
                Font = FONTS.Header,
                Parent = UI.Sidebar
            }),
            Content = Create("ScrollingFrame", {
                Name = name .. "Content",
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                Visible = false,
                Parent = UI.ContentArea
            })
        }
        
        AddCorners(tab.Button)
        
        tab.Button.MouseButton1Click:Connect(function()
            if UI.ActiveTab then
                UI.ActiveTab.Content.Visible = false
                UI.ActiveTab.Button.BackgroundTransparency = 0.9
            end
            UI.ActiveTab = tab
            tab.Content.Visible = true
            tab.Button.BackgroundTransparency = 0.7
        end)
        
        if #UI.Tabs == 0 then
            UI.ActiveTab = tab
            tab.Content.Visible = true
            tab.Button.BackgroundTransparency = 0.7
        end
        
        table.insert(UI.Tabs, tab)
        return tab
    end
    
    -- Initialize
    wait(1) -- Simulate loading
    UI.LoadingScreen:Destroy()
    UI.MainContainer.Visible = true
    
    return UI
end

return Library
