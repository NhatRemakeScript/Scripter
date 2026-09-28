local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Toggles = Library.Toggles
local Options = Library.Options

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local Run = game:GetService("RunService")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local FG = "Rod"
local RG = "ReelCounterGui"
local IL = {"desert","fossil","jungle","snow","starter","volcano"}
local SK = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}

local W = Library:CreateWindow({Title="FM-DNHUB",Footer="Obsidian",Icon=6687255998,NotifySide="Right",ShowCustomCursor=true,AutoShow=true})
local Main = W:AddTab("Chính","user")
local Tele = W:AddTab("Dịch chuyển","map-pin")
local Plr = W:AddTab("Người chơi","user")
local MG = Main:AddGroupbox({Side="Left",Name="Tự động",IconName="boxes"})
local SG2 = Main:AddGroupbox({Side="Right",Name="Bán cá",IconName="dollar-sign"})
local IG = Main:AddGroupbox({Side="Right",Name="Thông tin",IconName="info"})
local TG = Tele:AddGroupbox({Side="Left",Name="Đảo",IconName="map-pin"})
local PG2 = Plr:AddGroupbox({Side="Left",Name="Người chơi",IconName="user"})

local st = {fish=false,bypass=false,skill=false,sell=false,speed=false,hname=false,autoSellFull=false}
local island = "snow"
local sellInt = 300
local plat = nil
local uiS = {L=nil,R=nil,U=nil}

LP.Idled:Connect(function() pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end)
task.spawn(function()
    while true do pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) task.wait(30) end
end)

local pkt = RS:WaitForChild("Stardust"):WaitForChild("Packages"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local cnt, synced = 0, false

pcall(function()
    local mt = getrawmetatable(pkt)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        if self == pkt and getnamecallmethod() == "FireServer" then
            for _, v in ipairs({...}) do
                if typeof(v) == "buffer" and buffer.len(v) >= 2 then cnt = buffer.readu8(v, 1) synced = true end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

task.spawn(function()
    local t = tick()
    while not synced and tick() - t < 15 do task.wait(0.1) end
end)

local function sendPkt(op, pl)
    cnt = (cnt + 1) % 256
    local len = 2 + (pl and #pl or 0)
    local b = buffer.create(len)
    buffer.writeu8(b, 0, string.byte(op))
    buffer.writeu8(b, 1, cnt)
    if pl then for i = 1, #pl do buffer.writeu8(b, 1 + i, pl[i]) end end
    pcall(function() pkt:FireServer(b) end)
end

local function countBP()
    local bp = LP:FindFirstChild("Backpack")
    if not bp then return -1 end
    local c = 0
    for _, ch in ipairs(bp:GetChildren()) do
        if not string.find(string.lower(ch.Name), "rod") then c = c + 1 end
    end
    return c
end

local function setupLeaderstats()
    local stats = LP:FindFirstChild("leaderstats")
    if not stats then
        stats = Instance.new("Folder")
        stats.Name = "leaderstats"
        stats.Parent = LP
    end
    if not stats:FindFirstChild("Fish") then
        local f = Instance.new("IntValue"); f.Name = "Fish"; f.Parent = stats
    end
    if not stats:FindFirstChild("Slot") then
        local s = Instance.new("IntValue"); s.Name = "Slot"; s.Parent = stats
    end
    return stats
end

task.spawn(function()
    task.wait(1)
    local stats = setupLeaderstats()
    while true do
        local n = countBP()
        stats.Fish.Value = (n >= 0) and n or 0
        stats.Slot.Value = 50
        task.wait(2)
    end
end)

local function createPlat()
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if plat and plat.Parent then plat:Destroy() end
        local p = Instance.new("Part")
        p.Name = "FishPlat"
        p.Size = Vector3.new(15, 1, 15)
        p.Position = h.Position - Vector3.new(0, 3.5, 0)
        p.Anchored = true
        p.CanCollide = true
        p.Transparency = 1
        p.CanQuery = false
        p.CanTouch = false
        p.Parent = workspace
        plat = p
        h.CFrame = CFrame.new(p.Position + Vector3.new(0, 3.5, 0)) * (h.CFrame - h.CFrame.Position)
    end)
end

local function removePlat()
    pcall(function() if plat and plat.Parent then plat:Destroy() end plat = nil end)
end

local function hasBtn()
    local f = false
    pcall(function()
        for _, g in ipairs(PG:GetChildren()) do
            if g:IsA("ScreenGui") and g.Enabled and g.Name == FG then
                for _, d in ipairs(g:GetDescendants()) do
                    if d.Name == "FishingActionButton" and d:IsA("ImageButton") and d.Visible then f = true end
                end
            end
        end
    end)
    return f
end

local function clickHold(d)
    pcall(function()
        local v = workspace.CurrentCamera.ViewportSize
        VIM:SendMouseButtonEvent(v.X/2, v.Y/2, 0, true, game, 0)
        task.wait(d or 0.7)
        VIM:SendMouseButtonEvent(v.X/2, v.Y/2, 0, false, game, 0)
    end)
end

local function clickQuick()
    pcall(function()
        local v = workspace.CurrentCamera.ViewportSize
        VIM:SendMouseButtonEvent(v.X/2, v.Y/2, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(v.X/2, v.Y/2, 0, false, game, 0)
    end)
end

local function sendKey(k)
    pcall(function()
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, k, false, game)
    end)
end

local function vis(i)
    if not i.Visible or i.AbsoluteSize.X <= 0 or i.AbsoluteSize.Y <= 0 then return false end
    local p = i.Parent
    while p and p ~= game do
        if p:IsA("ScreenGui") and not p.Enabled then return false end
        if p:IsA("GuiObject") and (not p.Visible or p.AbsoluteSize.X <= 0 or p.AbsoluteSize.Y <= 0) then return false end
        if p:IsA("CanvasGroup") and p.GroupTransparency >= 1 then return false end
        p = p.Parent
    end
    return true
end

local function scanMini()
    local tg
    for _, g in ipairs(PG:GetChildren()) do if g:IsA("ScreenGui") and g.Name == RG then tg = g break end end
    if not tg then return end
    local f = {L=false,R=false,U=false}
    pcall(function()
        for _, d in ipairs(tg:GetDescendants()) do
            if d:IsA("GuiObject") and vis(d) then
                if d.Name == "Left" then f.L = true
                elseif d.Name == "Right" then f.R = true
                elseif d.Name == "Up" then f.U = true end
            end
        end
    end)
    local n = tick()
    if f.L then if not uiS.L then uiS.L = n end if n - uiS.L >= 0.2 then sendKey(Enum.KeyCode.A) uiS.L = nil end else uiS.L = nil end
    if f.R then if not uiS.R then uiS.R = n end if n - uiS.R >= 0.2 then sendKey(Enum.KeyCode.D) uiS.R = nil end else uiS.R = nil end
    if f.U then if not uiS.U then uiS.U = n end if n - uiS.U >= 0.2 then sendKey(Enum.KeyCode.W) uiS.U = nil end else uiS.U = nil end
end

local function startBypass()
    task.spawn(function() while st.bypass do scanMini() task.wait(0.05) end end)
end

local function saveCharState()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return nil end
    local state = {
        cframe = h.CFrame,
        velocity = h.AssemblyLinearVelocity,
        angular = h.AssemblyAngularVelocity,
        rotVelocity = h.RotVelocity,
        autoRotate = hum.AutoRotate,
        platformStand = hum.PlatformStand,
        walkSpeed = hum.WalkSpeed,
        jumpPower = hum.JumpPower,
        humanoidState = hum:GetState(),
        collideStates = {},
    }
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then state.collideStates[p] = p.CanCollide end
    end
    return state
end

local function restoreCharState(state)
    if not state then return end
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    h.CFrame = state.cframe
    h.AssemblyLinearVelocity = state.velocity
    h.AssemblyAngularVelocity = state.angular
    h.RotVelocity = state.rotVelocity
    hum.AutoRotate = state.autoRotate
    hum.PlatformStand = state.platformStand
    hum.WalkSpeed = state.walkSpeed
    hum.JumpPower = state.jumpPower
    pcall(function() hum:ChangeState(state.humanoidState) end)
    for part, cc in pairs(state.collideStates) do
        if part and part.Parent then part.CanCollide = cc end
    end
end

local function tweenTo(cf, speed)
    speed = speed or 100
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local saved = saveCharState()
        hum.AutoRotate = false
        hum.PlatformStand = true
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        local sCF = h.CFrame
        local sRot = sCF - sCF.Position
        local sPos = sCF.Position
        local tPos = cf.Position
        local dist = (tPos - sPos).Magnitude
        if dist < 1 then
            h.CFrame = CFrame.new(tPos) * sRot
            if saved then
                saved.cframe = CFrame.new(tPos) * sRot
                saved.velocity = Vector3.zero
                saved.angular = Vector3.zero
                saved.rotVelocity = Vector3.zero
            end
            restoreCharState(saved)
            return
        end
        local nc
        nc = Run.Stepped:Connect(function()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        local dur = dist / speed
        local stk = tick()
        while tick() - stk < dur do
            local c2 = LP.Character
            if not c2 then break end
            local h2 = c2:FindFirstChild("HumanoidRootPart")
            if not h2 then break end
            local a = math.clamp((tick() - stk) / dur, 0, 1)
            h2.CFrame = CFrame.new(sPos:Lerp(tPos, a)) * sRot
            h2.AssemblyLinearVelocity = Vector3.zero
            h2.AssemblyAngularVelocity = Vector3.zero
            h2.RotVelocity = Vector3.zero
            task.wait(0.03)
        end
        if nc then nc:Disconnect() end
        local c3 = LP.Character
        if c3 then
            local h3 = c3:FindFirstChild("HumanoidRootPart")
            if h3 then h3.CFrame = CFrame.new(tPos) * sRot end
        end
        if saved then
            saved.cframe = CFrame.new(tPos) * sRot
            saved.velocity = Vector3.zero
            saved.angular = Vector3.zero
            saved.rotVelocity = Vector3.zero
        end
        restoreCharState(saved)
    end)
end

local skillT
local function startSkill()
    if skillT then task.cancel(skillT); skillT = nil end
    skillT = task.spawn(function()
        while st.fish and st.skill do
            for _, k in ipairs(SK) do
                if not (st.fish and st.skill) then break end
                sendKey(k)
            end
            task.wait(0.2)
        end
        skillT = nil
    end)
end

local function startFish()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 0
        LP.Character.Humanoid.JumpPower = 0
    end
    createPlat()
    task.spawn(function()
        while st.fish do
            pcall(function()
                local c = LP.Character
                if c and plat and plat.Parent then
                    local h = c:FindFirstChild("HumanoidRootPart")
                    if h then plat.Position = Vector3.new(h.Position.X, plat.Position.Y, h.Position.Z) end
                end
            end)
            task.wait(0.5)
        end
    end)
    task.spawn(function()
        while st.fish do
            while not hasBtn() and st.fish do task.wait(0.05) end
            if not st.fish then break end
            task.wait(0.3)
            clickHold(0.7)
            while not hasBtn() and st.fish do task.wait(0.05) end
            if not st.fish then break end
            task.wait(0.3)
            clickQuick()
            while hasBtn() and st.fish do task.wait(0.05) end
            if not st.fish then break end
            task.wait(1)
            clickQuick()
        end
    end)
    if st.skill then startSkill() end
end

local function stopFish()
    removePlat()
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = st.speed and 40 or 16 h.JumpPower = 50 end
    end)
end

local function findNPC()
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local mp = c.HumanoidRootPart.Position
    local best, bd = nil, math.huge
    for _, o in ipairs(workspace:GetDescendants()) do
        local n = string.lower(o.Name)
        if string.find(n, "seller") or string.find(n, "fish_seller") or string.find(n, "fishseller") then
            local p
            if o:IsA("Model") then p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            elseif o:IsA("BasePart") then p = o end
            if p then
                local d = (mp - p.Position).Magnitude
                if d < bd then bd = d best = p end
            end
        end
    end
    return best
end

local function doSell()
    if not synced then
        local s = tick()
        while not synced and tick() - s < 3 do task.wait(0.05) end
    end
    local wasFish = st.fish
    if wasFish then st.fish = false removePlat() task.wait(0.3) end
    pcall(function()
        local c = LP.Character
        if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then t.Parent = LP:FindFirstChild("Backpack") end end end
    end)
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then
        if wasFish then st.fish = true; startFish() end
        return false
    end
    local oldCF = c.HumanoidRootPart.CFrame
    local npc = findNPC()
    if not npc then
        Library:Notify({Title="Bán cá",Description="Không tìm thấy NPC",Time=3})
        if wasFish then st.fish = true; startFish() end
        return false
    end

    tweenTo(CFrame.new(npc.Position + Vector3.new(0, 3, 5)), 100)

    for i = 1, 5 do sendPkt("Z") task.wait(0.1) end
    task.wait(0.2)
    sendPkt("d")
    task.wait(0.2)
    sendPkt("d")
    task.wait(0.2)
    sendPkt("a", {0x01})
    task.wait(0.3)

    tweenTo(oldCF, 100)

    task.wait(0.3)
    sendKey(Enum.KeyCode.One)
    task.wait(0.2)
    if wasFish then st.fish = true; startFish() end
    Library:Notify({Title="Bán cá",Description="Đã bán xong!",Time=2})
    return true
end

local function startSell()
    task.spawn(function()
        while st.sell do
            for i = sellInt, 1, -1 do if not st.sell then break end task.wait(1) end
            if not st.sell then break end
            doSell()
            task.wait(1)
        end
    end)
end

local function startAutoSellFull()
    task.spawn(function()
        while st.autoSellFull do
            if countBP() >= 50 then
                Library:Notify({Title="Bán cá",Description="Kho đầy, đang bán...",Time=2})
                doSell()
                task.wait(2)
            end
            task.wait(2)
        end
    end)
end

local function findIsland(n)
    local t = "island_" .. n
    for _, o in ipairs(workspace:GetDescendants()) do if string.lower(o.Name) == t then return o end end
end

local function findSpawn(i)
    if not i then return nil end
    for _, d in ipairs(i:GetDescendants()) do if d:IsA("SpawnLocation") then return d end end
    for _, d in ipairs(i:GetDescendants()) do if d:IsA("BasePart") and string.find(string.lower(d.Name), "spawn") then return d end end
    if i:IsA("Model") and i.PrimaryPart then return i.PrimaryPart end
    for _, d in ipairs(i:GetChildren()) do if d:IsA("BasePart") then return d end end
end

local function teleIsland(n)
    local i = findIsland(n)
    if not i then Library:Notify({Title="Dịch chuyển",Description="Không tìm thấy island_"..n,Time=3}) return end
    local sp = findSpawn(i)
    if not sp then Library:Notify({Title="Dịch chuyển",Description="Không có spawn",Time=3}) return end
    tweenTo(CFrame.new(sp.Position + Vector3.new(0, 5, 0)), 100)
    task.wait(0.3)
    sendKey(Enum.KeyCode.One)
    task.wait(0.2)
    Library:Notify({Title="Dịch chuyển",Description="Đã tới island_"..n,Time=2})
end

local hnR = false
local hnC = {}
local function applyHN()
    pcall(function()
        local n = LP.Name
        local function sc(c)
            for _, o in ipairs(c:GetDescendants()) do
                if o:IsA("TextLabel") and (o.Text == n or o.Text == "@" .. n) then
                    if not hnC[o] then hnC[o] = {t=o.Text, v=o.Visible, tr=o.TextTransparency} end
                    if st.hname then o.Text = "" o.Visible = false o.TextTransparency = 1
                    else o.Text = hnC[o].t o.Visible = hnC[o].v o.TextTransparency = hnC[o].tr end
                end
            end
        end
        sc(workspace)
        for _, g in ipairs(PG:GetChildren()) do if g:IsA("ScreenGui") then sc(g) end end
    end)
end
local function startHN()
    if hnR then return end
    hnR = true
    task.spawn(function() while st.hname do applyHN() task.wait(0.3) end hnR = false end)
end
local function restoreHN()
    for o, d in pairs(hnC) do pcall(function() if o and o.Parent then o.Text = d.t o.Visible = d.v o.TextTransparency = d.tr end end) end
    hnC = {}
end

MG:AddToggle("Fish", {Text="Tự động câu", Default=false, Callback=function(v) st.fish=v if v then startFish() else stopFish() end end})
MG:AddToggle("Skill", {Text="Tự động kỹ năng", Default=false, Callback=function(v) st.skill=v if v and st.fish then startSkill() end end})
MG:AddToggle("Bypass", {Text="Vượt Minigame", Default=false, Callback=function(v) st.bypass=v if v then startBypass() end end})

SG2:AddToggle("Sell", {Text="Tự động bán", Default=false, Callback=function(v) st.sell=v if v then startSell() end end})
SG2:AddToggle("AutoSellFull", {Text="Bán nếu đầy kho (50/50)", Default=false, Callback=function(v) st.autoSellFull=v if v then startAutoSellFull() end end})
SG2:AddSlider("SellInt", {Text="Thời gian (giây)", Default=300, Min=30, Max=3600, Rounding=0, Compact=false, Callback=function(v) sellInt=v end})
SG2:AddButton("SellNow", {Text="BÁN NGAY", Func=function() task.spawn(doSell) end})

local bpLabelObj = IG:AddLabel("BpCount", {Text = "Ba lô: --/50", DoesLoop = false})

task.spawn(function()
    while true do
        local n = countBP()
        if n < 0 then
            bpLabelObj:Set("Ba lô: --/50")
        else
            bpLabelObj:Set("Ba lô: " .. n .. "/50")
        end
        task.wait(2)
    end
end)

TG:AddDropdown("Island", {Text="Chọn đảo", Values=IL, Default=1, Multi=false, Callback=function(v) island=v end})
TG:AddButton("Tele", {Text="DỊCH CHUYỂN", Func=function() teleIsland(island) end})

PG2:AddToggle("Speed", {Text="Tốc độ (40)", Default=false, Callback=function(v) st.speed=v if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v and 40 or 16 end end})
PG2:AddToggle("HName", {Text="Ẩn tên", Default=false, Callback=function(v) st.hname=v if v then startHN() else restoreHN() end end})
PG2:AddButton("Kill", {Text="Tắt Menu", Func=function()
    st.fish=false st.bypass=false st.skill=false st.sell=false st.speed=false st.hname=false st.autoSellFull=false
    removePlat()
    if skillT then task.cancel(skillT); skillT=nil end
    restoreHN()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed=16 LP.Character.Humanoid.JumpPower=50
    end
    Library:Unload()
end})

LP.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid")
    task.wait(0.5)
    if st.speed then c.Humanoid.WalkSpeed=40 end
    if st.fish then startFish() end
end)

Library:Notify({Title="FM-DNHUB",Description="Đã load thành công!",Time=5})