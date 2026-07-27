local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local layer = index % 3
	local angle = index * 2.399 + t * (c.k12 or 2.5) * (layer % 2 == 0 and 1 or -1)
	local radius = (c.k11 or 170) * (0.5 + layer * 0.25)
	local point = cen + Vector3.new(math.cos(angle) * radius, (layer - 1) * 45, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Storm Radius", Min = 30, Max = 700, Key = "k11", Default = 170 },
	{ Type = "Slider", Name = "Storm Speed", Min = 1, Max = 15, Key = "k12", Default = 2.5 }
}

return M
