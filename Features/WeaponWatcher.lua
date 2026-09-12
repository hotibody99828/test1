-- ==================================================
-- WEAPON SELECTOR WATCHER (SEA2) - NO CONFIG
-- ==================================================

local AutoHopPage = _G.YOKUDO_AutoHopPage

-- ==================================================
-- ⭐ UPDATE WEAPON BUTTON (សម្រាប់ UI Update)
-- ==================================================
function _G.YOKUDO_UpdateWeaponButton(weaponType)
    if not AutoHopPage then 
        print("⚠️ AutoHopPage not ready!")
        return 
    end
    
    for _, child in ipairs(AutoHopPage:GetDescendants()) do
        if child.Name == "WeaponButton" then
            child.Text = weaponType
            print("✅ Weapon Button updated to: " .. weaponType)
            return
        end
    end
end

-- ==================================================
-- ⭐ SET WEAPON TYPE (សម្រាប់ UI Update - មិន Equip)
-- ==================================================
function _G.YOKUDO_SetWeaponType(weaponType)
    if not weaponType or weaponType == "" then
        weaponType = "Melee"
    end
    
    if _G.YOKUDO_AutoEquip then
        _G.YOKUDO_AutoEquip.SelectedType = weaponType
    end
    
    -- Update UI
    if _G.YOKUDO_UpdateWeaponButton then
        _G.YOKUDO_UpdateWeaponButton(weaponType)
    end
    
    print("✅ Weapon Type set to: " .. weaponType .. " (UI Updated)")
end

-- ==================================================
-- WATCH DROPDOWN (តាមដានការផ្លាស់ប្ដូរ - មិន Equip)
-- ==================================================
local function setupWeaponSelectorWatcher()
    task.wait(0.5)
    local weaponButton = nil
    if AutoHopPage then
        for _, child in ipairs(AutoHopPage:GetDescendants()) do
            if child.Name == "WeaponButton" then
                weaponButton = child
                break
            end
        end
    end
    
    if weaponButton then
        weaponButton:GetPropertyChangedSignal("Text"):Connect(function()
            local newType = weaponButton.Text
            if newType ~= _G.YOKUDO_AutoEquip.SelectedType then
                _G.YOKUDO_AutoEquip.SelectedType = newType
                print("✅ Weapon Type changed to: " .. newType)
            end
        end)
    else
        -- Retry if not found
        task.spawn(function()
            task.wait(1)
            setupWeaponSelectorWatcher()
        end)
    end
end

task.spawn(function()
    task.wait(1)
    setupWeaponSelectorWatcher()
end)

print("✅ WeaponWatcher Loaded (No Config - Watch Only)")
