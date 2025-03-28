local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ESpeed = require(ReplicatedStorage:WaitForChild("Enums"):WaitForChild("ESpeed"))

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Tweens = {}

local TweenSpeed
local TWInfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local TargetSpeed = ESpeed.Walk
local Stunned = false

function Tweens.Stun(camera: boolean?)
    if TweenSpeed then
        TweenSpeed:Cancel()
    end

    if camera then
        Humanoid.AutoRotate = false
    end

    Stunned = true
    Humanoid.WalkSpeed = 0
end

function Tweens.UnStun()
    Stunned = false

    TweenSpeed = TweenService:Create(Humanoid, TWInfo, { WalkSpeed = TargetSpeed })
    TweenSpeed:Play()
end

function Tweens.IsStunned()
    return Stunned
end

function Tweens.SetSpeed(speed: number)
    if TargetSpeed == speed then return end
    TargetSpeed = speed

    if not Stunned then
        TweenSpeed = TweenService:Create(Humanoid, TWInfo, { WalkSpeed = speed })
        TweenSpeed:Play()
    end
end

function Tweens.GetSpeed()
    return TargetSpeed
end

return Tweens