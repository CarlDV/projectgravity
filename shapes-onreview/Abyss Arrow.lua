local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local target = (x6.target_positions or {})[((d.id or 1) - 1) % math.max(1, #(x6.target_positions or {})) + 1]
	if not target then target = cen + Vector3.new(0, 0, -500) end
	local direction = target - cen
	if direction.Magnitude < 0.01 then direction = Vector3.new(0, 0, -1) else direction = direction.Unit end
	local travel = (t * (c.k12 or 250) + (d.id or 1) * 19) % math.max(1, c.k11 or 800)
	local point = cen + direction * travel + Vector3.new(0, math.sin(t * 10 + (d.id or 1)) * 8, 0)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Arrow Range", Min = 100, Max = 2000, Key = "k11", Default = 800 },
	{ Type = "Slider", Name = "Arrow Speed", Min = 20, Max = 800, Key = "k12", Default = 250 }
}

return M
