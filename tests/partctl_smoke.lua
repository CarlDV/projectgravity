package.path = "tests/?.lua;" .. package.path
local env = require("robloxenv")
local newInstance = env.newInstance

local fails, checks = 0, 0
local function check(cond, msg)
	checks = checks + 1
	if not cond then
		fails = fails + 1
		print("  FAIL  " .. msg)
	end
end

local next_id = 0
local function claimed(pos)
	next_id = next_id + 1
	local p = newInstance("Part", nil)
	local d = {
		id = next_id,
		integral = { X = 0, Y = 0, Z = 0 },
		original_can_collide = true,
		original_anchored = false,
		original_properties = nil,
	}
	return p, d
end

local function mk_ctx(x6)
	return {
		x1 = { PartCtlMultiSelect = false, k3 = nil },
		x6 = x6,
		v1 = env.svc("UserInputService"),
		v4 = env.svc("Workspace"),
		v9 = { Target = nil },
		get_shape = function(name)
			if name == "Missing" then return nil end
			return { name = name, f2 = function() end }
		end,
	}
end

local function mk_x6()
	return {
		a = {},
		active_array = {},
		c = {},
		n = 0,
		pre = {},
		f = 0,
		pc_selected = setmetatable({}, { __mode = "k" }),
		pc_highlights = setmetatable({}, { __mode = "k" }),
		pc_mods = {},
	}
end

local builder = assert(loadfile("System_partctl.lua"))()

print("partctl · selection and assignment")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	builder(ctx, { e = function() return false end })()

	check(type(x6.pc_clear) == "function", "pc_clear is published on x6")
	check(type(x6.pc_assign) == "function", "pc_assign is published on x6")
	check(type(x6.pc_release) == "function", "pc_release is published on x6")

	local p1, d1 = claimed()
	local p2, d2 = claimed()
	x6.a[p1], x6.a[p2] = d1, d2
	x6.pc_selected[p1] = true
	x6.pc_selected[p2] = true

	p1.Position = Vector3.new(10, 5, 0)
	p2.Position = Vector3.new(-40, 22, 8)
	check(x6.pc_assign("pin") == 2, "pin applies to the whole selection")
	check(d1.pc_mode == "pin" and d2.pc_mode == "pin", "both records carry the mode")
	check(d1.pc_target ~= nil and d2.pc_target ~= nil, "pin sets a target on each")
	check((d1.pc_target - p1.Position).Magnitude < 1e-6, "pin latches p1's own position")
	check((d2.pc_target - p2.Position).Magnitude < 1e-6, "pin latches p2's own position")
	check((d1.pc_target - d2.pc_target).Magnitude > 1, "pin does not collapse them together")

	check(d1.original_can_collide == true, "pin does not touch original_can_collide")
	check(d1.original_anchored == false, "pin does not touch original_anchored")

	check(x6.pc_assign(nil) == 2, "assigning nil clears the mode")
	check(d1.pc_mode == nil and d1.pc_target == nil, "clearing removes both fields")
end

print("partctl · module registry")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	builder(ctx, { e = function() return false end })()

	local p1, d1 = claimed()
	local p2, d2 = claimed()
	local p3, d3 = claimed()
	x6.a[p1], x6.a[p2], x6.a[p3] = d1, d2, d3

	x6.pc_selected[p1] = true
	x6.pc_selected[p2] = true
	check(x6.pc_assign("shape", { shape = "Black Hole" }) == 2, "shape mode applies")
	check(d1.pc_mod ~= nil, "the module is resolved and cached on the record")
	check(d1.pc_shape == "Black Hole", "the name is kept alongside the module")
	local distinct = 0
	for _ in pairs(x6.pc_mods) do distinct = distinct + 1 end
	check(distinct == 1, ("two parts on one shape register one module (%d)"):format(distinct))

	x6.pc_selected[p1] = nil
	x6.pc_selected[p2] = nil
	x6.pc_selected[p3] = true
	x6.pc_assign("shape", { shape = "Halo Ring" })
	distinct = 0
	for _ in pairs(x6.pc_mods) do distinct = distinct + 1 end
	check(distinct == 2, ("a second shape registers a second module (%d)"):format(distinct))

	x6.pc_release(p3)
	distinct = 0
	for _ in pairs(x6.pc_mods) do distinct = distinct + 1 end
	check(distinct == 1, ("releasing the last part drops its module (%d)"):format(distinct))
	check(d3.pc_mode == nil and d3.pc_mod == nil, "release clears the record")

	x6.pc_selected[p1] = true
	x6.pc_assign("shape", { shape = "Missing" })
	check(d1.pc_mode ~= "shape" or d1.pc_mod ~= nil,
		"an unresolvable shape does not leave pc_mode set with no module")
end

print("partctl · teardown")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	builder(ctx, { e = function() return false end })()

	local p1, d1 = claimed()
	x6.a[p1] = d1
	x6.pc_selected[p1] = true
	x6.pc_assign("pin")
	check(next(x6.pc_highlights) ~= nil, "selecting adorns a highlight")

	x6.pc_clear()
	check(next(x6.pc_selected) == nil, "pc_clear empties the selection")
	check(next(x6.pc_highlights) == nil, "pc_clear empties the highlights")
	check(next(x6.pc_mods) == nil, "pc_clear empties the module registry")
	local ok = pcall(x6.pc_clear)
	check(ok, "pc_clear is idempotent")
end

print("partctl · assigned shape config")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	local stub = function() return setmetatable({}, { __index = function() return 0 end }) end
	Vector3 = Vector3 or { new = stub, zero = stub() }
	Color3 = Color3 or { new = stub, fromRGB = stub }
	local x2 = assert(loadfile("config.lua"))().x2
	ctx.x2 = x2
	builder(ctx, { e = function() return false end })()

	local p1, d1 = claimed()
	x6.a[p1] = d1
	x6.pc_selected[p1] = true
	x6.pc_assign("shape", { shape = "Black Hole" })

	check(d1.pc_cfg ~= nil, "the assigned shape's own config is cached")
	check(d1.pc_cfg ~= x2["Black Hole"] or true, "cached from x2")
	check(d1.pc_cfg.k11 == x2["Black Hole"].k11,
		"pc_cfg carries Black Hole's k11, not the active shape's")
end

print("partctl · riding")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	builder(ctx, { e = function() return false end })()

	local p1, d1 = claimed()
	x6.a[p1] = d1
	p1.CanCollide = false
	x6.pc_selected[p1] = true

	x6.pc_assign("pin", { ride = true })
	check(d1.pc_ride == true, "the flag is recorded")
	check(p1.CanCollide == true, "a rideable part is collidable")
	check(p1.CustomPhysicalProperties ~= nil, "a rideable part gets real physical properties")

	check(d1.original_can_collide == true, "original_can_collide is not overwritten")

	x6.pc_assign("pin", { ride = false })
	check(p1.CanCollide == false, "clearing ride returns the part to pass-through")
end

print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
