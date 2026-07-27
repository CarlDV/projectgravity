local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local range = math.max(1, c.k11 or 700)
	local target = cen + Vector3.new(0, 0, -range)
	local progress = ((t * (c.k12 or 200) + (d.id or 1) * 24) % range) / range
	local wave = math.sin(progress * math.pi * 6 + t * 8 + (d.id or 1)) * (c.k13 or 35)
	local point = cen:Lerp(target, progress) + Vector3.new(wave, wave * 0.35, 0)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Torpedo Range", Min = 100, Max = 2000, Key = "k11", Default = 700 },
	{ Type = "Slider", Name = "Torpedo Speed", Min = 20, Max = 700, Key = "k12", Default = 200 },
	{ Type = "Slider", Name = "Wake Width", Min = 1, Max = 120, Key = "k13", Default = 35 }
}

return M
