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

local SelectedLanguage = GG.Language

function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end
    return result
end
function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end
local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))
local mouse = Players.LocalPlayer:GetMouse()
local old_March = CoreGui:FindFirstChild('March')
if old_March then Debris:AddItem(old_March, 0) end
if not isfolder("March") then makefolder("March") end
local Connections = setmetatable({
    disconnect = function(self, connection)
        if not self[connection] then return end
        self[connection]:Disconnect()
        self[connection] = nil
    end,
    disconnect_all = function(self)
        for _, value in self do
            if typeof(value) == 'function' then continue end
            value:Disconnect()
        end
    end
}, Connections)
local Util = setmetatable({
    map = function(self, value, in_minimum, in_maximum, out_minimum, out_maximum)
        return (value - in_minimum) * (out_maximum - out_minimum) / (in_maximum - in_minimum) + out_minimum
    end,
    viewport_point_to_world = function(self, location, distance)
        local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
        return unit_ray.Origin + unit_ray.Direction * distance
    end,
    get_offset = function(self)
        local viewport_size_Y = workspace.CurrentCamera.ViewportSize.Y
        return self:map(viewport_size_Y, 0, 2560, 8, 56)
    end
}, Util)
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur
function AcrylicBlur.new(object)
    local self = setmetatable({_object = object,_folder = nil,_frame = nil,_root = nil}, AcrylicBlur)
    self:setup()
    return self
end
function AcrylicBlur:create_folder()
    local old_folder = workspace.CurrentCamera:FindFirstChild('AcrylicBlur')
    if old_folder then Debris:AddItem(old_folder, 0) end
    local folder = Instance.new('Folder')
    folder.Name = 'AcrylicBlur'
    folder.Parent = workspace.CurrentCamera
    self._folder = folder
end
function AcrylicBlur:create_depth_of_fields()
    local depth_of_fields = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    depth_of_fields.FarIntensity = 0
    depth_of_fields.FocusDistance = 0.05
    depth_of_fields.InFocusRadius = 0.1
    depth_of_fields.NearIntensity = 1
    depth_of_fields.Name = 'AcrylicBlur'
    depth_of_fields.Parent = Lighting
    for _, object in Lighting:GetChildren() do
        if not object:IsA('DepthOfFieldEffect') then continue end
        if object == depth_of_fields then continue end
        Connections[object] = object:GetPropertyChangedSignal('FarIntensity'):Connect(function() object.FarIntensity = 0 end)
        object.FarIntensity = 0
    end
end
function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object
    self._frame = frame
end
function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name = 'Root'
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    part.Parent = self._folder
    local specialMesh = Instance.new('SpecialMesh')
    specialMesh.MeshType = Enum.MeshType.Brick
    specialMesh.Offset = Vector3.new(0, 0, -0.000001)
    specialMesh.Parent = part
    self._root = part
end
function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()
    self:render(0.001)
    self:check_quality_level()
end
function AcrylicBlur:render(distance)
    local positions = {top_left = Vector2.new(),top_right = Vector2.new(),bottom_right = Vector2.new()}
    local function update_positions(size, position)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end
    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right
        local top_left3D = Util:viewport_point_to_world(top_left, distance)
        local top_right3D = Util:viewport_point_to_world(top_right, distance)
        local bottom_right3D = Util:viewport_point_to_world(bottom_right, distance)
        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude
        if not self._root then return end
        self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end
    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        update_positions(size, position)
        task.spawn(update)
    end
    Connections['cframe_update'] = workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections['viewport_size_update'] = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
    Connections['field_of_view_update'] = workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)
    Connections['frame_absolute_position'] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['frame_absolute_size'] = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)
    task.spawn(update)
end
function AcrylicBlur:check_quality_level()
    local game_settings = UserSettings().GameSettings
    local quality_level = game_settings.SavedQualityLevel.Value
    if quality_level < 8 then self:change_visiblity(false) end
    Connections['quality_level'] = game_settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        local ql = UserSettings().GameSettings.SavedQualityLevel.Value
        self:change_visiblity(ql >= 8)
    end)
end
function AcrylicBlur:change_visiblity(state)
    self._root.Transparency = state and 0.98 or 1
end
local Config = setmetatable({
    save = function(self, file_name, config)
        local ok, result = pcall(function()
            local flags = HttpService:JSONEncode(config)
            writefile('March/'..file_name..'.json', flags)
        end)
        if not ok then warn('failed to save config', result) end
    end,
    load = function(self, file_name, config)
        local success_load, result = pcall(function()
            if not isfile('March/'..file_name..'.json') then self:save(file_name, config) return end
            local flags = readfile('March/'..file_name..'.json')
            if not flags then self:save(file_name, config) return end
            return HttpService:JSONDecode(flags)
        end)
        if not success_load then warn('failed to load config', result) end
        if not result then result = {_flags = {},_keybinds = {},_library = {}} end
        return result
    end
}, Config)
local Library = {_config = Config:load(game.GameId),_choosing_keybind=false,_device=nil,_ui_open=true,_ui_scale=1,_ui_loaded=false,_ui=nil,_dragging=false,_drag_start=nil,_container_position=nil}
Library.__index = Library
function Library.new()
    local self = setmetatable({_loaded=false,_tab=0}, Library)
    self:create_ui()
    return self
end
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "RobloxCoreGuis"
NotificationContainer.Size = UDim2.new(0, 300, 0, 0)
NotificationContainer.Position = UDim2.new(0.8, 0, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ClipsDescendants = false
NotificationContainer.Parent = game:GetService("CoreGui").RobloxGui:FindFirstChild("RobloxCoreGuis") or Instance.new("ScreenGui", game:GetService("CoreGui").RobloxGui)
NotificationContainer.AutomaticSize = Enum.AutomaticSize.Y
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = NotificationContainer
function Library.SendNotification(settings)
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, 0, 0, 60)
    Notification.BackgroundTransparency = 1
    Notification.BorderSizePixel = 0
    Notification.Name = "Notification"
    Notification.Parent = NotificationContainer
    Notification.AutomaticSize = Enum.AutomaticSize.Y
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Notification
    local InnerFrame = Instance.new("Frame")
    InnerFrame.Size = UDim2.new(1, 0, 0, 60)
    InnerFrame.Position = UDim2.new(0, 0, 0, 0)
    InnerFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    InnerFrame.BackgroundTransparency = 0.1
    InnerFrame.BorderSizePixel = 0
    InnerFrame.Name = "InnerFrame"
    InnerFrame.Parent = Notification
    InnerFrame.AutomaticSize = Enum.AutomaticSize.Y
    local InnerUICorner = Instance.new("UICorner")
    InnerUICorner.CornerRadius = UDim.new(0, 4)
    InnerUICorner.Parent = InnerFrame
    local Title = Instance.new("TextLabel")
    Title.Text = settings.title or "Notification Title"
    Title.TextColor3 = Color3.fromRGB(210, 210, 210)
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextSize = 14
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.TextWrapped = true
    Title.AutomaticSize = Enum.AutomaticSize.Y
    Title.Parent = InnerFrame
    local Body = Instance.new("TextLabel")
    Body.Text = settings.text or "This is the body of the notification."
    Body.TextColor3 = Color3.fromRGB(180, 180, 180)
    Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Body.TextSize = 12
    Body.Size = UDim2.new(1, -10, 0, 30)
    Body.Position = UDim2.new(0, 5, 0, 25)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = InnerFrame
    task.spawn(function()
        wait(.1)
        local totalHeight = Title.TextBounds.Y + Body.TextBounds.Y + 10
        InnerFrame.Size = UDim2.new(1, 0, 0, totalHeight)
    end)
    task.spawn(function()
        local tweenIn = TweenService:Create(InnerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 10 + NotificationContainer.Size.Y.Offset)})
        tweenIn:Play()
        local duration = settings.duration or 5
        task.wait(duration)
        local tweenOut = TweenService:Create(InnerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 310, 0, 10 + NotificationContainer.Size.Y.Offset)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function() Notification:Destroy() end)
    end)
end
function Library:get_screen_scale()
    local viewport_size_x = workspace.CurrentCamera.ViewportSize.X
    self._ui_scale = viewport_size_x / 1400
end
function Library:get_device()
    local device = 'Unknown'
    if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then device = 'PC' elseif UserInputService.TouchEnabled then device = 'Mobile' elseif UserInputService.GamepadEnabled then device = 'Console' end
    self._device = device
end
function Library:removed(action) self._ui.AncestryChanged:Once(action) end
function Library:flag_type(flag, flag_type)
    if not Library._config._flags[flag] then return end
    return typeof(Library._config._flags[flag]) == flag_type
end
function Library:remove_table_value(__table, table_value)
    for index, value in __table do if value == table_value then table.remove(__table, index) break end end
end
function Library:create_ui()
    local old_March = CoreGui:FindFirstChild('March')
    if old_March then Debris:AddItem(old_March, 0) end
    local March = Instance.new('ScreenGui')
    March.ResetOnSpawn = false
    March.Name = 'March'
    March.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    March.Parent = CoreGui
    local Container = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundTransparency = 0.05
    Container.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.BorderSizePixel = 0
    Container.Parent = March
    local UICorner = Instance.new('UICorner', Container)
    UICorner.CornerRadius = UDim.new(0, 10)
    local UIStroke = Instance.new('UIStroke', Container)
    UIStroke.Color = Color3.fromRGB(52, 66, 89)
    UIStroke.Transparency = 0.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.Size = UDim2.new(0, 950, 0, 650)
    Handler.Parent = Container
    local Tabs = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(0, 175, 0, 550)
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0.0261, 0, 0.1111, 0)
    Tabs.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    Tabs.Parent = Handler
    local UIListLayoutTabs = Instance.new('UIListLayout', Tabs)
    UIListLayoutTabs.Padding = UDim.new(0, 4)
    local ClientName = Instance.new('TextLabel')
    ClientName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ClientName.TextColor3 = Color3.fromRGB(255, 100, 100)
    ClientName.TextTransparency = 0.2
    ClientName.Text = 'March'
    ClientName.Position = UDim2.new(0.056, 0, 0.055, 0)
    ClientName.Size = UDim2.new(0, 31, 0, 13)
    ClientName.BackgroundTransparency = 1
    ClientName.Parent = Handler
    local UIGradientClient = Instance.new('UIGradient', ClientName)
    UIGradientClient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}
    local Pin = Instance.new('Frame')
    Pin.Name = 'Pin'
    Pin.Position = UDim2.new(0.026, 0, 0.136, 0)
    Pin.Size = UDim2.new(0, 2, 0, 16)
    Pin.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    Pin.Parent = Handler
    local UICornerPin = Instance.new('UICorner', Pin)
    UICornerPin.CornerRadius = UDim.new(1, 0)
    local Icon = Instance.new('ImageLabel')
    Icon.ImageColor3 = Color3.fromRGB(255, 100, 100)
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Image = 'rbxassetid://107819132007001'
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.025, 0, 0.055, 0)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Parent = Handler
    local Divider = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0.5
    Divider.Position = UDim2.new(0.235, 0, 0, 0)
    Divider.Size = UDim2.new(0, 1, 0, 650)
    Divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Divider.Parent = Handler
    local Sections = Instance.new('Folder', Handler)
    Sections.Name = 'Sections'
    local Minimize = Instance.new('TextButton')
    Minimize.Text = ''
    Minimize.AutoButtonColor = false
    Minimize.BackgroundTransparency = 1
    Minimize.Name = 'Minimize'
    Minimize.Position = UDim2.new(0.02006, 0, 0.02923, 0)
    Minimize.Size = UDim2.new(0, 24, 0, 24)
    Minimize.Parent = Handler
    local UIScale = Instance.new('UIScale', Container)
    self._ui = March
    local function on_drag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position
            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end
    local function update_drag(input)
        local delta = input.Position - self._drag_start
        local position = UDim2.new(self._container_position.X.Scale, self._container_position.X.Offset + delta.X, self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y)
        TweenService:Create(Container, TweenInfo.new(0.2), {Position = position}):Play()
    end
    local function drag(input)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then update_drag(input) end
    end
    Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)
    self:removed(function() self._ui = nil Connections:disconnect_all() end)
    function self:UIVisiblity() March.Enabled = not March.Enabled end
    function self:change_visiblity(state)
        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = state and UDim2.fromOffset(950, 650) or UDim2.fromOffset(140, 70)}):Play()
    end
    function self:load()
        local content = {}
        for _, object in March:GetDescendants() do if object:IsA('ImageLabel') then table.insert(content, object) end end
        ContentProvider:PreloadAsync(content)
        self:get_device()
        if self._device == 'Mobile' or self._device == 'Unknown' then
            self:get_screen_scale()
            UIScale.Scale = self._ui_scale
            Connections['ui_scale'] = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                UIScale.Scale = self._ui_scale
            end)
        end
        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(950, 650)}):Play()
        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end
    function self:update_tabs(tab, left_section, right_section)
        for _, object in Tabs:GetChildren() do
            if object.Name ~= 'Tab' then continue end
            if object == tab then
                if object.BackgroundTransparency ~= 0.5 then
                    local offset = object.LayoutOrder * (0.113 / 1.3)
                    TweenService:Create(Pin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.026, 0.135 + offset)}):Play()
                    TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
                    TweenService:Create(object.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.2,TextColor3 = Color3.fromRGB(255, 100, 100)}):Play()
                    TweenService:Create(object.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)}):Play()
                    TweenService:Create(object.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.2,ImageColor3 = Color3.fromRGB(255, 100, 100)}):Play()
                end
                continue
            end
            if object.BackgroundTransparency ~= 1 then
                TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                TweenService:Create(object.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.7,TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(object.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Offset = Vector2.new(0, 0)}):Play()
                TweenService:Create(object.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.8,ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end
    end
    function self:update_sections(left_section, right_section)
        for _, object in Sections:GetChildren() do
            if object == left_section or object == right_section then object.Visible = true else object.Visible = false end
        end
    end
    function self:create_tab(title, icon)
        local TabManager = {}
        local font_params = Instance.new('GetTextBoundsParams')
        font_params.Text = title
        font_params.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        font_params.Size = 13
        font_params.Width = 10000
        local font_size = TextService:GetTextBoundsAsync(font_params)
        local first_tab = not Tabs:FindFirstChild('Tab')
        local Tab = Instance.new('TextButton')
        Tab.Text = ''
        Tab.AutoButtonColor = false
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.new(0, 175, 0, 48)
        Tab.LayoutOrder = self._tab
        Tab.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        Tab.Parent = Tabs
        local TabCorner = Instance.new('UICorner', Tab)
        TabCorner.CornerRadius = UDim.new(0, 5)
        local TextLabelTab = Instance.new('TextLabel', Tab)
        TextLabelTab.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabelTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabelTab.TextTransparency = 0.7
        TextLabelTab.Text = title
        TextLabelTab.Size = UDim2.new(0, font_size.X, 0, 16)
        TextLabelTab.AnchorPoint = Vector2.new(0, 0.5)
        TextLabelTab.Position = UDim2.new(0.24, 0, 0.5, 0)
        TextLabelTab.BackgroundTransparency = 1
        TextLabelTab.TextXAlignment = Enum.TextXAlignment.Left
        local UIGradientTab = Instance.new('UIGradient', TextLabelTab)
        UIGradientTab.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155,155,155)),ColorSequenceKeypoint.new(1, Color3.fromRGB(58,58,58))}
        local IconTab = Instance.new('ImageLabel', Tab)
        IconTab.ImageTransparency = 0.8
        IconTab.AnchorPoint = Vector2.new(0, 0.5)
        IconTab.BackgroundTransparency = 1
        IconTab.Position = UDim2.new(0.1, 0, 0.5, 0)
        IconTab.Image = icon
        IconTab.Size = UDim2.new(0, 12, 0, 12)
        local LeftSection = Instance.new('ScrollingFrame', Sections)
        LeftSection.Name = 'LeftSection'
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        LeftSection.ScrollBarThickness = 0
        LeftSection.Size = UDim2.new(0, 330, 0, 600)
        LeftSection.AnchorPoint = Vector2.new(0, 0.5)
        LeftSection.BackgroundTransparency = 1
        LeftSection.Position = UDim2.new(0.2594, 0, 0.5, 0)
        LeftSection.Visible = false
        local LeftLayout = Instance.new('UIListLayout', LeftSection)
        LeftLayout.Padding = UDim.new(0, 11)
        LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local UIPaddingLeft = Instance.new('UIPadding', LeftSection)
        UIPaddingLeft.PaddingTop = UDim.new(0, 1)
        local RightSection = Instance.new('ScrollingFrame', Sections)
        RightSection.Name = 'RightSection'
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        RightSection.ScrollBarThickness = 0
        RightSection.Size = UDim2.new(0, 330, 0, 600)
        RightSection.AnchorPoint = Vector2.new(0, 0.5)
        RightSection.BackgroundTransparency = 1
        RightSection.Position = UDim2.new(0.629, 0, 0.5, 0)
        RightSection.Visible = false
        local RightLayout = Instance.new('UIListLayout', RightSection)
        RightLayout.Padding = UDim.new(0, 11)
        RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local UIPaddingRight = Instance.new('UIPadding', RightSection)
        UIPaddingRight.PaddingTop = UDim.new(0, 1)
        self._tab += 1
        if first_tab then self:update_tabs(Tab, LeftSection, RightSection) self:update_sections(LeftSection, RightSection) end
        Tab.MouseButton1Click:Connect(function() self:update_tabs(Tab, LeftSection, RightSection) self:update_sections(LeftSection, RightSection) end)
        function TabManager:create_module(settings)
            local LayoutOrderModule = 0
            local ModuleManager = {_state = false,_size = 0,_multiplier = 0}
            if settings.section == 'right' then settings.section = RightSection else settings.section = LeftSection end
            local Module = Instance.new('Frame', settings.section)
            Module.ClipsDescendants = true
            Module.BackgroundTransparency = 0.5
            Module.Position = UDim2.new(0.0041, 0, 0, 0)
            Module.Size = UDim2.new(0, 310, 0, 130)
            Module.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
            local ModuleLayout = Instance.new('UIListLayout', Module)
            local ModuleCorner = Instance.new('UICorner', Module)
            ModuleCorner.CornerRadius = UDim.new(0, 5)
            local ModuleStroke = Instance.new('UIStroke', Module)
            ModuleStroke.Color = Color3.fromRGB(52, 66, 89)
            ModuleStroke.Transparency = 0.5
            ModuleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            local Header = Instance.new('TextButton', Module)
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.new(0, 310, 0, 130)
            local IconHeader = Instance.new('ImageLabel', Header)
            IconHeader.ImageColor3 = Color3.fromRGB(255, 100, 100)
            IconHeader.ImageTransparency = 0.7
            IconHeader.AnchorPoint = Vector2.new(0, 0.5)
            IconHeader.Image = 'rbxassetid://79095934438045'
            IconHeader.Position = UDim2.new(0.071, 0, 0.82, 0)
            IconHeader.Size = UDim2.new(0, 18, 0, 18)
            local ModuleName = Instance.new('TextLabel', Header)
            ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            ModuleName.TextColor3 = Color3.fromRGB(255, 100, 100)
            ModuleName.TextTransparency = 0.2
            if not settings.rich then ModuleName.Text = settings.title or "Skibidi" else ModuleName.RichText = true ModuleName.Text = settings.richtext or "<font color='rgb(255,0,0)'>March</font> user" end
            ModuleName.Size = UDim2.new(0, 240, 0, 16)
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.new(0.073, 0, 0.24, 0)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            local Description = Instance.new('TextLabel', Header)
            Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Description.TextColor3 = Color3.fromRGB(255, 100, 100)
            Description.TextTransparency = 0.7
            Description.Text = settings.description
            Description.Size = UDim2.new(0, 240, 0, 15)
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.new(0.073, 0, 0.42, 0)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            local Toggle = Instance.new('Frame', Header)
            Toggle.BackgroundTransparency = 0.7
            Toggle.Position = UDim2.new(0.82, 0, 0.757, 0)
            Toggle.Size = UDim2.new(0, 30, 0, 15)
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            local ToggleCorner = Instance.new('UICorner', Toggle)
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            local Circle = Instance.new('Frame', Toggle)
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundTransparency = 0.2
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.Size = UDim2.new(0, 15, 0, 15)
            Circle.BackgroundColor3 = Color3.fromRGB(66, 80, 115)
            local CircleCorner = Instance.new('UICorner', Circle)
            CircleCorner.CornerRadius = UDim.new(1, 0)
            local Keybind = Instance.new('Frame', Header)
            Keybind.BackgroundTransparency = 0.7
            Keybind.Position = UDim2.new(0.15, 0, 0.735, 0)
            Keybind.Size = UDim2.new(0, 40, 0, 18)
            Keybind.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            local KeybindCorner = Instance.new('UICorner', Keybind)
            KeybindCorner.CornerRadius = UDim.new(0, 3)
            local KeyText = Instance.new('TextLabel', Keybind)
            KeyText.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            KeyText.TextColor3 = Color3.fromRGB(255, 150, 150)
            KeyText.Text = 'None'
            KeyText.AnchorPoint = Vector2.new(0.5, 0.5)
            KeyText.Size = UDim2.new(0, 32, 0, 16)
            KeyText.BackgroundTransparency = 1
            KeyText.TextXAlignment = Enum.TextXAlignment.Left
            KeyText.Position = UDim2.new(0.5, 0, 0.5, 0)
            KeyText.TextSize = 11
            local Divider1 = Instance.new('Frame', Header)
            Divider1.AnchorPoint = Vector2.new(0.5, 0)
            Divider1.BackgroundTransparency = 0.5
            Divider1.Position = UDim2.new(0.5, 0, 0.62, 0)
            Divider1.Size = UDim2.new(0, 310, 0, 1)
            Divider1.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
            local Divider2 = Instance.new('Frame', Header)
            Divider2.AnchorPoint = Vector2.new(0.5, 0)
            Divider2.BackgroundTransparency = 0.5
            Divider2.Position = UDim2.new(0.5, 0, 1, 0)
            Divider2.Size = UDim2.new(0, 310, 0, 1)
            Divider2.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
            local Options = Instance.new('Frame', Module)
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.Size = UDim2.new(0, 310, 0, 8)
            local UIPaddingOptions = Instance.new('UIPadding', Options)
            UIPaddingOptions.PaddingTop = UDim.new(0, 8)
            local UIListLayoutOptions = Instance.new('UIListLayout', Options)
            UIListLayoutOptions.Padding = UDim.new(0, 5)
            UIListLayoutOptions.HorizontalAlignment = Enum.HorizontalAlignment.Center
            function ModuleManager:change_state(state)
                self._state = state
                if self._state then
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(310, 130 + self._size + self._multiplier)}):Play()
                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 100, 100),Position = UDim2.fromScale(0.53, 0.5)}):Play()
                else
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(310, 130)}):Play()
                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(66, 80, 115),Position = UDim2.fromScale(0, 0.5)}):Play()
                end
                Library._config._flags[settings.flag] = self._state
                Config:save(game.GameId, Library._config)
                settings.callback(self._state)
            end
            function ModuleManager:connect_keybind()
                if not Library._config._keybinds[settings.flag] then return end
                Connections[settings.flag..'_keybind'] = UserInputService.InputBegan:Connect(function(input, process)
                    if process then return end
                    if tostring(input.KeyCode) ~= Library._config._keybinds[settings.flag] then return end
                    self:change_state(not self._state)
                end)
            end
            function ModuleManager:scale_keybind(empty)
                if Library._config._keybinds[settings.flag] and not empty then
                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    local font_params2 = Instance.new('GetTextBoundsParams')
                    font_params2.Text = keybind_string
                    font_params2.Font = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold)
                    font_params2.Size = 10
                    font_params2.Width = 10000
                    local font_size2 = TextService:GetTextBoundsAsync(font_params2)
                    Keybind.Size = UDim2.fromOffset(font_size2.X + 6, 15)
                    KeyText.Size = UDim2.fromOffset(font_size2.X, 13)
                else
                    Keybind.Size = UDim2.fromOffset(31, 15)
                    KeyText.Size = UDim2.fromOffset(25, 13)
                end
            end
            if Library:flag_type(settings.flag, 'boolean') then
                ModuleManager._state = true
                settings.callback(ModuleManager._state)
                Toggle.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                Circle.Position = UDim2.fromScale(0.53, 0.5)
            end
            if Library._config._keybinds[settings.flag] then
                local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                KeyText.Text = keybind_string
                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end
            Connections[settings.flag..'_input_began'] = Header.InputBegan:Connect(function(input)
                if Library._choosing_keybind then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                Library._choosing_keybind = true
                Connections['keybind_choose_start'] = UserInputService.InputBegan:Connect(function(input2, process)
                    if process then return end
                    if input2.KeyCode == Enum.KeyCode.Unknown then return end
                    if input2.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)
                        Library._config._keybinds[settings.flag] = nil
                        Config:save(game.GameId, Library._config)
                        KeyText.Text = 'None'
                        if Connections[settings.flag..'_keybind'] then Connections[settings.flag..'_keybind']:Disconnect() Connections[settings.flag..'_keybind'] = nil end
                        Connections['keybind_choose_start']:Disconnect()
                        Connections['keybind_choose_start'] = nil
                        Library._choosing_keybind = false
                        return
                    end
                    Connections['keybind_choose_start']:Disconnect()
                    Connections['keybind_choose_start'] = nil
                    Library._config._keybinds[settings.flag] = tostring(input2.KeyCode)
                    Config:save(game.GameId, Library._config)
                    if Connections[settings.flag..'_keybind'] then Connections[settings.flag..'_keybind']:Disconnect() Connections[settings.flag..'_keybind'] = nil end
                    ModuleManager:connect_keybind()
                    ModuleManager:scale_keybind()
                    Library._choosing_keybind = false
                    local keybind_string2 = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    KeyText.Text = keybind_string2
                end)
            end)
            Header.MouseButton1Click:Connect(function() ModuleManager:change_state(not ModuleManager._state) end)
            function ModuleManager:create_paragraph(settings2)
                LayoutOrderModule += 1
                local ParagraphManager = {}
                if self._size == 0 then self._size = 11 end
                self._size += settings2.customScale or 70
                if ModuleManager._state then Module.Size = UDim2.fromOffset(310, 130 + self._size) end
                Options.Size = UDim2.fromOffset(310, self._size)
                local Paragraph = Instance.new('Frame', Options)
                Paragraph.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                Paragraph.BackgroundTransparency = 0.1
                Paragraph.Size = UDim2.new(0, 207, 0, 30)
                Paragraph.BorderSizePixel = 0
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y
                Paragraph.LayoutOrder = LayoutOrderModule
                local ParagraphCorner = Instance.new('UICorner', Paragraph)
                ParagraphCorner.CornerRadius = UDim.new(0, 4)
                local Title = Instance.new('TextLabel', Paragraph)
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Title.TextColor3 = Color3.fromRGB(210, 210, 210)
                Title.Text = settings2.title or "Title"
                Title.Size = UDim2.new(1, -10, 0, 20)
                Title.Position = UDim2.new(0, 5, 0, 5)
                Title.BackgroundTransparency = 1
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Center
                Title.TextSize = 12
                Title.AutomaticSize = Enum.AutomaticSize.XY
                local Body = Instance.new('TextLabel', Paragraph)
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = Color3.fromRGB(180, 180, 180)
                if not settings2.rich then Body.Text = settings2.text or "Skibidi" else Body.RichText = true Body.Text = settings2.richtext or "<font color='rgb(255,0,0)'>March</font> user" end
                Body.Size = UDim2.new(1, -10, 0, 20)
                Body.Position = UDim2.new(0, 5, 0, 30)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 11
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Paragraph.MouseEnter:Connect(function() TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(42, 50, 66)}):Play() end)
                Paragraph.MouseLeave:Connect(function() TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(32, 38, 51)}):Play() end)
                return ParagraphManager
            end
            function ModuleManager:create_text(settings2)
                LayoutOrderModule += 1
                local TextManager = {}
                if self._size == 0 then self._size = 11 end
                self._size += settings2.customScale or 50
                if ModuleManager._state then Module.Size = UDim2.fromOffset(241, 93 + self._size) end
                Options.Size = UDim2.fromOffset(241, self._size)
                local TextFrame = Instance.new('Frame', Options)
                TextFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                TextFrame.BackgroundTransparency = 0.1
                TextFrame.Size = UDim2.new(0, 207, 0, settings2.CustomYSize)
                TextFrame.BorderSizePixel = 0
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y
                TextFrame.LayoutOrder = LayoutOrderModule
                local TextCorner = Instance.new('UICorner', TextFrame)
                TextCorner.CornerRadius = UDim.new(0, 4)
                local Body = Instance.new('TextLabel', TextFrame)
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = Color3.fromRGB(180, 180, 180)
                if not settings2.rich then Body.Text = settings2.text or "Skibidi" else Body.RichText = true Body.Text = settings2.richtext or "<font color='rgb(255,0,0)'>March</font> user" end
                Body.Size = UDim2.new(1, -10, 1, 0)
                Body.Position = UDim2.new(0, 5, 0, 5)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 10
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                TextFrame.MouseEnter:Connect(function() TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(42, 50, 66)}):Play() end)
                TextFrame.MouseLeave:Connect(function() TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(32, 38, 51)}):Play() end)
                function TextManager:Set(new_settings)
                    if not new_settings.rich then Body.Text = new_settings.text or "Skibidi" else Body.RichText = true Body.Text = new_settings.richtext or "<font color='rgb(255,0,0)'>March</font> user" end
                end
                return TextManager
            end
            function ModuleManager:create_textbox(settings2)
                LayoutOrderModule += 1
                local TextboxManager = {_text = ""}
                if self._size == 0 then self._size = 11 end
                self._size += 32
                if ModuleManager._state then Module.Size = UDim2.fromOffset(241, 93 + self._size) end
                Options.Size = UDim2.fromOffset(241, self._size)
                local Label = Instance.new('TextLabel', Options)
                Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextTransparency = 0.2
                Label.Text = settings2.title or "Enter text"
                Label.Size = UDim2.new(0, 207, 0, 13)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextSize = 10
                Label.LayoutOrder = LayoutOrderModule
                local Textbox = Instance.new('TextBox', Options)
                Textbox.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
                Textbox.PlaceholderText = settings2.placeholder or "Enter text..."
                Textbox.Text = Library._config._flags[settings2.flag] or ""
                Textbox.Name = 'Textbox'
                Textbox.Size = UDim2.new(0, 207, 0, 15)
                Textbox.TextSize = 10
                Textbox.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                Textbox.BackgroundTransparency = 0.9
                Textbox.ClearTextOnFocus = false
                Textbox.LayoutOrder = LayoutOrderModule
                local TextboxCorner = Instance.new('UICorner', Textbox)
                TextboxCorner.CornerRadius = UDim.new(0, 4)
                function TextboxManager:update_text(text)
                    self._text = text
                    Library._config._flags[settings2.flag] = self._text
                    Config:save(game.GameId, Library._config)
                    settings2.callback(self._text)
                end
                if Library:flag_type(settings2.flag, 'string') then TextboxManager:update_text(Library._config._flags[settings2.flag]) end
                Textbox.FocusLost:Connect(function() TextboxManager:update_text(Textbox.Text) end)
                return TextboxManager
            end
            function ModuleManager:create_checkbox(settings2)
                LayoutOrderModule += 1
                local CheckboxManager = { _state = false }
                if self._size == 0 then self._size = 11 end
                self._size += 20
                if ModuleManager._state then Module.Size = UDim2.fromOffset(241, 93 + self._size) end
                Options.Size = UDim2.fromOffset(241, self._size)
                local Checkbox = Instance.new("TextButton", Options)
                Checkbox.Text = ""
                Checkbox.AutoButtonColor = false
                Checkbox.BackgroundTransparency = 1
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(0, 207, 0, 15)
                Checkbox.LayoutOrder = LayoutOrderModule
                local TitleLabel = Instance.new("TextLabel", Checkbox)
                if SelectedLanguage == "th" then TitleLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal) TitleLabel.TextSize = 13 else TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal) TitleLabel.TextSize = 11 end
                TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TitleLabel.TextTransparency = 0.2
                TitleLabel.Text = settings2.title or "Skibidi"
                TitleLabel.Size = UDim2.new(0, 142, 0, 13)
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                local KeybindBox = Instance.new("Frame", Checkbox)
                KeybindBox.Size = UDim2.fromOffset(14, 14)
                KeybindBox.Position = UDim2.new(1, -35, 0.5, 0)
                KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
                KeybindBox.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                local KeybindCorner = Instance.new("UICorner", KeybindBox)
                KeybindCorner.CornerRadius = UDim.new(0, 4)
                local KeybindLabel = Instance.new("TextLabel", KeybindBox)
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                KeybindLabel.TextSize = 10
                KeybindLabel.Font = Enum.Font.SourceSans
                KeybindLabel.Text = Library._config._keybinds[settings2.flag] and string.gsub(tostring(Library._config._keybinds[settings2.flag]), "Enum.KeyCode.", "") or "..."
                local Box = Instance.new("Frame", Checkbox)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundTransparency = 0.9
                Box.Position = UDim2.new(1, 0, 0.5, 0)
                Box.Size = UDim2.new(0, 15, 0, 15)
                Box.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                local BoxCorner = Instance.new("UICorner", Box)
                BoxCorner.CornerRadius = UDim.new(0, 4)
                local Fill = Instance.new("Frame", Box)
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundTransparency = 0.2
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                local FillCorner = Instance.new("UICorner", Fill)
                FillCorner.CornerRadius = UDim.new(0, 3)
                function CheckboxManager:change_state(state)
                    self._state = state
                    if self._state then
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()
                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(9, 9)}):Play()
                    else
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.9}):Play()
                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(0, 0)}):Play()
                    end
                    Library._config._flags[settings2.flag] = self._state
                    Config:save(game.GameId, Library._config)
                    settings2.callback(self._state)
                end
                if Library:flag_type(settings2.flag, "boolean") then CheckboxManager:change_state(Library._config._flags[settings2.flag]) end
                Checkbox.MouseButton1Click:Connect(function() CheckboxManager:change_state(not CheckboxManager._state) end)
                Checkbox.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                    if Library._choosing_keybind then return end
                    Library._choosing_keybind = true
                    local chooseConnection
                    chooseConnection = UserInputService.InputBegan:Connect(function(keyInput, processed)
                        if processed then return end
                        if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if keyInput.KeyCode == Enum.KeyCode.Unknown then return end
                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            ModuleManager:scale_keybind(true)
                            Library._config._keybinds[settings2.flag] = nil
                            Config:save(game.GameId, Library._config)
                            KeybindLabel.Text = "..."
                            if Connections[settings2.flag .. "_keybind"] then Connections[settings2.flag .. "_keybind"]:Disconnect() Connections[settings2.flag .. "_keybind"] = nil end
                            chooseConnection:Disconnect()
                            Library._choosing_keybind = false
                            return
                        end
                        chooseConnection:Disconnect()
                        Library._config._keybinds[settings2.flag] = tostring(keyInput.KeyCode)
                        Config:save(game.GameId, Library._config)
                        if Connections[settings2.flag .. "_keybind"] then Connections[settings2.flag .. "_keybind"]:Disconnect() Connections[settings2.flag .. "_keybind"] = nil end
                        ModuleManager:connect_keybind()
                        ModuleManager:scale_keybind()
                        Library._choosing_keybind = false
                        local keybind_string = string.gsub(tostring(Library._config._keybinds[settings2.flag]), "Enum.KeyCode.", "")
                        KeybindLabel.Text = keybind_string
                    end)
                end)
                local keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local storedKey = Library._config._keybinds[settings2.flag]
                        if storedKey and tostring(input.KeyCode) == storedKey then CheckboxManager:change_state(not CheckboxManager._state) end
                    end
                end)
                Connections[settings2.flag .. "_keypress"] = keyPressConnection
                return CheckboxManager
            end
            function ModuleManager:create_divider(settings2)
                LayoutOrderModule += 1
                if self._size == 0 then self._size = 11 end
                self._size += 27
                if ModuleManager._state then Module.Size = UDim2.fromOffset(241, 93 + self._size) end
                local dividerHeight = 1
                local dividerWidth = 207
                local OuterFrame = Instance.new('Frame', Options)
                OuterFrame.Size = UDim2.new(0, dividerWidth, 0, 20)
                OuterFrame.BackgroundTransparency = 1
                OuterFrame.Name = 'OuterFrame'
                OuterFrame.LayoutOrder = LayoutOrderModule
                if settings2 and settings2.showtopic then
                    local TextLabel = Instance.new('TextLabel', OuterFrame)
                    TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.Text = settings2.title
                    TextLabel.Size = UDim2.new(0, 153, 0, 13)
                    TextLabel.Position = UDim2.new(0.5, 0, 0.501, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                    TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
                    TextLabel.TextSize = 11
                    TextLabel.ZIndex = 3
                    TextLabel.TextStrokeTransparency = 0
                end
                if not settings2 or settings2 and not settings2.disableline then
                    local DividerLine = Instance.new('Frame', OuterFrame)
                    DividerLine.Size = UDim2.new(1, 0, 0, dividerHeight)
                    DividerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    DividerLine.Name = 'Divider'
                    DividerLine.ZIndex = 2
                    DividerLine.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2)
                    local Gradient = Instance.new('UIGradient', DividerLine)
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    })
                    Gradient.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.5, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    local DividerCorner = Instance.new('UICorner', DividerLine)
                    DividerCorner.CornerRadius = UDim.new(0, 2)
                end
                return true
            end
            function ModuleManager:create_slider(settings2)
                LayoutOrderModule += 1
                local SliderManager = {}
                if self._size == 0 then self._size = 11 end
                self._size += 27
                if ModuleManager._state then Module.Size = UDim2.fromOffset(241, 93 + self._size) end
                Options.Size = UDim2.fromOffset(241, self._size)
                local Slider = Instance.new('TextButton', Options)
                Slider.Text = ''
                Slider.AutoButtonColor = false
                Slider.BackgroundTransparency = 1
                Slider.Name = 'Slider'
                Slider.Size = UDim2.new(0, 207, 0, 22)
                Slider.LayoutOrder = LayoutOrderModule
                local TextLabelSlider = Instance.new('TextLabel', Slider)
                if GG.SelectedLanguage == "th" then
                    TextLabelSlider.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabelSlider.TextSize = 13
                else
                    TextLabelSlider.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabelSlider.TextSize = 11
                end
                TextLabelSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabelSlider.TextTransparency = 0.2
                TextLabelSlider.Text = settings2.title
                TextLabelSlider.Size = UDim2.new(0, 153, 0, 13)
                TextLabelSlider.Position = UDim2.new(0, 0, 0.05, 0)
                TextLabelSlider.BackgroundTransparency = 1
                TextLabelSlider.TextXAlignment = Enum.TextXAlignment.Left
                local Drag = Instance.new('Frame', Slider)
                Drag.AnchorPoint = Vector2.new(0.5, 1)
                Drag.BackgroundTransparency = 0.9
                Drag.Position = UDim2.new(0.5, 0, 0.95, 0)
                Drag.Name = 'Drag'
                Drag.Size = UDim2.new(0, 207, 0, 4)
                Drag.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                local DragCorner = Instance.new('UICorner', Drag)
                DragCorner.CornerRadius = UDim.new(1, 0)
                local Fill = Instance.new('Frame', Drag)
                Fill.AnchorPoint = Vector2.new(0, 0.5)
                Fill.BackgroundTransparency = 0.5
                Fill.Position = UDim2.new(0, 0, 0.5, 0)
                Fill.Name = 'Fill'
                Fill.Size = UDim2.new(0, 103, 0, 4)
                Fill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                local FillCorner = Instance.new('UICorner', Fill)
                FillCorner.CornerRadius = UDim.new(0, 3)
                local UIGradientFill = Instance.new('UIGradient', Fill)
                UIGradientFill.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79))}
                local CircleSlider = Instance.new('Frame', Fill)
                CircleSlider.AnchorPoint = Vector2.new(1, 0.5)
                CircleSlider.Name = 'Circle'
                CircleSlider.Position = UDim2.new(1, 0, 0.5, 0)
                CircleSlider.Size = UDim2.new(0, 6, 0, 6)
                CircleSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                local CircleCornerSlider = Instance.new('UICorner', CircleSlider)
                CircleCornerSlider.CornerRadius = UDim.new(1, 0)
                local Value = Instance.new('TextLabel', Slider)
                Value.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Value.TextColor3 = Color3.fromRGB(255, 255, 255)
                Value.TextTransparency = 0.2
                Value.Text = '50'
                Value.Name = 'Value'
                Value.Size = UDim2.new(0, 42, 0, 13)
                Value.AnchorPoint = Vector2.new(1, 0)
                Value.Position = UDim2.new(1, 0, 0, 0)
                Value.BackgroundTransparency = 1
                Value.TextXAlignment = Enum.TextXAlignment.Right
                Value.TextSize = 10
                function SliderManager:set_percentage(percentage)
                    local rounded_number = 0
                    if settings2.round_number then rounded_number = math.floor(percentage) else rounded_number = math.floor(percentage * 10) / 10 end
                    percentage = (percentage - settings2.minimum_value) / (settings2.maximum_value - settings2.minimum_value)
                    local slider_size = math.clamp(percentage, 0.02, 1) * Drag.Size.X.Offset
                    local number_threshold = math.clamp(rounded_number, settings2.minimum_value, settings2.maximum_value)
                    Library._config._flags[settings2.flag] = number_threshold
                    Value.Text = number_threshold
                    TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(slider_size, Drag.Size.Y.Offset)}):Play()
                    settings2.callback(number_threshold)
                end
                function SliderManager:update()
                    local mouse_position = (mouse.X - Drag.AbsolutePosition.X) / Drag.Size.X.Offset
                    local percentage = settings2.minimum_value + (settings2.maximum_value - settings2.minimum_value) * mouse_position
                    self:set_percentage(percentage)
                end
                function SliderManager:input()
                    SliderManager:update()
                    Connections['slider_drag_'..settings2.flag] = mouse.Move:Connect(function() SliderManager:update() end)
                    Connections['slider_input_'..settings2.flag] = UserInputService.InputEnded:Connect(function(input, process)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        Connections:disconnect('slider_drag_'..settings2.flag)
                        Connections:disconnect('slider_input_'..settings2.flag)
                        if not settings2.ignoresaved then Config:save(game.GameId, Library._config) end
                    end)
                end
                if Library:flag_type(settings2.flag, 'number') then
                    if not settings2.ignoresaved then SliderManager:set_percentage(Library._config._flags[settings2.flag]) else SliderManager:set_percentage(settings2.value) end
                else
                    SliderManager:set_percentage(settings2.value)
                end
                Slider.MouseButton1Down:Connect(function() SliderManager:input() end)
                return SliderManager
            end
            function ModuleManager:create_dropdown(settings2)
                return {update=function()end}
            end
            return ModuleManager
        end
        return TabManager
    end
    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input, process)
        if input.KeyCode ~= Enum.KeyCode.Insert then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)
    self._ui.Container.Handler.Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)
    return self
end
-- Exploit environment compatibility patch
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return true, res end
    return false, res
end
local function exists(f) return typeof(f) == 'function' end
local has_fs = exists(isfolder) and exists(makefolder) and exists(writefile) and exists(readfile)
local function safe_cloneref(obj)
    if exists(cloneref) then
        local ok, res = pcall(cloneref, obj)
        if ok and res then return res end
    end
    return obj
end

if not gethui then gethui = function() return (game:FindFirstChildOfClass('CoreGui') or game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')) end end
if not isfile then isfile = function() return false end end
if not isfolder then isfolder = function() return false end end
if not makefolder then makefolder = function() end end
if not writefile then writefile = function() end end
if not readfile then readfile = function() return '' end end

if UserInputService then
    UserInputService = safe_cloneref(UserInputService)
    TweenService = safe_cloneref(TweenService)
    TextService = safe_cloneref(TextService)
    HttpService = safe_cloneref(HttpService)
    ContentProvider = safe_cloneref(ContentProvider)
    RunService = safe_cloneref(RunService)
    Lighting = safe_cloneref(Lighting)
    Players = safe_cloneref(Players)
    CoreGui = safe_cloneref(CoreGui)
    Debris = safe_cloneref(Debris)
end

if Config then
    local raw_save = Config.save
    function Config:save(id, data)
        if not has_fs then return end
        safe_pcall(raw_save, self, id, data)
    end
    local raw_load = Config.load
    function Config:load(id)
        if not has_fs then return {_flags = {}, _keybinds = {}} end
        local ok, res = safe_pcall(raw_load, self, id)
        if ok and res then return res end
        return {_flags = {}, _keybinds = {}}
    end
end

local _Library_new = Library.new
function Library.new(settings)
    settings = settings or {}
    local self = _Library_new(settings)
    self._settings = settings
    return self
end

local _create_ui_pending
local function patch_create_ui()
    if _create_ui_pending or not Library.create_ui then return end
    _create_ui_pending = true
    local raw_create = Library.create_ui
    function Library:create_ui(name)
        local ui = raw_create(self, name)
        -- Reparent safely
        local parent = (self._settings and self._settings.parent) or (exists(gethui) and gethui()) or CoreGui or (Players.LocalPlayer:WaitForChild('PlayerGui'))
        if ui and ui._ui and ui._ui.Parent ~= parent then
            safe_pcall(function()
                ui._ui.Parent = parent
                if syn and exists(syn.protect_gui) then syn.protect_gui(ui._ui) end
                if get_hidden_gui and exists(get_hidden_gui) then
                    -- some executors use get_hidden_gui
                    pcall(function() ui._ui.Parent = get_hidden_gui() end)
                end
            end)
        end
        return ui
    end
end
patch_create_ui()

if AcrylicBlur and AcrylicBlur.new then
    local raw_blur_new = AcrylicBlur.new
    function AcrylicBlur.new(container)
        if (Library._settings and Library._settings.disable_blur) then return end
        safe_pcall(raw_blur_new, container)
    end
end

local _raw_load = Library.load
if _raw_load then
    function Library:load(...)
        local result = { _raw_load(self, ...) }
        return table.unpack(result)
    end
end
