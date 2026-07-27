local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = index * math.pi * 2 / count
	local cycle = (t * (c.k12 or 5) + index * 0.2) % 2
	local radius = (c.k11 or 180) * (cycle < 1 and cycle or 2 - cycle)
	local point = cen + Vector3.new(math.cos(angle) * radius, math.sin(angle * 4) * 25, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Crossfire Radius", Min = 20, Max = 700, Key = "k11", Default = 180 },
	{ Type = "Slider", Name = "Crossfire Rate", Min = 1, Max = 20, Key = "k12", Default = 5 }
}

return M
