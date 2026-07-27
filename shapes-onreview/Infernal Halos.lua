local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local count = math.max(1, #(x6.active_array or {}))
	local index = ((d.id or 1) - 1) % count
	local ring = index % 2 == 0 and 1 or -1
	local angle = index * math.pi * 2 / count + t * (c.k12 or 5) * ring
	local radius = c.k11 or 160
	local point = cen + Vector3.new(math.cos(angle) * radius, ring * (c.k13 or 45), math.sin(angle) * radius)
	return (point - p.Position) * (x1.k10 * x9.c1), point
end

M.Controls = {
	{ Type = "Slider", Name = "Halo Radius", Min = 20, Max = 650, Key = "k11", Default = 160 },
	{ Type = "Slider", Name = "Halo Speed", Min = 1, Max = 20, Key = "k12", Default = 5 },
	{ Type = "Slider", Name = "Halo Offset", Min = 5, Max = 200, Key = "k13", Default = 45 }
}

return M
