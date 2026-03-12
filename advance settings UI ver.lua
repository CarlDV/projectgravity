--!native

-- PLEASE DONT DISTRIBUTE IF FOUND :((
-- DISCORD: dein2fl (you can also find me in IY server - @David/@dein2fl)
-- DO NOT DISTRIBUTE!!
local function safe_service(name)
	local service = game:GetService(name)
	if cloneref then
		return cloneref(service)
	end
	return service
end

local v1, v2, v3, v4, v5, v6, v7 =
	safe_service("UserInputService"), --v1
	safe_service("Players"), --v2
	safe_service("RunService"), --v3
	safe_service("Workspace"), --v4
	safe_service("StarterGui"), --v5
	safe_service("TweenService"), --v6
	safe_service("ContextActionService") --v7
local HttpService = safe_service("HttpService")

if setthreadidentity then
	pcall(function()
		setthreadidentity(8)
	end)
end

local v8, v9 = v2.LocalPlayer, v2.LocalPlayer:GetMouse()
if v1.TouchEnabled and not v1.KeyboardEnabled then
	v8:Kick("PC ONLY. GET OFF MOBILE.")
	while true do
	end
end
local x9 = { c1 = 0.15, c2 = 0.05, c3 = 0.01, c4 = 0.2, c5 = 0.6, c6 = 0.8, c7 = 0.1, c8 = 0.25 }
local ANTI_SLEEP = Vector3.new(0, 0.01, 0)
local x1 = {
	k1 = 2000, --sim rad !!!important 🤬
	k2 = Vector3.new(5, 5, 5),
	k3 = Color3.fromRGB(255, 105, 180),
	k4 = math.huge,
	k5 = { "NoAttract", "Character" },
	k6 = "Celestial Ribbon",
	k7 = 4,
	k8 = 0.8,
	k9 = 80,
	k10 = 20,
	k11 = 2,
	k12 = 100,
	k13 = 10,
	k14 = 5,
	k15 = 10,
	k16 = 0.6,
	k17 = 150,
	Tgt = nil,
	ImpactManual = false,
	IsLaunching = false,
	Disabled = false,
	TgtActive = false,
	PI_All = false,
	AnchorSelf = false,
	AntiFling = false,
	Paused = false,
	Damping = 0.5,
	Ki = 0.1,
	MaxSpeed = 500,
	AngularDamping = 0.5,
	VerticalStiffness = 1.0,
}
local x2 = {
	["Big Ring Things"] = { k12 = 100, k13 = 10, k14 = 5, k16 = 0.6, k15 = 10, k11 = 2, k17 = 150, k23 = false },
	["Celestial Ribbon"] = {
		k12 = 0,
		k13 = 15,
		k14 = 30,
		k16 = 0.4,
		k11 = 1,
		k17 = 150,
		k18 = false,
		k19 = false,
		k23 = false,
	},
	["Hollow Worm"] = { k12 = 0, k13 = 15, k14 = 35, k16 = 0.4, k15 = 10, k11 = 15, k17 = 150, k23 = false },
	["Cosmic Comet"] = { k12 = 50, k13 = 20, k14 = 20, k16 = 0.5, k15 = 5, k11 = 5, k17 = 150, k23 = false },
	["Point Impact"] = { k12 = 0, k13 = 500, k14 = 0, k16 = 0, k15 = 0, k11 = 0, k17 = 50, k23 = false },
	["Orbital Shell"] = {
		k11 = 90,
		k12 = 0,
		k13 = 15,
		k14 = 0,
		k15 = 0,
		k16 = 0,
		k17 = 150,
		k23 = false,
		k18 = false,
		k19 = false,
	},

	["Vortex Funnel"] = { k11 = 50, k12 = 300, k13 = 30, k14 = 400, k15 = 5, k16 = 0, k17 = 400, k23 = false },
	["Quantum Atoms"] = { k11 = 60, k12 = 0, k13 = 15, k14 = 0, k15 = 3, k16 = 0, k17 = 150, k23 = false },
	["Halo Ring"] = { k11 = 40, k12 = 0, k13 = 5, k14 = 80, k15 = 0, k16 = 0, k17 = 50, k23 = false },
	["Slingshot"] = { k11 = 50, k12 = 3, k13 = 100, k14 = 0, k15 = 5, k16 = 0, k17 = 100, k23 = false },
	["Gods Call"] = { k11 = 10, k12 = 0, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 50, k23 = false },
	["Deflect"] = { k11 = 50, k12 = 500, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 50, k23 = false },
	["Shield Wall"] = { k11 = 20, k12 = 25, k13 = 20, k14 = 50, k15 = 10, k16 = 0, k17 = 50, k23 = false },
	["Sculptor"] = { k11 = 0, k12 = 0, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Torus Knot"] = { k11 = 3, k12 = 2, k13 = 10, k14 = 50, k15 = 20, k16 = 0, k17 = 0, k23 = false },
	["Möbius Strip"] = { k11 = 50, k12 = 20, k13 = 15, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["DNA Helix"] = { k11 = 20, k12 = 80, k13 = 10, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Black Hole"] = { k11 = 40, k12 = 100, k13 = 15, k14 = 50, k15 = 5, k16 = 0, k17 = 0, k23 = false },
	["Tesseract"] = { k11 = 40, k12 = 80, k13 = 10, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Klein Bottle"] = { k11 = 60, k12 = 20, k13 = 20, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Space Station"] = { k11 = 80, k12 = 30, k13 = 10, k14 = 150, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Supernova"] = { k11 = 15, k12 = 100, k13 = 25, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Dyson Sphere"] = { k11 = 150, k12 = 8, k13 = 10, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Seraphim"] = { k11 = 80, k12 = 4, k13 = 15, k14 = 40, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Alien Mothership"] = { k11 = 120, k12 = 40, k13 = 15, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Quantum Core"] = { k11 = 100, k12 = 30, k13 = 40, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Galactic Web"] = { k11 = 400, k12 = 10, k13 = 5, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false, k24 = 200 },
	["Meteor Shower"] = { k11 = 500, k12 = 300, k13 = 150, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["World Serpent"] = { k11 = 400, k12 = 100, k13 = 20, k14 = 20, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Aurora Borealis"] = { k11 = 600, k12 = 300, k13 = 15, k14 = 100, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Arcane Orrery"] = { k11 = 120, k12 = 4, k13 = 8, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Maelstrom Spire"] = { k11 = 30, k12 = 200, k13 = 15, k14 = 6, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Eldritch Binding"] = { k11 = 100, k12 = 200, k13 = 5, k14 = 8, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Graviton Engine"] = { k11 = 4, k12 = 60, k13 = 12, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Fractal Web"] = { k11 = 40, k12 = 3, k13 = 3, k14 = 5, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	["Leviathan Coil"] = { k11 = 50, k12 = 15, k13 = 8, k14 = 250, k15 = 0, k16 = 0, k17 = 0, k23 = false },
}
x1.S = x2

local favorites = {}
local function save_favs()
	if writefile then
		pcall(function()
			writefile("GravityFavorites.json", HttpService:JSONEncode(favorites))
		end)
	end
end
local function load_favs()
	if isfile and isfile("GravityFavorites.json") then
		pcall(function()
			favorites = HttpService:JSONDecode(readfile("GravityFavorites.json"))
		end)
	end
end
load_favs()

-- Persistent Storage Logic
local function sanitize(t)
	local res = {}
	for k, v in pairs(t) do
		if typeof(v) == "Vector3" then
			res[k] = { __type = "Vector3", x = v.X, y = v.Y, z = v.Z }
		elseif typeof(v) == "Color3" then
			res[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
		elseif typeof(v) == "number" then
			if v == math.huge then
				res[k] = { __type = "inf" }
			elseif v == -math.huge then
				res[k] = { __type = "-inf" }
			else
				res[k] = v
			end
		elseif typeof(v) == "table" then
			res[k] = sanitize(v)
		elseif typeof(v) == "Instance" or typeof(v) == "function" or typeof(v) == "userdata" then
			-- skip
		else
			res[k] = v
		end
	end
	return res
end

local function desanitize(t)
	local res = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			if v.__type == "Vector3" then
				res[k] = Vector3.new(v.x, v.y, v.z)
			elseif v.__type == "Color3" then
				res[k] = Color3.new(v.r, v.g, v.b)
			elseif v.__type == "inf" then
				res[k] = math.huge
			elseif v.__type == "-inf" then
				res[k] = -math.huge
			else
				res[k] = desanitize(v)
			end
		else
			res[k] = v
		end
	end
	return res
end

function save_settings()
	if not writefile then
		return
	end
	local data = { x1 = sanitize(x1), x2 = sanitize(x2) }
	data.x1.Tgt = nil
	data.x1.IsLaunching = nil
	local success, json = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	if success then
		writefile("GravitySettings_Auto.json", json)
	end
end

function load_settings()
	if isfile and isfile("GravitySettings_Auto.json") then
		local json = readfile("GravitySettings_Auto.json")
		local success, data = pcall(function()
			return HttpService:JSONDecode(json)
		end)
		if success and data then
			local cx1 = desanitize(data.x1)
			local cx2 = desanitize(data.x2)
			for k, v in pairs(cx1) do
				if x1[k] ~= nil and typeof(x1[k]) == typeof(v) then
					x1[k] = v
				end
			end
			for mk, mv in pairs(cx2) do
				if x2[mk] then
					for sk, sv in pairs(mv) do
						x2[mk][sk] = sv
					end
				end
			end
		end
	end
end

-- Load settings immediately on execution
load_settings()
local function x3()
	return x1.S[x1.k6] or {}
end
local x4, x5 = {}, {}
local x6 = {
	b = nil,
	c = {},
	a = {},
	o = false,
	d = false,
	p = 0,
	f = 0,
	n = 0,
	pi_targets = {},
	pi_timer = 0,
	ex_nodes = {},
	ex_timer = 0,
	esp_timer = 0,
	claim_queue = {},
	active_array = {},
	pre = {},
	pre_buffer = table.create(200),
	-- Sculptor mode state
	sculptor_selected = {},
	sculptor_dragging = false,
	sculptor_drag_start = nil,
	sculptor_box_start = nil,
	sculptor_box = nil,
	sculptor_highlights = {},
	sculptor_preset_ui = nil,
}

local function px(md, t, c)
	if not x6.pre[md] then
		x6.pre[md] = table.create(200)
	end
	local r = x6.pre[md]
	table.clear(r)
	local res = 200
	if md == "Celestial Ribbon" then
		local s, w, h, l = (c.k13 or 10) * x9.c2, (c.k11 or 8), c.k14 or 50, (c.k16 or x9.c5) * 100
		local R = (c.k17 or 150)
		for i = 1, res do
			local pc = (i - 1) / (res - 1)
			local ph = (t * s) - (pc * (l * x9.c2))
			local px, pz, py = math.cos(ph) * R, math.sin(ph * 1.618) * R, math.sin(ph * 0.577) * h
			local T = Vector3.new(px, py, pz).Unit
			local Rv = T:Cross(Vector3.yAxis)
			if Rv.Magnitude < 0.01 then
				Rv = Vector3.xAxis
			end
			Rv = Rv.Unit
			local trn = Rv * math.cos(ph * 0.5) + (T:Cross(Rv)) * math.sin(ph * 0.5)
			r[i] = { p = Vector3.new(px, py, pz), t = trn, ph = ph }
		end
	elseif md == "Hollow Worm" then
		local s, radius, h, wf, l =
			(c.k13 or 10) * x9.c2, (c.k11 or 8), c.k14 or 50, (c.k15 or 10) * x9.c7, (c.k16 or x9.c5) * 100
		local R = (c.k17 or 150)
		for i = 1, res do
			local pc = (i - 1) / (res - 1)
			local ph = (t * s) - (pc * (l * x9.c2))
			local sx, sz, sy = math.cos(ph) * R, math.sin(ph) * R, math.sin(ph * wf) * h
			r[i] = Vector3.new(sx, sy, sz)
		end
	elseif md == "Cosmic Comet" then
		local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
		local R = (c.k17 or 150)
		for i = 1, res do
			local pc = (i - 1) / (res - 1)
			local ph = (t * s) - (pc * (l * x9.c2))
			r[i] = Vector3.new(math.cos(ph) * R, math.sin(ph * (c.k15 or 5) * x9.c7) * h, math.sin(ph) * R)
		end
	elseif md == "Orbital Shell" then
		local s = (c.k13 or 10) * x9.c2
		local ph = t * s
		r[1] = { ca = math.cos(ph), sa = math.sin(ph) }
	end
end
local x7 = {}
function x7.n(t, x, d)
	pcall(function()
		v5:SetCore("SendNotification", { Title = t, Text = x, Duration = d or 3 })
	end)
end
local EXCLUDED_NAMES = {
	Baseplate = true, HumanoidRootPart = true, Terrain = true, Handle = true,
	Head = true, Torso = true, ["Left Arm"] = true, ["Right Arm"] = true,
	["Left Leg"] = true, ["Right Leg"] = true,
	UpperTorso = true, LowerTorso = true, LeftUpperArm = true, LeftLowerArm = true,
	LeftHand = true, RightUpperArm = true, RightLowerArm = true, RightHand = true,
	LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
	RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
}
function x7.e(p)
	if not p:IsA("BasePart") then
		return true
	end
	if EXCLUDED_NAMES[p.Name] then
		return true
	end
	for _, t in ipairs(x1.k5) do
		if p:FindFirstChild(t) or (p.Parent and p.Parent:FindFirstChild(t)) then
			return true
		end
	end

	-- Check if part belongs to ANY player's character
	for _, pl in ipairs(v2:GetPlayers()) do
		if pl.Character and p:IsDescendantOf(pl.Character) then
			return true
		end
	end

	-- Robust Character Detection (Ascend tree)
	local target = p
	while target and target ~= v4 and target ~= game do
		if
			target:IsA("Model")
			and (target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("AnimationController"))
		then
			return true
		end
		if target:IsA("Accessory") or target:IsA("Tool") then
			return true
		end
		target = target.Parent
	end

	if p.Anchored then
		return true
	end
	return false
end
x5.g = nil
function x5.s(p, t, mn, mx, df, cb)
	df = df or mn
	local f = Instance.new("Frame", p)
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 42)
	
	local l = Instance.new("TextLabel", f)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, 20)
	l.Text = t
	l.TextColor3 = Color3.fromRGB(180, 180, 180)
	l.TextXAlignment = 0
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	
	local vl = Instance.new("TextLabel", f)
	vl.BackgroundTransparency = 1
	vl.Position = UDim2.new(1, -50, 0, 0)
	vl.Size = UDim2.new(0, 50, 0, 20)
	vl.Text = tostring(df)
	vl.TextColor3 = Color3.fromRGB(255, 255, 255)
	vl.TextXAlignment = 1
	vl.Font = Enum.Font.GothamBold
	vl.TextSize = 12
	
	local sc = Instance.new("Frame", f)
	sc.BackgroundTransparency = 1
	sc.Position = UDim2.new(0, 0, 0, 26)
	sc.Size = UDim2.new(1, 0, 0, 4)
	
	local sb = Instance.new("Frame", sc)
	sb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	sb.BorderSizePixel = 0
	sb.Size = UDim2.new(1, 0, 1, 0)
	Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
	
	local fl = Instance.new("Frame", sb)
	fl.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Pure white accent for modern look
	fl.BorderSizePixel = 0
	df = df or 0
	fl.Size = UDim2.new((df - mn) / (mx - mn), 0, 1, 0)
	Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
	
	local k = Instance.new("ImageButton", sc)
	k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	k.AnchorPoint = Vector2.new(0.5, 0.5)
	k.Position = UDim2.new((df - mn) / (mx - mn), 0, 0.5, 0)
	k.Size = UDim2.new(0, 12, 0, 12)
	k.BorderSizePixel = 0
	k.AutoButtonColor = false
	Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
	
	local d = false
	local function u(i)
		local pos = i.Position.X
		local rp = pos - sc.AbsolutePosition.X
		local pc = math.clamp(rp / sc.AbsoluteSize.X, 0, 1)
		local v = mn + (mx - mn) * pc
		if mx - mn > 50 then
			v = math.floor(v + 0.5)
		else
			v = math.floor(v * 10 + 0.5) / 10
		end
		v6:Create(fl, TweenInfo.new(0.1), { Size = UDim2.new(pc, 0, 1, 0) }):Play()
		v6:Create(k, TweenInfo.new(0.1), { Position = UDim2.new(pc, 0, 0.5, 0) }):Play()
		vl.Text = tostring(v)
		cb(v)
		if save_settings then
			save_settings()
		end
	end
	
	k.MouseButton1Down:Connect(function() d = true end)
	sb.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			d = true
			u(i)
		end
	end)
	v1.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
	v1.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then u(i) end end)
end

function x5.t(p, t, df, cb)
	local f = Instance.new("Frame", p)
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 32)
	
	local l = Instance.new("TextLabel", f)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(0.8, 0, 1, 0)
	l.Text = t
	l.TextColor3 = Color3.fromRGB(180, 180, 180)
	l.TextXAlignment = 0
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	
	local bg = Instance.new("Frame", f)
	bg.BackgroundColor3 = df and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(40, 40, 45)
	bg.Position = UDim2.new(1, -36, 0.5, -9)
	bg.Size = UDim2.new(0, 36, 0, 18)
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
	
	local toggle = Instance.new("Frame", bg)
	toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Position = df and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	toggle.Size = UDim2.new(0, 14, 0, 14)
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
	
	local b = Instance.new("TextButton", f)
	b.BackgroundTransparency = 1
	b.Size = UDim2.new(1, 0, 1, 0)
	b.Text = ""
	
	b.MouseButton1Click:Connect(function()
		df = not df
		v6:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = df and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(40, 40, 45)}):Play()
		v6:Create(toggle, TweenInfo.new(0.2), {Position = df and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
		cb(df)
		if save_settings then save_settings() end
	end)
	return b
end

function x5.b(p, t, cb)
	local b = Instance.new("TextButton", p)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	b.Size = UDim2.new(1, 0, 0, 34)
	b.AutoButtonColor = false
	b.Text = t
	b.TextColor3 = Color3.fromRGB(220, 220, 220)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	
	local str = Instance.new("UIStroke", b)
	str.Color = Color3.fromRGB(50, 50, 55)
	str.Thickness = 1
	
	b.MouseEnter:Connect(function()
		v6:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	b.MouseLeave:Connect(function()
		v6:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
	end)
	
	b.MouseButton1Click:Connect(function() cb(b) end)
	return b
end

function x5.h(p, t)
	local l = Instance.new("TextLabel", p)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, 24)
	l.Text = t:upper()
	l.TextColor3 = Color3.fromRGB(100, 100, 110)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
end

function x5.st()
	if x5.g and x5.up then
		x5.up()
		return
	end
	if x5.g then
		x5.g:Destroy()
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "G_" .. math.random(999)
	if gethui then
		sg.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(sg)
		sg.Parent = game:GetService("CoreGui")
	else
		sg.Parent = v8:WaitForChild("PlayerGui")
	end
	x6.sg = sg
	x5.g = sg
	x5.mw(sg)
end
function x5.mw(sg)
	-- Status HUD (Simplified & Sleek)
	local hud = Instance.new("Frame", sg)
	hud.Name = "StatusHUD"
	hud.BackgroundTransparency = 1
	hud.Position = UDim2.new(0.5, -200, 0, 20)
	hud.Size = UDim2.new(0, 400, 0, 30)
	
	local hud_l = Instance.new("TextLabel", hud)
	hud_l.BackgroundTransparency = 1
	hud_l.Size = UDim2.new(1, 0, 1, 0)
	hud_l.Font = Enum.Font.GothamBold
	hud_l.TextSize = 14
	hud_l.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	table.insert(x6.c, v3.RenderStepped:Connect(function()
		if not x5.g then return end
		local tgt = x1.Tgt and (x1.Tgt.DisplayName or x1.Tgt.Name) or "None"
		local state = x1.Disabled and "DISABLED" or (x1.Paused and "PAUSED" or "ACTIVE")
		local col = x1.Disabled and Color3.fromRGB(255, 80, 80) or (x1.Paused and Color3.fromRGB(255, 180, 80) or Color3.fromRGB(80, 255, 150))
		hud_l.Text = string.format("TARGET: %s  |  STATUS: %s", tgt:upper(), state)
		hud_l.TextColor3 = col
	end))

	local m = Instance.new("Frame", sg)
	m.Name = "Main"
	m.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	m.Position = UDim2.new(0, 30, 0.5, -250)
	m.Size = UDim2.new(0, 320, 0, 500)
	m.Active = true
	m.Draggable = true
	Instance.new("UICorner", m).CornerRadius = UDim.new(0, 10)
	local ms = Instance.new("UIStroke", m)
	ms.Color = Color3.fromRGB(40, 40, 45)
	ms.Thickness = 1

	local h = Instance.new("Frame", m)
	h.BackgroundTransparency = 1
	h.Size = UDim2.new(1, 0, 0, 50)
	
	local t = Instance.new("TextLabel", h)
	t.BackgroundTransparency = 1
	t.Position = UDim2.new(0, 20, 0, 0)
	t.Size = UDim2.new(0.6, 0, 1, 0)
	t.Text = "PROJECT GRAVITY"
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.GothamBlack
	t.TextSize = 16
	t.TextXAlignment = 0

	local c = Instance.new("ScrollingFrame", m)
	c.BackgroundTransparency = 1
	c.Position = UDim2.new(0, 0, 0, 60)
	c.Size = UDim2.new(1, 0, 1, -70)
	c.ScrollBarThickness = 0
	c.AutomaticCanvasSize = Enum.AutomaticSize.Y
	c.CanvasSize = UDim2.new(0, 0, 0, 0)
	local l = Instance.new("UIListLayout", c)
	l.Padding = UDim.new(0, 12)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local p = Instance.new("UIPadding", c)
	p.PaddingLeft = UDim.new(0, 20)
	p.PaddingRight = UDim.new(0, 20)
	p.PaddingBottom = UDim.new(0, 20)

	local am = Instance.new("Frame", sg)
	am.Name = "Advanced"
	am.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	am.Position = UDim2.new(0, 360, 0.5, -200)
	am.Size = UDim2.new(0, 260, 0, 380)
	am.Visible = false
	am.Active = true
	am.Draggable = true
	Instance.new("UICorner", am).CornerRadius = UDim.new(0, 10)
	local ams = Instance.new("UIStroke", am)
	ams.Color = Color3.fromRGB(40, 40, 45)
	ams.Thickness = 1

	local ah = Instance.new("Frame", am)
	ah.BackgroundTransparency = 1
	ah.Size = UDim2.new(1, 0, 0, 50)
	local at = Instance.new("TextLabel", ah)
	at.BackgroundTransparency = 1
	at.Position = UDim2.new(0, 20, 0, 0)
	at.Size = UDim2.new(0.6, 0, 1, 0)
	at.Text = "ADVANCED"
	at.TextColor3 = Color3.fromRGB(255, 255, 255)
	at.Font = Enum.Font.GothamBold
	at.TextSize = 14
	at.TextXAlignment = 0

	local ac = Instance.new("ScrollingFrame", am)
	ac.BackgroundTransparency = 1
	ac.Position = UDim2.new(0, 0, 0, 50)
	ac.Size = UDim2.new(1, 0, 1, -60)
	ac.ScrollBarThickness = 0
	ac.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ac.CanvasSize = UDim2.new(0, 0, 0, 0)
	local acl = Instance.new("UIListLayout", ac)
	acl.Padding = UDim.new(0, 10)
	acl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local ap = Instance.new("UIPadding", ac)
	ap.PaddingLeft = UDim.new(0, 20)
	ap.PaddingRight = UDim.new(0, 20)

	x5.s(ac, "Damping", 0, 5, x1.Damping, function(v)
		x1.Damping = v
		save_settings()
	end)
	x5.s(ac, "Integral Gain", 0, 10, x1.Ki, function(v)
		x1.Ki = v
		save_settings()
	end)
	x5.s(ac, "Max Speed", 50, 2000, x1.MaxSpeed or 500, function(v)
		x1.MaxSpeed = v
		save_settings()
	end)
	x5.s(ac, "Angular Damp", 0, 1, x1.AngularDamping or 0.5, function(v)
		x1.AngularDamping = v
		save_settings()
	end)
	x5.s(ac, "Vert Stiffness", 0.1, 5, x1.VerticalStiffness or 1.0, function(v)
		x1.VerticalStiffness = v
		save_settings()
	end)

	local ab = x5.b(c, "Advanced Settings", function()
		am.Visible = not am.Visible
	end)
	ab.Size = UDim2.new(1, 0, 0, 36)
	
	-- Mode Display
	local mode_f = Instance.new("Frame", c)
	mode_f.BackgroundTransparency = 1
	mode_f.Size = UDim2.new(1, 0, 0, 44)
	local db = Instance.new("TextButton", mode_f)
	db.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	db.Size = UDim2.new(1, 0, 1, 0)
	db.Text = "  " .. x1.k6:upper()
	db.TextColor3 = Color3.fromRGB(255, 255, 255)
	db.Font = Enum.Font.GothamBold
	db.TextSize = 13
	db.TextXAlignment = 0
	Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)
	local dst = Instance.new("UIStroke", db)
	dst.Color = Color3.fromRGB(40, 40, 45)
	
	local arr = Instance.new("TextLabel", db)
	arr.BackgroundTransparency = 1
	arr.Position = UDim2.new(1, -30, 0, 0)
	arr.Size = UDim2.new(0, 30, 1, 0)
	arr.Text = "▼"
	arr.TextColor3 = Color3.fromRGB(150, 150, 160)
	arr.TextSize = 10

	db.MouseButton1Click:Connect(function()
		if x6.dlst_container then
			x6.dlst_container.Visible = not x6.dlst_container.Visible
			if x6.dlst_container.Visible and x6.populate_modes then
				x6.populate_modes("")
			end
		end
	end)

	local gsc = Instance.new("Frame", c)
	gsc.BackgroundTransparency = 1
	gsc.Size = UDim2.new(1, 0, 0, 0)
	gsc.AutomaticSize = Enum.AutomaticSize.Y
	local gscl = Instance.new("UIListLayout", gsc)
	gscl.Padding = UDim.new(0, 8)
	gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local sc = Instance.new("Frame", c)
	sc.BackgroundTransparency = 1
	sc.Size = UDim2.new(1, 0, 0, 0)
	sc.AutomaticSize = Enum.AutomaticSize.Y
	local scl = Instance.new("UIListLayout", sc)
	scl.Padding = UDim.new(0, 8)
	scl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local function f1()
		sc:ClearAllChildren()
		gsc:ClearAllChildren()
		local gscl = Instance.new("UIListLayout", gsc)
		gscl.Padding = UDim.new(0, 10)
		gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local scl = Instance.new("UIListLayout", sc)
		scl.Padding = UDim.new(0, 10)
		scl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local s = x3()
		
		x5.h(gsc, "Control")
		x5.t(gsc, "Simplified Interface", x1.SimpleMode, function(v)
			x1.SimpleMode = v
			save_settings()
			f1() -- Refresh to show/hide shits
		end)
		
		x5.t(gsc, "Anchor to Self", x1.AnchorSelf, function(v)
			x1.AnchorSelf = v
			save_settings()
		end)

		if not x1.SimpleMode then
			x5.t(gsc, "Anti-Fling", x1.AntiFling, function(v)
				x1.AntiFling = v
				save_settings()
			end)
		end

		x6.disable_btn = x5.t(gsc, "Disable Gravity", x1.Disabled, function(v)
			x1.Disabled = v
			save_settings()
			if x6.b then
				x6.b.Transparency = v and 1 or 0.8
				if x6.b:FindFirstChild("Visual") then x6.b.Visual.Enabled = not v end
			end
			for _, d in pairs(x6.a) do
				if d.lv then d.lv.MaxForce = v and 0 or x1.k4 end
			end
		end)

		if not x1.SimpleMode then
			x5.t(gsc, "Target Everyone", x1.PI_All, function(v)
				x1.PI_All = v
				save_settings()
			end)
		end

		local l_btn = Instance.new("TextButton", gsc)
		l_btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		l_btn.Size = UDim2.new(1, 0, 0, 36)
		l_btn.Text = "FORCE LAUNCH"
		l_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		l_btn.Font = Enum.Font.GothamBold
		l_btn.TextSize = 13
		Instance.new("UICorner", l_btn).CornerRadius = UDim.new(0, 6)
		l_btn.Visible = x1.ImpactManual or (x1.k6 == "Slingshot" and x1.SlingshotManual)

		l_btn.MouseButton1Click:Connect(function()
			x1.IsLaunching = not x1.IsLaunching
			l_btn.Text = x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH"
			l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(200, 50, 50)
		end)
		
		table.insert(x6.c, v3.Heartbeat:Connect(function()
			if x1.ImpactManual or (x1.k6 == "Slingshot" and x1.SlingshotManual) then
				l_btn.Visible = true
				l_btn.Text = x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH"
				l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(200, 50, 50)
			else
				l_btn.Visible = false
			end
		end))

		local tn = x1.Tgt and "Target: " .. (x1.Tgt.DisplayName or x1.Tgt.Name) or "Select Target"
		
		local tdb = Instance.new("TextButton", gsc)
		tdb.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		tdb.Size = UDim2.new(1, 0, 0, 38)
		tdb.Text = "  " .. tn:upper()
		tdb.TextColor3 = Color3.fromRGB(255, 255, 255)
		tdb.Font = Enum.Font.GothamBold
		tdb.TextSize = 12
		tdb.TextXAlignment = 0
		Instance.new("UICorner", tdb).CornerRadius = UDim.new(0, 6)
		local dst2 = Instance.new("UIStroke", tdb)
		dst2.Color = Color3.fromRGB(40, 40, 45)
		
		if x1.Tgt then
			local ctb = Instance.new("TextButton", tdb)
			ctb.BackgroundTransparency = 1
			ctb.Position = UDim2.new(1, -30, 0, 0)
			ctb.Size = UDim2.new(0, 30, 1, 0)
			ctb.Text = "×"
			ctb.TextColor3 = Color3.fromRGB(200, 80, 80)
			ctb.TextSize = 20
			ctb.MouseButton1Click:Connect(function()
				x1.Tgt = nil
				x1.TgtActive = false
				f1()
			end)
		end

		local tdlst = Instance.new("Frame", m)
		tdlst.Visible = false
		tdlst.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		tdlst.Position = UDim2.new(1, 15, 0, 0)
		tdlst.Size = UDim2.new(0, 220, 1, 0)
		Instance.new("UICorner", tdlst).CornerRadius = UDim.new(0, 10)
		local ts = Instance.new("UIStroke", tdlst)
		ts.Color = Color3.fromRGB(40, 40, 45)

		local search_bar = Instance.new("TextBox", tdlst)
		search_bar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		search_bar.Position = UDim2.new(0, 10, 0, 10)
		search_bar.Size = UDim2.new(1, -20, 0, 34)
		search_bar.PlaceholderText = "Search players..."
		search_bar.Text = ""
		search_bar.TextColor3 = Color3.fromRGB(255, 255, 255)
		search_bar.Font = Enum.Font.Gotham
		search_bar.TextSize = 13
		Instance.new("UICorner", search_bar).CornerRadius = UDim.new(0, 6)

		local scroll_frame = Instance.new("ScrollingFrame", tdlst)
		scroll_frame.BackgroundTransparency = 1
		scroll_frame.Position = UDim2.new(0, 0, 0, 55)
		scroll_frame.Size = UDim2.new(1, 0, 1, -65)
		scroll_frame.ScrollBarThickness = 0
		scroll_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		local tdll = Instance.new("UIListLayout", scroll_frame)
		tdll.Padding = UDim.new(0, 5)
		tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local active_highlight = nil
		local function clear_highlight()
			if active_highlight then active_highlight:Destroy() active_highlight = nil end
		end

		local function update_list(filter_text)
			clear_highlight()
			scroll_frame:ClearAllChildren()
			local tdll = Instance.new("UIListLayout", scroll_frame)
			tdll.Padding = UDim.new(0, 5)
			tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center

			for _, pl in ipairs(v2:GetPlayers()) do
				if pl == v8 then continue end
				if filter_text ~= "" and not (pl.DisplayName:lower():find(filter_text:lower()) or pl.Name:lower():find(filter_text:lower())) then continue end

				local ib = Instance.new("TextButton", scroll_frame)
				ib.Size = UDim2.new(1, -16, 0, 44)
				ib.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				ib.Text = "  " .. pl.DisplayName
				ib.TextColor3 = Color3.fromRGB(255, 255, 255)
				ib.Font = Enum.Font.GothamBold
				ib.TextSize = 12
				ib.TextXAlignment = 0
				Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 6)

				ib.MouseEnter:Connect(function()
					ib.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					if pl.Character then
						local h = Instance.new("Highlight", pl.Character)
						h.FillColor = Color3.fromRGB(255, 255, 255)
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						active_highlight = h
					end
				end)
				ib.MouseLeave:Connect(function()
					ib.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
					clear_highlight()
				end)

				ib.MouseButton1Click:Connect(function()
					x1.Tgt = pl
					x1.TgtActive = true
					tdlst.Visible = false
					f1()
				end)
			end
		end

		search_bar:GetPropertyChangedSignal("Text"):Connect(function() update_list(search_bar.Text) end)
		tdb.MouseButton1Click:Connect(function()
			tdlst.Visible = not tdlst.Visible
			if tdlst.Visible then update_list("") end
		end)

		if not x1.SimpleMode then
		x5.h(sc, "Shape")
		if x1.k6 == "Big Ring Things" then

			x5.s(sc, "Ring Count", 1, 20, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Ring Gap", 50, 300, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Ring Speed", 0, 200, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Height Offset", 0, 100, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "Tilt Angle", 0, 90, s.k15, function(v)
				s.k15 = v
			end)
			x5.s(sc, "Tilt Speed", 0, 50, s.k16 * 10, function(v)
				s.k16 = v / 10
			end)
		elseif x1.k6 == "Celestial Ribbon" then
			x5.s(sc, "Ribbon Speed", 1, 300, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Ribbon Length", 10, 500, s.k16 * 100, function(v)
				s.k16 = v / 100
			end)
			x5.s(sc, "Ribbon Width", 1, 150, s.k11 * 2, function(v)
				s.k11 = v / 2
			end)
			x5.s(sc, "Height Limit", 0, 200, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "Move Area", 50, 800, s.k17, function(v)
				s.k17 = v
			end)
			x5.t(sc, "Enable Slither", s.k18, function(v)
				s.k18 = v
			end)
			x5.t(sc, "Dual Dragons", s.k19, function(v)
				s.k19 = v
			end)
		elseif x1.k6 == "Hollow Worm" then
			x5.s(sc, "Worm Speed", 1, 300, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Worm Length", 10, 500, s.k16 * 100, function(v)
				s.k16 = v / 100
			end)
			x5.s(sc, "Tube Radius", 1, 100, s.k11 * 2, function(v)
				s.k11 = v / 2
			end)
			x5.s(sc, "Height Limit", 0, 200, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "Wavelength", 1, 50, s.k15, function(v)
				s.k15 = v
			end)
			x5.s(sc, "Move Area", 50, 800, s.k17, function(v)
				s.k17 = v
			end)
		elseif x1.k6 == "Cosmic Comet" then
			x5.s(sc, "Comet Speed", 1, 300, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Tail Length", 10, 500, s.k16 * 100, function(v)
				s.k16 = v / 100
			end)
			x5.s(sc, "Head Radius", 1, 50, s.k11 * 2, function(v)
				s.k11 = v / 2
			end)
			x5.s(sc, "Tail Spread", 0, 200, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Height Limit", 0, 200, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "Move Area", 50, 800, s.k17, function(v)
				s.k17 = v
			end)
		elseif x1.k6 == "Point Impact" then
			x5.s(sc, "Spin Speed", 1, 500, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Closeness", 1, 50, s.k11 * 2, function(v)
				s.k11 = v / 2
			end)
			x5.s(sc, "Move Area", 50, 800, s.k17, function(v)
				s.k17 = v
			end)
		elseif x1.k6 == "Orbital Shell" then
			x5.s(sc, "Spin Speed", 1, 300, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Shell Radius", 50, 1000, s.k11, function(v)
				s.k11 = v
			end)
			x5.t(sc, "Cut in Half", s.k18, function(v)
				s.k18 = v
			end)
			x5.t(sc, "Stable Flow", s.k19, function(v)
				s.k19 = v
			end)
			x5.s(sc, "Move Area", 50, 1500, s.k17, function(v)
				s.k17 = v
			end)
		elseif x1.k6 == "Vortex Funnel" then
			x5.s(sc, "Swirl Speed", 1, 300, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Base Radius", 10, 300, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Top Radius", 50, 1000, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Funnel Height", 50, 1000, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "Suction Power", 1, 20, s.k15, function(v)
				s.k15 = v
			end)
			x5.s(sc, "Move Area", 50, 1500, s.k17, function(v)
				s.k17 = v
			end)
		elseif x1.k6 == "Quantum Atoms" then
			x5.s(sc, "Orbit Speed", 1, 300, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Atom Radius", 20, 500, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Orbit Count", 1, 10, s.k15, function(v)
				s.k15 = v
			end)
			x5.s(sc, "Move Area", 50, 800, s.k17, function(v)
				s.k17 = v
			end)
		elseif x1.k6 == "Halo Ring" then
			x5.s(sc, "Spin Speed", 0, 200, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Halo Radius", 20, 300, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Height Offset", 20, 200, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Slingshot" then
			x5.s(sc, "Charge Dist", 10, 200, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Cycle Time", 1, 10, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Fling Speed", 1, 500, s.k13, function(v)
				s.k13 = v
			end)
			x5.t(sc, "Manual Fire", x1.SlingshotManual, function(v)
				x1.SlingshotManual = v
				x1.IsLaunching = false
			end)
		elseif x1.k6 == "Gods Call" then
			x5.s(sc, "Ascent Speed", 1, 100, s.k11, function(v)
				s.k11 = v
			end)
		elseif x1.k6 == "Deflect" then
			x5.s(sc, "Range", 10, 500, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Force", 50, 5000, s.k12, function(v)
				s.k12 = v
			end)
		elseif x1.k6 == "Shield Wall" then
			x5.s(sc, "Spin Speed", 1, 200, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Width", 1, 200, s.k11 * 10, function(v)
				s.k11 = v / 10
			end)
			x5.s(sc, "Height", 1, 50, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Distance", 5, 100, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "H-Offset", -50, 50, s.k15, function(v)
				s.k15 = v
			end)
		elseif x1.k6 == "Torus Knot" then
			x5.s(sc, "P Knot", 1, 10, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Q Knot", 1, 10, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Radius", 10, 300, s.k14, function(v)
				s.k14 = v
			end)
			x5.s(sc, "Tube Size", 5, 100, s.k15, function(v)
				s.k15 = v
			end)
		elseif x1.k6 == "Möbius Strip" then
			x5.s(sc, "Radius", 10, 300, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Width", 5, 200, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
		elseif x1.k6 == "DNA Helix" then
			x5.s(sc, "Radius", 5, 200, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Height", 10, 500, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Frequency", 10, 200, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Black Hole" then
			x5.s(sc, "Event Horizon", 10, 200, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Disk Radius", 50, 2000, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Spin Speed", 1, 200, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Disk Height", 5, 200, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Tesseract" then
			x5.s(sc, "Inner Size", 10, 200, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Outer Size", 20, 400, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Rotation Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
		elseif x1.k6 == "Klein Bottle" then
			x5.s(sc, "Radius", 10, 300, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Flow Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
		elseif x1.k6 == "Space Station" then
			x5.s(sc, "Ring Radius", 20, 400, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Ring Thickness", 5, 100, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Orbit Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Spindle Length", 20, 500, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Supernova" then
			x5.s(sc, "Core Radius", 5, 100, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Blast Radius", 50, 800, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Pulse Speed", 1, 200, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
		elseif x1.k6 == "Dyson Sphere" then
			x5.s(sc, "Radius", 50, 400, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Grid Density", 2, 50, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
		elseif x1.k6 == "Seraphim" then
			x5.s(sc, "Radius", 20, 200, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Ring Count", 1, 10, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Wingspan", 10, 150, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Alien Mothership" then
			x5.s(sc, "Radius", 50, 400, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Core Height", 10, 150, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Beam Length", 50, 500, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Quantum Core" then
			x5.s(sc, "Ring Radius", 50, 400, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Ring Thickness", 10, 100, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Spin Speed", 1, 200, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Core Volatility", 10, 200, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Galactic Web" then
			x5.s(sc, "Radius Spread", 50, 1500, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Spin Speed", 1, 100, s.k12 * 10, function(v)
				s.k12 = v / 10
			end)
			x5.s(sc, "Drift Speed", 1, 50, s.k13, function(v)
				s.k13 = v
			end)
			x5.t(sc, "Cut In Half", s.k23, function(v)
				s.k23 = v
			end)
			x5.s(sc, "Web Height Limit", 0, 1500, s.k24, function(v)
				s.k24 = v
				save_settings()
			end)
		elseif x1.k6 == "Meteor Shower" then
			x5.s(sc, "XZ Spread", 100, 1500, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Spawn Height", 50, 1500, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Fall Speed", 50, 2000, s.k13, function(v)
				s.k13 = v
			end)
		elseif x1.k6 == "World Serpent" then
			x5.s(sc, "Snake Length", 100, 2000, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Wave Height", 10, 500, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Move Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Frequency", 10, 200, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Aurora Borealis" then
			x5.s(sc, "Sky Span", 100, 2000, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Sky Height", 50, 1500, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Flow Speed", 1, 100, s.k13 * 10, function(v)
				s.k13 = v / 10
			end)
			x5.s(sc, "Band Width", 50, 500, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Arcane Orrery" then
			x5.s(sc, "Orrery Radius", 40, 300, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Arm Count", 2, 8, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Spin Speed", 1, 50, s.k13, function(v)
				s.k13 = v
			end)
			x5.s(sc, "Height", 50, 500, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Maelstrom Spire" then
			x5.s(sc, "Base Radius", 10, 150, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Tower Height", 50, 500, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Vortex Speed", 1, 50, s.k13, function(v)
				s.k13 = v
			end)
			x5.s(sc, "Jet Count", 3, 12, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Eldritch Binding" then
			x5.s(sc, "Sigil Radius", 30, 250, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Tower Height", 50, 500, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Rotation Speed", 1, 30, s.k13, function(v)
				s.k13 = v
			end)
			x5.s(sc, "Tendril Count", 3, 16, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Graviton Engine" then
			x5.s(sc, "Turbine Count", 2, 8, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Radius", 20, 200, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Spin Speed", 1, 50, s.k13, function(v)
				s.k13 = v
			end)
			x5.s(sc, "Tower Height", 50, 500, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Fractal Web" then
			x5.s(sc, "Hex Radius", 15, 120, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Depth", 2, 4, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Breath Speed", 1, 20, s.k13, function(v)
				s.k13 = v
			end)
			x5.s(sc, "Rotation Speed", 1, 30, s.k14, function(v)
				s.k14 = v
			end)
		elseif x1.k6 == "Leviathan Coil" then
			x5.s(sc, "Coil Radius", 15, 150, s.k11, function(v)
				s.k11 = v
			end)
			x5.s(sc, "Body Thickness", 5, 50, s.k12, function(v)
				s.k12 = v
			end)
			x5.s(sc, "Coil Speed", 1, 30, s.k13, function(v)
				s.k13 = v
			end)
			x5.s(sc, "Tower Height", 50, 500, s.k14, function(v)
				s.k14 = v
			end)
		end
		end -- end SimpleMode check for Shape section
	end
	x5.up = f1
	-- Modernized mode list
	local dlst_container = Instance.new("Frame", m)
	dlst_container.Name = "ModeSelector"
	dlst_container.Visible = false
	dlst_container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	dlst_container.Position = UDim2.new(1, 15, 0, 0)
	dlst_container.Size = UDim2.new(0, 220, 1, 0)
	Instance.new("UICorner", dlst_container).CornerRadius = UDim.new(0, 10)
	local dls = Instance.new("UIStroke", dlst_container)
	dls.Color = Color3.fromRGB(40, 40, 45)
	
	local msb = Instance.new("TextBox", dlst_container)
	msb.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	msb.Position = UDim2.new(0, 10, 0, 10)
	msb.Size = UDim2.new(1, -20, 0, 34)
	msb.PlaceholderText = "Search modes..."
	msb.Text = ""
	msb.TextColor3 = Color3.fromRGB(255, 255, 255)
	msb.Font = Enum.Font.Gotham
	msb.TextSize = 13
	Instance.new("UICorner", msb).CornerRadius = UDim.new(0, 6)

	local dlst = Instance.new("ScrollingFrame", dlst_container)
	dlst.BackgroundTransparency = 1
	dlst.Position = UDim2.new(0, 0, 0, 55)
	dlst.Size = UDim2.new(1, 0, 1, -65)
	dlst.ScrollBarThickness = 0
	dlst.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dlst.CanvasSize = UDim2.new(0, 0, 0, 0)

	x6.dlst_container = dlst_container

	local function populate_modes(filter)
		dlst:ClearAllChildren()
		local dll = Instance.new("UIListLayout", dlst)
		dll.Padding = UDim.new(0, 5)
		dll.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local modes = { "Big Ring Things", "Celestial Ribbon", "Hollow Worm", "Cosmic Comet", "Point Impact", "Orbital Shell", "Vortex Funnel", "Quantum Atoms", "Halo Ring", "Slingshot", "Gods Call", "Deflect", "Shield Wall", "Sculptor", "Torus Knot", "Möbius Strip", "DNA Helix", "Black Hole", "Tesseract", "Klein Bottle", "Space Station", "Supernova", "Dyson Sphere", "Seraphim", "Alien Mothership", "Quantum Core", "Galactic Web", "Meteor Shower", "World Serpent", "Aurora Borealis", "Arcane Orrery", "Maelstrom Spire", "Eldritch Binding", "Graviton Engine", "Fractal Web", "Leviathan Coil" }

		table.sort(modes, function(a, b)
			local fa, fb = favorites[a] and 1 or 0, favorites[b] and 1 or 0
			if fa ~= fb then
				return fa > fb
			end
			return a < b
		end)

		for _, mn in ipairs(modes) do
			if filter ~= "" and not mn:lower():find(filter:lower()) then continue end

			local f = Instance.new("Frame", dlst)
			f.Size = UDim2.new(1, -16, 0, 40)
			f.BackgroundColor3 = mn == x1.k6 and Color3.fromRGB(40, 40, 180) or Color3.fromRGB(25, 25, 30)
			Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

			local ib = Instance.new("TextButton", f)
			ib.Size = UDim2.new(1, -40, 1, 0)
			ib.BackgroundTransparency = 1
			ib.Text = "  " .. mn
			ib.TextColor3 = Color3.fromRGB(255, 255, 255)
			ib.Font = Enum.Font.GothamBold
			ib.TextSize = 12
			ib.TextXAlignment = 0

			local sb = Instance.new("TextButton", f)
			sb.Position = UDim2.new(1, -35, 0, 0)
			sb.Size = UDim2.new(0, 35, 1, 0)
			sb.BackgroundTransparency = 1
			sb.Text = favorites[mn] and "★" or "☆"
			sb.TextColor3 = favorites[mn] and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 80, 85)
			sb.Font = Enum.Font.GothamBold
			sb.TextSize = 14

			sb.MouseButton1Click:Connect(function()
				favorites[mn] = not favorites[mn]
				save_favs()
				populate_modes(filter)
			end)

			ib.MouseButton1Click:Connect(function()
				x1.k6 = mn
				-- Clear per-part mode state so new mode re-initializes positions
				for _, d in pairs(x6.a) do
					d.v1, d.v2, d.v3, d.v4, d.v5, d.v6, d.v7, d.v8, d.v9 = nil, nil, nil, nil, nil, nil, nil, nil, nil
					d.integral = Vector3.zero
				end
				if db then db.Text = "  " .. mn:upper() end
				dlst_container.Visible = false
				save_settings()
				if x5.up then x5.up() end
			end)
		end
	end

	msb:GetPropertyChangedSignal("Text"):Connect(function()
		populate_modes(msb.Text)
	end)

	x6.populate_modes = populate_modes
	populate_modes("")


	local minb = Instance.new("TextButton", h)
	minb.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
	minb.Position = UDim2.new(1, -60, 0.5, -10)
	minb.Size = UDim2.new(0, 20, 0, 20)
	minb.Text = ""
	Instance.new("UICorner", minb).CornerRadius = UDim.new(1, 0)
	
	local closeb = Instance.new("TextButton", h)
	closeb.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeb.Position = UDim2.new(1, -30, 0.5, -10)
	closeb.Size = UDim2.new(0, 20, 0, 20)
	closeb.Text = ""
	Instance.new("UICorner", closeb).CornerRadius = UDim.new(1, 0)
	
	local im = false
	minb.MouseButton1Click:Connect(function()
		im = not im
		c.Visible = not im
		m:TweenSize(im and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 500), "Out", "Quart", 0.3, true)
	end)
	
	closeb.MouseButton1Click:Connect(function() sg:Destroy() end)
end
local function f2(p, cen, d, md, t)
	local wp, wc = p.Position, cen
	local tc = wc - wp
	if tc.Magnitude < x9.c7 then
		return Vector3.new(0, 0.01, 0)
	end
	local c = x1.S[md] or {}
	if md == "Big Ring Things" then
		local rc = c.k11 or 2
		if not d.v1 or d.v2 ~= rc then
			d.v1 = math.random(1, rc)
			d.v2 = rc
			d.v3 = math.random() * math.pi * 2
		end
		local gap, spd = c.k12 or 170, (x9.c2 - (d.v1 - 1) * x9.c3) * (c.k13 or 10)
		if d.v1 % 2 == 0 then
			spd = -spd
		end
		local a = d.v3 + (t * spd)
		local tx, tz = math.cos(a) * (x1.k9 + (d.v1 - 1) * gap), math.sin(a) * (x1.k9 + (d.v1 - 1) * gap)
		local ty = 0
		local sw = math.sin(t * (c.k16 or x9.c4) + d.v1) * math.rad(c.k15 or 12)
		local rx, rz = sw, sw * 0.5
		if rx ~= 0 then
			local cy, sy = math.cos(rx), math.sin(rx)
			local ny = ty * cy - tz * sy
			local nz = ty * sy + tz * cy
			ty, tz = ny, nz
		end
		if rz ~= 0 then
			local cx, sx = math.cos(rz), math.sin(rz)
			local nx = tx * cx - ty * sx
			local ny = tx * sx + ty * cx
			tx, ty = nx, ny
		end
		local tp = cen + Vector3.new(tx, ty, tz)
		local ho = c.k14 or 5
		if tp.Y < ho then
			tp = Vector3.new(tp.X, ho, tp.Z)
		end
		return (tp - wp) * (x1.k10 * x9.c1)
	elseif md == "Celestial Ribbon" then
		local w = c.k11 or 8
		if not d.v7 then
			d.v7 = math.random() - 0.5
			d.v6 = math.random()
		end
		if c.k19 and not d.v9 then
			d.v9 = math.random(0, 1)
		end
		local p_data = x6.pre and x6.pre[md]
		local fin
		if p_data and #p_data > 0 then
			local idx = math.floor(d.v6 * (#p_data - 1)) + 1
			local node = p_data[idx]
			fin = node.p
				+ (node.t * (d.v7 * w))
				+ (c.k18 and (node.t * math.sin(node.ph * 8)) * (w * 2.0) or Vector3.zero)
		else
			local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
			local ph = (t * s) - (d.v6 * (l * x9.c2))
			local R = (c.k17 or 150)
			local px, pz, py = math.cos(ph) * R, math.sin(ph * 1.618) * R, math.sin(ph * 0.577) * h
			local T = Vector3.new(px, py, pz).Unit
			local Rvec = T:Cross(Vector3.yAxis)
			if Rvec.Magnitude < 0.01 then
				Rvec = Vector3.xAxis
			end
			Rvec = Rvec.Unit
			local trn = Rvec * math.cos(ph * 0.5) + (T:Cross(Rvec)) * math.sin(ph * 0.5)
			fin = Vector3.new(px, py, pz)
				+ (trn * (d.v7 * w))
				+ (c.k18 and (trn * math.sin(ph * 8)) * (w * 2.0) or Vector3.zero)
		end
		if c.k19 and d.v9 == 1 then
			fin = -fin
		end
		return ((cen + fin) - wp) * (x1.k10 * x9.c1)
	elseif md == "Hollow Worm" then
		local r, wf = (c.k11 or 8), (c.k15 or 10) * x9.c7
		if not d.v4 then
			d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			d.v6 = math.random()
		end
		local p_data = x6.pre and x6.pre[md]
		local center_pos
		if p_data and #p_data > 0 then
			local idx = math.floor(d.v6 * (#p_data - 1)) + 1
			center_pos = p_data[idx]
		else
			local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
			local ph = (t * s) - (d.v6 * (l * x9.c2))
			local R = (c.k17 or 150)
			center_pos = Vector3.new(math.cos(ph) * R, math.sin(ph * wf) * h, math.sin(ph) * R)
		end
		local cx, sx_spin = math.cos(t * 2), math.sin(t * 2)
		local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx_spin, d.v4.Y, d.v4.X * sx_spin + d.v4.Z * cx).Unit
		return ((cen + center_pos + (rd * r)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Cosmic Comet" then
		local hr, ts = (c.k11 or 4), (c.k12 or 50) * x9.c7
		if not d.v4 then
			d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			d.v6 = math.random()
		end
		if not d.v8 then
			d.v8 = math.random()
		end
		local p_data = x6.pre and x6.pre[md]
		local center_pos
		if p_data and #p_data > 0 then
			local idx = math.floor(d.v6 * (#p_data - 1)) + 1
			center_pos = p_data[idx]
		else
			local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
			local ph = (t * s) - (d.v6 * (l * x9.c2))
			local R = (c.k17 or 150)
			center_pos = Vector3.new(math.cos(ph) * R, math.sin(ph * (c.k15 or 5) * x9.c7) * h, math.sin(ph) * R)
		end
		return ((cen + center_pos + (d.v4 * (d.v8 * (hr + (d.v6 * d.v6 * 30 * ts))))) - wp) * (x1.k10 * x9.c1)
	elseif md == "Point Impact" then
		local s = 500
		local radius = c.k11 or 0
		if x1.ImpactManual then
			if not x1.IsLaunching then
				s = 1
				radius = 35
			else
				s = 1000 -- Massive spin
				radius = 0
			end
		end
		if not d.v5 then
			d.v5 = math.random() - 0.5
		end
		if not d.v4 then
			d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		end

		-- Direct, instant homing logic
		local cx, sx = math.cos(t * s), math.sin(t * s)
		local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx, d.v4.Y + d.v5, d.v4.X * sx + d.v4.Z * cx).Unit

		-- Use direct vector to target with massive multiplier for "instant" feel
		local target_pos = cen + (rd * radius)
		return (target_pos - wp) * 5000 -- Overpowering force
	elseif md == "Orbital Shell" then
		local R = (c.k11 or 200)
		if not d.v4 then
			d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		end
		local pd = x6.pre and x6.pre[md] and x6.pre[md][1]
		local ca, sa
		if pd then
			ca, sa = pd.ca, pd.sa
		else
			local s = (c.k13 or 10) * x9.c2
			ca, sa = math.cos(t * s), math.sin(t * s)
		end
		local rv
		if c.k19 then
			rv = Vector3.new(d.v4.X * ca - d.v4.Z * sa, d.v4.Y, d.v4.X * sa + d.v4.Z * ca)
		else
			if not d.v5 then
				d.v5 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			end
			local k, v = d.v5, d.v4
			rv = v * ca + k:Cross(v) * sa + k * (k:Dot(v) * (1 - ca))
		end
		if c.k18 then
			rv = Vector3.new(rv.X, math.abs(rv.Y), rv.Z)
		end
		return ((cen + (rv * R)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Vortex Funnel" then
		local s, R_base, R_top, H = (c.k13 or 10) * x9.c2, (c.k11 or 50), (c.k12 or 300), (c.k14 or 400)
		if not d.v4 then
			d.v4 = math.random()
		end
		if not d.v6 then
			d.v6 = math.random() * math.pi * 2
		end
		local current_r = R_base + ((R_top - R_base) * (d.v4 ^ 2))
		local phase = (t * s) + d.v6 + ((1 - d.v4) * (c.k15 or 5) * 5)
		return ((cen + Vector3.new(current_r * math.cos(phase), d.v4 * H - (H / 2), current_r * math.sin(phase))) - wp)
			* (x1.k10 * x9.c1)
	elseif md == "Quantum Atoms" then
		local s, R, Orbits = (c.k13 or 15) * x9.c2, (c.k11 or 60), (c.k15 or 3)
		if not d.v1 then
			d.v1 = math.random(1, Orbits)
		end
		if not d.v6 then
			d.v6 = math.random() * math.pi * 2
		end
		local cx, cz, tilt = math.cos(d.v6 + (t * s)) * R, math.sin(d.v6 + (t * s)) * R, (math.pi / Orbits) * (d.v1 - 1)
		local tx, ty, sp =
			0 * math.sin(tilt) + cx * math.cos(tilt),
			0 * math.cos(tilt) - cx * math.sin(tilt),
			(math.pi * 2 / Orbits) * (d.v1 - 1)
		return (
			(cen + Vector3.new(tx * math.cos(sp) - cz * math.sin(sp), ty, tx * math.sin(sp) + cz * math.cos(sp))) - wp
		) * (x1.k10 * x9.c1)
	elseif md == "Halo Ring" then
		local s, R, H = (c.k13 or 5) * x9.c2, (c.k11 or 40), (c.k14 or 80)
		if not d.v6 then
			d.v6 = math.random() * math.pi * 2
		end
		return ((cen + Vector3.new(math.cos(d.v6 + (t * s)) * R, H, math.sin(d.v6 + (t * s)) * R)) - wp)
			* (x1.k10 * x9.c1)
	elseif md == "Slingshot" then
		local dist = c.k11 or 50
		local cycle = c.k12 or 3
		local speed = c.k13 or 100
		if not d.v1 then
			d.v1 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			d.v2 = math.random() * cycle
			d.v2 = 0
		end
		local phase = (t + d.v2) % cycle
		local is_charging = phase < (cycle * 0.8)
		if x1.SlingshotManual then
			is_charging = not x1.IsLaunching
		end
		if is_charging then
			local charge_pos = cen + (d.v1 * dist)
			return (charge_pos - wp) * (5 * x9.c1)
		else
			local smash_pos = cen
			return (smash_pos - wp) * (speed * x9.c1)
		end
	elseif md == "Gods Call" then
		local ascent_speed = c.k11 or 10
		return Vector3.new(0, ascent_speed, 0)
	elseif md == "Deflect" then
		local range, speed = c.k11 or 50, c.k12 or 500
		if tc.Magnitude < range then
			return (wp - wc).Unit * speed
		end
	elseif md == "Shield Wall" then
		local s, w, h, d_val, h_off = (c.k13 or 20) * x9.c2, (c.k11 or 1), (c.k12 or 10), (c.k14 or 15), (c.k15 or 0)
		if not d.v4 then
			d.v4 = math.random() - 0.5
			d.v5 = math.random() - 0.5
		end
		local angle = (t * s) + (d.v4 * w)
		local tx = math.cos(angle) * d_val
		local tz = math.sin(angle) * d_val
		local ty = (d.v5 * h) + h_off
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Torus Knot" then
		local p_knot, q_knot, s = (c.k11 or 3), (c.k12 or 2), (c.k13 or 10) * x9.c2
		local R, r = (c.k14 or 50), (c.k15 or 20)
		if not d.v6 then
			d.v6 = math.random() * math.pi * 2
		end
		local phase = (t * s) + d.v6
		local cos_q = math.cos(q_knot * phase)
		local tx = (R + r * cos_q) * math.cos(p_knot * phase)
		local tz = (R + r * cos_q) * math.sin(p_knot * phase)
		local ty = r * math.sin(q_knot * phase)
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Möbius Strip" then
		local R, width, s = (c.k11 or 50), (c.k12 or 20), (c.k13 or 15) * x9.c2
		if not d.v6 then
			d.v6 = math.random() * math.pi * 2
		end
		if not d.v1 then
			d.v1 = (math.random() - 0.5) * 2
		end
		local v_ang = (t * s) + d.v6
		local w_offset = d.v1 * width
		local tx = (R + w_offset * math.cos(v_ang / 2)) * math.cos(v_ang)
		local tz = (R + w_offset * math.cos(v_ang / 2)) * math.sin(v_ang)
		local ty = w_offset * math.sin(v_ang / 2)
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "DNA Helix" then
		local R, H, s, freq = (c.k11 or 20), (c.k12 or 80), (c.k13 or 10) * x9.c2, (c.k14 or 50)
		if not d.v1 then
			d.v1 = math.random()
		end
		if not d.v2 then
			d.v2 = math.random(0, 1)
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		local is_rung = d.v3 > 0.8
		local phase = (t * s) + (d.v1 * freq)
		local offset = d.v2 * math.pi
		local tx, ty, tz = 0, (d.v1 - 0.5) * H, 0
		if is_rung then
			local rung_pos = math.floor(d.v1 * 10) / 10
			local rung_phase = (t * s) + (rung_pos * freq)
			local rung_t = (math.random() - 0.5) * 2
			tx = rung_t * R * math.cos(rung_phase)
			tz = rung_t * R * math.sin(rung_phase)
			ty = (rung_pos - 0.5) * H
		else
			tx = R * math.cos(phase + offset)
			tz = R * math.sin(phase + offset)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Black Hole" then
		local event_horizon, disk_radius, spin, disk_height =
			(c.k11 or 40), (c.k12 or 100), (c.k13 or 15) * x9.c2, (c.k14 or 50)
		if not d.v2 then
			d.v2 = math.random()
		end
		if not d.v6 then
			d.v6 = math.random() * math.pi * 2
		end
		local rad = event_horizon + (d.v2 * (disk_radius - event_horizon))
		local local_spin = spin * (disk_radius / rad)
		local disk_phase = (t * local_spin) + d.v6
		local thickness = (math.random() - 0.5) * disk_height * math.sin(disk_phase * 2) * (event_horizon / rad)
		local tx = rad * math.cos(disk_phase)
		local tz = rad * math.sin(disk_phase)
		return ((cen + Vector3.new(tx, thickness, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Tesseract" then
		local size, outer_size, s = (c.k11 or 40), (c.k12 or 80), (c.k13 or 10) * x9.c2
		if not d.v1 then
			d.v1 = math.random(0, 31)
		end
		local target_rot = (t * s)

		local function proj_4d(x, y, z, w, rot)
			local nw = w * math.cos(rot) - x * math.sin(rot)
			local nx = w * math.sin(rot) + x * math.cos(rot)
			local perspective = size / (size - nw * 0.5)
			return nx * perspective, y * perspective, z * perspective
		end

		local points = {
			{ -1, -1, -1 },
			{ 1, -1, -1 },
			{ -1, 1, -1 },
			{ 1, 1, -1 },
			{ -1, -1, 1 },
			{ 1, -1, 1 },
			{ -1, 1, 1 },
			{ 1, 1, 1 },
		}

		local edge = d.v1
		local from, to
		if edge < 12 then -- Inner Cube
			from = points[(edge % 4) * 2 + 1]
			to = points[(edge % 4) * 2 + 2]
		elseif edge < 24 then -- Outer Cube
			from = points[((edge - 12) % 4) * 2 + 1]
			to = points[((edge - 12) % 4) * 2 + 2]
		else -- Connecting struts
			from = points[(edge - 24) + 1]
			to = points[(edge - 24) + 1]
		end

		local lerp = (math.sin(t * s + d.v1) + 1) / 2
		local lx = from[1] + (to[1] - from[1]) * lerp
		local ly = from[2] + (to[2] - from[2]) * lerp
		local lz = from[3] + (to[3] - from[3]) * lerp
		local lw = (edge >= 12 and edge < 24) and 1 or -1

		local rx, ry, rz = proj_4d(lx * outer_size, ly * outer_size, lz * outer_size, lw * outer_size, target_rot)
		return ((cen + Vector3.new(rx, ry, rz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Klein Bottle" then
		local R, s = (c.k11 or 60), (c.k13 or 20) * x9.c2
		if not d.v1 then
			d.v1 = math.random() * math.pi * 2
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		local u_phase = (t * s) + d.v1
		local v_phase = (t * s * 0.5) + d.v2

		local cos_u, sin_u = math.cos(u_phase), math.sin(u_phase)
		local cos_v, sin_v = math.cos(v_phase), math.sin(v_phase)

		local tx = (R + cos_u * sin_v - sin_u * sin_v * 2) * cos_v
		local ty = sin_u * sin_v * R
		local tz = (R + cos_u * sin_v - sin_u * sin_v * 2) * sin_v

		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Space Station" then
		local R, RingThickness, s, CoreRadius = (c.k11 or 80), (c.k12 or 30), (c.k13 or 10) * x9.c2, (c.k14 or 150)
		if not d.v1 then
			d.v1 = math.random()
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random(1, 3)
		end

		local phase = (t * s) + d.v2
		local tx, ty, tz = 0, 0, 0

		if d.v3 == 1 then -- Central Spindle
			ty = (d.v1 - 0.5) * CoreRadius
			tx = math.cos(phase * 3) * (10 + (d.v1 * 5))
			tz = math.sin(phase * 3) * (10 + (d.v1 * 5))
		elseif d.v3 == 2 then -- Outer Habitation Ring
			local ringPhase = phase * 0.5
			local tubeOffset = (d.v1 - 0.5) * RingThickness
			tx = (R + tubeOffset) * math.cos(ringPhase)
			tz = (R + tubeOffset) * math.sin(ringPhase)
			ty = (math.random() - 0.5) * 5
		else -- Connecting Spokes
			local spokeCount = 4
			local spokeAngle = math.floor(d.v2 / (math.pi * 2) * spokeCount) * (math.pi * 2 / spokeCount)
			local spokeSpin = phase * 0.5
			local dist = d.v1 * R
			tx = dist * math.cos(spokeAngle + spokeSpin)
			tz = dist * math.sin(spokeAngle + spokeSpin)
			ty = 0
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Supernova" then
		local ExpandingRad, MaxSize, s = (c.k11 or 15), (c.k12 or 100), (c.k13 or 25) * x9.c2
		if not d.v1 then
			d.v1 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		end
		if not d.v2 then
			d.v2 = math.random()
		end
		local cycle = (t * s) % math.pi
		local burst = math.sin(cycle)

		local core_jitter = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 2
		local shockwave = d.v1 * (burst * MaxSize * d.v2)
		local current_pos = (burst > 0.1) and shockwave or (d.v1 * ExpandingRad + core_jitter)

		return ((cen + current_pos) - wp) * (x1.k10 * x9.c1)
	elseif md == "Dyson Sphere" then
		local R, ShellDensity, s = (c.k11 or 150), (c.k12 or 8), (c.k13 or 10) * x9.c2
		if not d.v1 then
			d.v1 = math.random()
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random() * math.pi
		end
		if not d.v4 then
			local roll = math.random()
			if roll < 0.15 then
				d.v4 = 1 -- Core
			elseif roll < 0.85 then
				d.v4 = 2 -- Shell
			else
				d.v4 = 3 -- Streams
			end
		end

		local phase = (t * s)

		if d.v4 == 1 then
			-- Core
			local core_r = 15 + math.sin(phase * 2) * 2
			local tx = core_r * math.sin(d.v3) * math.cos(d.v2 + phase * 3)
			local ty = core_r * math.cos(d.v3)
			local tz = core_r * math.sin(d.v3) * math.sin(d.v2 + phase * 3)
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
		elseif d.v4 == 2 then
			-- Shell: Discretized points to look like panels
			local p_theta = math.floor(d.v2 * ShellDensity) / ShellDensity
			local p_phi = math.floor(d.v3 * (ShellDensity / 2)) / (ShellDensity / 2)
			local rot_theta = p_theta + (phase * 0.2)

			local tx = R * math.sin(p_phi) * math.cos(rot_theta)
			local ty = R * math.cos(p_phi)
			local tz = R * math.sin(p_phi) * math.sin(rot_theta)
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
		else
			-- Energy Streams: Flowing down the radius lines
			local stream_progress = (d.v1 + phase * 1.5) % 1
			local current_r = 15 + stream_progress * (R - 15)
			-- Quantize angles to match shell "nodes"
			local p_theta = math.floor(d.v2 * 10) / 10
			local p_phi = math.floor(d.v3 * 10) / 10
			local rot_theta = p_theta + (phase * 0.2)

			local tx = current_r * math.sin(p_phi) * math.cos(rot_theta)
			local ty = current_r * math.cos(p_phi)
			local tz = current_r * math.sin(p_phi) * math.sin(rot_theta)
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
		end
	elseif md == "Seraphim" then
		local R, RingCount, s, Wingspan = (c.k11 or 80), (c.k12 or 4), (c.k13 or 15) * x9.c2, (c.k14 or 40)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.2 then
				d.v1 = 0 -- Eye / Core
			elseif roll < 0.6 then
				d.v1 = math.random(1, RingCount) -- Rings
			else
				d.v1 = -1 -- Wings
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0

		if d.v1 == 0 then
			-- Eye
			local eye_phase = d.v2 + phase * 4
			tx = 5 * math.cos(eye_phase)
			ty = 10 * math.sin(eye_phase)
			tz = 0
		elseif d.v1 > 0 then
			-- Rings
			local ring_idx = d.v1
			local ring_phase = d.v2 + (phase * (1 + ring_idx * 0.2))
			local tilt_x = (ring_idx / RingCount) * math.pi
			local tilt_z = phase * 0.5 + ring_idx

			-- Base ring circle
			local bx = R * math.cos(ring_phase)
			local by = 0
			local bz = R * math.sin(ring_phase)

			-- Apply tilts
			local cx, sx = math.cos(tilt_x), math.sin(tilt_x)
			local cz, sz = math.cos(tilt_z), math.sin(tilt_z)

			-- Rotate X
			local rx1 = bx
			local ry1 = by * cx - bz * sx
			local rz1 = by * sx + bz * cx

			-- Rotate Z
			tx = rx1 * cz - ry1 * sz
			ty = rx1 * sz + ry1 * cz
			tz = rz1
		else
			-- Wings
			local wing_side = (d.v2 % 2 > 1) and 1 or -1
			local wing_pos = (d.v2 / (math.pi * 2))
			local wing_w = wing_pos * Wingspan * 2

			local wing_flap = math.sin(phase * 2) * 15 * wing_pos

			tx = wing_w * wing_side
			ty = wing_flap + math.abs(wing_side * wing_w * 0.5) -- v-shape
			tz = -20 - (wing_pos * 30)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Alien Mothership" then
		local Radius, CoreHeight, s, BeamLen = (c.k11 or 120), (c.k12 or 40), (c.k13 or 15) * x9.c2, (c.k14 or 200)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.6 then
				d.v1 = 1 -- Saucer
			elseif roll < 0.8 then
				d.v1 = 2 -- Abduction Beam
			else
				d.v1 = 3 -- Scout ships
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.random() * math.pi * 2
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0

		if d.v1 == 1 then
			-- Saucer: wide torus / flat sphere
			local r = Radius * math.sqrt(d.v3)
			local y_curve = math.sin(math.acos(d.v3)) * CoreHeight
			if d.v2 > math.pi then
				y_curve = -y_curve
			end

			local rot = d.v4 + phase
			tx = r * math.cos(rot)
			tz = r * math.sin(rot)
			ty = y_curve
		elseif d.v1 == 2 then
			-- Beam: expanding cylinder downward, parts moving up
			local beam_prog = (d.v3 + phase * 2) % 1
			ty = -CoreHeight - (beam_prog * BeamLen)
			local beam_rad = 10 + (beam_prog * Radius * 0.4)
			local rot = d.v2 + phase * 3
			tx = beam_rad * math.cos(rot)
			tz = beam_rad * math.sin(rot)
		else
			-- Scout ships: 3 small clusters orbiting
			local group = math.floor(d.v3 * 3)
			local orbit_phase = phase * 0.5 + (group * math.pi * 2 / 3)
			local orbit_r = Radius * 1.5
			local cx = orbit_r * math.cos(orbit_phase)
			local cz = orbit_r * math.sin(orbit_phase)
			local cy = math.sin(phase * 2 + group) * 20

			local local_rot = d.v4 + phase * 5
			local local_r = math.random() * 10
			tx = cx + local_r * math.cos(local_rot)
			tz = cz + local_r * math.sin(local_rot)
			ty = cy + (math.random() - 0.5) * 5
		end

		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Quantum Core" then
		local R, RingThickness, s, ParticleSpeed = (c.k11 or 100), (c.k12 or 30), (c.k13 or 40) * x9.c2, (c.k14 or 50)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.4 then
				d.v1 = 1 -- Horizontal Ring
			elseif roll < 0.8 then
				d.v1 = 2 -- Vertical Ring
			else
				d.v1 = 3 -- Core Particles
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random() * math.pi * 2
		end
		if not d.v4 then
			d.v4 = (math.random() - 0.5) * 2
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0

		if d.v1 == 1 then
			local ring_phase = d.v2 + phase
			local torus_x = (R + RingThickness * math.cos(d.v3)) * math.cos(ring_phase)
			local torus_z = (R + RingThickness * math.cos(d.v3)) * math.sin(ring_phase)
			local torus_y = RingThickness * math.sin(d.v3)

			tx, ty, tz = torus_x, torus_y, torus_z
		elseif d.v1 == 2 then
			local ring_phase = d.v2 + phase * 1.1 -- Slightly off-sync
			local torus_x = (R + RingThickness * math.cos(d.v3)) * math.cos(ring_phase)
			local torus_y = (R + RingThickness * math.cos(d.v3)) * math.sin(ring_phase)
			local torus_z = RingThickness * math.sin(d.v3)

			tx, ty, tz = torus_x, torus_y, torus_z
		else
			-- Crazy core particles
			local spd = ParticleSpeed * 0.1
			local dist = (math.sin(t * spd + d.v2) * 0.5 + 0.5) * (R * 0.8)
			local phi = d.v3 + phase * 3 * d.v4
			local theta = d.v2 + phase * 4 * d.v4

			tx = dist * math.sin(phi) * math.cos(theta)
			ty = dist * math.cos(phi)
			tz = dist * math.sin(phi) * math.sin(theta)
		end

		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Galactic Web" then
		local Spread, SpinSpeed, DriftTime = (c.k11 or 400), (c.k12 or 10) * x9.c2, (c.k13 or 5)
		if not d.v1 then
			d.v1 = (math.random() - 0.5) * 2
		end
		if not d.v2 then
			d.v2 = (math.random() - 0.5) * 2
		end
		if not d.v3 then
			d.v3 = (math.random() - 0.5) * 2
		end
		if not d.v4 then
			d.v4 = math.random() * math.pi * 2
		end
		if not d.v5 then
			d.v5 = (math.random() - 0.5) * 2
		end
		if not d.rot_axis then
			local rx, ry, rz = math.random() - 0.5, math.random() - 0.5, math.random() - 0.5
			local len = math.sqrt(rx * rx + ry * ry + rz * rz)
			if len == 0 then
				rx, ry, rz, len = 0, 1, 0, 1
			end
			d.rot_axis = Vector3.new(rx / len, ry / len, rz / len)
		end

		local phase = t * SpinSpeed + d.v4
		local drift_phase = (t / DriftTime) + d.v4

		-- Scattered slow-moving spherical network
		local drift_x = math.sin(drift_phase) * d.v5 * (Spread * 0.25)
		local drift_y = math.cos(drift_phase * 0.8) * d.v5 * (Spread * 0.25)
		local drift_z = math.sin(drift_phase * 1.2) * d.v5 * (Spread * 0.25)

		local px = d.v1 * Spread + drift_x
		local py = d.v2 * Spread + drift_y
		local pz = d.v3 * Spread + drift_z

		-- Random rotation around independent axis for each node
		local p_vec = Vector3.new(px, py, pz)
		local k = d.rot_axis
		local cos_p = math.cos(phase)
		local sin_p = math.sin(phase)

		local cross = k:Cross(p_vec)
		local dot = k:Dot(p_vec)
		local rotated = p_vec * cos_p + cross * sin_p + k * (dot * (1 - cos_p))

		-- Height Limit Logic (Smooth Scaling)
		local h_lim = c.k24 or 200
		local vertical_scale = h_lim / math.max(1, Spread)
		local final_y = rotated.Y * vertical_scale

		if c.k23 then
			final_y = math.abs(final_y)
		end

		return ((cen + Vector3.new(rotated.X, final_y, rotated.Z)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Meteor Shower" then
		local SpreadXZ, HeightSpawn, FallSpeed, Density = (c.k11 or 500), (c.k12 or 300), (c.k13 or 150), (c.k14 or 50)
		if not d.v1 then
			d.v1 = (math.random() - 0.5) * SpreadXZ
		end
		if not d.v2 then
			d.v2 = (math.random() - 0.5) * SpreadXZ
		end
		if not d.v3 then
			d.v3 = math.random()
		end -- Phase offset for falling

		-- Fast diagonal falling motion
		local drop_dist = HeightSpawn * 2
		local fall_time = drop_dist / FallSpeed
		local current_fall = ((t + d.v3 * fall_time) % fall_time) / fall_time

		local y_pos = HeightSpawn - (current_fall * drop_dist)
		-- Meteors fall at a slant (x and z drift)
		local x_pos = d.v1 - (current_fall * (SpreadXZ * 0.5))
		local z_pos = d.v2 - (current_fall * (SpreadXZ * 0.25))

		return ((cen + Vector3.new(x_pos, y_pos, z_pos)) - wp) * (x1.k10 * x9.c1)
	elseif md == "World Serpent" then
		local Length, Amplitude, s, Wavelength =
			(c.k11 or 400), (c.k12 or 100), (c.k13 or 20) * x9.c2, (c.k14 or 20) * 10
		if not d.v1 then
			d.v1 = math.random()
		end -- Body position segment

		local phase = t * s
		local pos_along_body = d.v1 * Length

		-- Slithering wave logic
		local wave_offset = (pos_along_body - (phase * 500)) / Wavelength

		-- Wrapping around a massive circle to form a continuous loop
		local outer_radius = Length / math.pi
		local angle = (pos_along_body / Length) * math.pi * 2 + phase

		local undulation_y = math.sin(wave_offset * math.pi * 2) * Amplitude
		local undulation_r = math.cos(wave_offset * math.pi * 2) * (Amplitude * 0.5)

		local current_radius = outer_radius + undulation_r
		local tx = current_radius * math.cos(angle)
		local tz = current_radius * math.sin(angle)
		local ty = undulation_y

		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Aurora Borealis" then
		local Span, Height, s, RibbonWidth = (c.k11 or 600), (c.k12 or 300), (c.k13 or 15) * x9.c2, (c.k14 or 100)
		if not d.v1 then
			d.v1 = (math.random() - 0.5) * 2
		end -- Position along the aurora directly
		if not d.v2 then
			d.v2 = math.random()
		end -- Height within the ribbon
		if not d.v3 then
			d.v3 = math.random() * math.pi * 2
		end

		local phase = t * s

		-- Massive curved ribbon sweeping the sky
		local x_pos = d.v1 * (Span * 0.5)

		-- Multiple sine waves to create natural curtain-like folds
		local fold_1 = math.sin((x_pos / 100) + phase) * (Span * 0.1)
		local fold_2 = math.sin((x_pos / 50) - phase * 1.5) * (Span * 0.05)
		local z_pos = fold_1 + fold_2

		-- Curving the entire thing slightly
		z_pos = z_pos + math.pow(d.v1, 2) * (Span * 0.2)

		-- Vertical displacement and drifting
		local y_pos = Height + (d.v2 * RibbonWidth)
		-- Add vertical waviness
		y_pos = y_pos + math.sin((x_pos / 100) + phase * 2 + d.v3) * (RibbonWidth * 0.5)

		return ((cen + Vector3.new(x_pos, y_pos, z_pos)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Arcane Orrery" then
		local R, Arms, s, H = (c.k11 or 120), (c.k12 or 4), (c.k13 or 8) * x9.c2, (c.k14 or 200)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.12 then
				d.v1 = 1 -- Central Axis Stream
			elseif roll < 0.30 then
				d.v1 = 2 -- Inner Gear Ring
			elseif roll < 0.48 then
				d.v1 = 3 -- Outer Gear Ring
			elseif roll < 0.72 then
				d.v1 = 4 -- Orbital Arms
			else
				d.v1 = 5 -- Zodiac Belt
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.random() * math.pi * 2
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0

		if d.v1 == 1 then
			-- Central Axis Stream: double helix up/down the pillar
			local prog = d.v3
			ty = (prog - 0.5) * H
			local helix_r = 12 + math.sin(prog * math.pi * 6) * 3
			local strand = (d.v2 > math.pi) and math.pi or 0
			local helix_angle = prog * math.pi * 8 + phase * 3 + strand
			tx = helix_r * math.cos(helix_angle)
			tz = helix_r * math.sin(helix_angle)
			ty = ty + math.sin(phase * 2 + prog * 10) * 3
		elseif d.v1 == 2 then
			-- Inner Gear Ring at mid-height
			local teeth = 16
			local gear_r = R * 0.5
			local gear_phase = d.v2 + phase
			local tooth_bump = math.abs(math.sin(gear_phase * teeth / 2)) * 12
			local r = gear_r + tooth_bump
			tx = r * math.cos(gear_phase)
			tz = r * math.sin(gear_phase)
			ty = H * 0.4 + math.sin(phase + d.v2) * 3
		elseif d.v1 == 3 then
			-- Outer Gear Ring counter-rotating
			local teeth = 20
			local gear_r = R * 0.8
			local gear_phase = d.v2 - phase * 0.7
			local tooth_bump = math.abs(math.sin(gear_phase * teeth / 2)) * 15
			local r = gear_r + tooth_bump
			tx = r * math.cos(gear_phase)
			tz = r * math.sin(gear_phase)
			ty = H * 0.4 + math.sin(phase * 1.3 + d.v2) * 5
		elseif d.v1 == 4 then
			-- Orbital Arms with planet clusters
			local arm_idx = math.floor(d.v2 / (math.pi * 2) * Arms)
			local arm_angle = (arm_idx / Arms) * math.pi * 2 + phase * 0.3
			local dist = d.v3 * R
			local planet_r = 8 + math.sin(d.v4 * 6) * 4
			local planet_phase = d.v4 + phase * 4
			tx = dist * math.cos(arm_angle) + planet_r * math.cos(planet_phase)
			tz = dist * math.sin(arm_angle) + planet_r * math.sin(planet_phase)
			ty = H * 0.5 + math.sin(arm_angle * 3 + phase) * 15 + planet_r * math.sin(planet_phase * 0.5) * 0.5
		else
			-- Zodiac Belt: tilted elliptical ring at top
			local belt_r = R * 1.1
			local belt_phase = d.v2 + phase * 0.5
			local tilt = math.pi * 0.25
			local bx = belt_r * math.cos(belt_phase)
			local bz = belt_r * math.sin(belt_phase)
			local by = 0
			local cy, sy2 = math.cos(tilt), math.sin(tilt)
			local ry = by * cy - bz * sy2
			local rz = by * sy2 + bz * cy
			tx = bx
			ty = H * 0.8 + ry
			tz = rz
			-- Node clusters at 12 points
			local node = math.floor(belt_phase / (math.pi * 2) * 12) * (math.pi * 2 / 12)
			local near_node = math.abs(belt_phase % (math.pi * 2 / 12) - math.pi / 12)
			if near_node < 0.15 then
				local pulse = math.sin(phase * 3 + node * 5) * 8
				tx = tx + math.cos(d.v4) * pulse
				tz = tz + math.sin(d.v4) * pulse
			end
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Maelstrom Spire" then
		local BaseR, H, s, Jets = (c.k11 or 30), (c.k12 or 200), (c.k13 or 15) * x9.c2, (c.k14 or 6)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.25 then
				d.v1 = 1 -- Base Vortex
			elseif roll < 0.50 then
				d.v1 = 2 -- Compression Funnel
			elseif roll < 0.70 then
				d.v1 = 3 -- Crown Jets
			elseif roll < 0.92 then
				d.v1 = 4 -- Rainfall Curtain
			else
				d.v1 = 5 -- Eye of Storm
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.random() * math.pi * 2
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0
		local TopR = BaseR * 4

		if d.v1 == 1 then
			-- Base Vortex: logarithmic spiral at ground
			local spiral_a = d.v2 + phase * 2
			local spiral_r = BaseR * 0.5 + d.v3 * TopR * 1.2
			local log_r = spiral_r * (1 + math.log(1 + d.v3 * 2))
			tx = log_r * math.cos(spiral_a)
			tz = log_r * math.sin(spiral_a)
			ty = -5 + math.sin(spiral_a * 3) * 3
		elseif d.v1 == 2 then
			-- Compression Funnel: spiraling up with decreasing radius
			local prog = d.v3
			local funnel_r = TopR * (1 - prog * 0.8)
			local angular_speed = 1 + prog * 3
			local funnel_phase = d.v2 + phase * angular_speed
			tx = funnel_r * math.cos(funnel_phase)
			tz = funnel_r * math.sin(funnel_phase)
			ty = prog * H
		elseif d.v1 == 3 then
			-- Crown Jets at platform height
			local jet_idx = math.floor(d.v2 / (math.pi * 2) * Jets)
			local jet_angle = (jet_idx / Jets) * math.pi * 2 + phase * 0.3
			local jet_dist = d.v3 * TopR * 2
			local wobble = math.sin(phase * 3 + jet_idx * 1.5) * 10
			tx = jet_dist * math.cos(jet_angle + wobble * 0.02)
			tz = jet_dist * math.sin(jet_angle + wobble * 0.02)
			ty = H + wobble + math.sin(d.v4 + phase) * 5
		elseif d.v1 == 4 then
			-- Rainfall Curtain: parabolic arcs falling back down
			local arc_prog = (d.v3 + phase * 0.5) % 1
			local arc_angle = d.v2 + phase * 0.2
			local arc_r = TopR * 1.5 + arc_prog * TopR * 0.5
			local arc_y = H * (1 - 4 * (arc_prog - 0.5) * (arc_prog - 0.5))
			tx = arc_r * math.cos(arc_angle)
			tz = arc_r * math.sin(arc_angle)
			ty = arc_y
		else
			-- Eye of Storm: small cluster hovering still at center top
			local eye_r = 5 + math.sin(phase * 0.5 + d.v2) * 2
			tx = eye_r * math.cos(d.v2 + phase * 0.1)
			tz = eye_r * math.sin(d.v2 + phase * 0.1)
			ty = H + math.sin(phase + d.v3 * math.pi) * 2
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Eldritch Binding" then
		local R, H, s, Tendrils = (c.k11 or 100), (c.k12 or 200), (c.k13 or 5) * x9.c2, (c.k14 or 8)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.15 then
				d.v1 = 1 -- Lower Pentagram
			elseif roll < 0.30 then
				d.v1 = 2 -- Upper Hexagram
			elseif roll < 0.50 then
				d.v1 = 3 -- Binding Chains
			elseif roll < 0.62 then
				d.v1 = 4 -- Sigil Pulsar Nodes
			elseif roll < 0.85 then
				d.v1 = 5 -- Dark Tendrils
			else
				d.v1 = 6 -- Containment Shell
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.random()
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0

		if d.v1 == 1 then
			-- Lower Pentagram: 5-pointed star edges
			local star_pts = 5
			local edge_idx = math.floor(d.v2 / (math.pi * 2) * star_pts)
			local a1 = (edge_idx / star_pts) * math.pi * 2 + phase
			local a2 = ((edge_idx + 2) % star_pts / star_pts) * math.pi * 2 + phase
			local lerp_t = d.v3
			local x1p = R * math.cos(a1)
			local z1p = R * math.sin(a1)
			local x2p = R * math.cos(a2)
			local z2p = R * math.sin(a2)
			tx = x1p + (x2p - x1p) * lerp_t
			tz = z1p + (z2p - z1p) * lerp_t
			ty = 10
		elseif d.v1 == 2 then
			-- Upper Hexagram: 6-pointed star, counter-rotating
			local star_pts = 6
			local edge_idx = math.floor(d.v2 / (math.pi * 2) * star_pts)
			local a1 = (edge_idx / star_pts) * math.pi * 2 - phase
			local a2 = ((edge_idx + 2) % star_pts / star_pts) * math.pi * 2 - phase
			local lerp_t = d.v3
			tx = R * math.cos(a1) + (R * math.cos(a2) - R * math.cos(a1)) * lerp_t
			tz = R * math.sin(a1) + (R * math.sin(a2) - R * math.sin(a1)) * lerp_t
			ty = H
		elseif d.v1 == 3 then
			-- Binding Chains: lines connecting lower to upper vertices
			local chain_idx = math.floor(d.v2 / (math.pi * 2) * 10)
			local lower_a = (chain_idx % 5) / 5 * math.pi * 2 + phase
			local upper_a = (chain_idx % 6) / 6 * math.pi * 2 - phase
			local prog = d.v3
			tx = R * math.cos(lower_a) * (1 - prog) + R * math.cos(upper_a) * prog
			tz = R * math.sin(lower_a) * (1 - prog) + R * math.sin(upper_a) * prog
			ty = 10 + prog * (H - 10)
			-- Chain sag
			ty = ty - math.sin(prog * math.pi) * 15
		elseif d.v1 == 4 then
			-- Sigil Pulsar Nodes at vertices
			local node_count = 11
			local node_idx = math.floor(d.v2 / (math.pi * 2) * node_count)
			local is_lower = node_idx < 5
			local node_a
			if is_lower then
				node_a = (node_idx / 5) * math.pi * 2 + phase
				ty = 10
			else
				node_a = ((node_idx - 5) / 6) * math.pi * 2 - phase
				ty = H
			end
			local pulse = math.sin(phase * 3 + node_idx * 2) * 0.5 + 0.5
			local node_r = R + pulse * 15
			tx = node_r * math.cos(node_a) + math.cos(d.v4 * math.pi * 2) * pulse * 8
			tz = node_r * math.sin(node_a) + math.sin(d.v4 * math.pi * 2) * pulse * 8
		elseif d.v1 == 5 then
			-- Dark Tendrils: serpentine paths up the pillar
			local tendril_idx = math.floor(d.v2 / (math.pi * 2) * Tendrils)
			local base_angle = (tendril_idx / Tendrils) * math.pi * 2
			local prog = (d.v3 + phase * 0.5) % 1
			ty = prog * H
			local snake = math.sin(prog * math.pi * 6 + phase * 2 + tendril_idx) * 15
			local tendril_r = 15 + snake + d.v4 * 3
			tx = tendril_r * math.cos(base_angle + prog * math.pi * 2)
			tz = tendril_r * math.sin(base_angle + prog * math.pi * 2)
		else
			-- Containment Shell: sparse sphere breathing in/out
			local phi = d.v2
			local theta = d.v3 * math.pi
			local breath = math.sin(phase * 0.5) * 0.2 + 1
			local shell_r = R * 1.3 * breath
			tx = shell_r * math.sin(theta) * math.cos(phi + phase * 0.1)
			tz = shell_r * math.sin(theta) * math.sin(phi + phase * 0.1)
			ty = H * 0.5 + shell_r * math.cos(theta)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Graviton Engine" then
		local Turbines, R, s, H = (c.k11 or 4), (c.k12 or 60), (c.k13 or 12) * x9.c2, (c.k14 or 200)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.25 then
				d.v1 = 1 -- Turbine Ring
			elseif roll < 0.45 then
				d.v1 = 2 -- Blade Clusters
			elseif roll < 0.60 then
				d.v1 = 3 -- Conduit Streams
			elseif roll < 0.72 then
				d.v1 = 4 -- Exhaust Plumes
			elseif roll < 0.88 then
				d.v1 = 5 -- Antenna Dish
			else
				d.v1 = 6 -- Energy Beam
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.random()
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0
		local turb_spacing = H / (Turbines + 1)

		if d.v1 == 1 then
			-- Turbine Rings stacked along pillar
			local turb_idx = math.floor(d.v3 * Turbines)
			local turb_y = turb_spacing * (turb_idx + 1)
			local turb_phase = d.v2 + phase * (1 + turb_idx * 0.3)
			if turb_idx % 2 == 1 then
				turb_phase = -turb_phase
			end
			tx = R * math.cos(turb_phase)
			tz = R * math.sin(turb_phase)
			ty = turb_y
		elseif d.v1 == 2 then
			-- Blade Clusters within turbine rings
			local turb_idx = math.floor(d.v3 * Turbines)
			local turb_y = turb_spacing * (turb_idx + 1)
			local blade_count = 6
			local blade_idx = math.floor(d.v2 / (math.pi * 2) * blade_count)
			local blade_base_angle = (blade_idx / blade_count) * math.pi * 2 + phase * (1 + turb_idx * 0.3)
			if turb_idx % 2 == 1 then
				blade_base_angle = -blade_base_angle
			end
			local blade_len = R * 0.4
			local blade_prog = d.v4
			local blade_r = R * 0.6 + blade_prog * blade_len
			local blade_tilt = math.pi * 0.15
			tx = blade_r * math.cos(blade_base_angle)
			tz = blade_r * math.sin(blade_base_angle)
			ty = turb_y + math.sin(blade_tilt) * blade_prog * blade_len * 0.3
		elseif d.v1 == 3 then
			-- Conduit Streams between turbines
			local turb_idx = math.floor(d.v3 * math.max(1, Turbines - 1))
			local lower_y = turb_spacing * (turb_idx + 1)
			local upper_y = turb_spacing * (turb_idx + 2)
			local pipe_count = 4
			local pipe_idx = math.floor(d.v2 / (math.pi * 2) * pipe_count)
			local pipe_angle = (pipe_idx / pipe_count) * math.pi * 2 + phase * 0.2
			local prog = (d.v4 + phase * 2) % 1
			local pipe_r = 15
			tx = pipe_r * math.cos(pipe_angle)
			tz = pipe_r * math.sin(pipe_angle)
			ty = lower_y + prog * (upper_y - lower_y)
		elseif d.v1 == 4 then
			-- Exhaust Plumes below each turbine
			local turb_idx = math.floor(d.v3 * Turbines)
			local turb_y = turb_spacing * (turb_idx + 1)
			local exhaust_prog = (d.v4 + phase * 3) % 1
			local exhaust_r = R * 0.3 + exhaust_prog * R * 0.5
			local exhaust_angle = d.v2 + phase * 2
			tx = exhaust_r * math.cos(exhaust_angle)
			tz = exhaust_r * math.sin(exhaust_angle)
			ty = turb_y - exhaust_prog * turb_spacing * 0.6
		elseif d.v1 == 5 then
			-- Antenna Dish at platform top (parabolic)
			local dish_r = d.v3 * R * 1.2
			local dish_angle = d.v2 + phase * 0.3
			local dish_y = H + (dish_r * dish_r) / (R * 2)
			tx = dish_r * math.cos(dish_angle)
			tz = dish_r * math.sin(dish_angle)
			ty = dish_y
		else
			-- Energy Beam: tight column shooting upward
			local beam_r = 3 + math.sin(phase * 5 + d.v2 * 10) * 2
			local beam_prog = (d.v3 + phase * 4) % 1
			tx = beam_r * math.cos(d.v2)
			tz = beam_r * math.sin(d.v2)
			ty = H + 20 + beam_prog * H * 0.8
			-- Scatter at high altitude
			if beam_prog > 0.7 then
				local scatter = (beam_prog - 0.7) / 0.3
				tx = tx + math.cos(d.v4 * math.pi * 2) * scatter * 40
				tz = tz + math.sin(d.v4 * math.pi * 2) * scatter * 40
			end
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Fractal Web" then
		local HexR, Depth, BSpeed, RSpeed = (c.k11 or 40), (c.k12 or 3), (c.k13 or 3) * x9.c2, (c.k14 or 5) * x9.c2
		if not d.v1 then
			d.v1 = math.random(0, math.max(1, Depth - 1))
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.floor(math.random() * 6)
		end

		local phase = t * RSpeed
		local breath = math.sin(t * BSpeed) * 0.3 + 1
		local level = d.v1
		local tx, ty, tz = 0, 0, 0

		-- Calculate hierarchical hex position
		local accumulated_x, accumulated_z = 0, 0
		local current_r = HexR
		for lv = 0, level do
			local vertex_idx
			if lv == level then
				vertex_idx = d.v4
			else
				vertex_idx = math.floor(d.v2 / (math.pi * 2) * 6 + lv) % 6
			end
			local angle = (vertex_idx / 6) * math.pi * 2 + phase * (1 / (lv + 1))
			local offset_r = current_r * breath * (1 + lv * 0.3)
			accumulated_x = accumulated_x + offset_r * math.cos(angle)
			accumulated_z = accumulated_z + offset_r * math.sin(angle)
			current_r = current_r * 0.5
		end

		-- Edge-walking within current hex
		local edge_prog = d.v3
		local next_vertex = (d.v4 + 1) % 6
		local cur_angle = (d.v4 / 6) * math.pi * 2 + phase * (1 / (level + 1))
		local nxt_angle = (next_vertex / 6) * math.pi * 2 + phase * (1 / (level + 1))
		local edge_r = current_r * breath * (1 + level * 0.3)
		local ex = edge_r * math.cos(cur_angle) * (1 - edge_prog) + edge_r * math.cos(nxt_angle) * edge_prog
		local ez = edge_r * math.sin(cur_angle) * (1 - edge_prog) + edge_r * math.sin(nxt_angle) * edge_prog

		tx = accumulated_x + ex
		tz = accumulated_z + ez
		ty = 50 + level * 20 + math.sin(phase + d.v2) * 5

		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Leviathan Coil" then
		local CoilR, Thick, s, H = (c.k11 or 50), (c.k12 or 15), (c.k13 or 8) * x9.c2, (c.k14 or 250)
		if not d.v1 then
			local roll = math.random()
			if roll < 0.45 then
				d.v1 = 1 -- Serpent Body
			elseif roll < 0.58 then
				d.v1 = 2 -- Head
			elseif roll < 0.72 then
				d.v1 = 3 -- Tail Whip
			elseif roll < 0.87 then
				d.v1 = 4 -- Wing Flares
			else
				d.v1 = 5 -- Spine Ridge
			end
		end
		if not d.v2 then
			d.v2 = math.random() * math.pi * 2
		end
		if not d.v3 then
			d.v3 = math.random()
		end
		if not d.v4 then
			d.v4 = math.random() * math.pi * 2
		end

		local phase = t * s
		local tx, ty, tz = 0, 0, 0
		local coil_loops = 4
		local body_length = coil_loops * math.pi * 2
		-- Vertical bobbing of entire coil
		local bob = math.sin(phase * 0.3) * 15

		if d.v1 == 1 then
			-- Serpent Body: thick tube following helix
			local prog = d.v3
			local coil_angle = prog * body_length + phase
			local body_y = prog * H + bob
			local thickness = Thick * (0.5 + math.sin(prog * math.pi) * 0.5)
			local tube_angle = d.v2
			local body_r = CoilR + math.cos(tube_angle) * thickness
			local body_up = math.sin(tube_angle) * thickness
			tx = body_r * math.cos(coil_angle)
			tz = body_r * math.sin(coil_angle)
			ty = body_y + body_up
		elseif d.v1 == 2 then
			-- Head: dense cluster at front of serpent
			local head_angle = phase
			local head_y = H + bob + 10
			local jaw_open = math.sin(phase * 2) * 0.5 + 0.5
			local head_r = Thick * 1.5
			local is_upper = d.v3 > 0.5
			local jaw_offset = (is_upper and 1 or -1) * jaw_open * 8
			tx = CoilR * math.cos(head_angle) + math.cos(d.v2) * head_r * d.v3
			tz = CoilR * math.sin(head_angle) + math.sin(d.v2) * head_r * d.v3
			ty = head_y + jaw_offset + math.cos(d.v4) * head_r * 0.3
		elseif d.v1 == 3 then
			-- Tail Whip: tapers and oscillates rapidly
			local prog = d.v3 * 0.3
			local tail_angle = prog * body_length * 0.5 + phase * 2
			local tail_y = prog * H * 0.3 + bob - 10
			local taper = Thick * (1 - d.v3) * 0.4
			local whip_freq = 8
			local whip_offset = math.sin(phase * whip_freq + prog * 20) * taper * 2
			tx = (CoilR + whip_offset) * math.cos(tail_angle) + math.cos(d.v2) * taper
			tz = (CoilR + whip_offset) * math.sin(tail_angle) + math.sin(d.v2) * taper
			ty = tail_y + math.sin(d.v4 + phase * 3) * taper
		elseif d.v1 == 4 then
			-- Wing Flares: periodic burst outward at 2 body points
			local wing_point = d.v3 > 0.5 and 0.35 or 0.65
			local wing_angle = wing_point * body_length + phase
			local wing_y = wing_point * H + bob
			local flare_cycle = math.sin(phase * 1.5 + (d.v3 > 0.5 and 0 or math.pi))
			local flare = math.max(0, flare_cycle)
			local wing_side = (d.v2 > math.pi) and 1 or -1
			local wing_spread = flare * CoilR * 1.5
			local wing_prog = d.v4 / (math.pi * 2)
			-- Fan shape
			local fan_angle = wing_angle + wing_side * math.pi * 0.5
			local fan_r = wing_prog * wing_spread
			tx = CoilR * math.cos(wing_angle) + fan_r * math.cos(fan_angle + (wing_prog - 0.5) * 0.8)
			tz = CoilR * math.sin(wing_angle) + fan_r * math.sin(fan_angle + (wing_prog - 0.5) * 0.8)
			ty = wing_y + fan_r * 0.3 * math.sin(wing_prog * math.pi)
		else
			-- Spine Ridge: elevated line along body top
			local prog = d.v3
			local coil_angle = prog * body_length + phase
			local body_y = prog * H + bob
			local spine_r = CoilR
			local spine_up = Thick * (0.5 + math.sin(prog * math.pi) * 0.5) + 5
			tx = spine_r * math.cos(coil_angle)
			tz = spine_r * math.sin(coil_angle)
			ty = body_y + spine_up + math.sin(prog * 30 + phase * 2) * 2
		end
		return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
	elseif md == "Sculptor" then
		-- Sculptor mode: selected parts follow mouse, unselected hold position
		if x6.sculptor_selected[p] then
			if x6.sculptor_dragging and x6.sculptor_drag_target then
				-- Move toward mouse target position (smooth, distance-based speed)
				local target = x6.sculptor_drag_target
				local offset = x6.sculptor_selected[p] or Vector3.zero
				local target_pos = target + offset
				local delta = target_pos - wp
				local dist = delta.Magnitude
				-- Smooth movement: slower when close, faster when far
				if dist < 0.5 then
					return Vector3.new(0, 0.01, 0) -- Basically at target, hold
				else
					-- Cap speed to prevent jitter, scale with distance
					local speed = math.clamp(dist * 3, 1, 100)
					return delta.Unit * speed
				end
			else
				-- Hold position (near-zero velocity to prevent physics sleep)
				return Vector3.new(0, 0.01, 0)
			end
		else
			-- Unselected parts: just hold position (don't float toward center)
			return Vector3.new(0, 0.01, 0)
		end
	end
	return ANTI_SLEEP
end
local no_damp = { ["Slingshot"] = true, ["Point Impact"] = true, ["Deflect"] = true }
local function f3()
	if not x6.b or x1.Disabled then
		return
	end
	if x1.Paused then
		for _, d in pairs(x6.a) do
			if d.lv then
				d.lv.VectorVelocity = Vector3.new(0, 0.01, 0)
			end
		end
		return
	end
	pcall(function()
		local c = x6.b.Position
		x6.f = x6.f + 1
		local dt = x6.n > 5000 and 10 or (x6.n > 2500 and 6 or (x6.n > 1000 and 3 or 1))
		local et, ft = x1.k7 or dt, time()
		local i = 0
		if ft > x6.pi_timer then
			x6.pi_timer = ft + 1
			x6.pi_targets = {}
			if x1.PI_All then
				for _, pl in ipairs(v2:GetPlayers()) do
					if pl ~= v8 and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
						table.insert(x6.pi_targets, pl)
					end
				end
			else
				if x1.Tgt and x1.Tgt.Character and x1.Tgt.Character:FindFirstChild("HumanoidRootPart") then
					table.insert(x6.pi_targets, x1.Tgt)
				end
			end
		end
		px(x1.k6, ft, x3())
		local cur_no_damp = no_damp[x1.k6]
		for _, p in ipairs(x6.active_array) do
			local d = x6.a[p]
			if not d then
				continue
			end

			if not p.Parent then
				x4.f2(p)
				continue
			end
			-- Skip parts we lost network ownership of
			if isnetworkowner then
				local ok, owned = pcall(isnetworkowner, p)
				if ok and not owned then
					if d.lv then d.lv.VectorVelocity = Vector3.zero end
					continue
				end
			end
			local p_vel = p.AssemblyLinearVelocity
			i = i + 1
			if i % et ~= (x6.f % et) then
				continue
			end
			local active_c = c
			if #x6.pi_targets > 0 then
				local t_idx = ((i - 1) % #x6.pi_targets) + 1
				local tgt = x6.pi_targets[t_idx]

				if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
					active_c = tgt.Character.HumanoidRootPart.Position
				end
			end
			local tc = active_c - p.Position
			local tc_mag = tc.Magnitude
			if tc_mag > x1.k1 then
				continue
			end
			if tc_mag > x9.c7 then
				local target_pos_delta = f2(p, active_c, d, x1.k6, ft)
				if x1.VerticalStiffness and x1.VerticalStiffness ~= 1 then
					target_pos_delta =
						Vector3.new(target_pos_delta.X, target_pos_delta.Y * x1.VerticalStiffness, target_pos_delta.Z)
				end
				if x1.Ki and x1.Ki > 0 and d.integral then
					d.integral = d.integral + (target_pos_delta * dt)
					local max_i = 100
					if d.integral.Magnitude > max_i then
						d.integral = d.integral.Unit * max_i
					end
					target_pos_delta = target_pos_delta + (d.integral * x1.Ki)
				end
				local tv = target_pos_delta
				if x1.Damping and x1.Damping > 0 and not cur_no_damp then
					tv = tv - (p_vel * x1.Damping)
				end

				-- Energy-Aware Scaling
				if x1.MaxSpeed and not cur_no_damp then
					local spd = p_vel.Magnitude
					local s_factor = math.clamp(1 - (spd / x1.MaxSpeed), 0.2, 1)
					tv = tv * s_factor
				end

				local smoothing = (x1.k6 == "Point Impact" and 1) or x1.k8
				if x1.DramaMode and x1.k6 == "Point Impact" then
					smoothing = 1
				end
				d.vl = d.vl and d.vl:Lerp(tv, smoothing) or tv
				if x1.MaxSpeed and not cur_no_damp then
					if d.vl.Magnitude > x1.MaxSpeed then
						d.vl = d.vl.Unit * x1.MaxSpeed
					end
				else
					if d.vl.Magnitude > 3000 then
						d.vl = d.vl.Unit * 3000
					end
				end
				d.lv.VectorVelocity = d.vl
				if x1.AngularDamping and x1.AngularDamping > 0 then
					p.AssemblyAngularVelocity = p.AssemblyAngularVelocity
						* math.pow(1 - math.clamp(x1.AngularDamping, 0, 0.99), dt)
				end
			end
		end
	end)
end
function x4.ProcessQueue()
	local queue = x6.claim_queue
	local qi = x6.queue_idx or 1
	local qn = #queue
	if qi > qn then
		if qn > 0 then
			table.clear(queue)
			x6.queue_idx = 1
		end
		return
	end
	local start = os.clock()
	while qi <= qn do
		if os.clock() - start > 0.0015 then
			break
		end
		local p = queue[qi]
		qi = qi + 1
		if p and p:IsA("BasePart") and p:IsDescendantOf(v4) then
			x4.f1(p)
		end
	end
	x6.queue_idx = qi
	if qi > qn then
		table.clear(queue)
		x6.queue_idx = 1
	end
end
local function f4()
	if not x6.b or x1.Disabled then
		return
	end
	if x1.TgtActive and x1.Tgt and x1.Tgt.Character and x1.Tgt.Character:FindFirstChild("HumanoidRootPart") then
		x6.b.Position = x1.Tgt.Character.HumanoidRootPart.Position
		x6.b.AssemblyLinearVelocity = Vector3.zero
		return
	elseif x1.AnchorSelf and v8.Character and v8.Character:FindFirstChild("HumanoidRootPart") then
		x6.b.Position = v8.Character.HumanoidRootPart.Position
		x6.b.AssemblyLinearVelocity = Vector3.zero
		return
	elseif x6.d then
		local c = v4.CurrentCamera
		if not c then
			return
		end
		x6.p = x6.p or (x6.b.Position - c.CFrame.Position).Magnitude
		local mp = v1:GetMouseLocation()
		local r = c:ViewportPointToRay(mp.X, mp.Y)
		local tp = r.Origin + (r.Direction * x6.p)
		x6.b.Position = x6.b.Position:Lerp(tp, x9.c8)
		x6.b.AssemblyLinearVelocity = Vector3.zero
	end
end
function x4.f1(p)
	if not p:IsA("BasePart") or x7.e(p) or x6.a[p] then
		return
	end
	-- Skip parts we don't have network ownership of
	if isnetworkowner then
		local ok, owned = pcall(isnetworkowner, p)
		if ok and not owned then
			return
		end
	end
	for _, c in ipairs(p:GetChildren()) do
		if
			c:IsA("BodyAngularVelocity")
			or c:IsA("BodyForce")
			or c:IsA("BodyGyro")
			or c:IsA("BodyPosition")
			or c:IsA("BodyThrust")
			or c:IsA("BodyVelocity")
			or c:IsA("RocketPropulsion")
		then
			c:Destroy()
		end
		if c:IsA("Attachment") or c:IsA("AlignPosition") or c:IsA("Torque") then
			c:Destroy()
		end
	end
	-- Strip anti-exploit Touched/TouchEnded connections
	if getconnections then
		pcall(function()
			for _, conn in ipairs(getconnections(p.Touched)) do
				pcall(function() conn:Disable() end)
			end
			for _, conn in ipairs(getconnections(p.TouchEnded)) do
				pcall(function() conn:Disable() end)
			end
		end)
	end
	if p:FindFirstChild("BHAtt") then
		p.BHAtt:Destroy()
	end
	p.CanCollide = false
	p.Anchored = false
	p.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0)
	local a = Instance.new("Attachment", p)
	a.Name = "GRV_ATT"
	local lv = Instance.new("LinearVelocity", p)
	lv.Name = "GRV_LV"
	lv.MaxForce = x1.k4
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Attachment0 = a
	local av = Instance.new("AngularVelocity", p)
	av.Name = "GRV_AV"
	av.MaxTorque = math.huge
	av.RelativeTo = Enum.ActuatorRelativeTo.World
	av.AngularVelocity = Vector3.zero
	av.Attachment0 = a
	x6.a[p] = { at = a, lv = lv, av = av, integral = Vector3.zero }
	table.insert(x6.active_array, p)
	x6.n = x6.n + 1
end
function x4.f2(p)
	local d = x6.a[p]
	if d then
		if d.at and d.at.Parent then
			d.at:Destroy()
		end
		if d.lv and d.lv.Parent then
			d.lv:Destroy()
		end
		if d.av and d.av.Parent then
			d.av:Destroy()
		end
		x6.a[p] = nil
		local idx = table.find(x6.active_array, p)
		if idx then
			local last = #x6.active_array
			if idx ~= last then
				x6.active_array[idx] = x6.active_array[last]
			end
			table.remove(x6.active_array, last)
		end
		x6.n = math.max(0, x6.n - 1)
	end
end
function x4.f3()
	pcall(function()
		settings().Physics.AllowSleep = false
	end)
	local last_upd = 0
	table.insert(
		x6.c,
		v3.Heartbeat:Connect(function(dt)
			if time() - last_upd > 0.5 then
				last_upd = time()
				for _, p in ipairs(v2:GetPlayers()) do
					if p ~= v8 then
						pcall(function()
							p.MaximumSimulationRadius = 0
							if sethiddenproperty then
								sethiddenproperty(p, "SimulationRadius", 0)
							end
						end)
					end
				end
				pcall(function()
					if sethiddenproperty then
						sethiddenproperty(v8, "NetworkIsSleeping", false)
					end
				end)
				pcall(function()
					if setscriptable then
						setscriptable(v8, "SimulationRadius", true)
						setscriptable(v8, "MaximumSimulationRadius", true)
					end
				end)

				pcall(function()
					v8.MaximumSimulationRadius = 9e9
				end)

				pcall(function()
					if sethiddenproperty then
						sethiddenproperty(v8, "SimulationRadius", 9e9)
					elseif setsimulationradius then
						setsimulationradius(9e9)
					end
				end)

				pcall(function()
					if x6.b then
						v8.ReplicationFocus = x6.b
					else
						v8.ReplicationFocus = nil
					end
				end)
			end
		end)
	)
	table.insert(
		x6.c,
		v3.Stepped:Connect(function()
			if x1.AntiFling then
				for _, p in ipairs(v2:GetPlayers()) do
					if p ~= v8 and p.Character then
						for _, part in ipairs(p.Character:GetChildren()) do
							if part:IsA("BasePart") and part.CanCollide then
								part.CanCollide = false
							end
						end
					end
				end
			end
		end)
	)
end
function x4.f4(pos)
	if x6.b then
		v6:Create(x6.b, TweenInfo.new(x9.c7), { Position = pos }):Play()
		return
	end
	local f = Instance.new("Folder", v4)
	f.Name = "AS"
	x6.b = Instance.new("Part", f)
	x6.b.Size = x1.k2
	x6.b.Shape = "Ball"
	x6.b.Color = x1.k3
	x6.b.Anchored = true
	x6.b.CanCollide = false
	x6.b.Material = "Neon"
	x6.b.Position = pos
	x6.b.Transparency = x9.c7
	local bg = Instance.new("BillboardGui", x6.b)
	bg.Name = "Visual"
	bg.Adornee = x6.b
	bg.Size = UDim2.new(0, 20, 0, 20)
	bg.AlwaysOnTop = true
	local img = Instance.new("ImageLabel", bg)
	img.BackgroundTransparency = 1
	img.Size = UDim2.new(1, 0, 1, 0)
	img.Image = "rbxassetid://3570695787"
	img.ImageColor3 = x1.k3
	v6
		:Create(
			x6.b,
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Size = x1.k2 * 1.2 }
		)
		:Play()
	local descendants = v4:GetDescendants()
	for i, v in ipairs(descendants) do
		if v:IsA("BasePart") then
			table.insert(x6.claim_queue, v)
		end
		if i % 500 == 0 then
			task.wait()
		end
	end

	table.insert(
		x6.c,
		v4.DescendantAdded:Connect(function(v)
			if v:IsA("BasePart") then
				table.insert(x6.claim_queue, v)
			end
		end)
	)
	x6.o = true
	x7.n("Sys", "Started", 3)
	x5.st()
	table.insert(
		x6.c,
		v3.Heartbeat:Connect(function()
			f3()
			f4()
			x4.ProcessQueue()
		end)
	)
end
function x4.f5()
	if x6.b then
		x6.b.Parent:Destroy()
		x6.b = nil
	end
	if x6.sg then
		x6.sg:Destroy()
		x6.sg = nil
	end
	for p, _ in pairs(x6.a) do
		x4.f2(p)
	end
	for _, c in ipairs(x6.c) do
		c:Disconnect()
	end
	x6.c = {}
	x6.a = {}
	x6.o = false
	v7:UnbindAction("C")
	v7:UnbindAction("R")
	if x5.g then
		x5.g:Destroy()
	end
	x7.n("Sys", "Stopped", 2)
end
local x8 = {}
function x8.h(n, s, o)
	if s ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if n == "C" then
		x4.f4(v9.Hit.p)
		return Enum.ContextActionResult.Sink
	elseif n == "R" then
		x4.f5()
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end
function x8.i()
	v7:BindAction("C", x8.h, false, Enum.KeyCode.E)
	v7:BindAction("R", x8.h, false, Enum.KeyCode.Q)
	v7:BindAction("P", function(_, s)
		if s == Enum.UserInputState.Begin then
			x1.Paused = not x1.Paused
			x7.n("Sys", x1.Paused and "Paused" or "Resumed", 2)
		end
	end, false, Enum.KeyCode.P)
	v7:BindAction("Disable", function(_, s)
		if s == Enum.UserInputState.Begin then
			x1.Disabled = not x1.Disabled
			local state = x1.Disabled and "Disabled" or "Enabled"
			x7.n("Sys", "Script " .. state, 2)
			-- Update UI toggle
			if x6.disable_btn then
				x6.disable_btn.BackgroundColor3 = x1.Disabled and Color3.fromRGB(100, 255, 100)
					or Color3.fromRGB(60, 60, 60)
				-- Trigger callback logic if needed, but x1.Disabled is already set.
				-- Wait, x5.t logic runs on click. Here we manually set x1.Disabled.
				-- We should maintain the side-effects of disabling script which are inside the x5.t callback.
				-- Refactoring: The callback creates side effects.
				-- It's better to just invoke the button click logic or replicate it.
				-- Replicating side effects here:
				local v = x1.Disabled
				if x6.b then
					x6.b.Transparency = v and 1 or x9.c7
					if x6.b:FindFirstChild("Visual") then
						x6.b.Visual.Enabled = not v
					end
				end
				for _, d in pairs(x6.a) do
					if d.lv then
						d.lv.MaxForce = v and 0 or x1.k4
					end
					if d.av then
						d.av.MaxTorque = v and 0 or math.huge
					end
				end
			end
		end
	end, false, Enum.KeyCode.L)
	table.insert(
		x6.c,
		v1.InputBegan:Connect(function(i, p)
			if p or not x6.b then
				return
			end
			if i.UserInputType == Enum.UserInputType.MouseButton1 and v9.Target == x6.b then
				x6.d = true
				x6.p = (v4.CurrentCamera and (x6.b.Position - v4.CurrentCamera.CFrame.Position).Magnitude) or 50
			end
		end)
	)
	table.insert(
		x6.c,
		v1.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				x6.d = false
			end
		end)
	)

	-- Sculptor Mode Helper Functions
	local function sculptor_clear_highlights()
		for part, highlight in pairs(x6.sculptor_highlights) do
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end
		x6.sculptor_highlights = {}
	end

	local function sculptor_add_highlight(part)
		if x6.sculptor_highlights[part] then
			return
		end
		local highlight = Instance.new("SelectionBox")
		highlight.Adornee = part
		highlight.Color3 = Color3.fromRGB(0, 255, 200)
		highlight.LineThickness = 0.05
		highlight.SurfaceTransparency = 0.8
		highlight.SurfaceColor3 = Color3.fromRGB(0, 255, 200)
		highlight.Parent = part
		x6.sculptor_highlights[part] = highlight
	end

	local function sculptor_remove_highlight(part)
		if x6.sculptor_highlights[part] then
			x6.sculptor_highlights[part]:Destroy()
			x6.sculptor_highlights[part] = nil
		end
	end

	local function sculptor_select(part, add_to_selection)
		if not add_to_selection then
			-- Clear previous selection
			for p, _ in pairs(x6.sculptor_selected) do
				sculptor_remove_highlight(p)
			end
			x6.sculptor_selected = {}
		end
		if part and x6.a[part] then
			x6.sculptor_selected[part] = Vector3.zero
			sculptor_add_highlight(part)
		end
	end

	local function sculptor_deselect(part)
		x6.sculptor_selected[part] = nil
		sculptor_remove_highlight(part)
	end

	local function sculptor_get_mouse_world_pos(distance)
		local cam = v4.CurrentCamera
		if not cam then
			return nil
		end
		local mp = v1:GetMouseLocation()
		local ray = cam:ViewportPointToRay(mp.X, mp.Y)
		return ray.Origin + (ray.Direction * distance)
	end

	-- Sculptor Mode Input Handlers
	table.insert(
		x6.c,
		v1.InputBegan:Connect(function(input, processed)
			if processed or x1.k6 ~= "Sculptor" then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local target = v9.Target
				local shift_held = v1:IsKeyDown(Enum.KeyCode.LeftShift) or v1:IsKeyDown(Enum.KeyCode.RightShift)

				if target and x6.a[target] then
					-- Clicked on a controlled part
					if x6.sculptor_selected[target] then
						if shift_held then
							-- Shift+click on selected = deselect
							sculptor_deselect(target)
						else
							-- Start dragging all selected
							x6.sculptor_dragging = true
							x6.sculptor_drag_start = target.Position
							x6.sculptor_drag_distance = (v4.CurrentCamera.CFrame.Position - target.Position).Magnitude
							x6.sculptor_drag_target = target.Position
							-- Store relative offsets for all selected parts
							for part, _ in pairs(x6.sculptor_selected) do
								x6.sculptor_selected[part] = part.Position - target.Position
							end
						end
					else
						-- Click on unselected part = select it
						sculptor_select(target, shift_held)
						if not shift_held then
							-- Start dragging this part
							x6.sculptor_dragging = true
							x6.sculptor_drag_start = target.Position
							x6.sculptor_drag_distance = (v4.CurrentCamera.CFrame.Position - target.Position).Magnitude
							x6.sculptor_drag_target = target.Position
							x6.sculptor_selected[target] = Vector3.zero
						end
					end
				else
					-- Clicked on empty space - start box selection
					if not shift_held then
						for p, _ in pairs(x6.sculptor_selected) do
							sculptor_remove_highlight(p)
						end
						x6.sculptor_selected = {}
					end
					x6.sculptor_box_start = v1:GetMouseLocation()
					if not x6.sculptor_box and x6.sg then
						x6.sculptor_box = Instance.new("Frame", x6.sg)
						x6.sculptor_box.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
						x6.sculptor_box.BackgroundTransparency = 0.7
						x6.sculptor_box.BorderSizePixel = 2
						x6.sculptor_box.BorderColor3 = Color3.fromRGB(0, 255, 200)
						x6.sculptor_box.ZIndex = 50
					end
				end
			end
		end)
	)

	table.insert(
		x6.c,
		v1.InputChanged:Connect(function(input, processed)
			if x1.k6 ~= "Sculptor" then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if x6.sculptor_dragging then
					-- Update drag target position
					x6.sculptor_drag_target = sculptor_get_mouse_world_pos(x6.sculptor_drag_distance or 50)
				elseif x6.sculptor_box_start and x6.sculptor_box then
					-- Update box selection visual
					local current = v1:GetMouseLocation()
					local minX = math.min(x6.sculptor_box_start.X, current.X)
					local minY = math.min(x6.sculptor_box_start.Y, current.Y)
					local maxX = math.max(x6.sculptor_box_start.X, current.X)
					local maxY = math.max(x6.sculptor_box_start.Y, current.Y)
					x6.sculptor_box.Position = UDim2.new(0, minX, 0, minY)
					x6.sculptor_box.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
					x6.sculptor_box.Visible = true
				end
			end
		end)
	)

	table.insert(
		x6.c,
		v1.InputEnded:Connect(function(input)
			if x1.k6 ~= "Sculptor" then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if x6.sculptor_dragging then
					x6.sculptor_dragging = false
					x6.sculptor_drag_target = nil
				end
				if x6.sculptor_box_start and x6.sculptor_box then
					-- Finish box selection
					local current = v1:GetMouseLocation()
					local minX = math.min(x6.sculptor_box_start.X, current.X)
					local minY = math.min(x6.sculptor_box_start.Y, current.Y)
					local maxX = math.max(x6.sculptor_box_start.X, current.X)
					local maxY = math.max(x6.sculptor_box_start.Y, current.Y)

					-- Select parts within the box
					local cam = v4.CurrentCamera
					if cam then
						for part, _ in pairs(x6.a) do
							local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
							if
								onScreen
								and screenPos.X >= minX
								and screenPos.X <= maxX
								and screenPos.Y >= minY
								and screenPos.Y <= maxY
							then
								x6.sculptor_selected[part] = Vector3.zero
								sculptor_add_highlight(part)
							end
						end
					end

					x6.sculptor_box.Visible = false
					x6.sculptor_box_start = nil
				end
			end
		end)
	)

	-- Clear sculptor state when mode changes (handled on mode switch)
	x7.n("Rdy", "Press 'E'", 5)
end
x4.f3()
x8.i()
x5.st()
