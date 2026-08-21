local fails, checks = 0, 0
local function check(cond, msg)
	checks = checks + 1
	if not cond then
		fails = fails + 1
		print("  FAIL  " .. msg)
	end
end
local function slurp(path)
	local f = assert(io.open(path), "cannot open " .. path)
	local s = f:read("a")
	f:close()
	return s
end

do
	local cfg = assert(loadfile("config.lua"))
	local stub = function() return setmetatable({}, { __index = function() return 0 end }) end
	Vector3 = { new = stub, zero = stub() }
	Color3 = { new = stub, fromRGB = stub }
	local x1 = cfg().x1
	check(x1.MaxFidelity ~= nil, "config.lua x1 declares MaxFidelity")
	check(type(x1.MaxFidelity) == "boolean",
		("MaxFidelity is a boolean, not a %s"):format(type(x1.MaxFidelity)))
	check(x1.MaxFidelity == false, "MaxFidelity defaults to off")
end

for _, path in ipairs({ "System.lua", "mobilever/System.lua" }) do
	local src = slurp(path)

	check(src:find("local max_fid%s*=%s*x1%.MaxFidelity") ~= nil,
		path .. ": declares `local max_fid = x1.MaxFidelity`")

	check(src:find("if%s+force_smooth%s+or%s+max_fid%s+then") ~= nil,
		path .. ": the dt/et pin reads max_fid alongside force_smooth")

	check(src:find("local%s+always_process%s*=[^\n]*max_fid") ~= nil,
		path .. ": always_process includes max_fid")

	check(src:find("local%s+always_process%s*=[^\n]*is_drop_shape") ~= nil,
		path .. ": always_process still honours is_drop_shape")
	check(src:find("local%s+always_process%s*=[^\n]*is_self_bounded_shape") ~= nil,
		path .. ": always_process still honours is_self_bounded_shape")

	local n = 0
	for _ in src:gmatch("max_fid") do n = n + 1 end
	check(n == 4, ("%s: max_fid appears 4 times (1 decl + 3 uses), found %d"):format(path, n))

	check(src:find("k1_sq%s*=%s*k1%s*%*%s*k1") ~= nil, path .. ": k1 still drives the cull radius")
	check(src:find("c7_sq%s*=%s*c7%s*%*%s*c7") ~= nil, path .. ": c7 still drives the deadzone")
end

for _, path in ipairs({ "UI.lua", "mobilever/UI.lua" }) do
	local src = slurp(path)
	check(src:find("x1%.MaxFidelity%s*=%s*v") ~= nil, path .. ": a toggle writes x1.MaxFidelity")
	check(src:find("Max Fidelity") ~= nil, path .. ": the toggle is labelled")
	local fs = src:find("Force Smooth %(Lags%)") or src:find("Force Smooth")
	local mf = src:find("Max Fidelity")
	check(fs ~= nil and mf ~= nil and math.abs(mf - fs) < 900,
		path .. ": Max Fidelity sits next to Force Smooth, not in the Perf group")
end

print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
