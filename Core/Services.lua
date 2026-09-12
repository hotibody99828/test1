-- ==================================================
-- CORE SERVICES
-- ==================================================

_G.YOKUDO.Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui"),
    VirtualInput = game:GetService("VirtualInputManager"),
    ContentProvider = game:GetService("ContentProvider"),
    HttpService = game:GetService("HttpService"),
}

-- Alias
local S = _G.YOKUDO.Services
_G.Y = {
    P = S.Players,
    TS = S.TweenService,
    UIS = S.UserInputService,
    RS = S.RunService,
    Replicated = S.ReplicatedStorage,
    WS = S.Workspace,
    GUI = S.CoreGui,
    VI = S.VirtualInput,
    CP = S.ContentProvider,
    HS = S.HttpService,
}

print("✅ Services Loaded")
