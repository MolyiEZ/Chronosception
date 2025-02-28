local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head") :: BasePart
local StartEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Start") :: BindableEvent

Humanoid.AutoRotate = false

Camera.FieldOfView = 90
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CameraSubject = Head
Camera.Focus = Camera.CameraSubject.CFrame
Camera.CFrame = Camera.Focus

local x, y, z = Camera.CFrame:ToEulerAngles(Enum.RotationOrder.XYZ)

local xRot = y
local yRot = -x
local RandomPitch = 0
local RandomRoll = 0
local MouseDrift = 0
local OscX = 0
local SwayYaw = 0
local VelTilt = 0
local Freq = 10
local Amp = 10

local CameraSensitivity = 0.15
local MaxOffset = 25

local Config = {
	Idle = { Threshold = 0.1, Freq = 13, Amp = 15 },
	Walk = { Threshold = 10, Freq = 15, Amp = 17 },
	Run = { Threshold = 18, Freq = 16, Amp = 18 }
}

local function Lerp(a, b, t)
	return a + (b - a) * t
end

local function UpdateCamera(dt)
	dt = dt * 60
	if Humanoid.AutoRotate then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		local mouseDelta = UserInputService:GetMouseDelta()
		local mouseSensitivity = UserGameSettings.MouseSensitivity

		xRot = xRot + math.rad((mouseDelta.X * 0.25) * mouseSensitivity * -1)
		yRot = yRot + math.rad((mouseDelta.Y * 0.25) * mouseSensitivity * -1)
		yRot = math.clamp(yRot, math.rad(-75), math.rad(75))

		Camera.Focus = CFrame.new(Camera.CameraSubject.Position)
		Camera.CFrame = Camera.Focus * CFrame.fromEulerAnglesYXZ(yRot, xRot, 0)
		local x, y, z = Camera.CFrame:ToOrientation()
		HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, y, 0), 1)

		local vel = HumanoidRootPart.AssemblyLinearVelocity
		local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude

		if dt > 3 then
			RandomPitch = 0
			RandomRoll = 0
		else
			local tTick = tick()
			RandomPitch = Lerp(RandomPitch, math.cos(tTick * 0.5 * math.random(10,15)) * ((math.random(5,20) / 200) * dt), 0.05 * dt)
			RandomRoll = Lerp(RandomRoll, math.cos(tTick * 0.5 * math.random(5,10)) * ((math.random(2,10) / 200) * dt), 0.05 * dt)
		end

		Camera.CFrame = Camera.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(MouseDrift)) * CFrame.fromEulerAnglesXYZ(math.rad(OscX * dt), math.rad(SwayYaw * dt), VelTilt) * CFrame.Angles(0, 0, math.rad(OscX * dt * (speed / 5))) * CFrame.fromEulerAnglesXYZ(math.rad(RandomPitch), math.rad(RandomRoll), math.rad(RandomRoll * 10))
		local WalkSpeed = math.max(Humanoid.WalkSpeed, 0.01)

		VelTilt = math.clamp(Lerp(VelTilt, -Camera.CFrame:VectorToObjectSpace(vel / WalkSpeed).X * 0.08, 0.1 * dt), -0.35, 0.2)
		MouseDrift = Lerp(MouseDrift, math.clamp(UserInputService:GetMouseDelta().X, -5, 5), 0.25 * dt)
		OscX = Lerp(OscX, math.sin(tick() * Freq) / 5 * math.min(1, Amp / 10), 0.25 * dt)

		if speed > 1 then
			SwayYaw = Lerp(SwayYaw, math.cos(tick() * 0.5 * math.floor(Freq)) * (Freq / 200), 0.25 * dt)
		else
			SwayYaw = Lerp(SwayYaw, 0, 0.05 * dt)
		end
		if speed > Config.Run.Threshold then
			Freq, Amp = Config.Run.Freq, Config.Run.Amp
		elseif speed > Config.Walk.Threshold then
			Freq, Amp = Config.Walk.Freq, Config.Walk.Amp
		elseif speed > Config.Idle.Threshold then
			Freq, Amp = Config.Idle.Freq, Config.Idle.Amp
		else
			Amp = 0
		end
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		local viewportSize = Camera.ViewportSize;

        local OffsetX = ((Mouse.X - viewportSize.X / 2) / (viewportSize.X / 2)) * MaxOffset;
        local OffsetY = ((Mouse.Y - viewportSize.Y / 2) / (viewportSize.Y / 2)) * MaxOffset;

        Camera.Focus = Camera.CameraSubject.CFrame
        Camera.CFrame = Camera.Focus * CFrame.Angles(math.rad(-OffsetY * CameraSensitivity), math.rad(-OffsetX * CameraSensitivity), 0)
	end

	Camera.CFrame = Camera.CFrame + Humanoid.CameraOffset
end

RunService:BindToRenderStep("FirstPerson", 0, UpdateCamera)