-- ==================================================
-- AUTO UNLOCK HAKI LEGENDARY (NO CONFIG)
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

-- ==================================================
-- TOGGLE DEBOUNCE
-- ==================================================
local isToggling = false
local toggleLock = false
local isFeatureRunning = false

-- ==================================================
-- STATE
-- ==================================================
_G.YOKUDO_AutoUnlockHakiEnabled = false
_G.YOKUDO_AutoUnlockHakiLoop = nil

-- ==================================================
-- UNLOCK HAKI FUNCTION
-- ==================================================
local function unlockHaki()
    pcall(function()
        local args = {
            "ColorsDealer",
            "2"
        }
        local Remote = ReplicatedStorage:FindFirstChild("Remotes")
        if Remote then
            local CommF = Remote:FindFirstChild("CommF_")
            if CommF then
                CommF:InvokeServer(unpack(args))
            end
        end
    end)
end

-- ==================================================
-- AUTO UNLOCK HAKI LOOP
-- ==================================================
local function unlockHakiLoop()
    isFeatureRunning = true
    
    while _G.YOKUDO_AutoUnlockHakiEnabled do
        unlockHaki()
        task.wait(0.05)
    end
    
    isFeatureRunning = false
end

-- ==================================================
-- TOGGLE FUNCTION (គ្មាន Config)
-- ==================================================
function _G.YOKUDO_ToggleAutoUnlockHaki()
    if toggleLock then
        print("⏳ Please wait, toggling in progress...")
        return
    end
    
    if isToggling then
        return
    end
    
    isToggling = true
    toggleLock = true
    
    _G.YOKUDO_AutoUnlockHakiEnabled = not _G.YOKUDO_AutoUnlockHakiEnabled
    
    if _G.YOKUDO_AutoUnlockHakiEnabled then
        if isFeatureRunning then
            print("⚠️ Auto Unlock Haki is already running!")
            isToggling = false
            toggleLock = false
            return
        end
        
        if _G.YOKUDO_AutoUnlockHakiLoop then
            _G.YOKUDO_AutoUnlockHakiLoop:Disconnect()
            _G.YOKUDO_AutoUnlockHakiLoop = nil
        end
        
        _G.YOKUDO_AutoUnlockHakiLoop = task.spawn(unlockHakiLoop)
        print("✅ Auto Unlock Haki: ON")
    else
        if _G.YOKUDO_AutoUnlockHakiLoop then
            task.cancel(_G.YOKUDO_AutoUnlockHakiLoop)
            _G.YOKUDO_AutoUnlockHakiLoop = nil
        end
        
        isFeatureRunning = false
        print("❌ Auto Unlock Haki: OFF")
    end
    
    -- Update UI
    if _G.YOKUDO_UpdateUI_UnlockHaki then
        _G.YOKUDO_UpdateUI_UnlockHaki(_G.YOKUDO_AutoUnlockHakiEnabled)
    end
    
    task.wait(0.3)
    isToggling = false
    toggleLock = false
end

-- ==================================================
-- STATE
-- ==================================================
_G.YOKUDO_AutoUnlockHakiEnabled = false

-- ==================================================
-- CHARACTER RESPAWN HANDLER
-- ==================================================
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if _G.YOKUDO_AutoUnlockHakiEnabled then
        if _G.YOKUDO_AutoUnlockHakiLoop then
            task.cancel(_G.YOKUDO_AutoUnlockHakiLoop)
            _G.YOKUDO_AutoUnlockHakiLoop = nil
        end
        _G.YOKUDO_AutoUnlockHakiLoop = task.spawn(unlockHakiLoop)
    end
end)

print("✅ AutoUnlockHaki Loaded (No Config)")
