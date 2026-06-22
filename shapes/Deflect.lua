local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Deflect"
	local range, speed = c.k11 or 50, c.k12 or 500
			if tc.Magnitude < range then
				return (wp - wc).Unit * speed
			end
end

return M