local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local width = c.k11 or 160
	local range = math.max(1, c.k13 or 900)
	local hit = (t * (c.k12 or 300) + index * width) % range
	local point = cen + Vector3.new((index - (count - 1) / 2) * width, 0, -hit)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Hammer Width", Min = 20, Max = 500, Key = "k11", Default = 160 },
	{ Type = "Slider", Name = "Hammer Speed", Min = 20, Max = 900, Key = "k12", Default = 300 },
	{ Type = "Slider", Name = "Hammer Range", Min = 200, Max = 2000, Key = "k13", Default = 900 }
}

return M
