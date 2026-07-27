local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local index = d.id or 1
	local lane = index % 5 - 2
	local range = math.max(1, c.k11 or 1000)
	local depth = (t * (c.k12 or 320) + index * 25) % range
	local point = cen + Vector3.new(lane * (c.k13 or 22), math.sin(t * 12 + index) * 6, -depth)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Rail Range", Min = 100, Max = 2500, Key = "k11", Default = 1000 },
	{ Type = "Slider", Name = "Rail Speed", Min = 20, Max = 1000, Key = "k12", Default = 320 },
	{ Type = "Slider", Name = "Rail Spread", Min = 1, Max = 100, Key = "k13", Default = 22 }
}

return M
