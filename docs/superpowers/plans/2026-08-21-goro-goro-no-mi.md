# Goro Goro no Mi Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A new `shapes/` module that arranges claimed unanchored parts into a jagged, forking
lightning bolt running from the anchor to the cursor's hit point, re-rolling its shape several
times a second.

**Architecture:** One self-contained Lua module implementing the standard shape contract
(`M.f2`, `M.Controls`, `M.cleanup`). All path geometry is a pure function of a hashed integer
seed, so every part independently derives the identical bolt with no shared mutable state. The
seed and the aim point are stamped once per bucket generation into `x6.pre`, which is what keeps
the bolt from tearing across the frames the parts are spread over.

**Tech Stack:** Lua 5.1 / Luau. Tests run under LuaJIT against the stub harness in `tests/`.

**Spec:** `docs/superpowers/specs/2026-08-21-lightning-fidelity-partctl-design.md` — sub-project 1.
Read the "Engine constraints" section before starting; constraints 1, 2, 3, 5, 6, 7 and 8 all
bear on this file.

## Global Constraints

- **No `math.random` anywhere in the path math.** `f2` runs once per part; a shared generator
  would give every part a different bolt. All randomness is the pure hash `h(seed, node, chan)`.
- **The seed may only change on a bucket-generation boundary.** `gen = floor(x6.f / et)` where
  `et = x1.k7`. A mid-cycle reseed splits the parts across two different bolts.
- **Return two values.** `return delta, pure_target_pos`. Omitting the second makes the ~15 Hz
  target step read as stutter.
- **`Vector3`, `math.clamp` and `table.create` are Luau builtins.** The test harness supplies the
  last two for LuaJIT; do not avoid them.
- **Integer intermediates must stay under 2^53.** LuaJIT and Luau both lose precision past it.
- **New `x2` keys must exist in `config.lua` at their exact final type.** Toggles are booleans.
  `load_settings` only restores a saved value when a default of the matching type already exists.
- **`Min`/`Max` on a control are display units; the `x2` default is stored units.** stored × `Div`
  = displayed.
- **Run from the repo root.** Every test path is relative to it.

---

## File Structure

| File | Responsibility |
|---|---|
| `shapes/Goro Goro no Mi.lua` | **Create.** The whole shape: hash, path, branches, aim, controls. |
| `config.lua` | **Modify.** One `x2` block, 11 keys. |
| `tests/bolt_smoke.lua` | **Create.** Per-shape harness and all geometry assertions. |

`tests/shapes_smoke.lua` is deliberately *not* touched: it already declares 198 top-level locals
against LuaJIT's ceiling of 200 per chunk, so a new section there with more than two locals fails
to compile. `tests/cube_smoke.lua` is the precedent for a dedicated per-shape harness.

`tests/controls_lint.lua` and `tests/slider_range_lint.lua` both enumerate via
`io.popen("ls shapes")`, so they pick the new file up with no edit. They must be run.

---

### Task 1: Hash, basis, and the main-channel path

**Files:**
- Create: `shapes/Goro Goro no Mi.lua`
- Test: `tests/bolt_smoke.lua`

**Interfaces:**
- Consumes: nothing.
- Produces: `M.f2(p, cen, d, t, c, x1, x9)` honouring the shape contract and reading `c.k11`
  (Bolt Length, number), `c.k12` (Node Count, number), `c.k13` (Jaggedness, number). Internal
  helpers `h(seed, node, chan) -> number in [0,1)`, `basis(dir) -> u, v`, and
  `on_path(origin, dir, len, n, amp, seed, chan, taper, f) -> pos, u, v`. Tasks 2 and 3 call all
  three by these exact names and signatures.

- [ ] **Step 1: Write the failing test**

Create `tests/bolt_smoke.lua`:

```lua
-- Goro Goro no Mi: the hash, the jittered path, the branches, and the
-- generation-quantised reseed.
--
--   luajit tests/bolt_smoke.lua      (from the repo root)

package.path = "tests/?.lua;" .. package.path
local rm = require("robloxmath")
Vector3, CFrame = rm.Vector3, rm.CFrame
Color3 = { new = function() return {} end }
Color3.fromRGB = Color3.new
if not math.clamp then
	math.clamp = function(x, lo, hi) return x < lo and lo or (x > hi and hi or x) end
end

local fails, checks = 0, 0
local function check(cond, msg)
	checks = checks + 1
	if not cond then
		fails = fails + 1
		print("  FAIL  " .. msg)
	end
end
local function finite(v)
	return v and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) ~= math.huge
		and math.abs(v.Y) ~= math.huge
		and math.abs(v.Z) ~= math.huge
end
```

(continues in the next step — this block is the harness preamble only)

Append the module loader and the Task 1 assertions to the same file:

```lua
local SRC = "shapes/Goro Goro no Mi.lua"
local S = assert(load(assert(io.open(SRC)):read("a"), "bolt"))()
local function part(pos) return { Position = pos or Vector3.new(0, 0, 0) } end
local x1 = { k10 = 20, k7 = 4, k3 = Color3.fromRGB(0, 255, 255) }
local x9 = { c1 = 0.15 }
local function mk_x6(n) return { pre = {}, f = 0, n = n or 400 } end
local CFG = { k11 = 200, k12 = 18, k13 = 14, k14 = 12, k15 = 0,
              k16 = 0.3, k17 = 0.4, k18 = 0, k19 = false, k20 = false, k21 = false }
local function cfg(over)
	local o = {}
	for k, v in pairs(CFG) do o[k] = v end
	for k, v in pairs(over or {}) do o[k] = v end
	return o
end

-- Perpendicular distance from the ideal straight cen -> aim segment, and how far
-- along that axis the point sits. Every geometry bound below is one of these two.
local function split(cen, dir, p)
	local rel = p - cen
	local along = rel:Dot(dir)
	return (rel - dir * along).Magnitude, along
end

print("Goro Goro no Mi · hash")
do
	-- The squaring term in the hash is load-bearing. The obvious single LCG round is
	-- linear, so it preserves the structure of its linear input: measured over 24000
	-- samples it put channels 1 and 2 within 0.02 of each other 99.3% of the time
	-- against 4% for a uniform pair, which would collapse the jitter onto one
	-- diagonal and produce a wrong-looking bolt with no error anywhere. These two
	-- rates are the regression guard for that.
	local adj, chan, n = 0, 0, 0
	for seed = 1, 1500 do
		for node = 0, 30 do
			n = n + 1
			if math.abs(S._h(seed, node, 1) - S._h(seed, node + 1, 1)) < 0.02 then adj = adj + 1 end
			if math.abs(S._h(seed, node, 1) - S._h(seed, node, 2)) < 0.02 then chan = chan + 1 end
		end
	end
	check(math.abs(adj / n - 0.04) < 0.015, ("adjacent nodes decorrelated: %.4f vs 0.04"):format(adj / n))
	check(math.abs(chan / n - 0.04) < 0.015, ("channels decorrelated: %.4f vs 0.04"):format(chan / n))
	local lo, hi = 1, 0
	for seed = 1, 200 do
		for node = 0, 63 do
			local v = S._h(seed, node, 1)
			if v < lo then lo = v end
			if v > hi then hi = v end
			check(v == v and v >= 0 and v < 1, "hash stays in [0,1)")
		end
	end
	check(lo < 0.02 and hi > 0.98, ("hash spans its range: %.3f..%.3f"):format(lo, hi))
end

print("Goro Goro no Mi · main channel")
do
	local x6 = mk_x6()
	local cen = Vector3.new(0, 10, 0)
	local c = cfg()                      -- k15 = 0: no branches yet
	-- Aim At Cursor is off (k19 = false) and the harness has no camera, so the
	-- module falls back to its documented no-camera direction. This task therefore
	-- needs no game stub at all; task 3 adds the cursor path and its own stubs.
	local dir = Vector3.new(0, 0, 1)
	local bad, worst, far, seen = 0, 0, 0, {}
	for id = 1, 400 do
		local _, tp = S.f2(part(), cen, { id = id }, 0.5, c, x1, x6, x9)
		if not finite(tp) then
			bad = bad + 1
		else
			seen[("%.2f,%.2f,%.2f"):format(tp.X, tp.Y, tp.Z)] = true
			local perp, along = split(cen, dir, tp)
			if perp > worst then worst = perp end
			if along > far then far = along end
		end
	end
	local distinct = 0
	for _ in pairs(seen) do distinct = distinct + 1 end

	check(bad == 0, ("every id finite (%d bad)"):format(bad))
	check(distinct > 350, ("Weyl spread: %d/400 distinct slots"):format(distinct))
	-- sqrt(2) is not padding: jitter is applied on u and v independently, so the
	-- combined perpendicular magnitude reaches amp * sqrt(2). A bound of k13 + 1
	-- looks right and fails.
	local bound = (c.k13 + c.k18) * 1.4143 + 1
	check(worst <= bound, ("main channel within %.1f of the axis (worst %.1f)"):format(bound, worst))
	check(far <= c.k11 + 1, ("never overshoots Bolt Length %d (max along %.1f)"):format(c.k11, far))
	check(worst > 1, ("the path is actually jittered, not straight (worst %.1f)"):format(worst))
end
```

Finally the file tail. Tasks 2 and 3 insert their sections **above** these two lines:

```lua
print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/bolt_smoke.lua
```

Expected: a hard error, not a FAIL line — `cannot open shapes/Goro Goro no Mi.lua`, because the
`assert(io.open(...))` on the module path is what runs first.

- [ ] **Step 3: Write the minimal implementation**

Create `shapes/Goro Goro no Mi.lua`:

```lua
-- Enel's Goro Goro no Mi. A jagged bolt from the anchor to the cursor, built out
-- of claimed parts -- there is no Beam, no ParticleEmitter and no Trail anywhere
-- in here, only positions.
--
-- Every part calls f2 independently, so all of them have to derive the SAME bolt
-- or the formation tears. That is why nothing here touches math.random: a shared
-- generator would advance once per part and hand each one a different path. All
-- variation comes from h(), a pure hash.
local M = {}

local PHI1 = 0.6180339887498949
local PHI2 = 0.7548776662466927
local HM = 16777216

-- The x*x term is load-bearing. A single linear LCG round preserves the structure
-- of its linear input: measured, it put channels 1 and 2 within 0.02 of each other
-- 99.3% of the time against 4% for a uniform pair, which collapses the jitter onto
-- one diagonal. Squaring drops that to 3.97%. Do not simplify it back.
-- Largest intermediates are 1048575 * 73856093 = 7.7e13 and x*x + x*22695477 =
-- 6.7e14, both far under 2^53, which LuaJIT and Luau alike lose precision past.
local function h(seed, node, chan)
	local x = ((seed % 1048576) * 73856093 + node * 19349663 + chan * 83492791) % HM
	x = (x * x + x * 22695477 + 12345) % HM
	return x / HM
end
M._h = h                                  -- read by tests/bolt_smoke.lua

-- Perpendicular basis for dir. u degenerates when dir is vertical; the fallback is
-- the one at shapes/Twin Core Beam.lua:125-130. Vector3.zAxis does not exist in the
-- test harness's Vector3, so spell axis constants out.
local function basis(dir)
	local u = Vector3.new(-dir.Z, 0, dir.X)
	if u.Magnitude < 1e-4 then
		u = Vector3.new(1, 0, 0)
	else
		u = u.Unit
	end
	return u, dir:Cross(u).Unit
end
```

Continue in the same file — the two tapers and the path sampler:

```lua
-- Pinned at both ends: node 0 is cen and node n is the aim point, both jitter-free,
-- so the bolt visibly starts at the caster and lands on the cursor.
local function sin_taper(j, n)
	return math.sin(math.pi * j / n)
end

-- Pinned at the root only. A branch should fray at its free end.
local function tip_taper(j, n)
	return 1 - j / n
end

-- Position at fractional arc position f along an n-node jittered polyline.
-- Interpolating inside the segment rather than snapping to the nearest node is what
-- keeps part density continuous instead of clumping on the nodes.
local function on_path(origin, dir, len, n, amp, seed, chan, taper, f)
	local u, v = basis(dir)
	local function node(j)
		local w = taper(j, n)
		return origin + dir * ((j / n) * len)
			+ u * (amp * w * (2 * h(seed, j, chan) - 1))
			+ v * (amp * w * (2 * h(seed, j, chan + 1) - 1))
	end
	local q = f * n
	local j = math.floor(q)
	if j >= n then j = n - 1 end
	if j < 0 then j = 0 end
	return node(j) + (node(j + 1) - node(j)) * (q - j), u, v
end
```

And the first `f2`. Aim is the fixed fallback for now; task 3 replaces it:

```lua
function M.f2(p, cen, d, t, c, x1, x6, x9)
	local nodes = math.clamp(math.floor(c.k12 or 18), 4, 64)
	local amp = c.k13 or 14

	local aim = cen + Vector3.new(0, 0, 1) * (c.k11 or 200)
	local rel = aim - cen
	local len = rel.Magnitude
	if len < 1e-3 then
		return Vector3.zero, cen
	end
	local dir = rel.Unit

	local f1 = ((d.id or 1) * PHI1) % 1
	local pos = on_path(cen, dir, len, nodes, amp, 1, 1, sin_taper, f1)

	return (pos - p.Position) * (x1.k10 * x9.c1), pos
end

M.Controls = {
	{ Type = "Slider", Name = "Bolt Length", Min = 20, Max = 1000, Key = "k11", Default = 200 },
	{ Type = "Slider", Name = "Node Count", Min = 4, Max = 64, Key = "k12", Default = 18, IntOnly = true },
	{ Type = "Slider", Name = "Jaggedness", Min = 0, Max = 100, Key = "k13", Default = 14 },
}

return M
```

Add the matching `x2` block to `config.lua`, beside the other One Piece shapes, so
`controls_lint` passes. Tasks 2, 3 and 5 extend it:

```lua
["Goro Goro no Mi"] = { k11 = 200, k12 = 18, k13 = 14 },
```

The test's `CFG` table deliberately carries all eleven keys from the start, including ones no
task has added to `Controls` yet. It is a plain table, not validated against `Controls`, so this
is harmless and saves editing it in every task.

- [ ] **Step 4: Run the test to verify it passes**

```bash
luajit tests/bolt_smoke.lua
```

Expected: `0 failures`. Roughly 12800 checks — the hash section alone runs 12800 range checks.

- [ ] **Step 5: Run the two lints that auto-discover the new file**

```bash
luajit tests/controls_lint.lua && luajit tests/slider_range_lint.lua
```

Expected: both report `0 problems`, with the shape count up by one (51 controls-lint shapes, 52
slider-range shapes). A failure here means the `x2` block is missing a key or has a type mismatch.

- [ ] **Step 6: Commit**

```bash
git add "shapes/Goro Goro no Mi.lua" config.lua tests/bolt_smoke.lua
git commit -m "Add Goro Goro no Mi: hashed jittered bolt path

The hash keeps its squaring term deliberately: a single linear LCG round
correlated channels 1 and 2 at 99.3%, which collapses the perpendicular
jitter onto one diagonal and produces a wrong-looking bolt with no error
anywhere. tests/bolt_smoke.lua pins both decorrelation rates."
```

---

### Task 2: Branches and core thickness

**Files:**
- Modify: `shapes/Goro Goro no Mi.lua`
- Modify: `config.lua`
- Test: `tests/bolt_smoke.lua`

**Interfaces:**
- Consumes: `h`, `basis`, `on_path`, `sin_taper`, `tip_taper`, `PHI1`, `PHI2` from Task 1.
- Produces: `f2` additionally reads `c.k15` (Branch Count, number), `c.k16` (Branch Share,
  stored fraction 0..0.8), `c.k17` (Branch Length, stored fraction 0.1..1.0), `c.k18` (Core
  Thickness, number). No new exported names.

- [ ] **Step 1: Write the failing test**

Insert into `tests/bolt_smoke.lua` above the `print(("\n%d checks..."))` tail:

```lua
print("Goro Goro no Mi · branches and thickness")
do
	local x6 = mk_x6()
	local cen = Vector3.new(0, 10, 0)
	local c = cfg({ k15 = 3, k16 = 0.3, k17 = 0.4, k18 = 2 })
	local dir = Vector3.new(0, 0, 1)
	local len = c.k11
	local main_worst, branch_worst, nmain, nbranch = 0, 0, 0, 0
	local bad = 0
	for id = 1, 2000 do
		local _, tp = S.f2(part(), cen, { id = id }, 0.5, c, x1, x6, x9)
		if not finite(tp) then
			bad = bad + 1
		else
			local perp = split(cen, dir, tp)
			-- Same selector the shape uses, so the split is measured rather than
			-- inferred from a radius guess.
			if ((id * 0.7548776662466927) % 1) < c.k16 then
				nbranch = nbranch + 1
				if perp > branch_worst then branch_worst = perp end
			else
				nmain = nmain + 1
				if perp > main_worst then main_worst = perp end
			end
		end
	end
	check(bad == 0, ("every id finite with branches on (%d bad)"):format(bad))
	check(nmain > 0 and nbranch > 0, "both channels populated")
	check(math.abs(nbranch / 2000 - c.k16) < 0.05,
		("branch share tracks the slider: %.3f vs %.2f"):format(nbranch / 2000, c.k16))
```

Continue the same `do` block with the two separate bounds and the degenerate cases:

```lua
	-- Branches MUST be bounded separately. They fork away from the axis by design, so
	-- they fail the main-channel bound: the prototype measured 32.7 against a main
	-- channel of 18.4 on identical settings.
	local main_bound = (c.k13 + c.k18) * 1.4143 + 1
	local branch_bound = len * c.k17 + (c.k13 + c.k18) * 1.5
	check(main_worst <= main_bound,
		("main channel still within %.1f (worst %.1f)"):format(main_bound, main_worst))
	check(branch_worst <= branch_bound,
		("branches within %.1f (worst %.1f)"):format(branch_bound, branch_worst))
	check(branch_worst > main_worst, "branches actually leave the main channel")

	-- Zero branches must degrade to the main channel, not divide by zero.
	local c0 = cfg({ k15 = 0, k16 = 0.3, k18 = 2 })
	local okz = true
	for id = 1, 400 do
		local _, tp = S.f2(part(), cen, { id = id }, 0.5, c0, x1, x6, x9)
		if not finite(tp) then okz = false end
	end
	check(okz, "Branch Count 0 stays finite")

	-- Slider extremes.
	for _, pair in ipairs({ { 0, 0 }, { 100, 20 } }) do
		local ce = cfg({ k13 = pair[1], k18 = pair[2], k15 = 3, k16 = 0.3 })
		local oke = true
		for id = 1, 400 do
			local _, tp = S.f2(part(), cen, { id = id }, 0.5, ce, x1, x6, x9)
			if not finite(tp) then oke = false end
		end
		check(oke, ("Jaggedness %d / Thickness %d stays finite"):format(pair[1], pair[2]))
	end

	-- Node Count at both ends of its clamp.
	for _, n in ipairs({ 4, 64 }) do
		local cn = cfg({ k12 = n, k15 = 3, k16 = 0.3, k18 = 2 })
		local okn = true
		for id = 1, 200 do
			local _, tp = S.f2(part(), cen, { id = id }, 0.5, cn, x1, x6, x9)
			if not finite(tp) then okn = false end
		end
		check(okn, ("Node Count %d stays finite"):format(n))
	end
end
```

The degenerate vertical-basis case is **not** tested here: with Aim At Cursor off the aim is
always the fallback `+Z`, so there is no way to point the bolt straight up yet. Task 3 adds it
once the cursor path exists.

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/bolt_smoke.lua
```

Expected: FAIL on `both channels populated`, `branch share tracks the slider` and
`branches actually leave the main channel` — Task 1's `f2` ignores `k15`/`k16` entirely, so every
part is a main-channel part. The finite and Node Count checks pass already.

- [ ] **Step 3: Write the minimal implementation**

Replace the body of `M.f2` in `shapes/Goro Goro no Mi.lua` between the `dir` line and the
`return`:

```lua
	local branches = math.clamp(math.floor(c.k15 or 3), 0, 12)
	local share = math.clamp(c.k16 or 0.3, 0, 0.8)
	local bfrac = math.clamp(c.k17 or 0.4, 0.1, 1.0)
	local thick = c.k18 or 2

	local id = d.id or 1
	local f1 = (id * PHI1) % 1
	local f2 = (id * PHI2) % 1

	local pos, u, v
	if branches > 0 and f2 < share then
		-- Which branch. Renormalise f2 across the share so the branches get an even
		-- cut of it, then reuse the remainder as the position along the branch.
		local q = f2 / share * branches
		local bi = math.floor(q)
		if bi >= branches then bi = branches - 1 end

		local bnodes = math.max(2, math.floor(nodes / 3))
		local bu, bv = basis(dir)
		local bdir = (dir
			+ bu * ((2 * h(seed, bi, 4) - 1) * 0.9)
			+ bv * ((2 * h(seed, bi, 5) - 1) * 0.9)).Unit
		local blen = len * bfrac * (0.5 + 0.5 * h(seed, bi, 6))

		-- Root on an interior node, never node 0 or node n: a branch off a pinned
		-- endpoint reads as a second bolt rather than a fork.
		local root_j = 1 + math.floor(h(seed, bi, 3) * (nodes - 1))
		local root = on_path(cen, dir, len, nodes, amp, seed, 1, sin_taper, root_j / nodes)

		-- seed + 991 + bi so a branch's own jitter is independent of the trunk's.
		pos, u, v = on_path(root, bdir, blen, bnodes, amp * 0.6, seed + 991 + bi, 1,
			tip_taper, q - bi)
	else
		pos, u, v = on_path(cen, dir, len, nodes, amp, seed, 1, sin_taper, f1)
	end

	-- Parts sitting exactly on the polyline read as one line of bricks. Keyed on the
	-- seed rather than t, so the scatter re-rolls with each flicker and holds still
	-- between: a crackle, not a buzz.
	pos = pos
		+ u * ((2 * h(seed, id, 7) - 1) * thick)
		+ v * ((2 * h(seed, id, 8) - 1) * thick)
```

`seed` is referenced throughout. Task 1 passed the literal `1`; add a placeholder local above the
block so this task compiles on its own, and Task 3 replaces its right-hand side:

```lua
	local seed = 1                        -- task 3 stamps this per bucket generation
```

Extend `M.Controls` with the four new entries. `k16` and `k17` carry `Div = 100`, so their
`Min`/`Max` are in display units while `config.lua` stores the fraction:

```lua
	{ Type = "Slider", Name = "Branch Count", Min = 0, Max = 12, Key = "k15", Default = 3, IntOnly = true },
	{ Type = "Slider", Name = "Branch Share", Min = 0, Max = 80, Key = "k16", Default = 30, Div = 100 },
	{ Type = "Slider", Name = "Branch Length", Min = 10, Max = 100, Key = "k17", Default = 40, Div = 100 },
	{ Type = "Slider", Name = "Core Thickness", Min = 0, Max = 20, Key = "k18", Default = 2 },
```

Extend the `x2` block. `k16` and `k17` are **stored** units — 0.3 displays as 30:

```lua
["Goro Goro no Mi"] = { k11 = 200, k12 = 18, k13 = 14, k15 = 3, k16 = 0.3, k17 = 0.4, k18 = 2 },
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
luajit tests/bolt_smoke.lua
```

Expected: `0 failures`.

- [ ] **Step 5: Run the lints**

```bash
luajit tests/controls_lint.lua && luajit tests/slider_range_lint.lua
```

Expected: `0 problems` from both. `slider_range_lint` is the one that catches a `Div` mistake —
a default stored pre-multiplied shows ten or a hundred times too large against its `Min`/`Max`.

- [ ] **Step 6: Commit**

```bash
git add "shapes/Goro Goro no Mi.lua" config.lua tests/bolt_smoke.lua
git commit -m "Add branches and core thickness to Goro Goro no Mi

Branches are bounded separately from the main channel in the tests: they
fork away from the axis by design and measure 32.7 studs against the main
channel's 18.4 on identical settings, so a single shared bound cannot hold
both."
```

---

### Task 3: Cursor aim and generation-quantised reseed

This is the task that makes it a lightning bolt rather than a static zigzag, and the one where
constraint 2 is load-bearing.

**Files:**
- Modify: `shapes/Goro Goro no Mi.lua`
- Modify: `config.lua`
- Test: `tests/bolt_smoke.lua`

**Interfaces:**
- Consumes: everything from Tasks 1 and 2.
- Produces: `f2` reads `c.k14` (Flicker Rate, Hz) and `c.k19` (Aim At Cursor, boolean), and holds
  state at `x6.pre["Goro Goro no Mi"]` with fields `{ seed, last_gen, next_roll, aim }`. Task 5
  adds `holding`, `tap_locked`, `touch_mode`, `last_frame` and `conns` to the same table.

- [ ] **Step 1: Write the failing test**

Add the game stubs to `tests/bolt_smoke.lua` **immediately above the Task 3 section**, not at the
top of the file. Placement matters: Task 1's section asserts against the no-camera fallback
direction, and installing a `workspace.CurrentCamera` above it would change what that section
measures. These are cut down from `tests/shapes_smoke.lua:119-185`:

```lua
-- Mutable so a section can move the cursor and prove the bolt follows it.
local MOUSE_HIT = Vector3.new(140, 8, 40)
local function set_mouse(v) MOUSE_HIT = v end
game = {
	GetService = function(_, name)
		if name == "Players" then
			return { LocalPlayer = { GetMouse = function() return { Hit = CFrame.new(MOUSE_HIT) } end } }
		end
		return {
			TouchEnabled = false,
			KeyboardEnabled = true,
			InputBegan = { Connect = function() return { Disconnect = function() end } end },
			InputEnded = { Connect = function() return { Disconnect = function() end } end },
			GetMouseLocation = function() return { X = 400, Y = 300 } end,
		}
	end,
}
workspace = {
	CurrentCamera = { CFrame = CFrame.new(0, 0, 0),
		ViewportPointToRay = function() return { Origin = Vector3.zero, Direction = Vector3.new(0, 0, 1) } end },
	Raycast = function() return { Position = MOUSE_HIT } end,
}
Enum = setmetatable({}, { __index = function()
	return setmetatable({}, { __index = function() return 0 end })
end })
```

**The module must not look up services at module scope.** `shapes/Twin Core Beam.lua:3-4` hoists
`game:GetService` to the top of the file; do the opposite here and resolve inside `resolve_aim`
and inside Task 5's connection setup, both under `pcall`. Two reasons: it lets the stubs be
installed anywhere before first use rather than before `load`, and in game it means a module
loaded before services are ready cannot error at load.

Note `CFrame.new(0,0,0).LookVector` is `(0, 0, -1)` — Roblox convention — in both the harness
(`tests/robloxmath.lua:57-60`) and the engine. The no-camera fallback is `(0, 0, 1)`, so the two
are genuinely different directions and Task 1's section measures the fallback.

Then add the section, above the file tail:

```lua
print("Goro Goro no Mi · aim and flicker")
do
	local cen = Vector3.new(0, 10, 0)
	local c = cfg({ k19 = true, k14 = 12, k15 = 3, k16 = 0.3, k18 = 2 })

	-- The bolt lands on the cursor.
	set_mouse(Vector3.new(140, 8, 40))
	local x6 = mk_x6()
	x6.f = 8
	local dir = (MOUSE_HIT - cen).Unit
	local len = (MOUSE_HIT - cen).Magnitude
	local far, bad = 0, 0
	for id = 1, 400 do
		local _, tp = S.f2(part(), cen, { id = id }, 1.0, c, x1, x6, x9)
		if not finite(tp) then bad = bad + 1 else
			local _, along = split(cen, dir, tp)
			if along > far then far = along end
		end
	end
	check(bad == 0, ("cursor aim finite (%d bad)"):format(bad))
	check(far <= len + 1, ("bolt lands on the cursor, not past it (%.1f of %.1f)"):format(far, len))
	check(far > len * 0.8, ("bolt actually reaches the cursor (%.1f of %.1f)"):format(far, len))
```

Continue the same block with the three checks that pin constraint 2 — these are the ones worth
the task:

```lua
	-- Every part in a generation sits on the SAME bolt. et = x1.k7 = 4, so ids
	-- spread across four frames within one generation must agree exactly.
	local x6b = mk_x6()
	local ref = {}
	for frame = 8, 11 do             -- gen = floor(8/4) = 2 for all four
		x6b.f = frame
		for id = 1, 50 do
			local _, tp = S.f2(part(), cen, { id = id }, 1.0 + frame / 60, c, x1, x6b, x9)
			local key = ("%.4f,%.4f,%.4f"):format(tp.X, tp.Y, tp.Z)
			if ref[id] == nil then ref[id] = key end
			check(ref[id] == key,
				("id %d agrees across frame %d within one generation"):format(id, frame))
		end
	end

	-- Advancing t past a flicker interval WITHOUT crossing a generation boundary must
	-- not move the path. This is what tears the bolt if it regresses.
	local x6c = mk_x6()
	x6c.f = 8
	local _, a = S.f2(part(), cen, { id = 77 }, 1.0, c, x1, x6c, x9)
	local _, b = S.f2(part(), cen, { id = 77 }, 1.0 + 5 / c.k14, c, x1, x6c, x9)
	check((a - b).Magnitude < 1e-6,
		("t alone does not reseed within a generation (moved %.4f)"):format((a - b).Magnitude))

	-- Crossing a generation boundary with enough elapsed time DOES reseed.
	local moved = 0
	for id = 1, 200 do
		local x6d = mk_x6()
		x6d.f = 8
		local _, p1 = S.f2(part(), cen, { id = id }, 1.0, c, x1, x6d, x9)
		x6d.f = 12                      -- gen 2 -> 3
		local _, p2 = S.f2(part(), cen, { id = id }, 1.0 + 2 / c.k14, c, x1, x6d, x9)
		if (p1 - p2).Magnitude > 0.5 then moved = moved + 1 end
	end
	check(moved > 150, ("crossing a generation reseeds (%d/200 parts moved)"):format(moved))

	-- The degenerate basis, now reachable: aim straight up. A vertical bolt must keep
	-- its full perpendicular spread. If the xAxis fallback in basis() were wrong the
	-- frame would collapse and the bolt would silently flatten -- the likeliest single
	-- bug in this file, and invisible without this check.
	set_mouse(Vector3.new(0, 210, 0))
	local x6e = mk_x6()
	x6e.f = 8
	local vdir = Vector3.new(0, 1, 0)
	local vworst = 0
	for id = 1, 1000 do
		local _, tp = S.f2(part(), cen, { id = id }, 1.0, cfg({ k19 = true, k15 = 0, k18 = 2 }), x1, x6e, x9)
		if finite(tp) then
			local perp = split(cen, vdir, tp)
			if perp > vworst then vworst = perp end
		end
	end
	check(vworst > 1, ("vertical basis does not collapse (spread %.1f)"):format(vworst))
	set_mouse(Vector3.new(140, 8, 40))
end
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/bolt_smoke.lua
```

Expected: FAIL on `bolt actually reaches the cursor` and `crossing a generation reseeds` — Tasks 1
and 2 hardcode the aim to `+Z` and the seed to `1`, so the bolt ignores the cursor and never
re-rolls. The agreement checks pass already, vacuously.

- [ ] **Step 3: Write the implementation**

Add `resolve_aim` above `M.f2` in `shapes/Goro Goro no Mi.lua`:

```lua
-- Services are resolved here, not at module scope, so a module loaded before the
-- services are ready cannot error and the test harness can install its stubs at any
-- point before the first call.
local function resolve_aim(cen, c)
	local length = c.k11 or 200

	if c.k19 then
		local ok, hit = pcall(function()
			local plrs = game:GetService("Players")
			local plr = plrs and plrs.LocalPlayer
			local mouse = plr and plr:GetMouse()
			if mouse and mouse.Hit then
				local pos = mouse.Hit.Position
				-- The > 10000 rejection is the one at shapes/Twin Core Beam.lua:62:
				-- mouse.Hit degenerates to a point at infinity when the ray hits
				-- nothing, and an aim there makes len enormous and the bolt invisible.
				if pos and pos.Magnitude < 10000 then
					return pos
				end
			end
			local cam = workspace.CurrentCamera
			if not cam then return nil end
			local uis = game:GetService("UserInputService")
			local ml = uis:GetMouseLocation()
			local ray = cam:ViewportPointToRay(ml.X, ml.Y)
			local res = workspace:Raycast(ray.Origin, ray.Direction * 1000)
			return res and res.Position or (ray.Origin + ray.Direction * length)
		end)
		if ok and hit then
			return hit
		end
	end

	-- Cursor off, or no cursor to be had: run along the camera's look direction, and
	-- along +Z when there is no camera at all.
	local ok2, look = pcall(function()
		local cam = workspace.CurrentCamera
		return cam and cam.CFrame and cam.CFrame.LookVector or nil
	end)
	local dir = Vector3.new(0, 0, 1)
	if ok2 and look and look.Magnitude > 0.1 then
		dir = look.Unit
	end
	return cen + dir * length
end
```

Then replace the top of `M.f2` — the `local seed = 1` placeholder and the hardcoded `aim` line —
with the stamp:

```lua
	local flicker = math.clamp(c.k14 or 12, 1, 60)

	local st = x6.pre["Goro Goro no Mi"]
	if not st then
		st = { seed = 1, last_gen = -1, next_roll = 0 }
		x6.pre["Goro Goro no Mi"] = st
	end

	-- Constraint 2. k7 spreads the parts across et frames, so the seed and the aim
	-- point may only change on a generation boundary. A reseed mid-cycle leaves some
	-- parts on bolt k and the rest on bolt k+1, which reads as the bolt ripping in
	-- half rather than flickering. Flicker is therefore time-driven but
	-- generation-quantised: at the requested rate when that is slower than the bucket
	-- cycle, clamped to one roll per cycle when it is faster.
	local et = math.max(1, math.floor(x1.k7 or 1))
	local gen = math.floor((x6.f or 0) / et)
	if st.last_gen ~= gen then
		st.last_gen = gen
		if t >= st.next_roll then
			st.seed = st.seed + 1
			st.next_roll = t + 1 / flicker
		end
		st.aim = resolve_aim(cen, c)
	end
	if not st.aim then
		st.aim = resolve_aim(cen, c)
	end

	local seed = st.seed
	local aim = st.aim
```

There is no `M.px` stage and there must not be one: constraint 5 says `px` never receives `cen`,
and both ends of this bolt are anchored to it — node 0 *is* `cen`, and under constraint 6 `cen` is
genuinely per-part. The stamping has to live in `f2`, guarded so only the first part of a
generation does the work. Do not "fix" this into a `px` stage later.

Add the two new `Controls` entries:

```lua
	{ Type = "Slider", Name = "Flicker Rate", Min = 1, Max = 60, Key = "k14", Default = 12 },
	{ Type = "Toggle", Name = "Aim At Cursor", Key = "k19", Default = true },
```

And extend the `x2` block. `k19` must be a **boolean**:

```lua
["Goro Goro no Mi"] = {
	k11 = 200, k12 = 18, k13 = 14, k14 = 12, k15 = 3,
	k16 = 0.3, k17 = 0.4, k18 = 2, k19 = true,
},
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
luajit tests/bolt_smoke.lua
```

Expected: `0 failures`. Task 1's section must still pass unchanged — if it now fails on
`never overshoots Bolt Length`, the stubs were installed above it instead of below.

- [ ] **Step 5: Run the lints**

```bash
luajit tests/controls_lint.lua && luajit tests/slider_range_lint.lua
```

Expected: `0 problems`. A `k19` stored as a number instead of `true` is exactly what
`controls_lint` exists to catch.

- [ ] **Step 6: Commit**

```bash
git add "shapes/Goro Goro no Mi.lua" config.lua tests/bolt_smoke.lua
git commit -m "Aim Goro Goro no Mi at the cursor and quantise its flicker

The seed and the aim point are stamped once per bucket generation, not per
frame. k7 spreads the parts across et frames, so a mid-cycle reseed leaves
some parts on one bolt and the rest on the next -- the bolt rips in half
instead of flickering. Three checks in bolt_smoke pin that."
```

---

### Task 4: Hold To Fire, and the cleanup it obliges

**Files:**
- Modify: `shapes/Goro Goro no Mi.lua`
- Modify: `config.lua`
- Test: `tests/bolt_smoke.lua`

**Interfaces:**
- Consumes: the `x6.pre["Goro Goro no Mi"]` table from Task 3.
- Produces: `M.cleanup(x6, x1)`, called by `System.lua`'s `cleanup_shape` (`System.lua:151-157`)
  on shape switch, disable and stop. `f2` reads `c.k20` (Hold To Fire, boolean).

- [ ] **Step 1: Write the failing test**

```lua
print("Goro Goro no Mi · hold to fire and cleanup")
do
	local cen = Vector3.new(0, 10, 0)
	local x6 = mk_x6()
	x6.f = 8

	-- Hold To Fire off: no listeners, and the bolt is live with no input at all.
	local c_off = cfg({ k19 = true, k20 = false })
	local _, tp = S.f2(part(), cen, { id = 5 }, 1.0, c_off, x1, x6, x9)
	check(finite(tp), "bolt is live with Hold To Fire off")
	check(x6.pre["Goro Goro no Mi"].conns == nil, "no listeners connected when not needed")

	-- Hold To Fire on, not held: the parts hold a cloud at cen rather than going dead.
	local x6h = mk_x6()
	x6h.f = 8
	local c_on = cfg({ k19 = true, k20 = true })
	local far, allsame = 0, {}
	for id = 1, 200 do
		local vel, p2 = S.f2(part(), cen, { id = id }, 1.0, c_on, x1, x6h, x9)
		check(finite(p2) and finite(vel), ("idle id %d finite"):format(id))
		local dist = (p2 - cen).Magnitude
		if dist > far then far = dist end
		allsame[("%.2f,%.2f,%.2f"):format(p2.X, p2.Y, p2.Z)] = true
	end
	local distinct = 0
	for _ in pairs(allsame) do distinct = distinct + 1 end
	check(far > 1, ("idle parts hold a cloud, not a single point (max %.1f)"):format(far))
	check(distinct > 150, ("idle cloud is spread, not stacked (%d/200)"):format(distinct))
	check(x6h.pre["Goro Goro no Mi"].conns ~= nil, "listeners connected when Hold To Fire is on")

	-- Cleanup must disconnect and clear. x6.pre survives a shape switch -- only
	-- M.cleanup runs -- so a module holding connections without one leaks them for the
	-- whole session and keeps writing into state while an unrelated shape is active.
	-- shapes/Twin Core Beam.lua:20-26 records that shipping once.
	local disconnected = 0
	for _, cn in ipairs(x6h.pre["Goro Goro no Mi"].conns) do
		local real = cn.Disconnect
		cn.Disconnect = function(...) disconnected = disconnected + 1; return real(...) end
	end
	local nconns = #x6h.pre["Goro Goro no Mi"].conns
	S.cleanup(x6h, x1)
	check(disconnected == nconns, ("cleanup disconnects all %d listeners"):format(nconns))
	check(x6h.pre["Goro Goro no Mi"] == nil, "cleanup clears its x6.pre entry")
	local ok = pcall(S.cleanup, mk_x6(), x1)
	check(ok, "cleanup is safe to call twice / on fresh state")
end
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/bolt_smoke.lua
```

Expected: a hard error on `S.cleanup` being nil (`attempt to call field 'cleanup'`), preceded by
FAILs on the two `conns` checks.

- [ ] **Step 3: Write the implementation**

Add the listener setup inside the `if not st then` branch in `M.f2`, after the table is created.
This is `shapes/Twin Core Beam.lua:28-47` with the same desktop/touch split:

```lua
	if c.k20 and not st.conns then
		st.conns = {}
		local ok = pcall(function()
			local uis = game:GetService("UserInputService")
			st.touch_mode = uis.TouchEnabled and not uis.KeyboardEnabled
			st.conns[#st.conns + 1] = uis.InputBegan:Connect(function(inp, gpe)
				if gpe then return end
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					st.holding = true
				elseif inp.UserInputType == Enum.UserInputType.Touch then
					if st.touch_mode then
						st.tap_locked = not st.tap_locked
					else
						st.holding = true
					end
				end
			end)
			st.conns[#st.conns + 1] = uis.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					st.holding = false
				elseif inp.UserInputType == Enum.UserInputType.Touch and not st.touch_mode then
					st.holding = false
				end
			end)
		end)
		if not ok then
			st.conns = nil
		end
	end
```

Then gate the bolt. Put this after the stamp, before the geometry:

```lua
	local firing = true
	if c.k20 then
		firing = st.holding or st.tap_locked or x1.IsLaunching or false
	end

	if not firing then
		-- A loose cloud at cen. Returning Vector3.zero instead reads as the parts
		-- going dead, which is worse than idle.
		local id0 = d.id or 1
		local rad = 6 + (c.k18 or 2)
		local cloud = cen + Vector3.new(
			(2 * h(seed, id0, 11) - 1) * rad,
			(2 * h(seed, id0, 12) - 1) * rad,
			(2 * h(seed, id0, 13) - 1) * rad)
		return (cloud - p.Position) * (x1.k10 * x9.c1), cloud
	end
```

And the cleanup, mirroring `shapes/Twin Core Beam.lua:148-161`:

```lua
function M.cleanup(x6, x1)
	if not x6 or not x6.pre then
		return
	end
	local st = x6.pre["Goro Goro no Mi"]
	if st and st.conns then
		for _, conn in ipairs(st.conns) do
			pcall(function()
				conn:Disconnect()
			end)
		end
	end
	x6.pre["Goro Goro no Mi"] = nil
end
```

One `Controls` entry and one `x2` key, boolean:

```lua
	{ Type = "Toggle", Name = "Hold To Fire", Key = "k20", Default = false },
```

- [ ] **Step 4: Run the test and the lints**

```bash
luajit tests/bolt_smoke.lua && luajit tests/controls_lint.lua && luajit tests/slider_range_lint.lua
```

Expected: `0 failures` and `0 problems` from all three.

- [ ] **Step 5: Commit**

```bash
git add "shapes/Goro Goro no Mi.lua" config.lua tests/bolt_smoke.lua
git commit -m "Add Hold To Fire to Goro Goro no Mi, with the cleanup it obliges

Listeners are only connected when the toggle is on, and M.cleanup
disconnects them. x6.pre survives a shape switch -- only M.cleanup runs --
so without one the listeners stay connected for the session and keep
writing into state while an unrelated shape is active."
```

---

### Task 5: Neon recolour, and the full-suite gate

**Files:**
- Modify: `shapes/Goro Goro no Mi.lua`
- Modify: `config.lua`
- Test: `tests/bolt_smoke.lua`

**Interfaces:**
- Consumes: everything prior.
- Produces: `f2` reads `c.k21` (Neon Recolour, boolean) and, when set, writes `p.Material` and
  `p.Color`. Nothing later consumes this.

- [ ] **Step 1: Write the failing test**

```lua
print("Goro Goro no Mi · neon recolour")
do
	local cen = Vector3.new(0, 10, 0)
	local x6 = mk_x6()
	x6.f = 8
	local writes = 0
	local function tracked()
		local t = { Position = Vector3.new(0, 0, 0) }
		return setmetatable({}, {
			__index = t,
			__newindex = function(_, k, v) writes = writes + 1; t[k] = v end,
		}), t
	end

	-- Off by default: the shape must not touch parts it only borrowed.
	local pa = tracked()
	S.f2(pa, cen, { id = 3 }, 1.0, cfg({ k21 = false }), x1, x6, x9)
	check(writes == 0, ("no property writes with the toggle off (%d)"):format(writes))

	-- On: writes once, then never again for an unchanged part. A physics property
	-- write per part per frame is the cost the guard at shapes/Platform.lua:259-263
	-- exists to avoid.
	writes = 0
	local pb, raw = tracked()
	local c_on = cfg({ k21 = true })
	S.f2(pb, cen, { id = 3 }, 1.0, c_on, x1, x6, x9)
	local first = writes
	check(first > 0, "the toggle actually writes")
	check(raw.Material ~= nil and raw.Color ~= nil, "both Material and Color are set")
	writes = 0
	for _ = 1, 20 do
		S.f2(pb, cen, { id = 3 }, 1.0, c_on, x1, x6, x9)
	end
	check(writes == 0, ("guarded: %d further writes across 20 frames"):format(writes))
end
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/bolt_smoke.lua
```

Expected: FAIL on `the toggle actually writes` and `both Material and Color are set`; `k21` is
read by nothing yet.

- [ ] **Step 3: Write the implementation**

Add just before the `return` in `M.f2`:

```lua
	-- Optional, and off by default, because it mutates parts the script only
	-- borrowed and leaves them recoloured after a shape switch -- shapes/Platform.lua
	-- has the same property and it is accepted behaviour there. Compare before
	-- assigning: a physics property write per part per frame is the whole cost the
	-- guard at shapes/Platform.lua:259-263 exists to avoid.
	if c.k21 then
		local want = x1.k3 or Color3.fromRGB(0, 255, 255)
		if p.Material ~= Enum.Material.Neon then
			p.Material = Enum.Material.Neon
		end
		if p.Color ~= want then
			p.Color = want
		end
	end
```

One `Controls` entry, one boolean `x2` key. The block is now complete at all eleven keys:

```lua
	{ Type = "Toggle", Name = "Neon Recolour", Key = "k21", Default = false },
```

```lua
["Goro Goro no Mi"] = {
	k11 = 200, k12 = 18, k13 = 14, k14 = 12, k15 = 3,
	k16 = 0.3, k17 = 0.4, k18 = 2, k19 = true, k20 = false, k21 = false,
},
```

- [ ] **Step 4: Run the whole suite, not just the new file**

```bash
for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: every file reports `0 failures` / `0 problems` / `ALL CHECKS PASSED`. The baseline before
this plan was green, so any red here is this plan's doing. `controls_lint` should now report 51
shapes and `slider_range_lint` 52.

- [ ] **Step 5: Commit**

```bash
git add "shapes/Goro Goro no Mi.lua" config.lua tests/bolt_smoke.lua
git commit -m "Add optional neon recolour to Goro Goro no Mi

Off by default: it mutates parts the script only borrowed and leaves them
recoloured after a shape switch. Guarded compare-before-assign, because a
physics property write per part per frame is the cost that guard exists to
avoid."
```

- [ ] **Step 6: In-game confirmation**

Automated coverage stops at the geometry. These need a running client, and the shape is not
"tested" until they are done — say so plainly rather than reporting the task complete on green
tests alone:

1. Claim a large pile of parts, select Goro Goro no Mi, and confirm the bolt tracks the cursor and
   flickers rather than sliding.
2. Confirm it does not visibly tear or split into two offset halves. Tearing means the stamp
   escaped its generation — the one failure the unit tests are built to catch, so it should not
   happen, but it is the thing to look for.
3. Aim straight up and confirm the bolt keeps its thickness instead of flattening into a ribbon.
4. Toggle Hold To Fire and confirm both the fire gate and the idle cloud on desktop, then on
   mobile (tap toggles rather than holds).
5. Toggle Neon Recolour on and off, then switch shapes, and confirm nothing errors.

---

## Self-Review

**Spec coverage.** Every element of sub-project 1 maps to a task: the hash and its squaring term
(Task 1), node path with `sin` taper and pinned endpoints (Task 1), Weyl mapping and in-segment
interpolation (Task 1), branches with `tip` taper (Task 2), core thickness (Task 2), aim chain and
generation-quantised stamping (Task 3), the no-`px` decision (Task 3), Hold To Fire and mandatory
cleanup (Task 4), Neon recolour (Task 5), all eleven controls and their `x2` types (accumulated
across Tasks 1–5), and all ten spec verification points (Tasks 1–3 cover 1–10; the vertical-basis
case moved from Task 2 to Task 3 because it needs the cursor path to be reachable).

**Deviation from the spec, deliberate:** the spec's verification section originally named a new
section in `tests/shapes_smoke.lua`. That file declares 198 top-level locals against LuaJIT's
ceiling of 200 per chunk, so it cannot host one. The spec has been corrected to name
`tests/bolt_smoke.lua`; this plan and the spec agree.

**Type consistency.** `h(seed, node, chan)`, `basis(dir)`, `on_path(origin, dir, len, n, amp, seed,
chan, taper, f)`, `resolve_aim(cen, c)`, `sin_taper(j, n)`, `tip_taper(j, n)` — each is used in
later tasks with the same name and arity it is defined with. `M._h` is the only test-visible
export. State fields `seed`, `last_gen`, `next_roll`, `aim`, `conns`, `holding`, `tap_locked`,
`touch_mode` are spelled identically in Tasks 3 and 4.

**Known-unverifiable.** Nothing in `tests/` drives Roblox physics, input, or rendering, so the fire
gate, the touch path, the recolour and the on-screen read of the bolt are in-game checks only.
Step 6 of Task 5 is not optional.
