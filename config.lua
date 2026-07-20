-- ============================================================================
-- Project Gravity — namespace legend
-- ----------------------------------------------------------------------------
-- The codebase uses short symbol names. This is the authoritative map. Keep it
-- in sync when adding config keys or context fields.
--
-- Tables passed around via `context`:
--   x1  global settings (this file's `x1`); x1.S aliases x2 at runtime
--   x2  per-shape settings, keyed by shape name (this file's `x2`)
--   x5  UI module return (built by UI.lua)
--   x6  runtime state (anchor part, active parts, connections) — see System.lua
--   x7  helper fns (notify x7.n, exclusion test x7.e) — built in System.lua
--   x9  physics scaling constants c1..c8 — defined in main.lua
--
-- Roblox services (context v1..v9):
--   v1 UserInputService   v2 Players            v3 RunService
--   v4 Workspace          v5 StarterGui         v6 TweenService
--   v7 ContextActionService  v8 LocalPlayer     v9 Mouse
--
-- System.lua function handles:
--   f1 claim part   f2 release part   f3 physics loop   f4 spawn/move anchor
--   f5 stop/teardown
--
-- x1 global keys (k1..k10 are engine-wide; k11+ are per-shape, see x2):
--   k1  attract range (parts farther than this are ignored)
--   k2  anchor part size (Vector3)      k3  anchor/center color (Color3)
--   k4  LinearVelocity MaxForce         k5  exclusion tag names
--   k6  current shape name              k7  frame-skip interval (perf)
--   k8  velocity smoothing factor       k9  global ring radius
--   k10 global pull strength (used by nearly every shape's f2)
--
-- x2 per-shape keys (k11..k23): meaning is defined by each shape's `Controls`
--   table in shapes/<name>.lua — the same key means different things per shape.
-- ============================================================================

return {
	x1 = {
		k1 = 2000,
		k2 = Vector3.new(5, 5, 5),
		k3 = Color3.fromRGB(255, 105, 180),
		k4 = math.huge,
		k5 = { "NoAttract", "Character" },
		k6 = "Celestial Ribbon",
		k7 = 4,
		k8 = 0.8,
		k9 = 80,
		k10 = 20,
		k11 = 2,
		k12 = 100,
		k13 = 10,
		k14 = 5,
		k15 = 10,
		k16 = 0.6,
		k17 = 150,
		Targets = {},
		ImpactManual = false,
		IsLaunching = false,
		Disabled = false,
		TgtActive = false,
		PI_All = false,
		AnchorSelf = false,
		AntiFling = false,
		PredictiveTracking = true,
		PredictionFactor = 150,
		ShowHUD = true,
		AggressiveClaim = false,
		["Force Smooth (Lags)"] = false,
		["Realistic Liftoff"] = false,
		Paused = false,
		Damping = 0.5,
		Ki = 0.1,
		MaxSpeed = 500,
		AngularDamping = 0.5,
		VerticalStiffness = 1.0,
		VoidProtection = true,
	},
	x2 = {
		["Pulsar Vortex"] = { k11 = 200, k12 = 8, k13 = 10, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Big Ring Things"] = { k12 = 100, k13 = 10, k14 = 5, k16 = 0.6, k15 = 10, k11 = 2, k17 = 150, k23 = false },
		["Celestial Ribbon"] = { k12 = 0, k13 = 15, k14 = 30, k16 = 0.4, k11 = 1, k17 = 150, k18 = false, k19 = false, k23 = false },
		["Hollow Worm"] = { k12 = 0, k13 = 15, k14 = 35, k16 = 0.4, k15 = 10, k11 = 15, k17 = 150, k23 = false },
		["Cosmic Comet"] = { k12 = 50, k13 = 20, k14 = 20, k16 = 0.5, k15 = 5, k11 = 5, k17 = 150, k23 = false },
		["Point Impact"] = { k12 = 0, k13 = 500, k14 = 0, k16 = 0, k15 = 0, k11 = 0, k17 = 50, k23 = false },
		["Domain Expansion Infinite Void"] = { k11 = 90, k12 = 0, k13 = 15, k14 = 0, k15 = 0, k16 = 0, k23 = false, k18 = true, k19 = true },
		["Vortex Funnel"] = { k11 = 50, k12 = 300, k13 = 30, k14 = 400, k15 = 5, k16 = 0, k17 = 400, k23 = false },
		["Quantum Atoms"] = { k11 = 60, k12 = 0, k13 = 15, k14 = 0, k15 = 3, k16 = 0, k17 = 150, k23 = false },
		["Halo Ring"] = { k11 = 40, k12 = 0, k13 = 5, k14 = 80, k15 = 0, k16 = 0, k17 = 50, k23 = false },
		["Slingshot"] = { k11 = 50, k12 = 3, k13 = 100, k14 = 0, k15 = 5, k16 = 0, k17 = 100, k23 = false },
		["Gods Call"] = { k11 = 10, k12 = 0, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 50, k23 = false },
		["Deflect"] = { k11 = 50, k12 = 500, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 50, k23 = false },
		["Shield Wall"] = { k11 = 20, k12 = 25, k13 = 20, k14 = 50, k15 = 10, k16 = 0, k17 = 50, k23 = false },
		["Sculptor"] = { k11 = 0, k12 = 0, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Torus Knot"] = { k11 = 3, k12 = 2, k13 = 10, k14 = 50, k15 = 20, k16 = 0, k17 = 0, k23 = false },
		["Möbius Strip"] = { k11 = 50, k12 = 20, k13 = 15, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["DNA Helix"] = { k11 = 20, k12 = 80, k13 = 10, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Black Hole"] = { k11 = 40, k12 = 100, k13 = 15, k14 = 50, k15 = 5, k16 = 0, k17 = 0, k23 = false },
		-- ["Drop"] = { k11 = 500, k12 = 5 },
		["Dense Spin"] = { k11 = 50, k12 = 2 },
		["Tesseract"] = { k11 = 40, k12 = 80, k13 = 10, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Klein Bottle"] = { k11 = 60, k12 = 20, k13 = 20, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Space Station"] = { k11 = 80, k12 = 30, k13 = 10, k14 = 150, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Supernova"] = { k11 = 15, k12 = 100, k13 = 25, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Dyson Sphere"] = { k11 = 150, k12 = 8, k13 = 10, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Seraphim"] = { k11 = 80, k12 = 4, k13 = 15, k14 = 40, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Alien Mothership"] = { k11 = 120, k12 = 40, k13 = 15, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Cursed Technique Red"] = { k11 = 2000, k12 = 100 },
		["Quantum Core"] = { k11 = 100, k12 = 30, k13 = 40, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Galactic Web"] = { k11 = 400, k12 = 10, k13 = 5, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false, k24 = 200 },
		["Meteor Shower"] = { k11 = 500, k12 = 300, k13 = 150, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["World Serpent"] = { k11 = 400, k12 = 100, k13 = 20, k14 = 20, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Aurora Borealis"] = { k11 = 600, k12 = 300, k13 = 15, k14 = 100, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Arcane Orrery"] = { k11 = 120, k12 = 4, k13 = 8, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Maelstrom Spire"] = { k11 = 30, k12 = 200, k13 = 15, k14 = 6, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Eldritch Binding"] = { k11 = 100, k12 = 200, k13 = 5, k14 = 8, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Graviton Engine"] = { k11 = 4, k12 = 60, k13 = 12, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Fractal Web"] = { k11 = 40, k12 = 3, k13 = 3, k14 = 5, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Leviathan Coil"] = { k11 = 50, k12 = 15, k13 = 8, k14 = 250, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	},
}
