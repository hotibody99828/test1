-- ==================================================
-- CHARACTER RESPAWN HANDLER (NO CONFIG)
-- ==================================================

local Player = _G.YOKUDO.Player

Player.OnCharacterAdded(function()
    task.wait(0.5)
    
    -- ==============================================
    -- AUTO BOSS FEATURES (ប្រើ Toggle ផ្ទាល់)
    -- ==============================================
    
    -- Auto Darkbeard
    if _G.YOKUDO_AutoDarkBeardEnabled then
        if _G.YOKUDO_ToggleAutoDarkBeard then
            _G.YOKUDO_ToggleAutoDarkBeard()
            print("✅ Auto Darkbeard restarted")
        end
    end
    
    -- Auto Cursed Captain
    if _G.YOKUDO_AutoCursedCaptainEnabled then
        if _G.YOKUDO_ToggleAutoCursedCaptain then
            _G.YOKUDO_ToggleAutoCursedCaptain()
            print("✅ Auto Cursed Captain restarted")
        end
    end
    
    -- Auto Core
    if _G.YOKUDO_AutoCoreEnabled then
        if _G.YOKUDO_ToggleAutoCore then
            _G.YOKUDO_ToggleAutoCore()
            print("✅ Auto Core restarted")
        end
    end
    
    -- ==============================================
    -- AUTO ABILITIES
    -- ==============================================
    
    -- Auto Buso
    if _G.YOKUDO_BusoEnabled then
        if _G.YOKUDO_ToggleAutoBuso then
            _G.YOKUDO_ToggleAutoBuso()
            print("✅ Auto Buso restarted")
        end
    end
    
    -- Auto Ken
    if _G.YOKUDO_ObservationEnabled then
        if _G.YOKUDO_ToggleAutoKen then
            _G.YOKUDO_ToggleAutoKen()
            print("✅ Auto Ken restarted")
        end
    end
    
    -- ==============================================
    -- MOVEMENT HACKS
    -- ==============================================
    
    -- Walk on Water
    if _G.YOKUDO_WalkEnabled then
        if _G.YOKUDO_ToggleWalkOnWater then
            _G.YOKUDO_ToggleWalkOnWater()
            print("✅ Walk on Water restarted")
        end
    end
    
    -- Speed Hack
    if _G.YOKUDO_SpeedEnabled then
        if _G.YOKUDO_StartSpeedLoop then
            _G.YOKUDO_StartSpeedLoop()
            print("✅ Speed Hack restarted")
        end
    end
    
    -- Jump Hack
    if _G.YOKUDO_JumpEnabled then
        if _G.YOKUDO_EnableJumpPower then
            _G.YOKUDO_EnableJumpPower()
            print("✅ Jump Hack restarted")
        end
    end
    
    -- ==============================================
    -- AUTO CLICK ATTACK
    -- ==============================================
    if _G.YOKUDO_AutoClickAttackEnabled then
        if _G.YOKUDO_ToggleAutoClickAttack then
            _G.YOKUDO_ToggleAutoClickAttack()
            print("✅ Auto Click Attack restarted")
        end
    end
    
    -- ==============================================
    -- SHOP FEATURES
    -- ==============================================
    
    -- Auto Buy Sword
    if _G.YOKUDO_AutoBuySwordEnabled then
        if _G.YOKUDO_ToggleAutoBuySword then
            _G.YOKUDO_ToggleAutoBuySword()
            print("✅ Auto Buy Sword restarted")
        end
    end
    
    -- Auto Unlock Haki
    if _G.YOKUDO_AutoUnlockHakiEnabled then
        if _G.YOKUDO_ToggleAutoUnlockHaki then
            _G.YOKUDO_ToggleAutoUnlockHaki()
            print("✅ Auto Unlock Haki restarted")
        end
    end
    
    -- ==============================================
    -- AUTO HOP FEATURES
    -- ==============================================
    
    -- Auto Hop Darkbeard
    if _G.YOKUDO_AutoHopDarkBeardEnabled then
        if _G.YOKUDO_ToggleAutoHopDarkBeard then
            _G.YOKUDO_ToggleAutoHopDarkBeard()
            print("✅ Auto Hop Darkbeard restarted")
        end
    end
    
    -- Auto Hop Cursed Captain
    if _G.YOKUDO_AutoHopCursedCaptainEnabled then
        if _G.YOKUDO_ToggleAutoHopCursedCaptain then
            _G.YOKUDO_ToggleAutoHopCursedCaptain()
            print("✅ Auto Hop Cursed Captain restarted")
        end
    end
end)

print("✅ CharacterHandler Loaded (No Config)")
