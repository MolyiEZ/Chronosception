local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local LightFlickering = SoundsFolder:WaitForChild("LightFlickering")
local Lights = CollectionService:GetTagged("Light") :: { BasePart }

local TWInfoOn = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
local TWInfoOff = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

for _, Bulb in Lights do
    local PointLight = Bulb:WaitForChild("PointLight")
    local FlickeringSound

    Bulb.AttributeChanged:Connect(function(attribute)
        if attribute ~= "IsPowered" then return end
        local IsPowered = Bulb:GetAttribute("IsPowered")

        if IsPowered then
            TweenService:Create(PointLight, TWInfoOn, { Brightness = 0.6 }):Play()
            TweenService:Create(Bulb, TWInfoOn, { Transparency = 0 }):Play()

            if Bulb:GetAttribute("Flickering") then
                FlickeringSound = LightFlickering:Clone()
                FlickeringSound.Parent = Bulb
                FlickeringSound:Play()

                task.wait(1.25)

                while Bulb:GetAttribute("IsPowered") do
                    local normalBrightness = 0.6
                    local normalTransparency = 0
                    local normalTween = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

                    TweenService:Create(PointLight, normalTween, {Brightness = normalBrightness}):Play()
                    TweenService:Create(Bulb, normalTween, {Transparency = normalTransparency}):Play()
                    task.wait(math.random(1000, 2500) / 1000)

                    for _ = 1, math.random(1, 8) do
                        if not Bulb:GetAttribute("IsPowered") then break end
                        local flickerBrightness = math.random(25, 50) / 100
                        local flickerTransparency = 1 - flickerBrightness 
                        local flickerDuration = math.random(25, 200) / 1000
                        local flickerTween = TweenInfo.new(flickerDuration, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

                        TweenService:Create(PointLight, flickerTween, {Brightness = flickerBrightness}):Play()
                        TweenService:Create(Bulb, flickerTween, {Transparency = flickerTransparency}):Play()
                        task.wait(math.random(25, 200) / 1000)
                    end
                end
            end
        else
            if FlickeringSound then
                local Tween = TweenService:Create(FlickeringSound, TWInfoOff, { Volume = 0 })

                Tween.Completed:Once(function()
                    FlickeringSound:Destroy()
                end)

                Tween:Play()
            end

            RunService.Heartbeat:Wait()

            TweenService:Create(PointLight, TWInfoOff, { Brightness = 0 }):Play()
            TweenService:Create(Bulb, TWInfoOff, { Transparency = 1 }):Play()
        end
    end)
end
