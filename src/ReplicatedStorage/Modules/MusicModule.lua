local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Musics = ReplicatedStorage:WaitForChild("Music")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CurrentTrack

local MusicModule = {}

function MusicModule.Play(music: string)
    local Music = Musics[music]:Clone()
    Music.Volume = 0.25
    Music.Parent = PlayerGui
    Music:Play()

    CurrentTrack = Music
end

function MusicModule.Stop(fadeOut: number?)
    if not CurrentTrack then return end
    local Tween = TweenService:Create(CurrentTrack, TweenInfo.new(fadeOut or 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Volume = 0 })
    Tween.Completed:Once(function(playbackState)
        CurrentTrack:Stop()
        CurrentTrack = nil
    end)
    Tween:Play()
end

return MusicModule