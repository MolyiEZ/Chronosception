local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local TWInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

local CameraShake = {}

function CameraShake.Start(duration: number, intensity: number)
    local StartTime = os.clock()
    local Connection
    
    Connection = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - StartTime
        if elapsed >= duration then
            TweenService:Create(Humanoid, TWInfo, { CameraOffset = Vector3.zero }):Play()
            Connection:Disconnect()
            return
        end
        
        local Alpha = 1 - (elapsed / duration)
        local Offset = Vector3.new(
            math.random(-10, 10) * intensity * Alpha,
            math.random(-10, 10) * intensity * Alpha,
            math.random(-10, 10) * intensity * Alpha
        )

        Humanoid.CameraOffset = Offset
    end)
end

return CameraShake