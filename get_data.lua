-- File: get_data.lua
-- Lấy dữ liệu inventory, honey, và ong trong tổ từ Bee Swarm Simulator

repeat
    task.wait()
until game:IsLoaded()

local plr = game.Players.LocalPlayer

repeat
    task.wait()
until plr
repeat
    task.wait()
until plr.Character
repeat
    task.wait()
until plr.Character:FindFirstChild("HumanoidRootPart")

-- Module để lấy dữ liệu từ game
local GetDataModule = {}

-- Function để format số với dấu phẩy
function GetDataModule.formatNumber(v)
    return tostring(v):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

-- Function để lấy hive của player
function GetDataModule.GetPlrHive()
    for _, v in pairs(game.Workspace.Honeycombs:GetChildren()) do
        if tostring(v.Owner.Value) == plr.Name then
            return v
        end
    end
    return nil
end

-- Function để lấy dữ liệu inventory (items trong túi)
function GetDataModule.GetInventoryData()
    local success, result = pcall(function()
        local StatCache = require(game.ReplicatedStorage.ClientStatCache):Get()
        return StatCache
    end)
    
    if success and result then
        local inventoryData = {
            -- Dữ liệu cơ bản
            Pollen = plr.CoreStats.Pollen.Value,
            Capacity = plr.CoreStats.Capacity.Value,
            Honey = plr.CoreStats.Honey.Value,
            
            -- Items trong inventory
            Items = {},
            
            -- Eggs
            Eggs = result.Eggs or {},
            
            -- Equipment
            EquippedItems = {
                Bag = result.EquippedBag or "None",
                Hat = result.EquippedHat or "None", 
                Tool = result.EquippedTool or "None",
                Belt = result.EquippedBelt or "None",
                Guard = result.EquippedGuard or "None",
                Boots = result.EquippedBoots or "None",
                Collector = result.EquippedCollector or "None",
                Parachute = result.EquippedParachute or "None"
            }
        }
        
        -- Lấy items từ StatCache nếu có
        if result.Items then
            inventoryData.Items = result.Items
        end
        
        return inventoryData
    else
        print("Không thể lấy dữ liệu inventory:", result)
        return nil
    end
end

-- Function để lấy dữ liệu honey tổng
function GetDataModule.GetHoneyData()
    local success, result = pcall(function()
        local StatCache = require(game.ReplicatedStorage.ClientStatCache):Get()
        return {
            CurrentHoney = plr.CoreStats.Honey.Value,
            TotalHoney = StatCache.Totals.Honey or 0,
            HoneyPerSecond = StatCache.HoneyAtLastSave or 0
        }
    end)
    
    if success then
        return result
    else
        print("Không thể lấy dữ liệu honey:", result)
        return {
            CurrentHoney = plr.CoreStats.Honey.Value,
            TotalHoney = 0,
            HoneyPerSecond = 0
        }
    end
end

-- Function để lấy dữ liệu ong trong tổ
function GetDataModule.GetBeesData()
    local success, result = pcall(function()
        local StatCache = require(game.ReplicatedStorage.ClientStatCache):Get()
        local beesData = {
            BeeCount = 0,
            BeeSlots = 0,
            Bees = {},
            HiveData = {}
        }
        
        -- Lấy thông tin về ong
        if StatCache.Bees then
            for slot, beeData in pairs(StatCache.Bees) do
                if beeData then
                    beesData.BeeCount = beesData.BeeCount + 1
                    beesData.Bees[slot] = {
                        Type = beeData.Type or "Unknown",
                        Level = beeData.Level or 1,
                        Attack = beeData.Attack or 0,
                        Energy = beeData.Energy or 0,
                        Speed = beeData.Speed or 0,
                        AbilityRate = beeData.AbilityRate or 0,
                        Abilities = beeData.Abilities or {},
                        Mods = beeData.Mods or {}
                    }
                end
            end
        end
        
        -- Lấy số slot có sẵn
        local hive = GetDataModule.GetPlrHive()
        if hive then
            local slots = hive:FindFirstChild("Cells")
            if slots then
                beesData.BeeSlots = #slots:GetChildren()
                beesData.HiveData = {
                    HiveID = hive.HiveID.Value,
                    Position = hive.SpawnPos.Value,
                    MaxSlots = beesData.BeeSlots
                }
            end
        end
        
        return beesData
    end)
    
    if success then
        return result
    else
        print("Không thể lấy dữ liệu ong:", result)
        return {
            BeeCount = 0,
            BeeSlots = 0,
            Bees = {},
            HiveData = {}
        }
    end
end

-- Function để lấy tất cả dữ liệu
function GetDataModule.GetAllData()
    local allData = {
        PlayerName = plr.Name,
        Timestamp = os.time(),
        Inventory = GetDataModule.GetInventoryData(),
        Honey = GetDataModule.GetHoneyData(), 
        Bees = GetDataModule.GetBeesData()
    }
    
    return allData
end

-- Function để in dữ liệu ra console một cách đẹp
function GetDataModule.PrintData()
    local data = GetDataModule.GetAllData()
    
    print("=============== PLAYER DATA ===============")
    print("Player:", data.PlayerName)
    print("Time:", os.date("%Y-%m-%d %H:%M:%S", data.Timestamp))
    print("")
    
    if data.Honey then
        print("========== HONEY DATA ==========")
        print("Current Honey:", GetDataModule.formatNumber(data.Honey.CurrentHoney))
        print("Total Honey Made:", GetDataModule.formatNumber(data.Honey.TotalHoney))
        print("")
    end
    
    if data.Inventory then
        print("========== INVENTORY DATA ==========")
        print("Pollen:", GetDataModule.formatNumber(data.Inventory.Pollen) .. "/" .. GetDataModule.formatNumber(data.Inventory.Capacity))
        print("Current Honey:", GetDataModule.formatNumber(data.Inventory.Honey))
        print("")
        
        print("=== EQUIPPED ITEMS ===")
        for item, equipped in pairs(data.Inventory.EquippedItems) do
            print(item .. ":", equipped)
        end
        print("")
        
        print("=== EGGS ===")
        for eggType, count in pairs(data.Inventory.Eggs) do
            if count > 0 then
                print(eggType .. ":", count)
            end
        end
        print("")
    end
    
    if data.Bees then
        print("========== BEES DATA ==========")
        print("Bee Count:", data.Bees.BeeCount .. "/" .. data.Bees.BeeSlots)
        
        if data.Bees.HiveData and data.Bees.HiveData.HiveID then
            print("Hive ID:", data.Bees.HiveData.HiveID)
        end
        print("")
        
        print("=== BEES LIST ===")
        for slot, bee in pairs(data.Bees.Bees) do
            print("Slot " .. slot .. ":", bee.Type .. " (Level " .. bee.Level .. ")")
        end
        print("")
    end
    
    print("==========================================")
    
    return data
end

-- Function để save dữ liệu ra file JSON (nếu có hỗ trợ)
function GetDataModule.SaveDataToFile()
    local data = GetDataModule.GetAllData()
    local success, result = pcall(function()
        if writefile and game:GetService("HttpService") then
            local jsonData = game:GetService("HttpService"):JSONEncode(data)
            local fileName = "PlayerData_" .. plr.Name .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".json"
            
            if not isfolder("BSS_PlayerData") then
                makefolder("BSS_PlayerData")
            end
            
            writefile("BSS_PlayerData/" .. fileName, jsonData)
            print("Đã lưu dữ liệu vào file:", fileName)
            return true
        else
            print("Không hỗ trợ ghi file trong executor này")
            return false
        end
    end)
    
    if not success then
        print("Lỗi khi lưu file:", result)
    end
    
    return data
end

-- Auto update data mỗi 30 giây
function GetDataModule.StartAutoUpdate(interval)
    interval = interval or 30
    spawn(function()
        while true do
            task.wait(interval)
            print("\n=== AUTO UPDATE DATA ===")
            GetDataModule.PrintData()
        end
    end)
end

-- Chạy trực tiếp khi load file
print("🚀 Đang khởi động Get Data...")
task.wait(2)

-- In dữ liệu lần đầu
print("📊 Lấy dữ liệu lần đầu...")
GetDataModule.PrintData()

-- Tạo các function global để dễ sử dụng
getgenv().GetAllData = GetDataModule.GetAllData
getgenv().GetInventoryData = GetDataModule.GetInventoryData
getgenv().GetHoneyData = GetDataModule.GetHoneyData
getgenv().GetBeesData = GetDataModule.GetBeesData
getgenv().PrintData = GetDataModule.PrintData
getgenv().SaveDataToFile = GetDataModule.SaveDataToFile
getgenv().StartAutoUpdate = GetDataModule.StartAutoUpdate
getgenv().formatNumber = GetDataModule.formatNumber

print("✅ Get Data đã sẵn sàng!")
print("📝 Sử dụng các function:")
print("   PrintData() - In dữ liệu")
print("   SaveDataToFile() - Lưu file")
print("   StartAutoUpdate(30) - Auto update")
print("   GetAllData() - Lấy tất cả data")

--[[
Các function có sẵn sau khi chạy script:

- PrintData() - In tất cả dữ liệu ra console
- SaveDataToFile() - Lưu dữ liệu ra file JSON
- StartAutoUpdate(interval) - Tự động update data (mặc định 30s)
- GetAllData() - Lấy tất cả dữ liệu
- GetInventoryData() - Lấy dữ liệu inventory
- GetHoneyData() - Lấy dữ liệu honey
- GetBeesData() - Lấy dữ liệu ong
- formatNumber(number) - Format số với dấu phẩy

Ví dụ:
PrintData()
SaveDataToFile()
StartAutoUpdate(60)
]]

PrintData()           -- In tất cả dữ liệu
SaveDataToFile()      -- Lưu ra file JSON  
StartAutoUpdate(30)   -- Auto update mỗi 30 giây
GetAllData()          -- Lấy tất cả dữ liệu raw