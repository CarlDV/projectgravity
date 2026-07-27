local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local columns = math.max(1, math.floor(math.sqrt(count)))
	local row = math.floor(index / columns)
	local col = index % columns
	local spacing = c.k11 or 45
	local height = math.max(1, c.k13 or 900)
	local cycle = (t * (c.k12 or 140) + row * spacing * 2) % height
	local target = cen + Vector3.new((col - (columns - 1) / 2) * spacing, height / 2 - cycle, (row - (columns - 1) / 2) * spacing)
	return (target - p.Position) * (x1.k10 * x9.c1), target
end

M.Controls = {
	{ Type = "Slider", Name = "Impact Spacing", Min = 10, Max = 120, Key = "k11", Default = 45 },
	{ Type = "Slider", Name = "Fall Speed", Min = 20, Max = 600, Key = "k12", Default = 140 },
	{ Type = "Slider", Name = "Drop Height", Min = 200, Max = 2000, Key = "k13", Default = 900 }
}

return M
