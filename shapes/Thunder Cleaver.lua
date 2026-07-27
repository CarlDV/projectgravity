local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local width = c.k11 or 240
	local x = (index / math.max(1, count - 1) - 0.5) * width
	local sweep = math.sin(t * (c.k12 or 4) + index * 0.2) * (c.k13 or 260)
	local point = cen + Vector3.new(x, 15 * math.sin(index), sweep)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Blade Width", Min = 40, Max = 900, Key = "k11", Default = 240 },
	{ Type = "Slider", Name = "Sweep Speed", Min = 1, Max = 15, Key = "k12", Default = 4 },
	{ Type = "Slider", Name = "Sweep Reach", Min = 40, Max = 900, Key = "k13", Default = 260 }
}

return M
