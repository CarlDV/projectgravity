local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = index * math.pi * 2 / count + t * (c.k12 or 2)
	local pulse = math.max(0, math.sin(t * (c.k13 or 8)))
	local radius = (c.k11 or 150) * pulse
	local point = cen + Vector3.new(math.cos(angle) * radius, math.sin(angle * 3) * radius * 0.2, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Pulse Radius", Min = 20, Max = 600, Key = "k11", Default = 150 },
	{ Type = "Slider", Name = "Rotation", Min = 1, Max = 12, Key = "k12", Default = 2 },
	{ Type = "Slider", Name = "Pulse Rate", Min = 1, Max = 20, Key = "k13", Default = 8 }
}

return M
