-- ==================================================
-- AUTO DARKBEARD (NO CONFIG) - FULL
-- ==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

-- ==================================================
-- DARKBEARD POSITION
-- ==================================================
local DARKBEARD_POSITION = Vector3.new(4267, 35, -3849)

-- ==================================================
-- TWEEN SPEED
-- ==================================================
local TWEEN_SPEED = 180

-- ==================================================
-- STATE
-- ==================================================
local isRunning = false
local loopConnection = nil
local noCollideConnection = nil
local noCollideActive = false

-- ==================================================
-- RESPAWN STATE
-- ==================================================
local hasRespawned = false
local characterAddedConnection = nil
local respawnCount = 0
local maxRespawnCount = 2

-- ==================================================
-- TWEEN TELEPORT VARIABLES
-- ==================================================
local currentTween = nil
local bodyVelocity = nil
local bodyGyro = nil
local isTweening = false
local lockConnection = nil
local isLocked = false
local currentBossPos = nil
local followConnection = nil
local bossTarget = nil
local isBossDead = false
local isTweeningToPosition = false
local bossFound = false
local isAtPosition = false
local isFollowingBoss = false

-- ==================================================
-- NO COLLIDE FUNCTIONS
-- ==================================================
local function applyNoCollide()
    local character = Player.Character
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function startNoCollide()
    if noCollideConnection then return end
    if noCollideActive then return end
    
    noCollideActive = true
    applyNoCollide()
    
    noCollideConnection = RunService.Heartbeat:Connect(function()
        if not noCollideActive then return end
        applyNoCollide()
    end)
end

local function stopNoCollide()
    noCollideActive = false
    
    if noCollideConnection then
        noCollideConnection:Disconnect()
        noCollideConnection = nil
    end
    
    local character = Player.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ==================================================
-- TWEEN TELEPORT FUNCTIONS
-- ==================================================
local function cleanupBody()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isTweening = false
    isLocked = false
    isTweeningToPosition = false
end

local function stopTweenTeleport()
    cleanupBody()
    if lockConnection then
        lockConnection:Disconnect()
        lockConnection = nil
    end
    isLocked = false
    currentBossPos = nil
    bossTarget = nil
    isTweeningToPosition = false
    stopNoCollide()
end

local function stopTweenToPosition()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isTweening = false
    isTweeningToPosition = false
    if bodyVelocity then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

local function tweenToPosition(targetPos, speed)
    local character = Player.Character
    if not character then return false end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isTweening = false
    isTweeningToPosition = true
    
    if lockConnection then
        lockConnection:Disconnect()
        lockConnection = nil
    end
    isLocked = false
    
    startNoCollide()
    
    local distance = (targetPos - root.Position).Magnitude
    if distance < 3 then 
        isTweeningToPosition = false
        if bodyVelocity then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        stopNoCollide()
        return true 
    end
    
    local duration = math.max(0.5, distance / speed)
    
    local direction = (targetPos - root.Position).Unit
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10000
        bodyVelocity.Parent = root
    end
    bodyVelocity.Velocity = direction * speed
    
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10000
        bodyGyro.Parent = root
    end
    bodyGyro.CFrame = CFrame.lookAt(root.Position, targetPos)
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    currentTween = TweenService:Create(root, tweenInfo, {
        CFrame = CFrame.new(targetPos)
    })
    
    isTweening = true
    
    currentTween:Play()
    currentTween.Completed:Wait()
    
    if bodyVelocity then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
    
    if not isTweening then
        isTweeningToPosition = false
        stopNoCollide()
        return false
    end
    
    isTweeningToPosition = false
    stopNoCollide()
    return true
end

local function tweenToBoss(bossPos, speed)
    local character = Player.Character
    if not character then return false end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isTweening = false
    isTweeningToPosition = false
    
    if lockConnection then
        lockConnection:Disconnect()
        lockConnection = nil
    end
    isLocked = false
    
    startNoCollide()
    
    local targetPos = Vector3.new(bossPos.X, bossPos.Y + 30, bossPos.Z)
    local distance = (targetPos - root.Position).Magnitude
    if distance < 3 then 
        if bodyVelocity then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        stopNoCollide()
        return true 
    end
    
    local duration = math.max(0.10, distance / speed)
    
    local direction = (targetPos - root.Position).Unit
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10000
        bodyVelocity.Parent = root
    end
    bodyVelocity.Velocity = direction * speed
    
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10000
        bodyGyro.Parent = root
    end
    bodyGyro.CFrame = CFrame.lookAt(root.Position, targetPos)
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    currentTween = TweenService:Create(root, tweenInfo, {
        CFrame = CFrame.new(targetPos)
    })
    
    isTweening = true
    
    currentTween:Play()
    currentTween.Completed:Wait()
    
    if bodyVelocity then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
    
    if not isTweening then
        stopNoCollide()
        return false
    end
    
    stopNoCollide()
    return true
end

-- ==================================================
-- RESPAWN FUNCTIONS
-- ==================================================
local function setSpawnPoint(location)
    local Event = ReplicatedStorage:FindFirstChild("Remotes")
    if Event then
        local CommF = Event:FindFirstChild("CommF_")
        if CommF then
            pcall(function()
                CommF:InvokeServer("SetLastSpawnPoint", location)
            end)
        end
    end
end

local function setSpawnPointMultiple(location)
    for i = 1, 3 do
        setSpawnPoint(location)
        task.wait(0.01)
    end
end

local function respawnPlayer(location)
    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            task.wait(0.10)
            humanoid.Health = 0
            task.wait(0.01)
            setSpawnPointMultiple(location)
            return true
        end
    end
    return false
end

local function respawnToBar()
    respawnPlayer("Bar")
end

local function respawnToIceCastle()
    respawnPlayer("IceCastle")
end

-- ==================================================
-- CHECK DISTANCE AFTER RESPAWN
-- ==================================================
local function checkDistanceAfterRespawn()
    task.wait(10)
    
    local character = Player.Character
    if not character then
        return false
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end
    
    local distance = (DARKBEARD_POSITION - root.Position).Magnitude
    
    if distance > 5000 and respawnCount < maxRespawnCount then
        return true
    end
    
    return false
end

-- ==================================================
-- AUTO RESPAWN CHECK
-- ==================================================
local function checkAndRespawn()
    if respawnCount >= maxRespawnCount then
        return false
    end
    
    local bossInStorage = ReplicatedStorage:FindFirstChild("Darkbeard")
    if not bossInStorage then
        return false
    end
    
    local character = Player.Character
    if not character then
        return false
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end
    
    local distance = (DARKBEARD_POSITION - root.Position).Magnitude
    
    if distance > 5000 then
        respawnToBar()
        respawnCount = respawnCount + 1
        
        task.wait(0.5)
        
        local function onCharacterAdded()
            if hasRespawned then
                return
            end
            
            task.wait(0.5)
            hasRespawned = true
            
            respawnToIceCastle()
            respawnCount = respawnCount + 1
            
            task.spawn(function()
                if checkDistanceAfterRespawn() then
                    if respawnCount < maxRespawnCount then
                        hasRespawned = false
                        checkAndRespawn()
                    end
                end
            end)
            
            if characterAddedConnection then
                characterAddedConnection:Disconnect()
                characterAddedConnection = nil
            end
        end
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
        characterAddedConnection = Player.CharacterAdded:Connect(onCharacterAdded)
        
        return true
    end
    
    return false
end

-- ==================================================
-- FIND DARKBEARD BOSS
-- ==================================================
local function findDarkbeard()
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        local boss = enemies:FindFirstChild("Darkbeard")
        if boss and boss:FindFirstChild("Humanoid") then
            local humanoid = boss.Humanoid
            if humanoid.Health > 0 then
                return boss, "workspace"
            else
                return nil, "dead"
            end
        end
    end
    
    local stored = ReplicatedStorage:FindFirstChild("Darkbeard")
    if stored then
        return stored, "replicatedstorage"
    end
    
    return nil, nil
end

-- ==================================================
-- MAIN LOOP
-- ==================================================
local function darkBeardLoop()
    while isRunning do
        local character = Player.Character
        if not character then
            task.wait(0.01)
            continue
        end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            task.wait(0.01)
            continue
        end
        
        checkAndRespawn()
        
        local boss, location = findDarkbeard()
        
        if not boss then
            if location == "dead" then
                if not isBossDead then
                    isBossDead = true
                    cleanupBody()
                    if followConnection then
                        followConnection:Disconnect()
                        followConnection = nil
                    end
                    isFollowingBoss = false
                    isTweeningToPosition = false
                end
                task.wait(5)
                isBossDead = false
                continue
            end
            
            bossFound = false
            isAtPosition = false
            isFollowingBoss = false
            task.wait(0.01)
            continue
        end
        
        isBossDead = false
        
        if _G.YOKUDO_EquipWeaponFromBackpack then
            local weaponType = "Melee"
            if _G.YOKUDO_AutoEquip then
                weaponType = _G.YOKUDO_AutoEquip.SelectedType
            end
            _G.YOKUDO_EquipWeaponFromBackpack(weaponType)
        end
        
        if location == "workspace" then
            if isTweeningToPosition then
                stopTweenToPosition()
                isTweeningToPosition = false
            end
            
            local bossRoot = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
            if not bossRoot then
                task.wait(0.01)
                continue
            end
            
            local bossPos = bossRoot.Position
            bossTarget = boss
            currentBossPos = bossPos
            bossFound = true
            isFollowingBoss = true
            
            local dist = (bossPos - root.Position).Magnitude
            
            if dist > 60 then
                tweenToBoss(bossPos, TWEEN_SPEED)
                
                if followConnection then
                    followConnection:Disconnect()
                    followConnection = nil
                end
                
                followConnection = RunService.Heartbeat:Connect(function()
                    if not isRunning then
                        if followConnection then
                            followConnection:Disconnect()
                            followConnection = nil
                        end
                        return
                    end
                    
                    if not bossTarget or not bossTarget.Parent then
                        return
                    end
                    
                    local bossRoot = bossTarget:FindFirstChild("HumanoidRootPart") or bossTarget:FindFirstChild("Torso")
                    if not bossRoot then return end
                    
                    local currentBossPos = bossRoot.Position
                    local char = Player.Character
                    if not char then return end
                    
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    local lockPos = Vector3.new(currentBossPos.X, currentBossPos.Y + 30, currentBossPos.Z)
                    
                    local distToLock = (lockPos - rootPart.Position).Magnitude
                    if distToLock > 5 then
                        rootPart.CFrame = CFrame.new(lockPos)
                    end
                    
                    local distToBoss = (currentBossPos - rootPart.Position).Magnitude
                    if distToBoss <= 60 then
                        if _G.YOKUDO_AttackTarget then
                            _G.YOKUDO_AttackTarget(bossTarget)
                        end
                    end
                end)
                isLocked = true
            else
                if _G.YOKUDO_AttackTarget then
                    _G.YOKUDO_AttackTarget(boss)
                end
            end
            
            task.wait(0.01)
            continue
        end
        
        if location == "replicatedstorage" then
            bossFound = false
            isAtPosition = false
            isFollowingBoss = false
            
            local distToPos = (DARKBEARD_POSITION - root.Position).Magnitude
            
            if distToPos > 5 and not isTweeningToPosition then
                tweenToPosition(DARKBEARD_POSITION, TWEEN_SPEED)
                task.wait(0.01)
            else
                isAtPosition = true
            end
            
            task.wait(0.01)
            continue
        end
    end
end

-- ==================================================
-- TOGGLE FUNCTION (គ្មាន Config)
-- ==================================================
function _G.YOKUDO_ToggleAutoDarkBeard()
    isRunning = not isRunning
    _G.YOKUDO_AutoDarkBeardEnabled = isRunning
    
    if isRunning then
        hasRespawned = false
        respawnCount = 0
        isBossDead = false
        bossFound = false
        isAtPosition = false
        isFollowingBoss = false
        isTweeningToPosition = false
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
        
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
        
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        
        loopConnection = task.spawn(darkBeardLoop)
        print("✅ Auto Darkbeard Started")
    else
        if loopConnection then
            task.cancel(loopConnection)
            loopConnection = nil
        end
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
        
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
        
        stopTweenTeleport()
        
        isBossDead = false
        bossFound = false
        isAtPosition = false
        isFollowingBoss = false
        isTweeningToPosition = false
        bossTarget = nil
        currentBossPos = nil
        isLocked = false
        
        print("❌ Auto Darkbeard Stopped")
    end
    
    -- Update UI
    if _G.YOKUDO_UpdateUI_DarkBeard then
        _G.YOKUDO_UpdateUI_DarkBeard(isRunning)
    end
end

-- ==================================================
-- STATE
-- ==================================================
_G.YOKUDO_AutoDarkBeardEnabled = false

-- ==================================================
-- CHARACTER RESPAWN HANDLER
-- ==================================================
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    stopNoCollide()
    if isRunning then
        stopTweenTeleport()
    end
end)

print("✅ AutoDarkBeard Loaded (No Config)")
