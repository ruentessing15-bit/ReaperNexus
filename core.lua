-- -- Reaper Nexus ULTIMATE [FULL VERSION - AUTOMATIC DISCORD CLIPBOARD]
-- -- No Thai characters in code

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // CLEANUP PREVIOUS RUNS
if _G.ReaperNexusCleanup then _G.ReaperNexusCleanup() end

-- // GLOBAL DATA POOLS
_G.ReaperNexusConfig = _G.ReaperNexusConfig or {
    Language = "English",
    SilentAimEnabled = false,
    SelectedBodyPart = "Head",
    ShowFov = false,
    FovRadius = 150,
    SpeedEnabled = false,
    SpeedMultiplier = 0.10,
    InfStamEnabled = false,
    EnabledBox = false,
    EnabledName = false,
    EnabledDistance = false,
    EnabledHpBar = false,
    ItemESP_Enabled = true
}

if not player_esp_data then player_esp_data = {} end
if not TargetData then TargetData = {} end

-- // CONFIG SAVE/LOAD HANDLER
local ConfigFileName = "Reaper_Nexus_Save.json"
local function SaveConfig()
    if writefile then
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, _G.ReaperNexusConfig)
        if success then
            writefile(ConfigFileName, encoded)
        end
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFileName) and readfile then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(ConfigFileName))
        if success and type(decoded) == "table" then
            for key, val in pairs(decoded) do
                _G.ReaperNexusConfig[key] = val
            end
        end
    end
end
LoadConfig()

-- // LOCALIZATION DICTIONARY
local Localization = {
    English = {
        Combat = "Combat", SilentAim = "Enable Silent Aim", BodyPart = "Target BodyPart", ShowFov = "Show FOV Circle", FovRadius = "FOV Radius",
        Player = "Player", Speed = "Enable Walk Speed", SpeedAmt = "Speed Multiplier", Stamina = "Infinite Stamina",
        ESP = "ESP", Box = "Show Box", Name = "Show Name", Distance = "Show Distance", HPBar = "Show HP Bar",
        Loot = "Auto Loot", ItemESP = "Enable Item ESP",
        Settings = "Settings", LangSelect = "UI Language", Rejoin = "Rejoin Game", SaveBtn = "Save Configurations",
        Loaded = "Full Systems Loaded Successfully!", SavedNotify = "Configurations saved successfully!",
        ClipboardNotify = "Discord link copied to clipboard!"
    },
    Thai = {
        Combat = "ต่อสู้", SilentAim = "เปิดใช้งาน ล็อกเป้า (Silent Aim)", BodyPart = "ชิ้นส่วนเป้าหมาย", ShowFov = "แสดงวงกลม FOV", FovRadius = "ระยะวงกลม FOV",
        Player = "ผู้เล่น", Speed = "เปิดใช้งาน ความเร็วการเดิน", SpeedAmt = "ตัวคูณความเร็ว", Stamina = "วิ่งไม่จำกัด",
        ESP = "มองทะลุ", Box = "แสดงกรอบ", Name = "แสดงชื่อ", Distance = "แสดงระยะทาง", HPBar = "แสดงหลอดเลือด",
        Loot = "เก็บฟาร์มอัตโนมัติ", ItemESP = "เปิดใช้งาน ไอเทม ESP",
        Settings = "ตั้งค่า", LangSelect = "ภาษาของ UI", Rejoin = "เปลี่ยนเซิร์ฟเวอร์ใหม่", SaveBtn = "บันทึกการตั้งค่าปัจจุบัน",
        Loaded = "โหลดระบบเสร็จสิ้นสมบูรณ์แล้ว!", SavedNotify = "บันทึกข้อมูลการตั้งค่าเรียบร้อยแล้ว!",
        ClipboardNotify = "คัดลอกลิงก์ Discord ลงในคลิปบอร์ดแล้ว!"
    }
}

local function GetText(key)
    local currentLang = _G.ReaperNexusConfig.Language
    if Localization[currentLang] and Localization[currentLang][key] then
        return Localization[currentLang][key]
    end
    return Localization["English"][key] or key
end

-- // 20 KEYS ARRAY
local GeneratedKeys = {
    "ganusn2k1h37n", "b9f8d7e6c5b4a", "x1y2z3w4v5u6t", "m7n8o9p0q1r2s",
    "k3l4m5n6o7p8q", "a1b2c3d4e5f6g", "h7i8j9k0l1m2n", "o3p4q5r6s7t8u",
    "v9w0x1y2z3a4b", "c5d6e7f8g9h0i", "j1k2l3m4n5o6p", "q7r8s9t0u1v2w",
    "x3y4z5a6b7c8d", "e9f0g1h2i3j4k", "l5m6n7o8p9q0r", "s1t2u3v4w5x6y",
    "z7a8b9c0d1e2f", "g3h4i5j6k7l8m", "n9o0p1q2r3s4t", "u5v6w7x8y9z0a"
}

-- // DISCORD LINK CONFIGURATION
local DiscordInviteLink = "https://discord.gg/ar4kTsd38F"

-- // UI WINDOW INITIALIZATION WITH AUTO-CLIPBOARD KEY SYSTEM
local Window = WindUI:CreateWindow({
    Title = "Reaper Nexus",
    Author = "by Nong R",
    Folder = "Reaper_Nexus_Config",
    Icon = "rbxassetid://91476568341639",
    Transparent = true,
    Theme = "Dark",
    KeySystem = { 
        Key = GeneratedKeys,
        Note = "Please enter a valid developer key to unlock Reaper Nexus. Click 'Get Key' to copy the Discord invite link.",
        Thumbnail = { Image = "rbxassetid://91476568341639", Title = "" },
        URL = DiscordInviteLink, -- Standard WindUI redirect fallback
        SaveKey = true,
    },
})
Window:EditOpenButton({ Enabled = false })

-- Hook Get Key click logic directly via setclipboard executor function
task.spawn(function()
    local coreGui = game:GetService("CoreGui")
    local keyWindow = coreGui:WaitForChild("WindUI", 5) and coreGui.WindUI:FindFirstChild("KeySystem") or coreGui:FindFirstChildOfClass("ScreenGui")
    
    if keyWindow then
        local function checkButtons(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("TextButton") and (string.lower(child.Text) == "get key" or string.find(string.lower(child.Name), "getkey")) then
                    child.MouseButton1Click:Connect(function()
                        if setclipboard then
                            setclipboard(DiscordInviteLink)
                            WindUI:Notify({ Title = "System Integration", Content = GetText("ClipboardNotify"), Duration = 3 })
                        elseif toclipboard then
                            toclipboard(DiscordInviteLink)
                            WindUI:Notify({ Title = "System Integration", Content = GetText("ClipboardNotify"), Duration = 3 })
                        end
                    end)
                else
                    checkButtons(child)
                end
            end
        end
        checkButtons(keyWindow)
    end
end)

-- // FLOATING BUTTON (MOBILE OPTIMIZED: 50x50 PX)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReaperNexusFloating"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif getgui then
    ScreenGui.Parent = getgui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Name = "MainButton"
FloatingButton.Parent = ScreenGui
FloatingButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FloatingButton.BorderSizePixel = 0
FloatingButton.Position = UDim2.new(0.05, 0, 0.2, 0)
FloatingButton.Size = UDim2.new(0, 50, 0, 50)
FloatingButton.Image = "rbxassetid://91476568341639"
FloatingButton.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = FloatingButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 1.5
UIStroke.Parent = FloatingButton

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

-- // TAB BUILDING COMPONENT
local Tabs = {}
local function BuildTabs()
    for _, child in pairs(Window:GetChildren()) do
        if child:IsA("Frame") or (child.Name and string.find(child.Name, "Tab")) then
            pcall(function() child:Destroy() end)
        end
    end

    Tabs.Combat = Window:Tab({Title = GetText("Combat"), Icon = "sword"})
    Tabs.Player = Window:Tab({Title = GetText("Player"), Icon = "user"})
    Tabs.ESP = Window:Tab({Title = GetText("ESP"), Icon = "eye"})
    Tabs.Loot = Window:Tab({Title = GetText("Loot"), Icon = "box"}) 
    Tabs.Misc = Window:Tab({Title = GetText("Settings"), Icon = "settings"})

    -- COMBAT
    Tabs.Combat:Toggle({ Title = GetText("SilentAim"), Default = _G.ReaperNexusConfig.SilentAimEnabled, Callback = function(v) _G.ReaperNexusConfig.SilentAimEnabled = v end })
    Tabs.Combat:Dropdown({ Title = GetText("BodyPart"), Default = _G.ReaperNexusConfig.SelectedBodyPart, Values = {"Head", "HumanoidRootPart"}, Callback = function(v) _G.ReaperNexusConfig.SelectedBodyPart = v end })
    Tabs.Combat:Toggle({ Title = GetText("ShowFov"), Default = _G.ReaperNexusConfig.ShowFov, Callback = function(v) _G.ReaperNexusConfig.ShowFov = v end })
    Tabs.Combat:Slider({ Title = GetText("FovRadius"), Value = {Min = 50, Max = 500, Default = _G.ReaperNexusConfig.FovRadius}, Step = 1, Callback = function(v) _G.ReaperNexusConfig.FovRadius = v end })

    -- PLAYER
    Tabs.Player:Toggle({ Title = GetText("Speed"), Default = _G.ReaperNexusConfig.SpeedEnabled, Callback = function(v) _G.ReaperNexusConfig.SpeedEnabled = v end })
    Tabs.Player:Slider({ Title = GetText("SpeedAmt"), Value = {Min = 0.05, Max = 0.50, Default = _G.ReaperNexusConfig.SpeedMultiplier}, Step = 0.01, Callback = function(v) _G.ReaperNexusConfig.SpeedMultiplier = tonumber(v) end })
    Tabs.Player:Toggle({ Title = GetText("Stamina"), Default = _G.ReaperNexusConfig.InfStamEnabled, Callback = function(v) _G.ReaperNexusConfig.InfStamEnabled = v end })

    -- ESP
    Tabs.ESP:Toggle({ Title = GetText("Box"), Default = _G.ReaperNexusConfig.EnabledBox, Callback = function(v) _G.ReaperNexusConfig.EnabledBox = v end })
    Tabs.ESP:Toggle({ Title = GetText("Name"), Default = _G.ReaperNexusConfig.EnabledName, Callback = function(v) _G.ReaperNexusConfig.EnabledName = v end })
    Tabs.ESP:Toggle({ Title = GetText("Distance"), Default = _G.ReaperNexusConfig.EnabledDistance, Callback = function(v) _G.ReaperNexusConfig.EnabledDistance = v end })
    Tabs.ESP:Toggle({ Title = GetText("HPBar"), Default = _G.ReaperNexusConfig.EnabledHpBar, Callback = function(v) _G.ReaperNexusConfig.EnabledHpBar = v end })

    -- LOOT
    Tabs.Loot:Toggle({ Title = GetText("ItemESP"), Default = _G.ReaperNexusConfig.ItemESP_Enabled, Callback = function(v) _G.ReaperNexusConfig.ItemESP_Enabled = v end })

    -- SETTINGS
    Tabs.Misc:Dropdown({
        Title = GetText("LangSelect"),
        Default = _G.ReaperNexusConfig.Language,
        Values = {"English", "Thai"},
        Callback = function(v)
            if _G.ReaperNexusConfig.Language ~= v then
                _G.ReaperNexusConfig.Language = v
                SaveConfig()
                BuildTabs() 
            end
        end
    })
    Tabs.Misc:Button({ Title = GetText("SaveBtn"), Callback = function() SaveConfig() WindUI:Notify({ Title = "Reaper Nexus", Content = GetText("SavedNotify"), Duration = 3 }) end })
    Tabs.Misc:Button({ Title = GetText("Rejoin"), Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end })
end

-- // ESP POOL REGISTRATION
local function CreateESPData(plr)
    if plr == LocalPlayer then return end
    if not player_esp_data[plr] then
        player_esp_data[plr] = {
            Box = Drawing.new("Square"), Name = Drawing.new("Text"), Distance = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"), HealthBarOutline = Drawing.new("Square")
        }
        local e = player_esp_data[plr]
        e.Box.Thickness = 1; e.Box.Filled = false; e.Box.Color = Color3.fromRGB(255, 0, 0)
        e.Name.Size = 14; e.Name.Center = true; e.Name.Outline = true; e.Name.Color = Color3.fromRGB(255, 255, 255)
        e.Distance.Size = 14; e.Distance.Center = true; e.Distance.Outline = true; e.Distance.Color = Color3.fromRGB(255, 255, 255)
        e.HealthBar.Filled = true; e.HealthBarOutline.Thickness = 1; e.HealthBarOutline.Filled = false; e.HealthBarOutline.Color = Color3.fromRGB(0,0,0)
    end
end
for _, p in pairs(Players:GetPlayers()) do CreateESPData(p) end
Players.PlayerAdded:Connect(CreateESPData)
Players.PlayerRemoving:Connect(function(p) if player_esp_data[p] then for _,v in pairs(player_esp_data[p]) do v:Remove() end player_esp_data[p] = nil end end)

-- // CORE LOGIC IMPLEMENTATIONS
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.Color = Color3.fromRGB(0, 255, 0); FOVCircle.Visible = false
local BulletSpeed = 1500
local GunLookup = {["P226"]=true, ["MP5"]=true, ["M24"]=true, ["Draco"]=true, ["Glock"]=true, ["Sawnoff"]=true, ["Uzi"]=true, ["G3"]=true, ["C9"]=true, ["Hunting Rifle"]=true, ["Anaconda"]=true, ["AK47"]=true, ["Remington"]=true, ["Double Barrel"]=true, ["Skorpion"]=true}

local function GetTargetPart(character) return character and character:FindFirstChild(_G.ReaperNexusConfig.SelectedBodyPart) end

local function GetClosestTarget()
    local closest, shortest = nil, math.huge; local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = GetTargetPart(plr.Character)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if (not _G.ReaperNexusConfig.ShowFov or dist <= FOVCircle.Radius) and dist < shortest then shortest = dist closest = plr end
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
    if _G.ReaperNexusConfig.SilentAimEnabled and isGun then
        local target = GetClosestTarget()
        if target and target.Character then
            local tPart = target.Character:FindFirstChild(_G.ReaperNexusConfig.SelectedBodyPart) or target.Character:FindFirstChild("HumanoidRootPart")
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

-- // ESP DRAWING INTERACTION UPDATE
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
        
        esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(x, y); esp.Box.Visible = _G.ReaperNexusConfig.EnabledBox
        esp.Name.Text = player.DisplayName; esp.Name.Position = Vector2.new(x + width / 2, y - 16); esp.Name.Visible = _G.ReaperNexusConfig.EnabledName
        
        local lChar = LocalPlayer.Character; local lRoot = lChar and lChar:FindFirstChild("HumanoidRootPart")
        if lRoot then 
            local dist = math.floor((lRoot.Position - root.Position).Magnitude)
            esp.Distance.Text = tostring(dist) .. "m"; esp.Distance.Position = Vector2.new(x + width / 2, y + height + 2); esp.Distance.Visible = _G.ReaperNexusConfig.EnabledDistance 
        else 
            esp.Distance.Visible = false 
        end
        
        local healthRatio = hum.Health / hum.MaxHealth; local hBarX = x - 6
        esp.HealthBarOutline.Size = Vector2.new(4, height); esp.HealthBarOutline.Position = Vector2.new(hBarX, y); esp.HealthBarOutline.Visible = _G.ReaperNexusConfig.EnabledHpBar
        
        local hHeight = height * healthRatio
        esp.HealthBar.Size = Vector2.new(2, hHeight); esp.HealthBar.Position = Vector2.new(hBarX + 1, y + (height - hHeight)); esp.HealthBar.Color = Color3.fromHSV(healthRatio * 0.3, 1, 1); esp.HealthBar.Visible = _G.ReaperNexusConfig.EnabledHpBar
    else 
        for _, v in pairs(esp) do v.Visible = false end 
    end
end

-- // CHASSIS UPDATES & LOOPS
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ReaperNexusConfig.ShowFov
    FOVCircle.Radius = _G.ReaperNexusConfig.FovRadius
    if _G.ReaperNexusConfig.ShowFov then FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation() end
    for _, plr in pairs(Players:GetPlayers()) do if player_esp_data[plr] then updatePlayerESP(plr) end end
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if _G.ReaperNexusConfig.SpeedEnabled and hum and root then
                if hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + (hum.MoveDirection * _G.ReaperNexusConfig.SpeedMultiplier)
                end
            end
            
            if _G.ReaperNexusConfig.InfStamEnabled and char and char:FindFirstChild("Stamina") then
                local stam = char:FindFirstChild("Stamina")
                if stam:IsA("NumberValue") or stam:IsA("IntValue") then
                    stam.Value = 100
                end
            end
        end)
    end
end)

-- // WORKSPACE INITIAL BUILD
BuildTabs()

-- // CLEANUP ARTIFACT ENGINE
_G.ReaperNexusCleanup = function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, esp in pairs(player_esp_data) do for _, v in pairs(esp) do v:Remove() end end
    player_esp_data = {}
end

WindUI:Notify({ Title = "Reaper Nexus", Content = GetText("Loaded"), Duration = 5 })
