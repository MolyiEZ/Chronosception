local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local LoadingUI = script.Parent:WaitForChild("LoadingUI"):Clone()

ReplicatedFirst:RemoveDefaultLoadingScreen()
LoadingUI.Parent = PlayerGui
UserInputService.MouseIconEnabled = false
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local LoadingGroup = LoadingUI:WaitForChild("LoadingGroup")
local Round = LoadingGroup:WaitForChild("Round")
local TextLoading = LoadingGroup:WaitForChild("TextLoading")

local Assets = game:GetDescendants()
local MaxAssets = #Assets
local AssetsLoaded = 0

TextLoading.Text = 0 .. " / " .. MaxAssets

local function LoadGroup(startIndex, endIndex)
	local Group = {}
	for i = startIndex, endIndex do
		table.insert(Group, Assets[i])
	end

	ContentProvider:PreloadAsync(Group)
	AssetsLoaded = AssetsLoaded + #Group
	TextLoading.Text = AssetsLoaded .. " / " .. MaxAssets
end

local Connection = RunService.Heartbeat:Connect(function(dt)
    Round.Rotation = (Round.Rotation + 180 * dt) % 360
end)

local Index = 1
while Index <= MaxAssets do
	local GroupSize = math.random(math.floor(MaxAssets/16), math.floor(MaxAssets/4))
	local EndIndex = math.min(Index + GroupSize - 1, MaxAssets)

	LoadGroup(Index, EndIndex)

	Index = EndIndex + 1
end

task.wait(1.5)

local Tween = game:GetService("TweenService"):Create(LoadingGroup, TweenInfo.new(1.5, Enum.EasingStyle.Linear), { GroupTransparency = 1  })

Tween.Completed:Once(function(playbackState)
	Connection:Disconnect()
	LoadingUI:Destroy()
end)

Tween:Play()

task.wait(1.35)

Player:SetAttribute("LoadingFinished", true)