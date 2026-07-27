local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local targets = x6.target_positions or {}
	local target = targets[((d.id or 1) - 1) % math.max(1, #targets) + 1] or cen + Vector3.new(0, 0, -400)
	local ray = target - cen
	if ray.Magnitude < 0.01 then ray = Vector3.new(0, 0, -1) else ray = ray.Unit end
	local side = Vector3.new(-ray.Z, 0, ray.X)
	if side.Magnitude < 0.01 then side = Vector3.new(1, 0, 0) else side = side.Unit end
	local offset = math.sin(t * (c.k12 or 8) + (d.id or 1)) * (c.k11 or 25)
	local point = cen + ray * ((t * (c.k13 or 240) + (d.id or 1) * 20) % 1000) + side * offset
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Javelin Spread", Min = 1, Max = 100, Key = "k11", Default = 25 },
	{ Type = "Slider", Name = "Javelin Wave", Min = 1, Max = 20, Key = "k12", Default = 8 },
	{ Type = "Slider", Name = "Javelin Speed", Min = 20, Max = 800, Key = "k13", Default = 240 }
}

return M
