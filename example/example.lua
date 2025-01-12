
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 Example Script Hub | Game 🔫",
   LoadingTitle = "🔫 Gun Simulator 💥",
   LoadingSubtitle = "by 1_F0",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Example Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
})

local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

local args1 = {
    [1] = "Christmas2024",
    [2] = "gems"
}

local args2 = {
    [1] = "EventClover",
    [2] = "gems"
}

local args3 = {
    [1] = "Legacy",
    [2] = "gems"
}

local buyingChristmas = false -- Control variable for Christmas buying loop
local buyingClover = false -- Control variable for Clover buying loop
local buyingLegacy = false -- Control variable for Legacy buying loop

-- Function to start buying Christmas
local function startBuyingChristmas()
    buyingChristmas = true
    while buyingChristmas do
        game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_from_banner:InvokeServer(unpack(args1))
        wait(1) -- Wait for 1 second before the next purchase
    end
end

-- Function to stop buying Christmas
local function stopBuyingChristmas()
    buyingChristmas = false
end

-- Function to start buying Clover
local function startBuyingClover()
    buyingClover = true
    while buyingClover do
        game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_from_banner:InvokeServer(unpack(args2))
        wait(1) -- Wait for 1 second before the next purchase
    end
end

-- Function to stop buying Clover
local function stopBuyingClover()
    buyingClover = false
end

-- Function to start buying Legacy
local function startBuyingLegacy()
    buyingLegacy = true
    while buyingLegacy do
        game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_from_banner:InvokeServer(unpack(args3))
        wait(1) -- Wait for 1 second before the next purchase
    end
end

-- Function to stop buying Legacy
local function stopBuyingLegacy()
    buyingLegacy = false
end

-- Create a button for Auto Buying Christmas
local ButtonChristmas = MainTab:CreateButton({
   Name = "Toggle Auto Buying Christmas",
   Callback = function()
       if not buyingChristmas then
           startBuyingChristmas() -- Start buying Christmas
           game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Auto Buying Christmas Activated!"; Duration=5;})
       else
           stopBuyingChristmas() -- Stop buying Christmas
           game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Auto Buying Christmas Deactivated!"; Duration=5;})
       end
   end,
})

-- Create a button for Auto Buying Clover
local ButtonClover = MainTab:CreateButton({
   Name = "Toggle Auto Buying Clover",
   Callback = function()
       if not buyingClover then
           startBuyingClover() -- Start buying Clover
           game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Auto Buying Clover Activated!"; Duration=5;})
       else
           stopBuyingClover() -- Stop buying Clover
           game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Auto Buying Clover Deactivated!"; Duration=5;})
       end
   end,
})

-- Create a button for Auto Buying Legacy
local ButtonLegacy = MainTab:CreateButton({
   Name = "Toggle Auto Buying Legacy",
   Callback = function()
       if not buyingLegacy then
           startBuyingLegacy() -- Start buying Legacy
           game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Auto Buying Legacy Activated!"; Duration=5;})
       else
           stopBuyingLegacy() -- Stop buying Legacy
           game.StarterGui:SetCore("SendNotification ", {Title="Youtube Hub"; Text="Auto Buying Legacy Deactivated!"; Duration=5;})
       end
   end,
})  
