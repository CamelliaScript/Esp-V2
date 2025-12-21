if _G.__XRAY_ESP_RUNNING then return end
_G.__XRAY_ESP_RUNNING = true
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

local ESP_ENABLED = true
local MAX_DISTANCE = 500

local COLOR_BLUE_PASTEL = Color3.fromRGB(150, 200, 255)
local COLOR_RED_PASTEL  = Color3.fromRGB(255, 130, 130)

-- debounce SOLO para la tecla F
local toggleLock = false

do
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = LP:WaitForChild("PlayerGui")

    local mainText = Instance.new("TextLabel")
    mainText.Size = UDim2.new(1, 0, 0, 100)
    mainText.Position = UDim2.new(0, 0, -0.2, 0)
    mainText.BackgroundTransparency = 1
    mainText.Text = "Camellia"
    mainText.Font = Enum.Font.SourceSansBold
    mainText.TextSize = 60
    mainText.TextColor3 = COLOR_RED_PASTEL
    mainText.Parent = gui

    task.delay(2.5, function()
        gui:Destroy()
    end)
end

local function applyHighlight(player)
    if player == LP then return end

    local function setup()
        if not ESP_ENABLED then return end
        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Highlight") then
                v:Destroy()
            end
        end

        local hl = Instance.new("Highlight")
        hl.Name = "ESP_GLOW"
        hl.FillTransparency = 0.85
        hl.OutlineTransparency = 0.25
        hl.Parent = char

        task.spawn(function()
            while ESP_ENABLED and player.Parent and char.Parent and hrp.Parent do
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    local col = (dist < 50) and COLOR_RED_PASTEL or COLOR_BLUE_PASTEL
                    hl.FillColor = col
                    hl.OutlineColor = col
                end
                task.wait(0.1)
            end

            if hl then
                hl:Destroy()
            end
        end)
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.4)
        setup()
    end)

    if player.Character then
        task.wait(0.4)
        setup()
    end
end

local function clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, obj in ipairs(p.Character:GetChildren()) do
                if obj:IsA("Highlight") then
                    obj:Destroy()
                end
            end
        end
    end
end

local function enableAll()
    for _, p in ipairs(Players:GetPlayers()) do
        applyHighlight(p)
    end
end

UserInputService.InputBegan:Connect(function(key, gp)
	if gp then return end
	if key.KeyCode == Enum.KeyCode.F then
		ESP_ENABLED = not ESP_ENABLED

		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "X-RAYOS👀",
			Text = ESP_ENABLED and "Activado" or "Desactivado",
			Duration = 1.5
		})

		if ESP_ENABLED then
			task.spawn(enableAll)
		else
			clearESP()
		end
	end
end)


for _, p in ipairs(Players:GetPlayers()) do
    applyHighlight(p)
end

Players.PlayerAdded:Connect(function(p)
    applyHighlight(p)
end)
