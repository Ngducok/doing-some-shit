local kq0=game:GetService("RunService")
local u2n=game:GetService("Players")
local qwe={}
local function zf4()
    if get_hidden_gui then return get_hidden_gui() end
    if gethui then return gethui() end
end
local function p9f(v)
    if typeof(v)=="number" then return tostring(v) end
    if typeof(v)=="boolean" then return v and "true" or "false" end
    return tostring(v)
end
local function h3m(a,b)
    local r={}
    for k,v in pairs(a or {}) do r[k]=v end
    for k,v in pairs(b or {}) do r[k]=v end
    return r
end
function qwe.new(cfg)
    cfg=cfg or {}
    local g2=Instance.new("ScreenGui")
    g2.Name=cfg.name or "Shouko.dev"
    g2.DisplayOrder=cfg.displayOrder or 999
    g2.ResetOnSpawn=false
    g2.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local p0=zf4()
    if p0 then g2.Parent=p0 else g2.Parent=game.CoreGui end
    local m1=Instance.new("Frame")
    m1.Name="MainFrame"
    m1.AnchorPoint=Vector2.new(0.5,0.5)
    m1.BackgroundTransparency=1
    m1.Position=UDim2.new(0.5,0,0.5,0)
    m1.Size=UDim2.new(0,0,0,0)
    m1.Parent=g2
    local l8=Instance.new("UIListLayout")
    l8.Parent=m1
    l8.HorizontalAlignment=Enum.HorizontalAlignment.Center
    l8.SortOrder=Enum.SortOrder.LayoutOrder
    l8.Padding=UDim.new(0,cfg.padding or 10)
    local s9={_gui=g2,_frame=m1,_layout=l8,_labels={},_order=0,_formatters={},_bindings={},_autoSize=cfg.autoSize~=false,_defaults=cfg.defaults or {}}
    local hd=cfg.header or {}
    local h0=nil
    if hd.enabled~=false then
        h0=Instance.new("TextLabel")
        local st=Instance.new("UIStroke")
        h0.Name="Header"
        h0.Parent=m1
        h0.LayoutOrder=0
        h0.BackgroundTransparency=1
        h0.Font=hd.font or Enum.Font.FredokaOne
        h0.Text=hd.text or ""
        h0.TextColor3=hd.color or Color3.fromRGB(244,63,94)
        h0.TextSize=hd.textSize or 50
        st.Parent=h0
        st.Color=hd.strokeColor or Color3.fromRGB(0,0,0)
        st.Thickness=hd.strokeThickness or 1
        h0.Size=UDim2.new(0,200,0,hd.height or 80)
        s9._header=h0
    end
    local function r1()
        if not s9._autoSize then return end
        local w=0
        for _,c in ipairs(m1:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then
                c.Size=UDim2.new(0,c.TextBounds.X+10,0,c.AbsoluteSize.Y)
                if c.TextBounds.X>w then w=c.TextBounds.X end
            end
        end
        for _,c in ipairs(m1:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then
                c.Size=UDim2.new(0,w+20,0,c.AbsoluteSize.Y)
            end
        end
        local total=0
        for _,c in ipairs(m1:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then
                total=total+c.AbsoluteSize.Y+l8.Padding.Offset
            end
        end
        m1.Size=UDim2.new(0,w+40,0,total)
    end
    s9._resize=r1
    if h0 then h0:GetPropertyChangedSignal("Text"):Connect(r1) end
    function s9:setHeader(h)
        h=h or {}
        if not s9._header then return end
        if h.text~=nil then s9._header.Text=h.text end
        if h.color~=nil then s9._header.TextColor3=h.color end
        if h.textSize~=nil then s9._header.TextSize=h.textSize end
        if h.font~=nil then s9._header.Font=h.font end
        if h.height~=nil then s9._header.Size=UDim2.new(0,s9._header.Size.X.Offset,0,h.height) end
        r1()
    end
    function s9:setDefaults(d)
        for k,v in pairs(d) do s9._defaults[k]=v end
    end
    function s9:add(nm,pr,val,opt)
        if s9._labels[nm] then
            local o=s9._labels[nm]
            if o.instance then o.instance:Destroy() end
            s9._labels[nm]=nil
            s9._formatters[nm]=nil
            s9._bindings[nm]=nil
        end
        opt=h3m(s9._defaults,opt)
        s9._order+=1
        local lb=Instance.new("TextLabel")
        local st2=Instance.new("UIStroke")
        lb.Name=nm
        lb.Parent=m1
        lb.LayoutOrder=s9._order
        lb.Size=UDim2.new(0,200,0,opt.height or 30)
        lb.BackgroundTransparency=1
        lb.Font=opt.font or Enum.Font.FredokaOne
        lb.Text=""
        lb.TextColor3=opt.textColor or Color3.fromRGB(255,255,255)
        lb.TextSize=opt.textSize or 20
        st2.Parent=lb
        st2.Color=opt.strokeColor or Color3.fromRGB(0,0,0)
        st2.Thickness=opt.strokeThickness or 1
        s9._formatters[nm]=opt.formatter or p9f
        s9._labels[nm]={instance=lb,prefix=pr or "",value=val}
        s9:update(nm,val)
        lb:GetPropertyChangedSignal("Text"):Connect(r1)
        r1()
        return lb
    end
    function s9:update(nm,vv)
        local d=s9._labels[nm]
        if not d then return end
        d.value=vv
        local f=s9._formatters[nm] or p9f
        d.instance.Text=d.prefix..f(vv)
    end
    function s9:get(nm)
        local d=s9._labels[nm]
        return d and d.value
    end
    function s9:remove(nm)
        local d=s9._labels[nm]
        if not d then return end
        d.instance:Destroy()
        s9._labels[nm]=nil
        s9._formatters[nm]=nil
        s9._bindings[nm]=nil
        s9._resize()
    end
    function s9:bind(nm,fn,itv)
        s9._bindings[nm]={fn=fn,t=0,interval=itv or 0}
    end
    function s9:unbind(nm)
        s9._bindings[nm]=nil
    end
    function s9:destroy()
        if s9._conn then s9._conn:Disconnect() end
        g2:Destroy()
    end
    s9._conn=kq0.Heartbeat:Connect(function(dt)
        for k,b in pairs(s9._bindings) do
            b.t+=dt
            if b.t>=b.interval then
                b.t=0
                local ok,v=pcall(b.fn)
                if ok then s9:update(k,v) end
            end
        end
    end)
    if cfg.items then
        for _,it in ipairs(cfg.items) do
            s9:add(it.name,it.prefix,it.value,it.opts)
        end
    end
    r1()
    return s9
end
function qwe.simple(items)
    local pl=u2n.LocalPlayer
    local ui=qwe.new{header={text="Shouko.dev"..(pl and (" [ "..pl.Name.." ]") or "")}}
    if type(items)=="table" then
        local arr=false
        for k in pairs(items) do if typeof(k)=="number" then arr=true break end end
        if not arr then
            for k,v in pairs(items) do ui:add(k,k..": ",v) end
        else
            for _,it in ipairs(items) do
                if typeof(it)=="table" then
                    if it.name then ui:add(it.name,it.prefix,it.value,it.opts) elseif #it>=1 then ui:add(it[1],it[2],it[3],it[4]) end
                elseif typeof(it)=="string" then ui:add(it,it..": ","") end
            end
        end
    end
    return ui
end
return qwe
