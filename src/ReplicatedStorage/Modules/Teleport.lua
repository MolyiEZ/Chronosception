local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CameraShake = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CameraShake"))
local ETimeLine = require(ReplicatedStorage:WaitForChild("Enums"):WaitForChild("ETimeLine"))

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local TeleportSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Teleport") :: Sound
local IFPast = Lighting:WaitForChild("IFPast") :: ColorCorrectionEffect
local IFFuture = Lighting:WaitForChild("IFFuture") :: ColorCorrectionEffect
local IF2 = Lighting:WaitForChild("IF2") :: ColorCorrectionEffect
local IF3 = Lighting:WaitForChild("IF3") :: ColorCorrectionEffect
local CurrentTimeLine = ETimeLine.Present

local DEFAULT_FOV = 90
local MIN_FOV = 30
local SQUEEZE_TIME = 0.3
local SHAKE_DURATION = 0.8
local SHAKE_INTENSITY = 0.025

local TWInfoTeleportIn = TweenInfo.new(SQUEEZE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local TWInfoTeleportOut = TweenInfo.new(SQUEEZE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local DISTORTION_DURATION = 0.3
local MOTION_BLUR_INTENSITY = 12

local MotionBlur = Instance.new("BlurEffect")
MotionBlur.Size = 0
MotionBlur.Parent = Lighting

-- Present = -5000
-- Past = 5000
-- Future = 0

local Teleport = {}

local function _To(timeLine: number)
    TweenService:Create(MotionBlur, TWInfoTeleportOut, {Size = MOTION_BLUR_INTENSITY}):Play()

    local SqueezeTween = TweenService:Create(Camera, TWInfoTeleportIn, { FieldOfView = MIN_FOV })
    SqueezeTween:Play()
    task.wait(TWInfoTeleportIn.Time/1.4)

    if CurrentTimeLine == ETimeLine.Present then
        if timeLine == ETimeLine.Past then
            Character.PrimaryPart.CFrame = Character.PrimaryPart.CFrame + Vector3.new(10000, 0, 0)
        elseif timeLine == ETimeLine.Future then
            Character.PrimaryPart.CFrame = Character.PrimaryPart.CFrame + Vector3.new(5000, 0, 0)
        end
    elseif CurrentTimeLine == ETimeLine.Past and timeLine == ETimeLine.Future then
        Character.PrimaryPart.CFrame = Character.PrimaryPart.CFrame - Vector3.new(5000, 0, 0)
    elseif CurrentTimeLine == ETimeLine.Future and timeLine == ETimeLine.Past then
        Character.PrimaryPart.CFrame = Character.PrimaryPart.CFrame + Vector3.new(5000, 0, 0)
    end

    CurrentTimeLine = timeLine

    local Sound = TeleportSound:Clone()
    Sound.Parent = Character.PrimaryPart
    Sound.Ended:Once(function()
        Sound:Destroy()
    end)
    Sound:Play()

    TweenService:Create(MotionBlur, TWInfoTeleportOut, {Size = 0}):Play()

    TweenService:Create(Camera, TWInfoTeleportOut, {FieldOfView = DEFAULT_FOV}):Play()

    CameraShake.Start(SHAKE_DURATION, SHAKE_INTENSITY)

    local IF1 = timeLine == ETimeLine.Past and IFPast or IFFuture
    IF1.Enabled = true
    task.wait(0.1)
    IF1.Enabled = false
    IF2.Enabled = true
    task.wait(0.1)
    IF2.Enabled = false
    IF3.Enabled = true
    task.wait(0.1)
    IF3.Enabled = false
end

function Teleport.To(timeLine: number)
    if timeLine == CurrentTimeLine then return end

    task.spawn(function()
        _To(timeLine)
    end)
end

return Teleport