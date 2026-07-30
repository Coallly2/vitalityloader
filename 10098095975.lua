-- +1 Strength Per Click


-- ============================================================
-- [CONFIG] UPDATE YOUR KEY & DISCORD HERE
-- ============================================================
local CORRECT_KEY  = "VITALITYSCRIPTSISTHEBEST67"
local DISCORD_LINK = "https://discord.gg/2wdxu8ff6n"
-- ============================================================

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------------
-- STEP 1: VITALITY INTRO ANIMATION
---------------------------------------------------------------
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local introGui = Instance.new("ScreenGui", playerGui)
introGui.Name = "VitalityLoader"
introGui.ResetOnSpawn = false
introGui.IgnoreGuiInset = true

local introFrame = Instance.new("Frame", introGui)
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundTransparency = 1

local introBg = Instance.new("Frame", introFrame)
introBg.Size = UDim2.new(1, 0, 1, 0)
introBg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
introBg.BackgroundTransparency = 1
introBg.ZIndex = 0
TweenService:Create(introBg, TweenInfo.new(0.5), {BackgroundTransparency = 0.25}):Play()

local word = "VITALITY"
local letters = {}

for i = 1, #word do
	local char = word:sub(i, i)

	local label = Instance.new("TextLabel")
	label.Text = char
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 1 
	label.TextTransparency = 1
	label.TextScaled = false
	label.TextSize = 30 
	label.Size = UDim2.new(0, 50, 0, 50)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 52, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Parent = introFrame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 180)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255))
	})
	gradient.Rotation = 90
	gradient.Parent = label

	TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 55}):Play()
	table.insert(letters, label)
	task.wait(0.18)
end

task.wait(1.5)

-- Fade out Intro
for _, label in ipairs(letters) do
	TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
end
TweenService:Create(introBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
task.wait(0.6)

introGui:Destroy()
blur:Destroy()

---------------------------------------------------------------
-- STEP 2: MAIN KEY SYSTEM & HUB SCRIPT
---------------------------------------------------------------
local mainScriptLoaded = false
local targetGui = nil

local function loadMainScript()
	local existingGuis = {}
	
	local function scanExisting()
		for _, gui in ipairs(playerGui:GetChildren()) do existingGuis[gui] = true end
		pcall(function() for _, gui in ipairs(CoreGui:GetChildren()) do existingGuis[gui] = true end end)
		pcall(function() if gethui then for _, gui in ipairs(gethui():GetChildren()) do existingGuis[gui] = true end end end)
	end
	
	scanExisting()

	local success, err = pcall(function()
		local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/fanxx04/eee/refs/heads/main/skidded.lua"))()

		local Window = Library:Window({
			Name = "+1 Strength Per Click", 
			SubName = "Vitality Hub 〢 @Vitality", 
			Logo = "rbxassetid://106850780184145"
		})

		local GamePage = Window:Page({Name = "Main", Icon = "rbxassetid://112148279212860"})

		-- Helper resolution function to handle section creation safely
		local function getSection(page, name)
			if type(page.Section) == "function" then
				return page:Section({Name = name})
			elseif type(page.AddSection) == "function" then
				return page:AddSection({Name = name})
			elseif type(page.CreateSection) == "function" then
				return page:CreateSection({Name = name})
			end
			return page
		end

		-- Helper resolution function to create toggles safely
		local function addToggle(container, config)
			if type(container.Toggle) == "function" then
				return container:Toggle(config)
			elseif type(container.AddToggle) == "function" then
				return container:AddToggle(config)
			elseif type(container.CreateToggle) == "function" then
				return container:CreateToggle(config)
			elseif type(container.NewToggle) == "function" then
				return container:NewToggle(config)
			end
		end

		-- Helper resolution function to create buttons safely
		local function addButton(container, config)
			if type(container.Button) == "function" then
				return container:Button(config)
			elseif type(container.AddButton) == "function" then
				return container:AddButton(config)
			elseif type(container.CreateButton) == "function" then
				return container:CreateButton(config)
			elseif type(container.NewButton) == "function" then
				return container:NewButton(config)
			end
		end

		local MainSection = getSection(GamePage, "Main Features")
		local OptimizationSection = getSection(GamePage, "Optimization")

		-- Auto Click Toggle
		addToggle(MainSection, {
			Name = "Auto Click",
			Default = false,
			Callback = function(Value)
				_G.AutoClick = Value
				task.spawn(function()
					while _G.AutoClick do
						pcall(function()
							local Event = game:GetService("ReplicatedStorage").Remotes.Events.ClickRemote
							Event:FireServer()
						end)
						RunService.RenderStepped:Wait()
					end
				end)
			end
		})

		-- Auto Break Wall Toggle
		addToggle(MainSection, {
			Name = "Auto Break Wall",
			Default = false,
			Callback = function(Value)
				_G.AutoBreak = Value
				
				task.spawn(function()
					while _G.AutoBreak do
						pcall(function()
							local Event = game:GetService("ReplicatedStorage").Remotes.Events.DamageWall
							Event:FireServer()
						end)
						RunService.RenderStepped:Wait()
					end
				end)
			end
		})

		-- Auto Rebirth Toggle
		addToggle(MainSection, {
			Name = "Auto Rebirth",
			Default = false,
			Callback = function(Value)
				_G.AutoRebirth = Value
				task.spawn(function()
					while _G.AutoRebirth do
						pcall(function()
							local Event = game:GetService("ReplicatedStorage").Remotes.Events.RebirthRemote
							Event:FireServer()
						end)
						task.wait(0.5)
					end
				end)
			end
		})

		-- Auto 10B Win's Toggle
		addToggle(MainSection, {
			Name = "Auto 10B Win's",
			Default = false,
			Callback = function(Value)
				_G.Auto10BWins = Value
				task.spawn(function()
					while _G.Auto10BWins do
						pcall(function()
							player.Character.HumanoidRootPart.CFrame = CFrame.new(1858, 18, -1377)
							task.wait(0.1)
							UIS:SimulateKeyEvent(true, Enum.KeyCode.W, false, game)
							task.wait(0.1)
							UIS:SimulateKeyEvent(false, Enum.KeyCode.W, false, game)
						end)
						task.wait(0.5)
					end
				end)
			end
		})

		-- Remove Loading Screen Optimization Toggle/Button
		addButton(OptimizationSection, {
			Name = "Remove Loading/UI Screen",
			Callback = function()
				pcall(function()
					for _, gui in ipairs(playerGui:GetChildren()) do
						if gui:IsA("ScreenGui") and (gui.Name:lower():find("load") or gui.Name:lower():find("loading")) then
							gui:Destroy()
						end
					end
				end)
			end
		})

		-- Teleports Section
		local TPSection = getSection(GamePage, "Auto-Train TP")

		local tpLocations = {
			{"0 Rebirth Needed", Vector3.new(1872, 17, 2894)},
			{"1 Rebirth Needed", Vector3.new(1873, 17, 2920)},
			{"25 Rebirth Needed", Vector3.new(1871, 17, 2977)},
			{"200 Rebirth Needed", Vector3.new(1872, 17, 3012)},
			{"5k Rebirth Needed", Vector3.new(1900, 17, 2906)},
			{"100k Rebirth Needed", Vector3.new(1901, 17, 2936)},
			{"10M Rebirth Needed", Vector3.new(1900, 17, 2976)}
		}

		for _, data in ipairs(tpLocations) do
			addButton(TPSection, {
				Name = data[1],
				Callback = function()
					pcall(function()
						player.Character.HumanoidRootPart.CFrame = CFrame.new(data[2])
					end)
				end
			})
		end

		local Watermark = "+1 Strength Per Click"
		Library:CreateSettingsPage(Window, Watermark)
	end)

	if success then
		mainScriptLoaded = true
		
		task.spawn(function()
			task.wait(1.5) 
			
			local function findNewGui()
				for _, gui in ipairs(playerGui:GetChildren()) do
					if gui:IsA("ScreenGui") and not existingGuis[gui] and gui.Name ~= "PlaceholderUI" then return gui end
				end
				
				local found = nil
				pcall(function()
					for _, gui in ipairs(CoreGui:GetChildren()) do
						if gui:IsA("ScreenGui") and not existingGuis[gui] and gui.Name ~= "PlaceholderUI" then found = gui; break end
					end
				end)
				if found then return found end
				
				pcall(function()
					if gethui then
						for _, gui in ipairs(gethui():GetChildren()) do
							if gui:IsA("ScreenGui") and not existingGuis[gui] and gui.Name ~= "PlaceholderUI" then found = gui; break end
						end
					end
				end)
				
				return found
			end
			
			targetGui = findNewGui()
		end)

		print("Vitality Script Loaded Successfully")
		print("[Vitality] Press F4 to completely hide and show the menu.")
	else
		local sanitizedErr = tostring(err):gsub("https?://%S+", "[URL REFLASHED]"):gsub("([%a]:\\[^%s:]+)", "[LOCAL PATH]")
		print("Vitality Script Could not be loaded, please join the discord and report this bug")
		warn("[Vitality Debug]: " .. sanitizedErr)
	end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F4 and mainScriptLoaded then
		if targetGui then
			targetGui.Enabled = not targetGui.Enabled
		end
	end
end)

local existing = playerGui:FindFirstChild("PlaceholderUI")
if existing then
	existing:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlaceholderUI"
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
	subtitle.Text = "VITALITY HUB"
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
keyBox.Text = ""
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
		loadMainScript()
	else
		stopLoadingAnimation()
		showPage(redeemPage, "right")
		setStatus("Invalid or Expired Key! Check Discord for today's key.", Color3.fromRGB(255, 80, 80))
	end
end)

showPage(redeemPage, "right")
