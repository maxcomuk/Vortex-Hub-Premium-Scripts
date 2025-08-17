-- Disable Anti Cheat
local antikick
antikick = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and typeof(self) == "Instance" and method == "Kick" then
        return nil
    end

    return antikick(self, ...)
end))

local UseBagItemEvent = require(game:GetService("ReplicatedStorage").Modules.RemoteNils)

-- Overwrite the function with a no-op
UseBagItemEvent.UseBagItem = function(...) end

-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Uis = game:GetService("UserInputService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlaceId = game.PlaceId

-- Ingame Remote Events
local PickUpFunction = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Pickup")
local PlantEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("InteractStructure")
local DropEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DropBagItem")

-- KeyAuth application details
local Name = "Maxcomuk's Application"
local OwnerID = "pfgVMVodBB"
local AppVersion = "1.0"

--Getting hwid
local response = http_request({
    Url = "https://httpbin.org/get",
    Method = "GET"
})

-- Creating Hwid
local decoded = HttpService:JSONDecode(response.Body)
local headers = decoded.headers
local executor
if syn and syn.getexecutor then
    executor = syn.getexecutor()
elseif identifyexecutor then
    executor = identifyexecutor() 
else
    executor = nil
end
local hwid = headers[executor .. "-Fingerprint"]

local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/maxcomuk/Roblox-Ui-Libaries/main/Survival%20Odyssey%20Key%20System.lua"))()
local KeyValid = false
local response = KeySystem:Init({
    DiscordLink = "https://discord.gg/8xDgJCxnuY",
    Callback = function(key)
        local initResponse = game:HttpGet(
            "https://keyauth.win/api/1.1/?name=" .. Name ..
            "&ownerid=" .. OwnerID ..
            "&type=init&ver=" .. AppVersion
        )

        local initData = HttpService:JSONDecode(initResponse)
        if not initData.success then
            warn("KeyAuth Init Failed: " .. initData.message)
            return false
        end

        if not hwid then
            Player:Kick("Executor does not support script - Contact me via discord for support")
            return false
        end

        local licenseResponse = game:HttpGet(
            "https://keyauth.win/api/1.1/?name=" .. Name ..
            "&ownerid=" .. OwnerID ..
            "&type=license&key=" .. key ..
            "&ver=" .. AppVersion ..
            "&sessionid=" .. initData.sessionid ..
            "&hwid=".. hwid
        )

        local licenseData = HttpService:JSONDecode(licenseResponse)
        if not licenseData.success then
            warn("KeyAuth License Failed: " .. licenseData.message)
            return false
        end

        KeyValid = true
        return true
    end
})

if not response or not KeyValid then
    return
end

print("Ran Security Checks, user is valid")

-- Safe Part Position
local SafePartPos = Vector3.new(216.9568, 300.8601, -338.1944)

local SafePart = Instance.new("Part")
SafePart.Name = "SafePart"
SafePart.Size = Vector3.new(30, 5, 30)
SafePart.Anchored = true
SafePart.CanCollide = true
SafePart.Color = Color3.fromRGB(0, 0, 0)
SafePart.Transparency = 0
SafePart.Position = SafePartPos
SafePart.Parent = workspace

local Decal = Instance.new("Decal")
Decal.Texture = "rbxassetid://105475483051483"
Decal.Face = Enum.NormalId.Top
Decal.Parent = SafePart

-- Formating positions for hit bypass function
local function formatCFrame(cf)
    local components = {
        cf.Position.X, cf.Position.Y, cf.Position.Z,
        cf.RightVector.X, cf.RightVector.Y, cf.RightVector.Z,
        cf.UpVector.X, cf.UpVector.Y, cf.UpVector.Z,
        cf.LookVector.X, cf.LookVector.Y, cf.LookVector.Z,
    }

    for i = 1, #components do
        components[i] = string.format("%.4f", components[i])
    end

    return "[" .. table.concat(components, ",") .. "]"
end

-- Hit event bypass
local function HitObject(Part)
    local Char = Player.Character or Player.CharacterAdded:Wait()
    local cf = Char:GetPivot()
    local cf1 = Part:GetPivot()
    local CharPos = Char:GetPivot().Position
    
    local args = {
        {
            [formatCFrame(cf)] = Player.Character,
            [formatCFrame(cf1)] = Part,
        },
        workspace:GetServerTimeNow(),
        cf.Position
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SwingTool"):FireServer(unpack(args))
end

-- Loading Ui
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/maxcomuk/Vortex-Hub/main/LunaUi.lua", true))()

if Luna ==  nil then
    Player:Kick("Ui failed to load - check my discord for script status and report")
    return false
end

local Window = Luna:CreateWindow({
	Name = "Survival Odyssey",
	Subtitle = "Vortex Hub - Subscription (Premium)",
	LogoID = nil,
	LoadingEnabled = false,
	LoadingTitle = "Survival Odyssey Ui Loading",
	LoadingSubtitle = "by Vortex Hub",
})


if KeyValid == nil or false then Player:Kick("User tried bypassing script") end

Luna:Notification({
    Title = "Access Granted",
    Icon = "notifications",
    ImageSource = "Material",
    Content = "Thanks for purchasing premium, any problems contact me via discord. Thank you."
})

-- Creating Ui Popup for later use
local AntiAfkScreenGui = nil
local function CreateAntiAfkUi()
    local TweenInfo1 = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
    local Goal = {}
    Goal.Position = UDim2.new(0.5, 0,0, 108)

    local FadeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
    local FadeGoal = {}
    FadeGoal.Transparency = 0.250

    -- Instances:
    local AntiAfk = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")
    local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    local Info = Instance.new("TextLabel")
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
    local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
    local Timer = Instance.new("TextLabel")
    local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
    local CountDown = Instance.new("TextLabel")
    local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")

    --Properties:
    AntiAfk.Name = "Anti-Afk"
    AntiAfk.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    AntiAfk.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AntiAfkScreenGui = AntiAfk

    Main.Name = "Main"
    Main.Parent = AntiAfk
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(7, 0, 59)
    Main.BackgroundTransparency = 1
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.2, 0)
    Main.Size = UDim2.new(0, 381, 0, 109)

    UICorner.Parent = Main

    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 31, 170)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 31, 170))}
    UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.10), NumberSequenceKeypoint.new(1.00, 0.10)}
    UIGradient.Parent = Main

    UIAspectRatioConstraint.Parent = Main
    UIAspectRatioConstraint.AspectRatio = 3.495

    Info.Name = "Info"
    Info.Parent = Main
    Info.AnchorPoint = Vector2.new(0.5, 0.5)
    Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Info.BackgroundTransparency = 1.000
    Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Info.BorderSizePixel = 0
    Info.Position = UDim2.new(0, 190, 0, 32)
    Info.Size = UDim2.new(0, 200, 0, 50)
    Info.Font = Enum.Font.SourceSansBold
    Info.Text = "Anti-Afk Enabled"
    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
    Info.TextSize = 25.000
    Info.TextWrapped = true

    UITextSizeConstraint.Parent = Info
    UITextSizeConstraint.MaxTextSize = 25

    UIAspectRatioConstraint_2.Parent = Info
    UIAspectRatioConstraint_2.AspectRatio = 4.000

    Timer.Name = "Timer"
    Timer.Parent = Main
    Timer.AnchorPoint = Vector2.new(0.5, 0.5)
    Timer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Timer.BackgroundTransparency = 1.000
    Timer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Timer.BorderSizePixel = 0
    Timer.Position = UDim2.new(0, 100, 0, 70)
    Timer.Size = UDim2.new(0.400000036, 0, 0.400000036, 0)
    Timer.Font = Enum.Font.SourceSansBold
    Timer.Text = "Timer: "
    Timer.TextColor3 = Color3.fromRGB(255, 255, 255)
    Timer.TextSize = 20.000
    Timer.TextStrokeTransparency = 0.000

    UIAspectRatioConstraint_3.Parent = Timer
    UIAspectRatioConstraint_3.AspectRatio = 3.495

    CountDown.Name = "CountDown"
    CountDown.Parent = Main
    CountDown.AnchorPoint = Vector2.new(0.5, 0.5)
    CountDown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CountDown.BackgroundTransparency = 1.000
    CountDown.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CountDown.BorderSizePixel = 0
    CountDown.Position = UDim2.new(0, 251, 0, 69)
    CountDown.Size = UDim2.new(0, 152, 0, 43)
    CountDown.Font = Enum.Font.SourceSansBold
    CountDown.Text = "00:00"
    CountDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    CountDown.TextSize = 20.000
    CountDown.TextStrokeTransparency = 0.000

    UIAspectRatioConstraint_4.Parent = CountDown
    UIAspectRatioConstraint_4.AspectRatio = 3.535

    local FadeTween = TweenService:Create(Main, FadeInfo, FadeGoal)
    local Tween = TweenService:Create(Main, TweenInfo1, Goal)

    Tween:Play()
    FadeTween:Play()
    FadeTween.Completed:Wait()

    local StartTime = tick()
    while AntiAfkScreenGui and AntiAfkScreenGui.Parent do
        local elapsed = tick() - StartTime
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)

        CountDown.Text = string.format("%02d:%02d", minutes, seconds)
        task.wait(0.1)
    end
end

local function DestroyAntiAfkUi()
    if AntiAfkScreenGui then
        local TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        local Goal = {}
        Goal.Position = UDim2.new(0.5, 0, 0, 50)
        Goal.BackgroundTransparency = 1

        local Main = AntiAfkScreenGui:FindFirstChild("Main")
        if Main then
            local FadeTween = TweenService:Create(Main, TweenInfo, Goal)
            FadeTween:Play()
            FadeTween.Completed:Wait()
        end

        AntiAfkScreenGui:Destroy()
    end
end

-- Local Player Features
local LocalPlayerMod = {}
LocalPlayerMod.__index = LocalPlayerMod

function LocalPlayerMod.new()
    local self = setmetatable({}, LocalPlayerMod)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    
    self.flyconn = nil
    self.walkspeedconn = nil
    self.jumpconn = nil
    self.noclipconn = nil
    self.infjumpconn = nil

    self.FlyEnabled = false
    self.IsFlying = false
    self.FlySpeed = 50
    self.BodyGyro = nil
    self.BodyVelocity = nil
    self.InputStates = {
        Foward = false,
        BackWard = false,
        Left = false,
        Right = false,
        Up = false,
        Down = false,
    }

    return self
end

function LocalPlayerMod:ApplyFlyMod()
    local function StartFlying()
        if not self.FlyEnabled then return end

        if self.flyconn then
            self.flyconn:Disconnect()
            self.flyconn = nil
        end

        if self.IsFlying then return end
        self.IsFlying = true

        self.Char = Player.Character or Player.CharacterAdded:Wait()
        self.Root = self.Char:WaitForChild("HumanoidRootPart")
        self.Hum = self.Char:WaitForChild("Humanoid")
        if self.Hum then
            self.Hum.PlatformStand = true
        end

        self.BodyGyro = Instance.new("BodyGyro")
        self.BodyGyro.P = 9e4
        self.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        self.BodyGyro.CFrame = self.Root.CFrame
        self.BodyGyro.Parent = self.Root

        self.BodyVelocity = Instance.new("BodyVelocity")
        self.BodyVelocity.Velocity = Vector3.zero
        self.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.BodyVelocity.Parent = self.Root

        self.flyconn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            self.BodyGyro.CFrame = CFrame.new(Vector3.zero, cam.CFrame.LookVector)

            local moveVec = Vector3.zero
            if self.InputStates.Foward then moveVec += cam.CFrame.LookVector end
            if self.InputStates.BackWard then moveVec -= cam.CFrame.LookVector end
            if self.InputStates.Right then moveVec += cam.CFrame.RightVector end
            if self.InputStates.Left then moveVec -= cam.CFrame.RightVector end
            if self.InputStates.Up then moveVec += Vector3.new(0, 1, 0) end
            if self.InputStates.Down then moveVec -= Vector3.new(0, 1, 0) end

            if moveVec.Magnitude > 0 then
                moveVec = moveVec.Unit * self.FlySpeed
            end

            self.BodyVelocity.Velocity = moveVec
        end)
    end

    local function StopFlying()
        if not self.IsFlying then return end
        self.IsFlying = false

        if self.flyconn then self.flyconn:Disconnect() self.flyconn = nil end
        if self.BodyGyro then self.BodyGyro:Destroy() end
        if self.BodyVelocity then self.BodyVelocity:Destroy() end

        if self.Hum then
            self.Hum.PlatformStand = false
        end
    end

    Uis.InputBegan:Connect(function(Input, gameProcessed)
        if gameProcessed then return end

        if Input.KeyCode == Enum.KeyCode.F and self.FlyEnabled then
            if self.IsFlying then
                StopFlying()
            else
                StartFlying()
            end
        end

        if Input.KeyCode == Enum.KeyCode.W then self.InputStates.Foward = true end
        if Input.KeyCode == Enum.KeyCode.S then self.InputStates.BackWard = true end
        if Input.KeyCode == Enum.KeyCode.D then self.InputStates.Right = true end
        if Input.KeyCode == Enum.KeyCode.A then self.InputStates.Left = true end
        if Input.KeyCode == Enum.KeyCode.Space then self.InputStates.Up = true end
        if Input.KeyCode == Enum.KeyCode.LeftControl then self.InputStates.Down = true end
    end)

    Uis.InputEnded:Connect(function(Input)
        if Input.KeyCode == Enum.KeyCode.W then self.InputStates.Foward = false end
        if Input.KeyCode == Enum.KeyCode.S then self.InputStates.BackWard = false end
        if Input.KeyCode == Enum.KeyCode.D then self.InputStates.Right = false end
        if Input.KeyCode == Enum.KeyCode.A then self.InputStates.Left = false end
        if Input.KeyCode == Enum.KeyCode.Space then self.InputStates.Up = false end
        if Input.KeyCode == Enum.KeyCode.LeftControl then self.InputStates.Down = false end
    end)
end

function LocalPlayerMod:ApplyWalkSpeed(Value)
    if self.walkspeedconn then
        self.walkspeedconn:Disconnect()
        self.walkspeedconn = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    if self.Char then
        self.Hum = self.Char:WaitForChild("Humanoid")
        if self.Hum then
            self.Hum.WalkSpeed = Value
            self.walkspeedconn = self.Hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if self.Hum.WalkSpeed ~= Value then
                    self.Hum.WalkSpeed = Value
                end
            end)
        end
    end
end

function LocalPlayerMod:ApplyJumpPower(Value)
    if self.jumpconn then
        self.jumpconn:Disconnect()
        self.jumpconn = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    if self.Char then
        self.Hum = self.Char:WaitForChild("Humanoid")
        if self.Hum then
            self.Hum.JumpPower = Value
            self.jumpconn = self.Hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if self.Hum.JumpPower ~= Value then
                    self.Hum.JumpPower = Value
                end 
            end)
        end
    end
end

function LocalPlayerMod:ApplyNoClip()
    if self.noclipconn then
        self.noclipconn:Disconnect()
        self.noclipconn = nil
    end

    local debounce = false

    self.noclipconn = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        self.Char = Player.Character or Player.CharacterAdded:Wait()
        if self.Char then
            for _, part in pairs(self.Char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        debounce = false
    end)
end

function LocalPlayerMod:DisableNoClip()
    if self.noclipconn then
        self.noclipconn:Disconnect()
        self.noclipconn = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    if self.Char then
        for _, part in pairs(self.Char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end 
        end 
    end 
end

function LocalPlayerMod:ApplyInfJump()
    if self.infjumpconn then
        infjumpconn:Disconnect()
        infjumpconn = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.RootPart = self.Char:WaitForChild("HumanoidRootPart")

    if self.RootPart then
        self.infjumpconn = Uis.InputBegan:Connect(function(input, gpe)
            if gpe then return end

            if input.KeyCode == Enum.KeyCode.Space then
                self.RootPart.Velocity = Vector3.new(self.RootPart.Velocity.X, 50, self.RootPart.Velocity.Z)
            end
        end)
    end
end

function LocalPlayerMod:DisableInfJump()
    if self.infjumpconn then
        self.infjumpconn:Disconnect()
        self.infjumpconn = nil
    end
end

-- Local Player Tab Features
ApplyLocalPlayerMod = LocalPlayerMod.new()
ApplyLocalPlayerMod:ApplyFlyMod()

local LocalPlayerTab = Window:CreateTab({
	Name = "Local Player",
	Icon = "account_circle",
	ImageSource = "Material",
	ShowTitle = true
})

local NoClipToggle = LocalPlayerTab:CreateToggle({
    Name = "NoClip",
    Description = "Lets your character walk through walls / objects",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyLocalPlayerMod:ApplyNoClip()
        else
            ApplyLocalPlayerMod:DisableNoClip()
        end
    end
})

local WalkSpeedSlider = LocalPlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 300},
	Increment = 1,
	CurrentValue = 16,
    Callback = function(Value)
        if Value ~= nil then
            ApplyLocalPlayerMod:ApplyWalkSpeed(Value)
        end
    end
})

local JumpPowerSlider = LocalPlayerTab:CreateSlider({
	Name = "JumpPower",
	Range = {50, 500},
	Increment = 1,
	CurrentValue = 50,
    Callback = function(Value)
        if Value ~= nil then
            ApplyLocalPlayerMod:ApplyJumpPower(Value)
        end
    end
})

local FlyToggle = LocalPlayerTab:CreateToggle({
    Name = "Fly",
    Description = "Press F to fly, Space to go up, Left Control to go down",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyLocalPlayerMod.FlyEnabled = true
        else
            if ApplyLocalPlayerMod.FlyEnabled then ApplyLocalPlayerMod.FlyEnabled = false end
            if ApplyLocalPlayerMod.IsFlying then ApplyLocalPlayerMod.IsFlying = false end
            if ApplyLocalPlayerMod.flyconn then ApplyLocalPlayerMod.flyconn:Disconnect() ApplyLocalPlayerMod.flyconn = nil end
            if ApplyLocalPlayerMod.BodyGyro then ApplyLocalPlayerMod.BodyGyro:Destroy() end
            if ApplyLocalPlayerMod.BodyVelocity then ApplyLocalPlayerMod.BodyVelocity:Destroy() end
            if ApplyLocalPlayerMod.Hum then ApplyLocalPlayerMod.Hum.PlatformStand = false end
        end
    end
})

local FlightSpeedSlider = LocalPlayerTab:CreateSlider({
    Name = "Edit Fly Speed",
    Range = {0, 1000},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        ApplyLocalPlayerMod.FlySpeed = Value
    end
})

local InfJumpToggle = LocalPlayerTab:CreateToggle({
    Name = "Inf Jump",
    Description = "Removes jump cooldown",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyLocalPlayerMod:ApplyInfJump()
        else
            ApplyLocalPlayerMod:DisableInfJump()
        end
    end
})

-- Combat Features
local CombatMod = {}
CombatMod.__index = CombatMod

function CombatMod.new()
    local self = setmetatable({}, CombatMod)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    self.conn1 = nil
    self.conn2 = nil
    self.conn3 = nil
    self.conn4 = nil
    self.conn5 = nil
    
    self.tracerlines = {}

    return self
end

function CombatMod:ApplyKillAura()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local function FindTarget()
        local MaxDistance = 200
        local Target = nil
        for _, child in pairs(Players:GetPlayers()) do
            if child ~= Player and child.Character then
                local OtherChar = child.Character or child.CharacterAdded:Wait()
                local OtherRoot = OtherChar:FindFirstChild("HumanoidRootPart")
                if OtherRoot then
                    local Distance = (self.Root.Position - OtherRoot.Position).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = OtherChar
                    end 
                end
            end
        end
        return Target
    end

    local function HitTarget()
        local Target = FindTarget()
        if Target then
            local Success, Error = pcall(function()
                HitObject(Target)
            end)
            if not Success then
                warn("Failed To Hit Target")
            end
        end
    end

    local debounce = false
    self.conn1 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true
        
        HitTarget()

        debounce = false
    end)
end

function CombatMod:DisableKillAura()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end
end

function CombatMod:ApplyRageKill()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local DefaultTeam = game:GetService("Teams"):FindFirstChild("Neutral")

    local function FindTarget()
        local MaxDistance = math.huge
        local Target = nil

        for _, child in pairs(Players:GetPlayers()) do
            if child ~= Player then
                if child.Team == DefaultTeam then
                    local OtherChar = child.Character or child.CharacterAdded:Wait()
                    local OtherRoot = OtherChar:FindFirstChild("HumanoidRootPart")
                    if OtherChar and OtherRoot then
                        local Distance = (self.Root.Position - OtherRoot.Position).Magnitude
                        if Distance < MaxDistance then
                            MaxDistance = Distance
                            Target = child 
                        end
                    end
                elseif child.Team ~= Player.Team then
                    local OtherChar = child.Character or child.CharacterAdded:Wait()
                    local OtherRoot = OtherChar:FindFirstChild("HumanoidRootPart")
                    if OtherChar and OtherRoot then
                        local Distance = (self.Root.Position - OtherRoot.Position).Magnitude
                        if Distance < MaxDistance then
                            MaxDistance = Distance
                            Target = child 
                        end
                    end
                end
            end
        end
        return Target
    end

    local function HitTarget()
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        local Target = FindTarget()
        if Target and Target.Character then
            local TargetRoot = Target.Character:FindFirstChild("HumanoidRootPart")
            if TargetRoot then
                local aboveposition = TargetRoot.Position - Vector3.new(0, 14, 0)
                self.Root.CFrame = CFrame.new(aboveposition, TargetRoot.Position)
                
                task.wait(0.5)
                HitObject(Target.Character)
                task.wait(0.5)
            end
        end
    end

    self.conn2 = RunService.Heartbeat:Connect(function()
        HitTarget()
    end)
end

function CombatMod:DisableRageKill()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    if self.Root then
        self.Root.CFrame = CFrame.new(self.Root.Position + Vector3.new(25, 25, 25))
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)
    end 
end

local EspCharacterConnections = {}
local function RemoveEsp(Character)
	if not Character then return end
	for _, object in pairs(Character:GetChildren()) do
		if object:IsA("Highlight") and object.Name == "PlayerHighlight" then
			object:Destroy()
		end
	end
end

function CombatMod:ApplyEsp()
	local function CreateEnemyEsp(Character)
		if Character and not Character:FindFirstChild("PlayerHighlight") then
			RemoveEsp(Character)

			local Highlight = Instance.new("Highlight")
			Highlight.Name = "PlayerHighlight"
			Highlight.FillColor = Color3.fromRGB(255, 255, 153)
			Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
			Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			Highlight.Adornee = Character
			Highlight.Parent = Character

			Highlight.AncestryChanged:Connect(function(_, Parent)
				if not Parent then
					Highlight:Destroy()
				end
			end)
		end
	end

    local function HandleEnemies(OtherPlayer)
		local function Apply()
			if OtherPlayer.Character then
				CreateEnemyEsp(OtherPlayer.Character)
			end
		end

		Apply()

		if EspCharacterConnections[OtherPlayer] then
			EspCharacterConnections[OtherPlayer]:Disconnect()
		end

		EspCharacterConnections[OtherPlayer] = OtherPlayer.CharacterAdded:Connect(Apply)
	end

	local function ScanForPlayers()
		for _, OtherPlayer in pairs(Players:GetPlayers()) do
			if OtherPlayer ~= Player then
				HandleEnemies(OtherPlayer)
			end
		end

		self.conn3 = Players.PlayerAdded:Connect(function(NewPlayer)
			if NewPlayer ~= Player then
				HandleEnemies(NewPlayer)
			end
		end)
	end

    ScanForPlayers()
end

function CombatMod:DisableEsp()
    for _, OtherPlayer in pairs(Players:GetPlayers()) do
        if OtherPlayer ~= Player and OtherPlayer.Character then
            RemoveEsp(OtherPlayer.Character)
        end
    end

    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    for OtherPlayer, conn in pairs(EspCharacterConnections) do
        if conn then
            RemoveEsp(OtherPlayer.Character)
        end
    end
end

function CombatMod:ApplyTracers()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    for OtherPlayer, line in pairs(self.tracerlines) do
        if line then
            line.Visible = false
            if line.Remove then
                line:Remove()
            end
        end
    end
    table.clear(self.tracerlines)

    local function CreateTracerLines(Plr)
        if self.tracerlines[Plr] then
            return self.tracerlines[Plr]
        end

        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(0, 0, 255)
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = true

        self.tracerlines[Plr] = line
        return line
    end

    self.conn4 = RunService.RenderStepped:Connect(function()
        local screensize = workspace.CurrentCamera.ViewportSize
        local bottomcenter = Vector2.new(screensize.X / 2, screensize.Y)
        local Camera = workspace.CurrentCamera

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local RootPart = plr.Character.HumanoidRootPart
                local screenpos, onscreen = Camera:WorldToViewportPoint(RootPart.Position)

                local line = CreateTracerLines(plr)

                if onscreen and screenpos.Z > 0 then
                    line.Visible = true
                    line.From = bottomcenter
                    line.To = Vector2.new(screenpos.X, screenpos.Y)
                else
                    line.Visible = false
                end
            else
                if self.tracerlines[plr] then
                    self.tracerlines[plr].Visible = false
                end
            end
        end
    end)
end

function CombatMod:DisableTracerLines()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    for OtherPlayer, line in pairs(self.tracerlines) do
        if line then
            line.Visible = false
            if line.Remove then
                line:Remove()
            end 
        end
    end
    table.clear(self.tracerlines)
end

local SelectedBerry1 = nil
function CombatMod:ApplyAutoEat()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")

    local FindBerry
    local BerryFound = nil

    if SelectedBerry1 then
        FindBerry = function()
            local Folder = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List
            for _, object in pairs(Folder:GetChildren()) do
                for _, child in pairs(object:GetChildren()) do
                    if child:IsA("TextLabel") and child.Text == SelectedBerry1 then
                        BerryFound = tonumber(object.Name)
                        break
                    end
                end
                if BerryFound then break end
            end
        end 
    end

    local remotes = require(game.ReplicatedStorage.Modules.RemoteNils)
    local debounce = false
    self.conn5 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true
        FindBerry()
        if BerryFound and self.Hum.Health < 90 then
            game.ReplicatedStorage.Events.UseBagItem:FireServer(tonumber(BerryFound))
        end
        task.wait(0.2)
        debounce = false
    end)
end

function CombatMod:DisableAutoEat()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end
end

-- Combat Tab Features
local ApplyCombatMod = CombatMod.new()

local CombatTab = Window:CreateTab({
	Name = "Combat / pvp",
	Icon = "sports_mma",
	ImageSource = "Material",
	ShowTitle = true
})

local AutoEatDropDown = CombatTab:CreateDropdown({
    Name = "Select Berry For Auto Eat Toggle",
    Description = "Auto eats selected berry (its basically AUTO HEAL but requires berrys)",
    Options = {"Bluefruit", "Bloodfruit", "Jelly", "Lemon", "Strawberry", "Prickly Pear"},
    CurrentOption = {"Bloodfruit"},
    MultipleOptions = false,
    SpecialType = nil,
    Callback = function(Option)
        if Option ~= nil then
            SelectedBerry1 = Option
        end
    end
})

local AutoEatToggle = CombatTab:CreateToggle({
    Name = "Auto Eat Selected Berry",
    Description = "Auto heals by rapidly eating selected berry",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyCombatMod:ApplyAutoEat()
        else
            ApplyCombatMod:DisableAutoEat()
        end
    end
})

local KillAura = CombatTab:CreateToggle({
    Name = "Kill Aura",
    Description = "Hits All Nearby Players",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyCombatMod:ApplyKillAura()
        else
            ApplyCombatMod:DisableKillAura()
        end
    end
})

local RageKillAura = CombatTab:CreateToggle({
    Name = "Rage Kill All",
    Description = "Kills closest player until whole lobby is dead",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyCombatMod:ApplyRageKill()
        else
            ApplyCombatMod:DisableRageKill()
        end
    end
})

local Esp = CombatTab:CreateToggle({
	Name = "Esp",
	Description = "Highlights All The Enemies",
	CurrentValue = false,
	Callback = function(State)
        if State then
            ApplyCombatMod:ApplyEsp()
        else
            ApplyCombatMod:DisableEsp()
        end
	end
})

local TracerlinesToggle = CombatTab:CreateToggle({
    Name = "Tracer Lines",
    Description = "Creates lines pointing to all the players in the game",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyCombatMod:ApplyTracers()
        else
            ApplyCombatMod:DisableTracerLines()
        end
    end
})

-- Main Features
local MainMod = {}
MainMod.__index = MainMod

function MainMod.new()
    local self = setmetatable({}, MainMod)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    self.conn1 = nil
    self.conn2 = nil
    self.conn3 = nil
    self.conn4 = nil
    self.conn5 = nil
    self.conn6 = nil
    self.conn7 = nil
    self.conn8 = nil

    self.LastSavedPos = nil

    return self
end

function MainMod:ApplyAutoBreakResources()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local ResourcesFolder = workspace.Map.Resources
    local function FindTarget()
        local MaxDistance = 50
        local Target = nil
        for _, object in pairs(ResourcesFolder:GetChildren()) do
            for _, child in pairs(object:GetChildren()) do
                if child:IsA("Model") then
                    local Pos = child:GetPivot().Position
                    local Distance = (self.Root.Position - Pos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
        end
        return Target
    end

    local function HitTarget()
        local Target = FindTarget()
        if Target then
            local Success, Error = pcall(function()
                HitObject(Target)
            end)
            if not Success then
                warn("Unable To Hit Target")
            end
        end
    end

    local debounce = false
    self.conn1 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        HitTarget()

        debounce = false
    end)
end

function MainMod:DisableAutoBreakResources()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end
end

function MainMod:ApplyAutoHitCritters()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local CrittersFolder = workspace.Important.Critters
    local function FindTarget()
        local MaxDistance = 200
        local Target = nil
        if CrittersFolder then
            for _, child in pairs(CrittersFolder:GetChildren()) do
                if child:IsA("Model") then
                    local Pos = child:GetPivot().Position
                    local Distance = (self.Root.Position - Pos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    local function HitTarget()
        local Target = FindTarget()
        if Target then
            local Success, Error = pcall(function()
                HitObject(Target)
            end)
            if not Success then
                warn("Failed To Hit Target")
            end
        end
    end

    local debounce = false
    self.conn2 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        HitTarget()

        debounce = false
    end)
end

function MainMod:DisableAutoHitCritters()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end
end

function MainMod:ApplyAutoHitStructures()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local Folder1 = workspace.Important.Deployables
    local Folder2 = workspace.Important.Rubble

    local function FindStructure()
        local MaxDistance = 200
        local Target = nil
        for _, object in pairs(Folder1:GetChildren()) do
            if object:IsA("Model") then
                local Pos = object:GetPivot().Position
                local Distance = (self.Root.Position - Pos).Magnitude
                if Distance < MaxDistance then
                    MaxDistance = Distance
                    Target = object
                end
            end
        end
        return Target
    end

    local function FindRubble()
        local MaxDistance = 200
        local Target = nil
        for _, object in pairs(Folder2:GetChildren()) do
            if object:IsA("Model") then
                local Pos = object:GetPivot().Position
                local Distance = (self.Root.Position - Pos).Magnitude
                if Distance < MaxDistance then
                    MaxDistance = Distance
                    Target = object
                end
            end
        end
        return Target
    end

    local function HitTarget()
        local Target1 = FindStructure()
        local Target2 = FindRubble()
        if Target1 and Target2 then
            local Distance1 = (Target1:GetPivot().Position - Root.Position).Magnitude
            local Distance2 = (Target2:GetPivot().Position - Root.Position).Magnitude
            if Distance1 < Distance2 then
                HitObject(Target1)
            else
                HitObject(Target2)
            end
        end
        if Target1 then
            HitObject(Target1)
        elseif Target2 then
            HitObject(Target2)
        end
    end

    local debounce = false
    self.conn3 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        HitTarget()

        debounce = false
    end)
end

function MainMod:DisableAutoHitStructures()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end
end

function MainMod:ApplyAutoPickup()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

	local ItemsFolder = workspace.Important:FindFirstChild("Items")
	local FruitsFolder = workspace.Important:FindFirstChild("Homeless")

	local function FindNearest(folder, range)
		local closest, closestDist = nil, range
		for _, obj in pairs(folder:GetChildren()) do
			local pos
			if obj:IsA("BasePart") then
				pos = obj.Position
			elseif obj:IsA("Model") then
				pos = obj:GetPivot().Position
			end
			if pos then
				local dist = (self.Root.Position - pos).Magnitude
				if dist < closestDist then
					closest, closestDist = obj, dist
				end
			end
		end
		return closest
	end

	local function PickUpTarget()
		local item = ItemsFolder and FindNearest(ItemsFolder, 100)
		local fruit = FruitsFolder and FindNearest(FruitsFolder, 200)

		local target
		if item and fruit then
			local d1 = (item:GetPivot().Position - self.Root.Position).Magnitude
			local d2 = (fruit:GetPivot().Position - self.Root.Position).Magnitude
			target = (d1 < d2) and item or fruit
		else
			target = item or fruit
		end

		if target then
			local success, err = pcall(function()
				PickUpFunction:InvokeServer(target)
			end)
			if not success then
				warn("Pickup failed:", err)
			end
		end
	end

    local debounce = false
    self.conn4 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        PickUpTarget()

        debounce = false
    end)
end

function MainMod:DisableAutoPickup()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end
end

local PlantDetected = nil
function MainMod:ApplyAutoPlant()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local Folder = workspace.Important.Deployables
    local debounce = false

    self.conn5 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        for _, object in pairs(Folder:GetChildren()) do
            if object.Name == "Plant Box" then
                PlantEvent:FireServer(object, PlantDetected)
                task.wait(0.1)
            end
        end

        debounce = false
    end)
end

function MainMod:DisableAutoPlant()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end
end

function MainMod:ApplyAutoPlant1()
    if self.conn6 then
        self.conn6:Disconnect()
        self.conn6 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local debounce = false
    local Folder = workspace.Important.Deployables

    local function FindTarget()
        local Target = nil
        local MaxDistance = 100
        
        for _, object in pairs(Folder:GetChildren()) do
            if object.Name == "Plant Box" and not object:FindFirstChild("Plant", true) then
                local distance = (object:GetPivot().Position - self.Root.Position).Magnitude
                if distance < MaxDistance then
                    MaxDistance = distance
                    Target = object
                end
            end
        end
        
        return Target
    end

    self.conn6 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        local Target = FindTarget()
        if Target and PlantDetected then
            PlantEvent:FireServer(Target, PlantDetected)
            task.wait(0.1)
        end

        debounce = false
    end)
end

function MainMod:DisableAutoPlant1()
    if self.conn6 then
        self.conn6:Disconnect()
        self.conn6 = nil
    end
end

function MainMod:ApplyAutoPlantPickup()
    if self.conn7 then
        self.conn7:Disconnect()
        self.conn7 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.LastSavedPos = self.Root.Position

    local debounce = false
    local Folder = workspace.Important.Deployables

    self.conn7 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        self.Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))

        for _, object in pairs(Folder:GetChildren()) do
            if object.Name == "Plant Box" then
                for _, child in pairs(object:GetChildren()) do
                    if child:IsA("Model") and child.Name == "Coconut" then
                        for _, coco in pairs(child:GetChildren()) do
                            if coco:IsA("Model") then
                                self.Root.CFrame = CFrame.new(child:GetPivot().Position + Vector3.new(0, 5, 0))
                                task.wait(0.1)
                                PickUpFunction:InvokeServer(coco)
                                task.wait(0.1)
                                self.Root.Velocity = Vector3.new(0, 0, 0)
                                self.Root.RotVelocity = Vector3.new(0, 0, 0)   
                            end
                        end
                    elseif child:IsA("Model") and child.Name ~= "Coconut" then
                        self.Root.CFrame = CFrame.new(child:GetPivot().Position + Vector3.new(0, 5, 0))
                        task.wait(0.1)
                        PickUpFunction:InvokeServer(child)
                        task.wait(0.1)
                        self.Root.Velocity = Vector3.new(0, 0, 0)
                        self.Root.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end

        task.wait(0.1)
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        debounce = false
    end)
end

function MainMod:DisableAutoPlantPickUp()
    if self.conn7 then
        self.conn7:Disconnect()
        self.conn7 = nil
    end

    task.wait(0.3)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    
    self.Root.CFrame = CFrame.new(self.LastSavedPos)
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function MainMod:ApplyAutoPlantPickup1()
    if self.conn8 then
        self.conn8:Disconnect()
        self.conn8 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    local debounce = false
    local Folder = workspace.Important.Deployables

    self.conn8 = RunService.Heartbeat:Connect(function()
        if debounce then return end
        debounce = true

        local MaxDistance = 200
        for _, object in pairs(Folder:GetChildren()) do
            if object.Name == "Plant Box" then
                for _, child in pairs(object:GetChildren()) do
                    if child:IsA("Model") then
                        local distance = (child:GetPivot().Position - self.Root.Position).Magnitude
                        if distance < MaxDistance then
                            PickUpFunction:InvokeServer(child)
                        end
                    end
                end
            end
        end

        debounce = false
    end)
end

function MainMod:DisableAutoPlantPickup1()
    if self.conn8 then
        self.conn8:Disconnect()
        self.conn8 = nil
    end
end

-- Main Tab Features
ApplyMainMod = MainMod.new()

local MainTab = Window:CreateTab({
	Name = "Main",
	Icon = "dashboard",
	ImageSource = "Material",
	ShowTitle = true
})

local MainTabLabel1 = MainTab:CreateLabel({
	Text = "You must re-apply these features, if you have respawned or died",
	Style = 1
})

local AutoHitResourcesToggle = MainTab:CreateToggle({
    Name = "Auto Break Resources",
    Description = "Hits all nearby resources such as nodes and trees etc",
    CurrentValue = false,
    Callback = function(State)
        if State then
            MainMod:ApplyAutoBreakResources()
        else
            MainMod:DisableAutoBreakResources()
        end
    end
})

local AutoHitCritters = MainTab:CreateToggle({
    Name = "Auto Hit Critters",
    Description = "Hits all animals and ants etc",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoHitCritters()
        else
            ApplyMainMod:DisableAutoHitCritters()
        end
    end
})

local AutoHitStructures = MainTab:CreateToggle({
    Name = "Auto Break Structures",
    Description = "Hits all nearby structures",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoHitStructures()
        else
            ApplyMainMod:DisableAutoHitStructures()
        end
    end
})

local PickUpConnection
local PickUpState = false
local AutoPickup = MainTab:CreateToggle({
	Name = "Auto Pickup",
	Description = "Auto picks up drops nearby",
	CurrentValue = false,
	Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoPickup()
        else
            ApplyMainMod:DisableAutoPickup()
        end
	end
})

MainTab:CreateSection("Planting Features Below")

local AutoPlantDropDown = MainTab:CreateDropdown({
	Name = "Auto Plant Berry Selection",
    Description = nil,
	Options = {"Coconut", "Bluefruit", "Bloodfruit", "Jelly", "Lemon", "Strawberry", "Prickly Pear"},
    CurrentOption = {"Bluefruit"},
    MultipleOptions = false,
    SpecialType = nil,
    Callback = function(Options)
        if Options ~= nil then
            PlantDetected = Options
        end
	end
})

local AutoPlantToggle = MainTab:CreateToggle({
    Name = "Auto Plant All Plant Boxes From Selected Berry",
    Description = "Plants selected berry to all plant boxes on the map",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoPlant()
        else
            ApplyMainMod:DisableAutoPlant()
        end
    end
})

local AutoPickupToggle = MainTab:CreateToggle({
    Name = "Auto Pick Up All Berry's",
    Description = "Picks up all berry's on the map from the plant boxes",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoPlantPickup()
        else
            ApplyMainMod:DisableAutoPlantPickUp()
        end
    end
})

local AutoPlantToggle1 = MainTab:CreateToggle({
    Name = "Auto Plant All Nearby Plant Boxes From Selected Berry",
    Description = "Plants selected berry only to nearby plant boxes",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoPlant1()
        else
            ApplyMainMod:DisableAutoPlant1()
        end
    end 
})

local AutoPickupToggle1 = MainTab:CreateToggle({
    Name = "Auto Pick Up Nearby Berry's",
    Description = "Picks up all nearby berry's from the plant boxes",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyMainMod:ApplyAutoPlantPickup1()
        else
            ApplyMainMod:DisableAutoPlantPickup1()
        end
    end
})

-- Auto Farm Features
local AutoFarmMod = {}
AutoFarmMod.__index = AutoFarmMod

function AutoFarmMod.new()
    local self = setmetatable({}, AutoFarmMod)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    self.Root = self.Char:WaitForChild("HumanoidRootPart")

    self.conn1 = nil
    self.conn2 = nil
    self.conn3 = nil
    self.conn4 = nil
    self.conn5 = nil
    self.conn6 = nil
    self.conn7 = nil
    self.conn8 = nil
    self.conn9 = nil
    self.conn10 = nil
    self.conn11 = nil
    self.conn12 = nil
    self.conn13 = nil

    return self
end

function AutoFarmMod:ApplySunTreeFarm()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local FindTree
    local FindFeatherBush
    local PickupEssence

    local SunTreeFolder = workspace.Map.Resources["Sun Tree"]
    if SunTreeFolder then
        FindTree = function()
            local MaxDistance = math.huge
            local Target = nil
            
            for _, child in pairs(SunTreeFolder:GetChildren()) do
                if child:IsA("Model") then
                    local ChildPos = child:GetPivot().Position
                    local Distance = (self.Root.Position - ChildPos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    local FeatherBushesFolder = workspace.Map.Resources["Feather Bush"]
    if FeatherBushesFolder then
		FindFeatherBush = function()
			local MaxDistance = math.huge
			local Target = nil

			for _, child in pairs(FeatherBushesFolder:GetChildren()) do
				if child:IsA("Model") then
					local ChildPos = child:GetPivot().Position
					local Distance = (self.Root.Position - ChildPos).Magnitude
					if Distance < MaxDistance then
						MaxDistance = Distance
						Target = child
					end
				end
			end
			return Target
		end
    end

    local ItemsFolder = workspace.Important.Items
    if ItemsFolder then
        PickupEssence = function()
            local MaxDistance = 50
            local Target = nil

            for _, child in pairs(ItemsFolder:GetChildren()) do
                if child.Name == "Essence" and child:IsA("BasePart") then
                    local Pos = child.Position
                    local Distance = (self.Root.Position - Pos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    local function FindTarget(SunTree, FeatherBush)
        local Target = nil

        if SunTree and FeatherBush then
            local TreePos = (SunTree:GetPivot().Position - self.Root.Position).Magnitude
            local BushPos = (FeatherBush:GetPivot().Position - self.Root.Position).Magnitude

            if BushPos < TreePos then
                Target = FeatherBush
            elseif TreePos < BushPos then
                Target = SunTree
            else
                Target = FeatherBush
            end
            
            return Target
        end

        if SunTree then
            Target = SunTree
            return Target
        end

        if FeatherBush then
            Target = FeatherBush
            return Target
        end

        return false
    end

    local GrabbingEssence = false
    self.conn1 = RunService.Heartbeat:Connect(function()
        if GrabbingEssence then return end
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        local SunTree = FindTree()
        local FeatherBush = FindFeatherBush()
        
        local Target = FindTarget(SunTree, FeatherBush)
        if Target then
            task.wait(0.1)
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 14, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            local Essence = PickupEssence()
            if Essence then
                GrabbingEssence = true
                self.Root.CFrame = CFrame.new(Essence.Position + Vector3.new(0, 5, 0))
                PickUpFunction:InvokeServer(Essence)
                task.wait(0.3)
                GrabbingEssence = false
            end
        else
            self.Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))
            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableSunTreeFarm()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end

    task.wait(0.3)

    self.Char = Player.Character or player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = false
    end

    if self.Root then
        self.Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)
    end
end

function AutoFarmMod:ApplyAncientTreeFarm()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Map.Resources["Ancient Tree"]["Ancient Tree"]
        end)
        return Success and Result or nil
    end

    local TargetPos = Vector3.new(-106.98133850097656, 344.60980224609375, 239.3901824951172)
    self.Root.CFrame = CFrame.new(TargetPos)

    self.conn2 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 15, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableAncientTreeFarm()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    task.wait(0.3)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    if self.Root then
        self.Root.CFrame = CFrame.new(Vector3.new(-106.98133850097656, 344.60980224609375, 239.3901824951172))
        self.Hum = self.Char:WaitForChild("Humanoid")
        if self.Hum then
            self.Hum.PlatformStand = false
        end
    end
end

function AutoFarmMod:ApplyGoldFarm()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local FindTarget
    local FindGold
    local GrabbingGold = false

    local GoldNodes = workspace.Map.Resources["Gold Node"]
    if GoldNodes then
        FindTarget = function()
            local MaxDistance = math.huge
            local Target = nil

            for _, child in pairs(GoldNodes:GetChildren()) do
                if child:IsA("Model") then
                    local Pos = child:GetPivot().Position
                    local Distance = (self.Root.Position - Pos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    local ItemsFolder = workspace.Important.Items
    if ItemsFolder then
        FindGold = function()
            local MaxDistance = 50
            local Target = nil

            for _, child in pairs(ItemsFolder:GetChildren()) do
                if child.Name == "Raw Gold" or child.Name == "Big Raw Gold" then
                    local Pos = child.Position
                    local Distance = (self.Root.Position - Pos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    self.conn3 = RunService.Heartbeat:Connect(function()
        if GrabbingGold then return end
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        local Target = FindTarget()
        if Target then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 14, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            task.wait(0.5)
            HitObject(Target)

            local goldfound = FindGold()
            if goldfound then
                GrabbingGold = true
                self.Root.CFrame = CFrame.new(Target:GetPivot().Position)
                PickUpFunction:InvokeServer(goldfound)
                for i = 1, 5 do
                    local newgold = FindGold()
                    if newgold then
                        PickUpFunction:InvokeServer(goldfound)
                    end
                    task.wait(0.1)
                end
                GrabbingGold = false
            end
        end
    end)
end

function AutoFarmMod:DisableGoldFarm()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    task.wait(0.3)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)

    self.Hum.PlatformStand = false
end

function AutoFarmMod:ApplyIronFarm()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local FindIron
    local FindRawIron
    local GrabbingIron = false

    local IronFolder = workspace.Map.Resources["Iron Node"]
    if IronFolder then
        FindIron = function()
            local MaxDistance = math.huge
            local Target = nil

            for _, child in pairs(IronFolder:GetChildren()) do
                if child:IsA("Model") then
                    local Distance = (child:GetPivot().Position - self.Root.Position).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    local ItemsFolder = workspace.Important.Items
    if ItemsFolder then
        FindRawIron = function()
            local MaxDistance = 50
            local Target = nil

            for _, child in pairs(ItemsFolder:GetChildren()) do
                if child.Name == "Raw Iron" then
                    local Distance = (child.Position - self.Root.Position).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    self.conn4 = RunService.Heartbeat:Connect(function()
        if GrabbingIron then return end
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        local Iron = FindIron()
        if Iron then
            local belowposition = Iron:GetPivot().Position - Vector3.new(0, 5, 0)
            self.Root.CFrame = CFrame.new(belowposition, Iron:GetPivot().Position)
            task.wait(0.5)
            HitObject(Iron)

            local RawIron = FindRawIron()
            if RawIron then
                GrabbingIron = true

                self.Root.CFrame = CFrame.new(Iron:GetPivot().Position + Vector3.new(0, 10, 0))
                PickUpFunction:InvokeServer(RawIron)

                for i = 1, 5 do
                    local newrawiron = FindRawIron()
                    if newrawiron then
                        PickupEvent:InvokeServer(newrawiron)
                    end
                    task.wait(0.1)
                end
                GrabbingIron = false
            end
        end
    end)
end

function AutoFarmMod:DisableIronFarm()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)

    self.Hum.PlatformStand = false
end

function AutoFarmMod:ApplyOldGodFarm()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local TargetPos = Vector3.new(-62.545448303222656, -119.00000762939453, -972.10009765625)
    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.Gods["Old God"]
        end)
        return Success and Result or nil
    end

    self.Root.CFrame = CFrame.new(TargetPos)
    self.conn5 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target and Target:FindFirstChild("Health") and Target.Health.Value > 1000 then
            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)

            local belowposition = Target:GetPivot().Position - Vector3.new(0, 15, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)
        end
        
        if Target and Target:FindFirstChild("Health") and Target.Health.Value <= 1000 then
            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)

            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 25, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)
        end
    end)
end

function AutoFarmMod:DisableOldGodFarm()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end

    self.Char = Player.character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(-62.545448303222656, -119.00000762939453, -972.10009765625))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyWealthyGodFarm()
    if self.conn6 then
        self.conn6:Disconnect()
        self.conn6 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local success, result = pcall(function()
            return workspace.Map.Resources.Gods:FindFirstChild("Wealthy God")
        end)
        return success and result or nil
    end

    local TargetPos = Vector3.new(1500.572, 1.077, 31.321)
    self.Root.CFrame = CFrame.new(TargetPos)
    self.conn6 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target and Target:FindFirstChild("Health") and Target.Health.Value > 1000 then
            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)

            local belowposition = Target:GetPivot().Position - Vector3.new(0, 15, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)
        end

        if Target and Target:FindFirstChild("Health") and Target.Health.Value <= 1000 then
            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)

            local aboveposition = Target:GetPivot().Position + Vector3.new(10, 15, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)
        end
    end)
end

function AutoFarmMod:DisableWealthyGodFarm()
    if self.conn6 then
        self.conn6:Disconnect()
        self.conn6 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(1500.572, 1.077, 31.321))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyMiserableGodFarm()
    if self.conn7 then
        self.conn7:Disconnect()
        self.conn7 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.Gods["Miserable God"]
        end)
        return Success and Result or nil
    end

    local TargetPos = Vector3.new(268.2744140625, 162.91293334960938, -440.75860595703125)
    self.Root.CFrame = CFrame.new(TargetPos)
    self.conn7 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target and Target:FindFirstChild("Health") and Target.Health.Value > 1000 then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 15, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        if Target and Target:FindFirstChild("Health") and Target.Health.Value <= 1000 then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 30, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableMiserableGodFarm()
    if self.conn7 then
        self.conn7:Disconnect()
        self.conn7 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(268.2744140625, 162.91293334960938, -440.75860595703125))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyMaleoventGodFarm()
    if self.conn8 then
        self.conn8:Disconnect()
        self.conn8 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.God["Malevolent God"]
        end)
        return Success and Result or nil
    end

    local TargetPos = Vector3.new(-363.70452880859375, -60.634422302246094, 374.07684326171875)
    self.Root.CFrame = CFrame.new(TargetPos)
    self.conn8 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target and Target:FindFirstChild("Health") and Target.Health.Value > 1000 then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 20, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end

        if Target and Target:FindFirstChild("Health") and Target.Health.Value <= 1000 then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 25, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableMaleoventGodFarm()
    if self.conn8 then
        self.conn8:Disconnect()
        self.conn8 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(-363.70452880859375, -60.634422302246094, 374.07684326171875))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyGlowFarm()
    if self.conn9 then
        self.conn9:Disconnect()
        self.conn9 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local FindLargeTree
    local FindBigTree
    local FindTree
    local FindBush
    local PickupEssence

    local LargeTreeFolder = workspace.Map.Resources["Large Glowing Tree"]
    if LargeTreeFolder then
        FindLargeTree = function()
            local MaxDistance = math.huge
            local Target = nil

            for _, child in pairs(LargeTreeFolder:GetChildren()) do
                if child:IsA("Model") then
                    local childpos = child:GetPivot().Position
                    local distance = (self.Root.Position - childpos).Magnitude
                    if distance < MaxDistance then
                        MaxDistance = distance
                        Target = child
                    end
                end
            end

            return Target
        end
    end

    local BigTreeFolder = workspace.Map.Resources["Big Glowing Tree"]
    if BigTreeFolder then
        FindBigTree = function()
            local MaxDistance = math.huge
            local Target = nil

            for _, child in pairs(LargeTreeFolder:GetChildren()) do
                local childpos = child:GetPivot().Position
                local distance = (self.Root.Position - childpos).Magnitude
                if distance < MaxDistance then
                    MaxDistance = distance
                    Target = child
                end
            end

            return Target
        end
    end

    local TreeFolder = workspace.Map.Resources["Glowing Tree"]
    if TreeFolder then
        FindTree = function()
            local MaxDistance = math.huge
            local Target = nil

            for _, child in pairs(TreeFolder:GetChildren()) do
                local childpos = child:GetPivot().Position
                local distance = (self.Root.Position - childpos).Magnitude
                if distance < MaxDistance then
                    MaxDistance = distance
                    Target = child
                end
            end

            return Target
        end
    end

    local BushFolder = workspace.Map.Resources["Glowing Bush"]
    if BushFolder then
        FindBush = function()
            local MaxDistance = math.huge
            local Target = nil

            for _, child in pairs(TreeFolder:GetChildren()) do
                local childpos = child:GetPivot().Position
                local distance = (self.Root.Position - childpos).Magnitude
                if distance < MaxDistance then
                    MaxDistance = distance
                    Target = child
                end
            end

            return Target
        end
    end

    local ItemsFolder = workspace.Important.Items
    if ItemsFolder then
        PickupEssence = function()
            local MaxDistance = 50
            local Target = nil

            for _, child in pairs(ItemsFolder:GetChildren()) do
                if child.Name == "Essence" and child:IsA("BasePart") then
                    local Pos = child.Position
                    local Distance = (self.Root.Position - Pos).Magnitude
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = child
                    end
                end
            end
            return Target
        end
    end

    local function FindTarget(LargeTree, BigTree, Tree, Bush)
        local Target = nil
        local closestDistance = math.huge

        local function checkAndSet(obj)
            if obj then
                local dist = (obj:GetPivot().Position - self.Root.Position).Magnitude
                if dist < closestDistance then
                    closestDistance = dist
                    Target = obj
                end
            end
        end

        checkAndSet(LargeTree)
        checkAndSet(BigTree)
        checkAndSet(Tree)
        checkAndSet(Bush)

        return Target
    end

    local GrabbingEssence = false
    self.conn9 = RunService.Heartbeat:Connect(function()
        if GrabbingEssence then return end
        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        local LargeTree = FindLargeTree()
        local BigTree = FindBigTree()
        local Tree = FindTree()
        local Bush = FindBush()
        
        local Target = FindTarget(LargeTree, BigTree, Tree, Bush)
        if Target then
            task.wait(0.1)
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 14, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            local Essence = PickupEssence()
            if Essence then
                GrabbingEssence = true
                self.Root.CFrame = CFrame.new(Essence.Position + Vector3.new(0, 5, 0))
                PickUpFunction:InvokeServer(Essence)
                GrabbingEssence = false
            end
        end
    end)
end

function AutoFarmMod:DisableGlowFarm()
    if self.conn9 then
        self.conn9:Disconnect()
        self.conn9 = nil
    end

    task.wait(0.3)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(self.Root.Position + Vector3.new(0, 50, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyStoneFarm()
    if self.conn10 then
        self.conn10:Disconnect()
        self.conn10 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local FindTarget
    local FindStone

    local Folder = workspace.Map.Resources["Stone Node"]
    if Folder then
        FindTarget = function()
            local Target = nil
            local MaxDistance = math.huge

            for _, object in pairs(Folder:GetChildren()) do
                if object:IsA("Model") then
                    local distance = (object:GetPivot().Position - self.Root.Position).Magnitude
                    if distance < MaxDistance then
                        MaxDistance = distance
                        Target = object
                    end
                end
            end

            return Target
        end
    end

    local ItemsFolder = workspace.Important.Items
    if ItemsFolder then
        FindStone = function()
            local Target = nil
            local MaxDistance = 50

            for _, object in pairs(ItemsFolder:GetChildren()) do
                if object.Name == "Stone" then
                    local distance = (object.Position - self.Root.Position).Magnitude
                    if distance < MaxDistance then
                        MaxDistance = distance
                        Target = object
                    end
                end
            end

            return Target
        end
    end

    local GrabbingStone = false
    self.conn10 = RunService.Heartbeat:Connect(function()
        if GrabbingStone then return end

        self.Root.Velocity = Vector3.new(0, 0, 0)
        self.Root.RotVelocity = Vector3.new(0, 0, 0)

        local Target = FindTarget()
        if Target then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 8, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            task.wait(0.5)
            HitObject(Target)

            local Stone = FindStone()
            if Stone then
                GrabbingStone = true

                local aboveposition = Stone.Position + Vector3.new(0, 5, 0)
                self.Root.CFrame = CFrame.new(aboveposition)
                task.wait(0.1)
                PickUpFunction:InvokeServer(Stone)

                for i = 1, 10 do
                    local newstone = FindStone()
                    if newstone then
                        PickUpFunction:InvokeServer(newstone)
                    end
                end

                GrabbingStone = false
            end
        end
    end)
end

function AutoFarmMod:DisableStoneFarm()
    if self.conn10 then
        self.conn10:Disconnect()
        self.conn10 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyOverGrownGodFarm()
    if self.conn11 then
        self.conn11:Disconnect()
        self.conn11 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    if self.Hum then
        self.Hum.PlatformStand = true
    end
    self.Root.CFrame = CFrame.new(Vector3.new(Vector3.new(680.6983642578125, 264.61810302734375, -1180.3209228515625) + Vector3.new(0, 5, 0)))

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.Gods["Overgrown God"]
        end)
        return Success and Result or nil
    end

    self.conn11 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target and Target.Health.Value > 1000 then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 18, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end 
        
        if Target and Target.Health.Value <= 1000 then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 15, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableOverGrownGodFarm()
    if self.conn11 then
        self.conn11:Disconnect()
        self.conn11 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(653.0509643554688, -339.3125305175781, 1011.7593994140625) + Vector3.new(0, 5, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyRadientGodFarm()
    if self.conn12 then
        self.conn12:Disconnect()
        self.conn12 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    self.Hum.PlatformStand = true

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.Gods["Radiant God"]
        end)
        return Success and Result or nil
    end

    self.conn12 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target and Target.Health.Value > 1000 then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 18, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        elseif Target and Target.Health.Value <= 1000 then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 20, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableRadientGodFarm()
    if self.conn12 then
        self.conn12:Disconnect()
        self.conn12 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(789.7384033203125, 132.99998474121094, 60.3469123840332) + Vector3.new(0, 5, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoFarmMod:ApplyColdGodFarm()
    if self.conn13 then
        self.conn13:Disconnect()
        self.conn13 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = true
    self.Root.CFrame = CFrame.new(Vector3.new(Vector3.new(680.6983642578125, 264.61810302734375, -1180.3209228515625) + Vector3.new(0, 5, 0)))

    local function FindTarget1()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.Gods["Frozen God"]
        end)
        return Success and Result or nil
    end

    local function FindTarget2()
        local Success, Result = pcall(function()
            return workspace.Map.Resources.Gods["Cold God"]
        end)
        return Success and Result or nil
    end

    self.conn13 = RunService.Heartbeat:Connect(function()
        local Frozen = FindTarget1()
        if Frozen then
            local belowposition = Frozen:GetPivot().Position - Vector3.new(0, 18, 0)
            self.Root.CFrame = CFrame.new(belowposition, Frozen:GetPivot().Position)
            HitObject(Frozen)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end

        local Target = FindTarget2()
        if Target and Target.Health.Value > 1000 then
            local belowposition = Target:GetPivot().Position - Vector3.new(0, 18, 0)
            self.Root.CFrame = CFrame.new(belowposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        elseif Target and Target.Health.Value <= 1000 then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 20, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function AutoFarmMod:DisableColdGodFarm()
    if self.conn13 then
        self.conn13:Disconnect()
        self.conn13 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(Vector3.new(680.6983642578125, 264.61810302734375, -1180.3209228515625) + Vector3.new(0, 5, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

-- Auto Farm Tab Features
local ApplyAutoFarmMod = AutoFarmMod.new()

local FarmToggles = {}

local AutoFarmTab = Window:CreateTab({
	Name = "Auto Farms",
	Icon = "work",
	ImageSource = "Material",
	ShowTitle = true
})

AutoFarmTab:CreateSection("General farms")

FarmToggles.StoneFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Stone Farm",
    Description = "Mines Stone nodes and picks it up automatically",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "StoneFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end 
            end

            ApplyAutoFarmMod:ApplyStoneFarm()
        else
            ApplyAutoFarmMod:DisableStoneFarm()
        end
    end
})

FarmToggles.IronFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Iron Farm",
    Description = "Mines Iron nodes and picks it up automatically",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "IronFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyIronFarm()
        else
            ApplyAutoFarmMod:DisableIronFarm()
        end
    end
})

FarmToggles.GoldFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Gold Farm",
    Description = "Mines gold nodes and picks it up automatically (WARNING: you will be above the ore not below it and people can kill you)",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "GoldFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyGoldFarm()
        else
            ApplyAutoFarmMod:DisableGoldFarm()
        end
    end
})

FarmToggles.SunTreeFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Sun Tree Farm",
    Description = "Farms sun trees and feather bushes for essence and exp",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "SunTreeFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplySunTreeFarm()
        else
            ApplyAutoFarmMod:DisableSunTreeFarm()
        end
    end
})

FarmToggles.AncientTreeFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Ancient Tree Farm",
    Description = "Farms the ancient tree",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "AncientTreeFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyAncientTreeFarm()
        else
            ApplyAutoFarmMod:DisableAncientTreeFarm()
        end
    end
})

AutoFarmTab:CreateSection("statues / god farms")

local AutoFarmLabel = AutoFarmTab:CreateLabel({
	Text = "Use Auto Pickup To Pick Up the Drops",
	Style = 1
})

FarmToggles.OldGodFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Old god farm",
    Description = "Mines old god statue",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "OldGodFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyOldGodFarm()
        else
            ApplyAutoFarmMod:DisableOldGodFarm()
        end
    end
})

FarmToggles.WealthyGodFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Wealthy God Farm",
    Description = "Mines Wealthy god statue",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "WealthyGodFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyWealthyGodFarm()
        else
            ApplyAutoFarmMod:DisableWealthyGodFarm()
        end
    end
})

FarmToggles.MiserableGodFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Miserable God Farm",
    Description = "Mines Miserable God / Statue",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "MiserableGodFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyMiserableGodFarm()
        else
            ApplyAutoFarmMod:DisableMiserableGodFarm()
        end
    end
})

FarmToggles.OverGrownGodToggle = AutoFarmTab:CreateToggle({
    Name = "OverGrown God",
    Description = "Mines the overgrown god / statue",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "OverGrownGodToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end
            ApplyAutoFarmMod:ApplyOverGrownGodFarm()
        else
            ApplyAutoFarmMod:DisableOverGrownGodFarm()
        end
    end
})

FarmToggles.RadientGodToggle = AutoFarmTab:CreateToggle({
    Name = "Radient God",
    Description = "Mines the radient god / statue",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "RadientGodToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyRadientGodFarm()
        else
            ApplyAutoFarmMod:DisableRadientGodFarm()
        end
    end
})

FarmToggles.ColdGodToggle = AutoFarmTab:CreateToggle({
    Name = "Cold god / Frozen god",
    Description = "Mines the frozen ice on the cold god then mines the cold god",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "ColdGodToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyColdGodFarm()
        else
            ApplyAutoFarmMod:DisableColdGodFarm()
        end
    end
})

AutoFarmTab:CreateSection("Void Farms (WARNING: Requires you to be in the void to work")

FarmToggles.MaleoventGodFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Maleovent God Farm",
    Description = "Mines Maleovent God Statue In The Void",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(FarmToggles) do
                if name ~= "MaleoventGodFarmToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyAutoFarmMod:ApplyMaleoventGodFarm()
        else
            ApplyAutoFarmMod:DisableMaleoventGodFarm()
        end
    end
})

AutoFarmTab:CreateSection("Underworld Farms (WARNING: Requires you to be in the underworld to work)")

FarmToggles.GlowTreeFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Glow Tree / Bush Farm",
    Description = "Farms all nearby glowing large/big or normal tree and glowing bushes",
    CurrentValue = false,
    Callback = function(State)
        if State then
            ApplyAutoFarmMod:ApplyGlowFarm()
        else
            ApplyAutoFarmMod:DisableGlowFarm()
        end
    end
})

-- Boss Features
local BossMod = {}
BossMod.__index = BossMod

function BossMod.new()
    local self = setmetatable({}, BossMod)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.conn1 = nil
    self.conn2 = nil
    self.conn3 = nil
    self.conn4 = nil
    self.conn5 = nil

    return self
end

function BossMod:ApplyQueenAntBoss()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Important.Critters["Queen Ant"]
        end)
        return Success and Result or nil
    end

    local Queen_Ant = FindTarget()
    if not Queen_Ant then
        Luna:Notification({
            Title = "Queen Ant Not Spawned",
            Icon = "notifications",
            ImageSource = "Material",
            Content = "Please Wait For Queen Ant",
        })

    end

    self.conn1 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 20, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function BossMod:DisableQueenAntBoss()
    if self.conn1 then
        self.conn1:Disconnect()
        self.conn1 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(self.Root.Position + Vector3.new(0, 30, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function BossMod:ApplyGiantBoss()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Important.Critters.Giant
        end)
        return Success and Result or nil
    end

    local Giant = FindTarget()
    if not Giant then
        Luna:Notification({
            Title = "Giant Not Spawned",
            Icon = "notifications",
            ImageSource = "Material",
            Content = "Please Wait For Giant To Respawn"
        })
    end

    self.conn2 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 28, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function BossMod:DisableGiantBoss()
    if self.conn2 then
        self.conn2:Disconnect()
        self.conn2 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(self.Root.Position + Vector3.new(0, 20, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function BossMod:ApplyPinkGiantBoss()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Important.Critters["Pink Giant"]
        end)
        return Success and Result or nil
    end

    local Pink_Giant = FindTarget()
    if not Pink_Giant then
        Luna:Notification({
            Title = "Pink Giant Not Spawned",
            Icon = "notifications",
            ImageSource = "Material",
            Content = "Please Wait For Pink Giant To Respawn"
        })
    end

    self.conn3 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 25, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function BossMod:DisablePinkGiantBoss()
    if self.conn3 then
        self.conn3:Disconnect()
        self.conn3 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(self.Root.Position + Vector3.new(0, 30, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function BossMod:ApplyEmeraldGiantBoss()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = true
    end

    local function FindTarget()
        local Success, Result = pcall(function()
            return workspace.Important.Critters["Emerald Giant"]
        end)
        return Success and Result or nil
    end

    local Emerald_Giant = FindTarget()
    if not Emerald_Giant then
        Luna:Notification({
            Title = "Emerald Giant Not Spawned",
            Icon = "notifications",
            ImageSource = "Material",
            content = "Please Wait For Emerald Giant To Respawn"
        })
    end

    self.conn4 = RunService.Heartbeat:Connect(function()
        local Target = FindTarget()
        if Target then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 20, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function BossMod:DisableEmeraldGiantBoss()
    if self.conn4 then
        self.conn4:Disconnect()
        self.conn4 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    self.Hum.PlatformStand = false
    self.Root.CFrame = CFrame.new(self.Root.Position + Vector3.new(0, 20, 0))
    self.Root.Velocity = Vector3.new(0, 0, 0)
    self.Root.RotVelocity = Vector3.new(0, 0, 0)
end

function BossMod:ApplyKingAntBoss()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")
    local QueenHeart = nil

    local Folder = workspace.Important.Critters
    local function FindBoss()
        if Folder then
            for _, object in pairs(Folder:GetChildren()) do
                if object.Name == "King Ant" and object:IsA("Model") then
                    return object
                end
            end
            return false
        end
        return false
    end

    local function SpawnKingAnt()
        if QueenHeart then
            self.Root.CFrame = CFrame.new(Vector3.new(401.2962646484375, -164.07455444335938, 88.53450012207031) + Vector3.new(0, 5, 0))
            task.wait(1)
            DropEvent:FireServer(tonumber(QueenHeart), "Queen Heart")
            task.wait(0.1)
        end
    end

    local KingAnt = FindBoss()
    if not KingAnt then
        local Inventory = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List
        if Inventory then
            for _, object in pairs(Inventory:GetChildren()) do
                for _, child in pairs(object:GetChildren()) do
                    if child.Name == "title" and child.Text == "Queen Heart" then
                        QueenHeart = tonumber(object.Name) or object.Name
                        break
                    end
                end
                if QueenHeart then break end
            end
            if QueenHeart == nil then
                Luna:Notification({
                    Title = "Queen Heart Not Found",
                    Icon = "notifications_active",
                    ImageSource = "Material",
                    Content = "Must have queen heart to spawn in king ant",
                })
            end
        end
        SpawnKingAnt()
    end

    self.Hum.PlatformStand = true
    self.conn5 = RunService.Heartbeat:Connect(function()
        local Target = FindBoss()
        if Target then
            local aboveposition = Target:GetPivot().Position + Vector3.new(0, 35, 0)
            self.Root.CFrame = CFrame.new(aboveposition, Target:GetPivot().Position)
            HitObject(Target)

            self.Root.Velocity = Vector3.new(0, 0, 0)
            self.Root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function BossMod:DisableKingAntBoss()
    if self.conn5 then
        self.conn5:Disconnect()
        self.conn5 = nil
    end

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Hum = self.Char:WaitForChild("Humanoid")
    if self.Hum then
        self.Hum.PlatformStand = false
    end
end

-- Boss Tab Features
local ApplyBossMod = BossMod.new()
local BossToggle = {}

local BossTab = Window:CreateTab({
    Name = "Boss Farms",
    Icon = "groups",
    ImageSource = "Material",
    ShowTitle = true
})

local BossTabLabel1 = BossTab:CreateLabel({
	Text = "Please disable any auto farm features to use auto boss features thank you.",
	Style = 1
})

BossToggle.QueenAntToggle = BossTab:CreateToggle({
    Name = "Queen Ant",
    Description = "Kills Queen Ant",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(BossToggle) do
                if name ~= "QueenAntToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyBossMod:ApplyQueenAntBoss()
        else
            ApplyBossMod:DisableQueenAntBoss()
        end
    end
})

BossToggle.GiantToggle = BossTab:CreateToggle({
    Name = "Giant",
    Description = "Kills The Giant Boss",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(BossToggle) do
                if name ~= "GiantToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyBossMod:ApplyGiantBoss()
        else
            ApplyBossMod:DisableGiantBoss()
        end
    end
})

BossToggle.PinkGiantToggle = BossTab:CreateToggle({
    Name = "Pink Giant",
    Description = "Kills Pink Giant",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(BossToggle) do
                if name ~= "PinkGiantToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyBossMod:ApplyPinkGiantBoss()
        else
            ApplyBossMod:DisablePinkGiantBoss()
        end
    end
})

BossToggle.EmeraldGiantToggle = BossTab:CreateToggle({
    Name = "Emerald Giant",
    Description = "Kills Emerald Giant",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(BossToggle) do
                if name ~= "EmeraldGiantToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyBossMod:ApplyEmeraldGiantBoss()
        else
            ApplyBossMod:DisableEmeraldGiantBoss()
        end
    end
})

BossTab:CreateSection("Void Bosses")

BossToggle.KingAntToggle = BossTab:CreateToggle({
    Name = "King Ant",
    Description = "Must have a queen heart from the queen ant boss",
    CurrentValue = false,
    Callback = function(State)
        if State then
            for name, toggle in pairs(BossToggle) do
                if name ~= "KingAntToggle" then
                    toggle:Set({ CurrentValue = false })
                end
            end

            ApplyBossMod:ApplyKingAntBoss()
        else
            ApplyBossMod:DisableKingAntBoss()
        end
    end
})

-- Misc Features
local MiscMod = {}
MiscMod.__index = MiscMod

function MiscMod.new()
    local self = setmetatable({}, MiscMod)

    self.Char = Player.Character or Player.CharacterAdded:Wait()
    self.Root = self.Char:WaitForChild("HumanoidRootPart")
    self.Hum = self.Char:WaitForChild("Humanoid")

    return self
end

-- Misc Tab Features
local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "view_module",
    ImageSource = "Material",
    ShowTitle = true
})

local VoidTp = MiscTab:CreateButton({
    Name = "Teleport To Void",
    Description = "Please wait atleast 10 seconds for it to load before pressing the button again",
    Callback = function()
        local PlaceId = 18629058177
        TeleportService:Teleport(PlaceId, Player)
    end
})

local UnderWorldTp = MiscTab:CreateButton({
    Name = "Teleport To UnderWorld",
    Description = "Please wait atleast 10 seconds for it to load before pressing the button again",
    Callback = function()
        local PlaceId = 92039548740735
        TeleportService:Teleport(PlaceId, Player)
    end
})

local TeleportSafePartToggle = MiscTab:CreateButton({
    Name = "Teleport to safe part",
    Description = "Teleports you to the vortex hub logo part",
    Callback = function()
        local Char = Player.Character or Player.CharacterAdded:Wait()
        local Root = Char:WaitForChild("HumanoidRootPart")
        Root.CFrame = CFrame.new(SafePart.Position + Vector3.new(0, 5, 0))
    end 
})

local AntiAfkConn = nil
local AntiAfkToggle = MiscTab:CreateToggle({
    Name = "Anti-Afk",
    Description = "Prevents game randomly respawning you while afk",
    CurrentValue = false,
    Callback = function(State)
        if State then
            if AntiAfkConn then
                AntiAfkConn:Disconnect()
                AntiAfkConn = nil
            end

            CreateAntiAfkUi()

            local VirtualUser = game:GetService("VirtualUser")
            conn = Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new()) 
            end)
        else
            DestroyAntiAfkUi()
            if AntiAfkConn then
                AntiAfkConn:Disconnect()
                AntiAfkConn = nil
            end 
        end
    end
})

local ScriptUrl = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"
local VisitedServers = {}
local ServerHopToggle = MiscTab:CreateButton({
    Name = "Server Hop",
    Description = "Joins a new server",
    Callback = function(State)
        local function QueScript()
            if syn then
                syn.queue_on_teleport(ScriptUrl)
            elseif queue_on_teleport then
                queue_on_teleport(ScriptUrl)
            else
                Luna:Notification({
                    Title = "Failed to server hop",
                    Icon = "notifications_active",
                    ImageSource = "Material",
                    Content = "Your Executor might not support this feature",
                })
            end
        end

        local function ServerHop()
            local Success, Servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if Success and Servers and Servers.data then
                for _, Server in pairs(Servers.data) do
                    local ServerId = Server.id
                    local MaxPlayers = Server.maxPlayers
                    local CurrentPlayers = Server.playing
                    if CurrentPlayers < MaxPlayers and ServerId ~= game.JobId and not VisitedServers[ServerId] then
                        VisitedServers[ServerId] = true
                        QueScript()
                        TeleportService:TeleportToPlaceInstance(PlaceId, ServerId, Player)
                        return
                    end
                end
            end 
        end

        ServerHop()
    end
})

-- Reset Features Upon Death
local function UpdateFeatures(Mod)
    Mod.Char = Player.Character or Player.CharacterAdded:Wait()
    Mod.Hum = Mod.Char:WaitForChild("Humanoid")
    Mod.Root = Mod.Char:WaitForChild("HumanoidRootPart")
end

Player.CharacterAdded:Connect(function()
    UpdateFeatures(LocalPlayerMod)
    UpdateFeatures(MainMod)
    UpdateFeatures(CombatMod)
    UpdateFeatures(AutoFarmMod)
    UpdateFeatures(BossMod)

    if ApplyLocalPlayerMod.IsFlying then ApplyLocalPlayerMod.IsFlying = false end
    if ApplyLocalPlayerMod.flyconn then ApplyLocalPlayerMod.flyconn:Disconnect() ApplyLocalPlayerMod.flyconn = nil end
    if ApplyLocalPlayerMod.BodyGyro then ApplyLocalPlayerMod.BodyGyro:Destroy() end
    if ApplyLocalPlayerMod.BodyVelocity then ApplyLocalPlayerMod.BodyVelocity:Destroy() end
    if ApplyLocalPlayerMod.Hum then ApplyLocalPlayerMod.Hum.PlatformStand = false end

    if ApplyLocalPlayerMod.infjumpconn then
        ApplyLocalPlayerMod.infjumpconn:Disconnect()
        ApplyLocalPlayerMod.infjumpconn = nil

        ApplyLocalPlayerMod:ApplyInfJump()
    end
end)
