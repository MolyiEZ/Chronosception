local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local SecondEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Second") :: BindableEvent
local ThirdEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Third") :: BindableEvent
local ModulesFolder = ReplicatedStorage:WaitForChild("Modules")
local DialogueUI = require(ModulesFolder:WaitForChild("DialogueUI"))
local HighlightManager = require(ModulesFolder:WaitForChild("HighlightManager"))
local Tweens = require(ModulesFolder:WaitForChild("Tweens"))
local Teleport = require(ModulesFolder:WaitForChild("Teleport"))
local SkySettings = require(ModulesFolder:WaitForChild("SkySettings"))
local MusicModule = require(ModulesFolder:WaitForChild("MusicModule"))
local EnumsFolder = ReplicatedStorage:WaitForChild("Enums")
local ECharacter = require(EnumsFolder:WaitForChild("ECharacter"))
local EDialogue = require(EnumsFolder:WaitForChild("EDialogue"))
local ETimeLine = require(EnumsFolder:WaitForChild("ETimeLine"))

local GoPart1 = CollectionService:GetTagged("GoPart1")[1] :: BasePart
local GoPart2 = CollectionService:GetTagged("GoPart2")[1] :: BasePart
local DoorSecond = CollectionService:GetTagged("DoorSecond")[1] :: ProximityPrompt
local DoorFourth = CollectionService:GetTagged("DoorFourth")[1] :: ProximityPrompt
local SwitchSecond = CollectionService:GetTagged("SwitchSecond")[1] :: ProximityPrompt
local ButtonSecond = CollectionService:GetTagged("ButtonSecond")[1] :: BasePart
local ThunderParticles = CollectionService:GetTagged("Thunder") :: { ParticleEmitter }

local SoundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local PowerDownSound = SoundsFolder:WaitForChild("PowerDown") :: Sound

local TWInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

local SwitchActivated = false
local SwitchFounded = false
local DialogueSwitch = false

local Connection
local DoorConnection
local DoorFourthConnection
local SwitchConnection

Connection = GoPart2.Touched:Connect(function(otherPart)
    if not otherPart.Parent:FindFirstChild("Humanoid") then return end
    Connection:Disconnect()

    task.spawn(function()
        HighlightManager.Remove(GoPart1)
        Tweens.Stun()
        DialogueUI.Talk(ECharacter.You, EDialogue.SecondScene5)
        SkySettings.Default()
        Tweens.UnStun()
        Teleport.To(ETimeLine.Past)
        if DoorFourthConnection then DoorFourthConnection:Disconnect() end
        ThirdEvent:Fire()
    end)
end)

DoorConnection = DoorSecond.Triggered:Connect(function(playerWhoTriggered)
    if not SwitchActivated then
        task.spawn(function()
            DialogueUI.Talk(ECharacter.You, EDialogue.SecondSceneDoor0)
        end)

        return
    end

    DoorConnection:Disconnect()
    SwitchConnection:Disconnect()

    task.spawn(function()
        TweenService:Create(Lighting, TWInfo, { Ambient = Color3.fromRGB(25, 13, 11) }):Play()
        Tweens.Stun()
        DialogueUI.Talk(ECharacter.You, EDialogue.SecondScene3)
        Tweens.UnStun()
        HighlightManager.Add(GoPart1)
        DialogueUI.Talk(ECharacter.You, EDialogue.SecondScene4)
    end)
end)

DoorFourthConnection = DoorFourth.Triggered:Once(function(playerWhoTriggered)
    DoorFourth:SetAttribute("Tried", true)
end)

SwitchConnection = SwitchSecond.TriggerEnded:Connect(function(playerWhoTriggered)
    if not DialogueSwitch then
        DialogueSwitch = true
        HighlightManager.Remove(SwitchSecond.Parent.Parent)

        task.spawn(function()
            DialogueUI.Talk(ECharacter.You, EDialogue.SecondScene2)
        end)
    end

    DoorSecond:SetAttribute("IsLocked", SwitchActivated)
    SwitchActivated = not SwitchActivated
    SwitchFounded = true
end)

SecondEvent.Event:Wait()
Tweens.Stun()

task.wait(0.5)

task.spawn(function()
    MusicModule.Play("DarkAmbient")

    TweenService:Create(ButtonSecond.PointLight, TWInfo, { Brightness = 0 }):Play()
    local Tween = TweenService:Create(ButtonSecond, TWInfo, { Transparency = 1 })

    Tween.Completed:Once(function()
        for index, value in ThunderParticles do
            value.Enabled = true
        end
    end)

    Tween:Play()

    local Sound = PowerDownSound:Clone()
    Sound.Parent = ButtonSecond
    Sound.Ended:Once(function()
        Sound:Destroy()
    end)
    Sound:Play()


    DialogueUI.Talk(ECharacter.You, EDialogue.SecondScene0)
    DialogueUI.Talk(ECharacter.You, EDialogue.SecondScene1)
    Tweens.UnStun()

    HighlightManager.Add(SwitchSecond.Parent.Parent)

    task.wait(45)
    if not SwitchFounded then
        DialogueUI.Talk(ECharacter.You, EDialogue.SecondSceneHurry0)
        TweenService:Create(Lighting, TWInfo, { Ambient = Color3.fromRGB(100, 100, 100) }):Play()
    end
end)

