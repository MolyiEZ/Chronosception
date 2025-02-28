local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local LowerTorso = Character:WaitForChild("LowerTorso") :: BasePart
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local EffectsGroup = SoundService:WaitForChild("Effects") :: SoundGroup
local FootstepsSounds = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Footsteps") :: Folder
local AnimationNames = {
    RunFront = true,
    WalkFront = true,
    WalkFrontLeft = true,
    WalkFrontRight = true,
    WalkBack = true,
    WalkBackLeft = true,
    WalkBackRight = true,
    WalkLeft = true,
    WalkRight = true
}

local MIN_TREMOLO = 0.65
local MAX_TREMOLO = 0.95
local MIN_SPEED = 0.94
local MAX_SPEED = 1.06

Animator.AnimationPlayed:Connect(function(animationTrack: AnimationTrack)
    if not AnimationNames[animationTrack.Animation.Name] then return end
    local Connection = animationTrack:GetMarkerReachedSignal("Footstep"):Connect(function()
        local MaterialName = Humanoid.FloorMaterial.Name
        if MaterialName == "Air" then return end
        local Sounds = FootstepsSounds[MaterialName]:GetChildren()
        local SelectedSound = Sounds[math.random(1, #Sounds)]:Clone() :: Sound
        SelectedSound.Parent = LowerTorso
        SelectedSound.SoundGroup = EffectsGroup
        local randomSpeed = math.random() * (MAX_SPEED - MIN_SPEED) + MIN_SPEED
        SelectedSound.PlaybackSpeed =  math.round(randomSpeed * 1000) / 1000

        local tremoloSound = Instance.new("TremoloSoundEffect", SelectedSound)
        local randomTremolo = math.random() * (MAX_TREMOLO - MIN_TREMOLO) + MIN_TREMOLO
        tremoloSound.Depth = math.round(randomTremolo * 1000) / 1000

        SelectedSound:Play();

        SelectedSound.Stopped:Once(function()
            SelectedSound:Destroy()
        end)
    end)

    animationTrack.Stopped:Once(function()
        Connection:Disconnect()
    end)
end)