local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernUIPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local COLORS = {
    Background = Color3.fromRGB(25, 25, 25),
    TitleBar = Color3.fromRGB(35, 35, 35),
    Content = Color3.fromRGB(45, 45, 45),
    Border = Color3.fromRGB(0, 200, 0),
    Text = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(0, 180, 0),
    ToggleOff = Color3.fromRGB(80, 80, 80),
    Knob = Color3.fromRGB(255, 255, 255),
    Premium = Color3.fromRGB(255, 215, 0),
}

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = COLORS.Background
mainFrame.Parent = screenGui
mainFrame.Visible = false

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.Border
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = COLORS.TitleBar
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "GACF VIP"
titleText.TextColor3 = COLORS.Text
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Active = false
titleText.Parent = titleBar

local premiumLabel = Instance.new("TextLabel")
premiumLabel.Size = UDim2.new(0, 60, 0, 18)
premiumLabel.Position = UDim2.new(0.32, 0, 0.5, -9)
premiumLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
premiumLabel.BackgroundTransparency = 0.7
premiumLabel.Text = "PREMIUM"
premiumLabel.TextColor3 = COLORS.Premium
premiumLabel.Font = Enum.Font.GothamBold
premiumLabel.TextSize = 10
premiumLabel.TextXAlignment = Enum.TextXAlignment.Center
premiumLabel.Parent = titleBar

local premiumCorner = Instance.new("UICorner")
premiumCorner.CornerRadius = UDim.new(0, 3)
premiumCorner.Parent = premiumLabel

local premiumStroke = Instance.new("UIStroke")
premiumStroke.Color = COLORS.Premium
premiumStroke.Thickness = 1
premiumStroke.Parent = premiumLabel

local leaderstatsFrame = Instance.new("Frame")
leaderstatsFrame.Name = "LeaderstatsFrame"
leaderstatsFrame.Size = UDim2.new(1, -30, 0, 55)
leaderstatsFrame.Position = UDim2.new(0, 15, 0, 48)
leaderstatsFrame.BackgroundColor3 = COLORS.Content
leaderstatsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = leaderstatsFrame

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = Color3.fromRGB(70, 70, 70)
statsStroke.Thickness = 1
statsStroke.Parent = leaderstatsFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -10, 1, 0)
statsLabel.Position = UDim2.new(0, 5, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = COLORS.Text
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 13
statsLabel.TextWrapped = true
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = leaderstatsFrame

local function updateLeaderstats()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        statsLabel.Text = "Không có leaderstats"
        return
    end

    local text = ""
    local count = 0
    for _, stat in ipairs(leaderstats:GetChildren()) do
        text = text .. stat.Name .. ": " .. tostring(stat.Value)
        count = count + 1
        if count % 3 == 0 then
            text = text .. "\n"
        else
            text = text .. "  |  "
        end
    end
    statsLabel.Text = text
end

spawn(function()
    while true do
        updateLeaderstats()
        wait(1)
    end
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -118)
scrollFrame.Position = UDim2.new(0, 0, 0, 112)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.ScrollBarImageColor3 = COLORS.Border
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.FillDirection = Enum.FillDirection.Vertical
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = scrollFrame

local function CreateToggle(label, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -30, 0, 45)
    toggleFrame.LayoutOrder = 1
    toggleFrame.BackgroundColor3 = COLORS.Content
    toggleFrame.Parent = scrollFrame

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = toggleFrame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(70, 70, 70)
    frameStroke.Thickness = 1
    frameStroke.Parent = toggleFrame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -75, 1, 0)
    labelText.Position = UDim2.new(0, 12, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.GothamBold
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Active = false
    labelText.Parent = toggleFrame

    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 40, 0, 22)
    switchFrame.Position = UDim2.new(1, -52, 0, 11.5)
    switchFrame.BackgroundColor3 = default and COLORS.ToggleOn or COLORS.ToggleOff
    switchFrame.Parent = toggleFrame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 11)
    switchCorner.Parent = switchFrame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, default and 21 or 3, 0, 3)
    knob.BackgroundColor3 = COLORS.Knob
    knob.Parent = switchFrame

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local clickCatcher = Instance.new("TextButton")
    clickCatcher.Size = UDim2.new(1, 0, 1, 0)
    clickCatcher.BackgroundTransparency = 1
    clickCatcher.Text = ""
    clickCatcher.AutoButtonColor = false
    clickCatcher.Parent = toggleFrame

    local state = default

    clickCatcher.MouseButton1Click:Connect(function()
        state = not state
        switchFrame.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff

        local targetPos = state and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()

        if callback then
            callback(state)
        end
    end)

    return toggleFrame
end

local AIM_RANGE = 60
local silentAimEnabled = false
local currentTarget = nil
local glowParts = {}

local function removeGlow()
    for _, glow in pairs(glowParts) do
        pcall(function()
            glow:Destroy()
        end)
    end
    glowParts = {}
end

local function addGlowToTarget(character)
    removeGlow()
    
    if not character then return end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "TargetGlow"
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = part
            table.insert(glowParts, highlight)
        end
    end
end

local function findWeakestEnemyInRange()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local myPosition = character.HumanoidRootPart.Position
    local weakestEnemy = nil
    local lowestHealth = math.huge
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherCharacter = otherPlayer.Character
            if otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart") and otherCharacter:FindFirstChild("Humanoid") then
                local humanoid = otherCharacter.Humanoid
                if humanoid.Health > 0 then
                    local distance = (otherCharacter.HumanoidRootPart.Position - myPosition).Magnitude
                    
                    if distance <= AIM_RANGE then
                        if humanoid.Health < lowestHealth then
                            lowestHealth = humanoid.Health
                            weakestEnemy = otherCharacter
                        end
                    end
                end
            end
        end
    end
    
    return weakestEnemy
end

spawn(function()
    while true do
        if silentAimEnabled then
            pcall(function()
                local character = player.Character
                local target = findWeakestEnemyInRange()
                
                if target ~= currentTarget then
                    currentTarget = target
                    addGlowToTarget(target)
                end
                
                if currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health <= 0 then
                    currentTarget = nil
                    removeGlow()
                end
                
                if character and character:FindFirstChild("HumanoidRootPart") and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                    local root = character.HumanoidRootPart
                    local targetPosition = currentTarget.HumanoidRootPart.Position
                    
                    local lookDirection = (targetPosition - root.Position).Unit
                    local flatDirection = Vector3.new(lookDirection.X, 0, lookDirection.Z)
                    
                    if flatDirection.Magnitude > 0 then
                        local newCFrame = CFrame.lookAt(
                            root.Position,
                            root.Position + flatDirection
                        )
                        root.CFrame = newCFrame
                    end
                end
            end)
        else
            if currentTarget then
                currentTarget = nil
                removeGlow()
            end
        end
        
        task.wait()
    end
end)

CreateToggle("Silent Aim 🎯", false, function(state)
    silentAimEnabled = state
    print("Silent Aim:", state)
    if not state then
        currentTarget = nil
        removeGlow()
    end
end)

local skillTeleEnabled = false
local m1TeleEnabled = false
local oldNamecall = nil

local function teleportToCurrentTarget()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
        local targetRoot = currentTarget.HumanoidRootPart
        
        local targetLookDirection = targetRoot.CFrame.LookVector
        local behindPosition = targetRoot.Position - (targetLookDirection * 1)
        
        character.HumanoidRootPart.CFrame = CFrame.new(behindPosition)
        
        print("Teleported behind:", currentTarget.Parent.Name)
    else
        print("Không có mục tiêu để tele!")
    end
end

local function startHook()
    if oldNamecall then
        return
    end
    
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        local result = oldNamecall(self, ...)
        
        if method == "FireServer" then
            pcall(function()
                if #args >= 1 and type(args[1]) == "table" then
                    local data = args[1]
                    
                    if skillTeleEnabled and data["Request"] == "Skill" and data["Number"] == "2" then
                        print("Phát hiện skill 2, teleporting...")
                        task.spawn(teleportToCurrentTarget)
                    end
                    
                    if m1TeleEnabled and data["Request"] == "M1Up" then
                        print("Phát hiện M1Up, teleporting...")
                        task.spawn(teleportToCurrentTarget)
                    end
                end
            end)
        end
        
        return result
    end)
end

local function stopHook()
    if oldNamecall then
        hookmetamethod(game, "__namecall", oldNamecall)
        oldNamecall = nil
    end
end

CreateToggle("Skill Tele ⚡", false, function(state)
    skillTeleEnabled = state
    print("Skill Tele:", state)
    
    if state or m1TeleEnabled then
        startHook()
    else
        stopHook()
    end
end)

CreateToggle("M1 Tele 😈", false, function(state)
    m1TeleEnabled = state
    print("M1 Tele:", state)
    
    if state or skillTeleEnabled then
        startHook()
    else
        stopHook()
    end
end)

local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
toggleButton.BackgroundTransparency = 0
toggleButton.Image = ""
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = COLORS.Border
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleButton

local toggleText = Instance.new("TextLabel")
toggleText.Size = UDim2.new(1, 0, 1, 0)
toggleText.BackgroundTransparency = 1
toggleText.Text = "VIP"
toggleText.TextColor3 = COLORS.Border
toggleText.Font = Enum.Font.GothamBold
toggleText.TextSize = 14
toggleText.TextScaled = false
toggleText.Parent = toggleButton

local glowFrame = Instance.new("Frame")
glowFrame.Size = UDim2.new(1.3, 0, 1.3, 0)
glowFrame.Position = UDim2.new(-0.15, 0, -0.15, 0)
glowFrame.BackgroundColor3 = COLORS.Border
glowFrame.BackgroundTransparency = 0.8
glowFrame.Parent = toggleButton

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = glowFrame

local isOpen = false

toggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    mainFrame.Visible = isOpen
end)

local draggingToggle = false
local dragToggleOffset = Vector2.new(0, 0)
local touchTogglePos = nil

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        local position = input.Position
        local mousePos = Vector2.new(position.X, position.Y)
        local framePos = toggleButton.Position
        dragToggleOffset = Vector2.new(mousePos.X - framePos.X.Offset, mousePos.Y - framePos.Y.Offset)
        touchTogglePos = mousePos
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        
        if touchTogglePos then
            local delta = mousePos - touchTogglePos
            touchTogglePos = mousePos
            
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local frameSize = toggleButton.AbsoluteSize
            
            local newX = toggleButton.Position.X.Offset + delta.X
            local newY = toggleButton.Position.Y.Offset + delta.Y
            
            newX = math.clamp(newX, 0, viewportSize.X - frameSize.X)
            newY = math.clamp(newY, 0, viewportSize.Y - frameSize.Y)
            
            toggleButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = false
        touchTogglePos = nil
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = false
        touchTogglePos = nil
    end
end)

local draggingMain = false
local dragMainOffset = Vector2.new(0, 0)
local touchMainPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        local position = input.Position
        local mousePos = Vector2.new(position.X, position.Y)
        local framePos = mainFrame.Position
        dragMainOffset = Vector2.new(mousePos.X - framePos.X.Offset, mousePos.Y - framePos.Y.Offset)
        touchMainPos = mousePos
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        
        if touchMainPos then
            local delta = mousePos - touchMainPos
            touchMainPos = mousePos
            
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local frameSize = mainFrame.AbsoluteSize
            
            local newX = mainFrame.Position.X.Offset + delta.X
            local newY = mainFrame.Position.Y.Offset + delta.Y
            
            newX = math.clamp(newX, 0, viewportSize.X - frameSize.X)
            newY = math.clamp(newY, 0, viewportSize.Y - frameSize.Y)
            
            mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = false
        touchMainPos = nil
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = false
        touchMainPos = nil
    end
end)

spawn(function()
    while wait(60) do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

player.CharacterRemoving:Connect(function()
    stopHook()
    removeGlow()
end)