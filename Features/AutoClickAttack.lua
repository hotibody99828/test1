-- ==================================================
-- AUTO CLICK ATTACK LOOP (NO CONFIG)
-- ==================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

_G.YOKUDO_AutoClickAttackEnabled = false
_G.YOKUDO_ClickAttackLoopConnection = nil

-- ==================================================
-- CONFIG
-- ==================================================
local CONFIG = {
    Range = 60,
    AttackDelay = 0.01,
    TargetPlayers = true,
    TargetMobs = true,
}

-- ==================================================
-- GET ALL MOBS
-- ==================================================
local function GetAllMobs()
    local Mobs = {}
    local Enemies = workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, Mob in ipairs(Enemies:GetChildren()) do
            if Mob:FindFirstChild("Humanoid") then
                local humanoid = Mob.Humanoid
                if humanoid.Health > 0 then
                    table.insert(Mobs, Mob)
                end
            end
        end
    end
    return Mobs
end

-- ==================================================
-- GET ALL PLAYERS
-- ==================================================
local function GetAllPlayers()
    local Targets = {}
    for _, Plr in ipairs(Players:GetPlayers()) do
        if Plr ~= Player then
            local Char = Plr.Character
            if Char and Char:FindFirstChild("Humanoid") then
                local humanoid = Char.Humanoid
                if humanoid.Health > 0 then
                    table.insert(Targets, Char)
                end
            end
        end
    end
    return Targets
end

-- ==================================================
-- GET ALL TARGETS (Nearest First)
-- ==================================================
local function GetAllTargets()
    local Targets = {}
    local character = Player.Character
    if not character then return Targets end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return Targets end
    
    -- Mobs
    if CONFIG.TargetMobs then
        local Mobs = GetAllMobs()
        for _, Mob in ipairs(Mobs) do
            local mobRoot = Mob:FindFirstChild("HumanoidRootPart") or Mob:FindFirstChild("Torso")
            if mobRoot then
                local dist = (mobRoot.Position - root.Position).Magnitude
                if dist <= CONFIG.Range then
                    table.insert(Targets, {
                        Object = Mob,
                        Type = "Mob",
                        Distance = dist,
                    })
                end
            end
        end
    end
    
    -- Players
    if CONFIG.TargetPlayers then
        local PlayersList = GetAllPlayers()
        for _, Char in ipairs(PlayersList) do
            local charRoot = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Torso")
            if charRoot then
                local dist = (charRoot.Position - root.Position).Magnitude
                if dist <= CONFIG.Range then
                    table.insert(Targets, {
                        Object = Char,
                        Type = "Player",
                        Distance = dist,
                    })
                end
            end
        end
    end
    
    -- Sort by distance (nearest first)
    table.sort(Targets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return Targets
end

-- ==================================================
-- GET HITBOX
-- ==================================================
local function GetHitbox(Target)
    local Parts = {"HumanoidRootPart", "Torso", "Head", "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg", "LeftArm", "RightArm"}
    for _, partName in ipairs(Parts) do
        local part = Target:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return Target:FindFirstChildOfClass("BasePart")
end

-- ==================================================
-- GENERATE HIT ID
-- ==================================================
local function GenerateHitID()
    local chars = "0123456789abcdef"
    local id = ""
    for i = 1, 8 do
        id = id .. string.sub(chars, math.random(1, 16), math.random(1, 16))
    end
    return id
end

-- ==================================================
-- ATTACK TARGET
-- ==================================================
local function AttackTarget(TargetData)
    local Target = TargetData.Object
    
    if not Target or not Target:FindFirstChild("Humanoid") then 
        return false 
    end
    if Target.Humanoid.Health <= 0 then 
        return false 
    end
    
    -- Find Remote Events
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Net = ReplicatedStorage:FindFirstChild("Modules")
    if Net then 
        Net = Net:FindFirstChild("Net") 
    end
    if not Net then 
        return false 
    end
    
    local AttackEvent = Net:FindFirstChild("RE/RegisterAttack")
    local HitEvent = Net:FindFirstChild("RE/RegisterHit")
    
    if not AttackEvent or not HitEvent then 
        return false 
    end
    
    -- Fire Attack
    pcall(function()
        AttackEvent:FireServer(0.01)
    end)
    
    -- Get Hitbox and Fire Hit
    local hitbox = GetHitbox(Target)
    if hitbox then
        local hitId = GenerateHitID()
        pcall(function()
            HitEvent:FireServer(hitbox, {}, nil, hitId)
        end)
        return true
    end
    
    return false
end

-- ==================================================
-- MAIN ATTACK LOOP
-- ==================================================
local function clickAttackLoop()
    while _G.YOKUDO_AutoClickAttackEnabled do
        local character = Player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            continue
        end
        
        local Targets = GetAllTargets()
        if #Targets > 0 then
            AttackTarget(Targets[1])  -- Attack nearest target
        end
        
        task.wait(CONFIG.AttackDelay)  -- 0.01s
    end
end

-- ==================================================
-- TOGGLE FUNCTION (គ្មាន Config)
-- ==================================================
function _G.YOKUDO_ToggleAutoClickAttack()
    _G.YOKUDO_AutoClickAttackEnabled = not _G.YOKUDO_AutoClickAttackEnabled
    
    if _G.YOKUDO_AutoClickAttackEnabled then
        if _G.YOKUDO_ClickAttackLoopConnection then
            _G.YOKUDO_ClickAttackLoopConnection:Disconnect()
            _G.YOKUDO_ClickAttackLoopConnection = nil
        end
        _G.YOKUDO_ClickAttackLoopConnection = task.spawn(clickAttackLoop)
        print("✅ Auto Click Attack: ON (Range: 60m, Speed: 0.01s)")
    else
        if _G.YOKUDO_ClickAttackLoopConnection then
            task.cancel(_G.YOKUDO_ClickAttackLoopConnection)
            _G.YOKUDO_ClickAttackLoopConnection = nil
        end
        print("❌ Auto Click Attack: OFF")
    end
    
    -- Update UI
    if _G.YOKUDO_UpdateUI_ClickAttack then
        _G.YOKUDO_UpdateUI_ClickAttack(_G.YOKUDO_AutoClickAttackEnabled)
    end
end

-- ==================================================
-- STATE
-- ==================================================
_G.YOKUDO_AutoClickAttackEnabled = false

print("✅ AutoClickAttack Loaded (No Config)")
