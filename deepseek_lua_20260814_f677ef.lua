--[==[ GACF VIP - PHẦN 1/3 ]==]
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local C = {
    Background = Color3.fromRGB(25,25,25),
    TitleBar = Color3.fromRGB(35,35,35),
    Content = Color3.fromRGB(45,45,45),
    Border = Color3.fromRGB(0,200,0),
    Text = Color3.fromRGB(255,255,255),
    ToggleOn = Color3.fromRGB(0,180,0),
    ToggleOff = Color3.fromRGB(80,80,80),
    Knob = Color3.fromRGB(255,255,255),
    Premium = Color3.fromRGB(255,215,0)
}

local gui = Instance.new("ScreenGui")
gui.Name = "ModernUIPanel"
gui.Parent = player:WaitForChild("PlayerGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0,420,0,320)
main.Position = UDim2.new(0.5,-210,0.5,-160)
main.BackgroundColor3 = C.Background
main.Parent = gui
main.Visible = false
Instance.new("UICorner",main).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke",main).Color = C.Border
Instance.new("UIStroke",main).Thickness = 1.5

local title = Instance.new("Frame")
title.Name = "TitleBar"
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = C.TitleBar
title.Parent = main
Instance.new("UICorner",title).CornerRadius = UDim.new(0,12)

local txt = Instance.new("TextLabel")
txt.Size = UDim2.new(1,-80,1,0)
txt.Position = UDim2.new(0,15,0,0)
txt.BackgroundTransparency = 1
txt.Text = "GACF VIP"
txt.TextColor3 = C.Text
txt.Font = Enum.Font.GothamBold
txt.TextSize = 18
txt.TextXAlignment = Enum.TextXAlignment.Left
txt.Active = false
txt.Parent = title

local prem = Instance.new("TextLabel")
prem.Size = UDim2.new(0,60,0,18)
prem.Position = UDim2.new(0.32,0,0.5,-9)
prem.BackgroundColor3 = Color3.fromRGB(0,0,0)
prem.BackgroundTransparency = 0.7
prem.Text = "PREMIUM"
prem.TextColor3 = C.Premium
prem.Font = Enum.Font.GothamBold
prem.TextSize = 10
prem.TextXAlignment = Enum.TextXAlignment.Center
prem.Parent = title
Instance.new("UICorner",prem).CornerRadius = UDim.new(0,3)
Instance.new("UIStroke",prem).Color = C.Premium
Instance.new("UIStroke",prem).Thickness = 1

local stats = Instance.new("Frame")
stats.Name = "LeaderstatsFrame"
stats.Size = UDim2.new(1,-30,0,55)
stats.Position = UDim2.new(0,15,0,48)
stats.BackgroundColor3 = C.Content
stats.Parent = main
Instance.new("UICorner",stats).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke",stats).Color = Color3.fromRGB(70,70,70)
Instance.new("UIStroke",stats).Thickness = 1

local statLbl = Instance.new("TextLabel")
statLbl.Size = UDim2.new(1,-10,1,0)
statLbl.Position = UDim2.new(0,5,0,0)
statLbl.BackgroundTransparency = 1
statLbl.TextColor3 = C.Text
statLbl.Font = Enum.Font.Gotham
statLbl.TextSize = 13
statLbl.TextWrapped = true
statLbl.TextXAlignment = Enum.TextXAlignment.Left
statLbl.Parent = stats

spawn(function()
    while true do
        local ls = player:FindFirstChild("leaderstats")
        if not ls then
            statLbl.Text = "Không có leaderstats"
        else
            local text = ""
            local count = 0
            for _,s in ipairs(ls:GetChildren()) do
                text = text .. s.Name .. ": " .. s.Value
                count = count + 1
                if count % 3 == 0 then
                    text = text .. "\n"
                else
                    text = text .. "  |  "
                end
            end
            statLbl.Text = text
        end
        wait(1)
    end
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ScrollFrame"
scroll.Size = UDim2.new(1,0,1,-118)
scroll.Position = UDim2.new(0,0,0,112)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = C.Border
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0,0,0,300)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.Padding = UDim.new(0,6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

function CreateToggle(label, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-30,0,45)
    f.LayoutOrder = 1
    f.BackgroundColor3 = C.Content
    f.Parent = scroll
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke",f).Color = Color3.fromRGB(70,70,70)
    Instance.new("UIStroke",f).Thickness = 1
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-75,1,0)
    l.Position = UDim2.new(0,12,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.Text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Active = false
    l.Parent = f
    
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,22)
    sw.Position = UDim2.new(1,-52,0,11.5)
    sw.BackgroundColor3 = default and C.ToggleOn or C.ToggleOff
    sw.Parent = f
    Instance.new("UICorner",sw).CornerRadius = UDim.new(0,11)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = UDim2.new(0,default and 21 or 3,0,3)
    knob.BackgroundColor3 = C.Knob
    knob.Parent = sw
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = f
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        sw.BackgroundColor3 = state and C.ToggleOn or C.ToggleOff
        local targetPos = state and UDim2.new(0,21,0,3) or UDim2.new(0,3,0,3)
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        if callback then callback(state) end
    end)
    return f
end
--[==[ GACF VIP - PHẦN 2/3 ]==]
local aimEnabled = false
local target = nil
local hpLabels = {} -- Lưu các BillBoardGui

-- Hàm tạo BillBoardGui hiển thị HP trên đầu mục tiêu
local function createHPBar(character)
    if not character then return end
    
    -- Xóa HP cũ nếu có
    if hpLabels[character] then
        hpLabels[character]:Destroy()
        hpLabels[character] = nil
    end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TargetHP"
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.MaxDistance = 100
    billboard.Parent = head
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = billboard
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0, 4)
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, -4, 0.7, 0)
    healthBar.Position = UDim2.new(0, 2, 0.15, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = frame
    Instance.new("UICorner",healthBar).CornerRadius = UDim.new(0, 2)
    
    local hpText = Instance.new("TextLabel")
    hpText.Name = "HPText"
    hpText.Size = UDim2.new(1, 0, 0.4, 0)
    hpText.Position = UDim2.new(0, 0, 0.65, 0)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.Font = Enum.Font.GothamBold
    hpText.TextSize = 12
    hpText.Text = ""
    hpText.Parent = frame
    
    hpLabels[character] = billboard
    return billboard
end

-- Hàm cập nhật HP
local function updateHP(character)
    if not character then return end
    local billboard = hpLabels[character]
    if not billboard then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local healthBar = billboard:FindFirstChild("Frame") and billboard.Frame:FindFirstChild("HealthBar")
    local hpText = billboard:FindFirstChild("Frame") and billboard.Frame:FindFirstChild("HPText")
    
    if healthBar and hpText then
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local percent = health / maxHealth
        
        healthBar.Size = UDim2.new(math.clamp(percent, 0, 1), -4, 0.7, 0)
        
        if percent > 0.5 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif percent > 0.25 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        hpText.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
    end
end

-- Hàm xóa HP của mục tiêu
local function removeHP(character)
    if character and hpLabels[character] then
        pcall(function() hpLabels[character]:Destroy() end)
        hpLabels[character] = nil
    end
end

-- Hàm xóa tất cả HP
local function clearAllHP()
    for char, billboard in pairs(hpLabels) do
        pcall(function() billboard:Destroy() end)
    end
    hpLabels = {}
end

local function findTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local pos = char.HumanoidRootPart.Position
    local weak = nil
    local low = math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local c = p.Character
            if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") then
                local h = c.Humanoid
                if h.Health > 0 then
                    local dist = (c.HumanoidRootPart.Position - pos).Magnitude
                    if dist <= 60 and h.Health < low then
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
                local t = findTarget()
                
                -- Xóa HP của target cũ
                if target and target ~= t then
                    removeHP(target)
                end
                
                if t ~= target then
                    target = t
                    if target then
                        createHPBar(target)
                    end
                end
                
                -- Cập nhật HP
                if target then
                    local h = target:FindFirstChild("Humanoid")
                    if not h or h.Health <= 0 then
                        removeHP(target)
                        target = nil
                    else
                        updateHP(target)
                    end
                end
                
                if char and char:FindFirstChild("HumanoidRootPart") and target and target:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local dir = (target.HumanoidRootPart.Position - root.Position).Unit
                    local flat = Vector3.new(dir.X, 0, dir.Z)
                    if flat.Magnitude > 0 then
                        root.CFrame = CFrame.lookAt(root.Position, root.Position + flat)
                    end
                end
            end)
        else
            if target then
                removeHP(target)
                target = nil
            end
        end
        task.wait()
    end
end)

CreateToggle("Silent Aim 🎯", false, function(s)
    aimEnabled = s
    if not s then
        if target then
            removeHP(target)
            target = nil
        end
        clearAllHP()
    end
end)

local skillTele = false
local m1Tele = false
local oldHook = nil

local function teleportBehind(distance)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if target and target:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.HumanoidRootPart
        local behindPos = targetRoot.Position - (targetRoot.CFrame.LookVector * distance)
        char.HumanoidRootPart.CFrame = CFrame.new(behindPos)
    end
end

local function startHook()
    if oldHook then return end
    oldHook = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        local result = oldHook(self, ...)
        if method == "FireServer" then
            pcall(function()
                if #args >= 1 and type(args[1]) == "table" then
                    local data = args[1]
                    if skillTele and data["Request"] == "Skill" and data["Number"] == "2" then
                        task.spawn(function() teleportBehind(1) end)
                    end
                    if m1Tele and data["Request"] == "M1Up" then
                        task.spawn(function() teleportBehind(3) end)
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

CreateToggle("Skill Tele ⚡", false, function(s)
    skillTele = s
    if s or m1Tele then startHook() else stopHook() end
end)

CreateToggle("M1 Tele 😈", false, function(s)
    m1Tele = s
    if s or skillTele then startHook() else stopHook() end
end)
--[==[ GACF VIP - PHẦN 3/3 ]==]
local btn = Instance.new("ImageButton")
btn.Name = "ToggleButton"
btn.Size = UDim2.new(0,50,0,50)
btn.Position = UDim2.new(0,20,0.5,-25)
btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
btn.BackgroundTransparency = 0
btn.Image = ""
btn.Parent = gui
Instance.new("UICorner",btn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke",btn).Color = C.Border
Instance.new("UIStroke",btn).Thickness = 2

local btxt = Instance.new("TextLabel")
btxt.Size = UDim2.new(1,0,1,0)
btxt.BackgroundTransparency = 1
btxt.Text = "VIP"
btxt.TextColor3 = C.Border
btxt.Font = Enum.Font.GothamBold
btxt.TextSize = 14
btxt.TextScaled = false
btxt.Parent = btn

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1.3,0,1.3,0)
glow.Position = UDim2.new(-0.15,0,-0.15,0)
glow.BackgroundColor3 = C.Border
glow.BackgroundTransparency = 0.8
glow.Parent = btn
Instance.new("UICorner",glow).CornerRadius = UDim.new(1,0)

local open = false
btn.MouseButton1Click:Connect(function()
    open = not open
    main.Visible = open
end)

local dragging = false
local touchPos = nil

btn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        touchPos = Vector2.new(i.Position.X, i.Position.Y)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local p = Vector2.new(i.Position.X, i.Position.Y)
        if touchPos then
            local delta = p - touchPos
            touchPos = p
            local vs = workspace.CurrentCamera.ViewportSize
            local fs = btn.AbsoluteSize
            local nx = math.clamp(btn.Position.X.Offset + delta.X, 0, vs.X - fs.X)
            local ny = math.clamp(btn.Position.Y.Offset + delta.Y, 0, vs.Y - fs.Y)
            btn.Position = UDim2.new(0, nx, 0, ny)
        end
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        touchPos = nil
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
    pcall(function()
        stopHook()
        target = nil
        clearAllHP()
    end)
end)

player.CharacterAdded:Connect(function()
    pcall(function()
        target = nil
        clearAllHP()
    end)
end)

game:BindToClose(function()
    pcall(clearAllHP)
end)

print("GACF VIP Loaded Successfully!")
