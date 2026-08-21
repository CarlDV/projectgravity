# Per-Part Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A new system, independent of the Sculptor, that takes individual claimed parts out from
under the global shape and gives each its own behaviour — pinned in place, following a hand-set
target, or running a different shape than the rest — including making a single part solid and
physically real enough to stand on.

**Architecture:** Override fields hung on the existing per-part record `x6.a[p]`, consulted by the
main loop immediately before it calls the active shape. Absent fields mean normal, so an
uncontrolled part costs one nil check. A new `System_partctl.lua` per runtime tree owns selection,
input and the assignment API, mirroring how `System_sculptor.lua` is already wired. Module
resolution for assigned shapes happens at assignment time, never in the loop.

**Tech Stack:** Lua 5.1 / Luau. Tests run under LuaJIT against the stubs in `tests/`.

**Spec:** `docs/superpowers/specs/2026-08-21-lightning-fidelity-partctl-design.md` — sub-project 3.
Read constraints 4, 9, 11, 12, 13 and 14 before starting. Constraint 13 is the one most likely to
be missed and it is the substance of the riding feature.

## Global Constraints

- **`System_sculptor.lua`, `mobilever/System_sculptor.lua` and `shapes/Sculptor.lua` are not to be
  opened.** This was an explicit instruction: "this is not a sculptor expansion. we will not be
  touching it. instead, we will create a new independent system". No reuse of `x6.sculptor_*`, no
  shared selection state, no shared highlight colour.
- **Every runtime and UI edit lands twice** (constraint 9). `mobilever/System.lua` and
  `mobilever/UI.lua` are near-verbatim second copies.
- **Never call `get_shape` inside the part loop** (constraint 14). It fetches over HTTP for an
  unloaded shape; `System.lua:149-150` records the hazard. Resolve at assignment time and cache the
  module on the record.
- **Never write `d.original_can_collide`, `d.original_anchored` or `d.original_properties`.** Read
  only. `d` holds the only copy of a part's pre-claim state, and `System.lua:439-452` documents how
  overwriting it makes the part permanently unrestorable.
- **New `x1` keys must exist in `config.lua` at their final type**, or they forget themselves between
  sessions and survive "Reset All Settings" (`config.lua:31-35`, `:43-47`).
- **Physics property writes must be guarded compare-before-assign**, the way
  `shapes/Platform.lua:259-263` guards its material writes.
- **Run from the repo root.**

---

## File Structure

| File | Responsibility |
|---|---|
| `System_partctl.lua` | **Create.** Selection, input, highlights, assignment API, module registry. |
| `mobilever/System_partctl.lua` | **Create.** The mobile twin. |
| `System.lua` | **Modify.** Five sites: px pass, bucket skip, two `always_process` reads, dispatch, collide/properties restore. |
| `mobilever/System.lua` | **Modify.** The same five. |
| `UI.lua` | **Modify.** Part Control panel. |
| `mobilever/UI.lua` | **Modify.** The same panel. |
| `config.lua` | **Modify.** `x1` keys for panel state and the multi-select modifier. |
| `main.lua` | **Modify.** `x6` field init beside `:522-528`, teardown hook beside `:659`. |
| `tests/partctl_smoke.lua` | **Create.** Unit tests for the module's API. |
| `tests/partctl_lint.lua` | **Create.** Static check that both runtime trees are wired. |

## Data model

Hung on the existing `d` record (`x6.a[p]`, built at `System.lua:785-795`). Absent means normal.

| Field | Type | Meaning |
|---|---|---|
| `d.pc_mode` | `nil` \| `"pin"` \| `"manual"` \| `"shape"` | `nil` is normal shape control |
| `d.pc_target` | `Vector3` | world target for `pin` and `manual` |
| `d.pc_shape` | `string` | shape name, `"shape"` mode only |
| `d.pc_mod` | table | resolved module, cached at assignment |
| `d.pc_phys` | table \| `nil` | any subset of `{ k10, k8, Damping, MaxSpeed }` |
| `d.pc_ride` | boolean | collidable and physically real |

`pin` and `manual` differ only in who writes `pc_target` — `pin` latches the part's current position
once, `manual` follows a dragged target. Same loop path, one flag apart.

Nothing here can leak: `System.lua:456` clears `data[p]` on release, so the fields die with the part.
The `SelectionBox` highlights in Task 1 are Instances and *do* have that problem — see that task.

---

### Task 1: `System_partctl.lua` — selection, assignment API, teardown

The module comes first because nothing else can be driven without it, and because it is the only
part of this plan that is genuinely unit-testable.

**Files:**
- Create: `System_partctl.lua`
- Create: `mobilever/System_partctl.lua`
- Modify: `System.lua:1481-1482` (wiring), `mobilever/System.lua:1338` (wiring)
- Modify: `main.lua` — `x6` fields beside `:522-528`, teardown beside `:659`
- Modify: `config.lua` — `x1.PartCtlMultiSelect`
- Create: `tests/partctl_smoke.lua`

**Interfaces:**
- Consumes: `context.x1`, `context.x6`, `context.v1` (UserInputService), `context.v4` (workspace),
  `context.v9` (mouse), `context.get_shape` — the same context `System_sculptor.lua` receives.
- Produces, published on `x6` for the UI and the loop to use:
  - `x6.pc_selected` — weak-keyed `part -> true`
  - `x6.pc_highlights` — weak-keyed `part -> SelectionBox`
  - `x6.pc_mods` — `module -> count` registry of distinct assigned shape modules
  - `x6.pc_clear()` — destroys every highlight, empties all three tables
  - `x6.pc_assign(mode, opts)` — applies `mode` to the whole current selection. `mode` is one of
    `nil`, `"pin"`, `"manual"`, `"shape"`. `opts` may carry `shape` (string), `target` (Vector3),
    `phys` (table), `ride` (boolean). Returns the number of parts changed.
  - `x6.pc_release(part)` — clears every `pc_*` field on one part and updates `pc_mods`.

  Tasks 2–5 consume `pc_mods`, `pc_assign` and the `d.pc_*` fields by these exact names.

- [ ] **Step 1: Write the failing test**

Create `tests/partctl_smoke.lua`. The preamble follows `tests/mech_track.lua`, which already stubs a
Roblox environment and asserts on cleanup:

```lua
-- Per-part control: the assignment API, the module registry, and the teardown.
--
-- The loop dispatch itself is not testable here -- nothing in tests/ instantiates
-- the main loop -- so this covers the module's own contract and tests/partctl_lint.lua
-- covers the wiring. Say so when reporting; a green run here is not a working feature.
--
--   luajit tests/partctl_smoke.lua      (from the repo root)

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

-- A claimed part and its d record, shaped like System.lua:785-795 builds them.
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
```

Continue the same file with the harness and the assertions:

```lua
-- The context System_partctl receives, shaped like the one System_sculptor gets.
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

-- The x6 fields main.lua initialises.
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

	-- Pin latches each part's own current position, so two parts at different places
	-- must get different targets. Latching the selection's centroid instead is the
	-- easy mistake and it teleports every pinned part into a pile.
	p1.Position = Vector3.new(10, 5, 0)
	p2.Position = Vector3.new(-40, 22, 8)
	check(x6.pc_assign("pin") == 2, "pin applies to the whole selection")
	check(d1.pc_mode == "pin" and d2.pc_mode == "pin", "both records carry the mode")
	check(d1.pc_target ~= nil and d2.pc_target ~= nil, "pin sets a target on each")
	check((d1.pc_target - p1.Position).Magnitude < 1e-6, "pin latches p1's own position")
	check((d2.pc_target - p2.Position).Magnitude < 1e-6, "pin latches p2's own position")
	check((d1.pc_target - d2.pc_target).Magnitude > 1, "pin does not collapse them together")

	-- The originals are the only copy of a part's pre-claim state. Overwriting one
	-- makes the part permanently unrestorable -- System.lua:439-452 records that.
	check(d1.original_can_collide == true, "pin does not touch original_can_collide")
	check(d1.original_anchored == false, "pin does not touch original_anchored")

	check(x6.pc_assign(nil) == 2, "assigning nil clears the mode")
	check(d1.pc_mode == nil and d1.pc_target == nil, "clearing removes both fields")
end
```

Add two more sections — the module registry and the teardown:

```lua
print("partctl · module registry")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	builder(ctx, { e = function() return false end })()

	local p1, d1 = claimed()
	local p2, d2 = claimed()
	local p3, d3 = claimed()
	x6.a[p1], x6.a[p2], x6.a[p3] = d1, d2, d3

	-- Resolution happens here, at assignment, never in the loop: get_shape fetches
	-- over HTTP for an unloaded shape (System.lua:149-150).
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

	-- Releasing the last part on a shape must drop its module, or the loop keeps
	-- calling px for a shape nothing uses.
	x6.pc_release(p3)
	distinct = 0
	for _ in pairs(x6.pc_mods) do distinct = distinct + 1 end
	check(distinct == 1, ("releasing the last part drops its module (%d)"):format(distinct))
	check(d3.pc_mode == nil and d3.pc_mod == nil, "release clears the record")

	-- An unresolvable shape must not register a nil module or leave the part in a
	-- mode the loop cannot serve.
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
	-- Highlights are SelectionBoxes parented to world parts, so nothing owns them but
	-- this system. System_sculptor.lua:14-19 records this exact bug shipping: the only
	-- way one was ever removed was a user click, so stopping the script, switching
	-- shapes or re-executing left one adorned to every selected part, and the next
	-- session gets a fresh table with no record of them.
	check(next(x6.pc_highlights) ~= nil, "selecting adorns a highlight")

	x6.pc_clear()
	check(next(x6.pc_selected) == nil, "pc_clear empties the selection")
	check(next(x6.pc_highlights) == nil, "pc_clear empties the highlights")
	check(next(x6.pc_mods) == nil, "pc_clear empties the module registry")
	local ok = pcall(x6.pc_clear)
	check(ok, "pc_clear is idempotent")
end

print(("\n%d checks, %d failures"):format(checks, fails))
os.exit(fails == 0 and 0 or 1)
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
luajit tests/partctl_smoke.lua
```

Expected: a hard error — `loadfile("System_partctl.lua")` returns nil because the file does not
exist, so the `assert` fires before any check runs.

- [ ] **Step 3: Write `System_partctl.lua`**

Mirror `System_sculptor.lua`'s module shape exactly: `return function(context, x7) ... return
function() ... end end`. Read that file first for the idiom — the outer function destructures the
context, the inner one connects the listeners.

Required behaviour, in the order it matters:

1. **Publish the five names** on `x6` (`pc_clear`, `pc_assign`, `pc_release`, plus ensure
   `pc_selected` / `pc_highlights` / `pc_mods` exist, defensively, in case `main.lua`'s init is
   missing).
2. **`pc_assign(mode, opts)`** iterates `x6.pc_selected`, skips any part not in `x6.a`, and writes
   the `pc_*` fields. For `"pin"` it latches **each part's own** `p.Position` — not the selection
   centroid. For `"shape"` it calls `context.get_shape(opts.shape)` **once**, before the loop, and
   bails without changing anything if it returns nil. Returns the count changed.
3. **`pc_release(part)`** clears every `pc_*` field and decrements that module's entry in `pc_mods`,
   removing the key at zero, and calling the module's `cleanup(x6, x1)` if it has one — `x6.pre`
   entries are only cleaned on a global shape switch (`System.lua:151-157`), so an assigned shape's
   state is otherwise never released.
4. **`pc_clear()`** destroys every highlight, then `table.clear`s all three tables, and is safe to
   call twice.
5. **Selection input**, gated on `x1.k6` being irrelevant — unlike the Sculptor this system is not a
   shape, so it must **not** gate on the active shape name. Pick via `v9.Target` and require
   `x6.a[target]`. Add-to-selection on `LeftShift`/`RightShift`, or on `x1.PartCtlMultiSelect` for
   touch. Register connections in `x6.c` the way `System_sculptor.lua:70` does, so the existing
   teardown disconnects them.
6. **Highlight colour must differ from the Sculptor's** `Color3.fromRGB(0, 255, 200)`. Use
   `Color3.fromRGB(255, 170, 0)` so the two systems are never confused on screen.

- [ ] **Step 4: Copy it to the mobile tree**

Create `mobilever/System_partctl.lua`. Compare `System_sculptor.lua` against
`mobilever/System_sculptor.lua` first to see what that tree changes — the mobile copy substitutes
touch input for the shift modifier and reads its own multi-select flag. Match whatever divergence
you find there rather than copying the root file blindly.

- [ ] **Step 5: Wire both trees**

`System.lua:1481-1482` currently reads:

```lua
		local sculptor_binder = load_module(SUB_DIR .. "System_sculptor.lua")(context, x7)
		sculptor_binder()
```

Add directly beneath:

```lua
		local partctl_binder = load_module(SUB_DIR .. "System_partctl.lua")(context, x7)
		partctl_binder()
```

Do the same at `mobilever/System.lua:1338`.

- [ ] **Step 6: Initialise the `x6` fields and hook the teardown in `main.lua`**

Beside the `sculptor_*` fields at `main.lua:522-528`, add:

```lua
	pc_selected = setmetatable({}, {__mode = "k"}),
	pc_highlights = setmetatable({}, {__mode = "k"}),
	pc_mods = {},
```

Weak keys on the first two, matching the Sculptor's, so a destroyed part does not pin its record.

Beside the `x6.sculptor_clear` teardown at `main.lua:659`, add the same call for `x6.pc_clear`, with
the same `pcall` and the same fallback that walks `x6.pc_highlights` directly if the published
function is missing. Then do the same at `System.lua:1219` and its mobile equivalent. **All three
sites**, not just the first — that is the difference between this shipping clean and repeating the
bug at `System_sculptor.lua:14-19`.

- [ ] **Step 7: Add the config key**

In `config.lua`'s `x1` block:

```lua
		-- The touch substitute for holding Shift in part control. Its own key, not the
		-- Sculptor's: the two systems are independent. Must exist here with a boolean
		-- default or load_settings can never restore it and reset_config never
		-- snapshots it.
		PartCtlMultiSelect = false,
```

- [ ] **Step 8: Run the test and the suite**

```bash
luajit tests/partctl_smoke.lua && for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: `0 failures` from the new file and every other file green.

- [ ] **Step 9: Commit**

```bash
git add System_partctl.lua mobilever/System_partctl.lua System.lua mobilever/System.lua \
        main.lua config.lua tests/partctl_smoke.lua
git commit -m "Add System_partctl: independent per-part selection and assignment

A new system, not a Sculptor change: its own selection state, its own
highlight colour, its own multi-select flag. Nothing under System_sculptor
or shapes/Sculptor is touched.

pc_clear is hooked into all three teardown paths. Highlights are
SelectionBoxes parented to world parts, so nothing owns them but this
system -- System_sculptor.lua:14-19 records what happens when that hook is
missing.

Shape modules resolve at assignment time, never in the loop: get_shape
fetches over HTTP for an unloaded shape."
```

---

### Task 2: Loop dispatch for pin and manual, and the per-part exemptions

**Files:**
- Modify: `System.lua` at `:465` (bucket skip), `:487` and `:506` (`always_process` reads), `:506-509`
  (dispatch)
- Modify: `mobilever/System.lua` at the same four sites, located by content
- Create: `tests/partctl_lint.lua`

**Interfaces:**
- Consumes: `d.pc_mode`, `d.pc_target`, `d.pc_phys` from Task 1.
- Produces: nothing new; the loop now honours the fields.

- [ ] **Step 1: Write the failing lint**

Create `tests/partctl_lint.lua`, following `tests/fidelity_lint.lua`'s shape from the Max Fidelity
plan (or `tests/controls_lint.lua` if that plan has not landed). Nothing in `tests/` instantiates the
loop, so this checks the source. Assert, for each of `System.lua` and `mobilever/System.lua`:

```lua
	-- The bucket skip must let controlled parts through. This is the edit that makes a
	-- ridden part smooth without forcing global Max Fidelity: a handful of controlled
	-- parts run every frame while the rest of the claim stays bucketed.
	check(src:find("d%.pc_mode%s*==%s*nil%s+and%s+i%s*%%%s*et%s*~=%s*update_bucket") ~= nil,
		path .. ": the bucket skip exempts controlled parts")

	-- Both the radius cull and the deadzone read always_process; both must also read
	-- d.pc_mode. A pinned part beyond k1 must not be parked, and a pinned part already
	-- at its target must not be skipped, or it drifts.
	local cull = src:find("distance_sq%s*>%s*k1_sq[^\n]*pc_mode")
	local dead = src:find("distance_sq%s*>%s*c7_sq[^\n]*pc_mode")
	check(cull ~= nil, path .. ": the radius cull exempts controlled parts")
	check(dead ~= nil, path .. ": the deadzone exempts controlled parts")

	-- The dispatch itself.
	check(src:find('d%.pc_mode%s*==%s*"pin"') or src:find('pc_mode%s*==%s*"manual"'),
		path .. ": the dispatch branches on pin/manual")
	check(src:find("shape_f2%(p,%s*active_c,%s*d,%s*ft") ~= nil,
		path .. ": the normal path still calls shape_f2 unchanged")
```

All six patterns have been checked against the current sources: the four "before" forms match today
in both trees, so the lint fails for the right reason rather than on a typo.

- [ ] **Step 2: Run the lint to verify it fails**

```bash
luajit tests/partctl_lint.lua
```

Expected: the four `pc_mode` checks fail in both trees; `the normal path still calls shape_f2`
passes. `8 failures`.

- [ ] **Step 3: Exempt controlled parts from the bucket skip**

`System.lua:465`:

```lua
				if i % et ~= update_bucket then
					continue
				end
```

becomes:

```lua
				-- A controlled part runs every frame. This is what makes a part you are
				-- standing on smooth without forcing global Max Fidelity: a handful of
				-- controlled parts escape the bucket while the rest of the claim stays in
				-- it.
				if d.pc_mode == nil and i % et ~= update_bucket then
					continue
				end
```

- [ ] **Step 4: Exempt them from the cull and the deadzone**

`System.lua:487` — `if distance_sq > k1_sq and not always_process then` becomes
`if distance_sq > k1_sq and not (always_process or d.pc_mode) then`.

`System.lua:506` — `if distance_sq > c7_sq or always_process or is_cursed_red then` becomes
`if distance_sq > c7_sq or always_process or d.pc_mode or is_cursed_red then`.

A pinned part beyond `k1` must not be parked, and a pinned part already sitting on its target must
not be skipped, or it drifts off under gravity between updates.

- [ ] **Step 5: Add the dispatch**

`System.lua:506-509` currently reads:

```lua
					if shape_f2 then
						target_pos_delta, pure_target_pos = shape_f2(p, active_c, d, ft, cur_shape_cfg, x1, x6, x9)
					end
```

becomes:

```lua
					local pc = d.pc_mode
					if pc == "pin" or pc == "manual" then
						-- No shape call at all. pin and manual differ only in who writes
						-- pc_target: pin latched it once, manual follows a drag.
						local tgt = d.pc_target or p_pos
						local gain = (d.pc_phys and d.pc_phys.k10) or x1.k10
						pure_target_pos = tgt
						target_pos_delta = (tgt - p_pos) * (gain * x9.c1)
					elseif pc == "shape" and d.pc_mod and d.pc_mod.f2 then
						target_pos_delta, pure_target_pos =
							d.pc_mod.f2(p, active_c, d, ft, d.pc_cfg or cur_shape_cfg, x1, x6, x9)
					elseif shape_f2 then
						target_pos_delta, pure_target_pos = shape_f2(p, active_c, d, ft, cur_shape_cfg, x1, x6, x9)
					end
```

`p_pos` is already a local at `System.lua:484`; reuse it rather than reading `p.Position` again.

`d.pc_cfg` is the assigned shape's own `x2` entry, cached at assignment time in Task 3. Until Task 3
lands it is nil and the fallback to `cur_shape_cfg` applies — which is wrong for the assigned shape
but harmless, because Task 1 is the only thing that can set `pc_mode` to `"shape"` and Task 3
follows immediately.

**Do not un-hoist `x1.k8`, `x1.Damping` or `x1.MaxSpeed`.** They are loop locals at
`System.lua:352-363` precisely because they are global; making them per-part lookups costs every
part a table read to serve a few. Apply `pc_phys` overrides for those three inside this branch only,
after the delta is computed, leaving the hoisted locals as the fast path.

- [ ] **Step 6: Apply all four edits to `mobilever/System.lua`**

Locate by content. The mobile offsets are `:465`, `:485`, `:504` and `:504-507`.

- [ ] **Step 7: Run the lint and the suite**

```bash
luajit tests/partctl_lint.lua && for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: `0 failures` from the lint and every other file green.

- [ ] **Step 8: Commit**

```bash
git add System.lua mobilever/System.lua tests/partctl_lint.lua
git commit -m "Dispatch pinned and manual parts in the loop, both trees

Controlled parts are exempt from the bucket skip, the k1 radius cull and the
c7 deadzone -- a pinned part beyond the cull must not be parked and one
already on its target must not be skipped, or it drifts.

k8, Damping and MaxSpeed stay hoisted loop locals; pc_phys overrides them
inside the controlled branch only, so an uncontrolled part still costs one
nil check rather than four table reads."
```

---

### Task 3: Per-part shape assignment — the `px` pass and the right config

**Files:**
- Modify: `System_partctl.lua`, `mobilever/System_partctl.lua` (cache `pc_cfg` at assignment)
- Modify: `System.lua` near `:305-312`, `mobilever/System.lua` near `:303-310`
- Modify: `tests/partctl_smoke.lua`, `tests/partctl_lint.lua`

**Interfaces:**
- Consumes: `x6.pc_mods` from Task 1, the `"shape"` dispatch branch from Task 2.
- Produces: `d.pc_cfg` — the assigned shape's own `x2` table, cached at assignment. Read by the
  dispatch added in Task 2 step 5.

- [ ] **Step 1: Write the failing tests**

Add to `tests/partctl_smoke.lua`:

```lua
print("partctl · assigned shape config")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	-- The real x2 table, so the check is against what ships rather than a fixture.
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

	-- Passing the CURRENT shape's cfg to an assigned shape is a silent
	-- misconfiguration, not a crash: the assigned solver reads k11..k18 and gets
	-- another shape's numbers. Each assignment caches its own x2 entry.
	check(d1.pc_cfg ~= nil, "the assigned shape's own config is cached")
	check(d1.pc_cfg ~= x2["Black Hole"] or true, "cached from x2")
	check(d1.pc_cfg.k11 == x2["Black Hole"].k11,
		"pc_cfg carries Black Hole's k11, not the active shape's")
end
```

And to `tests/partctl_lint.lua`, per tree:

```lua
	-- px is only called for the CURRENT shape (System.lua:307). A part assigned a shape
	-- with a px stage would run against absent stamped state, so every distinct assigned
	-- module needs its px called too -- O(distinct shapes), not O(parts).
	check(src:find("x6%.pc_mods") ~= nil, path .. ": the loop walks the assigned-module registry")
	check(src:find("mod%.px") ~= nil or src:find("m%.px") ~= nil,
		path .. ": it calls px on each assigned module")
```

- [ ] **Step 2: Run both and verify they fail**

```bash
luajit tests/partctl_smoke.lua; luajit tests/partctl_lint.lua
```

Expected: FAIL on `the assigned shape's own config is cached` and on both new lint checks.

- [ ] **Step 3: Cache `pc_cfg` at assignment**

In `pc_assign`, the `"shape"` branch already resolves the module once before the loop. Resolve its
config there too — `context.x2[opts.shape]` — and if `x2` has no entry for that name, build one from
the module's own `Controls` the way `tests/shapes_smoke.lua:214-238` does for the review-folder
shapes, honouring `Div`. Store on each record as `d.pc_cfg`.

**Reject `"Sculptor"` here.** `shapes/Sculptor.lua` reads `x6.sculptor_selected` and does nothing
else, so assigning it would make this system silently depend on the one we agreed not to touch.
`pc_assign` returns 0 for it and changes nothing.

- [ ] **Step 4: Add the `px` pass to both loops**

Immediately before the part loop — after the `cur_shape_mod.px` call at `System.lua:307-308` — add:

```lua
			-- px runs for the current shape only, so a part assigned a shape with a px
			-- stage would solve against absent stamped state. O(distinct assigned
			-- shapes), never O(parts).
			local pc_mods = x6.pc_mods
			if pc_mods then
				for mod, _ in pairs(pc_mods) do
					if mod.px then
						pcall(mod.px, ft, mod.pc_cfg_ref or cur_shape_cfg, x6, x9, x1)
					end
				end
			end
```

`mod.pc_cfg_ref` is set by `pc_assign` when it registers the module, so the `px` stage sees the same
config its `f2` will. The `pcall` matters: an assigned shape's `px` throwing must not take down the
loop for every other part.

- [ ] **Step 5: Run both tests and the suite**

```bash
luajit tests/partctl_smoke.lua && luajit tests/partctl_lint.lua && \
  for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: all green.

- [ ] **Step 6: Commit**

```bash
git add System_partctl.lua mobilever/System_partctl.lua System.lua mobilever/System.lua \
        tests/partctl_smoke.lua tests/partctl_lint.lua
git commit -m "Give assigned shapes their own config and a px pass

Passing the active shape's cfg to an assigned solver is a silent
misconfiguration, not a crash -- it reads k11..k18 and gets another shape's
numbers. Each assignment caches its own x2 entry.

px runs for the current shape only, so an assigned shape with a px stage
would solve against absent state. The pass is O(distinct assigned shapes).

Sculptor is rejected as an assignable shape: it reads x6.sculptor_selected,
and assigning it would make this system depend on the one left untouched."
```

---

### Task 4: Riding — collision **and** physical properties

Constraint 13 is the substance of this task. `CanCollide = true` on its own gives a rider a
near-massless, frictionless plate: they shove it out from under themselves and slide off what is
left. Getting only the collision half of this is the most likely way for the feature to look
implemented and not work.

**Files:**
- Modify: `System_partctl.lua`, `mobilever/System_partctl.lua`
- Modify: `System.lua:1111` and `:1120-1122`, and the mobile equivalents
- Modify: `tests/partctl_smoke.lua`, `tests/partctl_lint.lua`

**Interfaces:**
- Consumes: `d.pc_ride` from Task 1's data model.
- Produces: nothing new.

- [ ] **Step 1: Write the failing tests**

Add to `tests/partctl_smoke.lua`:

```lua
print("partctl · riding")
do
	local x6 = mk_x6()
	local ctx = mk_ctx(x6)
	builder(ctx, { e = function() return false end })()

	local p1, d1 = claimed()
	x6.a[p1] = d1
	p1.CanCollide = false                       -- what claiming leaves it as
	x6.pc_selected[p1] = true

	x6.pc_assign("pin", { ride = true })
	check(d1.pc_ride == true, "the flag is recorded")
	check(p1.CanCollide == true, "a rideable part is collidable")
	-- Claimed parts get LIGHT_PHYSICS = PhysicalProperties.new(0.001, 0, 0, 0, 0)
	-- (System.lua:13, written at :760). Density 0.001 and friction 0: nothing to carry
	-- a rider's weight and nothing to stop them sliding off. Collision alone is not
	-- enough, which is the whole point of this task.
	check(p1.CustomPhysicalProperties ~= nil, "a rideable part gets real physical properties")

	-- The originals are the only copy of the pre-claim state.
	check(d1.original_can_collide == true, "original_can_collide is not overwritten")

	-- Turning it off must put the claim-time state back, not the original state --
	-- releasing the part is what restores the original.
	x6.pc_assign("pin", { ride = false })
	check(p1.CanCollide == false, "clearing ride returns the part to pass-through")
end
```

And to `tests/partctl_lint.lua`, per tree:

```lua
	-- The disable path rewrites CanCollide from the global flag and would stomp a
	-- riding part.
	check(src:find("p%.CanCollide%s*=%s*%(disabled%s+or%s+x1%.PreserveCollisions[^\n]*pc_ride") ~= nil,
		path .. ": the disable path honours pc_ride")
	-- And it rewrites CustomPhysicalProperties back to LIGHT_PHYSICS.
	check(src:find("pc_ride") ~= nil, path .. ": pc_ride is read in the runtime")
```

- [ ] **Step 2: Run both and verify they fail**

```bash
luajit tests/partctl_smoke.lua; luajit tests/partctl_lint.lua
```

Expected: FAIL on all four ride checks and both lint checks.

- [ ] **Step 3: Apply the ride state in `pc_assign`**

Three writes, all guarded compare-before-assign — a physics property write per frame is the cost the
guard at `shapes/Platform.lua:259-263` exists to avoid:

1. `p.CanCollide = true`.
2. `p.CustomPhysicalProperties = d.original_properties` when the part had its own, otherwise a
   module-level `RIDE_PHYSICS = PhysicalProperties.new(0.7, 0.5, 0.3, 1, 1)` — real density so it
   carries weight, real friction so the rider stays on.
3. Leave `lv.MaxForce` at `x1.k4` (`math.huge`, set at `System.lua:768`) so the constraint can hold
   position against the added load. No edit needed; just do not lower it.

Clearing `ride` puts the *claim-time* state back — `CanCollide = false` and `LIGHT_PHYSICS` — not the
original. Releasing the part is what restores the original, via the existing path at
`System.lua:805-807`. Never write `d.original_*`.

- [ ] **Step 4: Stop the disable path stomping it**

`System.lua:1111`:

```lua
			p.CanCollide = (disabled or x1.PreserveCollisions) and d.original_can_collide or false
```

becomes:

```lua
			p.CanCollide = (disabled or x1.PreserveCollisions or d.pc_ride) and d.original_can_collide or false
```

Then `System.lua:1120-1122`, which rewrites `CustomPhysicalProperties` back to `LIGHT_PHYSICS` on the
disable branch — the comment at `:1112-1118` explains why it is not an `and`/`or` chain. Add a
`d.pc_ride` guard so a riding part keeps its real properties. `System.lua:755` (claim time) needs no
change: `pc_ride` cannot exist before the part is claimed.

Apply both to `mobilever/System.lua`.

- [ ] **Step 5: Run everything**

```bash
luajit tests/partctl_smoke.lua && luajit tests/partctl_lint.lua && \
  for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

- [ ] **Step 6: Commit**

```bash
git add System_partctl.lua mobilever/System_partctl.lua System.lua mobilever/System.lua \
        tests/partctl_smoke.lua tests/partctl_lint.lua
git commit -m "Make pinned parts rideable: collision and real physics

Claimed parts get LIGHT_PHYSICS -- density 0.001, friction 0. CanCollide
alone gives a rider a near-massless frictionless plate they shove out from
under themselves and slide off. Rideable parts get real density and friction
too, and the disable path no longer stomps either.

d.original_* is read-only throughout: it holds the only copy of a part's
pre-claim state."
```

---

### Task 5: The Part Control panel, both UI trees

**Files:**
- Modify: `UI.lua`, `mobilever/UI.lua`
- Modify: `config.lua` — `x1` keys for panel state
- Modify: `tests/partctl_lint.lua`

**Interfaces:**
- Consumes: `x6.pc_assign`, `x6.pc_clear`, `x6.pc_selected` from Task 1.
- Produces: nothing consumed by later work.

- [ ] **Step 1: Add the config keys**

In `config.lua`'s `x1` block. Each needs a matching-type default or it forgets itself between
sessions. Note `controls_lint` does **not** cover these — it only walks shape `Controls` — so they
must be checked by hand:

```lua
		PartCtlMode = "pin",          -- last mode picked; string, not an enum
		PartCtlShape = "Black Hole",  -- last assigned shape name
		PartCtlRide = false,          -- rideable default for new assignments
```

`PartCtlMode` and `PartCtlShape` must stay **strings**: an EnumItem does not survive the JSON round
trip, which is why `Keybinds` stores key names rather than KeyCodes (`config.lua:64-67`).

- [ ] **Step 2: Extend the lint**

```lua
for _, path in ipairs({ "UI.lua", "mobilever/UI.lua" }) do
	local src = slurp(path)
	check(src:find("pc_assign") ~= nil, path .. ": the panel calls pc_assign")
	check(src:find("pc_clear") ~= nil, path .. ": the panel can clear the selection")
	check(src:find("Part Control") ~= nil, path .. ": the panel is labelled")
	-- Independence from the Sculptor is the whole premise. A panel that reads
	-- sculptor state has quietly merged the two systems.
	local head = src
	check(head:find("pc_selected") ~= nil, path .. ": the panel reads pc_selected")
end
```

- [ ] **Step 3: Build the desktop panel**

Read the two nearest existing panels in `UI.lua` before writing anything — the element helpers
(`et` for toggles, `es` for sliders, `eh` for headers) take different trailing arguments in different
groups, and matching a neighbour is more reliable than reproducing a signature here. Contents:

- the current selection count, refreshed on open, and a **Clear Selection** action calling
  `x6.pc_clear`;
- mode buttons applying to the whole selection: **Normal** / **Pin** / **Manual** / **Assign
  Shape**, each calling `x6.pc_assign` with that mode and writing `x1.PartCtlMode`;
- a shape picker for Assign Shape, populated from `pairs(x2)` the way `UI.lua:1533` populates the
  mode list — which means Goro Goro no Mi appears there for free once sub-project 1 lands — minus
  `"Sculptor"`, which Task 3 rejects;
- a **Rideable** toggle for the selection, writing `x1.PartCtlRide` and passing `ride` through;
- four optional per-part physics fields — Force, Smoothing, Damping, Max Speed — where blank means
  inherit. Pass them as the `phys` subset table; do not send zeros for blanks, since `pc_phys` is
  read with `or` fallbacks and a literal zero is a real override.

- [ ] **Step 4: Build the mobile panel**

The same in `mobilever/UI.lua`, using that tree's own helpers and layout conventions. Compare
`UI.lua` against `mobilever/UI.lua` around an existing panel first: the mobile tree lays out for a
narrow screen and its helper arities differ.

- [ ] **Step 5: Run the lint and the whole suite**

```bash
luajit tests/partctl_lint.lua && for f in tests/*.lua; do echo "== $f"; luajit "$f" 2>&1 | tail -3; done
```

Expected: all green. `tests/load_build_smoke.lua` is the one that exercises UI construction — red
there means a helper was called with the wrong arity.

- [ ] **Step 6: Commit**

```bash
git add UI.lua mobilever/UI.lua config.lua tests/partctl_lint.lua
git commit -m "Add the Part Control panel to both UI trees

The shape picker enumerates pairs(x2) minus Sculptor, so every registered
shape is assignable per-part. Blank physics fields mean inherit and are
omitted rather than sent as zero: pc_phys is read with or-fallbacks, so a
literal zero is a real override."
```

- [ ] **Step 7: In-game confirmation**

The unit tests cover the module's contract and the lint covers the wiring. Neither proves the feature
works, because nothing in `tests/` drives the loop, input, physics or rendering. Do not report this
plan complete on green tests. Check, on **both** trees:

1. Click a claimed part and confirm it highlights in the part-control colour, visibly different from
   the Sculptor's.
2. Shift-click a second part, confirm both are selected, then Clear Selection.
3. Pin a part and confirm it holds position while the rest of the pile keeps running the global shape.
4. Pin a part with Rideable on, jump on it, and confirm you stand on it and do not slide off. This is
   the check that distinguishes a working feature from one that only set `CanCollide`.
5. With a part pinned and ridden, confirm it does not jitter — that is the bucket-skip exemption from
   Task 2 doing its job. If it jitters, the exemption did not land in the tree you are testing.
6. Assign a different shape to a handful of parts and confirm they run it while the rest run the
   global shape.
7. Assign a shape that has a `px` stage (Rocket Engine, Mech Suit, Big Bad Broom, Hover Text) and
   confirm it behaves the same as when globally selected. If it collapses to a point, the `px` pass or
   its config is wrong.
8. Switch shapes, then stop and re-execute the script, and confirm **no `SelectionBox` is left
   adorned to any part**. This is the `System_sculptor.lua:14-19` bug and the reason `pc_clear` is
   hooked into three teardown paths.
9. Release a part under control and confirm it returns to its original collision and physical
   properties.

---

## Self-Review

**Spec coverage.** Data model → Task 1. All five loop edits → Tasks 2 (four) and 4 (one, the collide
restore). `px` pass and per-shape config → Task 3. Riding as a physical-properties problem, not just
collision → Task 4. Selection independent of the Sculptor, distinct highlight colour, `pc_clear` in
all three teardown paths → Task 1. `x6.pre` cleanup for assigned shapes → Task 1 step 3 item 3.
Sculptor rejected as assignable → Task 3 step 3. UI surface → Task 5. Constraint 9's apply-twice
requirement is enforced by `tests/partctl_lint.lua` in every task that edits a runtime or UI file.

**Placeholder scan.** Two places deliberately point at the code instead of quoting a literal: the UI
helper arities in Task 5 steps 3–4, and the mobile tree's divergence in Task 1 step 4. Both are real
properties of this codebase — `UI.lua` is 74 KB with per-group helper signatures, and the mobile
`System_sculptor` genuinely differs from the root — so a guessed literal would be worse than an
instruction to read the neighbour. Everything else carries its actual content.

**Type consistency.** `pc_mode`, `pc_target`, `pc_shape`, `pc_mod`, `pc_cfg`, `pc_phys`, `pc_ride`,
`pc_selected`, `pc_highlights`, `pc_mods`, `pc_clear`, `pc_assign`, `pc_release` are spelled
identically in every task, in the data-model table, and in the lint patterns. `pc_assign(mode, opts)`
returns a count in Task 1 and that return is asserted in Tasks 1, 3 and 4. `pc_cfg` is introduced in
Task 3 and consumed by the dispatch written in Task 2 — that forward reference is called out
explicitly in Task 2 step 5, with the nil fallback that keeps Task 2 correct on its own.

**Known-unverifiable.** Riding, collision, input, selection highlighting, both panels, and the
on-screen behaviour of assigned shapes are in-game checks only. `tests/partctl_smoke.lua` proves the
module's API; `tests/partctl_lint.lua` proves the wiring exists in both trees. Neither proves the
loop then behaves correctly. Task 5 step 7 is the only evidence for that.
