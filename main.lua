if getgenv().XRAYOS_LOADED then return end
getgenv().XRAYOS_LOADED = true
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

local ESP_ENABLED = true
local MAX_DISTANCE = 500

local COLOR_BLUE_PASTEL = Color3.fromRGB(120, 180, 255)
local COLOR_RED_PASTEL  = Color3.fromRGB(255, 90, 90)

-- =========================
-- NOTIFICACIÓN
-- =========================
local notifyLock = false
local function notifyESP(state)
	if notifyLock then return end
	notifyLock = true
	StarterGui:SetCore("SendNotification", {
		Title = state and "X-RAYOS🟢" or "X-RAYOS🔴",
		Text = state and "Activado" or "Desactivado",
		Duration = 1.5
	})
	task.delay(0.2, function() notifyLock = false end)
end

-- =========================
-- HIGHLIGHT
-- =========================
local function applyHighlight(player)
	if player == LP then return end
	local function setup()
		if not ESP_ENABLED then return end
		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		for _,h in ipairs(char:GetChildren()) do
			if h:IsA("Highlight") then h:Destroy() end
		end

		local glow = Instance.new("Highlight")
		glow.FillTransparency = 0.85
		glow.OutlineTransparency = 0.3
		glow.Parent = char

		task.spawn(function()
			while ESP_ENABLED and glow.Parent do
				local studs = 0
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					studs = math.floor((LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
				end
				glow.FillColor = (studs < 50) and COLOR_RED_PASTEL or COLOR_BLUE_PASTEL
				glow.OutlineColor = glow.FillColor
				task.wait(0.1)
			end
			glow:Destroy()
		end)
	end
	player.CharacterAdded:Connect(function() task.wait(0.4) setup() end)
	if player.Character then task.wait(0.4) setup() end
end

-- =========================
-- ENABLE / DISABLE
-- =========================
local function clearESP()
	for _,p in ipairs(Players:GetPlayers()) do
		if p.Character then
			for _,d in ipairs(p.Character:GetDescendants()) do
				if d:IsA("Highlight") then d:Destroy() end
			end
		end
	end
end

local function enableAll()
	for _,p in ipairs(Players:GetPlayers()) do
		applyHighlight(p)
	end
end

-- =========================
-- TOGGLE (F)
-- =========================
UserInputService.InputBegan:Connect(function(key,gp)
	if gp then return end
	if key.KeyCode == Enum.KeyCode.F then
		ESP_ENABLED = not ESP_ENABLED
		notifyESP(ESP_ENABLED)
		if ESP_ENABLED then
			enableAll()
		else
			clearESP()
		end
	end
end)

-- INIT
for _,p in ipairs(Players:GetPlayers()) do
	applyHighlight(p)
end
Players.PlayerAdded:Connect(function(p)
	applyHighlight(p)
end)
