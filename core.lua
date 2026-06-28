-- Reaper Nexus ULTIMATE [FINAL VERSION - 20 RANDOM KEYS]
-- No Thai characters in code logic

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // CLEANUP PREVIOUS RUNS
if _G.ReaperNexusCleanup then _G.ReaperNexusCleanup() end

-- // KEY LIST (20 RANDOM KEYS)
local KEY_LIST = {
    "Zr123", "aung17b9p2n", "rn92k4m1p5z", "nexus7b8v3q", "reaper1p9x2w",
    "candy4m7n2b", "nongr5v8x3z", "delta9k1p4m", "nexus2b7v8q", "reaper3p9x1w",
    "candy5m4n7b", "nongr8v2x9z", "delta1k4p7m", "nexus3b9v2q", "reaper7p1x8w",
    "candy2m9n4b", "nongr4v7x1z", "delta8k2p9m", "nexus1b4v7q", "reaper9p3x2w"
}

-- // UI SETUP
local Window = WindUI:CreateWindow({
    Title = "Reaper Nexus",
    Author = "by Nong R",
    Folder = "Reaper_Nexus_Config",
    Icon = "rbxassetid://91476568341639",
    Transparent = true,
    Theme = "Dark",
    KeySystem = { 
        Key = KEY_LIST,
        Note = "Please enter one of the 20 keys to unlock Reaper Nexus",
        Thumbnail = {
            Image = "rbxassetid://91476568341639",
            Title = "",
        },
        URL = "https://www.google.com",
        SaveKey = true,
    },
})

Window:EditOpenButton({ Enabled = false })

-- // SMALL & TRANSPARENT FLOATING BUTTON
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReaperNexusFloating"
ScreenGui.Parent = game:GetService("CoreGui")

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Name = "MainButton"
FloatingButton.Parent = ScreenGui
FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatingButton.BackgroundTransparency = 0.6
FloatingButton.BorderSizePixel = 0
FloatingButton.Position = UDim2.new(0.02, 0, 0.2, 0)
FloatingButton.Size = UDim2.new(0, 35, 0, 35)
FloatingButton.Image = "rbxassetid://91476568341639"
FloatingButton.ImageTransparency = 0.3
FloatingButton.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = FloatingButton

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
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

FloatingButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

FloatingButton.MouseButton1Click:Connect(function() Window:Toggle() end)

-- // ORIGINAL FUNCTIONS FROM PASTED_CONTENT.TXT
local TargetData = {}; local WeaponDB = {}; local Connections = {}
local SelectedBodyPart = "Head"; local SilentAimEnabled = false; local showFov = false; local BulletSpeed = 1500
local GunLookup = {["P226"]=true, ["MP5"]=true, ["M24"]=true, ["Draco"]=true, ["Glock"]=true, ["Sawnoff"]=true, ["Uzi"]=true, ["G3"]=true, ["C9"]=true, ["Hunting Rifle"]=true, ["Anaconda"]=true, ["AK47"]=true, ["Remington"]=true, ["Double Barrel"]=true, ["Skorpion"]=true}
local FOVCircle = Drawing.new("Circle"); FOVCircle.Radius = 150; FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.Color = Color3.fromRGB(0, 255, 0); FOVCircle.Visible = false
local speedEnabled = false; local speedMultiplier = 0.10; local infStamEnabled = false
_G.EnabledBox = false; _G.EnabledHpBar = false; _G.EnabledName = false; _G.EnabledDistance = false; local ItemESP_Enabled = true

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

-- // TABS
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword"})
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
local LootTab = Window:Tab({Title = "Auto Loot", Icon = "box"}) 
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})

-- // UI ELEMENTS
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

-- // SETTINGS
SettingsTab:Button({ Title = "Boost FPS", Desc = "Disable shadows and effects", Callback = function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("PostProcessEffect") or v:IsA("ParticleEmitter") or v:IsA("Explosion") then v.Enabled = false end
    end
    WindUI:Notify({ Title = "FPS Boost", Content = "Effects disabled!", Duration = 3 })
end })

local currentLang = "EN"
SettingsTab:Button({ Title = "Switch Language (EN/TH)", Desc = "Current: " .. currentLang, Callback = function()
    if currentLang == "EN" then currentLang = "TH" else currentLang = "EN" end
    WindUI:Notify({ Title = "Language", Content = "Switched to " .. currentLang, Duration = 2 })
end })

SettingsTab:Button({ Title = "Rejoin Game", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end })

-- // LOOPS
RunService.RenderStepped:Connect(function()
    if showFov then FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation() end
end)

-- // CLEANUP
_G.ReaperNexusCleanup = function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
end

WindUI:Notify({ Title = "Reaper Nexus", Content = "Ultimate Systems Loaded!", Duration = 5 })
