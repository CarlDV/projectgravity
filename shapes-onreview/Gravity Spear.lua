local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local targets = x6.target_positions or {}
	local target = targets[((d.id or 1) - 1) % math.max(1, #targets) + 1] or cen + Vector3.new(0, 0, -300)
	local direction = target - cen
	if direction.Magnitude < 0.01 then direction = Vector3.new(0, 0, -1) else direction = direction.Unit end
	local range = math.max(1, c.k11 or 900)
	local point = cen + direction * ((t * (c.k12 or 260) + (d.id or 1) * 8) % range)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Spear Range", Min = 100, Max = 2000, Key = "k11", Default = 900 },
	{ Type = "Slider", Name = "Spear Speed", Min = 20, Max = 800, Key = "k12", Default = 260 }
}

return M
