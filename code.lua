local UIS, Plrs, RS, WS, SG, TS, CAS =
	game:GetService("UserInputService"),
	game:GetService("Players"),
	game:GetService("RunService"),
	game:GetService("Workspace"),
	game:GetService("StarterGui"),
	game:GetService("TweenService"),
	game:GetService("ContextActionService")
local LP, Mus = Plrs.LocalPlayer, Plrs.LocalPlayer:GetMouse()
if WS:FindFirstChild("SwirlVisuals") then
	WS.SwirlVisuals:Destroy()
end
local CFG = {
	MR = 2000,
	BHS = Vector3.new(5, 5, 5),
	BHC = Color3.fromRGB(255, 105, 180),
	PS = 25,
	SS = 130,
	AMF = math.huge,
	EXT = { "NoAttract", "Character" },
	MOB = false,
	SM = "Ethereal",
	PT = 4,
	CL = true,
	SNT = true,
	PL = 0.1,
	TSP = 5,
	ERC = 3,
	ERG = 100,
	ERS = 10,
	EHO = 5,
	ETA = 12,
	ETS = 0.6,
}
local SYS, GUI = {}, {}
local ENV =
	{ bh = nil, cn = {}, ap = {}, on = false, mob = UIS.TouchEnabled, drg = false, dp = 0, fc = 0, pc = 0, sl = {} }
local HLP = {}
function HLP.N(t, x, d)
	pcall(function()
		SG:SetCore("SendNotification", { Title = t, Text = x, Duration = d or 3 })
	end)
end
function HLP.Ex(p)
	if not p:IsA("BasePart") then
		return true
	end
	for _, t in ipairs(CFG.EXT) do
		if p:FindFirstChild(t) or (p.Parent and p.Parent:FindFirstChild(t)) then
			return true
		end
	end
	if p.Parent and p.Parent:FindFirstChildOfClass("Humanoid") then
		return true
	end
	if LP.Character and p:IsDescendantOf(LP.Character) then
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
GUI.G = nil
function GUI.Sld(p, t, min, max, def, cb)
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
	vl.Text = tostring(def)
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
	fl.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
	Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
	local k = Instance.new("ImageButton", sc)
	k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	k.AnchorPoint = Vector2.new(0.5, 0.5)
	k.Position = UDim2.new((def - min) / (max - min), 0, 0.5, 0)
	k.Size = UDim2.new(0, 14, 0, 14)
	k.BorderSizePixel = 0
	k.AutoButtonColor = false
	Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
	local d = false
	local function u(i)
		local pos = i.Position.X
		local rp = pos - sc.AbsolutePosition.X
		local pc = math.clamp(rp / sc.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * pc)
		TS:Create(fl, TweenInfo.new(0.05), { Size = UDim2.new(pc, 0, 1, 0) }):Play()
		TS:Create(k, TweenInfo.new(0.05), { Position = UDim2.new(pc, 0, 0.5, 0) }):Play()
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
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			d = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if d and i.UserInputType == Enum.UserInputType.MouseMovement then
			u(i)
		end
	end)
end
function GUI.Tgl(p, t, def, cb)
	local f = Instance.new("Frame", p)
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 28)
	local l = Instance.new("TextLabel", f)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(0.8, 0, 1, 0)
	l.Text = t
	l.TextColor3 = Color3.fromRGB(220, 220, 220)
	l.TextXAlignment = 0
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 14
	local s = Instance.new("TextButton", f)
	s.Text = ""
	s.AnchorPoint = Vector2.new(1, 0.5)
	s.Position = UDim2.new(1, 0, 0.5, 0)
	s.Size = UDim2.new(0, 44, 0, 24)
	s.BackgroundColor3 = def and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 55)
	s.AutoButtonColor = false
	Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
	local k = Instance.new("Frame", s)
	k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	k.Size = UDim2.new(0, 18, 0, 18)
	k.Position = def and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
	s.MouseButton1Click:Connect(function()
		def = not def
		local c = def and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 55)
		local tp = def and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		TS:Create(s, TweenInfo.new(0.2), { BackgroundColor3 = c }):Play()
		TS:Create(k, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Position = tp }):Play()
		cb(def)
	end)
end
function GUI.Stp()
	if GUI.G then
		GUI.G:Destroy()
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "Grv_" .. math.random(99)
	if gethui then
		sg.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(sg)
		sg.Parent = game:GetService("CoreGui")
	else
		sg.Parent = LP:WaitForChild("PlayerGui")
	end
	ENV.sg = sg
	GUI.G = sg
	GUI.MW(sg)
end
function GUI.MW(sg)
	local main = Instance.new("Frame", sg)
	main.Name = "M"
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	main.BackgroundTransparency = 0.15
	main.Position = UDim2.new(0, 20, 0.5, -240)
	main.Size = UDim2.new(0, 300, 0, 480)
	main.Active = true
	main.Draggable = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
	local ms = Instance.new("UIStroke", main)
	ms.Color = Color3.fromRGB(60, 60, 70)
	ms.Thickness = 1
	ms.Transparency = 0.5
	local h = Instance.new("Frame", main)
	h.BackgroundTransparency = 1
	h.Size = UDim2.new(1, 0, 0, 40)
	local t = Instance.new("TextLabel", h)
	t.BackgroundTransparency = 1
	t.Position = UDim2.new(0, 15, 0, 0)
	t.Size = UDim2.new(0.7, 0, 1, 0)
	t.Text = "Gravity Engine"
	t.TextColor3 = Color3.fromRGB(240, 240, 255)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 22
	t.TextXAlignment = 0
	local c = Instance.new("ScrollingFrame", main)
	c.BackgroundTransparency = 1
	c.Position = UDim2.new(0, 0, 0, 50)
	c.Size = UDim2.new(1, 0, 1, -60)
	c.ScrollBarThickness = 4
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
	GUI.Sld(c, "Pull Strength", -500, 500, CFG.PS, function(v)
		CFG.PS = v
	end)
	GUI.Sld(c, "Swirl Strength", 0, 1000, CFG.SS, function(v)
		CFG.SS = v
	end)
	GUI.Sld(c, "Range", 1000, 100000, CFG.MR, function(v)
		CFG.MR = v
		if LP then
			LP.MaximumSimulationRadius = v
		end
	end)
	local sp1 = Instance.new("Frame", c)
	sp1.BackgroundTransparency = 1
	sp1.Size = UDim2.new(1, 0, 0, 10)
	local dl = Instance.new("TextLabel", c)
	dl.BackgroundTransparency = 1
	dl.Size = UDim2.new(1, 0, 0, 20)
	dl.Text = "Shape Mode"
	dl.TextColor3 = Color3.fromRGB(180, 180, 190)
	dl.Font = Enum.Font.GothamBold
	dl.TextSize = 12
	dl.TextXAlignment = 0
	local db = Instance.new("TextButton", c)
	db.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	db.Size = UDim2.new(1, 0, 0, 36)
	db.Text = CFG.SM
	db.TextColor3 = Color3.fromRGB(255, 255, 255)
	db.Font = Enum.Font.GothamBold
	db.TextSize = 14
	db.AutoButtonColor = false
	Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)
	local dst = Instance.new("UIStroke", db)
	dst.Color = Color3.fromRGB(80, 80, 90)
	dst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dlst = Instance.new("ScrollingFrame", main)
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
	for _, mn in ipairs({ "Disk", "Ethereal" }) do
		local ib = Instance.new("TextButton", dlst)
		ib.Size = UDim2.new(1, -10, 0, 30)
		ib.BackgroundTransparency = 1
		ib.Text = mn
		ib.TextColor3 = Color3.fromRGB(200, 200, 200)
		ib.Font = Enum.Font.GothamMedium
		ib.TextSize = 14
		ib.ZIndex = 21
		ib.MouseButton1Click:Connect(function()
			CFG.SM = mn
			db.Text = mn
			dlst.Visible = false
		end)
	end
	local sp2 = Instance.new("Frame", c)
	sp2.BackgroundTransparency = 1
	sp2.Size = UDim2.new(1, 0, 0, 15)
	GUI.Tgl(c, "Claim Lock (Protect)", CFG.CL, function(v)
		CFG.CL = v
	end)
	GUI.Tgl(c, "Sentinel Mode (Anti-Theft)", CFG.SNT, function(v)
		CFG.SNT = v
	end)
	local sp3 = Instance.new("Frame", c)
	sp3.BackgroundTransparency = 1
	sp3.Size = UDim2.new(1, 0, 0, 15)
	local pl = Instance.new("TextLabel", c)
	pl.BackgroundTransparency = 1
	pl.TextColor3 = Color3.fromRGB(180, 180, 190)
	pl.Size = UDim2.new(1, 0, 0, 20)
	pl.Text = "Physics Tweaks:"
	pl.Font = Enum.Font.GothamBold
	pl.TextSize = 12
	pl.TextXAlignment = 0
	GUI.Sld(c, "Tween Speed", 1, 50, CFG.TSP, function(v)
		CFG.TSP = v
	end)
	GUI.Sld(c, "Ethereal Rings", 1, 20, CFG.ERC, function(v)
		CFG.ERC = v
	end)
	GUI.Sld(c, "Ring Gap", 50, 300, CFG.ERG, function(v)
		CFG.ERG = v
	end)
	GUI.Sld(c, "Ring Speed", 0, 200, CFG.ERS * 10, function(v)
		CFG.ERS = v / 10
	end)
	GUI.Sld(c, "Height Offset", 0, 100, CFG.EHO, function(v)
		CFG.EHO = v
	end)
	GUI.Sld(c, "Tilt Angle", 0, 90, CFG.ETA, function(v)
		CFG.ETA = v
	end)
	GUI.Sld(c, "Tilt Speed", 0, 50, CFG.ETS * 10, function(v)
		CFG.ETS = v / 10
	end)
	local minb = Instance.new("TextButton", h)
	minb.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
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
			main:TweenSize(UDim2.new(0, 300, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
			minb.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		else
			main:TweenSize(UDim2.new(0, 300, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
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
		GUI.G:Destroy()
	end)
end
function SYS.Net()
	settings().Physics.AllowSleep = false
	table.insert(
		ENV.cn,
		RS.Heartbeat:Connect(function()
			for _, p in ipairs(Plrs:GetPlayers()) do
				if p ~= LP then
					p.MaximumSimulationRadius = 0
					pcall(function()
						sethiddenproperty(p, "SimulationRadius", 0)
					end)
				end
			end
			LP.MaximumSimulationRadius = CFG.MR
			pcall(function()
				setsimulationradius(CFG.MR)
			end)
			if CFG.SNT then
				SYS.SNT()
			end
		end)
	)
end
local function _Vel(p, center, d, mode, pull, swirl, t)
	local wp, wc = p.Position, center
	local tc = wc - wp
	local dst = tc.Magnitude
	if dst < 0.1 then
		return Vector3.zero
	end
	local dir = tc.Unit
	local rad = math.sqrt(tc.X ^ 2 + tc.Z ^ 2)
	local vel = Vector3.zero
	local t = t or time()
	if mode == "Ethereal" then
		local rc = CFG.ERC or 2
		if not d.rIdx or d.rMax ~= rc then
			d.rIdx = math.random(1, rc)
			d.rMax = rc
			d.aOff = math.random() * math.pi * 2
		end
		local sr = CFG.ETHEREAL_START_RADIUS or 80
		local gap = CFG.ERG or 170
		local efr = sr + (d.rIdx - 1) * gap
		local spd = (0.05 - (d.rIdx - 1) * 0.01) * (CFG.ERS or 10)
		if d.rIdx % 2 == 0 then
			spd = -spd
		end
		local a = d.aOff + (t * spd)
		local tx, tz = math.cos(a) * efr, math.sin(a) * efr
		local ty = 0
		local ta = CFG.ETA or 12
		local ts = CFG.ETS or 0.2
		local sw = math.sin(t * ts + d.rIdx) * math.rad(ta)
		local trx, trz = sw, sw * 0.5
		if trx ~= 0 then
			local cy, sy = math.cos(trx), math.sin(trx)
			local ny = ty * cy - tz * sy
			local nz = ty * sy + tz * cy
			ty, tz = ny, nz
		end
		if trz ~= 0 then
			local cx, sx = math.cos(trz), math.sin(trz)
			local nx = tx * cx - ty * sx
			local ny = tx * sx + ty * cx
			tx, ty = nx, ny
		end
		local tp = center + Vector3.new(tx, ty, tz)
		local ho = CFG.EHO or 5
		if tp.Y < ho then
			tp = Vector3.new(tp.X, ho, tp.Z)
		end
		vel = (tp - wp) * (CFG.TSP * 0.15)
	else
		local up = Vector3.yAxis
		if math.abs(dir.Y) > 0.95 then
			up = Vector3.xAxis
		end
		local tan = dir:Cross(up).Unit
		if rad < 30 then
			local nz = Vector3.new(math.sin(t * 5 + wp.X), math.cos(t * 4 + wp.Y), math.sin(t * 6 + wp.Z)) * 20
			vel = (dir * -1 * pull) + nz
		else
			local sm = math.clamp(150 / dst, 1, 20)
			vel = (dir * pull) + (tan * swirl * sm)
		end
	end
	return vel
end
local function _Upd()
	if not ENV.bh then
		return
	end
	local s, e = pcall(function()
		local c = ENV.bh.Position
		ENV.fc = ENV.fc + 1
		local ac = ENV.pc
		local dt = 1
		if ac > 5000 then
			dt = 10
		elseif ac > 2500 then
			dt = 6
		elseif ac > 1000 then
			dt = 3
		end
		local et = CFG.PT or dt
		local ft = time()
		local i = 0
		for p, d in pairs(ENV.ap) do
			if not p.Parent then
				SYS.Rel(p)
				continue
			end
			i = i + 1
			if i % et ~= (ENV.fc % et) then
				continue
			end
			if d.av then
				d.av:Destroy()
				d.av = nil
			end
			local tc = c - p.Position
			local dist = tc.Magnitude
			if not CFG.CL and dist > CFG.MR then
				continue
			end
			local rf = Vector3.zero
			if CFG.CL then
				if p.Position.Y < -50 then
					p.CFrame = CFrame.new(c + Vector3.new(0, 50, 0))
					p.AssemblyLinearVelocity = Vector3.zero
				end
				if dist > 500 then
					rf = (c - p.Position).Unit * ((dist - 500) * 5)
				end
			end
			if dist > 0.1 then
				local tv = _Vel(p, c, d, CFG.SM, CFG.PS, CFG.SS, ft)
				if not d.lVel then
					d.lVel = Vector3.zero
				end
				local el = CFG.CL and 0.8 or CFG.PL
				local sv = d.lVel:Lerp(tv + rf, el)
				d.lVel = sv
				d.lv.VectorVelocity = sv
			end
		end
	end)
	if not s then
		warn("PE", e)
	end
end
local function _Drg()
	if not ENV.bh or not ENV.drg then
		return
	end
	local c = WS.CurrentCamera
	if not c then
		return
	end
	if not ENV.dp then
		ENV.dp = (ENV.bh.Position - c.CFrame.Position).Magnitude
	end
	local mp = UIS:GetMouseLocation()
	local r = c:ViewportPointToRay(mp.X, mp.Y)
	local tp = r.Origin + (r.Direction * ENV.dp)
	ENV.bh.Position = ENV.bh.Position:Lerp(tp, 0.25)
	ENV.bh.AssemblyLinearVelocity = Vector3.zero
end
function SYS.SNT()
	if not CFG.SNT then
		return
	end
	local BS = 20
	if not ENV.sl or #ENV.sl == 0 then
		ENV.sl = {}
		for p, d in pairs(ENV.ap) do
			table.insert(ENV.sl, { p, d })
		end
	end
	if not ENV.idx then
		ENV.idx = 1
	end
	local bad = {
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
	local chk = 0
	local max = #ENV.sl
	while chk < BS do
		if ENV.idx > max then
			ENV.idx = 1
			ENV.sl = {}
			for p, d in pairs(ENV.ap) do
				table.insert(ENV.sl, { p, d })
			end
			max = #ENV.sl
			if max == 0 then
				break
			end
		end
		local it = ENV.sl[ENV.idx]
		local p = it[1]
		local d = it[2]
		ENV.idx = ENV.idx + 1
		chk = chk + 1
		if p and p.Parent then
			for _, c in ipairs(p:GetChildren()) do
				if table.find(bad, c.ClassName) then
					local safe = false
					if c == d.lv or c == d.att or c == d.av then
						safe = true
					end
					if not safe then
						pcall(function()
							c:Destroy()
						end)
					end
				end
			end
			if p.CanTouch then
				p.CanTouch = false
			end
			if not p.Locked then
				p.Locked = true
			end
		end
	end
end
function SYS.Frc(p)
	if HLP.Ex(p) or ENV.ap[p] then
		return
	end
	for _, c in ipairs(p:GetChildren()) do
		if c:IsA("BodyMover") or c:IsA("Constraint") then
			c:Destroy()
		end
	end
	if p:FindFirstChild("BHAtt") then
		p.BHAtt:Destroy()
	end
	p.CanCollide = false
	p.Anchored = false
	local a = Instance.new("Attachment", p)
	a.Name = "BHAtt"
	local lv = Instance.new("LinearVelocity", p)
	lv.MaxForce = CFG.AMF
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Attachment0 = a
	ENV.ap[p] = { att = a, lv = lv, osz = p.Size }
	ENV.pc = ENV.pc + 1
end
function SYS.Rel(p)
	local d = ENV.ap[p]
	if d then
		if d.att and d.att.Parent then
			d.att:Destroy()
		end
		if d.lv and d.lv.Parent then
			d.lv:Destroy()
		end
		ENV.ap[p] = nil
		ENV.pc = math.max(0, ENV.pc - 1)
	end
end
function SYS.Spawn(pos)
	if ENV.bh then
		TS:Create(ENV.bh, TweenInfo.new(0.1), { Position = pos }):Play()
		return
	end
	local f = Instance.new("Folder", WS)
	f.Name = "AttrSys"
	ENV.bh = Instance.new("Part", f)
	ENV.bh.Size = CFG.BHS
	ENV.bh.Shape = "Ball"
	ENV.bh.Color = CFG.BHC
	ENV.bh.Anchored = true
	ENV.bh.CanCollide = false
	ENV.bh.Material = "Neon"
	ENV.bh.Position = pos
	ENV.bh.Transparency = 0.1
	ENV.drg = false
	TS:Create(
		ENV.bh,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Size = CFG.BHS * 1.2 }
	):Play()
	for _, v in ipairs(WS:GetDescendants()) do
		SYS.Frc(v)
	end
	table.insert(
		ENV.cn,
		WS.DescendantAdded:Connect(function(v)
			SYS.Frc(v)
		end)
	)
	ENV.on = true
	HLP.N("Attr", "Spawned. Drag to move.", 3)
	GUI.Stp()
end
function SYS.Kill()
	if ENV.bh then
		ENV.bh.Parent:Destroy()
		ENV.bh = nil
	end
	if ENV.sg then
		ENV.sg:Destroy()
		ENV.sg = nil
	end
	for p, _ in pairs(ENV.ap) do
		SYS.Rel(p)
	end
	for _, c in ipairs(ENV.cn) do
		c:Disconnect()
	end
	ENV.cn = {}
	ENV.ap = {}
	ENV.on = false
	CAS:UnbindAction("CBH")
	CAS:UnbindAction("RBH")
	if GUI.G then
		GUI.G:Destroy()
	end
	HLP.N("Attr", "Removed.", 2)
end
local INP = {}
function INP.H(n, s, o)
	if s ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if n == "CBH" then
		SYS.Spawn(Mus.Hit.p)
		return Enum.ContextActionResult.Sink
	elseif n == "RBH" then
		SYS.Kill()
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end
function INP.Init()
	CAS:BindAction("CBH", INP.H, false, Enum.KeyCode.E)
	CAS:BindAction("RBH", INP.H, false, Enum.KeyCode.Q)
	table.insert(
		ENV.cn,
		UIS.InputBegan:Connect(function(i, p)
			if p or not ENV.bh then
				return
			end
			if i.UserInputType == Enum.UserInputType.MouseButton1 and Mus.Target == ENV.bh then
				ENV.drg = true
				ENV.dp = (WS.CurrentCamera and (ENV.bh.Position - WS.CurrentCamera.CFrame.Position).Magnitude) or 50
			end
		end)
	)
	table.insert(
		ENV.cn,
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				ENV.drg = false
			end
		end)
	)
	HLP.N("Ready", "Press 'E'.", 5)
end
SYS.Net()
INP.Init()
table.insert(ENV.cn, RS.Heartbeat:Connect(_Upd))
table.insert(ENV.cn, RS.RenderStepped:Connect(_Drg))
local sc
sc = RS.Heartbeat:Connect(function()
	if not sc.Connected then
		SYS.Kill()
	end
end)
table.insert(ENV.cn, sc)
GUI.Stp()
HLP.N("Gravity", "Loaded.", 3)
