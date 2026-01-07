--!native
local v1, v2, v3, v4, v5, v6, v7 =
	game:GetService("UserInputService"),
	game:GetService("Players"),
	game:GetService("RunService"),
	game:GetService("Workspace"),
	game:GetService("StarterGui"),
	game:GetService("TweenService"),
	game:GetService("ContextActionService")
local v8, v9 = v2.LocalPlayer, v2.LocalPlayer:GetMouse()
if v1.TouchEnabled and not v1.KeyboardEnabled then
	v8:Kick("PC ONLY. GET OFF MOBILE.")
	while true do
	end
end
local x9 = { c1 = 0.15, c2 = 0.05, c3 = 0.01, c4 = 0.2, c5 = 0.6, c6 = 0.8, c7 = 0.1, c8 = 0.25 }
local ANTI_SLEEP = Vector3.new(0, 0.01, 0)
local x1 = {
	k1 = 2000,
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
}
x1.S = {}
for m, d in pairs(x2) do
	x1.S[m] = table.clone(d)
end
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
	pre = {},
	pre_buffer = table.create(200),
}
local function px(md, t, c)
	local r = x6.pre_buffer
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
	x6.pre[md] = table.clone(r)
end
local x7 = {}
function x7.n(t, x, d)
	pcall(function()
		v5:SetCore("SendNotification", { Title = t, Text = x, Duration = d or 3 })
	end)
end
function x7.e(p)
	if not p:IsA("BasePart") then
		return true
	end
	for _, t in ipairs(x1.k5) do
		if p:FindFirstChild(t) or (p.Parent and p.Parent:FindFirstChild(t)) then
			return true
		end
	end
	if p.Parent and p.Parent:FindFirstChildOfClass("Humanoid") then
		return true
	end
	if v8.Character and p:IsDescendantOf(v8.Character) then
		return true
	end
	if p.Anchored then
		return true
	end
	if p.Name == "Baseplate" or p.Name == "HumanoidRootPart" then
		return true
	end
	return false
end
x5.g = nil
function x5.s(p, t, mn, mx, df, cb)
	df = df or mn
	local f = Instance.new("Frame", p)
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 36)
	local l = Instance.new("TextLabel", f)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, 18)
	l.Text = t
	l.TextColor3 = Color3.fromRGB(220, 220, 220)
	l.TextXAlignment = 0
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 13
	local vl = Instance.new("TextLabel", f)
	vl.BackgroundTransparency = 1
	vl.Position = UDim2.new(1, -50, 0, 0)
	vl.Size = UDim2.new(0, 50, 0, 18)
	vl.Text = tostring(df)
	vl.TextColor3 = Color3.fromRGB(220, 220, 220)
	vl.TextXAlignment = 1
	vl.Font = Enum.Font.GothamBold
	vl.TextSize = 13
	local sc = Instance.new("Frame", f)
	sc.BackgroundTransparency = 1
	sc.Position = UDim2.new(0, 0, 0, 22)
	sc.Size = UDim2.new(1, 0, 0, 6)
	local sb = Instance.new("Frame", sc)
	sb.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	sb.BorderSizePixel = 0
	sb.Size = UDim2.new(1, 0, 1, 0)
	Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
	local fl = Instance.new("Frame", sb)
	fl.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
	fl.BorderSizePixel = 0
	fl.Size = UDim2.new((df - mn) / (mx - mn), 0, 1, 0)
	Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
	local k = Instance.new("ImageButton", sc)
	k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	k.AnchorPoint = Vector2.new(0.5, 0.5)
	k.Position = UDim2.new((df - mn) / (mx - mn), 0, 0.5, 0)
	k.Size = UDim2.new(0, 14, 0, 14)
	k.BorderSizePixel = 0
	k.AutoButtonColor = false
	Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
	local d = false
	local function u(i)
		local pos = i.Position.X
		local rp = pos - sc.AbsolutePosition.X
		local pc = math.clamp(rp / sc.AbsoluteSize.X, 0, 1)
		local v = math.floor(mn + (mx - mn) * pc + 0.5)
		v6:Create(fl, TweenInfo.new(0.05), { Size = UDim2.new(pc, 0, 1, 0) }):Play()
		v6:Create(k, TweenInfo.new(0.05), { Position = UDim2.new(pc, 0, 0.5, 0) }):Play()
		vl.Text = tostring(v)
		cb(v)
	end
	k.MouseButton1Down:Connect(function()
		d = true
	end)
	sb.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			d = true
			u(i)
		end
	end)
	v1.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			d = false
		end
	end)
	v1.InputChanged:Connect(function(i)
		if d and i.UserInputType == Enum.UserInputType.MouseMovement then
			u(i)
		end
	end)
end
function x5.t(p, t, df, cb)
	local f = Instance.new("Frame", p)
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 30)
	local l = Instance.new("TextLabel", f)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(0.8, 0, 1, 0)
	l.Text = t
	l.TextColor3 = Color3.fromRGB(220, 220, 220)
	l.TextXAlignment = 0
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 13
	local b = Instance.new("TextButton", f)
	b.BackgroundColor3 = df and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
	b.Position = UDim2.new(1, -24, 0.5, -12)
	b.Size = UDim2.new(0, 24, 0, 24)
	b.Text = ""
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function()
		df = not df
		b.BackgroundColor3 = df and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
		cb(df)
	end)
end
function x5.b(p, t, cb)
	local f = Instance.new("Frame", p)
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 30)
	local b = Instance.new("TextButton", f)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	b.Size = UDim2.new(1, 0, 1, 0)
	b.Text = t
	b.TextColor3 = Color3.fromRGB(220, 220, 220)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.MouseButton1Click:Connect(function()
		cb(b)
	end)
end
function x5.h(p, t)
	local l = Instance.new("TextLabel", p)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, 20)
	l.Text = t
	l.TextColor3 = Color3.fromRGB(150, 150, 255)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
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
	local m = Instance.new("Frame", sg)
	m.Name = "M"
	m.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	m.BackgroundTransparency = 0.15
	m.Position = UDim2.new(0, 20, 0.5, -240)
	m.Size = UDim2.new(0, 300, 0, 480)
	m.Active = true
	m.Draggable = true
	Instance.new("UICorner", m).CornerRadius = UDim.new(0, 12)
	local ms = Instance.new("UIStroke", m)
	ms.Color = Color3.fromRGB(60, 60, 70)
	ms.Thickness = 1
	ms.Transparency = 0.5
	local h = Instance.new("Frame", m)
	h.BackgroundTransparency = 1
	h.Size = UDim2.new(1, 0, 0, 40)
	local t = Instance.new("TextLabel", h)
	t.BackgroundTransparency = 1
	t.Position = UDim2.new(0, 15, 0, 0)
	t.Size = UDim2.new(0.7, 0, 1, 0)
	t.Text = "GSettings"
	t.TextColor3 = Color3.fromRGB(240, 240, 255)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 22
	t.TextXAlignment = 0
	local c = Instance.new("ScrollingFrame", m)
	c.BackgroundTransparency = 1
	c.Position = UDim2.new(0, 0, 0, 50)
	c.Size = UDim2.new(1, 0, 1, -95)
	c.ScrollBarThickness = 4

	local am = Instance.new("Frame", sg)
	am.Name = "AM"
	am.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	am.BackgroundTransparency = 0.1
	am.Position = UDim2.new(0, 330, 0.5, -240)
	am.Size = UDim2.new(0, 250, 0, 350)
	am.Visible = false
	am.Active = true
	am.Draggable = true
	Instance.new("UICorner", am).CornerRadius = UDim.new(0, 12)
	local ams = Instance.new("UIStroke", am)
	ams.Color = Color3.fromRGB(80, 80, 200)
	ams.Thickness = 1
	ams.Transparency = 0.5

	local ah = Instance.new("Frame", am)
	ah.BackgroundTransparency = 1
	ah.Size = UDim2.new(1, 0, 0, 40)
	local at = Instance.new("TextLabel", ah)
	at.BackgroundTransparency = 1
	at.Position = UDim2.new(0, 15, 0, 0)
	at.Size = UDim2.new(0.7, 0, 1, 0)
	at.Text = "Advanced (advanced shits!)"
	at.TextColor3 = Color3.fromRGB(200, 200, 255)
	at.Font = Enum.Font.GothamBold
	at.TextSize = 18
	at.TextXAlignment = 0

	local ac = Instance.new("ScrollingFrame", am)
	ac.BackgroundTransparency = 1
	ac.Position = UDim2.new(0, 0, 0, 50)
	ac.Size = UDim2.new(1, 0, 1, -60)
	ac.ScrollBarThickness = 4
	ac.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ac.CanvasSize = UDim2.new(0, 0, 0, 0)
	Instance.new("UIListLayout", ac).Padding = UDim.new(0, 8)
	local ap = Instance.new("UIPadding", ac)
	ap.PaddingLeft = UDim.new(0, 15)
	ap.PaddingRight = UDim.new(0, 15)

	x5.s(ac, "Damping", 0, 50, x1.Damping * 10, function(v)
		x1.Damping = v / 10
	end)
	x5.s(ac, "Integral Gain", 0, 100, x1.Ki * 10, function(v)
		x1.Ki = v / 10
	end)
	if not x1.MaxSpeed then
		x1.MaxSpeed = 500
	end
	x5.s(ac, "Max Speed", 50, 1000, x1.MaxSpeed, function(v)
		x1.MaxSpeed = v
	end)
	if not x1.AngularDamping then
		x1.AngularDamping = 0.5
	end
	x5.s(ac, "Angular Damp", 0, 10, x1.AngularDamping * 10, function(v)
		x1.AngularDamping = v / 10
	end)
	if not x1.VerticalStiffness then
		x1.VerticalStiffness = 1.0
	end
	x5.s(ac, "Vert Stiffness", 1, 50, x1.VerticalStiffness * 10, function(v)
		x1.VerticalStiffness = v / 10
	end)

	local ab = Instance.new("TextButton", c)
	ab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	ab.Size = UDim2.new(1, 0, 0, 30)
	ab.Text = "Advanced Settings"
	ab.TextColor3 = Color3.fromRGB(150, 150, 255)
	ab.Font = Enum.Font.GothamBold
	ab.TextSize = 14
	ab.AutoButtonColor = false
	Instance.new("UICorner", ab).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", ab).Color = Color3.fromRGB(60, 60, 80)

	ab.MouseButton1Click:Connect(function()
		am.Visible = not am.Visible
		ab.TextColor3 = am.Visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 255)
		ab.BackgroundColor3 = am.Visible and Color3.fromRGB(60, 60, 150) or Color3.fromRGB(30, 30, 35)
	end)
	c.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	c.AutomaticCanvasSize = Enum.AutomaticSize.Y
	c.CanvasSize = UDim2.new(0, 0, 0, 0)
	local l = Instance.new("UIListLayout", c)
	l.Padding = UDim.new(0, 8)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local p = Instance.new("UIPadding", c)
	p.PaddingLeft = UDim.new(0, 15)
	p.PaddingRight = UDim.new(0, 15)
	p.PaddingTop = UDim.new(0, 5)
	p.PaddingBottom = UDim.new(0, 20)
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
		gscl.Padding = UDim.new(0, 8)
		gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local scl = Instance.new("UIListLayout", sc)
		scl.Padding = UDim.new(0, 8)
		scl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local s = x3()
		x5.h(gsc, "- GLOBAL SETTINGS -")
		x5.t(gsc, "Anchor to Self", x1.AnchorSelf, function(v)
			x1.AnchorSelf = v
		end)
		x5.t(gsc, "Disable Gravity", x1.Disabled, function(v)
			x1.Disabled = v
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
		end)
		x5.t(gsc, "Enable Anchor", x1.TgtActive, function(v)
			x1.TgtActive = v
		end)
		x5.t(gsc, "Impact All", x1.PI_All, function(v)
			x1.PI_All = v
		end)

		local l_btn = Instance.new("TextButton", gsc)
		l_btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		l_btn.Size = UDim2.new(1, 0, 0, 30)
		l_btn.Text = "LAUNCH"
		l_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		l_btn.Font = Enum.Font.GothamBlack
		l_btn.TextSize = 14
		Instance.new("UICorner", l_btn).CornerRadius = UDim.new(0, 6)
		l_btn.Visible = x1.ImpactManual

		l_btn.MouseButton1Click:Connect(function()
			x1.IsLaunching = not x1.IsLaunching
			l_btn.Text = x1.IsLaunching and "RESET" or "LAUNCH"
			l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(60, 180, 255) or Color3.fromRGB(255, 60, 60)
		end)
		table.insert(
			x6.c,
			v3.Heartbeat:Connect(function()
				if x1.ImpactManual then
					l_btn.Text = x1.IsLaunching and "RESET" or "LAUNCH"
					l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(60, 180, 255)
						or Color3.fromRGB(255, 60, 60)
				elseif x1.k6 == "Slingshot" and x1.SlingshotManual then
					l_btn.Visible = true
					l_btn.Text = x1.IsLaunching and "RESET" or "LAUNCH"
					l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(60, 180, 255)
						or Color3.fromRGB(255, 60, 60)
				else
					l_btn.Visible = false
				end
			end)
		)
		local tn = "Select Target >"
		if x1.Tgt then
			tn = "Target: " .. (x1.Tgt.DisplayName or x1.Tgt.Name)
		end
		local tdb = Instance.new("TextButton", gsc)
		tdb.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		tdb.Size = UDim2.new(1, 0, 0, 36)
		tdb.Text = tn
		tdb.TextColor3 = Color3.fromRGB(255, 255, 255)
		tdb.Font = Enum.Font.GothamBold
		tdb.TextSize = 14
		tdb.AutoButtonColor = false
		Instance.new("UICorner", tdb).CornerRadius = UDim.new(0, 6)
		local tdlst = Instance.new("ScrollingFrame", m)
		tdlst.Visible = false
		tdlst.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		tdlst.Position = UDim2.new(1, 10, 0, 0)
		tdlst.Size = UDim2.new(0, 160, 1, 0)
		tdlst.BorderSizePixel = 0
		tdlst.ZIndex = 25
		tdlst.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tdlst.CanvasSize = UDim2.new(0, 0, 0, 0)
		tdlst.ScrollBarThickness = 2
		Instance.new("UICorner", tdlst).CornerRadius = UDim.new(0, 8)
		local tdll = Instance.new("UIListLayout", tdlst)
		tdll.Padding = UDim.new(0, 2)
		tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center
		tdb.MouseButton1Click:Connect(function()
			tdlst.Visible = not tdlst.Visible
			tdlst:ClearAllChildren()
			local tdll = Instance.new("UIListLayout", tdlst)
			tdll.Padding = UDim.new(0, 2)
			tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center
			for _, pl in ipairs(v2:GetPlayers()) do
				local ib = Instance.new("TextButton", tdlst)
				ib.Size = UDim2.new(1, -10, 0, 30)
				ib.BackgroundTransparency = 1
				ib.Text = pl.DisplayName or pl.Name
				ib.TextColor3 = Color3.fromRGB(200, 200, 200)
				ib.Font = Enum.Font.GothamMedium
				ib.TextSize = 14
				ib.ZIndex = 26
				ib.MouseButton1Click:Connect(function()
					x1.Tgt = pl
					tdb.Text = "Target: " .. (pl.DisplayName or pl.Name)
					tdlst.Visible = false
				end)
			end
		end)
		local ctb = Instance.new("TextButton", gsc)
		ctb.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		ctb.Size = UDim2.new(1, 0, 0, 30)
		ctb.Text = "Clear Target"
		ctb.TextColor3 = Color3.fromRGB(255, 255, 255)
		ctb.Font = Enum.Font.GothamBold
		ctb.TextSize = 13
		ctb.AutoButtonColor = false
		Instance.new("UICorner", ctb).CornerRadius = UDim.new(0, 6)
		ctb.MouseButton1Click:Connect(function()
			x1.Tgt = nil
			tdb.Text = "Select Target >"
		end)
		x5.h(sc, "- SHAPE SETTINGS -")
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
		end
	end
	x5.up = f1
	local db = Instance.new("TextButton", c)
	db.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	db.Size = UDim2.new(1, 0, 0, 36)
	db.Text = x1.k6
	db.TextColor3 = Color3.fromRGB(255, 255, 255)
	db.Font = Enum.Font.GothamBold
	db.TextSize = 14
	db.AutoButtonColor = false
	Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)
	local dst = Instance.new("UIStroke", db)
	dst.Color = Color3.fromRGB(80, 80, 90)
	dst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dlst = Instance.new("ScrollingFrame", m)
	dlst.Visible = false
	dlst.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	dlst.Position = UDim2.new(1, 10, 0, 0)
	dlst.Size = UDim2.new(0, 160, 1, 0)
	dlst.BorderSizePixel = 0
	dlst.ZIndex = 20
	dlst.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dlst.CanvasSize = UDim2.new(0, 0, 0, 0)
	dlst.ScrollBarThickness = 2
	Instance.new("UICorner", dlst).CornerRadius = UDim.new(0, 8)
	local dll = Instance.new("UIListLayout", dlst)
	dll.Padding = UDim.new(0, 2)
	dll.HorizontalAlignment = Enum.HorizontalAlignment.Center
	db.MouseButton1Click:Connect(function()
		dlst.Visible = not dlst.Visible
	end)
	for _, mn in ipairs({
		"Big Ring Things",
		"Celestial Ribbon",
		"Hollow Worm",
		"Cosmic Comet",
		"Point Impact",
		"Orbital Shell",
		"Vortex Funnel",
		"Quantum Atoms",
		"Halo Ring",
		"Slingshot",
		"Gods Call",
		"Deflect",
		"Shield Wall",
	}) do
		local ib = Instance.new("TextButton", dlst)
		ib.Size = UDim2.new(1, -10, 0, 30)
		ib.BackgroundTransparency = 1
		ib.Text = mn
		ib.TextColor3 = Color3.fromRGB(200, 200, 200)
		ib.Font = Enum.Font.GothamMedium
		ib.TextSize = 14
		ib.ZIndex = 21
		ib.MouseButton1Click:Connect(function()
			x1.k6 = mn
			db.Text = mn
			dlst.Visible = false
			for _, d in pairs(x6.a) do
				d.v1, d.v2, d.v3 = nil, nil, nil
				d.v4, d.v5, d.v6 = nil, nil, nil
				d.v7 = nil
			end
			x5.st()
		end)
	end
	x5.s(c, "Tween Speed", 1, 50, x1.k10, function(v)
		x1.k10 = v
	end)
	f1()
	local minb = Instance.new("TextButton", h)
	minb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	minb.Position = UDim2.new(1, -65, 0, 10)
	minb.Size = UDim2.new(0, 20, 0, 20)
	minb.Text = ""
	minb.AutoButtonColor = false
	Instance.new("UICorner", minb).CornerRadius = UDim.new(1, 0)
	local im = false
	minb.MouseButton1Click:Connect(function()
		im = not im
		c.Visible = not im
		dlst.Visible = false
		if im then
			m:TweenSize(UDim2.new(0, 300, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
			minb.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		else
			m:TweenSize(UDim2.new(0, 300, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
			minb.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		end
	end)
	local clb = Instance.new("TextButton", h)
	clb.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	clb.Position = UDim2.new(1, -30, 0, 10)
	clb.Size = UDim2.new(0, 20, 0, 20)
	clb.Text = ""
	clb.AutoButtonColor = false
	Instance.new("UICorner", clb).CornerRadius = UDim.new(1, 0)
	clb.MouseButton1Click:Connect(function()
		x5.g:Destroy()
	end)
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
		local s = (c.k13 or 40) * 100.0
		local radius = c.k11 or 0
		if x1.ImpactManual then
			if not x1.IsLaunching then
				s = 1
				radius = 35
			else
				s = 500
				radius = 0
			end
		end
		if not d.v5 then
			d.v5 = math.random() - 0.5
		end
		if not d.v4 then
			d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		end
		local cx, sx = math.cos(t * s), math.sin(t * s)
		local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx, d.v4.Y + d.v5, d.v4.X * sx + d.v4.Z * cx).Unit
		return ((cen + (rd * radius)) - wp) * (100 * x9.c1)
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
	end
	return ANTI_SLEEP
end
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
		local no_damp = { ["Slingshot"] = true, ["Point Impact"] = true, ["Deflect"] = true }
		for p, d in pairs(x6.a) do
			if not p.Parent then
				x4.f2(p)
				continue
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
			if tc.Magnitude > x1.k1 then
				continue
			end
			if tc.Magnitude > x9.c7 then
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
				if x1.Damping and x1.Damping > 0 and not no_damp[x1.k6] then
					tv = tv - (p_vel * x1.Damping)
				end

				-- Energy-Aware Scaling
				if x1.MaxSpeed and not no_damp[x1.k6] then
					local spd = p_vel.Magnitude
					local s_factor = math.clamp(1 - (spd / x1.MaxSpeed), 0.2, 1)
					tv = tv * s_factor
				end

				local smoothing = (x1.k6 == "Point Impact" and 1) or x1.k8
				if x1.DramaMode and x1.k6 == "Point Impact" then
					smoothing = 1
				end
				d.vl = d.vl and d.vl:Lerp(tv, smoothing) or tv
				if x1.MaxSpeed and not no_damp[x1.k6] then
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
	local processed = 0
	while #x6.claim_queue > 0 and processed < 10 do
		local p = table.remove(x6.claim_queue, 1)
		if p and p:IsA("BasePart") and p:IsDescendantOf(v4) then
			x4.f1(p)
		end
		processed = processed + 1
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
		x6.n = math.max(0, x6.n - 1)
	end
end
function x4.f3()
	pcall(function()
		settings().Physics.AllowSleep = false
	end)
	table.insert(
		x6.c,
		v3.Heartbeat:Connect(function(dt)
			for _, p in ipairs(v2:GetPlayers()) do
				if p ~= v8 then
					pcall(function()
						p.MaximumSimulationRadius = 0
						sethiddenproperty(p, "SimulationRadius", 0)
					end)
				end
			end
			pcall(function()
				v8.MaximumSimulationRadius = x1.k1
				setsimulationradius(x1.k1)
				if x6.b then
					v8.ReplicationFocus = x6.b
				else
					v8.ReplicationFocus = nil
				end
			end)
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
	x7.n("Rdy", "Press 'E'", 5)
end
x4.f3()
x8.i()
x5.st()
