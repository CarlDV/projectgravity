local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = index * math.pi * 2 / count + math.sin(t * (c.k12 or 3)) * 0.8
	local radius = c.k11 or 190
	local plunge = math.max(0, math.sin(t * (c.k13 or 7) + index * 0.3))
	local point = cen + Vector3.new(math.cos(angle) * radius * plunge, (1 - plunge) * 220, math.sin(angle) * radius * plunge)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Fang Radius", Min = 30, Max = 700, Key = "k11", Default = 190 },
	{ Type = "Slider", Name = "Fang Turn", Min = 1, Max = 12, Key = "k12", Default = 3 },
	{ Type = "Slider", Name = "Fang Strike", Min = 1, Max = 20, Key = "k13", Default = 7 }
}

return M
