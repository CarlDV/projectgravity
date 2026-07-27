local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local height = (index / math.max(1, count - 1) - 0.5) * (c.k11 or 300)
	local angle = t * (c.k12 or 3) + index * math.pi
	local radius = c.k13 or 70
	local point = cen + Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Crusher Height", Min = 40, Max = 900, Key = "k11", Default = 300 },
	{ Type = "Slider", Name = "Crusher Speed", Min = 1, Max = 15, Key = "k12", Default = 3 },
	{ Type = "Slider", Name = "Crusher Radius", Min = 10, Max = 250, Key = "k13", Default = 70 }
}

return M
