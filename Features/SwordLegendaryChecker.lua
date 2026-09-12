-- ==================================================
-- SWORD LEGENDARY CHECKER (SEA2) - LOAD DATA FROM VPS
-- ==================================================

local HttpService = game:GetService("HttpService")
local VPS_URL = "http://217.216.73.147:3000"

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

local function MaskJobId(jobId)
    if not jobId or jobId == "" then return "Unknown" end
    if #jobId > 8 then
        return string.sub(jobId, 1, 8) .. "..." .. string.sub(jobId, -4)
    end
    return jobId
end

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

    card.MouseButton1Click:Connect(function()
        if _G.YOKUDO_JoinServerByJobId then
            _G.YOKUDO_JoinServerByJobId(data.jobid)
        end
    end)

    card.MouseEnter:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
    end)

    card.MouseLeave:Connect(function()
        card.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
    end)

    return card
end

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
        local displayTitle = server.extra and server.extra ~= "" and server.extra or titleText
        CreateServerCard(serverList, server, displayTitle)
    end
end

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

local function CreateRefreshBtn(parent, type, titleText)
    local CooldownTime = 5
    local LastRefreshTime = 0
    local isCooldown = false

    local btnHolder = Instance.new("Frame")
    btnHolder.Size = UDim2.new(1, 0, 0, 35)
    btnHolder.BackgroundTransparency = 1
    btnHolder.BorderSizePixel = 0
    btnHolder.Parent = parent

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

    local slide = Instance.new("Frame")
    slide.Size = UDim2.new(0, 0, 1, 0)
    slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slide.BackgroundTransparency = 0.7
    slide.BorderSizePixel = 0
    slide.Parent = refreshBtn

    local serverList = CreateServerList(parent)

    local function PlaySlideAnimation()
        slide.Size = UDim2.new(0, 0, 1, 0)
        local tween = Y.TS:Create(slide, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        slide.Size = UDim2.new(0, 0, 1, 0)
    end

    local function CheckCooldown()
        return isCooldown
    end

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

task.wait(1)
CreateRefreshBtn(_G.YOKUDO_SwordPage, "sea2_sword", "Sword Legendary")
