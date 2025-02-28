local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local StartEvent = EventsFolder:WaitForChild("Start") :: BindableEvent
local SecondEvent = EventsFolder:WaitForChild("Scenes"):WaitForChild("Second") :: BindableEvent
local ModulesFolder = ReplicatedStorage:WaitForChild("Modules")
local DialogueUI = require(ModulesFolder:WaitForChild("DialogueUI"))
local HighlightManager = require(ModulesFolder:WaitForChild("HighlightManager"))
local Teleport = require(ModulesFolder:WaitForChild("Teleport"))
local SkySettings = require(ModulesFolder:WaitForChild("SkySettings"))
local EnumsFolder = ReplicatedStorage:WaitForChild("Enums")
local ECharacter = require(EnumsFolder:WaitForChild("ECharacter"))
local EDialogue = require(EnumsFolder:WaitForChild("EDialogue"))
local ETimeLine = require(EnumsFolder:WaitForChild("ETimeLine"))

local TWInfoButton = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1)
local TWInfo = TweenInfo.new(1.1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

local Levers = CollectionService:GetTagged("Lever") :: { BasePart }
local DoorStart = CollectionService:GetTagged("DoorStart")[1] :: ProximityPrompt
local Button = CollectionService:GetTagged("Button")[1] :: BasePart
local Batteries = CollectionService:GetTagged("Battery") :: { BasePart }
local BatteryPlaces = CollectionService:GetTagged("BatteryPlace") :: { BasePart }
local ThunderParticles = CollectionService:GetTagged("Thunder") :: { ParticleEmitter }
local BatteryConnections: { [BasePart]: { RBXScriptConnection } } = {}

local SoundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local ElectricZapSound = SoundsFolder:WaitForChild("ElectricZap") :: Sound
local ElectricShockSound = SoundsFolder:WaitForChild("ElectricShock") :: Sound 
local LeverSound = SoundsFolder:WaitForChild("Lever") :: Sound
local PowerUpSound = SoundsFolder:WaitForChild("PowerUp") :: Sound

local BatteriesPlaced = 0;
local LeversDown = 0;

for index, value in Levers do
    (value.ProximityPrompt :: ProximityPrompt).Triggered:Connect(function(playerWhoTriggered)
        HighlightManager.Remove(value)

        local Tween = TweenService:Create(value, TWInfo, { CFrame = value.Pos.CFrame })
        LeversDown += 1
        value.ProximityPrompt.Enabled = false

        if LeversDown >= #Levers then
            Tween.Completed:Once(function()
                task.spawn(function()
                    DialogueUI.Talk(ECharacter.You, EDialogue.FirstScene2)
                end)

                HighlightManager.Add(Button.Parent, Color3.new(0, 176, 117))

                TweenService:Create(Button.PointLight, TWInfo, { Brightness = 0.35 }):Play()
                local TweenButton = TweenService:Create(Button, TWInfo, { Transparency = 0 })

                TweenButton.Completed:Once(function()
                    Button.ProximityPrompt.Enabled = true
                    TweenService:Create(Button, TWInfoButton, { Transparency = 0.45 }):Play()
                end)

                TweenButton:Play()

                local UpSound = PowerUpSound:Clone()
                UpSound.Parent = Button
                UpSound.Ended:Once(function()
                    UpSound:Destroy()
                end)

                UpSound:Play()
            end)
        end

        Tween:Play()

        local LSound = LeverSound:Clone()
        LSound.Parent = value
        LSound.Ended:Once(function()
            LSound:Destroy()
        end)
        LSound:Play()
    end)
end

(Button.ProximityPrompt :: ProximityPrompt).Triggered:Connect(function(playerWhoTriggered)
    HighlightManager.Remove(Button)
    Teleport.To(ETimeLine.Future)
    SkySettings.Red()
    SecondEvent:Fire()
end)

DoorStart.Triggered:Connect(function(playerWhoTriggered)
    if BatteriesPlaced < #Batteries then
        DialogueUI.Talk(ECharacter.You, EDialogue.FirstSceneDoor0)
    elseif LeversDown < #Levers then
        DialogueUI.Talk(ECharacter.You, EDialogue.FirstSceneDoor1)
    else
        DialogueUI.Talk(ECharacter.You, EDialogue.FirstSceneDoor2)
    end
end)

for _, Battery in Batteries do
    local DragBattery = Battery.DragDetector
    BatteryConnections[Battery] = {}

    local DragStartConnection = DragBattery.DragStart:Connect(function(playerWhoDragged, cursorRay, viewFrame, hitFrame, clickedPart, vrInputFrame, isModeSwitchKeyDown)
        for _, Place in BatteryPlaces do
            if Place:GetAttribute("Placed") then continue end
            HighlightManager.Add(Place.Parent)
        end
    end)
    table.insert(BatteryConnections[Battery], DragStartConnection)

    local DragEndConnection = DragBattery.DragEnd:Connect(function(playerWhoDragged)
        for _, Place in BatteryPlaces do
            if Place:GetAttribute("Placed") then continue end
            HighlightManager.Remove(Place.Parent)
        end
    end)
    table.insert(BatteryConnections[Battery], DragEndConnection)
end

for _, Place in BatteryPlaces do
    local PlaceConnection
    PlaceConnection = Place.Touched:Connect(function(otherPart)
        if otherPart.Anchored then return end
        if not otherPart:HasTag("Battery") then return end
        PlaceConnection:Disconnect()
        otherPart.Anchored = true
        BatteriesPlaced += 1
        Place:SetAttribute("Placed", true)

        if BatteryConnections[otherPart] then
            for _, connection in BatteryConnections[otherPart] do
                connection:Disconnect()
            end

            BatteryConnections[otherPart] = nil
        end

        otherPart.DragDetector:RestartDrag()
        local Tween = TweenService:Create(otherPart, TWInfo, { CFrame = Place.CFrame })

        Tween.Completed:Once(function()
            local SSound = ElectricShockSound:Clone()
            SSound.Parent = otherPart
            SSound.Ended:Once(function()
                SSound:Destroy()
            end)
            SSound:Play()

            otherPart.Connect1.Thunder:Emit(8)
            otherPart.Connect2.Thunder:Emit(8)

            if BatteriesPlaced < #Batteries then return end

            task.spawn(function()
                DialogueUI.Talk(ECharacter.You, EDialogue.FirstScene1)
            end)

            for _, value in Levers do
                HighlightManager.Add(value, Color3.fromRGB(255, 212, 190))
                value.ProximityPrompt.Enabled = true
            end

            for index, value in ThunderParticles do
                value.Enabled = true
            end

            local ESound = ElectricZapSound:Clone()
            ESound.Parent = Button.Parent.Parent.TheTimeMachine
            ESound.Ended:Once(function()
                ESound:Destroy()
            end)
            ESound:Play()
        end)

        Tween:Play()

        HighlightManager.Remove(Place.Parent)
        HighlightManager.Remove(otherPart.Parent)
        otherPart.ProximityPrompt.Enabled = false
        otherPart.DragDetector:Destroy()
    end)
end

StartEvent.Event:Wait()

task.wait(1)

for index, Battery in Batteries do
    HighlightManager.Add(Battery.Parent, Color3.fromRGB(255, 212, 190)) 
end

task.spawn(function()
    DialogueUI.Talk(ECharacter.You, EDialogue.FirstScene0)
end)