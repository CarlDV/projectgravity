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

local M = assert(loadfile("shapes/Raigo.lua"))()

local function mk_part(pos)
	local p = newInstance("Part", nil)
	p.Position = pos or Vector3.new(0, 0, 0)
	p.Material = Enum.Material.SmoothPlastic
	p.Color = Color3.fromRGB(100, 100, 100)
	return p
end

local function mk_ctx()
	return {
		x1 = { k10 = 20, k3 = Color3.fromRGB(0, 255, 255), IsLaunching = false },
		x6 = { pre = {}, f = 0, n = 50 },
		x9 = { c1 = 0.15 },
		c = {
			k11 = 8,
			k12 = 250,
			k13 = 80,
			k14 = 0.7,
			k15 = 12,
			k16 = 8,
			k17 = 12,
			k18 = true,
			k19 = true,
			k20 = true,
		},
	}
end

print("Raigo · hover phase")
do
	local ctx = mk_ctx()
	local p = mk_part(Vector3.new(0, 0, 0))
	local cen = Vector3.new(0, 50, 0)
	local d = { id = 1 }

	local delta, pos = M.f2(p, cen, d, 0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(delta ~= nil and pos ~= nil, "f2 returns delta and target position")
	check(pos.Y > cen.Y, "orb hovers above the center/head")

	local st = ctx.x6.pre["Raigo"]
	check(st ~= nil, "state machine is stored in x6.pre")
	check(st.phase == "HOVER", "initial state is HOVER")
end

print("Raigo · launch and flight")
do
	local ctx = mk_ctx()
	local p = mk_part(Vector3.new(0, 50, 0))
	local cen = Vector3.new(0, 50, 0)
	local d = { id = 1 }

	M.f2(p, cen, d, 0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	local st = ctx.x6.pre["Raigo"]

	st.dest_pos = Vector3.new(200, 50, 0)
	st.start_pos = st.orb_pos
	st.phase = "LAUNCH"
	st.t_launch = 1.0

	local delta, pos = M.f2(p, cen, d, 1.2, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(st.phase == "LAUNCH" or st.phase == "EXPLODE", "phase progresses during flight")
	check(st.orb_pos.X > 10, "orb moves toward destination")

	M.f2(p, cen, d, 3.0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(st.phase == "EXPLODE", "reaching destination triggers EXPLODE")
end

print("Raigo · explosion and return")
do
	local ctx = mk_ctx()
	local p = mk_part(Vector3.new(200, 50, 0))
	local cen = Vector3.new(0, 50, 0)
	local d = { id = 1 }

	M.f2(p, cen, d, 0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	local st = ctx.x6.pre["Raigo"]
	st.phase = "EXPLODE"
	st.t_blast = 2.0
	st.blast_origin = Vector3.new(200, 50, 0)

	local delta, pos = M.f2(p, cen, d, 2.3, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(st.phase == "EXPLODE", "in explosion phase during blast duration")
	check((pos - st.blast_origin).Magnitude > 0, "parts expand outward")

	M.f2(p, cen, d, 3.0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(st.phase == "RETURN", "blast duration elapsing triggers RETURN")

	M.f2(p, cen, d, 6.0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(st.phase == "HOVER", "returning completes and resets to HOVER")
end

print("Raigo · cleanup")
do
	local ctx = mk_ctx()
	local p = mk_part(Vector3.new(0, 0, 0))
	M.f2(p, Vector3.new(0, 0, 0), { id = 1 }, 0, ctx.c, ctx.x1, ctx.x6, ctx.x9)
	check(ctx.x6.pre["Raigo"] ~= nil, "state exists before cleanup")
	M.cleanup(ctx.x6, ctx.x1)
	check(ctx.x6.pre["Raigo"] == nil, "cleanup drops state")
end

print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
