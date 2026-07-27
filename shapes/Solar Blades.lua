local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local angle = index * math.pi * 2 / count
	local strike = math.abs(math.sin(t * (c.k12 or 7) + index * 0.4))
	local radius = (c.k11 or 200) * strike
	local point = cen + Vector3.new(math.cos(angle) * radius, (1 - strike) * 180, math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Blade Radius", Min = 30, Max = 700, Key = "k11", Default = 200 },
	{ Type = "Slider", Name = "Strike Rate", Min = 1, Max = 20, Key = "k12", Default = 7 }
}

return M
