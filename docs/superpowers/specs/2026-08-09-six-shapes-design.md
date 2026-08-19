# Six Shapes: Lag Tree, World Envelope, Wake Spline

**Date:** 2026-08-09
**Status:** Approved, pending implementation

## Origin

Requested as "more shapes, unique ones", with the note that `CanCollide` only affects the
client. Three uncovered niches, two shapes each, paired so one solver serves both.

An audit of all 48 existing shapes found that every one of them is a closed-form function of
`(cen, t, d.id, controls)`. Three consequences follow, and each is a niche:

- Nothing has **memory**. The formation teleports rigidly with the anchor and never lags,
  whips or settles. The only per-part integration anywhere is `shapes/Dense Spin.lua:17-18`,
  two scalar angle accumulators.
- Nothing **measures the world**. Only three shapes raycast at all, and all three cast for a
  single scalar: `shapes/Platform.lua:482,498` for ground and ceiling height, and
  `shapes/Big Bad Broom.lua:33` / `shapes/Twin Core Beam.lua:59` for a cursor aim point. Every
  other shape is identical in a cave, a stadium and the void.
- Nothing **records the player**. `shapes/Cosmic Comet.lua` and `shapes/Light Light no Mi.lua`
  bake curves into point arrays, but both curves are synthetic. Broom and Twin Core Beam read
  the cursor only as an instantaneous direction, never an accumulating path.

## Engine constraints

Beyond the four in `2026-08-08-shape-modes-design.md`, which all still hold:

**5. `px` never receives `cen`.** `System.lua:285-287` passes `(ft, cfg, x6, x9, x1)`. A solver
that integrates in `px` must run against `x6.b.Position` and store **offsets**, letting `f2`
re-root them at its own `cen`. Deriving anchor-relative geometry in `px` is the shipped bug
recorded at `shapes/Big Bad Broom.lua:133-135`.

**6. `cen` is genuinely per-part.** `System.lua:444-447` deals each part a different
`active_c` round-robin across `x1.Targets`. A rigid formation must either pick one anchor in
`px` and publish it, or be re-rootable onto an arbitrary origin.

**7. Stored slider values are display units divided by `Div`.** `UI.lua:1225` stores
`value / Div` and `UI.lua:1223` multiplies back for display. `Min`/`Max` are therefore in
**display** space while `config.lua` defaults are in **stored** space. Rocket Engine's
`k14 = 15` under `Div = 10` shows as 150 on the panel.

**8. `tests/controls_lint.lua` checks type, not range.** It asserts every `Controls` key exists
in `x2` at the matching final type — `Toggle` to boolean, `TextBox` to string, else number. A
default outside `Min..Max` passes the lint and is caught only in game.

## The three solvers

Each solver is duplicated **verbatim** into both files of its pair. `shapes/` modules cannot
`require` a shared library — `main.lua:340-380` fetches each file standalone and `loadstring`s
it. This is copy-paste, not abstraction. Edit one, edit both.

All three cost O(nodes) or O(rays) per frame, never O(parts). All three stamp on the bucket
boundary `gen = math.floor((x6.f or 0) / et)` and return `pure_target_pos`, without which the
~15 Hz target step reads as stutter.

### Lag Tree — inertia and settling

A fixed tree of `N` nodes, each a damped spring chasing its rest offset from the anchor, with
parent-lag coupling `KP` so displacement compounds down the index. `PA[j] < j` is an invariant,
so one forward pass integrates the whole tree in order.

State lives in `x6.pre["<ShapeName>"]`: parent index `PA`, rest offsets `S0`, world guide
positions `G`, velocities `V`, lag `L`, per-node frequency `SW` and damping ratio `SZ`,
coupling `KP`, and cap length `CL`. Every array is allocated once at creation and never
resized, so no slider can trigger a rebuild.

Sub-stepping is driven by `wmax`, the running maximum of `SW`, so a stiff spring cannot
explode at low frame rates. `dt` is clamped to `0.25` as in `shapes/Rocket Engine.lua:66-70`.
A relative-lag fuse `lmax` bounds total displacement, keeping every node inside `x1.k1 = 2000`.

### World Envelope — reads the map

A fixed lattice of probe directions, refreshed round-robin at a bounded rays-per-frame budget.
The critical decision: **cache world-space planes, not radii.** Each direction `j` stores a hit
point `H[j]` and a surface normal `N[j]`.

A radius is only meaningful from the origin it was measured at. Because `px` cannot see `cen`
(constraint 5) and `cen` is per-part (constraint 6), the field must be re-rootable onto an
arbitrary origin — and a plane is, where a radius is not. Re-rooting is exact: the sub-agent
verified numerically against a 45-degree wall that re-rooting a hit measured at `r = 100` onto
an origin 60 studs to the side returns 40.0 against a ground truth of 40.0, and that the
formula returns exactly `r` when `cen == org`.

Storing the normal is also what makes Ymir's pulse legible: displacement runs along the
**measured** normal, so a single crest heaves vertically on the floor, punches horizontally on
a wall and drops from the ceiling within one frame.

`RaycastParams` must exclude claimed parts the way `shapes/Platform.lua:296-309` does, and
`M.cleanup` must release the params object, since `x6.pre` survives shape switches.

### Wake Spline — your own path

A ring buffer of anchor samples, appended only when the anchor has moved past a threshold, so
standing still does not collapse the trail to a point. Samples are resampled to uniform arc
length and carried on a parallel-transported frame.

Capacity `K = 768` with at most `MAX_PUSH = 24` appended per frame and `NODES_MAX = 288`
indexed by `f2`, giving a 480-slot guard band. Worst case `px` writes `24 × (10 - 1) = 216`
slots between the stamp and the last `f2` of that cycle; 216 < 480, so every slot `f2` can
reach is immutable for the whole cycle even though `px` writes the ring live. This is what
makes it safe to write the buffer every frame while reading it on a stagger.

Arc length is capped at `ARC_MAX = 1400` studs, trimming the tail so it stays inside
`x1.k1 = 2000`. Memory is ~31 KB, preallocated, with no allocation at 60 Hz.

## The six shapes

Control counts are trimmed to 12 or fewer, matching `shapes/Rocket Engine.lua` at 12. Cut
controls become hardcoded constants at the values listed.

### Meteor Hammer — Lag Tree

A wrecking ball on a 24-node chain. Lag compounds at `KP = 0.94` per stage, so the tip lags the
grip about 12.6x and tip speed vastly exceeds grip speed. Hold to wind into a near-horizontal
conical orbit; release and it rings down through a dozen decaying arcs.

The **free end** is the structural difference from its pair partner, and it is where momentum
concentrates. At the default 50% head share, half of every claimed part packs into a 20-stud
ball moving several hundred studs/s. Per constraint 4 this is the heavy contact shape: other
clients resolve that ball as solid at the part's **original** density, not the 0.001
`LIGHT_PHYSICS` value (`System.lua:13`, applied `System.lua:724`).

| Type | Name | Key | Min | Max | Default | Notes |
|---|---|---|---|---|---|---|
| Slider | `Chain · Length` | k11 | 20 | 400 | 110 | |
| Slider | `Chain · Springiness` | k18 | 10 | 160 | 11 | Div 10 |
| Slider | `Chain · Damping %` | k19 | 10 | 100 | 55 | IntOnly |
| Slider | `Head · Radius` | k13 | 3 | 70 | 20 | |
| Slider | `Head · Share %` | k14 | 10 | 85 | 50 | IntOnly |
| Slider | `Grip Height` | k15 | -40 | 140 | 14 | |
| Slider | `Weight` | k16 | 40 | 900 | 260 | |
| Slider | `Air Drag %` | k17 | 0 | 100 | 12 | IntOnly |
| Slider | `Hold Mode (1 Spin Up, 2 Lash At Cursor)` | k22 | 1 | 2 | 1 | IntOnly |
| Toggle | `Hold To Swing` | k20 | | | true | |
| Slider | `Swing Power` | k21 | 0 | 500 | 180 | |
| Slider | `Lash Impulse` | k23 | 0 | 800 | 320 | |

Cut: `Chain · Thickness` to 2.5, `Head · Lead` to 120, `Teleport Snap` to 300.

### Mochi Mochi no Mi — Lag Tree

A 3x3x3 free-form-deformation cage instead of a free end: one deforming volume where every
node is boxed in by its parent and its children. Trails 26 studs behind you, stretches into a
teardrop when you sprint, pancakes on landing, and wobbles through four visible overshoots
after you stop.

The contact signature is the structural opposite of Meteor Hammer's: a thick shell whose centre
trails **behind** you, so the victim who dodges you is hit by the follow-through, and the
23.7% overshoot keeps it ploughing forward for ~0.6 s after you stop dead. Hold to compress
into a knot, release to blow everyone nearby outward.

| Type | Name | Key | Min | Max | Default | Notes |
|---|---|---|---|---|---|---|
| Slider | `Body · Radius` | k11 | 10 | 220 | 60 | |
| Slider | `Body · Lift` | k12 | -60 | 200 | 30 | |
| Slider | `Body · Softness %` | k13 | 5 | 100 | 45 | IntOnly |
| Slider | `Body · Skin %` | k14 | 0 | 100 | 70 | IntOnly |
| Slider | `Jiggle Damping %` | k15 | 0 | 100 | 22 | IntOnly |
| Slider | `Follow Rate` | k16 | 4 | 40 | 1.6 | Div 10 |
| Slider | `Wobble %` | k17 | 0 | 100 | 62 | IntOnly |
| Toggle | `Splat On Floor` | k18 | | | true | |
| Toggle | `Hold To Compress` | k19 | | | true | |
| Slider | `Compress %` | k20 | 20 | 100 | 38 | IntOnly |
| Slider | `Burst Kick` | k21 | 0 | 400 | 140 | |

Cut: `Teleport Snap` to 300.

### Ymir's Flesh — World Envelope

Parts tile the 2-manifold where the probe rays **stop**, a few studs off the measured face, so
the silhouette is the room: doorways, pillars, stair nosings and window reveals all read. A
travelling crest leaves the anchor and races outward across the floor, up the walls and over
the ceiling, displacing the crust along the measured surface normal.

Named for the Norse giant whose corpse became the world — earth from his flesh, the sky-vault
from his skull — because the shape makes the room's own surfaces manifest as matter and then
makes them breathe.

| Type | Name | Key | Min | Max | Default | Notes |
|---|---|---|---|---|---|---|
| Slider | `Probe · Directions` | k11 | 48 | 384 | 192 | IntOnly |
| Slider | `Probe · Rays Per Frame` | k12 | 2 | 48 | 12 | IntOnly |
| Slider | `Probe · Reach` | k13 | 60 | 600 | 300 | |
| Slider | `Open Sky · Radius` | k14 | 20 | 600 | 140 | |
| Slider | `Surface (1 All, 2 Floor, 3 Walls, 4 Ceiling)` | k18 | 1 | 4 | 1 | IntOnly |
| Slider | `Skin · Patch %` | k15 | 40 | 250 | 110 | IntOnly |
| Slider | `Skin · Thickness` | k16 | 0 | 40 | 4 | |
| Slider | `Skin · Lift` | k17 | -6 | 40 | 1 | |
| Slider | `Pulse · Height` | k20 | 0 | 200 | 40 | |
| Slider | `Pulse · Speed` | k21 | 0 | 300 | 60 | |
| Slider | `Pulse · Length` | k22 | 20 | 400 | 120 | |

Cut: `Probe · Settle` to 240, `Pulse · Sharpness` to 4.

### Yamata no Orochi — World Envelope

Fills the open air the rays passed **through**, not the surfaces they stopped on — the inverse
read of the same cache. The debris finds every exit at once and grows a neck down each: two
long necks in a corridor, one head craning through each doorway, one going up and one down in
a stairwell, a symmetrical starburst in an open field.

The legibility tell is that head length equals real distance. Walk at a wall and the head
shortens live; a head down a corridor is exactly as long as the corridor. Each neck is thin at
the base with a heavy knot at the tip, and one head lunges through a doorway at whoever is
standing in it.

| Type | Name | Key | Min | Max | Default | Notes |
|---|---|---|---|---|---|---|
| Slider | `Probe · Directions` | k11 | 48 | 384 | 192 | IntOnly |
| Slider | `Probe · Rays Per Frame` | k12 | 2 | 48 | 12 | IntOnly |
| Slider | `Probe · Reach` | k13 | 60 | 600 | 400 | |
| Slider | `Heads · Count` | k15 | 1 | 8 | 5 | IntOnly |
| Slider | `Heads · Separation (Degrees)` | k16 | 10 | 120 | 50 | IntOnly |
| Slider | `Neck · Thickness` | k17 | 1 | 30 | 5 | |
| Slider | `Head · Thickness` | k18 | 2 | 60 | 16 | |
| Slider | `Sway · Width` | k20 | 0 | 60 | 14 | |
| Slider | `Sway Speed` | k22 | 1 | 300 | 3 | Div 10 |
| Slider | `Strike · Rest %` | k23 | 20 | 100 | 55 | IntOnly |
| Slider | `Strike · Every` | k24 | 5 | 100 | 2.2 | Div 10 |
| Toggle | `Strike On Click` | k27 | | | false | |

Cut: `Probe · Settle` to 240, `Keep Heads Off The Floor` to true, `Aim A Head At Camera` to
false, `Strike · Overshoot` to 10, `Head · Tip Mass` to 3, `Sway · Waves` to 1.5.

### Mugen Train — Wake Spline

Walk or fly anywhere and you leave a railway behind you; a four-carriage freight train barrels
down it, chasing your heels and flattening anyone standing on the route you took. Parts do two
jobs: a rolling section of two-rail track with sleepers, windowed around the locomotive so
track materialises ahead and dissolves behind, and rectangular carriage shells.

A compact dense mass translating along the recorded curve — the contact half of this pair.

| Type | Name | Key | Min | Max | Default | Notes |
|---|---|---|---|---|---|---|
| Slider | `Trail · Length` | k11 | 40 | 1400 | 420 | |
| Slider | `Train · Speed` | k13 | 10 | 600 | 90 | |
| Slider | `Train · Cars` | k14 | 1 | 12 | 4 | IntOnly |
| Slider | `Run Mode (1 Chase, 2 Shuttle)` | k21 | 1 | 2 | 1 | IntOnly |
| Slider | `Car · Length` | k15 | 8 | 60 | 26 | |
| Slider | `Car · Width` | k16 | 4 | 40 | 14 | |
| Slider | `Car · Height` | k17 | 4 | 40 | 14 | |
| Slider | `Car · Gap` | k18 | 0 | 40 | 10 | |
| Slider | `Rail · Share %` | k19 | 0 | 60 | 22 | IntOnly |
| Slider | `Rail · Gauge` | k20 | 2 | 40 | 9 | |
| Toggle | `Freeze Track` | k24 | | | false | |

Cut: `Car · Wall %` to 30, `Rail · Span` to 240.

### Dragons Teeth — Wake Spline

Nothing travels along the curve. Parts spread uniformly over the whole arc and all the motion
is a per-node height envelope keyed to each node's birth time: a tooth is 0 studs tall the
instant its node is laid and smoothsteps to full height over ~0.35 s, so fangs slam up out of
the floor in sequence behind a sprinting player. Sprint a circle around someone and they are
sealed in.

Cadmus sowed the dragon's teeth and the Spartoi rose out of the furrow he had walked, which is
exactly the premise; "dragon's teeth" is also the real name for concrete anti-vehicle barriers,
so the name states both the motion and the function. Apostrophe dropped to match
`shapes/Gods Call.lua`.

| Type | Name | Key | Min | Max | Default | Notes |
|---|---|---|---|---|---|---|
| Slider | `Trail · Length` | k11 | 40 | 1400 | 300 | |
| Slider | `Tooth · Height` | k13 | 5 | 120 | 34 | |
| Slider | `Tooth · Pitch` | k14 | 6 | 80 | 18 | |
| Slider | `Tooth · Thickness` | k15 | 1 | 30 | 7 | |
| Slider | `Tooth · Fill %` | k16 | 30 | 100 | 75 | IntOnly |
| Slider | `Ridge · Height` | k17 | 0 | 30 | 4 | |
| Slider | `Ridge · Width` | k18 | 1 | 40 | 6 | |
| Slider | `Rise · Seconds` | k19 | 1 | 30 | 0.35 | Div 10 |
| Slider | `Base · Drop` | k20 | 0 | 30 | 3 | |
| Toggle | `Ground Snap` | k21 | | | true | |
| Toggle | `Freeze Wall` | k22 | | | false | |

No cuts; 11 controls.

## Testing notification

These six ship behind a testing notice. A shape declares itself with a module-level flag,
following the `M.Drop` precedent read at `System.lua:376`:

```lua
M.Testing = true
```

A flag beats a hardcoded name list in `System.lua`, because the module is already resolved at
every insertion point — `get_shape(name)` is called before the notification would fire.

**Three insertion points, because `switch_shape` is not the only path that sets `k6`:**

1. `System.lua:1122-1154`, `x4.switch_shape` — the main path, already calling `x7.n` on load
   failure at `:1127`. Fire after `x1.k6 = name`.
2. `UI.lua:1500-1524` — the fallback branch taken before System is up, which sets `x1.k6 = mn`
   directly at `:1510` and never calls `switch_shape`.
3. `mobilever/UI.lua:1179-1199` — sets `x1.k6 = mn` at `:1182`. The mobile tree has **no**
   `switch_shape` at all and no `x7`, but `context.x8` is populated at `main.lua:565` and
   `x8.notify` is bound to `x7.n` at `System.lua:29`. Click handlers run long after the UI
   module is built, so `context.x8.notify` resolves at call time.

The literal call, in all three places:

```lua
local mod = get_shape(name)
if mod and mod.Testing then
    x7.n("Testing", name .. " is still in testing.", 4)
end
```

with `x7.n` replaced by `context.x8 and context.x8.notify` in the two UI trees.

Fire on **every** switch, not once per session: these are experimental physics shapes that can
fling parts, and the warning is worth repeating. Also fire at startup when a saved `k6` is
already a testing shape (`main.lua:329-331`), since the shape is active without the user having
just picked it.

Note `x7.n`'s in-panel branch at `System.lua:19` is dead — nothing in the repo defines
`x5.toast`, so every notification already falls through to `SetCore("SendNotification")`. This
change does not depend on that branch and does not fix it.

## Registration

Six files, six `x2` blocks in `config.lua`, every key at its exact final type. Toggles must be
booleans; `tests/controls_lint.lua` fails the build on a type mismatch or a missing key.

File names must match the `x2` key byte for byte, including the apostrophe in
`shapes/Ymir's Flesh.lua`.

## Verification

`luajit tests/controls_lint.lua` from the repo root is the only meaningful automated check, and
it verifies registration only. Beyond it, verification is a syntax parse and in-game
confirmation.

**The adversarial review of these specs did not complete.** Three lenses were planned —
stagger/feed-forward correctness, cost and numerical stability, and lint/registration — and all
three were cancelled before returning. The designs above are unverified against the engine
source beyond the constraints already cited. Treat the numeric constants, and especially the
Lag Tree sub-stepping and the Wake Spline guard-band arithmetic, as unreviewed.
