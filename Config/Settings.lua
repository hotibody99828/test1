-- ==================================================
-- CONFIG SETTINGS
-- ==================================================

_G.YOKUDO = {
    -- Hub Info
    Name = "YOKUDO HUB | SEA2 | [Premium]",
    Version = "FINAL",
    Author = "Yokudo",
    
    -- Asset
    AssetID = "rbxassetid://101352576986760",
    
    -- UI
    UI = {
        Width = 480,
        Height = 340,
        SidebarWidth = 115,
        TabHeight = 32,
        Theme = {
            Background = Color3.fromRGB(16, 17, 23),
            Sidebar = Color3.fromRGB(20, 21, 28),
            TopBar = Color3.fromRGB(23, 24, 32),
            Accent = Color3.fromRGB(105, 90, 190),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(145, 145, 165),
        }
    },
    
    -- Boss Positions
    Bosses = {
        Darkbeard = Vector3.new(3785, 70, -3503),
        CursedCaptain = Vector3.new(2500, 50, -2000),
    },
    
    -- Default Settings
    Defaults = {
        TweenSpeed = 250,
        AttackRange = 60,
        Speed = 16,
        Jump = 50,
        RaceV3Cooldown = 30,
    }
}

print("✅ Settings Loaded")
