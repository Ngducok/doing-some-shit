getgenv().GG = {
    Language = {
        CheckboxEnabled = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue = "Value",
        DropdownSelect = "Select",
        DropdownNone = "None",
        DropdownSelected = "Selected",
        ButtonClick = "Click",
        TextboxEnter = "Enter",
        ModuleEnabled = "Enabled",
        ModuleDisabled = "Disabled",
        TabGeneral = "General",
        TabSettings = "Settings",
        Loading = "Loading...",
        Error = "Error",
        Success = "Success"
    }
}

local UserInputService = cloneref(game:GetService('UserInputService'))
local TweenService = cloneref(game:GetService('TweenService'))
local TextService = cloneref(game:GetService('TextService'))
local HttpService = cloneref(game:GetService('HttpService'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local mouse = Players.LocalPlayer:GetMouse()
local Connections = {}
local function bind(key, fn)
    Connections[key] = fn
    return key
end
local function disconnect(key)
    if Connections[key] then Connections[key]:Disconnect() Connections[key]=nil end
end
local function disconnectAll()
    for k,c in pairs(Connections) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end Connections[k]=nil end
end
local Config = {}
function Config:load(id)
    local default = { _flags = {}, _keybinds = {}, _library = {} }
    local fn = 'March/'..id..'.json'
    if not isfolder('March') then makefolder('March') end
    if not isfile(fn) then writefile(fn, HttpService:JSONEncode(default)) return default end
    local ok,data = pcall(readfile, fn)
    if not ok or not data or #data == 0 then return default end
    local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, data)
    if not ok2 or type(decoded) ~= 'table' then return default end
    for k,v in pairs(default) do if decoded[k]==nil then decoded[k]=v end end
    return decoded
end
function Config:save(id, cfg)
    local fn = 'March/'..id..'.json'
    local ok,enc = pcall(HttpService.JSONEncode, HttpService, cfg)
    if ok then writefile(fn, enc) end
end
local Library = {}
Library.__index = Library
function Library.new(options)
    options = options or {}
    local self = setmetatable({}, Library)
    self._config = Config:load(game.GameId)
    self._choosing_keybind = false
    self._ui_open = true
    self._tab_index = 0
    self._tabs = {}
    self._current_tab = nil
    self._accent = options.accent or Color3.fromRGB(255,100,100)
    self._theme_bg = options.background or Color3.fromRGB(16,18,24)
    self._theme_section = options.section or Color3.fromRGB(28,32,42)
    self._theme_section_hover = options.section_hover or Color3.fromRGB(36,41,54)
    self._font_semibold = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    self._font_regular = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    self:_build_root()
    self:_size_root(true)
    self:_connect_inputs()
    return self
end
function Library:_build_root()
    local old = CoreGui:FindFirstChild('March')
    if old then old:Destroy() end
    local gui = Instance.new('ScreenGui')
    gui.Name = 'March'
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    self._gui = gui
    local container = Instance.new('Frame')
    container.Name = 'Container'
    container.AnchorPoint = Vector2.new(.5,.5)
    container.Position = UDim2.fromScale(.5,.5)
    container.Size = UDim2.fromOffset(0,0)
    container.BackgroundColor3 = self._theme_bg
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.Parent = gui
    local uc = Instance.new('UICorner', container)
    uc.CornerRadius = UDim.new(0,12)
    local stroke = Instance.new('UIStroke', container)
    stroke.Color = self._accent
    stroke.Transparency = .85
    stroke.Thickness = 1
    local layoutHolder = Instance.new('Frame')
    layoutHolder.Name = 'Holder'
    layoutHolder.BackgroundTransparency = 1
    layoutHolder.Size = UDim2.fromScale(1,1)
    layoutHolder.Parent = container
    local left = Instance.new('Frame')
    left.Name = 'Nav'
    left.Size = UDim2.new(0,.22,1,0)
    left.BackgroundTransparency = 1
    left.Parent = layoutHolder
    local tabsScroll = Instance.new('ScrollingFrame')
    tabsScroll.Name = 'Tabs'
    tabsScroll.Size = UDim2.new(1,0,1,-80)
    tabsScroll.Position = UDim2.new(0,0,0,80)
    tabsScroll.ScrollBarThickness = 0
    tabsScroll.BackgroundTransparency = 1
    tabsScroll.Parent = left
    local tabsList = Instance.new('UIListLayout', tabsScroll)
    tabsList.Padding = UDim.new(0,8)
    tabsList.SortOrder = Enum.SortOrder.LayoutOrder
    local header = Instance.new('TextLabel')
    header.Name = 'Title'
    header.BackgroundTransparency = 1
    header.FontFace = self._font_semibold
    header.Text = 'March'
    header.TextColor3 = self._accent
    header.TextSize = 22
    header.Position = UDim2.new(0,16,0,24)
    header.Size = UDim2.new(1,-32,0,28)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = left
    local right = Instance.new('Frame')
    right.Name = 'Pages'
    right.Size = UDim2.new(1,-left.Size.X.Offset,1,0)
    right.Position = UDim2.new(0, left.Size.X.Offset,0,0)
    right.AnchorPoint = Vector2.new(0,0)
    right.BackgroundTransparency = 1
    right.Parent = layoutHolder
    local tabsFolder = Instance.new('Folder')
    tabsFolder.Name = 'TabPages'
    tabsFolder.Parent = right
    self._container = container
    self._nav = tabsScroll
    self._pages = tabsFolder
end
function Library:_size_root(open)
    TweenService:Create(self._container, TweenInfo.new(.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = open and UDim2.fromOffset(math.clamp(workspace.CurrentCamera.ViewportSize.X*0.6,900,1400), math.clamp(workspace.CurrentCamera.ViewportSize.Y*0.65,620,900)) or UDim2.fromOffset(160,70)
    }):Play()
end
function Library:_connect_inputs()
    bind('toggle_ui', UserInputService.InputBegan:Connect(function(i,g)
        if g then return end
        if i.KeyCode == Enum.KeyCode.Insert then
            self._ui_open = not self._ui_open
            self:_size_root(self._ui_open)
        end
    end))
    local dragStartPos, dragStartUDim
    bind('drag_begin', self._container.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragStartPos = i.Position
            dragStartUDim = self._container.Position
            local c
            c = i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then
                    disconnect('drag_render')
                    c:Disconnect()
                end
            end)
            bind('drag_render', UserInputService.InputChanged:Connect(function(ch)
                if ch.UserInputType==Enum.UserInputType.MouseMovement then
                    local delta = ch.Position - dragStartPos
                    self._container.Position = UDim2.new(dragStartUDim.X.Scale, dragStartUDim.X.Offset+delta.X, dragStartUDim.Y.Scale, dragStartUDim.Y.Offset+delta.Y)
                end
            end))
        end
    end))
end
function Library:destroy()
    disconnectAll()
    if self._gui then self._gui:Destroy() end
end
function Library:create_tab(title, icon)
    self._tab_index += 1
    local tabButton = Instance.new('TextButton')
    tabButton.Name = 'Tab'
    tabButton.AutoButtonColor = false
    tabButton.Text = ''
    tabButton.Size = UDim2.new(1,-8,0,58)
    tabButton.BackgroundColor3 = self._theme_section
    tabButton.BackgroundTransparency = 0.1
    tabButton.BorderSizePixel = 0
    tabButton.LayoutOrder = self._tab_index
    tabButton.Parent = self._nav
    local corner = Instance.new('UICorner', tabButton)
    corner.CornerRadius = UDim.new(0,8)
    local ic = Instance.new('ImageLabel')
    ic.Name = 'Icon'
    ic.BackgroundTransparency = 1
    ic.Image = icon or ''
    ic.ImageTransparency = icon and .15 or 1
    ic.Size = UDim2.fromOffset(20,20)
    ic.Position = UDim2.new(0,16,0,19)
    ic.Parent = tabButton
    local text = Instance.new('TextLabel')
    text.BackgroundTransparency = 1
    text.FontFace = self._font_semibold
    text.Text = title
    text.TextColor3 = Color3.fromRGB(230,230,236)
    text.TextSize = 15
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Position = UDim2.new(0, icon and 48 or 20, 0, 0)
    text.Size = UDim2.new(1,-(icon and 56 or 28),1,0)
    text.Parent = tabButton
    local page = Instance.new('ScrollingFrame')
    page.Name = 'Page'
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageTransparency = .8
    page.Size = UDim2.fromScale(1,1)
    page.Parent = self._pages
    local padding = Instance.new('UIPadding', page)
    padding.PaddingTop = UDim.new(0,20)
    padding.PaddingLeft = UDim.new(0,20)
    padding.PaddingRight = UDim.new(0,20)
    padding.PaddingBottom = UDim.new(0,20)
    local list = Instance.new('UIListLayout', page)
    list.Padding = UDim.new(0,14)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.FillDirection = Enum.FillDirection.Horizontal
    list.Wraps = true
    list.ItemSize = UDim2.new(0, math.floor((workspace.CurrentCamera.ViewportSize.X*0.6 - 140)/2), 0, 0)
    local TabManager = {}
    TabManager._page = page
    TabManager._modules = {}
    function TabManager:show()
        if self == self._library._current_tab then return end
        for _,t in pairs(self._library._tabs) do t._page.Visible = false t:_deselect() end
        self._page.Visible = true
        self:_select()
        self._library._current_tab = self
    end
    function TabManager:_select()
        TweenService:Create(tabButton, TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = self._library._accent, BackgroundTransparency = .2}):Play()
        TweenService:Create(text, TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.new(1,1,1)}):Play()
        if ic.Image~='' then TweenService:Create(ic, TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.new(1,1,1) }):Play() end
    end
    function TabManager:_deselect()
        TweenService:Create(tabButton, TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = self._library._theme_section, BackgroundTransparency = .1}):Play()
        TweenService:Create(text, TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(200,200,205)}):Play()
        if ic.Image~='' then TweenService:Create(ic, TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(200,200,205)}):Play() end
    end
    function TabManager:create_module(o)
        o = o or {}
        local ModuleManager = {_state = o.open or false, _size = 0, _library = self._library}
        local frame = Instance.new('Frame')
        frame.Name = 'Module'
        frame.Size = UDim2.new(0, list.ItemSize.X.Offset-10, 0, 140)
        frame.BackgroundColor3 = self._library._theme_section
        frame.BackgroundTransparency = .05
        frame.Parent = self._page
        local cornerM = Instance.new('UICorner', frame)
        cornerM.CornerRadius = UDim.new(0,10)
        local layout = Instance.new('UIListLayout', frame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0,8)
        local header = Instance.new('Frame')
        header.Name = 'Header'
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, -24, 0, 56)
        header.Position = UDim2.new(0,12,0,0)
        header.Parent = frame
        local hList = Instance.new('UIListLayout', header)
        hList.FillDirection = Enum.FillDirection.Vertical
        hList.SortOrder = Enum.SortOrder.LayoutOrder
        hList.Padding = UDim.new(0,6)
        local title = Instance.new('TextLabel')
        title.BackgroundTransparency = 1
        title.FontFace = self._library._font_semibold
        title.Text = o.title or 'Module'
        title.TextColor3 = self._library._accent
        title.TextSize = 16
        title.Position = UDim2.new(0,0,0,8)
        title.Size = UDim2.new(1,0,0,18)
        title.Parent = header
        local desc = Instance.new('TextLabel')
        desc.BackgroundTransparency = 1
        desc.FontFace = self._library._font_regular
        desc.Text = o.description or ''
        desc.TextColor3 = Color3.fromRGB(190,190,194)
        desc.TextSize = 13
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.AutomaticSize = Enum.AutomaticSize.Y
        desc.TextWrapped = true
        desc.Size = UDim2.new(1,0,0,0)
        desc.Position = UDim2.new(0,0,0,26)
        desc.Parent = header
        local toggleArea = Instance.new('TextButton')
        toggleArea.Text = ''
        toggleArea.AutoButtonColor = false
        toggleArea.BackgroundTransparency = 1
        toggleArea.Size = UDim2.new(1,0,1,0)
        toggleArea.Parent = header
        local toggleFrame = Instance.new('Frame')
        toggleFrame.Size = UDim2.fromOffset(40,20)
        toggleFrame.AnchorPoint = Vector2.new(1,1)
        toggleFrame.Position = UDim2.new(1,0,1,0)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40,46,58)
        toggleFrame.Parent = header
        local tCorner = Instance.new('UICorner', toggleFrame)
        tCorner.CornerRadius = UDim.new(1,0)
        local knob = Instance.new('Frame')
        knob.Size = UDim2.fromOffset(20,20)
        knob.BackgroundColor3 = Color3.fromRGB(80,90,108)
        knob.Parent = toggleFrame
        local kCorner = Instance.new('UICorner', knob)
        kCorner.CornerRadius = UDim.new(1,0)
        local optsHolder = Instance.new('Frame')
        optsHolder.Name = 'Options'
        optsHolder.BackgroundTransparency = 1
        optsHolder.Size = UDim2.new(1,-24,0,0)
        optsHolder.Position = UDim2.new(0,12,0,0)
        optsHolder.Parent = frame
        local optsLayout = Instance.new('UIListLayout', optsHolder)
        optsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optsLayout.Padding = UDim.new(0,8)
        function ModuleManager:_animate()
            local targetSize = self._state and (140 + self._size) or 140
            TweenService:Create(frame, TweenInfo.new(.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, frame.Size.X.Offset, 0, targetSize)}):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = self._state and self._library._accent or Color3.fromRGB(40,46,58)}):Play()
            TweenService:Create(knob, TweenInfo.new(.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = self._state and UDim2.new(1,-20,0,0) or UDim2.new(0,0,0,0), BackgroundColor3 = self._state and self._library._accent or Color3.fromRGB(80,90,108)}):Play()
        end
        function ModuleManager:toggle(state)
            self._state = state == nil and not self._state or state
            self:_animate()
            if o.flag then self._library._config._flags[o.flag] = self._state Config:save(game.GameId,self._library._config) end
            if o.callback then task.spawn(o.callback,self._state) end
        end
        toggleArea.MouseButton1Click:Connect(function() ModuleManager:toggle() end)
        if o.flag and self._library._config._flags[o.flag] ~= nil then ModuleManager._state = self._library._config._flags[o.flag] end
        ModuleManager:_animate()
        function ModuleManager:_add_height(h) self._size += h if self._state then frame.Size = UDim2.new(0,frame.Size.X.Offset,0,140+self._size) end end
        function ModuleManager:create_paragraph(p)
            p = p or {}
            local holder = Instance.new('Frame')
            holder.Size = UDim2.new(1,0,0,0)
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.BackgroundTransparency = 1
            holder.Parent = optsHolder
            local t = Instance.new('TextLabel')
            t.BackgroundTransparency = 1
            t.FontFace = self._library._font_semibold
            t.Text = p.title or 'Title'
            t.TextColor3 = Color3.fromRGB(230,230,236)
            t.TextSize = 14
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Size = UDim2.new(1,0,0,16)
            t.Parent = holder
            local b = Instance.new('TextLabel')
            b.BackgroundTransparency = 1
            b.FontFace = self._library._font_regular
            b.TextWrapped = true
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.TextYAlignment = Enum.TextYAlignment.Top
            b.AutomaticSize = Enum.AutomaticSize.Y
            b.Size = UDim2.new(1,0,0,0)
            if p.rich then b.RichText = true b.Text = p.richtext or '' else b.Text = p.text or '' end
            b.TextColor3 = Color3.fromRGB(190,190,194)
            b.TextSize = 13
            b.Parent = holder
            task.defer(function()
                RunService.Heartbeat:Wait()
                ModuleManager:_add_height(holder.AbsoluteSize.Y + 2)
            end)
            return holder
        end
        function ModuleManager:create_checkbox(c)
            c = c or {}
            local btn = Instance.new('TextButton')
            btn.AutoButtonColor = false
            btn.Text = ''
            btn.Size = UDim2.new(1,0,0,28)
            btn.BackgroundColor3 = self._library._theme_section
            btn.BackgroundTransparency = .3
            btn.Parent = optsHolder
            local cc = Instance.new('UICorner', btn)
            cc.CornerRadius = UDim.new(0,6)
            local name = Instance.new('TextLabel')
            name.BackgroundTransparency = 1
            name.FontFace = self._library._font_semibold
            name.Text = c.title or 'Checkbox'
            name.TextSize = 13
            name.TextColor3 = Color3.fromRGB(220,220,225)
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Position = UDim2.new(0,12,0,0)
            name.Size = UDim2.new(1,-60,1,0)
            name.Parent = btn
            local box = Instance.new('Frame')
            box.Size = UDim2.fromOffset(22,22)
            box.AnchorPoint = Vector2.new(1,.5)
            box.Position = UDim2.new(1,-12,.5,0)
            box.BackgroundColor3 = Color3.fromRGB(50,56,68)
            box.Parent = btn
            local bcorner = Instance.new('UICorner', box)
            bcorner.CornerRadius = UDim.new(0,6)
            local fill = Instance.new('Frame')
            fill.Size = UDim2.fromOffset(0,0)
            fill.AnchorPoint = Vector2.new(.5,.5)
            fill.Position = UDim2.new(.5,0,.5,0)
            fill.BackgroundColor3 = self._library._accent
            fill.Parent = box
            local fcorner = Instance.new('UICorner', fill)
            fcorner.CornerRadius = UDim.new(0,5)
            local state = false
            if c.flag then
                if self._library._config._flags[c.flag] ~= nil then state = self._library._config._flags[c.flag] end
            end
            local function render()
                TweenService:Create(fill, TweenInfo.new(.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = state and UDim2.fromOffset(14,14) or UDim2.fromOffset(0,0)}):Play()
            end
            function btn:set(v)
                state = v
                if c.flag then self._library._config._flags[c.flag]=state Config:save(game.GameId,self._library._config) end
                render()
                if c.callback then task.spawn(c.callback,state) end
            end
            btn.MouseButton1Click:Connect(function() btn:set(not state) end)
            btn:set(state)
            ModuleManager:_add_height(btn.AbsoluteSize.Y + 8)
            return btn
        end
        function ModuleManager:create_slider(s)
            s = s or {}
            local minimum = s.min or 0
            local maximum = s.max or 100
            local value = s.value or minimum
            if s.flag and self._library._config._flags[s.flag] then value = self._library._config._flags[s.flag] end
            local holder = Instance.new('Frame')
            holder.Size = UDim2.new(1,0,0,46)
            holder.BackgroundTransparency = 1
            holder.Parent = optsHolder
            local name = Instance.new('TextLabel')
            name.BackgroundTransparency = 1
            name.FontFace = self._library._font_semibold
            name.Text = s.title or 'Slider'
            name.TextColor3 = Color3.fromRGB(220,220,225)
            name.TextSize = 13
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Position = UDim2.new(0,0,0,0)
            name.Size = UDim2.new(1,0,0,16)
            name.Parent = holder
            local valueLabel = Instance.new('TextLabel')
            valueLabel.BackgroundTransparency = 1
            valueLabel.FontFace = self._library._font_semibold
            valueLabel.Text = tostring(value)
            valueLabel.TextColor3 = self._accent
            valueLabel.TextSize = 13
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Size = UDim2.new(1,0,0,16)
            valueLabel.Position = UDim2.new(0,0,0,0)
            valueLabel.Parent = holder
            local bar = Instance.new('Frame')
            bar.Size = UDim2.new(1,0,0,8)
            bar.Position = UDim2.new(0,0,0,28)
            bar.BackgroundColor3 = Color3.fromRGB(48,54,66)
            bar.Parent = holder
            local bcorner = Instance.new('UICorner', bar)
            bcorner.CornerRadius = UDim.new(1,0)
            local fill = Instance.new('Frame')
            fill.Size = UDim2.fromScale((value-minimum)/(maximum-minimum),1)
            fill.BackgroundColor3 = self._accent
            fill.Parent = bar
            local fcorner = Instance.new('UICorner', fill)
            fcorner.CornerRadius = UDim.new(1,0)
            local dragging = false
            local function set_val(x)
                x = math.clamp(x, minimum, maximum)
                value = s.decimal and x or math.floor(x + 0.5)
                fill.Size = UDim2.fromScale((value-minimum)/(maximum-minimum),1)
                valueLabel.Text = tostring(value)
                if s.flag then self._library._config._flags[s.flag] = value Config:save(game.GameId,self._library._config) end
                if s.callback then s.callback(value) end
            end
            bar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true set_val(minimum + (maximum-minimum)*((mouse.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X)) end
            end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement) then
                    set_val(minimum + (maximum-minimum)*((mouse.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X))
                end
            end)
            set_val(value)
            ModuleManager:_add_height(holder.AbsoluteSize.Y + 4)
            return holder
        end
        ModuleManager._library = self._library
        table.insert(self._modules, ModuleManager)
        task.defer(function() ModuleManager:_add_height(0) end)
        return ModuleManager
    end
    tabButton.MouseButton1Click:Connect(function() TabManager:show() end)
    TabManager._library = self
    table.insert(self._tabs, TabManager)
    if not self._current_tab then TabManager:show() end
    return TabManager
end
function Library:load()
    local assets = {}
    for _,o in self._gui:GetDescendants() do if o:IsA('ImageLabel') then table.insert(assets,o) end end
    pcall(function() ContentProvider:PreloadAsync(assets) end)
    self:_size_root(true)
end
function Library:flag_type(flag, t)
    if not self._config._flags[flag] then return false end
    return typeof(self._config._flags[flag])==t
end
function Library:close()
    self._ui_open=false
    self:_size_root(false)
end
function Library:open()
    self._ui_open=true
    self:_size_root(true)
end
return Library
