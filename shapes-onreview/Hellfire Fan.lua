local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = (index / count) * math.pi * 2 + t * (c.k12 or 1.5)
	local sweep = math.sin(t * (c.k13 or 6) + index) * (c.k11 or 180)
	local point = cen + Vector3.new(math.cos(angle) * (c.k11 or 180), sweep * 0.35, math.sin(angle) * (c.k11 or 180))
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Fan Radius", Min = 30, Max = 600, Key = "k11", Default = 180 },
	{ Type = "Slider", Name = "Fan Rotation", Min = 1, Max = 10, Key = "k12", Default = 1.5 },
	{ Type = "Slider", Name = "Fan Sweep", Min = 1, Max = 20, Key = "k13", Default = 6 }
}

return M
