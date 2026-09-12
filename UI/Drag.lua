-- ==================================================
-- DRAG SYSTEM
-- ==================================================

local Y = _G.Y
local Services = _G.YOKUDO.Services
local Main = _G.YOKUDO_Main
local TopBar = _G.YOKUDO_TopBar

local Dragging = false
local DragStart = nil
local StartPosition = nil
local ActiveTouch = nil

local function StartDrag(Input)
    if Dragging then return end
    if Input.UserInputType == Enum.UserInputType.Touch then
        ActiveTouch = Input
    end
    Dragging = true
    DragStart = Input.Position
    StartPosition = Main.Position
end

local function StopDrag()
    Dragging = false
    ActiveTouch = nil
    DragStart = nil
    StartPosition = nil
end

TopBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or 
       Input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(Input)
    end
end)

local function CreateDragZone(Name, Position, Size)
    local Zone = Instance.new("Frame")
    Zone.Name = Name
    Zone.Position = Position
    Zone.Size = Size
    Zone.BackgroundTransparency = 1
    Zone.BorderSizePixel = 0
    Zone.Active = true
    Zone.ZIndex = 50
    Zone.Parent = Main
    
    Zone.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or 
           Input.UserInputType == Enum.UserInputType.Touch then
            StartDrag(Input)
        end
    end)
    
    return Zone
end

CreateDragZone("DragTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 5))
CreateDragZone("DragBottom", UDim2.new(0, 0, 1, -5), UDim2.new(1, 0, 0, 5))
CreateDragZone("DragLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 5, 1, 0))
CreateDragZone("DragRight", UDim2.new(1, -5, 0, 0), UDim2.new(0, 5, 1, 0))

Services.UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then return end
    if Input.UserInputType == Enum.UserInputType.Touch then
        if ActiveTouch and Input ~= ActiveTouch then return end
    end
    if not DragStart or not StartPosition then return end
    if Input.UserInputType ~= Enum.UserInputType.MouseMovement and
       Input.UserInputType ~= Enum.UserInputType.Touch then return end
    
    local Delta = Input.Position - DragStart
    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )
end)

Services.UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Touch then
        if ActiveTouch and Input == ActiveTouch then
            StopDrag()
        end
        return
    end
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Dragging then StopDrag() end
    end
end)

print("✅ Drag System Loaded")
