-- ==================================================
-- AUTO KEN (OBSERVATION HAKI)
-- ==================================================

local Y = _G.Y
local Player = _G.YOKUDO.Player

_G.YOKUDO_ObservationEnabled = false
_G.YOKUDO_ObservationLoopConnection = nil

local lastCheckTime = 0
local checkInterval = 0.5

local CommE = Y.Replicated:FindFirstChild("Remotes")
if CommE then
    CommE = CommE:FindFirstChild("CommE")
end

local function TurnOnKen()
    if CommE then
        pcall(function()
            CommE:FireServer("Ken", true)
        end)
    end
end

local function highlightExists()
    local characterName = Player.Local.Name
    local path = Y.WS:FindFirstChild("Characters")
    if not path then return false end
    local char = path:FindFirstChild(characterName)
    if not char then return false end
    return char:FindFirstChild("Highlight") ~= nil
end

local function startAutoObservation()
    if _G.YOKUDO_ObservationLoopConnection then return end
    lastCheckTime = tick()
    TurnOnKen()
    _G.YOKUDO_ObservationLoopConnection = Y.RS.Stepped:Connect(function()
        if not _G.YOKUDO_ObservationEnabled then return end
        if tick() - lastCheckTime >= checkInterval then
            lastCheckTime = tick()
            if not highlightExists() then
                TurnOnKen()
            end
        end
    end)
end

local function stopAutoObservation()
    if _G.YOKUDO_ObservationLoopConnection then
        _G.YOKUDO_ObservationLoopConnection:Disconnect()
        _G.YOKUDO_ObservationLoopConnection = nil
    end
    lastCheckTime = 0
end

function _G.YOKUDO_ToggleAutoKen()
    _G.YOKUDO_ObservationEnabled = not _G.YOKUDO_ObservationEnabled
    if _G.YOKUDO_ObservationEnabled then
        startAutoObservation()
    else
        stopAutoObservation()
    end
end

print("✅ AutoKen Loaded")
