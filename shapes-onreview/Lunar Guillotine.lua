local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local angle = ((d.id or 1) - 1) * math.pi * 2 / count + t * (c.k12 or 3)
	local radius = c.k11 or 220
	local point = cen + Vector3.new(math.cos(angle) * radius, math.sin(angle * 2) * 35, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Guillotine Radius", Min = 30, Max = 800, Key = "k11", Default = 220 },
	{ Type = "Slider", Name = "Guillotine Speed", Min = 1, Max = 15, Key = "k12", Default = 3 }
}

return M
