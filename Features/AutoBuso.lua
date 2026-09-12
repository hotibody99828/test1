-- ==================================================
-- AUTO BUSO HAKI (NO CONFIG) - AUTO START ON
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

-- ==================================================
-- STATE (កំណត់ true ដំបូង)
-- ==================================================
_G.YOKUDO_BusoEnabled = true
_G.YOKUDO_BusoLoopConnection = nil
_G.YOKUDO_BusoCharConnection = nil

-- ==================================================
-- CHECK BUSO
-- ==================================================
local function IsBusoOn()
    local username = Player.Name
    local character = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(username)
    if character then
        return character:FindFirstChild("HasBuso") ~= nil
    end
    return false
end

-- ==================================================
-- TURN ON BUSO
-- ==================================================
local function TurnOnBuso()
    local Remote = ReplicatedStorage:FindFirstChild("Remotes")
    if Remote then
        local CommF = Remote:FindFirstChild("CommF_")
        if CommF then
            pcall(function()
                CommF:InvokeServer("Buso")
            end)
        end
    end
end

-- ==================================================
-- START AUTO BUSO
-- ==================================================
function startAutoBuso()
    if _G.YOKUDO_BusoLoopConnection then return end
    
    -- Turn on Buso immediately
    TurnOnBuso()
    
    -- Loop to keep Buso on
    _G.YOKUDO_BusoLoopConnection = RunService.Stepped:Connect(function()
        if not _G.YOKUDO_BusoEnabled then return end
        if not IsBusoOn() then
            TurnOnBuso()
        end
    end)
    
    -- Restart on respawn
    _G.YOKUDO_BusoCharConnection = Player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.YOKUDO_BusoEnabled then 
            TurnOnBuso() 
        end
    end)
end

-- ==================================================
-- STOP AUTO BUSO
-- ==================================================
function stopAutoBuso()
    if _G.YOKUDO_BusoLoopConnection then 
        _G.YOKUDO_BusoLoopConnection:Disconnect() 
        _G.YOKUDO_BusoLoopConnection = nil 
    end
    if _G.YOKUDO_BusoCharConnection then 
        _G.YOKUDO_BusoCharConnection:Disconnect() 
        _G.YOKUDO_BusoCharConnection = nil 
    end
end

-- ==================================================
-- TOGGLE FUNCTION (សម្រាប់ User ចុច)
-- ==================================================
function _G.YOKUDO_ToggleAutoBuso()
    _G.YOKUDO_BusoEnabled = not _G.YOKUDO_BusoEnabled
    
    if _G.YOKUDO_BusoEnabled then
        startAutoBuso()
        print("✅ Auto Buso: ON")
    else
        stopAutoBuso()
        print("❌ Auto Buso: OFF")
    end
    
    -- Update UI
    if _G.YOKUDO_UpdateUI_Buso then
        _G.YOKUDO_UpdateUI_Buso(_G.YOKUDO_BusoEnabled)
    end
end

-- ==================================================
-- ⭐ AUTO START (ចាប់ផ្ដើមភ្លាមៗ)
-- ==================================================
task.spawn(function()
    -- រង់ចាំ Character Loaded
    repeat task.wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    -- ចាប់ផ្ដើម Auto Buso
    if _G.YOKUDO_BusoEnabled then
        startAutoBuso()
        print("✅ Auto Buso started automatically (ON)")
    end
end)

-- ==================================================
-- UPDATE UI STATE (ឲ្យ UI បង្ហាញ ON)
-- ==================================================
task.spawn(function()
    task.wait(0.5)
    if _G.YOKUDO_UpdateUI_Buso then
        _G.YOKUDO_UpdateUI_Buso(true)
    end
end)

print("✅ AutoBuso Loaded (No Config - Auto Start ON)")
