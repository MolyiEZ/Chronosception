local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Tweens = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Tweens"))

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local StartEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Start") :: BindableEvent

UserInputService.MouseIcon = "rbxassetid://115129763629710"
Mouse.Icon = "rbxassetid://115129763629710"

Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

Tweens.Stun()

function DisableTransparency(part: BasePart)
    if not part:IsA("BasePart") then return end

	if part.Name == "Head" then
		part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			part.LocalTransparencyModifier = 1
		end)
		part.LocalTransparencyModifier = 1
	else
		part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			part.LocalTransparencyModifier = 0
		end)
		part.LocalTransparencyModifier = 0
	end
end

for _, v in script.Parent:GetChildren() do
	DisableTransparency(v)
end

script.Parent.ChildAdded:Connect(function(v)
	DisableTransparency(v)
end)

StartEvent.Event:Once(function()
	Humanoid.AutoRotate = true
	UserInputService.MouseIconEnabled = true
	Tweens.UnStun()
end)
