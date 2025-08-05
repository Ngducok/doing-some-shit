repeat task.wait() until game:IsLoaded()

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

local tabl = {}
function format(v)
    return tostring(v):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function getinv()
    local success, result = pcall(function()
        return require(game.ReplicatedStorage.ClientStatCache):Get()
    end)
    
    if not success then
        return nil
    end
    
    local data = {
        pl = plr.CoreStats.Pollen.Value,
        cap = plr.CoreStats.Capacity.Value,
        hn = plr.CoreStats.Honey.Value,
        itms = {},
        eggs = result.Eggs or {},
        equippeditm = {
            t = result.EquippedTool or "None",
            p = result.EquippedParachute or "None"
        }
    }
    if result.Items then
        data.itms = result.Items
    end
    return data
end

function gethn()
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
        return {
            CurrentHoney = plr.CoreStats.Honey.Value,
            TotalHoney = 0,
            HoneyPerSecond = 0
        }
    end
end

function getbees()
    local success, result = pcall(function()
        local StatCache = require(game.ReplicatedStorage.ClientStatCache):Get()
        local beesData = {
            count = 0,
            slots = 0,
            bees = {}
        }
        
        if StatCache.Bees then
            for slot, beeData in pairs(StatCache.Bees) do
                if beeData then
                    beesData.count = beesData.count + 1
                    beesData.bees[slot] = {
                        type = beeData.Type or "Unknown",
                        level = beeData.Level or 1
                    }
                end
            end
        end
        
        return beesData
    end)
    
    if success then
        return result
    else
        return {
            count = 0,
            slots = 0,
            bees = {}
        }
    end
end

function printdata()
    local inv = getinv()
    local honey = gethn()
    local bees = getbees()
    
    print("=============== PLAYER DATA ===============")
    print("Player:", plr.Name)
    print("")
    
    if honey then
        print("========== HONEY ==========")
        print("Current:", format(honey.CurrentHoney))
        print("Total:", format(honey.TotalHoney))
        print("")
    end
    
    if inv then
        print("========== INVENTORY ==========")
        print("Pollen:", format(inv.pl) .. "/" .. format(inv.cap))
        print("Honey:", format(inv.hn))
        print("")
        
        print("=== EQUIPPED ===")
        print("Tool:", inv.equippeditm.t)
        print("Parachute:", inv.equippeditm.p)
        print("")
        
        print("=== EGGS ===")
        for eggType, count in pairs(inv.eggs) do
            if count > 0 then
                print(eggType .. ":", count)
            end
        end
        print("")
    end
    
    if bees then
        print("========== BEES ==========")
        print("Count:", bees.count)
        for slot, bee in pairs(bees.bees) do
            print("Slot " .. slot .. ":", bee.type .. " (Lv" .. bee.level .. ")")
        end
        print("")
    end
    
    print("==========================================")
end

printdata()
