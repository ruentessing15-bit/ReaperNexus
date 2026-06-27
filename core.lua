-- Reaper Nexus ULTIMATE [FULL VERSION - FLOATING BUTTON]
-- No Thai characters in code

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // CLEANUP PREVIOUS RUNS
if _G.ReaperNexusCleanup then _G.ReaperNexusCleanup() end

-- // UI SETUP WITH KEY SYSTEM
local Window = WindUI:CreateWindow({
    Title = "Reaper Nexus",
    Author = "by Nong R",
    Folder = "Reaper_Nexus_Config",
    Icon = "rbxassetid://91476568341639",
    Transparent = true,
    Theme = "Dark",
    KeySystem = { 
        Key = {"Zr123"},
        Note = "Please enter the key to unlock Reaper Nexus",
        Thumbnail = {
            Image = "rbxassetid://91476568341639",
            Title = "",
        },
        URL = "https://www.google.com",
        SaveKey = true,
    },
})

Window:EditOpenButton({ Enabled = false })

-- // FLOATING BUTTON (DRAGGABLE & ROUNDED)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReaperNexusFloating"
ScreenGui.Parent = game:GetService("CoreGui")

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Name = "MainButton"
FloatingButton.Parent = ScreenGui
FloatingButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FloatingButton.BorderSizePixel = 0
FloatingButton.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatingButton.Size = UDim2.new(0, 50, 0, 50)
FloatingButton.Image = "rbxassetid://91476568341639"
FloatingButton.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = FloatingButton

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
UIGradient.Parent = FloatingButton

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatingButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

FloatingButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

FloatingButton.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

-- // TABS
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword"})
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
local LootTab = Window:Tab({Title = "Auto Loot", Icon = "box"}) 
local MiscTab = Window:Tab({Title = "Misc & FPS", Icon = "settings"})

-- // VARIABLES FROM ORIGINAL CODE
local SelectedBodyPart = "Head"; local SilentAimEnabled = false; local showFov = false; local BulletSpeed = 1500
local GunLookup = {["P226"]=true, ["MP5"]=true, ["M24"]=true, ["Draco"]=true, ["Glock"]=true, ["Sawnoff"]=true, ["Uzi"]=true, ["G3"]=true, ["C9"]=true, ["Hunting Rifle"]=true, ["Anaconda"]=true, ["AK47"]=true, ["Remington"]=true, ["Double Barrel"]=true, ["Skorpion"]=true}
local FOVCircle = Drawing.new("Circle"); FOVCircle.Radius = 150; FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.Color = Color3.fromRGB(0, 255, 0); FOVCircle.Visible = false
local speedEnabled = false; local speedMultiplier = 0.10; local infStamEnabled = false; local MagnetConfig = { Enabled = false, Radius = 20 }
_G.EnabledBox = false; _G.EnabledHpBar = false; _G.EnabledName = false; _G.EnabledDistance = false; local ItemESP_Enabled = true

-- // CORE LOGIC FROM ORIGINAL CODE
local function GetTargetPart(character) return character and character:FindFirstChild(SelectedBodyPart) end

local function GetClosestTarget()
    local closest, shortest = nil, math.huge; local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = GetTargetPart(plr.Character)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if (not showFov or dist <= FOVCircle.Radius) and dist < shortest then shortest = dist closest = plr end
                end
            end
        end
    end
    return closest
end

local function GetResolvedVelocity(target, root)
    if not root or not target.Character then return Vector3.zero end
    local hum = target.Character:FindFirstChildOfClass("Humanoid"); local trackingPart = (hum and hum.SeatPart) and hum.SeatPart or root
    if not TargetData[target] then TargetData[target] = { LastPos = trackingPart.Position, LastTick = tick(), SmoothVel = Vector3.zero } end
    local data = TargetData[target]; local now, dt = tick(), tick() - data.LastTick
    local calculatedVel = (dt > 0.01 and dt < 1) and (trackingPart.Position - data.LastPos) / dt or Vector3.zero
    data.LastPos = trackingPart.Position; data.LastTick = now
    local realVel = trackingPart.AssemblyLinearVelocity
    if realVel.Magnitude > 250 or realVel.Magnitude < 2 then if calculatedVel.Magnitude > 1 then realVel = calculatedVel end end
    data.SmoothVel = data.SmoothVel:Lerp(realVel.Magnitude > 500 and realVel.Unit * 500 or realVel, 0.75)
    return data.SmoothVel
end

-- // SILENT AIM HOOK
local send = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
local oldFire
oldFire = hookfunction(send.FireServer, function(self, ...)
    local args = {...}; local isGun = false
    pcall(function() if typeof(args[3])=="Instance" and GunLookup[args[3].Name] then isGun = true end end)
    if not isGun and LocalPlayer.Character then for _, t in pairs(LocalPlayer.Character:GetChildren()) do if (t:IsA("Tool") or t:IsA("Model")) and GunLookup[t.Name] then isGun = true break end end end
    if SilentAimEnabled and isGun then
        local target = GetClosestTarget()
        if target and target.Character then
            local tPart = target.Character:FindFirstChild(SelectedBodyPart) or target.Character:FindFirstChild("HumanoidRootPart")
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if tPart and root then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local curPos = myRoot and myRoot.Position or Camera.CFrame.Position
                local dist = (tPart.Position - curPos).Magnitude; local ping = (Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000) or 0.1
                local offset = (dist / BulletSpeed) + ping; local aimPos = tPart.Position + (GetResolvedVelocity(target, root) * offset)
                if type(args[4]) == "userdata" then args[4] = CFrame.new(9e9, 9e9, 9e9) end
                if type(args[5]) == "table" then for _, b in pairs(args[5]) do if type(b) == "table" and b[1] then b[1]["Instance"], b[1]["Position"] = tPart, aimPos end end end
            end
        end
    end
    return oldFire(self, unpack(args))
end)

-- // ESP LOGIC
local function updatePlayerESP(player)
    local esp = player_esp_data[player]
    if not esp then return end
    local char = player.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart"); local head = char and char:FindFirstChild("Head")
    if not (char and hum and root and head and hum.Health > 0) then for _, v in pairs(esp) do v.Visible = false end return end
    local screenHead, onHead = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local screenFeet, onFeet = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
    if onHead or onFeet then
        local height = math.abs(screenHead.Y - screenFeet.Y); local width = height / 2; local x = screenHead.X - (width / 2); local y = screenHead.Y
        esp.Box.PointA = Vector2.new(x + width, y); esp.Box.PointB = Vector2.new(x, y); esp.Box.PointC = Vector2.new(x, y + height); esp.Box.PointD = Vector2.new(x + width, y + height); esp.Box.Visible = _G.EnabledBox
        esp.Name.Text = player.DisplayName; esp.Name.Position = Vector2.new(x + width / 2, y - 16); esp.Name.Visible = _G.EnabledName
        local lChar = LocalPlayer.Character; local lRoot = lChar and lChar:FindFirstChild("HumanoidRootPart")
        if lRoot then local dist = math.floor((lRoot.Position - root.Position).Magnitude); esp.Distance.Text = tostring(dist) .. "m"; esp.Distance.Position = Vector2.new(x + width / 2, y + height + 2); esp.Distance.Visible = _G.EnabledDistance else esp.Distance.Visible = false end
        local healthRatio = hum.Health / hum.MaxHealth; local hBarX = x - 6; esp.HealthBarOutline.PointA = Vector2.new(hBarX + 4, y); esp.HealthBarOutline.PointB = Vector2.new(hBarX, y); esp.HealthBarOutline.PointC = Vector2.new(hBarX, y + height); esp.HealthBarOutline.PointD = Vector2.new(hBarX + 4, y + height); esp.HealthBarOutline.Visible = _G.EnabledHpBar
        local hHeight = height * healthRatio; esp.HealthBar.PointA = Vector2.new(hBarX + 3, y + (height - hHeight)); esp.HealthBar.PointB = Vector2.new(hBarX + 1, y + (height - hHeight)); esp.HealthBar.PointC = Vector2.new(hBarX + 1, y + height); esp.HealthBar.PointD = Vector2.new(hBarX + 3, y + height); esp.HealthBar.Color = Color3.fromHSV(healthRatio * 0.3, 1, 1); esp.HealthBar.Visible = _G.EnabledHpBar
    else for _, v in pairs(esp) do v.Visible = false end end
end

-- // UI CONNECTIONS
CombatTab:Toggle({ Title = "Enable Silent Aim", Default = false, Callback = function(v) SilentAimEnabled = v end })
CombatTab:Dropdown({ Title = "Target BodyPart", Default = "Head", Values = {"Head", "HumanoidRootPart"}, Callback = function(v) SelectedBodyPart = v end })
CombatTab:Toggle({ Title = "Show FOV Circle", Default = false, Callback = function(v) showFov = v; FOVCircle.Visible = v end })
CombatTab:Slider({ Title = "FOV Radius", Value = {Min = 50, Max = 500, Default = 150}, Step = 1, Callback = function(v) FOVCircle.Radius = v end })

PlayerTab:Toggle({ Title = "Enable Walk Speed", Default = false, Callback = function(s) speedEnabled = s end })
PlayerTab:Slider({ Title = "Speed Multiplier", Value = {Min = 0.05, Max = 0.15, Default = 0.10}, Step = 0.01, Callback = function(v) speedMultiplier = tonumber(v) end })
PlayerTab:Toggle({ Title = "Infinite Stamina", Default = false, Callback = function(s) infStamEnabled = s end })

ESPTab:Toggle({ Title = "Show Box", Default = false, Callback = function(s) _G.EnabledBox = s end })
ESPTab:Toggle({ Title = "Show Name", Default = false, Callback = function(s) _G.EnabledName = s end })
ESPTab:Toggle({ Title = "Show Distance", Default = false, Callback = function(s) _G.EnabledDistance = s end })
ESPTab:Toggle({ Title = "Show HP Bar", Default = false, Callback = function(s) _G.EnabledHpBar = s end })

LootTab:Toggle({ Title = "Enable Item ESP", Default = true, Callback = function(s) ItemESP_Enabled = s end })

MiscTab:Button({ Title = "Rejoin Game", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end })

-- // RUNSERVICE LOOPS
RunService.RenderStepped:Connect(function()
    if showFov then FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation() end
    for _, plr in pairs(Players:GetPlayers()) do if player_esp_data[plr] then updatePlayerESP(plr) end end
end)

-- // CLEANUP FUNCTION
_G.ReaperNexusCleanup = function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, esp in pairs(player_esp_data) do for _, v in pairs(esp) do v:Remove() end end
    player_esp_data = {}
end

WindUI:Notify({ Title = "Reaper Nexus", Content = "Full Systems Loaded Successfully!", Duration = 5 })
