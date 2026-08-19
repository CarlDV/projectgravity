# Shape Modes: Rocket, Mech, Big Bad Broom

**Date:** 2026-08-08
**Status:** Approved, pending implementation

## Origin

Proposed in Discord on 2026-08-08. Three additions to `shapes/`, each a self-contained module following the existing shape contract.

## Engine constraints

Four facts about the runtime shape every decision below.

**1. Parts are never oriented.** `System.lua:737` applies a `LinearVelocity` plus an `AngularVelocity` that is only ever damped toward zero. Parts are translated, never turned. Every mode here is therefore a *point cloud in a silhouette*, assembled from whatever parts were claimed. `Hover Text` establishes that this reads well, but none of these will match the sketches literally.

**2. Bucketing shears rigid formations.** `k7` updates each part on one frame in `et`. A formation meant to hold its shape must derive its basis from a value stamped once per bucket cycle (`gen = floor(x6.f / et)`), never from live `t`. This is the `Hover Text.lua:139` technique. All three modes are rigid, so all three stamp.

**3. Part ids are a sliding window, not `1..n`.** Assigning slots by `id % n` clumps and starves slots. Each mode maps id to slot through a Weyl sequence, as `Hover Text` does for glyph pixels.

**4. `CanCollide = false` is client-local.** `System.lua:720` clears collisions on claimed parts, but that write does not replicate. Other clients still resolve those parts as solid, so contact-based effects land on other players without `PreserveCollisions`.

## Shared skeleton

Each mode is the same two-stage machine:

- `M.px` stamps a **basis** — origin, orthonormal frame, phase — once per bucket cycle into `x6.pre[<name>]`.
- `M.f2` maps its part to a fixed local-space slot, then transforms that slot by the stamped basis.

The silhouette generators differ; the skeleton does not. It is duplicated per file rather than extracted, because `shapes/` modules cannot require a shared library. Revisit if a fourth consumer appears.

## Rocket

`M.px` advances one shared phase per bucket cycle and caches the caster root position.

`M.f2` splits parts by an **Exhaust Share** slider. Engine parts sit on a cylindrical shell around the current path point. Exhaust parts trail back along `-tangent` with lateral spread and a per-part age, so the stream stretches out behind the engine rather than clumping at it.

Two patterns, selected by a **Flight Path** control:

- **Circle** orbits `cen` in a plane chosen by an **Orbit Axis** control.
- **Figure 8** is a Gerono lemniscate spanning caster and target:

```
P(theta) = M + along * (L * sin(theta)) + perp * (W * 0.5 * sin(2 * theta))
```

where `M` is the midpoint of caster and `cen`, and `along = (cen - caster).Unit`. It crosses at the midpoint and loops at each end, matching the infinity path from the thread.

`System.lua:307` already assigns `active_c` per part, round-robin across `x1.Targets`. Two selected targets therefore produce two independent figure-8s — each spanning caster to that target — with no extra code. With no target selected the two foci collapse to one point, so the path degenerates; detect that and fall back to Circle.

## Mech

`M.px` reads the character's BaseParts and, for each, takes its CFrame relative to `HumanoidRootPart` along with its `Size`. That yields a set of oriented boxes describing the actual avatar — R6 or R15, with no rig-specific branching.

It fills those boxes with points at density proportional to volume, so the torso reads solid while arms stay thin. The resulting cloud is cached against `(character, size, part count)` and rebuilt on respawn or when the size slider moves.

`M.f2` places the cloud at a **Placement** offset (front, behind, beside, on) from `cen`, scaled by **Size**, facing either the caster's look direction or the caster itself. **Stationary** latches a world position on the first frame it is enabled, instead of tracking.

## Big Bad Broom

The handle is a line cloud and the head a flat slab, split by share as in Rocket.

`M.px` lazily connects `UserInputService` and stores the aim ray hit, button state, and accumulated mouse delta into `x6.pre` — the `Twin Core Beam.lua:20` pattern, gated on `state.last_frame ~= x6.f`. Holding the button extends the head along the handle. Mouse delta drives sweep angle about a **Sweep Axis** (horizontal, vertical, sideways).

Crush needs no additional code and no `PreserveCollisions`, per constraint 4: the victim's client resolves the head as solid and their own physics does the work.

`M.cleanup` must disconnect the input connections and clear its `x6.pre` entry. `x6.pre` survives shape switches — only `M.cleanup` runs — so a shape holding connections without one leaks them.

## Registration

Three files, three `x2` blocks in `config.lua`, every key at its exact final type.

Two past bugs (#3, #6) were key and type registration mistakes, and these modes add roughly twenty new keys. Add a static check that walks every `shapes/*.lua` `M.Controls` and asserts each `Key` exists in `x2` with a matching type.

## Verification

That registration check is the only meaningful automated test available here. Beyond it, verification is a syntax parse and in-game confirmation. State that plainly rather than describing these modes as tested.

