local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local index = d.id or 1
	local wave = math.sin(t * (c.k12 or 6) + index * 0.8)
	local forward = ((t * (c.k13 or 210) + index * 22) % math.max(1, c.k11 or 750))
	local point = cen + Vector3.new(wave * 60, math.cos(t * 4 + index) * 20, -forward)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Chain Range", Min = 100, Max = 1800, Key = "k11", Default = 750 },
	{ Type = "Slider", Name = "Chain Lash", Min = 1, Max = 20, Key = "k12", Default = 6 },
	{ Type = "Slider", Name = "Chain Speed", Min = 20, Max = 700, Key = "k13", Default = 210 }
}

return M
