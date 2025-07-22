local player = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Pozice tvé základny (změň podle potřeby)
local MY_BASE_POSITION = Vector3.new(0, 10, 0)

-- Klíčová slova pro brainroty
local brainrotKeywords = {"tralalero", "tralala", "tripi", "tropi"}

-- Stav menu
local menuVisible = false

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealBrainrotGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Malý červený kruh (dragovatelný)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.Text = ""
toggleBtn.TextTransparency = 1
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 10
toggleBtn.ClipsDescendants = true
toggleBtn.Selectable = false
toggleBtn.Draggable = true
toggleBtn.Modal = true
toggleBtn.Parent = screenGui

-- Menu frame (skryté)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 350)
menuFrame.Position = UDim2.new(0, 60, 0, 50)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ClipsDescendants = true
menuFrame.ZIndex = 9
menuFrame.Parent = screenGui

-- ScrollFrame uvnitř menu
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.ScrollBarThickness = 8
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = menuFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = scrollFrame

-- Funkce hledání brainrotu podle klíčových slov
local function findNearbyBrainrot(radius)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local lowerName = obj.Name:lower()
            for _, keyword in ipairs(brainrotKeywords) do
                if string.find(lowerName, keyword) then
                    local primaryPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                    if primaryPart and (primaryPart.Position - hrp.Position).Magnitude <= radius then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- Instant Steal: vezmi brainrot a teleportuj se do základny
local function instantSteal()
    local brainrot = findNearbyBrainrot(10)
    if brainrot then
        brainrot.Parent = char -- přesuneš brainrot do své postavy
        hrp.CFrame = CFrame.new(MY_BASE_POSITION)
        print("Teleportováno s brainrotem do base!")
    else
        print("Brainrot nenalezen v okolí.")
    end
end

-- Pomocná funkce pro vytváření tlačítek v menu
local function createButton(name, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 2
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    btn.AutoButtonColor = false
    btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Přidání tlačítka Instant Steal do menu
createButton("Instant Steal", instantSteal)

-- Toggle menu viditelnosti po kliknutí na malý červený kruh
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
end)
