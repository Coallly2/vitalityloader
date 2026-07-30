-- Legend's of Speed Source!
local CORRECT_KEY  = "VITALITYSCRIPTSISTHEBEST67" -- Change this whenever you want!
local DISCORD_LINK = "https://discord.gg/2wdxu8ff6n"
-- ============================================================

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function loadMainScript()
	local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/fanxx04/eee/refs/heads/main/skidded.lua"))()

	local Window = Library:Window({
		Name = "Vitality Scripts", 
		SubName = "Legends of Speed 〢 @Vitality", 
		Logo = "rbxassetid://106850780184145"
	})

	local GamePage = Window:Page({Name = "Legends of Speed", Icon = "rbxassetid://112148279212860"})
	local SafePage = Window:Page({Name = "Safe Mode", Icon = "rbxassetid://115398113982385"})

	local Watermark = "Vitality"
	Library:CreateSettingsPage(Window, Watermark)

	local activeThreads = {}
	local function registerThread(thread)
		table.insert(activeThreads, thread)
	end

	--============================================================
	-- LEGENDS OF SPEED (NORMAL FAST MODE)
	--============================================================
	local orbSection = GamePage:Section({Name = "Auto Collectors (Max Speed)", Side = 1, Icon = "rbxassetid://103376704722051"})
	local raceHoopSection = GamePage:Section({Name = "Auto Races & Hoops", Side = 1, Icon = "rbxassetid://109855212076373"})
	local miscSection = GamePage:Section({Name = "Auto Rebirth & Gifts", Side = 2, Icon = "rbxassetid://128420521375441"})

	local function setupCollector(section, name, flag, eventPath, args)
		local isRunning = false
		local thread = nil

		section:Toggle({
			Name = name,
			Flag = flag,
			Callback = function(state)
				isRunning = state
				if state then
					thread = task.spawn(function()
						while isRunning do
							pcall(function()
								local current = ReplicatedStorage
								for _, path in ipairs(eventPath) do
									current = current:FindFirstChild(path)
								end
								if current then
									current:FireServer(unpack(args))
								end
							end)
							RunService.Heartbeat:Wait()
						end
					end)
					registerThread(thread)
				else
					if thread then pcall(function() task.cancel(thread) end) thread = nil end
				end
			end
		})
	end

	-- Orbs & Gems
	setupCollector(orbSection, "Auto Red Orb (+40 Speed)", "AutoRedOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Red Orb", "City"})
	setupCollector(orbSection, "Auto Blue Orb (+15 Speed)", "AutoBlueOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Blue Orb", "City"})
	setupCollector(orbSection, "Auto Orange Orb (+10 Speed)", "AutoOrangeOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Orange Orb", "City"})
	setupCollector(orbSection, "Auto Yellow Orb (+1 EXP)", "AutoYellowOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Yellow Orb", "City"})
	setupCollector(orbSection, "Auto Gem Collector", "AutoGem", {"rEvents", "orbEvent"}, {"collectOrb", "Gem", "City"})

	-- Auto Hoops
	local isHooping = false
	local hoopThread = nil
	raceHoopSection:Toggle({
		Name = "Auto Collect All Hoops",
		Flag = "AutoHoops",
		Callback = function(state)
			isHooping = state
			if state then
				hoopThread = task.spawn(function()
					while isHooping do
						pcall(function()
							local hoopsFolder = workspace:FindFirstChild("Hoops") or workspace:FindFirstChild("HoopFolder")
							if hoopsFolder then
								for _, hoop in ipairs(hoopsFolder:GetChildren()) do
									if not isHooping then break end
									if hoop:IsA("BasePart") or hoop:FindFirstChild("TouchInterest") then
										firetouchinterest(player.Character.HumanoidRootPart, hoop, 0)
										firetouchinterest(player.Character.HumanoidRootPart, hoop, 1)
									end
								end
							end
						end)
						RunService.Heartbeat:Wait()
					end
				end)
				registerThread(hoopThread)
			else
				if hoopThread then pcall(function() task.cancel(hoopThread) end) hoopThread = nil end
			end
		end
	})

	-- Auto Join & Win Race
	local isRacing = false
	local raceThread = nil
	raceHoopSection:Toggle({
		Name = "Auto Join & Win Races",
		Flag = "AutoRaceWin",
		Callback = function(state)
			isRacing = state
			if state then
				raceThread = task.spawn(function()
					while isRacing do
						pcall(function()
							local joinEvent = ReplicatedStorage:FindFirstChild("rEvents"):FindFirstChild("raceEvent")
							if joinEvent then
								joinEvent:FireServer("joinRace")
							end
							local finishTouch = workspace:FindFirstChild("RaceEnd") or workspace:FindFirstChild("FinishLine")
							if finishTouch and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
								firetouchinterest(player.Character.HumanoidRootPart, finishTouch, 0)
								firetouchinterest(player.Character.HumanoidRootPart, finishTouch, 1)
							end
						end)
						task.wait(0.5)
					end
				end)
				registerThread(raceThread)
			else
				if raceThread then pcall(function() task.cancel(raceThread) end) raceThread = nil end
			end
		end
	})

	-- Rebirth & Gifts
	setupCollector(miscSection, "Auto Rebirth", "AutoRebirth", {"rEvents", "rebirthEvent"}, {"rebirthRequest"})

	local isClaimingGifts = false
	local giftThread = nil
	miscSection:Toggle({
		Name = "Auto Claim Free Gifts",
		Flag = "AutoClaimGifts",
		Callback = function(state)
			isClaimingGifts = state
			if state then
				giftThread = task.spawn(function()
					while isClaimingGifts do
						pcall(function()
							local ev = ReplicatedStorage:FindFirstChild("rEvents"):FindFirstChild("freeGiftClaimRemote")
							if ev then
								for i = 1, 8 do
									ev:InvokeServer("claimGift", i)
								end
							end
						end)
						task.wait(1)
					end
				end)
				registerThread(giftThread)
			else
				if giftThread then pcall(function() task.cancel(giftThread) end) giftThread = nil end
			end
		end
	})

	--============================================================
	-- LEGENDS OF SPEED (SAFE MODE - 0.1s DELAY)
	--============================================================
	local safeOrbSection = SafePage:Section({Name = "Safe Collectors (0.1s)", Side = 1, Icon = "rbxassetid://103376704722051"})
	local safeMiscSection = SafePage:Section({Name = "Safe Rebirth", Side = 2, Icon = "rbxassetid://128420521375441"})

	local function setupSafeCollector(section, name, flag, eventPath, args)
		local isRunning = false
		local thread = nil

		section:Toggle({
			Name = name,
			Flag = flag,
			Callback = function(state)
				isRunning = state
				if state then
					thread = task.spawn(function()
						while isRunning do
							pcall(function()
								local current = ReplicatedStorage
								for _, path in ipairs(eventPath) do
									current = current:FindFirstChild(path)
								end
								if current then
									current:FireServer(unpack(args))
								end
							end)
							task.wait(0.1)
						end
					end)
					registerThread(thread)
				else
					if thread then pcall(function() task.cancel(thread) end) thread = nil end
				end
			end
		})
	end

	setupSafeCollector(safeOrbSection, "Auto Red Orb (+40 Speed)", "SafeRedOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Red Orb", "City"})
	setupSafeCollector(safeOrbSection, "Auto Gem", "SafeGem", {"rEvents", "orbEvent"}, {"collectOrb", "Gem", "City"})
	setupSafeCollector(safeOrbSection, "Auto Orange Orb (+10 Speed)", "SafeOrangeOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Orange Orb", "City"})
	setupSafeCollector(safeOrbSection, "Auto Yellow Orb (+1 EXP)", "SafeYellowOrb", {"rEvents", "orbEvent"}, {"collectOrb", "Yellow Orb", "City"})

	setupSafeCollector(safeMiscSection, "Auto Rebirth", "SafeRebirth", {"rEvents", "rebirthEvent"}, {"rebirthRequest"})
end

local existing = playerGui:FindFirstChild("VitalityUI")
if existing then
	existing:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VitalityUI"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(11, 12, 16)
frame.Size = UDim2.new(0, 594, 0, 354)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.ClipsDescendants = true
frame.BorderSizePixel = 0

local frameCorner = Instance.new("UICorner")
frameCorner.Parent = frame
frameCorner.CornerRadius = UDim.new(0, 11)

local close = Instance.new("TextButton")
close.Parent = frame
close.BackgroundTransparency = 1
close.Position = UDim2.new(1, -35, 0, 5)
close.Size = UDim2.new(0, 30, 0, 25)
close.Font = Enum.Font.GothamBold
close.Text = "X"
close.TextColor3 = Color3.fromRGB(170, 170, 170)
close.TextSize = 18
close.ZIndex = 20
close.BorderSizePixel = 0

local pagesFolder = Instance.new("Folder")
pagesFolder.Name = "Pages"
pagesFolder.Parent = frame

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name
	page.Parent = pagesFolder
	page.BackgroundTransparency = 1
	page.Size = UDim2.new(1, 0, 1, 0)
	page.Position = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.BorderSizePixel = 0
	return page
end

local getKeyPage = createPage("GetKeyPage")
local redeemPage = createPage("RedeemPage")
local loadingPage = createPage("LoadingPage")

local currentPage = nil
local switching = false
local loadingAnimationId = 0

local tweenInInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenOutInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local function showPage(newPage, direction)
	if switching or currentPage == newPage then
		return
	end

	switching = true

	if not currentPage then
		newPage.Visible = true
		newPage.Position = UDim2.new(0, 0, 0, 0)
		currentPage = newPage
		switching = false
		return
	end

	local oldPage = currentPage
	local offset = direction == "right" and 1 or -1

	newPage.Visible = true
	newPage.Position = UDim2.new(offset, 0, 0, 0)

	local outTween = TweenService:Create(oldPage, tweenOutInfo, {
		Position = UDim2.new(-offset, 0, 0, 0)
	})

	local inTween = TweenService:Create(newPage, tweenInInfo, {
		Position = UDim2.new(0, 0, 0, 0)
	})

	outTween:Play()
	inTween:Play()
	inTween.Completed:Wait()

	oldPage.Visible = false
	oldPage.Position = UDim2.new(0, 0, 0, 0)
	currentPage = newPage
	switching = false
end

local function makeHeader(parent)
	local headerGroup = Instance.new("Frame")
	headerGroup.Parent = parent
	headerGroup.BackgroundTransparency = 1
	headerGroup.AnchorPoint = Vector2.new(0.5, 0)
	headerGroup.Position = UDim2.new(0.5, 0, 0.06, 0)
	headerGroup.Size = UDim2.new(0, 260, 0, 52)
	headerGroup.BorderSizePixel = 0

	local textGroup = Instance.new("Frame")
	textGroup.Parent = headerGroup
	textGroup.BackgroundTransparency = 1
	textGroup.AnchorPoint = Vector2.new(0.5, 0)
	textGroup.Position = UDim2.new(0.5, 28, 0, 0)
	textGroup.Size = UDim2.new(0, 140, 0, 34)
	textGroup.BorderSizePixel = 0

	local title = Instance.new("TextLabel")
	title.Parent = textGroup
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 0, 0, 0)
	title.Size = UDim2.new(1, 0, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.Text = "Vitality"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.BorderSizePixel = 0

	local subtitle = Instance.new("TextLabel")
	subtitle.Parent = textGroup
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.new(0, 0, 0, 19)
	subtitle.Size = UDim2.new(1, 0, 0, 14)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Text = "BEST ROBLOX HUB"
	subtitle.TextColor3 = Color3.new(1, 1, 1)
	subtitle.TextSize = 10
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	subtitle.BorderSizePixel = 0

	local logo = Instance.new("ImageLabel")
	logo.Parent = headerGroup
	logo.BackgroundTransparency = 1
	logo.AnchorPoint = Vector2.new(1, 0.5)
	logo.Position = UDim2.new(0.5, -30, 0.5, -5)
	logo.Size = UDim2.new(0, 34, 0, 34)
	logo.Image = "rbxassetid://106850780184145"
	logo.BorderSizePixel = 0
end

makeHeader(getKeyPage)
makeHeader(redeemPage)

local function makeTabs(parent, redeemActive)
	local tabWidth = 100
	local tabHeight = 38
	local gap = 12
	local totalWidth = (tabWidth * 2) + gap
	local startX = 0.5
	local startOffset = -(totalWidth / 2)

	local redeemButton = Instance.new("TextButton")
	redeemButton.Parent = parent
	redeemButton.Position = UDim2.new(startX, startOffset, 0.23, 0)
	redeemButton.Size = UDim2.new(0, tabWidth, 0, tabHeight)
	redeemButton.BackgroundColor3 = redeemActive and Color3.fromRGB(40, 190, 207) or Color3.fromRGB(14, 14, 16)
	redeemButton.Font = redeemActive and Enum.Font.GothamBold or Enum.Font.Gotham
	redeemButton.Text = "Redeem Key"
	redeemButton.TextColor3 = redeemActive and Color3.new(1, 1, 1) or Color3.fromRGB(170, 170, 170)
	redeemButton.TextSize = 13
	redeemButton.BorderSizePixel = 0

	local redeemCorner = Instance.new("UICorner")
	redeemCorner.Parent = redeemButton
	redeemCorner.CornerRadius = UDim.new(0, 6)

	local getButton = Instance.new("TextButton")
	getButton.Parent = parent
	getButton.Position = UDim2.new(startX, startOffset + tabWidth + gap, 0.23, 0)
	getButton.Size = UDim2.new(0, tabWidth, 0, tabHeight)
	getButton.BackgroundColor3 = redeemActive and Color3.fromRGB(14, 14, 16) or Color3.fromRGB(40, 190, 207)
	getButton.Font = redeemActive and Enum.Font.Gotham or Enum.Font.GothamBold
	getButton.Text = "Get Key"
	getButton.TextColor3 = redeemActive and Color3.fromRGB(170, 170, 170) or Color3.new(1, 1, 1)
	getButton.TextSize = 13
	getButton.BorderSizePixel = 0

	local getCorner = Instance.new("UICorner")
	getCorner.Parent = getButton
	getCorner.CornerRadius = UDim.new(0, 6)

	return redeemButton, getButton
end

local getKeyTabRedeem, getKeyTabGet = makeTabs(getKeyPage, false)
local redeemTabRedeem, redeemTabGet = makeTabs(redeemPage, true)

local getKeyImage = Instance.new("ImageLabel")
getKeyImage.Parent = getKeyPage
getKeyImage.BackgroundTransparency = 1
getKeyImage.AnchorPoint = Vector2.new(0.5, 0)
getKeyImage.Position = UDim2.new(0.5, 0, 0.4, 0)
getKeyImage.Size = UDim2.new(0, 74, 0, 73)
getKeyImage.Image = "rbxassetid://80213665896573"
getKeyImage.BorderSizePixel = 0

local copyLink = Instance.new("TextButton")
copyLink.Parent = getKeyPage
copyLink.AnchorPoint = Vector2.new(0.5, 0)
copyLink.Position = UDim2.new(0.5, 0, 0.65, 0)
copyLink.Size = UDim2.new(0, 230, 0, 45)
copyLink.BackgroundColor3 = Color3.fromRGB(40, 190, 207)
copyLink.Font = Enum.Font.GothamBold
copyLink.Text = "Copy Discord Link"
copyLink.TextColor3 = Color3.new(1, 1, 1)
copyLink.TextSize = 20
copyLink.BorderSizePixel = 0

local copyLinkCorner = Instance.new("UICorner")
copyLinkCorner.Parent = copyLink
copyLinkCorner.CornerRadius = UDim.new(0, 6)

local getKeyInfo = Instance.new("TextLabel")
getKeyInfo.Parent = getKeyPage
getKeyInfo.BackgroundTransparency = 1
getKeyInfo.AnchorPoint = Vector2.new(0.5, 0)
getKeyInfo.Position = UDim2.new(0.5, 0, 0.80, 0)
getKeyInfo.Size = UDim2.new(0, 240, 0, 40)
getKeyInfo.Font = Enum.Font.Gotham
getKeyInfo.Text = "Keys reset every 24 hours!\nJoin Discord to get today's key."
getKeyInfo.TextColor3 = Color3.fromRGB(130, 130, 130)
getKeyInfo.TextSize = 11
getKeyInfo.TextWrapped = true
getKeyInfo.TextXAlignment = Enum.TextXAlignment.Center
getKeyInfo.BorderSizePixel = 0

local redeemImage = Instance.new("ImageLabel")
redeemImage.Parent = redeemPage
redeemImage.BackgroundTransparency = 1
redeemImage.AnchorPoint = Vector2.new(0.5, 0)
redeemImage.Position = UDim2.new(0.5, 0, 0.4, 0)
redeemImage.Size = UDim2.new(0, 74, 0, 73)
redeemImage.Image = "rbxassetid://85454232851622"
redeemImage.BorderSizePixel = 0

local keyBox = Instance.new("TextBox")
keyBox.Parent = redeemPage
keyBox.BackgroundColor3 = Color3.fromRGB(14, 15, 17)
keyBox.BorderSizePixel = 0
keyBox.AnchorPoint = Vector2.new(0.5, 0)
keyBox.Position = UDim2.new(0.5, 0, 0.617, 0)
keyBox.Size = UDim2.new(0, 231, 0, 44)
keyBox.Font = Enum.Font.Gotham
keyBox.PlaceholderText = "Enter 24h Key"
keyBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
keyBox.Text = "" -- Always blank for manual entry
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.TextSize = 14

local keyBoxCorner = Instance.new("UICorner")
keyBoxCorner.Parent = keyBox
keyBoxCorner.CornerRadius = UDim.new(0, 6)

local launch = Instance.new("TextButton")
launch.Parent = redeemPage
launch.BackgroundColor3 = Color3.fromRGB(40, 190, 207)
launch.BorderSizePixel = 0
launch.AnchorPoint = Vector2.new(0.5, 0)
launch.Position = UDim2.new(0.5, 0, 0.78, 0)
launch.Size = UDim2.new(0, 231, 0, 44)
launch.Font = Enum.Font.GothamBold
launch.Text = "Launch"
launch.TextColor3 = Color3.fromRGB(255, 255, 255)
launch.TextSize = 21

local launchCorner = Instance.new("UICorner")
launchCorner.Parent = launch
launchCorner.CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = redeemPage
statusLabel.BackgroundTransparency = 1
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.Position = UDim2.new(0.5, 0, 0.91, 0)
statusLabel.Size = UDim2.new(0, 340, 0, 24)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextWrapped = true
statusLabel.BorderSizePixel = 0

local barWidth = 30
local barMinHeight = 55
local barMaxHeight = 125
local barY = 0.60

local activeColor = Color3.fromRGB(40, 190, 207)
local idleColor = Color3.fromRGB(33, 159, 173)

local bar1 = Instance.new("Frame")
bar1.Parent = loadingPage
bar1.BackgroundColor3 = activeColor
bar1.BorderSizePixel = 0
bar1.AnchorPoint = Vector2.new(0.5, 1)
bar1.Position = UDim2.new(0.42, 0, barY, 0)
bar1.Size = UDim2.new(0, barWidth, 0, barMinHeight)

local bar1Corner = Instance.new("UICorner")
bar1Corner.Parent = bar1
bar1Corner.CornerRadius = UDim.new(0, 6)

local bar2 = Instance.new("Frame")
bar2.Parent = loadingPage
bar2.BackgroundColor3 = idleColor
bar2.BorderSizePixel = 0
bar2.AnchorPoint = Vector2.new(0.5, 1)
bar2.Position = UDim2.new(0.50, 0, barY, 0)
bar2.Size = UDim2.new(0, barWidth, 0, barMinHeight)

local bar2Corner = Instance.new("UICorner")
bar2Corner.Parent = bar2
bar2Corner.CornerRadius = UDim.new(0, 6)

local bar3 = Instance.new("Frame")
bar3.Parent = loadingPage
bar3.BackgroundColor3 = idleColor
bar3.BorderSizePixel = 0
bar3.AnchorPoint = Vector2.new(0.5, 1)
bar3.Position = UDim2.new(0.58, 0, barY, 0)
bar3.Size = UDim2.new(0, barWidth, 0, barMinHeight)

local bar3Corner = Instance.new("UICorner")
bar3Corner.Parent = bar3
bar3Corner.CornerRadius = UDim.new(0, 6)

local loadingText = Instance.new("TextLabel")
loadingText.Parent = loadingPage
loadingText.BackgroundTransparency = 1
loadingText.AnchorPoint = Vector2.new(0.5, 0)
loadingText.Position = UDim2.new(0.5, 0, 0.76, 0)
loadingText.Size = UDim2.new(0, 340, 0, 50)
loadingText.Font = Enum.Font.Gotham
loadingText.Text = "Verifying Key..."
loadingText.TextColor3 = Color3.new(1, 1, 1)
loadingText.TextSize = 17
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.TextWrapped = true
loadingText.BorderSizePixel = 0

local function setStatus(text, color)
	statusLabel.Text = text or ""
	statusLabel.TextColor3 = color or Color3.fromRGB(170, 170, 170)
end

local function setBarColors(activeIndex)
	bar1.BackgroundColor3 = activeIndex == 1 and activeColor or idleColor
	bar2.BackgroundColor3 = activeIndex == 2 and activeColor or idleColor
	bar3.BackgroundColor3 = activeIndex == 3 and activeColor or idleColor
end

local function tweenBar(bar, height, duration)
	local tween = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, barWidth, 0, height)
	})
	tween:Play()
	return tween
end

local function startLoadingAnimation()
	loadingAnimationId += 1
	local token = loadingAnimationId

	bar1.Size = UDim2.new(0, barWidth, 0, barMinHeight)
	bar2.Size = UDim2.new(0, barWidth, 0, barMinHeight)
	bar3.Size = UDim2.new(0, barWidth, 0, barMinHeight)
	setBarColors(1)

	task.spawn(function()
		local states = {
			{1, {barMaxHeight, barMinHeight, barMinHeight}},
			{2, {barMinHeight, barMaxHeight, barMinHeight}},
			{3, {barMinHeight, barMinHeight, barMaxHeight}},
		}

		local index = 1

		while loadingAnimationId == token and loadingPage.Visible do
			local activeIndex = states[index][1]
			local heights = states[index][2]

			setBarColors(activeIndex)

			local t1 = tweenBar(bar1, heights[1], 0.6)
			local t2 = tweenBar(bar2, heights[2], 0.6)
			local t3 = tweenBar(bar3, heights[3], 0.6)

			t1.Completed:Wait()

			if loadingAnimationId ~= token or not loadingPage.Visible then
				break
			end

			index += 1
			if index > #states then
				index = 1
			end
		end
	end)
end

local function stopLoadingAnimation()
	loadingAnimationId += 1
end

close.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

getKeyTabRedeem.MouseButton1Click:Connect(function()
	setStatus("")
	showPage(redeemPage, "left")
end)

redeemTabGet.MouseButton1Click:Connect(function()
	setStatus("")
	showPage(getKeyPage, "right")
end)

copyLink.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(DISCORD_LINK)
		copyLink.Text = "Copied!"
		task.delay(1.2, function()
			if copyLink and copyLink.Parent then
				copyLink.Text = "Copy Discord Link"
			end
		end)
	else
		copyLink.Text = "Clipboard Unavailable"
		task.delay(1.2, function()
			if copyLink and copyLink.Parent then
				copyLink.Text = "Copy Discord Link"
			end
		end)
	end
end)

launch.MouseButton1Click:Connect(function()
	local inputKey = keyBox.Text
	showPage(loadingPage, "left")
	startLoadingAnimation()

	task.wait(1)

	if inputKey == CORRECT_KEY then
		loadingText.Text = "Key valid, launching..."
		task.wait(1)
		stopLoadingAnimation()
		screenGui:Destroy()
		pcall(loadMainScript)
	else
		stopLoadingAnimation()
		showPage(redeemPage, "right")
		setStatus("Invalid or Expired Key! Check Discord for today's key.", Color3.fromRGB(255, 80, 80))
	end
end)

showPage(redeemPage, "right")
