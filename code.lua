local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if Workspace:FindFirstChild("SwirlVisuals") then
	Workspace.SwirlVisuals:Destroy()
end

-- Configuration
local Config = {
	MAX_SIMULATION_RADIUS = 2000,
	BLACK_HOLE_SIZE = Vector3.new(5, 5, 5),
	BLACK_HOLE_COLOR = Color3.fromRGB(0, 0, 0),
	BLACK_HOLE_GLOW_RANGE = 25,
	BLACK_HOLE_GLOW_BRIGHTNESS = 15,
	BLACK_HOLE_GLOW_COLOR = Color3.fromRGB(0, 0, 255),
	PULL_STRENGTH = 25,
	SWIRL_STRENGTH = 130,
	ALIGN_MAX_FORCE = math.huge,
	EXCLUDED_TAGS = { "NoAttract", "Character" },
	MOBILE_SUPPORT = false,
	ORBIT_STABILIZER = false,
	SINE_WAVE = false,
	SHELL_LOCK = false,
	QUANTUM_JITTER = false,
	CHAOS_STORM = false,
	TIME_WARP = false,
	SWIRL_MODE = "Ethereal", -- "Disk", "Sphere", "Atom"
	PHYSICS_THROTTLE = 4,

	-- Claim Lock
	CLAIM_LOCK = true,

	-- Sentinel Mode (Active Defense)
	SENTINEL_MODE = false,

	TEXT_SCALE = 5,
	TEXT_SPACING = 1.5,

	-- New Controls
	PHYSICS_LERP = 0.2,
	TWEEN_SPEED = 10, -- Base Attraction Speed

	-- Ethereal Shape Config
	ETHEREAL_RING_COUNT = 2,
	ETHEREAL_START_RADIUS = 80,
	ETHEREAL_RING_GAP = 170,
	ETHEREAL_RING_SPEED = 10,
	ETHEREAL_HEIGHT_OFFSET = 5,
	ETHEREAL_TILT_ANGLE = 12,
	ETHEREAL_TILT_SPEED = 0.2,
}

local FontShapes = {
	["A"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 1, 1, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 } },
	["B"] = { { 1, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 1, 1, 0 } },
	["C"] = { { 0, 1, 1, 1 }, { 1, 0, 0, 0 }, { 1, 0, 0, 0 }, { 1, 0, 0, 0 }, { 0, 1, 1, 1 } },
	["D"] = { { 1, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 1, 1, 0 } },
	["E"] = { { 1, 1, 1, 1 }, { 1, 0, 0, 0 }, { 1, 1, 1, 0 }, { 1, 0, 0, 0 }, { 1, 1, 1, 1 } },
	["F"] = { { 1, 1, 1, 1 }, { 1, 0, 0, 0 }, { 1, 1, 1, 0 }, { 1, 0, 0, 0 }, { 1, 0, 0, 0 } },
	["G"] = { { 0, 1, 1, 1 }, { 1, 0, 0, 0 }, { 1, 0, 1, 1 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["H"] = { { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 1, 1, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 } },
	["I"] = { { 0, 1, 1, 0 }, { 0, 0, 1, 0 }, { 0, 0, 1, 0 }, { 0, 0, 1, 0 }, { 0, 1, 1, 0 } },
	["J"] = { { 0, 0, 1, 1 }, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["K"] = { { 1, 0, 0, 1 }, { 1, 0, 1, 0 }, { 1, 1, 0, 0 }, { 1, 0, 1, 0 }, { 1, 0, 0, 1 } },
	["L"] = { { 1, 0, 0, 0 }, { 1, 0, 0, 0 }, { 1, 0, 0, 0 }, { 1, 0, 0, 0 }, { 1, 1, 1, 1 } },
	["M"] = { { 1, 0, 0, 0, 1 }, { 1, 1, 0, 1, 1 }, { 1, 0, 1, 0, 1 }, { 1, 0, 0, 0, 1 }, { 1, 0, 0, 0, 1 } },
	["N"] = { { 1, 0, 0, 1 }, { 1, 1, 0, 1 }, { 1, 0, 1, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 } },
	["O"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["P"] = { { 1, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 1, 1, 0 }, { 1, 0, 0, 0 }, { 1, 0, 0, 0 } },
	["Q"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 1, 1 }, { 0, 1, 1, 1 } },
	["R"] = { { 1, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 1, 1, 0 }, { 1, 0, 1, 0 }, { 1, 0, 0, 1 } },
	["S"] = { { 0, 1, 1, 1 }, { 1, 0, 0, 0 }, { 0, 1, 1, 0 }, { 0, 0, 0, 1 }, { 1, 1, 1, 0 } },
	["T"] = { { 1, 1, 1 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 } },
	["U"] = { { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["V"] = { { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 }, { 0, 0, 1, 0 } },
	["W"] = { { 1, 0, 0, 0, 1 }, { 1, 0, 0, 0, 1 }, { 1, 0, 1, 0, 1 }, { 1, 0, 1, 0, 1 }, { 0, 1, 1, 1, 0 } },
	["X"] = { { 1, 0, 0, 1 }, { 0, 1, 1, 0 }, { 0, 0, 1, 0 }, { 0, 1, 1, 0 }, { 1, 0, 0, 1 } },
	["Y"] = { { 1, 0, 0, 1 }, { 0, 1, 1, 0 }, { 0, 0, 1, 0 }, { 0, 0, 1, 0 }, { 0, 0, 1, 0 } },
	["Z"] = { { 1, 1, 1, 1 }, { 0, 0, 0, 1 }, { 0, 0, 1, 0 }, { 0, 1, 0, 0 }, { 1, 1, 1, 1 } },
	["0"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["1"] = { { 0, 0, 1, 0 }, { 0, 1, 1, 0 }, { 0, 0, 1, 0 }, { 0, 0, 1, 0 }, { 0, 1, 1, 1 } },
	["2"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 0, 0, 1, 0 }, { 0, 1, 0, 0 }, { 1, 1, 1, 1 } },
	["3"] = { { 1, 1, 1, 0 }, { 0, 0, 0, 1 }, { 0, 1, 1, 0 }, { 0, 0, 0, 1 }, { 1, 1, 1, 0 } },
	["4"] = { { 1, 0, 0, 1 }, { 1, 0, 0, 1 }, { 1, 1, 1, 1 }, { 0, 0, 0, 1 }, { 0, 0, 0, 1 } },
	["5"] = { { 1, 1, 1, 1 }, { 1, 0, 0, 0 }, { 1, 1, 1, 0 }, { 0, 0, 0, 1 }, { 1, 1, 1, 0 } },
	["6"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 0 }, { 1, 1, 1, 0 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["7"] = { { 1, 1, 1, 1 }, { 0, 0, 0, 1 }, { 0, 0, 1, 0 }, { 0, 1, 0, 0 }, { 0, 1, 0, 0 } },
	["8"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 0, 1, 1, 0 } },
	["9"] = { { 0, 1, 1, 0 }, { 1, 0, 0, 1 }, { 0, 1, 1, 1 }, { 0, 0, 0, 1 }, { 0, 1, 1, 0 } },
	[" "] = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } },
	["."] = { { 0 }, { 0 }, { 0 }, { 0 }, { 1 } },
	[","] = { { 0 }, { 0 }, { 0 }, { 0 }, { 1 }, { 1 } },
	["+"] = { { 0, 0, 1, 0, 0 }, { 0, 0, 1, 0, 0 }, { 1, 1, 1, 1, 1 }, { 0, 0, 1, 0, 0 }, { 0, 0, 1, 0, 0 } },
	["-"] = { { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 }, { 1, 1, 1, 1, 1 }, { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 } },
	["!"] = { { 1 }, { 1 }, { 1 }, { 0 }, { 1 } },
	["?"] = { { 1, 1, 1, 0 }, { 0, 0, 0, 1 }, { 0, 1, 1, 0 }, { 0, 0, 0, 0 }, { 0, 1, 0, 0 } },

	-- Emojis
	["HAPPY"] = { { 0, 1, 0, 1, 0 }, { 0, 0, 0, 0, 0 }, { 1, 0, 0, 0, 1 }, { 0, 1, 1, 1, 0 }, { 0, 0, 0, 0, 0 } },
	["SAD"] = { { 0, 1, 0, 1, 0 }, { 0, 0, 0, 0, 0 }, { 0, 1, 1, 1, 0 }, { 1, 0, 0, 0, 1 }, { 0, 0, 0, 0, 0 } },
	["HEART"] = { { 0, 1, 0, 1, 0 }, { 1, 1, 1, 1, 1 }, { 1, 1, 1, 1, 1 }, { 0, 1, 1, 1, 0 }, { 0, 0, 1, 0, 0 } },
	["SKULL"] = { { 0, 1, 1, 1, 0 }, { 1, 0, 1, 0, 1 }, { 1, 1, 1, 1, 1 }, { 0, 1, 0, 1, 0 }, { 0, 1, 0, 1, 0 } },
	["STAR"] = { { 0, 0, 1, 0, 0 }, { 0, 1, 1, 1, 0 }, { 1, 1, 1, 1, 1 }, { 0, 1, 0, 1, 0 }, { 1, 0, 0, 0, 1 } },
	["GHOST"] = { { 0, 1, 1, 1, 0 }, { 1, 0, 1, 0, 1 }, { 1, 1, 1, 1, 1 }, { 1, 1, 1, 1, 1 }, { 1, 0, 1, 0, 1 } },
	["ALIEN"] = { { 0, 0, 1, 0, 0 }, { 0, 1, 1, 1, 0 }, { 1, 1, 1, 1, 1 }, { 1, 0, 1, 0, 1 }, { 1, 0, 0, 0, 1 } },
	["CREEPER"] = { { 1, 1, 1, 1, 1 }, { 1, 0, 1, 0, 1 }, { 1, 1, 1, 1, 1 }, { 0, 1, 1, 1, 0 }, { 0, 1, 0, 1, 0 } },
	["PACMAN"] = { { 0, 1, 1, 1, 0 }, { 1, 1, 1, 1, 1 }, { 1, 1, 0, 0, 0 }, { 1, 1, 1, 1, 1 }, { 0, 1, 1, 1, 0 } },
	["CHECK"] = { { 0, 0, 0, 0, 1 }, { 0, 0, 0, 1, 0 }, { 1, 0, 1, 0, 0 }, { 0, 1, 0, 0, 0 }, { 0, 0, 0, 0, 0 } },
	["X"] = { { 1, 0, 0, 0, 1 }, { 0, 1, 0, 1, 0 }, { 0, 0, 1, 0, 0 }, { 0, 1, 0, 1, 0 }, { 1, 0, 0, 0, 1 } },
	["SWORD"] = { { 0, 0, 0, 0, 1 }, { 0, 0, 0, 1, 0 }, { 0, 0, 1, 0, 0 }, { 0, 1, 1, 1, 0 }, { 1, 0, 1, 0, 0 } },
	["SHIELD"] = { { 1, 1, 1, 1, 1 }, { 1, 1, 1, 1, 1 }, { 1, 1, 1, 1, 1 }, { 0, 1, 1, 1, 0 }, { 0, 0, 1, 0, 0 } },
	["CROWN"] = { { 1, 0, 1, 0, 1 }, { 1, 0, 1, 0, 1 }, { 1, 1, 1, 1, 1 }, { 1, 1, 1, 1, 1 }, { 0, 1, 1, 1, 0 } },
	["MUSIC"] = { { 0, 0, 1, 1, 1 }, { 0, 0, 1, 0, 1 }, { 0, 0, 1, 0, 1 }, { 1, 1, 1, 0, 0 }, { 1, 1, 1, 0, 0 } },
}

local State = {
	blackHole = nil,
	attachment1 = nil,
	connections = {},
	affectedParts = {},
	isActive = false,
	isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	isDragging = false,
	dragDepth = 0,
	frameCount = 0,
	-- Text Mode
	isTextMode = false,
	currentText = "HI",
	textPoints = {},
	textRotation = CFrame.identity,
	-- Cache
	sortedPartsCache = {},
	lastPartCount = 0,
}

local Util = {}

function Util.GetTextPoints(text)
	text = string.upper(text)
	local points = {}
	local totalWidth = 0
	local charShapes = {}

	-- Parser: Support :{TAG}: syntax
	local i = 1
	while i <= #text do
		local shape = nil
		local advance = 1

		-- Check for tag start
		if string.sub(text, i, i + 1) == ":{" then
			local endTag = string.find(text, "}:", i + 2)
			if endTag then
				local tag = string.sub(text, i + 2, endTag - 1)
				if FontShapes[tag] then
					shape = FontShapes[tag]
					advance = (endTag + 1) - i + 1
				end
			end
		end

		if not shape then
			local char = string.sub(text, i, i)
			shape = FontShapes[char] or FontShapes[" "]
		end

		table.insert(charShapes, shape)
		local w = shape[1] and #shape[1] or 4
		totalWidth = totalWidth + w + Config.TEXT_SPACING
		i = i + advance
	end

	local startX = -totalWidth * Config.TEXT_SCALE / 2
	local currentX = startX

	for i, shape in ipairs(charShapes) do
		local h = #shape
		local w = #shape[1]

		for r = 1, h do
			for c = 1, w do
				if shape[r][c] == 1 then
					-- Row 1 is top, maps to higher Y
					local y = (h - r) * Config.TEXT_SCALE
					local x = currentX + (c - 1) * Config.TEXT_SCALE

					-- 3D Extrusion Loop (Front, Mid, Back)
					-- Generates multiple layers for thickness
					local layers = 1 -- 0, +/-1 (3 layers total)
					for zLayer = -layers, layers do
						local z = zLayer * (Config.TEXT_SCALE * 0.8) -- Slightly tighter Z packing
						table.insert(points, Vector3.new(x, y, z))
					end
				end
			end
		end
		currentX = currentX + (w + Config.TEXT_SPACING) * Config.TEXT_SCALE
	end

	return points
end

function Util.Notify(title, text, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration or 3,
		})
	end)
end

function Util.IsExcluded(part)
	if not part:IsA("BasePart") then
		return true
	end
	for _, tag in ipairs(Config.EXCLUDED_TAGS) do
		if part:FindFirstChild(tag) or (part.Parent and part.Parent:FindFirstChild(tag)) then
			return true
		end
	end
	if part.Parent and part.Parent:FindFirstChildOfClass("Humanoid") then
		return true
	end
	if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
		return true
	end
	if part.Anchored then
		return true
	end
	if part.Name == "Baseplate" or part.Name == "HumanoidRootPart" then
		return true
	end
	return false
end

-- // UI Module // --
local UI = {}
UI.Gui = nil

function UI.CreateSlider(parent, title, min, max, default, callback)
	local frame = Instance.new("Frame", parent)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 36)

	local label = Instance.new("TextLabel", frame)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 18)
	label.Text = title
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13

	local valueLabel = Instance.new("TextLabel", frame)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.new(1, -50, 0, 0)
	valueLabel.Size = UDim2.new(0, 50, 0, 18)
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 13

	local sliderContainer = Instance.new("Frame", frame)
	sliderContainer.BackgroundTransparency = 1
	sliderContainer.Position = UDim2.new(0, 0, 0, 22)
	sliderContainer.Size = UDim2.new(1, 0, 0, 6)

	local sliderBg = Instance.new("Frame", sliderContainer)
	sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	sliderBg.BorderSizePixel = 0
	sliderBg.Size = UDim2.new(1, 0, 1, 0)

	local bgCorner = Instance.new("UICorner", sliderBg)
	bgCorner.CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", sliderBg)
	fill.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

	local fillCorner = Instance.new("UICorner", fill)
	fillCorner.CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("ImageButton", sliderContainer) -- Easier to hit than Frame
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = false

	local knobCorner = Instance.new("UICorner", knob)
	knobCorner.CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function Update(input)
		local pos = input.Position.X
		local relativePos = pos - sliderContainer.AbsolutePosition.X
		local percent = math.clamp(relativePos / sliderContainer.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * percent)

		TweenService:Create(fill, TweenInfo.new(0.05), { Size = UDim2.new(percent, 0, 1, 0) }):Play()
		TweenService:Create(knob, TweenInfo.new(0.05), { Position = UDim2.new(percent, 0, 0.5, 0) }):Play()

		valueLabel.Text = tostring(value)
		callback(value)
	end

	knob.MouseButton1Down:Connect(function()
		dragging = true
	end)
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			Update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			Update(input)
		end
	end)
end

function UI.CreateToggle(parent, title, default, callback)
	local frame = Instance.new("Frame", parent)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 28)

	local label = Instance.new("TextLabel", frame)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.8, 0, 1, 0)
	label.Text = title
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14

	local switch = Instance.new("TextButton", frame)
	switch.Text = ""
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, 0, 0.5, 0)
	switch.Size = UDim2.new(0, 44, 0, 24)
	switch.BackgroundColor3 = default and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(50, 50, 55)
	switch.AutoButtonColor = false

	local switchCorner = Instance.new("UICorner", switch)
	switchCorner.CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", switch)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)

	local knobCorner = Instance.new("UICorner", knob)
	knobCorner.CornerRadius = UDim.new(1, 0)

	switch.MouseButton1Click:Connect(function()
		default = not default
		local targetColor = default and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(50, 50, 55)
		local targetPos = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)

		TweenService:Create(switch, TweenInfo.new(0.2), { BackgroundColor3 = targetColor }):Play()
		TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Position = targetPos }):Play()

		callback(default)
	end)
end

function UI.Setup()
	if UI.Gui then
		UI.Gui:Destroy()
	end

	local sg = Instance.new("ScreenGui")
	sg.Name = "BlackHoleUI"
	if RunService:IsStudio() then
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
	else
		sg.Parent = game:GetService("CoreGui")
	end
	UI.Gui = sg

	-- Main Container (Dark Glass)
	local main = Instance.new("Frame", sg)
	main.Name = "Main"
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	main.BackgroundTransparency = 0.15
	main.Position = UDim2.new(0, 20, 0.5, -240)
	main.Size = UDim2.new(0, 300, 0, 520)
	main.Active = true
	main.Draggable = true

	local mainCorner = Instance.new("UICorner", main)
	mainCorner.CornerRadius = UDim.new(0, 12)

	local mainStroke = Instance.new("UIStroke", main)
	mainStroke.Color = Color3.fromRGB(60, 60, 70)
	mainStroke.Thickness = 1
	mainStroke.Transparency = 0.5

	-- Header
	local header = Instance.new("Frame", main)
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 40)

	local title = Instance.new("TextLabel", header)
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 15, 0, 0)
	title.Size = UDim2.new(0.7, 0, 1, 0)
	title.Text = "Gravity Engine"
	title.TextColor3 = Color3.fromRGB(240, 240, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left

	-- Scrollable Content
	local container = Instance.new("ScrollingFrame", main)
	container.BackgroundTransparency = 1
	container.Position = UDim2.new(0, 0, 0, 50)
	container.Size = UDim2.new(1, 0, 1, -60)
	container.ScrollBarThickness = 4
	container.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
	container.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local layout = Instance.new("UIListLayout", container)
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local padding = Instance.new("UIPadding", container)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 20)

	-- 1. Sliders (Expanded Width due to ScrollingFrame padding)
	UI.CreateSlider(container, "Pull Strength", -500, 500, Config.PULL_STRENGTH, function(v)
		Config.PULL_STRENGTH = v
	end)
	UI.CreateSlider(container, "Swirl Strength", 0, 1000, Config.SWIRL_STRENGTH, function(v)
		Config.SWIRL_STRENGTH = v
	end)
	UI.CreateSlider(container, "Range", 1000, 100000, Config.MAX_SIMULATION_RADIUS, function(v)
		Config.MAX_SIMULATION_RADIUS = v
		if LocalPlayer then
			LocalPlayer.MaximumSimulationRadius = v
		end
	end)

	-- Spacer
	local spacer1 = Instance.new("Frame", container)
	spacer1.BackgroundTransparency = 1
	spacer1.Size = UDim2.new(1, 0, 0, 10)

	-- 2. Dropdown (Redesigned)
	local ddLabel = Instance.new("TextLabel", container)
	ddLabel.BackgroundTransparency = 1
	ddLabel.Size = UDim2.new(1, 0, 0, 20)
	ddLabel.Text = "Shape Mode"
	ddLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	ddLabel.Font = Enum.Font.GothamBold
	ddLabel.TextSize = 12
	ddLabel.TextXAlignment = Enum.TextXAlignment.Left

	local ddBtn = Instance.new("TextButton", container)
	ddBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	ddBtn.Size = UDim2.new(1, 0, 0, 36)
	ddBtn.Text = Config.SWIRL_MODE
	ddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ddBtn.Font = Enum.Font.GothamBold
	ddBtn.TextSize = 14
	ddBtn.AutoButtonColor = false

	local ddCorner = Instance.new("UICorner", ddBtn)
	ddCorner.CornerRadius = UDim.new(0, 6)

	local ddStroke = Instance.new("UIStroke", ddBtn)
	ddStroke.Color = Color3.fromRGB(80, 80, 90)
	ddStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	-- Dropdown List
	local ddList = Instance.new("ScrollingFrame", main)
	ddList.Name = "DropdownList"
	ddList.Visible = false
	ddList.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	ddList.Position = UDim2.new(1, 10, 0, 0)
	ddList.Size = UDim2.new(0, 160, 1, 0)
	ddList.BorderSizePixel = 0
	ddList.ZIndex = 20
	ddList.CanvasSize = UDim2.new(0, 0, 0, 0)
	ddList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ddList.ScrollBarThickness = 2

	local ddListCorner = Instance.new("UICorner", ddList)
	ddListCorner.CornerRadius = UDim.new(0, 8)

	local ddLayout = Instance.new("UIListLayout", ddList)
	ddLayout.Padding = UDim.new(0, 2)
	ddLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	ddBtn.MouseButton1Click:Connect(function()
		ddList.Visible = not ddList.Visible
	end)

	local swirlModes = {
		"Disk",
		"Sphere",
		"Atom",
		"Tornado",
		"Grid",
		"Saturn",
		"Galaxy",
		"Heart",
		"Vortex",
		"Vertical",
		"DNA",
		"BlackHole",
		"Dragon",
		"SolarSystem",
		"DoubleHelix",
		"Ethereal",

		"Orbitals",
		"FilledDisk",
		"TorusKnot",
		"Mobius",
		"Lissajous",
		"DysonSphere",
		"HyperHelix",
		"Quasar",
		"Tesseract",
		"KleinBottle",
		"Lorenz",
		"HopfFibration",
		"CalabiYau",
		"Mandelbulb",
		"Gyroid",
		"Enneper",
		"SuperToroid",
		"Rose",
		"HexGrid",
	}

	for _, modeName in ipairs(swirlModes) do
		local itemBtn = Instance.new("TextButton", ddList)
		itemBtn.Size = UDim2.new(1, -10, 0, 30)
		itemBtn.BackgroundTransparency = 1
		itemBtn.Text = modeName
		itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		itemBtn.Font = Enum.Font.GothamMedium
		itemBtn.TextSize = 14
		itemBtn.ZIndex = 21

		itemBtn.MouseButton1Click:Connect(function()
			Config.SWIRL_MODE = modeName
			ddBtn.Text = modeName
			ddList.Visible = false
		end)
	end

	-- Spacer
	local spacer2 = Instance.new("Frame", container)
	spacer2.BackgroundTransparency = 1
	spacer2.Size = UDim2.new(1, 0, 0, 15)

	-- 3. Toggles
	UI.CreateToggle(container, "Orbit Stabilizer", Config.ORBIT_STABILIZER, function(v)
		Config.ORBIT_STABILIZER = v
	end)
	UI.CreateToggle(container, "Sine Wave", Config.SINE_WAVE, function(v)
		Config.SINE_WAVE = v
	end)
	UI.CreateToggle(container, "Shell Lock", Config.SHELL_LOCK, function(v)
		Config.SHELL_LOCK = v
	end)

	local spacer3 = Instance.new("Frame", container)
	spacer3.BackgroundTransparency = 1
	spacer3.Size = UDim2.new(1, 0, 0, 10)

	UI.CreateToggle(container, "Quantum Jitter", Config.QUANTUM_JITTER, function(v)
		Config.QUANTUM_JITTER = v
	end)
	UI.CreateToggle(container, "Chaos Storm", Config.CHAOS_STORM, function(v)
		Config.CHAOS_STORM = v
	end)
	UI.CreateToggle(container, "Time Warp", Config.TIME_WARP, function(v)
		Config.TIME_WARP = v
	end)
	UI.CreateToggle(container, "Claim Lock (Protect)", Config.CLAIM_LOCK, function(v)
		Config.CLAIM_LOCK = v
	end)
	UI.CreateToggle(container, "Sentinel Mode (Anti-Theft)", Config.SENTINEL_MODE, function(v)
		Config.SENTINEL_MODE = v
	end)

	local spacer4 = Instance.new("Frame", container)
	spacer4.BackgroundTransparency = 1
	spacer4.Size = UDim2.new(1, 0, 0, 10)

	UI.CreateToggle(container, "Vertical Mode", Config.VERTICAL_MODE, function(v)
		Config.VERTICAL_MODE = v
	end)
	UI.CreateToggle(container, "Show Visual Guides", State.showGuides, function(v)
		State.showGuides = v
		if not v and State.visualFolder then
			State.visualFolder:Destroy()
			State.visualFolder = nil
		end
	end)

	-- 1.5 Extra Physics Control
	local spacerPhy = Instance.new("Frame", container)
	spacerPhy.BackgroundTransparency = 1
	spacerPhy.Size = UDim2.new(1, 0, 0, 15)

	local phyLabel = Instance.new("TextLabel", container)
	phyLabel.BackgroundTransparency = 1
	phyLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	phyLabel.Size = UDim2.new(1, 0, 0, 20)
	phyLabel.Text = "Physics Tweaks:"
	phyLabel.Font = Enum.Font.GothamBold
	phyLabel.TextSize = 12
	phyLabel.TextXAlignment = Enum.TextXAlignment.Left

	UI.CreateSlider(container, "Tween Speed", 1, 50, Config.TWEEN_SPEED, function(v)
		Config.TWEEN_SPEED = v
	end)

	UI.CreateSlider(container, "Ethereal Rings", 1, 20, Config.ETHEREAL_RING_COUNT, function(v)
		Config.ETHEREAL_RING_COUNT = v
	end)

	UI.CreateSlider(container, "Ring Gap", 50, 300, Config.ETHEREAL_RING_GAP, function(v)
		Config.ETHEREAL_RING_GAP = v
	end)

	UI.CreateSlider(container, "Ring Speed", 0, 50, Config.ETHEREAL_RING_SPEED * 10, function(v)
		Config.ETHEREAL_RING_SPEED = v / 10
	end)

	UI.CreateSlider(container, "Height Offset", 0, 100, Config.ETHEREAL_HEIGHT_OFFSET, function(v)
		Config.ETHEREAL_HEIGHT_OFFSET = v
	end)

	UI.CreateSlider(container, "Tilt Angle", 0, 90, Config.ETHEREAL_TILT_ANGLE, function(v)
		Config.ETHEREAL_TILT_ANGLE = v
	end)

	UI.CreateSlider(container, "Tilt Speed", 0, 50, Config.ETHEREAL_TILT_SPEED * 10, function(v)
		Config.ETHEREAL_TILT_SPEED = v / 10
	end)

	-- Text Formation
	local spacerText = Instance.new("Frame", container)
	spacerText.BackgroundTransparency = 1
	spacerText.Size = UDim2.new(1, 0, 0, 15)

	local txtLabel = Instance.new("TextLabel", container)
	txtLabel.BackgroundTransparency = 1
	txtLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	txtLabel.Size = UDim2.new(1, 0, 0, 20)
	txtLabel.Text = "Text Formation:"
	txtLabel.Font = Enum.Font.GothamBold
	txtLabel.TextSize = 12
	txtLabel.TextXAlignment = Enum.TextXAlignment.Left

	UI.CreateSlider(container, "Text Scale", 1, 20, Config.TEXT_SCALE, function(v)
		Config.TEXT_SCALE = v
		if State.isTextMode then
			State.textPoints = Util.GetTextPoints(State.currentText)
			State.revealIndex = 0 -- Reset Animation
		end
	end)

	local txtBox = Instance.new("TextBox", container)
	txtBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	txtBox.TextColor3 = Color3.new(1, 1, 1)
	txtBox.Font = Enum.Font.GothamMedium
	txtBox.TextSize = 14
	txtBox.Size = UDim2.new(1, 0, 0, 32)
	txtBox.Text = State.currentText
	txtBox.PlaceholderText = "Type text to spawn..."
	txtBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
	txtBox.ClearTextOnFocus = false

	local boxCorner = Instance.new("UICorner", txtBox)
	boxCorner.CornerRadius = UDim.new(0, 8)

	local boxStroke = Instance.new("UIStroke", txtBox)
	boxStroke.Color = Color3.fromRGB(80, 80, 90)
	boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	txtBox.FocusLost:Connect(function()
		State.currentText = txtBox.Text
		if State.isTextMode then
			State.textPoints = Util.GetTextPoints(State.currentText)
			State.revealIndex = 0 -- Reset Animation
		end
	end)

	UI.CreateToggle(container, "Enable Text Mode", State.isTextMode, function(v)
		State.isTextMode = v
		if v then
			State.textPoints = Util.GetTextPoints(State.currentText)
			State.revealIndex = 0 -- Animation Start
			-- Capture camera rotation
			if Workspace.CurrentCamera then
				State.textRotation = Workspace.CurrentCamera.CFrame.Rotation
			else
				State.textRotation = CFrame.identity
			end
			Util.Notify("Text Mode", "Enabled. Points: " .. #State.textPoints, 2)
		else
			State.textPoints = {}
		end
	end)

	-- Window Controls
	local minimize = Instance.new("TextButton", header)
	minimize.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	minimize.Position = UDim2.new(1, -65, 0, 10)
	minimize.Size = UDim2.new(0, 20, 0, 20)
	minimize.Text = ""
	minimize.AutoButtonColor = false

	local minCorner = Instance.new("UICorner", minimize)
	minCorner.CornerRadius = UDim.new(1, 0)

	local isMin = false
	minimize.MouseButton1Click:Connect(function()
		isMin = not isMin
		container.Visible = not isMin
		ddList.Visible = false
		if isMin then
			main:TweenSize(UDim2.new(0, 300, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
			minimize.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- Green to restore
		else
			main:TweenSize(UDim2.new(0, 300, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
			minimize.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		end
	end)

	local close = Instance.new("TextButton", header)
	close.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	close.Position = UDim2.new(1, -30, 0, 10)
	close.Size = UDim2.new(0, 20, 0, 20)
	close.Text = ""
	close.AutoButtonColor = false

	local closeCorner = Instance.new("UICorner", close)
	closeCorner.CornerRadius = UDim.new(1, 0)

	close.MouseButton1Click:Connect(function()
		UI.Gui:Destroy()
	end)
end

local Core = {}

function Core.UpdateVisuals()
	if not State.blackHole then
		return
	end

	local mode = Config.SWIRL_MODE
	-- Recreate folder if mode changed or doesn't exist
	if not State.visualFolder or State.currentVisualMode ~= mode then
		if State.visualFolder then
			State.visualFolder:Destroy()
		end
		State.visualFolder = Instance.new("Folder", Workspace)
		State.visualFolder.Name = "SwirlVisuals"
		State.currentVisualMode = mode

		-- Helper to create trail line
		local function createTrail(points, color)
			for i = 1, #points - 1 do
				local p1 = points[i]
				local p2 = points[i + 1]
				local dist = (p1 - p2).Magnitude
				if dist > 0.1 then
					local part = Instance.new("Part", State.visualFolder)
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Color = color or Color3.fromRGB(0, 255, 255)
					part.Size = Vector3.new(0.5, 0.5, dist)
					part.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist / 2)
					part.Transparency = 0.5
					-- Tag for local offset logic if needed, but for now we regenerate or move group?
					-- Actually, static parts relative to 0,0,0 then moved?
					-- No, let's just make them constantly follow the black hole in the loop below.
					-- Better: Create them inside a Model and move the Model PrimaryPart?
				end
			end
		end

		-- Using Trail objects with Attachments is better for moving objects, but static neon parts are easiest for "Hologram" feel.
		-- Let's make a Model and move it.
		local model = Instance.new("Model", State.visualFolder)
		State.visualModel = model
		local centerPart = Instance.new("Part", model)
		centerPart.Name = "Center"
		centerPart.Anchored = true
		centerPart.CanCollide = false
		centerPart.Transparency = 1
		centerPart.Position = Vector3.new(0, 0, 0) -- Origin
		model.PrimaryPart = centerPart

		local function addPoint(pos, color)
			local p = Instance.new("Part", model)
			p.Anchored = true
			p.CanCollide = false
			p.Material = Enum.Material.Neon
			p.Color = color or Color3.fromRGB(100, 200, 255)
			p.Size = Vector3.new(0.8, 0.8, 0.8)
			p.Position = pos
			return p
		end

		-- Generate Geometry at Origin (0,0,0)
		local c = Vector3.new(0, 0, 0)

		if mode == "DNA" then
			for i = -30, 30 do
				local y = i * 2
				local angle = y * 0.1
				local r = 40
				addPoint(Vector3.new(math.cos(angle) * r, y, math.sin(angle) * r), Color3.fromRGB(0, 255, 100))
				addPoint(
					Vector3.new(math.cos(angle + math.pi) * r, y, math.sin(angle + math.pi) * r),
					Color3.fromRGB(255, 0, 100)
				)
			end
		elseif mode == "Helix" then -- Syncd with DNA? No, we don't have Helix mode, only DNA.
			-- ...
		elseif mode == "Heart" then
			for i = 0, 100 do
				local theta = (i / 100) * math.pi * 2
				local r = 40 * (1 - math.sin(theta)) + 15
				local x = r * math.cos(theta)
				local z = r * math.sin(theta)
				addPoint(Vector3.new(x, 0, z), Color3.fromRGB(255, 50, 50))
			end
		elseif mode == "Galaxy" then
			for arm = 0, 1 do
				local offset = arm * math.pi
				for i = 0, 50 do
					local r = i * 4
					local theta = math.log(r + 1) * 2 + offset
					addPoint(Vector3.new(math.cos(theta) * r, 0, math.sin(theta) * r), Color3.fromRGB(100, 100, 255))
				end
			end
		elseif mode == "Atom" then
			for _, axis in ipairs({ Vector3.xAxis, Vector3.yAxis, Vector3.zAxis }) do
				for i = 0, 30 do
					local theta = (i / 30) * math.pi * 2
					local cf = CFrame.fromAxisAngle(axis, theta) * CFrame.new(0, 0, 60)
					addPoint(cf.Position, Color3.fromRGB(50, 255, 50))
				end
			end
		elseif mode == "Saturn" then
			for i = 0, 60 do
				local theta = (i / 60) * math.pi * 2
				addPoint(Vector3.new(math.cos(theta) * 120, 0, math.sin(theta) * 120), Color3.fromRGB(255, 200, 100))
			end
		elseif mode == "Orbitals" then
			local axes = { Vector3.new(1, 1, 0).Unit, Vector3.new(0, 1, 1).Unit, Vector3.new(1, 0, 1).Unit }
			for _, axis in ipairs(axes) do
				local cfBase = CFrame.lookAt(Vector3.new(0, 0, 0), axis)
				for i = 0, 40 do
					local theta = (i / 40) * math.pi * 2
					local p = cfBase * CFrame.fromAxisAngle(Vector3.new(0, 0, 1), theta) * CFrame.new(0, 50, 0)
					addPoint(p.Position, Color3.fromRGB(200, 200, 255))
				end
			end
		elseif mode == "TorusKnot" then
			-- Trefoil (2,3)
			for i = 0, 100 do
				local t = (i / 100) * math.pi * 2
				local R, r = 50, 20
				local x = (R + r * math.cos(3 * t)) * math.cos(2 * t)
				local y = (R + r * math.cos(3 * t)) * math.sin(2 * t)
				local z = r * math.sin(3 * t)
				addPoint(Vector3.new(x, z, y), Color3.fromRGB(255, 100, 255))
			end
		elseif mode == "Mobius" then
			for i = 0, 60 do
				local u = (i / 60) * math.pi * 2 -- Loop
				local R = 50
				-- Center line
				local x = R * math.cos(u)
				local z = R * math.sin(u)
				local y = 0
				addPoint(Vector3.new(x, y, z), Color3.fromRGB(100, 255, 200))
			end
		elseif mode == "Lissajous" then
			for i = 0, 100 do
				local t = (i / 100) * math.pi * 2
				local A, B, C = 40, 40, 40
				local a, b, c = 3, 2, 4
				local x = A * math.sin(a * t)
				local y = B * math.sin(b * t)
				local z = C * math.sin(c * t)
				addPoint(Vector3.new(x, y, z), Color3.fromRGB(255, 255, 50))
			end
		elseif mode == "DysonSphere" then
			-- Nested Geodesic Shells
			for radius = 30, 90, 30 do
				local steps = 20
				for i = 0, steps do
					local phi = math.acos(1 - 2 * (i / steps))
					local theta = math.pi * (1 + 5 ^ 0.5) * i
					local x = radius * math.cos(theta) * math.sin(phi)
					local y = radius * math.sin(theta) * math.sin(phi)
					local z = radius * math.cos(phi)
					addPoint(Vector3.new(x, y, z), Color3.fromRGB(100, 200, 255))
				end
			end
		elseif mode == "HyperHelix" then
			-- Helix winding around a Torus
			local R, r = 60, 15
			local coils = 12
			for i = 0, 300 do
				local t = (i / 300) * math.pi * 2
				local angle = t * coils
				-- Toroidal coordinates
				local tx = (R + r * math.cos(angle)) * math.cos(t)
				local tz = (R + r * math.cos(angle)) * math.sin(t)
				local ty = r * math.sin(angle)
				addPoint(Vector3.new(tx, ty, tz), Color3.fromRGB(255, 50, 255))
			end
		elseif mode == "Quasar" then
			-- Massive Disk + BEAMS
			-- Disk
			for i = 0, 60 do
				local t = (i / 60) * math.pi * 2
				local r = 120
				addPoint(Vector3.new(math.cos(t) * r, 0, math.sin(t) * r), Color3.fromRGB(255, 100, 50))
			end
			-- Jets
			for h = -200, 200, 20 do
				if math.abs(h) > 20 then
					addPoint(Vector3.new(0, h, 0), Color3.fromRGB(50, 150, 255))
				end
			end
		elseif mode == "Tesseract" then
			-- 4D Hypercube edges (projected)
			-- Just a stylized wireframe box inside a box connected
			local s = 40
			local corners = {}
			for x = -1, 1, 2 do
				for y = -1, 1, 2 do
					for z = -1, 1, 2 do
						table.insert(corners, Vector3.new(x * s, y * s, z * s))
						table.insert(corners, Vector3.new(x * s * 0.5, y * s * 0.5, z * s * 0.5))
					end
				end
			end
			-- Approximated visual for now, physics is the real deal
			for _, c in ipairs(corners) do
				addPoint(c, Color3.fromRGB(100, 255, 100))
			end
		elseif mode == "KleinBottle" then
			-- 8 figure
			for i = 0, 100 do
				local u = (i / 100) * math.pi * 2
				for j = 0, 10 do
					local v = (j / 10) * math.pi * 2
					local r = 30
					local x = (r + math.cos(u / 2) * math.sin(v) - math.sin(u / 2) * math.sin(2 * v)) * math.cos(u)
					local y = (r + math.cos(u / 2) * math.sin(v) - math.sin(u / 2) * math.sin(2 * v)) * math.sin(u)
					local z = math.sin(u / 2) * math.sin(v) + math.cos(u / 2) * math.sin(2 * v)
					addPoint(Vector3.new(x, y * 2, z * 20), Color3.fromRGB(100, 200, 100))
				end
			end
		elseif mode == "Lorenz" then
			-- Attractor
			local p = Vector3.new(0.1, 0.1, 0.1)
			for i = 1, 300 do
				local dt = 0.05
				local dx = 10 * (p.Y - p.X)
				local dy = p.X * (28 - p.Z) - p.Y
				local dz = p.X * p.Y - (8 / 3) * p.Z
				p = p + Vector3.new(dx, dy, dz) * dt
				addPoint(p * 2, Color3.fromRGB(200, 100, 50))
			end
		elseif mode == "HopfFibration" then
			-- Circles
			for i = 0, 50 do
				local t = (i / 50) * math.pi * 4
				local x = math.sin(t) * 40
				local z = math.cos(t) * 40
				local y = math.sin(t * 2) * 20
				addPoint(Vector3.new(x, y, z), Color3.fromRGB(255, 50, 255))
			end
		elseif mode == "CalabiYau" then
			-- String theory blob
			for i = 0, 100 do
				local t = i * 0.1
				addPoint(
					Vector3.new(math.sin(t) * 30, math.cos(t * 2) * 30, math.sin(t * 3) * 30),
					Color3.fromRGB(255, 255, 0)
				)
			end
		elseif mode == "Mandelbulb" then
			-- Spiral fractal hint
			for i = 0, 60 do
				local theta = i * 0.2
				local phi = i * 0.3
				local r = 40
				local x = r * math.sin(theta) * math.cos(phi)
				local y = r * math.sin(theta) * math.sin(phi)
				local z = r * math.cos(theta)
				addPoint(Vector3.new(x, y, z), Color3.fromRGB(100, 255, 200))
			end
		elseif mode == "Gyroid" then
			-- Infinite surface approximation (cubic lattice points)
			for x = -1, 1 do
				for y = -1, 1 do
					for z = -1, 1 do
						addPoint(Vector3.new(x * 40, y * 40, z * 40), Color3.fromRGB(50, 200, 255))
					end
				end
			end
		elseif mode == "Enneper" then
			for i = -10, 10 do
				local u = i / 5
				local v = u
				local r = 15
				local x = r * (u - u ^ 3 / 3 + u * v ^ 2)
				local y = r * (v - v ^ 3 / 3 + v * u ^ 2)
				local z = r * (u ^ 2 - v ^ 2)
				if x * x + y * y + z * z < 10000 then
					addPoint(Vector3.new(x, y, z), Color3.fromRGB(255, 100, 100))
				end
			end
		elseif mode == "SuperToroid" then
			-- Square donut
			for i = 0, 60 do
				local t = (i / 60) * math.pi * 2
				local R = 50
				local x = R * (math.abs(math.cos(t)) ^ 0.5) * (math.cos(t) > 0 and 1 or -1)
				local z = R * (math.abs(math.sin(t)) ^ 0.5) * (math.sin(t) > 0 and 1 or -1)
				addPoint(Vector3.new(x, 0, z), Color3.fromRGB(200, 200, 200))
			end
		elseif mode == "Rose" then
			-- k=4
			for i = 0, 100 do
				local t = (i / 100) * math.pi * 2
				local k = 4
				local r = 60 * math.cos(k * t)
				local x = r * math.cos(t)
				local z = r * math.sin(t)
				addPoint(Vector3.new(x, 0, z), Color3.fromRGB(255, 50, 150))
			end
		elseif mode == "HexGrid" then
			-- Hexagonal pattern on sphere
			for i = 0, 40 do
				local theta = math.random() * math.pi * 2
				local r = 50
				local x = r * math.cos(theta)
				local z = r * math.sin(theta)
				addPoint(Vector3.new(x, 0, z), Color3.fromRGB(100, 255, 50))
			end
		elseif mode == "Dragon" then
			-- Visual Guide: Spine + Wings
			local t = time() * 2
			local spineLen = 30
			for i = 0, spineLen do
				local p = i / spineLen
				local phase = -t + (i * 0.5)
				local x = math.sin(phase) * 20
				local z = (i - spineLen / 2) * 10
				local y = math.cos(phase * 0.5) * 5
				addPoint(Vector3.new(x, y, z), Color3.fromRGB(255, 50, 50))

				-- Wings
				if i == 10 then
					for w = 1, 15 do
						local wingSpan = w * 8
						local flap = math.sin(t * 2) * (w * 2)
						addPoint(Vector3.new(x + wingSpan, y + flap + 20, z), Color3.fromRGB(200, 50, 50))
						addPoint(Vector3.new(x - wingSpan, y + flap + 20, z), Color3.fromRGB(200, 50, 50))
					end
				end
			end
		elseif mode == "SolarSystem" then
			-- Sun
			addPoint(Vector3.zero, Color3.fromRGB(255, 255, 0))
			-- Orbits
			for orbit = 1, 5 do
				local r = orbit * 30
				for i = 0, 40 do
					local theta = (i / 40) * math.pi * 2
					addPoint(Vector3.new(math.cos(theta) * r, 0, math.sin(theta) * r), Color3.fromRGB(100, 100, 255))
				end
			end
		elseif mode == "DoubleHelix" then
			for i = -30, 30 do
				local y = i * 2
				local angle = y * 0.1
				local r = 30
				addPoint(Vector3.new(math.cos(angle) * r, y, math.sin(angle) * r), Color3.fromRGB(0, 255, 255))
				addPoint(
					Vector3.new(math.cos(angle + math.pi) * r, y, math.sin(angle + math.pi) * r),
					Color3.fromRGB(255, 0, 255)
				)
			end

			-- Ethereal Mode: Visuals prevented for Performance (Particles are sufficient)
		end
	end

	-- Move Model to Black Hole
	if State.visualModel and State.blackHole then
		State.visualModel:SetPrimaryPartCFrame(State.blackHole.CFrame)
	end
end

function Core.SetupNetworkAccess()
	settings().Physics.AllowSleep = false
	table.insert(
		State.connections,
		RunService.Heartbeat:Connect(function()
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					player.MaximumSimulationRadius = 0
					pcall(function()
						sethiddenproperty(player, "SimulationRadius", 0)
					end)
				end
			end
			LocalPlayer.MaximumSimulationRadius = Config.MAX_SIMULATION_RADIUS
			pcall(function()
				setsimulationradius(Config.MAX_SIMULATION_RADIUS)
			end)

			-- Visuals Update
			if State.showGuides and State.blackHole then
				Core.UpdateVisuals()
			end

			-- Sentinel Update
			if Config.SENTINEL_MODE then
				Core.UpdateSentinel()
			end
		end)
	)
end

-- Helper for Shape Physics (Refactored for Binary/Vertical/Stable)
-- Helper for Shape Physics (Refactored for Binary/Vertical/Stable/Sine/Shell/Chaos)
-- Helper for Shape Physics (Revamped: Dynamic, Complex, Time-Based)
local function GetShapeVelocity(
	part,
	center,
	data,
	mode,
	isVertical,
	pullStrength,
	swirlStrength,
	isStable,
	isSine,
	isShell,
	isJitter,
	isStorm,
	isWarp,
	t -- Opt: Pass time
)
	local worldPos = part.Position
	local worldCenter = center
	-- local t = time() -- Removed internal call

	-- Vertical Mode: Transform Inputs (Rotate 90deg around Z)
	if isVertical then
		local rel = worldPos - worldCenter
		worldPos = center + Vector3.new(-rel.Y, rel.X, rel.Z)
	end

	local toCenter = worldCenter - worldPos
	local dist = toCenter.Magnitude
	if dist < 0.1 then
		return Vector3.zero
	end

	local direction = toCenter.Unit
	local radius = math.sqrt(toCenter.X * toCenter.X + toCenter.Z * toCenter.Z)
	local tangent = Vector3.zero
	local velocity = Vector3.zero

	-- 1. Base Velocity Calculation
	local t = time() * 3 -- SPEED UP GLOBAL ANIMATION (Insanity Update)

	if isStable then
		-- Stable Orbit: Perfect Ring
		local up = Vector3.yAxis
		if math.abs(direction.Y) > 0.95 then
			up = Vector3.xAxis
		end
		tangent = direction:Cross(up).Unit
		velocity = (tangent * swirlStrength) + (direction * pullStrength)
	elseif mode == "Sphere" then
		-- Revamp: Pulsing Shells with randomized axes
		if not data.swirlAxis then
			data.swirlAxis = Random.new():NextUnitVector()
		end
		-- Rotate axis chaotically
		local rot = CFrame.fromAxisAngle(Vector3.yAxis, t * 0.5) * CFrame.fromAxisAngle(Vector3.xAxis, t * 0.2)
		local currentAxis = rot * data.swirlAxis

		tangent = direction:Cross(currentAxis).Unit
		-- Deep breathing pulse
		local pulse = math.sin(t * 3 + dist * 0.05) * 15
		local rForce = direction * pulse
		velocity = (direction * pullStrength) + (tangent * swirlStrength) + rForce
	elseif mode == "Atom" then
		-- Revamp: Quantum Jumps + Precession
		if not data.atomAxis then
			data.atomAxis = ({ Vector3.xAxis, Vector3.yAxis, Vector3.zAxis })[math.random(1, 3)]
			data.orbitSpeed = math.random() * 4 + 2
		end
		if not data.orbitSpeed then
			data.orbitSpeed = 3
		end

		-- Quantum Jump: Occasionally switch axis
		if math.random() < 0.01 then
			data.atomAxis = ({ Vector3.xAxis, Vector3.yAxis, Vector3.zAxis })[math.random(1, 3)]
		end

		local rotAmount = t * 1.5
		local rot = CFrame.fromAxisAngle(Vector3.yAxis, rotAmount)
		local currentAxis = rot * data.atomAxis

		tangent = direction:Cross(currentAxis).Unit
		local planeDist = (worldPos - center):Dot(currentAxis)
		local planeForce = -(currentAxis * planeDist * 10) -- Hard lock to plane
		velocity = (direction * pullStrength * 0.5) + (tangent * swirlStrength * data.orbitSpeed) + planeForce
	elseif mode == "Tornado" then
		-- Revamp: Funnel + Debris Field (Insanity)
		local h = (worldPos.Y - center.Y) + 50

		-- Decide if part is "Debris" or "Funnel"
		if not data.tornadoRole then
			data.tornadoRole = (math.random() > 0.8) and "Debris" or "Funnel"
		end

		if data.tornadoRole == "Debris" then
			-- Orbiting wildly outside
			tangent = direction:Cross(Vector3.yAxis).Unit
			local chaoticY = math.sin(t * 5 + part.Name:len()) * 50
			local radialOut = direction * 50
			velocity = (tangent * swirlStrength * 2) + radialOut + Vector3.new(0, chaoticY, 0)
		else
			-- Funnel
			local targetR = math.abs(h * 0.8) + 10
			local wobbleX = math.sin(t * 4 + h * 0.1) * 20
			local wobbleZ = math.cos(t * 4 + h * 0.1) * 20
			local localCenter = center + Vector3.new(wobbleX, 0, wobbleZ)

			local localToCenter = localCenter - worldPos
			local localR = math.sqrt(localToCenter.X ^ 2 + localToCenter.Z ^ 2)
			local rDiff = localR - targetR
			local rVec = Vector3.new(localToCenter.X, 0, localToCenter.Z).Unit
			local rForce = rVec * rDiff * 5

			tangent = direction:Cross(Vector3.yAxis).Unit
			velocity = (tangent * swirlStrength) + rForce + Vector3.new(0, 30, 0)
		end
	elseif mode == "Vortex" then
		-- Revamp: Black Hole Singularity
		local h = (center.Y - worldPos.Y) + 50
		local targetR = math.abs(h * 0.6) + 5
		local rDiff = radius - targetR
		local rForce = (toCenter * Vector3.new(1, 0, 1)).Unit * rDiff * 5
		tangent = direction:Cross(Vector3.yAxis).Unit

		-- Event Horizon Acceleration
		local speedMult = math.clamp(200 / math.max(radius, 1), 1, 10)
		velocity = (tangent * swirlStrength * speedMult) + rForce + Vector3.new(0, -30, 0)
	elseif mode == "Vertical" then
		-- Revamp: Gyroscope Tumble
		local rot = CFrame.Angles(t, t * 1.5, 0) -- Tumble
		local localPos = rot:PointToObjectSpace(worldPos - center)
		local xForce = Vector3.new(-localPos.X * 10, 0, 0)
		xForce = rot:VectorToWorldSpace(xForce)

		local axis = (rot * Vector3.xAxis).Unit
		tangent = direction:Cross(axis).Unit
		velocity = (direction * pullStrength * 0.5) + (tangent * swirlStrength) + xForce
	elseif mode == "Saturn" then
		-- Revamp: Turbulent Rings
		local tilt = 0.3
		local rot = CFrame.Angles(tilt, 0, t * 0.1)
		local axis = (rot * Vector3.yAxis).Unit

		local planeDist = (worldPos - center):Dot(axis)
		local yForce = -(axis * planeDist * 10)

		local gap = math.sin(radius * 0.15 + t) -- Moving gaps
		local gapForce = (toCenter * Vector3.new(1, 1, 1)).Unit * gap * 15
		tangent = direction:Cross(axis).Unit
		velocity = (direction * pullStrength * 0.1) + (tangent * swirlStrength) + yForce + gapForce
	elseif mode == "Galaxy" then
		-- Revamp: Quasar Jets + Spiral
		local bulgeRadius = 30
		local isBulge = radius < bulgeRadius

		if isBulge then
			local randAxis = Vector3.yAxis
			tangent = direction:Cross(randAxis).Unit
			velocity = (direction * pullStrength) + (tangent * swirlStrength * 2)
		else
			local armOffset = t * 1.0
			local angle = math.atan2(toCenter.Z, toCenter.X) + armOffset
			local armCount = 2
			local spiralPhase = (math.log(radius) / 0.3) - (angle * armCount)
			local armDensity = math.sin(spiralPhase)
			local armForceDir = (toCenter * Vector3.new(1, 0, 1)).Unit
			local armForce = armForceDir * armDensity * 30

			tangent = direction:Cross(Vector3.yAxis).Unit
			velocity = (direction * pullStrength * 0.5)
				+ (tangent * swirlStrength)
				+ armForce
				+ Vector3.new(0, -(worldPos.Y - center.Y) * 10, 0)
		end
	elseif mode == "Heart" then
		-- Revamp: Cardiac Arrest (Fast Beat)
		local beat = math.sin(t * 10) ^ 60 * 0.8 + 1
		local angle = math.atan2(toCenter.Z, toCenter.X)
		local cardiacR = (40 * (1 - math.sin(angle)) + 15) * beat
		local rErr = radius - cardiacR
		local shapeForce = (toCenter * Vector3.new(1, 0, 1)).Unit * rErr * 10
		tangent = direction:Cross(Vector3.yAxis).Unit
		velocity = (tangent * swirlStrength * 0.5) + shapeForce + Vector3.new(0, -(worldPos.Y - center.Y) * 10, 0)
	elseif mode == "DNA" then
		-- Revamp: Unzipping Helicase
		local y = worldPos.Y - center.Y
		-- Unzip effect moving up
		local unzipY = math.sin(t * 0.5) * 100
		local isUnzipped = math.abs(y - unzipY) < 30

		local strand = (part.Name:len() % 2 == 0) and 0 or math.pi
		if isUnzipped then
			strand = strand + math.pi / 2
		end -- Split open

		local helixRadius = isUnzipped and 70 or 40
		local twistRate = 0.05
		local rot = t * 4
		local targetX = math.cos(y * twistRate + strand + rot) * helixRadius
		local targetZ = math.sin(y * twistRate + strand + rot) * helixRadius
		local targetPos = center + Vector3.new(targetX, y, targetZ)
		velocity = (targetPos - worldPos) * 10
	elseif mode == "BlackHole" then
		local yForce = Vector3.new(0, -(worldPos.Y - center.Y) * 20, 0)
		local swirlMultiplier = math.clamp(800 / math.max(radius, 5), 1, 200)
		tangent = direction:Cross(Vector3.yAxis).Unit
		velocity = (direction * pullStrength * 4) + (tangent * swirlStrength * swirlMultiplier) + yForce
	elseif mode == "Orbitals" then
		-- Revamp: Chaotic Atom
		local ringCount = 3
		local ringIndex = (part.Name:len() % ringCount) + 1
		local baseAxes = { Vector3.xAxis, Vector3.yAxis, Vector3.zAxis }

		local axis = baseAxes[ringIndex]
		local rotSpeed = t * (1.0 + ringIndex * 0.5)
		local rot = CFrame.fromAxisAngle(Vector3.new(1, 2, 3).Unit, rotSpeed)
		axis = rot * axis

		local planeDist = (worldPos - center):Dot(axis)
		local planeForce = -(axis * planeDist * 10)
		local tVec = direction:Cross(axis).Unit
		local rDiff = radius - 60
		local rForce = (toCenter * Vector3.new(1, 1, 1)).Unit * rDiff * 2
		velocity = (tVec * swirlStrength * 2) + planeForce + rForce
	elseif mode == "Dragon" then
		-- Dragon Procedural Logic
		-- Assign body parts based on hash/random
		if not data.dragonPart then
			local r = math.random()
			if r < 0.1 then
				data.dragonPart = "Head"
			elseif r < 0.4 then
				data.dragonPart = "Wing"
			elseif r < 0.9 then
				data.dragonPart = "Body"
			else
				data.dragonPart = "Tail"
			end
			data.dragonIndex = math.random() -- 0 to 1 position along segment
		end

		local spineLength = 200

		local speed = t * 1.5 -- Slower, more majestic

		-- Spine Calculation (Reduced vertical bounce)
		-- Z is forward/back, X is side-to-side
		local spinePos = (data.dragonIndex - 0.5) * spineLength

		if data.dragonPart == "Head" then
			spinePos = -spineLength * 0.5 -- Front
		elseif data.dragonPart == "Tail" then
			spinePos = spineLength * 0.5 -- Back
		end

		local phase = speed - (spinePos * 0.05)
		local spineX = math.sin(phase) * 20 -- Reduced from 30
		local spineY = math.cos(phase * 0.5) * 5 -- Reduced from 10 (Less bounce)
		local spineZ = spinePos

		local targetPos = Vector3.zero

		if data.dragonPart == "Wing" then
			-- Attach to specific spine section
			local wingAttachZ = -spineLength * 0.2
			local wingPhase = speed - (wingAttachZ * 0.05)
			local bodyX = math.sin(wingPhase) * 20
			local bodyY = math.cos(wingPhase * 0.5) * 5

			local wingSpan = 80 * data.dragonIndex + 20
			local side = (math.random() > 0.5) and 1 or -1
			local flap = math.sin(t * 4) * (wingSpan * 0.4) -- Slower flap, less amplitude

			targetPos = center + Vector3.new(bodyX + (side * wingSpan), bodyY + flap + 15, wingAttachZ)
		else
			-- Body/Head/Tail follow spine
			targetPos = center + Vector3.new(spineX, spineY, spineZ)
		end

		-- Head Look-At Logic could go here (Head separates slightly)
		if data.dragonPart == "Head" then
			targetPos = targetPos + Vector3.new(0, 5, -20)
		end

		-- Responsive Tweening
		-- Responsive Tweening
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED + pullStrength * 0.5)
	elseif mode == "SolarSystem" then
		-- Solar System Logic
		if not data.planetIndex then
			local r = math.random()
			-- 10% Sun, 90% Planets
			if r < 0.1 then
				data.planetIndex = 0 -- Sun
			else
				data.planetIndex = math.random(1, 6) -- 6 Orbital lanes
				data.orbitOffset = math.random() * math.pi * 2
				data.orbitSpeed = (1 / data.planetIndex) -- Inner planets fast
			end
		end

		if data.planetIndex == 0 then
			-- Sun: Swarm center
			local rForce = (toCenter * Vector3.new(1, 1, 1)).Unit * (radius - 15) * 5
			velocity = (direction:Cross(Vector3.yAxis).Unit * swirlStrength * 0.5) + rForce
		else
			-- Planet Lanes
			local laneRadius = data.planetIndex * 40 + 20
			local angle = data.orbitOffset + (t * data.orbitSpeed * 0.5)

			local targetX = math.cos(angle) * laneRadius
			local targetZ = math.sin(angle) * laneRadius

			-- Solar System Logic
			local moonWobble = 0

			local targetPos = center
				+ Vector3.new(targetX + moonWobble, (math.random() - 0.5) * 5, targetZ + moonWobble)
			velocity = (targetPos - worldPos) * ((Config.TWEEN_SPEED + pullStrength) * 0.5)
		end
	elseif mode == "DoubleHelix" then
		-- Double Helix Logic
		local h = worldPos.Y - center.Y
		local twist = h * 0.05 + t -- Upward flow
		local rad = 40

		-- Determine Strand A or B based on Name hash
		local hook = (part.Name:len() % 2 == 0) and 0 or math.pi

		local targetX = math.cos(twist + hook) * rad
		local targetZ = math.sin(twist + hook) * rad
		local targetPos = center + Vector3.new(targetX, h, targetZ)

		-- Keep Y bounded? Or let it flow infinite? Let's constrain Y slightly to keep shape
		if math.abs(h) > 100 then
			local yForce = -h * 0.1
			targetPos = targetPos + Vector3.new(0, yForce, 0)
		end

		velocity = (targetPos - worldPos) * ((Config.TWEEN_SPEED + pullStrength) * 0.5)
	elseif mode == "Ethereal" then
		-- Ethereal Logic: PROCEDURAL DIVINE SPHERE
		local ringCount = Config.ETHEREAL_RING_COUNT

		-- Dynamic Re-assignment if count changes
		if not data.ringIdx or data.ringMax ~= ringCount then
			data.ringIdx = math.random(1, ringCount)
			data.ringMax = ringCount -- Store max to detect config changes
			data.angleOffset = math.random() * math.pi * 2
		end

		-- Procedural Ring Radii Generation
		local effectiveR = Config.ETHEREAL_START_RADIUS + (data.ringIdx - 1) * Config.ETHEREAL_RING_GAP

		-- Procedural Speed Calculation (Harmonic alternating)
		-- Ring 1=0.05, 2=-0.04...
		local speed = (0.05 - (data.ringIdx - 1) * 0.01) * Config.ETHEREAL_RING_SPEED
		if data.ringIdx % 2 == 0 then
			speed = -speed
		end

		local angle = data.angleOffset + (t * speed)

		-- Base Position (Flat)
		local tx = math.cos(angle) * effectiveR
		local tz = math.sin(angle) * effectiveR
		local ty = 0

		-- FLATTENED DISC LOGIC (Micro-Tilt Only)
		local tiltX, tiltZ = 0, 0

		-- Gentle swaying (Max degrees defined in Config) to keep it "living" but flat
		-- Each ring sways slightly out of phase
		local sway = math.sin(t * Config.ETHEREAL_TILT_SPEED + data.ringIdx) * math.rad(Config.ETHEREAL_TILT_ANGLE)

		tiltX = sway
		tiltZ = sway * 0.5

		-- Apply Tilts
		if tiltX ~= 0 then
			local cy, sy = math.cos(tiltX), math.sin(tiltX)
			local newY = ty * cy - tz * sy
			local newZ = ty * sy + tz * cy
			ty, tz = newY, newZ
		end
		if tiltZ ~= 0 then
			local cx, sx = math.cos(tiltZ), math.sin(tiltZ)
			local newX = tx * cx - ty * sx
			local newY = tx * sx + ty * cx
			tx, ty = newX, newY
		end

		local targetPos = center + Vector3.new(tx, ty, tz)

		-- Apply Height Offset
		if targetPos.Y < Config.ETHEREAL_HEIGHT_OFFSET then
			targetPos = Vector3.new(targetPos.X, Config.ETHEREAL_HEIGHT_OFFSET, targetPos.Z)
		end

		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.15)
	elseif mode == "Grid" then
		-- Revamp: Cyber Data Flow
		local snap = 15
		-- Fast flowing data pulses
		local waveY = 0
		local waveX = math.cos(worldPos.Z * 0.1 + t * 5) * 10

		-- Matrix Rain effect
		local drop = (worldPos.Y + t * 50) % 200 - 100

		local relPos = worldPos - center
		local targetRel = Vector3.new(
			math.round((relPos.X - waveX) / snap) * snap + waveX,
			0, -- Flat plane
			math.round(relPos.Z / snap) * snap
		)
		local targetPos = center + targetRel + Vector3.new(0, waveY, 0)
		velocity = (direction * pullStrength * 0.1) + ((targetPos - worldPos) * 8)
	elseif mode == "FilledDisk" then
		-- Revamp: Magma Pool (Stable)
		if not data.targetRadius then
			data.targetRadius = math.sqrt(math.random()) * 80
			if data.targetRadius < 10 then
				data.targetRadius = 10
			end
		end

		local rTarget = data.targetRadius

		local rDiff = radius - rTarget
		local rForce = (toCenter * Vector3.new(1, 0, 1)).Unit * rDiff * 5
		local yForce = Vector3.new(0, -(worldPos.Y - center.Y) * 10, 0)
		local tVec = direction:Cross(Vector3.yAxis).Unit
		velocity = (tVec * swirlStrength) + rForce + yForce
	elseif mode == "TorusKnot" then
		-- Revamp: Hyper Knot
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		data.pathIndex = (data.pathIndex + 0.01) % 1 -- Fast flow
		local paramT = data.pathIndex * math.pi * 2
		local R, r = 50, 25
		local targetX = (R + r * math.cos(3 * paramT)) * math.cos(2 * paramT)
		local targetZ = (R + r * math.cos(3 * paramT)) * math.sin(2 * paramT)
		local targetY = r * math.sin(3 * paramT)
		local targetPos = center + Vector3.new(targetX, targetY, targetZ)
		velocity = (targetPos - worldPos) * 20
	elseif mode == "Mobius" then
		-- Revamp: Super Strip
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		data.pathIndex = (data.pathIndex + 0.005) % 1
		local u = data.pathIndex * math.pi * 2
		local R = 50
		local twistRate = u * 0.5
		if not data.stripWidth then
			data.stripWidth = (math.random() - 0.5) * 30
		end
		local targetX = (R + data.stripWidth * math.cos(twistRate)) * math.cos(u)
		local targetZ = (R + data.stripWidth * math.cos(twistRate)) * math.sin(u)
		local targetY = data.stripWidth * math.sin(twistRate)
		local targetPos = center + Vector3.new(targetX, targetY, targetZ)
		velocity = (targetPos - worldPos) * 20
	elseif mode == "Lissajous" then
		-- Revamp: Neon Tangle
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local pathT = data.pathIndex * math.pi * 2
		local morph = math.sin(t * 2) * 0.8 + 1
		local A, B, C = 50 * morph, 50, 50
		local a, b, c = 3, 2, 5 -- Higher order
		local targetX = A * math.sin(a * pathT + math.pi / 2 + t)
		local targetY = B * math.sin(b * pathT)
		local targetZ = C * math.sin(c * pathT)
		local targetPos = center + Vector3.new(targetX, targetY, targetZ)
		velocity = (targetPos - worldPos) * 10
	elseif mode == "DysonSphere" then
		-- Revamp: Tech Core
		if not data.shellRadius then
			data.shellRadius = ({ 40, 70, 100 })[math.random(1, 3)]
		end
		local rDiff = radius - data.shellRadius
		local rForce = (toCenter * Vector3.new(1, 1, 1)).Unit * rDiff * 10
		local speed = 200 / data.shellRadius
		local rot = CFrame.fromEulerAnglesXYZ(t * speed * 0.02, t * speed * 0.03, t)
		local axis = rot * Vector3.yAxis
		tangent = direction:Cross(axis).Unit
		velocity = (tangent * swirlStrength * 2) + rForce
	elseif mode == "HyperHelix" then
		-- Revamp: Space Coil
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local paramT = data.pathIndex * math.pi * 2
		local breath = 0
		local R, r = 70 + breath, 20
		local coils = 8
		local angle = paramT * coils + t * 5
		local tx = (R + r * math.cos(angle)) * math.cos(paramT)
		local tz = (R + r * math.cos(angle)) * math.sin(paramT)
		local ty = r * math.sin(angle)
		local targetPos = center + Vector3.new(tx, ty, tz)
		velocity = (targetPos - worldPos) * 10
	elseif mode == "Quasar" then
		-- Revamp: Galactic Jet
		if not data.role then
			data.role = (math.random() > 0.3) and "Disk" or "Jet"
		end
		if data.role == "Jet" then
			local h = worldPos.Y - center.Y
			local targetR = 5
			local rDiff = radius - targetR
			local rVec = Vector3.new(worldPos.X - center.X, 0, worldPos.Z - center.Z).Unit
			local rForce = -(rVec * rDiff * 10)

			local sign = (h > 0) and 1 or -1
			if math.abs(h) < 20 then
				sign = (math.random() > 0.5) and 1 or -1
			end
			local speed = 800 + math.random() * 400
			local jetForce = Vector3.new(0, sign * speed, 0)
			if math.abs(h) > 2000 then
				jetForce = Vector3.new(0, -sign * 800, 0)
			end
			velocity = jetForce + rForce
		else
			local targetR = math.random(50, 400)
			local rDiff = radius - targetR
			local rForce = (toCenter * Vector3.new(1, 0, 1)).Unit * rDiff * 2
			local yForce = Vector3.new(0, -(worldPos.Y - center.Y) * 20, 0)
			local tVec = direction:Cross(Vector3.yAxis).Unit
			velocity = (tVec * swirlStrength * 4) + rForce + yForce
		end
	elseif mode == "Tesseract" then
		-- Revamp: Hypercube Rotation
		if not data.pos4 then
			data.pos4 =
				{ x = math.random() - 0.5, y = math.random() - 0.5, z = math.random() - 0.5, w = math.random() - 0.5 }
		end
		local c, s = math.cos(t * 2), math.sin(t * 2)
		local x, y, z, w = data.pos4.x, data.pos4.y, data.pos4.z, data.pos4.w
		local x1 = x * c - w * s
		local w1 = x * s + w * c
		local y1 = y * c - z * s
		local z1 = y * s + z * c
		local dist4 = 2.5
		local factor = 1 / (dist4 - w1)
		local scale = 180
		local targetPos = center + Vector3.new(x1 * factor * scale, y1 * factor * scale, z1 * factor * scale)
		velocity = (targetPos - worldPos) * 8
	elseif mode == "KleinBottle" then
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		if not data.pathIndex2 then
			data.pathIndex2 = math.random()
		end
		local u = data.pathIndex * math.pi * 2
		local v = data.pathIndex2 * math.pi * 2 + t -- Flow UV
		local r = 35
		local cx, sx = math.cos(u / 2), math.sin(u / 2)
		local targetX = (r + cx * math.sin(v) - sx * math.sin(2 * v)) * math.cos(u)
		local targetY = (r + cx * math.sin(v) - sx * math.sin(2 * v)) * math.sin(u)
		local targetZ = (sx * math.sin(v) + cx * math.sin(2 * v)) * 20
		targetY = targetY * 2
		local targetPos = center + Vector3.new(targetX, targetY, targetZ)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "Lorenz" then
		if not data.lorenzPos then
			data.lorenzPos = Vector3.new(1, 1, 1)
		end
		local dt = 0.02 -- Faster integration
		local p = data.lorenzPos
		local dx = 10 * (p.Y - p.X)
		local dy = p.X * (28 - p.Z) - p.Y
		local dz = p.X * p.Y - (8 / 3) * p.Z
		local delta = Vector3.new(dx, dy, dz) * dt
		data.lorenzPos = p + delta
		if data.lorenzPos.Magnitude > 150 or p.X ~= p.X then -- NaN check
			data.lorenzPos = Vector3.new(0.1, 0.1, 0.1)
		end
		local targetPos = center + (data.lorenzPos * 4)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.8)
	elseif mode == "HopfFibration" then
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local paramT = data.pathIndex * math.pi * 4
		local rot = t * 3
		local x0 = math.sin(paramT) * 50
		local z0 = math.cos(paramT) * 50
		local y0 = math.sin(paramT * 2 + t) * 30
		local rx = x0 * math.cos(rot) - z0 * math.sin(rot)
		local rz = x0 * math.sin(rot) + z0 * math.cos(rot)
		local targetPos = center + Vector3.new(rx, y0, rz)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "CalabiYau" then
		-- Revamp: Quantum Manifold
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local paramT = data.pathIndex * 20
		local vib = math.sin(t * 8 + paramT) * 4
		local targetX = math.sin(paramT) * (35 + vib)
		local targetY = math.cos(paramT * 2) * (35 + vib)
		local targetZ = math.sin(paramT * 3) * (35 + vib)
		local targetPos = center + Vector3.new(targetX, targetY, targetZ)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "Mandelbulb" then
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local phi = math.acos(1 - 2 * data.pathIndex)
		local theta = math.pi * 2 * math.random()
		local power = 8 + math.sin(t * 0.5) * 4 -- Exponent varies 4-12
		local r = 60 + math.sin(theta * 5 + t) * 10
		-- Naive spherical conversion for visual consistency
		local x = r * math.sin(phi) * math.cos(theta)
		local y = r * math.sin(phi) * math.sin(theta)
		local z = r * math.cos(phi)
		local targetPos = center + Vector3.new(x, y, z)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "Gyroid" then
		local scale = 0.15
		local move = t * 1.5
		local p = (worldPos - center) * scale
		local val = math.sin(p.X + move) * math.cos(p.Y)
			+ math.sin(p.Y + move) * math.cos(p.Z)
			+ math.sin(p.Z + move) * math.cos(p.X)
		local grad = Vector3.new(
			math.cos(p.X + move) * math.cos(p.Y) - math.sin(p.Z + move) * math.sin(p.X),
			-math.sin(p.X + move) * math.sin(p.Y) + math.cos(p.Y) * math.cos(p.Z),
			-math.sin(p.Y + move) * math.sin(p.Z) + math.cos(p.Z + move) * math.cos(p.X)
		)
		local correction = grad * val * -5 -- Stranger correction
		local rForce = (toCenter * Vector3.new(1, 1, 1)).Unit * (radius - 90) * 0.2
		if radius > 120 then
			correction = correction + rForce
		end
		velocity = correction * (Config.TWEEN_SPEED * 8) + (-data.linearVelocity.VectorVelocity * 0.1)
	elseif mode == "Enneper" then
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local u = (data.pathIndex - 0.5) * 4
		local v = (math.random() - 0.5) * 4
		local r = 18
		local x = r * (u - u ^ 3 / 3 + u * v ^ 2)
		local y = r * (v - v ^ 3 / 3 + v * u ^ 2)
		local z = r * (u ^ 2 - v ^ 2)
		local rot = t * 2
		local rx = x * math.cos(rot) - z * math.sin(rot)
		local rz = x * math.sin(rot) + z * math.cos(rot)
		local targetPos = center + Vector3.new(rx, y, rz)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "SuperToroid" then
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local paramT = data.pathIndex * math.pi * 2
		local R, r = 60, 25
		local n1 = 0.5 + math.sin(t * 2) * 0.4
		local c, s = math.cos(paramT), math.sin(paramT)
		local sgnC, sgnS = (c > 0 and 1 or -1), (s > 0 and 1 or -1)
		local tmp = (math.abs(c)) ^ n1 * sgnC
		local targetX = R * tmp
		local targetZ = R * (math.abs(s)) ^ n1 * sgnS
		local targetPos = center + Vector3.new(targetX, (math.random() - 0.5) * 30, targetZ)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "Rose" then
		if not data.pathIndex then
			data.pathIndex = math.random()
		end
		local paramT = data.pathIndex * math.pi * 2
		local k = 4 + math.sin(t * 0.5) * 3
		local r = 70 * math.cos(k * paramT)
		local targetX = r * math.cos(paramT + t)
		local targetZ = r * math.sin(paramT + t)
		local targetPos = center + Vector3.new(targetX, 0, targetZ)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
	elseif mode == "HexGrid" then
		local hexScale = 25 + math.sin(t * 4) * 5
		local q = math.floor(worldPos.X / hexScale * 2 / 3)
		local r = math.floor((worldPos.X / hexScale * -1 / 3 + worldPos.Z / hexScale * math.sqrt(3) / 3))
		local x = hexScale * 3 / 2 * q
		local z = hexScale * math.sqrt(3) * (r + q / 2)
		local targetPos = center + Vector3.new(x, worldPos.Y, z)
		velocity = (targetPos - worldPos) * (Config.TWEEN_SPEED * 0.5)
			+ ((toCenter * Vector3.new(1, 0, 1)).Unit * (radius - 100) * 0.1)
	else -- Default Disk
		-- Revamp: Spiral Ripples with MOLTEN CORE
		local up = Vector3.new(0, 1, 0)
		if math.abs(direction.Y) > 0.95 then
			up = Vector3.new(1, 0, 0)
		end
		tangent = direction:Cross(up).Unit

		if radius < 30 then
			-- Molten Core: Chaotic noise
			local noise = Vector3.new(
				math.sin(t * 5 + part.Position.X),
				math.cos(t * 4 + part.Position.Y),
				math.sin(t * 6 + part.Position.Z)
			) * 20
			velocity = (direction * -1 * pullStrength) + noise
		else
			-- Standard Disk
			local swirlMultiplier = math.clamp(150 / dist, 1, 20)
			local ripple = 0
			local rippleForce = Vector3.new(0, ripple, 0)
			velocity = (direction * pullStrength) + (tangent * swirlStrength * swirlMultiplier) + rippleForce
		end
	end

	-- 2. Modifiers Overrides (Apply to ALL Modes)

	-- Sine Wave (Vertical Oscillation)
	if isSine then
		-- Removed bounce
	end

	-- Shell Lock (Radius Clamp Constraint)
	if isShell then
		local targetRadius = 150 -- Default shell
		if data.shellR then
			targetRadius = data.shellR
		else
			data.shellR = 100 + math.random() * 100 -- Assign a shell once
			targetRadius = data.shellR
		end

		local rDiff = radius - targetRadius
		-- Force correction towards shell (Overpower velocity)
		local rForce = (toCenter * Vector3.new(1, 0, 1)).Unit * rDiff * 5

		-- Blend with existing tangential, but REPLACE radial component
		-- Simple addition works if rForce is strong enough
		velocity = velocity + rForce
	end

	-- 2. DRAMATIC Modifiers Overrides (Apply to ALL Modes)

	-- Sine Wave: THE TSUNAMI
	if isSine then
		-- Removed bounce
	end

	-- Shell Lock: GRAVITY WALL
	if isShell then
		local targetRadius = 150
		if data.shellR then
			targetRadius = data.shellR
		else
			data.shellR = 80 + math.random() * 100
			targetRadius = data.shellR
		end

		local rDiff = radius - targetRadius
		-- Hard wall bounce
		local rForce = (toCenter * Vector3.new(1, 0, 1)).Unit * rDiff * 20
		velocity = velocity + rForce
	end

	-- Quantum Jitter: REALITY FLICKER
	if isJitter then
		-- Teleport-like shaking
		if math.random() < 0.3 then
			velocity = velocity + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 500
		end
	end

	-- Chaos Storm: HURRICANE
	if isStorm then
		-- Violent turbulence
		local turb = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 200
		velocity = velocity + turb

		-- Random Explosions
		if math.random() < 0.02 then
			velocity = velocity * -5 -- Massive repelling blast
		end
	end

	-- Time Warp: BULLET TIME / HYPER SPEED
	if isWarp then
		if not data.warpSpeed then
			-- Extreme variance: Either 0.05x (Frozen) or 50x (Flash)
			if math.random() > 0.5 then
				data.warpSpeed = 0.05 -- Bullet time
			else
				data.warpSpeed = 5.0 -- Hyper speed
			end
		end

		-- Slowly morph speed for glitch effect
		if math.random() < 0.05 then
			data.warpSpeed = (data.warpSpeed == 0.05) and 5.0 or 0.05
		end

		velocity = velocity * data.warpSpeed
	end

	-- Vertical Mode: Inverse Transform Output
	if isVertical then
		velocity = Vector3.new(velocity.Y, -velocity.X, velocity.Z)
	end

	return velocity
end

-- Update forces with Pulse and Event Horizon logic
local function UpdateAttractionForces()
	if not State.blackHole then
		return
	end

	-- Wrap in pcall to prevent crash
	local success, err = pcall(function()
		local center = State.blackHole.Position
		local centerSize = State.blackHole.Size.X / 2

		-- Optimization: Split loops to avoid O(N^2) search in text mode
		if State.isTextMode and State.textPoints and #State.textPoints > 0 then
			-- Check for cache invalidation (simple count check, can be improved)
			local currentCount = 0
			for _ in pairs(State.affectedParts) do
				currentCount = currentCount + 1
			end

			if currentCount ~= State.lastPartCount or not State.sortedPartsCache then
				State.lastPartCount = currentCount
				State.sortedPartsCache = {}
				for p, d in pairs(State.affectedParts) do
					table.insert(State.sortedPartsCache, { p, d })
				end
				table.sort(State.sortedPartsCache, function(a, b)
					return a[1].Name < b[1].Name
				end)
			end

			for i, item in ipairs(State.sortedPartsCache) do
				local part = item[1]
				local data = item[2]

				if not part or not part.Parent or not State.affectedParts[part] then
					continue
				end

				local toCenter = (center - part.Position)
				local dist = toCenter.Magnitude

				-- Optimization: Distance Culling
				if dist > Config.MAX_SIMULATION_RADIUS then
					continue
				end

				-- Event Horizon
				if Config.EVENT_HORIZON and dist < (centerSize + 2) then
					pcall(function()
						part:Destroy()
					end)
					State.affectedParts[part] = nil
					continue
				end

				-- Assign to text point (Wrapped/Compressed)
				local ptIndex = ((i - 1) % #State.textPoints) + 1
				local pt = State.textPoints[ptIndex]

				-- Text Animation: Bobbing (Alive)
				local t = time()
				local bobOffset = Vector3.new(0, 0, 0)

				-- Camera Facing (Billboarding)
				local camera = Workspace.CurrentCamera
				local camPos = camera.CFrame.Position
				local rot = CFrame.lookAt(center, camPos)
				local worldPoint = rot:PointToWorldSpace(pt + bobOffset)

				-- Mouse Repel (Interaction)
				local mousePos = Mouse.Hit.p
				local distToMouse = (part.Position - mousePos).Magnitude
				local repelForce = Vector3.zero
				if distToMouse < 25 then
					local pushDir = (part.Position - mousePos).Unit
					repelForce = pushDir * (25 - distToMouse) * 15
				end

				local targetPos = worldPoint + repelForce
				local diff = targetPos - part.Position

				-- P-D Controller-like behavior via LinearVelocity
				local velocity = diff * 30
				data.linearVelocity.VectorVelocity = velocity

				-- Stabilize rotation: Stop spinning
				if not data.angularVelocity then
					local av = Instance.new("AngularVelocity", part)
					av.Name = "TextStabilizer"
					av.MaxTorque = math.huge -- Absolute freeze
					av.AngularVelocity = Vector3.new(0, 0, 0)
					av.RelativeTo = Enum.ActuatorRelativeTo.World
					av.Attachment0 = data.attachment
					data.angularVelocity = av
				end
			end
		else
			-- Normal Mode: Iterate dictionary directly (O(N))
			State.frameCount = State.frameCount + 1
			local throttle = Config.PHYSICS_THROTTLE or 1

			-- Cache Optimizations (Lookup Invariants outside loop)
			local swirlMode = Config.SWIRL_MODE
			local isVertical = Config.VERTICAL_MODE
			local pullStrength = Config.PULL_STRENGTH
			local swirlStrength = Config.SWIRL_STRENGTH
			local maxRadius = Config.MAX_SIMULATION_RADIUS

			-- Logic Flags
			local isStable = Config.ORBIT_STABILIZER
			local isSine = Config.SINE_WAVE
			local isShell = Config.SHELL_LOCK
			local isJitter = Config.QUANTUM_JITTER
			local isStorm = Config.CHAOS_STORM
			local isWarp = Config.TIME_WARP

			-- Performance: Smart Adaptive Throttling
			local activeCount = 0
			for _ in pairs(State.affectedParts) do
				activeCount = activeCount + 1
			end

			local dynamicThrottle = 1
			if activeCount > 5000 then
				dynamicThrottle = 10 -- Heavy Load
			elseif activeCount > 2500 then
				dynamicThrottle = 6
			elseif activeCount > 1000 then
				dynamicThrottle = 3
			end

			local effectiveThrottle = Config.PHYSICS_THROTTLE or dynamicThrottle

			-- Optimization: Cache time once per frame
			local frameTime = time()

			local i = 0

			for part, data in pairs(State.affectedParts) do
				if not part.Parent then
					Core.ReleasePart(part)
					continue
				end

				i = i + 1
				-- Throttling: Only update 1/Nth of parts each frame
				if i % effectiveThrottle ~= (State.frameCount % effectiveThrottle) then
					continue
				end

				if true then -- Wrapper to maintain block structure (matching 'end')
					-- Cleanup stabilizer if exists
					if data.angularVelocity then
						data.angularVelocity:Destroy()
						data.angularVelocity = nil
					end

					local toCenter = (center - part.Position)
					local dist = toCenter.Magnitude

					-- Optimization: Distance Culling (Skip far parts entirely)
					-- UNLESS Claim Lock is on
					if not Config.CLAIM_LOCK and dist > maxRadius then
						continue
					end

					-- Claim Lock Logic: Void Protection & Return Force
					local returnForce = Vector3.zero
					if Config.CLAIM_LOCK then
						-- 1. Void Protection
						if part.Position.Y < -50 then
							part.CFrame = CFrame.new(center + Vector3.new(0, 50, 0))
							part.AssemblyLinearVelocity = Vector3.zero
						end

						-- 2. Return Force (Tighter Leash for Stability)
						-- Prevent parts from wandering off the shape (500 stud limit)
						local leashRange = 500
						if dist > leashRange then
							local dir = (center - part.Position).Unit
							local distFactor = (dist - leashRange) * 5
							returnForce = dir * distFactor -- Elastic snap back
						end
					end

					-- Event Horizon
					if Config.EVENT_HORIZON and dist < (centerSize + 2) then
						pcall(function()
							part:Destroy()
						end)
						State.affectedParts[part] = nil
						continue
					end

					if dist > 0.1 then
						local targetVelocity = GetShapeVelocity(
							part,
							center,
							data,
							swirlMode,
							isVertical,
							pullStrength,
							swirlStrength,
							isStable,
							isSine,
							isShell,
							isJitter,
							isStorm,
							isWarp,
							frameTime -- Pass cached time
						)

						-- Initial velocity check
						if not data.lastVelocity then
							data.lastVelocity = Vector3.zero
						end

						-- Smoothing (Lerp) - The "Butter" Update
						-- Interpolate from current velocity to target velocity
						-- If Claim Lock is on, use stiffer Lerp (0.8) to keep parts glued to shape
						local effectiveLerp = Config.CLAIM_LOCK and 0.8 or Config.PHYSICS_LERP
						local smoothedVelocity = data.lastVelocity:Lerp(targetVelocity + returnForce, effectiveLerp)
						data.lastVelocity = smoothedVelocity

						data.linearVelocity.VectorVelocity = smoothedVelocity
					end
				end
			end
		end
	end)

	if not success then
		warn("Physics Error:", err)
	end
end

-- Physics loop for Dragging (Improved Raycast)
local function UpdateDrag()
	if not State.blackHole or not State.isDragging then
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	-- On drag start, calculate initial depth if not set
	if not State.dragDepth then
		local toHole = State.blackHole.Position - camera.CFrame.Position
		State.dragDepth = toHole.Magnitude
	end

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	-- Target is along ray at fixed depth
	local targetPos = ray.Origin + (ray.Direction * State.dragDepth)

	-- Smooth Lerp
	local currentPos = State.blackHole.Position
	local lerpAlpha = 0.25
	State.blackHole.Position = currentPos:Lerp(targetPos, lerpAlpha)
	State.blackHole.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Stop physics accumulation
end

-- Sentinel Prevention Logic
function Core.UpdateSentinel()
	if not Config.SENTINEL_MODE then
		return
	end

	-- Optimization: Time-Slicing (Distributed Processing)
	-- Instead of checking ALL parts every frame (which kills FPS with GetChildren),
	-- we check a small batch each frame.

	local BATCH_SIZE = 20 -- Check 20 parts per frame

	-- We need a list to iterate numerically
	if not State.sentinelList or #State.sentinelList == 0 then
		State.sentinelList = {}
		for part, data in pairs(State.affectedParts) do
			table.insert(State.sentinelList, { part, data })
		end
	end

	-- Rebuild list occasionally if counts mismatch drastically?
	-- Or just handle nil parts gracefully.

	if not State.sentinelIndex then
		State.sentinelIndex = 1
	end

	local dangerousClasses = {
		"BodyPosition",
		"BodyGyro",
		"BodyVelocity",
		"BodyAngularVelocity",
		"LinearVelocity",
		"AlignPosition",
		"AlignOrientation",
		"VectorForce",
		"Torque",
	}

	local checked = 0
	local maxParts = #State.sentinelList

	while checked < BATCH_SIZE do
		if State.sentinelIndex > maxParts then
			State.sentinelIndex = 1
			-- Refresh list at end of cycle to catch new parts
			State.sentinelList = {}
			for part, data in pairs(State.affectedParts) do
				table.insert(State.sentinelList, { part, data })
			end
			maxParts = #State.sentinelList
			if maxParts == 0 then
				break
			end
		end

		local item = State.sentinelList[State.sentinelIndex]
		local part = item[1]
		local data = item[2]

		State.sentinelIndex = State.sentinelIndex + 1
		checked = checked + 1

		if part and part.Parent then
			-- Scan children
			for _, child in ipairs(part:GetChildren()) do
				if table.find(dangerousClasses, child.ClassName) then
					-- Check if it's OURS (The one we made)
					local isSafe = false

					-- We store our distinct instances in 'data'
					if child == data.linearVelocity or child == data.attachment or child == data.angularVelocity then
						isSafe = true
					end

					-- If we didn't authorize it, DESTROY IT.
					if not isSafe then
						pcall(function()
							-- warn("Sentinel Removed:", child.ClassName, "from", part.Name)
							child:Destroy()
						end)
					end
				end
			end

			-- Enforce Properties
			if part.CanTouch then
				part.CanTouch = false
			end
			if not part.Locked then
				part.Locked = true
			end
		end
	end
end

function Core.ApplyForceToPart(part)
	if Util.IsExcluded(part) then
		return
	end
	if State.affectedParts[part] then
		return
	end

	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("BodyMover") or child:IsA("Constraint") then
			child:Destroy()
		end
	end

	local existingAttachment = part:FindFirstChild("BlackHoleAttachment")
	if existingAttachment then
		existingAttachment:Destroy()
	end

	part.CanCollide = false
	part.Anchored = false -- Critical fix: Ensure physics can act on it

	local attachment = Instance.new("Attachment", part)
	attachment.Name = "BlackHoleAttachment"

	local linearVelocity = Instance.new("LinearVelocity", part)
	linearVelocity.MaxForce = Config.ALIGN_MAX_FORCE
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Attachment0 = attachment

	State.affectedParts[part] = {
		attachment = attachment,
		linearVelocity = linearVelocity,
		angularVelocity = nil, -- Placeholder
		swirlAxis = Random.new():NextUnitVector(),
		atomAxis = ({ Vector3.xAxis, Vector3.yAxis, Vector3.zAxis })[math.random(1, 3)],
		originalSize = part.Size,
	}
end

function Core.ReleasePart(part)
	local data = State.affectedParts[part]
	if data then
		if data.attachment and data.attachment.Parent then
			data.attachment:Destroy()
		end
		if data.linearVelocity and data.linearVelocity.Parent then
			data.linearVelocity:Destroy()
		end
		if data.angularVelocity and data.angularVelocity.Parent then
			data.angularVelocity:Destroy()
		end
		State.affectedParts[part] = nil
	end
end

function Core.CreateOrMoveBlackHole(position)
	if State.blackHole then
		local tween = TweenService:Create(State.blackHole, TweenInfo.new(0.1), { Position = position })
		tween:Play()
		return
	end

	local folder = Instance.new("Folder", Workspace)
	folder.Name = "AttractorSystem"

	State.blackHole = Instance.new("Part", folder)
	State.blackHole.Size = Config.BLACK_HOLE_SIZE
	State.blackHole.Shape = Enum.PartType.Ball
	State.blackHole.Color = Config.BLACK_HOLE_COLOR
	State.blackHole.Anchored = true
	State.blackHole.CanCollide = false
	State.blackHole.Material = Enum.Material.Neon
	State.blackHole.Position = position
	State.blackHole.Transparency = 0.1

	State.isDragging = false

	-- Visuals (Glow + Particles)
	local glow = Instance.new("PointLight", State.blackHole)
	glow.Color = Config.BLACK_HOLE_GLOW_COLOR
	glow.Range = Config.BLACK_HOLE_GLOW_RANGE
	glow.Brightness = Config.BLACK_HOLE_GLOW_BRIGHTNESS

	-- ... (Particle Emitters same as before, condensed for brevity) ...
	-- Note: Keeping original particle create logic simplified in this replace block for length,
	-- but ensuring it still creates the visual "hole".

	local particleEmitter = Instance.new("ParticleEmitter", State.blackHole)
	particleEmitter.Texture = "rbxassetid://243098098"
	particleEmitter.Color = ColorSequence.new(Config.BLACK_HOLE_COLOR, Config.BLACK_HOLE_GLOW_COLOR)
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.5) })
	particleEmitter.Transparency =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1) })
	particleEmitter.Rate = 200
	particleEmitter.Lifetime = NumberRange.new(1, 2)
	particleEmitter.Speed = NumberRange.new(5, 10)
	particleEmitter.VelocitySpread = 180

	local sizeTween = TweenService:Create(
		State.blackHole,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Size = Config.BLACK_HOLE_SIZE * 1.2 }
	)
	sizeTween:Play()

	for _, v in ipairs(Workspace:GetDescendants()) do
		Core.ApplyForceToPart(v)
	end

	local descendantConnection = Workspace.DescendantAdded:Connect(function(v)
		Core.ApplyForceToPart(v)
	end)
	table.insert(State.connections, descendantConnection)

	State.isActive = true
	Util.Notify("Attractor", "Black hole created. Click and Drag to move cleanly.", 3)
	UI.Setup() -- Open GUI on create
end

function Core.Cleanup()
	if State.blackHole then
		State.blackHole.Parent:Destroy()
		State.blackHole = nil
	end
	for part, _ in pairs(State.affectedParts) do
		Core.ReleasePart(part)
	end
	for _, connection in ipairs(State.connections) do
		connection:Disconnect()
	end
	State.connections = {}
	State.affectedParts = {}
	State.isActive = false

	ContextActionService:UnbindAction("CreateBlackHole")
	ContextActionService:UnbindAction("RemoveBlackHole")

	if UI.Gui then
		UI.Gui:Destroy()
	end

	Util.Notify("Attractor", "Black hole removed.", 2)
end

local Input = {}

function Input.HandleAction(actionName, inputState, inputObject)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if actionName == "CreateBlackHole" then
		Core.CreateOrMoveBlackHole(Mouse.Hit.p)
		return Enum.ContextActionResult.Sink
	elseif actionName == "RemoveBlackHole" then
		Core.Cleanup()
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function Input.SetupInputs()
	ContextActionService:BindAction("CreateBlackHole", Input.HandleAction, false, Enum.KeyCode.E)
	ContextActionService:BindAction("RemoveBlackHole", Input.HandleAction, false, Enum.KeyCode.Q)

	-- Drag inputs
	table.insert(
		State.connections,
		UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			if not State.blackHole then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if Mouse.Target == State.blackHole then
					State.isDragging = true
					-- Calculate current depth relative to camera
					local camera = Workspace.CurrentCamera
					if camera then
						State.dragDepth = (State.blackHole.Position - camera.CFrame.Position).Magnitude
					else
						State.dragDepth = 50 -- Fallback
					end
				end
			end
		end)
	)

	table.insert(
		State.connections,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				State.isDragging = false
			end
		end)
	)

	Util.Notify("Script Executed", "Press 'E' to spawn. Drag to move.", 5)
end

local function Initialize()
	Core.SetupNetworkAccess()
	Input.SetupInputs()
	table.insert(State.connections, RunService.Heartbeat:Connect(UpdateAttractionForces))
	table.insert(State.connections, RunService.RenderStepped:Connect(UpdateDrag)) -- Using RenderStepped for smoother drag

	-- Fix for the "attempt to index nil" error: declare variable first
	local scriptConnection
	scriptConnection = RunService.Heartbeat:Connect(function()
		if not scriptConnection.Connected then
			Core.Cleanup()
		end
	end)
	table.insert(State.connections, scriptConnection)

	UI.Setup() -- Show UI Immediately
	Util.Notify("Black Hole", "Script Loaded. GUI Open.", 3)
end

Initialize()
