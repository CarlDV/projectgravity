--!native

local SESSION_ID = tostring(math.random(1000000, 9999999)) .. tostring(time())

if getgenv()._GRAVITY_SESSION_ID ~= nil and getgenv()._GRAVITY_DESTROY then
	pcall(getgenv()._GRAVITY_DESTROY)
end

getgenv()._GRAVITY_SESSION_ID = SESSION_ID

local function safe_service(name)
	local service = game:GetService(name)
	if cloneref then
		return cloneref(service)
	end
	return service
end

local v1, v2, v3, v4, v5, v6, v7 =
	safe_service("UserInputService"),
	safe_service("Players"),
	safe_service("RunService"),
	safe_service("Workspace"),
	safe_service("StarterGui"),
	safe_service("TweenService"),
	safe_service("ContextActionService")
local HttpService = safe_service("HttpService")

if setthreadidentity then
	pcall(function()
		setthreadidentity(8)
	end)
end

local function cleanup_previous()
	if gethui then
		for _, gui in ipairs(gethui():GetChildren()) do
			if gui:IsA("ScreenGui") and (gui.Name == "GravityLoading" or string.sub(gui.Name, 1, 2) == "G_") then
				pcall(function() gui:Destroy() end)
			end
		end
	elseif syn and syn.protect_gui then
		local core = game:GetService("CoreGui")
		for _, gui in ipairs(core:GetChildren()) do
			if gui:IsA("ScreenGui") and (gui.Name == "GravityLoading" or string.sub(gui.Name, 1, 2) == "G_") then
				pcall(function() gui:Destroy() end)
			end
		end
	else
		local pg = v2.LocalPlayer:FindFirstChild("PlayerGui")
		if pg then
			for _, gui in ipairs(pg:GetChildren()) do
				if gui:IsA("ScreenGui") and (gui.Name == "GravityLoading" or string.sub(gui.Name, 1, 2) == "G_") then
					pcall(function() gui:Destroy() end)
				end
			end
		end
	end
end
cleanup_previous()

local v8, v9 = v2.LocalPlayer, v2.LocalPlayer:GetMouse()
local is_mobile = v1.TouchEnabled and not v1.KeyboardEnabled
local SUB_DIR = is_mobile and "mobilever/" or ""

local loading_sg = Instance.new("ScreenGui")
loading_sg.Name = "GravityLoading"
loading_sg.DisplayOrder = 99999
loading_sg.IgnoreGuiInset = true
loading_sg.ResetOnSpawn = false
if gethui then
	loading_sg.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(loading_sg)
	loading_sg.Parent = game:GetService("CoreGui")
else
	loading_sg.Parent = v8:WaitForChild("PlayerGui")
end

local ACCENT = Color3.fromRGB(126, 92, 255)
local ACCENT2 = Color3.fromRGB(56, 214, 255)

local veil = Instance.new("Frame", loading_sg)
veil.BackgroundColor3 = Color3.fromRGB(6, 7, 11)
veil.BackgroundTransparency = 0.35
veil.BorderSizePixel = 0
veil.Size = UDim2.new(1, 0, 1, 0)

local stage = Instance.new("Frame", loading_sg)
stage.BackgroundTransparency = 1
stage.AnchorPoint = Vector2.new(0.5, 0.5)
stage.Position = UDim2.new(0.5, 0, 0.5, 0)
stage.Size = UDim2.new(0, 220, 0, 130)

local spinner = Instance.new("Frame", stage)
spinner.BackgroundTransparency = 1
spinner.AnchorPoint = Vector2.new(0.5, 0)
spinner.Position = UDim2.new(0.5, 0, 0, 0)
spinner.Size = UDim2.new(0, 40, 0, 40)
Instance.new("UICorner", spinner).CornerRadius = UDim.new(1, 0)
local uis = Instance.new("UIStroke", spinner)
uis.Thickness = 2.5
uis.Color = ACCENT
local uig = Instance.new("UIGradient", uis)
uig.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, ACCENT),
	ColorSequenceKeypoint.new(1, ACCENT2),
})
uig.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.45, 0.1),
	NumberSequenceKeypoint.new(1, 1),
})

local inner = Instance.new("Frame", spinner)
inner.BackgroundTransparency = 1
inner.AnchorPoint = Vector2.new(0.5, 0.5)
inner.Position = UDim2.new(0.5, 0, 0.5, 0)
inner.Size = UDim2.new(0, 20, 0, 20)
Instance.new("UICorner", inner).CornerRadius = UDim.new(1, 0)
local inner_stroke = Instance.new("UIStroke", inner)
inner_stroke.Thickness = 1.5
inner_stroke.Color = Color3.fromRGB(255, 94, 188)
inner_stroke.Transparency = 0.3
local inner_grad = Instance.new("UIGradient", inner_stroke)
inner_grad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.05),
	NumberSequenceKeypoint.new(1, 1),
})

local core = Instance.new("Frame", spinner)
core.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
core.BorderSizePixel = 0
core.AnchorPoint = Vector2.new(0.5, 0.5)
core.Position = UDim2.new(0.5, 0, 0.5, 0)
core.Size = UDim2.new(0, 6, 0, 6)
Instance.new("UICorner", core).CornerRadius = UDim.new(1, 0)

local wordmark = Instance.new("TextLabel", stage)
wordmark.BackgroundTransparency = 1
wordmark.Position = UDim2.new(0, 0, 0, 58)
wordmark.Size = UDim2.new(1, 0, 0, 20)
wordmark.Text = "PROJECT GRAVITY"
wordmark.TextColor3 = Color3.fromRGB(240, 242, 252)
wordmark.Font = Enum.Font.GothamBlack
wordmark.TextSize = 15

local loading_text = Instance.new("TextLabel", stage)
loading_text.BackgroundTransparency = 1
loading_text.Position = UDim2.new(0, 0, 0, 80)
loading_text.Size = UDim2.new(1, 0, 0, 14)
loading_text.Text = "initialising"
loading_text.TextColor3 = Color3.fromRGB(120, 126, 152)
loading_text.Font = Enum.Font.GothamMedium
loading_text.TextSize = 11

local bar_bed = Instance.new("Frame", stage)
bar_bed.BackgroundColor3 = Color3.fromRGB(25, 27, 39)
bar_bed.BorderSizePixel = 0
bar_bed.AnchorPoint = Vector2.new(0.5, 0)
bar_bed.Position = UDim2.new(0.5, 0, 0, 104)
bar_bed.Size = UDim2.new(0, 140, 0, 3)
Instance.new("UICorner", bar_bed).CornerRadius = UDim.new(1, 0)

local bar = Instance.new("Frame", bar_bed)
bar.BackgroundColor3 = ACCENT
bar.BorderSizePixel = 0
bar.Size = UDim2.new(0.08, 0, 1, 0)
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
local bar_grad = Instance.new("UIGradient", bar)
bar_grad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, ACCENT),
	ColorSequenceKeypoint.new(1, ACCENT2),
})

local boot_progress, boot_shown = 0.08, 0.08
local function boot_status(text, progress)
	loading_text.Text = text
	boot_progress = progress or boot_progress
end

local spin_t = 0
local spin_conn = v3.RenderStepped:Connect(function(dt)
	spin_t = spin_t + dt
	spinner.Rotation = spin_t * 260
	inner.Rotation = spin_t * -420
	local pulse = 5 + 2 * (0.5 + 0.5 * math.sin(spin_t * 4))
	core.Size = UDim2.new(0, pulse, 0, pulse)
	boot_shown = boot_shown + (boot_progress - boot_shown) * math.min(1, dt * 6)
	bar.Size = UDim2.new(boot_shown, 0, 1, 0)
end)

local x9 = { c1 = 0.15, c2 = 0.05, c3 = 0.01, c4 = 0.2, c5 = 0.6, c6 = 0.8, c7 = 0.1, c8 = 0.25 }
local ANTI_SLEEP = Vector3.new(0, 0.01, 0)
local BASE_URL = "https://raw.githubusercontent.com/CarlDV/projectgravity/main/"

local function safe_http_get(url)
	local cache_buster = "?cb=" .. tostring(math.random(1000000, 9999999))
	local fetch_url = url .. cache_buster
	local success, result = pcall(function()
		return game:HttpGet(fetch_url)
	end)
	if success and result then
		return result
	end
	local req = (type(request) == "function" and request) or (type(http) == "table" and http.request) or (type(syn) == "table" and syn.request)
	if req then
		local s, r = pcall(function()
			return req({Url = fetch_url, Method = "GET"})
		end)
		if s and type(r) == "table" and r.Body then
			return r.Body
		end
	end
	return nil
end

local function load_module(path)
	local code = safe_http_get(BASE_URL .. path)
	if code and not string.match(code, "^404: Not Found") then
		local func, err = loadstring(code)
		if func then
			return func()
		end
		warn("Syntax error in module " .. path .. ": " .. tostring(err))
		return nil
	end
	warn("Failed to download module: " .. path)
	return nil
end

local config = load_module("config.lua")
boot_status("configuration", 0.22)
local x1 = config.x1
local x2 = config.x2
x1.S = x2
if is_mobile then
	-- the on-screen dock is the only way to place the core without a keyboard
	x1.ShowDock = true
end

local local_shapes = {}
if isfolder and makefolder and listfiles and readfile then
	pcall(function()
		if not isfolder("GravityShapes") then
			makefolder("GravityShapes")
		end
		local files = listfiles("GravityShapes")
		for _, file in ipairs(files) do
			if string.match(string.lower(file), "%.lua$") or string.match(string.lower(file), "%.txt$") then
				local name = string.match(file, "([^/\\]+)%.[^%.]+$")
				if name then
					local_shapes[name] = file
					if not x2[name] then
						x2[name] = {}
						local read_success, code = pcall(readfile, file)
						if read_success and code then
							local func = loadstring(code)
							if func then
								local load_success, shape_mod = pcall(func)
								if load_success and type(shape_mod) == "table" and shape_mod.Controls then
									for _, ctrl in ipairs(shape_mod.Controls) do
										if type(ctrl) == "table" and ctrl.Key then
											local default_val = ctrl.Default
											if default_val == nil then
												default_val = ctrl.Min or 0
											end
											if ctrl.Div then
												default_val = default_val / ctrl.Div
											end
											x2[name][ctrl.Key] = default_val
										end
									end
								end	
							end
						end
					end
				end
			end
		end
	end)
end

local default_x1 = {}
for k, v in pairs(x1) do
	if typeof(v) == "table" then
		default_x1[k] = {}
		for sk, sv in pairs(v) do
			default_x1[k][sk] = sv
		end
	else
		default_x1[k] = v
	end
end
local default_x2 = {}
for mk, mv in pairs(x2) do
	default_x2[mk] = {}
	for sk, sv in pairs(mv) do
		default_x2[mk][sk] = sv
	end
end

local function reset_config()
	for k, v in pairs(default_x1) do
		if k ~= "S" and k ~= "Targets" then
			if typeof(v) == "table" then
				x1[k] = {}
				for sk, sv in pairs(v) do
					x1[k][sk] = sv
				end
			else
				x1[k] = v
			end
		end
	end
	for mk, mv in pairs(default_x2) do
		if x2[mk] then
			table.clear(x2[mk])
			for sk, sv in pairs(mv) do
				x2[mk][sk] = sv
			end
		end
	end
	x1.S = x2
end

local serialization = load_module("math/serialization.lua")
local sanitize = serialization.sanitize
local desanitize = serialization.desanitize

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

local save_pending = false
local function save_settings()
	if not writefile then
		return
	end
	if save_pending then return end
	save_pending = true
	task.delay(0.5, function()
		save_pending = false
		local data = { x1 = sanitize(x1), x2 = sanitize(x2) }
		data.x1.Tgt = nil
		data.x1.IsLaunching = nil
		local success, json = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		if success then
			pcall(function()
				writefile("GravitySettings_Auto.json", json)
			end)
		end
	end)
end

local function load_settings()
	if isfile and isfile("GravitySettings_Auto.json") then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile("GravitySettings_Auto.json"))
		end)
		if success and data then
			local cx1 = desanitize(data.x1)
			local cx2 = desanitize(data.x2)
			for k, v in pairs(cx1) do
				if k ~= "S" and x1[k] ~= nil and typeof(x1[k]) == typeof(v) then
					x1[k] = v
				end
			end
			for mk, mv in pairs(cx2) do
				if x2[mk] and type(mv) == "table" then
					for sk, sv in pairs(mv) do
						if x2[mk][sk] ~= nil and typeof(x2[mk][sk]) == typeof(sv) then
							x2[mk][sk] = sv
						end
					end
				end
			end
		end
	end
end
load_settings()
boot_status("settings", 0.34)

if setfpscap then
	pcall(function()
		local cap = tonumber(x1.FPSCap) or 240
		-- the UI treats 360 and above as "uncapped", and so does the executor hook
		setfpscap(cap >= 360 and 0 or cap)
	end)
end

local loaded_shapes = {}
local failed_shapes = {}
local function get_shape(name)
	local cached = loaded_shapes[name]
	if cached then
		return cached
	end
	-- Without this the physics loop would retry a broken download every single
	-- frame, which is far worse than the shape simply not working.
	if failed_shapes[name] then
		return nil
	end
	local success, result = false, nil

	if local_shapes and local_shapes[name] then
		local read_success, code = pcall(readfile, local_shapes[name])
		if read_success and code then
			local func, err = loadstring(code)
			if func then
				success, result = pcall(func)
			else
				result = "Syntax error in local shape: " .. tostring(err)
			end
		else
			result = "Failed to read local shape file"
		end
	end

	if not success then
		local url = BASE_URL .. "shapes/" .. HttpService:UrlEncode(name) .. ".lua"
		local code = safe_http_get(url)
		if code then
			local func, err = loadstring(code)
			if func then
				success, result = pcall(func)
			else
				result = "Syntax error in shape source: " .. tostring(err)
			end
		else
			result = "HTTP Request Failed"
		end
	end

	if success and type(result) == "table" then
		loaded_shapes[name] = result
		return result
	end

	failed_shapes[name] = true
	warn("Failed to load shape: " .. tostring(name) .. " Error: " .. tostring(result))
	return nil
end

local x6 = {
	b = nil,
	c = {},
	a = setmetatable({}, {__mode = "k"}),
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
	run_connections = {},
	pre = {},
	pre_buffer = table.create(200),
	sculptor_selected = setmetatable({}, {__mode = "k"}),
	sculptor_dragging = false,
	sculptor_drag_start = nil,
	sculptor_box_start = nil,
	sculptor_box = nil,
	sculptor_highlights = setmetatable({}, {__mode = "k"}),
	sculptor_preset_ui = nil,
	transition_time = 0,
	transition_dur = 2,
	f1_connections = {},
}

get_shape(x1.k6)
boot_status("formations", 0.5)

-- Warm the cache in the background: favourites first, then everything else at a
-- gentle pace. The old build fired one request per shape every 0.05s, which meant
-- roughly sixty downloads racing each other while the UI was still starting up.
coroutine.wrap(function()
	local queue = {}
	for mn in pairs(x2) do
		if mn ~= x1.k6 then
			queue[#queue + 1] = mn
		end
	end
	table.sort(queue, function(a, b)
		local fa, fb = favorites[a] and 1 or 0, favorites[b] and 1 or 0
		if fa ~= fb then
			return fa > fb
		end
		return a < b
	end)
	for i, mn in ipairs(queue) do
		pcall(get_shape, mn)
		if task and task.wait then
			task.wait(favorites[mn] and 0.05 or 0.4)
		end
		if i % 8 == 0 and task and task.wait then
			task.wait(1)
		end
	end
end)()

local context = {
	v1 = v1,
	v2 = v2,
	v3 = v3,
	v4 = v4,
	v5 = v5,
	v6 = v6,
	v7 = v7,
	v8 = v8,
	v9 = v9,
	x1 = x1,
	x2 = x2,
	x6 = x6,
	x9 = x9,
	favorites = favorites,
	save_favs = save_favs,
	save_settings = save_settings,
	get_shape = get_shape,
	local_shapes = local_shapes,
	loaded_shapes = loaded_shapes,
	load_module = load_module,
	is_mobile = is_mobile,
	SUB_DIR = SUB_DIR,
	reset_config = reset_config,
}

local function destroy()
	if spin_conn then
		pcall(function() spin_conn:Disconnect() end)
		spin_conn = nil
	end
	if loading_sg then
		pcall(function() loading_sg:Destroy() end)
		loading_sg = nil
	end
	for i = #x6.c, 1, -1 do
		pcall(function() x6.c[i]:Disconnect() end)
		x6.c[i] = nil
	end
	for i = #x6.run_connections, 1, -1 do
		pcall(function() x6.run_connections[i]:Disconnect() end)
		x6.run_connections[i] = nil
	end
	for p, d in pairs(x6.a) do
		if d then
			pcall(function()
				if p and p.Parent then
					p.CanCollide = d.original_can_collide
					p.Anchored = d.original_anchored
					p.CustomPhysicalProperties = d.original_properties
				end
				if d.at then d.at:Destroy() end
				if d.lv then d.lv:Destroy() end
				if d.av then d.av:Destroy() end
			end)
		end
	end
	x6.a = setmetatable({}, {__mode = "k"})
	if x6.b then
		pcall(function() x6.b:Destroy() end)
		x6.b = nil
	end
	if x6.sg then
		pcall(function() x6.sg:Destroy() end)
		x6.sg = nil
	end
	getgenv()._GRAVITY_SESSION_ID = nil
	getgenv()._GRAVITY_DESTROY = nil
end

getgenv()._GRAVITY_DESTROY = destroy

local success, err = pcall(function()
	-- The interface is responsive and handles touch itself, so both builds share
	-- it; only the physics system still has a device-specific variant.
	boot_status("interface", 0.62)
	local UI_builder = load_module("UI.lua")
	if not UI_builder then error("Failed to load UI") end
	local x5 = UI_builder(context)
	context.x5 = x5

	boot_status("physics", 0.85)
	local system_builder = load_module(SUB_DIR .. "System.lua")
	if not system_builder then error("Failed to load System") end
	local sys = system_builder(context)
	local x4 = sys.x4
	local x8 = sys.x8
	context.x4 = x4

	x4.f3()
	x8.i()
	x5.st()
	boot_status("ready", 1)
end)

local function dismiss_boot(fade)
	if not fade then
		if spin_conn then
			spin_conn:Disconnect()
			spin_conn = nil
		end
		if loading_sg then
			loading_sg:Destroy()
			loading_sg = nil
		end
		return
	end
	local info = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	pcall(function()
		v6:Create(veil, info, { BackgroundTransparency = 1 }):Play()
		for _, obj in ipairs(stage:GetDescendants()) do
			if obj:IsA("TextLabel") then
				v6:Create(obj, info, { TextTransparency = 1 }):Play()
			elseif obj:IsA("UIStroke") then
				v6:Create(obj, info, { Transparency = 1 }):Play()
			elseif obj:IsA("Frame") then
				v6:Create(obj, info, { BackgroundTransparency = 1 }):Play()
			end
		end
	end)
	task.delay(0.36, function()
		dismiss_boot(false)
	end)
end

dismiss_boot(success)

if not success then
	destroy()
	warn("Project Gravity Initialization Failed: " .. tostring(err))
else
	getgenv()._GRAVITY_SESSION_ID = SESSION_ID
end