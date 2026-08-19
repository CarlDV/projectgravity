--!native

local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local localPlayer, env = Players.LocalPlayer, getgenv()
local cache, connections = setmetatable({}, {__mode = "k"}), setmetatable({}, {__mode = "k"})

if env._ANTI_FLING_STOP then pcall(env._ANTI_FLING_STOP) end

local tickCount = 0
local stepped = RunService.Stepped:Connect(function()
	tickCount += 1
	if tickCount % 3 ~= 0 then return end
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player ~= localPlayer and player.Character
		if character then
			local parts = cache[character]
			if not parts then
				parts = {}
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then parts[#parts + 1] = part end
				end
				cache[character] = parts
				connections[character] = character.DescendantAdded:Connect(function(part)
					if part:IsA("BasePart") then parts[#parts + 1] = part end
				end)
			end
			for index = #parts, 1, -1 do
				local part = parts[index]
				if part and part.Parent then
					part.CanCollide = false
				else
					table.remove(parts, index)
				end
			end
		end
	end
end)

env._ANTI_FLING_STOP = function()
	stepped:Disconnect()
	for _, connection in pairs(connections) do connection:Disconnect() end
	table.clear(cache)
	table.clear(connections)
end
