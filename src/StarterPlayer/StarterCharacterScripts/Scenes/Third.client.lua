local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local ThirdEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Third") :: BindableEvent
local FourthEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Fourth") :: BindableEvent
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

local ProximityDates = CollectionService:GetTagged("ProximityDate") :: { ProximityPrompt }
local SecondDoor = CollectionService:GetTagged("SecondDoor")[1] :: ProximityPrompt
local SecondSwitch = CollectionService:GetTagged("SecondSwitch")[1] :: ProximityPrompt
local SecondSwitchDown = CollectionService:GetTagged("SecondSwitchDown")[1] :: ProximityPrompt

local CurrentLightHovered
local SwitchDialogue = false
local DateFounded = false
local Connections = {}

SecondDoor.Triggered:Once(function(playerWhoTriggered)
    task.spawn(function()
        CurrentLightHovered = SecondSwitch.Parent.Parent
        HighlightManager.Add(SecondSwitch.Parent.Parent)
        DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene3)
    end)
end)

SecondSwitch.Triggered:Once(function(playerWhoTriggered)
    if SwitchDialogue then return end
    SwitchDialogue = true
    task.spawn(function()
        HighlightManager.Remove(CurrentLightHovered)
        CurrentLightHovered = nil
        DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene4)
    end)
end)

SecondSwitchDown.Triggered:Once(function(playerWhoTriggered)
    if SwitchDialogue then return end
    SwitchDialogue = true
    task.spawn(function()
        HighlightManager.Remove(CurrentLightHovered)
        CurrentLightHovered = nil
        DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene4)
    end)
end)

for _, value in ProximityDates do
    table.insert(Connections, value.Triggered:Connect(function()
        if DateFounded then return end
        local Light = value.Light.Value
        if not Light:GetAttribute("IsPowered") then
            local Switch = value.Switch.Value

            if CurrentLightHovered and CurrentLightHovered ~= Switch then
                HighlightManager.Remove(CurrentLightHovered)
                CurrentLightHovered = nil
            end

            if not CurrentLightHovered then HighlightManager.Add(Switch) end
            CurrentLightHovered = Switch
            DialogueUI.Talk(ECharacter.You, EDialogue.ThirdSceneLights0)
            return
        end

        DateFounded = true

        task.spawn(function()
            Tweens.Stun()

            DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene5)
            DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene6)
            DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene7)

            task.wait(0.75)

            if CurrentLightHovered then
                HighlightManager.Remove(CurrentLightHovered)
                CurrentLightHovered = nil
            end

            FourthEvent:Fire()
            Teleport.To(ETimeLine.Future)
            SkySettings.Red()
            
            task.wait(1)
            SecondSwitchDown.Parent:SetAttribute("IsPowered", false)
        end)

        for _, value in Connections do
            value:Disconnect()
        end

        for _, value in ProximityDates do
            value.Enabled = false
        end
    end))
end

ThirdEvent.Event:Wait()
Tweens.Stun()
MusicModule.Stop()

task.wait(1)

task.spawn(function()
    MusicModule.Play("Birds")
    DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene0)
    DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene1)
    DialogueUI.Talk(ECharacter.You, EDialogue.ThirdScene2)
    Tweens.UnStun()

    task.wait(60)
    if DateFounded then return end
    DialogueUI.Talk(ECharacter.You, EDialogue.ThirdSceneHurry0)

    for _, value in ProximityDates do
        HighlightManager.Add(value.Parent, Color3.fromHex("#64dae5"))
    end
end)

