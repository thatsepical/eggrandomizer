local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local localPlayer = players.LocalPlayer or players:GetPlayers()[1]

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

local gui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
gui.Name = "PetPredictorUI"
gui.ResetOnSpawn = false

local mainContainer = Instance.new("Frame", gui)
mainContainer.Size = UDim2.new(0, 180, 0, 120)
mainContainer.Position = UDim2.new(0.5, -90, 0.3, 0)
mainContainer.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
mainContainer.BorderSizePixel = 0
mainContainer.Active = true
mainContainer.Draggable = true
Instance.new("UICorner", mainContainer).CornerRadius = UDim.new(0, 8)

local contentFrame = Instance.new("Frame", mainContainer)
contentFrame.Size = UDim2.new(1, 0, 1, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0

local topSection = Instance.new("Frame", contentFrame)
topSection.Size = UDim2.new(1, 0, 0, 40)
topSection.Position = UDim2.new(0, 0, 0, 0)
topSection.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
topSection.BorderSizePixel = 0
topSection.ZIndex = 0

local bottomSection = Instance.new("Frame", contentFrame)
bottomSection.Size = UDim2.new(1, 0, 1, -40)
bottomSection.Position = UDim2.new(0, 0, 0, 40)
bottomSection.BackgroundColor3 = Color3.fromRGB(33, 34, 38)
bottomSection.BorderSizePixel = 0
bottomSection.ZIndex = 0

local divider = Instance.new("Frame", contentFrame)
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Position = UDim2.new(0, 0, 0, 40)
divider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
divider.BorderSizePixel = 0
divider.ZIndex = 1

local title = Instance.new("TextLabel", contentFrame)
title.Size = UDim2.new(1, -10, 0, 20)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "EGG RANDOMIZER"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 2

local credits = Instance.new("TextLabel", contentFrame)
credits.Size = UDim2.new(1, -10, 0, 15)
credits.Position = UDim2.new(0, 5, 0, 23)
credits.BackgroundTransparency = 1
credits.Text = "by @zenxq"
credits.Font = Enum.Font.SourceSans
credits.TextSize = 11
credits.TextColor3 = Color3.fromRGB(170, 170, 170)
credits.TextXAlignment = Enum.TextXAlignment.Center
credits.ZIndex = 2

local close = Instance.new("TextButton", contentFrame)
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -25, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(220, 220, 220)
close.BackgroundTransparency = 1
close.Font = Enum.Font.SourceSansBold
close.TextSize = 14
close.ZIndex = 2

local predict = Instance.new("TextButton", contentFrame)
predict.Size = UDim2.new(0, 140, 0, 30)
predict.Position = UDim2.new(0.5, -70, 0, 50)
predict.BackgroundColor3 = Color3.fromRGB(196, 74, 74)
predict.TextColor3 = Color3.new(0, 0, 0)
predict.Font = Enum.Font.SourceSans
predict.TextSize = 14
predict.Text = "PREDICT PETS"
predict.ZIndex = 2
Instance.new("UICorner", predict).CornerRadius = UDim.new(0, 6)

local loadingBarBg = Instance.new("Frame", contentFrame)
loadingBarBg.Size = UDim2.new(0, 140, 0, 20)
loadingBarBg.Position = UDim2.new(0.5, -70, 0, 50)
loadingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
loadingBarBg.BorderSizePixel = 0
loadingBarBg.Visible = false
loadingBarBg.ZIndex = 2

local loadingBar = Instance.new("Frame", loadingBarBg)
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(53, 204, 51)
loadingBar.BorderSizePixel = 0
loadingBar.ZIndex = 3

local loadingPercent = Instance.new("TextLabel", loadingBarBg)
loadingPercent.Size = UDim2.new(1, 0, 1, 0)
loadingPercent.BackgroundTransparency = 1
loadingPercent.Text = "0%"
loadingPercent.TextColor3 = Color3.new(1, 1, 1)
loadingPercent.Font = Enum.Font.SourceSansBold
loadingPercent.TextSize = 12
loadingPercent.ZIndex = 4

local loadingText = Instance.new("TextLabel", contentFrame)
loadingText.Size = UDim2.new(1, -10, 0, 15)
loadingText.Position = UDim2.new(0, 5, 0, 75)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Rerolling pets in 3 seconds"
loadingText.TextColor3 = Color3.fromRGB(220, 220, 220)
loadingText.Font = Enum.Font.SourceSans
loadingText.TextSize = 12
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.Visible = false
loadingText.ZIndex = 2

predict.MouseEnter:Connect(function()
    predict.BackgroundColor3 = Color3.fromRGB(166, 62, 62)
end)

predict.MouseLeave:Connect(function()
    predict.BackgroundColor3 = Color3.fromRGB(196, 74, 74)
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
showBtn.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.SourceSansBold
showBtn.TextSize = 12
showBtn.ZIndex = 2
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 6)
showBtn.Visible = false

close.MouseButton1Click:Connect(function()
    mainContainer.Visible = false
    showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible = true
    showBtn.Visible = false
end)