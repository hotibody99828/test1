-- ==================================================
-- UTILITY FUNCTIONS
-- ==================================================

_G.YOKUDO.Utils = {
    -- Generate Hit ID
    GenerateHitID = function()
        local chars = "0123456789abcdef"
        local id = ""
        for i = 1, 8 do
            id = id .. string.sub(chars, math.random(1, 16), math.random(1, 16))
        end
        return id
    end,
    
    -- Get Hitbox
    GetHitbox = function(target)
        local parts = {"HumanoidRootPart", "Torso", "Head", "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg", "LeftArm", "RightArm"}
        for _, partName in ipairs(parts) do
            local part = target:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                return part
            end
        end
        return target:FindFirstChildOfClass("BasePart")
    end,
    
    -- Get ToolTip
    GetToolTip = function(item)
        local success, value = pcall(function()
            return item.ToolTip
        end)
        if success and value ~= nil and value ~= "" then
            return value
        end
        return ""
    end,
    
    -- Clamp
    Clamp = function(value, min, max)
        return math.max(min, math.min(max, value))
    end,
    
    -- Distance
    Distance = function(pos1, pos2)
        return (pos1 - pos2).Magnitude
    end,
}

print("✅ Utils Loaded")
