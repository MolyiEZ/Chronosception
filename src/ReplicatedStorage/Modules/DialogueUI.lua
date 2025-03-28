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
local IsTyping, IsVisible = false, false
local ActiveConnections = {}
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
local DotsThread

local function CleanupDialogue()
	for _, Connection in ipairs(ActiveConnections) do
		if Connection and Connection.Connected then Connection:Disconnect() end
	end

	ActiveConnections = {}
	if DotsThread then
		task.cancel(DotsThread)
		DotsThread = nil
	end

	for _, Sound in ipairs(DialogueFrame:GetChildren()) do
		if Sound:IsA("Sound") then Sound:Destroy() end
	end

	IsTyping = false
	DialogueNext.Visible = false
end

local function StartDotAnimation(baseText)
	if DotsThread then task.cancel(DotsThread) end
	DialogueNext.Visible = true
	local Index = 1
	DotsThread = task.spawn(function()
		while true do
			DialogueNext.Text = baseText .. DOT_PATTERNS[Index]
			Index = (Index % #DOT_PATTERNS) + 1
			task.wait(DOT_SPEED)
		end
	end)
end

local function StopDotAnimation()
	if DotsThread then task.cancel(DotsThread) end
	DotsThread = nil
	DialogueNext.Visible = false
end

local function PlayTalkSound(person: string)
	local Sound = Sounds[person]:Clone()
	Sound.Parent = DialogueFrame
	Sound.PlaybackSpeed = math.random() * (MAX_PITCH - MIN_PITCH) + MIN_PITCH
	Sound:Play()
	Sound.Ended:Once(function() Sound:Destroy() end)
end

local function GetClosingTag(openTag: string)
	local TagName = openTag:match("<(%w+)")
	return TagName and ("</" .. TagName .. ">") or ""
end

local function Tokenize(input: string)
	local Tokens = {}
	local Index = 1
	while Index <= #input do
		local Start, End = input:find("<.->", Index)
		if Start then
			if Start > Index then
				table.insert(Tokens, { Type = "Text", Content = input:sub(Index, Start - 1) })
			end
			table.insert(Tokens, { Type = "Tag", Content = input:sub(Start, End) })
			Index = End + 1
		else
			table.insert(Tokens, { Type = "Text", Content = input:sub(Index) })
			break
		end
	end

	return Tokens
end

local function CopyArray(arr: table)
	local Copy = {}

	for i, v in ipairs(arr) do
		Copy[i] = v
	end

	return Copy
end

local function ParseSegments(tokens: table)
	local Segments = {}
	local ActiveStack = {}
	local CurrentText = ""

	for _, Token in ipairs(tokens) do
		if Token.Type == "Tag" then
			if #CurrentText > 0 then
				table.insert(Segments, { Text = CurrentText, Formatting = CopyArray(ActiveStack) })
				CurrentText = ""
			end

			if Token.Content:sub(-2) == "/>" then
				table.insert(Segments, { Text = Token.Content, Formatting = nil, IsSelfClosing = true })
			elseif Token.Content:sub(2,2) == "/" then
				table.remove(ActiveStack)
			else
				table.insert(ActiveStack, Token.Content)
			end
		else
			CurrentText = CurrentText .. Token.Content
		end
	end

	if #CurrentText > 0 then
		table.insert(Segments, { Text = CurrentText, Formatting = CopyArray(ActiveStack) })
	end

	return Segments
end

local function GetFormatTags(formatting: table)
	local OpenStr = ""
	local CloseStr = ""
	if formatting then
		for _, Tag in ipairs(formatting) do
			OpenStr = OpenStr .. Tag
			CloseStr = GetClosingTag(Tag) .. CloseStr
		end
	end
	return OpenStr, CloseStr
end

local function AnimateText(person: string, inputText: string)
    local Tokens = Tokenize(inputText)
    local Segments = ParseSegments(Tokens)
    local FinalText = ""
    local TimeAccumulator = 0
    local SoundAccumulator = 0
    local LastTime = os.clock()
    
    for _, Seg in ipairs(Segments) do
        if not IsTyping then
            DialogueText.Text = inputText
            return
        end

        if Seg.IsSelfClosing then
            FinalText = FinalText .. Seg.Text
            DialogueText.Text = FinalText
            continue
        end

        local OpenStr, CloseStr = GetFormatTags(Seg.Formatting)
        local CurrentSegmentRevealed = ""
        local Index = 1

        while Index <= #Seg.Text do
            if not IsTyping then
                DialogueText.Text = inputText
                return
            end

            local CurrentTime = os.clock()
            local dt = CurrentTime - LastTime
            TimeAccumulator = TimeAccumulator + dt
            SoundAccumulator = SoundAccumulator + dt
            LastTime = CurrentTime

            local CharsToShow = math.floor(TimeAccumulator / NORMAL_SPEED)
            if CharsToShow > 0 then
                TimeAccumulator = TimeAccumulator % NORMAL_SPEED
                local EndIndex = math.min(Index + CharsToShow - 1, #Seg.Text)
                local Chars = Seg.Text:sub(Index, EndIndex)

                CurrentSegmentRevealed = CurrentSegmentRevealed .. Chars
                DialogueText.Text = FinalText .. OpenStr .. CurrentSegmentRevealed .. CloseStr

                if IsTyping and SoundAccumulator >= SOUND_SPEED then
                    PlayTalkSound(person)
                    SoundAccumulator = 0
                end
                
                Index = EndIndex + 1
            end

            RunService.Heartbeat:Wait()
        end

        FinalText = FinalText .. OpenStr .. CurrentSegmentRevealed .. CloseStr
    end
end

function Dialogue.Talk(person: string, text: string)
	CleanupDialogue()
	RunService.Heartbeat:Wait()
	CleanupDialogue()
	RunService.Heartbeat:Wait()

	DialoguePerson.Image = Persons[person] or ""

	IsVisible = true
	IsTyping = true
	DialogueName.Text = person
	DialogueGroup.GroupTransparency = 1

	DialogueText.Text = ""

	local FadeIn = TweenService:Create(DialogueGroup, fadeInInfo, {GroupTransparency = 0})
	FadeIn:Play()
	FadeIn.Completed:Wait()

	StartDotAnimation("Press F to pass")

	local SkipConnection = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == BUTTON and IsTyping then
			IsTyping = false
			DialogueText.Text = text
			PlayTalkSound(person)
		end
	end)
	table.insert(ActiveConnections, SkipConnection)

	AnimateText(person, text)

	IsTyping = false
	SkipConnection:Disconnect()
	StartDotAnimation("Press F to continue")

	local Clicked = false
	local Connection
	
	Connection = UserInputService.InputBegan:Connect(function(input)
		if Clicked or input.KeyCode ~= BUTTON then return end
		Connection:Disconnect()
		Clicked = true

		StopDotAnimation()
		CleanupDialogue()
		local FadeOut = TweenService:Create(DialogueGroup, fadeOutInfo, { GroupTransparency = 1 })
		FadeOut:Play()
		IsVisible = false
	end)
	table.insert(ActiveConnections, Connection)

	while not Clicked do
		RunService.Heartbeat:Wait()
	end
end

function Dialogue.IsDialogueActive()
	return IsVisible or IsTyping
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
