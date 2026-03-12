local bruh = settings():GetService("PhysicsSettings")
bruh.AllowSleep = false
bruh.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled

getgenv().Network = getgenv().Network or {}
Network.Parts = Network.Parts or {}
Network.Velocity = Vector3.new(0, -25.5, 0) + Vector3.new(0, math.cos(tick() * 10) / 100, 0)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ForcedParts = {}
local Joints = {}

local function ForcePart(part)
	if not part or not part:IsA("BasePart") then
		return
	end
	if part.Anchored then
		return
	end
	if part.Parent:FindFirstChildOfClass("Humanoid") then
		return
	end
	if ForcedParts[part] then
		return
	end

	for _, obj in ipairs(part:GetChildren()) do
		if obj:IsA("Attachment") or obj:IsA("AlignPosition") or obj:IsA("Torque") then
			obj:Destroy()
		end
	end

	part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
	part.CanCollide = false
	part.CanTouch = false
	part.Massless = true
	part.Parent = workspace

	local torque = Instance.new("Torque", part)
	torque.Torque = Vector3.new(1e4, 1e4, 1e4)

	local attachment = Instance.new("Attachment", part)

	local anchor = Instance.new("Part", workspace)
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Massless = true
	anchor.CFrame = part.CFrame
	anchor.Parent = workspace
	anchor.Name = part.Name .. "__anchor"

	local anchorAttachment = Instance.new("Attachment", anchor)

	local align = Instance.new("AlignPosition", part)
	align.MaxForce = 9e9
	align.MaxVelocity = math.huge
	align.Responsiveness = 200
	align.Attachment0 = attachment
	align.Attachment1 = anchorAttachment

	local AlignOrientation = Instance.new("AlignOrientation", part)
	AlignOrientation.Attachment0 = attachment
	AlignOrientation.Attachment1 = anchorAttachment
	AlignOrientation.Responsiveness = 200
	AlignOrientation.MaxTorque = 9e9

	table.insert(Joints, torque)
	table.insert(Joints, attachment)
	table.insert(Joints, align)
	table.insert(Joints, AlignOrientation)

	ForcedParts[part] = {
		Attachment = attachment,
		Align = align,
		AlignOrientation = AlignOrientation,
		Torque = torque,
		AnchorPart = anchor,
		AnchorAttachment = anchorAttachment,
	}

	part.Destroying:Connect(function()
		if ForcedParts[part] then
			if ForcedParts[part].AnchorPart then
				ForcedParts[part].AnchorPart:Destroy()
			end
			ForcedParts[part] = nil
		end
	end)

	part.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if ForcedParts[part] then
				if ForcedParts[part].AnchorPart then
					ForcedParts[part].AnchorPart:Destroy()
				end
				ForcedParts[part] = nil
			end
		end
	end)
end

RunService.Heartbeat:Connect(function()
	sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
	for _, part in pairs(Network.Parts) do
		if part:IsDescendantOf(Workspace) then
			part.Velocity = Network.Velocity
		end
	end
end)

local TelekinesisEnabled = true
local TelekinesisConn, MouseDownConn, MouseUpConn, InputConn
local Mouse = LocalPlayer:GetMouse()
local HeldPart = nil
local HeldModel = nil
local Spinning = false

local function EnableTelekinesis()
	local TelekinesisDistance = 25
	local MinDistance = 10
	local MaxDistance = 900
	local DistanceStep = 10

	local Rotation = Vector3.new(0, 0, 0)
	local RotationSpeed = math.rad(15)

	TelekinesisEnabled = true

	MouseDownConn = Mouse.Button1Down:Connect(function()
		if not Mouse.Target or Mouse.Target.Anchored then
			return
		end

		local targetPlayer = Players:GetPlayerFromCharacter(Mouse.Target:FindFirstAncestorOfClass("Model"))
		if targetPlayer then
			return
		end -- PREVENT PLAYERS

		InputConn = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			if not TelekinesisEnabled or not HeldPart then
				return
			end

			if input.KeyCode == Enum.KeyCode.E then
				TelekinesisDistance = math.clamp(TelekinesisDistance + DistanceStep, MinDistance, MaxDistance)
			elseif input.KeyCode == Enum.KeyCode.Q then
				TelekinesisDistance = math.clamp(TelekinesisDistance - DistanceStep, MinDistance, MaxDistance)
			elseif input.KeyCode == Enum.KeyCode.R then
				Rotation = Rotation + Vector3.new(0, RotationSpeed, 0)
			elseif input.KeyCode == Enum.KeyCode.F then
				Rotation = Rotation - Vector3.new(0, RotationSpeed, 0)
			elseif input.KeyCode == Enum.KeyCode.T then
				Rotation = Rotation + Vector3.new(RotationSpeed, 0, 0)
			elseif input.KeyCode == Enum.KeyCode.G then
				Rotation = Rotation - Vector3.new(RotationSpeed, 0, 0)
			elseif input.KeyCode == Enum.KeyCode.X then
				Rotation = Vector3.new(0, 0, 0)
			elseif input.KeyCode == Enum.KeyCode.Z then
				Spinning = not Spinning
			end
		end)

		local model = Mouse.Target:FindFirstAncestorOfClass("Model")
		if model then
			HeldModel = model
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored then
					ForcePart(part)
					table.insert(Network.Parts, part)
				end
			end
		else
			HeldPart = Mouse.Target
			ForcePart(HeldPart)
			table.insert(Network.Parts, HeldPart)
		end

		TelekinesisConn = RunService.Heartbeat:Connect(function()
			if not TelekinesisEnabled then
				return
			end

			local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
			local goalPos = ray.Origin + ray.Direction * TelekinesisDistance

			local rotationCFrame
			if Spinning then
				local randomX = math.rad(math.random(-20, 30)) * 4
				local randomY = math.rad(math.random(-30, 10)) * 3
				local randomZ = math.rad(math.random(-50, 20)) * 2
				rotationCFrame = CFrame.Angles(Rotation.X, Rotation.Y, Rotation.Z)
					* CFrame.Angles(randomX, randomY, randomZ)
			else
				rotationCFrame = CFrame.Angles(Rotation.X, Rotation.Y, Rotation.Z)
			end

			if HeldModel then
				for _, part in ipairs(HeldModel:GetDescendants()) do
					if ForcedParts[part] then
						ForcedParts[part].AnchorPart.CFrame = CFrame.new(goalPos) * rotationCFrame
					end
				end
			elseif HeldPart and ForcedParts[HeldPart] then
				ForcedParts[HeldPart].AnchorPart.CFrame = CFrame.new(goalPos) * rotationCFrame
			end
		end)
	end)

	MouseUpConn = Mouse.Button1Up:Connect(function()
		HeldModel = nil
		HeldPart = nil
		TelekinesisDistance = 25
		MinDistance = 10
		MaxDistance = 900
		DistanceStep = 10

		if TelekinesisConn then
			TelekinesisConn:Disconnect()
			TelekinesisConn = nil
		end

		if InputConn then
			InputConn:Disconnect()
			InputConn = nil
		end
	end)
end

local function DisableTelekinesis()
	TelekinesisEnabled = false

	if TelekinesisConn then
		TelekinesisConn:Disconnect()
	end
	if MouseDownConn then
		MouseDownConn:Disconnect()
	end
	if MouseUpConn then
		MouseUpConn:Disconnect()
	end
	if InputConn then
		InputConn:Disconnect()
	end

	HeldPart = nil
	HeldModel = nil
end

local bodyVelocities = {}

local function PartsRepellent()
	RunService.Heartbeat:Connect(function()
		local radius = 10
		local origin = LocalPlayer.Character
			and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			and LocalPlayer.Character.HumanoidRootPart.Position
		if not origin then
			return
		end

		local region =
			Region3.new(origin - Vector3.new(radius, radius, radius), origin + Vector3.new(radius, radius, radius))
		local partsInRadius = workspace:FindPartsInRegion3(region, nil, math.huge)

		for _, part in pairs(partsInRadius) do
			if not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
				local dir = (part.Position - origin).Unit

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				bodyVelocity.Velocity = dir * 50
				bodyVelocity.Parent = part
				bodyVelocities[part] = bodyVelocity
			end
		end

		for part, bodyVelocity in pairs(bodyVelocities) do
			local dist = (part.Position - origin).Magnitude

			if dist > radius then
				bodyVelocity:Destroy()
				bodyVelocities[part] = nil
			end
		end
	end)
end

EnableTelekinesis()
