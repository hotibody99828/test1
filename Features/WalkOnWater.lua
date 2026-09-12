-- ==================================================
-- WALK ON WATER (NO CONFIG)
-- ==================================================

local Y = _G.Y
local Player = _G.YOKUDO.Player

_G.YOKUDO_WalkEnabled = false
_G.YOKUDO_WaterWalkPart = nil
_G.YOKUDO_WalkConnection = nil
_G.YOKUDO_LastX = nil
_G.YOKUDO_LastZ = nil

function enableWalkOnWater()
    if _G.YOKUDO_WaterWalkPart then return end
    local character = Player.GetCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    _G.YOKUDO_WaterWalkPart = Instance.new("Part")
    _G.YOKUDO_WaterWalkPart.Name = "WANG_WaterWalk"
    _G.YOKUDO_WaterWalkPart.Size = Vector3.new(4, 1.2, 2)
    _G.YOKUDO_WaterWalkPart.Transparency = 1
    _G.YOKUDO_WaterWalkPart.Anchored = true
    _G.YOKUDO_WaterWalkPart.CanCollide = true
    _G.YOKUDO_WaterWalkPart.Parent = Y.WS
    
    local function waitForCharacter()
        character = Player.GetCharacter() or Player.OnCharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    end
    
    waitForCharacter()
    
    _G.YOKUDO_WalkConnection = Y.RS.RenderStepped:Connect(function()
        if not _G.YOKUDO_WalkEnabled then return end
        if not character or not character.Parent then
            waitForCharacter()
            return
        end
        if not humanoidRootPart or not humanoidRootPart.Parent then
            humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
        end
        local currentPos = humanoidRootPart.Position
        if _G.YOKUDO_LastX == nil or _G.YOKUDO_LastZ == nil or math.abs(currentPos.X - _G.YOKUDO_LastX) > 0.1 or math.abs(currentPos.Z - _G.YOKUDO_LastZ) > 0.1 then
            if _G.YOKUDO_WaterWalkPart and _G.YOKUDO_WaterWalkPart.Parent then
                _G.YOKUDO_WaterWalkPart.Position = Vector3.new(currentPos.X, -5, currentPos.Z)
                _G.YOKUDO_LastX = currentPos.X
                _G.YOKUDO_LastZ = currentPos.Z
            end
        end
    end)
    
    Player.OnCharacterAdded(function(newChar)
        if not _G.YOKUDO_WalkEnabled then return end
        character = newChar
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        task.wait(0.1)
        if _G.YOKUDO_WaterWalkPart and humanoidRootPart then
            _G.YOKUDO_WaterWalkPart.Position = Vector3.new(humanoidRootPart.Position.X, -5, humanoidRootPart.Position.Z)
            _G.YOKUDO_LastX = humanoidRootPart.Position.X
            _G.YOKUDO_LastZ = humanoidRootPart.Position.Z
        end
    end)
end

function disableWalkOnWater()
    if _G.YOKUDO_WalkConnection then
        _G.YOKUDO_WalkConnection:Disconnect()
        _G.YOKUDO_WalkConnection = nil
    end
    if _G.YOKUDO_WaterWalkPart then
        _G.YOKUDO_WaterWalkPart:Destroy()
        _G.YOKUDO_WaterWalkPart = nil
    end
    _G.YOKUDO_LastX = nil
    _G.YOKUDO_LastZ = nil
end

-- ==================================================
-- TOGGLE FUNCTION (គ្មាន Config)
-- ==================================================
function _G.YOKUDO_ToggleWalkOnWater()
    _G.YOKUDO_WalkEnabled = not _G.YOKUDO_WalkEnabled
    
    if _G.YOKUDO_WalkEnabled then
        enableWalkOnWater()
        print("✅ Walk on Water: ON")
    else
        disableWalkOnWater()
        print("❌ Walk on Water: OFF")
    end
    
    -- Update UI
    if _G.YOKUDO_UpdateUI_Walk then
        _G.YOKUDO_UpdateUI_Walk(_G.YOKUDO_WalkEnabled)
    end
end

-- ==================================================
-- STATE
-- ==================================================
_G.YOKUDO_WalkEnabled = false

print("✅ WalkOnWater Loaded (No Config)")
