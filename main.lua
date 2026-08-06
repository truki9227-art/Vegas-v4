-- [[ ZENITH HUB - FULL EDITION | + QUAN SÁT NGƯỜI CHƠI | ARCEUS X ỔN ĐỊNH ]]

-- ==============================================
-- === MÀN HÌNH LOADING TRE ĐEN 1 GIÂY ===
-- ==============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local loadGui = Instance.new("ScreenGui")
loadGui.ResetOnSpawn = false
loadGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local bgLoading = Instance.new("Frame")
bgLoading.Size = UDim2.fromScale(1, 1)
bgLoading.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bgLoading.Parent = loadGui

local textLoading = Instance.new("TextLabel")
textLoading.Size = UDim2.new(0, 400, 0, 50)
textLoading.Position = UDim2.new(0.5, -200, 0.43, -25)
textLoading.BackgroundTransparency = 1
textLoading.Text = "Loading Zenith Hub..."
textLoading.TextScaled = true
textLoading.Font = Enum.Font.GothamBold
textLoading.TextColor3 = Color3.fromRGB(255, 255, 255)
textLoading.Parent = bgLoading

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 280, 0, 10)
barBg.Position = UDim2.new(0.5, -140, 0.53, 0)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.Parent = bgLoading
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
bar.BorderSizePixel = 0
bar.Parent = barBg
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

for i = 1, 100 do
    bar.Size = UDim2.new(i/100, 0, 1, 0)
    task.wait(0.01)
end
loadGui:Destroy()

-- ==============================================
-- === KHỞI TẠO DỊCH VỤ & BIẾN GỐC ===
-- ==============================================
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local RenderSettings = settings():GetService("RenderSettings")
local TweenService = game:GetService("TweenService")

-- Trạng thái chức năng GỐC
local speedEnabled, flyEnabled, espEnabled, sunsetEnabled, jumpEnabled, noclipEnabled, camLockEnabled, infJumpEnabled, fpsEnabled, sipLocEnabled = false, false, false, false, false, false, false, false, false, false
local walkSpeedValue, jumpPowerValue = 50, 100
local noclipConnection, infJumpConnection, fpsConnection, bv, bg, flyLoop, flyUpdateConnection, sipLocRenderConnection = nil
local speeds = 1
local nowe = false
local tpwalking = false
local waterRunEnabled = false
local wallRunConnection = nil
local originalGravity = workspace.Gravity
local originalCameraType = Camera.CameraType

-- Dịch chuyển / Bám theo người chơi
local playerList = {}
local currentTargetIndex = 1
local targetPlayer = nil
local tpEnabled = false

-- AIMBOT & XOAY CAM
local aimbotNearestEnabled = false     
local aimbotSelectedEnabled = false    
local aimbotAllCycleEnabled = false    
local selectedTargetPlayer = nil       
local cycleTargetIndex = 1
local cycleTimer = 0

-- ✅ MỚI: BIẾN CHỨC NĂNG QUAN SÁT NGƯỜI CHƠI
local isSpectating = false
local currentSpectateTarget = nil
local spectateGui = nil
local spectateListFrame = nil
local spectateStopBtn = nil
local spectateToggleBtn = nil
local oldCamSubject = nil
local oldCamType = nil

-- ==============================================
-- === TAB FIX LAG ===
-- ==============================================
local fixLagEnabled = false
local fixLagLevel = 1
local fixLagLoop = nil
local originalRender = {
    QualityLevel = RenderSettings.QualityLevel,
    LightingTechnology = Lighting.Technology,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    ExposureCompensation = Lighting.ExposureCompensation
}

-- ==============================================
-- === TAB CHẾ ĐỘ ẢO & HIỆU ỨNG CHÂN ===
-- ==============================================
local ghostSelfEnabled = false
local ghostEnemyEnabled = false
local ghostLightEnabled = false
local ghostLoop = nil
local ghostSpotLight = nil

local trailFire = false
local trailWater = false
local trailRainbow = false
local rainbowHue = 0
local TRAIL_NAMES = {Fire="AO_TRAIL_FIRE", Water="AO_TRAIL_WATER", Rainbow="AO_TRAIL_RAINBOW"}

local function getTrailLimbs()
    local char = LocalPlayer.Character if not char then return {} end
    local limbs = {}
    for _, name in pairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
        local l = char:FindFirstChild(name) if l and l:IsA("BasePart") then table.insert(limbs, l) end
    end
    if #limbs == 0 then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then table.insert(limbs, hrp) end
    end
    return limbs
end

local function clearAllTrails()
    trailFire=false trailWater=false trailRainbow=false
    local char = LocalPlayer.Character if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("ParticleEmitter") then
            for _, name in pairs(TRAIL_NAMES) do
                if part.Name == name then pcall(function() part:Destroy() end) end
            end
        end
    end
end

local function createTrail(parent, kind)
    if not parent or parent:FindFirstChild(TRAIL_NAMES[kind]) then return end
    local p = Instance.new("ParticleEmitter")
    p.Name = TRAIL_NAMES[kind]
    p.Enabled = true
    p.Lifetime = NumberRange.new(0.4, 0.9)
    p.Rate = 40
    p.Speed = NumberRange.new(6, 14)
    p.SpreadAngle = Vector2.new(30, 50)
    p.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0)})
    p.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 1)})
    p.Acceleration = Vector3.new(0, 3, 0)
    p.LockedToPart = true
    p.VelocityInheritance = 0.5
    if kind == "Fire" then
        p.Texture = "rbxassetid://154966922"
        p.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,240,100)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255,120,30)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(220,40,10)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80,0,0))
        }
        p.Lifetime = NumberRange.new(0.3, 0.75)
        p.Rate = 60
        p.Acceleration = Vector3.new(0, 12, 0)
        p.Speed = NumberRange.new(8, 18)
        p.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0)})
    elseif kind == "Water" then
        p.Texture = "rbxassetid://67235145"
        p.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(180,240,255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80,180,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30,90,200))
        }
        p.Lifetime = NumberRange.new(0.45, 1.1)
        p.Rate = 55
        p.Acceleration = Vector3.new(0, -14, 0)
        p.Speed = NumberRange.new(5, 12)
        p.SpreadAngle = Vector2.new(40, 60)
    elseif kind == "Rainbow" then
        p.Texture = "rbxassetid://148755873"
        p.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
        }
        p.Lifetime = NumberRange.new(0.5, 1.3)
        p.Rate = 75
        p.Acceleration = Vector3.new(0, 4, 0)
        p.Speed = NumberRange.new(7, 15)
        p.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.1), NumberSequenceKeypoint.new(1, 0)})
    end
    p.Parent = parent
    return p
end

local function setTrail(kind)
    clearAllTrails()
    if kind == "None" then return end
    local limbs = getTrailLimbs()
    for _, limb in pairs(limbs) do createTrail(limb, kind) end
    if kind == "Fire" then trailFire=true
    elseif kind == "Water" then trailWater=true
    elseif kind == "Rainbow" then trailRainbow=true end
end

local trailUpdateLoop = RunService.RenderStepped:Connect(function(dt)
    rainbowHue = (rainbowHue + dt * 2.2) % 1
    local char = LocalPlayer.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    local isMoving = hum.MoveDirection.Magnitude > 0.12 and hum.FloorMaterial ~= Enum.Material.Air
    local activeKind = trailFire and "Fire" or trailWater and "Water" or trailRainbow and "Rainbow" or nil
    if not activeKind then return end
    local limbs = getTrailLimbs()
    for _, limb in pairs(limbs) do
        if not limb:FindFirstChild(TRAIL_NAMES[activeKind]) then createTrail(limb, activeKind) end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("ParticleEmitter") then
            for _, name in pairs(TRAIL_NAMES) do
                if part.Name == name then
                    part.Enabled = (name == TRAIL_NAMES[activeKind]) and isMoving
                    if name == TRAIL_NAMES.Rainbow and part.Enabled then
                        local c1 = Color3.fromHSV(rainbowHue, 1, 1)
                        local c2 = Color3.fromHSV((rainbowHue + 0.16) % 1, 1, 1)
                        local c3 = Color3.fromHSV((rainbowHue + 0.33) % 1, 1, 1)
                        local c4 = Color3.fromHSV((rainbowHue + 0.5) % 1, 1, 1)
                        local c5 = Color3.fromHSV((rainbowHue + 0.66) % 1, 1, 1)
                        local c6 = Color3.fromHSV((rainbowHue + 0.83) % 1, 1, 1)
                        part.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.2, c2),
                            ColorSequenceKeypoint.new(0.4, c3), ColorSequenceKeypoint.new(0.6, c4),
                            ColorSequenceKeypoint.new(0.8, c5), ColorSequenceKeypoint.new(1, c6)
                        }
                    end
                end
            end
        end
    end
end)

-- ==============================================
-- === TAB HOÀN HÔN ===
-- ==============================================
local skyEnabled = false
local skyMode = "day"
local skyTween = nil
local originalSkyFull = {
    ClockTime = Lighting.ClockTime, FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart, OutdoorAmbient = Lighting.OutdoorAmbient, Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows, ExposureCompensation = Lighting.ExposureCompensation,
    ColorShift_Top = Lighting.ColorShift_Top, ColorShift_Bottom = Lighting.ColorShift_Bottom,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale, EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale, Technology = Lighting.Technology
}
local originalSkyObj = nil
pcall(function()
    local s = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
    s.Parent = Lighting
    originalSkyObj = { StarCount = s.StarCount, SunAngularSize = s.SunAngularSize, MoonAngularSize = s.MoonAngularSize }
end)
local SKY_MODES = {
    day     = { Name="☀️ SÁNG XANH",     ClockTime=14,   Brightness=2.3, ExposureCompensation=0.15, Ambient=Color3.fromRGB(180,215,255), OutdoorAmbient=Color3.fromRGB(255,240,210), FogColor=Color3.fromRGB(200,228,255), FogStart=80,  FogEnd=700, ColorShift_Top=Color3.fromRGB(100,170,255), ColorShift_Bottom=Color3.fromRGB(255,245,220), StarCount=0,     SunAngularSize=12, MoonAngularSize=0,  GlobalShadows=true },
    night   = { Name="🌙 ĐÊM TRĂNG",     ClockTime=22.8, Brightness=1.15,ExposureCompensation=-0.1, Ambient=Color3.fromRGB(35,55,115),  OutdoorAmbient=Color3.fromRGB(18,35,80),   FogColor=Color3.fromRGB(12,22,55),    FogStart=50,  FogEnd=450, ColorShift_Top=Color3.fromRGB(25,45,135),  ColorShift_Bottom=Color3.fromRGB(8,12,35),    StarCount=5000,  SunAngularSize=0,  MoonAngularSize=11, GlobalShadows=true },
    sunset  = { Name="🌇 HOÀNG HÔN",     ClockTime=18.3, Brightness=1.7, ExposureCompensation=0.22, Ambient=Color3.fromRGB(255,135,75), OutdoorAmbient=Color3.fromRGB(255,95,45),  FogColor=Color3.fromRGB(255,115,55),  FogStart=60,  FogEnd=520, ColorShift_Top=Color3.fromRGB(255,70,25),  ColorShift_Bottom=Color3.fromRGB(255,175,75), StarCount=300,   SunAngularSize=20, MoonAngularSize=0,  GlobalShadows=true },
    purple  = { Name="💜 BẦU TÍM",       ClockTime=20.2, Brightness=1.85,ExposureCompensation=0.12, Ambient=Color3.fromRGB(185,120,255),OutdoorAmbient=Color3.fromRGB(205,150,255),FogColor=Color3.fromRGB(155,95,220),  FogStart=70,  FogEnd=580, ColorShift_Top=Color3.fromRGB(175,70,255), ColorShift_Bottom=Color3.fromRGB(255,175,220),StarCount=1800,  SunAngularSize=0,  MoonAngularSize=9,  GlobalShadows=true },
    space   = { Name="🌌 VŨ TRỤ",        ClockTime=0,    Brightness=0.75,ExposureCompensation=-0.35,Ambient=Color3.fromRGB(8,8,28),     OutdoorAmbient=Color3.fromRGB(4,4,18),     FogColor=Color3.fromRGB(0,0,8),       FogStart=250, FogEnd=1400,ColorShift_Top=Color3.fromRGB(18,0,55),    ColorShift_Bottom=Color3.fromRGB(0,0,0),      StarCount=15000, SunAngularSize=0,  MoonAngularSize=0,  GlobalShadows=false },
    ocean   = { Name="🌊 BIỂN XANH",      ClockTime=11,   Brightness=2.1, ExposureCompensation=0.08, Ambient=Color3.fromRGB(120,220,220),OutdoorAmbient=Color3.fromRGB(160,240,230),FogColor=Color3.fromRGB(140,210,225), FogStart=100, FogEnd=650, ColorShift_Top=Color3.fromRGB(60,180,200), ColorShift_Bottom=Color3.fromRGB(210,250,245),StarCount=0,     SunAngularSize=14, MoonAngularSize=0,  GlobalShadows=true }
}
local function applySkyMode(mode)
    if skyTween then pcall(function() skyTween:Cancel() end) skyTween = nil end
    local data = SKY_MODES[mode] if not data then return end
    skyMode = mode
    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = {}
    for k,v in pairs(data) do
        if k~="Name" and k~="StarCount" and k~="SunAngularSize" and k~="MoonAngularSize" then goal[k]=v end
    end
    goal.GlobalShadows = data.GlobalShadows
    skyTween = TweenService:Create(Lighting, tweenInfo, goal)
    pcall(function() skyTween:Play() end)
    pcall(function()
        local s = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
        s.Parent = Lighting
        s.StarCount = data.StarCount s.SunAngularSize = data.SunAngularSize s.MoonAngularSize = data.MoonAngularSize
    end)
end
local function restoreOriginalSkyFull()
    if skyTween then pcall(function() skyTween:Cancel() end) skyTween = nil end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = {}
    for k,v in pairs(originalSkyFull) do if k~="Technology" then goal[k]=v end end
    pcall(function() TweenService:Create(Lighting, tweenInfo, goal):Play() end)
    Lighting.Technology = originalSkyFull.Technology
    pcall(function()
        local s = Lighting:FindFirstChildOfClass("Sky")
        if s and originalSkyObj then for k,v in pairs(originalSkyObj) do s[k]=v end end
    end)
end

local originalSettings = { ClockTime = Lighting.ClockTime, FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd, OutdoorAmbient = Lighting.OutdoorAmbient }

local function refreshPlayerList()
    playerList = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(playerList, p) end end
    if currentTargetIndex > #playerList then currentTargetIndex = 1 end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupCharacter(char)
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("ESP_Billboard") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Billboard"; billboard.AlwaysOnTop = true; billboard.Size = UDim2.new(0, 150, 0, 40); billboard.StudsOffset = Vector3.new(0, 2.5, 0); billboard.Parent = head
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.Text = player.Name; label.TextColor3 = Color3.fromRGB(255, 255, 0); label.Font = Enum.Font.SourceSansBold; label.TextSize = 14; label.Parent = billboard
        end
    end
    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

local function removeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("ESP_Billboard") then
            pcall(function() player.Character.Head.ESP_Billboard:Destroy() end)
        end
    end
end

-- --- ĐI BỘ TRÊN TƯỜNG ---
local function startWallRun()
    if wallRunConnection then return end
    workspace.Gravity = 0
    wallRunConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local raycastParams = RaycastParams.new() raycastParams.FilterDescendantsInstances = {char} raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local rayResult = workspace:Raycast(root.Position, -root.CFrame.UpVector * 3, raycastParams)
        if rayResult then
            local normal = rayResult.Normal local upVector = normal local lookVector = root.CFrame.LookVector
            local rightVector = lookVector:Cross(upVector).Unit lookVector = upVector:Cross(rightVector).Unit
            root.CFrame = CFrame.new(root.Position, rightVector, upVector) hum.AutoRotate = false
        else hum.AutoRotate = true end
        if hum.MoveDirection.Magnitude > 0 then
            local moveDir = hum.MoveDirection local worldMove = (root.CFrame.RightVector * moveDir.X + root.CFrame.UpVector * -moveDir.Z).Unit
            root.Velocity = worldMove * hum.WalkSpeed + root.CFrame.UpVector * 0.1
        else root.Velocity = root.CFrame.UpVector * 0.1 end
    end)
end
local function stopWallRun()
    if wallRunConnection then wallRunConnection:Disconnect() wallRunConnection = nil end
    workspace.Gravity = originalGravity
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart")
        if hum then hum.AutoRotate = true end
        if root then root.CFrame = CFrame.new(root.Position, Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z), Vector3.new(0,1,0)) end
    end
end

-- --- SÍP LÓC ---
local dot = Instance.new("Part")
dot.Shape = Enum.PartType.Ball dot.Size = Vector3.new(0.2,0.2,0.2) dot.Material = Enum.Material.Neon dot.Color = Color3.new(1,1,1) dot.Anchored = true dot.CanCollide = false dot.Transparency = 1 dot.Parent = workspace
local function updateSipLoc()
	local char = LocalPlayer.Character if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid") if not hrp or not hum then return end
	if sipLocEnabled then
		hum.AutoRotate = false local look = Camera.CFrame.LookVector
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X,0,look.Z))
		dot.Transparency = 0 dot.Position = hrp.Position + Vector3.new(0,2,-1)
	else hum.AutoRotate = true dot.Transparency = 1 end
end
local function startSipLoc() if sipLocRenderConnection then return end sipLocRenderConnection = RunService.RenderStepped:Connect(updateSipLoc) end
local function stopSipLoc()
	if sipLocRenderConnection then sipLocRenderConnection:Disconnect() sipLocRenderConnection = nil end
	local char = LocalPlayer.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.AutoRotate = true end end
	dot.Transparency = 1
end

-- --- FIX LAG ---
local function applyFixLagLevel(level)
    RenderSettings.QualityLevel = originalRender.QualityLevel Lighting.Technology = originalRender.LightingTechnology
    Lighting.FogEnd = originalRender.FogEnd Lighting.FogStart = originalRender.FogStart Lighting.Brightness = originalRender.Brightness Lighting.GlobalShadows = originalRender.GlobalShadows
    Lighting.EnvironmentSpecularScale = originalRender.EnvironmentSpecularScale Lighting.EnvironmentDiffuseScale = originalRender.EnvironmentDiffuseScale Lighting.ExposureCompensation = originalRender.ExposureCompensation
    if level >= 1 then RenderSettings.QualityLevel = Enum.QualityLevel.Level03 Lighting.GlobalShadows = false pcall(function() RenderSettings.FrameRateManager = true end) end
    if level >= 2 then Lighting.Technology = Enum.Technology.Compatibility Lighting.EnvironmentSpecularScale = 0 Lighting.EnvironmentDiffuseScale = 0.1 Lighting.ExposureCompensation = 0.3 Lighting.FogEnd = math.min(Lighting.FogEnd, 400) end
    if level >= 3 then
        Lighting.FogEnd = 150 Lighting.FogStart = 80 Lighting.Brightness = 1.2 RenderSettings.QualityLevel = Enum.QualityLevel.Level01
        task.spawn(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Trail") then pcall(function() v.Enabled = false end) end
            end
        end)
    end
end
local function startFixLag()
    if fixLagLoop then return end applyFixLagLevel(fixLagLevel)
    fixLagLoop = RunService.Heartbeat:Connect(function()
        if not fixLagEnabled then return end
        if fixLagLevel >= 1 then Lighting.GlobalShadows = false end
        if fixLagLevel >= 3 then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character or workspace) then
                        local dist = (v.Position - Camera.CFrame.Position).Magnitude if dist > 200 then v.LocalTransparencyModifier = 0.8 end
                    end
                end
            end)
        end
    end)
end
local function stopFixLag()
    if fixLagLoop then fixLagLoop:Disconnect() fixLagLoop = nil end
    RenderSettings.QualityLevel = originalRender.QualityLevel Lighting.Technology = originalRender.LightingTechnology
    Lighting.FogEnd = originalRender.FogEnd Lighting.FogStart = originalRender.FogStart Lighting.Brightness = originalRender.Brightness Lighting.GlobalShadows = originalRender.GlobalShadows
    Lighting.EnvironmentSpecularScale = originalRender.EnvironmentSpecularScale Lighting.EnvironmentDiffuseScale = originalRender.EnvironmentDiffuseScale Lighting.ExposureCompensation = originalRender.ExposureCompensation
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = true end
        end
    end)
end

-- --- CHẾ ĐỘ ẢO ---
local function updateGhostMode()
    if ghostSelfEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier = 0.7 end end
    elseif not ghostSelfEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier = 0 end end
    end
    if ghostEnemyEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then for _, part in ipairs(plr.Character:GetDescendants()) do if part:IsA("BasePart") then part.LocalTransparencyModifier = 0.6 end end end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then for _, part in ipairs(plr.Character:GetDescendants()) do if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end end end
        end
    end
    if ghostLightEnabled then
        if not ghostSpotLight then
            ghostSpotLight = Instance.new("SpotLight") ghostSpotLight.Name = "GhostFlashLight" ghostSpotLight.Brightness = 3 ghostSpotLight.Range = 60 ghostSpotLight.Angle = 45 ghostSpotLight.Color = Color3.fromRGB(255, 255, 240) ghostSpotLight.Parent = Camera
        end
        ghostSpotLight.Enabled = true
    else if ghostSpotLight then ghostSpotLight.Enabled = false end end
end
local function startGhostLoop() if ghostLoop then return end ghostLoop = RunService.RenderStepped:Connect(updateGhostMode) end
local function stopGhostLoop()
    if ghostLoop then ghostLoop:Disconnect() ghostLoop = nil end
    ghostSelfEnabled = false ghostEnemyEnabled = false ghostLightEnabled = false updateGhostMode()
    if ghostSpotLight then ghostSpotLight:Destroy() ghostSpotLight = nil end clearAllTrails()
end

-- ==============================================
-- === ✅ HÀM CHỨC NĂNG QUAN SÁT NGƯỜI CHƠI ===
-- ==============================================
local function updateSpectateList()
    if not spectateListFrame then return end
    for _, c in ipairs(spectateListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            count += 1
            local pb = Instance.new("TextButton")
            pb.Size = UDim2.new(1, -10, 0, 35)
            pb.Position = UDim2.new(0, 5, 0, (count-1)*40 + 5)
            pb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            pb.TextColor3 = Color3.fromRGB(255, 255, 255)
            pb.TextSize = 14
            pb.Font = Enum.Font.Gotham
            pb.Text = p.Name
            pb.Parent = spectateListFrame
            Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 6)
            pb.MouseButton1Click:Connect(function()
                startSpectating(p)
            end)
        end
    end
    spectateListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(280, count * 40 + 10))
end

function startSpectating(targetPlr)
    if not targetPlr or not targetPlr.Character or not targetPlr.Character:FindFirstChild("HumanoidRootPart") then return end
    -- Lưu trạng thái cũ để trả về
    oldCamType = Camera.CameraType
    oldCamSubject = Camera.CameraSubject
    -- Tắt các chức năng đè camera
    isSpectating = true
    currentSpectateTarget = targetPlr
    aimbotNearestEnabled = false
    aimbotSelectedEnabled = false
    aimbotAllCycleEnabled = false
    -- Ẩn danh sách, hiện nút thoát
    if spectateListFrame then spectateListFrame.Visible = false end
    if spectateStopBtn then spectateStopBtn.Visible = true end
    -- Đổi camera sang điều khiển bằng script
    pcall(function() Camera.CameraType = Enum.CameraType.Scriptable end)
end

function stopSpectating()
    isSpectating = false
    currentSpectateTarget = nil
    if spectateStopBtn then spectateStopBtn.Visible = false end
    -- Trả camera về người chơi
    pcall(function()
        Camera.CameraType = oldCamType or Enum.CameraType.Custom
        local meChar = LocalPlayer.Character
        if meChar then
            local hum = meChar:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
    end)
    oldCamType = nil
    oldCamSubject = nil
end

-- ==============================================
-- === GIAO DIỆN CHÍNH ===
-- ==============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenithHub_Fluent"; ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 395) MainFrame.Position = UDim2.new(0.5, -260, 0.5, -197)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28) MainFrame.BorderSizePixel = 0 MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32) TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35) TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

-- Kéo menu thủ công (không dùng Draggable bị Arceus X chặn)
local dragging, dragStart, startPos = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = i.Position startPos = MainFrame.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "ZENITH HUB - FULL EDITION"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar
RunService.RenderStepped:Connect(function() Title.TextColor3 = Color3.fromHSV((os.clock()%5)/5, 1, 1) end)

local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 130, 1, -32); SideBar.Position = UDim2.new(0, 0, 0, 32); SideBar.BackgroundColor3 = Color3.fromRGB(32, 32, 32); SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -140, 1, -42); ContentFrame.Position = UDim2.new(0, 135, 0, 37); ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- 6 TAB
local TabChinhContainer = Instance.new("ScrollingFrame", ContentFrame)
TabChinhContainer.Size = UDim2.new(1, 0, 1, 0); TabChinhContainer.BackgroundTransparency = 1; TabChinhContainer.ScrollBarThickness = 2; TabChinhContainer.CanvasSize = UDim2.new(0, 0, 0, 600)

local TabAimbotContainer = Instance.new("ScrollingFrame", ContentFrame)
TabAimbotContainer.Size = UDim2.new(1, 0, 1, 0); TabAimbotContainer.BackgroundTransparency = 1; TabAimbotContainer.ScrollBarThickness = 2; TabAimbotContainer.CanvasSize = UDim2.new(0, 0, 0, 520); TabAimbotContainer.Visible = false

local TabFixLagContainer = Instance.new("ScrollingFrame", ContentFrame)
TabFixLagContainer.Size = UDim2.new(1, 0, 1, 0); TabFixLagContainer.BackgroundTransparency = 1; TabFixLagContainer.ScrollBarThickness = 2; TabFixLagContainer.CanvasSize = UDim2.new(0, 0, 0, 520); TabFixLagContainer.Visible = false

local TabAoContainer = Instance.new("ScrollingFrame", ContentFrame)
TabAoContainer.Size = UDim2.new(1, 0, 1, 0); TabAoContainer.BackgroundTransparency = 1; TabAoContainer.ScrollBarThickness = 2; TabAoContainer.CanvasSize = UDim2.new(0, 0, 0, 560); TabAoContainer.Visible = false

local TabHoanHonContainer = Instance.new("ScrollingFrame", ContentFrame)
TabHoanHonContainer.Size = UDim2.new(1, 0, 1, 0); TabHoanHonContainer.BackgroundTransparency = 1; TabHoanHonContainer.ScrollBarThickness = 2; TabHoanHonContainer.CanvasSize = UDim2.new(0, 0, 0, 620); TabHoanHonContainer.Visible = false

local TabCaiDatContainer = Instance.new("ScrollingFrame", ContentFrame)
TabCaiDatContainer.Size = UDim2.new(1, 0, 1, 0); TabCaiDatContainer.BackgroundTransparency = 1; TabCaiDatContainer.ScrollBarThickness = 2; TabCaiDatContainer.CanvasSize = UDim2.new(0, 0, 0, 700); TabCaiDatContainer.Visible = false

local AllContainers = {TabChinhContainer, TabAimbotContainer, TabFixLagContainer, TabAoContainer, TabHoanHonContainer, TabCaiDatContainer}

local function createTabButton(text, yPos)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(1, -10, 0, 28); btn.Position = UDim2.new(0, 5, 0, yPos); btn.BackgroundColor3 = Color3.fromRGB(38, 38, 38); btn.Text = text; btn.TextColor3 = Color3.fromRGB(180, 180, 180); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local ChinhTabBtn = createTabButton("🏠 Chính", 8)
local AimbotTabBtn = createTabButton("🎯 Aimbot Cam", 40)
local FixLagTabBtn = createTabButton("⚡ Fix Lag", 72)
local AoTabBtn = createTabButton("👻 Chế Độ Ảo", 104)
local HoanHonTabBtn = createTabButton("🌅 Hoàn Hôn", 136)
local CaiDatTabBtn = createTabButton("⚙️ Cài Đặt", 168)

ChinhTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ChinhTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local AllTabBtns = {ChinhTabBtn, AimbotTabBtn, FixLagTabBtn, AoTabBtn, HoanHonTabBtn, CaiDatTabBtn}

local function setActiveTab(activeBtn, activeContainer)
    for _, c in pairs(AllContainers) do c.Visible = false end
    for _, b in pairs(AllTabBtns) do
        b.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        b.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    activeContainer.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

ChinhTabBtn.MouseButton1Click:Connect(function() setActiveTab(ChinhTabBtn, TabChinhContainer) end)
AimbotTabBtn.MouseButton1Click:Connect(function() setActiveTab(AimbotTabBtn, TabAimbotContainer) end)
FixLagTabBtn.MouseButton1Click:Connect(function() setActiveTab(FixLagTabBtn, TabFixLagContainer) end)
AoTabBtn.MouseButton1Click:Connect(function() setActiveTab(AoTabBtn, TabAoContainer) end)
HoanHonTabBtn.MouseButton1Click:Connect(function() setActiveTab(HoanHonTabBtn, TabHoanHonContainer) end)
CaiDatTabBtn.MouseButton1Click:Connect(function() setActiveTab(CaiDatTabBtn, TabCaiDatContainer) end)

local function createModernRow(parent, text, yPos, callback, isSlider, defaultVal, sliderCallback)
    local rowFrame = Instance.new("Frame", parent)
    rowFrame.Size = UDim2.new(1, -10, 0, 38); rowFrame.Position = UDim2.new(0, 0, 0, yPos); rowFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38); rowFrame.BorderSizePixel = 0
    Instance.new("UICorner", rowFrame).CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel", rowFrame)
    label.Size = UDim2.new(0.6, 0, 1, 0); label.Position = UDim2.new(0, 10, 0, 0); label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.fromRGB(210, 210, 210); label.Font = Enum.Font.SourceSans; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    if not isSlider then
        local toggleBtn = Instance.new("TextButton", rowFrame)
        toggleBtn.Size = UDim2.new(0, 70, 0, 22); toggleBtn.Position = UDim2.new(1, -80, 0.5, -11); toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55); toggleBtn.Text = "TẮT"; toggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180); toggleBtn.Font = Enum.Font.SourceSansBold; toggleBtn.TextSize = 11
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
        toggleBtn.MouseButton1Click:Connect(function()
            local newState = callback(toggleBtn)
            if newState then toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100); toggleBtn.Text = "BẬT"; toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55); toggleBtn.Text = "TẮT"; toggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180) end
        end)
    else
        local box = Instance.new("TextBox", rowFrame)
        box.Size = UDim2.new(0, 50, 0, 22); box.Position = UDim2.new(1, -60, 0.5, -11); box.BackgroundColor3 = Color3.fromRGB(28, 28, 28); box.Text = tostring(defaultVal); box.TextColor3 = Color3.fromRGB(0, 180, 255); box.Font = Enum.Font.SourceSansBold; box.TextSize = 12
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        box.FocusLost:Connect(function() local val = tonumber(box.Text) if val then sliderCallback(val) else box.Text = tostring(defaultVal) end end)
    end
end

local function note(p, t, y, c)
    local lb = Instance.new("TextLabel", p)
    lb.Size = UDim2.new(1, -20, 0, 18); lb.Position = UDim2.new(0, 10, 0, y); lb.BackgroundTransparency = 1
    lb.Text = t; lb.TextColor3 = c or Color3.fromRGB(180,180,180); lb.Font = Enum.Font.SourceSans; lb.TextSize = 12; lb.TextXAlignment = Enum.TextXAlignment.Left
end

-- ==============================================
-- === TAB AIMBOT ===
-- ==============================================
createModernRow(TabAimbotContainer, "🎯 Xoay cam người gần nhất", 10, function()
    aimbotNearestEnabled = not aimbotNearestEnabled
    return aimbotNearestEnabled
end, false)

local selectTargetBtn = Instance.new("TextButton", TabAimbotContainer)
selectTargetBtn.Size = UDim2.new(1, -10, 0, 32); selectTargetBtn.Position = UDim2.new(0, 0, 0, 52)
selectTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 140); selectTargetBtn.Text = "👤 Bấm chọn mục tiêu: [Chưa chọn]"
selectTargetBtn.Font = Enum.Font.SourceSansBold; selectTargetBtn.TextSize = 12; selectTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", selectTargetBtn).CornerRadius = UDim.new(0, 4)
selectTargetBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    if #playerList == 0 then selectTargetBtn.Text = "👤 Không có người chơi nào!" return end
    selectedTargetPlayer = playerList[currentTargetIndex]
    if selectedTargetPlayer then selectTargetBtn.Text = "🎯 Đã chọn: " .. selectedTargetPlayer.Name end
    currentTargetIndex = (currentTargetIndex % #playerList) + 1
end)

createModernRow(TabAimbotContainer, "🔒 Khóa cam theo mục tiêu", 94, function()
    aimbotSelectedEnabled = not aimbotSelectedEnabled
    return aimbotSelectedEnabled
end, false)

createModernRow(TabAimbotContainer, "🔄 Xoay cam tất cả người chơi", 136, function()
    aimbotAllCycleEnabled = not aimbotAllCycleEnabled
    cycleTimer = 0 cycleTargetIndex = 1
    return aimbotAllCycleEnabled
end, false)

note(TabAimbotContainer, "📝 Hướng dẫn Aimbot:", 185, Color3.fromRGB(200, 150, 255))
note(TabAimbotContainer, "• Xoay gần nhất: Tự động nhìn kẻ địch gần bạn", 210)
note(TabAimbotContainer, "• Khóa mục tiêu chọn: Bấm nút xanh đổi tên xong bật công tắc", 235)
note(TabAimbotContainer, "• Xoay vòng quanh: Tự động đổi góc nhìn qua lại tất cả người chơi", 260, Color3.fromRGB(0, 220, 150))

-- ==============================================
-- === TAB CHÍNH ===
-- ==============================================
createModernRow(TabChinhContainer, "Chạy Nhanh + Lửa chân", 10, function() speedEnabled = not speedEnabled return speedEnabled end, false)
createModernRow(TabChinhContainer, "↳ Tốc độ chạy", 52, nil, true, 50, function(val) walkSpeedValue = val end)

createModernRow(TabChinhContainer, "Bay", 94, function(btn)
    flyEnabled = not flyEnabled
    if flyEnabled then
        nowe = true btn.Text = "Tắt"
        local chr = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = chr:FindFirstChildWhichIsA("Humanoid")
        tpwalking = false
        for i = 1, speeds do
            task.spawn(function()
                local hb = RunService.Heartbeat
                tpwalking = true
                while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                    if hum.MoveDirection.Magnitude > 0 then chr:TranslateBy(hum.MoveDirection) end
                end
            end)
        end
        chr.Animate.Disabled = true
        local Hum = chr:FindFirstChildOfClass("Humanoid") or chr:FindFirstChildOfClass("AnimationController")
        pcall(function() for _,v in next, Hum:GetPlayingAnimationTracks() do v:AdjustSpeed(0) end end)
        for _,s in ipairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s,false) end) end
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Swimming) end)
        flyLoop = task.spawn(function()
            local bodyPart = hum.RigType == Enum.HumanoidRigType.R6 and chr:WaitForChild("Torso") or chr:WaitForChild("UpperTorso")
            bg = Instance.new("BodyGyro", bodyPart) bg.P = 9e4 bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bv = Instance.new("BodyVelocity", bodyPart) bv.Velocity = Vector3.new(0,0.1,0) bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            hum.PlatformStand = true
            flyUpdateConnection = RunService.RenderStepped:Connect(function()
                if not bg or not bodyPart then return end
                local cl = Camera.CFrame.LookVector
                bg.CFrame = CFrame.new(bodyPart.Position, bodyPart.Position + Vector3.new(cl.X, cl.Y, cl.Z))
            end)
        end)
    else
        nowe = false tpwalking = false btn.Text = "Bay"
        if flyUpdateConnection then pcall(function() flyUpdateConnection:Disconnect() end) flyUpdateConnection = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then
            for _,s in ipairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s,true) end) end
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
            hum.PlatformStand = false
            LocalPlayer.Character.Animate.Disabled = false
        end
        if flyLoop then pcall(function() task.cancel(flyLoop) end) flyLoop = nil end
        if bv then pcall(function() bv:Destroy() end) bv = nil end
        if bg then pcall(function() bg:Destroy() end) bg = nil end
    end
    return flyEnabled
end, false)

local flySpeedRow = Instance.new("Frame", TabChinhContainer)
flySpeedRow.Size = UDim2.new(1, -10, 0, 38); flySpeedRow.Position = UDim2.new(0, 0, 0, 136); flySpeedRow.BackgroundColor3 = Color3.fromRGB(38, 38, 38); flySpeedRow.BorderSizePixel = 0
Instance.new("UICorner", flySpeedRow).CornerRadius = UDim.new(0, 4)
local flyLabel = Instance.new("TextLabel", flySpeedRow)
flyLabel.Size = UDim2.new(0.6, 0, 1, 0); flyLabel.Position = UDim2.new(0, 10, 0, 0); flyLabel.BackgroundTransparency = 1; flyLabel.Text = "↳ Tốc độ bay"; flyLabel.TextColor3 = Color3.fromRGB(210, 210, 210); flyLabel.Font = Enum.Font.SourceSans; flyLabel.TextSize = 13; flyLabel.TextXAlignment = Enum.TextXAlignment.Left
local flyPlus = Instance.new("TextButton", flySpeedRow)
flyPlus.Size = UDim2.new(0, 22, 0, 22); flyPlus.Position = UDim2.new(1, -80, 0.5, -11); flyPlus.BackgroundColor3 = Color3.fromRGB(133, 145, 255); flyPlus.Text = "+"; flyPlus.Font = Enum.Font.SourceSansBold; flyPlus.TextSize = 14
Instance.new("UICorner", flyPlus).CornerRadius = UDim.new(0, 4)
local flySpeedDisplay = Instance.new("TextLabel", flySpeedRow)
flySpeedDisplay.Size = UDim2.new(0, 32, 0, 22); flySpeedDisplay.Position = UDim2.new(1, -55, 0.5, -11); flySpeedDisplay.BackgroundColor3 = Color3.fromRGB(255, 85, 0); flySpeedDisplay.Text = tostring(speeds); flySpeedDisplay.Font = Enum.Font.SourceSansBold; flySpeedDisplay.TextSize = 12; flySpeedDisplay.TextXAlignment = Enum.TextXAlignment.Center; flySpeedDisplay.TextYAlignment = Enum.TextYAlignment.Center
Instance.new("UICorner", flySpeedDisplay).CornerRadius = UDim.new(0, 4)
local flyMinus = Instance.new("TextButton", flySpeedRow)
flyMinus.Size = UDim2.new(0, 22, 0, 22); flyMinus.Position = UDim2.new(1, -20, 0.5, -11); flyMinus.BackgroundColor3 = Color3.fromRGB(123, 255, 247); flyMinus.Text = "-"; flyMinus.Font = Enum.Font.SourceSansBold; flyMinus.TextSize = 14
Instance.new("UICorner", flyMinus).CornerRadius = UDim.new(0, 4)
flyPlus.MouseButton1Down:Connect(function() speeds = speeds + 1 flySpeedDisplay.Text = speeds end)
flyMinus.MouseButton1Down:Connect(function() if speeds > 1 then speeds = speeds - 1 flySpeedDisplay.Text = speeds end end)

createModernRow(TabChinhContainer, "Nhảy Cao", 178, function() jumpEnabled = not jumpEnabled return jumpEnabled end, false)
createModernRow(TabChinhContainer, "↳ Sức mạnh nhảy", 220, nil, true, 100, function(val) jumpPowerValue = val end)
createModernRow(TabChinhContainer, "Vô hạn nhảy", 262, function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
            end
        end)
    else if infJumpConnection then pcall(function() infJumpConnection:Disconnect() end) infJumpConnection = nil end end
    return infJumpEnabled
end, false)
createModernRow(TabChinhContainer, "Xuyên tường", 304, function() noclipEnabled = not noclipEnabled return noclipEnabled end, false)
createModernRow(TabChinhContainer, "Đi bộ trên tường", 346, function()
    waterRunEnabled = not waterRunEnabled
    if waterRunEnabled then startWallRun() else stopWallRun() end
    return waterRunEnabled
end, false)
createModernRow(TabChinhContainer, "Síp Lóc", 388, function()
    sipLocEnabled = not sipLocEnabled
    if sipLocEnabled then startSipLoc() else stopSipLoc() end
    return sipLocEnabled
end, false)

-- CHỌN NGƯỜI + BAY BÁM THEO
local selectTPTargetBtn = Instance.new("TextButton", TabChinhContainer)
selectTPTargetBtn.Size = UDim2.new(1, -10, 0, 32); selectTPTargetBtn.Position = UDim2.new(0, 0, 0, 432)
selectTPTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90); selectTPTargetBtn.Text = "🔎 Chọn người chơi để bay đến: [Chưa chọn]"
selectTPTargetBtn.Font = Enum.Font.SourceSansBold; selectTPTargetBtn.TextSize = 12; selectTPTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", selectTPTargetBtn).CornerRadius = UDim.new(0, 4)
selectTPTargetBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    if #playerList == 0 then selectTPTargetBtn.Text = "🔎 Không có người chơi nào!" return end
    targetPlayer = playerList[currentTargetIndex]
    if targetPlayer then selectTPTargetBtn.Text = "🎯 Đã chọn TP: " .. targetPlayer.Name end
    currentTargetIndex = (currentTargetIndex % #playerList) + 1
end)

createModernRow(TabChinhContainer, "🚀 Bay bám theo người chơi đã chọn", 476, function()
    tpEnabled = not tpEnabled
    return tpEnabled
end, false)

-- ==============================================
-- === TAB FIX LAG ===
-- ==============================================
createModernRow(TabFixLagContainer, "⚡ BẬT / TẮT FIX LAG", 10, function()
    fixLagEnabled = not fixLagEnabled
    if fixLagEnabled then startFixLag() else stopFixLag() end
    return fixLagEnabled
end, false)
local lagRow = Instance.new("Frame", TabFixLagContainer)
lagRow.Size = UDim2.new(1, -10, 0, 46); lagRow.Position = UDim2.new(0, 0, 0, 52); lagRow.BackgroundColor3 = Color3.fromRGB(38, 38, 38); lagRow.BorderSizePixel = 0
Instance.new("UICorner", lagRow).CornerRadius = UDim.new(0, 4)
local lagLbl = Instance.new("TextLabel", lagRow)
lagLbl.Size = UDim2.new(1, -20, 0, 18); lagLbl.Position = UDim2.new(0, 10, 0, 5); lagLbl.BackgroundTransparency = 1
lagLbl.Text = "👇 Chọn mức Fix Lag (chọn trước khi bật)"; lagLbl.TextColor3 = Color3.fromRGB(255, 200, 100); lagLbl.Font = Enum.Font.SourceSansBold; lagLbl.TextSize = 12; lagLbl.TextXAlignment = Enum.TextXAlignment.Left
local lagBtns = {}
local function makeLagBtn(txt, lvl, x, col)
    local b = Instance.new("TextButton", lagRow)
    b.Size = UDim2.new(0, 90, 0, 22); b.Position = UDim2.new(0, x, 0, 20)
    b.BackgroundColor3 = fixLagLevel == lvl and col or Color3.fromRGB(60,60,60)
    b.Text = txt; b.Font = Enum.Font.SourceSansBold; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        fixLagLevel = lvl
        for _, bb in pairs(lagBtns) do bb.BackgroundColor3 = Color3.fromRGB(60,60,60) end
        b.BackgroundColor3 = col
        if fixLagEnabled then applyFixLagLevel(lvl) end
    end)
    table.insert(lagBtns, b)
end
makeLagBtn("🟢 NHẸ", 1, 15, Color3.fromRGB(46, 139, 87))
makeLagBtn("🟡 VỪA", 2, 125, Color3.fromRGB(230, 160, 0))
makeLagBtn("🔴 MẠNH", 3, 235, Color3.fromRGB(200, 40, 40))

-- ==============================================
-- === TAB CHẾ ĐỘ ẢO + HIỆU ỨNG CHÂN ===
-- ==============================================
createModernRow(TabAoContainer, "👻 BẬT / TẮT CHẾ ĐỘ ẢO TỔNG", 10, function()
    local any = ghostSelfEnabled or ghostEnemyEnabled or ghostLightEnabled or trailFire or trailWater or trailRainbow
    if not any then startGhostLoop() ghostSelfEnabled = true return true
    else stopGhostLoop() return false end
end, false)
createModernRow(TabAoContainer, "↳ Ảo Bản Thân", 52, function()
    ghostSelfEnabled = not ghostSelfEnabled
    if not ghostLoop then startGhostLoop() end updateGhostMode()
    return ghostSelfEnabled
end, false)
createModernRow(TabAoContainer, "↳ Ảo Đối Thủ", 94, function()
    ghostEnemyEnabled = not ghostEnemyEnabled
    if not ghostLoop then startGhostLoop() end updateGhostMode()
    return ghostEnemyEnabled
end, false)
createModernRow(TabAoContainer, "↳ Đèn Pin Ảo", 136, function()
    ghostLightEnabled = not ghostLightEnabled
    if not ghostLoop then startGhostLoop() end updateGhostMode()
    return ghostLightEnabled
end, false)

createModernRow(TabAoContainer, "🔥 CHẠY RA LỬA", 180, function()
    if trailFire then clearAllTrails() return false end
    setTrail("Fire") return true
end, false)
createModernRow(TabAoContainer, "💧 CHẠY RA NƯỚC", 224, function()
    if trailWater then clearAllTrails() return false end
    setTrail("Water") return true
end, false)
createModernRow(TabAoContainer, "🌈 CHẠY RA RAINBOW", 268, function()
    if trailRainbow then clearAllTrails() return false end
    setTrail("Rainbow") return true
end, false)

-- ==============================================
-- === TAB HOÀN HÔN ===
-- ==============================================
createModernRow(TabHoanHonContainer, "🌅 BẬT / TẮT HOÀN HÔN TỔNG", 10, function()
    skyEnabled = not skyEnabled
    if skyEnabled then applySkyMode(skyMode) else restoreOriginalSkyFull() end
    if skyEnabled then sunsetEnabled = false Lighting.ClockTime = originalSettings.ClockTime Lighting.OutdoorAmbient = originalSettings.OutdoorAmbient end
    return skyEnabled
end, false)
local skyLbl = Instance.new("TextLabel", TabHoanHonContainer)
skyLbl.Size = UDim2.new(1, -20, 0, 18); skyLbl.Position = UDim2.new(0, 10, 0, 58); skyLbl.BackgroundTransparency = 1
skyLbl.Text = "✨ CHỌN BẦU TRỜI ĐẸP"; skyLbl.TextColor3 = Color3.fromRGB(255, 180, 220); skyLbl.Font = Enum.Font.SourceSansBold; skyLbl.TextSize = 12; skyLbl.TextXAlignment = Enum.TextXAlignment.Left

local skyRow1 = Instance.new("Frame", TabHoanHonContainer)
skyRow1.Size = UDim2.new(1, -10, 0, 42); skyRow1.Position = UDim2.new(0, 0, 0, 82); skyRow1.BackgroundColor3 = Color3.fromRGB(38, 38, 38); skyRow1.BorderSizePixel = 0
Instance.new("UICorner", skyRow1).CornerRadius = UDim.new(0, 4)
local skyBtns = {}
local function makeSkyBtn(txt, mode, x, col, parent)
    local b = Instance.new("TextButton", parent or skyRow1)
    b.Size = UDim2.new(0, 165, 0, 28); b.Position = UDim2.new(0, x, 0, 7)
    b.BackgroundColor3 = skyMode == mode and col or Color3.fromRGB(55,55,55)
    b.Text = txt; b.Font = Enum.Font.SourceSansBold; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        skyMode = mode
        for _, bb in pairs(skyBtns) do bb.BackgroundColor3 = Color3.fromRGB(55,55,55) end
        b.BackgroundColor3 = col
        if skyEnabled then applySkyMode(mode) end
    end)
    table.insert(skyBtns, b)
end
makeSkyBtn("☀️ SÁNG XANH",   "day",    10,  Color3.fromRGB(50, 150, 255))
makeSkyBtn("🌙 ĐÊM TRĂNG",   "night",  185, Color3.fromRGB(40, 60, 160))

local skyRow2 = Instance.new("Frame", TabHoanHonContainer)
skyRow2.Size = UDim2.new(1, -10, 0, 42); skyRow2.Position = UDim2.new(0, 0, 0, 134); skyRow2.BackgroundColor3 = Color3.fromRGB(38, 38, 38); skyRow2.BorderSizePixel = 0
Instance.new("UICorner", skyRow2).CornerRadius = UDim.new(0, 4)
makeSkyBtn("🌇 HOÀNG HÔN",  "sunset", 10,  Color3.fromRGB(255, 90, 35), skyRow2)
makeSkyBtn("💜 BẦU TÍM",    "purple", 185, Color3.fromRGB(160, 70, 230), skyRow2)

local skyRow3 = Instance.new("Frame", TabHoanHonContainer)
skyRow3.Size = UDim2.new(1, -10, 0, 42); skyRow3.Position = UDim2.new(0, 0, 0, 186); skyRow3.BackgroundColor3 = Color3.fromRGB(38, 38, 38); skyRow3.BorderSizePixel = 0
Instance.new("UICorner", skyRow3).CornerRadius = UDim.new(0, 4)
makeSkyBtn("🌌 VŨ TRỤ",     "space",  10,  Color3.fromRGB(20, 10, 60), skyRow3)
makeSkyBtn("🌊 BIỂN XANH",   "ocean",  185, Color3.fromRGB(30, 170, 180), skyRow3)

-- ==============================================
-- === ✅ TAB CÀI ĐẶT + UI QUAN SÁT NGƯỜI CHƠI ===
-- ==============================================
createModernRow(TabCaiDatContainer, "ESP Xem tên người", 10, function() espEnabled = not espEnabled if espEnabled then for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end else removeESP() end return espEnabled end, false)
createModernRow(TabCaiDatContainer, "Bầu trời hoàng hôn", 52, function()
    sunsetEnabled = not sunsetEnabled
    if sunsetEnabled then skyEnabled = false restoreOriginalSkyFull() end
    if sunsetEnabled then Lighting.ClockTime = 17.65; Lighting.OutdoorAmbient = Color3.fromRGB(245, 110, 40)
    else Lighting.ClockTime = originalSettings.ClockTime; Lighting.OutdoorAmbient = originalSettings.OutdoorAmbient end
    return sunsetEnabled
end, false)

local FpsLabel = Instance.new("TextLabel", ScreenGui); FpsLabel.Size = UDim2.new(0, 80, 0, 24); FpsLabel.Position = UDim2.new(0.05, 0, 0.25, 0); FpsLabel.BackgroundColor3 = Color3.fromRGB(40, 35, 45); FpsLabel.TextColor3 = Color3.new(1, 1, 0); FpsLabel.Font = Enum.Font.SourceSansBold; FpsLabel.TextSize = 12; FpsLabel.Visible = false; Instance.new("UICorner", FpsLabel)
createModernRow(TabCaiDatContainer, "Hiển thị FPS", 94, function()
    fpsEnabled = not fpsEnabled; FpsLabel.Visible = fpsEnabled
    if fpsEnabled then
        local lastTime, frameCount = os.clock(), 0
        fpsConnection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1 local currentTime = os.clock()
            if currentTime - lastTime >= 1 then FpsLabel.Text = "FPS: " .. tostring(frameCount) frameCount = 0 lastTime = currentTime end
        end)
    else if fpsConnection then pcall(function() fpsConnection:Disconnect() end) end end
    return fpsEnabled
end, false)

-- ✅ UI CHỨC NĂNG QUAN SÁT (đặt trong Tab Cài Đặt)
local spectateTitle = Instance.new("TextLabel", TabCaiDatContainer)
spectateTitle.Size = UDim2.new(1, -20, 0, 20); spectateTitle.Position = UDim2.new(0, 10, 0, 140)
spectateTitle.BackgroundTransparency = 1; spectateTitle.Text = "🔭 QUAN SÁT NGƯỜI CHƠI"; spectateTitle.TextColor3 = Color3.fromRGB(0, 220, 255); spectateTitle.Font = Enum.Font.GothamBold; spectateTitle.TextSize = 14; spectateTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Nút mở danh sách chọn người
spectateToggleBtn = Instance.new("TextButton", TabCaiDatContainer)
spectateToggleBtn.Size = UDim2.new(1, -10, 0, 36); spectateToggleBtn.Position = UDim2.new(0, 0, 0, 170)
spectateToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
spectateToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spectateToggleBtn.TextSize = 14
spectateToggleBtn.Font = Enum.Font.GothamBold
spectateToggleBtn.Text = "🔭 Mở Danh Sách Người Chơi"
spectateToggleBtn.Parent = TabCaiDatContainer
Instance.new("UICorner", spectateToggleBtn).CornerRadius = UDim.new(0, 8)

-- Danh sách người chơi (ẩn mặc định)
spectateListFrame = Instance.new("ScrollingFrame", ScreenGui)
spectateListFrame.Name = "SpectateList"
spectateListFrame.Size = UDim2.new(0, 210, 0, 300)
spectateListFrame.Position = UDim2.new(0, 20, 0, 160)
spectateListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
spectateListFrame.BackgroundTransparency = 0.1
spectateListFrame.ScrollBarThickness = 4
spectateListFrame.Visible = false
spectateListFrame.Parent = ScreenGui
Instance.new("UICorner", spectateListFrame).CornerRadius = UDim.new(0, 8)

-- Nút THOÁT QUAN SÁT (chỉ hiện khi đang xem)
spectateStopBtn = Instance.new("TextButton", ScreenGui)
spectateStopBtn.Name = "StopSpectate"
spectateStopBtn.Size = UDim2.new(0, 180, 0, 44)
spectateStopBtn.Position = UDim2.new(0.5, -90, 0.88, 0)
spectateStopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
spectateStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spectateStopBtn.TextSize = 15
spectateStopBtn.Font = Enum.Font.GothamBold
spectateStopBtn.Text = "❌ Thoát Quan Sát"
spectateStopBtn.Visible = false
spectateStopBtn.Parent = ScreenGui
Instance.new("UICorner", spectateStopBtn).CornerRadius = UDim.new(0, 10)

-- Sự kiện bật/tắt danh sách
spectateToggleBtn.MouseButton1Click:Connect(function()
    spectateListFrame.Visible = not spectateListFrame.Visible
    if spectateListFrame.Visible then
        spectateToggleBtn.Text = "❌ Đóng Danh Sách"
        spectateToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        updateSpectateList()
    else
        spectateToggleBtn.Text = "🔭 Mở Danh Sách Người Chơi"
        spectateToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    end
end)

-- Sự kiện bấm nút thoát quan sát
spectateStopBtn.MouseButton1Click:Connect(function()
    stopSpectating()
end)

-- Tự động cập nhật danh sách khi có người vào/ra
Players.PlayerAdded:Connect(function()
    if spectateListFrame and spectateListFrame.Visible then updateSpectateList() end
end)
Players.PlayerRemoving:Connect(function(p)
    -- Nếu người đang quan sát rời game thì tự thoát
    if isSpectating and currentSpectateTarget == p then stopSpectating() end
    if spectateListFrame and spectateListFrame.Visible then updateSpectateList() end
end)

-- Nút đổi server
local HopBtn = Instance.new("TextButton", TabCaiDatContainer)
HopBtn.Size = UDim2.new(1, -10, 0, 30); HopBtn.Position = UDim2.new(0, 0, 0, 220); HopBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 150); HopBtn.Text = "🚀 Đổi server ít người nhất"; HopBtn.Font = Enum.Font.SourceSansBold; HopBtn.TextSize = 12; Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0, 4)
HopBtn.MouseButton1Click:Connect(function()
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local success, data = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
	if success and data and data.data then
		for _, server in pairs(data.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer) end)
				break
			end
		end
	end
end)

-- ==============================================
-- === VÒNG LẶP LOGIC CHÍNH (HEARTBEAT) ===
-- ==============================================
RunService.RenderStepped:Connect(function(dt)
    -- ✅ ƯU TIÊN: LOGIC QUAN SÁT NGƯỜI CHƠI
    if isSpectating and currentSpectateTarget then
        local tChar = currentSpectateTarget.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") and tChar:FindFirstChildOfClass("Humanoid") and tChar.Humanoid.Health > 0 then
            local tRoot = tChar.HumanoidRootPart
            -- Camera đặt phía sau lưng, hơi nhìn từ trên xuống
            Camera.CFrame = tRoot.CFrame * CFrame.new(0, 3.5, -14) * CFrame.Angles(math.rad(-10), math.rad(180), 0)
        else
            -- Mục tiêu chết / mất nhân vật → tự thoát
            stopSpectating()
        end
        return -- Bỏ qua các logic aimbot khác khi đang quan sát
    end

    -- Logic bình thường
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid; local root = char:FindFirstChild("HumanoidRootPart")
        if speedEnabled then hum.WalkSpeed = walkSpeedValue else hum.WalkSpeed = 16 end
        if jumpEnabled then hum.JumpPower = jumpPowerValue; hum.UseJumpPower = true else hum.UseJumpPower = false end
        if noclipEnabled then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
        
        -- Bay bám theo người chơi
        if tpEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and root then
            root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 2)
        end
        
        if root then
            if aimbotNearestEnabled then
                local closest, shortestDistance = nil, math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
                        local distance = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then shortestDistance = distance; closest = player end
                    end
                end
                if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
                end
            end

            if aimbotSelectedEnabled and selectedTargetPlayer and selectedTargetPlayer.Character and selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, selectedTargetPlayer.Character.HumanoidRootPart.Position)
            end

            if aimbotAllCycleEnabled then
                cycleTimer = cycleTimer + dt
                if cycleTimer >= 3 then
                    cycleTimer = 0 refreshPlayerList()
                    if #playerList > 0 then cycleTargetIndex = (cycleTargetIndex % #playerList) + 1 end
                end
                local target = playerList[cycleTargetIndex]
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

-- --- VIỀN RAINBOW CHO MENU ---
local stroke = Instance.new("UIStroke")
stroke.Parent = MainFrame stroke.Thickness = 2
local hue = 0
RunService.RenderStepped:Connect(function(dt) hue = (hue + dt * 0.15) % 1 stroke.Color = Color3.fromHSV(hue, 1, 1) end)

-- --- NÚT BẬT TẮT TOÀN BỘ MENU ---
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0); ToggleBtn.Image = "rbxassetid://90661485753344"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke") btnStroke.Thickness = 2 btnStroke.Parent = ToggleBtn
local btnHue = 0
RunService.RenderStepped:Connect(function(dt) btnHue = (btnHue + dt * 0.25) % 1 btnStroke.Color = Color3.fromHSV(btnHue, 1, 1) end)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    -- Ẩn luôn danh sách spectate khi tắt menu
    if not MainFrame.Visible and spectateListFrame then spectateListFrame.Visible = false end
end)
