local HighlightManager = {}
local TweenService = game:GetService("TweenService")

local TWInfo = TweenInfo.new(
    1,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.InOut,
    -1
)

local TWInfoOut = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function HighlightManager.Add(part: BasePart, color: Color3?)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color or Color3.fromRGB(255,255,255)
    highlight.Parent = part

    local tweenGoal = {OutlineTransparency = 0.75}
    local tween = TweenService:Create(highlight, TWInfo, tweenGoal)

    tween:Play()

    return highlight
end

function HighlightManager.Remove(part: BasePart)
    if not part then return end
    local descendants = part:GetDescendants()

    for _, value in descendants do
        if not value:IsA("Highlight") then continue end

        task.spawn(function()
            local fadeOutTween = TweenService:Create(value, TWInfoOut, {
                OutlineTransparency = 1
            })
            fadeOutTween:Play()

            task.wait(TWInfoOut.Time)
            value:Destroy()
        end)
    end
end

return HighlightManager