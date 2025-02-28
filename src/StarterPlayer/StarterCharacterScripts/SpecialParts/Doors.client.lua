local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DialogueUI = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DialogueUI"))
local ECharacter = require(ReplicatedStorage:WaitForChild("Enums"):WaitForChild("ECharacter"))
local DoubleDoors = CollectionService:GetTagged("DoubleDoor") :: { ProximityPrompt }
local Doors = CollectionService:GetTagged("Door") :: { ProximityPrompt }

local SoundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local WoodDoorOpen = SoundsFolder:WaitForChild("WoodDoorOpen") :: Sound
local WoodDoorClose = SoundsFolder:WaitForChild("WoodDoorClose") :: Sound
local WoodDoorLocked = SoundsFolder:WaitForChild("WoodDoorLocked") :: Sound

local TWInfo = TweenInfo.new(1.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

local function RotateAroundPivot(Door: BasePart, Angle: number)
    local PivotOffset = Door.PivotOffset
    local GoalCFrame = PivotOffset * CFrame.Angles(0, math.rad(Angle), 0) * PivotOffset:Inverse()
    return Door.CFrame * GoalCFrame
end

local function PlayDoorSound(Door: BasePart, Sound: Sound)
    Sound.Parent = Door.Parent

    Sound.Ended:Once(function()
        Sound:Destroy()
    end)

    Sound:Play()
end

local function AnimateDoor(Door: BasePart, Angle: number)
    TweenService:Create(Door, TWInfo, { CFrame = RotateAroundPivot(Door, Angle) }):Play()
end

local function HandleDoor(Prompt: ProximityPrompt, Door1: BasePart, Door2: BasePart?)
    if Prompt:GetAttribute("IsLocked") then
        if Prompt:GetAttribute("LockedSound") then
            PlayDoorSound(Prompt.Parent, WoodDoorLocked:Clone())
        end

        if Prompt:GetAttribute("LockedDialogue") then
            task.spawn(function()
                DialogueUI.Talk(ECharacter.You, [[Seems to be locked.]])
            end)
        end

        return
    end
    local Angle = Prompt:GetAttribute("Angle")
    local IsOpened = Prompt:GetAttribute("IsOpened")

    if IsOpened then
        AnimateDoor(Door1, Angle)
        if Door2 then AnimateDoor(Door2, -Angle) end
        task.wait(TWInfo.Time / 3)
        PlayDoorSound(Prompt.Parent, (IsOpened and WoodDoorClose or WoodDoorOpen):Clone())
    else
        PlayDoorSound(Prompt.Parent, (IsOpened and WoodDoorClose or WoodDoorOpen):Clone())
        AnimateDoor(Door1, -Angle)
        if Door2 then AnimateDoor(Door2, Angle) end
    end

    Prompt:SetAttribute("IsOpened", not IsOpened)
end

for _, Value in DoubleDoors do
    Value.Triggered:Connect(function()
        HandleDoor(Value, Value.Parent.Door1, Value.Parent.Door2)
    end)
end

for _, Value in Doors do
    Value.Triggered:Connect(function()
        HandleDoor(Value, Value.Parent.Door1)
    end)
end
