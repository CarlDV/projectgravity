local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local phase = t * (c.k12 or 1.8) + index * 0.7
	local width = c.k11 or 90
	local point = cen + Vector3.new(math.sin(phase) * width, math.cos(phase * 2) * width, -((t * (c.k13 or 180) + index * 30) % 700))
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Rift Width", Min = 20, Max = 300, Key = "k11", Default = 90 },
	{ Type = "Slider", Name = "Rift Twist", Min = 1, Max = 12, Key = "k12", Default = 1.8 },
	{ Type = "Slider", Name = "Rift Speed", Min = 20, Max = 600, Key = "k13", Default = 180 }
}

return M
