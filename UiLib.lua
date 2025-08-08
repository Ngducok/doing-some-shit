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
local function v7(a,b)
    local r={}
    for k,v in pairs(a or {}) do r[k]=v end
    for k,v in pairs(b or {}) do r[k]=v end
    return r
end
function v3.new(v8)
    v8=v8 or {}
    local v9=Instance.new("ScreenGui")
    v9.Name=v8.name or "Shouko.dev"
    v9.DisplayOrder=v8.displayOrder or 999
    v9.ResetOnSpawn=false
    v9.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local v10=v4()
    if v10 then v9.Parent=v10 else v9.Parent=game.CoreGui end
    local v11=Instance.new("Frame")
    v11.Name="MainFrame"
    v11.AnchorPoint=Vector2.new(0.5,0.5)
    v11.BackgroundTransparency=1
    v11.Position=UDim2.new(0.5,0,0.5,0)
    v11.Size=UDim2.new(0,0,0,0)
    v11.Parent=v9
    local v12=Instance.new("UIListLayout")
    v12.Parent=v11
    v12.HorizontalAlignment=Enum.HorizontalAlignment.Center
    v12.SortOrder=Enum.SortOrder.LayoutOrder
    v12.Padding=UDim.new(0,v8.padding or 10)
    local v13={_gui=v9,_frame=v11,_layout=v12,_labels={},_order=0,_formatters={},_bindings={},_autoSize=v8.autoSize~=false,_defaults=v8.defaults or {}} 
    local hcfg=v8.header or {}
    local v14=nil
    if hcfg.enabled~=false then
        v14=Instance.new("TextLabel")
        local s=Instance.new("UIStroke")
        v14.Name="Header"
        v14.Parent=v11
        v14.LayoutOrder=0
        v14.BackgroundTransparency=1
        v14.Font=hcfg.font or Enum.Font.FredokaOne
        v14.Text=hcfg.text or ""
        v14.TextColor3=hcfg.color or Color3.fromRGB(244,63,94)
        v14.TextSize=hcfg.textSize or 50
        s.Parent=v14
        s.Color=hcfg.strokeColor or Color3.fromRGB(0,0,0)
        s.Thickness=hcfg.strokeThickness or 1
        v14.Size=UDim2.new(0,200,0,hcfg.height or 80)
        v13._header=v14
    end
    local function v15()
        if not v13._autoSize then return end
        local w=0
        for _,c in ipairs(v11:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then
                c.Size=UDim2.new(0,c.TextBounds.X+10,0,c.AbsoluteSize.Y)
                if c.TextBounds.X>w then w=c.TextBounds.X end
            end
        end
        for _,c in ipairs(v11:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then
                c.Size=UDim2.new(0,w+20,0,c.AbsoluteSize.Y)
            end
        end
        local total=0
        for _,c in ipairs(v11:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then
                total=total+c.AbsoluteSize.Y+v12.Padding.Offset
            end
        end
        v11.Size=UDim2.new(0,w+40,0,total)
    end
    v13._resize=v15
    if v14 then v14:GetPropertyChangedSignal("Text"):Connect(v15) end
    function v13:setHeader(cfg)
        cfg=cfg or {}
        if not v13._header then return end
        if cfg.text~=nil then v13._header.Text=cfg.text end
        if cfg.color~=nil then v13._header.TextColor3=cfg.color end
        if cfg.textSize~=nil then v13._header.TextSize=cfg.textSize end
        if cfg.font~=nil then v13._header.Font=cfg.font end
        if cfg.height~=nil then v13._header.Size=UDim2.new(0,v13._header.Size.X.Offset,0,cfg.height) end
        v15()
    end
    function v13:setDefaults(d)
        for k,v in pairs(d) do v13._defaults[k]=v end
    end
    function v13:add(v16,v17,v18,v19)
        if v13._labels[v16] then
            local o=v13._labels[v16]
            if o.instance then o.instance:Destroy() end
            v13._labels[v16]=nil
            v13._formatters[v16]=nil
            v13._bindings[v16]=nil
        end
        v19=v7(v13._defaults,v19)
        v13._order=v13._order+1
        local lbl=Instance.new("TextLabel")
        local st=Instance.new("UIStroke")
        lbl.Name=v16
        lbl.Parent=v11
        lbl.LayoutOrder=v13._order
        lbl.Size=UDim2.new(0,200,0,v19.height or 30)
        lbl.BackgroundTransparency=1
        lbl.Font=v19.font or Enum.Font.FredokaOne
        lbl.Text=""
        lbl.TextColor3=v19.textColor or Color3.fromRGB(255,255,255)
        lbl.TextSize=v19.textSize or 20
        st.Parent=lbl
        st.Color=v19.strokeColor or Color3.fromRGB(0,0,0)
        st.Thickness=v19.strokeThickness or 1
        v13._formatters[v16]=v19.formatter or v5
        v13._labels[v16]={instance=lbl,prefix=v17 or "",value=v18}
        v13:update(v16,v18)
        lbl:GetPropertyChangedSignal("Text"):Connect(v15)
        v15()
        return lbl
    end
    function v13:update(n,val)
        local d=v13._labels[n]
        if not d then return end
        d.value=val
        local f=v13._formatters[n] or v5
        d.instance.Text=d.prefix..f(val)
    end
    function v13:get(n)
        local d=v13._labels[n]
        return d and d.value
    end
    function v13:remove(n)
        local d=v13._labels[n]
        if not d then return end
        d.instance:Destroy()
        v13._labels[n]=nil
        v13._formatters[n]=nil
        v13._bindings[n]=nil
        v13._resize()
    end
    function v13:bind(n,fn,i)
        v13._bindings[n]={fn=fn,t=0,interval=i or 0}
    end
    function v13:unbind(n)
        v13._bindings[n]=nil
    end
    function v13:destroy()
        if v13._conn then v13._conn:Disconnect() end
        v9:Destroy()
    end
    v13._conn=v1.Heartbeat:Connect(function(dt)
        for k,b in pairs(v13._bindings) do
            b.t=b.t+dt
            if b.t>=b.interval then
                b.t=0
                local ok,val=pcall(b.fn)
                if ok then v13:update(k,val) end
            end
        end
    end)
    if v8.items then
        for _,it in ipairs(v8.items) do
            v13:add(it.name,it.prefix,it.value,it.opts)
        end
    end
    v15()
    return v13
end
return v3
