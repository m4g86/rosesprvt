-- ============== ROSESPRVT - GLASSMORPHISM + FULL LOGIC ==============
-- GUI glass style + semua logic beneran jalan

if _G.EvadeHubRunning then
    _G.EvadeHubRunning = false
    task.wait(0.5)
end
_G.EvadeHubRunning = true
_G.TPEnabled = false
_G.TPBodyOnly = false
_G.AvoidNextbot = false
_G.NoclipBarrierEnabled = false
_G.BarrierESPEnabled = false
_G.WallTPEnabled = false
_G.AutoReviveEnabled = false
_G.ShowTimer = false
_G.HideEndScreen = false

local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Events = game:GetService("ReplicatedStorage").Events
local remote = Events.Character.ToolAction
local reviveRemote = Events.Character.Interact

-- ===== KOORDINAT CAMP =====
local mapCoords = {
    ["Mayday"]    = CFrame.new(21.63, 387.03, 178.96),
    ["Poolrooms"] = CFrame.new(30.98, 118.25, -1731.19),
    ["Maze"] = CFrame.new(-136.25, -106.75, -92.77),
    ["Hanami"] = CFrame.new(949.10, -13.91, 1246.06),
    ["Vibrance"] = CFrame.new(-171.85, 29.74, 182.39),
    ["Garden"] = CFrame.new(-395.77, 359.31, -569.44),
    ["IndoorWaterPark"] = CFrame.new(636.69, 309.83, 697.04),
    ["Shire"] = CFrame.new(-19.58, 4.98, 1072.94),
    ["Library"] = CFrame.new(1905.89, 303.75, 79.92),
    ["DesertBus"] = CFrame.new(718.17, -80.17, -185.00),
    ["Alleyways"] = CFrame.new(-31.41, 4.95, 544.07),
    ["Sewers"] = CFrame.new(393.44, 115.82, -570.58),
    ["Bedroom"] = CFrame.new(-77.89, 172.42, -490.27),
    ["ScorchingOutpost"] = CFrame.new(-536.34, 92.94, 168.30),
    ["DrabSmall"] = CFrame.new(446.19, 246.38, -96.58),
}

-- ===== SETTINGS =====
local DELAY_MAP_BARU = 6
local DELAY_RESPAWN = 5
local VOTING_CHECK = 2
local BARRIER_FOLDERS = {"InvisParts", "InvisPartsPathAvoidance"}
local AVOID_RANGE = 15
local AVOID_SPEED = 1.2
local RAYCAST_DOWN = 10
local REVIVE_RANGE = 15

-- ===== SAVE/LOAD COORDS =====
local COORDS_FILE = "tp_coords.json"
local SAFE_COORDS_FILE = "safe_coords.json"

-- safe coords (posisi badan AFK, beda dari teleporter)
local safeCoords = {}

local function loadSavedCoords()
    pcall(function()
        if isfile and isfile(COORDS_FILE) then
            local data = HttpService:JSONDecode(readfile(COORDS_FILE))
            for name, pos in pairs(data) do
                mapCoords[name] = CFrame.new(pos.x, pos.y, pos.z)
            end
        end
    end)
    pcall(function()
        if isfile and isfile(SAFE_COORDS_FILE) then
            local data = HttpService:JSONDecode(readfile(SAFE_COORDS_FILE))
            for name, pos in pairs(data) do
                safeCoords[name] = CFrame.new(pos.x, pos.y, pos.z)
            end
        end
    end)
end
local function saveCoords()
    pcall(function()
        local data = {}
        for name, cf in pairs(mapCoords) do
            data[name] = {x = cf.X, y = cf.Y, z = cf.Z}
        end
        if writefile then writefile(COORDS_FILE, HttpService:JSONEncode(data)) end
    end)
end
local function saveSafeCoords()
    pcall(function()
        local data = {}
        for name, cf in pairs(safeCoords) do
            data[name] = {x = cf.X, y = cf.Y, z = cf.Z}
        end
        if writefile then writefile(SAFE_COORDS_FILE, HttpService:JSONEncode(data)) end
    end)
end
loadSavedCoords()

-- ===== GUI SETUP =====
local oldGui = player.PlayerGui:FindFirstChild("TestGlass")
if oldGui then oldGui:Destroy() end
pcall(function() game:GetService("CoreGui"):FindFirstChild("TestGlass"):Destroy() end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestGlass"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.IgnoreGuiInset = true

local parented = false
if gethui then pcall(function() screenGui.Parent = gethui(); parented = true end) end
if not parented then
    local ok = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not ok then screenGui.Parent = player.PlayerGui end
end

-- ===== MAIN FRAME (glass panel) =====
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 440, 0, 500)
main.Position = UDim2.new(0.5, -220, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
local mc = Instance.new("UICorner", main) mc.CornerRadius = UDim.new(0, 16)

-- glass border
local ms = Instance.new("UIStroke", main)
ms.Color = Color3.fromRGB(255, 255, 255)
ms.Transparency = 0.75
ms.Thickness = 1.5

-- gradient overlay
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 50, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 35)),
})
grad.Rotation = 135

-- ===== TITLE BAR =====
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 16, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "rosesprvt"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.Montserrat
titleText.TextSize = 16

local badge = Instance.new("TextLabel", titleBar)
badge.Size = UDim2.new(0, 36, 0, 18)
badge.Position = UDim2.new(0, 90, 0.5, -9)
badge.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
badge.BackgroundTransparency = 0.3
badge.Text = "v0.1"
badge.TextColor3 = Color3.fromRGB(200, 220, 255)
badge.Font = Enum.Font.Montserrat
badge.TextSize = 10
local bdc = Instance.new("UICorner", badge) bdc.CornerRadius = UDim.new(1, 0)

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 0.6
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
closeBtn.Font = Enum.Font.Montserrat
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = false
local cbc = Instance.new("UICorner", closeBtn) cbc.CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    _G.EvadeHubRunning = false
    screenGui:Destroy()
end)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -68, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundTransparency = 0.8
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(200, 210, 230)
minBtn.Font = Enum.Font.Montserrat
minBtn.TextSize = 16
minBtn.AutoButtonColor = false
local mbc = Instance.new("UICorner", minBtn) mbc.CornerRadius = UDim.new(1, 0)

-- ===== CONTENT SCROLL =====
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -24, 1, -52)
content.Position = UDim2.new(0, 12, 0, 44)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(100, 140, 255)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local cl = Instance.new("UIListLayout", content)
cl.Padding = UDim.new(0, 8)
cl.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== KEYBIND =====
local toggleKey = Enum.KeyCode.RightShift
local waitingForKey = false
local keybindCooldown = false

-- ===== UI HELPERS =====
local function makeGlassCard(parent, order, height)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, height or 50)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.88
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    local cc = Instance.new("UICorner", card) cc.CornerRadius = UDim.new(0, 12)
    local cs = Instance.new("UIStroke", card)
    cs.Color = Color3.fromRGB(255, 255, 255)
    cs.Transparency = 0.85
    cs.Thickness = 1
    return card
end

local function makeToggle(parent, order, label, sublabel, callback)
    local card = makeGlassCard(parent, order, sublabel and 58 or 46)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -70, 0, 16)
    lbl.Position = UDim2.new(0, 14, 0, sublabel and 10 or 15)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(240, 245, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Montserrat
    lbl.TextSize = 13
    if sublabel then
        local sub = Instance.new("TextLabel", card)
        sub.Size = UDim2.new(1, -70, 0, 12)
        sub.Position = UDim2.new(0, 14, 0, 30)
        sub.BackgroundTransparency = 1
        sub.Text = sublabel
        sub.TextColor3 = Color3.fromRGB(140, 160, 190)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Font = Enum.Font.Montserrat
        sub.TextSize = 10
    end

    -- switch
    local sw = Instance.new("TextButton", card)
    sw.Size = UDim2.new(0, 40, 0, 22)
    sw.Position = UDim2.new(1, -52, 0.5, -11)
    sw.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    sw.BackgroundTransparency = 0.3
    sw.Text = "" sw.AutoButtonColor = false
    local swc = Instance.new("UICorner", sw) swc.CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    local kc = Instance.new("UICorner", knob) kc.CornerRadius = UDim.new(1, 0)
    local kg = Instance.new("UIStroke", knob)
    kg.Color = Color3.fromRGB(100, 140, 255)
    kg.Thickness = 0
    kg.Transparency = 0.5

    local state = false
    local ti = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    sw.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(knob, ti, {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(60, 70, 90)}):Play()
        TweenService:Create(kg, TweenInfo.new(0.2), {Thickness = state and 2 or 0}):Play()
        lbl.TextColor3 = state and Color3.fromRGB(180, 210, 255) or Color3.fromRGB(240, 245, 255)
        if callback then callback(state) end
    end)
    return card
end

local function makeButton(parent, order, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 235, 255)
    btn.Font = Enum.Font.Montserrat
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    local bc = Instance.new("UICorner", btn) bc.CornerRadius = UDim.new(0, 20)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = Color3.fromRGB(120, 160, 255)
    bs.Transparency = 0.6
    bs.Thickness = 1
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
    end)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function makeSectionHeader(parent, order, text)
    local header = Instance.new("TextButton", parent)
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    header.BackgroundTransparency = 0.92
    header.Text = "" header.AutoButtonColor = false
    header.LayoutOrder = order
    local hc = Instance.new("UICorner", header) hc.CornerRadius = UDim.new(0, 12)
    local lbl = Instance.new("TextLabel", header)
    lbl.Size = UDim2.new(1, -32, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 200, 230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Montserrat
    lbl.TextSize = 12

    local arrow = Instance.new("TextLabel", header)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "⌄"
    arrow.TextColor3 = Color3.fromRGB(140, 160, 190)
    arrow.Font = Enum.Font.Montserrat
    arrow.TextSize = 14

    local body = Instance.new("Frame", parent)
    body.Size = UDim2.new(1, 0, 0, 0)
    body.BackgroundTransparency = 1
    body.LayoutOrder = order + 0.5
    body.Visible = false
    body.AutomaticSize = Enum.AutomaticSize.Y
    local bl = Instance.new("UIListLayout", body)
    bl.Padding = UDim.new(0, 6)
    bl.SortOrder = Enum.SortOrder.LayoutOrder

    local expanded = false
    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        body.Visible = expanded
        arrow.Text = expanded and "⌃" or "⌄"
        TweenService:Create(header, TweenInfo.new(0.15), {
            BackgroundTransparency = expanded and 0.85 or 0.92
        }):Play()
    end)
    return header, body
end

-- ===== STATUS BAR =====
local statusCard = makeGlassCard(content, 0, 36)
local spinner = Instance.new("ImageLabel", statusCard)
spinner.Size = UDim2.new(0, 16, 0, 16)
spinner.Position = UDim2.new(0, 12, 0.5, -8)
spinner.BackgroundTransparency = 1
spinner.Image = "rbxassetid://2459243309"
task.spawn(function()
    while screenGui.Parent do
        spinner.Rotation = (spinner.Rotation + 4) % 360
        task.wait(0.02)
    end
end)

local statusLbl = Instance.new("TextLabel", statusCard)
statusLbl.Size = UDim2.new(1, -40, 1, 0)
statusLbl.Position = UDim2.new(0, 34, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Ready"
statusLbl.TextColor3 = Color3.fromRGB(160, 200, 255)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Font = Enum.Font.Montserrat
statusLbl.TextSize = 12

local function setStatus(text)
    statusLbl.Text = text
end

-- ===== TAB SYSTEM =====
local tabs = {}
local activeTab = nil

local tabBar = Instance.new("Frame", content)
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.BackgroundTransparency = 1
tabBar.LayoutOrder = 1
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function switchTab(name)
    activeTab = name
    for n, data in pairs(tabs) do
        data.page.Visible = (n == name)
        local isActive = (n == name)
        TweenService:Create(data.btn, TweenInfo.new(0.15), {
            BackgroundTransparency = isActive and 0.4 or 0.85,
            BackgroundColor3 = isActive and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(255, 255, 255),
        }):Play()
        data.lbl.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 160, 190)
    end
end

local function addTab(name, order)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0, 74, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.85
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    local bc = Instance.new("UICorner", btn) bc.CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(140, 160, 190)
    lbl.Font = Enum.Font.Montserrat
    lbl.TextSize = 12

    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.LayoutOrder = 10 + order
    page.Visible = false
    page.AutomaticSize = Enum.AutomaticSize.Y
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 8)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    tabs[name] = {btn = btn, lbl = lbl, page = page}
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return page
end

-- Create tabs
local mainPage = addTab("Main", 1)
local survPage = addTab("Survival", 2)
local miscPage = addTab("Misc", 3)
local shopPage = addTab("Shop", 4)
local cfgPage = addTab("Config", 5)

-- ===== BARRIER ESP FUNCTIONS (defined early so toggles can call them) =====
local espHighlights = {}

local function clearESP()
    for _, hl in pairs(espHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espHighlights = {}
end

local function scanBarrierESP()
    clearESP()
    if not _G.BarrierESPEnabled then return end
    local g = workspace:FindFirstChild("Game")
    if not g then return end
    local m = g:FindFirstChild("Map")
    if not m then return end
    for _, fn in ipairs(BARRIER_FOLDERS) do
        local f = m:FindFirstChild(fn)
        if f then for _, v in pairs(f:GetDescendants()) do
            if v:IsA("BasePart") and not espHighlights[v] then
                local hl = Instance.new("BoxHandleAdornment")
                hl.Adornee = v
                hl.Size = v.Size
                hl.Color3 = Color3.fromRGB(255, 40, 60)
                hl.Transparency = 0.7
                hl.AlwaysOnTop = false
                hl.Parent = v
                espHighlights[v] = hl
            end
        end end
    end
end

-- ===== MAIN TAB - AUTO TP LOGIC =====
local gameFolder = workspace:FindFirstChild("Game") or workspace:WaitForChild("Game", 10)
local debounce = false
local lastPlaceTime = 0

-- ===== HELPER: WAIT UNTIL CHAR READY =====
local function waitUntilCharReady(char, timeout)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return false end
    local elapsed = 0
    while elapsed < timeout do
        if humanoid.Health > 0 
           and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
           and humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown then
            return true
        end
        task.wait(0.3) elapsed += 0.3
    end
    return false
end

-- ===== LOGIC: AUTO PLACE TP =====
local function placeTP(waitTime, manual)
    if not manual and not _G.TPEnabled then return end
    if debounce or (tick() - lastPlaceTime < 4) then return end
    debounce = true

    if manual then
        setStatus("Placing teleporter (manual)...")
    else
        setStatus("Round baru, nunggu map load...")
        if waitTime and waitTime > 0 then task.wait(waitTime) end
        if not _G.TPEnabled then debounce = false; return end
    end

    local pg = player.PlayerGui
    local function checkVoting()
        local v = pg:FindFirstChild("Global")
        if v then v = v:FindFirstChild("CanDisable") end
        if v then v = v:FindFirstChild("Vote") end
        return v and v:IsA("GuiObject") and v.Visible
    end
    if not manual then
        -- quick voting check (cuma 1x, ga loop)
        if checkVoting() then
            setStatus("Lagi voting, skip TP")
            debounce = false; return
        end
    end

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then debounce = false; return end

    if not manual then
        -- tunggu humanoid ready (max 2 detik aja)
        local humanoid = char:WaitForChild("Humanoid", 3)
        if humanoid then
            local elapsed = 0
            while elapsed < 2 do
                if humanoid.Health > 0 
                   and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
                   and humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown then
                    break
                end
                task.wait(0.2) elapsed += 0.2
            end
        end
    end

    local mapFolder = gameFolder:FindFirstChild("Map") or gameFolder:WaitForChild("Map", 5)
    if not mapFolder then debounce = false; return end
    local mapName = mapFolder:GetAttribute("MapName")
    if not mapName then
        for i = 1, 15 do
            mapName = mapFolder:GetAttribute("MapName")
            if mapName then break end
            task.wait(0.1)
        end
    end
    if not mapName then debounce = false; return end
    local campCF = mapCoords[mapName]
    if not campCF then
        setStatus("Map '" .. mapName .. "' belum ada koordinat")
        debounce = false; return
    end

    setStatus("Placing: " .. mapName)
    remote:FireServer(2) task.wait(0.5)
    remote:FireServer(0, 16) task.wait(1)
    remote:FireServer(1, {"Teleporter", campCF * CFrame.new(0, -2.7, 0)})

    setStatus("Placed! Map: " .. mapName)
    lastPlaceTime = tick()
    task.wait(1)
    debounce = false
end

-- ===== LOGIC: TP BADAN ONLY =====
local function tpBadan(waitTime, manual)
    if not manual and not _G.TPBodyOnly then return end
    if debounce or (tick() - lastPlaceTime < 4) then return end
    debounce = true

    if manual then
        setStatus("TP Badan (manual)...")
    else
        setStatus("Round baru, nunggu map (body only)...")
        if waitTime and waitTime > 0 then task.wait(waitTime) end
        if not _G.TPBodyOnly then debounce = false; return end
    end

    local pg = player.PlayerGui
    local function checkVoting()
        local v = pg:FindFirstChild("Global")
        if v then v = v:FindFirstChild("CanDisable") end
        if v then v = v:FindFirstChild("Vote") end
        return v and v:IsA("GuiObject") and v.Visible
    end
    if not manual then
        if checkVoting() then
            setStatus("Lagi voting, skip TP")
            debounce = false; return
        end
    end

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then debounce = false; return end

    if not manual then
        local humanoid = char:WaitForChild("Humanoid", 3)
        if humanoid then
            local elapsed = 0
            while elapsed < 2 do
                if humanoid.Health > 0 
                   and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
                   and humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown then
                    break
                end
                task.wait(0.2) elapsed += 0.2
            end
        end
    end

    local mapFolder = gameFolder:FindFirstChild("Map") or gameFolder:WaitForChild("Map", 5)
    if not mapFolder then debounce = false; return end
    local mapName = mapFolder:GetAttribute("MapName")
    if not mapName then debounce = false; return end
    -- pake safeCoords kalau ada, fallback ke mapCoords
    local safeCF = safeCoords[mapName] or mapCoords[mapName]
    if not safeCF then
        setStatus("Map '" .. mapName .. "' belum ada koordinat")
        debounce = false; return
    end

    setStatus("TP Badan: " .. mapName .. (safeCoords[mapName] and " (safe)" or " (camp)"))
    hrp.CFrame = safeCF
    task.wait(0.3)

    setStatus("Badan sampai! " .. mapName)
    lastPlaceTime = tick()
    task.wait(1)
    debounce = false
end

makeToggle(mainPage, 1, "Auto Place TP", "Place teleporter tiap ganti round", function(s)
    _G.TPEnabled = s
    setStatus(s and "Auto TP aktif" or "Auto TP off")
end)

makeButton(mainPage, 2, "Pasang Sekarang", function()
    task.spawn(placeTP, 0, true)
end)

makeToggle(mainPage, 3, "TP Badan Only", "TP badan ke camp tiap round (badan tetep solid)", function(s)
    _G.TPBodyOnly = s
    setStatus(s and "TP Badan ON" or "TP Badan OFF")
end)

makeButton(mainPage, 4, "TP Badan Sekarang", function()
    task.spawn(tpBadan, 0, true)
end)

-- ===== AFK MODE =====
_G.AFKModeEnabled = false

makeToggle(mainPage, 5, "AFK Mode", "TP badan ke safe + pasang teleporter otomatis", function(s)
    _G.AFKModeEnabled = s
    if s then
        -- matiin toggle lain biar ga bentrok
        _G.TPEnabled = false
        _G.TPBodyOnly = false
    end
    setStatus(s and "AFK Mode ON" or "AFK Mode OFF")
end)

-- ===== TP KE TEMEN =====
-- dropdown-style: bikin list player, klik = TP ke dia
local _, tpPlayerBody = makeSectionHeader(mainPage, 7, "TP ke Player")

local tpPlayerList = Instance.new("Frame", tpPlayerBody)
tpPlayerList.Size = UDim2.new(1, 0, 0, 0)
tpPlayerList.BackgroundTransparency = 1
tpPlayerList.AutomaticSize = Enum.AutomaticSize.Y
tpPlayerList.LayoutOrder = 1
local tpListLayout = Instance.new("UIListLayout", tpPlayerList)
tpListLayout.Padding = UDim.new(0, 4)
tpListLayout.SortOrder = Enum.SortOrder.Name

local function refreshPlayerList()
    -- clear old buttons
    for _, child in pairs(tpPlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    -- add players
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", tpPlayerList)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundTransparency = 0.88
            btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = Color3.fromRGB(220, 230, 255)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Montserrat
            btn.TextSize = 11
            btn.AutoButtonColor = false
            local bc = Instance.new("UICorner", btn)
            bc.CornerRadius = UDim.new(0, 8)

            btn.MouseEnter:Connect(function()
                btn.BackgroundTransparency = 0.7
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundTransparency = 0.88
            end)

            btn.MouseButton1Click:Connect(function()
                local myChar = player.Character
                local targetChar = p.Character
                if not myChar or not targetChar then
                    setStatus("Karakter ga ada!")
                    return
                end
                local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if myHRP and targetHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                    setStatus("TP ke " .. p.DisplayName)
                end
            end)
        end
    end
end

-- refresh button
makeButton(tpPlayerBody, 2, "Refresh List", function()
    refreshPlayerList()
    setStatus("Player list refreshed")
end)

-- auto refresh pas section dibuka
refreshPlayerList()

-- auto refresh tiap player join/leave
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    refreshPlayerList()
end)

-- ===== SURVIVAL TAB =====
makeToggle(survPage, 1, "Avoid Nextbot", "Auto dodge dari nextbot (tetep di lantai)", function(s)
    _G.AvoidNextbot = s
    setStatus(s and "Avoid ON" or "Avoid OFF")
end)

makeToggle(survPage, 2, "Auto Revive", "Revive player downed otomatis", function(s)
    _G.AutoReviveEnabled = s
    setStatus(s and "Auto Revive ON" or "Auto Revive OFF")
end)

-- ===== TIMER HUD (floating, draggable) =====
local timerHud = Instance.new("Frame", screenGui)
timerHud.Size = UDim2.new(0, 130, 0, 50)
timerHud.Position = UDim2.new(0.5, -65, 0, 16)
timerHud.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
timerHud.BackgroundTransparency = 0.2
timerHud.BorderSizePixel = 0
timerHud.Visible = false
timerHud.Active = true
timerHud.Draggable = true
local thc = Instance.new("UICorner", timerHud) thc.CornerRadius = UDim.new(0, 12)
local ths = Instance.new("UIStroke", timerHud)
ths.Color = Color3.fromRGB(100, 140, 255)
ths.Transparency = 0.5
ths.Thickness = 1.5

local timerTitle = Instance.new("TextLabel", timerHud)
timerTitle.Size = UDim2.new(1, 0, 0, 14)
timerTitle.Position = UDim2.new(0, 0, 0, 4)
timerTitle.BackgroundTransparency = 1
timerTitle.Text = "ROUND TIMER"
timerTitle.TextColor3 = Color3.fromRGB(100, 140, 255)
timerTitle.Font = Enum.Font.Montserrat
timerTitle.TextSize = 9

local timerValue = Instance.new("TextLabel", timerHud)
timerValue.Size = UDim2.new(1, 0, 0, 28)
timerValue.Position = UDim2.new(0, 0, 0, 18)
timerValue.BackgroundTransparency = 1
timerValue.Text = "--:--"
timerValue.TextColor3 = Color3.fromRGB(255, 255, 255)
timerValue.Font = Enum.Font.Montserrat
timerValue.TextSize = 22

-- ===== MISC TAB =====
makeToggle(miscPage, 1, "Noclip Barrier", "Tembus invisible walls", function(s)
    _G.NoclipBarrierEnabled = s
    setStatus(s and "Noclip ON" or "Noclip OFF")
    if not s then
        -- restore barriers
        local g = workspace:FindFirstChild("Game")
        if g then local m = g:FindFirstChild("Map")
            if m then for _, fn in ipairs(BARRIER_FOLDERS) do
                local f = m:FindFirstChild(fn)
                if f then for _, v in pairs(f:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end end
            end end
        end
    end
end)

makeToggle(miscPage, 2, "Barrier ESP", "Highlight barrier merah", function(s)
    _G.BarrierESPEnabled = s
    setStatus(s and "Barrier ESP ON" or "Barrier ESP OFF")
    if s then
        scanBarrierESP()
    else
        clearESP()
    end
end)

makeToggle(miscPage, 3, "Wall TP (Xray)", "Transparanin tembok (badan tetep solid)", function(s)
    _G.WallTPEnabled = s
    setStatus(s and "Xray ON" or "Xray OFF")
end)

makeToggle(miscPage, 4, "Round Timer", "Tampilin sisa waktu round di layar", function(s)
    _G.ShowTimer = s
    setStatus(s and "Timer ON" or "Timer OFF")
    if timerHud then timerHud.Visible = s end
end)

makeToggle(miscPage, 5, "Hide End Screen", "Ilangin UI survived/died pas round selesai", function(s)
    _G.HideEndScreen = s
    setStatus(s and "Hide End Screen ON" or "Hide End Screen OFF")
    -- kalau dimatiin, restore UI yang lagi di-hide
    if not s then
        local pg = player.PlayerGui
        local shared = pg:FindFirstChild("Shared")
        if shared then
            local hud = shared:FindFirstChild("HUD")
            if hud then
                local interactors = hud:FindFirstChild("Interactors")
                if interactors then
                    local popups = interactors:FindFirstChild("Popups")
                    if popups then
                        local results = popups:FindFirstChild("Results")
                        if results and results:IsA("GuiObject") then
                            results.Visible = true
                        end
                    end
                end
            end
        end
        local global = pg:FindFirstChild("Global")
        if global then
            local rewards = global:FindFirstChild("Rewards")
            if rewards and rewards:IsA("GuiObject") then
                rewards.Visible = true
            end
        end
    end
end)

-- ===== SHOP TAB =====
local shopCategories = {
    Deployable = {
        {name = "Teleporter", id = 148},
        -- tambahin item deployable lain
    },
    Power = {
        -- tambahin power items nanti (spy ID-nya)
        -- {name = "Speed Boost", id = ???},
    },
}

local purchaseRemote = nil
pcall(function()
    purchaseRemote = game:GetService("ReplicatedStorage").Events.Data.Purchase
end)

-- state
local selectedDeployable = "Teleporter"
local selectedPower = nil
local autoBuyEnabled = false
local autoBuyItem = nil

-- Side panel
local shopPanel = Instance.new("Frame", screenGui)
shopPanel.Size = UDim2.new(0, 200, 0, 400)
shopPanel.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
shopPanel.BackgroundTransparency = 0.15
shopPanel.BorderSizePixel = 0
shopPanel.Visible = false
local spc = Instance.new("UICorner", shopPanel) spc.CornerRadius = UDim.new(0, 12)
local sps = Instance.new("UIStroke", shopPanel)
sps.Color = Color3.fromRGB(255, 255, 255)
sps.Transparency = 0.75
sps.Thickness = 1.5

-- panel follows main
task.spawn(function()
    while _G.EvadeHubRunning and screenGui.Parent do
        if shopPanel.Visible then
            shopPanel.Position = UDim2.new(
                0, main.AbsolutePosition.X + main.AbsoluteSize.X + 8,
                0, main.AbsolutePosition.Y
            )
            shopPanel.Size = UDim2.new(0, 200, 0, main.AbsoluteSize.Y)
        end
        task.wait(0.05)
    end
end)

-- panel title
local shopPanelTitle = Instance.new("TextLabel", shopPanel)
shopPanelTitle.Size = UDim2.new(1, 0, 0, 36)
shopPanelTitle.BackgroundTransparency = 1
shopPanelTitle.Text = "  Select"
shopPanelTitle.TextColor3 = Color3.fromRGB(180, 200, 230)
shopPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
shopPanelTitle.Font = Enum.Font.Montserrat
shopPanelTitle.TextSize = 14

local shopDivider = Instance.new("Frame", shopPanel)
shopDivider.Size = UDim2.new(1, -16, 0, 1)
shopDivider.Position = UDim2.new(0, 8, 0, 36)
shopDivider.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
shopDivider.BackgroundTransparency = 0.5
shopDivider.BorderSizePixel = 0

-- panel list
local shopList = Instance.new("ScrollingFrame", shopPanel)
shopList.Size = UDim2.new(1, -16, 1, -48)
shopList.Position = UDim2.new(0, 8, 0, 42)
shopList.BackgroundTransparency = 1
shopList.BorderSizePixel = 0
shopList.ScrollBarThickness = 3
shopList.ScrollBarImageColor3 = Color3.fromRGB(100, 140, 255)
shopList.CanvasSize = UDim2.new(0, 0, 0, 0)
shopList.AutomaticCanvasSize = Enum.AutomaticSize.Y
local sll = Instance.new("UIListLayout", shopList)
sll.Padding = UDim.new(0, 4)
sll.SortOrder = Enum.SortOrder.LayoutOrder

local currentPanelCategory = nil

local function openPanel(category, valueLabel)
    -- clear list
    for _, child in pairs(shopList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local items = shopCategories[category]
    if not items or #items == 0 then
        shopPanel.Visible = false
        return
    end

    shopPanelTitle.Text = "  " .. category
    currentPanelCategory = category

    for i, item in ipairs(items) do
        local row = Instance.new("TextButton", shopList)
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.9
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = i
        local rc = Instance.new("UICorner", row) rc.CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -12, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = item.name
        lbl.TextColor3 = Color3.fromRGB(220, 230, 255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Montserrat
        lbl.TextSize = 12

        row.MouseEnter:Connect(function() row.BackgroundTransparency = 0.75 end)
        row.MouseLeave:Connect(function() row.BackgroundTransparency = 0.9 end)

        row.MouseButton1Click:Connect(function()
            if category == "Deployable" then
                selectedDeployable = item.name
                autoBuyItem = item
            elseif category == "Power" then
                selectedPower = item.name
                autoBuyItem = item
            end
            valueLabel.Text = item.name
            shopPanel.Visible = false
            setStatus("Selected: " .. item.name)
        end)
    end

    shopPanel.Visible = true
end

-- === Shop page rows ===

-- Row: Deployable (klik = open panel)
local deployCard = makeGlassCard(shopPage, 1, 46)
local deployLbl = Instance.new("TextLabel", deployCard)
deployLbl.Size = UDim2.new(0.5, 0, 1, 0)
deployLbl.Position = UDim2.new(0, 14, 0, 0)
deployLbl.BackgroundTransparency = 1
deployLbl.Text = "Deployable"
deployLbl.TextColor3 = Color3.fromRGB(220, 230, 255)
deployLbl.TextXAlignment = Enum.TextXAlignment.Left
deployLbl.Font = Enum.Font.Montserrat
deployLbl.TextSize = 13

local deployVal = Instance.new("TextButton", deployCard)
deployVal.Size = UDim2.new(0, 110, 0, 28)
deployVal.Position = UDim2.new(1, -122, 0.5, -14)
deployVal.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
deployVal.Text = selectedDeployable or "Select"
deployVal.TextColor3 = Color3.fromRGB(160, 180, 210)
deployVal.Font = Enum.Font.Montserrat
deployVal.TextSize = 11
deployVal.AutoButtonColor = false
local dvc = Instance.new("UICorner", deployVal) dvc.CornerRadius = UDim.new(0, 6)

local deployArrow = Instance.new("TextLabel", deployVal)
deployArrow.Size = UDim2.new(0, 16, 1, 0)
deployArrow.Position = UDim2.new(1, -16, 0, 0)
deployArrow.BackgroundTransparency = 1
deployArrow.Text = "⌄"
deployArrow.TextColor3 = Color3.fromRGB(100, 120, 150)
deployArrow.Font = Enum.Font.Montserrat
deployArrow.TextSize = 12

deployVal.MouseButton1Click:Connect(function()
    if shopPanel.Visible and currentPanelCategory == "Deployable" then
        shopPanel.Visible = false
    else
        openPanel("Deployable", deployVal)
    end
end)

-- Row: Power (klik = open panel)
local powerCard = makeGlassCard(shopPage, 2, 46)
local powerLbl = Instance.new("TextLabel", powerCard)
powerLbl.Size = UDim2.new(0.5, 0, 1, 0)
powerLbl.Position = UDim2.new(0, 14, 0, 0)
powerLbl.BackgroundTransparency = 1
powerLbl.Text = "Power"
powerLbl.TextColor3 = Color3.fromRGB(220, 230, 255)
powerLbl.TextXAlignment = Enum.TextXAlignment.Left
powerLbl.Font = Enum.Font.Montserrat
powerLbl.TextSize = 13

local powerVal = Instance.new("TextButton", powerCard)
powerVal.Size = UDim2.new(0, 110, 0, 28)
powerVal.Position = UDim2.new(1, -122, 0.5, -14)
powerVal.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
powerVal.Text = "Select"
powerVal.TextColor3 = Color3.fromRGB(160, 180, 210)
powerVal.Font = Enum.Font.Montserrat
powerVal.TextSize = 11
powerVal.AutoButtonColor = false
local pvc = Instance.new("UICorner", powerVal) pvc.CornerRadius = UDim.new(0, 6)

local powerArrow = Instance.new("TextLabel", powerVal)
powerArrow.Size = UDim2.new(0, 16, 1, 0)
powerArrow.Position = UDim2.new(1, -16, 0, 0)
powerArrow.BackgroundTransparency = 1
powerArrow.Text = "⌄"
powerArrow.TextColor3 = Color3.fromRGB(100, 120, 150)
powerArrow.Font = Enum.Font.Montserrat
powerArrow.TextSize = 12

powerVal.MouseButton1Click:Connect(function()
    if shopPanel.Visible and currentPanelCategory == "Power" then
        shopPanel.Visible = false
    else
        openPanel("Power", powerVal)
    end
end)

-- Row: Auto Buy toggle (spam buy selected item)
makeToggle(shopPage, 3, "Auto Buy", "Spam buy item yang dipilih", function(s)
    autoBuyEnabled = s
    setStatus(s and "Auto Buy ON" or "Auto Buy OFF")
end)

-- Auto buy loop
task.spawn(function()
    while _G.EvadeHubRunning do
        if autoBuyEnabled and autoBuyItem and purchaseRemote then
            pcall(function()
                purchaseRemote:InvokeServer(autoBuyItem.id)
            end)
        end
        task.wait(0.5)
    end
end)

-- hide panel pas pindah tab
local oldSwitchTab = switchTab
switchTab = function(name)
    oldSwitchTab(name)
    if name ~= "Shop" then
        shopPanel.Visible = false
    end
end

-- ===== CONFIG TAB =====
local _, cfgPosBody = makeSectionHeader(cfgPage, 1, "Posisi Config")

makeButton(cfgPosBody, 1, "Set Posisi Teleporter (map ini)", function()
    local char = player.Character
    if not char then setStatus("Karakter belum spawn"); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local mapFolder = gameFolder:FindFirstChild("Map")
    if not mapFolder then setStatus("Map folder ga ada"); return end
    local mapName = mapFolder:GetAttribute("MapName")
    if not mapName then setStatus("MapName ga ke-detect"); return end
    mapCoords[mapName] = hrp.CFrame
    saveCoords()
    setStatus("TP pos updated: " .. mapName .. " (" .. math.floor(hrp.CFrame.X) .. ", " .. math.floor(hrp.CFrame.Y) .. ", " .. math.floor(hrp.CFrame.Z) .. ")")
end)

makeButton(cfgPosBody, 2, "Set Posisi Safe/AFK (map ini)", function()
    local char = player.Character
    if not char then setStatus("Karakter belum spawn"); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local mapFolder = gameFolder:FindFirstChild("Map")
    if not mapFolder then setStatus("Map folder ga ada"); return end
    local mapName = mapFolder:GetAttribute("MapName")
    if not mapName then setStatus("MapName ga ke-detect"); return end
    safeCoords[mapName] = hrp.CFrame
    saveSafeCoords()
    setStatus("Safe pos updated: " .. mapName .. " (" .. math.floor(hrp.CFrame.X) .. ", " .. math.floor(hrp.CFrame.Y) .. ", " .. math.floor(hrp.CFrame.Z) .. ")")
end)

-- Section: FOV
local _, cfgFovBody = makeSectionHeader(cfgPage, 2, "Field of View")

local fovCard = makeGlassCard(cfgFovBody, 1, 70)

local fovLbl = Instance.new("TextLabel", fovCard)
fovLbl.Size = UDim2.new(0.5, 0, 0, 20)
fovLbl.Position = UDim2.new(0, 14, 0, 8)
fovLbl.BackgroundTransparency = 1
fovLbl.Text = "FOV"
fovLbl.TextColor3 = Color3.fromRGB(160, 175, 195)
fovLbl.TextXAlignment = Enum.TextXAlignment.Left
fovLbl.Font = Enum.Font.Montserrat
fovLbl.TextSize = 13

local fovValLbl = Instance.new("TextLabel", fovCard)
fovValLbl.Size = UDim2.new(0.5, -14, 0, 20)
fovValLbl.Position = UDim2.new(0.5, 0, 0, 8)
fovValLbl.BackgroundTransparency = 1
fovValLbl.Text = "90"
fovValLbl.TextColor3 = Color3.fromRGB(200, 210, 225)
fovValLbl.TextXAlignment = Enum.TextXAlignment.Right
fovValLbl.Font = Enum.Font.Code
fovValLbl.TextSize = 13

-- slider track
local fovTrack = Instance.new("Frame", fovCard)
fovTrack.Size = UDim2.new(1, -28, 0, 6)
fovTrack.Position = UDim2.new(0, 14, 0, 42)
fovTrack.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
fovTrack.BorderSizePixel = 0
local ftc = Instance.new("UICorner", fovTrack) ftc.CornerRadius = UDim.new(1, 0)

-- slider fill
local fovFill = Instance.new("Frame", fovTrack)
fovFill.Size = UDim2.new((90 - 30) / (120 - 30), 0, 1, 0)
fovFill.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
fovFill.BorderSizePixel = 0
local ffc = Instance.new("UICorner", fovFill) ffc.CornerRadius = UDim.new(1, 0)

-- slider knob
local fovKnob = Instance.new("Frame", fovTrack)
fovKnob.Size = UDim2.new(0, 16, 0, 16)
fovKnob.Position = UDim2.new((90 - 30) / (120 - 30), -8, 0.5, -8)
fovKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovKnob.BorderSizePixel = 0
fovKnob.ZIndex = 5
local fkc = Instance.new("UICorner", fovKnob) fkc.CornerRadius = UDim.new(1, 0)

-- slider interaction
local fovDragging = false
local FOV_MIN = 30
local FOV_MAX = 120
local currentFOV = 90

local function updateFovSlider(ratio)
    ratio = math.clamp(ratio, 0, 1)
    currentFOV = math.floor(FOV_MIN + (FOV_MAX - FOV_MIN) * ratio)
    fovFill.Size = UDim2.new(ratio, 0, 1, 0)
    fovKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
    fovValLbl.Text = tostring(currentFOV)
    -- set FOV lewat Fear attribute (Fear = FOV / 90)
    pcall(function()
        local fovAdj = player.PlayerScripts:FindFirstChild("Camera")
        if fovAdj then
            fovAdj = fovAdj:FindFirstChild("FOVAdjusters")
            if fovAdj then
                fovAdj:SetAttribute("Fear", currentFOV / 90)
            end
        end
    end)
end

-- pake TextButton biar bisa intercept input tanpa bubble ke parent drag
local fovHitbox = Instance.new("TextButton", fovCard)
fovHitbox.Size = UDim2.new(1, -20, 0, 26)
fovHitbox.Position = UDim2.new(0, 10, 0, 35)
fovHitbox.BackgroundTransparency = 1
fovHitbox.Text = ""
fovHitbox.AutoButtonColor = false
fovHitbox.ZIndex = 6

fovHitbox.MouseButton1Down:Connect(function(x, y)
    fovDragging = true
    -- disable main drag
    main.Draggable = false
    local ratio = math.clamp((x - fovTrack.AbsolutePosition.X) / fovTrack.AbsoluteSize.X, 0, 1)
    updateFovSlider(ratio)
end)

UIS.InputChanged:Connect(function(input)
    if fovDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local ratio = math.clamp((input.Position.X - fovTrack.AbsolutePosition.X) / fovTrack.AbsoluteSize.X, 0, 1)
        updateFovSlider(ratio)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if fovDragging then
            fovDragging = false
            main.Draggable = true
        end
    end
end)

-- keep FOV persistent lewat Fear attribute
RunService:BindToRenderStep("EvadeHubFOV", Enum.RenderPriority.Camera.Value + 1, function()
    if not _G.EvadeHubRunning then return end
    if currentFOV and currentFOV >= FOV_MIN and currentFOV <= FOV_MAX then
        pcall(function()
            local fovAdj = player.PlayerScripts:FindFirstChild("Camera")
            if fovAdj then
                fovAdj = fovAdj:FindFirstChild("FOVAdjusters")
                if fovAdj then
                    local target = currentFOV / 90
                    if fovAdj:GetAttribute("Fear") ~= target then
                        fovAdj:SetAttribute("Fear", target)
                    end
                end
            end
        end)
    end
end)

-- cleanup pas hub ditutup
screenGui.Destroying:Connect(function()
    pcall(function() RunService:UnbindFromRenderStep("EvadeHubFOV") end)
    -- restore Fear ke default
    pcall(function()
        local fovAdj = player.PlayerScripts.Camera.FOVAdjusters
        fovAdj:SetAttribute("Fear", 1)
    end)
end)

-- Section: Auto Command (PS)
local _, cfgCmdBody = makeSectionHeader(cfgPage, 2.5, "Auto Command (PS)")

_G.AutoCommandEnabled = false
_G.AutoCommandText = "!specialround Plushie Hell"

-- Toggle
makeToggle(cfgCmdBody, 1, "Auto Command", "Fire command tiap ganti map/round", function(s)
    _G.AutoCommandEnabled = s
    setStatus(s and "Auto Cmd ON" or "Auto Cmd OFF")
end)

-- Input command
local cmdCard = makeGlassCard(cfgCmdBody, 2, 46)
local cmdLbl = Instance.new("TextLabel", cmdCard)
cmdLbl.Size = UDim2.new(0, 70, 1, 0)
cmdLbl.Position = UDim2.new(0, 14, 0, 0)
cmdLbl.BackgroundTransparency = 1
cmdLbl.Text = "Command"
cmdLbl.TextColor3 = Color3.fromRGB(160, 175, 195)
cmdLbl.TextXAlignment = Enum.TextXAlignment.Left
cmdLbl.Font = Enum.Font.Montserrat
cmdLbl.TextSize = 12

local cmdInput = Instance.new("TextBox", cmdCard)
cmdInput.Size = UDim2.new(1, -100, 0, 28)
cmdInput.Position = UDim2.new(0, 88, 0.5, -14)
cmdInput.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
cmdInput.BorderSizePixel = 0
cmdInput.Text = _G.AutoCommandText
cmdInput.TextColor3 = Color3.fromRGB(200, 210, 225)
cmdInput.PlaceholderText = "!command here"
cmdInput.Font = Enum.Font.Code
cmdInput.TextSize = 11
cmdInput.ClearTextOnFocus = false
local cic = Instance.new("UICorner", cmdInput) cic.CornerRadius = UDim.new(0, 6)
local cip = Instance.new("UIPadding", cmdInput) cip.PaddingLeft = UDim.new(0, 6) cip.PaddingRight = UDim.new(0, 6)

cmdInput.FocusLost:Connect(function()
    _G.AutoCommandText = cmdInput.Text
    setStatus("Command set: " .. cmdInput.Text)
end)

-- Fire now button
makeButton(cfgCmdBody, 3, "Fire Command Now", function()
    local vipCmd = game:GetService("ReplicatedStorage").Events.Admin:FindFirstChild("VIPCommandEvent")
    if vipCmd then
        local ok = pcall(function()
            vipCmd:InvokeServer(_G.AutoCommandText)
        end)
        setStatus(ok and "Fired: " .. _G.AutoCommandText or "Failed!")
    else
        setStatus("VIPCommandEvent not found!")
    end
end)

-- Section: Keybind
local _, cfgKbBody = makeSectionHeader(cfgPage, 3, "Keybind")

-- ===== KEYBIND SYSTEM =====
local keybinds = {
    {name = "Toggle UI", key = Enum.KeyCode.RightShift, action = function() main.Visible = not main.Visible end},
    {name = "Noclip Barrier", key = nil, action = function()
        _G.NoclipBarrierEnabled = not _G.NoclipBarrierEnabled
        setStatus(_G.NoclipBarrierEnabled and "Noclip ON" or "Noclip OFF")
    end},
    {name = "Xray Walls", key = nil, action = function()
        _G.WallTPEnabled = not _G.WallTPEnabled
        setStatus(_G.WallTPEnabled and "Xray ON" or "Xray OFF")
    end},
    {name = "Barrier ESP", key = nil, action = function()
        _G.BarrierESPEnabled = not _G.BarrierESPEnabled
        setStatus(_G.BarrierESPEnabled and "ESP ON" or "ESP OFF")
        if _G.BarrierESPEnabled then scanBarrierESP() else clearESP() end
    end},
}

local kbButtons = {} -- simpan reference button buat update text

for i, kb in ipairs(keybinds) do
    local card = makeGlassCard(cfgKbBody, i, 46)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = kb.name
    lbl.TextColor3 = Color3.fromRGB(160, 175, 195)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Montserrat
    lbl.TextSize = 13

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 70, 0, 28)
    btn.Position = UDim2.new(1, -82, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    btn.Text = kb.key and kb.key.Name or "---"
    btn.TextColor3 = Color3.fromRGB(200, 210, 225)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.AutoButtonColor = false
    local bc = Instance.new("UICorner", btn) bc.CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", btn) bs.Color = Color3.fromRGB(80, 90, 110) bs.Thickness = 1

    kbButtons[i] = btn

    btn.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        btn.Text = "..."
        btn.TextColor3 = Color3.fromRGB(100, 140, 255)
        local conn
        conn = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Unknown then return end
                -- Backspace/Delete = clear keybind
                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                    kb.key = nil
                    btn.Text = "---"
                else
                    kb.key = input.KeyCode
                    btn.Text = input.KeyCode.Name
                end
                btn.TextColor3 = Color3.fromRGB(200, 210, 225)
                waitingForKey = false
                keybindCooldown = true
                conn:Disconnect()
                setStatus("Keybind " .. kb.name .. ": " .. btn.Text)
                task.delay(1, function() keybindCooldown = false end)
            end
        end)
    end)
end

-- Default tab
switchTab("Main")

-- ===== KEYBIND INPUT HANDLER =====
UIS.InputBegan:Connect(function(input, gp)
    if waitingForKey then return end
    if keybindCooldown then return end
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    for _, kb in ipairs(keybinds) do
        if kb.key and input.KeyCode == kb.key then
            kb.action()
            break
        end
    end
end)

-- ===== MINIMIZE ICON =====
local miniIcon = Instance.new("TextButton", screenGui)
miniIcon.Size = UDim2.new(0, 42, 0, 42)
miniIcon.Position = UDim2.new(0, 10, 0.5, -21)
miniIcon.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
miniIcon.BackgroundTransparency = 0.3
miniIcon.Text = "◈"
miniIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
miniIcon.Font = Enum.Font.Montserrat
miniIcon.TextSize = 20
miniIcon.AutoButtonColor = false
miniIcon.Visible = false
miniIcon.Active = true
miniIcon.Draggable = true
local mic = Instance.new("UICorner", miniIcon) mic.CornerRadius = UDim.new(1, 0)
local mis = Instance.new("UIStroke", miniIcon)
mis.Color = Color3.fromRGB(140, 180, 255)
mis.Transparency = 0.5
mis.Thickness = 1.5

local miniDragStart, miniDragged = nil, false
miniIcon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        miniDragStart = i.Position; miniDragged = false
    end
end)
miniIcon.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement and miniDragStart then
        if (i.Position - miniDragStart).Magnitude > 5 then miniDragged = true end
    end
end)
miniIcon.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        if not miniDragged then main.Visible = true; miniIcon.Visible = false end
        miniDragStart = nil; miniDragged = false
    end
end)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    miniIcon.Visible = true
end)

-- ===== RESIZE HANDLE (pojok kanan bawah) =====
local resizeHandle = Instance.new("TextButton", main)
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = "⋱"
resizeHandle.TextColor3 = Color3.fromRGB(140, 160, 190)
resizeHandle.Font = Enum.Font.Montserrat
resizeHandle.TextSize = 16
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 10

local resizing = false
local resizeStart = nil
local startSize = nil

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        startSize = main.Size
        main.Draggable = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local newW = math.max(320, startSize.X.Offset + delta.X)
        local newH = math.max(300, startSize.Y.Offset + delta.Y)
        main.Size = UDim2.new(0, newW, 0, newH)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if resizing then
            resizing = false
            main.Draggable = true
        end
    end
end)

-- ======================================================
-- ================ LOGIC LOOPS =========================
-- ======================================================

-- ===== LOGIC: NOCLIP BARRIER (loop) =====
task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.NoclipBarrierEnabled then
            local g = workspace:FindFirstChild("Game")
            if g then local m = g:FindFirstChild("Map")
                if m then for _, fn in ipairs(BARRIER_FOLDERS) do
                    local f = m:FindFirstChild(fn)
                    if f then for _, v in pairs(f:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end end
                end end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.BarrierESPEnabled then
            scanBarrierESP()
        else
            clearESP()
        end
        task.wait(5)
    end
    clearESP()
end)

-- ===== LOGIC: ROUND TIMER =====
local function findTimer()
    local gf = workspace:FindFirstChild("Game")
    if not gf then return nil end
    local stats = gf:FindFirstChild("Stats")
    if not stats then return nil end
    local t = stats:GetAttribute("Timer")
    if type(t) == "number" then return t end
    return nil
end

local function formatTime(sec)
    if not sec or sec < 0 then return "--:--" end
    local m = math.floor(sec / 60)
    local s = math.floor(sec % 60)
    return string.format("%02d:%02d", m, s)
end

task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.ShowTimer and timerHud then
            local val = findTimer()
            if val then
                timerValue.Text = formatTime(val)
                timerValue.TextColor3 = val < 10 and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
            else
                timerValue.Text = "--:--"
                timerValue.TextColor3 = Color3.fromRGB(140, 160, 190)
            end
        end
        task.wait(0.25)
    end
end)

-- ===== LOGIC: HIDE END SCREEN =====
local UserInputService = game:GetService("UserInputService")
local _endScreenActive = false

task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.HideEndScreen then
            local pg = player.PlayerGui
            local shared = pg:FindFirstChild("Shared")
            if shared then
                local hud = shared:FindFirstChild("HUD")
                if hud then
                    local interactors = hud:FindFirstChild("Interactors")
                    if interactors then
                        local popups = interactors:FindFirstChild("Popups")
                        if popups then
                            local results = popups:FindFirstChild("Results")
                            if results and results:IsA("GuiObject") and results.Visible then
                                _endScreenActive = true
                                -- cari exit button dan trigger semua cara
                                local exitBtn = results:FindFirstChild("TextButton", true)
                                if exitBtn and exitBtn:IsA("TextButton") then
                                    -- cara 1: getconnections
                                    pcall(function()
                                        for _, conn in pairs(getconnections(exitBtn.MouseButton1Click)) do
                                            conn:Fire()
                                        end
                                    end)
                                    -- cara 2: firesignal
                                    pcall(function()
                                        firesignal(exitBtn.MouseButton1Click)
                                    end)
                                    -- cara 3: fireclick
                                    pcall(function()
                                        fireclick(exitBtn)
                                    end)
                                    -- cara 4: virtual input (klik di posisi button)
                                    pcall(function()
                                        local pos = exitBtn.AbsolutePosition + (exitBtn.AbsoluteSize / 2)
                                        local VIM = game:GetService("VirtualInputManager")
                                        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                        task.wait(0.05)
                                        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                                    end)
                                    task.wait(0.2)
                                end
                                -- fallback: force hide
                                if results.Visible then
                                    results.Visible = false
                                end
                            else
                                _endScreenActive = false
                            end
                        end
                    end
                end
            end
            -- hide Rewards di Global
            local global = pg:FindFirstChild("Global")
            if global then
                local rewards = global:FindFirstChild("Rewards")
                if rewards and rewards:IsA("GuiObject") and rewards.Visible then
                    rewards.Visible = false
                end
            end
        end
        task.wait(0.3)
    end
end)

-- cursor lock loop: override game's mouse unlock selama end screen di-hide
task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.HideEndScreen and _endScreenActive then
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                UserInputService.MouseIconEnabled = false
            end)
        end
        task.wait(0.05) -- spam cepet biar game ga sempet override
    end
end)

-- ===== LOGIC: WALL TP (XRAY) - CUMA TEMBOK, LANTAI AMAN =====
local wallData = {}

local function isWall(part)
    local size = part.Size
    -- lantai = tipis di Y DAN lebar di X dan Z
    if size.Y <= 3 and size.X >= 6 and size.Z >= 6 then
        return false -- ini lantai, skip
    end
    -- cek nama lantai
    local name = part.Name:lower()
    if name:find("floor") or name:find("ground") or name:find("base") or name:find("platform") or name:find("spawn") then
        return false
    end
    -- sisanya = tembok/wall (part yang cukup gede)
    if size.X >= 2 or size.Y >= 2 or size.Z >= 2 then
        return true
    end
    return false
end

task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.WallTPEnabled then
            local g = workspace:FindFirstChild("Game")
            if g then local m = g:FindFirstChild("Map")
                if m then for _, v in pairs(m:GetDescendants()) do
                    if v:IsA("BasePart") and v.Transparency < 0.5 and isWall(v) then
                        if not wallData[v] then
                            wallData[v] = {
                                transparency = v.Transparency,
                                canCollide = v.CanCollide,
                                textures = {},
                                textureId = nil,
                            }
                            -- hide Decal/Texture yang bikin tembok masih keliatan
                            for _, child in pairs(v:GetChildren()) do
                                if child:IsA("Decal") or child:IsA("Texture") then
                                    wallData[v].textures[child] = child.Transparency
                                    child.Transparency = 1
                                elseif child:IsA("SurfaceGui") then
                                    wallData[v].textures[child] = child.Enabled
                                    child.Enabled = false
                                end
                            end
                            -- MeshPart TextureID
                            if v:IsA("MeshPart") and v.TextureID ~= "" then
                                wallData[v].textureId = v.TextureID
                                v.TextureID = ""
                            end
                        end
                        v.Transparency = 0.7
                        v.CanCollide = false
                    end
                end end
            end
        else
            -- restore tembok
            for part, data in pairs(wallData) do
                if part and part.Parent then
                    part.Transparency = data.transparency
                    part.CanCollide = data.canCollide
                    -- restore textures
                    for child, origVal in pairs(data.textures) do
                        if child and child.Parent then
                            if child:IsA("Decal") or child:IsA("Texture") then
                                child.Transparency = origVal
                            elseif child:IsA("SurfaceGui") then
                                child.Enabled = origVal
                            end
                        end
                    end
                    -- restore MeshPart TextureID
                    if data.textureId and part:IsA("MeshPart") then
                        part.TextureID = data.textureId
                    end
                end
            end
            wallData = {}
        end
        task.wait(1)
    end
    -- cleanup on exit
    for part, data in pairs(wallData) do
        if part and part.Parent then
            part.Transparency = data.transparency
            part.CanCollide = data.canCollide
            for child, origVal in pairs(data.textures) do
                if child and child.Parent then
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = origVal
                    elseif child:IsA("SurfaceGui") then
                        child.Enabled = origVal
                    end
                end
            end
            if data.textureId and part:IsA("MeshPart") then
                part.TextureID = data.textureId
            end
        end
    end
end)

-- ===== LOGIC: AVOID NEXTBOT =====
local function getClosestNextbot()
    local myChar = player.Character
    if not myChar then return nil, math.huge end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil, math.huge end

    local closest = nil
    local closestDist = math.huge
    local playerChars = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = true end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not playerChars[v] then
            local tHRP = v:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local pos = tHRP.Position
                if math.abs(pos.X) < 49000 and math.abs(pos.Z) < 49000 then
                    local dist = (myHRP.Position - pos).Magnitude
                    if dist < closestDist then
                        closest = tHRP
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest, closestDist
end

local function hasFloor(position)
    local rayOrigin = position + Vector3.new(0, 2, 0)
    local rayDirection = Vector3.new(0, -RAYCAST_DOWN, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    return workspace:Raycast(rayOrigin, rayDirection, params) ~= nil
end

local avoidConn = RunService.Heartbeat:Connect(function()
    if not _G.EvadeHubRunning then return end
    if not _G.AvoidNextbot then return end

    local myChar = player.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local nextbot, dist = getClosestNextbot()
    if not nextbot then return end
    if dist > AVOID_RANGE then return end

    local myPos = myHRP.Position
    local nbPos = nextbot.Position

    local awayDir = (myPos - nbPos) * Vector3.new(1, 0, 1)
    if awayDir.Magnitude < 0.1 then awayDir = Vector3.new(1, 0, 0) end
    awayDir = awayDir.Unit

    local right = Vector3.new(awayDir.Z, 0, -awayDir.X).Unit
    local directions = {
        awayDir,
        (awayDir + right).Unit,
        (awayDir - right).Unit,
        right,
        -right,
        (right + awayDir * 0.3).Unit,
        (-right + awayDir * 0.3).Unit,
        (-awayDir + right).Unit,
    }

    local bestPos = nil
    local bestScore = -math.huge
    for _, dir in ipairs(directions) do
        local testPos = myPos + dir * AVOID_SPEED
        if hasFloor(testPos) then
            local distFromNB = (testPos - nbPos).Magnitude
            if distFromNB > bestScore then
                bestScore = distFromNB
                bestPos = testPos
            end
        end
    end

    if bestPos then
        myHRP.CFrame = CFrame.new(bestPos, nbPos)
    end
end)

-- ===== LOGIC: AUTO REVIVE =====
task.spawn(function()
    while _G.EvadeHubRunning do
        if _G.AutoReviveEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local tChar = p.Character
                    if tChar and tChar:GetAttribute("Downed") == true then
                        local myChar = player.Character
                        if myChar then
                            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                            local tHRP = tChar:FindFirstChild("HumanoidRootPart")
                            if myHRP and tHRP then
                                local dist = (myHRP.Position - tHRP.Position).Magnitude
                                if dist <= REVIVE_RANGE then
                                    local oldCF = myHRP.CFrame
                                    myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 2)
                                    task.wait(0.2)
                                    reviveRemote:FireServer("Revive", nil, p.Name)
                                    task.wait(0.3)
                                    reviveRemote:FireServer("Revive", true, p.Name)
                                    task.wait(0.3)
                                    myHRP.CFrame = oldCF
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- ===== TRIGGERS: AUTO TP (detect loading screen selesai) =====
local function waitForLoadingDone(timeout)
    -- tunggu LoadMap.Visible jadi false (loading selesai)
    local pg = player.PlayerGui
    local elapsed = 0
    while elapsed < (timeout or 30) do
        local global = pg:FindFirstChild("Global")
        if global then
            local loadMap = global:FindFirstChild("LoadMap")
            if loadMap and not loadMap.Visible then
                return true
            end
        end
        task.wait(0.2)
        elapsed = elapsed + 0.2
    end
    return false -- timeout
end

-- AFK Mode: pake logic sama kayak placeTP, baru TP badan ke safe
local function afkModeAction()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local mapFolder = gameFolder:FindFirstChild("Map") or gameFolder:WaitForChild("Map", 5)
    if not mapFolder then return end
    local mapName = mapFolder:GetAttribute("MapName")
    if not mapName then
        for i = 1, 15 do
            mapName = mapFolder:GetAttribute("MapName")
            if mapName then break end
            task.wait(0.1)
        end
    end
    if not mapName then return end

    local campCF = mapCoords[mapName]
    local safeCF = safeCoords[mapName] or campCF

    if not campCF then
        setStatus("AFK: map '" .. mapName .. "' belum ada koordinat")
        return
    end

    -- 1. Place teleporter (logic sama kayak placeTP)
    setStatus("AFK: placing TP - " .. mapName)
    local oldCF = hrp.CFrame
    remote:FireServer(2) task.wait(0.3)
    remote:FireServer(0, 16) task.wait(0.5)
    hrp.CFrame = campCF
    task.wait(0.5)
    remote:FireServer(1, {"Teleporter", campCF * CFrame.new(0, -2.7, 0)})
    task.wait(0.3)

    -- 2. TP badan ke safe spot
    if safeCF then
        hrp.CFrame = safeCF
        setStatus("AFK: done! TP placed + safe - " .. mapName)
    else
        hrp.CFrame = oldCF
        setStatus("AFK: TP placed - " .. mapName)
    end
end

player.CharacterAdded:Connect(function()
    if not _G.EvadeHubRunning then return end

    -- tunggu loading screen ilang
    waitForLoadingDone(30)
    task.wait(0.5)

    -- auto command (PS)
    if _G.AutoCommandEnabled and _G.AutoCommandText ~= "" then
        pcall(function()
            local vipCmd = game:GetService("ReplicatedStorage").Events.Admin:FindFirstChild("VIPCommandEvent")
            if vipCmd then
                vipCmd:InvokeServer(_G.AutoCommandText)
                setStatus("Auto Cmd: " .. _G.AutoCommandText)
            end
        end)
    end

    if _G.AFKModeEnabled then
        task.spawn(afkModeAction)
    elseif _G.TPEnabled then
        task.spawn(placeTP, 0)
    elseif _G.TPBodyOnly then
        task.spawn(tpBadan, 0)
    end
end)

gameFolder.ChildAdded:Connect(function(c)
    if c.Name == "Map" and _G.EvadeHubRunning then
        -- tunggu loading screen ilang
        waitForLoadingDone(30)
        task.wait(0.5)

        -- auto command (PS)
        if _G.AutoCommandEnabled and _G.AutoCommandText ~= "" then
            pcall(function()
                local vipCmd = game:GetService("ReplicatedStorage").Events.Admin:FindFirstChild("VIPCommandEvent")
                if vipCmd then
                    vipCmd:InvokeServer(_G.AutoCommandText)
                    setStatus("Auto Cmd: " .. _G.AutoCommandText)
                end
            end)
        end

        if _G.AFKModeEnabled then
            task.spawn(afkModeAction)
        elseif _G.TPEnabled then
            task.spawn(placeTP, 0)
        elseif _G.TPBodyOnly then
            task.spawn(tpBadan, 0)
        end
        -- re-apply noclip & esp on new map
        if _G.BarrierESPEnabled then
            task.delay(2, scanBarrierESP)
        end
    end
end)

-- ===== CLEANUP ON DESTROY =====
screenGui.Destroying:Connect(function()
    _G.EvadeHubRunning = false
    avoidConn:Disconnect()
    clearESP()
end)

StarterGui:SetCore("SendNotification", {
    Title = "rosesprvt",
    Text = "v0.1 loaded!",
    Duration = 3
})

print("[rosesprvt] Loaded with full logic!")
