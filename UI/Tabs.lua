-- ==================================================
-- TABS (SEA2) + SERVER CHECKER (LOAD FROM VPS)
-- ==================================================

local Y = _G.Y
local Services = _G.YOKUDO.Services
local Settings = _G.YOKUDO
local HttpService = game:GetService("HttpService")

-- ==================================================
-- ⭐ VPS CONFIG
-- ==================================================
local VPS_URL = "http://217.216.73.147:3000"

-- ==================================================
-- ⭐ LOAD DATA FROM VPS (ប្រើ game:HttpGet + pcall)
-- ==================================================
local function LoadDataFromVPS(type)
    local success, result = pcall(function()
        local url = VPS_URL .. "/api/data/" .. type
        local response = game:HttpGet(url)
        
        if response and response ~= "" then
            local data = HttpService:JSONDecode(response)
            return data.servers or {}
        else
            return {}
        end
    end)
    
    if success then
        return result or {}
    else
        return {}
    end
end

-- ==================================================
-- ⭐ MASK JOBID (លាក់ពាក់កណ្ដាល)
-- ==================================================
local function MaskJobId(jobId)
    if not jobId or jobId == "" then
        return "Unknown"
    end
    
    if #jobId > 8 then
        local first = string.sub(jobId, 1, 8)
        local last = string.sub(jobId, -4)
        return first .. "..." .. last
    end
    
    return jobId
end

-- ==================================================
-- ⭐ CREATE SERVER CARD (ចុចលើ Card → Teleport)
-- ==================================================
local function CreateServerCard(parent, data, titleText)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 0, 70)
    card.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(105, 90, 190)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = card

    -- Title (Value ពី Server)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 18)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    -- Player Count
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, -20, 0, 16)
    playerLabel.Position = UDim2.new(0, 10, 0, 24)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "Player Count : " .. tostring(data.players or 0)
    playerLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    playerLabel.TextSize = 11
    playerLabel.Font = Enum.Font.GothamMedium
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = card

    -- JobID (Mask)
    local jobLabel = Instance.new("TextLabel")
    jobLabel.Size = UDim2.new(1, -20, 0, 16)
    jobLabel.Position = UDim2.new(0, 10, 0, 43)
    jobLabel.BackgroundTransparency = 1
    jobLabel.Text = "Jobid : " .. MaskJobId(data.jobid)
    jobLabel.TextColor3 = Color3.fromRGB(145, 145, 175)
    jobLabel.TextSize = 10
    jobLabel.Font = Enum.Font.Gotham
    jobLabel.TextXAlignment = Enum.TextXAlignment.Left
    jobLabel.TextTruncate = Enum.TextTruncate.AtEnd
    jobLabel.Parent = card

    -- Age (ពណ៌លឿង)
    local ageLabel = Instance.new("TextLabel")
    ageLabel.Size = UDim2.new(0, 60, 0, 16)
    ageLabel.Position = UDim2.new(1, -70, 0, 43)
    ageLabel.BackgroundTransparency = 1
    ageLabel.Text = "Age : " .. tostring(data.age or 0) .. "s"
    ageLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    ageLabel.TextSize = 11
    ageLabel.Font = Enum.Font.GothamBold
    ageLabel.TextXAlignment = Enum.TextXAlignment.Right
    ageLabel.Parent = card

    -- ⭐ ចុចលើ Card ទាំងមូល → Teleport
    card.MouseButton1Click:Connect(function()
        if _G.YOKUDO_JoinServerByJobId then
            _G.YOKUDO_JoinServerByJobId(data.jobid)
        end
    end)

    -- Hover Effect
    card.MouseEnter:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
    end)

    card.MouseLeave:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
    end)

    return card
end

-- ==================================================
-- ⭐ UPDATE SERVER LIST (បង្ហាញ Data ពី VPS - ដក No servers found)
-- ==================================================
local function UpdateServerList(serverList, servers, titleText)
    for _, child in ipairs(serverList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    table.sort(servers, function(a, b)
        return a.age < b.age
    end)

    if #servers == 0 then
        return
    end

    for i, server in ipairs(servers) do
        local displayTitle = titleText
        
        -- ⭐ បើ extra ជាលេខ (នាទី) → បង្ហាញអត្ថបទពេញលេញ
        if server.extra and server.extra ~= "" then
            local minutes = tonumber(server.extra)
            if minutes then
                if titleText == "Full Moon" then
                    displayTitle = "Full Moon End in " .. minutes .. " minutes"
                elseif titleText == "Near Moon" then
                    displayTitle = "Full Moon in " .. minutes .. " minutes"
                else
                    displayTitle = server.extra
                end
            else
                displayTitle = server.extra
            end
        end
        
        CreateServerCard(serverList, server, displayTitle)
    end
end

-- ==================================================
-- ⭐ CREATE SERVER LIST CONTAINER
-- ==================================================
local function CreateServerList(parent)
    local serverList = Instance.new("ScrollingFrame")
    serverList.Size = UDim2.new(1, 0, 0, 300)
    serverList.BackgroundTransparency = 1
    serverList.BorderSizePixel = 0
    serverList.ScrollBarThickness = 4
    serverList.ScrollBarImageColor3 = Color3.fromRGB(105, 90, 190)
    serverList.CanvasSize = UDim2.new(0, 0, 0, 0)
    serverList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    serverList.Parent = parent

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = serverList

    return serverList
end

-- ==================================================
-- ⭐ CREATE REFRESH BUTTON (ពេញទទឹង + ពណ៌ប្រផេះ + Animation)
-- ==================================================
local function CreateRefreshBtn(parent, type, titleText)
    local CooldownTime = 5
    local LastRefreshTime = 0
    local isCooldown = false

    -- Button Holder
    local btnHolder = Instance.new("Frame")
    btnHolder.Size = UDim2.new(1, 0, 0, 35)
    btnHolder.BackgroundTransparency = 1
    btnHolder.BorderSizePixel = 0
    btnHolder.Parent = parent

    -- Button (ពេញទទឹង Page)
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 35)
    refreshBtn.Position = UDim2.new(0, 0, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    refreshBtn.BackgroundTransparency = 0.3
    refreshBtn.Text = ""
    refreshBtn.AutoButtonColor = false
    refreshBtn.Parent = btnHolder

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = refreshBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(200, 200, 220)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = refreshBtn

    -- ⭐ Text "Refresh Server" នៅខាងឆ្វេង
    local refreshText = Instance.new("TextLabel")
    refreshText.Size = UDim2.new(1, -20, 1, 0)
    refreshText.Position = UDim2.new(0, 10, 0, 0)
    refreshText.BackgroundTransparency = 1
    refreshText.Text = "Refresh Server"
    refreshText.TextColor3 = Color3.fromRGB(200, 200, 220)
    refreshText.TextSize = 12
    refreshText.Font = Enum.Font.GothamBold
    refreshText.TextXAlignment = Enum.TextXAlignment.Left
    refreshText.TextYAlignment = Enum.TextYAlignment.Center
    refreshText.Parent = refreshBtn

    -- Animation Slide
    local slide = Instance.new("Frame")
    slide.Size = UDim2.new(0, 0, 1, 0)
    slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slide.BackgroundTransparency = 0.7
    slide.BorderSizePixel = 0
    slide.Parent = refreshBtn

    local serverList = CreateServerList(parent)

    -- Animation Function
    local function PlaySlideAnimation()
        slide.Size = UDim2.new(0, 0, 1, 0)
        local tween = Y.TS:Create(slide, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        slide.Size = UDim2.new(0, 0, 1, 0)
    end

    -- ⭐ Cooldown - អាចចុចបានគ្រប់ពេល ប៉ុន្តែ Data មានប្រសិទ្ធភាពតែពេលដល់ 5s
    local function CheckCooldown()
        return isCooldown
    end

    -- Click Event
    refreshBtn.MouseButton1Click:Connect(function()
        LastRefreshTime = tick()
        PlaySlideAnimation()

        if not CheckCooldown() then
            isCooldown = true
            
            local servers = LoadDataFromVPS(type)
            UpdateServerList(serverList, servers, titleText)

            task.spawn(function()
                while isCooldown do
                    local Elapsed = tick() - LastRefreshTime
                    if Elapsed >= CooldownTime then
                        isCooldown = false
                        break
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    return refreshBtn, serverList
end

-- ==================================================
-- CREATE PAGES
-- ==================================================
local InfoPage = CreatePage("INFO")
local ShopPage = CreatePage("SHOP")
local AutoHopPage = CreatePage("AUTO_HOP")
local DarkBeardPage = CreatePage("DARK_BEARD")
local CursedCaptainPage = CreatePage("CURSED_CAPTAIN")
local CorePage = CreatePage("CORE")
local SwordPage = CreatePage("SWORD_LEGENDARY")
local HakiPage = CreatePage("HAKI_LEGENDARY")
local FruitPage = CreatePage("FRUIT")
local BerryPage = CreatePage("BERRY")
local SettingPage = CreatePage("SETTING")

-- ==================================================
-- CREATE TABS
-- ==================================================
local InfoTab = CreateTab("Info", 1)
local ShopTab = CreateTab("Shop", 2)
local AutoHopTab = CreateTab("Auto Hop", 3)
local DarkBeardTab = CreateTab("Dark Beard", 4)
local CursedCaptainTab = CreateTab("Cursed Captain", 5)
local CoreTab = CreateTab("Core", 6)
local SwordTab = CreateTab("Sword Legendary", 7)
local HakiTab = CreateTab("Haki Legendary", 8)
local FruitTab = CreateTab("Fruit", 9)
local BerryTab = CreateTab("Berry", 10)
local SettingTab = CreateTab("Setting", 11)

-- ==================================================
-- TAB MAP
-- ==================================================
local Tabs = {
    [InfoTab] = InfoPage,
    [ShopTab] = ShopPage,
    [AutoHopTab] = AutoHopPage,
    [DarkBeardTab] = DarkBeardPage,
    [CursedCaptainTab] = CursedCaptainPage,
    [CoreTab] = CorePage,
    [SwordTab] = SwordPage,
    [HakiTab] = HakiPage,
    [FruitTab] = FruitPage,
    [BerryTab] = BerryPage,
    [SettingTab] = SettingPage
}

-- ==================================================
-- SELECT TAB
-- ==================================================
local function SelectTab(SelectedTab, SelectedPage)
    for Tab, Page in pairs(Tabs) do
        Page.Visible = false
        local Indicator = Tab:FindFirstChild("Indicator")
        local TabText = Tab:FindFirstChild("TabText")
        Y.TS:Create(Tab, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        if Indicator then
            Y.TS:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
        if TabText then
            Y.TS:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(155, 155, 175)}):Play()
        end
    end

    SelectedPage.Visible = true
    task.wait(0.05)
    pcall(function()
        SelectedPage.CanvasPosition = Vector2.new(0, 0)
    end)

    Y.TS:Create(SelectedTab, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    local Indicator = SelectedTab:FindFirstChild("Indicator")
    local TabText = SelectedTab:FindFirstChild("TabText")
    if Indicator then
        Y.TS:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end
    if TabText then
        Y.TS:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end
end

for Tab, Page in pairs(Tabs) do
    Tab.MouseButton1Click:Connect(function()
        SelectTab(Tab, Page)
    end)
end

SelectTab(InfoTab, InfoPage)

-- ==================================================
-- ⭐ INFO TAB
-- ==================================================
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "YOKUDO HUB PREMIUM"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = InfoPage

local line = Instance.new("Frame")
line.Name = "Line"
line.Size = UDim2.new(0.9, 0, 0, 1)
line.Position = UDim2.new(0.05, 0, 0, 55)
line.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
line.BorderSizePixel = 0
line.Parent = InfoPage

local tgLabel = Instance.new("TextLabel")
tgLabel.Name = "TgLabel"
tgLabel.Size = UDim2.new(1, -20, 0, 22)
tgLabel.Position = UDim2.new(0, 10, 0, 72)
tgLabel.BackgroundTransparency = 1
tgLabel.Text = "Telegram Group :"
tgLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
tgLabel.TextSize = 13
tgLabel.TextXAlignment = Enum.TextXAlignment.Left
tgLabel.TextYAlignment = Enum.TextYAlignment.Center
tgLabel.Font = Enum.Font.GothamBold
tgLabel.Parent = InfoPage

local tgLink = Instance.new("TextLabel")
tgLink.Name = "TgLink"
tgLink.Size = UDim2.new(1, -20, 0, 22)
tgLink.Position = UDim2.new(0, 10, 0, 94)
tgLink.BackgroundTransparency = 1
tgLink.Text = "https://t.me/mailay20"
tgLink.TextColor3 = Color3.fromRGB(200, 200, 220)
tgLink.TextSize = 12
tgLink.TextXAlignment = Enum.TextXAlignment.Left
tgLink.TextYAlignment = Enum.TextYAlignment.Center
tgLink.Font = Enum.Font.Gotham
tgLink.Parent = InfoPage

local dcLabel = Instance.new("TextLabel")
dcLabel.Name = "DcLabel"
dcLabel.Size = UDim2.new(1, -20, 0, 22)
dcLabel.Position = UDim2.new(0, 10, 0, 126)
dcLabel.BackgroundTransparency = 1
dcLabel.Text = "Discord Group :"
dcLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
dcLabel.TextSize = 13
dcLabel.TextXAlignment = Enum.TextXAlignment.Left
dcLabel.TextYAlignment = Enum.TextYAlignment.Center
dcLabel.Font = Enum.Font.GothamBold
dcLabel.Parent = InfoPage

local dcLink = Instance.new("TextLabel")
dcLink.Name = "DcLink"
dcLink.Size = UDim2.new(1, -20, 0, 22)
dcLink.Position = UDim2.new(0, 10, 0, 148)
dcLink.BackgroundTransparency = 1
dcLink.Text = "https://discord.gg/2XbN7M5Vem"
dcLink.TextColor3 = Color3.fromRGB(200, 200, 220)
dcLink.TextSize = 12
dcLink.TextXAlignment = Enum.TextXAlignment.Left
dcLink.TextYAlignment = Enum.TextYAlignment.Center
dcLink.Font = Enum.Font.Gotham
dcLink.Parent = InfoPage

local tgUserLabel = Instance.new("TextLabel")
tgUserLabel.Name = "TgUserLabel"
tgUserLabel.Size = UDim2.new(1, -20, 0, 22)
tgUserLabel.Position = UDim2.new(0, 10, 0, 180)
tgUserLabel.BackgroundTransparency = 1
tgUserLabel.Text = "Telegram :"
tgUserLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
tgUserLabel.TextSize = 13
tgUserLabel.TextXAlignment = Enum.TextXAlignment.Left
tgUserLabel.TextYAlignment = Enum.TextYAlignment.Center
tgUserLabel.Font = Enum.Font.GothamBold
tgUserLabel.Parent = InfoPage

local tgUserLink = Instance.new("TextLabel")
tgUserLink.Name = "TgUserLink"
tgUserLink.Size = UDim2.new(1, -20, 0, 22)
tgUserLink.Position = UDim2.new(0, 10, 0, 202)
tgUserLink.BackgroundTransparency = 1
tgUserLink.Text = "@maibigber"
tgUserLink.TextColor3 = Color3.fromRGB(200, 200, 220)
tgUserLink.TextSize = 12
tgUserLink.TextXAlignment = Enum.TextXAlignment.Left
tgUserLink.TextYAlignment = Enum.TextYAlignment.Center
tgUserLink.Font = Enum.Font.Gotham
tgUserLink.Parent = InfoPage

local buildLabel = Instance.new("TextLabel")
buildLabel.Name = "BuildLabel"
buildLabel.Size = UDim2.new(1, -20, 0, 30)
buildLabel.Position = UDim2.new(0, 10, 0, 240)
buildLabel.BackgroundTransparency = 1
buildLabel.Text = "Build By : Kon Khmer 🇰🇭"
buildLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
buildLabel.TextSize = 13
buildLabel.TextXAlignment = Enum.TextXAlignment.Center
buildLabel.TextYAlignment = Enum.TextYAlignment.Center
buildLabel.Font = Enum.Font.GothamBold
buildLabel.Parent = InfoPage

-- ==================================================
-- ⭐ SERVER CHECKER (ជំនួស Refresh Button ចាស់)
-- ==================================================
CreateRefreshBtn(DarkBeardPage, "sea2_darkbeard", "Darkbeard")
CreateRefreshBtn(CursedCaptainPage, "sea2_cursed_captain", "Cursed Captain")
CreateRefreshBtn(CorePage, "sea2_core", "Core")
CreateRefreshBtn(SwordPage, "sea2_sword", "Sword Legendary")
CreateRefreshBtn(HakiPage, "sea2_haki", "Haki Legendary")
CreateRefreshBtn(FruitPage, "sea2_fruit", "Fruit")
CreateRefreshBtn(BerryPage, "sea2_berry", "Berry")

-- ==================================================
-- SHOP TAB
-- ==================================================
CreateSectionTitle(ShopPage, "Shop", 1)

local buySword = CreateSmartCheckbox(
    ShopPage,
    "Auto Buy Legendary Sword",
    2,
    function()
        _G.YOKUDO_ToggleAutoBuySword()
    end,
    function()
        return _G.YOKUDO_AutoBuySwordEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_BuySword == nil then
    _G.YOKUDO_UpdateUI_BuySword = buySword.Update
end

local unlockHaki = CreateSmartCheckbox(
    ShopPage,
    "Auto Unlock Haki Legendary",
    3,
    function()
        _G.YOKUDO_ToggleAutoUnlockHaki()
    end,
    function()
        return _G.YOKUDO_AutoUnlockHakiEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_UnlockHaki == nil then
    _G.YOKUDO_UpdateUI_UnlockHaki = unlockHaki.Update
end

-- Join Server With Jobid
CreateSectionTitle(ShopPage, "Join Server With Jobid", 4)

local jobIdHolder = Instance.new("Frame")
jobIdHolder.Name = "JobIdHolder"
jobIdHolder.Size = UDim2.new(1, 0, 0, 28)
jobIdHolder.BackgroundTransparency = 1
jobIdHolder.BorderSizePixel = 0
jobIdHolder.LayoutOrder = 5
jobIdHolder.ZIndex = 9
jobIdHolder.Parent = ShopPage

local jobIdLabel = Instance.new("TextLabel")
jobIdLabel.Name = "JobIdLabel"
jobIdLabel.Size = UDim2.new(0, 55, 1, 0)
jobIdLabel.Position = UDim2.new(0, 0, 0, 0)
jobIdLabel.BackgroundTransparency = 1
jobIdLabel.Text = "JobId:"
jobIdLabel.TextColor3 = Color3.fromRGB(205, 205, 220)
jobIdLabel.TextSize = 11
jobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
jobIdLabel.TextYAlignment = Enum.TextYAlignment.Center
jobIdLabel.Font = Enum.Font.GothamMedium
jobIdLabel.ZIndex = 10
jobIdLabel.Parent = jobIdHolder

local jobIdTextBox = Instance.new("TextBox")
jobIdTextBox.Name = "JobIdTextBox"
jobIdTextBox.Size = UDim2.new(0, 180, 1, -4)
jobIdTextBox.Position = UDim2.new(0, 58, 0, 2)
jobIdTextBox.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
jobIdTextBox.BorderSizePixel = 0
jobIdTextBox.Text = ""
jobIdTextBox.PlaceholderText = "Paste Premium Jobid or Normal"
jobIdTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jobIdTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
jobIdTextBox.TextSize = 10
jobIdTextBox.TextXAlignment = Enum.TextXAlignment.Left
jobIdTextBox.TextYAlignment = Enum.TextYAlignment.Center
jobIdTextBox.Font = Enum.Font.GothamMedium
jobIdTextBox.ZIndex = 11
jobIdTextBox.Parent = jobIdHolder

local TBoxCorner = Instance.new("UICorner")
TBoxCorner.CornerRadius = UDim.new(0, 4)
TBoxCorner.Parent = jobIdTextBox

local TBoxStroke = Instance.new("UIStroke")
TBoxStroke.Color = Color3.fromRGB(200, 200, 220)
TBoxStroke.Thickness = 0.5
TBoxStroke.Transparency = 0.2
TBoxStroke.Parent = jobIdTextBox

local joinButton = Instance.new("TextButton")
joinButton.Name = "JoinButton"
joinButton.Size = UDim2.new(0, 60, 1, -4)
joinButton.Position = UDim2.new(1, -62, 0, 2)
joinButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
joinButton.BorderSizePixel = 0
joinButton.Text = "Join"
joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
joinButton.TextSize = 11
joinButton.TextXAlignment = Enum.TextXAlignment.Center
joinButton.TextYAlignment = Enum.TextYAlignment.Center
joinButton.Font = Enum.Font.GothamBold
joinButton.ZIndex = 11
joinButton.Parent = jobIdHolder

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 4)
BtnCorner.Parent = joinButton

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(200, 200, 220)
BtnStroke.Thickness = 0.5
BtnStroke.Transparency = 0.2
BtnStroke.Parent = joinButton

joinButton.MouseEnter:Connect(function()
    joinButton.BackgroundColor3 = Color3.fromRGB(135, 120, 225)
end)

joinButton.MouseLeave:Connect(function()
    joinButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
end)

joinButton.MouseButton1Click:Connect(function()
    local inputText = jobIdTextBox.Text
    if inputText and inputText ~= "" and inputText ~= "Paste Premium Jobid or Normal" then
        if _G.YOKUDO_JoinServerByEncoded then
            local ok, msg = _G.YOKUDO_JoinServerByEncoded(inputText)
            if ok then
                print("✅ " .. msg)
            else
                print("❌ " .. msg)
            end
        else
            warn("⚠️ _G.YOKUDO_JoinServerByEncoded not found! Make sure JoinServer.lua is loaded.")
        end
    else
        print("⚠️ Please paste Premium Jobid or Normal!")
    end
end)

jobIdTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        joinButton.MouseButton1Click:Fire()
    end
end)

-- ==================================================
-- AUTO HOP TAB
-- ==================================================
CreateSectionTitle(AutoHopPage, "Select Weapon for attack", 1)
CreateWeaponDropdown(AutoHopPage, 2)

local clickAttack = CreateSmartCheckbox(
    AutoHopPage,
    "Auto Click Attack",
    3,
    function()
        _G.YOKUDO_ToggleAutoClickAttack()
    end,
    function()
        return _G.YOKUDO_AutoClickAttackEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_ClickAttack == nil then
    _G.YOKUDO_UpdateUI_ClickAttack = clickAttack.Update
end

-- Farm Boss: Darkbeard
CreateSectionTitle(AutoHopPage, "Farm Boss", 4)

local darkBeard = CreateSmartCheckbox(
    AutoHopPage,
    "Auto Darkbeard",
    5,
    function()
        _G.YOKUDO_ToggleAutoDarkBeard()
    end,
    function()
        return _G.YOKUDO_AutoDarkBeardEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_DarkBeard == nil then
    _G.YOKUDO_UpdateUI_DarkBeard = darkBeard.Update
end

-- Auto Hop Darkbeard
local hopDarkBeardFrame, hopDarkBeardCheckbox, getHopDarkBeardState = CreateCheckbox(AutoHopPage, "Auto Hop Darkbeard", 6)

-- Farm Boss: Cursed Captain
CreateSectionTitle(AutoHopPage, "Farm Boss", 7)

local cursedCaptain = CreateSmartCheckbox(
    AutoHopPage,
    "Auto Cursed Captain",
    8,
    function()
        _G.YOKUDO_ToggleAutoCursedCaptain()
    end,
    function()
        return _G.YOKUDO_AutoCursedCaptainEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_CursedCaptain == nil then
    _G.YOKUDO_UpdateUI_CursedCaptain = cursedCaptain.Update
end

-- Auto Hop Cursed Captain
local hopCursedCaptainFrame, hopCursedCaptainCheckbox, getHopCursedCaptainState = CreateCheckbox(AutoHopPage, "Auto Hop Cursed Captain", 9)

-- Farm Boss: Core
CreateSectionTitle(AutoHopPage, "Farm Boss", 10)

local core = CreateSmartCheckbox(
    AutoHopPage,
    "Auto Core",
    11,
    function()
        _G.YOKUDO_ToggleAutoCore()
    end,
    function()
        return _G.YOKUDO_AutoCoreEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_Core == nil then
    _G.YOKUDO_UpdateUI_Core = core.Update
end

-- Auto Hop Checkbox Events
hopDarkBeardCheckbox.MouseButton1Click:Connect(function()
    if _G.YOKUDO_ToggleAutoHopDarkBeard then
        _G.YOKUDO_ToggleAutoHopDarkBeard()
    end
end)

hopCursedCaptainCheckbox.MouseButton1Click:Connect(function()
    if _G.YOKUDO_ToggleAutoHopCursedCaptain then
        _G.YOKUDO_ToggleAutoHopCursedCaptain()
    end
end)

-- ==================================================
-- SETTING TAB
-- ==================================================
CreateSectionTitle(SettingPage, "Tween Settings", 1)
CreateStopTweenButton(SettingPage, 2)

CreateSectionTitle(SettingPage, "Other", 3)
local noClipFrame, noClipCheckbox, getNoClipState = CreateCheckbox(SettingPage, "No Clip", 4)

CreateSectionTitle(SettingPage, "Auto Abilities", 5)

local buso = CreateSmartCheckbox(
    SettingPage,
    "Auto Buso",
    6,
    function()
        _G.YOKUDO_ToggleAutoBuso()
    end,
    function()
        return _G.YOKUDO_BusoEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_Buso == nil then
    _G.YOKUDO_UpdateUI_Buso = buso.Update
end

local obsFrame, obsCheckbox, getObsState = CreateCheckbox(SettingPage, "Auto Ken", 7)

CreateSectionTitle(SettingPage, "Movement Hacks", 8)
local jumpHolder, jumpCheckbox, getJumpState, jumpTextBox, getJumpValue = CreateTextBoxWithCheckbox(SettingPage, "Jump Hack", 9)
local speedHolder, speedCheckbox, getSpeedState, speedTextBox, getSpeedValue = CreateTextBoxWithCheckbox(SettingPage, "Speed Hack", 10)

local walk = CreateSmartCheckbox(
    SettingPage,
    "Walk on Water",
    11,
    function()
        _G.YOKUDO_ToggleWalkOnWater()
    end,
    function()
        return _G.YOKUDO_WalkEnabled or false
    end
)

if _G.YOKUDO_UpdateUI_Walk == nil then
    _G.YOKUDO_UpdateUI_Walk = walk.Update
end

-- Setting Checkbox Events
obsCheckbox.MouseButton1Click:Connect(function()
    if _G.YOKUDO_ToggleAutoKen then
        _G.YOKUDO_ToggleAutoKen()
    end
end)

noClipCheckbox.MouseButton1Click:Connect(function()
    if _G.YOKUDO_ToggleNoClip then
        _G.YOKUDO_ToggleNoClip()
    end
end)

-- ==================================================
-- OTHER PAGES
-- ==================================================

_G.YOKUDO_AutoHopPage = AutoHopPage
_G.YOKUDO_DarkBeardPage = DarkBeardPage
_G.YOKUDO_CursedCaptainPage = CursedCaptainPage
_G.YOKUDO_CorePage = CorePage
_G.YOKUDO_SwordPage = SwordPage
_G.YOKUDO_HakiPage = HakiPage
_G.YOKUDO_FruitPage = FruitPage
_G.YOKUDO_BerryPage = BerryPage

print("✅ Tabs Loaded (SEA2 - No Config - Server Checker)")
