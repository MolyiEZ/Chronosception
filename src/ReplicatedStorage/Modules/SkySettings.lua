local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedSky = ReplicatedStorage:WaitForChild("RedSky") :: Sky
local DefaultSky = Lighting:WaitForChild("DefaultSky") :: Sky

local SkySettings = {}

function SkySettings.Default()
    Lighting.ColorCorrection.TintColor = Color3.fromRGB(255,255,255)
    Lighting.Ambient = Color3.fromRGB(15,15,15)
    Lighting.Brightness = 2
    Lighting.ColorShift_Top = Color3.fromRGB(165,147,122)
    Lighting.ClockTime = 11.3
    Lighting.GeographicLatitude = 103
    Lighting.FogColor = Color3.fromRGB(7, 124, 147)
    RedSky.Parent = ReplicatedStorage
    DefaultSky.Parent = Lighting
end

function SkySettings.Red()
    Lighting.ColorCorrection.TintColor = Color3.fromRGB(230, 199, 199)
    Lighting.Ambient = Color3.fromRGB(25, 13, 11)
    Lighting.Brightness = 0.3
    Lighting.ColorShift_Top = Color3.fromRGB(165, 141, 54)
    Lighting.ClockTime = 7.6
    Lighting.GeographicLatitude = 105
    Lighting.FogColor = Color3.fromRGB(103, 45, 12)
    RedSky.Parent = Lighting
    DefaultSky.Parent = ReplicatedStorage
end

return SkySettings