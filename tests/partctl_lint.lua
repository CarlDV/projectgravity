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

for _, path in ipairs({ "System.lua", "mobilever/System.lua" }) do
	local src = slurp(path)

	check(src:find("d%.pc_mode%s*==%s*nil%s+and%s+i%s*%%%s*et%s*~=%s*update_bucket") ~= nil,
		path .. ": the bucket skip exempts controlled parts")

	local cull = src:find("distance_sq%s*>%s*k1_sq[^\n]*pc_mode")
	local dead = src:find("distance_sq%s*>%s*c7_sq[^\n]*pc_mode")
	check(cull ~= nil, path .. ": the radius cull exempts controlled parts")
	check(dead ~= nil, path .. ": the deadzone exempts controlled parts")

	check(src:find('d%.pc_mode%s*==%s*"pin"') or src:find('pc_mode%s*==%s*"manual"'),
		path .. ": the dispatch branches on pin/manual")
	check(src:find("shape_f2%(p,%s*active_c,%s*d,%s*ft") ~= nil,
		path .. ": the normal path still calls shape_f2 unchanged")

	check(src:find("x6%.pc_mods") ~= nil, path .. ": the loop walks the assigned-module registry")
	check(src:find("mod%.px") ~= nil or src:find("m%.px") ~= nil,
		path .. ": it calls px on each assigned module")

	check(src:find("p%.CanCollide%s*=%s*%(disabled%s+or%s+x1%.PreserveCollisions[^\n]*pc_ride") ~= nil,
		path .. ": the disable path honours pc_ride")
	check(src:find("pc_ride") ~= nil, path .. ": pc_ride is read in the runtime")
end

for _, path in ipairs({ "UI.lua", "mobilever/UI.lua" }) do
	local src = slurp(path)
	check(src:find("pc_assign") ~= nil, path .. ": the panel calls pc_assign")
	check(src:find("pc_clear") ~= nil, path .. ": the panel can clear the selection")
	check(src:find("Part Control") ~= nil, path .. ": the panel is labelled")
	check(src:find("pc_selected") ~= nil, path .. ": the panel reads pc_selected")
end

print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
