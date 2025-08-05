repeat task.wait() until game:IsLoaded()

local v1 = game.Players.LocalPlayer

repeat
    task.wait()
until v1
repeat
    task.wait()
until v1.Character
repeat
    task.wait()
until v1.Character:FindFirstChild("HumanoidRootPart")

local v2 = {}
function v_u_1(v)
    return tostring(v):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function v_u_2()
    local v3, v4 = pcall(function()
        return require(game.ReplicatedStorage.ClientStatCache):Get()
    end)
    
    if not v3 then
        return nil
    end
    
    local v5 = {
        v6 = v1.CoreStats.Pollen.Value,
        v7 = v1.CoreStats.Capacity.Value,
        v8 = v1.CoreStats.Honey.Value,
        v9 = {},
        v10 = v4.Eggs or {},
        v11 = {
            v12 = v4.EquippedCollector or "None",
            v13 = v4.EquippedParachute or "None",
            v14 = v4.EquippedBag or "None",
            v15 = v4.EquippedHat or "None"
        }
    }
    if v4.Items then
        v5.v9 = v4.Items
    end
    return v5
end

function v_u_3()
    local v16, v17 = pcall(function()
        local v18 = require(game.ReplicatedStorage.ClientStatCache):Get()
        return {
            v19 = v1.CoreStats.Honey.Value,
            v20 = v18.Totals.Honey or 0,
            v21 = v18.HoneyAtLastSave or 0
        }
    end)
    
    if v16 then
        return v17
    else
        return {
            v19 = v1.CoreStats.Honey.Value,
            v20 = 0,
            v21 = 0
        }
    end
end

function v_u_4()
    local v22, v23 = pcall(function()
        local v24 = require(game.ReplicatedStorage.ClientStatCache):Get()
        local v26 = {
            v27 = 0,
            v28 = 0,
            v29 = {}
        }
        
        if v24 and v24.Bees then
            for v30, v31 in pairs(v24.Bees) do
                if v31 and v31.Type then
                    v26.v27 = v26.v27 + 1
                    v26.v29[v30] = {
                        v32 = v31.Type or "Unknown",
                        v33 = v31.Level or 1
                    }
                end
            end
        end
        
        for _, v34 in pairs(game.Workspace.Honeycombs:GetChildren()) do
            if v34.Owner.Value and tostring(v34.Owner.Value) == v1.Name then
                local v35 = v34:FindFirstChild("Cells")
                if v35 then
                    v26.v28 = #v35:GetChildren()
                end
                break
            end
        end
        
        return v26
    end)
    
    if v22 then
        return v23
    else
        return {
            v27 = 0,
            v28 = 0,
            v29 = {}
        }
    end
end

function v_u_5()
    local v36 = v_u_2()
    local v37 = v_u_3()
    local v38 = v_u_4()
    
    print("=============== PLAYER DATA ===============")
    print("Player:", v1.Name)
    print("")
    
    if v37 then
        print("========== HONEY ==========")
        print("Current:", v_u_1(v37.v19))
        print("Total:", v_u_1(v37.v20))
        print("")
    end
    
    if v36 then
        print("========== INVENTORY ==========")
        print("Pollen:", v_u_1(v36.v6) .. "/" .. v_u_1(v36.v7))
        print("Honey:", v_u_1(v36.v8))
        print("")
        
        print("=== EQUIPPED ===")
        print("Collector:", v36.v11.v12)
        print("Parachute:", v36.v11.v13)
        print("Bag:", v36.v11.v14)
        print("Hat:", v36.v11.v15)
        print("")
        
        print("=== INV ===")
        for v39, v40 in pairs(v36.v10) do
            if v40 > 0 then
                print(v39 .. ":", v40)
            end
        end
        print("")
    end
  --[[  
  BUG
    if v38 then
        print("========== BEES ==========")
        print("Count:", v38.v27 .. "/" .. v38.v28)
        for v41, v42 in pairs(v38.v29) do
            print("Slot " .. v41 .. ":", v42.v32 .. " (Lv" .. v42.v33 .. ")")
        end
        print("")
    end
    
    print("==========================================")
end
]]
v_u_5()
