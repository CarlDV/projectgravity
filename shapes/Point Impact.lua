local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Point Impact"
	local s = 500
			local radius = c.k11 or 0
			if x1.ImpactManual then
				if not x1.IsLaunching then
					s = 1
					radius = 35
				else
					s = 1000
					radius = 0
				end
			end
			if not d.v5 then
				d.v5 = math.random() - 0.5
			end
			if not d.v4 then
				d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			end


			local cx, sx = math.cos(t * s), math.sin(t * s)
			local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx, d.v4.Y + d.v5, d.v4.X * sx + d.v4.Z * cx).Unit


			local target_pos = cen + (rd * radius)
			return (target_pos - wp) * 5000
end

return M