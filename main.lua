-- [[ НАВИГАТОР ПО ТОЧКАМ (исправлен) ]]
-- Вкладки: Точки | Настройки
-- Функции: постановка точек, полёт по порядку, зацикливание, задержка

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ===== ДАННЫЕ =====
local Points = {}
local IsFlying = false
local IsLoop = false
local CurrentIndex = 1
local Speed = 50
local LoopDelay = 1
local Minimized = false
local BodyVelocity = nil
local BodyGyro = nil
local FlyConnection = nil
local CurrentTab = "Points"
local IsWaitingForLoop = false

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Navigator"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- ===== ОСНОВНОЕ ОКНО =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = MainFrame

-- ===== ШАПКА =====
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Color3.fromRGB(123, 63, 252)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "НАВИГАТОР"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local PointsCount = Instance.new("TextLabel")
PointsCount.Size = UDim2.new(0.2, 0, 1, 0)
PointsCount.Position = UDim2.new(0.78, 0, 0, 0)
PointsCount.Text = "0"
PointsCount.TextColor3 = Color3.fromRGB(100, 200, 255)
PointsCount.TextSize = 26
PointsCount.TextXAlignment = Enum.TextXAlignment.Right
PointsCount.BackgroundTransparency = 1
PointsCount.Font = Enum.Font.GothamBold
PointsCount.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.86, 0, 0.08, 0)
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.93, 0, 0.08, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ===== ВКЛАДКИ =====
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 38)
TabBar.Position = UDim2.new(0, 0, 0, 46)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local PointsTab = Instance.new("TextButton")
PointsTab.Size = UDim2.new(0.5, 0, 1, 0)
PointsTab.Position = UDim2.new(0, 0, 0, 0)
PointsTab.Text = "ТОЧКИ"
PointsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
PointsTab.TextSize = 14
PointsTab.BackgroundColor3 = Color3.fromRGB(123, 63, 252)
PointsTab.BorderSizePixel = 0
PointsTab.Font = Enum.Font.GothamSemibold
PointsTab.Parent = TabBar

local SettingsTab = Instance.new("TextButton")
SettingsTab.Size = UDim2.new(0.5, 0, 1, 0)
SettingsTab.Position = UDim2.new(0.5, 0, 0, 0)
SettingsTab.Text = "НАСТРОЙКИ"
SettingsTab.TextColor3 = Color3.fromRGB(180, 180, 210)
SettingsTab.TextSize = 14
SettingsTab.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
SettingsTab.BorderSizePixel = 0
SettingsTab.Font = Enum.Font.GothamSemibold
SettingsTab.Parent = TabBar

-- ===== КОНТЕНТ =====
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -84)
Content.Position = UDim2.new(0, 0, 0, 84)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- ===== ВКЛАДКА "ТОЧКИ" =====
local PointsPanel = Instance.new("Frame")
PointsPanel.Size = UDim2.new(1, 0, 1, 0)
PointsPanel.BackgroundTransparency = 1
PointsPanel.Parent = Content

local PlaceBtn = Instance.new("TextButton")
PlaceBtn.Size = UDim2.new(0.85, 0, 0, 44)
PlaceBtn.Position = UDim2.new(0.075, 0, 0.04, 0)
PlaceBtn.Text = "📌 ПОСТАВИТЬ ТОЧКУ"
PlaceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlaceBtn.TextSize = 15
PlaceBtn.BackgroundColor3 = Color3.fromRGB(123, 63, 252)
PlaceBtn.BorderSizePixel = 0
PlaceBtn.Font = Enum.Font.GothamSemibold
PlaceBtn.Parent = PointsPanel
local PlaceCorner = Instance.new("UICorner")
PlaceCorner.CornerRadius = UDim.new(0, 8)
PlaceCorner.Parent = PlaceBtn

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.4, 0, 0, 32)
ClearBtn.Position = UDim2.new(0.075, 0, 0.2, 0)
ClearBtn.Text = "🗑 ОЧИСТИТЬ"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.TextSize = 13
ClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
ClearBtn.BorderSizePixel = 0
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.Parent = PointsPanel
local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

local PointsList = Instance.new("ScrollingFrame")
PointsList.Size = UDim2.new(0.4, 0, 0, 32)
PointsList.Position = UDim2.new(0.52, 0, 0.2, 0)
PointsList.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
PointsList.BorderSizePixel = 0
PointsList.ScrollBarThickness = 3
PointsList.CanvasSize = UDim2.new(0, 0, 0, 0)
PointsList.Parent = PointsPanel
local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 6)
ListCorner.Parent = PointsList

local function UpdatePointsList()
    for _, child in pairs(PointsList:GetChildren()) do child:Destroy() end
    PointsList.CanvasSize = UDim2.new(0, 0, 0, #Points * 24)
    for i, pos in ipairs(Points) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, (i-1) * 22)
        label.Text = string.format("#%d: %.0f, %.0f, %.0f", i, pos.X, pos.Y, pos.Z)
        label.TextColor3 = Color3.fromRGB(200, 200, 235)
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.Parent = PointsList
    end
end

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.42, 0, 0, 42)
StartBtn.Position = UDim2.new(0.075, 0, 0.4, 0)
StartBtn.Text = "🚀 СТАРТ"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.TextSize = 15
StartBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 120)
StartBtn.BorderSizePixel = 0
StartBtn.Font = Enum.Font.GothamSemibold
StartBtn.Parent = PointsPanel
local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.42, 0, 0, 42)
StopBtn.Position = UDim2.new(0.51, 0, 0.4, 0)
StopBtn.Text = "⏹ СТОП"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.TextSize = 15
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
StopBtn.BorderSizePixel = 0
StopBtn.Font = Enum.Font.GothamSemibold
StopBtn.Parent = PointsPanel
local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopBtn

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0.9, 0, 0, 22)
StatusText.Position = UDim2.new(0.05, 0, 0.72, 0)
StatusText.Text = "🟢 Готов"
StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusText.TextSize = 13
StatusText.TextXAlignment = Enum.TextXAlignment.Center
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = PointsPanel

-- ===== ВКЛАДКА "НАСТРОЙКИ" =====
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(1, 0, 1, 0)
SettingsPanel.BackgroundTransparency = 1
SettingsPanel.Visible = false
SettingsPanel.Parent = Content

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.6, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.075, 0, 0.04, 0)
SpeedLabel.Text = "🚀 СКОРОСТЬ"
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
SpeedLabel.TextSize = 13
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = SettingsPanel

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.3, 0, 0, 32)
SpeedInput.Position = UDim2.new(0.65, 0, 0.02, 0)
SpeedInput.Text = "50"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 16
SpeedInput.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
SpeedInput.BorderSizePixel = 0
SpeedInput.TextXAlignment = Enum.TextXAlignment.Center
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.Parent = SettingsPanel
local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedInput

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then
        Speed = val
    else
        SpeedInput.Text = tostring(Speed)
    end
end)

local LoopLabel = Instance.new("TextLabel")
LoopLabel.Size = UDim2.new(0.6, 0, 0, 20)
LoopLabel.Position = UDim2.new(0.075, 0, 0.22, 0)
LoopLabel.Text = "🔁 ЗАЦИКЛИТЬ"
LoopLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
LoopLabel.TextSize = 13
LoopLabel.TextXAlignment = Enum.TextXAlignment.Left
LoopLabel.BackgroundTransparency = 1
LoopLabel.Font = Enum.Font.Gotham
LoopLabel.Parent = SettingsPanel

local LoopBtn = Instance.new("TextButton")
LoopBtn.Size = UDim2.new(0.3, 0, 0, 30)
LoopBtn.Position = UDim2.new(0.65, 0, 0.2, 0)
LoopBtn.Text = "ВЫКЛ"
LoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopBtn.TextSize = 13
LoopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
LoopBtn.BorderSizePixel = 0
LoopBtn.Font = Enum.Font.GothamSemibold
LoopBtn.Parent = SettingsPanel
local LoopCorner = Instance.new("UICorner")
LoopCorner.CornerRadius = UDim.new(0, 6)
LoopCorner.Parent = LoopBtn

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0.6, 0, 0, 20)
DelayLabel.Position = UDim2.new(0.075, 0, 0.42, 0)
DelayLabel.Text = "⏱ ЗАДЕРЖКА (сек)"
DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
DelayLabel.TextSize = 13
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.BackgroundTransparency = 1
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.Parent = SettingsPanel

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(0.3, 0, 0, 32)
DelayInput.Position = UDim2.new(0.65, 0, 0.4, 0)
DelayInput.Text = "1"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.TextSize = 16
DelayInput.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
DelayInput.BorderSizePixel = 0
DelayInput.TextXAlignment = Enum.TextXAlignment.Center
DelayInput.Font = Enum.Font.Gotham
DelayInput.Parent = SettingsPanel
local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0, 6)
DelayCorner.Parent = DelayInput

DelayInput.FocusLost:Connect(function()
    local val = tonumber(DelayInput.Text)
    if val and val > 0 then
        LoopDelay = val
    else
        DelayInput.Text = tostring(LoopDelay)
    end
end)

-- ===== ФУНКЦИИ =====

local function UpdatePointsCount()
    PointsCount.Text = tostring(#Points)
    UpdatePointsList()
end

local function PlacePoint()
    local Character = Player.Character
    if not Character then
        StatusText.Text = "❌ Персонаж не найден"
        StatusText.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then
        StatusText.Text = "❌ RootPart не найден"
        StatusText.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    table.insert(Points, Root.Position)
    UpdatePointsCount()
    StatusText.Text = "✅ Точка " .. #Points .. " поставлена"
    StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
end

local function ClearPoints()
    if IsFlying then StopFlight() end
    Points = {}
    CurrentIndex = 1
    UpdatePointsCount()
    StatusText.Text = "🗑 Точки очищены"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 100)
end

local function StopFlight()
    IsFlying = false
    IsWaitingForLoop = false
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.PlatformStand = false
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        end
    end
    StartBtn.Text = "🚀 СТАРТ"
    StartBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 120)
    if StatusText.Text ~= "✅ Маршрут пройден!" then
        StatusText.Text = "⏹ Остановлен"
        StatusText.TextColor3 = Color3.fromRGB(200, 200, 100)
    end
end

local function StartFlight()
    if #Points == 0 then
        StatusText.Text = "❌ Нет точек!"
        StatusText.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    if IsFlying then return end
    IsFlying = true
    IsWaitingForLoop = false
    CurrentIndex = 1

    local Character = Player.Character
    if not Character then
        IsFlying = false
        StatusText.Text = "❌ Персонаж не найден"
        StatusText.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Root or not Humanoid then
        IsFlying = false
        StatusText.Text = "❌ Ошибка персонажа"
        StatusText.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end

    StatusText.Text = "✈️ Летим к точке 1/" .. #Points
    StatusText.TextColor3 = Color3.fromRGB(100, 200, 255)
    StartBtn.Text = "ЛЕТИТ..."
    StartBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 100)

    Humanoid.PlatformStand = true
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    BodyVelocity.Parent = Root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    BodyGyro.Parent = Root

    if FlyConnection then FlyConnection:Disconnect() end

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not IsFlying then
            StopFlight()
            return
        end
        if not Character or not Root then
            StopFlight()
            return
        end

        -- Если ждём зацикливание — ничего не делаем
        if IsWaitingForLoop then
            return
        end

        local CurrentPos = Root.Position
        local Target = Points[CurrentIndex]
        local Dist = (Target - CurrentPos).Magnitude

        if Dist < 3 then
            CurrentIndex = CurrentIndex + 1
            if CurrentIndex > #Points then
                -- ДОСТИГЛИ ПОСЛЕДНЕЙ ТОЧКИ
                if IsLoop then
                    -- Зацикливание: ждём задержку, потом начинаем сначала
                    IsWaitingForLoop = true
                    StatusText.Text = "🔄 Зацикливание..." .. LoopDelay .. "с"
                    StatusText.TextColor3 = Color3.fromRGB(100, 200, 255)
                    
                    -- Останавливаем движение
                    if BodyVelocity then
                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    task.wait(LoopDelay)
                    
                    if not IsFlying then
                        IsWaitingForLoop = false
                        return
                    end
                    
                    -- Начинаем сначала
                    IsWaitingForLoop = false
                    CurrentIndex = 1
                    StatusText.Text = "✈️ Точка 1/" .. #Points
                    StatusText.TextColor3 = Color3.fromRGB(100, 200, 255)
                else
                    -- Останавливаемся
                    StatusText.Text = "✅ Маршрут пройден!"
                    StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
                    StopFlight()
                end
                return
            end
            StatusText.Text = "✈️ Точка " .. CurrentIndex .. "/" .. #Points
            return
        end

        local Dir = (Target - CurrentPos).Unit
        if BodyVelocity then
            BodyVelocity.Velocity = Dir * Speed
        end
        if BodyGyro then
            BodyGyro.CFrame = CFrame.lookAt(Root.Position, Root.Position + Dir)
        end
    end)
end

-- ===== ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК =====

PointsTab.MouseButton1Click:Connect(function()
    CurrentTab = "Points"
    PointsPanel.Visible = true
    SettingsPanel.Visible = false
    PointsTab.BackgroundColor3 = Color3.fromRGB(123, 63, 252)
    PointsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsTab.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    SettingsTab.TextColor3 = Color3.fromRGB(180, 180, 210)
end)

SettingsTab.MouseButton1Click:Connect(function()
    CurrentTab = "Settings"
    PointsPanel.Visible = false
    SettingsPanel.Visible = true
    SettingsTab.BackgroundColor3 = Color3.fromRGB(123, 63, 252)
    SettingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    PointsTab.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    PointsTab.TextColor3 = Color3.fromRGB(180, 180, 210)
end)

-- ===== КНОПКИ =====

PlaceBtn.MouseButton1Click:Connect(PlacePoint)
ClearBtn.MouseButton1Click:Connect(ClearPoints)

StartBtn.MouseButton1Click:Connect(function()
    if IsFlying then
        StopFlight()
    else
        StartFlight()
    end
end)

StopBtn.MouseButton1Click:Connect(StopFlight)

LoopBtn.MouseButton1Click:Connect(function()
    IsLoop = not IsLoop
    LoopBtn.Text = IsLoop and "ВКЛ" or "ВЫКЛ"
    LoopBtn.BackgroundColor3 = IsLoop and Color3.fromRGB(123, 63, 252) or Color3.fromRGB(60, 60, 100)
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    TabBar.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "─"
    MainFrame.Size = Minimized and UDim2.new(0, 340, 0, 46) or UDim2.new(0, 340, 0, 420)
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopFlight()
    ScreenGui:Destroy()
end)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.F then
        StartBtn.MouseButton1Click:Connect()
    end
    if Input.KeyCode == Enum.KeyCode.G then
        StopBtn.MouseButton1Click:Connect()
    end
    if Input.KeyCode == Enum.KeyCode.P then
        PlaceBtn.MouseButton1Click:Connect()
    end
end)

-- Восстановление при респавне
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if IsFlying then StopFlight() end
end)

-- ===== ИНИЦИАЛИЗАЦИЯ =====

UpdatePointsCount()
print("✅ НАВИГАТОР загружен! P — точка, F — Старт, G — Стоп")
