local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Torus Knot"
	local p_knot, q_knot, s = (c.k11 or 3), (c.k12 or 2), (c.k13 or 10) * x9.c2
			local R, r = (c.k14 or 50), (c.k15 or 20)
			if not d.v6 then
				d.v6 = math.random() * math.pi * 2
			end
			local phase = (t * s) + d.v6
			local cos_q = math.cos(q_knot * phase)
			local tx = (R + r * cos_q) * math.cos(p_knot * phase)
			local tz = (R + r * cos_q) * math.sin(p_knot * phase)
			local ty = r * math.sin(q_knot * phase)
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

return M