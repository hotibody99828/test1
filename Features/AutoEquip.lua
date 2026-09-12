-- ==================================================
-- AUTO EQUIP SYSTEM
-- ==================================================

local Player = _G.YOKUDO.Player
local Utils = _G.YOKUDO.Utils

_G.YOKUDO_AutoEquip = {
    SelectedType = "Melee",
    SelectedName = nil,
    Enabled = false,
    Loop = nil,
    IsEquipping = false,
}

local function FindWeaponInBackpack(weaponType)
    local backpack = Player.GetBackpack()
    if not backpack then return nil end
    for _, item in ipairs(backpack:GetChildren()) do
        local tooltip = Utils.GetToolTip(item)
        if tooltip == weaponType then
            return item
        end
    end
    return nil
end

local function EquipWeapon(item)
    if not item then return false end
    if _G.YOKUDO_AutoEquip.IsEquipping then return false end
    _G.YOKUDO_AutoEquip.IsEquipping = true
    
    local char = Player.GetCharacter()
    if not char then
        _G.YOKUDO_AutoEquip.IsEquipping = false
        return false
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        _G.YOKUDO_AutoEquip.IsEquipping = false
        return false
    end
    
    local backpack = Player.GetBackpack()
    
    if item.Parent == backpack then
        item.Parent = char
        task.wait(0.05)
        humanoid:EquipTool(item)
        _G.YOKUDO_AutoEquip.SelectedName = item.Name
        _G.YOKUDO_AutoEquip.IsEquipping = false
        return true
    elseif item.Parent == char then
        humanoid:EquipTool(item)
        _G.YOKUDO_AutoEquip.SelectedName = item.Name
        _G.YOKUDO_AutoEquip.IsEquipping = false
        return true
    else
        _G.YOKUDO_AutoEquip.IsEquipping = false
        return false
    end
end

function _G.YOKUDO_EquipWeaponFromBackpack(weaponType)
    local weapon = FindWeaponInBackpack(weaponType)
    if weapon then
        return EquipWeapon(weapon)
    end
    return false
end


