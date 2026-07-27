local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = index * 2.399 + t * (c.k12 or 4)
	local radius = c.k11 or 130
	local spike = math.abs(math.sin(t * (c.k13 or 9) + index))
	local point = cen + Vector3.new(math.cos(angle) * radius * spike, math.cos(angle * 2) * 40, math.sin(angle) * radius * spike)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Flare Radius", Min = 20, Max = 600, Key = "k11", Default = 130 },
	{ Type = "Slider", Name = "Flare Rotation", Min = 1, Max = 15, Key = "k12", Default = 4 },
	{ Type = "Slider", Name = "Flare Pulse", Min = 1, Max = 25, Key = "k13", Default = 9 }
}

return M
