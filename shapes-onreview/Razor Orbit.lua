local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local phase = index * math.pi * 2 / count + t * (c.k12 or 4)
	local radius = c.k11 or 140
	local point = cen + Vector3.new(math.cos(phase) * radius, math.sin(t * 3 + index) * 10, math.sin(phase) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Razor Radius", Min = 20, Max = 600, Key = "k11", Default = 140 },
	{ Type = "Slider", Name = "Razor Speed", Min = 1, Max = 20, Key = "k12", Default = 4 }
}

return M
