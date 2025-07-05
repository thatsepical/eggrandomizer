local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "CustomGUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundTransparency = 1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local updateAllEsp = nil
local activeEggs = {}
local espCache = {}

local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Parent = mainFrame
cooldownLabel.Position = UDim2.new(0, 0, 0, 120)
cooldownLabel.Size = UDim2.new(0, 240, 0, 25)
cooldownLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
cooldownLabel.TextColor3 = Color3.new(1, 1, 1)
cooldownLabel.TextScaled = true
cooldownLabel.Font = Enum.Font.SourceSansBold
cooldownLabel.Visible = false

local function createToggle(name, pos, initialState, callback)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = pos
	frame.Size = UDim2.new(0, 240, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.Parent = mainFrame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.TextScaled = true
	button.Font = Enum.Font.SourceSansBold
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = frame

	local isOn = initialState
	local randomizerRunning = false

	local function updateText()
		local icon = isOn and ":green_circle:" or ":red_circle:"
		local status = isOn and "ON" or "OFF"
		if name == "AutoHatch" then
			button.Text = icon .. " Auto Hatch:\n" .. status
		elseif name == "AutoRandomizer" then
			button.Text = icon .. " Auto\nRandomizer: " .. status
		end
	end

	button.MouseButton1Click:Connect(function()
		isOn = not isOn
		updateText()

		if name == "AutoRandomizer" then
			if isOn and not randomizerRunning then
				randomizerRunning = true
				task.spawn(function()
					while isOn do
						if callback then callback(true) end
						cooldownLabel.Visible = true
						for i = 10, 1, -1 do
							cooldownLabel.Text = "Cooldown: " .. i .. "s"
							task.wait(1)
						end
						cooldownLabel.Text = "Randomizing..."
						task.wait(3)
					end
					cooldownLabel.Visible = false
					cooldownLabel.Text = ""
					randomizerRunning = false
				end)
			end
		else
			if callback then callback(isOn) end
		end
	end)

	updateText()
end

createToggle("AutoHatch", UDim2.new(0, 0, 0, 0), true)
createToggle("AutoRandomizer", UDim2.new(0, 0, 0, 60), false, function()
	if updateAllEsp then updateAllEsp() end
end)

local antiAfkFrame = Instance.new("Frame", mainFrame)
antiAfkFrame.Position = UDim2.new(0, 0, 0, 160)
antiAfkFrame.Size = UDim2.new(0, 240, 0, 50)
antiAfkFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
antiAfkFrame.BorderSizePixel = 0

local antiAfkLabel = Instance.new("TextLabel", antiAfkFrame)
antiAfkLabel.Size = UDim2.new(1, 0, 1, 0)
antiAfkLabel.BackgroundTransparency = 1
antiAfkLabel.Text = ":white_check_mark: Anti-AFK: ON"
antiAfkLabel.TextScaled = true
antiAfkLabel.Font = Enum.Font.SourceSansBold
antiAfkLabel.TextColor3 = Color3.new(1, 1, 1)

local helpButton = Instance.new("TextButton", mainFrame)
helpButton.Position = UDim2.new(0, 250, 0, 0)
helpButton.Size = UDim2.new(0, 30, 0, 50)
helpButton.Text = ":question:"
helpButton.TextScaled = true
helpButton.Font = Enum.Font.SourceSansBold
helpButton.TextColor3 = Color3.new(1, 1, 1)
helpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
helpButton.BorderSizePixel = 0

local helpPopup = Instance.new("Frame", mainFrame)
helpPopup.Position = UDim2.new(0.5, -150, 0.5, -75)
helpPopup.Size = UDim2.new(0, 300, 0, 150)
helpPopup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
helpPopup.Visible = false
helpPopup.BorderSizePixel = 0

local helpText = Instance.new("TextLabel", helpPopup)
helpText.Size = UDim2.new(1, -20, 1, -20)
helpText.Position = UDim2.new(0, 10, 0, 10)
helpText.BackgroundTransparency = 1
helpText.TextColor3 = Color3.new(1, 1, 1)
helpText.Font = Enum.Font.SourceSans
helpText.TextSize = 18
helpText.TextWrapped = true
helpText.Text = "Auto Hatches when:\nQueen Bee, Raccoon, Dragonfly,\nMimic Octopus, Butterfly, Disco Bee"

helpButton.MouseButton1Click:Connect(function()
	helpPopup.Visible = not helpPopup.Visible
end)

local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local localPlayer = player

local hatchFunction = getupvalue(getupvalue(getconnections(replicatedStorage.GameEvents.PetEggService.OnClientEvent)[1].Function, 1), 2)
local eggModels = getupvalue(hatchFunction, 1)
local eggPets = getupvalue(hatchFunction, 2)

local function getObjectFromId(objectId)
	for eggModel in eggModels do
		if eggModel:GetAttribute("OBJECT_UUID") ~= objectId then continue end
		return eggModel
	end
end

local function UpdateEsp(objectId, petName)
	local object = getObjectFromId(objectId)
	if not object or not espCache[objectId] then return end

	local eggName = object:GetAttribute("EggName")
	local displayName = petName or "Cannot hatch yet!"
	espCache[objectId].Text = `{eggName} | {displayName}`
end

local function AddEsp(object)
	if object:GetAttribute("OWNER") ~= localPlayer.Name then return end

	local eggName = object:GetAttribute("EggName")
	local petName = eggPets[object:GetAttribute("OBJECT_UUID")]
	local objectId = object:GetAttribute("OBJECT_UUID")
	if not objectId then return end

	local label = Drawing.new("Text")
	label.Text = `{eggName} | {petName or "Cannot hatch yet!"}`
	label.Size = 24
	label.Color = Color3.new(1, 1, 1)
	label.Outline = true
	label.OutlineColor = Color3.new(0, 0, 0)
	label.Center = true
	label.Visible = false

	espCache[objectId] = label
	activeEggs[objectId] = object
end

local function RemoveEsp(object)
	if object:GetAttribute("OWNER") ~= localPlayer.Name then return end

	local objectId = object:GetAttribute("OBJECT_UUID")
	if espCache[objectId] then
		espCache[objectId]:Remove()
		espCache[objectId] = nil
	end
	activeEggs[objectId] = nil
end

updateAllEsp = function()
	for objectId, object in activeEggs do
		local petName = eggPets[objectId]
		UpdateEsp(objectId, petName)
	end
end

local function UpdateEspPositions()
	for objectId, object in activeEggs do
		if not object or not object:IsDescendantOf(workspace) then
			activeEggs[objectId] = nil
			if espCache[objectId] then
				espCache[objectId].Visible = false
			end
			continue
		end

		local label = espCache[objectId]
		if label then
			local pos, onScreen = currentCamera:WorldToViewportPoint(object:GetPivot().Position)
			label.Visible = onScreen
			if onScreen then
				label.Position = Vector2.new(pos.X, pos.Y)
			end
		end
	end
end

local old
old = hookfunction(getconnections(replicatedStorage.GameEvents.EggReadyToHatch_RE.OnClientEvent)[1].Function, newcclosure(function(objectId, petName)
	UpdateEsp(objectId, petName)
	return old(objectId, petName)
end))

for _, object in collectionService:GetTagged("PetEggServer") do
	task.spawn(AddEsp, object)
end
collectionService:GetInstanceAddedSignal("PetEggServer"):Connect(AddEsp)
collectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(RemoveEsp)
runService.PreRender:Connect(UpdateEspPositions)
