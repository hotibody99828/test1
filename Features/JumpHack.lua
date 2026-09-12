-- ==================================================
-- JUMP HACK
-- ==================================================

local Player = _G.YOKUDO.Player

_G.YOKUDO_JumpEnabled = false
_G.YOKUDO_CurrentJump = 50
_G.YOKUDO_OriginalJump = 50

function _G.YOKUDO_EnableJumpPower()
    local char = Player.GetCharacter()
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            _G.YOKUDO_OriginalJump = humanoid.JumpPower
            humanoid.JumpPower = _G.YOKUDO_CurrentJump
        end
    end
end

function _G.YOKUDO_DisableJumpPower()
    local char = Player.GetCharacter()
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = _G.YOKUDO_OriginalJump
        end
    end
end

function _G.YOKUDO_ToggleJumpHack()
    _G.YOKUDO_JumpEnabled = not _G.YOKUDO_JumpEnabled
    if _G.YOKUDO_JumpEnabled then
        if _G.YOKUDO_JumpTextBoxValue then
            _G.YOKUDO_CurrentJump = _G.YOKUDO_JumpTextBoxValue
        end
        _G.YOKUDO_EnableJumpPower()
    else
        _G.YOKUDO_DisableJumpPower()
    end
end

function _G.YOKUDO_UpdateJumpValue(value)
    local val = tonumber(value)
    if val then
        _G.YOKUDO_CurrentJump = math.clamp(val, 50, 300)
        _G.YOKUDO_JumpTextBoxValue = _G.YOKUDO_CurrentJump
        if _G.YOKUDO_JumpEnabled then
            _G.YOKUDO_DisableJumpPower()
            _G.YOKUDO_EnableJumpPower()
        end
    end
end

print("✅ JumpHack Loaded")
