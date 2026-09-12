-- ==================================================
-- PLAYER MANAGER
-- ==================================================

local Services = _G.YOKUDO.Services
local Player = Services.Players.LocalPlayer

_G.YOKUDO.Player = {
    Local = Player,
    
    GetCharacter = function()
        return Player.Character
    end,
    
    GetHumanoid = function()
        local char = Player.Character
        if char then
            return char:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end,
    
    GetRootPart = function()
        local char = Player.Character
        if char then
            return char:FindFirstChild("HumanoidRootPart")
        end
        return nil
    end,
    
    GetBackpack = function()
        return Player:FindFirstChild("Backpack")
    end,
    
    IsAlive = function()
        local humanoid = _G.YOKUDO.Player.GetHumanoid()
        if humanoid then
            return humanoid.Health > 0
        end
        return false
    end,
    
    OnCharacterAdded = function(callback)
        Player.CharacterAdded:Connect(callback)
    end,
}

print("✅ Player Manager Loaded")
