# Max Fidelity Switch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One toggle that gives up all five of the runtime loop's accuracy-for-speed shortcuts, so
every claimed part is solved every frame at full precision regardless of how many there are.

**Architecture:** No new mechanism. `x1["Force Smooth (Lags)"]` already pins three of the five
shortcuts; `MaxFidelity` is a strict superset that widens the same three conditions and adds the
two it misses by extending the existing `always_process` flag. Five small edits per runtime tree,
one toggle per UI tree.

**Tech Stack:** Lua 5.1 / Luau. No test harness drives the main loop, so verification is a green
suite, a syntax parse, and in-game confirmation.

**Spec:** `docs/superpowers/specs/2026-08-21-lightning-fidelity-partctl-design.md` — sub-project 2.
Read constraints 9, 10 and 11 before starting.

## Global Constraints

- **Every runtime edit lands twice.** `mobilever/System.lua` is a near-verbatim second copy of
  `System.lua` and carries the same guards within two lines of the same offsets. Same for
  `mobilever/UI.lua` against `UI.lua`. A change applied to one tree only is a
  desktop-only or mobile-only bug and no test here catches it.
- **`MaxFidelity` must exist in `config.lua`'s `x1` block as a boolean.** `load_settings` only
  restores a saved value when a default of the matching type already exists, and `reset_config`
  only restores what it snapshotted from that table. A key the UI writes but `x1` omits both
  forgets itself between sessions and survives "Reset All Settings" — see the comments at
  `config.lua:31-35` and `config.lua:43-47`, both written after exactly that bug.
- **Do not change the values of `k1`, `c7`, `k7` or `k8`.** Bypass the tests, never the settings,
  so turning the switch off restores the previous behaviour exactly.
- **Do not group the toggle with the four `Perf_*` toggles.** Those describe changes to the game's
  rendering, already applied elsewhere (`UI.lua:1436`, `main.lua:277`). This one changes the
  script's own loop.
- **Run from the repo root.**

---

## File Structure

| File | Responsibility |
|---|---|
| `config.lua` | **Modify.** One `x1` boolean. |
| `System.lua` | **Modify.** Three edits: hoist the local, widen the `dt`/`et` pin, widen `always_process`, widen `sm_alpha`. |
| `mobilever/System.lua` | **Modify.** The same three, at offsets within two lines. |
| `UI.lua` | **Modify.** One toggle beside `Force Smooth (Lags)`. |
| `mobilever/UI.lua` | **Modify.** The same toggle. |

Plus one new file:

| `tests/fidelity_lint.lua` | **Create.** Static check that both runtime trees honour the flag. |

Nothing in `tests/` instantiates the main loop, so a behavioural test is not available. A static
check is, and it targets the single most likely bug in this plan — applying the change to one tree
and not the other. `tests/controls_lint.lua` is the precedent for a static check earning its place
here.

---

### Task 1: The flag, and both runtime trees

The config key and both `System.lua` files land together: a flag the runtime ignores is not an
independently reviewable deliverable, and the lint that guards it has to see both trees to be
worth writing.

**Files:**
- Modify: `config.lua` (`x1` block, near the other booleans)
- Modify: `System.lua` at `:226-230`, `:363`, `:413`
- Modify: `mobilever/System.lua` at `:224-228`, `:361`, `:411` (verify by content, not by number)
- Create: `tests/fidelity_lint.lua`

**Interfaces:**
- Consumes: nothing.
- Produces: `x1.MaxFidelity` (boolean, default `false`), read by both runtime trees and written by
  both UI trees in Task 2. Inside each `System.lua`, the local is named `max_fid` and is declared
  beside `force_smooth`; Task 2 does not touch it.

- [ ] **Step 1: Write the failing test**

Create `tests/fidelity_lint.lua`:

```lua
-- Max Fidelity has to be honoured in BOTH runtime trees. mobilever/System.lua is a
-- near-verbatim second copy of System.lua, so the natural failure is a change that
-- lands in one and not the other -- a desktop-only or mobile-only bug that nothing
-- else here catches. No test harness instantiates the loop, so this checks the
-- source rather than the behaviour, which is honest about what it proves: that the
-- flag is wired at all four sites in both trees, not that the loop then does the
-- right thing.
--
--   luajit tests/fidelity_lint.lua      (from the repo root)

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
```

Continue the same file with the assertions:

```lua
-- The default has to be a boolean and it has to be in the x1 block, or load_settings
-- can never restore it and reset_config never snapshots it. config.lua:31-35 records
-- that failure shipping once already.
do
	local cfg = assert(loadfile("config.lua"))
	-- config.lua builds Vector3/Color3 values at load, so give it the two stubs it
	-- needs before calling it.
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

	-- Shortcuts 1 and 2: the part-count ladder and the k7 bucket.
	check(src:find("if%s+force_smooth%s+or%s+max_fid%s+then") ~= nil,
		path .. ": the dt/et pin reads max_fid alongside force_smooth")

	-- Shortcuts 3 and 4: the radius cull and the deadzone, both via always_process.
	check(src:find("local%s+always_process%s*=[^\n]*max_fid") ~= nil,
		path .. ": always_process includes max_fid")

	-- Nothing may weaken the existing flag while widening it.
	check(src:find("local%s+always_process%s*=[^\n]*is_drop_shape") ~= nil,
		path .. ": always_process still honours is_drop_shape")
	check(src:find("local%s+always_process%s*=[^\n]*is_self_bounded_shape") ~= nil,
		path .. ": always_process still honours is_self_bounded_shape")

	-- Shortcut 5: velocity smoothing. Counting is how a partially-applied edit is
	-- caught: one declaration plus three uses, two of which share the `force_smooth
	-- or max_fid` form, so the total must be exactly four.
	local n = 0
	for _ in src:gmatch("max_fid") do n = n + 1 end
	check(n == 4, ("%s: max_fid appears 4 times (1 decl + 3 uses), found %d"):format(path, n))

	-- The values themselves must be untouched: bypass the tests, not the settings.
	check(src:find("k1_sq%s*=%s*k1%s*%*%s*k1") ~= nil, path .. ": k1 still drives the cull radius")
	check(src:find("c7_sq%s*=%s*c7%s*%*%s*c7") ~= nil, path .. ": c7 still drives the deadzone")
end

print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/fidelity_lint.lua
```

Expected: FAIL on `config.lua x1 declares MaxFidelity`, `MaxFidelity is a boolean`,
`MaxFidelity defaults to off`, and then six failures per tree — the two `is_drop_shape` /
`is_self_bounded_shape` and the two `k1_sq` / `c7_sq` checks should already pass, so expect
`12 failures` out of 19 checks.

- [ ] **Step 3: Add the config key**

In `config.lua`, in the `x1` block beside the other booleans (near `PreserveCollisions` /
`PredictiveTracking`), add:

```lua
		-- Gives up all five of the loop's accuracy-for-speed shortcuts at once: the
		-- part-count ladder, the k7 bucket, the k1 radius cull, the c7 deadzone and
		-- the k8 smoothing. Force Smooth (Lags) already covers the first, second and
		-- fifth; this is that toggle finished. Boolean, and it must live here or
		-- load_settings can never restore it and reset_config never snapshots it.
		MaxFidelity = false,
```

- [ ] **Step 4: Widen the three conditions in `System.lua`**

**4a.** At `System.lua:226-230`, this:

```lua
			local force_smooth = x1["Force Smooth (Lags)"]
			if force_smooth then
				dt = 1
				et = 1
			end
```

becomes:

```lua
			local force_smooth = x1["Force Smooth (Lags)"]
			local max_fid = x1.MaxFidelity
			if force_smooth or max_fid then
				dt = 1
				et = 1
			end
```

`et = 1` makes `update_bucket = x6.f % 1` zero and `i % 1 == 0` for every part, so the bucket skip
at `:465` becomes a no-op with no edit to that line. `dt = 1` drops the ladder's compensation out
of `dt_mult` (`:356`) and the angular damping rate (`:369`) in the same stroke.

`max_fid` is declared here, before both remaining sites, so it is in scope for all three.

**4b.** At `System.lua:363`:

```lua
			if force_smooth then
				sm_alpha = 1
			end
```

becomes:

```lua
			if force_smooth or max_fid then
				sm_alpha = 1
			end
```

**4c.** At `System.lua:413`:

```lua
			local always_process = (is_drop_shape or is_self_bounded_shape) and true or false
```

becomes:

```lua
			-- max_fid here is the whole of shortcuts 3 and 4: :487 and :506 already read
			-- this flag, so neither line changes. Bypassing the tests rather than
			-- changing k1 and c7 means turning the switch off restores the previous
			-- behaviour exactly.
			local always_process = (is_drop_shape or is_self_bounded_shape or max_fid) and true or false
```

- [ ] **Step 5: Apply the identical three edits to `mobilever/System.lua`**

Locate each site **by content, not by line number** — the mobile twin sits within two lines of the
root's offsets (`:224` for the `force_smooth` read, `:361` for `sm_alpha`, `:411` for
`always_process`) and will drift. Search for `local force_smooth`, `sm_alpha = 1` and
`local always_process` and make the same three changes.

- [ ] **Step 6: Run the lint to verify it passes**

```bash
luajit tests/fidelity_lint.lua
```

Expected: `19 checks, 0 failures`. If `max_fid appears 4 times` fails with a count of 3, one of the
two `if` conditions was missed in that tree — that is the whole reason the check counts rather than
matching.

- [ ] **Step 7: Run the whole suite**

```bash
for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: all green. None of the existing tests touch these lines, so red here means an edit landed
in the wrong place.

- [ ] **Step 8: Commit**

```bash
git add config.lua System.lua mobilever/System.lua tests/fidelity_lint.lua
git commit -m "Add Max Fidelity: drop all five loop shortcuts at once

Force Smooth (Lags) already pinned the part-count ladder, the k7 bucket and
the k8 smoothing. This widens those same conditions and extends
always_process to cover the two it missed -- the k1 radius cull and the c7
deadzone. k1 and c7 keep their values; only the tests are bypassed, so
turning it off restores the previous behaviour exactly.

tests/fidelity_lint.lua counts the wiring in both runtime trees, because
mobilever/System.lua is a near-verbatim copy and landing the change in one
tree only is a mobile-only bug nothing else catches."
```

---

### Task 2: The toggle in both UI trees

**Files:**
- Modify: `UI.lua` at `:971` (inside the general-settings group `gsc`)
- Modify: `mobilever/UI.lua` beside its `Force Smooth` equivalent
- Modify: `tests/fidelity_lint.lua`

**Interfaces:**
- Consumes: `x1.MaxFidelity` from Task 1.
- Produces: nothing consumed by later work.

- [ ] **Step 1: Extend the lint**

Add to `tests/fidelity_lint.lua`, above the final `print`:

```lua
-- Both UI trees must expose it, or the flag exists and no user can reach it.
for _, path in ipairs({ "UI.lua", "mobilever/UI.lua" }) do
	local src = slurp(path)
	check(src:find("x1%.MaxFidelity%s*=%s*v") ~= nil, path .. ": a toggle writes x1.MaxFidelity")
	check(src:find("Max Fidelity") ~= nil, path .. ": the toggle is labelled")
	-- It must sit with Force Smooth, not with the four Perf_* toggles: those describe
	-- changes to the game's rendering that are applied elsewhere (UI.lua:1436,
	-- main.lua:277), and grouping a loop-fidelity switch with them invites exactly
	-- that confusion.
	local fs = src:find("Force Smooth %(Lags%)") or src:find("Force Smooth")
	local mf = src:find("Max Fidelity")
	check(fs ~= nil and mf ~= nil and math.abs(mf - fs) < 900,
		path .. ": Max Fidelity sits next to Force Smooth, not in the Perf group")
end
```

- [ ] **Step 2: Run the lint to verify it fails**

```bash
luajit tests/fidelity_lint.lua
```

Expected: `6 failures` — three per UI tree. The 19 checks from Task 1 still pass.

- [ ] **Step 3: Add the desktop toggle**

`UI.lua:971` currently builds the `Force Smooth (Lags)` toggle with the helper `et`:

```lua
				et(gsc, "Force Smooth (Lags)", x1["Force Smooth (Lags)"], function(v)
					x1["Force Smooth (Lags)"] = v
```

Add directly beneath that entry's closing, following the same call shape the surrounding code uses
(read the two neighbouring `et(...)` calls before writing this — the helper's trailing arguments
differ between groups and copying the neighbour is more reliable than reproducing it here):

```lua
				et(gsc, "Max Fidelity (No Skipping)", x1.MaxFidelity, function(v)
					x1.MaxFidelity = v
				end)
```

The label says what it costs. Do not name it "Max Fidelity" alone — the whole point is that it
trades frame rate for accuracy, and a user with 5000 claimed parts should be able to guess that from
the label.

- [ ] **Step 4: Add the mobile toggle**

Find the `Force Smooth` toggle in `mobilever/UI.lua` and add the same entry beside it, using that
file's own toggle helper and group variable. Do **not** put it in the Advanced panel next to
`Disable Shadows` / `Disable Post-FX` / `Potato Materials` / `Hide Particles`.

- [ ] **Step 5: Run the lint and the whole suite**

```bash
luajit tests/fidelity_lint.lua && for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: `25 checks, 0 failures` from the lint, and every other file green. `tests/load_build_smoke.lua`
is the one that exercises UI construction — if it goes red, the toggle was added with the wrong
helper arity.

- [ ] **Step 6: Commit**

```bash
git add UI.lua mobilever/UI.lua tests/fidelity_lint.lua
git commit -m "Expose Max Fidelity in both UI trees

Sits beside Force Smooth (Lags), not with the four Perf_* toggles: those
change the game's rendering and are applied elsewhere, while this one
changes the script's own loop."
```

- [ ] **Step 7: In-game confirmation**

Nothing in `tests/` drives the loop, so the switch is not verified until this is done. Report it
that way — a green lint proves the wiring, not the behaviour.

1. Claim over 1000 parts so the part-count ladder is active (`dt` becomes 3), pick any shape, and
   confirm motion visibly steps.
2. Turn Max Fidelity on and confirm the stepping smooths out and the frame rate drops.
3. Turn it off and confirm the previous behaviour returns exactly — this is what proves `k1` and
   `c7` were bypassed rather than changed.
4. Fling parts far past 2000 studs with it off and confirm they stay parked; turn it on and confirm
   they are driven back. This is the one real behaviour change in the plan and it is where the cost
   lands on a large claim.
5. Repeat 1–4 on mobile. Constraint 9 means a desktop pass says nothing about the mobile tree.

---

## Self-Review

**Spec coverage.** All five shortcuts from constraint 10 are covered: 1 and 2 by the `dt`/`et` pin
(Task 1 step 4a), 3 and 4 by `always_process` (step 4c), 5 by `sm_alpha` (step 4b). The `x1` key and
its type requirement is step 3. Both UI trees are Task 2. The spec's "behaviour change worth
stating" — runaway parts no longer parked — is Task 2 step 7 item 4. Constraint 9's
apply-twice requirement is enforced mechanically by the lint rather than left to care.

**Placeholder scan.** One deliberate instruction to read surrounding code rather than copy a
literal: the `et(...)` helper's trailing arguments differ between UI groups, so Task 2 step 3 says
to match the neighbour. That is a real property of `UI.lua`, not a gap — reproducing a guessed arity
here would be worse than pointing at the truth.

**Type consistency.** `x1.MaxFidelity` (boolean) and the local `max_fid` are spelled identically in
every task and in the lint's patterns. The lint's expected counts (4 per runtime tree; 19 checks
after Task 1, 25 after Task 2) match the edits the tasks actually make.

**Known-unverifiable.** The lint proves the flag is wired at all four sites in both trees. It does
not and cannot prove the loop then behaves correctly — no harness instantiates it. Task 2 step 7 is
the only evidence for behaviour.
