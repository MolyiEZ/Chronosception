local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local FourthEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Fourth") :: BindableEvent
local FifthEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Fifth") :: BindableEvent
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
local PaperSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Paper") :: Sound

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head") :: BasePart
local DoorFourth = CollectionService:GetTagged("DoorFourth")[1] :: ProximityPrompt
local GoPart = CollectionService:GetTagged("GoPart3")[1] :: BasePart
local GoPart4 = CollectionService:GetTagged("GoPart4")[1] :: BasePart

local FadeOutUI = PlayerGui:WaitForChild("FadeOut") :: ScreenGui
local FadeGroup = FadeOutUI:WaitForChild("FadeGroup") :: CanvasGroup

local TWInfo = TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local Connection

Connection = GoPart.Touched:Connect(function(otherPart)
    if not otherPart.Parent:FindFirstChild("Humanoid") then return end
    Connection:Disconnect()

    task.spawn(function()
        Tweens.Stun()

        local Tween = TweenService:Create(FadeGroup, TWInfo, { GroupTransparency = 0 })

        Tween.Completed:Once(function()
            UserInputService.MouseIconEnabled = false
            Tweens.Stun(true)
            Lighting.Ambient = Color3.fromRGB(50, 50, 50)
            Character.PrimaryPart.CFrame = GoPart4.CFrame

            Tween = TweenService:Create(FadeGroup, TWInfo, { GroupTransparency = 1 })
            Tween:Play()
            Tween.Completed:Wait()

            HighlightManager.Remove(GoPart.Parent)
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene3);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene4);
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene5);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene6);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene7);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene8);
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene9);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene10);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene11);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene12);
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene13);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene14);
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene15);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene16);
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene17);
            DialogueUI.Talk(ECharacter.Dad, EDialogue.FourthScene18);
            DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene19);

            Teleport.To(ETimeLine.Past)
            SkySettings.Default()
            Lighting.Ambient = Color3.fromRGB(50, 50, 50)
            FifthEvent:Fire()
        end)

        Tween:Play()
    end)
end)

FourthEvent.Event:Wait()
MusicModule.Stop()

DoorFourth.Triggered:Once(function(playerWhoTriggered)
    if not DoorFourth:GetAttribute("Tried") then return end
    Tweens.Stun()
    DialogueUI.Talk(ECharacter.You, EDialogue.FourthSceneDoor0);
    Tweens.UnStun()
end)

Tweens.Stun()

task.wait(1)

task.spawn(function()
    MusicModule.Play("DarkAmbient")
    DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene0)
    DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene1)
    Tweens.UnStun()

    task.wait(1)

    local Sound = PaperSound:Clone()
    Sound.Parent = GoPart
    Sound:Play()
    Sound.Ended:Once(function()
        Sound:Destroy()
    end)

    task.wait(0.5)

    DoorFourth:SetAttribute("IsLocked", false)
    DialogueUI.Talk(ECharacter.You, EDialogue.FourthScene2)

    HighlightManager.Add(GoPart.Parent)
end)

