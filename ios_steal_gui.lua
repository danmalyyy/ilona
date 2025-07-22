local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- Infinite jump flag
local infJump = false

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local function createButton(name, pos, func)
    local button = Instance.new("TextButton", screenGui)
    button.Size = UDim2.new(0, 140, 0, 40)
    button.Position = pos
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BorderSizePixel = 2
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.MouseButton1Click:Connect(func)
end

-- Actions
createButton("TP Forward", UDim2.new(0, 20, 0, 100), function()
    hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 30)
end)

createButton("TP Roof", UDim2.new(0, 20, 0, 150), function()
    local pos = hrp.Position
    hrp.CFrame = CFrame.new(pos.X, 150, pos.Z)
end)

createButton("Speed Boost", UDim2.new(0, 20, 0, 200), function()
    hum.WalkSpeed = 100
end)

createButton("Speed Jump", UDim2.new(0, 20, 0, 250), function()
    hum.JumpPower = 100
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

createButton("Toggle Inf Jump", UDim2.new(0, 20, 0, 300), function()
    infJump = not infJump
end)

createButton("Instant Steal", UDim2.new(0, 20, 0, 350), function()
    -- Simuluje kliknutí na tlačítko "Steal"
    local stealBtn = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Steal")
    if stealBtn and stealBtn:IsA("TextButton") then
        pcall(function()
            stealBtn:Activate()
        end)
    end
    -- TP do boji base (ZDE nastav souřadnice dle hry!)
    local BOJI_BASE = Vector3.new(-150, 20, 240) -- <<< sem napiš přesnou pozici boji base
    hrp.CFrame = CFrame.new(BOJI_BASE)
end)

-- Infinite jump loop
RS.Stepped:Connect(function()
    if infJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
