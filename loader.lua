local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local localPlayer = players.LocalPlayer or players:GetPlayers()[1]
local UIS = game:GetService("UserInputService")

local eggChances = {
    ["Common Egg"] = {["Dog"] = 33, ["Bunny"] = 33, ["Golden Lab"] = 33},
    ["Uncommon Egg"] = {["Black Bunny"] = 25, ["Chicken"] = 25, ["Cat"] = 25, ["Deer"] = 25},
    ["Rare Egg"] = {["Orange Tabby"] = 33.33, ["Spotted Deer"] = 25, ["Pig"] = 16.67, ["Rooster"] = 16.67, ["Monkey"] = 8.33},
    ["Legendary Egg"] = {["Cow"] = 42.55, ["Silver Monkey"] = 42.55, ["Sea Otter"] = 10.64, ["Turtle"] = 2.13, ["Polar Bear"] = 2.13},
    ["Mythical Egg"] = {["Grey Mouse"] = 37.5, ["Brown Mouse"] = 26.79, ["Squirrel"] = 26.79, ["Red Giant Ant"] = 8.93, ["Red Fox"] = 0},
    ["Bug Egg"] = {["Snail"] = 40, ["Giant Ant"] = 35, ["Caterpillar"] = 25, ["Praying Mantis"] = 0, ["Dragon Fly"] = 0},
    ["Night Egg"] = {["Hedgehog"] = 47, ["Mole"] = 23.5, ["Frog"] = 21.16, ["Echo Frog"] = 8.35, ["Night Owl"] = 0, ["Raccoon"] = 0},
    ["Bee Egg"] = {["Bee"] = 65, ["Honey Bee"] = 20, ["Bear Bee"] = 10, ["Petal Bee"] = 5, ["Queen Bee"] = 0},
    ["Anti Bee Egg"] = {["Wasp"] = 55, ["Tarantula Hawk"] = 31, ["Moth"] = 14, ["Butterfly"] = 0, ["Disco Bee"] = 0},
    ["Common Summer Egg"] = {["Starfish"] = 50, ["Seafull"] = 25, ["Crab"] = 25},
    ["Rare Summer Egg"] = {["Flamingo"] = 30, ["Toucan"] = 25, ["Sea Turtle"] = 20, ["Orangutan"] = 15, ["Seal"] = 10},
    ["Paradise Egg"] = {["Ostrich"] = 43, ["Peacock"] = 33, ["Capybara"] = 24, ["Scarlet Macaw"] = 3, ["Mimic Octopus"] = 1},
    ["Premium Night Egg"] = {["Hedgehog"] = 50, ["Mole"] = 26, ["Frog"] = 14, ["Echo Frog"] = 10}
}

local displayedEggs = {}

local function getPetForEgg(eggName)
    local pets = eggChances[eggName]
    if not pets then return "?" end
    local valid = {}
    for pet, chance in pairs(pets) do
        if chance > 0 then table.insert(valid, pet) end
    end
    return #valid > 0 and valid[math.random(1, #valid)] or "?"
end

local function createEspGui(object, labelText)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    local adornee = object:FindFirstChildWhichIsA("BasePart") or object.PrimaryPart
    if not adornee then return nil end
    billboard.Adornee = adornee
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = labelText
    label.Parent = billboard
    billboard.Parent = game:GetService("CoreGui")
    return billboard, label
end

local function addESP(egg)
    if egg:GetAttribute("OWNER") ~= localPlayer.Name then return end
    local eggName = egg:GetAttribute("EggName")
    local objectId = egg:GetAttribute("OBJECT_UUID")
    if not eggName or not objectId or displayedEggs[objectId] then return end
    local pet = getPetForEgg(eggName)
    local labelText = eggName .. " | " .. pet
    local espGui, espLabel = createEspGui(egg, labelText)
    if espGui then
        displayedEggs[objectId] = {
            egg = egg,
            gui = espGui,
            label = espLabel,
            eggName = eggName,
            currentPet = pet
        }
    end
end

local function removeESP(egg)
    local objectId = egg:GetAttribute("OBJECT_UUID")
    if objectId and displayedEggs[objectId] then
        if displayedEggs[objectId].gui and displayedEggs[objectId].gui.Parent then
            displayedEggs[objectId].gui:Destroy()
        end
        displayedEggs[objectId] = nil
    end
end

for _, egg in collectionService:GetTagged("PetEggServer") do addESP(egg) end
collectionService:GetInstanceAddedSignal("PetEggServer"):Connect(addESP)
collectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(removeESP)

local playerGui = localPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "PetPredictorUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local isPC = UIS.MouseEnabled
local uiScale = isPC and 1.15 or 1

local discordBlack = Color3.fromRGB(32, 34, 37)
local lavender = Color3.fromRGB(196, 74, 74)
local darkLavender = Color3.fromRGB(196, 74, 74)
local headerColor = Color3.fromRGB(47, 49, 54)
local textColor = Color3.fromRGB(220, 220, 220)

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 80*uiScale, 0, 25*uiScale)
toggleButton.Position = UDim2.new(0, 10, 0, 20)
toggleButton.Text = "Close/Open"
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 14
toggleButton.BackgroundColor3 = discordBlack
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Parent = gui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 180, 0, 120)
mainFrame.Position = UDim2.new(0.5, -90, 0.3, 0)
mainFrame.BackgroundColor3 = discordBlack
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = headerColor
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local versionText = Instance.new("TextLabel")
versionText.Text = "v1.0.0"
versionText.Size = UDim2.new(0, 40, 0, 12)
versionText.Position = UDim2.new(0, 5, 0, 5)
versionText.Font = Enum.Font.SourceSans
versionText.TextSize = 10
versionText.TextColor3 = textColor
versionText.BackgroundTransparency = 1
versionText.TextXAlignment = Enum.TextXAlignment.Left
versionText.Parent = header

local title = Instance.new("TextLabel")
title.Text = "EGG RANDOMIZER"
title.Size = UDim2.new(1, -10, 0, 20)
title.Position = UDim2.new(0, 5, 0, 5)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = textColor
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = header

local credit = Instance.new("TextLabel")
credit.Text = "by @zenxq"
credit.Size = UDim2.new(1, -10, 0, 12)
credit.Position = UDim2.new(0, 5, 0, 22)
credit.Font = Enum.Font.SourceSans
credit.TextSize = 10
credit.TextColor3 = textColor
credit.BackgroundTransparency = 1
credit.TextXAlignment = Enum.TextXAlignment.Center
credit.Parent = header

local tabBackground = Instance.new("Frame")
tabBackground.Size = UDim2.new(1, 0, 0, 20)
tabBackground.Position = UDim2.new(0, 0, 0, 35)
tabBackground.BackgroundColor3 = headerColor
tabBackground.BorderSizePixel = 0
tabBackground.Parent = header
Instance.new("UICorner", tabBackground).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 16
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = textColor
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(0, 0, 0, 55)
contentFrame.Size = UDim2.new(1, 0, 1, -55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local predict = Instance.new("TextButton", contentFrame)
predict.Size = UDim2.new(0.8, 0, 0, 30)
predict.Position = UDim2.new(0.1, 0, 0.3, 0)
predict.BackgroundColor3 = lavender
predict.TextColor3 = Color3.new(0, 0, 0)
predict.Font = Enum.Font.SourceSans
predict.TextSize = 14
predict.Text = "PREDICT PETS"
Instance.new("UICorner", predict).CornerRadius = UDim.new(0, 6)

local loadingBarBg = Instance.new("Frame", contentFrame)
loadingBarBg.Size = UDim2.new(0.8, 0, 0, 25)
loadingBarBg.Position = UDim2.new(0.1, 0, 0.3, 0)
loadingBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
loadingBarBg.BorderSizePixel = 0
loadingBarBg.Visible = false

local loadingBar = Instance.new("Frame", loadingBarBg)
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
loadingBar.BorderSizePixel = 0

local loadingPercent = Instance.new("TextLabel", loadingBarBg)
loadingPercent.Size = UDim2.new(1, 0, 1, 0)
loadingPercent.BackgroundTransparency = 1
loadingPercent.Text = "0%"
loadingPercent.TextColor3 = Color3.new(1, 1, 1)
loadingPercent.Font = Enum.Font.SourceSansBold
loadingPercent.TextSize = 14
loadingPercent.TextStrokeTransparency = 0.5

local loadingText = Instance.new("TextLabel", contentFrame)
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(0.8, 0, 0, 40)
loadingText.Position = UDim2.new(0.1, 0, 0.7, 0)
loadingText.Font = Enum.Font.SourceSans
loadingText.TextSize = 12
loadingText.TextColor3 = textColor
loadingText.BackgroundTransparency = 1
loadingText.TextXAlignment = Enum.TextXAlignment.Left
loadingText.TextYAlignment = Enum.TextYAlignment.Top
loadingText.TextWrapped = true
loadingText.TextScaled = false
loadingText.AutomaticSize = Enum.AutomaticSize.Y
loadingText.Visible = false
loadingText.Text = "Rerolling pets in 3 seconds"

predict.MouseEnter:Connect(function()
    predict.BackgroundColor3 = darkLavender
end)

predict.MouseLeave:Connect(function()
    predict.BackgroundColor3 = lavender
end)

local function startLoading()
    predict.Visible = false
    loadingBarBg.Visible = true
    loadingText.Visible = true
    
    local duration = 3
    local startTime = tick()
    
    while tick() - startTime < duration do
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        local remaining = math.ceil(duration - elapsed)
        
        loadingBar.Size = UDim2.new(progress, 0, 1, 0)
        loadingPercent.Text = math.floor(progress * 100) .. "%"
        loadingText.Text = "Rerolling pets in " .. remaining .. " seconds"
        task.wait()
    end
    
    loadingBarBg.Visible = false
    loadingText.Visible = false
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    predict.Visible = true
    
    for objectId, data in pairs(displayedEggs) do
        if data.gui and data.gui.Parent then
            data.gui:Destroy()
        end
    end
    
    for objectId, data in pairs(displayedEggs) do
        local newPet = getPetForEgg(data.eggName)
        local labelText = data.eggName .. " | " .. newPet
        local espGui, espLabel = createEspGui(data.egg, labelText)
        if espGui then
            displayedEggs[objectId] = {
                egg = data.egg,
                gui = espGui,
                label = espLabel,
                eggName = data.eggName,
                currentPet = newPet
            }
        end
    end
end

predict.MouseButton1Click:Connect(function()
    startLoading()
end)

local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.new(0, 80, 0, 25)
showBtn.Position = UDim2.new(0, 10, 0.5, -12)
showBtn.Text = "SHOW UI"
showBtn.BackgroundColor3 = discordBlack
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.SourceSansBold
showBtn.TextSize = 12
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 6)
showBtn.Visible = false

toggleButton.MouseButton1Click:Connect(function() 
    mainFrame.Visible = not mainFrame.Visible 
end)

closeBtn.MouseButton1Click:Connect(function() 
    mainFrame.Visible = false 
    showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function() 
    mainFrame.Visible = true 
    showBtn.Visible = false
end)

mainFrame.Visible = true