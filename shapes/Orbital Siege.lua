local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = index * math.pi * 2 / count + t * (c.k12 or 2)
	local radius = (c.k11 or 210) * (0.65 + 0.35 * math.sin(t * (c.k13 or 5) + index))
	local point = cen + Vector3.new(math.cos(angle) * radius, math.sin(angle * 3) * 55, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Siege Radius", Min = 30, Max = 800, Key = "k11", Default = 210 },
	{ Type = "Slider", Name = "Siege Rotation", Min = 1, Max = 12, Key = "k12", Default = 2 },
	{ Type = "Slider", Name = "Siege Pulse", Min = 1, Max = 18, Key = "k13", Default = 5 }
}

return M
