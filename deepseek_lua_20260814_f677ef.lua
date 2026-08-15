--[==[ GACF VIP - PHẦN 1/3 ]==]
local GACF = loadstring(game:HttpGet("https://raw.githubusercontent.com/NhatRemakeScript/Scripter/refs/heads/main/Edit1f.lua"))()

local menu = GACF:CreateUI("GACF VIP")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local aimEnabled = false
local m1TeleEnabled = false
local espEnabled = false
local currentTarget = nil
local AIM_RANGE = 100
local oldHook = nil

local espObjects = {}

local function findWeakestEnemy()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local weak = nil
    local low = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local c = p.Character
            if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") then
                local h = c.Humanoid
                if h.Health > 0 then
                    local dist = (c.HumanoidRootPart.Position - myPos).Magnitude
                    if dist <= AIM_RANGE and h.Health < low then
                        low = h.Health
                        weak = c
                    end
                end
            end
        end
    end
    return weak
end

spawn(function()
    while true do
        if aimEnabled then
            pcall(function()
                local char = player.Character
                local target = findWeakestEnemy()
                currentTarget = target
                if char and char:FindFirstChild("HumanoidRootPart") and target and target:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local dir = (target.HumanoidRootPart.Position - root.Position).Unit
                    local flat = Vector3.new(dir.X, 0, dir.Z)
                    if flat.Magnitude > 0 then
                        root.CFrame = CFrame.lookAt(root.Position, root.Position + flat)
                    end
                end
            end)
        end
        task.wait()
    end
end)

local function performM1Teleport()
    if not m1TeleEnabled then return end
    local target = findWeakestEnemy()
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local targetRoot = target.HumanoidRootPart
    local behindPos = targetRoot.Position - (targetRoot.CFrame.LookVector * 1)
    local telePos = behindPos + Vector3.new(0, 1, 0)
    root.CFrame = CFrame.lookAt(telePos, targetRoot.Position)
end

local function setupHook()
    if oldHook then return end
    oldHook = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        local result = oldHook(self, ...)
        if method == "FireServer" then
            pcall(function()
                if #args >= 1 and type(args[1]) == "table" then
                    local data = args[1]
                    if data["Request"] == "M1Down" or data["Request"] == "M1Up" then
                        task.spawn(performM1Teleport)
                    end
                end
            end)
        end
        return result
    end)
end

local function stopHook()
    if oldHook then
        pcall(function() hookmetamethod(game, "__namecall", oldHook) end)
        oldHook = nil
    end
end
--[==[ GACF VIP - PHẦN 2/3 ]==]
local function createESP(playerObj)
    local character = playerObj.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not rootPart or not humanoid then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. playerObj.Name
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.MaxDistance = 150
    billboard.AlwaysOnTop = true
    billboard.Parent = rootPart
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.Parent = billboard
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerObj.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = bg
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(0.9, 0, 0, 6)
    healthBar.Position = UDim2.new(0.05, 0, 0.4, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = bg
    Instance.new("UICorner", healthBar).CornerRadius = UDim.new(0, 3)
    
    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1, 0, 0, 16)
    hpText.Position = UDim2.new(0, 0, 0.65, 0)
    hpText.BackgroundTransparency = 1
    hpText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.Font = Enum.Font.Gotham
    hpText.TextSize = 11
    hpText.TextXAlignment = Enum.TextXAlignment.Center
    hpText.Parent = bg
    
    espObjects[playerObj] = {
        Billboard = billboard,
        HealthBar = healthBar,
        HpText = hpText,
        Humanoid = humanoid
    }
end

local function removeESP(playerObj)
    if espObjects[playerObj] then
        pcall(function()
            if espObjects[playerObj].Billboard then
                espObjects[playerObj].Billboard:Destroy()
            end
        end)
        espObjects[playerObj] = nil
    end
end

local function clearAllESP()
    for p, data in pairs(espObjects) do
        pcall(function()
            if data.Billboard then
                data.Billboard:Destroy()
            end
        end)
    end
    espObjects = {}
end

local function updateESP()
    if not espEnabled then
        clearAllESP()
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local humanoid = char.Humanoid
                if humanoid.Health > 0 then
                    if not espObjects[p] then
                        createESP(p)
                    else
                        local data = espObjects[p]
                        if data.HealthBar and data.HpText and data.Humanoid then
                            local hp = data.Humanoid.Health
                            local maxHp = data.Humanoid.MaxHealth
                            local percent = hp / maxHp
                            data.HealthBar.Size = UDim2.new(math.clamp(percent, 0, 1) * 0.9, 0, 0, 6)
                            if percent > 0.5 then
                                data.HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            elseif percent > 0.25 then
                                data.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                            else
                                data.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            end
                            data.HpText.Text = math.floor(hp) .. "/" .. math.floor(maxHp)
                        end
                    end
                else
                    removeESP(p)
                end
            else
                removeESP(p)
            end
        end
    end
end

spawn(function()
    while true do
        if espEnabled then
            pcall(updateESP)
        else
            clearAllESP()
        end
        task.wait(0.1)
    end
end)
--[==[ GACF VIP - PHẦN 3/3 ]==]
menu:AddToggle("Silent Aim", "🎯", false, function(state)
    aimEnabled = state
    if not state then currentTarget = nil end
end)

menu:AddToggle("M1 Teleport", "⚡", false, function(state)
    m1TeleEnabled = state
    if state then setupHook() else stopHook() end
end)

menu:AddToggle("ESP Target", "👁️", false, function(state)
    espEnabled = state
    if not state then clearAllESP() end
end)

menu:AddSeparator()

menu:AddSlider("Aim Range", "📏", 50, 200, 100, function(value)
    AIM_RANGE = value
end)

menu:AddLabel("Made by GACF", "⚡")

player.CharacterRemoving:Connect(function()
    pcall(function()
        if espEnabled then clearAllESP() end
        currentTarget = nil
        stopHook()
    end)
end)

player.CharacterAdded:Connect(function()
    pcall(function()
        task.wait(0.5)
        currentTarget = nil
        if espEnabled then clearAllESP() end
        if m1TeleEnabled then setupHook() end
    end)
end)

game:BindToClose(function()
    pcall(function()
        stopHook()
        clearAllESP()
    end)
end)
