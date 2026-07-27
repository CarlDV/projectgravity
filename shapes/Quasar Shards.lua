local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local index = d.id or 1
	local range = math.max(1, c.k11 or 950)
	local depth = (t * (c.k12 or 270) + index * 21) % range
	local zigzag = ((math.floor(t * (c.k13 or 8) + index) % 2) * 2 - 1) * (c.k14 or 38)
	local point = cen + Vector3.new(zigzag, math.sin(t * 9 + index) * 12, -depth)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Shard Range", Min = 100, Max = 2200, Key = "k11", Default = 950 },
	{ Type = "Slider", Name = "Shard Speed", Min = 20, Max = 900, Key = "k12", Default = 270 },
	{ Type = "Slider", Name = "Zigzag Rate", Min = 1, Max = 25, Key = "k13", Default = 8 },
	{ Type = "Slider", Name = "Zigzag Width", Min = 1, Max = 150, Key = "k14", Default = 38 }
}

return M
