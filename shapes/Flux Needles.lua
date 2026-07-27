local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local index = d.id or 1
	local range = math.max(1, c.k11 or 850)
	local reach = (t * (c.k12 or 230) + index * 28) % range
	local angle = index * 2.399 + t * 0.6
	local spread = (c.k13 or 45) * (reach / range)
	local point = cen + Vector3.new(math.cos(angle) * spread, math.sin(angle) * spread, -reach)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Needle Range", Min = 100, Max = 2000, Key = "k11", Default = 850 },
	{ Type = "Slider", Name = "Needle Speed", Min = 20, Max = 800, Key = "k12", Default = 230 },
	{ Type = "Slider", Name = "Needle Spread", Min = 1, Max = 150, Key = "k13", Default = 45 }
}

return M
