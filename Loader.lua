-- ==================================================
-- YOKUDO HUB | SEA2 | [Premium] | Loader (NO CONFIG - CLEAN)
-- ==================================================

local BASE_URL = "https://raw.githubusercontent.com/hotibody99828/dodonana98/main/"

_G.YOKUDO_EnablePrint = false

local oldPrint = print
print = function(...)
    if _G.YOKUDO_EnablePrint then
        oldPrint(...)
    end
end

print("🔵 Loading YOKUDO HUB | SEA2 | [Premium]...")

-- ==================================================
-- ⭐ CACHE SYSTEM
-- ==================================================
_G.YOKUDO_Cache = _G.YOKUDO_Cache or {}

local function GetScript(path)
    local fullPath = BASE_URL .. path
    if _G.YOKUDO_Cache[fullPath] then
        return _G.YOKUDO_Cache[fullPath]
    end
    local script = game:HttpGet(fullPath)
    _G.YOKUDO_Cache[fullPath] = script
    return script
end

-- ==================================================
-- WAIT UNTIL GAME IS LOADED
-- ==================================================
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

print("✅ Game loaded, Player: " .. Player.Name)

-- ==================================================
-- ⭐ CREATE CLEAN LOADING SCREEN (តែ Progress Bar + %)
-- ==================================================
local function CreateLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.ResetOnSpawn = false
    LoadingGui.IgnoreGuiInset = true
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadingGui.DisplayOrder = 9999
    LoadingGui.Parent = CoreGui

    -- Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 280, 0, 110)
    Container.Position = UDim2.new(0.5, -140, 0.5, -55)
    Container.BackgroundColor3 = Color3.fromRGB(16, 17, 23)
    Container.BackgroundTransparency = 0.1
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Parent = LoadingGui

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 14)
    ContainerCorner.Parent = Container

    local ContainerBorder = Instance.new("UIStroke")
    ContainerBorder.Color = Color3.fromRGB(105, 90, 190)
    ContainerBorder.Thickness = 2
    ContainerBorder.Transparency = 0.2
    ContainerBorder.Parent = Container

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -30, 0, 28)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "YOKUDO HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Container

    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -30, 0, 14)
    Subtitle.Position = UDim2.new(0, 15, 0, 36)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "SEA2 | [Premium]"
    Subtitle.TextColor3 = Color3.fromRGB(145, 145, 175)
    Subtitle.TextSize = 9
    Subtitle.TextXAlignment = Enum.TextXAlignment.Center
    Subtitle.TextYAlignment = Enum.TextYAlignment.Center
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.Parent = Container

    -- Loading Bar Background
    local BarBg = Instance.new("Frame")
    BarBg.Name = "BarBg"
    BarBg.Size = UDim2.new(0.75, 0, 0, 4)
    BarBg.Position = UDim2.new(0.125, 0, 0.5, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    BarBg.BorderSizePixel = 0
    BarBg.Parent = Container

    local BarBgCorner = Instance.new("UICorner")
    BarBgCorner.CornerRadius = UDim.new(1, 0)
    BarBgCorner.Parent = BarBg

    -- Loading Bar
    local Bar = Instance.new("Frame")
    Bar.Name = "Bar"
    Bar.Size = UDim2.new(0, 0, 1, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    Bar.BorderSizePixel = 0
    Bar.Parent = BarBg

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    -- ⭐ Percent ONLY (គ្មាន Status Text)
    local Percent = Instance.new("TextLabel")
    Percent.Name = "Percent"
    Percent.Size = UDim2.new(1, -30, 0, 22)
    Percent.Position = UDim2.new(0, 15, 0.7, 0)
    Percent.BackgroundTransparency = 1
    Percent.Text = "0%"
    Percent.TextColor3 = Color3.fromRGB(105, 90, 190)
    Percent.TextSize = 18
    Percent.TextXAlignment = Enum.TextXAlignment.Center
    Percent.TextYAlignment = Enum.TextYAlignment.Center
    Percent.Font = Enum.Font.GothamBold
    Percent.Parent = Container

    local function UpdateProgress(percent)
        percent = math.clamp(percent, 0, 100)
        Bar.Size = UDim2.new(percent / 100, 0, 1, 0)
        Percent.Text = math.floor(percent) .. "%"
    end

    return {
        Gui = LoadingGui,
        Update = UpdateProgress,
        Destroy = function()
            LoadingGui:Destroy()
        end
    }
end

-- ==================================================
-- ⭐ CREATE LOADING SCREEN
-- ==================================================
local Loading = CreateLoadingScreen()
Loading.Update(5)

-- ==================================================
-- AUTO JOIN MARINES
-- ==================================================
if _G.YOKUDO_HasJoinedMarines == nil then
    _G.YOKUDO_HasJoinedMarines = false
end

task.spawn(function()
    local success = pcall(function()
        ReplicatedStorage:WaitForChild("Remotes", 5)
    end)
    
    if success and not _G.YOKUDO_HasJoinedMarines then
        pcall(function()
            local args = {"SetTeam2", "Marines"}
            local Remote = ReplicatedStorage:FindFirstChild("Remotes")
            if Remote then
                local CommF = Remote:FindFirstChild("CommF_")
                if CommF then
                    CommF:InvokeServer(unpack(args))
                    _G.YOKUDO_HasJoinedMarines = true
                    print("⚓ Joined Team Marines!")
                end
            end
        end)
    end
end)

Player.CharacterAdded:Connect(function()
    if _G.YOKUDO_HasJoinedMarines then return end
    task.wait(0.5)
    if not _G.YOKUDO_HasJoinedMarines then
        pcall(function()
            local args = {"SetTeam2", "Marines"}
            local Remote = ReplicatedStorage:FindFirstChild("Remotes")
            if Remote then
                local CommF = Remote:FindFirstChild("CommF_")
                if CommF then
                    CommF:InvokeServer(unpack(args))
                    _G.YOKUDO_HasJoinedMarines = true
                    print("⚓ Joined Team Marines! (After Respawn)")
                end
            end
        end)
    end
end)

-- ==================================================
-- LOAD CONFIG & CORE
-- ==================================================
Loading.Update(10)
loadstring(GetScript("Config/Settings.lua"))()
Loading.Update(20)
loadstring(GetScript("Core/Services.lua"))()
Loading.Update(30)
loadstring(GetScript("Core/Player.lua"))()
Loading.Update(40)
loadstring(GetScript("Core/Utils.lua"))()

-- ==================================================
-- LOAD UI & TABS
-- ==================================================
task.spawn(function()
    Loading.Update(50)
    loadstring(GetScript("UI/Toggle.lua"))()
    Loading.Update(58)
    loadstring(GetScript("UI/Main.lua"))()
    Loading.Update(65)
    loadstring(GetScript("UI/Components.lua"))()
    Loading.Update(72)
    loadstring(GetScript("UI/Drag.lua"))()
    Loading.Update(80)
    loadstring(GetScript("UI/Tabs.lua"))()
    Loading.Update(85)
    print("✅ UI & Tabs Loaded")
end)

-- ==================================================
-- LOAD FEATURES (Parallel)
-- ==================================================
task.spawn(function()
    local Features = {
        -- ===== HUB FEATURES =====
        "SpeedHack",
        "JumpHack",
        "AutoEquip",
        "AutoAttack",
        "AutoClickAttack",
        "WalkOnWater",
        "AutoBuso",
        "AutoKen",
        "AutoUnlockHaki",
        "JoinServer",
        "AutoDarkBeard",
        "AutoHopDarkBeard",
        "AutoCursedCaptain",
        "AutoHopCursedCaptain",
        "AutoCore",
        "AutoBuySword",
        "CharacterHandler",
        "WeaponWatcher",
        
        -- ===== SERVER CHECKER FEATURES =====
        "HakiLegendaryChecker",
        "SwordLegendaryChecker",
        "DarkBeardChecker",
        "CursedCaptainChecker",
        "CoreChecker",
        "FruitChecker",
        "BerryChecker"
    }
    
    local total = #Features
    local loaded = 0
    
    -- ⭐ ផ្ទុក Features ទាំងអស់ក្នុងពេលតែមួយ
    local threads = {}
    for _, Feature in ipairs(Features) do
        table.insert(threads, task.spawn(function()
            pcall(function()
                loadstring(GetScript("Features/" .. Feature .. ".lua"))()
            end)
            loaded = loaded + 1
            local percent = 85 + (loaded / total * 15)
            Loading.Update(percent)
        end))
    end
    
    -- រង់ចាំផ្ទុកទាំងអស់រួច
    for _, thread in ipairs(threads) do
        task.wait(0.01)
    end
    
    print("✅ All Features Loaded")
    Loading.Update(100)
    
    task.wait(0.3)
    Loading.Destroy()
    print("✅ Loading Screen Closed!")
    print("🚀 YOKUDO HUB | SEA2 | [Premium] Ready!")
end)

print("🚀 YOKUDO HUB | SEA2 | [Premium] Loading...")
