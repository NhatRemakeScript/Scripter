local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local Run = game:GetService("RunService")
local Collection = game:GetService("CollectionService")
local Pathfinding = game:GetService("PathfindingService")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local IL = {"desert","fossil","jungle","snow","starter","volcano"}
local SF = "DNHub_Settings.json"
local SPOTF = "DNHub_Spot.json"
local AEF = "https://raw.githubusercontent.com/NhatRemakeScript/Roblox/refs/heads/main/Aoaoowbeeuua.lua"

local MAIN_PARTS = {"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}

local def = {
	fish=false, skill=false, bypass=false,
	sell=false, autoSellFull=false, useWalk=false,
	speed=36, speedOn=false,
	fakename=false, esp=false,
	bossEsp1=true, bossEsp2=true,
	liteGfx=false, autoLock=false, autoReturn=false,
	lockRarity={Legendary=true, Mythical=true, Divine=true},
	skillOrder={1,2,1,3},
	sellInt=300, island="snow", teleMode="fast",
	autoExec=false, customName="DNHub",
	tagColorR=0.7, tagColorG=0.4, tagColorB=1.0, tagRainbow=false
}

local function loadCfg()
	local d = {}
	for k,v in pairs(def) do
		if type(v) == "table" then
			local copy = {}
			for kk, vv in pairs(v) do copy[kk] = vv end
			d[k] = copy
		else
			d[k] = v
		end
	end
	if isfile and isfile(SF) then
		local ok,c = pcall(readfile,SF)
		if ok and c and c~="" then
			local ok2,dec = pcall(function() return game:GetService("HttpService"):JSONDecode(c) end)
			if ok2 and type(dec)=="table" then
				for k,v in pairs(dec) do
					if def[k] ~= nil then
						if type(def[k]) == "table" then
							if type(v) == "table" then d[k] = v end
						elseif type(v) == type(def[k]) then
							d[k] = v
						end
					end
				end
			end
		end
	end
	return d
end

local sv = loadCfg()
local st = {}
for k,v in pairs(sv) do
	if type(v) == "table" then
		local copy = {}
		for kk, vv in pairs(v) do copy[kk] = vv end
		st[k] = copy
	else
		st[k] = v
	end
end
local island = st.island or "snow"
local sellInt = st.sellInt or 300
local teleMode = st.teleMode or "fast"
local customName = st.customName or "DNHub"
local uiS = {L=nil,R=nil,U=nil}

local function save()
	pcall(function()
		writefile(SF, game:GetService("HttpService"):JSONEncode({
			fish=st.fish, skill=st.skill, bypass=st.bypass,
			sell=st.sell, autoSellFull=st.autoSellFull, useWalk=st.useWalk,
			speed=st.speed, speedOn=st.speedOn,
			fakename=st.fakename, esp=st.esp,
			bossEsp1=st.bossEsp1, bossEsp2=st.bossEsp2,
			liteGfx=st.liteGfx, autoLock=st.autoLock, autoReturn=st.autoReturn,
			lockRarity=st.lockRarity, skillOrder=st.skillOrder,
			sellInt=sellInt, island=island, teleMode=teleMode,
			autoExec=st.autoExec, customName=customName,
			tagColorR=st.tagColorR, tagColorG=st.tagColorG, tagColorB=st.tagColorB,
			tagRainbow=st.tagRainbow
		}))
	end)
end

-- ============ CLIENT / CONTROLLERS ============
local Client, Catalog
pcall(function()
	local sd = RS:FindFirstChild("Stardust")
	if sd then
		local c = sd:FindFirstChild("Client")
		if c then Client = require(c) end
	end
	local data = RS:FindFirstChild("Data")
	local cat = data and data:FindFirstChild("Catalog")
	if cat then Catalog = require(cat) end
end)

local RarityPriority = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythical=6,Divine=7}

local function getController(name)
	if Client and type(Client.GetController) == "function" then
		local ok, c = pcall(function() return Client.GetController(name) end)
		if ok then return c end
	end
	return nil
end

-- ============ SAVE / RESTORE CHAR (chỉ part chính) ============
local function saveState()
	local c = LP.Character
	if not c then return nil end
	local h = c:FindFirstChild("HumanoidRootPart")
	local hu = c:FindFirstChildOfClass("Humanoid")
	if not h or not hu then return nil end
	local s = {cframe=h.CFrame,vel=h.AssemblyLinearVelocity,ang=h.AssemblyAngularVelocity,rv=h.RotVelocity,ar=hu.AutoRotate,ps=hu.PlatformStand,ws=hu.WalkSpeed,jp=hu.JumpPower,hs=hu:GetState(),cc={}}
	for _, name in ipairs(MAIN_PARTS) do
		local p = c:FindFirstChild(name)
		if p and p:IsA("BasePart") then
			s.cc[p] = p.CanCollide
		end
	end
	return s
end

local function hardRestore(savedCharacter, saved)
	local cur = LP.Character
	if cur then
		-- Chỉ restore part trong saved.cc — không touch part khác
		if saved and saved.cc then
			for p, cc in pairs(saved.cc) do
				if p and p.Parent then
					pcall(function() p.CanCollide = cc end)
				end
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
end

-- ============ TWEEN ============
local Tweening = false

local function tSpeed() return teleMode=="fast" and 70 or 40 end

local function tweenTo(cf, spd)
	spd = spd or tSpeed()

	if Tweening then
		local timeout = tick() + 10
		while Tweening and tick() < timeout do task.wait(0.05) end
		if Tweening then return end
	end
	Tweening = true

	local ok, err = pcall(function()
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

		-- Noclip: chỉ uncollide part chính
		local nc = Run.Stepped:Connect(function()
			local cur = LP.Character
			if cur and cur == savedCharacter then
				for _, name in ipairs(MAIN_PARTS) do
					local p = cur:FindFirstChild(name)
					if p and p:IsA("BasePart") then
						p.CanCollide = false
					end
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

		if nc then
			nc:Disconnect()
			nc = nil
		end

		local c3 = LP.Character
		if c3 and c3 == savedCharacter then
			local h3 = c3:FindFirstChild("HumanoidRootPart")
			if h3 then
				h3.CFrame = CFrame.new(tP) * sR
			end
		end

		hardRestore(savedCharacter, saved)
		task.wait(0.05)
		hardRestore(savedCharacter, saved)
		task.wait(0.15)
		hardRestore(savedCharacter, saved)
	end)

	Tweening = false
end

-- ============ WALK ============
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
		if not live or LP.Character ~= c or h.Health <= 0 or (alive and not alive()) then break end
		if (live.Position - goal).Magnitude <= (stopAt or 2) then
			h:MoveTo(live.Position)
			return true
		end
		if wi < #waypoints and (live.Position - waypoints[wi].Position).Magnitude <= 3 then
			wi += 1
			h:MoveTo(waypoints[wi].Position)
		end
		if (live.Position - lastPos).Magnitude < 0.3 then
			still += 0.1
		else
			still = 0
			lastPos = live.Position
		end
		if still >= 0.8 then
			still = 0
			h:MoveTo(waypoints[wi].Position)
		end
	end
	if h.Parent then h:MoveTo(r.Position) end
	return false
end

-- ============ AUTO MINIGAME ============
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
	if f.L then if not uiS.L then uiS.L=n end if n-uiS.L>=0.2 then sKey(Enum.KeyCode.A) uiS.L=nil end else uiS.L=nil end
	if f.R then if not uiS.R then uiS.R=n end if n-uiS.R>=0.2 then sKey(Enum.KeyCode.D) uiS.R=nil end else uiS.R=nil end
	if f.U then if not uiS.U then uiS.U=n end if n-uiS.U>=0.2 then sKey(Enum.KeyCode.W) uiS.U=nil end else uiS.U=nil end
end

-- ============ INPUT PRESS ============
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
	task.wait(hold or 0.045)
	release(action)
end

-- ============ ROD ============
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
	local rarity = RarityPriority[cat.rarity] or 0
	return dmg * 1e6 + luck * 1e3 + (cat.skillSlots or 0) * 10 + rarity
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

-- ============ SKILL ============
local SKILL_SLOTS = 4
local SlotPhase = {}
local SkillCycle = {index = 1}

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
	for i = 1, SKILL_SLOTS do
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
	local order = st.skillOrder
	if type(order) ~= "table" or #order == 0 then
		order = {1,2,3,4}
	end
	local total = #order
	for attempt = 1, total do
		local slot = order[SkillCycle.index]
		SkillCycle.index = SkillCycle.index + 1
		if SkillCycle.index > total then
			SkillCycle.index = 1
		end
		if slot and ids[slot] and slotReady("Slot"..slot) then
			if useSkill(slot) then return true end
		end
	end
	return false
end

-- ============ FISHING LOOP ============
local Fish = {
	dead = false,
	running = false,
	farm = false,
	firstPullDone = false,
	lastState = nil,
	lastCast = 0,
	lastSkill = 0,
	lastEquip = 0,
	CAST_HOLD = 0.65,
	TAP_HOLD = 0.045,
	MIN_CAST_GAP = 0.7,
	SKILL_SPACING = 0.35,
	EQUIP_DELAY = 0.35,
	FIRST_PULL_TARGET = 0.96,
}

local function runFishLoop()
	Fish.running = true
	Fish.dead = false
	while not Fish.dead do
		if not Fish.farm then task.wait(0.2) continue end
		if Tweening then task.wait(0.1) continue end
		if not LP.Character then task.wait(0.2) continue end
		if not heldRodId() and os.clock() - Fish.lastEquip >= Fish.EQUIP_DELAY then
			Fish.lastEquip = os.clock()
			if equipAnyRod() then task.wait(Fish.EQUIP_DELAY) end
		end
		local f = getController("FishingController")
		if not f then task.wait(0.25) continue end
		local ok, state = pcall(function() return f:GetState() end)
		if not ok then task.wait(0.1) continue end
		if state ~= Fish.lastState then
			if state == "FirstPull" then Fish.firstPullDone = false end
			Fish.lastState = state
		end
		if state == "Idling" then
			if os.clock() - Fish.lastCast >= Fish.MIN_CAST_GAP then
				Fish.lastCast = os.clock()
				local ctx = RS:FindFirstChild("Inputs")
				local fc = ctx and ctx:FindFirstChild("FishingContext")
				local action = fc and fc:FindFirstChild("FishingPrimary")
				if action then tap(action, Fish.CAST_HOLD) end
			else
				task.wait(0.05)
			end
		elseif state == "FirstPull" then
			local okV, value = pcall(function() return f:GetPullBarValue() end)
			if okV and not Fish.firstPullDone and value >= Fish.FIRST_PULL_TARGET then
				Fish.firstPullDone = true
				local ctx = RS:FindFirstChild("Inputs")
				local fc = ctx and ctx:FindFirstChild("FishingContext")
				local action = fc and fc:FindFirstChild("FishingPrimary")
				if action then tap(action, Fish.TAP_HOLD) end
			else
				task.wait()
			end
		elseif state == "Reeling" then
			if st.skill and os.clock() - Fish.lastSkill >= Fish.SKILL_SPACING and LP:GetAttribute("IsUsingSkill") ~= true then
				if castSkill() then Fish.lastSkill = os.clock() end
			end
			local okAuto, isAuto = pcall(function() return f:IsAutoSession() end)
			if okAuto and isAuto then
				task.wait(0.05)
			else
				local ctx = RS:FindFirstChild("Inputs")
				local fc = ctx and ctx:FindFirstChild("FishingContext")
				local action = fc and fc:FindFirstChild("FishingPrimary")
				if action then tap(action, Fish.TAP_HOLD) end
			end
		else
			task.wait(0.05)
		end
	end
	Fish.running = false
end

local minigameTask
local function startFish()
	Fish.farm = true
	if not Fish.running then task.spawn(runFishLoop) end
	if not minigameTask then
		minigameTask = task.spawn(function()
			while st.bypass or st.fish do
				scanMini()
				task.wait(0.05)
			end
			minigameTask = nil
		end)
	end
end

local function stopFish()
	Fish.farm = false
end

-- ============ SPEED ============
local function applySpeed(v)
	st.speed = v
	local c = LP.Character
	if st.speedOn and c then
		local hu = c:FindFirstChildOfClass("Humanoid")
		if hu and hu.Health > 0 then
			hu.WalkSpeed = v
		end
	end
	save()
end

local function enableSpeed(on)
	st.speedOn = on
	local c = LP.Character
	if c then
		local hu = c:FindFirstChildOfClass("Humanoid")
		if hu and hu.Health > 0 then
			hu.WalkSpeed = on and st.speed or 16
		end
	end
	save()
end

-- ============ SPOT ============
local Spot = {cframe=nil, radius=14}

local function saveSpotFile()
	if not writefile or not Spot.cframe then return end
	pcall(function()
		local p, l = Spot.cframe.Position, Spot.cframe.LookVector
		writefile(SPOTF, game:GetService("HttpService"):JSONEncode({x=p.X,y=p.Y,z=p.Z,lx=l.X,ly=l.Y,lz=l.Z}))
	end)
end

local function loadSpotFile()
	if not isfile or not isfile(SPOTF) then return end
	local ok,c = pcall(readfile,SPOTF)
	if not ok or not c or c=="" then return end
	local ok2,d = pcall(function() return game:GetService("HttpService"):JSONDecode(c) end)
	if not ok2 or type(d)~="table" then return end
	local x,y,z = tonumber(d.x),tonumber(d.y),tonumber(d.z)
	if not (x and y and z) then return end
	local pos = Vector3.new(x,y,z)
	local lv = Vector3.new(tonumber(d.lx) or 0, tonumber(d.ly) or 0, tonumber(d.lz) or 0)
	if lv.Magnitude < 0.01 then lv = Vector3.new(0,0,-1) end
	Spot.cframe = CFrame.lookAt(pos, pos + lv.Unit)
end

loadSpotFile()

local function atSpot(margin)
	if not Spot.cframe then return false, math.huge end
	local c = LP.Character
	if not c then return false, math.huge end
	local r = c:FindFirstChild("HumanoidRootPart")
	if not r then return false, math.huge end
	local d = (r.Position - Spot.cframe.Position).Magnitude
	return d <= (Spot.radius + (margin or 0)), d
end

local function saveSpot()
	local c = LP.Character
	if not c then return end
	local r = c:FindFirstChild("HumanoidRootPart")
	if not r then return end
	local look = Vector3.new(r.CFrame.LookVector.X, 0, r.CFrame.LookVector.Z)
	if look.Magnitude < 0.01 then look = Vector3.new(0,0,-1) end
	Spot.cframe = CFrame.lookAt(r.Position, r.Position + look.Unit)
	saveSpotFile()
	WindUI:Notify({Title="Spot", Content="Đã lưu vị trí câu", Duration=2})
end

local function returnToSpot()
	if not Spot.cframe then
		WindUI:Notify({Title="Spot", Content="Chưa lưu vị trí", Duration=2})
		return
	end
	task.spawn(function()
		local reached = walkTo(Spot.cframe.Position, 3, 25, function() return true end)
		if not reached then tweenTo(Spot.cframe) end
	end)
end

-- ============ FIND NPC ============
local function findNPC()
	local c = LP.Character
	if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
	local mp = c.HumanoidRootPart.Position
	local best, bd = nil, math.huge
	for _, o in ipairs(workspace:GetDescendants()) do
		local lower = string.lower(o.Name)
		if lower:find("fish_seller") then
			local p
			if o:IsA("Model") then
				p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
			elseif o:IsA("BasePart") then
				p = o
			end
			if p then
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

-- ============ AUTO LOCK ============
local LockState = {sent={}, busy=false, at=0}

local RARITY_ORDER = {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine","Secret","Exotic"}

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
		rarities = {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine"}
	end
	table.sort(rarities, function(a,b)
		local ia, ib
		for i, v in ipairs(RARITY_ORDER) do
			if v == a then ia = i end
			if v == b then ib = i end
		end
		return (ia or 99) < (ib or 99)
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

		local wantRarity = {}
		local hasAny = false
		if type(st.lockRarity) == "table" then
			for r, v in pairs(st.lockRarity) do
				if v == true then
					wantRarity[r] = true
					hasAny = true
				end
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

		local queue = {}
		local now = os.clock()
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

-- ============ LITE GRAPHICS ============
local LiteBackup = nil

local function setLite(want)
	local L = game:GetService("Lighting")
	if want then
		if not LiteBackup then
			LiteBackup = {effects={},shadows=L.GlobalShadows,diffuse=L.EnvironmentDiffuseScale,specular=L.EnvironmentSpecularScale,atmos={},clouds={}}
			for _, e in ipairs(L:GetChildren()) do
				if e:IsA("PostEffect") then LiteBackup.effects[e.Name] = e.Enabled end
				if e:IsA("Atmosphere") then LiteBackup.atmos = {density=e.Density,offset=e.Offset,haze=e.Haze,glare=e.Glare} end
				if e:IsA("Clouds") then LiteBackup.clouds = {cover=e.Cover,density=e.Density} end
			end
		end
		pcall(function()
			L.GlobalShadows=false
			L.EnvironmentDiffuseScale=0
			L.EnvironmentSpecularScale=0
		end)
		for _, e in ipairs(L:GetChildren()) do
			if e:IsA("PostEffect") then pcall(function() e.Enabled=false end)
			elseif e:IsA("Atmosphere") then pcall(function() e.Density=0 e.Offset=0 e.Haze=0 e.Glare=0 end)
			elseif e:IsA("Clouds") then pcall(function() e.Cover=0 e.Density=0 end) end
		end
		task.spawn(function()
			for _, inst in ipairs(workspace:GetDescendants()) do
				pcall(function()
					if inst:IsA("ParticleEmitter") then
						inst.Enabled=false inst.Rate=0
					elseif inst:IsA("Beam") or inst:IsA("Trail") then
						inst.Enabled=false
					elseif inst:IsA("PointLight") or inst:IsA("SurfaceLight") or inst:IsA("SpotLight") then
						inst.Enabled=false
					elseif inst:IsA("Highlight") and inst.Name ~= "DNHubBossEsp" and inst.Name ~= "DNHubNameTag" then
						inst.Enabled=false
					elseif inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
						inst.Enabled=false
					end
				end)
				task.wait()
			end
		end)
		st.liteGfx = true
	else
		if LiteBackup then
			pcall(function()
				L.GlobalShadows = LiteBackup.shadows
				L.EnvironmentDiffuseScale = LiteBackup.diffuse
				L.EnvironmentSpecularScale = LiteBackup.specular
			end)
			for _, e in ipairs(L:GetChildren()) do
				if e:IsA("PostEffect") and LiteBackup.effects[e.Name] ~= nil then
					pcall(function() e.Enabled = LiteBackup.effects[e.Name] end)
				elseif e:IsA("Atmosphere") and next(LiteBackup.atmos) then
					pcall(function()
						e.Density = LiteBackup.atmos.density
						e.Offset = LiteBackup.atmos.offset
						e.Haze = LiteBackup.atmos.haze
						e.Glare = LiteBackup.atmos.glare
					end)
				elseif e:IsA("Clouds") and next(LiteBackup.clouds) then
					pcall(function()
						e.Cover = LiteBackup.clouds.cover
						e.Density = LiteBackup.clouds.density
					end)
				end
			end
			LiteBackup = nil
		end
		st.liteGfx = false
	end
	save()
end

-- ============ SELL ============
local function doSell()
	local wf = st.fish
	if wf then Fish.farm = false task.wait(0.3) end
	local c = LP.Character
	if not c or not c:FindFirstChild("HumanoidRootPart") then
		if wf then Fish.farm = true end
		return false
	end
	local oldCF = c.HumanoidRootPart.CFrame
	local npc = findNPC()
	if not npc then
		WindUI:Notify({Title="Sell", Content="Không tìm thấy NPC", Duration=3})
		if wf then Fish.farm = true end
		return false
	end
	local standPos = npc.Position + Vector3.new(0, 3, 5)
	if st.useWalk then
		walkTo(standPos, 3, 25, function() return true end)
	else
		tweenTo(CFrame.new(standPos))
	end
	task.wait(0.4)
	local ok, coin, count = sellAll()
	if not ok then
		local pkt = RS:FindFirstChild("Stardust") and RS.Stardust:FindFirstChild("Packages") and RS.Stardust.Packages:FindFirstChild("Packet") and RS.Stardust.Packages.Packet:FindFirstChild("RemoteEvent")
		if pkt and type(buffer)=="table" then
			local cnt = 0
			local function sp(op, pl)
				cnt = (cnt+1)%256
				local b = buffer.create(2+(pl and #pl or 0))
				buffer.writeu8(b, 0, string.byte(op))
				buffer.writeu8(b, 1, cnt)
				if pl then for i=1,#pl do buffer.writeu8(b, 1+i, pl[i]) end end
				pcall(function() pkt:FireServer(b) end)
			end
			sp("c",{0x41}) task.wait(0.2)
			sp("c",{0x42,0x01}) task.wait(0.2)
			sp("c",{0x43}) task.wait(0.2)
			sp("f",{0x4A}) task.wait(0.2)
			sp("c",{0x4B}) task.wait(0.2)
			sp("\\",{0x4C}) task.wait(0.2)
			sp("c",{0x4D,0x01}) task.wait(0.2)
			sp("c",{0x4E}) task.wait(0.5)
		end
	end
	if st.useWalk then
		walkTo(oldCF.Position, 3, 25, function() return true end)
	else
		tweenTo(oldCF)
	end
	task.wait(0.3)
	if wf then Fish.farm = true end
	WindUI:Notify({Title="Sell", Content= ok and ("Bán xong! +"..tostring(coin)) or "Bán xong!", Duration=2})
	return true
end

local function startSell()
	task.spawn(function()
		while st.sell do
			for i=sellInt,1,-1 do if not st.sell then break end task.wait(1) end
			if not st.sell then break end
			doSell()
			task.wait(1)
		end
	end)
end

local function startAutoFull()
	task.spawn(function()
		while st.autoSellFull do
			local bp = LP:FindFirstChild("Backpack")
			local count = 0
			if bp then
				for _, ch in ipairs(bp:GetChildren()) do
					if not ch.Name:lower():find("rod") then count = count + 1 end
				end
			end
			if count >= 50 then
				doSell()
				task.wait(2)
			end
			task.wait(2)
		end
	end)
end

-- ============ ISLAND TELE ============
local function findIsland(n)
	local t = "island_"..n
	for _, o in ipairs(workspace:GetDescendants()) do if o.Name:lower()==t then return o end end
end

local function findSpawn(i)
	if not i then return nil end
	for _, d in ipairs(i:GetDescendants()) do if d:IsA("SpawnLocation") then return d end end
	for _, d in ipairs(i:GetDescendants()) do if d:IsA("BasePart") and d.Name:lower():find("spawn") then return d end end
	if i:IsA("Model") and i.PrimaryPart then return i.PrimaryPart end
	for _, d in ipairs(i:GetChildren()) do if d:IsA("BasePart") then return d end end
end

local function teleIsland(n)
	local i = findIsland(n)
	if not i then WindUI:Notify({Title="Tele", Content="Không tìm thấy "..n, Duration=3}) return end
	local sp = findSpawn(i)
	if not sp then WindUI:Notify({Title="Tele", Content="Không có spawn", Duration=3}) return end
	tweenTo(CFrame.new(sp.Position + Vector3.new(0,5,0)))
	task.wait(0.3)
end

-- ============ ESP ISLAND ============
local espF, espC
local function clearESP()
	if espF then pcall(function() espF:Destroy() end) espF=nil end
	if espC then pcall(function() espC:Disconnect() end) espC=nil end
end

local ISLAND_LABELS = {starter="Starter", jungle="Jungle", desert="Desert", snow="Snow", volcano="Volcano", fossil="Fossil"}

local function startESP()
	clearESP()
	espF = Instance.new("Folder") espF.Name="DNHub_ESP" espF.Parent=workspace
	for _, name in ipairs(IL) do
		local isl = findIsland(name)
		if isl then
			local part = findSpawn(isl)
			if part then
				local lb = Instance.new("BillboardGui")
				lb.Size = UDim2.new(0,200,0,40)
				lb.StudsOffset = Vector3.new(0,20,0)
				lb.AlwaysOnTop = true
				lb.Adornee = part
				lb.Parent = espF
				local tx = Instance.new("TextLabel")
				tx.Size = UDim2.new(1,0,1,0)
				tx.BackgroundTransparency = 1
				tx.Text = ISLAND_LABELS[name] or isl.Name
				tx.TextColor3 = Color3.fromRGB(255,255,255)
				tx.TextStrokeColor3 = Color3.fromRGB(0,0,0)
				tx.TextStrokeTransparency = 0
				tx.TextSize = 18
				tx.Font = Enum.Font.GothamBold
				tx.Parent = lb
			end
		end
	end
end

local function stopESP() clearESP() end

-- ============ BOSS ESP ============
local BossEspActive = nil

local function bossRegionPart(id)
	for _, inst in ipairs(Collection:GetTagged("BossRegion")) do
		if inst:GetAttribute("bossRegionId")==id then return inst end
	end
end

local function bossFxActive(region)
	local fx = region and region:FindFirstChild("BossSpawnerFX")
	return fx ~= nil and fx:GetAttribute("BossSpawnerFXActive")==true
end

local function bossRegionMeta(id)
	if not (Catalog and Catalog.BossRegion and Catalog.BossRegion.GetById) then return nil end
	local ok, entry = pcall(function() return Catalog.BossRegion.GetById(id) end)
	if not ok or type(entry) ~= "table" then return nil end
	local slot = tonumber(id:match("_(%d+)$")) or 1
	return {
		id = id,
		name = tostring(entry.name or id),
		islandId = entry.fallbackIslandId,
		slot = slot,
	}
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
				if type(id) == "string" then
					return inst, id
				end
			end
		end
	end
	return nil, nil
end

local function bossEsp()
	if not (st.bossEsp1 or st.bossEsp2) then
		clearBossEsp()
		return
	end

	local part, id = findActiveBossRegion()
	if not part or not id then
		clearBossEsp()
		return
	end

	local meta = bossRegionMeta(id)
	if not meta then
		clearBossEsp()
		return
	end

	local want = (meta.slot == 1 and st.bossEsp1) or (meta.slot == 2 and st.bossEsp2)
	if not want then
		clearBossEsp()
		return
	end

	if BossEspActive and BossEspActive.id ~= id then
		clearBossEsp()
	end

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

	if BossEspActive.gui.Adornee ~= part then
		BossEspActive.gui.Adornee = part
	end
	if BossEspActive.lbl then
		pcall(function()
			BossEspActive.lbl.Text = meta.name .. "\n" .. tostring(meta.islandId or "?")
		end)
	end
end

local function stopBossEsp()
	clearBossEsp()
end

-- ============ FAKE NAME ============
local fnR = false
local fnC = {}
local tag = nil
local tagLabel = nil
local tagColorState = {r=st.tagColorR or 0.7, g=st.tagColorG or 0.4, b=st.tagColorB or 1.0, rainbow=st.tagRainbow or false}
local humanoidRef = nil
local lastKillAt = 0
local NAME_HIDE = string.char(226,128,139)

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

	local tx = tostring(customName ~= "" and customName or LP.DisplayName)
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
	lb.TextColor3 = Color3.new(tagColorState.r, tagColorState.g, tagColorState.b)
	lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
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

local function applyTagColor()
	if not tagLabel or not tagLabel.Parent then return end
	if tagColorState.rainbow then
		local color = Color3.fromHSV((os.clock() % 12) / 12, 0.85, 1)
		pcall(function() tagLabel.TextColor3 = color end)
	else
		pcall(function() tagLabel.TextColor3 = Color3.new(tagColorState.r, tagColorState.g, tagColorState.b) end)
	end
end

local function refreshName()
	hideOriginalNames()
	if not tag or not tag.Parent or not tagLabel or not tagLabel.Parent then
		createCustomTag()
	end
	local text = tostring(customName ~= "" and customName or LP.DisplayName)
	if tagLabel and tagLabel.Parent then
		if tagLabel.Text ~= text then
			pcall(function() tagLabel.Text = text end)
		end
		applyTagColor()
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
		while st.fakename do
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

local function setTagColor(r, g, b)
	tagColorState.r = r
	tagColorState.g = g
	tagColorState.b = b
	tagColorState.rainbow = false
	st.tagColorR = r st.tagColorG = g st.tagColorB = b st.tagRainbow = false
	applyTagColor()
	save()
end

local function setTagRainbow(on)
	tagColorState.rainbow = on
	st.tagRainbow = on
	save()
end

local function updateTagText()
	if tagLabel then
		pcall(function()
			tagLabel.Text = tostring(customName ~= "" and customName or LP.DisplayName)
		end)
	end
end

-- ============ WINDUI ============
local Window = WindUI:CreateWindow({
	Title = "FM-DNHUB",
	Icon = "fish",
	Author = "DN Team",
	Folder = "DNHub",
	Size = UDim2.fromOffset(700, 480),
	Theme = "Dark",
	Transparent = true,
	Resizable = true,
	HideSearchBar = false,
	Topbar = {Height=44, ButtonsType="Mac"},
	OpenButton = {
		Title = "FM-DNHUB",
		Icon = "fish",
		CornerRadius = UDim.new(1,0),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		Color = ColorSequence.new(Color3.fromHex("#7D91FF"), Color3.fromHex("#A0B4FF")),
	},
})

local MainTab = Window:Tab({Title="Chính", Icon="user"})
local TeleTab = Window:Tab({Title="Dịch chuyển", Icon="map-pin"})
local PlrTab = Window:Tab({Title="Người chơi", Icon="users"})
local BossTab = Window:Tab({Title="Boss", Icon="swords"})
local MiscTab = Window:Tab({Title="Khác", Icon="settings"})

LP.Idled:Connect(function() pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end)
task.spawn(function() while true do pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) task.wait(30) end end)

-- ============ UI ============
local MGSection = MainTab:Section({Title="Tự động"})
MGSection:Toggle({Title="Tự động câu", Default=st.fish, Callback=function(v) st.fish=v if v then startFish() else stopFish() end save() end})
MGSection:Toggle({Title="Tự động kỹ năng", Default=st.skill, Callback=function(v) st.skill=v save() end})
MGSection:Toggle({Title="Vượt Minigame", Default=st.bypass, Callback=function(v) st.bypass=v save() end})

local SkillSection = MainTab:Section({Title="Thứ tự Skill"})
SkillSection:Input({
	Title = "Thứ tự slot (1,2,3,4 - cách dấu phẩy)",
	Value = table.concat(st.skillOrder or {1,2,1,3}, ","),
	Placeholder = "1,2,1,3",
	Callback = function(v)
		local arr = {}
		for num in tostring(v):gmatch("%d+") do
			local n = tonumber(num)
			if n and n >= 1 and n <= 4 then
				table.insert(arr, n)
			end
		end
		if #arr > 0 then
			st.skillOrder = arr
			SkillCycle.index = 1
			save()
		end
	end
})
SkillSection:Button({Title="Preset: Z,X,Z,C", Callback=function()
	st.skillOrder = {1,2,1,3}
	SkillCycle.index = 1
	save()
end})
SkillSection:Button({Title="Preset: Z,X,C,V", Callback=function()
	st.skillOrder = {1,2,3,4}
	SkillCycle.index = 1
	save()
end})
SkillSection:Button({Title="Preset: V,C,X,Z", Callback=function()
	st.skillOrder = {4,3,2,1}
	SkillCycle.index = 1
	save()
end})

local SG2Section = MainTab:Section({Title="Bán cá"})
SG2Section:Toggle({Title="Tự động bán", Default=st.sell, Callback=function(v) st.sell=v if v then startSell() end save() end})
SG2Section:Toggle({Title="Bán nếu đầy kho", Default=st.autoSellFull, Callback=function(v) st.autoSellFull=v if v then startAutoFull() end save() end})
SG2Section:Toggle({Title="Đi bộ tới NPC (thay tween)", Default=st.useWalk, Callback=function(v) st.useWalk=v save() end})
SG2Section:Slider({Title="Thời gian (giây)", Value={Min=30,Max=3600,Default=sellInt}, Step=1, Callback=function(v) sellInt=v save() end})
SG2Section:Button({Title="BÁN NGAY", Callback=function() task.spawn(doSell) end})

local SpotSection = MainTab:Section({Title="Vị trí câu"})
SpotSection:Button({Title="Lưu vị trí", Callback=function() saveSpot() end})
SpotSection:Button({Title="Về vị trí đã lưu", Callback=function() returnToSpot() end})
SpotSection:Toggle({Title="Tự về khi lệch", Default=st.autoReturn, Callback=function(v) st.autoReturn=v save() end})

local LockSection = MainTab:Section({Title="Khoá Cá🔒"})
LockSection:Toggle({
	Title = "Bật tự khoá cá",
	Default = st.autoLock,
	Callback = function(v)
		st.autoLock = v
		save()
		if v then task.spawn(autoLockPass) end
	end
})

local rarityList = getRarityList()
local function raritySetToArray(set)
	local arr = {}
	for _, r in ipairs(rarityList) do
		if type(set)=="table" and set[r] then
			table.insert(arr, r)
		end
	end
	return arr
end

LockSection:Dropdown({
	Title = "Độ hiếm muốn khoá",
	Values = rarityList,
	Multi = true,
	AllowNone = true,
	Value = raritySetToArray(st.lockRarity),
	Callback = function(picked)
		local set = {}
		if type(picked) == "table" then
			for _, r in ipairs(picked) do set[r] = true end
		elseif type(picked) == "string" then
			set[picked] = true
		end
		st.lockRarity = set
		save()
	end
})

LockSection:Button({Title="Khoá ngay", Callback=function() task.spawn(autoLockPass) end})

local TGSection = TeleTab:Section({Title="Đảo"})
TGSection:Dropdown({Title="Chọn đảo", Values=IL, Value=island, Callback=function(v) island=v save() end})
TGSection:Button({Title="DỊCH CHUYỂN", Callback=function() teleIsland(island) end})
TGSection:Toggle({Title="ESP Đảo", Default=st.esp, Callback=function(v) st.esp=v if v then startESP() else stopESP() end save() end})

local BossSection = BossTab:Section({Title="ESP Boss"})
BossSection:Toggle({Title="ESP Part 1", Default=st.bossEsp1, Callback=function(v) st.bossEsp1=v save() end})
BossSection:Toggle({Title="ESP Part 2", Default=st.bossEsp2, Callback=function(v) st.bossEsp2=v save() end})
BossSection:Button({Title="Reset ESP", Callback=function() stopBossEsp() end})

local SpeedSection = PlrTab:Section({Title="Tốc độ"})
SpeedSection:Toggle({Title="Bật tăng tốc", Default=st.speedOn, Callback=function(v) enableSpeed(v) end})
SpeedSection:Slider({Title="Tốc độ (16-200)", Value={Min=16,Max=200,Default=st.speed}, Step=1, Callback=function(v) applySpeed(v) end})
SpeedSection:Input({Title="Nhập số", Value=tostring(st.speed), Placeholder="36", Callback=function(v)
	local n = tonumber(v)
	if n and n >= 16 and n <= 500 then applySpeed(n) end
end})

local FNSection = PlrTab:Section({Title="Fake Name"})
FNSection:Toggle({
	Title = "Bật Fake Name",
	Default = st.fakename,
	Callback = function(v)
		st.fakename = v
		if v then startFake() else stopFake() end
		save()
	end
})
FNSection:Input({
	Title = "Tên hiển thị",
	Value = customName,
	Placeholder = "Nhập tên...",
	Callback = function(v)
		customName = v
		save()
		updateTagText()
	end
})
FNSection:Toggle({
	Title = "Màu cầu vồng",
	Default = st.tagRainbow,
	Callback = function(v) setTagRainbow(v) end
})
FNSection:Colorpicker({
	Title = "Màu tag",
	Default = Color3.new(st.tagColorR or 0.7, st.tagColorG or 0.4, st.tagColorB or 1.0),
	Callback = function(color) setTagColor(color.R, color.G, color.B) end
})

local MiscSection = MiscTab:Section({Title="Đồ hoạ"})
MiscSection:Toggle({Title="Giảm đồ hoạ (FPS cao)", Default=st.liteGfx, Callback=function(v) setLite(v) end})

local SysSection = MiscTab:Section({Title="Hệ thống"})
SysSection:Dropdown({
	Title = "Chế độ dịch chuyển",
	Values = {"Nhanh (70)","Bình thường (40)"},
	Value = teleMode=="fast" and "Nhanh (70)" or "Bình thường (40)",
	Callback = function(v)
		teleMode = v=="Nhanh (70)" and "fast" or "normal"
		save()
	end
})
SysSection:Toggle({Title="Auto Execute", Default=st.autoExec, Callback=function(v) st.autoExec=v save() end})
SysSection:Button({Title="Lưu cài đặt", Callback=function() save() WindUI:Notify({Title="Config", Content="Đã lưu!", Duration=2}) end})
SysSection:Button({Title="Tải cài đặt", Callback=function()
	local s = loadCfg()
	for k,v in pairs(s) do
		if type(v) == "table" then
			local copy = {}
			for kk, vv in pairs(v) do copy[kk] = vv end
			st[k] = copy
		else
			st[k] = v
		end
	end
	island = st.island or "snow"
	sellInt = st.sellInt or 300
	teleMode = st.teleMode or "fast"
	customName = st.customName or "DNHub"
	WindUI:Notify({Title="Config", Content="Đã tải!", Duration=3})
end})

MiscTab:Button({Title="Tắt Menu", Callback=function()
	st.fish=false st.bypass=false st.skill=false st.sell=false st.speedOn=false st.fakename=false st.autoSellFull=false st.esp=false
	st.bossEsp1=false st.bossEsp2=false st.liteGfx=false st.autoLock=false
	Fish.farm = false
	stopESP()
	stopBossEsp()
	stopFake()
	if LP.Character and LP.Character:FindFirstChild("Humanoid") then
		LP.Character.Humanoid.WalkSpeed=16
		LP.Character.Humanoid.JumpPower=50
	end
	-- Restore CanCollide CHỈ part chính
	local c = LP.Character
	if c then
		for _, name in ipairs(MAIN_PARTS) do
			local p = c:FindFirstChild(name)
			if p and p:IsA("BasePart") then
				p.CanCollide = true
			end
		end
		local hu = c:FindFirstChildOfClass("Humanoid")
		if hu then
			hu.AutoRotate = true
			hu.PlatformStand = false
		end
	end
	save()
	Window:Destroy()
end})

-- ============ LOOPS ============
task.spawn(function()
	while true do
		if st.bossEsp1 or st.bossEsp2 then pcall(bossEsp) end
		task.wait(1.5)
	end
end)

task.spawn(function()
	while true do
		if st.autoLock then pcall(autoLockPass) end
		task.wait(2)
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if st.autoReturn and st.fish and Spot.cframe then
			local ok = atSpot()
			if not ok and Fish.farm then pcall(returnToSpot) end
		end
	end
end)

-- ============ AUTO START ============
task.spawn(function()
	task.wait(2)
	if st.fish then startFish() end
	if st.sell then startSell() end
	if st.autoSellFull then startAutoFull() end
	if st.fakename then startFake() end
	if st.esp then startESP() end
	if st.speedOn and st.speed then applySpeed(st.speed) end
	if st.liteGfx then setLite(true) end
	if st.autoExec then pcall(function() loadstring(game:HttpGet(AEF))() end) end
end)

LP.CharacterAdded:Connect(function(c)
	c:WaitForChild("Humanoid")
	task.wait(0.5)
	if st.speedOn and st.speed then c.Humanoid.WalkSpeed = st.speed end
	if st.fish then startFish() end
	if st.fakename then
		task.wait(0.3)
		hideOriginalNames()
		createCustomTag()
	end
end)

WindUI:Notify({Title="FM-DNHUB", Content="Đã load!", Duration=4})
