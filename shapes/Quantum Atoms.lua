local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Quantum Atoms"
	local s, R, Orbits = (c.k13 or 15) * x9.c2, (c.k11 or 60), (c.k15 or 3)
			if not d.v1 then
				d.v1 = math.random(1, Orbits)
			end
			if not d.v6 then
				d.v6 = math.random() * math.pi * 2
			end
			local cx, cz, tilt = math.cos(d.v6 + (t * s)) * R, math.sin(d.v6 + (t * s)) * R, (math.pi / Orbits) * (d.v1 - 1)
			local tx, ty, sp =
				0 * math.sin(tilt) + cx * math.cos(tilt),
				0 * math.cos(tilt) - cx * math.sin(tilt),
				(math.pi * 2 / Orbits) * (d.v1 - 1)
			return (
				(cen + Vector3.new(tx * math.cos(sp) - cz * math.sin(sp), ty, tx * math.sin(sp) + cz * math.cos(sp))) - wp
			) * (x1.k10 * x9.c1)
end

return M