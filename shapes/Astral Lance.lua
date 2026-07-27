local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local targets = x6.target_positions or {}
	local target = targets[((d.id or 1) - 1) % math.max(1, #targets) + 1] or cen
	local dir = target - cen
	if dir.Magnitude < 0.01 then dir = Vector3.new(0, 1, 0) else dir = dir.Unit end
	local spread = ((d.id or 1) % 7 - 3) * (c.k11 or 18)
	local side = Vector3.new(-dir.Z, 0, dir.X)
	if side.Magnitude < 0.01 then side = Vector3.new(1, 0, 0) else side = side.Unit end
	local point = cen + dir * ((t * (c.k12 or 180) + (d.id or 1) * 12) % math.max(1, c.k13 or 700)) + side * spread
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Lane Spread", Min = 1, Max = 80, Key = "k11", Default = 18 },
	{ Type = "Slider", Name = "Lance Speed", Min = 20, Max = 600, Key = "k12", Default = 180 },
	{ Type = "Slider", Name = "Lance Range", Min = 100, Max = 2000, Key = "k13", Default = 700 }
}

return M
