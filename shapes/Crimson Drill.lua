local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local length = math.max(1, c.k11 or 280)
	local drill = (t * (c.k12 or 220) + (d.id or 1) * 17) % length
	local angle = t * (c.k13 or 5) + (d.id or 1) * 0.5
	local point = cen + Vector3.new(math.cos(angle) * drill * 0.25, math.sin(angle * 2) * 20, -drill)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Drill Length", Min = 50, Max = 1000, Key = "k11", Default = 280 },
	{ Type = "Slider", Name = "Drill Speed", Min = 20, Max = 800, Key = "k12", Default = 220 },
	{ Type = "Slider", Name = "Drill Spin", Min = 1, Max = 20, Key = "k13", Default = 5 }
}

return M
