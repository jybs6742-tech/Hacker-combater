--// TELEPORT MENU - MOBILE extreml
--// ORBIT + LOCK ON + HIGHLIGHT ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local ORBIT_SPEED = 5000000
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

local selectedPlayer = nil
local orbiting = false
local lockOn = false
local lockOnBeforeOrbit = false

local destroyed = false
local lastDirection = nil
local teleportTimer = 0
local ESP = nil

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
Title.Size = UDim2.new(1, -110, 1, 0)
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
MinimizeButton.Position = UDim2.new(1, -96, 0, 6)
MinimizeButton.BackgroundColor3 = NORMAL_COLOR
MinimizeButton.BackgroundTransparency = 0.05
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = Header

--------------------------------------------------
-- LOCK ON
--------------------------------------------------

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(0, 28, 0, 28)
LockButton.Position = UDim2.new(1, -64, 0, 6)
LockButton.BackgroundColor3 = NORMAL_COLOR
LockButton.BackgroundTransparency = 0.05
LockButton.Text = "L"
LockButton.TextColor3 = Color3.new(1, 1, 1)
LockButton.TextSize = 15
LockButton.Font = Enum.Font.GothamBold
LockButton.BorderSizePixel = 0
LockButton.Parent = Header

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
-- PLAYER LIST
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
-- DISTANCE
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
-- DISTANCE
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
-- HIGHLIGHT ESP
--------------------------------------------------

local function RemoveESP()
	if ESP then
		ESP:Destroy()
		ESP = nil
	end
end

local function CreateESP(player)
	RemoveESP()

	if not player or not player.Character then
		return
	end

	local highlight = Instance.new("Highlight")

	highlight.Name = "SelectedPlayerESP"
	highlight.Adornee = player.Character

	-- Preenche o corpo inteiro
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 0.5

	-- Contorno vermelho
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineTransparency = 0

	-- Continua aparecendo mesmo atrás de objetos
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = player.Character

	ESP = highlight
end

--------------------------------------------------
-- RESTAURAR CÂMERA NO PRÓPRIO PLAYER
--------------------------------------------------

local function RestoreLocalCamera()
	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	Camera.CameraType = Enum.CameraType.Custom

	local character = LocalPlayer.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			Camera.CameraSubject = humanoid
		end
	end
end

--------------------------------------------------
-- VIEW NO PLAYER SELECIONADO
-- USADO DURANTE O ORBIT
--------------------------------------------------

local function ViewSelectedPlayer()
	Camera = workspace.CurrentCamera

	if not Camera or not selectedPlayer then
		return
	end

	local character = selectedPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = humanoid
end

--------------------------------------------------
-- ATIVAR LOCK ON
-- CÂMERA CONTINUA NO SEU PERSONAGEM
--------------------------------------------------

local function EnableLockOn()
	if orbiting then
		return
	end

	if not selectedPlayer then
		return
	end

	local character = selectedPlayer.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

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
-- DESATIVAR LOCK ON
--------------------------------------------------

local function DisableLockOn()
	lockOn = false

	LockButton.BackgroundColor3 = NORMAL_COLOR

	RestoreLocalCamera()
end

--------------------------------------------------
-- SELECIONAR PLAYER
--------------------------------------------------

local function SelectPlayer(player)
	if orbiting then
		return
	end

	selectedPlayer = player

	for _, button in ipairs(PlayerList:GetChildren()) do
		if button:IsA("TextButton") then

			if button:GetAttribute("PlayerName") == player.Name then
				button.TextColor3 = SELECTED_COLOR
			else
				button.TextColor3 = Color3.new(1, 1, 1)
			end

		end
	end

	CreateESP(player)
end

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local function UpdatePlayerList()

	for _, child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local players = Players:GetPlayers()

	table.sort(players, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	for _, player in ipairs(players) do

		if player ~= LocalPlayer then

			local Button = Instance.new("TextButton")

			Button.Size = UDim2.new(1, -8, 0, 30)
			Button.BackgroundColor3 = NORMAL_COLOR
			Button.BackgroundTransparency = 0.05
			Button.BorderSizePixel = 0

			Button.Text = player.Name

			if selectedPlayer == player then
				Button.TextColor3 = SELECTED_COLOR
			else
				Button.TextColor3 = Color3.new(1, 1, 1)
			end

			Button.TextSize = 13
			Button.Font = Enum.Font.Gotham
			Button:SetAttribute("PlayerName", player.Name)
			Button.Parent = PlayerList

			Button.Activated:Connect(function()
				SelectPlayer(player)
			end)
		end
	end

	task.wait()

	PlayerList.CanvasSize =
		UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
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

	--------------------------------------------------
	-- RESTAURA O LOCK ON ANTERIOR
	--------------------------------------------------

	if lockOnBeforeOrbit and selectedPlayer then

		lockOn = true
		LockButton.BackgroundColor3 = LOCK_COLOR

		RestoreLocalCamera()

	else

		lockOn = false
		LockButton.BackgroundColor3 = NORMAL_COLOR

		task.defer(function()
			if not destroyed and not orbiting then
				RestoreLocalCamera()
			end
		end)
	end
end

--------------------------------------------------
-- INICIAR ORBIT
--------------------------------------------------

local function StartOrbit()

	if not selectedPlayer then

		OrbitButton.Text = "Selecione alguém!"

		task.delay(1, function()

			if not destroyed and not orbiting then
				OrbitButton.Text = "Orbit: OFF"
			end

		end)

		return
	end

	local character = selectedPlayer.Character

	if not character then
		return
	end

	local targetRoot =
		character:FindFirstChild("HumanoidRootPart")

	if not targetRoot then
		return
	end

	UpdateDistance()

	--------------------------------------------------
	-- SALVA O ESTADO DO LOCK ON
	--------------------------------------------------

	lockOnBeforeOrbit = lockOn

	-- Lock On fica temporariamente desligado
	lockOn = false
	LockButton.BackgroundColor3 = OFF_COLOR

	orbiting = true
	lastDirection = nil
	teleportTimer = 0

	OrbitButton.Text = "Orbit: ON"
	OrbitButton.BackgroundColor3 = ON_COLOR

	--------------------------------------------------
	-- DURANTE O ORBIT:
	-- CAMERA OLHA O PLAYER SELECIONADO
	--------------------------------------------------

	ViewSelectedPlayer()
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
-- BOTÃO LOCK ON
--------------------------------------------------

LockButton.Activated:Connect(function()

	-- Não pode usar Lock On durante Orbit
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
-- ORBIT + LOCK ON
--------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)

	if destroyed then
		return
	end

	--------------------------------------------------
	-- LOCK ON
	--------------------------------------------------

	if lockOn and not orbiting and selectedPlayer then

		local character = selectedPlayer.Character

		local targetRoot =
			character and
			character:FindFirstChild("HumanoidRootPart")

		if targetRoot then

			Camera = workspace.CurrentCamera

			if Camera then

				-- Continua seguindo VOCÊ
				Camera.CameraType = Enum.CameraType.Custom

				local myCharacter = LocalPlayer.Character

				local myHumanoid =
					myCharacter and
					myCharacter:FindFirstChildOfClass("Humanoid")

				if myHumanoid then
					if Camera.CameraSubject ~= myHumanoid then
						Camera.CameraSubject = myHumanoid
					end
				end

				--------------------------------------------------
				-- NÃO MOVE A CÂMERA.
				-- APENAS FAZ ELA OLHAR PARA O ALVO.
				--------------------------------------------------

				local cameraPosition = Camera.CFrame.Position

				Camera.CFrame = CFrame.lookAt(
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

	if not selectedPlayer then
		StopOrbit()
		return
	end

	local myCharacter = LocalPlayer.Character
	local targetCharacter = selectedPlayer.Character

	if not myCharacter or not targetCharacter then
		return
	end

	local myRoot =
		myCharacter:FindFirstChild("HumanoidRootPart")

	local targetRoot =
		targetCharacter:FindFirstChild("HumanoidRootPart")

	if not myRoot or not targetRoot then
		return
	end

	teleportTimer += deltaTime

	local interval = 0 / ORBIT_SPEED

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
			table.insert(availableDirections, direction)
		end

	end

	local direction =
		availableDirections[
			math.random(1, #availableDirections)
		]

	lastDirection = direction

	local distance = ORBIT_DISTANCE

	local teleportPosition =
		targetRoot.Position +
		direction * distance

	myRoot.CFrame = CFrame.lookAt(
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

		if selectedPlayer == player then

			CreateESP(player)

			if orbiting then
				ViewSelectedPlayer()
			end
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	WatchPlayer(player)
end

Players.PlayerAdded:Connect(function(player)

	WatchPlayer(player)

	task.wait(0.2)

	if not destroyed then
		UpdatePlayerList()
	end
end)

--------------------------------------------------
-- PLAYER SAINDO
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	if selectedPlayer == player then

		RemoveESP()

		selectedPlayer = nil

		if orbiting then
			StopOrbit()
		end

		if lockOn then
			DisableLockOn()
		end
	end

	task.wait(0.1)

	if not destroyed then
		UpdatePlayerList()
	end
end)

--------------------------------------------------
-- RESPAWN DO PRÓPRIO PLAYER
--------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function()

	task.wait(0.5)

	if destroyed then
		return
	end

	if orbiting then
		ViewSelectedPlayer()
	else
		RestoreLocalCamera()
	end
end)

--------------------------------------------------
-- MINIMIZAR
--------------------------------------------------

local minimized = false

MinimizeButton.Activated:Connect(function()

	minimized = not minimized

	if minimized then

		Main.Size = UDim2.new(0, 210, 0, 40)

		PlayerList.Visible = false
		DistanceLabel.Visible = false
		DistanceBox.Visible = false
		OrbitButton.Visible = false

		MinimizeButton.Text = "+"

	else

		Main.Size = UDim2.new(0, 210, 0, 300)

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
-- MANTER ESP NO PLAYER SELECIONADO
--------------------------------------------------

task.spawn(function()

	while not destroyed do

		task.wait(0.5)

		if selectedPlayer then

			if not ESP
				or not ESP.Parent
				or not selectedPlayer.Character
				or ESP.Adornee ~= selectedPlayer.Character
			then
				CreateESP(selectedPlayer)
			end

		end
	end

end)
