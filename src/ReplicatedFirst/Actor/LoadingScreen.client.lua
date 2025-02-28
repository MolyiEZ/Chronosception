-- Starting Services
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

-- Starting Variables
local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local loadingUI = script.Parent:WaitForChild("LoadingUI"):Clone()

ReplicatedFirst:RemoveDefaultLoadingScreen()
loadingUI.Parent = playerGui
UserInputService.MouseIconEnabled = false
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local loadingGroup = loadingUI:WaitForChild("LoadingGroup")
local round = loadingGroup:WaitForChild("Round")
local textLoading = loadingGroup:WaitForChild("TextLoading")

local assets = game:GetDescendants()
local maxAssets = #assets
local assetsLoaded = 0

textLoading.Text = 0 .. " / " .. maxAssets

local function loadGroup(startIndex, endIndex)
	local group = {}
	for i = startIndex, endIndex do
		table.insert(group, assets[i])
	end

	ContentProvider:PreloadAsync(group)
	assetsLoaded = assetsLoaded + #group
	textLoading.Text = assetsLoaded .. " / " .. maxAssets
end

local Connection = RunService.Heartbeat:Connect(function(dt)
    round.Rotation = (round.Rotation + 180 * dt) % 360
end)

local index = 1
while index <= maxAssets do
	local groupSize = math.random(math.floor(maxAssets/16), math.floor(maxAssets/4))
	local endIndex = math.min(index + groupSize - 1, maxAssets)

	loadGroup(index, endIndex)

	index = endIndex + 1
end

task.wait(1.5)

local Tween = game:GetService("TweenService"):Create(loadingGroup, TweenInfo.new(1.5, Enum.EasingStyle.Linear), { GroupTransparency = 1  })

Tween.Completed:Once(function(playbackState)
	Connection:Disconnect()
	loadingUI:Destroy()
end)

Tween:Play()

task.wait(1.35)

Player:SetAttribute("LoadingFinished", true)