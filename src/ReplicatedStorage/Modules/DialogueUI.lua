local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ECharacter = require(ReplicatedStorage:WaitForChild("Enums"):WaitForChild("ECharacter"))

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TalkSoundsFolder = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Talk") :: Folder
local TalkSoundYou = TalkSoundsFolder:WaitForChild("You") :: Sound
local TalkSoundYouIteration = TalkSoundsFolder:WaitForChild("YouIteration") :: Sound
local TalkSoundDad = TalkSoundsFolder:WaitForChild("Dad") :: Sound
local TalkSoundNarrator = TalkSoundsFolder:WaitForChild("Narrator") :: Sound

local DialogueUI = PlayerGui:WaitForChild("DialogueUI") :: ScreenGui
local DialogueGroup = DialogueUI:WaitForChild("DialogueGroup") :: Frame
local DialogueFrame = DialogueGroup:WaitForChild("DialogueFrame") :: CanvasGroup

local DialogueText = DialogueFrame:WaitForChild("Dialogue") :: TextLabel
local DialogueName = DialogueFrame:WaitForChild("Name") :: TextLabel
local DialogueNext = DialogueFrame:WaitForChild("Next") :: TextLabel
local DialoguePerson = DialogueFrame:WaitForChild("Person") :: ImageLabel

local Dialogue = {}
local isTyping, isVisible = false, false
local activeConnections = {}
local Persons = {
	[ECharacter.You] = "rbxassetid://72889430595307",
	[ECharacter.YouIteration] = "rbxassetid://134187447504257",
	[ECharacter.Dad] = "rbxassetid://93063863161723",
	[ECharacter["???"]] = "rbxassetid://140391009253634",
}

local Sounds = {
	[ECharacter.You] = TalkSoundYou,
	[ECharacter.YouIteration] = TalkSoundYouIteration,
	[ECharacter.Dad] = TalkSoundDad,
	[ECharacter["???"]] = TalkSoundNarrator,
}

local DOT_PATTERNS = {". ", ".. ", "... "}
local DOT_SPEED, NORMAL_SPEED, SOUND_SPEED = 0.55, 0.0455, 0.055
local NORMAL_SPEED_BACKUP = NORMAL_SPEED
local FADE_TIME = 0.5
local MIN_PITCH, MAX_PITCH = 0.995, 1.005
local BUTTON = Enum.KeyCode.F

local fadeInInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fadeOutInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local dotAnimationThread

local function CleanupDialogue()
	for _, conn in ipairs(activeConnections) do
		if conn and conn.Connected then conn:Disconnect() end
	end

	activeConnections = {}
	if dotAnimationThread then
		task.cancel(dotAnimationThread)
		dotAnimationThread = nil
	end

	for _, child in ipairs(DialogueFrame:GetChildren()) do
		if child:IsA("Sound") then child:Destroy() end
	end

	isTyping = false
	DialogueNext.Visible = false
end

local function StartDotAnimation(baseText)
	if dotAnimationThread then task.cancel(dotAnimationThread) end
	DialogueNext.Visible = true
	local index = 1
	dotAnimationThread = task.spawn(function()
		while true do
			DialogueNext.Text = baseText .. DOT_PATTERNS[index]
			index = (index % #DOT_PATTERNS) + 1
			task.wait(DOT_SPEED)
		end
	end)
end

local function StopDotAnimation()
	if dotAnimationThread then task.cancel(dotAnimationThread) end
	dotAnimationThread = nil
	DialogueNext.Visible = false
end

local function PlayTalkSound(person: string)
	local sound = Sounds[person]:Clone()
	sound.Parent = DialogueFrame
	sound.PlaybackSpeed = math.random()*(MAX_PITCH - MIN_PITCH) + MIN_PITCH
	sound:Play()
	sound.Ended:Once(function() sound:Destroy() end)
end

local function GetClosingTag(openTag)
	local tagName = openTag:match("<(%w+)")
	return tagName and ("</" .. tagName .. ">") or ""
end

local function Tokenize(input)
	local tokens = {}
	local pos = 1
	while pos <= #input do
		local s, e = input:find("<.->", pos)
		if s then
			if s > pos then
				table.insert(tokens, { type = "text", content = input:sub(pos, s - 1) })
			end
			table.insert(tokens, { type = "tag", content = input:sub(s, e) })
			pos = e + 1
		else
			table.insert(tokens, { type = "text", content = input:sub(pos) })
			break
		end
	end
	return tokens
end

local function ShallowCopy(t)
	local copy = {}
	for i, v in ipairs(t) do
		copy[i] = v
	end
	return copy
end

local function ParseSegments(tokens)
	local segments = {}
	local activeStack = {}
	local currentText = ""
	for _, token in ipairs(tokens) do
		if token.type == "tag" then
			if #currentText > 0 then
				table.insert(segments, { text = currentText, formatting = ShallowCopy(activeStack) })
				currentText = ""
			end

			if token.content:sub(-2) == "/>" then
				table.insert(segments, { text = token.content, formatting = nil, isSelfClosing = true })
			elseif token.content:sub(2,2) == "/" then
				table.remove(activeStack)
			else
				table.insert(activeStack, token.content)
			end
		else
			currentText = currentText .. token.content
		end
	end
	if #currentText > 0 then
		table.insert(segments, { text = currentText, formatting = ShallowCopy(activeStack) })
	end
	return segments
end

local function GetFormatTags(formatting)
	local openStr = ""
	local closeStr = ""
	if formatting then
		for _, tag in ipairs(formatting) do
			openStr = openStr .. tag
			closeStr = GetClosingTag(tag) .. closeStr
		end
	end
	return openStr, closeStr
end

local function AnimateText(person, inputText)
    local tokens = Tokenize(inputText)
    local segments = ParseSegments(tokens)
    local finalText = ""
    local timeAccumulator = 0
    local soundAccumulator = 0
    local lastTime = os.clock()
    
    for _, seg in ipairs(segments) do
        if not isTyping then
            DialogueText.Text = inputText
            return
        end

        if seg.isSelfClosing then
            finalText = finalText .. seg.text
            DialogueText.Text = finalText
            continue
        end

        local openStr, closeStr = GetFormatTags(seg.formatting)
        local currentSegmentRevealed = ""
        local i = 1

        while i <= #seg.text do
            if not isTyping then
                DialogueText.Text = inputText
                return
            end

            local currentTime = os.clock()
            local deltaTime = currentTime - lastTime
            timeAccumulator = timeAccumulator + deltaTime
            soundAccumulator = soundAccumulator + deltaTime
            lastTime = currentTime

            local charsToShow = math.floor(timeAccumulator / NORMAL_SPEED)
            if charsToShow > 0 then
                timeAccumulator = timeAccumulator % NORMAL_SPEED
                local endIndex = math.min(i + charsToShow - 1, #seg.text)
                local chars = seg.text:sub(i, endIndex)

                currentSegmentRevealed = currentSegmentRevealed .. chars
                DialogueText.Text = finalText .. openStr .. currentSegmentRevealed .. closeStr

                if isTyping and soundAccumulator >= SOUND_SPEED then
                    PlayTalkSound(person)
                    soundAccumulator = 0
                end
                
                i = endIndex + 1
            end

            RunService.Heartbeat:Wait()
        end

        finalText = finalText .. openStr .. currentSegmentRevealed .. closeStr
    end
end

function Dialogue.Talk(person: string, text: string, maxTime: number?)
	CleanupDialogue()
	RunService.Heartbeat:Wait()
	CleanupDialogue()
	RunService.Heartbeat:Wait()

	DialoguePerson.Image = Persons[person] or ""

	isVisible = true
	isTyping = true
	DialogueName.Text = person
	DialogueGroup.GroupTransparency = 1

	DialogueText.Text = ""

	local fadeIn = TweenService:Create(DialogueGroup, fadeInInfo, {GroupTransparency = 0})
	fadeIn:Play()
	fadeIn.Completed:Wait()

	StartDotAnimation("Press F to pass")

	local skipConn = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == BUTTON and isTyping then
			isTyping = false
			DialogueText.Text = text
			PlayTalkSound(person)
		end
	end)
	table.insert(activeConnections, skipConn)

	AnimateText(person, text)

	isTyping = false
	skipConn:Disconnect()
	StartDotAnimation("Press F to continue")

	local timeToSkip = 0
	local clicked = false
	local conn
	
	conn = UserInputService.InputBegan:Connect(function(input)
		if clicked or input.KeyCode ~= BUTTON then return end
		conn:Disconnect()
		clicked = true

		StopDotAnimation()
		CleanupDialogue()
		local fadeOut = TweenService:Create(DialogueGroup, fadeOutInfo, { GroupTransparency = 1 })
		fadeOut:Play()
		isVisible = false
	end)
	table.insert(activeConnections, conn)

	while not clicked do
		RunService.Heartbeat:Wait()
	end
end

function Dialogue.IsDialogueActive()
	return isVisible or isTyping
end

function Dialogue.SetSpeed(speed: number?)
	NORMAL_SPEED = speed or NORMAL_SPEED_BACKUP
end

function Dialogue.Centered(bool: boolean)
	if bool then
		DialogueText.TextXAlignment = Enum.TextXAlignment.Center
		DialogueText.TextYAlignment = Enum.TextXAlignment.Center
	else
		DialogueText.TextXAlignment = Enum.TextXAlignment.Left
		DialogueText.TextYAlignment = Enum.TextYAlignment.Top
	end
end

return Dialogue
