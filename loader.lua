-- SERVICES
local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local localPlayer = players.LocalPlayer or players:GetPlayers()[1]

-- DATA
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

-- FUNCTION: Get a valid pet (not 0%)
local function getPetForEgg(eggName)
    local pets = eggChances[eggName]
    if not pets then return "?" end
    local valid = {}
    for pet, chance in pairs(pets) do
        if chance > 0 then table.insert(valid, pet) end
    end
    return #valid > 0 and valid[math.random(1, #valid)] or "?"
end

-- FUNCTION: Create ESP GUI
local function createEspGui(object, labelText)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    local adornee = object:FindFirstChildWhichIsA("BasePart") or object.PrimaryPart
    if not adornee then return nil end
    billboard.Adornee = adornee
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    billboard.Parent = game:GetService("CoreGui")
    return billboard
end

-- FUNCTION: Add ESP
local function addESP(egg)
    if egg:GetAttribute("OWNER") ~= localPlayer.Name then return end
    local eggName = egg:GetAttribute("EggName")
    local objectId = egg:GetAttribute("OBJECT_UUID")
    if not eggName or not objectId or displayedEggs[objectId] then return end
    local pet = getPetForEgg(eggName)
    local labelText = eggName .. " | " .. pet
    local espGui = createEspGui(egg, labelText)
    if espGui then
        displayedEggs[objectId] = {
            egg = egg,
            gui = espGui,
            label = espGui:FindFirstChild("TextLabel"),
            eggName = eggName,
            currentPet = pet
        }
    end
end

-- FUNCTION: Remove ESP
local function removeESP(egg)
    local objectId = egg:GetAttribute("OBJECT_UUID")
    if objectId and displayedEggs[objectId] then
        displayedEggs[objectId].gui:Destroy()
        displayedEggs[objectId] = nil
    end
end

-- CONNECT ESP TO EGGS
for _, egg in collectionService:GetTagged("PetEggServer") do addESP(egg) end
collectionService:GetInstanceAddedSignal("PetEggServer"):Connect(addESP)
collectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(removeESP)

-- GUI SETUP
local gui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
gui.Name = "PetPredictorUI"
gui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 150)
frame.Position = UDim2.new(0.5, -120, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- TITLE LABEL
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "ðŸ¾ Pet Predictor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -30, 0, 10)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

-- PREDICT BUTTON
local predict = Instance.new("TextButton", frame)
predict.Size = UDim2.new(0, 180, 0, 36)
predict.Position = UDim2.new(0.5, -90, 0, 60)
predict.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
predict.TextColor3 = Color3.new(1, 1, 1)
predict.Font = Enum.Font.GothamBold
predict.TextSize = 18
predict.Text = "ðŸ”® Predict Pets"
Instance.new("UICorner", predict).CornerRadius = UDim.new(0, 8)

predict.MouseEnter:Connect(function()
    predict.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
end)
predict.MouseLeave:Connect(function()
    predict.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
end)

predict.MouseButton1Click:Connect(function()
    for _, data in pairs(displayedEggs) do
        local newPet = getPetForEgg(data.eggName)
        if data.label then
            data.label.Text = data.eggName .. " | " .. newPet
        end
        data.currentPet = newPet
    end
end)

-- CREDITS
local credits = Instance.new("TextLabel", frame)
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -20)
credits.BackgroundTransparency = 1
credits.Text = "made by: anonymous person ðŸ‘¨ðŸ»â€ðŸ’»"
credits.Font = Enum.Font.Gotham
credits.TextSize = 13
credits.TextColor3 = Color3.fromRGB(170, 170, 170)

-- TOGGLE BUTTON
local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.new(0, 100, 0, 36)
showBtn.Position = UDim2.new(0, 20, 0.5, -18)
showBtn.Text = "ðŸ¾ Show UI"
showBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.GothamBold
showBtn.TextSize = 16
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 8)
showBtn.Visible = false

-- TOGGLE EVENTS
close.MouseButton1Click:Connect(function()
    frame.Visible = false
    showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    showBtn.Visible = false
end)