-- ==================================================
-- SPEED HACK
-- ==================================================
_G.YOKUDO_EnablePrint = false  -- false = បិទ, true = បើក

local oldPrint = print
print = function(...)
    if _G.YOKUDO_EnablePrint then
        oldPrint(...)
    end
end
local Y = _G.Y
local Player = _G.YOKUDO.Player
local Settings = _G.YOKUDO

-- ==================================================
-- STATE
-- ==================================================
_G.YOKUDO_SpeedEnabled = false
_G.YOKUDO_CurrentSpeed = 16
_G.YOKUDO_SpeedLoopConnection = nil

-- ==================================================
-- START SPEED LOOP
-- ==================================================
function _G.YOKUDO_StartSpeedLoop()
    if _G.YOKUDO_SpeedLoopConnection then return end
    _G.YOKUDO_SpeedLoopConnection = Y.RS.RenderStepped:Connect(function()
        if not _G.YOKUDO_SpeedEnabled then return end
        local char = Player.GetCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= _G.YOKUDO_CurrentSpeed then
                humanoid.WalkSpeed = _G.YOKUDO_CurrentSpeed
            end
        end
    end)
end

-- ==================================================
-- STOP SPEED LOOP
-- ==================================================
function _G.YOKUDO_StopSpeedLoop()
    if _G.YOKUDO_SpeedLoopConnection then
        _G.YOKUDO_SpeedLoopConnection:Disconnect()
        _G.YOKUDO_SpeedLoopConnection = nil
    end
    local char = Player.GetCharacter()
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

-- ==================================================
-- TOGGLE
-- ==================================================
function _G.YOKUDO_ToggleSpeedHack()
    _G.YOKUDO_SpeedEnabled = not _G.YOKUDO_SpeedEnabled
    if _G.YOKUDO_SpeedEnabled then
        if _G.YOKUDO_SpeedTextBoxValue then
            _G.YOKUDO_CurrentSpeed = _G.YOKUDO_SpeedTextBoxValue
        end
        _G.YOKUDO_StartSpeedLoop()
    else
        _G.YOKUDO_StopSpeedLoop()
    end
end

-- ==================================================
-- UPDATE SPEED VALUE
-- ==================================================
function _G.YOKUDO_UpdateSpeedValue(value)
    local val = tonumber(value)
    if val then
        _G.YOKUDO_CurrentSpeed = math.clamp(val, 16, 350)
        _G.YOKUDO_SpeedTextBoxValue = _G.YOKUDO_CurrentSpeed
        if _G.YOKUDO_SpeedEnabled then
            if _G.YOKUDO_SpeedLoopConnection then 
                _G.YOKUDO_SpeedLoopConnection:Disconnect() 
                _G.YOKUDO_SpeedLoopConnection = nil 
            end
            _G.YOKUDO_StartSpeedLoop()
        end
    end
end

-- ==================================================
-- CHARACTER RESPAWN
-- ==================================================
Player.OnCharacterAdded(function()
    task.wait(0.5)
    if _G.YOKUDO_SpeedEnabled then
        _G.YOKUDO_StartSpeedLoop()
    end
end)

print("✅ SpeedHack Loaded")
