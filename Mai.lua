-- [[ ZENITH HUB FULL | + AIMBOT MỚI: KHÓA CAM MƯỢT + ESP ĐỎ + BẮN XUYÊN TƯỜNG ]]

-- ==============================================
-- === MÀN HÌNH LOADING ===
-- ==============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local loadGui = Instance.new("ScreenGui") loadGui.ResetOnSpawn = false loadGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local bgLoading = Instance.new("Frame") bgLoading.Size=UDim2.fromScale(1,1) bgLoading.BackgroundColor3=Color3.fromRGB(10,10,10) bgLoading.Parent=loadGui
local textLoading = Instance.new("TextLabel") textLoading.Size=UDim2.new(0,400,0,50) textLoading.Position=UDim2.new(0.5,-200,0.43,-25) textLoading.BackgroundTransparency=1 textLoading.Text="Loading Zenith Hub..." textLoading.TextScaled=true textLoading.Font=Enum.Font.GothamBold textLoading.TextColor3=Color3.new(1,1,1) textLoading.Parent=bgLoading
local barBg=Instance.new("Frame") barBg.Size=UDim2.new(0,280,0,10) barBg.Position=UDim2.new(0.5,-140,0.53,0) barBg.BackgroundColor3=Color3.fromRGB(40,40,40) barBg.Parent=bgLoading Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
local bar=Instance.new("Frame") bar.Size=UDim2.new(0,0,1,0) bar.BackgroundColor3=Color3.fromRGB(0,170,255) bar.Parent=barBg Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
for i=1,100 do bar.Size=UDim2.new(i/100,0,1,0) task.wait(0.01) end loadGui:Destroy()

-- ==============================================
-- === KHỞI TẠO DỊCH VỤ ===
-- ==============================================
local RunService=game:GetService("RunService") local Lighting=game:GetService("Lighting") local HttpService=game:GetService("HttpService") local TeleportService=game:GetService("TeleportService") local UserInputService=game:GetService("UserInputService") local Workspace=game:GetService("Workspace") local Camera=Workspace.CurrentCamera local RenderSettings=settings():GetService("RenderSettings") local TweenService=game:GetService("TweenService")

-- ==============================================
-- === 🎯 AIMBOT MỚI CỦA BẠN — TOÀN BỘ Ở ĐÂY (CHỐNG TRÙNG + SILENT AIM) ===
-- ==============================================
-- Kiểm tra tránh trùng lặp
if _G.CameraLockRunning then _G.CameraLockRunning = false task.wait(0.2) end
_G.CameraLockRunning = true

-- Biến aimbot mới
local isLocked = false
local cameraSpeed = 15
local espEnabled = false
local silentAimEnabled = false
local espCache = {}

-- Hàm xóa / tạo ESP ĐỎ
local function removeESP(player)
    if espCache[player] then for _, obj in pairs(espCache[player]) do if obj then obj:Destroy() end end espCache[player] = nil end
end
local function createESP(player)
    if player == LocalPlayer or not player.Character then return end
    removeESP(player)
    local char = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char highlight.FillColor = Color3.fromRGB(255, 0, 0) highlight.FillTransparency = 0.5 highlight.OutlineColor = Color3.fromRGB(255, 255, 255) highlight.Parent = char
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") billboard.Size = UDim2.new(0, 100, 0, 50) billboard.StudsOffset = Vector3.new(0, 2.5, 0) billboard.AlwaysOnTop = true billboard.Parent = char
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0) textLabel.BackgroundTransparency = 1 textLabel.Text = player.Name textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) textLabel.TextStrokeTransparency = 0 textLabel.TextSize = 14 textLabel.Font = Enum.Font.SourceSansBold textLabel.Parent = billboard
    espCache[player] = {Highlight = highlight, Billboard = billboard}
end
Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

-- Lấy người gần nhất
local function getNearestPlayer()
    local myChar = LocalPlayer.Character if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position local nearestTarget = nil local shortestDistance = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local targetChar = p.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local distance = (targetChar.HumanoidRootPart.Position - myPos).Magnitude
                    if distance < shortestDistance then shortestDistance = distance nearestTarget = targetChar.HumanoidRootPart end
                end
            end
        end
    end
    return nearestTarget
end

-- 💥 HOOK BẮN XUYÊN TƯỜNG / SILENT AIM (ĐÚNG CODE BẠN)
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod() local args = {...}
    if silentAimEnabled and not checkcaller() then
        if method == "Raycast" and self == Workspace then
            local nearest = getNearestPlayer()
            if nearest then local origin = args[1] local direction = (nearest.Position - origin).Unit * 1000 args[2] = direction return oldNameCall(self, unpack(args)) end
        elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
            local nearest = getNearestPlayer()
            if nearest then local origin = args[1].Origin local direction = (nearest.Position - origin).Unit * 1000 args[1] = Ray.new(origin, direction) return oldNameCall(self, unpack(args)) end
        end
    end
    return oldNameCall(self, ...)
end)

-- ==============================================
-- === BIẾN CHỨC NĂNG CŨ — GIỮ NGUYÊN 100% ===
-- ==============================================
local speedEnabled, flyEnabled, espOldEnabled, sunsetEnabled, jumpEnabled, noclipEnabled, infJumpEnabled, fpsEnabled, sipLocEnabled = false, false, false, false, false, false, false, false, false
local walkSpeedValue, jumpPowerValue = 50, 100
local noclipConnection, infJumpConnection, fpsConnection, bv, bg, flyLoop, flyUpdateConnection, sipLocRenderConnection = nil
local speeds = 1 local nowe, tpwalking, waterRunEnabled = false, false, false
local wallRunConnection = nil local originalGravity = workspace.Gravity
local playerList, currentTargetIndex, targetPlayer, tpEnabled = {}, 1, nil, false

-- ✅ QUAN SÁT NGƯỜI CHƠI
local isSpectating, currentSpectateTarget, spectateListFrame, spectateStopBtn, spectateToggleBtn = false, nil, nil, nil, nil
local oldCamSubject, oldCamType = nil, nil

-- ⚡ FIX LAG
local fixLagEnabled, fixLagLevel, fixLagLoop = false, 1, nil
local originalRender = {QualityLevel=RenderSettings.QualityLevel,LightingTechnology=Lighting.Technology,FogEnd=Lighting.FogEnd,FogStart=Lighting.FogStart,Brightness=Lighting.Brightness,GlobalShadows=Lighting.GlobalShadows,EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale,EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale,ExposureCompensation=Lighting.ExposureCompensation}

-- 👻 CHẾ ĐỘ ẢO + HIỆU ỨNG CHÂN
local ghostSelfEnabled, ghostEnemyEnabled, ghostLightEnabled, ghostLoop, ghostSpotLight = false, false, false, nil, nil
local trailFire, trailWater, trailRainbow, rainbowHue = false, false, false, 0
local TRAIL_NAMES = {Fire="AO_TRAIL_FIRE", Water="AO_TRAIL_WATER", Rainbow="AO_TRAIL_RAINBOW"}

-- 🌅 HOÀN HÔN
local skyEnabled, skyMode, skyTween = false, "day", nil
local originalSkyFull = {ClockTime=Lighting.ClockTime,FogColor=Lighting.FogColor,FogEnd=Lighting.FogEnd,FogStart=Lighting.FogStart,OutdoorAmbient=Lighting.OutdoorAmbient,Ambient=Lighting.Ambient,Brightness=Lighting.Brightness,GlobalShadows=Lighting.GlobalShadows,ExposureCompensation=Lighting.ExposureCompensation,ColorShift_Top=Lighting.ColorShift_Top,ColorShift_Bottom=Lighting.ColorShift_Bottom,EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale,EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale,Technology=Lighting.Technology}
local originalSkyObj = nil pcall(function()local s=Lighting:FindFirstChildOfClass("Sky")or Instance.new("Sky")s.Parent=Lighting originalSkyObj={StarCount=s.StarCount,SunAngularSize=s.SunAngularSize,MoonAngularSize=s.MoonAngularSize}end)
local SKY_MODES = {
    day={Name="☀️ SÁNG XANH",ClockTime=14,Brightness=2.3,ExposureCompensation=0.15,Ambient=Color3.fromRGB(180,215,255),OutdoorAmbient=Color3.fromRGB(255,240,210),FogColor=Color3.fromRGB(200,228,255),FogStart=80,FogEnd=700,ColorShift_Top=Color3.fromRGB(100,170,255),ColorShift_Bottom=Color3.fromRGB(255,245,220),StarCount=0,SunAngularSize=12,MoonAngularSize=0,GlobalShadows=true},
    night={Name="🌙 ĐÊM TRĂNG",ClockTime=22.8,Brightness=1.15,ExposureCompensation=-0.1,Ambient=Color3.fromRGB(35,55,115),OutdoorAmbient=Color3.fromRGB(18,35,80),FogColor=Color3.fromRGB(12,22,55),FogStart=50,FogEnd=450,ColorShift_Top=Color3.fromRGB(25,45,135),ColorShift_Bottom=Color3.fromRGB(8,12,35),StarCount=5000,SunAngularSize=0,MoonAngularSize=11,GlobalShadows=true},
    sunset={Name="🌇 HOÀNG HÔN",ClockTime=18.3,Brightness=1.7,ExposureCompensation=0.22,Ambient=Color3.fromRGB(255,135,75),OutdoorAmbient=Color3.fromRGB(255,95,45),FogColor=Color3.fromRGB(255,115,55),FogStart=60,FogEnd=520,ColorShift_Top=Color3.fromRGB(255,70,25),ColorShift_Bottom=Color3.fromRGB(255,175,75),StarCount=300,SunAngularSize=20,MoonAngularSize=0,GlobalShadows=true},
    purple={Name="💜 BẦU TÍM",ClockTime=20.2,Brightness=1.85,ExposureCompensation=0.12,Ambient=Color3.fromRGB(185,120,255),OutdoorAmbient=Color3.fromRGB(205,150,255),FogColor=Color3.fromRGB(155,95,220),FogStart=70,FogEnd=580,ColorShift_Top=Color3.fromRGB(175,70,255),ColorShift_Bottom=Color3.fromRGB(255,175,220),StarCount=1800,SunAngularSize=0,MoonAngularSize=9,GlobalShadows=true},
    space={Name="🌌 VŨ TRỤ",ClockTime=0,Brightness=0.75,ExposureCompensation=-0.35,Ambient=Color3.fromRGB(8,8,28),OutdoorAmbient=Color3.fromRGB(4,4,18),FogColor=Color3.fromRGB(0,0,8),FogStart=250,FogEnd=1400,ColorShift_Top=Color3.fromRGB(18,0,55),ColorShift_Bottom=Color3.fromRGB(0,0,0),StarCount=15000,SunAngularSize=0,MoonAngularSize=0,GlobalShadows=false},
    ocean={Name="🌊 BIỂN XANH",ClockTime=11,Brightness=2.1,ExposureCompensation=0.08,Ambient=Color3.fromRGB(120,220,220),OutdoorAmbient=Color3.fromRGB(160,240,230),FogColor=Color3.fromRGB(140,210,225),FogStart=100,FogEnd=650,ColorShift_Top=Color3.fromRGB(60,180,200),ColorShift_Bottom=Color3.fromRGB(210,250,245),StarCount=0,SunAngularSize=14,MoonAngularSize=0,GlobalShadows=true}
}
local originalSettings = {ClockTime=Lighting.ClockTime,FogColor=Lighting.FogColor,FogEnd=Lighting.FogEnd,OutdoorAmbient=Lighting.OutdoorAmbient}

-- ==============================================
-- === TẤT CẢ HÀM CHỨC NĂNG CŨ — GIỮ NGUYÊN Y HẾT ===
-- ==============================================
local function getTrailLimbs()local c=LocalPlayer.Character if not c then return{}end local t={} for _,n in pairs({"LeftFoot","RightFoot","Left Leg","Right Leg"})do local l=c:FindFirstChild(n) if l and l:IsA("BasePart")then table.insert(t,l)end end if #t==0 then local hrp=c:FindFirstChild("HumanoidRootPart") if hrp then table.insert(t,hrp)end end return t end
local function clearAllTrails()trailFire=false trailWater=false trailRainbow=false local c=LocalPlayer.Character if not c then return end for _,p in ipairs(c:GetDescendants())do if p:IsA("ParticleEmitter")then for _,n in pairs(TRAIL_NAMES)do if p.Name==n then pcall(function()p:Destroy()end)end end end end end
local function createTrail(parent,kind)
    if not parent or parent:FindFirstChild(TRAIL_NAMES[kind])then return end local p=Instance.new("ParticleEmitter")p.Name=TRAIL_NAMES[kind]p.Enabled=true p.Lifetime=NumberRange.new(0.4,0.9)p.Rate=40 p.Speed=NumberRange.new(6,14)p.SpreadAngle=Vector2.new(30,50)p.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(1,0)})p.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(1,1)})p.Acceleration=Vector3.new(0,3,0)p.LockedToPart=true p.VelocityInheritance=0.5
    if kind=="Fire"then p.Texture="rbxassetid://154966922"p.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,100)),ColorSequenceKeypoint.new(0.4,Color3.fromRGB(255,120,30)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(220,40,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(80,0,0))}p.Lifetime=NumberRange.new(0.3,0.75)p.Rate=60 p.Acceleration=Vector3.new(0,12,0)p.Speed=NumberRange.new(8,18)p.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.2),NumberSequenceKeypoint.new(1,0)})
    elseif kind=="Water"then p.Texture="rbxassetid://67235145"p.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(180,240,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(80,180,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,90,200))}p.Lifetime=NumberRange.new(0.45,1.1)p.Rate=55 p.Acceleration=Vector3.new(0,-14,0)p.Speed=NumberRange.new(5,12)p.SpreadAngle=Vector2.new(40,60)
    else p.Texture="rbxassetid://148755873"p.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.2,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,255))}p.Lifetime=NumberRange.new(0.5,1.3)p.Rate=75 p.Acceleration=Vector3.new(0,4,0)p.Speed=NumberRange.new(7,15)p.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.1),NumberSequenceKeypoint.new(1,0)})end
    p.Parent=parent return p
end
local function setTrail(kind)clearAllTrails()if kind=="None"then return end local limbs=getTrailLimbs()for _,l in pairs(limbs)do createTrail(l,kind)end if kind=="Fire"then trailFire=true elseif kind=="Water"then trailWater=true else trailRainbow=true end end
local trailUpdateLoop=RunService.RenderStepped:Connect(function(dt)
    rainbowHue=(rainbowHue+dt*2.2)%1 local c=LocalPlayer.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid")if not h then return end local isMoving=h.MoveDirection.Magnitude>0.12 and h.FloorMaterial~=Enum.Material.Air
    local activeKind=trailFire and"Fire"or trailWater and"Water"or trailRainbow and"Rainbow"or nil if not activeKind then return end
    local limbs=getTrailLimbs()for _,l in pairs(limbs)do if not l:FindFirstChild(TRAIL_NAMES[activeKind])then createTrail(l,activeKind)end end
    for _,p in ipairs(c:GetDescendants())do if p:IsA("ParticleEmitter")then for _,n in pairs(TRAIL_NAMES)do if p.Name==n then p.Enabled=(n==TRAIL_NAMES[activeKind])and isMoving if n==TRAIL_NAMES.Rainbow and p.Enabled then local cs={}for i=0,5 do table.insert(cs,ColorSequenceKeypoint.new(i/5,Color3.fromHSV((rainbowHue+i*0.16)%1,1,1)))end p.Color=ColorSequence.new(cs)end end end end end
end)

local function refreshPlayerList()playerList={}for _,p in ipairs(Players:GetPlayers())do if p~=LocalPlayer then table.insert(playerList,p)end end if currentTargetIndex>#playerList then currentTargetIndex=1 end end
local function applyESP(player)if player==LocalPlayer then return end local function setup(char)local head=char:WaitForChild("Head",5)if head and not head:FindFirstChild("ESP_Billboard")then local billboard=Instance.new("BillboardGui")billboard.Name="ESP_Billboard"billboard.AlwaysOnTop=true billboard.Size=UDim2.new(0,150,0,40)billboard.StudsOffset=Vector3.new(0,2.5,0)billboard.Parent=head local label=Instance.new("TextLabel")label.Size=UDim2.new(1,0,1,0)label.BackgroundTransparency=1 label.Text=player.Name label.TextColor3=Color3.fromRGB(255,255,0)label.Font=Enum.Font.SourceSansBold label.TextSize=14 label.Parent=billboard end end if player.Character then setup(player.Character)end player.CharacterAdded:Connect(setup)end
local function removeESP()for _,player in ipairs(Players:GetPlayers())do if player.Character and player.Character:FindFirstChild("Head")and player.Character.Head:FindFirstChild("ESP_Billboard")then pcall(function()player.Character.Head.ESP_Billboard:Destroy()end)end end end

local function startWallRun()if wallRunConnection then return end workspace.Gravity=0 wallRunConnection=RunService.Heartbeat:Connect(function()local c=LocalPlayer.Character if not c then return end local root=c:FindFirstChild("HumanoidRootPart")local hum=c:FindFirstChildOfClass("Humanoid")if not root or not hum then return end local raycastParams=RaycastParams.new()raycastParams.FilterDescendantsInstances={c}raycastParams.FilterType=Enum.RaycastFilterType.Exclude local rayResult=workspace:Raycast(root.Position,-root.CFrame.UpVector*3,raycastParams)if rayResult then local normal=rayResult.Normal local upVector=normal local lookVector=root.CFrame.LookVector local rightVector=lookVector:Cross(upVector).Unit lookVector=upVector:Cross(rightVector).Unit root.CFrame=CFrame.new(root.Position,rightVector,upVector)hum.AutoRotate=false else hum.AutoRotate=true end if hum.MoveDirection.Magnitude>0 then local moveDir=hum.MoveDirection local worldMove=(root.CFrame.RightVector*moveDir.X+root.CFrame.UpVector*-moveDir.Z).Unit root.Velocity=worldMove*hum.WalkSpeed+root.CFrame.UpVector*0.1 else root.Velocity=root.CFrame.UpVector*0.1 end end)end
local function stopWallRun()if wallRunConnection then wallRunConnection:Disconnect()wallRunConnection=nil end workspace.Gravity=originalGravity local c=LocalPlayer.Character if c then local hum=c:FindFirstChildOfClass("Humanoid")local root=c:FindFirstChild("HumanoidRootPart")if hum then hum.AutoRotate=true end if root then root.CFrame=CFrame.new(root.Position,Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z),Vector3.new(0,1,0))end end end

local dot=Instance.new("Part")dot.Shape=Enum.PartType.Ball dot.Size=Vector3.new(0.2,0.2,0.2)dot.Material=Enum.Material.Neon dot.Color=Color3.new(1,1,1)dot.Anchored=true dot.CanCollide=false dot.Transparency=1 dot.Parent=workspace
local function updateSipLoc()local c=LocalPlayer.Character if not c then return end local hrp=c:FindFirstChild("HumanoidRootPart")local hum=c:FindFirstChildOfClass("Humanoid")if not hrp or not hum then return end if sipLocEnabled then hum.AutoRotate=false local look=Camera.CFrame.LookVector hrp.CFrame=CFrame.new(hrp.Position,hrp.Position+Vector3.new(look.X,0,look.Z))dot.Transparency=0 dot.Position=hrp.Position+Vector3.new(0,2,-1)else hum.AutoRotate=true dot.Transparency=1 end end
local function startSipLoc()if sipLocRenderConnection then return end sipLocRenderConnection=RunService.RenderStepped:Connect(updateSipLoc)end
local function stopSipLoc()if sipLocRenderConnection then sipLocRenderConnection:Disconnect()sipLocRenderConnection=nil end local c=LocalPlayer.Character if c then local hum=c:FindFirstChildOfClass("Humanoid")if hum then hum.AutoRotate=true end end dot.Transparency=1 end

local function applyFixLagLevel(level)RenderSettings.QualityLevel=originalRender.QualityLevel Lighting.Technology=originalRender.LightingTechnology Lighting.FogEnd=originalRender.FogEnd Lighting.FogStart=originalRender.FogStart Lighting.Brightness=originalRender.Brightness Lighting.GlobalShadows=originalRender.GlobalShadows Lighting.EnvironmentSpecularScale=originalRender.EnvironmentSpecularScale Lighting.EnvironmentDiffuseScale=originalRender.EnvironmentDiffuseScale Lighting.ExposureCompensation=originalRender.ExposureCompensation if level>=1 then RenderSettings.QualityLevel=Enum.QualityLevel.Level03 Lighting.GlobalShadows=false end if level>=2 then Lighting.Technology=Enum.Technology.Compatibility Lighting.EnvironmentSpecularScale=0 Lighting.EnvironmentDiffuseScale=0.1 Lighting.ExposureCompensation=0.3 Lighting.FogEnd=math.min(Lighting.FogEnd,400)end if level>=3 then Lighting.FogEnd=150 Lighting.FogStart=80 Lighting.Brightness=1.2 RenderSettings.QualityLevel=Enum.QualityLevel.Level01 task.spawn(function()for _,v in ipairs(workspace:GetDescendants())do if v:IsA("Fire")or v:IsA("Smoke")or v:IsA("Sparkles")or v:IsA("ParticleEmitter")or v:IsA("Trail")then pcall(function()v.Enabled=false end)end end end)end end
local function startFixLag()if fixLagLoop then return end applyFixLagLevel(fixLagLevel)fixLagLoop=RunService.Heartbeat:Connect(function()if not fixLagEnabled then return end if fixLagLevel>=1 then Lighting.GlobalShadows=false end if fixLagLevel>=3 then pcall(function()for _,v in ipairs(workspace:GetDescendants())do if v:IsA("BasePart")and not v:IsDescendantOf(LocalPlayer.Character or workspace)then local dist=(v.Position-Camera.CFrame.Position).Magnitude if dist>200 then v.LocalTransparencyModifier=0.8 end end end end)end end)end
local function stopFixLag()if fixLagLoop then fixLagLoop:Disconnect()fixLagLoop=nil end RenderSettings.QualityLevel=originalRender.QualityLevel Lighting.Technology=originalRender.LightingTechnology Lighting.FogEnd=originalRender.FogEnd Lighting.FogStart=originalRender.FogStart Lighting.Brightness=originalRender.Brightness Lighting.GlobalShadows=originalRender.GlobalShadows Lighting.EnvironmentSpecularScale=originalRender.EnvironmentSpecularScale Lighting.EnvironmentDiffuseScale=originalRender.EnvironmentDiffuseScale Lighting.ExposureCompensation=originalRender.ExposureCompensation pcall(function()for _,v in ipairs(workspace:GetDescendants())do if v:IsA("BasePart")then v.LocalTransparencyModifier=0 end if v:IsA("Fire")or v:IsA("Smoke")or v:IsA("Sparkles")or v:IsA("ParticleEmitter")or v:IsA("Trail")then v.Enabled=true end end end)end

local function updateGhostMode()if ghostSelfEnabled and LocalPlayer.Character then for _,part in ipairs(LocalPlayer.Character:GetDescendants())do if part:IsA("BasePart")or part:IsA("Decal")then part.LocalTransparencyModifier=0.7 end end elseif not ghostSelfEnabled and LocalPlayer.Character then for _,part in ipairs(LocalPlayer.Character:GetDescendants())do if part:IsA("BasePart")or part:IsA("Decal")then part.LocalTransparencyModifier=0 end end end if ghostEnemyEnabled then for _,plr in ipairs(Players:GetPlayers())do if plr~=LocalPlayer and plr.Character then for _,part in ipairs(plr.Character:GetDescendants())do if part:IsA("BasePart")then part.LocalTransparencyModifier=0.6 end end end end else for _,plr in ipairs(Players:GetPlayers())do if plr~=LocalPlayer and plr.Character then for _,part in ipairs(plr.Character:GetDescendants())do if part:IsA("BasePart")then part.LocalTransparencyModifier=0 end end end end end if ghostLightEnabled then if not ghostSpotLight then ghostSpotLight=Instance.new("SpotLight")ghostSpotLight.Name="GhostFlashLight"ghostSpotLight.Brightness=3 ghostSpotLight.Range=60 ghostSpotLight.Angle=45 ghostSpotLight.Color=Color3.fromRGB(255,255,240)ghostSpotLight.Parent=Camera end ghostSpotLight.Enabled=true else if ghostSpotLight then ghostSpotLight.Enabled=false end end end
local function startGhostLoop()if ghostLoop then return end ghostLoop=RunService.RenderStepped:Connect(updateGhostMode)end
local function stopGhostLoop()if ghostLoop then ghostLoop:Disconnect()ghostLoop=nil end ghostSelfEnabled=false ghostEnemyEnabled=false ghostLightEnabled=false updateGhostMode()if ghostSpotLight then ghostSpotLight:Destroy()ghostSpotLight=nil end clearAllTrails()end

local function applySkyMode(mode)if skyTween then pcall(function()skyTween:Cancel()end)skyTween=nil end local data=SKY_MODES[mode]if not data then return end skyMode=mode local tweenInfo=TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)local goal={}for k,v in pairs(data)do if k~="Name"and k~="StarCount"and k~="SunAngularSize"and k~="MoonAngularSize"then goal[k]=v end end goal.GlobalShadows=data.GlobalShadows skyTween=TweenService:Create(Lighting,tweenInfo,goal)pcall(function()skyTween:Play()end)pcall(function()local s=Lighting:FindFirstChildOfClass("Sky")or Instance.new("Sky")s.Parent=Lighting s.StarCount=data.StarCount s.SunAngularSize=data.SunAngularSize s.MoonAngularSize=data.MoonAngularSize end)end
local function restoreOriginalSkyFull()if skyTween then pcall(function()skyTween:Cancel()end)skyTween=nil end local tweenInfo=TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)local goal={}for k,v in pairs(originalSkyFull)do if k~="Technology"then goal[k]=v end end pcall(function()TweenService:Create(Lighting,tweenInfo,goal):Play()end)Lighting.Technology=originalSkyFull.Technology pcall(function()local s=Lighting:FindFirstChildOfClass("Sky")if s and originalSkyObj then for k,v in pairs(originalSkyObj)do s[k]=v end end end)end

-- ✅ HÀM QUAN SÁT NGƯỜI CHƠI
local function updateSpectateList()if not spectateListFrame then return end for _,c in ipairs(spectateListFrame:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end local count=0 for _,p in ipairs(Players:GetPlayers())do if p~=LocalPlayer then count+=1 local pb=Instance.new("TextButton")pb.Size=UDim2.new(1,-10,0,35)pb.Position=UDim2.new(0,5,0,(count-1)*40+5)pb.BackgroundColor3=Color3.fromRGB(50,50,50)pb.TextColor3=Color3.new(1,1,1)pb.TextSize=14 pb.Font=Enum.Font.Gotham pb.Text=p.Name pb.Parent=spectateListFrame Instance.new("UICorner",pb).CornerRadius=UDim.new(0,6)pb.MouseButton1Click:Connect(function()if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart")then return end oldCamType=Camera.CameraType oldCamSubject=Camera.CameraSubject isSpectating=true currentSpectateTarget=p if spectateListFrame then spectateListFrame.Visible=false end if spectateStopBtn then spectateStopBtn.Visible=true end pcall(function()Camera.CameraType=Enum.CameraType.Scriptable end)end)end end spectateListFrame.CanvasSize=UDim2.new(0,0,0,math.max(280,count*40+10))end
local function stopSpectating()isSpectating=false currentSpectateTarget=nil if spectateStopBtn then spectateStopBtn.Visible=false end pcall(function()Camera.CameraType=oldCamType or Enum.CameraType.Custom local mc=LocalPlayer.Character if mc then local hum=mc:FindFirstChildOfClass("Humanoid")if hum then Camera.CameraSubject=hum end end end)oldCamType=nil oldCamSubject=nil end

-- ==============================================
-- === GIAO DIỆN CHÍNH — GIỮ NGUYÊN ===
-- ==============================================
local ScreenGui=Instance.new("ScreenGui")ScreenGui.Name="ZenithHub_Fluent"ScreenGui.ResetOnSpawn=false ScreenGui.Parent=LocalPlayer:WaitForChild("PlayerGui")
local MainFrame=Instance.new("Frame")MainFrame.Size=UDim2.new(0,520,0,395)MainFrame.Position=UDim2.new(0.5,-260,0.5,-197)MainFrame.BackgroundColor3=Color3.fromRGB(28,28,28)MainFrame.BorderSizePixel=0 MainFrame.Active=true MainFrame.Parent=ScreenGui Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,8)
local TopBar=Instance.new("Frame")TopBar.Size=UDim2.new(1,0,0,32)TopBar.BackgroundColor3=Color3.fromRGB(35,35,35)TopBar.BorderSizePixel=0 TopBar.Parent=MainFrame Instance.new("UICorner",TopBar).CornerRadius=UDim.new(0,8)
local dragging,dragStart,startPos=false,nil,nil
TopBar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=MainFrame.Position i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dragging=false end end)end end)
UserInputService.InputChanged:Connect(function(i)if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dragStart MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)end end)
local Title=Instance.new("TextLabel")Title.Size=UDim2.new(1,-100,1,0)Title.Position=UDim2.new(0,12,0,0)Title.BackgroundTransparency=1 Title.Text="ZENITH HUB - FULL EDITION"Title.TextColor3=Color3.new(1,1,1)Title.Font=Enum.Font.SourceSansBold Title.TextSize=14 Title.TextXAlignment=Enum.TextXAlignment.Left Title.Parent=TopBar
RunService.RenderStepped:Connect(function()Title.TextColor3=Color3.fromHSV((os.clock()%5)/5,1,1)end)
local SideBar=Instance.new("Frame")SideBar.Size=UDim2.new(0,130,1,-32)SideBar.Position=UDim2.new(0,0,0,32)SideBar.BackgroundColor3=Color3.fromRGB(32,32,32)SideBar.BorderSizePixel=0 SideBar.Parent=MainFrame
local ContentFrame=Instance.new("Frame")ContentFrame.Size=UDim2.new(1,-140,1,-42)ContentFrame.Position=UDim2.new(0,135,0,37)ContentFrame.BackgroundTransparency=1 ContentFrame.Parent=MainFrame

-- 6 TAB
local TabChinh=Instance.new("ScrollingFrame",ContentFrame)TabChinh.Size=UDim2.new(1,0,1,0)TabChinh.BackgroundTransparency=1 TabChinh.ScrollBarThickness=2 TabChinh.CanvasSize=UDim2.new(0,0,0,600)
local TabAimbot=Instance.new("ScrollingFrame",ContentFrame)TabAimbot.Size=UDim2.new(1,0,1,0)TabAimbot.BackgroundTransparency=1 TabAimbot.ScrollBarThickness=2 TabAimbot.CanvasSize=UDim2.new(0,0,0,550)TabAimbot.Visible=false
local TabFixLag=Instance.new("ScrollingFrame",ContentFrame)TabFixLag.Size=UDim2.new(1,0,1,0)TabFixLag.BackgroundTransparency=1 TabFixLag.ScrollBarThickness=2 TabFixLag.CanvasSize=UDim2.new(0,0,0,520)TabFixLag.Visible=false
local TabAo=Instance.new("ScrollingFrame",ContentFrame)TabAo.Size=UDim2.new(1,0,1,0)TabAo.BackgroundTransparency=1 TabAo.ScrollBarThickness=2 TabAo.CanvasSize=UDim2.new(0,0,0,560)TabAo.Visible=false
local TabHoanHon=Instance.new("ScrollingFrame",ContentFrame)TabHoanHon.Size=UDim2.new(1,0,1,0)TabHoanHon.BackgroundTransparency=1 TabHoanHon.ScrollBarThickness=2 TabHoanHon.CanvasSize=UDim2.new(0,0,0,620)TabHoanHon.Visible=false
local TabCaiDat=Instance.new("ScrollingFrame",ContentFrame)TabCaiDat.Size=UDim2.new(1,0,1,0)TabCaiDat.BackgroundTransparency=1 TabCaiDat.ScrollBarThickness=2 TabCaiDat.CanvasSize=UDim2.new(0,0,0,750)TabCaiDat.Visible=false
local AllTabs={TabChinh,TabAimbot,TabFixLag,TabAo,TabHoanHon,TabCaiDat}

local function createTabBtn(text,y)local b=Instance.new("TextButton",SideBar)b.Size=UDim2.new(1,-10,0,28)b.Position=UDim2.new(0,5,0,y)b.BackgroundColor3=Color3.fromRGB(38,38,38)b.Text=text b.TextColor3=Color3.fromRGB(180,180,180)b.Font=Enum.Font.SourceSansBold b.TextSize=12 Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)return b end
local B1=createTabBtn("🏠 Chính",8)local B2=createTabBtn("🎯 Aimbot Cam",40)local B3=createTabBtn("⚡ Fix Lag",72)local B4=createTabBtn("👻 Chế Độ Ảo",104)local B5=createTabBtn("🌅 Hoàn Hôn",136)local B6=createTabBtn("⚙️ Cài Đặt",168)
B1.BackgroundColor3=Color3.fromRGB(45,45,45)B1.TextColor3=Color3.new(1,1,1)
local AllBtns={B1,B2,B3,B4,B5,B6}
local function openTab(btn,tab)for _,t in pairs(AllTabs)do t.Visible=false end for _,b in pairs(AllBtns)do b.BackgroundColor3=Color3.fromRGB(38,38,38)b.TextColor3=Color3.fromRGB(180,180,180)end tab.Visible=true btn.BackgroundColor3=Color3.fromRGB(45,45,45)btn.TextColor3=Color3.new(1,1,1)end
B1.MouseButton1Click:Connect(function()openTab(B1,TabChinh)end)B2.MouseButton1Click:Connect(function()openTab(B2,TabAimbot)end)B3.MouseButton1Click:Connect(function()openTab(B3,TabFixLag)end)B4.MouseButton1Click:Connect(function()openTab(B4,TabAo)end)B5.MouseButton1Click:Connect(function()openTab(B5,TabHoanHon)end)B6.MouseButton1Click:Connect(function()openTab(B6,TabCaiDat)end)

local function row(par,txt,y,cb,isSl,def,cbSl)
    local rf=Instance.new("Frame",par)rf.Size=UDim2.new(1,-10,0,38)rf.Position=UDim2.new(0,0,0,y)rf.BackgroundColor3=Color3.fromRGB(38,38,38)Instance.new("UICorner",rf).CornerRadius=UDim.new(0,4)
    local lb=Instance.new("TextLabel",rf)lb.Size=UDim2.new(0.6,0,1,0)lb.Position=UDim2.new(0,10,0,0)lb.BackgroundTransparency=1 lb.Text=txt lb.TextColor3=Color3.fromRGB(210,210,210)lb.Font=Enum.Font.SourceSans lb.TextSize=13 lb.TextXAlignment=Enum.TextXAlignment.Left
    if not isSl then
        local tb=Instance.new("TextButton",rf)tb.Size=UDim2.new(0,70,0,22)tb.Position=UDim2.new(1,-80,0.5,-11)tb.BackgroundColor3=Color3.fromRGB(55,55,55)tb.Text="TẮT"tb.TextColor3=Color3.fromRGB(180,180,180)tb.Font=Enum.Font.SourceSansBold tb.TextSize=11 Instance.new("UICorner",tb).CornerRadius=UDim.new(0,4)
        tb.MouseButton1Click:Connect(function()local ns=cb(tb)if ns then tb.BackgroundColor3=Color3.fromRGB(0,150,100)tb.Text="BẬT"tb.TextColor3=Color3.new(1,1,1)else tb.BackgroundColor3=Color3.fromRGB(55,55,55)tb.Text="TẮT"tb.TextColor3=Color3.fromRGB(180,180,180)end end)
    else
        local bx=Instance.new("TextBox",rf)bx.Size=UDim2.new(0,50,0,22)bx.Position=UDim2.new(1,-60,0.5,-11)bx.BackgroundColor3=Color3.fromRGB(28,28,28)bx.Text=tostring(def)bx.TextColor3=Color3.fromRGB(0,180,255)bx.Font=Enum.Font.SourceSansBold bx.TextSize=12 Instance.new("UICorner",bx).CornerRadius=UDim.new(0,4)
        bx.FocusLost:Connect(function()local v=tonumber(bx.Text)if v then cbSl(v)else bx.Text=tostring(def)end end)
    end
end
local function note(p,t,y,c)local l=Instance.new("TextLabel",p)l.Size=UDim2.new(1,-20,0,18)l.Position=UDim2.new(0,10,0,y)l.BackgroundTransparency=1 l.Text=t l.TextColor3=c or Color3.fromRGB(180,180,180)l.Font=Enum.Font.SourceSans l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left end

-- ==============================================
-- === 🎯 TAB AIMBOT MỚI — TOÀN BỘ NÚT THEO CODE BẠN ===
-- ==============================================
row(TabAimbot,"🎯 BẬT HỆ THỐNG AIMBOT",10,function()
    if _G.CameraLockRunning then _G.CameraLockRunning=false task.wait(0.2) return false
    else _G.CameraLockRunning=true return true end
end,false)

row(TabAimbot,"🔒 KHÓA CAM MƯỢT (Lerp)",52,function()
    if not _G.CameraLockRunning then return false end
    isLocked=not isLocked return isLocked
end,false)

row(TabAimbot,"🔴 HIỆN ESP ĐỎ (Highlight)",94,function()
    if not _G.CameraLockRunning then return false end
    espEnabled=not espEnabled
    if espEnabled then for _,p in ipairs(Players:GetPlayers())do if p~=LocalPlayer then createESP(p)end end
    else for _,p in ipairs(Players:GetPlayers())do removeESP(p)end end
    return espEnabled
end,false)

row(TabAimbot,"💥 BẮN XUYÊN TƯỜNG / Silent Aim",136,function()
    if not _G.CameraLockRunning then return false end
    silentAimEnabled=not silentAimEnabled return silentAimEnabled
end,false)

row(TabAimbot,"⚙️ TỐC ĐỘ XOAY CAM",178,nil,true,15,function(v)if v>0 then cameraSpeed=v end end)

note(TabAimbot,"📝 HƯỚNG DẪN SỬ DỤNG:",225,Color3.fromRGB(0,220,255))
note(TabAimbot,"1️⃣ Bước 1: BẬT \"Hệ thống Aimbot\" đầu tiên",250)
note(TabAimbot,"2️⃣ Khóa Cam = tự nhìn người gần nhất MƯỢT NHẤT",275)
note(TabAimbot,"3️⃣ ESP Đỏ = hiện khung đỏ toàn bộ người chơi",300)
note(TabAimbot,"4️⃣ 💥 Bắn xuyên tường = đạn tự cong vào người địch",325,Color3.fromRGB(255,100,100))
note(TabAimbot,"5️⃣ Tốc độ 10-20 chuẩn, 50+ = khóa tức thì",350,Color3.fromRGB(255,220,100))

-- ==============================================
-- === 🏠 TAB CHÍNH — GIỮ NGUYÊN 100% ===
-- ==============================================
row(TabChinh,"Chạy Nhanh",10,function()speedEnabled=not speedEnabled return speedEnabled end,false)
row(TabChinh,"↳ Tốc độ chạy",52,nil,true,50,function(v)walkSpeedValue=v end)
row(TabChinh,"Bay",94,function(btn)
    flyEnabled=not flyEnabled
    if flyEnabled then
        nowe=true local chr=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()local hum=chr:FindFirstChildWhichIsA("Humanoid")tpwalking=false
        for i=1,speeds do task.spawn(function()local hb=RunService.Heartbeat tpwalking=true while tpwalking and hb:Wait()and chr and hum and hum.Parent do if hum.MoveDirection.Magnitude>0 then chr:TranslateBy(hum.MoveDirection)end end end)end
        chr.Animate.Disabled=true local Hum=chr:FindFirstChildOfClass("Humanoid")or chr:FindFirstChildOfClass("AnimationController")pcall(function()for _,v in next,Hum:GetPlayingAnimationTracks()do v:AdjustSpeed(0)end end)
        for _,s in ipairs(Enum.HumanoidStateType:GetEnumItems())do pcall(function()hum:SetStateEnabled(s,false)end)end hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)pcall(function()hum:ChangeState(Enum.HumanoidStateType.Swimming)end)
        flyLoop=task.spawn(function()local bodyPart=hum.RigType==Enum.HumanoidRigType.R6 and chr:WaitForChild("Torso")or chr:WaitForChild("UpperTorso")bg=Instance.new("BodyGyro",bodyPart)bg.P=9e4 bg.MaxTorque=Vector3.new(9e9,9e9,9e9)bv=Instance.new("BodyVelocity",bodyPart)bv.Velocity=Vector3.new(0,0.1,0)bv.MaxForce=Vector3.new(9e9,9e9,9e9)hum.PlatformStand=true flyUpdateConnection=RunService.RenderStepped:Connect(function()if not bg or not bodyPart then return end local cl=Camera.CFrame.LookVector bg.CFrame=CFrame.new(bodyPart.Position,bodyPart.Position+Vector3.new(cl.X,cl.Y,cl.Z))end)end)
    else
        nowe=false tpwalking=false if flyUpdateConnection then pcall(function()flyUpdateConnection:Disconnect()end)flyUpdateConnection=nil end
        local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then for _,s in ipairs(Enum.HumanoidStateType:GetEnumItems())do pcall(function()hum:SetStateEnabled(s,true)end)end pcall(function()hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)end)hum.PlatformStand=false LocalPlayer.Character.Animate.Disabled=false end
        if flyLoop then pcall(function()task.cancel(flyLoop)end)flyLoop=nil end if bv then pcall(function()bv:Destroy()end)bv=nil end if bg then pcall(function()bg:Destroy()end)bg=nil end
    end
    return flyEnabled
end,false)
local fsr=Instance.new("Frame",TabChinh)fsr.Size=UDim2.new(1,-10,0,38)fsr.Position=UDim2.new(0,0,0,136)fsr.BackgroundColor3=Color3.fromRGB(38,38,38)Instance.new("UICorner",fsr).CornerRadius=UDim.new(0,4)
local fl=Instance.new("TextLabel",fsr)fl.Size=UDim2.new(0.6,0,1,0)fl.Position=UDim2.new(0,10,0,0)fl.BackgroundTransparency=1 fl.Text="↳ Tốc độ bay"fl.TextColor3=Color3.fromRGB(210,210,210)fl.Font=Enum.Font.SourceSans fl.TextSize=13
local fp=Instance.new("TextButton",fsr)fp.Size=UDim2.new(0,22,0,22)fp.Position=UDim2.new(1,-80,0.5,-11)fp.BackgroundColor3=Color3.fromRGB(133,145,255)fp.Text="+"fp.Font=Enum.Font.SourceSansBold fp.TextSize=14 Instance.new("UICorner",fp).CornerRadius=UDim.new(0,4)
local fd=Instance.new("TextLabel",fsr)fd.Size=UDim2.new(0,32,0,22)fd.Position=UDim2.new(1,-55,0.5,-11)fd.BackgroundColor3=Color3.fromRGB(255,85,0)fd.Text=tostring(speeds)fd.Font=Enum.Font.SourceSansBold fd.TextSize=12 fd.TextXAlignment=Enum.TextXAlignment.Center fd.TextYAlignment=Enum.TextYAlignment.Center Instance.new("UICorner",fd).CornerRadius=UDim.new(0,4)
local fm=Instance.new("TextButton",fsr)fm.Size=UDim2.new(0,22,0,22)fm.Position=UDim2.new(1,-20,0.5,-11)fm.BackgroundColor3=Color3.fromRGB(123,255,247)fm.Text="-"fm.Font=Enum.Font.SourceSansBold fm.TextSize=14 Instance.new("UICorner",fm).CornerRadius=UDim.new(0,4)
fp.MouseButton1Down:Connect(function()speeds+=1 fd.Text=tostring(speeds)end)fm.MouseButton1Down:Connect(function()if speeds>1 then speeds-=1 fd.Text=tostring(speeds)end end)
row(TabChinh,"Nhảy Cao",178,function()jumpEnabled=not jumpEnabled return jumpEnabled end,false)
row(TabChinh,"↳ Lực nhảy",220,nil,true,100,function(v)jumpPowerValue=v end)
row(TabChinh,"Vô hạn nhảy",262,function()infJumpEnabled=not infJumpEnabled if infJumpEnabled then infJumpConnection=UserInputService.JumpRequest:Connect(function()if infJumpEnabled and LocalPlayer.Character then local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")if h then pcall(function()h:ChangeState(Enum.HumanoidStateType.Jumping)end)end end end)else if infJumpConnection then pcall(function()infJumpConnection:Disconnect()end)infJumpConnection=nil end end return infJumpEnabled end,false)
row(TabChinh,"Xuyên tường",304,function()noclipEnabled=not noclipEnabled return noclipEnabled end,false)
row(TabChinh,"Đi bộ trên tường",346,function()waterRunEnabled=not waterRunEnabled if waterRunEnabled then startWallRun()else stopWallRun()end return waterRunEnabled end,false)
row(TabChinh,"Síp Lóc",388,function()sipLocEnabled=not sipLocEnabled if sipLocEnabled then startSipLoc()else stopSipLoc()end return sipLocEnabled end,false)
local selTP=Instance.new("TextButton",TabChinh)selTP.Size=UDim2.new(1,-10,0,32)selTP.Position=UDim2.new(0,0,0,432)selTP.BackgroundColor3=Color3.fromRGB(60,60,90)selTP.Text="🔎 Chọn người chơi để bay đến: [Chưa chọn]"selTP.Font=Enum.Font.SourceSansBold selTP.TextSize=12 selTP.TextColor3=Color3.new(1,1,1)Instance.new("UICorner",selTP).CornerRadius=UDim.new(0,4)
selTP.MouseButton1Click:Connect(function()refreshPlayerList()if #playerList==0 then selTP.Text="👤 Không có người chơi!"return end targetPlayer=playerList[currentTargetIndex]if targetPlayer then selTP.Text="🎯 Đã chọn: "..targetPlayer.Name end currentTargetIndex=currentTargetIndex%#playerList+1 end)
row(TabChinh,"🚀 Bay bám theo người đã chọn",476,function()tpEnabled=not tpEnabled return tpEnabled end,false)

-- ==============================================
-- === ⚡ TAB FIX LAG — GIỮ NGUYÊN ===
-- ==============================================
row(TabFixLag,"⚡ BẬT / TẮT FIX LAG",10,function()fixLagEnabled=not fixLagEnabled if fixLagEnabled then startFixLag()else stopFixLag()end return fixLagEnabled end,false)
local lr=Instance.new("Frame",TabFixLag)lr.Size=UDim2.new(1,-10,0,46)lr.Position=UDim2.new(0,0,0,52)lr.BackgroundColor3=Color3.fromRGB(38,38,38)Instance.new("UICorner",lr).CornerRadius=UDim.new(0,4)
local ll=Instance.new("TextLabel",lr)ll.Size=UDim2.new(1,-20,0,18)ll.Position=UDim2.new(0,10,0,5)ll.BackgroundTransparency=1 ll.Text="👇 Chọn mức (chọn trước khi bật)"ll.TextColor3=Color3.fromRGB(255,200,100)ll.Font=Enum.Font.SourceSansBold ll.TextSize=12
local lbs={}
local function mklb(txt,l,x,col)local b=Instance.new("TextButton",lr)b.Size=UDim2.new(0,90,0,22)b.Position=UDim2.new(0,x,0,20)b.BackgroundColor3=fixLagLevel==l and col or Color3.fromRGB(60,60,60)b.Text=txt b.Font=Enum.Font.SourceSansBold b.TextSize=12 Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)b.MouseButton1Click:Connect(function()fixLagLevel=l for _,bb in pairs(lbs)do bb.BackgroundColor3=Color3.fromRGB(60,60,60)end b.BackgroundColor3=col if fixLagEnabled then applyFixLagLevel(l)end end)table.insert(lbs,b)end
mklb("🟢 NHẸ",1,15,Color3.fromRGB(46,139,87))mklb("🟡 VỪA",2,125,Color3.fromRGB(230,160,0))mklb("🔴 MẠNH",3,235,Color3.fromRGB(200,40,40))

-- ==============================================
-- === 👻 TAB CHẾ ĐỘ ẢO — GIỮ NGUYÊN ===
-- ==============================================
row(TabAo,"👻 BẬT / TẮT CHẾ ĐỘ ẢO TỔNG",10,function()local any=ghostSelfEnabled or ghostEnemyEnabled or ghostLightEnabled or trailFire or trailWater or trailRainbow if not any then startGhostLoop()ghostSelfEnabled=true return true else stopGhostLoop()return false end end,false)
row(TabAo,"↳ Ảo Bản Thân",52,function()ghostSelfEnabled=not ghostSelfEnabled if not ghostLoop then startGhostLoop()end updateGhostMode()return ghostSelfEnabled end,false)
row(TabAo,"↳ Ảo Đối Thủ",94,function()ghostEnemyEnabled=not ghostEnemyEnabled if not ghostLoop then startGhostLoop()end updateGhostMode()return ghostEnemyEnabled end,false)
row(TabAo,"↳ Đèn Pin Ảo",136,function()ghostLightEnabled=not ghostLightEnabled if not ghostLoop then startGhostLoop()end updateGhostMode()return ghostLightEnabled end,false)
row(TabAo,"🔥 Chân Lửa",180,function()if trailFire then clearAllTrails()return false end setTrail("Fire")return true end,false)
row(TabAo,"💧 Chân Nước",224,function()if trailWater then clearAllTrails()return false end setTrail("Water")return true end,false)
row(TabAo,"🌈 Chân Cầu Vồng",268,function()if trailRainbow then clearAllTrails()return false end setTrail("Rainbow")return true end,false)

-- ==============================================
-- === 🌅 TAB HOÀN HÔN — GIỮ NGUYÊN ===
-- ==============================================
row(TabHoanHon,"🌅 BẬT / TẮT HOÀN HÔN TỔNG",10,function()skyEnabled=not skyEnabled if skyEnabled then applySkyMode(skyMode)else restoreOriginalSkyFull()end if skyEnabled then sunsetEnabled=false Lighting.ClockTime=originalSettings.ClockTime Lighting.OutdoorAmbient=originalSettings.OutdoorAmbient end return skyEnabled end,false)
local sl5=Instance.new("TextLabel",TabHoanHon)sl5.Size=UDim2.new(1,-20,0,18)sl5.Position=UDim2.new(0,10,0,58)sl5.BackgroundTransparency=1 sl5.Text="✨ CHỌN BẦU TRỜI"sl5.TextColor3=Color3.fromRGB(255,180,220)sl5.Font=Enum.Font.SourceSansBold sl5.TextSize=12
local function mkSR(y,m1,c1,m2,c2)
    local r=Instance.new("Frame",TabHoanHon)r.Size=UDim2.new(1,-10,0,42)r.Position=UDim2.new(0,0,0,y)r.BackgroundColor3=Color3.fromRGB(38,38,38)Instance.new("UICorner",r).CornerRadius=UDim.new(0,4)
    local function mb(txt,m,x,col)local b=Instance.new("TextButton",r)b.Size=UDim2.new(0,165,0,28)b.Position=UDim2.new(0,x,0,7)b.BackgroundColor3=skyMode==m and col or Color3.fromRGB(55,55,55)b.Text=SKY_MODES[m].Name b.Font=Enum.Font.SourceSansBold b.TextSize=12 Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)b.MouseButton1Click:Connect(function()skyMode=m applySkyMode(m)for _,o in pairs(r:GetChildren())do if o:IsA("TextButton")then o.BackgroundColor3=Color3.fromRGB(55,55,55)end end b.BackgroundColor3=col end)end
    mb(SKY_MODES[m1].Name,m1,10,c1)mb(SKY_MODES[m2].Name,m2,185,c2)
end
mkSR(82,"day",Color3.fromRGB(50,150,255),"night",Color3.fromRGB(40,60,160))
mkSR(134,"sunset",Color3.fromRGB(255,90,35),"purple",Color3.fromRGB(160,70,230))
mkSR(186,"space",Color3.fromRGB(20,10,60),"ocean",Color3.fromRGB(30,170,180))

-- ==============================================
-- === ⚙️ TAB CÀI ĐẶT — GIỮ NGUYÊN (ESP + FPS + QUAN SÁT + ĐỔI SERVER) ===
-- ==============================================
row(TabCaiDat,"ESP Xem tên người",10,function()espOldEnabled=not espOldEnabled if espOldEnabled then for _,p in ipairs(Players:GetPlayers())do applyESP(p)end else removeESP()end return espOldEnabled end,false)
row(TabCaiDat,"Bầu trời hoàng hôn nhanh",52,function()sunsetEnabled=not sunsetEnabled if sunsetEnabled then skyEnabled=false restoreOriginalSkyFull()end if sunsetEnabled then Lighting.ClockTime=17.65 Lighting.OutdoorAmbient=Color3.fromRGB(245,110,40)else Lighting.ClockTime=originalSettings.ClockTime Lighting.OutdoorAmbient=originalSettings.OutdoorAmbient end return sunsetEnabled end,false)
local FpsL=Instance.new("TextLabel",ScreenGui)FpsL.Size=UDim2.new(0,80,0,24)FpsL.Position=UDim2.new(0.05,0,0.25,0)FpsL.BackgroundColor3=Color3.fromRGB(40,35,45)FpsL.TextColor3=Color3.new(1,1,0)FpsL.Font=Enum.Font.SourceSansBold FpsL.TextSize=12 FpsL.Visible=false Instance.new("UICorner",FpsL)
row(TabCaiDat,"Hiển thị FPS",94,function()
    fpsEnabled=not fpsEnabled FpsL.Visible=fpsEnabled
    if fpsEnabled then local lt,fc=os.clock(),0 fpsConnection=RunService.RenderStepped:Connect(function()fc+=1 local t=os.clock()if t-lt>=1 then FpsL.Text="FPS: "..tostring(fc)fc=0 lt=t end end)
    else if fpsConnection then pcall(function()fpsConnection:Disconnect()end)fpsConnection=nil end end
    return fpsEnabled
end,false)

-- ✅ UI QUAN SÁT NGƯỜI CHƠI
local st=Instance.new("TextLabel",TabCaiDat)st.Size=UDim2.new(1,-20,0,20)st.Position=UDim2.new(0,10,0,140)st.BackgroundTransparency=1 st.Text="🔭 QUAN SÁT NGƯỜI CHƠI"st.TextColor3=Color3.fromRGB(0,220,255)st.Font=Enum.Font.GothamBold st.TextSize=14
spectateToggleBtn=Instance.new("TextButton",TabCaiDat)spectateToggleBtn.Size=UDim2.new(1,-10,0,36)spectateToggleBtn.Position=UDim2.new(0,0,0,170)spectateToggleBtn.BackgroundColor3=Color3.fromRGB(0,120,180)spectateToggleBtn.TextColor3=Color3.new(1,1,1)spectateToggleBtn.TextSize=14 spectateToggleBtn.Font=Enum.Font.GothamBold spectateToggleBtn.Text="🔭 Mở Danh Sách Người Chơi"Instance.new("UICorner",spectateToggleBtn).CornerRadius=UDim.new(0,8)
spectateListFrame=Instance.new("ScrollingFrame",ScreenGui)spectateListFrame.Name="SpecList"spectateListFrame.Size=UDim2.new(0,210,0,300)spectateListFrame.Position=UDim2.new(0,20,0,160)spectateListFrame.BackgroundColor3=Color3.fromRGB(20,20,20)spectateListFrame.BackgroundTransparency=0.1 spectateListFrame.ScrollBarThickness=4 spectateListFrame.Visible=false Instance.new("UICorner",spectateListFrame).CornerRadius=UDim.new(0,8)
spectateStopBtn=Instance.new("TextButton",ScreenGui)spectateStopBtn.Name="StopSpec"spectateStopBtn.Size=UDim2.new(0,180,0,44)spectateStopBtn.Position=UDim2.new(0.5,-90,0.88,0)spectateStopBtn.BackgroundColor3=Color3.fromRGB(220,50,50)spectateStopBtn.TextColor3=Color3.new(1,1,1)spectateStopBtn.TextSize=15 spectateStopBtn.Font=Enum.Font.GothamBold spectateStopBtn.Text="❌ Thoát Quan Sát"spectateStopBtn.Visible=false Instance.new("UICorner",spectateStopBtn).CornerRadius=UDim.new(0,10)
spectateToggleBtn.MouseButton1Click:Connect(function()spectateListFrame.Visible=not spectateListFrame.Visible if spectateListFrame.Visible then spectateToggleBtn.Text="❌ Đóng Danh Sách"spectateToggleBtn.BackgroundColor3=Color3.fromRGB(180,50,50)updateSpectateList()else spectateToggleBtn.Text="🔭 Mở Danh Sách Người Chơi"spectateToggleBtn.BackgroundColor3=Color3.fromRGB(0,120,180)end end)
spectateStopBtn.MouseButton1Click:Connect(stopSpectating)
Players.PlayerAdded:Connect(function()if spectateListFrame and spectateListFrame.Visible then updateSpectateList()end end)
Players.PlayerRemoving:Connect(function(p)if isSpectating and currentSpectateTarget==p then stopSpectating()end if spectateListFrame and spectateListFrame.Visible then updateSpectateList()end removeESP(p)end)

-- 🚀 ĐỔI SERVER
local Hop=Instance.new("TextButton",TabCaiDat)Hop.Size=UDim2.new(1,-10,0,30)Hop.Position=UDim2.new(0,0,0,220)Hop.BackgroundColor3=Color3.fromRGB(80,40,150)Hop.Text="🚀 Đổi server ít người nhất"Hop.Font=Enum.Font.SourceSansBold Hop.TextSize=12 Instance.new("UICorner",Hop).CornerRadius=UDim.new(0,4)
Hop.MouseButton1Click:Connect(function()local u="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"local ok,d=pcall(function()return HttpService:JSONDecode(game:HttpGet(u))end)if ok and d and d.data then for _,s in pairs(d.data)do if s.playing<s.maxPlayers and s.id~=game.JobId then pcall(function()TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,LocalPlayer)end)break end end end end)

-- ==============================================
-- === 🔄 VÒNG LẶP CHÍNH — ƯU TIÊN: QUAN SÁT → AIMBOT MỚI → CHỨC NĂNG CŨ ===
-- ==============================================
RunService.RenderStepped:Connect(function(dt)
    -- 1️⃣ ƯU TIÊN 1: QUAN SÁT NGƯỜI CHƠI
    if isSpectating and currentSpectateTarget then
        local tc=currentSpectateTarget.Character
        if tc and tc:FindFirstChild("HumanoidRootPart")and tc:FindFirstChildOfClass("Humanoid")and tc.Humanoid.Health>0 then
            local tr=tc.HumanoidRootPart Camera.CFrame=tr.CFrame*CFrame.new(0,3.5,-14)*CFrame.Angles(math.rad(-10),math.rad(180),0)
        else stopSpectating()end
        return
    end

    -- 2️⃣ ƯU TIÊN 2: 🎯 AIMBOT MỚI CỦA BẠN (CHẠY KHI _G ĐƯỢC BẬT)
    if _G.CameraLockRunning then
        -- Tự tạo ESP khi người mới vào
        if espEnabled then for _,p in ipairs(Players:GetPlayers())do if p~=LocalPlayer and p.Character then if not espCache[p]or not p.Character:FindFirstChildOfClass("Highlight")then createESP(p)end end end end
        -- Khóa cam MƯỢT = Lerp (đúng code bạn) — nhắm vào đầu + Vector3.new(0, 2, 0)
        if isLocked then
            local t=getNearestPlayer()
            if t then
                local tp=t.Position+Vector3.new(0,2,0)
                local cp=Camera.CFrame.Position
                local tc=CFrame.new(cp,tp)
                Camera.CFrame=Camera.CFrame:Lerp(tc,math.clamp(cameraSpeed*dt,0.01,1))
            end
        end
    end

    -- 3️⃣ TẤT CẢ CHỨC NĂNG CŨ — VẪN CHẠY BÌNH THƯỜNG
    local c=LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid")then
        local h=c.Humanoid local r=c:FindFirstChild("HumanoidRootPart")
        if speedEnabled then h.WalkSpeed=walkSpeedValue else h.WalkSpeed=16 end
        if jumpEnabled then h.JumpPower=jumpPowerValue h.UseJumpPower=true else h.UseJumpPower=false end
        if noclipEnabled then for _,v in ipairs(c:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end
        if tpEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")and r then
            r.CFrame=targetPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,2,2)
        end
    end
end)

-- ==============================================
-- === ✨ PHỤ KIỆN — VIỀN CẦU VỒNG + NÚT ẨN MENU ===
-- ==============================================
local stk=Instance.new("UIStroke")stk.Parent=MainFrame stk.Thickness=2
local hu=0 RunService.RenderStepped:Connect(function(dt)hu=(hu+dt*0.15)%1 stk.Color=Color3.fromHSV(hu,1,1)end)
local TG=Instance.new("ImageButton",ScreenGui)TG.Size=UDim2.new(0,45,0,45)TG.Position=UDim2.new(0.05,0,0.2,0)TG.Image="rbxassetid://90661485753344"Instance.new("UICorner",TG).CornerRadius=UDim.new(1,0)
local tgs=Instance.new("UIStroke")tgs.Thickness=2 tgs.Parent=TG
local bhu=0 RunService.RenderStepped:Connect(function(dt)bhu=(bhu+dt*0.25)%1 tgs.Color=Color3.fromHSV(bhu,1,1)end)
TG.MouseButton1Click:Connect(function()MainFrame.Visible=not MainFrame.Visible if not MainFrame.Visible and spectateListFrame then spectateListFrame.Visible=false end end)
