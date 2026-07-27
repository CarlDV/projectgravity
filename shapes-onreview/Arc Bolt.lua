local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local lane = ((d.id or 1) - 1) % count
	local phase = t * (c.k12 or 4) + lane * math.pi * 2 / count
	local radius = c.k11 or 120
	local target = cen + Vector3.new(math.cos(phase) * radius, math.sin(phase * 2) * radius * 0.35, math.sin(phase) * radius)
	return (target - p.Position) * (x1.k10 * x9.c1), target
end

M.Controls = {
	{ Type = "Slider", Name = "Orbit Radius", Min = 20, Max = 500, Key = "k11", Default = 120 },
	{ Type = "Slider", Name = "Orbit Speed", Min = 1, Max = 20, Key = "k12", Default = 4 }
}

return M
