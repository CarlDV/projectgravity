local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "DNA Helix"
	local R, H, s, freq = (c.k11 or 20), (c.k12 or 80), (c.k13 or 10) * x9.c2, (c.k14 or 50)
			if not d.v1 then
				d.v1 = math.random()
			end
			if not d.v2 then
				d.v2 = math.random(0, 1)
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			local is_rung = d.v3 > 0.8
			local phase = (t * s) + (d.v1 * freq)
			local offset = d.v2 * math.pi
			local tx, ty, tz = 0, (d.v1 - 0.5) * H, 0
			if is_rung then
				local rung_pos = math.floor(d.v1 * 10) / 10
				local rung_phase = (t * s) + (rung_pos * freq)
				local rung_t = (math.random() - 0.5) * 2
				tx = rung_t * R * math.cos(rung_phase)
				tz = rung_t * R * math.sin(rung_phase)
				ty = (rung_pos - 0.5) * H
			else
				tx = R * math.cos(phase + offset)
				tz = R * math.sin(phase + offset)
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

return M