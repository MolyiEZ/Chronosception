local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local FifthEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Fifth") :: BindableEvent
local ModulesFolder = ReplicatedStorage:WaitForChild("Modules")
local DialogueUI = require(ModulesFolder:WaitForChild("DialogueUI"))
local HighlightManager = require(ModulesFolder:WaitForChild("HighlightManager"))
local Tweens = require(ModulesFolder:WaitForChild("Tweens"))
local Teleport = require(ModulesFolder:WaitForChild("Teleport"))
local SkySettings = require(ModulesFolder:WaitForChild("SkySettings"))
local MusicModule = require(ModulesFolder:WaitForChild("MusicModule"))
local CameraShake = require(ModulesFolder:WaitForChild("CameraShake"))
local EnumsFolder = ReplicatedStorage:WaitForChild("Enums")
local ECharacter = require(EnumsFolder:WaitForChild("ECharacter"))
local EDialogue = require(EnumsFolder:WaitForChild("EDialogue"))
local ETimeLine = require(EnumsFolder:WaitForChild("ETimeLine"))

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Gun = Character:WaitForChild("Gun") :: BasePart
local Barrel = Gun:WaitForChild("Barrel") :: BasePart
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local TWInfoHeartbeat = TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local TWInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local TWInfoCredits = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local FadeOutUI = PlayerGui:WaitForChild("FadeOut") :: ScreenGui
local FadeGroup = FadeOutUI:WaitForChild("FadeGroup") :: CanvasGroup

local MouseUI = PlayerGui:WaitForChild("Mouse") :: ScreenGui
local MouseGroup = MouseUI:WaitForChild("MouseGroup") :: CanvasGroup

local CreditsUI = PlayerGui:WaitForChild("Credits") :: ScreenGui
local CreditsGroup = CreditsUI:WaitForChild("CreditsGroup") :: CanvasGroup

local StartGUI = PlayerGui:WaitForChild("StartGUI") :: ScreenGui
local StartGUIGroup = StartGUI:WaitForChild("CanvasGroup") :: CanvasGroup

local SoundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local GunShot = (SoundsFolder:WaitForChild("Shot") :: Sound):Clone()
local GunEquip = (SoundsFolder:WaitForChild("Equip") :: Sound):Clone()
local Ringing = SoundsFolder:WaitForChild("Ringing"):Clone()
local HeavyBreathing = SoundsFolder:WaitForChild("HeavyBreathing"):Clone()
local Heartbeat = SoundsFolder:WaitForChild("Heartbeat"):Clone()
GunShot.Parent = Barrel
GunEquip.Parent = Barrel
Ringing.Parent = PlayerGui
HeavyBreathing.Parent = PlayerGui
Heartbeat.Parent = PlayerGui

local CurrentFov = 90

local IF = Lighting:WaitForChild("IF2") :: ColorCorrectionEffect
local DOT_PATTERNS = {". ", ".. ", "... "}

local IdleGunAnim = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("IdleGun") :: Animation
local GunShotAnim = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunShot") :: Animation
local IdleGun = Animator:LoadAnimation(IdleGunAnim)
local GunShotAnimation = Animator:LoadAnimation(GunShotAnim)

local AscendanceSpawn = CollectionService:GetTagged("AscendanceSpawn")[1] :: BasePart
local AscendanceSwitch = CollectionService:GetTagged("AscendanceSwitch")[1] :: ProximityPrompt

local HEARTBEAT_FOV_MIN = 88
local HEARTBEAT_FOV_MAX = 92
local BaseFieldOfView = 90
local PATTERN_DURATION = Heartbeat.TimeLength
local BEAT_DURATION = 0.4
local BEAT_GAP = PATTERN_DURATION / 2 - 0.05

local function HeartbeatFOV()
    local StartTime = tick()
    local Connection

    Connection = RunService.Heartbeat:Connect(function()
        local ElapsedTime = (tick() - StartTime) % PATTERN_DURATION
        local FOV = BaseFieldOfView

        local function SingleBeat(eTime: number)
            local HalfBeat = BEAT_DURATION / 2
            if eTime < HalfBeat then
                local Alpha = math.sin((eTime / HalfBeat) * math.pi)
                return BaseFieldOfView + (HEARTBEAT_FOV_MAX - BaseFieldOfView) * Alpha
            else
                local Alpha = math.sin(((eTime - HalfBeat) / HalfBeat) * math.pi)
                return BaseFieldOfView + (HEARTBEAT_FOV_MIN - BaseFieldOfView) * Alpha
            end
        end

        if ElapsedTime < BEAT_DURATION then
            FOV = SingleBeat(ElapsedTime)
        elseif ElapsedTime > BEAT_GAP and ElapsedTime < BEAT_GAP + BEAT_DURATION then
            FOV = SingleBeat(ElapsedTime - BEAT_GAP)
        end

        Camera.FieldOfView = FOV
    end)

    Heartbeat.Destroying:Once(function()
        Connection:Disconnect()
        Camera.FieldOfView = BaseFieldOfView
    end)
end

GunShot.Ended:Once(function()
    GunShot:Destroy()
end)

GunEquip.Ended:Once(function()
    GunEquip:Destroy()
end)

Ringing.Ended:Once(function()
    Ringing:Destroy()
end)

HeavyBreathing.Ended:Once(function()
    HeavyBreathing:Destroy()
end)

FifthEvent.Event:Wait()

task.wait(1)

task.spawn(function()
    HeavyBreathing:Play()
    Heartbeat:Play()
    HeartbeatFOV()

    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene0)
    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene1)

    GunEquip:Play()
    IdleGun:Play(0.25, 1, 0.75)
    Gun.Transparency = 0

    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene2)
    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene3)
    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene4)
    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene5)
    DialogueUI.Talk(ECharacter.You, EDialogue.FifthScene6)

    TweenService:Create(MouseGroup, TWInfoHeartbeat, { GroupTransparency = 0 }):Play()

    Mouse.Button1Down:Wait()

    GunShotAnimation:Play()
    CameraShake.Start(0.85, 0.045)

    IF.Enabled = true
    Ringing:Play()
    GunShot:Play()

    for _, value in Barrel:GetDescendants() do
        if not value:IsA("ParticleEmitter") then continue end
        value:Emit(1)
    end

    task.wait(0.1)
    IF.Enabled = false

    local TweenHeartbeat = TweenService:Create(Heartbeat, TWInfoHeartbeat, { Volume = 0 })
    TweenHeartbeat.Completed:Once(function()
        Heartbeat:Destroy()
        Camera.FieldOfView = BaseFieldOfView
    end)
    TweenHeartbeat:Play()

    local TweenBreath = TweenService:Create(HeavyBreathing, TWInfoHeartbeat, { Volume = 0 })
    TweenBreath.Completed:Once(function()
        HeavyBreathing:Destroy()
    end)
    TweenBreath:Play()

    TweenService:Create(MouseGroup, TWInfo, { GroupTransparency = 1 }):Play()
    TweenService:Create(FadeGroup, TWInfo, { GroupTransparency = 0 }):Play()

    MusicModule.Stop()

    task.wait(5)

    Character.PrimaryPart.CFrame = AscendanceSpawn.CFrame
    SkySettings.Default()

    IdleGun:Stop()
    Gun.Transparency = 1
    for _, value in Player.Character:GetDescendants() do
        if not value:IsA("BasePart") then continue end
        value.Color = Color3.fromRGB(80, 60, 51)
    end

    DialogueUI.Talk(ECharacter["???"], EDialogue.FifthScene7)
    DialogueUI.Talk(ECharacter["???"], EDialogue.FifthScene8)
    DialogueUI.Talk(ECharacter["???"], EDialogue.FifthScene9)
    DialogueUI.Talk(ECharacter["???"], EDialogue.FifthScene10)
    DialogueUI.Talk(ECharacter["???"], EDialogue.FifthScene11)
    DialogueUI.Talk(ECharacter["???"], EDialogue.FifthScene12)

    task.wait(1)

    StartGUIGroup.Controls.GroupTransparency = 1
    StartGUIGroup.GroupTransparency = 0

    local Dots = true

    task.spawn(function()
        local index = 1
        while Dots do
            StartGUIGroup.TextLabel.Text = "Press F to continue" .. DOT_PATTERNS[index]
            index = (index % #DOT_PATTERNS) + 1
            task.wait(0.85)
        end
    end)

    TweenService:Create(FadeGroup, TWInfo, { GroupTransparency = 1 }):Play()

    task.wait(0.2)

    local Pressed = false
    local Connection
    Connection = UserInputService.InputBegan:Connect(function(input, processed)
        if Pressed or input.KeyCode ~= Enum.KeyCode.F then return end
        Pressed = true
        Connection:Disconnect()
        Dots = false
        TweenService:Create(StartGUIGroup, TWInfo, { GroupTransparency = 1 }):Play()

        AscendanceSwitch.Parent:SetAttribute("IsPowered", true)
        DialogueUI.Talk(ECharacter.YouIteration, EDialogue.FifthScene13)

        task.wait(1.25)

        TweenService:Create(CreditsGroup, TWInfoCredits, { GroupTransparency = 0 }):Play()
    end)
end)

