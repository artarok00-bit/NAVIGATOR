-- [[ НАВИГАТОР ПО ТОЧКАМ + КОНФИГИ (GitHub) ]]
-- Функции: постановка точек, полёт по порядку, зацикливание, задержка, конфиги

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- ===== НАСТРОЙКИ GITHUB =====
local GITHUB_TOKEN = ""  -- ВСТАВЬ СВОЙ ТОКЕН (если хочешь сохранять/удалять)
local GITHUB_USER = "artarok00-bit"
local GITHUB_REPO = "navigator-configs"
local GITHUB_BRANCH = "main"
local GITHUB_PATH = "configs"

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
local HasToken = GITHUB_TOKEN ~= ""

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Navigator"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- ===== ОСНОВНОЕ ОКНО =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
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
TitleText.Size = UDim2.new(0.5, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "НАВИГАТОР"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local PointsCount = Instance.new("TextLabel")
PointsCount.Size = UDim2.new(0.15, 0, 1, 0)
PointsCount.Position = UDim2.new(0.8, 0, 0, 0)
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
PointsTab.Size = UDim2.new(0.34, 0, 1, 0)
PointsTab.Position = UDim2.new(0, 0, 0, 0)
PointsTab.Text = "ТОЧКИ"
PointsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
PointsTab.TextSize = 13
PointsTab.BackgroundColor3 = Color3.fromRGB(123, 63, 252)
PointsTab.BorderSizePixel = 0
PointsTab.Font = Enum.Font.GothamSemibold
PointsTab.Parent = TabBar

local SettingsTab = Instance.new("TextButton")
SettingsTab.Size = UDim2.new(0.33, 0, 1, 0)
SettingsTab.Position = UDim2.new(0.34, 0, 0, 0)
SettingsTab.Text = "НАСТРОЙКИ"
SettingsTab.TextColor3 = Color3.fromRGB(180, 180, 210)
SettingsTab.TextSize = 13
SettingsTab.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
SettingsTab.BorderSizePixel = 0
SettingsTab.Font = Enum.Font.GothamSemibold
SettingsTab.Parent = TabBar

local ConfigTab = Instance.new("TextButton")
ConfigTab.Size = UDim2.new(0.33, 0, 1, 0)
ConfigTab.Position = UDim2.new(0.67, 0, 0, 0)
ConfigTab.Text = "КОНФИГИ"
ConfigTab.TextColor3 = Color3.fromRGB(180, 180, 210)
ConfigTab.TextSize = 13
ConfigTab.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
ConfigTab.BorderSizePixel = 0
ConfigTab.Font = Enum.Font.GothamSemibold
ConfigTab.Parent = TabBar

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
PlaceBtn.Size = UDim2.new(0.85, 0, 0, 42)
PlaceBtn.Position = UDim2.new(0.075, 0, 0.03, 0)
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
ClearBtn.Size = UDim2.new(0.4, 0, 0, 30)
ClearBtn.Position = UDim2.new(0.075, 0, 0.18, 0)
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
PointsList.Size = UDim2.new(0.4, 0, 0, 30)
PointsList.Position = UDim2.new(0.52, 0, 0.18, 0)
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
StartBtn.Size = UDim2.new(0.42, 0, 0, 40)
StartBtn.Position = UDim2.new(0.075, 0, 0.34, 0)
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
StopBtn.Size = UDim2.new(0.42, 0, 0, 40)
StopBtn.Position = UDim2.new(0.51, 0, 0.34, 0)
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
StatusText.Position = UDim2.new(0.05, 0, 0.65, 0)
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
SpeedInput.Size = UDim2.new(0.3, 0, 0, 30)
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
LoopBtn.Size = UDim2.new(0.3, 0, 0, 28)
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
DelayInput.Size = UDim2.new(0.3, 0, 0, 30)
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

-- ===== ВКЛАДКА "КОНФИГИ" =====
local ConfigPanel = Instance.new("Frame")
ConfigPanel.Size = UDim2.new(1, 0, 1, 0)
ConfigPanel.BackgroundTransparency = 1
ConfigPanel.Visible = false
ConfigPanel.Parent = Content

local ConfigNameInput = Instance.new("TextBox")
ConfigNameInput.Size = UDim2.new(0.5, 0, 0, 30)
ConfigNameInput.Position = UDim2.new(0.075, 0, 0.03, 0)
ConfigNameInput.Text = "мой маршрут"
ConfigNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigNameInput.TextSize = 14
ConfigNameInput.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
ConfigNameInput.BorderSizePixel = 0
ConfigNameInput.TextXAlignment = Enum.TextXAlignment.Center
ConfigNameInput.Font = Enum.Font.Gotham
ConfigNameInput.Parent = ConfigPanel
local NameCorner = Instance.new("UICorner")
NameCorner.CornerRadius = UDim.new(0, 6)
NameCorner.Parent = ConfigNameInput

local SaveConfigBtn = Instance.new("TextButton")
SaveConfigBtn.Size = UDim2.new(0.3, 0, 0, 30)
SaveConfigBtn.Position = UDim2.new(0.62, 0, 0.03, 0)
SaveConfigBtn.Text = HasToken and "💾 СОХРАНИТЬ" or "🔒 НЕТ ТОКЕНА"
SaveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConfigBtn.TextSize = 12
SaveConfigBtn.BackgroundColor3 = HasToken and Color3.fromRGB(123, 63, 252) or Color3.fromRGB(80, 80, 120)
SaveConfigBtn.BorderSizePixel = 0
SaveConfigBtn.Font = Enum.Font.GothamSemibold
SaveConfigBtn.Parent = ConfigPanel
local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 6)
SaveCorner.Parent = SaveConfigBtn

local ConfigList = Instance.new("ScrollingFrame")
ConfigList.Size = UDim2.new(0.85, 0, 0, 200)
ConfigList.Position = UDim2.new(0.075, 0, 0.15, 0)
ConfigList.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
ConfigList.BorderSizePixel = 0
ConfigList.ScrollBarThickness = 4
ConfigList.CanvasSize = UDim2.new(0, 0, 0, 0)
ConfigList.Parent = ConfigPanel
local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 6)
ConfigCorner.Parent = ConfigList

local ConfigStatus = Instance.new("TextLabel")
ConfigStatus.Size = UDim2.new(0.9, 0, 0, 20)
ConfigStatus.Position = UDim2.new(0.05, 0, 0.85, 0)
ConfigStatus.Text = "📁 Загрузка..."
ConfigStatus.TextColor3 = Color3.fromRGB(200, 200, 220)
ConfigStatus.TextSize = 12
ConfigStatus.TextXAlignment = Enum.TextXAlignment.Center
ConfigStatus.BackgroundTransparency = 1
ConfigStatus.Font = Enum.Font.Gotham
ConfigStatus.Parent = ConfigPanel

-- ===== ФУНКЦИИ GITHUB =====

local function GetConfigList()
    local url = "https://api.github.com/repos/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/contents/" .. GITHUB_PATH
    local headers = {}
    if HasToken then
        headers["Authorization"] = "Bearer " .. GITHUB_TOKEN
    end
    headers["Accept"] = "application/vnd.github.v3+json"
    
    local success, result = pcall(function()
        return HttpService:GetAsync(url, headers)
    end)
    
    if not success then return {} end
    
    local data = HttpService:JSONDecode(result)
    if type(data) ~= "table" then return {} end
    
    local configs = {}
    for _, item in ipairs(data) do
        if item.type == "file" and string.sub(item.name, -5) == ".json" then
            table.insert(configs, {
                name = string.sub(item.name, 1, -6),
                sha = item.sha,
                url = item.download_url
            })
        end
    end
    return configs
end

local function LoadConfigFromURL(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if not success then return nil end
    
    local data = HttpService:JSONDecode(result)
    return data
end

local function SaveConfigToGitHub(name)
    if not HasToken then
        ConfigStatus.Text = "❌ Нет токена для сохранения!"
        ConfigStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
        return false
    end
    
    local data = {
        name = name,
        points = Points,
        speed = Speed,
        loop = IsLoop,
        delay = LoopDelay
    }
    
    local json = HttpService:JSONEncode(data)
    local encoded = HttpService:Base64Encode(json)
    
    local url = "https://api.github.com/repos/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/contents/" .. GITHUB_PATH .. "/" .. name .. ".json"
    local headers = {
        ["Authorization"] = "Bearer " .. GITHUB_TOKEN,
        ["Accept"] = "application/vnd.github.v3+json"
    }
    
    local sha = nil
    local success, result = pcall(function()
        return HttpService:GetAsync(url, headers)
    end)
    
    if success then
        local data = HttpService:JSONDecode(result)
        if data and data.sha then
            sha = data.sha
        end
    end
    
    local body = {
        message = "Save config: " .. name,
        content = encoded,
        branch = GITHUB_BRANCH
    }
    if sha then
        body.sha = sha
    end
    
    local jsonBody = HttpService:JSONEncode(body)
    
    local success, result = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "PUT",
            Headers = {
                ["Authorization"] = "Bearer " .. GITHUB_TOKEN,
                ["Accept"] = "application/vnd.github.v3+json",
                ["Content-Type"] = "application/json"
            },
            Body = jsonBody
        })
    end)
    
    if success then
        ConfigStatus.Text = "✅ Конфиг сохранён!"
        ConfigStatus.TextColor3 = Color3.fromRGB(100, 200, 100)
        return true
    else
        ConfigStatus.Text = "❌ Ошибка сохранения!"
        ConfigStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
        return false
    end
end

local function DeleteConfigFromGitHub(name, sha)
    if not HasToken then
        ConfigStatus.Text = "❌ Нет токена для удаления!"
        ConfigStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
        return false
    end
    
    local url = "https://api.github.com/repos/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/contents/" .. GITHUB_PATH .. "/" .. name .. ".json"
    local body = {
        message = "Delete config: " .. name,
        sha = sha,
        branch = GITHUB_BRANCH
    }
    
    local jsonBody = HttpService:JSONEncode(body)
    
    local success, result = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "DELETE",
            Headers = {
                ["Authorization"] = "Bearer " .. GITHUB_TOKEN,
                ["Accept"] = "application/vnd.github.v3+json",
                ["Content-Type"] = "application/json"
            },
            Body = jsonBody
        })
    end)
    
    return success
end

local function RefreshConfigList()
    for _, child in pairs(ConfigList:GetChildren()) do child:Destroy() end
    
    ConfigStatus.Text = "📁 Загрузка..."
    ConfigStatus.TextColor3 = Color3.fromRGB(200, 200, 220)
    
    local configs = GetConfigList()
    
    if #configs == 0 then
        ConfigStatus.Text = "📁 Нет сохранённых конфигов"
        ConfigStatus.TextColor3 = Color3.fromRGB(200, 200, 220)
        return
    end
    
    ConfigList.CanvasSize = UDim2.new(0, 0, 0, #configs * 32 + 10)
    
    for i, config in ipairs(configs) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 28)
        row.Position = UDim2.new(0, 0, 0, (i-1) * 30 + 5)
        row.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
        row.BorderSizePixel = 0
        row.Parent = ConfigList
        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 4)
        rowCorner.Parent = row
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        nameLabel.Position = UDim2.new(0.04, 0, 0, 0)
        nameLabel.Text = "📁 " .. config.name
        nameLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = row
        
        local loadBtn = Instance.new("TextButton")
        loadBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
        loadBtn.Position = UDim2.new(0.6, 0, 0.1, 0)
        loadBtn.Text = "ЗАГР"
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.TextSize = 11
        loadBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 120)
        loadBtn.BorderSizePixel = 0
        loadBtn.Font = Enum.Font.GothamSemibold
        loadBtn.Parent = row
        local loadCorner = Instance.new("UICorner")
        loadCorner.CornerRadius = UDim.new(0, 4)
        loadCorner.Parent = loadBtn
        
        loadBtn.MouseButton1Click:Connect(function()
            local data = LoadConfigFromURL(config.url)
            if data then
                Points = data.points or {}
                Speed = data.speed or 50
                IsLoop = data.loop or false
                LoopDelay = data.delay or 1
                
                SpeedInput.Text = tostring(Speed)
                DelayInput.Text = tostring(LoopDelay)
                LoopBtn.Text = IsLoop and "ВКЛ" or "ВЫКЛ"
                LoopBtn.BackgroundColor3 = IsLoop and Color3.fromRGB(123, 63, 252) or Color3.fromRGB(60, 60, 100)
                
                UpdatePointsCount()
                ConfigStatus.Text = "✅ Загружено: " .. config.name
                ConfigStatus.TextColor3 = Color3.fromRGB(100, 200, 100)
            else
                ConfigStatus.Text = "❌ Ошибка загрузки!"
                ConfigStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
            end
        end)
        
        if HasToken then
            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
            delBtn.Position = UDim2.new(0.82, 0, 0.1, 0)
            delBtn.Text = "✕"
            delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtn.TextSize = 14
            delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
            delBtn.BorderSizePixel = 0
            delBtn.Font = Enum.Font.Gotham
            delBtn.Parent = row
            local delCorner = Instance.new("UICorner")
            delCorner.CornerRadius = UDim.new(0, 4)
            delCorner.Parent = delBtn
            
            delBtn.MouseButton1Click:Connect(function()
                local success = DeleteConfigFromGitHub(config.name, config.sha)
                if success then
                    ConfigStatus.Text = "🗑 Удалено: " .. config.name
                    ConfigStatus.TextColor3 = Color3.fromRGB(200, 200, 100)
                    RefreshConfigList()
                else
                    ConfigStatus.Text = "❌ Ошибка удаления!"
                    ConfigStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
                end
            end)
        end
    end
    
    ConfigStatus.Text = "📁 " .. #configs .. " конфигов"
    ConfigStatus.TextColor3 = Color3.fromRGB(200, 200, 220)
end

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
        StatusText.TextColor3 = Color3.from
