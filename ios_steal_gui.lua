local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local infJump = false
local speedBoost = false
local jumpBoost = false

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

-- Draggable frame function
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    RS.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main menu frame
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 160, 0, 270)
menuFrame.Position = UDim2.new(0, 100, 0, 100)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
makeDraggable(menuFrame)

-- Toggle button (small red circle)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false -- so it doesn't change color when tapped
makeDraggable(toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

-- Helper to create toggle buttons inside the menu
local function createToggleButton(text, y, getFlag, setFlag, onActivate, onDeactivate)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16

    local function updateText()
        if getFlag() then
            btn.Text = text .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            btn.Text = text .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end

    btn.MouseButton1Click:Connect(function()
        local newVal = not getFlag()
        setFlag(newVal)
        if newVal then
            if onActivate then pcall(onActivate) end
        else
            if onDeactivate then pcall(onDeactivate) end
        end
        updateText()
    end)

    updateText()
end

-- TP Forward (teleport 30 studs forward)
local function tpForward()
    local lookVector = hrp.CFrame.LookVector
    local newPos = hrp.Position + (lookVector * 30)
    hrp.CFrame = CFrame.new(newPos)
end

-- TP Roof (teleport to 150 height above current X,Z)
local function tpRoof()
    local pos = hrp.Position
    hrp.CFrame = CFrame.new(pos.X, 150, pos.Z)
end

-- Speed Boost on/off
local function enableSpeedBoost()
    hum.WalkSpeed = 100
end
local function disableSpeedBoost()
    hum.WalkSpeed = 16 -- default speed
end

-- Jump Boost on/off
local function enableJumpBoost()
    hum.JumpPower = 100
end
local function disableJumpBoost()
    hum.JumpPower = 50 -- default jump power
end

-- Infinite jump toggle handled in stepped
local function toggleInfJump(active)
    infJump = active
end

-- Instant Steal teleport (example coordinates, uprav podle hry)
local function instantSteal()
    -- Pokus o aktivaci steal buttonu v UI hry
    local stealBtn = player.PlayerGui:FindFirstChild("Steal")
    if stealBtn and stealBtn:IsA("TextButton") then
        pcall(function() stealBtn:Activate() end)
    end
    -- Teleport do boji base, nastav podle hry přesné souřadnice
    local BOJI_BASE = Vector3.new(-150, 20, 240)
    hrp.CFrame = CFrame.new(BOJI_BASE)
end

-- Vytvoření tlačítek menu

-- TP Forward je tlačítko, které jednoduše teleportuje ihned, nemá stav zapnuto/vypnuto
local tpForwardBtn = Instance.new("TextButton", menuFrame)
tpForwardBtn.Size = UDim2.new(1, -10, 0, 30)
tpForwardBtn.Position = UDim2.new(0, 5, 0, 5)
tpForwardBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpForwardBtn.TextColor3 = Color3.new(1,1,1)
tpForwardBtn.Font = Enum.Font.SourceSansBold
tpForwardBtn.TextSize = 16
tpForwardBtn.Text = "TP Forward"
tpForwardBtn.MouseButton1Click:Connect(tpForward)

-- Ostatní tlačítka s přepínačem

createToggleButton("Speed Boost", 45, 
    function() return speedBoost end,
    function(v) speedBoost = v end,
    enableSpeedBoost,
    disableSpeedBoost
)

createToggleButton("Jump Boost", 85, 
    function() return jumpBoost end,
    function(v) jumpBoost = v end,
    enableJumpBoost,
    disableJumpBoost
)

createToggleButton("Infinite Jump", 125, 
    function() return infJump end,
    function(v) toggleInfJump(v) end
)

createToggleButton("Instant Steal", 165, 
    function() return false end,
    function()
        instantSteal()
    end
)

-- Infinite jump loop
RS.Stepped:Connect(function()
    if infJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
