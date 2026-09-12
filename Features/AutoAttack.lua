-- ==================================================
-- AUTO ATTACK FUNCTIONS (SEA3)
-- ==================================================

local Y = _G.Y
local Utils = _G.YOKUDO.Utils

function _G.YOKUDO_AttackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") then return false end
    if target.Humanoid.Health <= 0 then return false end
    
    local Net = Y.Replicated:FindFirstChild("Modules")
    if Net then Net = Net:FindFirstChild("Net") end
    if not Net then return false end
    
    local AttackEvent = Net:FindFirstChild("RE/RegisterAttack")
    local HitEvent = Net:FindFirstChild("RE/RegisterHit")
    
    if not AttackEvent or not HitEvent then return false end
    
    pcall(function()
        AttackEvent:FireServer(0.01)
    end)
    
    local hitbox = Utils.GetHitbox(target)
    if hitbox then
        local hitId = Utils.GenerateHitID()
        pcall(function()
            HitEvent:FireServer(hitbox, {}, nil, hitId)
        end)
        return true
    end
    
    return false
end

print("✅ AutoAttack Loaded")
