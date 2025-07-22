local player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("StealBrainrotSettings_"..player.UserId)

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Změň na pozici své base!
local MY_BASE_POSITION = Vector3.new(0, 10, 0)

-- Stavy toggle módů
local states = {
    speedBoost = false,
    jumpBoost = false,
    infJump = false,
}

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

-- Malý červený kruh (dragovatelný)
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
toggleBtn.Modal = true
toggleBtn.Selectable = false
toggleBtn.Draggable = true

-- Menu frame (skryté)
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 180, 0, 350)
menuFrame.Position = UDim2.new(0, 60, 0, 50)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

-- Uložení a načtení nastavení
local function saveSettings()
    local success, err = pcall(function()
        dataStore:SetAsync("settings", {
            pos = toggleBtn.Position,
            states = states,
        })
    end)
    if not success then warn("Save failed: "..err) end
end

local function loadSettings()
    local success, data = pcall(function()
        return dataStore:GetAsync("settings")
    end)
    if success and data then
        if data.pos then toggleBtn.Position = data.pos end
        if data.states then 
            states = data.states
            applyStates()
        end
    end
end

-- Aplikace toggle stavů
function applyStates()
    hum.WalkSpeed = states.speedBoost and 100 or 16
    hum.JumpPower = states.jumpBoost and 100 or 50
end

-- Infinite jump loop
RS.Stepped:Connect(function()
    if states.infJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Teleport forward funkce
local function tpForward()
    local lookVector = hrp.CFrame.LookVector
    local newPos = hrp.Position + (lookVector * 30)
    -- Udržíme Y pozici
    hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z)
end

-- Teleport roof
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

-- Instant Steal: vezmi brainrot a teleportuj se do své base
local function instantSteal()
    local brainrot = findNearbyBrainrot(10)
    if brainrot then
        -- Přidej brainrot do postavy (nebo kam je potřeba, uprav dle hry)
        brainrot.Parent = char
        hrp.CFrame = CFrame.new(MY_BASE_POSITION)
        print("Teleportováno s brainrotem do base!")
    else
        print("Brainrot nenalezen v okolí.")
    end
end

-- Tlačítko vytvoření s toggle funkcí (pro Speed, Jump, Infinite Jump)
local function createToggleButton(name, stateKey)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 2
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name .. ": OFF"
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        applyStates()
        saveSettings()
    end)

    -- Inicializace textu podle stavu
    btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
    return btn
end

-- Tlačítko vytvoření (bez toggle)
local function createButton(name, onClick)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 2
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Label pro nejlepší brainrot info
local bestBrainrotLabel = Instance.new("TextLabel", scrollFrame)
bestBrainrotLabel.Size = UDim2.new(1, -10, 0, 30)
bestBrainrotLabel.BackgroundTransparency = 1
bestBrainrotLabel.TextColor3 = Color3.new(1, 1, 1)
bestBrainrotLabel.TextScaled = true
bestBrainrotLabel.TextXAlignment = Enum.TextXAlignment.Left
bestBrainrotLabel.Text = "Nejlepší brainrot: N/A"

-- Funkce pro získání nejlepšího brainrota podle Speed (přizpůsob dle tvých leaderstats)
local function getBestBrainrot()
    local bestPlayer = nil
    local bestSpeed = 0
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local speedStat = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Speed")
            if speedStat and speedStat.Value > bestSpeed then
                bestSpeed = speedStat.Value
                bestPlayer = plr
            end
        end
    end
    return bestPlayer, bestSpeed
end

-- Aktualizace labelu každých 5 sekund
coroutine.wrap(function()
    while true do
        local plr, speed = getBestBrainrot()
        if plr then
            bestBrainrotLabel.Text = string.format("Nejlepší brainrot: %s (%.2f M/sec)", plr.Name, speed)
        else
            bestBrainrotLabel.Text = "Nejlepší brainrot: N/A"
        end
        wait(5)
    end
end)()

-- Přidání tlačítek do menu
createToggleButton("Speed Boost", "speedBoost")
createToggleButton("Jump Boost", "jumpBoost")
createToggleButton("Infinite Jump", "infJump")
createButton("TP Forward", tpForward)
createButton("TP Roof", tpRoof)
createButton("Instant Steal", instantSteal)

-- Toggle menu viditelnosti po kliknutí na malý červený kruh
toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
    saveSettings()
end)

-- Při startu načti uložená data
loadSettings()
applyStates()
