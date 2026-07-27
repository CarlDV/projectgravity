local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local targets = x6.target_positions or {}
	local target = targets[((d.id or 1) - 1) % math.max(1, #targets) + 1] or cen
	local direction = target - cen
	if direction.Magnitude < 0.01 then direction = Vector3.new(0, 0, -1) else direction = direction.Unit end
	local range = math.max(1, c.k11 or 1000)
	local reach = (t * (c.k12 or 300) + (d.id or 1) * 40) % range
	local pulse = 1 + math.max(0, math.sin(t * (c.k13 or 6))) * 0.5
	local point = cen + direction * reach * pulse
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Cannon Range", Min = 100, Max = 2500, Key = "k11", Default = 1000 },
	{ Type = "Slider", Name = "Cannon Speed", Min = 20, Max = 900, Key = "k12", Default = 300 },
	{ Type = "Slider", Name = "Cannon Pulse", Min = 1, Max = 20, Key = "k13", Default = 6 }
}

return M
