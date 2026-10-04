local LOGO_ASSET_ID = "97143806525012"
local LOGO_URL = "rbxassetid://" .. LOGO_ASSET_ID

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Collection = game:GetService("CollectionService")
local Pathfinding = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local C = {
    ISLAND_ORDER = {"starter","jungle","desert","snow","volcano","fossil"},
    ISLAND_DISPLAY = {"Starter","Jungle","Desert","Snow","Volcano","Fossil"},
    ISLAND_LABELS = {starter="Starter", jungle="Jungle", desert="Desert", snow="Snow", volcano="Volcano", fossil="Fossil"},
    ISLAND_IDS = {starter="island_starter", jungle="island_jungle", desert="island_desert", snow="island_snow", volcano="island_volcano", fossil="island_fossil"},
    MAIN_PARTS = {"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"},
    FISH_CAPACITY = 50,
    BOSS_TWEEN_SPEED = 36,
    EVENT_NAMES = {Rain=true, Rain2=true, rainbow=true, ParticleEmitter=true},
    BOAT_SPEED = {truck = 50, red_truck = 100},
}

local S = {
    fish=false, skill=false, bypass=false,
    sell=false, autoSellFull=false, useWalk=false,
    speed=36, speedOn=false,
    fakename=false, esp=false,
    bossEsp1=true, bossEsp2=true,
    autoLock=false,
    lockRarity={Legendary=true, Mythical=true, Divine=true},
    skillOrder={1,2,1,3},
    sellInt=300, island="starter",
    customName="DNHub 3.0",
    autoBoss=false,
    antiAfk=true, antiAfkInterval=50, antiAfkKey="F13",
    castHold=0.65, tapHold=0.045, firstPullTarget=0.96,
    qteDelay=0.2, skillSpacing=0.35, equipDelay=0.35,
    returnAfterSell=true, sellTravelMode="Tween",
    boat="truck",
}

local Fish = {dead=false, running=false, farm=false, paused=false, firstPullDone=false, lastState=nil, lastCast=0, lastSkill=0, lastEquip=0}
local SellBusy = false
local Tweening = false
local Traveling = false
local NCStore, NCHold = {}, nil
local ESPFolder, ESPGuis, RainbowTask = nil, {}, nil
local uiS = {L=nil,R=nil,U=nil}
local Client, Catalog, RarityEnums, SellEnums, FishingConfig, PullBarMath, FishStorageRules

pcall(function()
    local sd = RS:FindFirstChild("Stardust")
    if sd then
        local c = sd:FindFirstChild("Client")
        if c then Client = require(c) end
    end
    local data = RS:FindFirstChild("Data")
    local cat = data and data:FindFirstChild("Catalog")
    if cat then Catalog = require(cat) end
    local enums = data and data:FindFirstChild("Enums")
    if enums then
        local r = enums:FindFirstChild("RarityEnums")
        local s = enums:FindFirstChild("SellEnums")
        if r then RarityEnums = require(r) end
        if s then SellEnums = require(s) end
    end
    local cfg = data and data:FindFirstChild("Config")
    if cfg then
        local f = cfg:FindFirstChild("FishingConfig")
        if f then FishingConfig = require(f) end
    end
    local shared = RS:FindFirstChild("Shared")
    local lib = shared and shared:FindFirstChild("Lib")
    if lib then
        local p = lib:FindFirstChild("PullBarMath")
        if p then PullBarMath = require(p) end
        local fs = lib:FindFirstChild("FishStorageRules")
        if fs then FishStorageRules = require(fs) end
    end
end)

local RarityPriority = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythical=6,Divine=7,Secret=8,Exotic=9,Huge=10}

local function getController(name)
    if Client and type(Client.GetController) == "function" then
        local ok, c = pcall(function() return Client.GetController(name) end)
        if ok then return c end
    end
    return nil
end

local function lc()
    local c = LP.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChildOfClass("Humanoid")
    if r and h and h.Health > 0 then return c, r, h end
end

local function fetchProfile()
    local data = getController("PlayerDataV2Controller")
    if not data then return nil end
    local ok, profile = pcall(function() return data:Fetch() end)
    if ok and type(profile) == "table" then return profile end
    ok, profile = pcall(function() return data:Fetch(LP) end)
    if ok and type(profile) == "table" then return profile end
    return nil
end

local function heldRodId()
    local c = LP.Character
    if not c then return nil end
    for _, child in ipairs(c:GetChildren()) do
        if child:IsA("Tool") and Catalog and Catalog.Rod and Catalog.Rod.GetById and Catalog.Rod.GetById(child.Name) then
            return child.Name
        end
    end
    return nil
end

local function rodScore(rodId)
    if not (Catalog and Catalog.Rod and Catalog.Rod.GetById) then return nil end
    local cat = Catalog.Rod.GetById(rodId)
    if not cat then return nil end
    local dmg, luck = 0, 0
    for _, s in ipairs(cat.stats or {}) do
        if s.stat == "attackDamage" then dmg += s.value or 0
        elseif s.stat == "luck" then luck += s.value or 0 end
    end
    return dmg * 1e6 + luck * 1e3 + (cat.skillSlots or 0) * 10 + (RarityPriority[cat.rarity] or 0)
end

local function bestRodId(profile)
    local bestId, bestScore
    for rodId in pairs(profile.Rods or {}) do
        local s = rodScore(rodId)
        if s and (not bestScore or s > bestScore) then bestId, bestScore = rodId, s end
    end
    return bestId
end

local function hasRodTool(rodId)
    local bp = LP:FindFirstChildOfClass("Backpack")
    return bp ~= nil and bp:FindFirstChild(rodId) ~= nil
end

local function equipRod(rodId)
    local backpack = getController("BackpackController")
    local held = getController("HeldToolController")
    if not backpack or not held or not held:IsInputEnabled() then return false end
    local predicted = held:PredictEquipByName(rodId)
    backpack.EquipByName:Fire(rodId, predicted)
    return true
end

local function equipAnyRod()
    local profile = fetchProfile()
    if type(profile) ~= "table" or type(profile.Rods) ~= "table" then return false end
    local best = bestRodId(profile)
    if not best or not hasRodTool(best) then return false end
    return equipRod(best)
end

local function isRodItem(item)
    return string.lower(item.Name):find("rod") ~= nil
end

local function countFishInBackpack()
    local bp = LP:FindFirstChildOfClass("Backpack")
    if not bp then return 0, 0, 0 end
    local total, fish, rods = 0, 0, 0
    for _, item in ipairs(bp:GetChildren()) do
        total = total + 1
        if isRodItem(item) then rods = rods + 1 else fish = fish + 1 end
    end
    return fish, total, rods
end

local SkillQueue = {}
local SkillOrderSet = {1,2,1,3}

local function reloadSkillQueue()
    SkillQueue = {}
    for _, v in ipairs(SkillOrderSet) do table.insert(SkillQueue, v) end
end

local function nextSkillSlot()
    if #SkillQueue == 0 then reloadSkillQueue() end
    return table.remove(SkillQueue, 1)
end

local SlotPhase = {}

local function markSlotCasting(slotName, skillId)
    local entry = SlotPhase[slotName]
    if type(entry) ~= "table" then return end
    entry.phase = "Casting"
    entry.remaining = 0
    local skill = skillId and Catalog and Catalog.Skill and Catalog.Skill.GetById and Catalog.Skill.GetById(skillId)
    entry.localReadyAt = os.clock() + (skill and (skill.cooldown or 0) or 0)
end

local function slotReady(slotName)
    local entry = SlotPhase[slotName]
    if type(entry) ~= "table" then return true end
    if entry.phase == "Ready" then return true end
    if entry.localReadyAt and os.clock() >= entry.localReadyAt then return true end
    return false
end

local function equippedSkillIds()
    local profile = fetchProfile()
    if not profile then return {} end
    local rodId = profile.RodEquip
    local entry = rodId and profile.Rods and profile.Rods[rodId]
    local slots = entry and entry.BookSlots
    local out = {}
    if type(slots) ~= "table" then return out end
    for i = 1, 4 do
        local sid = slots["Slot"..i]
        if type(sid) == "string" and sid ~= "" then out[i] = sid end
    end
    return out
end

local function useSkill(idx)
    local kb = getController("KeybindsController")
    local bind = kb and kb.Keys and kb.Keys["Slot"..idx]
    local cb = bind and bind.callback
    if type(cb) ~= "function" then return false end
    cb(false)
    markSlotCasting("Slot"..idx, equippedSkillIds()[idx])
    return true
end

local function castSkill()
    local ids = equippedSkillIds()
    local tries = 0
    local maxTries = #SkillOrderSet
    while tries < maxTries do
        tries = tries + 1
        local slot = nextSkillSlot()
        if slot and ids[slot] and slotReady("Slot"..slot) then
            if useSkill(slot) then return true end
        end
    end
    return false
end

local function saveState()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hu = c:FindFirstChildOfClass("Humanoid")
    if not h or not hu then return nil end
    local s = {cframe=h.CFrame, ar=hu.AutoRotate, ps=hu.PlatformStand, ws=hu.WalkSpeed, jp=hu.JumpPower, hs=hu:GetState(), cc={}}
    for _, name in ipairs(C.MAIN_PARTS) do
        local p = c:FindFirstChild(name)
        if p and p:IsA("BasePart") then s.cc[p] = p.CanCollide end
    end
    return s
end

local function hardRestore(savedCharacter, saved)
    local cur = LP.Character
    if not cur then return end
    if saved and saved.cc then
        for p, cc in pairs(saved.cc) do
            if p and p.Parent then pcall(function() p.CanCollide = cc end) end
        end
    end
    local curHu = cur:FindFirstChildOfClass("Humanoid")
    if curHu then
        if saved then
            curHu.AutoRotate = saved.ar
            curHu.PlatformStand = saved.ps
            curHu.WalkSpeed = saved.ws
            curHu.JumpPower = saved.jp
            pcall(function() curHu:ChangeState(saved.hs) end)
        else
            curHu.AutoRotate = true
            curHu.PlatformStand = false
            curHu.WalkSpeed = 16
            curHu.JumpPower = 50
        end
    end
end

local function tweenTo(cf, spd)
    spd = spd or 40
    if Tweening then
        local timeout = tick() + 15
        while Tweening and tick() < timeout do task.wait(0.05) end
        if Tweening then Tweening = false end
    end
    Tweening = true
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hu = c:FindFirstChildOfClass("Humanoid")
        if not h or not hu then return end
        local savedCharacter = c
        local saved = saveState()
        hu.AutoRotate = false
        hu.PlatformStand = true
        hu:ChangeState(Enum.HumanoidStateType.Physics)
        local sCF = h.CFrame
        local sR = sCF - sCF.Position
        local sP = sCF.Position
        local tP = cf.Position
        local dist = (tP - sP).Magnitude
        if dist < 1 then
            h.CFrame = CFrame.new(tP) * sR
            hardRestore(savedCharacter, saved)
            return
        end
        local nc = RunService.Stepped:Connect(function()
            local cur = LP.Character
            if cur and cur == savedCharacter then
                for _, name in ipairs(C.MAIN_PARTS) do
                    local p = cur:FindFirstChild(name)
                    if p and p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        local dur = dist / spd
        local stk = tick()
        while tick() - stk < dur do
            local c2 = LP.Character
            if not c2 or c2 ~= savedCharacter then break end
            local h2 = c2:FindFirstChild("HumanoidRootPart")
            if not h2 then break end
            local a = math.clamp((tick() - stk) / dur, 0, 1)
            h2.CFrame = CFrame.new(sP:Lerp(tP, a)) * sR
            h2.AssemblyLinearVelocity = Vector3.zero
            h2.AssemblyAngularVelocity = Vector3.zero
            h2.RotVelocity = Vector3.zero
            task.wait(0.03)
        end
        if nc then nc:Disconnect() end
        local c3 = LP.Character
        if c3 and c3 == savedCharacter then
            local h3 = c3:FindFirstChild("HumanoidRootPart")
            if h3 then h3.CFrame = CFrame.new(tP) * sR end
        end
        hardRestore(savedCharacter, saved)
        task.wait(0.05)
        hardRestore(savedCharacter, saved)
        task.wait(0.15)
        hardRestore(savedCharacter, saved)
    end)
    Tweening = false
end

local function dismissLootPopup()
    local f = getController("FishingController")
    if f then
        local ok = pcall(function()
            if type(f.DismissLoot) == "function" then f:DismissLoot() return true end
            if type(f.SkipLoot) == "function" then f:SkipLoot() return true end
            if type(f.CloseLoot) == "function" then f:CloseLoot() return true end
        end)
        if ok then return true end
    end
    local keywords = {"skip", "continue", "close", "dismiss", "confirm", "ok", "next"}
    for _, g in ipairs(PG:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled then
            for _, d in ipairs(g:GetDescendants()) do
                if d:IsA("TextButton") or d:IsA("ImageButton") then
                    local n = string.lower(d.Name)
                    for _, kw in ipairs(keywords) do
                        if n:find(kw) then
                            pcall(function()
                                for _, conn in ipairs(getconnections(d.Activated) or {}) do conn:Fire() end
                                for _, conn in ipairs(getconnections(d.MouseButton1Click) or {}) do conn:Fire() end
                            end)
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function walkTo(goal, stopAt, timeout, alive)
    local c = LP.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not (h and r) or h.Health <= 0 then return false end
    if alive and not alive() then return false end
    local deadline = os.clock() + (timeout or 25)
    local waypoints = {{Position = goal}}
    pcall(function()
        local path = Pathfinding:CreatePath({AgentCanJump=true, WaypointSpacing=6})
        path:ComputeAsync(r.Position, goal)
        if path.Status == Enum.PathStatus.Success then
            local pts = path:GetWaypoints()
            if #pts > 0 then waypoints = pts end
        end
    end)
    local wi = 1
    local lastPos = r.Position
    local still = 0
    h:MoveTo(waypoints[wi].Position)
    while os.clock() < deadline do
        task.wait(0.1)
        local live = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not live or LP.Character ~= c or h.Health <= 0 then break end
        if alive and not alive() then break end
        if (live.Position - goal).Magnitude <= (stopAt or 2) then
            h:MoveTo(live.Position)
            return true
        end
        if wi < #waypoints and (live.Position - waypoints[wi].Position).Magnitude <= 3 then
            wi += 1
            h:MoveTo(waypoints[wi].Position)
        end
        if (live.Position - lastPos).Magnitude < 0.3 then still += 0.1 else still = 0 lastPos = live.Position end
        if still >= 0.8 then still = 0 h:MoveTo(waypoints[wi].Position) end
    end
    if h.Parent then h:MoveTo(r.Position) end
    return false
end

local function vis(i)
    if not i.Visible or i.AbsoluteSize.X<=0 or i.AbsoluteSize.Y<=0 then return false end
    local p = i.Parent
    while p and p~=game do
        if p:IsA("ScreenGui") and not p.Enabled then return false end
        if p:IsA("GuiObject") and (not p.Visible or p.AbsoluteSize.X<=0 or p.AbsoluteSize.Y<=0) then return false end
        if p:IsA("CanvasGroup") and p.GroupTransparency>=1 then return false end
        p = p.Parent
    end
    return true
end

local function sKey(k)
    pcall(function()
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, k, false, game)
    end)
end

local function scanMini()
    local tg
    for _, g in ipairs(PG:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name=="ReelCounterGui" then tg=g break end
    end
    if not tg then return end
    local f = {L=false,R=false,U=false}
    pcall(function()
        for _, d in ipairs(tg:GetDescendants()) do
            if d:IsA("GuiObject") and vis(d) then
                if d.Name=="Left" then f.L=true
                elseif d.Name=="Right" then f.R=true
                elseif d.Name=="Up" then f.U=true end
            end
        end
    end)
    local n = tick()
    if f.L then if not uiS.L then uiS.L=n end if n-uiS.L>=S.qteDelay then sKey(Enum.KeyCode.A) uiS.L=nil end else uiS.L=nil end
    if f.R then if not uiS.R then uiS.R=n end if n-uiS.R>=S.qteDelay then sKey(Enum.KeyCode.D) uiS.R=nil end else uiS.R=nil end
    if f.U then if not uiS.U then uiS.U=n end if n-uiS.U>=S.qteDelay then sKey(Enum.KeyCode.W) uiS.U=nil end else uiS.U=nil end
end

local function lastHandler(sig)
    local fn
    if not getconnections then return nil end
    for _, c in ipairs(getconnections(sig)) do fn = c.Function end
    return fn
end

local function press(action)
    local fn = action and lastHandler(action.Pressed)
    if fn then fn() end
end

local function release(action)
    local fn = action and lastHandler(action.Released)
    if fn then fn() end
end

local function tap(action, hold)
    press(action)
    task.wait(hold or S.tapHold)
    release(action)
end

local function findNPC()
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local mp = c.HumanoidRootPart.Position
    local best, bd = nil, math.huge
    for _, o in ipairs(workspace:GetDescendants()) do
        local lower = string.lower(o.Name)
        if lower:find("fish_seller") or lower:find("fishmerchant") or lower:find("npcfishseller") or lower:find("nana") or lower:find("seller") then
            local p
            if o:IsA("Model") then p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            elseif o:IsA("BasePart") then p = o end
            if p and o:FindFirstChildWhichIsA("ProximityPrompt", true) then
                local d = (mp - p.Position).Magnitude
                if d < bd then bd = d best = p end
            end
        end
    end
    return best
end

local function sellAll()
    local sell = getController("SellController")
    if not sell then return false, 0, 0 end
    local ok, status, coin, count = pcall(function() return sell:SellAll() end)
    if not ok then return false, 0, 0 end
    return true, coin or 0, count or 0
end

local function doSellFull()
    if SellBusy then return false end
    SellBusy = true
    local wasFarming = Fish.farm
    if wasFarming then Fish.paused = true end
    task.wait(0.8)
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then
        SellBusy = false
        if wasFarming then Fish.paused = false end
        return false
    end
    local oldCF = c.HumanoidRootPart.CFrame
    local npc = findNPC()
    for _ = 1, 15 do
        if npc then break end
        task.wait(0.3)
        npc = findNPC()
    end
    if not npc then
        WindUI:Notify({Title="Sell Fish", Content="No fish seller found", Duration=3})
        SellBusy = false
        if wasFarming then Fish.paused = false end
        return false
    end
    Tweening = false
    task.wait(0.1)
    local standPos = npc.Position + Vector3.new(0, 3, 5)
    local mode = S.sellTravelMode or "Tween"
    if mode == "Walk" then walkTo(standPos, 3, 30, function() return true end)
    elseif mode == "Instant" then
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(standPos) task.wait(0.4) end
    else tweenTo(CFrame.new(standPos)) end
    local waitDeadline = tick() + 12
    while Tweening and tick() < waitDeadline do task.wait(0.05) end
    task.wait(0.6)
    local ok, coin = sellAll()
    if S.returnAfterSell then
        local c2 = LP.Character
        if c2 and c2:FindFirstChild("HumanoidRootPart") then
            Tweening = false
            task.wait(0.1)
            if mode == "Walk" then walkTo(oldCF.Position, 3, 30, function() return true end)
            elseif mode == "Instant" then
                local root2 = c2:FindFirstChild("HumanoidRootPart")
                if root2 then root2.CFrame = oldCF task.wait(0.4) end
            else
                tweenTo(oldCF)
                local waitBack = tick() + 12
                while Tweening and tick() < waitBack do task.wait(0.05) end
            end
        end
    end
    task.wait(0.3)
    if wasFarming then Fish.paused = false end
    WindUI:Notify({Title="Sell Fish", Content= ok and ("Sold! +"..tostring(coin)) or "Sold!", Duration=2})
    SellBusy = false
    return true
end

local function startSell()
    task.spawn(function()
        while S.sell do
            for _=S.sellInt,1,-1 do if not S.sell then break end task.wait(1) end
            if not S.sell then break end
            doSellFull()
            task.wait(1)
        end
    end)
end

local autoFullTask = nil
local function startAutoFull()
    if autoFullTask then return end
    autoFullTask = task.spawn(function()
        while S.autoSellFull do
            task.wait(2)
            if not S.autoSellFull then break end
            if SellBusy then continue end
            local fish = countFishInBackpack()
            if fish >= C.FISH_CAPACITY then
                WindUI:Notify({Title="Sell Fish", Content=("Bag full (%d/%d)"):format(fish, C.FISH_CAPACITY), Duration=2})
                doSellFull()
                task.wait(3)
            end
        end
        autoFullTask = nil
    end)
end

local function applySpeed(v)
    S.speed = v
    if S.speedOn then
        local c = LP.Character
        local hu = c and c:FindFirstChildOfClass("Humanoid")
        if hu and hu.Health > 0 then hu.WalkSpeed = v end
    end
end

local function enableSpeed(on)
    S.speedOn = on
    local c = LP.Character
    local hu = c and c:FindFirstChildOfClass("Humanoid")
    if hu and hu.Health > 0 then hu.WalkSpeed = on and S.speed or 16 end
end

local function runFishLoop()
    Fish.running = true
    Fish.dead = false
    while not Fish.dead do
        if not Fish.farm then task.wait(0.2) continue end
        if Fish.paused then task.wait(0.1) continue end
        if Tweening then task.wait(0.1) continue end
        if SellBusy then task.wait(0.1) continue end
        if Traveling then task.wait(0.1) continue end
        if BossStepState and BossStepState.holding then task.wait(0.1) continue end
        if not LP.Character then task.wait(0.2) continue end
        if not heldRodId() and os.clock() - Fish.lastEquip >= S.equipDelay then
            Fish.lastEquip = os.clock()
            if equipAnyRod() then task.wait(S.equipDelay) end
        end
        local f = getController("FishingController")
        if not f then task.wait(0.25) continue end
        local ok, state = pcall(function() return f:GetState() end)
        if not ok then task.wait(0.1) continue end
        if state ~= Fish.lastState then
            if state == "FirstPull" then Fish.firstPullDone = false
            elseif state == "Caught" then
                reloadSkillQueue()
                task.spawn(function()
                    task.wait(0.15)
                    for _ = 1, 5 do
                        if not Fish.farm then break end
                        if dismissLootPopup() then break end
                        task.wait(0.3)
                    end
                end)
            elseif state == "Idling" then
                reloadSkillQueue()
            end
            Fish.lastState = state
        end
        if state == "Idling" then
            if os.clock() - Fish.lastCast >= 0.7 then
                Fish.lastCast = os.clock()
                local ctx = RS:FindFirstChild("Inputs")
                local fc = ctx and ctx:FindFirstChild("FishingContext")
                local action = fc and fc:FindFirstChild("FishingPrimary")
                if action then tap(action, S.castHold) end
            else task.wait(0.05) end
        elseif state == "FirstPull" then
            local okV, value = pcall(function() return f:GetPullBarValue() end)
            if okV and not Fish.firstPullDone and value >= S.firstPullTarget then
                Fish.firstPullDone = true
                local ctx = RS:FindFirstChild("Inputs")
                local fc = ctx and ctx:FindFirstChild("FishingContext")
                local action = fc and fc:FindFirstChild("FishingPrimary")
                if action then tap(action, S.tapHold) end
            else task.wait() end
        elseif state == "Reeling" then
            if S.skill and os.clock() - Fish.lastSkill >= S.skillSpacing and LP:GetAttribute("IsUsingSkill") ~= true then
                if castSkill() then Fish.lastSkill = os.clock() end
            end
            local okAuto, isAuto = pcall(function() return f:IsAutoSession() end)
            if okAuto and isAuto then task.wait(0.05)
            else
                local ctx = RS:FindFirstChild("Inputs")
                local fc = ctx and ctx:FindFirstChild("FishingContext")
                local action = fc and fc:FindFirstChild("FishingPrimary")
                if action then tap(action, S.tapHold) end
            end
        else task.wait(0.05) end
    end
    Fish.running = false
end

local minigameTask
local function startFish()
    Fish.farm = true
    Fish.paused = false
    reloadSkillQueue()
    if not Fish.running then task.spawn(runFishLoop) end
    if not minigameTask then
        minigameTask = task.spawn(function()
            while S.bypass or S.fish do
                scanMini()
                task.wait(0.05)
            end
            minigameTask = nil
        end)
    end
end

local function stopFish()
    Fish.farm = false
    Fish.paused = false
end

local LockState = {sent={}, busy=false, at=0}

local function getRarityList()
    local rarities = {}
    local seen = {}
    pcall(function()
        if Catalog and Catalog.Fish and Catalog.Fish.GetAll then
            for _, e in pairs(Catalog.Fish.GetAll()) do
                if type(e) == "table" and type(e.rarity) == "string" then
                    if not seen[e.rarity] then
                        seen[e.rarity] = true
                        table.insert(rarities, e.rarity)
                    end
                end
            end
        end
    end)
    if #rarities == 0 then
        rarities = {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine","Huge"}
    end
    table.sort(rarities, function(a,b)
        return (RarityPriority[a] or 99) < (RarityPriority[b] or 99)
    end)
    return rarities
end

local function autoLockPass()
    if LockState.busy then return end
    LockState.busy = true
    task.spawn(function()
        local profile = fetchProfile()
        local fishes = profile and profile.Inventory and profile.Inventory.Fishes
        if type(fishes) ~= "table" then LockState.busy=false return end
        local sell = getController("SellController")
        if not sell then LockState.busy=false return end
        local wantRarity, hasAny = {}, false
        if type(S.lockRarity) == "table" then
            for r, v in pairs(S.lockRarity) do
                if v == true then wantRarity[r] = true hasAny = true end
            end
        end
        if not hasAny then LockState.busy=false return end
        local rarityOf = {}
        pcall(function()
            if Catalog and Catalog.Fish and Catalog.Fish.GetAll then
                for _, e in pairs(Catalog.Fish.GetAll()) do
                    if type(e)=="table" then rarityOf[e.id or e.Id] = e.rarity end
                end
            end
        end)
        local queue, now = {}, os.clock()
        for uid, fish in pairs(fishes) do
            if type(fish)=="table" and fish.locked ~= true then
                local r = fish.rarity or rarityOf[fish.fishId]
                if r and wantRarity[r] then
                    if not LockState.sent[uid] or now - LockState.sent[uid] > 20 then
                        table.insert(queue, uid)
                    end
                end
            end
        end
        for i = 1, math.min(#queue, 12) do
            local uid = queue[i]
            LockState.sent[uid] = now
            pcall(function() sell:ToggleLock(uid) end)
            task.wait(0.15)
        end
        LockState.busy = false
        LockState.at = os.clock()
    end)
end

-- ================= BOAT TRAVEL =================

local function getPacket()
    local sd = RS:FindFirstChild("Stardust")
    local pk = sd and sd:FindFirstChild("Packages")
    local pf = pk and pk:FindFirstChild("Packet")
    if not pf then return end
    local ok, P2 = pcall(require, pf)
    if ok and type(P2) == "table" and P2.String then return P2 end
end

local function myCar()
    local cf = workspace:FindFirstChild("Cars")
    if not cf then return end
    return cf:FindFirstChild(tostring(LP.UserId))
end

local function findMerchant(p)
    local best, bd = nil, math.huge
    for _, x in ipairs(Collection:GetTagged("Interactive")) do
        if x:GetAttribute("InteractiveId") == "npc_car_merchant" then
            local q = x:IsA("Model") and x:GetPivot().Position or (x:IsA("BasePart") and x.Position)
            if q then
                local d = (q - p).Magnitude
                if d < bd then best, bd = x, d end
            end
        end
    end
    return best
end

local function enableNC(boat)
    NCStore = {}
    local function uc(p)
        if p:IsA("BasePart") then NCStore[p] = p.CanCollide p.CanCollide = false end
    end
    for _, p in ipairs(boat:GetDescendants()) do uc(p) end
    local c = LP.Character
    if c then for _, p in ipairs(c:GetDescendants()) do uc(p) end end
    if NCHold then NCHold:Disconnect() end
    NCHold = RunService.Stepped:Connect(function()
        for part in pairs(NCStore) do
            if part.Parent and part.CanCollide then part.CanCollide = false end
        end
        local ch = LP.Character
        if ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end)
end

local function disableNC()
    if NCHold then NCHold:Disconnect() NCHold = nil end
    for part, was in pairs(NCStore) do
        if part.Parent then pcall(function() part.CanCollide = was end) end
    end
    NCStore = {}
end

local function ensureCar(k, merchantPos)
    k = k or "truck"
    local existing = myCar()
    if existing then
        local mn = existing:FindFirstChild("Main")
        local ds = existing:FindFirstChild("DSeat")
        local _, r = lc()
        if mn and ds and r and (mn.Position - r.Position).Magnitude <= 30 then
            return existing
        end
        existing:Destroy()
        task.wait(0.3)
    end
    if merchantPos then
        local c, r, h = lc()
        if h and r then
            h:MoveTo(merchantPos)
            local dl = os.clock() + 10
            while os.clock() < dl and (r.Position - merchantPos).Magnitude > 8 do task.wait(0.1) end
        end
    end
    local Packet = getPacket()
    if not Packet then return end
    local isl = "island_starter"
    pcall(function()
        local c = getController("IslandRegionController")
        isl = c and c:GetCurrentIslandId() or isl
    end)
    pcall(function() Packet("SpawnCarEvent", Packet.String):Fire(k .. "/" .. isl) end)
    local dl = os.clock() + 8
    repeat
        task.wait(0.2)
        local b = myCar()
        if b and b:FindFirstChild("Main") and b:FindFirstChild("DSeat") then return b end
    until os.clock() > dl
end

local function sitBoat(boat)
    local c, r, h = lc()
    if not boat or not h then return false end
    local ds = boat:FindFirstChild("DSeat")
    if not ds then return false end
    if ds.Occupant == h then enableNC(boat) return true end

    local dl = os.clock() + 12
    while os.clock() < dl do
        if ds.Occupant == h then enableNC(boat) return true end
        local c2, r2 = lc()
        if not r2 then return false end
        r2.CFrame = CFrame.new(ds.Position + Vector3.new(0, 3, 0))
        local pp = ds:FindFirstChildWhichIsA("ProximityPrompt", true)
        if pp then pcall(function() fireproximityprompt(pp) end) end
        task.wait(0.2)
    end
    if ds.Occupant == h then enableNC(boat) return true end
    return false
end

local function findLandBoat(id)
    local w = workspace:FindFirstChild("World")
    local isl = w and w:FindFirstChild("Islands")
    local i = isl and isl:FindFirstChild(id)
    if not i then return end
    local sp = i:FindFirstChild("SpawnPoint")
    if not sp then return end
    local ind = sp:FindFirstChild("Indicator")
    if not ind or not ind:IsA("BasePart") then return end
    return ind.Position + Vector3.new(0, 8, 0)
end

local function tweenBoat(boat, target, spd, timeout)
    local c, r, h = lc()
    if not h or not boat then return false end
    local mn = boat:FindFirstChild("Main")
    local ds = boat:FindFirstChild("DSeat")
    if not (mn and ds) or ds.Occupant ~= h then return false end

    enableNC(boat)

    local startPos = mn.Position
    local endPos = Vector3.new(target.X, startPos.Y, target.Z)
    local dist = (endPos - startPos).Magnitude
    local duration = math.max(dist / (spd or 50), 1)

    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {}
    goal.CFrame = CFrame.new(endPos, endPos + (endPos - startPos).Unit) * (mn.CFrame - mn.Position)
    local tw = TweenService:Create(mn, info, goal)

    local conn
    conn = RunService.Stepped:Connect(function()
        if not mn or not mn.Parent then return end
        mn.AssemblyLinearVelocity = Vector3.zero
        mn.AssemblyAngularVelocity = Vector3.zero
        local c2, r2 = lc()
        if c2 and r2 then
            r2.CFrame = CFrame.new(ds.Position + Vector3.new(0, 3, 0))
        end
    end)

    local done = false
    tw.Completed:Connect(function() done = true end)
    tw:Play()

    local dl = os.clock() + (timeout or 120) + duration
    while os.clock() < dl and not done do
        task.wait(0.1)
        if ds.Occupant ~= h then break end
    end

    if conn then conn:Disconnect() end
    pcall(function() tw:Cancel() end)

    local c3, r3 = lc()
    if r3 then
        r3.CFrame = CFrame.new(target + Vector3.new(0, 5, 0))
    end
    return true
end

local function leaveBoat(boat)
    local _, _, h = lc()
    if h and boat then
        local ds = boat:FindFirstChild("DSeat")
        if ds and ds.Occupant == h then
            h.Sit = false
            h.Jump = true
            task.wait(0.3)
        end
    end
    disableNC()
end

local function travelBoat(key)
    if Traveling then return end
    Traveling = true
    task.spawn(function()
        local id = C.ISLAND_IDS[key] or key
        local cur
        pcall(function() cur = getController("IslandRegionController"):GetCurrentIslandId() end)
        if cur == id then
            WindUI:Notify({Title="Travel", Content="Da o dao nay", Duration=2})
            Traveling = false
            return
        end

        local _, r0 = lc()
        if not r0 then
            WindUI:Notify({Title="Travel", Content="Khong co nhan vat", Duration=3})
            Traveling = false
            return
        end
        local merchant = findMerchant(r0.Position)
        if not merchant then
            WindUI:Notify({Title="Travel", Content="Khong tim thay NPC thuyen", Duration=3})
            Traveling = false
            return
        end
        local mp = merchant:IsA("Model") and merchant:GetPivot().Position or merchant.Position

        WindUI:Notify({Title="Travel", Content="Di toi NPC...", Duration=2})
        local _, r1, h1 = lc()
        if h1 and r1 then
            h1:MoveTo(mp)
            local dl = os.clock() + 10
            while os.clock() < dl and (r1.Position - mp).Magnitude > 10 do task.wait(0.1) end
        end

        WindUI:Notify({Title="Travel", Content="Mua thuyen "..S.boat.."...", Duration=2})
        local boat = ensureCar(S.boat, mp)
        if not boat then
            WindUI:Notify({Title="Travel", Content="Mua that bai", Duration=3})
            Traveling = false
            return
        end

        WindUI:Notify({Title="Travel", Content="Len thuyen...", Duration=2})
        if not sitBoat(boat) then
            WindUI:Notify({Title="Travel", Content="Khong len duoc", Duration=3})
            Traveling = false
            return
        end

        local land = findLandBoat(id)
        if not land then
            WindUI:Notify({Title="Travel", Content="Khong co dat", Duration=3})
            leaveBoat(boat)
            Traveling = false
            return
        end

        local spd = C.BOAT_SPEED[S.boat] or 50
        WindUI:Notify({Title="Travel", Content="Tween toi "..C.ISLAND_LABELS[key].." ("..spd..")", Duration=2})
        tweenBoat(boat, land, spd, 120)

        leaveBoat(boat)
        task.wait(1)
        WindUI:Notify({Title="Travel", Content="Da toi "..C.ISLAND_LABELS[key], Duration=2})
        Traveling = false
    end)
end

-- ================= ESP ISLAND (RAINBOW) =================

local function getIslandIndicator(islandId)
    local world = workspace:FindFirstChild("World")
    local islands = world and world:FindFirstChild("Islands")
    local island = islands and islands:FindFirstChild(islandId)
    if not island then return nil end
    local spawnPoint = island:FindFirstChild("SpawnPoint")
    if not spawnPoint then return nil end
    return spawnPoint:FindFirstChild("Indicator")
end

local function makeRainbowESP(islandId, islandLabel)
    local ind = getIslandIndicator(islandId)
    if not ind then return end

    if ESPGuis[islandId] then
        pcall(function() ESPGuis[islandId]:Destroy() end)
        ESPGuis[islandId] = nil
    end

    local bg = Instance.new("BillboardGui")
    bg.Name = "DNHubIslandESP_" .. islandId
    bg.Adornee = ind
    bg.Size = UDim2.fromOffset(240, 60)
    bg.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
    bg.AlwaysOnTop = true
    bg.MaxDistance = 5000
    bg.LightInfluence = 0
    bg.ResetOnSpawn = false
    bg.Parent = ESPFolder

    local frame = Instance.new("Frame")
    frame.Name = "Box"
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = bg
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Name = "RainbowStroke"
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Transparency = 0
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "RainbowLabel"
    label.Size = UDim2.new(1, -16, 1, -16)
    label.Position = UDim2.fromOffset(8, 8)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextWrapped = true
    label.RichText = true
    label.Text = islandLabel .. "\n(" .. islandId .. ")"
    label.Parent = frame

    ESPGuis[islandId] = bg
end

local function startRainbowLoop()
    if RainbowTask then return end
    RainbowTask = task.spawn(function()
        while ESPFolder and ESPFolder.Parent and next(ESPGuis) do
            local t = os.clock() * 0.5
            for _, bg in pairs(ESPGuis) do
                if bg and bg.Parent then
                    local frame = bg:FindFirstChild("Box")
                    local stroke = frame and frame:FindFirstChild("RainbowStroke")
                    if stroke then
                        local hue = (t + 0.0) % 1
                        pcall(function() stroke.Color = Color3.fromHSV(hue, 1, 1) end)
                    end
                end
            end
            task.wait(1/60)
        end
        RainbowTask = nil
    end)
end

local function clearESP()
    if ESPFolder then pcall(function() ESPFolder:Destroy() end) end
    ESPFolder = nil
    ESPGuis = {}
end

local function startESP()
    clearESP()
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "DNHub_IslandESP"
    ESPFolder.Parent = workspace
    for _, key in ipairs(C.ISLAND_ORDER) do
        makeRainbowESP(C.ISLAND_IDS[key], C.ISLAND_LABELS[key] or key)
    end
    startRainbowLoop()
    WindUI:Notify({Title="ESP Island", Content="Rainbow ESP enabled", Duration=3})
end

local function stopESP()
    clearESP()
    WindUI:Notify({Title="ESP Island", Content="ESP disabled", Duration=3})
end

-- ================= BOSS =================

local BossEspActive = nil
local ActiveBoss = {part=nil, id=nil, meta=nil}

local function bossFxActive(region)
    local fx = region and region:FindFirstChild("BossSpawnerFX")
    return fx ~= nil and fx:GetAttribute("BossSpawnerFXActive")==true
end

local function bossRegionMeta(id)
    if not (Catalog and Catalog.BossRegion and Catalog.BossRegion.GetById) then return nil end
    local ok, entry = pcall(function() return Catalog.BossRegion.GetById(id) end)
    if not ok or type(entry) ~= "table" then return nil end
    local slot = tonumber(id:match("_(%d+)$")) or 1
    return {id = id, name = tostring(entry.name or id), islandId = entry.fallbackIslandId, slot = slot}
end

local function clearBossEsp()
    if BossEspActive and BossEspActive.gui then
        pcall(function() BossEspActive.gui:Destroy() end)
    end
    BossEspActive = nil
end

local function findActiveBossRegion()
    for _, inst in ipairs(Collection:GetTagged("BossRegion")) do
        if inst:IsA("BasePart") and inst:IsDescendantOf(workspace) then
            if bossFxActive(inst) then
                local id = inst:GetAttribute("bossRegionId")
                if type(id) == "string" then return inst, id end
            end
        end
    end
    return nil, nil
end

local function bossEsp()
    if not (S.bossEsp1 or S.bossEsp2 or S.autoBoss) then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    local part, id = findActiveBossRegion()
    if not part or not id then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    local meta = bossRegionMeta(id)
    if not meta then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    local want = (meta.slot == 1 and S.bossEsp1) or (meta.slot == 2 and S.bossEsp2) or S.autoBoss
    if not want then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    ActiveBoss.part = part
    ActiveBoss.id = id
    ActiveBoss.meta = meta
    if BossEspActive and BossEspActive.id ~= id then clearBossEsp() end
    if not BossEspActive or not BossEspActive.gui or not BossEspActive.gui.Parent then
        local gui = Instance.new("BillboardGui")
        gui.Name = "DNHubBossEsp"
        gui.Adornee = part
        gui.AlwaysOnTop = true
        gui.MaxDistance = 8000
        gui.Size = UDim2.fromOffset(200, 60)
        gui.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
        gui.Parent = PG
        local box = Instance.new("Frame")
        box.Size = UDim2.fromScale(1, 1)
        box.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        box.BackgroundTransparency = 0.2
        box.BorderSizePixel = 0
        box.Parent = gui
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        local num = Instance.new("TextLabel")
        num.Name = "Number"
        num.Size = UDim2.fromOffset(56, 0)
        num.Position = UDim2.fromOffset(4, 0)
        num.BackgroundTransparency = 1
        num.Font = Enum.Font.GothamBold
        num.TextSize = 38
        num.Text = tostring(meta.slot)
        num.TextColor3 = Color3.fromRGB(255, 95, 95)
        num.Parent = box
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Text"
        lbl.Size = UDim2.new(1, -62, 1, 0)
        lbl.Position = UDim2.fromOffset(60, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
        lbl.TextWrapped = true
        lbl.Text = meta.name .. "\n" .. tostring(meta.islandId or "?")
        lbl.Parent = box
        BossEspActive = {gui = gui, part = part, id = id, num = num, lbl = lbl}
    end
    if BossEspActive.gui.Adornee ~= part then BossEspActive.gui.Adornee = part end
    if BossEspActive.lbl then
        pcall(function() BossEspActive.lbl.Text = meta.name .. "\n" .. tostring(meta.islandId or "?") end)
    end
end

local function stopBossEsp()
    clearBossEsp()
    ActiveBoss.part = nil
    ActiveBoss.id = nil
    ActiveBoss.meta = nil
end

local function teleToBoss()
    local part = ActiveBoss.part
    if not part or not part.Parent then
        WindUI:Notify({Title="Boss", Content="No active boss", Duration=3})
        return
    end
    WindUI:Notify({Title="Boss", Content="Tweening to boss "..tostring(ActiveBoss.meta and ActiveBoss.meta.name or "?"), Duration=2})
    tweenTo(CFrame.new(part.Position + Vector3.new(0, 8, 0)), C.BOSS_TWEEN_SPEED)
    task.wait(0.3)
end

local BossStepState = {
    holding = false,
    event = false,
    savedCf = nil,
    savedIsland = nil,
    bank = nil,
    bankFor = nil,
    bankAt = -math.huge,
    fails = 0,
    step = "Idle",
    phase = "idle",
    wasFishing = false,
}

local function detectActiveEvent()
    for _, inst in ipairs(workspace:GetDescendants()) do
        if C.EVENT_NAMES[inst.Name] then
            if inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
                if inst.Enabled then return true, inst end
            elseif inst:IsA("Model") or inst:IsA("Folder") or inst:IsA("BasePart") or inst:IsA("BillboardGui") then
                if inst:GetAttribute("Enabled") == true or inst:GetAttribute("Active") == true then
                    return true, inst
                end
            end
        end
    end
    return false, nil
end

local function bossGround(islandId)
    local waterY = 3
    pcall(function()
        if Catalog and Catalog.Island and Catalog.Island.GetWaterY then
            waterY = tonumber(Catalog.Island.GetWaterY(islandId)) or 3
        end
    end)
    local exclude = {}
    for _, plr in ipairs(P:GetPlayers()) do
        if plr.Character then table.insert(exclude, plr.Character) end
    end
    for _, inst in ipairs(Collection:GetTagged("IslandRegion")) do table.insert(exclude, inst) end
    for _, inst in ipairs(Collection:GetTagged("BossRegion")) do table.insert(exclude, inst) end
    local rays = RaycastParams.new()
    rays.FilterType = Enum.RaycastFilterType.Exclude
    rays.FilterDescendantsInstances = exclude
    rays.RespectCanCollide = true
    rays.IgnoreWater = false
    local lift = 3
    pcall(function()
        local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
            local leg = humanoid.Parent and humanoid.Parent:FindFirstChild("Left Leg")
            lift = 3 + ((leg and leg.Size.Y) or 2)
        end
    end)
    local cast = FishingConfig and FishingConfig.Cast or {}
    local minCast = tonumber(cast.BaitMinDist) or 30
    local maxCast = tonumber(cast.BaitMaxDist) or 60
    local server = tonumber(cast.ServerMaxDistance) or 80
    return {rays=rays, waterY=waterY, lift=lift, minCast=minCast, maxCast=math.min(maxCast, server-2)}
end

local function bossDryGround(hit, ctx)
    if not hit or hit.Normal.Y < 0.75 then return false end
    if hit.Instance.Material == Enum.Material.Water then return false end
    if hit.Position.Y <= ctx.waterY + 0.25 then return false end
    if hit.Instance:IsA("Terrain") then return true end
    if hit.Instance:IsA("BasePart") then return hit.Instance.CanCollide and hit.Instance.Anchored end
    return false
end

local function bossSupportAt(point, ctx)
    local hit = workspace:Raycast(point + Vector3.new(0,1,0), Vector3.new(0, -(ctx.lift+2), 0), ctx.rays)
    if not bossDryGround(hit, ctx) then return false end
    return math.abs(point.Y - hit.Position.Y - ctx.lift) <= 1.5
end

local function bossTargetValid(region, waterPoint, ctx)
    if not region.Parent then return false end
    local local3 = region.CFrame:PointToObjectSpace(waterPoint)
    local half = region.Size * 0.5
    if math.abs(local3.X) > half.X - 0.1 then return false end
    if math.abs(local3.Y) > half.Y then return false end
    if math.abs(local3.Z) > half.Z - 0.1 then return false end
    return workspace:Raycast(waterPoint + Vector3.new(0,100,0), Vector3.new(0,-100,0), ctx.rays) == nil
end

local function bossScanBank(region, islandId, alive)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root or typeof(region) ~= "Instance" then return nil end
    local ctx = bossGround(islandId)
    local half = region.Size * 0.5
    local function scanAlive()
        return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") == root
            and region:IsDescendantOf(workspace) and alive()
    end
    if not scanAlive() then return nil, true end
    local rays, sliceAt, cancelled = 0, os.clock(), false
    ctx.cast = function(origin, direction)
        if cancelled then return nil end
        if rays >= 48 or os.clock() - sliceAt >= 0.002 then
            task.wait()
            rays, sliceAt = 0, os.clock()
            if not scanAlive() then cancelled = true return nil end
        end
        rays += 1
        return workspace:Raycast(origin, direction, ctx.rays)
    end
    local waters = {}
    local function addWater(x, z)
        if cancelled or #waters >= 40 then return end
        local world = region.CFrame:PointToWorldSpace(Vector3.new(x, 0, z))
        local point = Vector3.new(world.X, ctx.waterY, world.Z)
        if bossTargetValid(region, point, ctx) then table.insert(waters, point) end
    end
    local fx = region:FindFirstChild("BossSpawnerFX")
    if typeof(fx) == "Instance" then
        local local3 = region.CFrame:PointToObjectSpace(fx.Position)
        addWater(math.clamp(local3.X, -half.X+1, half.X-1), math.clamp(local3.Z, -half.Z+1, half.Z-1))
    end
    local spanX = math.max(half.X - 2, 0)
    local spanZ = math.max(half.Z - 2, 0)
    local stepsX = math.clamp(math.ceil(region.Size.X / 22), 2, 12)
    local stepsZ = math.clamp(math.ceil(region.Size.Z / 22), 2, 12)
    for i = 0, stepsX do
        local x = -spanX + 2 * spanX * i / stepsX
        addWater(x, -spanZ) addWater(x, spanZ)
    end
    for i = 1, stepsZ - 1 do
        local z = -spanZ + 2 * spanZ * i / stepsZ
        addWater(-spanX, z) addWater(spanX, z)
    end
    for i = -1, 1, 2 do
        for j = -1, 1, 2 do
            addWater(i * half.X * 0.5, j * half.Z * 0.5)
        end
    end
    if cancelled then return nil, true end
    if #waters == 0 then return nil end
    local ranges = { ctx.minCast + 2, (ctx.minCast + ctx.maxCast) * 0.5, ctx.maxCast - 2 }
    local best, bestScore = nil, math.huge
    for _, water in ipairs(waters) do
        for _, range in ipairs(ranges) do
            for step = 0, 11 do
                if cancelled then return nil, true end
                local angle = step * math.pi / 6
                local hit = ctx.cast(
                    water + Vector3.new(math.cos(angle)*range, 120, math.sin(angle)*range),
                    Vector3.new(0, -124, 0)
                )
                if bossDryGround(hit, ctx) then
                    local stand = hit.Position + Vector3.new(0, ctx.lift + 0.1, 0)
                    local reach = (stand - water).Magnitude
                    if reach >= ctx.minCast and reach <= ctx.maxCast then
                        local solid = true
                        for _, offset in ipairs({Vector3.new(1.2,0,0), Vector3.new(-1.2,0,0), Vector3.new(0,0,1.2), Vector3.new(0,0,-1.2)}) do
                            if not bossSupportAt(stand + offset, ctx) then solid = false break end
                        end
                        if solid and bossSupportAt(stand, ctx) then
                            if ctx.cast(hit.Position + Vector3.new(0,0.3,0), Vector3.new(0,120,0)) == nil then
                                local score = (root.Position - stand).Magnitude + math.abs(reach - ranges[2]) * 2
                                if score < bestScore then
                                    bestScore = score
                                    best = CFrame.lookAt(stand, Vector3.new(water.X, stand.Y, water.Z))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if cancelled or not scanAlive() then return nil, true end
    return best
end

local function bossGetCurrentIsland()
    local id = ""
    pcall(function()
        local ctrl = getController("IslandRegionController")
        id = ctrl and ctrl:GetCurrentIslandId() or ""
    end)
    return id
end

local function bossFaceBoss(regionPart)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root or not regionPart or not regionPart.Parent then return end
    local face = Vector3.new(regionPart.Position.X, root.Position.Y, regionPart.Position.Z)
    pcall(function() root.CFrame = CFrame.lookAt(root.Position, face) end)
end

local function getIslandKeyFromId(id)
    for k, v in pairs(C.ISLAND_IDS) do
        if v == id then return k end
    end
    return id
end

local function bossRestore()
    local store = BossStepState
    if store.savedIsland and store.savedIsland ~= "" and store.savedIsland ~= bossGetCurrentIsland() then
        local key = getIslandKeyFromId(store.savedIsland)
        travelBoat(key)
        local dl = os.clock() + 60
        while Traveling and os.clock() < dl do task.wait(0.2) end
    end
    if store.savedCf then
        tweenTo(store.savedCf, C.BOSS_TWEEN_SPEED)
        task.wait(0.3)
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function() root.CFrame = store.savedCf end)
        end
    end
    store.savedCf = nil
    store.savedIsland = nil
end

local function bossStep()
    local store = BossStepState
    if not S.autoBoss then
        if store.holding then
            store.holding = false
            store.event = false
            store.step = "Idle"
            store.phase = "idle"
            bossRestore()
            if store.wasFishing then
                Fish.paused = false
                store.wasFishing = false
            end
        end
        return
    end
    local hasEvent = detectActiveEvent()
    if not hasEvent then
        if store.holding then
            store.holding = false
            store.event = false
            store.step = "Event ended - returning"
            store.phase = "idle"
            bossRestore()
            if store.wasFishing then
                Fish.paused = false
                store.wasFishing = false
            end
        end
        return
    end
    if not store.holding then
        store.holding = true
        store.event = true
        store.bank = nil
        store.bankFor = nil
        store.bankAt = -math.huge
        store.fails = 0
        store.phase = "saving"
        store.step = "Event detected - saving position"
        local c = LP.Character
        if c then
            local r = c:FindFirstChild("HumanoidRootPart")
            if r then
                store.savedCf = r.CFrame
                store.savedIsland = bossGetCurrentIsland()
            end
        end
        store.wasFishing = Fish.farm
        Fish.paused = true
    end
    if store.phase == "saving" then
        store.step = "Moving to Starter"
        travelBoat("starter")
        local dl = os.clock() + 60
        while Traveling and os.clock() < dl do task.wait(0.2) end
        task.wait(0.5)
        store.phase = "traveling"
        return
    end
    if store.phase == "traveling" then
        store.step = "Moving to boss bank"
        local part = ActiveBoss.part
        if not part or not part.Parent then
            store.step = "Waiting for boss region..."
            return
        end
        if store.bank == nil or store.bankFor ~= part or os.clock() - store.bankAt >= 20 then
            local found, cancelled = bossScanBank(part, ActiveBoss.meta and ActiveBoss.meta.islandId, function() return S.autoBoss end)
            if cancelled then return end            if not found then
                store.fails = (store.fails or 0) + 1
                if store.fails >= 3 then store.step = "No dry spot, waiting" task.wait(3) end
                return
            end
            store.fails = 0
            store.bankAt = os.clock()
            store.bank = found
            store.bankFor = part
        end
        local bank = store.bank
        if not bank then return end
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local distance = (root.Position - bank.Position).Magnitude
        if distance > 6 then
            tweenTo(bank, C.BOSS_TWEEN_SPEED)
        else
            store.phase = "fishing"
            store.step = "Arrived at boss bank"
            if store.wasFishing then
                Fish.paused = false
            end
        end
        return
    end
    if store.phase == "fishing" then
        store.step = "Farming boss"
        local part = ActiveBoss.part
        if part and part.Parent then
            bossFaceBoss(part)
        end
        return
    end
end

task.spawn(function()
    while true do
        if S.bossEsp1 or S.bossEsp2 or S.autoBoss then
            pcall(bossEsp)
        end
        if S.autoBoss then pcall(bossStep) end
        task.wait(1)
    end
end)

local tag = nil
local tagLabel = nil
local humanoidRef = nil
local lastKillAt = 0
local NAME_HIDE = string.char(226,128,139)
local fnC = {}
local fnR = false

local function hideOriginalNames()
    pcall(function()
        local rn = LP.Name
        local dn = LP.DisplayName
        local function sc(c)
            for _, o in ipairs(c:GetDescendants()) do
                if o:IsA("TextLabel") then
                    if o.Text == rn or o.Text == "@"..rn or o.Text == dn then
                        if not fnC[o] then fnC[o] = {t=o.Text, v=o.Visible, tr=o.TextTransparency} end
                        o.Text = "" o.Visible = false o.TextTransparency = 1
                    end
                end
            end
        end
        sc(workspace)
        for _, g in ipairs(PG:GetChildren()) do
            if g:IsA("ScreenGui") then sc(g) end
        end
    end)
end

local function restoreOriginalNames()
    for o, d in pairs(fnC) do
        pcall(function()
            if o and o.Parent then
                o.Text = d.t
                o.Visible = d.v
                o.TextTransparency = d.tr
            end
        end)
    end
    fnC = {}
end

local function createCustomTag()
    local ch = LP.Character
    if not ch then return end
    local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local stale = head:FindFirstChild("DNHubNameTag")
    if stale then pcall(function() stale:Destroy() end) end
    local tx = tostring(S.customName ~= "" and S.customName or LP.DisplayName)
    local bb = Instance.new("BillboardGui")
    bb.Name = "DNHubNameTag"
    bb.Size = UDim2.fromOffset(130, 18)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 150
    bb.LightInfluence = 0
    bb.Adornee = head
    bb.Parent = head
    local lb = Instance.new("TextLabel")
    lb.Name = "Label"
    lb.Size = UDim2.new(1, 0, 1, 0)
    lb.BackgroundTransparency = 1
    lb.Text = tx
    lb.TextColor3 = Color3.fromRGB(255,255,255)
    lb.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lb.TextStrokeTransparency = 0.3
    lb.TextScaled = true
    lb.Font = Enum.Font.GothamBold
    lb.RichText = false
    lb.Parent = bb
    tag = bb
    tagLabel = lb
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then
        humanoidRef = hum
        pcall(function() hum.DisplayName = NAME_HIDE end)
    end
end

local function killGameTag()
    local now = os.clock()
    if now - lastKillAt < 0.5 then return end
    lastKillAt = now
    local folder = workspace:FindFirstChild("Nametags")
    if not folder then return end
    local own = folder:FindFirstChild(LP.Name)
    if own then pcall(function() own:Destroy() end) end
end

local function refreshName()
    hideOriginalNames()
    if not tag or not tag.Parent or not tagLabel or not tagLabel.Parent then createCustomTag() end
    local text = tostring(S.customName ~= "" and S.customName or LP.DisplayName)
    if tagLabel and tagLabel.Parent then
        if tagLabel.Text ~= text then pcall(function() tagLabel.Text = text end) end
    end
    local hum = humanoidRef
    if hum and hum.Parent and hum.DisplayName ~= NAME_HIDE then
        pcall(function() hum.DisplayName = NAME_HIDE end)
    end
    killGameTag()
end

local function startFake()
    if fnR then return end
    fnR = true
    task.spawn(function()
        hideOriginalNames()
        createCustomTag()
        while S.fakename do
            pcall(refreshName)
            task.wait(0.15)
        end
        fnR = false
    end)
end

local function stopFake()
    restoreOriginalNames()
    if tag then pcall(function() tag:Destroy() end) end
    tag = nil
    tagLabel = nil
    humanoidRef = nil
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.DisplayName = LP.DisplayName end) end
    end
end

local antiAfkTask = nil
local function antiAfkTick()
    if not S.antiAfk then return end
    local ok, focused = pcall(function() return game:GetService("UserInputService"):GetFocusedTextBox() end)
    if ok and focused then return end
    local pressed = pcall(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new(0,0))
    end)
    if not pressed then
        pcall(function()
            local code = Enum.KeyCode[S.antiAfkKey or "F13"] or Enum.KeyCode.F13
            VIM:SendKeyEvent(true, code, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, code, false, game)
        end)
    end
end

local function startAntiAfk()
    if antiAfkTask then return end
    antiAfkTask = task.spawn(function()
        while S.antiAfk do
            task.wait(math.max(10, S.antiAfkInterval or 50))
            if not S.antiAfk then break end
            pcall(antiAfkTick)
        end
        antiAfkTask = nil
    end)
end

local Window = WindUI:CreateWindow({
    Title = "DNHUB 3.0",
    Icon = LOGO_URL,
    Author = "DN Team",
    Folder = "DNHub",
    Size = UDim2.fromOffset(700, 500),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    HideSearchBar = false,
    Topbar = {Height=44, ButtonsType="Mac"},
    OpenButton = {
        Title = "DNHUB 3.0",
        Icon = LOGO_URL,
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(Color3.fromHex("#7D91FF"), Color3.fromHex("#A0B4FF")),
    },
})

local Tabs = {}
Tabs.Main = Window:Tab({Title="Main", Icon="user"})
Tabs.Tele = Window:Tab({Title="Teleport", Icon="map-pin"})
Tabs.Boss = Window:Tab({Title="Boss", Icon="swords"})
Tabs.Plr = Window:Tab({Title="Player", Icon="users"})
Tabs.Misc = Window:Tab({Title="Misc", Icon="settings"})
Tabs.Settings = Window:Tab({Title="Settings", Icon="wrench"})

LP.Idled:Connect(function()
    pcall(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end)

do
    local sec = Tabs.Main:Section({Title="Automation"})
    sec:Toggle({Title = "Auto Fish", Default = S.fish, Callback = function(v) S.fish = v if v then startFish() else stopFish() end end})
    sec:Toggle({Title = "Auto Skill", Default = S.skill, Callback = function(v) S.skill = v end})
    sec:Toggle({Title = "Bypass Minigame", Default = S.bypass, Callback = function(v) S.bypass = v end})
end

do
    local sec = Tabs.Main:Section({Title="Skill Order"})
    sec:Input({
        Title = "Skill Order (1,2,3,4)",
        Value = table.concat(S.skillOrder or {1,2,1,3}, ","),
        Placeholder = "1,2,1,3",
        Callback = function(v)
            local arr = {}
            for num in tostring(v):gmatch("%d+") do
                local n = tonumber(num)
                if n and n >= 1 and n <= 4 then table.insert(arr, n) end
            end
            if #arr > 0 then
                S.skillOrder = arr
                SkillOrderSet = arr
                reloadSkillQueue()
            end
        end
    })
end

do
    local sec = Tabs.Main:Section({Title="Sell"})
    sec:Toggle({Title = "Auto Sell", Default = S.sell, Callback = function(v) S.sell = v if v then startSell() end end})
    sec:Toggle({Title = "Sell When Full", Default = S.autoSellFull, Callback = function(v) S.autoSellFull = v if v then startAutoFull() end end})
    sec:Toggle({Title = "Walk Mode", Default = S.useWalk, Callback = function(v) S.useWalk = v end})
    sec:Toggle({Title = "Return After Sell", Default = S.returnAfterSell, Callback = function(v) S.returnAfterSell = v end})
    sec:Dropdown({Title = "Travel Mode", Values = {"Tween","Walk","Instant"}, Value = S.sellTravelMode or "Tween",
        Callback = function(v) S.sellTravelMode = v S.useWalk = (v == "Walk") end})
    sec:Slider({Title = "Interval (s)", Value = {Min=30, Max=3600, Default=S.sellInt}, Step = 1,
        Callback = function(v) S.sellInt = v end})
    sec:Button({Title = "Sell Now", Callback = function() task.spawn(doSellFull) end})
end

do
    local sec = Tabs.Main:Section({Title="Fish Lock"})
    sec:Toggle({Title = "Auto Lock", Default = S.autoLock, Callback = function(v) S.autoLock = v if v then task.spawn(autoLockPass) end end})
    local rarityList = getRarityList()
    local function raritySetToArray(set)
        local arr = {}
        for _, r in ipairs(rarityList) do
            if type(set)=="table" and set[r] then table.insert(arr, r) end
        end
        return arr
    end
    sec:Dropdown({Title = "Lock Rarity", Values = rarityList, Multi = true, AllowNone = true,
        Value = raritySetToArray(S.lockRarity),
        Callback = function(picked)
            local set = {}
            if type(picked) == "table" then
                for _, r in ipairs(picked) do set[r] = true end
            elseif type(picked) == "string" then
                set[picked] = true
            end
            S.lockRarity = set
        end})
    sec:Button({Title = "Lock Now", Callback = function() task.spawn(autoLockPass) end})
end

do
    local sec = Tabs.Tele:Section({Title="Island (Boat Travel)"})
    sec:Dropdown({Title = "Island", Values = C.ISLAND_DISPLAY, Value = C.ISLAND_LABELS[S.island] or "Starter",
        Callback = function(v)
            for _, id in ipairs(C.ISLAND_ORDER) do
                if C.ISLAND_LABELS[id] == v then S.island = id break end
            end
        end})
    sec:Dropdown({Title = "Boat Type", Values = {"Truck (50)", "Red Truck (100)"}, Value = "Truck (50)",
        Callback = function(v)
            S.boat = (v == "Red Truck (100)") and "red_truck" or "truck"
        end})
    sec:Button({Title = "Travel by Boat", Callback = function() travelBoat(S.island) end})
    sec:Toggle({Title = "ESP Island (Rainbow)", Default = S.esp, Callback = function(v) S.esp = v if v then startESP() else stopESP() end end})
end

do
    local sec = Tabs.Boss:Section({Title="ESP Boss"})
    sec:Toggle({Title = "ESP Part 1", Default = S.bossEsp1, Callback = function(v) S.bossEsp1 = v end})
    sec:Toggle({Title = "ESP Part 2", Default = S.bossEsp2, Callback = function(v) S.bossEsp2 = v end})
    sec:Button({Title = "Reset ESP", Callback = function() stopBossEsp() end})
end

do
    local sec = Tabs.Boss:Section({Title="Auto Boss"})
    sec:Toggle({Title = "Auto Boss", Default = S.autoBoss,
        Callback = function(v)
            S.autoBoss = v
            if not v and BossStepState.holding then
                BossStepState.holding = false
                BossStepState.event = false
                BossStepState.step = "Idle"
                BossStepState.phase = "idle"
                bossRestore()
                if BossStepState.wasFishing then
                    Fish.paused = false
                    BossStepState.wasFishing = false
                end
            end
        end})
    sec:Button({Title = "Teleport to Boss", Callback = function() task.spawn(teleToBoss) end})
    local lbl = sec:Paragraph({Title = "Idle"})
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function() lbl:SetTitle(BossStepState.step or "Idle") end)
        end
    end)
end

do
    local sec = Tabs.Plr:Section({Title="Speed"})
    sec:Toggle({Title = "Enable Speed", Default = S.speedOn, Callback = function(v) enableSpeed(v) end})
    sec:Slider({Title = "Speed (16-200)", Value = {Min=16, Max=200, Default=S.speed}, Step = 1,
        Callback = function(v) applySpeed(v) end})
end

do
    local sec = Tabs.Plr:Section({Title="Fake Name"})
    sec:Toggle({Title = "Enable Fake Name", Default = S.fakename,
        Callback = function(v) S.fakename = v if v then startFake() else stopFake() end end})
    sec:Input({Title = "Custom Nametag", Value = S.customName, Placeholder = "DNHub 3.0",
        Callback = function(v) S.customName = v end})
end

do
    local sec = Tabs.Misc:Section({Title="System"})
    sec:Button({Title = "Unload Menu", Callback = function()
        S.fish = false S.skill = false S.bypass = false S.sell = false S.autoSellFull = false
        S.speedOn = false S.fakename = false S.esp = false S.bossEsp1 = false S.bossEsp2 = false
        S.autoLock = false S.autoBoss = false S.antiAfk = false
        Fish.farm = false
        Fish.paused = false
        stopESP()
        stopBossEsp()
        stopFake()
        disableNC()
        local c = LP.Character
        if c then
            local hu = c:FindFirstChildOfClass("Humanoid")
            if hu then hu.WalkSpeed = 16 hu.JumpPower = 50 end
        end
        Window:Destroy()
    end})
end

do
    local sec = Tabs.Settings:Section({Title="Anti AFK"})
    sec:Toggle({Title = "Anti AFK", Default = S.antiAfk,
        Callback = function(v) S.antiAfk = v if v then startAntiAfk() end end})
    sec:Slider({Title = "Interval (s)", Value = {Min=10, Max=300, Default=50}, Step = 1,
        Callback = function(v) S.antiAfkInterval = v end})
end

task.spawn(function()
    while true do
        if S.autoLock then pcall(autoLockPass) end
        task.wait(2)
    end
end)

task.spawn(function()
    task.wait(2)
    if S.fish then startFish() end
    if S.sell then startSell() end
    if S.autoSellFull then startAutoFull() end
    if S.fakename then startFake() end
    if S.esp then startESP() end
    if S.speedOn and S.speed then applySpeed(S.speed) end
    if S.antiAfk then startAntiAfk() end
end)

LP.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid")
    task.wait(0.5)
    if S.speedOn and S.speed then c.Humanoid.WalkSpeed = S.speed end
    if S.fish then startFish() end
    if S.fakename then
        task.wait(0.3)
        hideOriginalNames()
        createCustomTag()
    end
    if S.antiAfk then startAntiAfk() end
end)

WindUI:Notify({Title="DNHUB 3.0", Content="Loaded!", Duration=5})
