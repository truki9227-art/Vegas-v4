-- [[ ZENITH HUB - PHIÊN BẢN MODIFIED ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Trạng thái chức năng
local speedEnabled, flyEnabled, espEnabled, sunsetEnabled, jumpEnabled, noclipEnabled, camLockEnabled, infJumpEnabled, fpsEnabled = false, false, false, false, false, false, false, false, false
local walkSpeedValue, flySpeedValue, jumpPowerValue = 50, 50, 100
local flyConnection, noclipConnection, infJumpConnection, fpsConnection, bv, bg
local flyDirection = 0 
local tpEnabled = false
local playerList = {}
local currentTargetIndex = 1
local targetPlayer = nil
local waterRunEnabled = false

local originalSettings = {
    ClockTime = Lighting.ClockTime,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Materials = {}
}

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Part") or obj:IsA("MeshPart") then originalSettings.Materials[obj] = obj.Material end
end

local function refreshPlayerList()
    playerList = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(playerList, p) end end
    if currentTargetIndex > #playerList then currentTargetIndex = 1 end
end

-- --- HIỆU ỨNG HỆ THỐNG ---
local function updateFireEffect()
    local char = LocalPlayer.Character if not char then return end
    local leftFoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
    local rightFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if speedEnabled and hum and hum.MoveDirection.Magnitude > 0 then
        if leftFoot and not leftFoot:FindFirstChild("RunFire") then Instance.new("Fire", leftFoot).Name = "RunFire" end
        if rightFoot and not rightFoot:FindFirstChild("RunFire") then Instance.new("Fire", rightFoot).Name = "RunFire" end
    else
        if leftFoot and leftFoot:FindFirstChild("RunFire") then leftFoot.RunFire:Destroy() end
        if rightFoot and rightFoot:FindFirstChild("RunFire") then rightFoot.RunFire:Destroy() end
    end
end

local function updateWaterEffect()
    local char = LocalPlayer.Character if not char then return end
    local leftFoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
    local rightFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if waterRunEnabled and hum and hum.MoveDirection.Magnitude > 0 then
        if leftFoot and not leftFoot:FindFirstChild("RunWater") then
            local p = Instance.new("ParticleEmitter", leftFoot); p.Name = "RunWater"
            p.Color = ColorSequence.new(Color3.fromRGB(0, 180, 255)); p.Rate = 70; p.Lifetime = NumberRange.new(0.3, 0.6)
        end
        if rightFoot and not rightFoot:FindFirstChild("RunWater") then
            local p = Instance.new("ParticleEmitter", rightFoot); p.Name = "RunWater"
            p.Color = ColorSequence.new(Color3.fromRGB(0, 180, 255)); p.Rate = 70; p.Lifetime = NumberRange.new(0.3, 0.6)
        end
    else
        if leftFoot and leftFoot:FindFirstChild("RunWater") then leftFoot.RunWater:Destroy() end
        if rightFoot and rightFoot:FindFirstChild("RunWater") then rightFoot.RunWater:Destroy() end
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupCharacter(char)
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("ESP_Billboard") then
            local billboard = Instance.new("BillboardGui", head); billboard.Name = "ESP_Billboard"; billboard.AlwaysOnTop = true; billboard.Size = UDim2.new(0, 150, 0, 40); billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            local label = Instance.new("TextLabel", billboard); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.Text = player.Name; label.TextColor3 = Color3.fromRGB(255, 255, 0); label.Font = Enum.Font.SourceSansBold; label.TextSize = 14
        end
    end
    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

local function removeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("ESP_Billboard") then
            player.Character.Head.ESP_Billboard:Destroy()
        end
    end
end

-- --- THIẾT KẾ GIAO DIỆN ---
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "ZenithHub_Fluent"; ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 330)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

-- CHỈNH SỬA: Tên Zenith Hub và hiệu ứng 7 màu
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -100, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "ZENITH HUB"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left
RunService.RenderStepped:Connect(function() Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 130, 1, -32); SideBar.Position = UDim2.new(0, 0, 0, 32); SideBar.BackgroundColor3 = Color3.fromRGB(32, 32, 32); SideBar.BorderSizePixel = 0

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -140, 1, -42); ContentFrame.Position = UDim2.new(0, 135, 0, 37); ContentFrame.BackgroundTransparency = 1

local TabChinhContainer = Instance.new("ScrollingFrame", ContentFrame)
TabChinhContainer.Size = UDim2.new(1, 0, 1, 0); TabChinhContainer.BackgroundTransparency = 1; TabChinhContainer.ScrollBarThickness = 2; TabChinhContainer.CanvasSize = UDim2.new(0, 0, 0, 480)

local TabCaiDatContainer = Instance.new("ScrollingFrame", ContentFrame)
TabCaiDatContainer.Size = UDim2.new(1, 0, 1, 0); TabCaiDatContainer.BackgroundTransparency = 1; TabCaiDatContainer.ScrollBarThickness = 2; TabCaiDatContainer.CanvasSize = UDim2.new(0, 0, 0, 480); TabCaiDatContainer.Visible = false

-- --- CÁC NÚT TAB SIDEBAR ---
local ChinhTabBtn = Instance.new("TextButton", SideBar)
ChinhTabBtn.Size = UDim2.new(1, -10, 0, 30); ChinhTabBtn.Position = UDim2.new(0, 5, 0, 10); ChinhTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ChinhTabBtn.Text = "🏠 Chính"; ChinhTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ChinhTabBtn.Font = Enum.Font.SourceSansBold; ChinhTabBtn.TextSize = 13
Instance.new("UICorner", ChinhTabBtn).CornerRadius = UDim.new(0, 4)

local CaiDatTabBtn = Instance.new("TextButton", SideBar)
CaiDatTabBtn.Size = UDim2.new(1, -10, 0, 30); CaiDatTabBtn.Position = UDim2.new(0, 5, 0, 45); CaiDatTabBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38); CaiDatTabBtn.Text = "⚙️ Cài Đặt"; CaiDatTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180); CaiDatTabBtn.Font = Enum.Font.SourceSansBold; CaiDatTabBtn.TextSize = 13
Instance.new("UICorner", CaiDatTabBtn).CornerRadius = UDim.new(0, 4)

ChinhTabBtn.MouseButton1Click:Connect(function()
    TabChinhContainer.Visible = true; TabCaiDatContainer.Visible = false
    ChinhTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); ChinhTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CaiDatTabBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38); CaiDatTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

CaiDatTabBtn.MouseButton1Click:Connect(function()
    TabChinhContainer.Visible = false; TabCaiDatContainer.Visible = true
    CaiDatTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); CaiDatTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChinhTabBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38); ChinhTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

-- --- HÀM TẠO DÒNG CHỨC NĂNG ---
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
        box.FocusLost:Connect(function() local val = tonumber(box.Text) if val then sliderCallback(val) end end)
    end
end

-- --- TAB CHÍNH ---
createModernRow(TabChinhContainer, "Chạy Nhanh (Bật/Tắt lửa chân)", 75, function() speedEnabled = not speedEnabled return speedEnabled end, false)
createModernRow(TabChinhContainer, "↳ Tốc độ chạy nhanh", 117, nil, true, 50, function(val) walkSpeedValue = val end)
createModernRow(TabChinhContainer, "Fly Camera (Bay tự do)", 159, function(btn)
    flyEnabled = not flyEnabled
    if flyEnabled then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root, hum, cam = char:WaitForChild("HumanoidRootPart"), char:FindFirstChild("Humanoid"), workspace.CurrentCamera
        bv = Instance.new("BodyVelocity", root); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bg = Instance.new("BodyGyro", root); bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4
        if hum then hum.PlatformStand = true end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not char.Parent then return end
            local vel = Vector3.new(0, 0, 0)
            if hum and hum.MoveDirection.Magnitude > 0 then
                vel = cam.CFrame.LookVector * (hum.MoveDirection.Z < 0 and flySpeedValue or -flySpeedValue) + (cam.CFrame.RightVector * hum.MoveDirection.X * flySpeedValue)
            end
            vel = vel + Vector3.new(0, flyDirection * flySpeedValue, 0)
            bv.velocity = vel; bg.cframe = cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end if bv then bv:Destroy() end if bg then bg:Destroy() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
    end
    return flyEnabled
end, false)
createModernRow(TabChinhContainer, "↳ Tốc độ Fly Camera", 201, nil, true, 50, function(val) flySpeedValue = val end)

local flyCtrlFrame = Instance.new("Frame", TabChinhContainer); flyCtrlFrame.Size = UDim2.new(1, -10, 0, 30); flyCtrlFrame.Position = UDim2.new(0, 0, 0, 243); flyCtrlFrame.BackgroundTransparency = 1
local UpB = Instance.new("TextButton", flyCtrlFrame); UpB.Size = UDim2.new(0.48, 0, 1, 0); UpB.BackgroundColor3 = Color3.fromRGB(45,45,45); UpB.Text = "LÊN (UP)"; UpB.TextColor3 = Color3.new(1,1,1); UpB.Font = Enum.Font.SourceSansBold; UpB.TextSize = 11; Instance.new("UICorner", UpB)
local DownB = Instance.new("TextButton", flyCtrlFrame); DownB.Size = UDim2.new(0.48, 0, 1, 0); DownB.Position = UDim2.new(0.52, 0, 0, 0); DownB.BackgroundColor3 = Color3.fromRGB(45,45,45); DownB.Text = "XUỐNG (DOWN)"; DownB.TextColor3 = Color3.new(1,1,1); DownB.Font = Enum.Font.SourceSansBold; DownB.TextSize = 11; Instance.new("UICorner", DownB)
UpB.MouseButton1Click:Connect(function() if flyEnabled then flyDirection = (flyDirection == 1) and 0 or 1 end end)
DownB.MouseButton1Click:Connect(function() if flyEnabled then flyDirection = (flyDirection == -1) and 0 or -1 end end)

createModernRow(TabChinhContainer, "Nhảy Cao Hơn", 279, function() jumpEnabled = not jumpEnabled return jumpEnabled end, false)
createModernRow(TabChinhContainer, "↳ Sức mạnh nhảy cao", 321, nil, true, 100, function(val) jumpPowerValue = val end)
createModernRow(TabChinhContainer, "Fake Nhảy Tường (Vô hạn nhảy)", 363, function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
        end)
    else if infJumpConnection then infJumpConnection:Disconnect() end end
    return infJumpEnabled
end, false)
createModernRow(TabChinhContainer, "Đi Xuyên Tường (Noclip)", 405, function() noclipEnabled = not noclipEnabled return noclipEnabled end, false)
createModernRow(TabChinhContainer, "Đi Bộ Trên Tường", 447, function() waterRunEnabled = not waterRunEnabled return waterRunEnabled end, false)

-- --- TAB CÀI ĐẶT ---
createModernRow(TabCaiDatContainer, "Nhìn Tên Từ Xa (ESP Name)", 40, function() espEnabled = not espEnabled if espEnabled then for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end else removeESP() end return espEnabled end, false)
createModernRow(TabCaiDatContainer, "Bầu Trời Hoàng Hôn Đẹp", 82, function()
    sunsetEnabled = not sunsetEnabled
    if sunsetEnabled then Lighting.ClockTime = 17.65; Lighting.OutdoorAmbient = Color3.fromRGB(245, 110, 40)
    else Lighting.ClockTime = originalSettings.ClockTime; Lighting.OutdoorAmbient = originalSettings.OutdoorAmbient end
    return sunsetEnabled
end, false)

local FpsLabel = Instance.new("TextLabel", ScreenGui); FpsLabel.Size = UDim2.new(0, 80, 0, 24); FpsLabel.Position = UDim2.new(0.05, 0, 0.25, 0); FpsLabel.BackgroundColor3 = Color3.fromRGB(40, 35, 45); FpsLabel.TextColor3 = Color3.new(1, 1, 0); FpsLabel.Font = Enum.Font.SourceSansBold; FpsLabel.TextSize = 12; FpsLabel.Visible = false; Instance.new("UICorner", FpsLabel)

createModernRow(TabCaiDatContainer, "Hiện Chỉ Số FPS Thực Tế", 124, function()
    fpsEnabled = not fpsEnabled; FpsLabel.Visible = fpsEnabled
    if fpsEnabled then
        local lastTime, frameCount = os.clock(), 0
        fpsConnection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1 local currentTime = os.clock()
            if currentTime - lastTime >= 1 then FpsLabel.Text = "FPS: " .. tostring(frameCount) frameCount = 0 lastTime = currentTime end
        end)
    else if fpsConnection then fpsConnection:Disconnect() end end
    return fpsEnabled
end, false)

createModernRow(TabCaiDatContainer, "Xoay Cam Gần Nhất (Auto Lock)", 166, function() camLockEnabled = not camLockEnabled return camLockEnabled end, false)
createModernRow(TabCaiDatContainer, "Hành Động Chạy Ra Nước", 208, function() waterRunEnabled = not waterRunEnabled return waterRunEnabled end, false)

local SelectPlayerBtn = Instance.new("TextButton", TabCaiDatContainer); SelectPlayerBtn.Size = UDim2.new(1, -10, 0, 30); SelectPlayerBtn.Position = UDim2.new(0, 0, 0, 250); SelectPlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55); SelectPlayerBtn.Text = "🔎 [BẤM ĐỂ CHỌN MỤC TIÊU]"; SelectPlayerBtn.TextColor3 = Color3.new(1, 1, 1); SelectPlayerBtn.Font = Enum.Font.SourceSansBold; SelectPlayerBtn.TextSize = 12; Instance.new("UICorner", SelectPlayerBtn)
SelectPlayerBtn.MouseButton1Click:Connect(function() refreshPlayerList() if #playerList == 0 then return end targetPlayer = playerList[currentTargetIndex]; if targetPlayer then SelectPlayerBtn.Text = "👤 Đang chọn: " .. targetPlayer.Name end; currentTargetIndex = (currentTargetIndex % #playerList) + 1 end)

local TeleportBtn = Instance.new("TextButton", TabCaiDatContainer); TeleportBtn.Size = UDim2.new(1, -10, 0, 30); TeleportBtn.Position = UDim2.new(0, 0, 0, 290); TeleportBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40); TeleportBtn.Text = "Bay Đến Mục Tiêu: TẮT"; TeleportBtn.TextColor3 = Color3.new(1, 1, 1); TeleportBtn.Font = Enum.Font.SourceSansBold; TeleportBtn.TextSize = 12; Instance.new("UICorner", TeleportBtn)
TeleportBtn.MouseButton1Click:Connect(function() if not targetPlayer then return end tpEnabled = not tpEnabled; TeleportBtn.Text = tpEnabled and "Bay Đến Mục Tiêu: BẬT" or "Bay Đến Mục Tiêu: TẮT"; TeleportBtn.BackgroundColor3 = tpEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(150, 40, 40) end)

local HopBtn = Instance.new("TextButton", TabCaiDatContainer); HopBtn.Size = UDim2.new(1, -10, 0, 30); HopBtn.Position = UDim2.new(0, 0, 0, 330); HopBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 150); HopBtn.Text = "🚀 Chuyển Server Ít Người Nhất"; HopBtn.TextColor3 = Color3.new(1, 1, 1); HopBtn.Font = Enum.Font.SourceSansBold; HopBtn.TextSize = 12; Instance.new("UICorner", HopBtn)
HopBtn.MouseButton1Click:Connect(function() local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"; local data = game:GetService("HttpService"):JSONDecode(game:HttpGet(url)); for _, server in pairs(data.data) do if server.playing < server.maxPlayers and server.id ~= game.JobId then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer); break end end end)

local HopOldBtn = Instance.new("TextButton", TabCaiDatContainer); HopOldBtn.Size = UDim2.new(1, -10, 0, 30); HopOldBtn.Position = UDim2.new(0, 0, 0, 370); HopOldBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 40); HopOldBtn.Text = "⏳ Chuyển Server Ngẫu Nhiên"; HopOldBtn.TextColor3 = Color3.new(1, 1, 1); HopOldBtn.Font = Enum.Font.SourceSansBold; HopOldBtn.TextSize = 12; Instance.new("UICorner", HopOldBtn)
HopOldBtn.MouseButton1Click:Connect(function() local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"; local data = game:GetService("HttpService"):JSONDecode(game:HttpGet(url)); game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, data.data[1].id, LocalPlayer) end)

local ToggleBtn = Instance.new("ImageButton", ScreenGui); ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0); ToggleBtn.Image = "rbxthumb://type=Asset&id=117104276885811&w=150&h=150"; Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- --- LẶP HỆ THỐNG ---
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid; local root = char:FindFirstChild("HumanoidRootPart")
        if speedEnabled then hum.WalkSpeed = walkSpeedValue end
        updateFireEffect(); updateWaterEffect()
        if jumpEnabled then hum.JumpPower = jumpPowerValue; hum.UseJumpPower = true else hum.UseJumpPower = false end
        if tpEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 1.5) end
        if noclipEnabled then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
        if camLockEnabled then
            local closest, shortestDistance = nil, math.huge
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local distance = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then shortestDistance = distance; closest = player end
                end
            end
            if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Character.HumanoidRootPart.Position) end
        end
    end
end)
local stroke = Instance.new("UIStroke")
stroke.Parent = MainFrame
stroke.Thickness = 2
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = (hue + dt * 0.15) % 1
    stroke.Color = Color3.fromHSV(hue, 1, 1)
end)

-- Loading Screen
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1,1)
bg.BackgroundColor3 = Color3.fromRGB(20,20,20)
bg.Parent = gui
local text = Instance.new("TextLabel")
text.Size = UDim2.new(0,300,0,50)
text.Position = UDim2.new(0.5,-150,0.45,-25)
text.BackgroundTransparency = 1
text.Text = "Loading..."
text.TextScaled = true
text.Font = Enum.Font.GothamBold
text.TextColor3 = Color3.new(1,1,1)
text.Parent = bg
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0,250,0,10)
barBg.Position = UDim2.new(0.5,-125,0.55,0)
barBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
barBg.BorderSizePixel = 0
barBg.Parent = bg
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0,0,1,0)
bar.BackgroundColor3 = Color3.fromRGB(0,170,255)
bar.BorderSizePixel = 0
bar.Parent = barBg
for i = 1,100 do
    bar.Size = UDim2.new(i/100,0,1,0)
    task.wait(0.01)
end
gui:Destroy()
-- [[ BỔ SUNG: XOAY VÀ ĐÁ ]]
local flingEnabled = false
local kickEnabled = false
local kickPower = 50 -- Tốc độ mặc định

local function applyTargetEffects()
    if not flingEnabled and not kickEnabled then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
            
            if dist < 10 then
                -- 1. Chức năng Xoay (Chong chóng)
                if flingEnabled then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), 0)
                end
                
                -- 2. Chức năng Đá (Đẩy văng mạnh)
                if kickEnabled then
                    local direction = (hrp.Position - char.HumanoidRootPart.Position).Unit
                    hrp.CFrame = hrp.CFrame + (direction * (kickPower / 10)) + Vector3.new(0, 2, 0)
                end
            end
        end
    end
end

-- --- THÊM VÀO TAB CÀI ĐẶT ---
-- Nút Xoay
createModernRow(TabCaiDatContainer, "🌀 Xoay đối thủ", 415, function() 
    flingEnabled = not flingEnabled 
    return flingEnabled 
end, false)

-- Nút Đá
createModernRow(TabCaiDatContainer, "🦶 Đá đối thủ", 457, function() 
    kickEnabled = not kickEnabled 
    return kickEnabled 
end, false)

-- Chỉnh tốc độ Đá
createModernRow(TabCaiDatContainer, "↳ Tốc độ đá", 499, nil, true, 50, function(val) 
    kickPower = val 
end)

-- Gộp vào Heartbeat (Tìm hàm Heartbeat cũ và thêm dòng này vào trong)
RunService.Heartbeat:Connect(function()
    applyTargetEffects() 
end)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Image = "rbxassetid://90661485753344"

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)local dragging = false
local dragInput
local dragStart
local startPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)local dragging = false
local dragInput
local dragStart
local startPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
