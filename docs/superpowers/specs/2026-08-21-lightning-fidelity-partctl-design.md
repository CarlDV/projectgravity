# Lightning Shape, Max Fidelity, and Per-Part Control

**Date:** 2026-08-21
**Status:** Approved, pending implementation

## Origin

Opened with a Roblox Studio capture of a jagged glowing bolt fired from the caster to the
cursor hit point, asking whether the same thing could be built out of claimed parts —
"basically the beam but like Enel from One Piece". Clarified twice during design, and both
clarifications narrow the work:

- **"no effect just pure unanchored part"** — no `Beam`, no `ParticleEmitter`, no `Trail`. The
  bolt is claimed parts standing in a jagged line. This is a `shapes/` module and nothing else.
- **"this is not a sculptor expansion. we will not be touching it. instead, we will create a
  new independent system"** — `System_sculptor.lua` and `shapes/Sculptor.lua` are out of
  bounds. Per-part control is a new sibling module.

Two further asks arrived with the second clarification: a switch that gives up the script's own
performance shortcuts, and per-part control whose stated purpose is "you can move a single
object then let people ride on it or sum". The overall direction is "extremely customizable as
it gets for unanchored parts".

## Scope

Three sub-projects, independent, in this order. Each ships alone.

| # | Sub-project | Touches | Why here |
|---|---|---|---|
| 1 | **Goro Goro no Mi** — the lightning shape | one new `shapes/` file, one `x2` block | No shared code. Cannot break anything that exists. |
| 2 | **Max Fidelity** — drop the shortcuts | 5 guards in each `System.lua`, both UIs, `x1` | Small, and 3 needs it to be testable. |
| 3 | **Per-part control** — new independent system | new `System_partctl.lua` per tree, loop dispatch, both UIs | Largest. Wants 2 in place. |

**Why 2 before 3.** The part-count frame skipper is what would make a part you are standing on
jitter. Sub-project 3 carries its own per-part exemption from it, but bringing up a riding
feature while the global skipper is still shearing everything else makes it impossible to tell
a bug in the new code from the skipper doing its job. Land the honest switch first.

The naming follows the existing One Piece shapes — `Light Light no Mi`, `Mochi Mochi no Mi`,
`ROOM Ope Ope no Mi`. Enel's fruit is the Goro Goro no Mi.

## Engine constraints

Constraints 1–4 are in `2026-08-08-shape-modes-design.md` and 5–8 in
`2026-08-09-six-shapes-design.md`. All eight still hold. Each was re-checked against the
current tree while writing this; line numbers below are current.

Six more govern the work here.

**9. `mobilever/` is a near-verbatim second copy of the runtime.** `mobilever/System.lua` is
46 KB against the root's 50 KB and carries the same guards within two lines of the same
offsets: the part-count ladder at `mobilever/System.lua:219` vs `System.lua:221`,
`always_process` at `:411` vs `:413`, the bucket skip at `:465` vs `:465`, the radius cull at
`:485` vs `:487`, the deadzone at `:504` vs `:506`. `mobilever/System_sculptor.lua` likewise
mirrors the root module. **Every loop or wiring change in sub-projects 2 and 3 lands twice.**
A change applied to one tree only is a mobile-only or desktop-only bug that no test here
catches. Sub-project 1 is exempt: `shapes/` is shared by both trees.

**10. The script's own shortcuts are five, and none of them are the `Perf_*` flags.** The four
`Perf_*` keys reach `ApplyPerfShadows` / `PostFX` / `Materials` / `Particles` (`UI.lua:611-614`)
and change the *game's* rendering. The script's own gives-up-accuracy-for-speed behaviour is:

1. **Part-count ladder** (`System.lua:221`) — `dt` becomes 3 over 1000 claimed parts, 6 over
   2500, 10 over 5000. `dt` multiplies into `dt_mult` (`:356`) and the angular damping rate
   (`:369`), so it is a coarse compensation for updating less often.
2. **Bucket skip** (`System.lua:465`) — `i % et ~= update_bucket` runs each part on one frame
   in `et`, where `et = x1.k7` (default 4). At the default a part's shape math runs at ~15 Hz.
3. **Radius cull** (`System.lua:487`) — a part farther than `x1.k1` (2000 studs) from its
   centre is parked once and skipped. The comment there records why parking rather than plain
   skipping: a skipped part keeps its old `VectorVelocity` under `MaxForce = k4`, so it coasts
   outward forever and the same test culls it before the shape can ever pull it back.
4. **Deadzone** (`System.lua:506`) — a part already within `x9.c7` of its centre skips the
   shape call entirely.
5. **Velocity smoothing** (`System.lua:358-363`) — `x1.k8` (0.8) exponential blend toward the
   new target, converted to a frame-rate-independent `sm_alpha`.

`x1["Force Smooth (Lags)"]` (`System.lua:226-230`, `:363`) already pins 1 and 2 to 1 and forces
`sm_alpha = 1`. It does not touch 3 or 4. Sub-project 2 is that toggle finished, not a new
mechanism.

**11. `always_process` already exists as the cull-and-deadzone bypass.** `System.lua:413`
computes it once per frame from the shape identity (`is_drop_shape or is_self_bounded_shape`)
and it is read at `:487` and `:506`. Both sub-projects 2 and 3 widen this existing flag rather
than adding a parallel one, so they exercise a path that already ships.

**12. `d` is the per-part record and already carries a stable unique id.** `x6.a[p]` is built
at `System.lua:785-795` with `id = x6.part_id_counter`, a monotonic counter, plus the three
constraint instances and the three `original_*` restore fields. It is the correct home for
per-part overrides, and it is freed with the part at `:456` (`data[p] = nil`), so anything hung
on it cannot leak.

**13. Claimed parts are made near-massless and frictionless.**
`LIGHT_PHYSICS = PhysicalProperties.new(0.001, 0, 0, 0, 0)` (`System.lua:13`) is written at
claim (`:760`) and re-written on the disable path (`:1122`). Density 0.001 and friction 0. A
player cannot meaningfully stand on that: there is nothing to hold their weight and nothing to
stop them sliding off. **Riding is not a collision problem alone — it is a physical-properties
problem.** See sub-project 3.

**14. `get_shape` can block on HTTP.** `main.lua:454-500` fetches an unloaded shape over the
network and only then caches it in `loaded_shapes`. `System.lua:149-150` records the hazard in
so many words. It is exposed to the runtime as `context.get_shape` (`System.lua:5`), so
per-part shape assignment is possible, but resolution must happen **at assignment time, never
inside the part loop**.

---

# Sub-project 1 — Goro Goro no Mi

One new file, `shapes/Goro Goro no Mi.lua`, and one `x2` block. Nothing else in the repo
changes.

## What it is

A jagged polyline from `cen` to an aim point, with forked branches, that re-rolls its shape
several times a second. Parts are distributed along that polyline by arc length. Per constraint
1 the parts are never oriented, so this is a chain of bricks tracing a bolt, not a stroke —
`Hover Text` is the precedent that this reads correctly anyway.

## The agreement problem

`f2` is called once per part, independently. Every part must derive **the same** bolt or the
formation tears apart. Two consequences drive the whole design:

- **No `math.random` anywhere in the path math.** Each call would advance the shared generator
  and every part would sit on a different bolt. The jitter comes from a pure hash of
  `(seed, node, channel)` — same inputs, same output, no state.
- **The seed may only change on a bucket boundary.** This is constraint 2. With `et = 4` the
  parts are spread across four frames; a seed that advanced mid-cycle would leave a quarter of
  the parts on bolt *k* and the rest on bolt *k+1*, which reads as the bolt ripping in half
  rather than flickering. The seed advances only when the bucket generation advances.

## Stamped state

**No `M.px` stage.** The other rigid formations stamp their basis in `px`, but this one cannot:
constraint 5 says `px` never receives `cen`, and both ends of the bolt are anchored to it — node 0
*is* `cen`, and under constraint 6 `cen` is genuinely per-part. The stamping therefore happens
inside `f2`, guarded so only the first part of a generation does the work. This is deliberate and
should not be "corrected" to a `px` stage later.

Held in `x6.pre["Goro Goro no Mi"]`, following the `Twin Core Beam.lua:50` guard pattern
(`state.last_frame ~= x6.f`) but keyed on the generation rather than the frame:

```lua
local et  = math.max(1, math.floor(x1.k7 or 1))
local gen = math.floor((x6.f or 0) / et)

if st.last_gen ~= gen then
    st.last_gen = gen
    if t >= st.next_roll then
        st.seed     = st.seed + 1
        st.next_roll = t + (1 / flicker_hz)
    end
    st.aim = <resolve aim point>     -- stamped here too, same reason
end
```

The aim point is stamped in the same block. A cursor that moves between frames would otherwise
give each part a different endpoint, tearing the bolt exactly as a mid-cycle seed would.

Flicker is therefore **time-driven but generation-quantised**: it fires at the requested rate
when the rate is slower than the bucket cycle, and clamps to one roll per cycle when it is
faster. At `et = 4` and 60 fps that ceiling is ~15 Hz, which is already faster than the capture.

## The hash

```lua
local function h(seed, node, chan)
    local x = ((seed % 1048576) * 73856093 + node * 19349663 + chan * 83492791) % 16777216
    x = (x * x + x * 22695477 + 12345) % 16777216
    return x / 16777216
end
```

Returns `[0, 1)`. Two properties were measured on a throwaway prototype rather than assumed,
because both failure modes are silent:

**Precision.** LuaJIT and Luau both lose integer precision past 2^53, and a hash that degrades
there stops being deterministic across the two — the one property it exists for. Largest
intermediates here are `1048575 * 73856093` ≈ 7.7e13 in the first step and `x*x + x*22695477`
≈ 6.7e14 in the second, both far under 9.007e15. `seed` is masked to 2^20 so a long session
cannot drift into the unsafe range.

**The squaring term is load-bearing.** The obvious single LCG round —
`x = (x * 1103515245 + 12345) % M` — is *linear*, so it preserves the structure of its linear
input. Measured over 24000 samples it put channels 1 and 2 within 0.02 of each other **99.3%**
of the time, against 4% for a uniform pair. `a_j` and `b_j` would then be near-equal for every
node and the bolt would jitter along a single diagonal instead of filling the perpendicular
plane — a wrong-looking bolt with no error anywhere. Adding the `x*x` term drops that to 3.97%
and adjacent-node correlation to 3.95%, both at the uniform ideal. Do not "simplify" it back to
one linear round.

## Node path

```
dir = (aim - cen).Unit
L   = (aim - cen).Magnitude
u   = Vector3.new(-dir.Z, 0, dir.X).Unit        -- degenerate when dir is vertical
v   = dir:Cross(u).Unit
```

The degenerate case — `dir` near-vertical, so `u` has near-zero magnitude — falls back to
`Vector3.xAxis`. `Twin Core Beam.lua:125-130` already does exactly this check and is the
reference.

For `j = 0..N`:

```
s_j = (j / N) * L
w_j = sin(pi * j / N)                            -- 0 at both ends, 1 mid-span
a_j = A * w_j * (2 * h(seed, j, 1) - 1)
b_j = A * w_j * (2 * h(seed, j, 2) - 1)
P_j = cen + dir * s_j + u * a_j + v * b_j
```

`w_j` pins node 0 to `cen` and node `N` to the aim point with zero jitter, so the bolt visibly
starts at the caster and lands on the cursor rather than drifting off both ends. `A` is
Jaggedness in studs.

Cost is O(N) per part per frame, N ≤ 64. Recomputing per part rather than caching the array is
deliberate: caching would need an invalidation key covering `seed`, `cen`, `aim`, `N` and `A`,
and `cen` is genuinely per-part under constraint 6. Sixty-four sines is cheaper than getting
that wrong.

## Mapping a part onto the path

Constraint 3: ids are a sliding window, so `id % n` clumps and starves. Two Weyl channels:

```
f1 = ((d.id or 1) * 0.6180339887498949) % 1      -- position along path
f2 = ((d.id or 1) * 0.7548776662466927) % 1      -- branch pick / scatter
```

A part is a branch part when `f2 < branch_share` and at least one branch is configured.

**Main channel.** Walk `f1` into segment space and interpolate inside the segment, so parts fill
the spans between nodes instead of piling up on them:

```
q  = f1 * N
j  = math.floor(q)                               -- clamped to N-1
lp = q - j
pos = P_j + (P_(j+1) - P_j) * lp
```

**Branches.** Branch `bi = math.floor(f2 / branch_share * B)`, clamped to `B-1`. Each branch is
stamped from the hash, not stored, so it re-rolls with the bolt:

```
root_j = 1 + math.floor(h(seed, bi, 3) * (N - 1))       -- never node 0 or N
bdir   = (dir + u * (2*h(seed,bi,4) - 1) * 0.9
              + v * (2*h(seed,bi,5) - 1) * 0.9).Unit
Lb     = L * branch_frac * (0.5 + 0.5 * h(seed, bi, 6))
```

The branch is then the same construction with `M = max(2, floor(N / 3))` nodes, rooted at
`P_root_j`, running along `bdir` for `Lb`, jittered on its own perpendicular frame. Its taper is
`w = 1 - (j / M)` rather than a sine: a branch is pinned only at its root and should fray at the
free end. Position within the branch comes from renormalising `f1` over the branch share.

**Core thickness.** Parts sitting exactly on the polyline read as one line of bricks. Every part
gets a fixed scatter of up to `Core Thickness` studs on `u`/`v`, hashed from its own id plus the
seed:

```
pos = pos + u * (2*h(seed, d.id, 7) - 1) * T
          + v * (2*h(seed, d.id, 8) - 1) * T
```

Keyed on `seed` rather than `t` so the scatter re-rolls with each flicker and holds still
between — a crackle, not a buzz.

## Return

```lua
return (pos - p.Position) * (x1.k10 * x9.c1), pos
```

The second return value is mandatory, not optional. Without `pure_target_pos` the ~15 Hz target
step reads as stutter — the finding recorded in `2026-08-09-six-shapes-design.md`.

## Aim and firing

Aim resolution is lifted from `Twin Core Beam.lua:56-70` verbatim in behaviour: `mouse.Hit`
first, rejected when nil or `Magnitude > 10000`, then a `ViewportPointToRay` raycast out 1000
studs, then `ray.Origin + ray.Direction * 400` as the last resort. That chain is what makes it
work on both trees, and it is a read — no input connection needed.

Two toggles:

- **Aim At Cursor** (default on). Off means the bolt runs along the camera look direction for
  `Bolt Length` studs, so it works with no cursor at all.
- **Hold To Fire** (default off). Off means the bolt is always on and the module needs no input
  connections and no `M.cleanup`. On means the `Twin Core Beam.lua:28-47` connection pair, and
  then **`M.cleanup` is mandatory** — the comment at `Twin Core Beam.lua:20-26` records what
  happens without one: `x6.pre` survives a shape switch, so the listeners stay connected for the
  whole session and keep writing into state while an unrelated shape is active. When not firing,
  parts hold a loose cloud at `cen` — do not return `Vector3.zero`, which reads as the parts
  going dead.

## Optional recolour

A **Neon Recolour** toggle, default off because it mutates parts the script borrowed. When on,
set `p.Material = Enum.Material.Neon` and `p.Color` from `x1.k3`, guarded exactly as
`shapes/Platform.lua:259-263` does — compare before assigning, because writing a physics
property every frame per part is itself the cost the guard exists to avoid. `Platform.lua` is the
proof that a shape may do this at all.

Note this leaves the parts recoloured when the shape is switched away; `Platform` has the same
property and it is accepted behaviour there.

## Controls

Per constraint 7, `Min`/`Max` are display units and `x2` defaults are stored units — stored ×
`Div` = displayed. Per constraint 8 `controls_lint` checks type but not range, so an out-of-range
default ships silently.

| Key | Control | Range | Div | `x2` default | Displays |
|---|---|---|---|---|---|
| `k11` | Bolt Length | 20–1000 | — | `200` | 200 |
| `k12` | Node Count (IntOnly) | 4–64 | — | `18` | 18 |
| `k13` | Jaggedness | 0–100 | — | `14` | 14 |
| `k14` | Flicker Rate | 1–60 | — | `12` | 12 |
| `k15` | Branch Count (IntOnly) | 0–12 | — | `3` | 3 |
| `k16` | Branch Share | 0–80 | 100 | `0.3` | 30 |
| `k17` | Branch Length | 10–100 | 100 | `0.4` | 40 |
| `k18` | Core Thickness | 0–20 | — | `2` | 2 |
| `k19` | Aim At Cursor (Toggle) | — | — | `true` | — |
| `k20` | Hold To Fire (Toggle) | — | — | `false` | — |
| `k21` | Neon Recolour (Toggle) | — | — | `false` | — |

`k19`/`k20`/`k21` must stay booleans in `x2`. `load_settings` only restores a saved value when a
default of the matching type already exists, so a toggle stored as a number drops silently every
session — the failure class `config.lua:31-35` and `:127-131` were written to prevent.

## Verification

`tests/controls_lint.lua` and `tests/slider_range_lint.lua` both enumerate via
`io.popen("ls shapes")`, so the new file is covered by both the moment it lands — type coverage
and range coverage, no test edit needed.

`tests/shapes_smoke.lua` does **not** sweep every shape; it has hand-written per-shape sections
(`:697`, `:763`, `:881`). It cannot host this one: it already declares **198 top-level locals**
against LuaJIT's ceiling of 200 per chunk, so a new section with more than two locals fails to
compile. Use a dedicated `tests/bolt_smoke.lua` instead, following the `tests/cube_smoke.lua`
precedent — a per-shape harness that loads the module and `config.lua` directly. The stubs needed
are `robloxmath` plus a `game:GetService` returning `Players` with `GetMouse().Hit`, and a
`workspace.Raycast`; `shapes_smoke.lua:119-185` is the reference implementation to copy from.

Assert:

1. every part id in a 400-part sweep returns a finite target — no NaN, no inf;
2. **main-channel** parts lie within `(Jaggedness + Core Thickness) * sqrt(2) + 1` studs of the
   ideal straight `cen → aim` segment. The `sqrt(2)` is not padding: jitter is applied
   independently on both perpendicular axes, so the combined magnitude reaches `A * sqrt(2)`.
   A bound of `A + T + 1` looks right and fails — the prototype measured 18.4 studs against
   `A = 14, T = 2`, which is over `A + T` but comfortably under the correct bound;
3. **branch** parts lie within `L * Branch Length + (Jaggedness + Core Thickness) * 1.5`.
   Branches must be bounded separately or they fail the main-channel bound; the prototype
   measured 32.7 against that bound's 82;
4. distance along the axis never exceeds `L` by more than a stud — the bolt lands on the cursor
   rather than overshooting it;
5. Weyl spread: more than 350 of 400 ids produce distinct slots. The prototype gave 400/400;
6. branch share tracks the slider within 0.05 — measured 0.30 against a 0.30 setting;
7. two ids at the same `x6.f` sit on the *same* bolt: identical seed gives byte-identical
   geometry, and a reseed moves it. This is what tears if the seed or aim escapes its stamp;
8. holding `x6.f` fixed while advancing `t` past a flicker interval does **not** move the path,
   and advancing `x6.f` past a generation boundary does;
9. a vertical aim — the degenerate basis case — still produces the full perpendicular spread.
   The prototype measured 18.4, identical to the horizontal case, confirming the `xAxis` fallback
   does not collapse the frame. A bolt that silently flattens here is the likeliest single bug;
10. `Node Count = 4` and `= 64` both stay finite; `Branch Count = 0` degrades to the main channel
    rather than dividing by zero; `Jaggedness = 0` with `Core Thickness = 0` stays finite and does
    **not** assert a perp of zero — branches still fork at an angle, which is correct.

Beyond that it is a syntax parse and in-game confirmation. Say so plainly rather than describing
the shape as tested.

---

# Sub-project 2 — Max Fidelity

One new `x1` key, five guard edits per runtime tree, one toggle per UI tree.

## Shape of the change

`x1["Force Smooth (Lags)"]` already covers shortcuts 1, 2 and 5 of constraint 10. `MaxFidelity`
is a strict superset that also covers 3 and 4. It is implemented by widening the existing
conditions, never by adding a second mechanism.

The user asked for "a button". It ships as a toggle, next to `Force Smooth (Lags)`, because the
state has to persist and be visible — a momentary button would give no way to tell whether it is
on.

## `config.lua`

Add to the `x1` block, beside the other booleans:

```lua
MaxFidelity = false,
```

It must exist here with a boolean default or it can never be restored and will survive "Reset
All Settings" — the failure the comment at `config.lua:31-35` documents, and the one `FPSCap` and
`SculptorMultiSelect` were both added to fix.

## Runtime edits — apply to `System.lua` **and** `mobilever/System.lua` (constraint 9)

Root-tree line numbers; the mobile twin sits within two lines.

**a. Ladder and bucket** — `System.lua:226-230`. The existing block reads `force_smooth` and
pins `dt` and `et`. Widen its condition:

```lua
local force_smooth = x1["Force Smooth (Lags)"]
local max_fid      = x1.MaxFidelity
if force_smooth or max_fid then
    dt = 1
    et = 1
end
```

`et = 1` makes `update_bucket = x6.f % 1 = 0` and `i % 1 == 0` for every part, so the skip at
`:465` becomes a no-op without touching that line. `dt = 1` removes the ladder's compensation
factors from `dt_mult` (`:356`) and the angular damping rate (`:369`) in the same stroke.

**b. Cull and deadzone** — `System.lua:413`:

```lua
local always_process = (is_drop_shape or is_self_bounded_shape or max_fid) and true or false
```

This is the whole of shortcuts 3 and 4. `:487` and `:506` already read the flag, so neither line
changes. `k1` and `c7` keep their values — the tests are bypassed, not the settings, so turning
the switch back off restores the previous behaviour exactly.

**c. Smoothing** — `System.lua:363`:

```lua
if force_smooth or max_fid then
    sm_alpha = 1
end
```

`max_fid` must be declared before `:363` and before `:413` — hoist the local to the same place
`force_smooth` is read at `:226` and it is in scope for all three sites.

## Behaviour change worth stating

Dropping the radius cull means a part that has been flung to 10,000 studs is no longer parked and
forgotten — it is actively driven back. That is the point of the switch, but it is a real change
in what the script does with runaway parts, and on a large claim it is where the cost lands.

The risk is low because the bypass path is not new: drop shapes and self-bounded shapes already
run with `always_process` true on every frame, so this widens an exercised path rather than
opening an untested one.

## UI edits

**Desktop** — `UI.lua:971` builds the `Force Smooth (Lags)` toggle in the general-settings group
`gsc`. Add directly beneath it:

```
"Max Fidelity (No Skipping)"  ->  x1.MaxFidelity
```

**Mobile** — the same toggle in `mobilever/UI.lua`, beside its `Force Smooth` equivalent. Do not
put it in the Advanced/perf group with the four `Perf_*` toggles: those describe changes to the
game's rendering, and `UI.lua:1436` and `main.lua:277` both record that the `Perf_*` flags
describe things already applied elsewhere. Grouping a loop-fidelity switch with them invites
exactly that confusion.

## Verification

No existing test drives the main loop, so there is nothing here that the suite can assert.
Verification is: the full suite stays green (it must, since none of it touches these lines), a
syntax parse of both trees, and in-game confirmation with a large claim that turning the switch on
visibly smooths motion and turning it off restores the stepping.

State that plainly. Do not describe this as tested.

---

# Sub-project 3 — Per-part control

A new independent system. `System_sculptor.lua`, `mobilever/System_sculptor.lua` and
`shapes/Sculptor.lua` are not opened.

## Files

| File | Role |
|---|---|
| `System_partctl.lua` | new, root tree — selection, input, assignment API |
| `mobilever/System_partctl.lua` | new, mobile twin (constraint 9) |
| `System.lua` | 5 edits: px pass, bucket skip, two `always_process` reads, dispatch, collide restore |
| `mobilever/System.lua` | same 5 |
| `UI.lua`, `mobilever/UI.lua` | new Part Control panel |
| `config.lua` | `x1` keys for the panel's own state |
| `main.lua` | `x6` field initialisation and teardown hook |

## Module shape

`System_partctl.lua` mirrors `System_sculptor.lua` exactly: a module returning
`function(context, x7) ... return function() ... end end`. Wired at `System.lua:1481-1482`, which
currently reads

```lua
local sculptor_binder = load_module(SUB_DIR .. "System_sculptor.lua")(context, x7)
sculptor_binder()
```

Add the same two lines for `System_partctl.lua` directly beneath, and the same in
`mobilever/System.lua:1338`.

## Data model

Override fields hung on the existing `d` record (constraint 12). Absent means normal — a part
under no control has exactly the fields it has today.

| Field | Type | Meaning |
|---|---|---|
| `d.pc_mode` | `nil` \| `"pin"` \| `"manual"` \| `"shape"` | `nil` is normal shape control |
| `d.pc_target` | `Vector3` | world target for `pin` and `manual` |
| `d.pc_shape` | `string` | shape name, `"shape"` mode only |
| `d.pc_mod` | table | **resolved module**, cached at assignment (constraint 14) |
| `d.pc_phys` | table \| `nil` | `{ k10, k8, Damping, MaxSpeed }` overrides, any subset |
| `d.pc_ride` | boolean | collidable and physically real — see Riding |

`pin` and `manual` differ only in who writes `pc_target`: `pin` latches the part's position at
the moment it is pinned and never moves it; `manual` follows a target the user drags. Same code
path, one flag apart.

No new weak table is needed. The fields live and die with `d`, which `System.lua:456` clears on
release, so unlike the Sculptor's `SelectionBox` adornees there is nothing here that can outlive
its part. That bug — recorded at `System_sculptor.lua:14-19` — is worth reading before writing the
selection highlighting below, because the highlights *are* Instances and do have that problem.

## Loop edits — both trees

**a. Per-part `px` pass.** `System.lua:307-308` calls `px` for the current shape only. A part
assigned a shape whose solver has a `px` stage would run against stale or absent stamped state.
Before the part loop, walk a small registry of distinct assigned modules and call each one's `px`:

```lua
for mod in pairs(x6.pc_mods or EMPTY) do
    if mod.px then mod.px(ft, cur_shape_cfg, x6, x9, x1) end
end
```

`x6.pc_mods` is a set maintained by `System_partctl.lua` when assignments change, so this is
O(distinct assigned shapes), not O(parts). Note the config passed is the *current* shape's `cfg`,
which is wrong for the assigned shape — resolve each module's own `x2` entry and pass that
instead. Getting this backwards is a silent misconfiguration, not a crash.

**b. Exempt controlled parts from the bucket skip** — `System.lua:465`:

```lua
if d.pc_mode == nil and i % et ~= update_bucket then
    continue
end
```

This is the edit that makes riding viable without forcing global Max Fidelity: a handful of
controlled parts run every frame while the rest of the claim stays bucketed. It is also the reason
sub-project 3 is not blocked on sub-project 2 — 2 makes it easier to *test*, not possible.

**c. Exempt them from cull and deadzone** — `:487` and `:506`. These read the loop-invariant
`always_process`; make both read `(always_process or d.pc_mode)`. A pinned part beyond `k1` must
not be parked, and a pinned part already at its target must not be skipped, or it drifts.

**d. Dispatch** — `System.lua:508`, currently:

```lua
if shape_f2 then
    target_pos_delta, pure_target_pos = shape_f2(p, active_c, d, ft, cur_shape_cfg, x1, x6, x9)
end
```

becomes a three-way branch on `d.pc_mode`:

- `"pin"` / `"manual"` — `pure_target_pos = d.pc_target`, delta computed the same way every shape
  computes it: `(d.pc_target - p.Position) * (x1.k10 * x9.c1)`, with `pc_phys.k10` substituted when
  present. No shape call at all.
- `"shape"` — call `d.pc_mod.f2` with that module's own `x2` config in place of `cur_shape_cfg`.
  Everything else is identical, including returning `pure_target_pos`.
- `nil` — unchanged.

Per-part `pc_phys` for `k8`, `Damping` and `MaxSpeed` needs care: all three are hoisted to loop
locals at `System.lua:352-363` because they are global. Do **not** un-hoist them — that costs
every part a table lookup to serve a few. Instead compute the per-part override inside the
`d.pc_mode` branch only, leaving the hoisted locals as the fast path for uncontrolled parts.

**e. Collision restore** — `System.lua:1111` is the disable path and reads:

```lua
p.CanCollide = (disabled or x1.PreserveCollisions) and d.original_can_collide or false
```

It must not stomp a riding part. Add `or d.pc_ride` to the condition. `System.lua:755` (claim
time) needs no change: `pc_ride` cannot exist before the part is claimed.

`d.original_can_collide` is never written by this system — only read. The restore at
`System.lua:805` therefore keeps working, and the unrecoverable-state hazard documented at
`System.lua:439-452` is not reachable from here.

## Riding

Constraint 13 is the substance of this feature. `CanCollide = true` alone gives a player a
near-massless, frictionless plate: they will shove it out from under themselves and slide off what
is left. `d.pc_ride` therefore does three things, not one:

1. `p.CanCollide = true`;
2. `p.CustomPhysicalProperties = d.original_properties` when the part had its own, otherwise a new
   `RIDE_PHYSICS = PhysicalProperties.new(0.7, 0.5, 0.3, 1, 1)` — real density so it carries
   weight, real friction so the player stays on it;
3. leaves `lv.MaxForce` at `x1.k4` (`math.huge`, `System.lua:768`) so the constraint can hold
   position against the added load.

Both writes are reverted on release, and both must be guarded by a compare-before-assign the way
`shapes/Platform.lua:259-263` guards its material writes — a physics property write per frame is
the cost that guard exists to avoid.

Constraint 4 still applies and is worth expecting: `CanCollide` does not replicate, so what the
rider experiences and what other clients see will differ. For a local player standing on a local
part this is the wanted direction of the asymmetry, not a bug.

`x1.PreserveCollisions` stays a global and is unaffected. `pc_ride` is strictly additive — it can
turn collision on for one part, never off.

## Selection, independent of the Sculptor

Its own state, its own keys, no reuse of `x6.sculptor_*`:

```lua
x6.pc_selected   = setmetatable({}, {__mode = "k"})   -- part -> true
x6.pc_highlights = setmetatable({}, {__mode = "k"})   -- part -> SelectionBox
x6.pc_mods       = {}                                 -- module -> true
x6.pc_clear      = <published clear function>
```

Initialised in `main.lua` beside the `sculptor_*` fields at `main.lua:522-528`. Weak keys for the
first two, matching what the Sculptor does, so a destroyed part does not pin its record.

Input: pick under the cursor via `v9.Target` gated on `x6.a[target]` — the part must be claimed —
and a modifier for add-to-selection. On the mobile tree use the existing `x1.SculptorMultiSelect`
equivalent pattern but a **new key**, `x1.PartCtlMultiSelect`, defaulting to `false` in the `x1`
block. The comment at `config.lua:43-47` records what happens to a key the UI writes with no
default here: permanently false, unrestorable, and immune to Reset All Settings.

Distinct highlight colour from the Sculptor's `(0, 255, 200)` so the two systems are never
confused on screen.

**The teardown hazard.** `SelectionBox` instances are parented to world parts, so nothing owns them
but this system. `x6.pc_clear` must be published and called from all three teardown paths that
already call `x6.sculptor_clear`: `main.lua:659`, `System.lua:1219`, and the mobile equivalent.
`System_sculptor.lua:14-19` documents this exact bug shipping once already — stopping the script,
switching shapes, or re-executing left a `SelectionBox` adorned to every selected part with no
record left to remove it by. Do not repeat it.

## UI surface

A **Part Control** panel, new, in both UI trees. Contents:

- the current selection count, and a clear-selection action;
- mode buttons applying to the whole selection: Normal / Pin / Manual / Assign Shape;
- a shape picker for Assign Shape, populated from `pairs(x2)` the way `UI.lua:1533` populates the
  mode list — which means the new lightning shape appears there for free;
- a Rideable toggle for the selection;
- per-part physics fields (Force, Smoothing, Damping, Max Speed), blank meaning "inherit".

`x1` keys for the panel's own persisted state — last mode, last assigned shape name, rideable
default — each with a matching-type default in `config.lua`. Constraint 8 does not cover these;
they are not shape controls, so `controls_lint` will not check them. Check them by hand.

## Interaction with the shape list

A part in `"shape"` mode runs a solver while a different shape is globally selected. Two knock-on
effects to handle rather than discover:

- **`x6.pre` is shared.** Two parts assigned the same shape share its stamped state, which is
  correct. But a shape's `M.cleanup` runs only on a global shape switch (`System.lua:152`), so an
  assigned shape's `x6.pre` entry is never cleaned. Releasing the last part assigned to a shape must
  drop that module from `x6.pc_mods` and call its `cleanup` if it has one.
- **`Sculptor` must be rejected as an assignable shape.** `shapes/Sculptor.lua` reads
  `x6.sculptor_selected` and does nothing else; assigning it would make part control silently
  depend on the system we agreed not to touch. Filter it out of the picker.

## Verification

`tests/` has no harness that drives the main loop or the UI, so the automated surface here is thin
and it is more honest to say so than to invent coverage.

What can be tested, with a new `tests/partctl_smoke.lua` following the `tests/mech_track.lua`
pattern (it already stubs a Roblox environment and asserts on cleanup):

1. a `d` record with no `pc_*` fields takes the unchanged path — assert the dispatch returns
   exactly what `shape_f2` returned;
2. `pc_mode = "pin"` returns `pc_target` as `pure_target_pos` for any `p.Position`, and a delta
   that is finite and points at the target;
3. `pc_phys.k10` overrides the global without mutating `x1`;
4. the clear function empties `pc_selected`, `pc_highlights` and `pc_mods`, and is idempotent —
   the `mech_track.lua` "cleanup drops state" check is the model;
5. releasing the last part of an assigned shape drops the module from `pc_mods`.

The rest — riding, collision, selection, the panels — is in-game only. Both trees must be checked
separately; constraint 9 means a desktop pass says nothing about mobile.

---

# Registration summary

| Item | `config.lua` | Notes |
|---|---|---|
| Goro Goro no Mi | new `x2` block, 11 keys | `k19`/`k20`/`k21` boolean |
| Max Fidelity | `x1.MaxFidelity = false` | boolean |
| Part control | `x1.PartCtlMultiSelect = false` + panel-state keys | each at final type |

The shape needs no registration beyond its `x2` block: both the desktop shape list
(`UI.lua:1533`) and the keybind list (`UI.lua:789`) enumerate `pairs(x2)`, so it appears in both
automatically. `main.lua:443-445` falls back to the default shape if `x2[x1.k6]` is missing, which
is the safety net if the block is forgotten — the symptom is a shape that loads and does nothing,
not a crash.

# Out of scope

- Any change to `System_sculptor.lua`, `mobilever/System_sculptor.lua` or `shapes/Sculptor.lua`.
- Per-part appearance editing. Offered and not chosen; the shape's own Neon toggle is the only
  appearance write in this spec.
- Save/recall of arrangements. Offered and not chosen. `math/serialization.lua` exists
  (`main.lua:334`) if it is wanted later.
- Replicating collision to other clients. Constraint 4 is a platform limit, not a task.
- The El Thor vertical pillar variant. One bolt geometry, aimed.
