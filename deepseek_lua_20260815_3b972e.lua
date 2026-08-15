--[==[ GACF VIP SCRIPT - FULL HOÀN CHỈNH ]==]

-- ==================== PHẦN 1: FRAMEWORK NHÚNG TRỰC TIẾP ====================
--[[
    GACF UI FRAMEWORK - NHÚNG TRỰC TIẾP (KHÔNG CẦN LOAD EXTERNAL)
]]
local GACF = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local COLORS = {
    Background = Color3.fromRGB(12, 12, 18),
    Background2 = Color3.fromRGB(20, 20, 28),
    TitleBar = Color3.fromRGB(30, 30, 42),
    Content = Color3.fromRGB(40, 40, 52),
    ContentHover = Color3.fromRGB(50, 50, 65),
    Border = Color3.fromRGB(0, 200, 255),
    BorderGlow = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    ToggleOn = Color3.fromRGB(0, 220, 120),
    ToggleOff = Color3.fromRGB(70, 70, 85),
    Knob = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 200, 255),
    Danger = Color3.fromRGB(255, 60, 60),
}

local screenGui = nil
local mainFrame = nil
local scrollFrame = nil
local toggleButton = nil
local isOpen = false
local connections = {}
local menuTitle = "GACF VIP"

local function cleanup()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    pcall(function() if screenGui then screenGui:Destroy() end end)
    screenGui = nil
    mainFrame = nil
    scrollFrame = nil
    toggleButton = nil
end

-- ==================== TẠO UI ====================
function GACF:CreateUI(title)
    cleanup()
    menuTitle = title or "GACF VIP"
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GACF_UI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
    mainFrame.BackgroundColor3 = COLORS.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Parent = screenGui
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 998
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = COLORS.Border
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = COLORS.TitleBar
    titleBar.BackgroundTransparency = 0.05
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 18, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ " .. menuTitle
    titleText.TextColor3 = COLORS.Text
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COLORS.TextDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        isOpen = false
        mainFrame.Visible = false
    end)
    
    -- Scroll Frame
    scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -12, 1, -56)
    scrollFrame.Position = UDim2.new(0, 6, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = COLORS.Border
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    -- Toggle Button
    self:CreateToggle()
    
    return self
end

-- ==================== TẠO TOGGLE BUTTON ====================
function GACF:CreateToggle()
    if toggleButton then return end
    
    toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 44, 0, 44)
    toggleButton.Position = UDim2.new(1, -56, 1, -56)
    toggleButton.BackgroundColor3 = COLORS.Accent
    toggleButton.Text = "⚡"
    toggleButton.TextColor3 = COLORS.Text
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 20
    toggleButton.Parent = screenGui
    toggleButton.ZIndex = 999
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
    
    toggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        mainFrame.Visible = isOpen
        if isOpen then
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.05
            }):Play()
        end
    end)
    
    -- Drag
    local dragging = false
    local dragStart, startPos
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = toggleButton.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            toggleButton.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ==================== TẠO TOGGLE ====================
function GACF:AddToggle(label, icon, default, callback)
    if not scrollFrame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "🔘"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -80, 1, 0)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Toggle"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 40, 0, 20)
    switchFrame.Position = UDim2.new(1, -50, 0.5, -10)
    switchFrame.BackgroundColor3 = default and COLORS.ToggleOn or COLORS.ToggleOff
    switchFrame.Parent = container
    Instance.new("UICorner", switchFrame).CornerRadius = UDim.new(0, 10)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = COLORS.Knob
    knob.Parent = switchFrame
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local state = default or false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        switchFrame.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
        local targetPos = state and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        if callback then callback(state) end
    end)
    
    return container
end

-- ==================== TẠO BUTTON ====================
function GACF:AddButton(label, icon, callback)
    if not scrollFrame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "📌"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -55, 1, 0)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Button"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 28)
    btn.Position = UDim2.new(1, -58, 0, 6)
    btn.BackgroundColor3 = COLORS.Accent
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Text = "▶"
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 48, 0, 24)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 52, 0, 28)}):Play()
    end)
    
    return container
end

-- ==================== TẠO DROPDOWN ====================
function GACF:AddDropdown(label, icon, options, default, callback)
    if not scrollFrame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "📋"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Dropdown"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(0.4, -10, 1, 0)
    selectedText.Position = UDim2.new(0.55, 0, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = default or options[1] or "Select"
    selectedText.TextColor3 = COLORS.Accent
    selectedText.Font = Enum.Font.GothamBold
    selectedText.TextSize = 12
    selectedText.TextXAlignment = Enum.TextXAlignment.Right
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -22, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = COLORS.TextDim
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = container
    
    local listContainer = Instance.new("Frame")
    listContainer.Size = UDim2.new(1, 0, 0, #options * 35)
    listContainer.Position = UDim2.new(0, 0, 1, 2)
    listContainer.BackgroundColor3 = COLORS.Background2
    listContainer.Visible = false
    listContainer.ZIndex = 100
    listContainer.Parent = container
    Instance.new("UICorner", listContainer).CornerRadius = UDim.new(0, 8)
    
    local listStroke = Instance.new("UIStroke", listContainer)
    listStroke.Color = COLORS.Border
    listStroke.Thickness = 1
    listStroke.Transparency = 0.5
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listContainer
    
    local selectedValue = default or options[1]
    local isOpen = false
    local optionButtons = {}
    
    local function closeDropdown()
        isOpen = false
        listContainer.Visible = false
        arrow.Text = "▼"
        container.Size = UDim2.new(1, -6, 0, 40)
    end
    
    local function openDropdownFunc()
        isOpen = true
        listContainer.Visible = true
        arrow.Text = "▲"
        container.Size = UDim2.new(1, -6, 0, 40 + #options * 35)
    end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdownFunc()
        end
    end)
    
    -- Tạo options
    for i, option in pairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, -8, 0, 33)
        optionBtn.BackgroundColor3 = COLORS.Content
        optionBtn.BackgroundTransparency = 0.5
        optionBtn.Text = option
        optionBtn.TextColor3 = COLORS.Text
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 12
        optionBtn.Parent = listContainer
        Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 6)
        
        optionBtn.MouseButton1Click:Connect(function()
            selectedValue = option
            selectedText.Text = option
            if callback then callback(option) end
            closeDropdown()
        end)
        
        table.insert(optionButtons, optionBtn)
    end
    
    return container
end

-- ==================== TẠO SEPARATOR ====================
function GACF:AddSeparator()
    if not scrollFrame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = COLORS.Border
    line.BackgroundTransparency = 0.7
    line.Parent = container
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 1)
    
    return container
end

-- ==================== TẠO LABEL ====================
function GACF:AddLabel(text, icon)
    if not scrollFrame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = COLORS.TextDim
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    return container
end

-- ==================== TẠO TITLE ====================
function GACF:AddTitle(text, icon)
    if not scrollFrame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = (icon or "★") .. " " .. text
    title.TextColor3 = COLORS.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = COLORS.Accent
    line.BackgroundTransparency = 0.5
    line.Parent = container
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 1)
    
    return container
end

return GACF
-- ==================== KẾT THÚC FRAMEWORK ====================

-- ==================== PHẦN 2: LOGIC CHÍNH ====================
local menu = GACF:CreateUI("GACF VIP")

-- Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Biến toàn cục
local aimEnabled = false
local m1TeleEnabled = false
local espEnabled = false
local currentTarget = nil
local AIM_RANGE = 100
local autoRejoin = true
local isDead = false
local currentTargetMode = "Weakest"
local espObjects = {}
local hookConnection = nil

-- ==================== HÀM LẤY DANH SÁCH PLAYER ====================
local function getPlayerList()
    local list = {"Weakest Enemy"} -- Luôn có option Weakest Enemy
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- ==================== TARGET LOGIC ====================
local function getValidEnemies()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return {}
    end
    
    local myPos = player.Character.HumanoidRootPart.Position
    local enemies = {}
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player then
            local char = target.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local humanoid = char.Humanoid
                if humanoid.Health > 0 then
                    local distance = (char.HumanoidRootPart.Position - myPos).Magnitude
                    if distance <= AIM_RANGE then
                        table.insert(enemies, {
                            Character = char,
                            Humanoid = humanoid,
                            Distance = distance,
                            Health = humanoid.Health,
                            Player = target
                        })
                    end
                end
            end
        end
    end
    return enemies
end

local function findWeakestEnemy()
    local enemies = getValidEnemies()
    if #enemies == 0 then return nil end
    table.sort(enemies, function(a, b) return a.Health < b.Health end)
    return enemies[1].Character
end

local function findTargetByName(name)
    if name == "Weakest Enemy" then
        return findWeakestEnemy()
    end
    
    for _, target in pairs(Players:GetPlayers()) do
        if target.Name == name then
            local char = target.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                if char.Humanoid.Health > 0 then
                    return char
                end
            end
        end
    end
    return nil
end

local function getCurrentTarget()
    if currentTargetMode == "Weakest Enemy" then
        return findWeakestEnemy()
    else
        return findTargetByName(currentTargetMode)
    end
end

-- ==================== SILENT AIM ====================
task.spawn(function()
    while RunService:IsRunning() do
        if aimEnabled and not isDead then
            pcall(function()
                local char = player.Character
                local target = getCurrentTarget()
                currentTarget = target
                
                if char and char:FindFirstChild("HumanoidRootPart") and 
                   target and target:FindFirstChild("HumanoidRootPart") then
                    
                    local root = char.HumanoidRootPart
                    local direction = (target.HumanoidRootPart.Position - root.Position).Unit
                    local flatDirection = Vector3.new(direction.X, 0, direction.Z)
                    
                    if flatDirection.Magnitude > 0 then
                        root.CFrame = CFrame.lookAt(root.Position, root.Position + flatDirection)
                    end
                end
            end)
        end
        task.wait()
    end
end)

-- ==================== M1 TELEPORT ====================
local function performM1Teleport()
    if not m1TeleEnabled or isDead then return end
    
    local target = getCurrentTarget()
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local targetRoot = target.HumanoidRootPart
    
    local behindPosition = targetRoot.Position - (targetRoot.CFrame.LookVector * 1.5)
    local teleportPosition = behindPosition + Vector3.new(0, 1, 0)
    
    root.CFrame = CFrame.lookAt(teleportPosition, targetRoot.Position)
    root.Velocity = Vector3.new(0, 0, 0)
end

local function setupHook()
    if hookConnection then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" and #args >= 1 then
            pcall(function()
                local data = args[1]
                if type(data) == "table" then
                    if data["Request"] == "M1Down" or data["Request"] == "M1Up" then
                        task.spawn(performM1Teleport)
                    end
                end
            end)
        end
        return oldNamecall(self, ...)
    end)
    hookConnection = true
end

local function stopHook()
    if hookConnection then
        hookConnection = nil
        pcall(function() hookmetamethod(game, "__namecall", nil) end)
    end
end

-- ==================== ESP ====================
local function createESP(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not rootPart or not humanoid then return end
    
    removeESP(targetPlayer)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. targetPlayer.Name
    billboard.Size = UDim2.new(0, 180, 0, 55)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.MaxDistance = 150
    billboard.AlwaysOnTop = true
    billboard.Parent = rootPart
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = targetPlayer.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0.85, 0, 0, 8)
    healthBg.Position = UDim2.new(0.075, 0, 0, 22)
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.Parent = billboard
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = healthBg
    
    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1, 0, 0, 16)
    hpText.Position = UDim2.new(0, 0, 0, 32)
    hpText.BackgroundTransparency = 1
    hpText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.TextScaled = true
    hpText.Font = Enum.Font.Gotham
    hpText.Parent = billboard
    
    espObjects[targetPlayer] = {
        Billboard = billboard,
        HealthBar = healthBar,
        HealthBg = healthBg,
        HpText = hpText,
        Humanoid = humanoid
    }
end

local function removeESP(targetPlayer)
    if espObjects[targetPlayer] then
        if espObjects[targetPlayer].Billboard then
            espObjects[targetPlayer].Billboard:Destroy()
        end
        espObjects[targetPlayer] = nil
    end
end

local function clearAllESP()
    for playerObj, data in pairs(espObjects) do
        if data.Billboard then
            data.Billboard:Destroy()
        end
    end
    espObjects = {}
end

task.spawn(function()
    while RunService:IsRunning() do
        if espEnabled then
            pcall(function()
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player then
                        local char = target.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                            local humanoid = char.Humanoid
                            if humanoid.Health > 0 then
                                if not espObjects[target] then
                                    createESP(target)
                                else
                                    local data = espObjects[target]
                                    if data.Humanoid then
                                        local hp = data.Humanoid.Health
                                        local maxHp = data.Humanoid.MaxHealth
                                        local percent = hp / maxHp
                                        
                                        if percent > 0.5 then
                                            data.HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                                        elseif percent > 0.25 then
                                            data.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                                        else
                                            data.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                                        end
                                        
                                        data.HealthBar.Size = UDim2.new(percent, 0, 1, 0)
                                        data.HpText.Text = math.floor(hp) .. "/" .. math.floor(maxHp)
                                    end
                                end
                            else
                                removeESP(target)
                            end
                        else
                            removeESP(target)
                        end
                    end
                end
            end)
        else
            clearAllESP()
        end
        task.wait(0.1)
    end
end)

-- ==================== RUN TELE ====================
local function runTele()
    if isDead then return end
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    if humanoid.Health <= 0 then return end
    
    local newPosition = rootPart.Position + Vector3.new(0, 100, 0)
    rootPart.CFrame = CFrame.new(newPosition)
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
end

-- ==================== AUTO REJOIN ====================
local function rejoinServer()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

local function onDeath()
    isDead = true
    if autoRejoin then
        task.wait(2)
        rejoinServer()
    end
end

player.CharacterAdded:Connect(function(character)
    isDead = false
    task.wait(0.5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(onDeath)
    end
    if m1TeleEnabled then
        stopHook()
        setupHook()
    end
end)

-- ==================== PHẦN 3: MENU SETUP ====================
menu:AddTitle("Aimbot & Utilities", "🎯")

-- TARGET DROPDOWN - CÓ NÚT TAM GIÁC BÊN PHẢI
menu:AddDropdown("Target", "🎯", getPlayerList(), "Weakest Enemy", function(selected)
    currentTargetMode = selected
    print("Đã chọn target:", selected)
    
    -- Cập nhật lại dropdown khi có người chơi mới vào
    -- Tự động cập nhật mỗi 5 giây
end)

menu:AddSeparator()

-- Features
menu:AddToggle("Silent Aim", "🎯", false, function(state)
    aimEnabled = state
    if not state then currentTarget = nil end
end)

menu:AddToggle("M1 Teleport", "⚡", false, function(state)
    m1TeleEnabled = state
    if state then setupHook() else stopHook() end
end)

menu:AddButton("Run Tele", "🚀", function()
    runTele()
end)

menu:AddToggle("ESP Target", "👁️", false, function(state)
    espEnabled = state
    if not state then clearAllESP() end
end)

menu:AddSeparator()

-- Settings
menu:AddSlider("Aim Range", "📏", 50, 200, 100, function(value)
    AIM_RANGE = value
end)

menu:AddSeparator()

-- Utility
menu:AddToggle("Auto Rejoin", "🔄", true, function(state)
    autoRejoin = state
end)

menu:AddButton("Rejoin Server", "🚪", function()
    rejoinServer()
end)

menu:AddLabel("Made by GACF", "⚡")

-- ==================== AUTO UPDATE DROPDOWN ====================
task.spawn(function()
    while RunService:IsRunning() do
        task.wait(5) -- Cập nhật mỗi 5 giây
        -- TODO: Cần cập nhật lại dropdown options
        -- Hiện tại framework chưa hỗ trợ update options động
    end
end)

print("✅ GACF VIP Script loaded successfully!")