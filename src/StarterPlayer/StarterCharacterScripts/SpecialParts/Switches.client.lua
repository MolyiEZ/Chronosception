local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local StartEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Start") :: BindableEvent
local Switches = CollectionService:GetTagged("Switch") :: { ProximityPrompt }
local StartSwitch = CollectionService:GetTagged("StartSwitch")[1] :: ProximityPrompt
local SwitchSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Switch") :: Sound
local SwitchFuturisticSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("SwitchFuturistic") :: Sound

local TWInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

for _, SwitchProximity in Switches do
    local Futuristic = SwitchProximity:GetAttribute("Future")

    local Sound = (Futuristic and SwitchFuturisticSound or SwitchSound):Clone()
    Sound.Parent = SwitchProximity.Parent

    SwitchProximity.Triggered:Connect(function(playerWhoTriggered)
        local IsPowered = SwitchProximity.Parent:GetAttribute("IsPowered") or false
        SwitchProximity.Parent:SetAttribute("IsPowered", not IsPowered)
    end)

    SwitchProximity.Parent.AttributeChanged:Connect(function(attribute)
        if attribute ~= "IsPowered" then return end
        local IsPowered = SwitchProximity.Parent:GetAttribute("IsPowered")
        Sound:Play()

        if not Futuristic then
            local Orientation = SwitchProximity.Parent.Lever.Orientation

            if IsPowered then
                TweenService:Create(SwitchProximity.Parent.Lever, TWInfo, { Orientation = Vector3.new(Orientation.X, Orientation.Y - 10, Orientation.Z) }):Play() 
            else
                TweenService:Create(SwitchProximity.Parent.Lever, TWInfo, { Orientation = Vector3.new(Orientation.X, Orientation.Y + 10, Orientation.Z) }):Play()
            end
        end

        for _, value in SwitchProximity.Parent:GetDescendants() do
            if not value:IsA("ObjectValue") or value.Name ~= "Light" then continue end
            local Light = (value :: ObjectValue).Value :: BasePart
            Light:SetAttribute("IsPowered", IsPowered)
        end
    end)
end

StartEvent.Event:Once(function()
    StartSwitch.Parent:SetAttribute("IsPowered", true)
end)