--// TELEPORT MENU - MOBILE / PC
--// ORBIT + LOCK ON + HIGHLIGHT ESP
--// PLAYERS + NPCs
--// N = MOSTRAR/OCULTAR NPCs

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local ORBIT_SPEED = 100
local DEFAULT_ORBIT_DISTANCE = 3
local ORBIT_DISTANCE = DEFAULT_ORBIT_DISTANCE

local NORMAL_COLOR = Color3.fromRGB(50, 50, 50)
local SELECTED_COLOR = Color3.fromRGB(255, 220, 0)
local ON_COLOR = Color3.fromRGB(40, 170, 70)
local OFF_COLOR = Color3.fromRGB(70, 70, 70)
local LOCK_COLOR = Color3.fromRGB(50, 120, 220)

--------------------------------------------------
-- VARIABLES
--------------------------------------------------

local selectedTarget = nil
local targetIsNPC = false

local orbiting = false
local lockOn = false
local lockOnBeforeOrbit = false

local destroyed = false
local lastDirection = nil
local teleportTimer = 0
local ESP = nil

local showingNPCs = false

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrbitMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 210, 0, 300)
Main.Position = UDim2.new(0, 20, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 1
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -142, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Orbit"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
MinimizeButton.Position = UDim2.new(1, -128, 0, 6)
MinimizeButton.BackgroundColor3 = NORMAL_COLOR
MinimizeButton.BackgroundTransparency = 0.05
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = Header

--------------------------------------------------
-- L
--------------------------------------------------

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(0, 28, 0, 28)
LockButton.Position = UDim2.new(1, -96, 0, 6)
LockButton.BackgroundColor3 = NORMAL_COLOR
LockButton.BackgroundTransparency = 0.05
LockButton.Text = "L"
LockButton.TextColor3 = Color3.new(1, 1, 1)
LockButton.TextSize = 15
LockButton.Font = Enum.Font.GothamBold
LockButton.BorderSizePixel = 0
LockButton.Parent = Header

--------------------------------------------------
-- N
--------------------------------------------------

local NPCButton = Instance.new("TextButton")
NPCButton.Size = UDim2.new(0, 28, 0, 28)
NPCButton.Position = UDim2.new(1, -64, 0, 6)
NPCButton.BackgroundColor3 = NORMAL_COLOR
NPCButton.BackgroundTransparency = 0.05
NPCButton.Text = "N"
NPCButton.TextColor3 = Color3.new(1, 1, 1)
NPCButton.TextSize = 15
NPCButton.Font = Enum.Font.GothamBold
NPCButton.BorderSizePixel = 0
NPCButton.Parent = Header

--------------------------------------------------
-- CLOSE
--------------------------------------------------

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -32, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(120, 45, 45)
CloseButton.BackgroundTransparency = 0.05
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 15
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

--------------------------------------------------
-- LISTA
--------------------------------------------------

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Name = "PlayerList"
PlayerList.Size = UDim2.new(1, -20, 0, 175)
PlayerList.Position = UDim2.new(0, 10, 0, 48)
PlayerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerList.BackgroundTransparency = 0.2
PlayerList.BorderSizePixel = 1
PlayerList.ScrollBarThickness = 4
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.Parent = PlayerList

--------------------------------------------------
-- DISTÂNCIA
--------------------------------------------------

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(0, 75, 0, 28)
DistanceLabel.Position = UDim2.new(0, 10, 1, -68)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Distância:"
DistanceLabel.TextColor3 = Color3.new(1, 1, 1)
DistanceLabel.TextSize = 13
DistanceLabel.Font = Enum.Font.Gotham
DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
DistanceLabel.Parent = Main

local DistanceBox = Instance.new("TextBox")
DistanceBox.Size = UDim2.new(0, 55, 0, 28)
DistanceBox.Position = UDim2.new(0, 82, 1, -68)
DistanceBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DistanceBox.BackgroundTransparency = 0.15
DistanceBox.BorderSizePixel = 1
DistanceBox.Text = "3"
DistanceBox.TextColor3 = Color3.new(1, 1, 1)
DistanceBox.PlaceholderText = "3"
DistanceBox.TextSize = 13
DistanceBox.Font = Enum.Font.Gotham
DistanceBox.ClearTextOnFocus = false
DistanceBox.Parent = Main

--------------------------------------------------
-- ORBIT BUTTON
--------------------------------------------------

local OrbitButton = Instance.new("TextButton")
OrbitButton.Size = UDim2.new(1, -20, 0, 32)
OrbitButton.Position = UDim2.new(0, 10, 1, -36)
OrbitButton.BackgroundColor3 = OFF_COLOR
OrbitButton.BackgroundTransparency = 0.05
OrbitButton.BorderSizePixel = 0
OrbitButton.Text = "Orbit: OFF"
OrbitButton.TextColor3 = Color3.new(1, 1, 1)
OrbitButton.TextSize = 14
OrbitButton.Font = Enum.Font.GothamBold
OrbitButton.Parent = Main

--------------------------------------------------
-- DISTÂNCIA
--------------------------------------------------

local function UpdateDistance()

	local text = DistanceBox.Text

	if text == nil or text == "" then
		ORBIT_DISTANCE = DEFAULT_ORBIT_DISTANCE
		return
	end

	local number = tonumber(text)

	if number and number > 0 then
		ORBIT_DISTANCE = number
	else
		ORBIT_DISTANCE = DEFAULT_ORBIT_DISTANCE
	end
end

DistanceBox.FocusLost:Connect(function()

	UpdateDistance()

	if DistanceBox.Text == "" then
		DistanceBox.Text = tostring(DEFAULT_ORBIT_DISTANCE)
	end

end)

--------------------------------------------------
-- ESP
--------------------------------------------------

local function RemoveESP()

	if ESP then
		ESP:Destroy()
		ESP = nil
	end

end

local function CreateESP(target)

	RemoveESP()

	if not target then
		return
	end

	local character

	if target:IsA("Player") then
		character = target.Character
	elseif target:IsA("Model") then
		character = target
	end

	if not character then
		return
	end

	local highlight = Instance.new("Highlight")

	highlight.Name = "SelectedTargetESP"
	highlight.Adornee = character

	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 0.5

	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineTransparency = 0

	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = character

	ESP = highlight

end

--------------------------------------------------
-- PEGAR CHARACTER DO ALVO
--------------------------------------------------

local function GetTargetCharacter()

	if not selectedTarget then
		return nil
	end

	if targetIsNPC then
		return selectedTarget
	end

	return selectedTarget.Character
end

--------------------------------------------------
-- PEGAR ROOT DO ALVO
--------------------------------------------------

local function GetTargetRoot()

	local character = GetTargetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")

end

--------------------------------------------------
-- RESTAURAR CÂMERA
--------------------------------------------------

local function RestoreLocalCamera()

	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	Camera.CameraType = Enum.CameraType.Custom

	local character = LocalPlayer.Character

	if character then

		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			Camera.CameraSubject = humanoid
		end

	end

end

--------------------------------------------------
-- CÂMERA NO ALVO
--------------------------------------------------

local function ViewSelectedTarget()

	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local character = GetTargetCharacter()

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = humanoid

end

--------------------------------------------------
-- LOCK ON
--------------------------------------------------

local function EnableLockOn()

	if orbiting then
		return
	end

	if not selectedTarget then
		return
	end

	local root = GetTargetRoot()

	if not root then
		return
	end

	lockOn = true

	LockButton.BackgroundColor3 = LOCK_COLOR

	Camera = workspace.CurrentCamera

	if Camera then

		Camera.CameraType = Enum.CameraType.Custom

		local myCharacter = LocalPlayer.Character

		if myCharacter then

			local myHumanoid =
				myCharacter:FindFirstChildOfClass("Humanoid")

			if myHumanoid then
				Camera.CameraSubject = myHumanoid
			end

		end
	end

end

--------------------------------------------------
-- DESATIVAR LOCK
--------------------------------------------------

local function DisableLockOn()

	lockOn = false

	LockButton.BackgroundColor3 = NORMAL_COLOR

	RestoreLocalCamera()

end

--------------------------------------------------
-- SELECIONAR ALVO
--------------------------------------------------

local function SelectTarget(target, isNPC)

	if orbiting then
		return
	end

	selectedTarget = target
	targetIsNPC = isNPC

	for _, button in ipairs(PlayerList:GetChildren()) do

		if button:IsA("TextButton") then

			local sameTarget = false

			if isNPC then
				sameTarget =
					button:GetAttribute("NPCTarget") == target
			else
				sameTarget =
					button:GetAttribute("PlayerTarget") == target.Name
			end

			if sameTarget then
				button.TextColor3 = SELECTED_COLOR
			else
				button.TextColor3 = Color3.new(1, 1, 1)
			end

		end
	end

	CreateESP(target)

end

--------------------------------------------------
-- VERIFICAR NPC
--------------------------------------------------

local function IsNPC(model)

	if not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(model) then
		return false
	end

	local humanoid =
		model:FindFirstChildOfClass("Humanoid")

	return humanoid ~= nil

end

--------------------------------------------------
-- ATUALIZAR LISTA
--------------------------------------------------

local function UpdatePlayerList()

	for _, child in ipairs(PlayerList:GetChildren()) do

		if child:IsA("TextButton") then
			child:Destroy()
		end

	end

	--------------------------------------------------
	-- NPCs
	--------------------------------------------------

	if showingNPCs then

		Title.Text = "NPCs"
		NPCButton.BackgroundColor3 = LOCK_COLOR

		local npcs = {}

		for _, object in ipairs(workspace:GetDescendants()) do

			if IsNPC(object) then
				table.insert(npcs, object)
			end

		end

		table.sort(npcs, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)

		for _, npc in ipairs(npcs) do

			local Button = Instance.new("TextButton")

			Button.Size = UDim2.new(1, -8, 0, 30)
			Button.BackgroundColor3 = NORMAL_COLOR
			Button.BackgroundTransparency = 0.05
			Button.BorderSizePixel = 0

			Button.Text = npc.Name

			if selectedTarget == npc
				and targetIsNPC then

				Button.TextColor3 = SELECTED_COLOR

			else

				Button.TextColor3 =
					Color3.new(1, 1, 1)

			end

			Button.TextSize = 13
			Button.Font = Enum.Font.Gotham

			Button.Parent = PlayerList

			Button.Activated:Connect(function()

				SelectTarget(npc, true)

			end)

		end

	--------------------------------------------------
	-- PLAYERS
	--------------------------------------------------

	else

		Title.Text = "Orbit"
		NPCButton.BackgroundColor3 = NORMAL_COLOR

		local players = Players:GetPlayers()

		table.sort(players, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)

		for _, player in ipairs(players) do

			if player ~= LocalPlayer then

				local Button = Instance.new("TextButton")

				Button.Size =
					UDim2.new(1, -8, 0, 30)

				Button.BackgroundColor3 =
					NORMAL_COLOR

				Button.BackgroundTransparency = 0.05
				Button.BorderSizePixel = 0

				Button.Text = player.Name

				if selectedTarget == player
					and not targetIsNPC then

					Button.TextColor3 =
						SELECTED_COLOR

				else

					Button.TextColor3 =
						Color3.new(1, 1, 1)

				end

				Button.TextSize = 13
				Button.Font = Enum.Font.Gotham

				Button.Parent = PlayerList

				Button.Activated:Connect(function()

					SelectTarget(player, false)

				end)

			end

		end

	end

	task.wait()

	PlayerList.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			UIListLayout.AbsoluteContentSize.Y + 5
		)

end

--------------------------------------------------
-- PARAR ORBIT
--------------------------------------------------

local function StopOrbit()

	if not orbiting then
		return
	end

	orbiting = false

	lastDirection = nil
	teleportTimer = 0

	OrbitButton.Text = "Orbit: OFF"
	OrbitButton.BackgroundColor3 = OFF_COLOR

	if lockOnBeforeOrbit and selectedTarget then

		lockOn = true

		LockButton.BackgroundColor3 =
			LOCK_COLOR

		RestoreLocalCamera()

	else

		lockOn = false

		LockButton.BackgroundColor3 =
			NORMAL_COLOR

		RestoreLocalCamera()

	end

end

--------------------------------------------------
-- INICIAR ORBIT
--------------------------------------------------

local function StartOrbit()

	if not selectedTarget then

		OrbitButton.Text =
			"Selecione alguém!"

		task.delay(1, function()

			if not destroyed and not orbiting then
				OrbitButton.Text =
					"Orbit: OFF"
			end

		end)

		return
	end

	local targetRoot =
		GetTargetRoot()

	if not targetRoot then
		return
	end

	UpdateDistance()

	lockOnBeforeOrbit =
		lockOn

	lockOn = false

	LockButton.BackgroundColor3 =
		OFF_COLOR

	orbiting = true

	lastDirection = nil
	teleportTimer = 0

	OrbitButton.Text =
		"Orbit: ON"

	OrbitButton.BackgroundColor3 =
		ON_COLOR

	ViewSelectedTarget()

end

--------------------------------------------------
-- BOTÃO ORBIT
--------------------------------------------------

OrbitButton.Activated:Connect(function()

	if orbiting then
		StopOrbit()
	else
		StartOrbit()
	end

end)

--------------------------------------------------
-- BOTÃO L
--------------------------------------------------

LockButton.Activated:Connect(function()

	if orbiting then
		return
	end

	if lockOn then
		DisableLockOn()
	else
		EnableLockOn()
	end

end)

--------------------------------------------------
-- BOTÃO N
--------------------------------------------------

NPCButton.Activated:Connect(function()

	if orbiting then
		return
	end

	showingNPCs =
		not showingNPCs

	RemoveESP()

	selectedTarget = nil
	targetIsNPC = false

	lockOn = false

	LockButton.BackgroundColor3 =
		NORMAL_COLOR

	UpdatePlayerList()

end)

--------------------------------------------------
-- ORBIT + LOCK ON
--------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)

	if destroyed then
		return
	end

	--------------------------------------------------
	-- LOCK ON
	--------------------------------------------------

	if lockOn
		and not orbiting
		and selectedTarget then

		local targetRoot =
			GetTargetRoot()

		if targetRoot then

			Camera =
				workspace.CurrentCamera

			if Camera then

				Camera.CameraType =
					Enum.CameraType.Custom

				local myCharacter =
					LocalPlayer.Character

				local myHumanoid =
					myCharacter
					and myCharacter:
						FindFirstChildOfClass(
							"Humanoid"
						)

				if myHumanoid then

					if Camera.CameraSubject
						~= myHumanoid then

						Camera.CameraSubject =
							myHumanoid

					end

				end

				-- NÃO MOVE A CÂMERA.
				-- SÓ FAZ ELA OLHAR PARA O ALVO.

				local cameraPosition =
					Camera.CFrame.Position

				Camera.CFrame =
					CFrame.lookAt(
						cameraPosition,
						targetRoot.Position
					)

			end

		end

	end

	--------------------------------------------------
	-- ORBIT
	--------------------------------------------------

	if not orbiting then
		return
	end

	if not selectedTarget then

		StopOrbit()

		return
	end

	local myCharacter =
		LocalPlayer.Character

	local targetCharacter =
		GetTargetCharacter()

	if not myCharacter
		or not targetCharacter then

		return
	end

	local myRoot =
		myCharacter:
			FindFirstChild(
				"HumanoidRootPart"
			)

	local targetRoot =
		GetTargetRoot()

	if not myRoot
		or not targetRoot then

		return
	end

	teleportTimer += deltaTime

	local interval =
		1 / ORBIT_SPEED

	if teleportTimer < interval then
		return
	end

	teleportTimer = 0

	local directions = {

		targetRoot.CFrame.LookVector,

		-targetRoot.CFrame.LookVector,

		-targetRoot.CFrame.RightVector,

		targetRoot.CFrame.RightVector

	}

	local availableDirections = {}

	for _, direction in ipairs(directions) do

		if direction ~= lastDirection then

			table.insert(
				availableDirections,
				direction
			)

		end

	end

	local direction =
		availableDirections[
			math.random(
				1,
				#availableDirections
			)
		]

	lastDirection =
		direction

	local distance =
		ORBIT_DISTANCE

	local teleportPosition =
		targetRoot.Position
		+ direction * distance

	myRoot.CFrame =
		CFrame.lookAt(
			teleportPosition,
			targetRoot.Position
		)

end)

--------------------------------------------------
-- MONITORAR PLAYERS
--------------------------------------------------

local function WatchPlayer(player)

	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(function()

		task.wait(0.25)

		if destroyed then
			return
		end

		if selectedTarget == player
			and not targetIsNPC then

			CreateESP(player)

		end

	end)

end

for _, player in ipairs(
	Players:GetPlayers()
) do

	WatchPlayer(player)

end

Players.PlayerAdded:Connect(function(player)

	WatchPlayer(player)

	task.wait(0.2)

	if not destroyed
		and not showingNPCs then

		UpdatePlayerList()

	end

end)

--------------------------------------------------
-- PLAYER SAINDO
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	if selectedTarget == player
		and not targetIsNPC then

		RemoveESP()

		selectedTarget = nil

		if orbiting then
			StopOrbit()
		end

		if lockOn then
			DisableLockOn()
		end

	end

	task.wait(0.1)

	if not destroyed
		and not showingNPCs then

		UpdatePlayerList()

	end

end)

--------------------------------------------------
-- RESPAWN
--------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function()

	task.wait(0.5)

	if destroyed then
		return
	end

	if orbiting then

		ViewSelectedTarget()

	else

		RestoreLocalCamera()

	end

end)

--------------------------------------------------
-- MINIMIZAR
--------------------------------------------------

local minimized = false

MinimizeButton.Activated:Connect(function()

	minimized =
		not minimized

	if minimized then

		Main.Size =
			UDim2.new(
				0,
				210,
				0,
				40
			)

		PlayerList.Visible = false
		DistanceLabel.Visible = false
		DistanceBox.Visible = false
		OrbitButton.Visible = false

		MinimizeButton.Text = "+"

	else

		Main.Size =
			UDim2.new(
				0,
				210,
				0,
				300
			)

		PlayerList.Visible = true
		DistanceLabel.Visible = true
		DistanceBox.Visible = true
		OrbitButton.Visible = true

		MinimizeButton.Text = "-"

	end

end)

--------------------------------------------------
-- FECHAR
--------------------------------------------------

CloseButton.Activated:Connect(function()

	destroyed = true

	orbiting = false
	lockOn = false

	RemoveESP()

	RestoreLocalCamera()

	ScreenGui:Destroy()

end)

--------------------------------------------------
-- INICIALIZAÇÃO
--------------------------------------------------

UpdatePlayerList()
UpdateDistance()

--------------------------------------------------
-- ATUALIZAR NPCs
--------------------------------------------------

task.spawn(function()

	while not destroyed do

		task.wait(1)

		if showingNPCs
			and not orbiting then

			UpdatePlayerList()

		end

	end

end)

--------------------------------------------------
-- MANTER ESP
--------------------------------------------------

task.spawn(function()

	while not destroyed do

		task.wait(0.5)

		if selectedTarget then

			local character =
				GetTargetCharacter()

			if not ESP
				or not ESP.Parent
				or ESP.Adornee ~= character then

				CreateESP(selectedTarget)

			end

		end

	end

end)
