local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Tweens = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Tweens"))
local ESpeed = require(ReplicatedStorage:WaitForChild("Enums"):WaitForChild("ESpeed"))

local Animations = ReplicatedStorage:WaitForChild("Animations")
local RunAnimations = Animations:WaitForChild("Run") :: Folder
local WalkAnimations = Animations:WaitForChild("Walk") :: Folder
local RunFrontAnim = RunAnimations:WaitForChild("RunFront") :: Animation
local WalkFrontAnim = WalkAnimations:WaitForChild("WalkFront") :: Animation
local WalkFrontLeftAnim = WalkAnimations:WaitForChild("WalkFrontLeft") :: Animation
local WalkFrontRightAnim = WalkAnimations:WaitForChild("WalkFrontRight") :: Animation
local WalkBackAnim = WalkAnimations:WaitForChild("WalkBack") :: Animation
local WalkBackLeftAnim = WalkAnimations:WaitForChild("WalkBackLeft") :: Animation
local WalkBackRightAnim = WalkAnimations:WaitForChild("WalkBackRight") :: Animation
local WalkRightAnim = WalkAnimations:WaitForChild("WalkRight") :: Animation
local WalkLeftAnim = WalkAnimations:WaitForChild("WalkLeft") :: Animation
local IdleAnim = Animations:WaitForChild("Idle") :: Animation

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local RunFront = Animator:LoadAnimation(RunFrontAnim)

local WalkFront = Animator:LoadAnimation(WalkFrontAnim)
local WalkFrontLeft = Animator:LoadAnimation(WalkFrontLeftAnim)
local WalkFrontRight = Animator:LoadAnimation(WalkFrontRightAnim)
local WalkBack = Animator:LoadAnimation(WalkBackAnim)
local WalkBackLeft = Animator:LoadAnimation(WalkBackLeftAnim)
local WalkBackRight = Animator:LoadAnimation(WalkBackRightAnim)
local WalkLeft = Animator:LoadAnimation(WalkLeftAnim)
local WalkRight = Animator:LoadAnimation(WalkRightAnim)
local Idle = Animator:LoadAnimation(IdleAnim)

Idle:Play(0.1, 1, 0.65)

local AnimationPerDirection = {
    [Vector3.new(0,0,-1)] = WalkFront,
    [Vector3.new(-1,0,-1)] = WalkFrontLeft,
    [Vector3.new(1,0,-1)] = WalkFrontRight,
    [Vector3.new(0,0,1)] = WalkBack,
    [Vector3.new(-1,0,1)] = WalkBackLeft,
    [Vector3.new(1,0,1)] = WalkBackRight,
    [Vector3.new(-1,0,0)] = WalkLeft,
    [Vector3.new(1,0,0)] = WalkRight,
}

local FADE_OUT = 0.4
local FADE_IN = 0.4
local LIMIT = 1.32
local DISTANCE = LIMIT / 2
local WALK_ANIM_SPEED = 1.35
local RUN_ANIM_SPEED = 2

local CurrentMoveDirection = Vector3.zero
local PrevAnimation = nil
local PrevAnimationStop = 0
local PrevAnimationTimePosition = 0
local ShiftTouched = false

function StopAllAnimations(fadeOut: number)
    PrevAnimationStop = tick()
    PrevAnimationTimePosition = PrevAnimation ~= nil and PrevAnimation.TimePosition or 0
    RunFront:Stop(fadeOut)
    WalkFront:Stop(fadeOut)
    WalkFrontLeft:Stop(fadeOut)
    WalkFrontRight:Stop(fadeOut)
    WalkBack:Stop(fadeOut)
    WalkBackLeft:Stop(fadeOut)
    WalkBackRight:Stop(fadeOut)
    WalkLeft:Stop(fadeOut)
    WalkRight:Stop(fadeOut)
end

function WorldMovingDirection(dir)
    if dir == Vector3.zero then
        return dir
    end
    local Angle = math.atan2(dir.X, -dir.Z)
    local QuarterTurn = math.pi / 4
    Angle = -math.round(Angle / QuarterTurn) * QuarterTurn
    local NewX = math.round(-math.sin(Angle))
    local NewZ = math.round(-math.cos(Angle))
    if math.abs(NewX) <= 1e-10 then
        NewX = 0
    end
    if math.abs(NewZ) <= 1e-10 then
        NewZ = 0
    end
    return Vector3.new(NewX, 0, NewZ)
end

function AnimTime(normal: boolean)
    local TimeTick = tick() - PrevAnimationStop
    if not PrevAnimation or TimeTick > FADE_OUT then
        return 0
    end

    local Result
    if not normal then
        Result = PrevAnimationTimePosition + TimeTick
    else
        if TimeTick > DISTANCE then
            Result = PrevAnimationTimePosition - DISTANCE + TimeTick
        else
            Result = PrevAnimationTimePosition + DISTANCE + TimeTick
        end
    end

    if Result > LIMIT then
        Result = Result - LIMIT
    elseif Result < 0 then
        Result = LIMIT - math.abs(Result)
    end

    return Result
end

local function WalkAnimSpeed()
    return Humanoid.WalkSpeed * WALK_ANIM_SPEED / ESpeed.Walk
end

local function RunAnimSpeed()
    return Humanoid.WalkSpeed * RUN_ANIM_SPEED / ESpeed.Run
end

function MoveDirection()
    if Tweens.IsStunned() then
        StopAllAnimations(FADE_OUT)
        return
    end
    local Direction = WorldMovingDirection(HumanoidRootPart.CFrame:VectorToObjectSpace(Humanoid.MoveDirection))

    CurrentMoveDirection = Direction
    StopAllAnimations(FADE_OUT)
    if Direction == Vector3.zero then return end

    if ShiftTouched and Direction.Z ~= 1 then
        Tweens.SetSpeed(ESpeed.Run)
        RunFront:Play(FADE_IN, 1, RunAnimSpeed())
        RunFront.TimePosition = AnimTime(RunFront ~= WalkRight and PrevAnimation == WalkRight)
        PrevAnimation = RunFront
    else
        Tweens.SetSpeed(ESpeed.Walk)
        local Animation = AnimationPerDirection[CurrentMoveDirection]
        Animation:Play(FADE_IN, 1, WalkAnimSpeed())
        Animation.TimePosition = AnimTime(Animation ~= WalkRight and PrevAnimation == WalkRight)
        PrevAnimation = Animation
    end
end

local function HandleRunning(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        if input.UserInputState == Enum.UserInputState.Begin then
            ShiftTouched = true
            Tweens.SetSpeed(ESpeed.Run)
        else
            ShiftTouched = false
            Tweens.SetSpeed(ESpeed.Walk)
        end

        MoveDirection()
    end
end

Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(MoveDirection)
Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(MoveDirection)
UserInputService.InputBegan:Connect(HandleRunning)
UserInputService.InputEnded:Connect(HandleRunning)