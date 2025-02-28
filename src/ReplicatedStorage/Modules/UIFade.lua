local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Menu = PlayerGui:WaitForChild("Menu"):WaitForChild("CanvasGroup") :: CanvasGroup
local FadeUI = PlayerGui:WaitForChild("FadeUI"):WaitForChild("Frame") :: Frame

local TWInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local UIFade = {}

function UIFade.FadeOutMenu()
    local Tween = TweenService:Create(Menu, TWInfo, { GroupTransparency = 0 })
    Tween:Play()
    return Tween
end

function UIFade.FadeOut()
    local Tween = TweenService:Create(FadeUI, TWInfo, { BackgroundTransparency = 0 })
    Tween:Play()
    return Tween
end

function UIFade.FadeIn()
    local Tween = TweenService:Create(FadeUI, TWInfo, { BackgroundTransparency = 1 })
    Tween:Play()
    return Tween
end

return UIFade