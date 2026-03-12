--!native
-- Project Gravity: Modular Edition
-- Robust, Extensible, and Performant Physics Engine

local function safe_service(name)
	local service = game:GetService(name)
	if cloneref then return cloneref(service) end
	return service
end

local UserInputService, Players, RunService, Workspace, StarterGui, TweenService, ContextActionService =
	safe_service("UserInputService"),
	safe_service("Players"),
	safe_service("RunService"),
	safe_service("Workspace"),
	safe_service("StarterGui"),
	safe_service("TweenService"),
	safe_service("ContextActionService")
local HttpService = safe_service("HttpService")

if setthreadidentity then pcall(function() setthreadidentity(8) end) end

local LocalPlayer, Mouse = Players.LocalPlayer, Players.LocalPlayer:GetMouse()
local Constants = { c1 = 0.15, c2 = 0.05, c3 = 0.01, c4 = 0.2, c5 = 0.6, c6 = 0.8, c7 = 0.1, c8 = 0.25 }
local ANTI_SLEEP = Vector3.new(0, 0.01, 0)

-- Global State & Settings
local Config = {
	k1 = 2000,
	k2 = Vector3.new(5, 5, 5),
	k3 = Color3.fromRGB(255, 105, 180),
	k4 = math.huge,
	k5 = { "NoAttract", "Character" },
	k6 = "Celestial Ribbon",
	k7 = 0.5,
	k8 = 0.8,
	k9 = 50,
	k10 = 20,
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
	UIVisible = true,
}

local State = {
	b = nil,
	c = {},
	a = {},
	o = false,
	d = false,
	p = 0,
	f = 0,
	n = 0,
	pi_timer = 0,
	pi_targets = {},
	claim_queue = {},
	active_array = {},
	favorites = {},
	mode_registry = {}, -- Modular Mode Registry
	sculptor_selected = {},
	sculptor_highlights = {},
}

local PhysicsEngine = {}
local UIManager = { g = nil }
local Utils = {}
local Managers = {}

-- Registry Helper
local function register_mode(name, config, callbacks)
	State.mode_registry[name] = {
		Config = config,
		Init = callbacks.Init,
		Update = callbacks.Update,
		UI = callbacks.UI
	}
end

-- Utilities
function Utils.n(t, x, d) pcall(function() StarterGui:SetCore("SendNotification", { Title = t, Text = x, Duration = d or 3 }) end) end
function Utils.e(p)
	if not p:IsA("BasePart") then return true end
	for _, t in ipairs(Config.k5) do if p:FindFirstChild(t) or (p.Parent and p.Parent:FindFirstChild(t)) then return true end end
	local target = p
	while target and target ~= Workspace and target ~= game do
		if target:IsA("Model") and (target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("AnimationController")) then return true end
		if target:IsA("Accessory") or target:IsA("Tool") then return true end
		target = target.Parent
	end
	if LocalPlayer.Character and p:IsDescendantOf(LocalPlayer.Character) then return true end
	if p.Anchored then return true end
	local n = p.Name
	if n == "Baseplate" or n == "HumanoidRootPart" or n == "Terrain" or n == "Handle" then return true end
	return false
end

-- Persistent Storage Logic
local function sanitize(t)
	local res = {}
	for k, v in pairs(t) do
		if typeof(v) == "Vector3" then res[k] = { __type = "Vector3", x = v.X, y = v.Y, z = v.Z }
		elseif typeof(v) == "Color3" then res[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
		elseif typeof(v) == "number" then
			if v == math.huge then res[k] = { __type = "inf" }
			elseif v == -math.huge then res[k] = { __type = "-inf" }
			else res[k] = v end
		elseif typeof(v) == "table" then res[k] = sanitize(v)
		elseif typeof(v) == "Instance" or typeof(v) == "function" or typeof(v) == "userdata" then -- skip
		else res[k] = v end
	end
	return res
end

local function save_settings()
	if not writefile then return end
	local s = { Config = sanitize(Config), favorites = State.favorites }
	pcall(function() writefile("project_gravity_settings.json", HttpService:JSONEncode(s)) end)
end

local function load_settings()
	if not readfile or not isfile or not isfile("project_gravity_settings.json") then return end
	local ok, res = pcall(function() return HttpService:JSONDecode(readfile("project_gravity_settings.json")) end)
	if ok and typeof(res) == "table" then
		if res.Config then
			for k, v in pairs(res.Config) do
				if typeof(v) == "table" and v.__type == "Vector3" then Config[k] = Vector3.new(v.x, v.y, v.z)
				elseif typeof(v) == "table" and v.__type == "Color3" then Config[k] = Color3.new(v.r, v.g, v.b)
				elseif typeof(v) == "table" and v.__type == "inf" then Config[k] = math.huge
				elseif typeof(v) == "table" and v.__type == "-inf" then Config[k] = -math.huge
				else Config[k] = v end
			end
		end
		if res.favorites then State.favorites = res.favorites end
	end
end


-- Core Physics Engine


function PhysicsEngine.f1(p)
	if not p:IsA("BasePart") or Utils.e(p) or State.a[p] then return end
	for _, c in ipairs(p:GetChildren()) do
		if c:IsA("BodyAngularVelocity") or c:IsA("BodyForce") or c:IsA("BodyGyro") or c:IsA("BodyPosition") or c:IsA("BodyThrust") or c:IsA("BodyVelocity") or c:IsA("RocketPropulsion") or c:IsA("Attachment") or c:IsA("AlignPosition") or c:IsA("Torque") then
			c:Destroy()
		end
	end
	p.CanCollide = false; p.Anchored = false
	p.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0)
	local a = Instance.new("Attachment", p); a.Name = "GRV_ATT"
	local lv = Instance.new("LinearVelocity", p); lv.Name = "GRV_LV"; lv.MaxForce = Config.k4; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.RelativeTo = Enum.ActuatorRelativeTo.World; lv.Attachment0 = a
	local av = Instance.new("AngularVelocity", p); av.Name = "GRV_AV"; av.MaxTorque = math.huge; av.RelativeTo = Enum.ActuatorRelativeTo.World; av.AngularVelocity = Vector3.zero; av.Attachment0 = a
	
	local part_data = { at = a, lv = lv, av = av, UserInputService = nil, Players = nil, RunService = nil, Workspace = nil, StarterGui = nil, TweenService = nil, rot_axis = nil }
	
	-- Call Init if current mode has it
	local mode = State.mode_registry[Config.k6]
	if mode and mode.Init then mode.Init(part_data) end
	
	State.a[p] = part_data
	table.insert(State.active_array, p)
	State.n = State.n + 1
end

function PhysicsEngine.f2(p)
	local d = State.a[p]
	if d then
		if d.at and d.at.Parent then d.at:Destroy() end
		if d.lv and d.lv.Parent then d.lv:Destroy() end
		if d.av and d.av.Parent then d.av:Destroy() end
		State.a[p] = nil
		local idx = table.find(State.active_array, p)
		if idx then table.remove(State.active_array, idx) end
		State.n = math.max(0, State.n - 1)
	end
end

function PhysicsEngine.UpdatePhysics(dt)
	local cen = State.b and State.b.Position or Vector3.zero
	local t = os.clock()
	local mode = State.mode_registry[Config.k6]
	if not mode or Config.Disabled or Config.Paused then return end
	
	-- PI Targets Logic (Ported from advance settings.lua:2991)
	if t > (State.pi_timer or 0) then
		State.pi_timer = t + 1; State.pi_targets = {}
		if Config.PI_All then
			for _, pl in ipairs(Players:GetPlayers()) do 
				if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then 
					table.insert(State.pi_targets, pl) 
				end 
			end
		elseif Config.Tgt and typeof(Config.Tgt) == "Instance" and Config.Tgt:IsA("Player") then
			if Config.Tgt.Character and Config.Tgt.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(State.pi_targets, Config.Tgt)
			end
		end
	end

	local no_damp = { ["Slingshot"] = true, ["Point Impact"] = true, ["Deflect"] = true }
	local skip_interval = State.n > 5000 and 10 or (State.n > 2500 and 6 or (State.n > 1000 and 3 or 1))
	State.f = (State.f or 0) + 1

	for i = #State.active_array, 1, -1 do
		local p = State.active_array[i]
		if not p then continue end -- Added nil check
		if not p.Parent then PhysicsEngine.f2(p) continue end
		if i % skip_interval ~= (State.f % skip_interval) then continue end
		
		local active_c = cen
		if #State.pi_targets > 0 then
			local tgt = State.pi_targets[((i-1)%#State.pi_targets)+1]
			if tgt and typeof(tgt) == "Instance" and tgt:IsA("Player") and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then 
				active_c = tgt.Character.HumanoidRootPart.Position 
			end
		end
		
		local d = State.a[p]
		if (active_c - p.Position).Magnitude > Config.k1 then continue end
		
		local tv = mode.Update(p, active_c, d, mode.Config, t)
		if not tv then continue end
		
		-- Physics Processing (Ported from f3)
		if Config.VerticalStiffness and Config.VerticalStiffness ~= 1 then tv = Vector3.new(tv.X, tv.Y * Config.VerticalStiffness, tv.Z) end
		if Config.Ki and Config.Ki > 0 then d.integral = (d.integral or Vector3.zero) + (tv * dt); local mI = 100; if d.integral.Magnitude > mI then d.integral = d.integral.Unit * mI end; tv = tv + (d.integral * Config.Ki) end
		
		local p_vel = p.AssemblyLinearVelocity
		if Config.Damping and Config.Damping > 0 and not no_damp[Config.k6] then tv = tv - (p_vel * Config.Damping) end
		
		if Config.MaxSpeed and not no_damp[Config.k6] then
			local spd = p_vel.Magnitude
			local s_factor = math.clamp(1 - (spd / Config.MaxSpeed), 0.2, 1)
			tv = tv * s_factor
		end
		
		local smoothing = (Config.k6 == "Point Impact" or Config.IsLaunching) and 1 or (Config.k8 or 0.8)
		d.lv.VectorVelocity = d.lv.VectorVelocity:Lerp(tv, smoothing)
		
		local limit = Config.MaxSpeed or 3000
		if d.lv.VectorVelocity.Magnitude > limit then d.lv.VectorVelocity = d.lv.VectorVelocity.Unit * limit end
		
		if Config.AngularDamping and Config.AngularDamping > 0 then
			p.AssemblyAngularVelocity = p.AssemblyAngularVelocity * math.pow(1 - math.clamp(Config.AngularDamping, 0, 0.99), dt)
		end
	end
end

-- Unified Engine Loop
RunService.Heartbeat:Connect(function(dt)
	-- Pro-Service Simulation Optimizations
	pcall(function()
		LocalPlayer.MaximumSimulationRadius = 9e9
		if sethiddenproperty then 
			sethiddenproperty(LocalPlayer, "SimulationRadius", 9e9)
			sethiddenproperty(LocalPlayer, "NetworkIsSleeping", false)
		end
		if State.b then LocalPlayer.ReplicationFocus = State.b end
		if Config.AntiFling then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then for _, part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end end
	end)
	
	if State.o then
		PhysicsEngine.UpdatePhysics(dt)
		-- Queue processing
		local start = os.clock()
		while #State.claim_queue > 0 and os.clock() - start < 0.002 do
			local p = table.remove(State.claim_queue, 1)
			if p and p:IsA("BasePart") and p:IsDescendantOf(Workspace) then PhysicsEngine.f1(p) end
		end
	end
end)

-- UI Skeleton and Searchable Menu
function UIManager.st()
	if UIManager.g then UIManager.g:Destroy() end
	local sg = Instance.new("ScreenGui"); sg.Name = "G_" .. math.random(999)
	if gethui then sg.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(sg); sg.Parent = game:GetService("CoreGui") else sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	UIManager.g = sg
	
	-- Global Toggle Hook
	ContextActionService:BindAction("ModularGravity_ToggleUI", function(_, s)
		if s == Enum.UserInputState.Begin then
			Config.UIVisible = not Config.UIVisible
			if UIManager.g:FindFirstChild("M") then UIManager.g.M.Visible = Config.UIVisible end
		end
	end, false, Enum.KeyCode.V)

	UIManager.mw(sg)
end


-- UI Builder (Continued)
function UIManager.mw(sg)
	local m = Instance.new("Frame", sg); m.Name = "M"; m.BackgroundColor3 = Color3.fromRGB(15, 15, 20); m.BackgroundTransparency = 0.2
	m.Position = UDim2.new(0, 20, 0.5, -240); m.Size = UDim2.new(0, 310, 0, 500); m.Active = true; m.Draggable = true
	Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16); local ms = Instance.new("UIStroke", m); ms.Color = Color3.fromRGB(80, 80, 100); ms.Thickness = 1.5; ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	local grad = Instance.new("UIGradient", m)
	grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))})
	grad.Rotation = 45
	
	local h = Instance.new("Frame", m); h.BackgroundTransparency = 1; h.Size = UDim2.new(1, 0, 0, 50)
	local t = Instance.new("TextLabel", h); t.BackgroundTransparency = 1; t.Position = UDim2.new(0, 20, 0, 0); t.Size = UDim2.new(0.6, 0, 1, 0)
	t.Text = "Gravity MODULAR"; t.TextColor3 = Color3.fromRGB(255, 255, 255); t.Font = Enum.Font.GothamBold; t.TextSize = 20; t.TextXAlignment = 0
	
	-- Close Button (X)
	local close = Instance.new("TextButton", h); close.BackgroundTransparency = 1; close.Position = UDim2.new(1, -40, 0, 10); close.Size = UDim2.new(0, 30, 0, 30)
	close.Text = "×"; close.TextColor3 = Color3.fromRGB(200, 200, 200); close.Font = Enum.Font.GothamBold; close.TextSize = 24
	close.MouseButton1Click:Connect(function() m.Visible = false; Config.UIVisible = false end)
	
	local container = Instance.new("ScrollingFrame", m); container.BackgroundTransparency = 1; container.Position = UDim2.new(0, 0, 0, 50); container.Size = UDim2.new(1, 0, 1, -60);
	container.ScrollBarThickness = 2; container.AutomaticCanvasSize = Enum.AutomaticSize.Y; container.CanvasSize = UDim2.new(0,0,0,0)
	local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", container).PaddingTop = UDim.new(0, 10)
	
	local tip = Instance.new("TextLabel", container); tip.BackgroundTransparency = 1; tip.Size = UDim2.new(0.9, 0, 0, 20)
	tip.Text = "Press 'V' to hide/show UI"; tip.TextColor3 = Color3.fromRGB(150, 150, 200); tip.Font = Enum.Font.Gotham; tip.TextSize = 12
	
	-- Mode Selector Button
	local sel_btn = Instance.new("TextButton", container); sel_btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); sel_btn.Size = UDim2.new(0.9, 0, 0, 40)
	sel_btn.Text = "Mode: " .. Config.k6; sel_btn.TextColor3 = Color3.fromRGB(255, 255, 255); sel_btn.Font = Enum.Font.GothamBold; sel_btn.TextSize = 14
	Instance.new("UICorner", sel_btn).CornerRadius = UDim.new(0, 8)
	

	-- Target Selector Button
	local tgt_btn = Instance.new("TextButton", container); tgt_btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); tgt_btn.Size = UDim2.new(0.9, 0, 0, 40)
	tgt_btn.Text = "Target: Select >"; tgt_btn.TextColor3 = Color3.fromRGB(240, 240, 255); tgt_btn.Font = Enum.Font.GothamBold; tgt_btn.TextSize = 14
	Instance.new("UICorner", tgt_btn).CornerRadius = UDim.new(0, 8)
	
	tgt_btn.MouseButton1Click:Connect(function()
		UIManager.OpenTargetMenu()
	end)
	
	-- Mode Settings Container
	local settings_area = Instance.new("Frame", container); settings_area.BackgroundTransparency = 1; settings_area.Size = UDim2.new(0.9, 0, 0, 0); settings_area.AutomaticSize = Enum.AutomaticSize.Y
	local s_layout = Instance.new("UIListLayout", settings_area); s_layout.Padding = UDim.new(0, 8)
	
	local function rebuild_settings()
		settings_area:ClearAllChildren()
		local mode = State.mode_registry[Config.k6]
		if mode and mode.UI then
			UIManager.h(settings_area, "- MODE SETTINGS -")
			mode.UI(settings_area, mode.Config)
		end
		UIManager.AddGlobalSettings(settings_area)
	end
	
	sel_btn.MouseButton1Click:Connect(function()
		UIManager.OpenModeMenu(function(new_mode)
			Config.k6 = new_mode
			sel_btn.Text = "Mode: " .. new_mode
			rebuild_settings()
			save_settings()
		end)
	end)
	
	-- Status HUD
	local hud = Instance.new("TextLabel", sg); hud.BackgroundTransparency = 1; hud.AnchorPoint = Vector2.new(1, 0); hud.Size = UDim2.new(0, 400, 0, 30)
	hud.Position = UDim2.new(1, -20, 0, 10); hud.Font = Enum.Font.GothamBold; hud.TextSize = 16; hud.TextColor3 = Color3.fromRGB(255, 255, 255)
	hud.TextXAlignment = Enum.TextXAlignment.Right; hud.TextStrokeTransparency = 0.5
	
	RunService.RenderStepped:Connect(function()
		local tn = "None"
		if Config.Tgt then tn = (Config.Tgt == Mouse) and "Mouse" or (Config.Tgt.DisplayName or Config.Tgt.Name) end
		hud.Text = "TARGET: " .. tn .. " | MODE: " .. Config.k6
		tgt_btn.Text = "Target: " .. tn
	end)
	
	rebuild_settings()
end


-- Mode Registration: Meteor Shower
register_mode("Meteor Shower", { k11 = 500, k12 = 300, k13 = 150, k14 = 50 }, {
	Init = function(d) d.v1 = (math.random()-0.5)*500; d.v2 = (math.random()-0.5)*500; d.v3 = math.random() end,
	Update = function(p, cen, d, c, t)
		local sxz, hspawn, fspd = (c.k11 or 500), (c.k12 or 300), (c.k13 or 150); local drop = hspawn*2; local ftime = drop/fspd
		local cur = ((t + d.v3*ftime)%ftime)/ftime; local y = hspawn-(cur*drop)
		return ((cen + Vector3.new(d.v1-(cur*sxz*0.5), y, d.v2-(cur*sxz*0.25))) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Fall Speed", 50, 500, c.k13, function(v) c.k13 = v end) end
})

-- Mode Registration: World Serpent
register_mode("World Serpent", { k11 = 400, k12 = 100, k13 = 20, k14 = 200 }, {
	Init = function(d) d.v1 = math.random() end,
	Update = function(p, cen, d, c, t)
		local L, Amp, s, WL = (c.k11 or 400), (c.k12 or 100), (c.k13 or 20)*Constants.c2, (c.k14 or 200); local ph = t*s; local seg = d.v1*L
		local w_off = (seg-(ph*500))/WL; local ang = (seg/L)*math.pi*2 + ph; local cur_r = (L/math.pi) + math.cos(w_off*math.pi*2)*(Amp*0.5)
		local fin = Vector3.new(cur_r*math.cos(ang), math.sin(w_off*math.pi*2)*Amp, cur_r*math.sin(ang))
		return ((cen + fin) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Serpent Length", 100, 1000, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Aurora Borealis
register_mode("Aurora Borealis", { k11 = 600, k12 = 300, k13 = 15, k14 = 100 }, {
	Init = function(d) d.v1 = (math.random()-0.5)*2; d.v2 = math.random() end,
	Update = function(p, cen, d, c, t)
		local span, h, s, rw = (c.k11 or 600), (c.k12 or 300), (c.k13 or 15)*Constants.c2, (c.k14 or 100)
		local ph = t*s; local drift = math.sin(ph+d.v1*2)*50; local tx = d.v1*span + drift
		local ty = d.v2*rw + math.sin(ph*0.5+d.v1*3)*h; local tz = math.cos(ph*0.3+d.v1*5)*100
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Aurora Span", 200, 1500, c.k11, function(v) c.k11 = v end) end
})

function UIManager.OpenTargetMenu()
	if State.target_gui then State.target_gui:Destroy() end
	local menu = Instance.new("Frame", UIManager.g); menu.BackgroundColor3 = Color3.fromRGB(20, 20, 25); menu.Position = UDim2.new(0.5, -120, 0.5, -180); menu.Size = UDim2.new(0, 240, 0, 360)
	menu.Active = true; menu.Draggable = true; State.target_gui = menu; Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
	
	local list = Instance.new("ScrollingFrame", menu); list.BackgroundTransparency = 1; list.Position = UDim2.new(0, 0, 0, 10); list.Size = UDim2.new(1, 0, 1, -20); list.ScrollBarThickness = 2
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y; local list_layout = Instance.new("UIListLayout", list); list_layout.Padding = UDim.new(0, 4); list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local function add_btn(name, target)
		local b = Instance.new("TextButton", list); b.Size = UDim2.new(0.9, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.Text = name
		b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamMedium; b.TextSize = 13; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(function() Config.Tgt = target; menu:Destroy() end)
	end
	
	add_btn("None (World Center)", nil); add_btn("Mouse Cursor", Mouse)
	for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then add_btn(p.DisplayName or p.Name, p) end end
end

-- Searchable Mode Menu with Favoriting
function UIManager.OpenModeMenu(callback)
	if State.menu_gui then State.menu_gui:Destroy() end
	local menu = Instance.new("Frame", UIManager.g); menu.BackgroundColor3 = Color3.fromRGB(20, 20, 25); menu.Position = UDim2.new(0.5, -160, 0.5, -220); menu.Size = UDim2.new(0, 320, 0, 440)
	menu.Active = true; menu.Draggable = true; State.menu_gui = menu; Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
	
	local search_bar = Instance.new("TextBox", menu); search_bar.BackgroundColor3 = Color3.fromRGB(35, 35, 45); search_bar.Size = UDim2.new(0.9, 0, 0, 35); search_bar.Position = UDim2.new(0.05, 0, 0, 10)
	search_bar.PlaceholderText = "Search Modes..."; search_bar.Text = ""; search_bar.TextColor3 = Color3.fromRGB(255, 255, 255); search_bar.Font = Enum.Font.Gotham; search_bar.TextSize = 14
	Instance.new("UICorner", search_bar).CornerRadius = UDim.new(0, 8)
	
	local list = Instance.new("ScrollingFrame", menu); list.BackgroundTransparency = 1; list.Position = UDim2.new(0, 0, 0, 55); list.Size = UDim2.new(1, 0, 1, -65); list.ScrollBarThickness = 2
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y; local list_layout = Instance.new("UIListLayout", list); list_layout.Padding = UDim.new(0, 4); list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local function populate(filter)
		list:ClearAllChildren(); Instance.new("UIListLayout", list).Padding = UDim.new(0, 4); filter = filter:lower()
		local sorted = {}; for name, _ in pairs(State.mode_registry) do if name:lower():find(filter) then table.insert(sorted, name) end end
		table.sort(sorted, function(a, b)
			local favA, favB = State.favorites[a] and 1 or 0, State.favorites[b] and 1 or 0
			if favA ~= favB then return favA > favB end
			return a < b
		end)
		for _, name in ipairs(sorted) do
			local b = Instance.new("TextButton", list); b.Size = UDim2.new(0.95, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.Text = name
			b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamMedium; b.TextSize = 13; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			local star = Instance.new("TextButton", b); star.Size = UDim2.new(0, 30, 0, 30); star.Position = UDim2.new(1, -35, 0.5, -15); star.BackgroundTransparency = 1
			star.Text = State.favorites[name] and "★" or "☆"; star.TextColor3 = State.favorites[name] and Color3.fromRGB(255, 220, 50) or Color3.fromRGB(150, 150, 150); star.TextSize = 18
			star.MouseButton1Click:Connect(function() State.favorites[name] = not State.favorites[name]; populate(search_bar.Text); save_settings() end)
			b.MouseButton1Click:Connect(function() 
				if Config.k6 == "Sculptor" then Managers.ClearSculptor() end
				for _, pData in pairs(State.a) do pData.integral = Vector3.zero end
				callback(name); menu:Destroy() 
			end)
		end
	end
	search_bar:GetPropertyChangedSignal("Text"):Connect(function() populate(search_bar.Text) end); populate("")
end

-- Mode Registration: Celestial Ribbon
register_mode("Celestial Ribbon", {
	k11 = 1, k12 = 0, k13 = 15, k14 = 30, k16 = 0.4, k17 = 150, k18 = false, k19 = false
}, {
	Init = function(d)
		d.v6 = math.random()
		d.v7 = math.random() - 0.5
	end,
	Update = function(p, cen, d, c, t)
		local s, w, h, l = (c.k13 or 10) * Constants.c2, (c.k11 or 8), c.k14 or 50, (c.k16 or Constants.c5) * 100
		local R = (c.k17 or 150)
		local ph = (t * s) - (d.v6 * (l * Constants.c2))
		local px, pz, py = math.cos(ph) * R, math.sin(ph * 1.618) * R, math.sin(ph * 0.577) * h
		local T = Vector3.new(px, py, pz).Unit
		local Rvec = T:Cross(Vector3.yAxis)
		if Rvec.Magnitude < 0.01 then Rvec = Vector3.xAxis end
		Rvec = Rvec.Unit
		local trn = Rvec * math.cos(ph * 0.5) + (T:Cross(Rvec)) * math.sin(ph * 0.5)
		local fin = Vector3.new(px, py, pz) + (trn * (d.v7 * w)) + (c.k18 and (trn * math.sin(ph * 8)) * (w * 2.0) or Vector3.zero)
		if c.k19 and d.v9 == 1 then fin = -fin end
		return ((cen + fin) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c)
		UIManager.s(p, "Ribbon Radius", 50, 500, c.k17, function(v) c.k17 = v end)
		UIManager.s(p, "Ribbon Width", 1, 50, c.k11, function(v) c.k11 = v end)
		UIManager.s(p, "Spiral Speed", 1, 100, c.k13, function(v) c.k13 = v end)
	end
})

-- Mode Registration: Galactic Web
register_mode("Galactic Web", {
	k11 = 400, k12 = 10, k13 = 5, k24 = 200, k25 = false
}, {
	Init = function(d)
		d.v1 = (math.random() - 0.5) * 2; d.v2 = (math.random() - 0.5) * 2; d.v3 = (math.random() - 0.5) * 2
		d.v4 = math.random() * math.pi * 2; d.v5 = (math.random() - 0.5) * 2
		local rx, ry, rz = math.random() - 0.5, math.random() - 0.5, math.random() - 0.5
		local len = math.sqrt(rx * rx + ry * ry + rz * rz); if len == 0 then rx, ry, rz, len = 0, 1, 0, 1 end
		d.rot_axis = Vector3.new(rx / len, ry / len, rz / len)
	end,
	Update = function(p, cen, d, c, t)
		local Spread, SpinSpeed, DriftTime = (c.k11 or 400), (c.k12 or 10) * Constants.c2, (c.k13 or 5)
		local phase = t * SpinSpeed + d.v4; local drift_phase = (t / DriftTime) + d.v4
		local dx = math.sin(drift_phase) * d.v5 * (Spread * 0.25); local dy = math.cos(drift_phase * 0.8) * d.v5 * (Spread * 0.25); local dz = math.sin(drift_phase * 1.2) * d.v5 * (Spread * 0.25)
		local px, py, pz = d.v1 * Spread + dx, d.v2 * Spread + dy, d.v3 * Spread + dz
		local p_vec = Vector3.new(px, py, pz); local k = d.rot_axis; local cp, sp = math.cos(phase), math.sin(phase)
		local rotated = p_vec * cp + (k:Cross(p_vec)) * sp + k * (k:Dot(p_vec) * (1 - cp))
		local h_lim = c.k24 or 200; local v_scale = h_lim / math.max(1, Spread)
		local final_y = rotated.Y * v_scale
		if c.k25 then final_y = math.abs(final_y) end
		return ((cen + Vector3.new(rotated.X, final_y, rotated.Z)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c)
		UIManager.s(p, "Web Spread", 100, 1000, c.k11, function(v) c.k11 = v end)
		UIManager.s(p, "Height Limit", 0, 1500, c.k24, function(v) c.k24 = v end)
		UIManager.t(p, "Cut In Half", c.k25, function(v) c.k25 = v end)
	end
})


-- Mode Registration: Quantum Atoms
register_mode("Quantum Atoms", { k11 = 60, k13 = 15, k15 = 3 }, {
	Init = function(d) d.v1 = math.random(1, 3); d.v6 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local s, R, Orbits = (c.k13 or 15) * Constants.c2, (c.k11 or 60), (c.k15 or 3)
		local cx, cz, tilt = math.cos(d.v6 + (t * s)) * R, math.sin(d.v6 + (t * s)) * R, (math.pi / Orbits) * (d.v1 - 1)
		local tx, ty, sp = cx * math.cos(tilt), -cx * math.sin(tilt), (math.pi * 2 / Orbits) * (d.v1 - 1)
		return ((cen + Vector3.new(tx * math.cos(sp) - cz * math.sin(sp), ty, tx * math.sin(sp) + cz * math.cos(sp))) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Atom Radius", 10, 200, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Halo Ring
register_mode("Halo Ring", { k11 = 40, k13 = 5, k14 = 80 }, {
	Init = function(d) d.v6 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local s, R, H = (c.k13 or 5) * Constants.c2, (c.k11 or 40), (c.k14 or 80)
		return ((cen + Vector3.new(math.cos(d.v6 + (t * s)) * R, H, math.sin(d.v6 + (t * s)) * R)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Ring Radius", 10, 200, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Black Hole
register_mode("Black Hole", { k11 = 40, k12 = 100, k13 = 15, k14 = 50 }, {
	Init = function(d) d.v2 = math.random(); d.v6 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local eh, dr, spin, dh = (c.k11 or 40), (c.k12 or 100), (c.k13 or 15) * Constants.c2, (c.k14 or 50)
		local rad = eh + (d.v2 * (dr - eh)); local l_spin = spin * (dr / rad); local phase = (t * l_spin) + d.v6
		local thick = (math.random() - 0.5) * dh * math.sin(phase * 2) * (eh / rad)
		return ((cen + Vector3.new(rad * math.cos(phase), thick, rad * math.sin(phase))) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Event Horizon", 10, 200, c.k11, function(v) c.k11 = v end); UIManager.s(p, "Disk Radius", 50, 1000, c.k12, function(v) c.k12 = v end) end
})

-- Mode Registration: DNA Helix
register_mode("DNA Helix", { k11 = 20, k12 = 80, k13 = 10, k14 = 50 }, {
	Init = function(d) d.v1 = math.random(); d.v2 = math.random(0, 1); d.v3 = math.random() end,
	Update = function(p, cen, d, c, t)
		local R, H, s, freq = (c.k11 or 20), (c.k12 or 80), (c.k13 or 10) * Constants.c2, (c.k14 or 50)
		local phase = (t * s) + (d.v1 * freq); local offset = d.v2 * math.pi
		local tx, ty, tz = R * math.cos(phase + offset), (d.v1 - 0.5) * H, R * math.sin(phase + offset)
		if d.v3 > 0.8 then -- Rung particles
			local r_pos = math.floor(d.v1 * 10) / 10; local r_phase = (t * s) + (r_pos * freq)
			local r_t = (math.random() - 0.5) * 2
			tx, ty, tz = r_t * R * math.cos(r_phase), (r_pos - 0.5) * H, r_t * R * math.sin(r_phase)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Helix Radius", 5, 100, c.k11, function(v) c.k11 = v end); UIManager.s(p, "Helix Height", 20, 500, c.k12, function(v) c.k12 = v end) end
})


-- Mode Registration: Supernova
register_mode("Supernova", { k11 = 15, k12 = 100, k13 = 25 }, {
	Init = function(d) d.v1 = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit; d.v2 = math.random() end,
	Update = function(p, cen, d, c, t)
		local s, MaxSize = (c.k13 or 25)*Constants.c2, (c.k12 or 100); local burst = math.sin((t*s)%math.pi)
		local current = (burst > 0.1) and (d.v1 * (burst * MaxSize * d.v2)) or (d.v1 * (c.k11 or 15) + Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5)*2)
		return ((cen + current) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Core Radius", 5, 50, c.k11, function(v) c.k11 = v end); UIManager.s(p, "Explosion Size", 50, 500, c.k12, function(v) c.k12 = v end) end
})

-- Mode Registration: Seraphim
register_mode("Seraphim", { k11 = 80, k12 = 4, k13 = 15, k14 = 40 }, {
	Init = function(d)
		local r = math.random(); d.v1 = (r < 0.2) and 0 or (r < 0.6 and math.random(1, 4) or -1)
		d.v2 = math.random() * math.pi * 2
	end,
	Update = function(p, cen, d, c, t)
		local R, Wingspan, s = (c.k11 or 80), (c.k14 or 40), (c.k13 or 15)*Constants.c2; local ph = t*s; local tx, ty, tz = 0,0,0
		if d.v1 == 0 then -- Eye
			tx, ty = 5*math.cos(d.v2+ph*4), 10*math.sin(d.v2+ph*4)
		elseif d.v1 > 0 then -- Rings
			local r_ph = d.v2+(ph*(1+d.v1*0.2)); local tx1, ty1 = R*math.cos(r_ph), (d.v1/4)*math.pi
			local tz1, sz1 = ph*0.5+d.v1, math.sin(ph*0.5+d.v1); local cz1 = math.cos(tz1)
			tx, ty, tz = tx1*cz1 - (0*cz1 - R*math.sin(r_ph)*math.sin(ty1))*sz1, tx1*sz1 + (0*cz1 - R*math.sin(r_ph)*math.sin(ty1))*cz1, R*math.sin(r_ph)*math.cos(ty1)
		else -- Wings
			local side = (d.v2 % 2 > 1) and 1 or -1; local pos = (d.v2 / (math.pi*2)); local w = pos * Wingspan * 2
			tx, ty, tz = w*side, math.sin(ph*2)*15*pos + math.abs(side*w*0.5), -20-(pos*30)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Seraphim Radius", 40, 300, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Torus Knot
register_mode("Torus Knot", { k11 = 3, k12 = 2, k13 = 10, k14 = 50, k15 = 20 }, {
	Init = function(d) d.v6 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local pk, qk, s, R, r = (c.k11 or 3), (c.k12 or 2), (c.k13 or 10) * Constants.c2, (c.k14 or 50), (c.k15 or 20)
		local ph = (t * s) + d.v6; local cq = math.cos(qk * ph)
		local tx, ty, tz = (R + r * cq) * math.cos(pk * ph), r * math.sin(qk * ph), (R + r * cq) * math.sin(pk * ph)
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "P Knot", 1, 10, c.k11, function(v) c.k11 = v end); UIManager.s(p, "Q Knot", 1, 10, c.k12, function(v) c.k12 = v end) end
})

-- Mode Registration: Space Station
register_mode("Space Station", { k11 = 80, k12 = 30, k13 = 10, k14 = 150 }, {
	Init = function(d) d.v1 = math.random(); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(1, 3) end,
	Update = function(p, cen, d, c, t)
		local R, RT, s, CR = (c.k11 or 80), (c.k12 or 30), (c.k13 or 10) * Constants.c2, (c.k14 or 150)
		local ph, tx, ty, tz = (t * s) + d.v2, 0, 0, 0
		if d.v3 == 1 then ty = (d.v1 - 0.5) * CR; tx = math.cos(ph * 3) * (10 + (d.v1 * 5)); tz = math.sin(ph * 3) * (10 + (d.v1 * 5))
		elseif d.v3 == 2 then local rPh = ph * 0.5; local tOff = (d.v1 - 0.5) * RT; tx, tz = (R + tOff) * math.cos(rPh), (R + tOff) * math.sin(rPh)
		else local sc = 4; local sa = math.floor(d.v2 / (math.pi * 2) * sc) * (math.pi * 2 / sc); local ss = ph * 0.5; local dist = d.v1 * R
			tx, tz = dist * math.cos(sa + ss), dist * math.sin(sa + ss)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Station Radius", 20, 400, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Dyson Sphere
register_mode("Dyson Sphere", { k11 = 150, k12 = 8, k13 = 10 }, {
	Init = function(d) d.v1 = math.random(); d.v2 = math.random() * math.pi * 2; d.v3 = math.random() * math.pi; d.v4 = math.random() < 0.15 and 1 or (math.random() < 0.85 and 2 or 3) end,
	Update = function(p, cen, d, c, t)
		local R, SD, s = (c.k11 or 150), (c.k12 or 8), (c.k13 or 10) * Constants.c2; local ph = t * s; local tx, ty, tz = 0, 0, 0
		if d.v4 == 1 then local cr = 15 + math.sin(ph * 2) * 2; tx = cr * math.sin(d.v3) * math.cos(d.v2 + ph * 3); ty = cr * math.cos(d.v3); tz = cr * math.sin(d.v3) * math.sin(d.v2 + ph * 3)
		elseif d.v4 == 2 then local pt = math.floor(d.v2 * SD) / SD; local pp = math.floor(d.v3 * (SD / 2)) / (SD / 2); local rt = pt + (ph * 0.2)
			tx = R * math.sin(pp) * math.cos(rt); ty = R * math.cos(pp); tz = R * math.sin(pp) * math.sin(rt)
		else local sp = (d.v1 + ph * 1.5) % 1; local cr = 15 + sp * (R - 15); local pt = math.floor(d.v2 * 10) / 10; local pp = math.floor(d.v3 * 10) / 10; local rt = pt + (ph * 0.2)
			tx = cr * math.sin(pp) * math.cos(rt); ty = cr * math.cos(pp); tz = cr * math.sin(pp) * math.sin(rt)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Sphere Radius", 50, 400, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Alien Mothership
register_mode("Alien Mothership", { k11 = 120, k12 = 40, k13 = 15, k14 = 200 }, {
	Init = function(d) d.v1 = math.random() < 0.6 and 1 or (math.random() < 0.8 and 2 or 3); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local R, CH, s, BL = (c.k11 or 120), (c.k12 or 40), (c.k13 or 15) * Constants.c2, (c.k14 or 200); local ph, tx, ty, tz = t * s, 0, 0, 0
		if d.v1 == 1 then local r = R * math.sqrt(d.v3); local yc = math.sin(math.acos(d.v3)) * CH; if d.v2 > math.pi then yc = -yc end
			local rot = d.v4 + ph; tx, tz, ty = r * math.cos(rot), r * math.sin(rot), yc
		elseif d.v1 == 2 then local bp = (d.v3 + ph * 2) % 1; ty = -CH - (bp * BL); local br = 10 + (bp * R * 0.4); local rot = d.v2 + ph * 3; tx, tz = br * math.cos(rot), br * math.sin(rot)
		else local g = math.floor(d.v3 * 3); local op = ph * 0.5 + (g * math.pi * 2 / 3); local orbR = R * 1.5; tx, tz, ty = orbR * math.cos(op) + math.random() * 10 * math.cos(d.v4 + ph * 5), orbR * math.sin(op) + math.random() * 10 * math.sin(d.v4 + ph * 5), math.sin(ph * 2 + g) * 20
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Ship Radius", 50, 400, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Quantum Core
register_mode("Quantum Core", { k11 = 100, k12 = 30, k13 = 40, k14 = 50 }, {
	Init = function(d) d.v1 = math.random() < 0.4 and 1 or (math.random() < 0.8 and 2 or 3); d.v2 = math.random() * math.pi * 2; d.v3 = math.random() * math.pi * 2; d.v4 = (math.random() - 0.5) * 2 end,
	Update = function(p, cen, d, c, t)
		local R, RT, s, PS = (c.k11 or 100), (c.k12 or 30), (c.k13 or 40) * Constants.c2, (c.k14 or 50); local ph, tx, ty, tz = t * s, 0, 0, 0
		if d.v1 == 1 then local rp = d.v2 + ph; tx, tz, ty = (R + RT * math.cos(d.v3)) * math.cos(rp), (R + RT * math.cos(d.v3)) * math.sin(rp), RT * math.sin(d.v3)
		elseif d.v1 == 2 then local rp = d.v2 + ph * 1.1; tx, ty, tz = (R + RT * math.cos(d.v3)) * math.cos(rp), (R + RT * math.cos(d.v3)) * math.sin(rp), RT * math.sin(d.v3)
		else local spd = PS * 0.1; local dst = (math.sin(t * spd + d.v2) * 0.5 + 0.5) * (R * 0.8); local p = d.v3 + ph * 3 * d.v4; local th = d.v2 + ph * 4 * d.v4; tx, ty, tz = dst * math.sin(p) * math.cos(th), dst * math.cos(p), dst * math.sin(p) * math.sin(th)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Core Radius", 50, 400, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Tesseract
register_mode("Tesseract", { k11 = 40, k12 = 80, k13 = 10 }, {
	Init = function(d) d.v1 = math.random(0, 31) end,
	Update = function(p, cen, d, c, t)
		local size, oSize, s = (c.k11 or 40), (c.k12 or 80), (c.k13 or 10) * Constants.c2; local rot = t * s
		local pts = {{-1,-1,-1},{1,-1,-1},{-1,1,-1},{1,1,-1},{-1,-1,1},{1,-1,1},{-1,1,1},{1,1,1}}
		local from, to = pts[(d.v1%4)*2+1], pts[(d.v1%4)*2+2]; if d.v1 >= 12 and d.v1 < 24 then from, to = pts[((d.v1-12)%4)*2+1], pts[((d.v1-12)%4)*2+2] elseif d.v1 >= 24 then from, to = pts[(d.v1-24)+1], pts[(d.v1-24)+1] end
		local l = (math.sin(t*s+d.v1)+1)/2; local lx, ly, lz, lw = from[1]+(to[1]-from[1])*l, from[2]+(to[2]-from[2])*l, from[3]+(to[3]-from[3])*l, (d.v1>=12 and d.v1<24) and 1 or -1
		local nw = lw * math.cos(rot) - lx * math.sin(rot); local nx = lw * math.sin(rot) + lx * math.cos(rot); local persp = size / (size - nw * 0.5)
		return ((cen + Vector3.new(nx * persp * oSize, ly * persp * oSize, lz * persp * oSize)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Inner Size", 10, 200, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Arcane Orrery
register_mode("Arcane Orrery", { k11 = 120, k12 = 4, k13 = 8, k14 = 200 }, {
	Init = function(d) d.v1 = math.random() < 0.12 and 1 or (math.random() < 0.3 and 2 or (math.random() < 0.48 and 3 or (math.random() < 0.72 and 4 or 5))); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local R, Arms, s, H = (c.k11 or 120), (c.k12 or 4), (c.k13 or 8) * Constants.c2, (c.k14 or 200); local ph, tx, ty, tz = t * s, 0, 0, 0
		if d.v1 == 1 then local pr = d.v3; ty = (pr-0.5)*H; local hr = 12+math.sin(pr*math.pi*6)*3; local st = (d.v2>math.pi) and math.pi or 0; local ha = pr*math.pi*8+ph*3+st; tx, tz, ty = hr*math.cos(ha), hr*math.sin(ha), ty+math.sin(ph*2+pr*10)*3
		elseif d.v1 == 2 then local gp = d.v2+ph; local r = (R*0.5)+math.abs(math.sin(gp*8))*12; tx, tz, ty = r*math.cos(gp), r*math.sin(gp), H*0.4+math.sin(ph+d.v2)*3
		elseif d.v1 == 3 then local gp = d.v2-ph*0.7; local r = (R*0.8)+math.abs(math.sin(gp*10))*15; tx, tz, ty = r*math.cos(gp), r*math.sin(gp), H*0.4+math.sin(ph*1.3+d.v2)*5
		elseif d.v1 == 4 then local ai = math.floor(d.v2/(math.pi*2)*Arms); local aa = (ai/Arms)*math.pi*2+ph*0.3; local dist = d.v3*R; local pr = 8+math.sin(d.v4*6)*4; local pp = d.v4+ph*4; tx, tz, ty = dist*math.cos(aa)+pr*math.cos(pp), dist*math.sin(aa)+pr*math.sin(pp), H*0.5+math.sin(aa*3+ph)*15+pr*math.sin(pp*0.5)*0.5
		else local br = R*1.1; local bp = d.v2+ph*0.5; local tilt = math.pi*0.25; local bx, bz = br*math.cos(bp), br*math.sin(bp); local ry, rz = -bz*math.sin(tilt), bz*math.cos(tilt); tx, ty, tz = bx, H*0.8+ry, rz; local node = math.floor(bp/(math.pi*2)*12)*(math.pi*2/12); local near = math.abs(bp%(math.pi*2/12)-math.pi/12); if near<0.15 then local pulse = math.sin(ph*3+node*5)*8; tx, tz = tx+math.cos(d.v4)*pulse, tz+math.sin(d.v4)*pulse end
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Orrery Radius", 40, 300, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Maelstrom Spire
register_mode("Maelstrom Spire", { k11 = 30, k12 = 200, k13 = 15, k14 = 6 }, {
	Init = function(d) d.v1 = math.random() < 0.25 and 1 or (math.random() < 0.5 and 2 or (math.random() < 0.70 and 3 or (math.random() < 0.92 and 4 or 5))); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local BR, H, s, Jets = (c.k11 or 30), (c.k12 or 200), (c.k13 or 15) * Constants.c2, (c.k14 or 6); local ph, tx, ty, tz, TR = t * s, 0, 0, 0, (BR * 4)
		if d.v1 == 1 then local sa = d.v2+ph*2; local lr = (BR*0.5+d.v3*TR*1.2)*(1+math.log(1+d.v3*2)); tx, tz, ty = lr*math.cos(sa), lr*math.sin(sa), -5+math.sin(sa*3)*3
		elseif d.v1 == 2 then local pr = d.v3; local fr = TR*(1-pr*0.8); local fp = d.v2+ph*(1+pr*3); tx, tz, ty = fr*math.cos(fp), fr*math.sin(fp), pr*H
		elseif d.v1 == 3 then local ji = math.floor(d.v2/(math.pi*2)*Jets); local ja = (ji/Jets)*math.pi*2+ph*0.3; local jd = d.v3*TR*2; local wobble = math.sin(ph*3+ji*1.5)*10; tx, tz, ty = jd*math.cos(ja+wobble*0.02), jd*math.sin(ja+wobble*0.02), H+wobble+math.sin(d.v4+ph)*5
		elseif d.v1 == 4 then local ap = (d.v3+ph*0.5)%1; local aa = d.v2+ph*0.2; local ar = TR*1.5+ap*TR*0.5; local ay = H*(1-4*(ap-0.5)*(ap-0.5)); tx, tz, ty = ar*math.cos(aa), ar*math.sin(aa), ay
		else local er = 5+math.sin(ph*0.5+d.v2)*2; tx, tz, ty = er*math.cos(d.v2+ph*0.1), er*math.sin(d.v2+ph*0.1), H+math.sin(ph+d.v3*math.pi)*2
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Base Radius", 10, 150, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Eldritch Binding
register_mode("Eldritch Binding", { k11 = 100, k12 = 200, k13 = 5, k14 = 8 }, {
	Init = function(d) d.v1 = math.random() < 0.15 and 1 or (math.random() < 0.3 and 2 or (math.random() < 0.5 and 3 or (math.random() < 0.62 and 4 or (math.random() < 0.85 and 5 or 6)))); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.random() end,
	Update = function(p, cen, d, c, t)
		local R, H, s, Tendrils = (c.k11 or 100), (c.k12 or 200), (c.k13 or 5) * Constants.c2, (c.k14 or 8); local ph, tx, ty, tz = t * s, 0, 0, 0
		if d.v1 == 1 then local pts = 5; local ei = math.floor(d.v2/(math.pi*2)*pts); local a1, a2 = (ei/pts)*math.pi*2+ph, ((ei+2)%pts/pts)*math.pi*2+ph; local lt = d.v3; tx, ty, tz = R*math.cos(a1)+(R*math.cos(a2)-R*math.cos(a1))*lt, 10, R*math.sin(a1)+(R*math.sin(a2)-R*math.sin(a1))*lt
		elseif d.v1 == 2 then local pts = 6; local ei = math.floor(d.v2/(math.pi*2)*pts); local a1, a2 = (ei/pts)*math.pi*2-ph, ((ei+2)%pts/pts)*math.pi*2-ph; tx, ty, tz = R*math.cos(a1)+(R*math.cos(a2)-R*math.cos(a1))*d.v3, H, R*math.sin(a1)+(R*math.sin(a2)-R*math.sin(a1))*d.v3
		elseif d.v1 == 3 then local ci = math.floor(d.v2/(math.pi*2)*10); local la, ua, pr = (ci%5)/5*math.pi*2+ph, (ci%6)/6*math.pi*2-ph, d.v3; tx, tz = R*math.cos(la)*(1-pr)+R*math.cos(ua)*pr, R*math.sin(la)*(1-pr)+R*math.sin(ua)*pr; ty = 10+pr*(H-10)-math.sin(pr*math.pi)*15
		elseif d.v1 == 4 then local ni = math.floor(d.v2/(math.pi*2)*11); local isL = ni<5; local na = isL and ((ni/5)*math.pi*2+ph) or (((ni-5)/6)*math.pi*2-ph); ty = isL and 10 or H; local pulse = math.sin(ph*3+ni*2)*0.5+0.5; local nr = R+pulse*15; tx, tz = nr*math.cos(na)+math.cos(d.v4*math.pi*2)*pulse*8, nr*math.sin(na)+math.sin(d.v4*math.pi*2)*pulse*8
		elseif d.v1 == 5 then local ti = math.floor(d.v2/(math.pi*2)*Tendrils); local ba = (ti/Tendrils)*math.pi*2; local pr = (d.v3+ph*0.5)%1; ty = pr*H; local snake = math.sin(pr*math.pi*6+ph*2+ti)*15; local tr = 15+snake+d.v4*3; tx, tz = tr*math.cos(ba+pr*math.pi*2), tr*math.sin(ba+pr*math.pi*2)
		else local phi, theta, breath = d.v2, d.v3*math.pi, math.sin(ph*0.5)*0.2+1; local sr = R*1.3*breath; tx, ty, tz = sr*math.sin(theta)*math.cos(phi+ph*0.1), H*0.5+sr*math.cos(theta), sr*math.sin(theta)*math.sin(phi+ph*0.1)
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Sigil Radius", 30, 250, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Graviton Engine
register_mode("Graviton Engine", { k11 = 4, k12 = 60, k13 = 12, k14 = 200 }, {
	Init = function(d) d.v1 = math.random() < 0.25 and 1 or (math.random() < 0.45 and 2 or (math.random() < 0.6 and 3 or (math.random() < 0.72 and 4 or (math.random() < 0.88 and 5 or 6)))); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.random() end,
	Update = function(p, cen, d, c, t)
		local Turb, R, s, H = (c.k11 or 4), (c.k12 or 60), (c.k13 or 12) * Constants.c2, (c.k14 or 200); local ph, tx, ty, tz, spacing = t * s, 0, 0, 0, H/(Turb+1)
		if d.v1 == 1 then local ti = math.floor(d.v3*Turb); ty = spacing*(ti+1); local tp = d.v2+ph*(1+ti*0.3); if ti%2==1 then tp=-tp end; tx, tz = R*math.cos(tp), R*math.sin(tp)
		elseif d.v1 == 2 then local ti = math.floor(d.v3*Turb); ty = spacing*(ti+1); local ba = (math.floor(d.v2/(math.pi*2)*6)/6)*math.pi*2+ph*(1+ti*0.3); if ti%2==1 then ba=-ba end; local br = R*0.6+d.v4*R*0.4; tx, tz, ty = br*math.cos(ba), br*math.sin(ba), ty+math.sin(math.pi*0.15)*d.v4*R*0.4*0.3
		elseif d.v1 == 3 then local ti = math.floor(d.v3*math.max(1,Turb-1)); local ly, uy = spacing*(ti+1), spacing*(ti+2); local pa = (math.floor(d.v2/(math.pi*2)*4)/4)*math.pi*2+ph*0.2; local pr = (d.v4+ph*2)%1; tx, tz, ty = 15*math.cos(pa), 15*math.sin(pa), ly+pr*(uy-ly)
		elseif d.v1 == 4 then local ti = math.floor(d.v3*Turb); ty = spacing*(ti+1); local ep = (d.v4+ph*3)%1; local er = R*0.3+ep*R*0.5; local ea = d.v2+ph*2; tx, tz, ty = er*math.cos(ea), er*math.sin(ea), ty-ep*spacing*0.6
		elseif d.v1 == 5 then local dr = d.v3*R*1.2; local da = d.v2+ph*0.3; tx, tz, ty = dr*math.cos(da), dr*math.sin(da), H+(dr*dr)/(R*2)
		else local br = 3+math.sin(ph*5+d.v2*10)*2; local bp = (d.v3+ph*4)%1; tx, tz, ty = br*math.cos(d.v2), br*math.sin(d.v2), H+20+bp*H*0.8; if bp>0.7 then local sc = (bp-0.7)/0.3; tx, tz = tx+math.cos(d.v4*math.pi*2)*sc*40, tz+math.sin(d.v4*math.pi*2)*sc*40 end
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Turbine Count", 2, 8, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Fractal Web
register_mode("Fractal Web", { k11 = 40, k12 = 3, k13 = 3, k14 = 5 }, {
	Init = function(d) d.v1 = math.random(0, 2); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.floor(math.random()*6) end,
	Update = function(p, cen, d, c, t)
		local HexR, Dep, BSp, RSp = (c.k11 or 40), (c.k12 or 3), (c.k13 or 3)*Constants.c2, (c.k14 or 5)*Constants.c2; local ph, breath = t*RSp, math.sin(t*BSp)*0.3+1; local tx, tz, ax, az, cr = 0, 0, 0, 0, HexR
		for lv = 0, d.v1 do local vi = (lv == d.v1) and d.v4 or (math.floor(d.v2/(math.pi*2)*6+lv)%6); local ang = (vi/6)*math.pi*2+ph*(1/(lv+1)); local orad = cr*breath*(1+lv*0.3); ax, az = ax+orad*math.cos(ang), az+orad*math.sin(ang); cr = cr*0.5 end
		local ep, nv = d.v3, (d.v4+1)%6; local ca = (d.v4/6)*math.pi*2+ph*(1/(d.v1+1)); local na = (nv/6)*math.pi*2+ph*(1/(d.v1+1)); local er = cr*breath*(1+d.v1*0.3)
		tx, tz = ax + er*math.cos(ca)*(1-ep)+er*math.cos(na)*ep, az + er*math.sin(ca)*(1-ep)+er*math.sin(na)*ep
		return ((cen + Vector3.new(tx, 50+d.v1*20+math.sin(ph+d.v2)*5, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Hex Radius", 15, 120, c.k11, function(v) c.k11 = v end); UIManager.s(p, "Fractal Depth", 1, 4, c.k12, function(v) c.k12 = v end) end
})

-- Mode Registration: Leviathan Coil
register_mode("Leviathan Coil", { k11 = 50, k12 = 15, k13 = 8, k14 = 250 }, {
	Init = function(d) d.v1 = math.random() < 0.45 and 1 or (math.random() < 0.58 and 2 or (math.random() < 0.72 and 3 or (math.random() < 0.87 and 4 or 5))); d.v2 = math.random() * math.pi * 2; d.v3 = math.random(); d.v4 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local CR, Tk, s, H = (c.k11 or 50), (c.k12 or 15), (c.k13 or 8)*Constants.c2, (c.k14 or 250); local ph, tx, ty, tz, bob = t*s, 0, 0, 0, math.sin(t*s*0.3)*15
		if d.v1 == 1 then local pr = d.v3; local ca = pr*math.pi*8+ph; local thick = Tk*(0.5+math.sin(pr*math.pi)*0.5); tx, tz, ty = (CR+math.cos(d.v2)*thick)*math.cos(ca), (CR+math.cos(d.v2)*thick)*math.sin(ca), pr*H+bob+math.sin(d.v2)*thick
		elseif d.v1 == 2 then local ha = ph; local hr = Tk*1.5; local jo = math.sin(ph*2)*0.5+0.5; local jos = (d.v3>0.5 and 1 or -1)*jo*8; tx, tz, ty = CR*math.cos(ha)+math.cos(d.v2)*hr*d.v3, CR*math.sin(ha)+math.sin(d.v2)*hr*d.v3, H+bob+10+jos+math.cos(d.v4)*hr*0.3
		elseif d.v1 == 3 then local pr = d.v3*0.3; local ta = pr*math.pi*4+ph*2; local taper = Tk*(1-d.v3)*0.4; local wo = math.sin(ph*8+pr*20)*taper*2; tx, tz, ty = (CR+wo)*math.cos(ta)+math.cos(d.v2)*taper, (CR+wo)*math.sin(ta)+math.sin(d.v2)*taper, pr*H*0.3+bob-10+math.sin(d.v4+ph*3)*taper
		elseif d.v1 == 4 then local wp = d.v3>0.5 and 0.35 or 0.65; local wa, fc = wp*math.pi*8+ph, math.sin(ph*1.5+(d.v3>0.5 and 0 or math.pi)); local ws = math.max(0,fc)*CR*1.5; local wpr = d.v4/(math.pi*2); local fa = wa+(d.v2>math.pi and 1 or -1)*math.pi*0.5; local fr = wpr*ws; tx, tz, ty = CR*math.cos(wa)+fr*math.cos(fa+(wpr-0.5)*0.8), CR*math.sin(wa)+fr*math.sin(fa+(wpr-0.5)*0.8), wp*H+bob+fr*0.3*math.sin(wpr*math.pi)
		else local pr = d.v3; local ca = pr*math.pi*8+ph; local sr, su = CR, Tk*(0.5+math.sin(pr*math.pi)*0.5)+5; tx, tz, ty = sr*math.cos(ca), sr*math.sin(ca), pr*H+bob+su+math.sin(pr*30+ph*2)*2
		end
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Coil Radius", 15, 150, c.k11, function(v) c.k11 = v end) end
})
register_mode("Klein Bottle", { k11 = 60, k13 = 20 }, {
	Init = function(d) d.v1 = math.random() * math.pi * 2; d.v2 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local R, s = (c.k11 or 60), (c.k13 or 20) * Constants.c2; local up, vp = (t * s) + d.v1, (t * s * 0.5) + d.v2
		local cu, su, cv, sv = math.cos(up), math.sin(up), math.cos(vp), math.sin(vp)
		local tx, ty, tz = (R + cu * sv - su * sv * 2) * cv, su * sv * R, (R + cu * sv - su * sv * 2) * sv
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Bottle Radius", 10, 300, c.k11, function(v) c.k11 = v end) end
})
function UIManager.AddGlobalSettings(container)
	UIManager.h(container, "- ENGINE SETTINGS -")
	UIManager.s(container, "Damping", 0, 10, Config.Damping * 10, function(v) Config.Damping = v / 10 end)
	UIManager.s(container, "Max Speed", 50, 2000, Config.MaxSpeed, function(v) Config.MaxSpeed = v end)
	UIManager.t(container, "Anti-Fling", Config.AntiFling, function(v) Config.AntiFling = v end)
	UIManager.t(container, "Anchor Self", Config.AnchorSelf, function(v) Config.AnchorSelf = v end)
	UIManager.t(container, "Disable Script", Config.Disabled, function(v) Config.Disabled = v end)
end


-- Part Discovery Logic
function PhysicsEngine.DiscoverParts()
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and not State.a[p] then 
			local already_queued = false
			for _, qp in ipairs(State.claim_queue) do if qp == p then already_queued = true break end end
			if not already_queued then table.insert(State.claim_queue, p) end
		end
		if #State.claim_queue % 500 == 0 then task.wait() end
	end
	Workspace.DescendantAdded:Connect(function(p)
		if p:IsA("BasePart") and not State.a[p] then table.insert(State.claim_queue, p) end
	end)
end

-- Mode Registration: Hollow Worm
register_mode("Hollow Worm", {
	k11 = 8, k12 = 0, k13 = 15, k14 = 35, k15 = 10, k16 = 0.4, k17 = 150
}, {
	Init = function(d)
		d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		d.v6 = math.random()
	end,
	Update = function(p, cen, d, c, t)
		local r, wf = (c.k11 or 8), (c.k15 or 10) * Constants.c7
		local s, h, l = (c.k13 or 10) * Constants.c2, c.k14 or 50, (c.k16 or Constants.c5) * 100
		local ph = (t * s) - (d.v6 * (l * Constants.c2))
		local R = (c.k17 or 150)
		local center_pos = Vector3.new(math.cos(ph) * R, math.sin(ph * wf) * h, math.sin(ph) * R)
		local cx, sx = math.cos(t * 2), math.sin(t * 2)
		local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx, d.v4.Y, d.v4.X * sx + d.v4.Z * cx).Unit
		return ((cen + center_pos + (rd * r)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c)
		UIManager.s(p, "Worm Radius", 5, 100, c.k11, function(v) c.k11 = v end)
		UIManager.s(p, "Worm Height", 10, 200, c.k14, function(v) c.k14 = v end)
	end
})

-- Mode Registration: Cosmic Comet
register_mode("Cosmic Comet", {
	k11 = 5, k12 = 50, k13 = 20, k14 = 20, k15 = 5, k16 = 0.5, k17 = 150
}, {
	Init = function(d)
		d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		d.v6 = math.random(); d.v8 = math.random()
	end,
	Update = function(p, cen, d, c, t)
		local hr, ts = (c.k11 or 4), (c.k12 or 50) * Constants.c7
		local s, h, l = (c.k13 or 10) * Constants.c2, c.k14 or 50, (c.k16 or Constants.c5) * 100
		local ph = (t * s) - (d.v6 * (l * Constants.c2))
		local R = (c.k17 or 150)
		local center_pos = Vector3.new(math.cos(ph) * R, math.sin(ph * (c.k15 or 5) * Constants.c7) * h, math.sin(ph) * R)
		local fin = center_pos + (d.v4 * (d.v8 * (hr + (d.v6 * d.v6 * 30 * ts))))
		return ((cen + fin) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c)
		UIManager.s(p, "Comet Size", 1, 50, c.k11, function(v) c.k11 = v end)
		UIManager.s(p, "Tail Length", 10, 500, c.k12, function(v) c.k12 = v end)
	end
})

-- Mode Registration: Orbital Shell
register_mode("Orbital Shell", {
	k11 = 90, k12 = 0, k13 = 15, k14 = 0, k15 = 0, k16 = 0, k17 = 150, k18 = false, k19 = false
}, {
	Init = function(d)
		d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		d.v5 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
	end,
	Update = function(p, cen, d, c, t)
		local R, s = (c.k11 or 200), (c.k13 or 10) * Constants.c2
		local ca, sa = math.cos(t * s), math.sin(t * s)
		local k, v = d.v5, d.v4
		local rv = v * ca + k:Cross(v) * sa + k * (k:Dot(v) * (1 - ca))
		if c.k18 then rv = Vector3.new(rv.X, math.abs(rv.Y), rv.Z) end
		return ((cen + (rv * R)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c)
		UIManager.s(p, "Shell Radius", 50, 1000, c.k11, function(v) c.k11 = v end)
		UIManager.t(p, "Hemisphere", c.k18, function(v) c.k18 = v end)
	end
})


-- Mode Registration: Point Impact (Hyper-Impact)
register_mode("Point Impact", {
	k11 = 0, k13 = 500, k17 = 50
}, {
	Init = function(d)
		d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		d.v5 = math.random() - 0.5
	end,
	Update = function(p, cen, d, c, t)
		local s, radius = 500, c.k11 or 0
		if Config.ImpactManual then
			if not Config.IsLaunching then s, radius = 1, 35 else s, radius = 1000, 0 end
		end
		local cx, sx = math.cos(t * s), math.sin(t * s)
		local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx, d.v4.Y + d.v5, d.v4.X * sx + d.v4.Z * cx).Unit
		local target_pos = cen + (rd * radius)
		return (target_pos - p.Position) * 5000 -- Overpowering "Hyper-Impact" force
	end,
	UI = function(p, c)
		UIManager.s(p, "Impact Radius", 0, 100, c.k11, function(v) c.k11 = v end)
		UIManager.t(p, "Manual Launch", Config.ImpactManual, function(v) Config.ImpactManual = v end)
	end
})

-- Mode Registration: Big Ring Things
register_mode("Big Ring Things", { k9 = 50, k11 = 2, k12 = 170, k13 = 10, k14 = 5, k15 = 12, k16 = 2 }, {
	Init = function(d) d.v1 = math.random(1, 2); d.v3 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local rc, gap, r_base = (c.k11 or 2), (c.k12 or 170), (c.k9 or 50); if not d.v1 or d.v2 ~= rc then d.v1 = math.random(1, rc); d.v2 = rc end
		local spd = (Constants.c2 - (d.v1-1)*Constants.c3)*(c.k13 or 10); if d.v1%2==0 then spd = -spd end
		local a = d.v3+(t*spd); local tx, tz = math.cos(a)*(r_base+(d.v1-1)*gap), math.sin(a)*(r_base+(d.v1-1)*gap)
		local sw = math.sin(t*(c.k16 or Constants.c4)+d.v1)*math.rad(c.k15 or 12)
		local cy, sy, cx, sx = math.cos(sw), math.sin(sw), math.cos(sw*0.5), math.sin(sw*0.5)
		local ny = -tz*sy; local nz = tz*cy; local nx = tx*cx - ny*sx; ny = tx*sx + ny*cx; tx, ty, tz = nx, ny, nz
		local tp = cen + Vector3.new(tx, ty, tz); local ho = c.k14 or 5; if tp.Y < ho then tp = Vector3.new(tp.X, ho, tp.Z) end
		return (tp - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) 
		UIManager.s(p, "Core Radius", 10, 500, c.k9, function(v) c.k9 = v end)
		UIManager.s(p, "Ring Count", 1, 5, c.k11, function(v) c.k11 = v end) 
	end
})

-- Mode Registration: Slingshot
register_mode("Slingshot", { k11 = 50, k12 = 3, k13 = 100 }, {
	Init = function(d) d.v1 = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit; d.v2 = 0 end,
	Update = function(p, cen, d, c, t)
		local dist, cycle, spd = (c.k11 or 50), (c.k12 or 3), (c.k13 or 100)
		local ph = (t+d.v2)%cycle; local isC = Config.SlingshotManual and (not Config.IsLaunching) or (ph < cycle*0.8)
		if isC then return ((cen + d.v1*dist) - p.Position) * (5 * Constants.c1) end
		return (cen - p.Position) * (spd * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Charge Dist", 10, 200, c.k11, function(v) c.k11 = v end); UIManager.t(p, "Manual Launch", Config.SlingshotManual, function(v) Config.SlingshotManual = v end) end
})

-- Mode Registration: Gods Call
register_mode("Gods Call", { k11 = 10 }, {
	Update = function(p, cen, d, c, t) return Vector3.new(0, c.k11 or 10, 0) end,
	UI = function(p, c) UIManager.s(p, "Ascent Speed", 1, 100, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Deflect
register_mode("Deflect", { k11 = 50, k12 = 500 }, {
	Update = function(p, cen, d, c, t)
		local range, spd = (c.k11 or 50), (c.k12 or 500)
		if (cen - p.Position).Magnitude < range then return (p.Position - cen).Unit * spd end
		return ANTI_SLEEP
	end,
	UI = function(p, c) UIManager.s(p, "Deflect Range", 10, 500, c.k11, function(v) c.k11 = v end) end
})

-- Mode Registration: Shield Wall
register_mode("Shield Wall", { k11 = 1, k12 = 10, k13 = 20, k14 = 15, k15 = 0 }, {
	Init = function(d) d.v4 = math.random()-0.5; d.v5 = math.random()-0.5 end,
	Update = function(p, cen, d, c, t)
		local s, w, h, dv, ho = (c.k13 or 20)*Constants.c2, (c.k11 or 1), (c.k12 or 10), (c.k14 or 15), (c.k15 or 0)
		local ang = (t*s)+(d.v4*w); local tx, tz, ty = math.cos(ang)*dv, math.sin(ang)*dv, (d.v5*h)+ho
		return ((cen + Vector3.new(tx, ty, tz)) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c) UIManager.s(p, "Wall Distance", 5, 100, c.k14, function(v) c.k14 = v end) end
})

-- Mode Registration: Sculptor
register_mode("Sculptor", {}, {
	Update = function(p, cen, d, c, t)
		if State.sculptor_selected[p] then
			if State.sculptor_dragging and State.sculptor_drag_target then
				local target_pos = State.sculptor_drag_target + (State.sculptor_selected[p] or Vector3.zero)
				local delta = target_pos - p.Position; local dist = delta.Magnitude
				if dist < 0.5 then return ANTI_SLEEP end
				return delta.Unit * math.clamp(dist * 3, 1, 100)
			end
			return ANTI_SLEEP
		end
		return ANTI_SLEEP
	end,
	UI = function(p, c) UIManager.h(p, "Click parts to select."); UIManager.h(p, "Hold Shift to multi-select."); UIManager.h(p, "Drag selected parts.") end
})
register_mode("Vortex Funnel", {
	k11 = 50, k12 = 300, k13 = 30, k14 = 400, k15 = 5
}, {
	Init = function(d) d.v4 = math.random(); d.v6 = math.random() * math.pi * 2 end,
	Update = function(p, cen, d, c, t)
		local s, R_base, R_top, H = (c.k13 or 10) * Constants.c2, (c.k11 or 50), (c.k12 or 300), (c.k14 or 400)
		local current_r = R_base + ((R_top - R_base) * (d.v4 ^ 2))
		local phase = (t * s) + d.v6 + ((1 - d.v4) * (c.k15 or 5) * 5)
		local fin = Vector3.new(current_r * math.cos(phase), d.v4 * H - (H / 2), current_r * math.sin(phase))
		return ((cen + fin) - p.Position) * (Config.k10 * Constants.c1)
	end,
	UI = function(p, c)
		UIManager.s(p, "Base Radius", 10, 200, c.k11, function(v) c.k11 = v end)
		UIManager.s(p, "Top Radius", 50, 1000, c.k12, function(v) c.k12 = v end)
		UIManager.s(p, "Funnel Height", 100, 1000, c.k14, function(v) c.k14 = v end)
	end
})

-- Targeting UI & Logic

-- Update Heartbeat to handle Targets
RunService.Heartbeat:Connect(function()
	local target_pos = Vector3.zero
	if Config.Tgt then
		if Config.Tgt == Mouse then target_pos = Mouse.Hit.Position
		elseif Config.Tgt:IsA("Player") and Config.Tgt.Character and Config.Tgt.Character:FindFirstChild("HumanoidRootPart") then
			target_pos = Config.Tgt.Character.HumanoidRootPart.Position
		end
	end
	if State.b then State.b.Position = target_pos end
end)

-- UI Builder

-- UI Builder

function UIManager.s(p, t, mn, mx, df, cb)
	-- Slider implementation (optimized copy from original)
	df = df or mn
	local f = Instance.new("Frame", p); f.BackgroundTransparency = 1; f.Size = UDim2.new(1, 0, 0, 36)
	local l = Instance.new("TextLabel", f); l.BackgroundTransparency = 1; l.Size = UDim2.new(1, 0, 0, 18); l.Text = t
	l.TextColor3 = Color3.fromRGB(220, 220, 220); l.TextXAlignment = 0; l.Font = Enum.Font.GothamMedium; l.TextSize = 13
	local vl = Instance.new("TextLabel", f); vl.BackgroundTransparency = 1; vl.Position = UDim2.new(1, -50, 0, 0)
	vl.Size = UDim2.new(0, 50, 0, 18); vl.Text = tostring(df); vl.TextColor3 = Color3.fromRGB(220, 220, 220)
	vl.TextXAlignment = 1; vl.Font = Enum.Font.GothamBold; vl.TextSize = 13
	local sc = Instance.new("Frame", f); sc.BackgroundTransparency = 1; sc.Position = UDim2.new(0, 0, 0, 22); sc.Size = UDim2.new(1, 0, 0, 6)
	local sb = Instance.new("Frame", sc); sb.BackgroundColor3 = Color3.fromRGB(45, 45, 50); sb.BorderSizePixel = 0; sb.Size = UDim2.new(1, 0, 1, 0)
	Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
	local fl = Instance.new("Frame", sb); fl.BackgroundColor3 = Color3.fromRGB(255, 105, 180); fl.BorderSizePixel = 0
	fl.Size = UDim2.new((df - mn) / (mx - mn), 0, 1, 0)
	Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
	local k = Instance.new("ImageButton", sc); k.BackgroundColor3 = Color3.fromRGB(255, 255, 255); k.AnchorPoint = Vector2.new(0.5, 0.5)
	k.Position = UDim2.new((df - mn) / (mx - mn), 0, 0.5, 0); k.Size = UDim2.new(0, 14, 0, 14); k.BorderSizePixel = 0
	Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
	local dragging = false
	local function update(input)
		local pc = math.clamp((input.Position.X - sc.AbsolutePosition.X) / sc.AbsoluteSize.X, 0, 1)
		local val = math.floor(mn + (mx - mn) * pc + 0.5)
		fl.Size = UDim2.new(pc, 0, 1, 0); k.Position = UDim2.new(pc, 0, 0.5, 0); vl.Text = tostring(val)
		cb(val); save_settings()
	end
	k.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
	sb.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end)
end

function UIManager.t(p, t, df, cb)
	local f = Instance.new("Frame", p); f.BackgroundTransparency = 1; f.Size = UDim2.new(1, 0, 0, 30)
	local l = Instance.new("TextLabel", f); l.BackgroundTransparency = 1; l.Size = UDim2.new(0.8, 0, 1, 0); l.Text = t
	l.TextColor3 = Color3.fromRGB(220, 220, 220); l.TextXAlignment = 0; l.Font = Enum.Font.GothamMedium; l.TextSize = 13
	local b = Instance.new("TextButton", f); b.BackgroundColor3 = df and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
	b.Position = UDim2.new(1, -24, 0.5, -12); b.Size = UDim2.new(0, 24, 0, 24); b.Text = ""
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function() df = not df; b.BackgroundColor3 = df and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60); cb(df); save_settings() end)
	return b
end

function UIManager.h(p, t)
	local l = Instance.new("TextLabel", p); l.BackgroundTransparency = 1; l.Size = UDim2.new(1, 0, 0, 20); l.Text = t
	l.TextColor3 = Color3.fromRGB(150, 150, 255); l.Font = Enum.Font.GothamBold; l.TextSize = 12
end

-- System Managers: Input & Optimizations


-- Sculptor Selection Helpers
function Managers.ClearSculptor()
	for p, h in pairs(State.sculptor_highlights) do if h and h.Parent then h:Destroy() end end
	State.sculptor_highlights = {}; State.sculptor_selected = {}; State.sculptor_dragging = false
	if State.sculptor_box then State.sculptor_box:Destroy(); State.sculptor_box = nil end
	State.sculptor_box_start = nil
end

function Managers.AddSculptorHighlight(p)
	if State.sculptor_highlights[p] then return end
	local h = Instance.new("SelectionBox"); h.Adornee = p; h.Color3 = Color3.fromRGB(0, 255, 200); h.LineThickness = 0.05
	h.SurfaceTransparency = 0.8; h.SurfaceColor3 = Color3.fromRGB(0, 255, 200); h.Parent = p; State.sculptor_highlights[p] = h
end

-- Hotkey Actions
function PhysicsEngine.Start(pos)
	if State.b then TweenService:Create(State.b, TweenInfo.new(0.5), { Position = pos }):Play(); return end
	local f = Instance.new("Folder", Workspace); f.Name = "ModularGravity_Anchor"
	State.b = Instance.new("Part", f); State.b.Size = Config.k2; State.b.Shape = "Ball"; State.b.Color = Config.k3; State.b.Anchored = true
	State.b.CanCollide = false; State.b.Material = "Neon"; State.b.Position = pos; State.b.Transparency = 0.5
	local bg = Instance.new("BillboardGui", State.b); bg.Name = "Visual"; bg.Adornee = State.b; bg.Size = UDim2.new(0, 25, 0, 25); bg.AlwaysOnTop = true
	local img = Instance.new("ImageLabel", bg); img.BackgroundTransparency = 1; img.Size = UDim2.new(1, 0, 1, 0); img.Image = "rbxassetid://3570695787"; img.ImageColor3 = Config.k3
	TweenService:Create(State.b, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Size = Config.k2 * 1.2 }):Play()
	PhysicsEngine.DiscoverParts(); State.o = true; Utils.n("Sys", "Engine Started", 3)
end

function PhysicsEngine.Stop()
	if State.b then State.b.Parent:Destroy(); State.b = nil end
	for p, _ in pairs(State.a) do PhysicsEngine.f2(p) end
	State.o = false; Utils.n("Sys", "Engine Stopped", 2)
end

-- Input Handling
ContextActionService:BindAction("ModularGravity_Start", function(_, s) if s == Enum.UserInputState.Begin then PhysicsEngine.Start(Mouse.Hit.p) end end, false, Enum.KeyCode.E)
ContextActionService:BindAction("ModularGravity_Stop", function(_, s) if s == Enum.UserInputState.Begin then PhysicsEngine.Stop() end end, false, Enum.KeyCode.Q)
ContextActionService:BindAction("ModularGravity_Pause", function(_, s) if s == Enum.UserInputState.Begin then Config.Paused = not Config.Paused; Utils.n("Sys", Config.Paused and "Paused" or "Resumed", 2) end end, false, Enum.KeyCode.P)
ContextActionService:BindAction("ModularGravity_Disable", function(_, s)
	if s == Enum.UserInputState.Begin then
		Config.Disabled = not Config.Disabled; Utils.n("Sys", Config.Disabled and "Disabled" or "Enabled", 2)
		if State.b then State.b.Transparency = Config.Disabled and 1 or 0.5; if State.b:FindFirstChild("Visual") then State.b.Visual.Enabled = not Config.Disabled end end
		for _, d in pairs(State.a) do if d.lv then d.lv.MaxForce = Config.Disabled and 0 or Config.k4 end; if d.av then d.av.MaxTorque = Config.Disabled and 0 or math.huge end end
	end
end, false, Enum.KeyCode.L)

-- Sculptor Input Logic
UserInputService.InputBegan:Connect(function(i, g)
	if g or Config.k6 ~= "Sculptor" then return end
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		local t = Mouse.Target; local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		if t and State.a[t] then
			if State.sculptor_selected[t] then
				if shift then State.sculptor_selected[t] = nil; if State.sculptor_highlights[t] then State.sculptor_highlights[t]:Destroy(); State.sculptor_highlights[t]=nil end
				else State.sculptor_dragging = true; State.sculptor_drag_distance = (Workspace.CurrentCamera.CFrame.Position - t.Position).Magnitude
					State.sculptor_drag_target = t.Position; for p, _ in pairs(State.sculptor_selected) do State.sculptor_selected[p] = p.Position - t.Position end
				end
			else
				if not shift then Managers.ClearSculptor() end
				State.sculptor_selected[t] = Vector3.zero; Managers.AddSculptorHighlight(t)
				if not shift then State.sculptor_dragging = true; State.sculptor_drag_distance = (Workspace.CurrentCamera.CFrame.Position - t.Position).Magnitude; State.sculptor_drag_target = t.Position end
			end
		else
			if not shift then Managers.ClearSculptor() end
			State.sculptor_box_start = UserInputService:GetMouseLocation()
			if not State.sculptor_box then State.sculptor_box = Instance.new("Frame", UIManager.g); State.sculptor_box.BackgroundColor3 = Color3.fromRGB(0, 255, 200); State.sculptor_box.BackgroundTransparency = 0.7; State.sculptor_box.BorderSizePixel = 2; State.sculptor_box.BorderColor3 = Color3.fromRGB(0, 255, 200); State.sculptor_box.ZIndex = 50 end
		end
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if Config.k6 ~= "Sculptor" then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement then
		if State.sculptor_dragging then
			local cam = Workspace.CurrentCamera; local mp = UserInputService:GetMouseLocation(); local ray = cam:ViewportPointToRay(mp.X, mp.Y)
			State.sculptor_drag_target = ray.Origin + (ray.Direction * (State.sculptor_drag_distance or 50))
		elseif State.sculptor_box_start and State.sculptor_box then
			local cur = UserInputService:GetMouseLocation(); local mX, mY, MX, MY = math.min(State.sculptor_box_start.X, cur.X), math.min(State.sculptor_box_start.Y, cur.Y), math.max(State.sculptor_box_start.X, cur.X), math.max(State.sculptor_box_start.Y, cur.Y)
			State.sculptor_box.Position = UDim2.new(0, mX, 0, mY); State.sculptor_box.Size = UDim2.new(0, MX-mX, 0, MY-mY); State.sculptor_box.Visible = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		State.sculptor_dragging = false; State.sculptor_drag_target = nil
		if State.sculptor_box_start and State.sculptor_box then
			local cur = UserInputService:GetMouseLocation(); local mX, mY, MX, MY = math.min(State.sculptor_box_start.X, cur.X), math.min(State.sculptor_box_start.Y, cur.Y), math.max(State.sculptor_box_start.X, cur.X), math.max(State.sculptor_box_start.Y, cur.Y)
			local cam = Workspace.CurrentCamera; if cam then for p, _ in pairs(State.a) do local sPos, onS = cam:WorldToViewportPoint(p.Position); if onS and sPos.X >= mX and sPos.X <= MX and sPos.Y >= mY and sPos.Y <= MY then State.sculptor_selected[p] = Vector3.zero; Managers.AddSculptorHighlight(p) end end end
			State.sculptor_box.Visible = false; State.sculptor_box_start = nil
		end
	end
end)

-- Load and Initialize
load_settings(); UIManager.st(); UIManager.mw(UIManager.g)
