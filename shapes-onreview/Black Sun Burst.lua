local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local radius = c.k11 or 100
	local pulse = (t * (c.k12 or 3)) % 2
	local distance = pulse < 1 and pulse * radius or (2 - pulse) * radius
	local index = d.id or 1
	local angle = index * 2.399 + t * 0.7
	local point = cen + Vector3.new(math.cos(angle) * distance, math.sin(t * 5 + index) * 12, math.sin(angle) * distance)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Burst Radius", Min = 20, Max = 500, Key = "k11", Default = 100 },
	{ Type = "Slider", Name = "Burst Rate", Min = 1, Max = 15, Key = "k12", Default = 3 }
}

return M
