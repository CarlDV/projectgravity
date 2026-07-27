local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local index = d.id or 1
	local range = math.max(1, c.k11 or 800)
	local cycle = (t * (c.k12 or 180) + index * 31) % range
	local side = index % 2 == 0 and 1 or -1
	local arc = math.sin(cycle / range * math.pi) * (c.k13 or 120)
	local point = cen + Vector3.new(side * arc, math.cos(t * 5 + index) * 18, -cycle)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Maw Range", Min = 100, Max = 2000, Key = "k11", Default = 800 },
	{ Type = "Slider", Name = "Maw Speed", Min = 20, Max = 700, Key = "k12", Default = 180 },
	{ Type = "Slider", Name = "Maw Width", Min = 20, Max = 400, Key = "k13", Default = 120 }
}

return M
