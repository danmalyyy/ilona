local player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Pozice base, změň podle potřeby
local MY_BASE_POSITION = Vector3.new(0, 10, 0)

-- Stav toggle módů
local states = {
    speedBoost = false,
    jumpBoost = false,
    infJump = false,
}

-- Vytvoření GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

-- Malý červený tlačítko na otevření menu (dragovatelný)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 10
toggleBtn.Name = "ToggleButton"
toggleBtn.AnchorPoint = Vector2.new(0,0)
toggleBtn.TextTransparency = 1
toggleBtn.BackgroundTransparency = 0.3
toggleBtn.BorderSizePixel = 0
toggleBtn.ClipsDescendants = true
toggleBtn.Draggable = true

-- Hlavní menu frame
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 180, 0, 350)
menuFrame.Position = UDim2.new(0, 60, 0, 50)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0)  -- Černé pozadí
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ClipsDescendants = true
menuFrame.ZIndex = 9

-- Scrollframe pro tlačítka
local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.ScrollBarThickness = 8
scrollFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", scrollFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Aplikace toggle stavů
local function applyStates()
    hum.WalkSpeed = states.speedBoost and 100 or 16
    hum.JumpPower = states.jumpBoost and 100 or 50
end

-- Infinite jump
RS.Stepped:Connect(function()
    if states.infJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Teleport forward funkce (opravena)
local function tpForward()
    local lookVector = hrp.CFrame.LookVector
    local newPos = hrp.Position + (lookVector * 30)
    hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z)
end

-- Teleport na střechu (opravena)
local function tpRoof()
    local pos = hrp.Position
    hrp.CFrame = CFrame.new(pos.X, 150, pos.Z)
end

-- Najdi nearby brainrot (do 10 studů)
local function findNearbyBrainrot(radius)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and string.find(obj.Name:lower(), "brainrot") then
            local primaryPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if primaryPart and (primaryPart.Position - hrp.Position).Magnitude <= radius then
                return obj
            end
        end
    end
    return nil
end

-- Instant Steal funkce (přidána)
local function instantSteal()
    local brainrot = findNearbyBrainrot(10)
    if brainrot then
        brainrot.Parent = char
        hrp.CFrame = CFrame.new(MY_BASE_POSITION)
        print("Teleportováno s brainrotem do base!")
    else
        print("Brainrot nenalezen v okolí.")
    end
end

-- Vytvoření toggle tlačítka
local function createToggleButton(name, stateKey)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Černé pozadí
    btn.TextColor3 = Color3.new(1, 1, 1) -- Bíly text
    btn.BorderSizePixel = 1
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name .. ": OFF"
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        applyStates()
    end)

    btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
    return btn
end

-- Vytvoření tlačítka (bez toggle)
local function createButton(name, onClick)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 1
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Přidání tlačítek do menu
createToggleButton("Speed Boost", "speedBoost")
createToggleButton("Jump Boost", "jumpBoost")
createToggleButton("Infinite Jump", "infJump")
createButton("TP Forward", tpForward)
createButton("TP Roof", tpRoof)
createButton("Instant Steal", instantSteal)

-- Toggle menu viditelnosti
toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

applyStates()
