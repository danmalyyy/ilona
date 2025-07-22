local player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local basePos = Vector3.new(0, 10, 0)
local states = {
    speed = false,
    jump = false,
    infJump = false,
    autoSlap = false,
}
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ChilliGui"
screenGui.ResetOnSpawn = false
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.Draggable = true
toggleBtn.ZIndex = 10

local menu = Instance.new("Frame", screenGui)
menu.Name = "Menu"
menu.Size = UDim2.new(0, 180, 0, 400)
menu.Position = UDim2.new(0, 60, 0, 50)
menu.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Černé pozadí
menu.BorderSizePixel = 0
menu.Visible = false
menu.ZIndex = 9

local scroll = Instance.new("ScrollingFrame", menu)
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
local function createToggle(name, key)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Bílý text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name .. ": OFF"
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        btn.Text = name .. (states[key] and ": ON" or ": OFF")

        if key == "speed" then
            hum.WalkSpeed = states.speed and 100 or 16
        elseif key == "jump" then
            hum.JumpPower = states.jump and 100 or 50
        elseif key == "autoSlap" then
            if states.autoSlap then
                startAutoSlap()
            else
                stopAutoSlap()
            end
        end
    end)
    return btn
end

local function createButton(name, func)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Bílý text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(func)
    return btn
end
RS.Stepped:Connect(function()
    if states.infJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
local function tpForward()
    local look = hrp.CFrame.LookVector
    local targetPos = hrp.Position + look * 30
    hrp.CFrame = CFrame.new(targetPos.X, hrp.Position.Y, targetPos.Z)
end
local function tpRoof()
    local pos = hrp.Position
    hrp.CFrame = CFrame.new(pos.X, 150, pos.Z)
end
local function findBrainrot(radius)
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:lower():find("brainrot") then
            local part = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            if part and (part.Position - hrp.Position).Magnitude <= radius then
                return model
            end
        end
    end
    return nil
end

local function instantSteal()
    local brainrot = findBrainrot(10)
    if brainrot then
        brainrot.Parent = char
        hrp.CFrame = CFrame.new(basePos)
        print("Brainrot ukraden a teleportován do base!")
    else
        print("Brainrot v okolí nebyl nalezen.")
    end
end
local autoSlapConn
local function startAutoSlap()
    if autoSlapConn then return end
    autoSlapConn = RS.Stepped:Connect(function()
        if states.autoSlap then
            UIS.MouseClick:Fire()
        end
    end)
end
local function stopAutoSlap()
    if autoSlapConn then
        autoSlapConn:Disconnect()
        autoSlapConn = nil
    end
end
createToggle("Speed Boost", "speed")
createToggle("Jump Boost", "jump")
createToggle("Infinite Jump", "infJump")
createToggle("Auto Slap", "autoSlap")

createButton("TP Forward", tpForward)
createButton("TP Roof", tpRoof)
createButton("Instant Steal", instantSteal)

toggleBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)
