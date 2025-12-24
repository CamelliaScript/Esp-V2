local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Client = Players.LocalPlayer

local guiEnabled = true
local ESP_GENERAL = false
local espUsuariosActivos = {}
local disabledESPPlayers = {}
local activeESPPlayers = {}

local COLOR_BG = Color3.fromRGB(255,180,200)
local COLOR_BUTTON = Color3.fromRGB(255,140,180)
local COLOR_TEXT = Color3.fromRGB(255,255,255)
local COLOR_TEXTBOX = Color3.fromRGB(240,200,210)
local COLOR_BORDER = Color3.fromRGB(255,255,255)

local COLOR_NEAR = Color3.fromRGB(255,120,120)
local COLOR_FAR  = Color3.fromRGB(120,180,255)
local COLOR_OUTLINE = Color3.fromRGB(255,140,180)
local COLOR_GENERAL_HIGHLIGHT = Color3.fromRGB(180,255,180)

local ScreenGui = Instance.new("ScreenGui", Client.PlayerGui)
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,220,0,180)
Main.Position = UDim2.new(1, -600, 0.5, -90)
Main.AnchorPoint = Vector2.new(0,0)
Main.BackgroundColor3 = COLOR_BG
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = COLOR_BORDER
mainStroke.Thickness = 4

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,28)
Title.BackgroundTransparency = 1
Title.Text = "ESP Manager"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = COLOR_TEXT
Title.TextXAlignment = Enum.TextXAlignment.Center

local UserBox = Instance.new("TextBox", Main)
UserBox.Size = UDim2.new(1,-20,0,26)
UserBox.Position = UDim2.new(0,10,0,38)
UserBox.BackgroundColor3 = COLOR_TEXTBOX
UserBox.TextColor3 = Color3.fromRGB(255,140,180)
UserBox.Font = Enum.Font.GothamBold
UserBox.TextSize = 20
UserBox.ClearTextOnFocus = false
UserBox.PlaceholderText = "Usuario"
UserBox.PlaceholderColor3 = COLOR_TEXTBOX
UserBox.Text = ""
Instance.new("UICorner", UserBox).CornerRadius = UDim.new(0,6)
local userStroke = Instance.new("UIStroke", UserBox)
userStroke.Color = COLOR_BORDER
userStroke.Thickness = 2

local function createButton(parent, text, yPos)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1,-20,0,26)
	btn.Position = UDim2.new(0,10,0,yPos)
	btn.BackgroundColor3 = COLOR_BUTTON
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.TextColor3 = COLOR_TEXT
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = COLOR_BORDER
	stroke.Thickness = 0
	return btn
end

local ApplyESPBtn = createButton(Main, "Aplicar ESP (Usuario)", 70)
local DisableESPBtn = createButton(Main, "Desactivar ESP (Usuario)", 100)
local ESPGeneralBtn = createButton(Main, "ESP General", 130)

local function clearESP(player)
	if player.Character then
		for _, obj in ipairs(player.Character:GetDescendants()) do
			if obj:IsA("Highlight") or obj:IsA("BillboardGui") then obj:Destroy() end
		end
	end
	activeESPPlayers[player] = nil
end

local function createESP(player, isGeneral)
	if not player.Character or player == Client then return end
	local char = player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local existing = char:FindFirstChild("ESP_Highlight")
	if not existing then
		local glow = Instance.new("Highlight")
		glow.Name = "ESP_Highlight"
		glow.FillTransparency = isGeneral and 0.9 or 0.85
		glow.OutlineTransparency = 0.3
		glow.Parent = char
	end

	if not isGeneral then
		local head = char:FindFirstChild("Head")
		if not head then return end

		local old = head:FindFirstChild("ESP_TAG")
		if old then old:Destroy() end

		local gui = Instance.new("BillboardGui")
		gui.Name = "ESP_TAG"
		gui.Adornee = head
		gui.Size = UDim2.new(0,150,0,50)
		gui.AlwaysOnTop = true
		gui.LightInfluence = 0
		gui.StudsOffset = Vector3.new(0,11,0)
		gui.Parent = head

		local function makeLabel(offsetX, offsetY, color, yScale)
			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1,0,0.5,0)
			lbl.Position = UDim2.new(0, offsetX, yScale, offsetY)
			lbl.Font = Enum.Font.SourceSansBold
			lbl.TextScaled = false
			lbl.TextSize = 28
			lbl.TextColor3 = color
			lbl.Parent = gui
			return lbl
		end

		local glow_name = makeLabel(0,0,COLOR_OUTLINE,0.15)
		local w1_name = makeLabel(2,2,COLOR_OUTLINE,0.15)
		local w2_name = makeLabel(-2,-2,COLOR_OUTLINE,0.15)
		local txt_name = makeLabel(0,0,COLOR_FAR,0.15)

		local glow_info = makeLabel(0,0,COLOR_OUTLINE,0.55)
		local w1_info = makeLabel(2,2,COLOR_OUTLINE,0.55)
		local w2_info = makeLabel(-2,-2,COLOR_OUTLINE,0.55)
		local txt_info = makeLabel(0,0,COLOR_FAR,0.55)

		task.spawn(function()
			while player.Parent and char.Parent and head.Parent and gui.Parent do
				local hum = char:FindFirstChild("Humanoid")
				local hp = hum and math.floor(hum.Health) or 0
				local dist = 0
				if Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") then
					dist = (Client.Character.HumanoidRootPart.Position - head.Position).Magnitude
				end
				local col = dist < 50 and COLOR_NEAR or COLOR_FAR

				txt_name.Text = player.Name
				glow_name.Text = player.Name
				w1_name.Text = player.Name
				w2_name.Text = player.Name

				local info_text = string.format("HP: %d | %d studs", hp, dist)
				txt_info.Text = info_text
				glow_info.Text = info_text
				w1_info.Text = info_text
				w2_info.Text = info_text

				local highlightColor
if ESP_GENERAL then
    if dist <= 50 then
        highlightColor = Color3.fromRGB(255,180,200) -- rosado pastel cerca
    else
        highlightColor = Color3.fromRGB(230,230,230) -- blanco de lejos
    end
else
    if dist <= 50 then
        highlightColor = Color3.fromRGB(255,180,200) -- rosado pastel cerca
    else
        highlightColor = Color3.fromRGB(230,230,230) -- blanco de lejos
    end
end

-- Texto principal
txt_name.TextColor3 = highlightColor
txt_info.TextColor3 = highlightColor

-- Bordes
local bordeColor
local bordeTransp
if highlightColor == Color3.fromRGB(255,180,200) then
    -- rosado pastel → borde blanco sólido
    bordeColor = Color3.fromRGB(255,255,255)
    bordeTransp = 0
else
    -- blanco → borde negro semi-transparente
    bordeColor = Color3.fromRGB(0,0,0)
    bordeTransp = 0.5
end

-- Bordes del nombre
glow_name.TextColor3 = bordeColor
glow_name.TextTransparency = bordeTransp
w1_name.TextColor3 = bordeColor
w1_name.TextTransparency = bordeTransp
w2_name.TextColor3 = bordeColor
w2_name.TextTransparency = bordeTransp

-- Bordes del info (HP y studs)
glow_info.TextColor3 = bordeColor
glow_info.TextTransparency = bordeTransp
w1_info.TextColor3 = bordeColor
w1_info.TextTransparency = bordeTransp
w2_info.TextColor3 = bordeColor
w2_info.TextTransparency = bordeTransp
				task.wait(0.2)
			end
		end)
	end
	activeESPPlayers[player] = true
end

local function applyESP(player)
	local name = player.Name:lower()
	local isActive = ESP_GENERAL or (espUsuariosActivos[name] and not disabledESPPlayers[name])
	if disabledESPPlayers[name] and not ESP_GENERAL then isActive = false end

	if isActive then
		createESP(player, ESP_GENERAL)
	else
		clearESP(player)
	end
end

-- ================= BOTONES LOGICA =================
ApplyESPBtn.MouseButton1Click:Connect(function()
	local target = Players:FindFirstChild(UserBox.Text)
	if target then
		espUsuariosActivos[target.Name:lower()] = true
		disabledESPPlayers[target.Name:lower()] = nil
		applyESP(target)
	end
end)

DisableESPBtn.MouseButton1Click:Connect(function()
	local target = Players:FindFirstChild(UserBox.Text)
	if target then
		disabledESPPlayers[target.Name:lower()] = true
		espUsuariosActivos[target.Name:lower()] = nil
		applyESP(target)
	end
end)

ESPGeneralBtn.MouseButton1Click:Connect(function()
	ESP_GENERAL = not ESP_GENERAL
	for _, p in ipairs(Players:GetPlayers()) do
		applyESP(p)
	end
	if ESP_GENERAL then
		ESPGeneralBtn.Text = "ESP Normal"
		ESPGeneralBtn.BackgroundColor3 = Color3.fromRGB(255,120,150)
	else
		ESPGeneralBtn.Text = "ESP General"
		ESPGeneralBtn.BackgroundColor3 = COLOR_BUTTON
	end
end)

-- ================= LOOP PRINCIPAL =================
RS.RenderStepped:Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do
		if activeESPPlayers[p] and p.Character then
			local glow = p.Character:FindFirstChild("ESP_Highlight")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if glow and hrp then
				local dist = (Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")) 
					and (Client.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0

				local rosadoPastel = Color3.fromRGB(255,180,200)
				local blancoGlow = Color3.fromRGB(200,200,200) -- blanco más suave

				if ESP_GENERAL then
					if dist <= 50 then
						glow.FillColor = rosadoPastel
						glow.OutlineColor = rosadoPastel
						glow.FillTransparency = 0.5
						glow.OutlineTransparency = 0
					else
						glow.FillColor = blancoGlow
						glow.OutlineColor = blancoGlow
						glow.FillTransparency = 0.4
						glow.OutlineTransparency = 0.1
					end
				else
					if dist <= 50 then
						glow.FillColor = rosadoPastel
						glow.OutlineColor = rosadoPastel
						glow.FillTransparency = 0.5
						glow.OutlineTransparency = 0
					else
						glow.FillColor = blancoGlow
						glow.OutlineColor = blancoGlow
						glow.FillTransparency = 0.4
						glow.OutlineTransparency = 0.1
					end
				end
			end
		end
	end
end)

-- ================= ESP RESPWAN / NUEVOS JUGADORES =================
local function setupESPListeners(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.4)
		applyESP(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	setupESPListeners(p)
	applyESP(p)
end

Players.PlayerAdded:Connect(function(player)
	setupESPListeners(player)
	applyESP(player)
end)

-- ================= TOGGLE GUI CON ANIMACION (R) =================
local TweenService = game:GetService("TweenService")
local visibleR = true

UIS.InputBegan:Connect(function(input, rpe)
	if rpe then return end
	if input.KeyCode == Enum.KeyCode.R then
		visibleR = not visibleR
		if visibleR then
			Main.Visible = true
			Main.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(
				Main,
				TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 220, 0, 180)}
			):Play()
		else
			local tween = TweenService:Create(
				Main,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Size = UDim2.new(0, 0, 0, 0)}
			)
			tween:Play()
			tween.Completed:Wait()
			Main.Visible = false
		end
	end
end)

-- ================= DRAGGING FUNC =================
local dragging = false
local dragInput, mousePos, framePos

local function updateDrag(input)
	local delta = input.Position - mousePos
	Main.Position = UDim2.new(
		framePos.X.Scale,
		framePos.X.Offset + delta.X,
		framePos.Y.Scale,
		framePos.Y.Offset + delta.Y
	)
end

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)
