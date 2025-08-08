local v1=game:GetService("RunService")
local v2=game:GetService("Players")
local v3={}
local function v4()
    if get_hidden_gui then return get_hidden_gui() end
    if gethui then return gethui() end
end
local function v5(v6)
    if typeof(v6)=="number" then return tostring(v6) end
    if typeof(v6)=="boolean" then return v6 and "true" or "false" end
    return tostring(v6)
end
function v3.new(v7)
    v7=v7 or {}
    local v8=Instance.new("ScreenGui")
    v8.Name=v7.name or "Shouko.dev"
    v8.DisplayOrder=v7.displayOrder or 999
    v8.ResetOnSpawn=false
    v8.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local v9=v4()
    if v9 then v8.Parent=v9 else v8.Parent=game.CoreGui end
    local v10=Instance.new("Frame")
    v10.Name="MainFrame"
    v10.AnchorPoint=Vector2.new(0.5,0.5)
    v10.BackgroundTransparency=1
    v10.Position=UDim2.new(0.5,0,0.5,0)
    v10.Size=UDim2.new(0,0,0,0)
    v10.Parent=v8
    local v11=Instance.new("UIListLayout")
    v11.Parent=v10
    v11.HorizontalAlignment=Enum.HorizontalAlignment.Center
    v11.SortOrder=Enum.SortOrder.LayoutOrder
    v11.Padding=UDim.new(0,v7.padding or 10)
    local v12={_gui=v8,_frame=v10,_layout=v11,_labels={},_order=0,_formatters={},_bindings={},_autoSize=v7.autoSize~=false}
    local v40=Instance.new("TextLabel")
    local v41=Instance.new("UIStroke")
    v40.Name="Header"
    v40.Parent=v10
    v40.LayoutOrder=0
    v40.BackgroundTransparency=1
    v40.Font=v7.headerFont or Enum.Font.FredokaOne
    v40.Text=v7.headerText or ""
    v40.TextColor3=v7.headerColor or Color3.fromRGB(244,63,94)
    v40.TextSize=v7.headerTextSize or 50
    v41.Parent=v40
    v41.Color=v7.headerStrokeColor or Color3.fromRGB(0,0,0)
    v41.Thickness=v7.headerStrokeThickness or 1
    v40.Size=UDim2.new(0,200,0,v7.headerHeight or 80)
    v12._header=v40
    local function v13()
        if not v12._autoSize then return end
        local v14=0
        for _,v15 in ipairs(v10:GetChildren()) do
            if v15:IsA("TextLabel") or v15:IsA("TextButton") then
                v15.Size=UDim2.new(0,v15.TextBounds.X+10,0,v15.AbsoluteSize.Y)
                if v15.TextBounds.X>v14 then v14=v15.TextBounds.X end
            end
        end
        for _,v15 in ipairs(v10:GetChildren()) do
            if v15:IsA("TextLabel") or v15:IsA("TextButton") then
                v15.Size=UDim2.new(0,v14+20,0,v15.AbsoluteSize.Y)
            end
        end
        local v16=0
        for _,v15 in ipairs(v10:GetChildren()) do
            if v15:IsA("TextLabel") or v15:IsA("TextButton") then
                v16=v16+v15.AbsoluteSize.Y+v11.Padding.Offset
            end
        end
        v10.Size=UDim2.new(0,v14+40,0,v16)
    end
    v12._resize=v13
    v40:GetPropertyChangedSignal("Text"):Connect(v13)
    function v12:setHeader(v42,v43)
        if v12._header then
            if v42~=nil then v12._header.Text=v42 end
            if v43~=nil then v12._header.TextColor3=v43 end
        end
    end
    function v12:add(v17,v18,v19,v20)
        if v12._labels[v17] then
            local old=v12._labels[v17]
            if old.instance then old.instance:Destroy() end
            v12._labels[v17]=nil
            v12._formatters[v17]=nil
            v12._bindings[v17]=nil
        end
        v20=v20 or {}
        v12._order=v12._order+1
        local v21=Instance.new("TextLabel")
        local v22=Instance.new("UIStroke")
        v21.Name=v17
        v21.Parent=v10
        v21.LayoutOrder=v12._order
        v21.Size=UDim2.new(0,200,0,v20.height or 30)
        v21.BackgroundTransparency=1
        v21.Font=v20.font or Enum.Font.FredokaOne
        v21.Text=""
        v21.TextColor3=v20.textColor or Color3.fromRGB(255,255,255)
        v21.TextSize=v20.textSize or 20
        v22.Parent=v21
        v22.Color=v20.strokeColor or Color3.fromRGB(0,0,0)
        v22.Thickness=v20.strokeThickness or 1
        v12._formatters[v17]=v20.formatter or v5
        v12._labels[v17]={instance=v21,prefix=v18 or "",value=v19}
        v12:update(v17,v19)
        v21:GetPropertyChangedSignal("Text"):Connect(v13)
        v13()
        return v21
    end
    function v12:update(v23,v24)
        local v25=v12._labels[v23]
        if not v25 then return end
        v25.value=v24
        local v26=v12._formatters[v23] or v5
        v25.instance.Text=v25.prefix..v26(v24)
    end
    function v12:get(v27)
        local v28=v12._labels[v27]
        return v28 and v28.value
    end
    function v12:remove(v29)
        local v30=v12._labels[v29]
        if not v30 then return end
        v30.instance:Destroy()
        v12._labels[v29]=nil
        v12._formatters[v29]=nil
        v12._bindings[v29]=nil
        v12._resize()
    end
    function v12:bind(v31,v32,v33)
        v12._bindings[v31]={fn=v32,t=0,interval=v33 or 0}
    end
    function v12:unbind(v34)
        v12._bindings[v34]=nil
    end
    function v12:destroy()
        if v12._conn then v12._conn:Disconnect() end
        v8:Destroy()
    end
    v12._conn=v1.Heartbeat:Connect(function(v35)
        for v36,v37 in pairs(v12._bindings) do
            v37.t=v37.t+v35
            if v37.t>=v37.interval then
                v37.t=0
                local v38,v39=pcall(v37.fn)
                if v38 then v12:update(v36,v39) end
            end
        end
    end)
    v13()
    return v12
end
return v3
