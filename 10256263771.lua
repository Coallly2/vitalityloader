-- +1 Muscle to Push Boulder Script
--[[
	VITALITY — Key System UI + Universal Tab
	COMPLETELY STANDALONE! Black, White & Light Blue Theme
	With Window Controls - F4 to toggle
	PERSISTENT KEY SYSTEM - Remembers user for 24 hours
	GAME: +1 muscle to Push Boulder
]]

-- Console execution wrapper
local function setupVitality()
	-- Check if already running
	if game:GetService("CoreGui"):FindFirstChild("VitalityUI") then
		warn("[VITALITY] Already running!")
		return
	end
	
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local CoreGui = game:GetService("CoreGui")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local HttpService = game:GetService("HttpService")
	
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		warn("[VITALITY] No LocalPlayer found! Trying again...")
		task.wait(1)
		LocalPlayer = Players.LocalPlayer
		if not LocalPlayer then
			error("[VITALITY] Could not find LocalPlayer!")
		end
	end
	
	--============================================================
	-- CONFIG - CHANGE THIS KEY WHENEVER YOU WANT!
	--============================================================
	local MASTER_KEY = "VITALITYSCRIPTSISTHEBEST67"
	local DISCORD_LINK = "https://discord.gg/2wdxu8ff6n"
	local DAY_SECONDS = 24 * 60 * 60
	local GAME_NAME = "Game"
	
	--============================================================
	-- PERSISTENT STORAGE
	--============================================================
	local function saveUserData(data)
		local success, err = pcall(function()
			local json = HttpService:JSONEncode(data)
			writefile("Vitality_UserData.json", json)
		end)
		return success
	end
	
	local function loadUserData()
		local success, data = pcall(function()
			if isfile("Vitality_UserData.json") then
				local json = readfile("Vitality_UserData.json")
				return HttpService:JSONDecode(json)
			end
		end)
		if success and data then
			return data
		end
		return nil
	end
	
	-- Session state
	local sessionUnlockExpiry = nil
	local userData = loadUserData() or {}
	
	-- MinWindow position storage
	local minWindowPosition = userData.minWindowPosition or {X = 0.5, Y = 0.5, OffsetX = -30, OffsetY = -30}
	
	-- Check if user has valid unlock
	if userData.userId and userData.userId == LocalPlayer.UserId and userData.expiry and userData.expiry > os.time() then
		sessionUnlockExpiry = userData.expiry
	end
	
	-- Auto collect states
	local autoCollectors = {
		train = { running = false, connection = nil, name = "Train +1" },
		rebirth = { running = false, connection = nil, name = "Rebirth" },
		claimGift = { running = false, connection = nil, name = "Claim Gift" },
	}
	
	-- Safe mode auto collectors
	local safeCollectors = {
		train = { running = false, connection = nil, name = "Train +1", lastFire = 0, cooldown = 0.1 },
		rebirth = { running = false, connection = nil, name = "Rebirth", lastFire = 0, cooldown = 0.5 },
		claimGift = { running = false, connection = nil, name = "Claim Gift", lastFire = 0, cooldown = 0.5 },
	}
	
	-- Window state
	local isMinimized = false
	local windowSize = UDim2.new(0, 750, 0, 520)
	
	--============================================================
	-- THEME
	--============================================================
	local Theme = {
		Bg = Color3.fromRGB(0, 0, 0),
		Panel = Color3.fromRGB(20, 20, 25),
		Panel2 = Color3.fromRGB(30, 30, 38),
		Panel3 = Color3.fromRGB(40, 40, 50),
		Line = Color3.fromRGB(60, 65, 80),
		Ice = Color3.fromRGB(200, 230, 255),
		IceBright = Color3.fromRGB(100, 200, 255),
		IceDark = Color3.fromRGB(50, 100, 150),
		White = Color3.fromRGB(255, 255, 255),
		Dim = Color3.fromRGB(150, 160, 180),
		Dark = Color3.fromRGB(10, 10, 15),
		Danger = Color3.fromRGB(255, 80, 80),
		Good = Color3.fromRGB(80, 255, 180),
		Gold = Color3.fromRGB(255, 215, 0),
		Orange = Color3.fromRGB(255, 165, 0),
		Purple = Color3.fromRGB(170, 0, 255),
		Pink = Color3.fromRGB(255, 105, 180),
	}
	
	--============================================================
	-- HELPERS
	--============================================================
	local function create(className, props, children)
		local inst = Instance.new(className)
		for k, v in pairs(props or {}) do
			inst[k] = v
		end
		for _, child in ipairs(children or {}) do
			child.Parent = inst
		end
		return inst
	end
	
	local function corner(radius)
		return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
	end
	
	local function stroke(color, thickness)
		return create("UIStroke", {
			Color = color or Theme.Line,
			Thickness = thickness or 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
	end
	
	local function tween(inst, props, time, style)
		local t = TweenService:Create(inst, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad), props)
		t:Play()
		return t
	end
	
	local function formatHMS(seconds)
		seconds = math.max(0, math.floor(seconds))
		local h = math.floor(seconds / 3600)
		local m = math.floor((seconds % 3600) / 60)
		local s = seconds % 60
		return string.format("%02d:%02d:%02d", h, m, s)
	end
	
	-- Toast system
	local ToastHolder
	local toastQueue = {}
	local isShowingToast = false
	
	local function processToastQueue()
		if isShowingToast or #toastQueue == 0 then return end
		isShowingToast = true
		local data = table.remove(toastQueue, 1)
		
		local toast = create("Frame", {
			BackgroundColor3 = Theme.Panel,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 51,
		}, {
			corner(10),
			stroke(data.isError and Theme.Danger or Theme.IceBright, 1),
			create("UIPadding", {
				PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
			}),
			create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = data.message,
				TextColor3 = data.isError and Theme.Danger or Theme.Ice,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextWrapped = true,
			}),
		})
		toast.Parent = ToastHolder
		toast.BackgroundTransparency = 1
		toast.Position = UDim2.new(0, 0, 0, -10)
		tween(toast, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, 0.25)
		
		task.delay(2.6, function()
			if toast and toast.Parent then
				tween(toast, { BackgroundTransparency = 1 }, 0.3)
				task.delay(0.3, function()
					if toast then toast:Destroy() end
					isShowingToast = false
					task.spawn(processToastQueue)
				end)
			end
		end)
	end
	
	local function showToast(message, isError)
		table.insert(toastQueue, { message = message, isError = isError or false })
		if not isShowingToast then
			task.spawn(processToastQueue)
		end
	end
	
	--============================================================
	-- SCREEN GUI ROOT
	--============================================================
	local ScreenGui = create("ScreenGui", {
		Name = "VitalityUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
	})
	
	local success, err = pcall(function()
		ScreenGui.Parent = CoreGui
	end)
	if not success then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	
	--============================================================
	-- MAIN WINDOW
	--============================================================
	local MainWindow = create("Frame", {
		Name = "MainWindow",
		BackgroundColor3 = Theme.Dark,
		Size = windowSize,
		Position = UDim2.new(0.5, -375, 0.5, -260),
		ZIndex = 1,
	}, {
		corner(12),
		stroke(Theme.IceBright, 1),
	})
	MainWindow.Parent = ScreenGui
	
	--============================================================
	-- MINIMIZED WINDOW
	--============================================================
	local MinWindow = create("Frame", {
		Name = "MinWindow",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 60, 0, 60),
		Position = UDim2.new(minWindowPosition.X, minWindowPosition.OffsetX, minWindowPosition.Y, minWindowPosition.OffsetY),
		ZIndex = 100,
		Visible = false,
	}, {
		corner(30),
		stroke(Theme.IceBright, 2),
	})
	MinWindow.Parent = ScreenGui
	
	local MinWindowBtn = create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "V",
		Font = Enum.Font.GothamBlack,
		TextSize = 32,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		AutoButtonColor = false,
	})
	MinWindowBtn.Parent = MinWindow
	
	local minDragging = false
	local minDragStart = nil
	local minStartPos = nil
	
	MinWindowBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			minDragging = true
			minDragStart = input.Position
			minStartPos = MinWindow.Position
		end
	end)
	
	MinWindowBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			minDragging = false
			if minStartPos then
				minWindowPosition = {
					X = MinWindow.Position.X.Scale,
					Y = MinWindow.Position.Y.Scale,
					OffsetX = MinWindow.Position.X.Offset,
					OffsetY = MinWindow.Position.Y.Offset
				}
				userData.minWindowPosition = minWindowPosition
				saveUserData(userData)
			end
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if minDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - minDragStart
			MinWindow.Position = UDim2.new(
				minStartPos.X.Scale,
				minStartPos.X.Offset + delta.X,
				minStartPos.Y.Scale,
				minStartPos.Y.Offset + delta.Y
			)
		end
	end)
	
	MinWindowBtn.MouseButton1Click:Connect(function()
		MinWindow.Visible = false
		MainWindow.Visible = true
		isMinimized = false
		for _, child in pairs(MainWindow:GetChildren()) do
			if child ~= TitleBar then
				child.Visible = true
			end
		end
	end)
	
	--============================================================
	-- TITLE BAR
	--============================================================
	local TitleBar = create("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
	})
	TitleBar.Parent = MainWindow
	
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = input.Position
			local absPos = TitleBar.AbsolutePosition
			local absSize = TitleBar.AbsoluteSize
			if mousePos.X < absPos.X + absSize.X - 70 then
				dragging = true
				dragStart = input.Position
				startPos = MainWindow.Position
			end
		end
	end)
	
	TitleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainWindow.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.7, 0, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Text = "VITALITY · " .. GAME_NAME,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.White,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = TitleBar
	
	--============================================================
	-- WINDOW CONTROLS
	--============================================================
	local ControlFrame = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 70, 1, 0),
		Position = UDim2.new(1, -75, 0, 0),
	})
	ControlFrame.Parent = TitleBar
	
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}).Parent = ControlFrame
	
	local MinBtn = create("TextButton", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 32, 0, 28),
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Theme.White,
		AutoButtonColor = false,
	}, { corner(6), stroke(Theme.Line, 1) })
	MinBtn.Parent = ControlFrame
	
	local CloseBtn = create("TextButton", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 32, 0, 28),
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.White,
		AutoButtonColor = false,
	}, { corner(6), stroke(Theme.Line, 1) })
	CloseBtn.Parent = ControlFrame
	
	MinBtn.MouseEnter:Connect(function() MinBtn.BackgroundColor3 = Theme.Panel3 end)
	MinBtn.MouseLeave:Connect(function() MinBtn.BackgroundColor3 = Theme.Panel2 end)
	CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Theme.Danger end)
	CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Theme.Panel2 end)
	
	MinBtn.MouseButton1Click:Connect(function()
		isMinimized = true
		MainWindow.Visible = false
		MinWindow.Visible = true
		MinWindow.Position = UDim2.new(minWindowPosition.X, minWindowPosition.OffsetX, minWindowPosition.Y, minWindowPosition.OffsetY)
		showToast("Minimized - Click the V to open")
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		MainWindow.Visible = false
		MinWindow.Visible = false
		for _, collector in pairs(autoCollectors) do
			if collector.running then
				collector.running = false
				if collector.connection then
					collector.connection:Disconnect()
					collector.connection = nil
				end
			end
		end
		for _, collector in pairs(safeCollectors) do
			if collector.running then
				collector.running = false
				if collector.connection then
					collector.connection:Disconnect()
					collector.connection = nil
				end
			end
		end
		showToast("Vitality closed - Press F4 to reopen")
	end)
	
	--============================================================
	-- TOAST SYSTEM
	--============================================================
	ToastHolder = create("Frame", {
		Name = "ToastHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 360, 1, 0),
		Position = UDim2.new(0.5, -180, 0, 20),
		ZIndex = 50,
	}, {
		create("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	ToastHolder.Parent = ScreenGui
	
	--============================================================
	-- CONTENT CONTAINER
	--============================================================
	local ContentContainer = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -36),
		Position = UDim2.new(0, 0, 0, 36),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
	}, {
		create("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),
		create("UIListLayout", { 
			Padding = UDim.new(0, 8), 
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	ContentContainer.Parent = MainWindow
	
	--============================================================
	-- GATE SCREEN
	--============================================================
	local GateFrame = create("Frame", {
		Name = "Gate",
		BackgroundColor3 = Theme.Dark,
		Size = UDim2.new(1, 0, 1, 0),
	})
	GateFrame.Parent = ContentContainer
	
	local GateCard = create("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 380),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		corner(10),
		stroke(Theme.Line, 1),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20),
		}),
		create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
		}),
	})
	GateCard.Parent = GateFrame
	
	create("TextLabel", {
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Text = "VITALITY",
		Font = Enum.Font.GothamBlack,
		TextSize = 28,
		TextColor3 = Theme.White,
	}).Parent = GateCard
	
	create("TextLabel", {
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Text = "Powered by " .. GAME_NAME,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.IceBright,
	}).Parent = GateCard
	
	create("TextLabel", {
		LayoutOrder = 3,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		Text = "Enter your key to unlock 24-hour access",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextWrapped = true,
	}).Parent = GateCard
	
	local KeyBox = create("TextBox", {
		LayoutOrder = 4,
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(1, 0, 0, 38),
		PlaceholderText = "Enter your key...",
		Text = "",
		TextColor3 = Theme.White,
		PlaceholderColor3 = Theme.Dim,
		Font = Enum.Font.Code,
		TextSize = 14,
		ClearTextOnFocus = false,
	}, {
		corner(8),
		stroke(Theme.Line, 1),
		create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
	})
	KeyBox.Parent = GateCard
	
	local ErrorLabel = create("TextLabel", {
		LayoutOrder = 5,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		TextColor3 = Theme.Danger,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		Visible = false,
	})
	ErrorLabel.Parent = GateCard
	
	local UnlockBtn = create("TextButton", {
		LayoutOrder = 6,
		BackgroundColor3 = Theme.IceBright,
		Size = UDim2.new(1, 0, 0, 40),
		Text = "Unlock Access",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		AutoButtonColor = false,
	}, {
		corner(8),
	})
	UnlockBtn.Parent = GateCard
	
	create("TextLabel", {
		LayoutOrder = 7,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Text = "or",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
	}).Parent = GateCard
	
	local DiscordBtn = create("TextButton", {
		LayoutOrder = 8,
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(1, 0, 0, 36),
		Text = "Join Discord for a Free Key!",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Ice,
		AutoButtonColor = false,
	}, {
		corner(8),
		stroke(Theme.Line, 1),
	})
	DiscordBtn.Parent = GateCard
	
	local ManageLabel = create("TextButton", {
		LayoutOrder = 9,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Text = "Manage access key →",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		AutoButtonColor = false,
	})
	ManageLabel.Parent = GateCard
	
	create("TextLabel", {
		LayoutOrder = 10,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "● SYSTEM READY",
		Font = Enum.Font.Code,
		TextSize = 10,
		TextColor3 = Theme.Good,
	}).Parent = GateCard
	
	--============================================================
	-- MANAGE KEY MODAL
	--============================================================
	local ModalOverlay = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 10,
	})
	ModalOverlay.Parent = MainWindow
	
	local ModalBox = create("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(0, 320, 0, 180),
		Position = UDim2.new(0.5, -160, 0.5, -90),
		ZIndex = 11,
	}, {
		corner(12),
		stroke(Theme.IceBright, 1),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18),
		}),
		create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	ModalBox.Parent = ModalOverlay
	
	create("TextLabel", {
		LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
		Text = "Manage Access Key", Font = Enum.Font.GothamBold, TextSize = 16,
		TextColor3 = Theme.White,
	}).Parent = ModalBox
	
	create("TextLabel", {
		LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
		Text = "Update the master key for all users.",
		Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim,
		TextWrapped = true,
	}).Parent = ModalBox
	
	local NewKeyBox = create("TextBox", {
		LayoutOrder = 3,
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(1, 0, 0, 34),
		Text = "",
		PlaceholderText = "Enter new key",
		TextColor3 = Theme.White,
		Font = Enum.Font.Code,
		TextSize = 13,
		ClearTextOnFocus = false,
	}, {
		corner(8), stroke(Theme.Line, 1),
		create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
	})
	NewKeyBox.Parent = ModalBox
	
	local ModalButtonRow = create("Frame", {
		LayoutOrder = 4,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
		}),
	})
	ModalButtonRow.Parent = ModalBox
	
	local CancelBtn = create("TextButton", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0.5, -4, 1, 0),
		Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Dim,
		AutoButtonColor = false,
	}, { corner(8), stroke(Theme.Line, 1) })
	CancelBtn.Parent = ModalButtonRow
	
	local SaveKeyBtn = create("TextButton", {
		BackgroundColor3 = Theme.IceBright,
		Size = UDim2.new(0.5, -4, 1, 0),
		Text = "Save Key", Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		AutoButtonColor = false,
	}, { corner(8) })
	SaveKeyBtn.Parent = ModalButtonRow
	
	--============================================================
	-- DASHBOARD
	--============================================================
	local Dashboard = create("Frame", {
		Name = "Dashboard",
		BackgroundColor3 = Theme.Dark,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
	})
	Dashboard.Parent = ContentContainer
	
	local CountdownLabel = create("TextLabel", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.new(0, 12, 0, 6),
		Text = "KEY ACTIVE · 24:00:00",
		Font = Enum.Font.Code,
		TextSize = 12,
		TextColor3 = Theme.Ice,
	}, { corner(8), stroke(Theme.Line, 1) })
	CountdownLabel.Parent = Dashboard
	
	--============================================================
	-- TAB SYSTEM
	--============================================================
	local TabBar = create("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, -24, 0, 34),
		Position = UDim2.new(0, 12, 0, 42),
	}, {
		corner(8),
		stroke(Theme.Line, 1),
	})
	TabBar.Parent = Dashboard
	
	local TabLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	TabLayout.Parent = TabBar
	
	local Tabs = {}
	local ActiveTab = nil
	
	local function switchTab(tabName)
		for name, tab in pairs(Tabs) do
			if name == tabName then
				tab.Button.BackgroundColor3 = Theme.Panel2
				tab.Button.TextColor3 = Theme.IceBright
				tab.Content.Visible = true
				ActiveTab = name
			else
				tab.Button.BackgroundColor3 = Theme.Panel
				tab.Button.TextColor3 = Theme.Dim
				tab.Content.Visible = false
			end
		end
	end
	
	local function createTab(name, layoutOrder)
		local btn = create("TextButton", {
			LayoutOrder = layoutOrder,
			BackgroundColor3 = Theme.Panel,
			Size = UDim2.new(0, 120, 1, 0),
			Text = name,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Theme.Dim,
			AutoButtonColor = false,
		})
		btn.Parent = TabBar
		
		local content = create("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -24, 1, -84),
			Position = UDim2.new(0, 12, 0, 84),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 4,
			Visible = false,
		}, {
			create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		content.Parent = Dashboard
		
		btn.MouseButton1Click:Connect(function()
			switchTab(name)
		end)
		
		Tabs[name] = { Button = btn, Content = content }
		return content
	end
	
	-- Create tabs
	local UniversalContent = createTab("Universal", 1)
	local GameContent = createTab("Game", 2)
	local GameSafeContent = createTab("Game (Safe)", 3)
	
	--============================================================
	-- SECTION BUILDER
	--============================================================
	local function makeSection(parent, title, layoutOrder)
		local section = create("Frame", {
			LayoutOrder = layoutOrder,
			BackgroundColor3 = Theme.Panel,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, { corner(8), stroke(Theme.Line, 1) })
		section.Parent = parent
		
		create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 0, 28),
			Position = UDim2.new(0, 12, 0, 0),
			Text = title,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Theme.Ice,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = section
		
		local body = create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 28),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
			create("UIPadding", { PaddingBottom = UDim.new(0, 6) }),
		})
		body.Parent = section
		return section, body
	end
	
	local function makeRow(parent, layoutOrder, label, sub)
		local row = create("Frame", {
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
		})
		row.Parent = parent
		
		create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Text = label,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Theme.White,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}).Parent = row
		
		if sub then
			create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, 0, 1, -16),
				Position = UDim2.new(0, 12, 0, 16),
				Text = sub,
				Font = Enum.Font.Gotham,
				TextSize = 10,
				TextColor3 = Theme.Dim,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row
		end
		
		return row
	end
	
	local function makeToggle(parent, layoutOrder, label, sub, initialValue, callback)
		local row = makeRow(parent, layoutOrder, label, sub)
		
		local switch = create("Frame", {
			BackgroundColor3 = initialValue and Theme.IceBright or Theme.Panel2,
			Size = UDim2.new(0, 34, 0, 18),
			Position = UDim2.new(1, -46, 0.5, -9),
		}, { corner(9) })
		switch.Parent = row
		
		local knob = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0, 12, 0, 12),
			Position = initialValue and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6),
		}, { corner(6) })
		knob.Parent = switch
		
		local state = initialValue
		local btn = create("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
		})
		btn.Parent = switch
		
		btn.MouseButton1Click:Connect(function()
			state = not state
			tween(switch, { BackgroundColor3 = state and Theme.IceBright or Theme.Panel2 }, 0.15)
			tween(knob, { Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6) }, 0.15)
			if callback then
				callback(state)
			end
		end)
		
		return row
	end
	
	local function makeSlider(parent, layoutOrder, label, sub, minVal, maxVal, initialVal, formatter, callback)
		local row = makeRow(parent, layoutOrder, label, sub)
		
		local track = create("Frame", {
			BackgroundColor3 = Theme.Panel2,
			Size = UDim2.new(0, 140, 0, 3),
			Position = UDim2.new(1, -195, 0.5, -1.5),
		}, { corner(1.5) })
		track.Parent = row
		
		local fill = create("Frame", {
			BackgroundColor3 = Theme.IceBright,
			Size = UDim2.new((initialVal - minVal) / (maxVal - minVal), 0, 1, 0),
		}, { corner(1.5) })
		fill.Parent = track
		
		local knob = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0, 12, 0, 12),
			Position = UDim2.new((initialVal - minVal) / (maxVal - minVal), -6, 0.5, -6),
			ZIndex = 2,
		}, { corner(6) })
		knob.Parent = track
		
		local valueLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 50, 0, 20),
			Position = UDim2.new(1, -50, 0.5, -10),
			Text = formatter and formatter(initialVal) or tostring(initialVal),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Theme.Ice,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		valueLabel.Parent = row
		
		local dragging = false
		local currentValue = initialVal
		
		local function updateValue(inputX)
			local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			local val = math.floor(minVal + rel * (maxVal - minVal))
			currentValue = val
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -6, 0.5, -6)
			valueLabel.Text = formatter and formatter(val) or tostring(val)
			if callback then
				callback(val)
			end
		end
		
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateValue(input.Position.X)
			end
		end)
		
		return row
	end
	
	--============================================================
	-- UNIVERSAL TAB
	--============================================================
	local _, universalBody = makeSection(UniversalContent, "UNIVERSAL SETTINGS", 1)
	
	-- Walk Speed
	local walkSpeedRow = makeRow(universalBody, 1, "Walk Speed Multiplier", "Multiply your walk speed")
	local walkSpeedSlider = create("Frame", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 140, 0, 3),
		Position = UDim2.new(1, -195, 0.5, -1.5),
	}, { corner(1.5) })
	walkSpeedSlider.Parent = walkSpeedRow
	local walkSpeedFill = create("Frame", {
		BackgroundColor3 = Theme.IceBright,
		Size = UDim2.new(0.5, 0, 1, 0),
	}, { corner(1.5) })
	walkSpeedFill.Parent = walkSpeedSlider
	local walkSpeedKnob = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0.5, -6, 0.5, -6),
		ZIndex = 2,
	}, { corner(6) })
	walkSpeedKnob.Parent = walkSpeedSlider
	local walkSpeedLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -50, 0.5, -10),
		Text = "1.0x",
		Font = Enum.Font.Code,
		TextSize = 11,
		TextColor3 = Theme.Ice,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	walkSpeedLabel.Parent = walkSpeedRow
	local walkSpeedDragging = false
	local walkSpeedVal = 1.0
	local function updateWalkSpeed(inputX)
		local rel = math.clamp((inputX - walkSpeedSlider.AbsolutePosition.X) / walkSpeedSlider.AbsoluteSize.X, 0, 1)
		local val = math.floor(0.5 + rel * 4 * 10) / 10
		walkSpeedVal = val
		walkSpeedFill.Size = UDim2.new(rel, 0, 1, 0)
		walkSpeedKnob.Position = UDim2.new(rel, -6, 0.5, -6)
		walkSpeedLabel.Text = string.format("%.1fx", val)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = 16 * val
		end
	end
	walkSpeedKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			walkSpeedDragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			walkSpeedDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if walkSpeedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateWalkSpeed(input.Position.X)
		end
	end)
	
	-- Jump Power
	local jumpPowerRow = makeRow(universalBody, 2, "Jump Power Multiplier", "Multiply your jump power")
	local jumpPowerSlider = create("Frame", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 140, 0, 3),
		Position = UDim2.new(1, -195, 0.5, -1.5),
	}, { corner(1.5) })
	jumpPowerSlider.Parent = jumpPowerRow
	local jumpPowerFill = create("Frame", {
		BackgroundColor3 = Theme.IceBright,
		Size = UDim2.new(0.5, 0, 1, 0),
	}, { corner(1.5) })
	jumpPowerFill.Parent = jumpPowerSlider
	local jumpPowerKnob = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0.5, -6, 0.5, -6),
		ZIndex = 2,
	}, { corner(6) })
	jumpPowerKnob.Parent = jumpPowerSlider
	local jumpPowerLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -50, 0.5, -10),
		Text = "1.0x",
		Font = Enum.Font.Code,
		TextSize = 11,
		TextColor3 = Theme.Ice,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	jumpPowerLabel.Parent = jumpPowerRow
	local jumpPowerDragging = false
	local jumpPowerVal = 1.0
	local function updateJumpPower(inputX)
		local rel = math.clamp((inputX - jumpPowerSlider.AbsolutePosition.X) / jumpPowerSlider.AbsoluteSize.X, 0, 1)
		local val = math.floor(0.5 + rel * 4 * 10) / 10
		jumpPowerVal = val
		jumpPowerFill.Size = UDim2.new(rel, 0, 1, 0)
		jumpPowerKnob.Position = UDim2.new(rel, -6, 0.5, -6)
		jumpPowerLabel.Text = string.format("%.1fx", val)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.JumpPower = 50 * val
		end
	end
	jumpPowerKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			jumpPowerDragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			jumpPowerDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if jumpPowerDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateJumpPower(input.Position.X)
		end
	end)
	
	-- Launch Cobalt
	local cobaltRow = makeRow(universalBody, 3, "Launch Cobalt", "Load the Cobalt script")
	local CobaltBtn = create("TextButton", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 120, 0, 28),
		Position = UDim2.new(1, -132, 0.5, -14),
		Text = "Launch",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.White,
		AutoButtonColor = false,
	}, { corner(6), stroke(Theme.Line, 1) })
	CobaltBtn.Parent = cobaltRow
	
	CobaltBtn.MouseEnter:Connect(function() CobaltBtn.BackgroundColor3 = Theme.Panel3 end)
	CobaltBtn.MouseLeave:Connect(function() CobaltBtn.BackgroundColor3 = Theme.Panel2 end)
	
	CobaltBtn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
			showToast("Cobalt launched!")
		end)
	end)
	
	--============================================================
	-- GAME TAB - All Auto Collectors (No cooldown)
	--============================================================
	local _, gameBody = makeSection(GameContent, "AUTO COLLECTORS", 1)
	
	local function createAutoCollector(parent, collectorKey, label, eventPath, args)
		local collector = autoCollectors[collectorKey]
		local row = makeRow(parent, #parent:GetChildren() + 1, label, "")
		
		local btn = create("TextButton", {
			BackgroundColor3 = Theme.Panel2,
			Size = UDim2.new(0, 80, 0, 28),
			Position = UDim2.new(1, -92, 0.5, -14),
			Text = "▶ START",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Theme.White,
			AutoButtonColor = false,
		}, { corner(6), stroke(Theme.Line, 1) })
		btn.Parent = row
		
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Theme.Panel3 end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Theme.Panel2 end)
		
		local event = nil
		local function findEvent()
			if event then return event end
			local current = ReplicatedStorage
			for _, pathPart in ipairs(eventPath) do
				current = current:FindFirstChild(pathPart)
				if not current then break end
			end
			event = current
			return event
		end
		
		local function fireEvent()
			local ev = findEvent()
			if not ev then
				showToast("Event not found: " .. table.concat(eventPath, "."), true)
				return
			end
			
			pcall(function()
				ev:FireServer(unpack(args))
			end)
		end
		
		btn.MouseButton1Click:Connect(function()
			if collector.running then
				collector.running = false
				if collector.connection then
					collector.connection:Disconnect()
					collector.connection = nil
				end
				btn.Text = "▶ START"
				btn.BackgroundColor3 = Theme.Panel2
				showToast(label .. " stopped")
			else
				if not findEvent() then
					showToast("Event not found: " .. table.concat(eventPath, "."), true)
					return
				end
				
				collector.running = true
				btn.Text = "■ STOP"
				btn.BackgroundColor3 = Theme.Danger
				showToast(label .. " started!")
				
				fireEvent()
				collector.connection = RunService.Heartbeat:Connect(function()
					if collector.running then
						fireEvent()
					end
				end)
			end
		end)
		
		return row
	end
	
	-- Normal mode collectors
	createAutoCollector(gameBody, "train", "Auto Train +1", {"Packages", "Net", "RE/ClientTrain"}, {})
	createAutoCollector(gameBody, "rebirth", "Auto Rebirth", {"Packages", "Net", "RE/Rebirth"}, {})
	
	-- Claim Gift
	local claimGiftRow = makeRow(gameBody, #gameBody:GetChildren() + 1, "Claim All Gifts", "")
	local claimGiftBtn = create("TextButton", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 80, 0, 28),
		Position = UDim2.new(1, -92, 0.5, -14),
		Text = "▶ START",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.White,
		AutoButtonColor = false,
	}, { corner(6), stroke(Theme.Line, 1) })
	claimGiftBtn.Parent = claimGiftRow
	
	claimGiftBtn.MouseEnter:Connect(function() claimGiftBtn.BackgroundColor3 = Theme.Panel3 end)
	claimGiftBtn.MouseLeave:Connect(function() claimGiftBtn.BackgroundColor3 = Theme.Panel2 end)
	
	local giftEvent = nil
	local function findGiftEvent()
		if giftEvent then return giftEvent end
		local current = ReplicatedStorage
		local path = {"Packages", "Net", "RE/PlaytimeClaim"}
		for _, pathPart in ipairs(path) do
			current = current:FindFirstChild(pathPart)
			if not current then break end
		end
		giftEvent = current
		return giftEvent
	end
	
	local function fireGiftClaim()
		local ev = findGiftEvent()
		if not ev then
			showToast("Gift event not found!", true)
			return
		end
		
		for i = 1, 9 do
			pcall(function()
				ev:FireServer(i)
			end)
		end
	end
	
	claimGiftBtn.MouseButton1Click:Connect(function()
		local collector = autoCollectors.claimGift
		if collector.running then
			collector.running = false
			if collector.connection then
				collector.connection:Disconnect()
				collector.connection = nil
			end
			claimGiftBtn.Text = "▶ START"
			claimGiftBtn.BackgroundColor3 = Theme.Panel2
			showToast("Claim Gifts stopped")
		else
			if not findGiftEvent() then
				showToast("Gift event not found!", true)
				return
			end
			
			collector.running = true
			claimGiftBtn.Text = "■ STOP"
			claimGiftBtn.BackgroundColor3 = Theme.Danger
			showToast("Claim Gifts started!")
			
			fireGiftClaim()
			collector.connection = RunService.Heartbeat:Connect(function()
				if collector.running then
					fireGiftClaim()
				end
			end)
		end
	end)
	
	--============================================================
	-- GAME (SAFE) TAB
	--============================================================
	local _, gameSafeBody = makeSection(GameSafeContent, "AUTO COLLECTORS (Safe)", 1)
	
	local function createSafeCollector(parent, collectorKey, label, eventPath, args, cooldown)
		local collector = safeCollectors[collectorKey]
		local row = makeRow(parent, #parent:GetChildren() + 1, label, "")
		
		local btn = create("TextButton", {
			BackgroundColor3 = Theme.Panel2,
			Size = UDim2.new(0, 80, 0, 28),
			Position = UDim2.new(1, -92, 0.5, -14),
			Text = "▶ START",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Theme.White,
			AutoButtonColor = false,
		}, { corner(6), stroke(Theme.Line, 1) })
		btn.Parent = row
		
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Theme.Panel3 end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Theme.Panel2 end)
		
		local event = nil
		local function findEvent()
			if event then return event end
			local current = ReplicatedStorage
			for _, pathPart in ipairs(eventPath) do
				current = current:FindFirstChild(pathPart)
				if not current then break end
			end
			event = current
			return event
		end
		
		local function fireEvent()
			local ev = findEvent()
			if not ev then
				showToast("Event not found: " .. table.concat(eventPath, "."), true)
				return
			end
			
			local now = tick()
			if now - collector.lastFire < collector.cooldown then
				return
			end
			collector.lastFire = now
			
			pcall(function()
				ev:FireServer(unpack(args))
			end)
		end
		
		btn.MouseButton1Click:Connect(function()
			if collector.running then
				collector.running = false
				if collector.connection then
					collector.connection:Disconnect()
					collector.connection = nil
				end
				btn.Text = "▶ START"
				btn.BackgroundColor3 = Theme.Panel2
				showToast(label .. " stopped")
			else
				if not findEvent() then
					showToast("Event not found: " .. table.concat(eventPath, "."), true)
					return
				end
				
				collector.running = true
				collector.lastFire = 0
				btn.Text = "■ STOP"
				btn.BackgroundColor3 = Theme.Danger
				showToast(label .. " started (" .. cooldown .. "s cooldown)!")
				
				fireEvent()
				collector.connection = RunService.Heartbeat:Connect(function()
					if collector.running then
						fireEvent()
					end
				end)
			end
		end)
		
		return row
	end
	
	-- Safe collectors
	createSafeCollector(gameSafeBody, "train", "Auto Train +1", {"Packages", "Net", "RE/ClientTrain"}, {}, 0.1)
	createSafeCollector(gameSafeBody, "rebirth", "Auto Rebirth", {"Packages", "Net", "RE/Rebirth"}, {}, 0.5)
	
	-- Claim Gift Safe
	local claimGiftSafeRow = makeRow(gameSafeBody, #gameSafeBody:GetChildren() + 1, "Claim All Gifts", "")
	local claimGiftSafeBtn = create("TextButton", {
		BackgroundColor3 = Theme.Panel2,
		Size = UDim2.new(0, 80, 0, 28),
		Position = UDim2.new(1, -92, 0.5, -14),
		Text = "▶ START",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.White,
		AutoButtonColor = false,
	}, { corner(6), stroke(Theme.Line, 1) })
	claimGiftSafeBtn.Parent = claimGiftSafeRow
	
	claimGiftSafeBtn.MouseEnter:Connect(function() claimGiftSafeBtn.BackgroundColor3 = Theme.Panel3 end)
	claimGiftSafeBtn.MouseLeave:Connect(function() claimGiftSafeBtn.BackgroundColor3 = Theme.Panel2 end)
	
	local function fireGiftClaimSafe()
		local ev = findGiftEvent()
		if not ev then
			showToast("Gift event not found!", true)
			return
		end
		
		local collector = safeCollectors.claimGift
		local now = tick()
		if now - collector.lastFire < collector.cooldown then
			return
		end
		collector.lastFire = now
		
		for i = 1, 9 do
			pcall(function()
				ev:FireServer(i)
			end)
		end
	end
	
	claimGiftSafeBtn.MouseButton1Click:Connect(function()
		local collector = safeCollectors.claimGift
		if collector.running then
			collector.running = false
			if collector.connection then
				collector.connection:Disconnect()
				collector.connection = nil
			end
			claimGiftSafeBtn.Text = "▶ START"
			claimGiftSafeBtn.BackgroundColor3 = Theme.Panel2
			showToast("Claim Gifts stopped")
		else
			if not findGiftEvent() then
				showToast("Gift event not found!", true)
				return
			end
			
			collector.running = true
			collector.lastFire = 0
			claimGiftSafeBtn.Text = "■ STOP"
			claimGiftSafeBtn.BackgroundColor3 = Theme.Danger
			showToast("Claim Gifts started (0.5s cooldown)!")
			
			fireGiftClaimSafe()
			collector.connection = RunService.Heartbeat:Connect(function()
				if collector.running then
					fireGiftClaimSafe()
				end
			end)
		end
	end)
	
	--============================================================
	-- COUNTDOWN
	--============================================================
	local countdownConn = nil
	local function startCountdown(expiryUnix)
		if countdownConn then
			countdownConn:Disconnect()
		end
		countdownConn = RunService.Heartbeat:Connect(function()
			local remaining = expiryUnix - os.time()
			if remaining <= 0 then
				countdownConn:Disconnect()
				countdownConn = nil
				Dashboard.Visible = false
				GateFrame.Visible = true
				userData = {}
				saveUserData(userData)
				showToast("Access expired. Enter your key again.", true)
				return
			end
			CountdownLabel.Text = "KEY ACTIVE · " .. formatHMS(remaining)
		end)
	end
	
	local function showDashboard(expiryUnix)
		GateFrame.Visible = false
		Dashboard.Visible = true
		switchTab("Game")
		startCountdown(expiryUnix)
	end
	
	--============================================================
	-- KEY LOGIC
	--============================================================
	UnlockBtn.MouseButton1Click:Connect(function()
		local entered = KeyBox.Text
		if entered ~= "" and entered == MASTER_KEY then
			local expiry = os.time() + DAY_SECONDS
			sessionUnlockExpiry = expiry
			
			userData = {
				userId = LocalPlayer.UserId,
				expiry = expiry,
				key = entered,
				minWindowPosition = minWindowPosition
			}
			saveUserData(userData)
			
			ErrorLabel.Visible = false
			showToast("Key accepted — 24 hour access granted.")
			task.delay(0.3, function()
				showDashboard(expiry)
			end)
		else
			ErrorLabel.Text = "Invalid key."
			ErrorLabel.Visible = true
			local originalPos = KeyBox.Position
			for _, offset in ipairs({ -6, 6, -4, 4, 0 }) do
				tween(KeyBox, { Position = originalPos + UDim2.new(0, offset, 0, 0) }, 0.05)
				task.wait(0.05)
			end
		end
	end)
	
	DiscordBtn.MouseButton1Click:Connect(function()
		local copied = false
		if typeof(setclipboard) == "function" then
			local success = pcall(function()
				setclipboard(DISCORD_LINK)
			end)
			copied = success
		end
		
		if copied then
			showToast("Discord link copied!")
		else
			showToast("Discord: " .. DISCORD_LINK, false)
		end
	end)
	
	ManageLabel.MouseButton1Click:Connect(function()
		NewKeyBox.Text = MASTER_KEY
		ModalOverlay.Visible = true
	end)
	
	CancelBtn.MouseButton1Click:Connect(function()
		ModalOverlay.Visible = false
	end)
	
	SaveKeyBtn.MouseButton1Click:Connect(function()
		local newKey = NewKeyBox.Text
		if newKey == "" then
			showToast("Enter a key before saving.", true)
			return
		end
		showToast("Key updated! Restart script for changes.", true)
		ModalOverlay.Visible = false
	end)
	
	--============================================================
	-- KEYBOARD SHORTCUTS
	--============================================================
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.F4 then
			if MainWindow.Visible then
				MainWindow.Visible = false
				MinWindow.Visible = false
				for _, collector in pairs(autoCollectors) do
					if collector.running then
						collector.running = false
						if collector.connection then
							collector.connection:Disconnect()
							collector.connection = nil
						end
					end
				end
				for _, collector in pairs(safeCollectors) do
					if collector.running then
						collector.running = false
						if collector.connection then
							collector.connection:Disconnect()
							collector.connection = nil
						end
					end
				end
			else
				MainWindow.Visible = true
				if sessionUnlockExpiry and sessionUnlockExpiry > os.time() then
					showDashboard(sessionUnlockExpiry)
				end
			end
		end
	end)
	
	--============================================================
	-- INIT
	--============================================================
	if sessionUnlockExpiry and sessionUnlockExpiry > os.time() then
		showDashboard(sessionUnlockExpiry)
	else
		userData = {}
		saveUserData(userData)
	end
	
	print("[VITALITY] System initialized!")
	print("[VITALITY] F4 to toggle window")
end

-- Execute
local success, err = pcall(setupVitality)
if not success then
	warn("[VITALITY] Failed: " .. tostring(err))
else
	print("[VITALITY] Ready!")
end
