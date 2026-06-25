-- BUNDLED WITH MAXITOM BUNDLER

local __MODULES = {}

__MODULES["shapes/Alien Mothership.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Alien Mothership"
	local Radius, CoreHeight, s, BeamLen = (c.k11 or 120), (c.k12 or 40), (c.k13 or 15) * x9.c2, (c.k14 or 200)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.6 then
					d.v1 = 1
				elseif roll < 0.8 then
					d.v1 = 2
				else
					d.v1 = 3
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.random() * math.pi * 2
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0

			if d.v1 == 1 then

				local r = Radius * math.sqrt(d.v3)
				local y_curve = math.sin(math.acos(d.v3)) * CoreHeight
				if d.v2 > math.pi then
					y_curve = -y_curve
				end

				local rot = d.v4 + phase
				tx = r * math.cos(rot)
				tz = r * math.sin(rot)
				ty = y_curve
			elseif d.v1 == 2 then

				local beam_prog = (d.v3 + phase * 2) % 1
				ty = -CoreHeight - (beam_prog * BeamLen)
				local beam_rad = 10 + (beam_prog * Radius * 0.4)
				local rot = d.v2 + phase * 3
				tx = beam_rad * math.cos(rot)
				tz = beam_rad * math.sin(rot)
			else

				local group = math.floor(d.v3 * 3)
				local orbit_phase = phase * 0.5 + (group * math.pi * 2 / 3)
				local orbit_r = Radius * 1.5
				local cx = orbit_r * math.cos(orbit_phase)
				local cz = orbit_r * math.sin(orbit_phase)
				local cy = math.sin(phase * 2 + group) * 20

				local local_rot = d.v4 + phase * 5
				local local_r = math.random() * 10
				tx = cx + local_r * math.cos(local_rot)
				tz = cz + local_r * math.sin(local_rot)
				ty = cy + (math.random() - 0.5) * 5
			end

			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Radius", Min = 50, Max = 400, Key = "k11" },
	{ Type = "Slider", Name = "Core Height", Min = 10, Max = 150, Key = "k12" },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Beam Length", Min = 50, Max = 500, Key = "k14" }
}

return M
end

__MODULES["shapes/Arcane Orrery.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Arcane Orrery"
	local R, Arms, s, H = (c.k11 or 120), (c.k12 or 4), (c.k13 or 8) * x9.c2, (c.k14 or 200)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.12 then
					d.v1 = 1
				elseif roll < 0.30 then
					d.v1 = 2
				elseif roll < 0.48 then
					d.v1 = 3
				elseif roll < 0.72 then
					d.v1 = 4
				else
					d.v1 = 5
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.random() * math.pi * 2
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0

			if d.v1 == 1 then

				local prog = d.v3
				ty = (prog - 0.5) * H
				local helix_r = 12 + math.sin(prog * math.pi * 6) * 3
				local strand = (d.v2 > math.pi) and math.pi or 0
				local helix_angle = prog * math.pi * 8 + phase * 3 + strand
				tx = helix_r * math.cos(helix_angle)
				tz = helix_r * math.sin(helix_angle)
				ty = ty + math.sin(phase * 2 + prog * 10) * 3
			elseif d.v1 == 2 then

				local teeth = 16
				local gear_r = R * 0.5
				local gear_phase = d.v2 + phase
				local tooth_bump = math.abs(math.sin(gear_phase * teeth / 2)) * 12
				local r = gear_r + tooth_bump
				tx = r * math.cos(gear_phase)
				tz = r * math.sin(gear_phase)
				ty = H * 0.4 + math.sin(phase + d.v2) * 3
			elseif d.v1 == 3 then

				local teeth = 20
				local gear_r = R * 0.8
				local gear_phase = d.v2 - phase * 0.7
				local tooth_bump = math.abs(math.sin(gear_phase * teeth / 2)) * 15
				local r = gear_r + tooth_bump
				tx = r * math.cos(gear_phase)
				tz = r * math.sin(gear_phase)
				ty = H * 0.4 + math.sin(phase * 1.3 + d.v2) * 5
			elseif d.v1 == 4 then

				local arm_idx = math.floor(d.v2 / (math.pi * 2) * Arms)
				local arm_angle = (arm_idx / Arms) * math.pi * 2 + phase * 0.3
				local dist = d.v3 * R
				local planet_r = 8 + math.sin(d.v4 * 6) * 4
				local planet_phase = d.v4 + phase * 4
				tx = dist * math.cos(arm_angle) + planet_r * math.cos(planet_phase)
				tz = dist * math.sin(arm_angle) + planet_r * math.sin(planet_phase)
				ty = H * 0.5 + math.sin(arm_angle * 3 + phase) * 15 + planet_r * math.sin(planet_phase * 0.5) * 0.5
			else

				local belt_r = R * 1.1
				local belt_phase = d.v2 + phase * 0.5
				local tilt = math.pi * 0.25
				local bx = belt_r * math.cos(belt_phase)
				local bz = belt_r * math.sin(belt_phase)
				local by = 0
				local cy, sy2 = math.cos(tilt), math.sin(tilt)
				local ry = by * cy - bz * sy2
				local rz = by * sy2 + bz * cy
				tx = bx
				ty = H * 0.8 + ry
				tz = rz

				local node = math.floor(belt_phase / (math.pi * 2) * 12) * (math.pi * 2 / 12)
				local near_node = math.abs(belt_phase % (math.pi * 2 / 12) - math.pi / 12)
				if near_node < 0.15 then
					local pulse = math.sin(phase * 3 + node * 5) * 8
					tx = tx + math.cos(d.v4) * pulse
					tz = tz + math.sin(d.v4) * pulse
				end
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Orrery Radius", Min = 40, Max = 300, Key = "k11" },
	{ Type = "Slider", Name = "Arm Count", Min = 2, Max = 8, Key = "k12", IntOnly = true },
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 50, Key = "k13" },
	{ Type = "Slider", Name = "Height", Min = 50, Max = 500, Key = "k14" }
}

return M
end

__MODULES["shapes/Aurora Borealis.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Aurora Borealis"
	local Span, Height, s, RibbonWidth = (c.k11 or 600), (c.k12 or 300), (c.k13 or 15) * x9.c2, (c.k14 or 100)
			if not d.v1 then
				d.v1 = (math.random() - 0.5) * 2
			end
			if not d.v2 then
				d.v2 = math.random()
			end
			if not d.v3 then
				d.v3 = math.random() * math.pi * 2
			end

			local phase = t * s


			local x_pos = d.v1 * (Span * 0.5)


			local fold_1 = math.sin((x_pos / 100) + phase) * (Span * 0.1)
			local fold_2 = math.sin((x_pos / 50) - phase * 1.5) * (Span * 0.05)
			local z_pos = fold_1 + fold_2


			z_pos = z_pos + math.pow(d.v1, 2) * (Span * 0.2)


			local y_pos = Height + (d.v2 * RibbonWidth)

			y_pos = y_pos + math.sin((x_pos / 100) + phase * 2 + d.v3) * (RibbonWidth * 0.5)

			return ((cen + Vector3.new(x_pos, y_pos, z_pos)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Sky Span", Min = 100, Max = 2000, Key = "k11" },
	{ Type = "Slider", Name = "Sky Height", Min = 50, Max = 1500, Key = "k12" },
	{ Type = "Slider", Name = "Flow Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Band Width", Min = 50, Max = 500, Key = "k14" }
}

return M
end

__MODULES["shapes/Big Ring Things.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Big Ring Things"
	local rc = c.k11 or 2
			if not d.v1 or d.v2 ~= rc then
				d.v1 = math.random(1, rc)
				d.v2 = rc
				d.v3 = math.random() * math.pi * 2
			end
			local gap, spd = c.k12 or 170, (x9.c2 - (d.v1 - 1) * x9.c3) * (c.k13 or 10)
			if d.v1 % 2 == 0 then
				spd = -spd
			end
			local a = d.v3 + (t * spd)
			local tx, tz = math.cos(a) * (x1.k9 + (d.v1 - 1) * gap), math.sin(a) * (x1.k9 + (d.v1 - 1) * gap)
			local ty = 0
			local sw = math.sin(t * (c.k16 or x9.c4) + d.v1) * math.rad(c.k15 or 12)
			local rx, rz = sw, sw * 0.5
			if rx ~= 0 then
				local cy, sy = math.cos(rx), math.sin(rx)
				local ny = ty * cy - tz * sy
				local nz = ty * sy + tz * cy
				ty, tz = ny, nz
			end
			if rz ~= 0 then
				local cx, sx = math.cos(rz), math.sin(rz)
				local nx = tx * cx - ty * sx
				local ny = tx * sx + ty * cx
				tx, ty = nx, ny
			end
			local tp = cen + Vector3.new(tx, ty, tz)
			local ho = c.k14 or 5
			if tp.Y < ho then
				tp = Vector3.new(tp.X, ho, tp.Z)
			end
			return (tp - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Ring Count", Min = 1, Max = 20, Key = "k11", IntOnly = true },
	{ Type = "Slider", Name = "Ring Gap", Min = 50, Max = 300, Key = "k12" },
	{ Type = "Slider", Name = "Ring Speed", Min = 0, Max = 200, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Height Offset", Min = 0, Max = 100, Key = "k14" },
	{ Type = "Slider", Name = "Tilt Angle", Min = 0, Max = 90, Key = "k15" },
	{ Type = "Slider", Name = "Tilt Speed", Min = 0, Max = 50, Key = "k16", Div = 10 }
}

return M
end

__MODULES["shapes/Black Hole.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Black Hole"
	local event_horizon, disk_radius, spin, disk_height =
				(c.k11 or 40), (c.k12 or 100), (c.k13 or 15) * x9.c2, (c.k14 or 50)
			if not d.v2 then
				d.v2 = math.random()
			end
			if not d.v6 then
				d.v6 = math.random() * math.pi * 2
			end
			local rad = event_horizon + (d.v2 * (disk_radius - event_horizon))
			local local_spin = spin * (disk_radius / rad)
			local disk_phase = (t * local_spin) + d.v6
			local thickness = (math.random() - 0.5) * disk_height * math.sin(disk_phase * 2) * (event_horizon / rad)
			local tx = rad * math.cos(disk_phase)
			local tz = rad * math.sin(disk_phase)
			return ((cen + Vector3.new(tx, thickness, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Event Horizon", Min = 10, Max = 200, Key = "k11" },
	{ Type = "Slider", Name = "Disk Radius", Min = 50, Max = 2000, Key = "k12" },
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 200, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Disk Height", Min = 5, Max = 200, Key = "k14" }
}

return M
end

__MODULES["shapes/Celestial Ribbon.lua"] = function()
local M = {}

function M.px(t, c, x6, x9)
	if not x6.pre["Celestial Ribbon"] then
		x6.pre["Celestial Ribbon"] = table.create(200)
	end
	if not x6.pre["Celestial Ribbon_B"] then
		x6.pre["Celestial Ribbon_B"] = table.create(200)
	end
	local r = x6.pre["Celestial Ribbon"]
	local r2 = x6.pre["Celestial Ribbon_B"]
	table.clear(r)
	table.clear(r2)
	local res = 200
	local s, w, h, l = (c.k13 or 10) * x9.c2, (c.k11 or 8), c.k14 or 50, (c.k16 or x9.c5) * 100
	local R = (c.k17 or 150)
	for i = 1, res do
		local pc = (i - 1) / (res - 1)
		local ph = (t * s) - (pc * (l * x9.c2))
		
		local function get_pos(phi)
			return Vector3.new(math.cos(phi) * R, math.sin(phi * 0.577) * h, math.sin(phi * 1.618) * R)
		end
		
		local p_cur = get_pos(ph)
		local p_next = get_pos(ph - 0.05)
		local T = (p_next - p_cur).Unit
		if T.Magnitude ~= T.Magnitude then T = Vector3.xAxis end

		local Rv = T:Cross(Vector3.yAxis)
		if Rv.Magnitude < 0.001 then Rv = Vector3.xAxis end
		Rv = Rv.Unit
		
		local trn = Rv * math.cos(ph * 0.5) + (T:Cross(Rv)) * math.sin(ph * 0.5)
		r[i] = { p = p_cur, t = trn.Unit, ph = ph }

		local ph2 = ph + 2.37
		local function get_pos2(phi)
			return Vector3.new(math.cos(phi * 1.247) * R, math.sin(phi * 0.693) * h, math.sin(phi * 0.831) * R)
		end
		
		local p_cur2 = get_pos2(ph2)
		local p_next2 = get_pos2(ph2 - 0.05)
		local T2 = (p_next2 - p_cur2).Unit
		if T2.Magnitude ~= T2.Magnitude then T2 = Vector3.xAxis end

		local Rv2 = T2:Cross(Vector3.yAxis)
		if Rv2.Magnitude < 0.001 then Rv2 = Vector3.xAxis end
		Rv2 = Rv2.Unit
		
		local trn2 = Rv2 * math.cos(ph2 * 0.5) + (T2:Cross(Rv2)) * math.sin(ph2 * 0.5)
		r2[i] = { p = p_cur2, t = trn2.Unit, ph = ph2 }
	end
end

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local md = "Celestial Ribbon"
	local w = c.k11 or 8
	if not d.v7 then
		d.v7 = math.random() - 0.5
		d.v6 = math.random()
	end
	if c.k19 and not d.v9 then
		d.v9 = math.random(0, 1)
	end

	local spine_key = md
	if c.k19 and d.v9 == 1 then
		spine_key = md .. "_B"
	end

	local p_data = x6.pre and x6.pre[spine_key]
	local fin
	if p_data and #p_data > 0 then
		local idx = math.floor(d.v6 * (#p_data - 1)) + 1
		local node = p_data[idx]
		fin = node.p
			+ (node.t * (d.v7 * w))
			+ (c.k18 and (node.t * math.sin(node.ph * 8)) * (w * 2.0) or Vector3.zero)
	else
		local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
		local isB = c.k19 and d.v9 == 1
		local ph = (t * s) - (d.v6 * (l * x9.c2)) + (isB and 2.37 or 0)
		local R = (c.k17 or 150)
		local function get_pos_fallback(phi, is_b)
			if is_b then
				return Vector3.new(math.cos(phi * 1.247) * R, math.sin(phi * 0.693) * h, math.sin(phi * 0.831) * R)
			else
				return Vector3.new(math.cos(phi) * R, math.sin(phi * 0.577) * h, math.sin(phi * 1.618) * R)
			end
		end

		local p_cur = get_pos_fallback(ph, isB)
		local p_next = get_pos_fallback(ph - 0.05, isB)
		local T = (p_next - p_cur).Unit
		if T.Magnitude ~= T.Magnitude then T = Vector3.xAxis end

		local Rvec = T:Cross(Vector3.yAxis)
		if Rvec.Magnitude < 0.001 then
			Rvec = Vector3.xAxis
		end
		Rvec = Rvec.Unit
		local trn = Rvec * math.cos(ph * 0.5) + (T:Cross(Rvec)) * math.sin(ph * 0.5)
		
		fin = p_cur
			+ (trn.Unit * (d.v7 * w))
			+ (c.k18 and (trn.Unit * math.sin(ph * 8)) * (w * 2.0) or Vector3.zero)
	end
	return ((cen + fin) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Ribbon Speed", Min = 1, Max = 300, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Ribbon Length", Min = 10, Max = 500, Key = "k16", Div = 100 },
	{ Type = "Slider", Name = "Ribbon Width", Min = 1, Max = 150, Key = "k11", Div = 2 },
	{ Type = "Slider", Name = "Height Limit", Min = 0, Max = 200, Key = "k14" },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 800, Key = "k17" },
	{ Type = "Toggle", Name = "Enable Slither", Key = "k18" },
	{ Type = "Toggle", Name = "Dual Dragons", Key = "k19" }
}

return M
end

__MODULES["shapes/Cosmic Comet.lua"] = function()
local M = {}

function M.px(t, c, x6, x9)
	if not x6.pre["Cosmic Comet"] then
		x6.pre["Cosmic Comet"] = table.create(200)
	end
	local r = x6.pre["Cosmic Comet"]
	table.clear(r)
	local res = 200
	local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
	local R = (c.k17 or 150)
	for i = 1, res do
		local pc = (i - 1) / (res - 1)
		local ph = (t * s) - (pc * (l * x9.c2))
		r[i] = Vector3.new(math.cos(ph) * R, math.sin(ph * (c.k15 or 5) * x9.c7) * h, math.sin(ph) * R)
	end
end

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Cosmic Comet"
	local hr, ts = (c.k11 or 4), (c.k12 or 50) * x9.c7
			if not d.v4 then
				d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
				d.v6 = math.random()
			end
			if not d.v8 then
				d.v8 = math.random()
			end
			local p_data = x6.pre and x6.pre[md]
			local center_pos
			if p_data and #p_data > 0 then
				local idx = math.floor(d.v6 * (#p_data - 1)) + 1
				center_pos = p_data[idx]
			else
				local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
				local ph = (t * s) - (d.v6 * (l * x9.c2))
				local R = (c.k17 or 150)
				center_pos = Vector3.new(math.cos(ph) * R, math.sin(ph * (c.k15 or 5) * x9.c7) * h, math.sin(ph) * R)
			end
			return ((cen + center_pos + (d.v4 * (d.v8 * (hr + (d.v6 * d.v6 * 30 * ts))))) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Comet Speed", Min = 1, Max = 300, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Tail Length", Min = 10, Max = 500, Key = "k16", Div = 100 },
	{ Type = "Slider", Name = "Head Radius", Min = 1, Max = 50, Key = "k11", Div = 2 },
	{ Type = "Slider", Name = "Tail Spread", Min = 0, Max = 200, Key = "k12" },
	{ Type = "Slider", Name = "Height Limit", Min = 0, Max = 200, Key = "k14" },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 800, Key = "k17" }
}

return M
end

__MODULES["shapes/DNA Helix.lua"] = function()
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

M.Controls = {
	{ Type = "Slider", Name = "Radius", Min = 5, Max = 200, Key = "k11" },
	{ Type = "Slider", Name = "Height", Min = 10, Max = 500, Key = "k12" },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Frequency", Min = 10, Max = 200, Key = "k14" }
}

return M
end

__MODULES["shapes/Deflect.lua"] = function()
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

M.Controls = {
	{ Type = "Slider", Name = "Range", Min = 10, Max = 500, Key = "k11" },
	{ Type = "Slider", Name = "Force", Min = 50, Max = 5000, Key = "k12" }
}

return M
end

__MODULES["shapes/Dyson Sphere.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Dyson Sphere"
	local R, ShellDensity, s = (c.k11 or 150), (c.k12 or 8), (c.k13 or 10) * x9.c2
			if not d.v1 then
				d.v1 = math.random()
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random() * math.pi
			end
			if not d.v4 then
				local roll = math.random()
				if roll < 0.15 then
					d.v4 = 1
				elseif roll < 0.85 then
					d.v4 = 2
				else
					d.v4 = 3
				end
			end

			local phase = (t * s)

			if d.v4 == 1 then

				local core_r = 15 + math.sin(phase * 2) * 2
				local tx = core_r * math.sin(d.v3) * math.cos(d.v2 + phase * 3)
				local ty = core_r * math.cos(d.v3)
				local tz = core_r * math.sin(d.v3) * math.sin(d.v2 + phase * 3)
				return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
			elseif d.v4 == 2 then

				local p_theta = math.floor(d.v2 * ShellDensity) / ShellDensity
				local p_phi = math.floor(d.v3 * (ShellDensity / 2)) / (ShellDensity / 2)
				local rot_theta = p_theta + (phase * 0.2)

				local tx = R * math.sin(p_phi) * math.cos(rot_theta)
				local ty = R * math.cos(p_phi)
				local tz = R * math.sin(p_phi) * math.sin(rot_theta)
				return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
			else

				local stream_progress = (d.v1 + phase * 1.5) % 1
				local current_r = 15 + stream_progress * (R - 15)

				local p_theta = math.floor(d.v2 * 10) / 10
				local p_phi = math.floor(d.v3 * 10) / 10
				local rot_theta = p_theta + (phase * 0.2)

				local tx = current_r * math.sin(p_phi) * math.cos(rot_theta)
				local ty = current_r * math.cos(p_phi)
				local tz = current_r * math.sin(p_phi) * math.sin(rot_theta)
				return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
			end
end

M.Controls = {
	{ Type = "Slider", Name = "Radius", Min = 50, Max = 400, Key = "k11" },
	{ Type = "Slider", Name = "Grid Density", Min = 2, Max = 50, Key = "k12" },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 100, Key = "k13", Div = 10 }
}

return M
end

__MODULES["shapes/Eldritch Binding.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Eldritch Binding"
	local R, H, s, Tendrils = (c.k11 or 100), (c.k12 or 200), (c.k13 or 5) * x9.c2, (c.k14 or 8)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.15 then
					d.v1 = 1
				elseif roll < 0.30 then
					d.v1 = 2
				elseif roll < 0.50 then
					d.v1 = 3
				elseif roll < 0.62 then
					d.v1 = 4
				elseif roll < 0.85 then
					d.v1 = 5
				else
					d.v1 = 6
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.random()
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0

			if d.v1 == 1 then

				local star_pts = 5
				local edge_idx = math.floor(d.v2 / (math.pi * 2) * star_pts)
				local a1 = (edge_idx / star_pts) * math.pi * 2 + phase
				local a2 = ((edge_idx + 2) % star_pts / star_pts) * math.pi * 2 + phase
				local lerp_t = d.v3
				local x1p = R * math.cos(a1)
				local z1p = R * math.sin(a1)
				local x2p = R * math.cos(a2)
				local z2p = R * math.sin(a2)
				tx = x1p + (x2p - x1p) * lerp_t
				tz = z1p + (z2p - z1p) * lerp_t
				ty = 10
			elseif d.v1 == 2 then

				local star_pts = 6
				local edge_idx = math.floor(d.v2 / (math.pi * 2) * star_pts)
				local a1 = (edge_idx / star_pts) * math.pi * 2 - phase
				local a2 = ((edge_idx + 2) % star_pts / star_pts) * math.pi * 2 - phase
				local lerp_t = d.v3
				tx = R * math.cos(a1) + (R * math.cos(a2) - R * math.cos(a1)) * lerp_t
				tz = R * math.sin(a1) + (R * math.sin(a2) - R * math.sin(a1)) * lerp_t
				ty = H
			elseif d.v1 == 3 then

				local chain_idx = math.floor(d.v2 / (math.pi * 2) * 10)
				local lower_a = (chain_idx % 5) / 5 * math.pi * 2 + phase
				local upper_a = (chain_idx % 6) / 6 * math.pi * 2 - phase
				local prog = d.v3
				tx = R * math.cos(lower_a) * (1 - prog) + R * math.cos(upper_a) * prog
				tz = R * math.sin(lower_a) * (1 - prog) + R * math.sin(upper_a) * prog
				ty = 10 + prog * (H - 10)

				ty = ty - math.sin(prog * math.pi) * 15
			elseif d.v1 == 4 then

				local node_count = 11
				local node_idx = math.floor(d.v2 / (math.pi * 2) * node_count)
				local is_lower = node_idx < 5
				local node_a
				if is_lower then
					node_a = (node_idx / 5) * math.pi * 2 + phase
					ty = 10
				else
					node_a = ((node_idx - 5) / 6) * math.pi * 2 - phase
					ty = H
				end
				local pulse = math.sin(phase * 3 + node_idx * 2) * 0.5 + 0.5
				local node_r = R + pulse * 15
				tx = node_r * math.cos(node_a) + math.cos(d.v4 * math.pi * 2) * pulse * 8
				tz = node_r * math.sin(node_a) + math.sin(d.v4 * math.pi * 2) * pulse * 8
			elseif d.v1 == 5 then

				local tendril_idx = math.floor(d.v2 / (math.pi * 2) * Tendrils)
				local base_angle = (tendril_idx / Tendrils) * math.pi * 2
				local prog = (d.v3 + phase * 0.5) % 1
				ty = prog * H
				local snake = math.sin(prog * math.pi * 6 + phase * 2 + tendril_idx) * 15
				local tendril_r = 15 + snake + d.v4 * 3
				tx = tendril_r * math.cos(base_angle + prog * math.pi * 2)
				tz = tendril_r * math.sin(base_angle + prog * math.pi * 2)
			else

				local phi = d.v2
				local theta = d.v3 * math.pi
				local breath = math.sin(phase * 0.5) * 0.2 + 1
				local shell_r = R * 1.3 * breath
				tx = shell_r * math.sin(theta) * math.cos(phi + phase * 0.1)
				tz = shell_r * math.sin(theta) * math.sin(phi + phase * 0.1)
				ty = H * 0.5 + shell_r * math.cos(theta)
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Sigil Radius", Min = 30, Max = 250, Key = "k11" },
	{ Type = "Slider", Name = "Tower Height", Min = 50, Max = 500, Key = "k12" },
	{ Type = "Slider", Name = "Rotation Speed", Min = 1, Max = 30, Key = "k13" },
	{ Type = "Slider", Name = "Tendril Count", Min = 3, Max = 16, Key = "k14", IntOnly = true }
}

return M
end

__MODULES["shapes/Fractal Web.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Fractal Web"
	local HexR, Depth, BSpeed, RSpeed = (c.k11 or 40), (c.k12 or 3), (c.k13 or 3) * x9.c2, (c.k14 or 5) * x9.c2
			if not d.v1 then
				d.v1 = math.random(0, math.max(1, Depth - 1))
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.floor(math.random() * 6)
			end

			local phase = t * RSpeed
			local breath = math.sin(t * BSpeed) * 0.3 + 1
			local level = d.v1
			local tx, ty, tz = 0, 0, 0


			local accumulated_x, accumulated_z = 0, 0
			local current_r = HexR
			for lv = 0, level do
				local vertex_idx
				if lv == level then
					vertex_idx = d.v4
				else
					vertex_idx = math.floor(d.v2 / (math.pi * 2) * 6 + lv) % 6
				end
				local angle = (vertex_idx / 6) * math.pi * 2 + phase * (1 / (lv + 1))
				local offset_r = current_r * breath * (1 + lv * 0.3)
				accumulated_x = accumulated_x + offset_r * math.cos(angle)
				accumulated_z = accumulated_z + offset_r * math.sin(angle)
				current_r = current_r * 0.5
			end


			local edge_prog = d.v3
			local next_vertex = (d.v4 + 1) % 6
			local cur_angle = (d.v4 / 6) * math.pi * 2 + phase * (1 / (level + 1))
			local nxt_angle = (next_vertex / 6) * math.pi * 2 + phase * (1 / (level + 1))
			local edge_r = current_r * breath * (1 + level * 0.3)
			local ex = edge_r * math.cos(cur_angle) * (1 - edge_prog) + edge_r * math.cos(nxt_angle) * edge_prog
			local ez = edge_r * math.sin(cur_angle) * (1 - edge_prog) + edge_r * math.sin(nxt_angle) * edge_prog

			tx = accumulated_x + ex
			tz = accumulated_z + ez
			ty = 50 + level * 20 + math.sin(phase + d.v2) * 5

			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Hex Radius", Min = 15, Max = 120, Key = "k11" },
	{ Type = "Slider", Name = "Depth", Min = 2, Max = 4, Key = "k12" },
	{ Type = "Slider", Name = "Breath Speed", Min = 1, Max = 20, Key = "k13" },
	{ Type = "Slider", Name = "Rotation Speed", Min = 1, Max = 30, Key = "k14" }
}

return M
end

__MODULES["shapes/Galactic Web.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Galactic Web"
	local Spread, SpinSpeed, DriftTime = (c.k11 or 400), (c.k12 or 10) * x9.c2, (c.k13 or 5)
			if not d.v1 then
				d.v1 = (math.random() - 0.5) * 2
			end
			if not d.v2 then
				d.v2 = (math.random() - 0.5) * 2
			end
			if not d.v3 then
				d.v3 = (math.random() - 0.5) * 2
			end
			if not d.v4 then
				d.v4 = math.random() * math.pi * 2
			end
			if not d.v5 then
				d.v5 = (math.random() - 0.5) * 2
			end
			if not d.rot_axis then
				local rx, ry, rz = math.random() - 0.5, math.random() - 0.5, math.random() - 0.5
				local len = math.sqrt(rx * rx + ry * ry + rz * rz)
				if len == 0 then
					rx, ry, rz, len = 0, 1, 0, 1
				end
				d.rot_axis = Vector3.new(rx / len, ry / len, rz / len)
			end

			local phase = t * SpinSpeed + d.v4
			local drift_phase = (t * DriftTime) + d.v4

			local px = d.v1 * Spread
			local py = d.v2 * Spread
			local pz = d.v3 * Spread

			local p_vec = Vector3.new(px, py, pz)
			local k = d.rot_axis
			local cos_p = math.cos(phase)
			local sin_p = math.sin(phase)

			local cross = k:Cross(p_vec)
			local dot = k:Dot(p_vec)
			local rotated = p_vec * cos_p + cross * sin_p + k * (dot * (1 - cos_p))

			local drift_x = math.sin(drift_phase) * d.v5 * (Spread * 0.25)
			local drift_y = math.cos(drift_phase * 0.8) * d.v5 * (Spread * 0.25)
			local drift_z = math.sin(drift_phase * 1.2) * d.v5 * (Spread * 0.25)

			local rx = rotated.X + drift_x
			local rz = rotated.Z + drift_z

			local h_lim = c.k24 or 200
			local vertical_scale = h_lim / math.max(1, Spread)
			local final_y = rotated.Y * vertical_scale + drift_y

			if c.k23 then
				final_y = math.abs(final_y)
			end

			return ((cen + Vector3.new(rx, final_y, rz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Radius Spread", Min = 50, Max = 1500, Key = "k11" },
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 100, Key = "k12", Div = 10 },
	{ Type = "Slider", Name = "Drift Speed", Min = 1, Max = 50, Key = "k13" },
	{ Type = "Slider", Name = "Web Height Limit", Min = 0, Max = 1500, Key = "k24" },
	{ Type = "Toggle", Name = "Cut In Half", Key = "k23" }
}

return M
end

__MODULES["shapes/Gods Call.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Gods Call"
	local ascent_speed = c.k11 or 10
			return Vector3.new(0, ascent_speed, 0)
end

M.Controls = {
	{ Type = "Slider", Name = "Ascent Speed", Min = 1, Max = 100, Key = "k11" }
}

return M
end

__MODULES["shapes/Graviton Engine.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Graviton Engine"
	local Turbines, R, s, H = (c.k11 or 4), (c.k12 or 60), (c.k13 or 12) * x9.c2, (c.k14 or 200)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.25 then
					d.v1 = 1
				elseif roll < 0.45 then
					d.v1 = 2
				elseif roll < 0.60 then
					d.v1 = 3
				elseif roll < 0.72 then
					d.v1 = 4
				elseif roll < 0.88 then
					d.v1 = 5
				else
					d.v1 = 6
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.random()
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0
			local turb_spacing = H / (Turbines + 1)

			if d.v1 == 1 then

				local turb_idx = math.floor(d.v3 * Turbines)
				local turb_y = turb_spacing * (turb_idx + 1)
				local turb_phase = d.v2 + phase * (1 + turb_idx * 0.3)
				if turb_idx % 2 == 1 then
					turb_phase = -turb_phase
				end
				tx = R * math.cos(turb_phase)
				tz = R * math.sin(turb_phase)
				ty = turb_y
			elseif d.v1 == 2 then

				local turb_idx = math.floor(d.v3 * Turbines)
				local turb_y = turb_spacing * (turb_idx + 1)
				local blade_count = 6
				local blade_idx = math.floor(d.v2 / (math.pi * 2) * blade_count)
				local blade_base_angle = (blade_idx / blade_count) * math.pi * 2 + phase * (1 + turb_idx * 0.3)
				if turb_idx % 2 == 1 then
					blade_base_angle = -blade_base_angle
				end
				local blade_len = R * 0.4
				local blade_prog = d.v4
				local blade_r = R * 0.6 + blade_prog * blade_len
				local blade_tilt = math.pi * 0.15
				tx = blade_r * math.cos(blade_base_angle)
				tz = blade_r * math.sin(blade_base_angle)
				ty = turb_y + math.sin(blade_tilt) * blade_prog * blade_len * 0.3
			elseif d.v1 == 3 then

				local turb_idx = math.floor(d.v3 * math.max(1, Turbines - 1))
				local lower_y = turb_spacing * (turb_idx + 1)
				local upper_y = turb_spacing * (turb_idx + 2)
				local pipe_count = 4
				local pipe_idx = math.floor(d.v2 / (math.pi * 2) * pipe_count)
				local pipe_angle = (pipe_idx / pipe_count) * math.pi * 2 + phase * 0.2
				local prog = (d.v4 + phase * 2) % 1
				local pipe_r = 15
				tx = pipe_r * math.cos(pipe_angle)
				tz = pipe_r * math.sin(pipe_angle)
				ty = lower_y + prog * (upper_y - lower_y)
			elseif d.v1 == 4 then

				local turb_idx = math.floor(d.v3 * Turbines)
				local turb_y = turb_spacing * (turb_idx + 1)
				local exhaust_prog = (d.v4 + phase * 3) % 1
				local exhaust_r = R * 0.3 + exhaust_prog * R * 0.5
				local exhaust_angle = d.v2 + phase * 2
				tx = exhaust_r * math.cos(exhaust_angle)
				tz = exhaust_r * math.sin(exhaust_angle)
				ty = turb_y - exhaust_prog * turb_spacing * 0.6
			elseif d.v1 == 5 then

				local dish_r = d.v3 * R * 1.2
				local dish_angle = d.v2 + phase * 0.3
				local dish_y = H + (dish_r * dish_r) / (R * 2)
				tx = dish_r * math.cos(dish_angle)
				tz = dish_r * math.sin(dish_angle)
				ty = dish_y
			else

				local beam_r = 3 + math.sin(phase * 5 + d.v2 * 10) * 2
				local beam_prog = (d.v3 + phase * 4) % 1
				tx = beam_r * math.cos(d.v2)
				tz = beam_r * math.sin(d.v2)
				ty = H + 20 + beam_prog * H * 0.8

				if beam_prog > 0.7 then
					local scatter = (beam_prog - 0.7) / 0.3
					tx = tx + math.cos(d.v4 * math.pi * 2) * scatter * 40
					tz = tz + math.sin(d.v4 * math.pi * 2) * scatter * 40
				end
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Turbine Count", Min = 2, Max = 8, Key = "k11", IntOnly = true },
	{ Type = "Slider", Name = "Radius", Min = 20, Max = 200, Key = "k12" },
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 50, Key = "k13" },
	{ Type = "Slider", Name = "Tower Height", Min = 50, Max = 500, Key = "k14" }
}

return M
end

__MODULES["shapes/Halo Ring.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Halo Ring"
	local s, R, H = (c.k13 or 5) * x9.c2, (c.k11 or 40), (c.k14 or 80)
			if not d.v6 then
				d.v6 = math.random() * math.pi * 2
			end
			return ((cen + Vector3.new(math.cos(d.v6 + (t * s)) * R, H, math.sin(d.v6 + (t * s)) * R)) - wp)
				* (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Spin Speed", Min = 0, Max = 200, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Halo Radius", Min = 20, Max = 300, Key = "k11" },
	{ Type = "Slider", Name = "Height Offset", Min = 20, Max = 200, Key = "k14" }
}

return M
end

__MODULES["shapes/Hollow Worm.lua"] = function()
local M = {}

function M.px(t, c, x6, x9)
	if not x6.pre["Hollow Worm"] then
		x6.pre["Hollow Worm"] = table.create(200)
	end
	local r = x6.pre["Hollow Worm"]
	table.clear(r)
	local res = 200
	local s, radius, h, wf, l =
		(c.k13 or 10) * x9.c2, (c.k11 or 8), c.k14 or 50, (c.k15 or 10) * x9.c7, (c.k16 or x9.c5) * 100
	local R = (c.k17 or 150)
	for i = 1, res do
		local pc = (i - 1) / (res - 1)
		local ph = (t * s) - (pc * (l * x9.c2))
		local sx, sz, sy = math.cos(ph) * R, math.sin(ph) * R, math.sin(ph * wf) * h
		r[i] = Vector3.new(sx, sy, sz)
	end
end

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Hollow Worm"
	local r, wf = (c.k11 or 8), (c.k15 or 10) * x9.c7
			if not d.v4 then
				d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
				d.v6 = math.random()
			end
			local p_data = x6.pre and x6.pre[md]
			local center_pos
			if p_data and #p_data > 0 then
				local idx = math.floor(d.v6 * (#p_data - 1)) + 1
				center_pos = p_data[idx]
			else
				local s, h, l = (c.k13 or 10) * x9.c2, c.k14 or 50, (c.k16 or x9.c5) * 100
				local ph = (t * s) - (d.v6 * (l * x9.c2))
				local R = (c.k17 or 150)
				center_pos = Vector3.new(math.cos(ph) * R, math.sin(ph * wf) * h, math.sin(ph) * R)
			end
			local cx, sx_spin = math.cos(t * 2), math.sin(t * 2)
			local rd = Vector3.new(d.v4.X * cx - d.v4.Z * sx_spin, d.v4.Y, d.v4.X * sx_spin + d.v4.Z * cx).Unit
			return ((cen + center_pos + (rd * r)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Worm Speed", Min = 1, Max = 300, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Worm Length", Min = 10, Max = 500, Key = "k16", Div = 100 },
	{ Type = "Slider", Name = "Tube Radius", Min = 1, Max = 100, Key = "k11", Div = 2 },
	{ Type = "Slider", Name = "Height Limit", Min = 0, Max = 200, Key = "k14" },
	{ Type = "Slider", Name = "Wavelength", Min = 1, Max = 50, Key = "k15" },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 800, Key = "k17" }
}

return M
end

__MODULES["shapes/Klein Bottle.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Klein Bottle"
	local R, s = (c.k11 or 60), (c.k13 or 20) * x9.c2
			if not d.v1 then
				d.v1 = math.random() * math.pi * 2
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			local u_phase = (t * s) + d.v1
			local v_phase = (t * s * 0.5) + d.v2

			local cos_u, sin_u = math.cos(u_phase), math.sin(u_phase)
			local cos_v, sin_v = math.cos(v_phase), math.sin(v_phase)

			local tx = (R + cos_u * sin_v - sin_u * sin_v * 2) * cos_v
			local ty = sin_u * sin_v * R
			local tz = (R + cos_u * sin_v - sin_u * sin_v * 2) * sin_v

			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Radius", Min = 10, Max = 300, Key = "k11" },
	{ Type = "Slider", Name = "Flow Speed", Min = 1, Max = 100, Key = "k13", Div = 10 }
}

return M
end

__MODULES["shapes/Leviathan Coil.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Leviathan Coil"
	local CoilR, Thick, s, H = (c.k11 or 50), (c.k12 or 15), (c.k13 or 8) * x9.c2, (c.k14 or 250)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.45 then
					d.v1 = 1
				elseif roll < 0.58 then
					d.v1 = 2
				elseif roll < 0.72 then
					d.v1 = 3
				elseif roll < 0.87 then
					d.v1 = 4
				else
					d.v1 = 5
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.random() * math.pi * 2
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0
			local coil_loops = 4
			local body_length = coil_loops * math.pi * 2

			local bob = math.sin(phase * 0.3) * 15

			if d.v1 == 1 then

				local prog = d.v3
				local coil_angle = prog * body_length + phase
				local body_y = prog * H + bob
				local thickness = Thick * (0.5 + math.sin(prog * math.pi) * 0.5)
				local tube_angle = d.v2
				local body_r = CoilR + math.cos(tube_angle) * thickness
				local body_up = math.sin(tube_angle) * thickness
				tx = body_r * math.cos(coil_angle)
				tz = body_r * math.sin(coil_angle)
				ty = body_y + body_up
			elseif d.v1 == 2 then

				local head_angle = phase
				local head_y = H + bob + 10
				local jaw_open = math.sin(phase * 2) * 0.5 + 0.5
				local head_r = Thick * 1.5
				local is_upper = d.v3 > 0.5
				local jaw_offset = (is_upper and 1 or -1) * jaw_open * 8
				tx = CoilR * math.cos(head_angle) + math.cos(d.v2) * head_r * d.v3
				tz = CoilR * math.sin(head_angle) + math.sin(d.v2) * head_r * d.v3
				ty = head_y + jaw_offset + math.cos(d.v4) * head_r * 0.3
			elseif d.v1 == 3 then

				local prog = d.v3 * 0.3
				local tail_angle = prog * body_length * 0.5 + phase * 2
				local tail_y = prog * H * 0.3 + bob - 10
				local taper = Thick * (1 - d.v3) * 0.4
				local whip_freq = 8
				local whip_offset = math.sin(phase * whip_freq + prog * 20) * taper * 2
				tx = (CoilR + whip_offset) * math.cos(tail_angle) + math.cos(d.v2) * taper
				tz = (CoilR + whip_offset) * math.sin(tail_angle) + math.sin(d.v2) * taper
				ty = tail_y + math.sin(d.v4 + phase * 3) * taper
			elseif d.v1 == 4 then

				local wing_point = d.v3 > 0.5 and 0.35 or 0.65
				local wing_angle = wing_point * body_length + phase
				local wing_y = wing_point * H + bob
				local flare_cycle = math.sin(phase * 1.5 + (d.v3 > 0.5 and 0 or math.pi))
				local flare = math.max(0, flare_cycle)
				local wing_side = (d.v2 > math.pi) and 1 or -1
				local wing_spread = flare * CoilR * 1.5
				local wing_prog = d.v4 / (math.pi * 2)

				local fan_angle = wing_angle + wing_side * math.pi * 0.5
				local fan_r = wing_prog * wing_spread
				tx = CoilR * math.cos(wing_angle) + fan_r * math.cos(fan_angle + (wing_prog - 0.5) * 0.8)
				tz = CoilR * math.sin(wing_angle) + fan_r * math.sin(fan_angle + (wing_prog - 0.5) * 0.8)
				ty = wing_y + fan_r * 0.3 * math.sin(wing_prog * math.pi)
			else

				local prog = d.v3
				local coil_angle = prog * body_length + phase
				local body_y = prog * H + bob
				local spine_r = CoilR
				local spine_up = Thick * (0.5 + math.sin(prog * math.pi) * 0.5) + 5
				tx = spine_r * math.cos(coil_angle)
				tz = spine_r * math.sin(coil_angle)
				ty = body_y + spine_up + math.sin(prog * 30 + phase * 2) * 2
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Coil Radius", Min = 15, Max = 150, Key = "k11" },
	{ Type = "Slider", Name = "Body Thickness", Min = 5, Max = 50, Key = "k12" },
	{ Type = "Slider", Name = "Coil Speed", Min = 1, Max = 30, Key = "k13" },
	{ Type = "Slider", Name = "Tower Height", Min = 50, Max = 500, Key = "k14" }
}

return M
end

__MODULES["shapes/Maelstrom Spire.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Maelstrom Spire"
	local BaseR, H, s, Jets = (c.k11 or 30), (c.k12 or 200), (c.k13 or 15) * x9.c2, (c.k14 or 6)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.25 then
					d.v1 = 1
				elseif roll < 0.50 then
					d.v1 = 2
				elseif roll < 0.70 then
					d.v1 = 3
				elseif roll < 0.92 then
					d.v1 = 4
				else
					d.v1 = 5
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random()
			end
			if not d.v4 then
				d.v4 = math.random() * math.pi * 2
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0
			local TopR = BaseR * 4

			if d.v1 == 1 then

				local spiral_a = d.v2 + phase * 2
				local spiral_r = BaseR * 0.5 + d.v3 * TopR * 1.2
				local log_r = spiral_r * (1 + math.log(1 + d.v3 * 2))
				tx = log_r * math.cos(spiral_a)
				tz = log_r * math.sin(spiral_a)
				ty = -5 + math.sin(spiral_a * 3) * 3
			elseif d.v1 == 2 then

				local prog = d.v3
				local funnel_r = TopR * (1 - prog * 0.8)
				local angular_speed = 1 + prog * 3
				local funnel_phase = d.v2 + phase * angular_speed
				tx = funnel_r * math.cos(funnel_phase)
				tz = funnel_r * math.sin(funnel_phase)
				ty = prog * H
			elseif d.v1 == 3 then

				local jet_idx = math.floor(d.v2 / (math.pi * 2) * Jets)
				local jet_angle = (jet_idx / Jets) * math.pi * 2 + phase * 0.3
				local jet_dist = d.v3 * TopR * 2
				local wobble = math.sin(phase * 3 + jet_idx * 1.5) * 10
				tx = jet_dist * math.cos(jet_angle + wobble * 0.02)
				tz = jet_dist * math.sin(jet_angle + wobble * 0.02)
				ty = H + wobble + math.sin(d.v4 + phase) * 5
			elseif d.v1 == 4 then

				local arc_prog = (d.v3 + phase * 0.5) % 1
				local arc_angle = d.v2 + phase * 0.2
				local arc_r = TopR * 1.5 + arc_prog * TopR * 0.5
				local arc_y = H * (1 - 4 * (arc_prog - 0.5) * (arc_prog - 0.5))
				tx = arc_r * math.cos(arc_angle)
				tz = arc_r * math.sin(arc_angle)
				ty = arc_y
			else

				local eye_r = 5 + math.sin(phase * 0.5 + d.v2) * 2
				tx = eye_r * math.cos(d.v2 + phase * 0.1)
				tz = eye_r * math.sin(d.v2 + phase * 0.1)
				ty = H + math.sin(phase + d.v3 * math.pi) * 2
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Base Radius", Min = 10, Max = 150, Key = "k11" },
	{ Type = "Slider", Name = "Tower Height", Min = 50, Max = 500, Key = "k12" },
	{ Type = "Slider", Name = "Vortex Speed", Min = 1, Max = 50, Key = "k13" },
	{ Type = "Slider", Name = "Jet Count", Min = 3, Max = 12, Key = "k14", IntOnly = true }
}

return M
end

__MODULES["shapes/Meteor Shower.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Meteor Shower"
	local SpreadXZ, HeightSpawn, FallSpeed, Density = (c.k11 or 500), (c.k12 or 300), (c.k13 or 150), (c.k14 or 50)
			if not d.v1 then
				d.v1 = (math.random() - 0.5) * SpreadXZ
			end
			if not d.v2 then
				d.v2 = (math.random() - 0.5) * SpreadXZ
			end
			if not d.v3 then
				d.v3 = math.random()
			end


			local drop_dist = HeightSpawn * 2
			local fall_time = drop_dist / FallSpeed
			local current_fall = ((t + d.v3 * fall_time) % fall_time) / fall_time

			local y_pos = HeightSpawn - (current_fall * drop_dist)

			local x_pos = d.v1 - (current_fall * (SpreadXZ * 0.5))
			local z_pos = d.v2 - (current_fall * (SpreadXZ * 0.25))

			return ((cen + Vector3.new(x_pos, y_pos, z_pos)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "XZ Spread", Min = 100, Max = 1500, Key = "k11" },
	{ Type = "Slider", Name = "Spawn Height", Min = 50, Max = 1500, Key = "k12" },
	{ Type = "Slider", Name = "Fall Speed", Min = 50, Max = 2000, Key = "k13" }
}

return M
end

__MODULES["shapes/Möbius Strip.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Möbius Strip"
	local R, width, s = (c.k11 or 50), (c.k12 or 20), (c.k13 or 15) * x9.c2
			if not d.v6 then
				d.v6 = math.random() * math.pi * 2
			end
			if not d.v1 then
				d.v1 = (math.random() - 0.5) * 2
			end
			local v_ang = (t * s) + d.v6
			local w_offset = d.v1 * width
			local tx = (R + w_offset * math.cos(v_ang / 2)) * math.cos(v_ang)
			local tz = (R + w_offset * math.cos(v_ang / 2)) * math.sin(v_ang)
			local ty = w_offset * math.sin(v_ang / 2)
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Radius", Min = 10, Max = 300, Key = "k11" },
	{ Type = "Slider", Name = "Width", Min = 5, Max = 200, Key = "k12" },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 100, Key = "k13", Div = 10 }
}

return M
end

__MODULES["shapes/Orbital Shell.lua"] = function()
local M = {}

function M.px(t, c, x6, x9)
	if not x6.pre["Orbital Shell"] then
		x6.pre["Orbital Shell"] = table.create(200)
	end
	local r = x6.pre["Orbital Shell"]
	table.clear(r)
	local s = (c.k13 or 10) * x9.c2
	local ph = t * s
	r[1] = { ca = math.cos(ph), sa = math.sin(ph) }
end

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Orbital Shell"
	local R = (c.k11 or 200)
			if not d.v4 then
				d.v4 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			end
			local pd = x6.pre and x6.pre[md] and x6.pre[md][1]
			local ca, sa
			if pd then
				ca, sa = pd.ca, pd.sa
			else
				local s = (c.k13 or 10) * x9.c2
				ca, sa = math.cos(t * s), math.sin(t * s)
			end
			local rv
			if c.k19 then
				rv = Vector3.new(d.v4.X * ca - d.v4.Z * sa, d.v4.Y, d.v4.X * sa + d.v4.Z * ca)
			else
				if not d.v5 then
					d.v5 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
				end
				local k, v = d.v5, d.v4
				rv = v * ca + k:Cross(v) * sa + k * (k:Dot(v) * (1 - ca))
			end
			if c.k18 then
				rv = Vector3.new(rv.X, math.abs(rv.Y), rv.Z)
			end
			return ((cen + (rv * R)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 300, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Shell Radius", Min = 50, Max = 1000, Key = "k11" },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 1500, Key = "k17" },
	{ Type = "Toggle", Name = "Cut in Half", Key = "k18" },
	{ Type = "Toggle", Name = "Stable Flow", Key = "k19" }
}

return M
end

__MODULES["shapes/Point Impact.lua"] = function()
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

M.Controls = {
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 500, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Closeness", Min = 1, Max = 50, Key = "k11", Div = 2 },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 800, Key = "k17" }
}

return M
end

__MODULES["shapes/Pulsar Vortex.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Pulsar Vortex"
	local Spread, Speed, Torsion = (c.k11 or 200), (c.k12 or 8) * x9.c2, (c.k13 or 10)
	
	if not d.v1 then
		d.v1 = math.random() * math.pi * 2
	end
	if not d.v2 then
		d.v2 = math.random()
	end
	if not d.v3 then
		d.v3 = math.random() * math.pi
	end
	if not d.v4 then
		d.v4 = math.random() * math.pi * 2
	end

	local phase = t * Speed + d.v4
	local r = Spread * d.v2 * (0.6 + 0.4 * math.sin(phase * 0.5))

	local px = r * math.sin(d.v3) * math.cos(d.v1)
	local py = r * math.cos(d.v3)
	local pz = r * math.sin(d.v3) * math.sin(d.v1)

	local drift_x = math.sin(t * 1.2 + d.v2 * 15) * (Spread * 0.15)
	local drift_y = math.cos(t * 1.5 + d.v3 * 15) * (Spread * 0.15)
	local drift_z = math.sin(t * 0.9 + d.v1 * 15) * (Spread * 0.15)
	
	px = px + drift_x
	py = py + drift_y
	pz = pz + drift_z

	local horizontal_dist = math.sqrt(px^2 + pz^2)
	local twist = (horizontal_dist / Spread) * Torsion + t * 1.5
	
	local nx = px * math.cos(twist) - pz * math.sin(twist)
	local nz = px * math.sin(twist) + pz * math.cos(twist)
	px, pz = nx, nz

	local tumble = t * 0.3
	local ty = py * math.cos(tumble) - pz * math.sin(tumble)
	local tz = py * math.sin(tumble) + pz * math.cos(tumble)
	py, pz = ty, tz

	local final_y = py
	if c.k23 then
		final_y = math.abs(final_y)
	end

	return ((cen + Vector3.new(px, final_y, pz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Spread", Min = 50, Max = 800, Key = "k11" },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 30, Key = "k12" },
	{ Type = "Slider", Name = "Torsion Twist", Min = 1, Max = 50, Key = "k13" },
	{ Type = "Toggle", Name = "Cut in Half", Key = "k23" }
}

return M

end

__MODULES["shapes/Quantum Atoms.lua"] = function()
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

M.Controls = {
	{ Type = "Slider", Name = "Orbit Speed", Min = 1, Max = 300, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Atom Radius", Min = 20, Max = 500, Key = "k11" },
	{ Type = "Slider", Name = "Orbit Count", Min = 1, Max = 10, Key = "k15", IntOnly = true },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 800, Key = "k17" }
}

return M
end

__MODULES["shapes/Quantum Core.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Quantum Core"
	local R, RingThickness, s, ParticleSpeed = (c.k11 or 100), (c.k12 or 30), (c.k13 or 40) * x9.c2, (c.k14 or 50)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.4 then
					d.v1 = 1
				elseif roll < 0.8 then
					d.v1 = 2
				else
					d.v1 = 3
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random() * math.pi * 2
			end
			if not d.v4 then
				d.v4 = (math.random() - 0.5) * 2
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0

			if d.v1 == 1 then
				local ring_phase = d.v2 + phase
				local torus_x = (R + RingThickness * math.cos(d.v3)) * math.cos(ring_phase)
				local torus_z = (R + RingThickness * math.cos(d.v3)) * math.sin(ring_phase)
				local torus_y = RingThickness * math.sin(d.v3)

				tx, ty, tz = torus_x, torus_y, torus_z
			elseif d.v1 == 2 then
				local ring_phase = d.v2 + phase * 1.1
				local torus_x = (R + RingThickness * math.cos(d.v3)) * math.cos(ring_phase)
				local torus_y = (R + RingThickness * math.cos(d.v3)) * math.sin(ring_phase)
				local torus_z = RingThickness * math.sin(d.v3)

				tx, ty, tz = torus_x, torus_y, torus_z
			else

				local spd = ParticleSpeed * 0.1
				local dist = (math.sin(t * spd + d.v2) * 0.5 + 0.5) * (R * 0.8)
				local phi = d.v3 + phase * 3 * d.v4
				local theta = d.v2 + phase * 4 * d.v4

				tx = dist * math.sin(phi) * math.cos(theta)
				ty = dist * math.cos(phi)
				tz = dist * math.sin(phi) * math.sin(theta)
			end

			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Ring Radius", Min = 50, Max = 400, Key = "k11" },
	{ Type = "Slider", Name = "Ring Thickness", Min = 10, Max = 100, Key = "k12" },
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 200, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Core Volatility", Min = 10, Max = 200, Key = "k14" }
}

return M
end

__MODULES["shapes/Sculptor.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Sculptor"

			if x6.sculptor_selected[p] then
				if x6.sculptor_dragging and x6.sculptor_drag_target then

					local target = x6.sculptor_drag_target
					local offset = x6.sculptor_selected[p] or Vector3.zero
					local target_pos = target + offset
					local delta = target_pos - wp
					local dist = delta.Magnitude

					if dist < 0.5 then
						return Vector3.new(0, 0.01, 0)
					else

						local speed = math.clamp(dist * 3, 1, 100)
						return delta.Unit * speed
					end
				else

					return Vector3.new(0, 0.01, 0)
				end
			else

				return Vector3.new(0, 0.01, 0)
			end
end

return M
end

__MODULES["shapes/Seraphim.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Seraphim"
	local R, RingCount, s, Wingspan = (c.k11 or 80), (c.k12 or 4), (c.k13 or 15) * x9.c2, (c.k14 or 40)
			if not d.v1 then
				local roll = math.random()
				if roll < 0.2 then
					d.v1 = 0
				elseif roll < 0.6 then
					d.v1 = math.random(1, RingCount)
				else
					d.v1 = -1
				end
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end

			local phase = t * s
			local tx, ty, tz = 0, 0, 0

			if d.v1 == 0 then

				local eye_phase = d.v2 + phase * 4
				tx = 5 * math.cos(eye_phase)
				ty = 10 * math.sin(eye_phase)
				tz = 0
			elseif d.v1 > 0 then

				local ring_idx = d.v1
				local ring_phase = d.v2 + (phase * (1 + ring_idx * 0.2))
				local tilt_x = (ring_idx / RingCount) * math.pi
				local tilt_z = phase * 0.5 + ring_idx


				local bx = R * math.cos(ring_phase)
				local by = 0
				local bz = R * math.sin(ring_phase)


				local cx, sx = math.cos(tilt_x), math.sin(tilt_x)
				local cz, sz = math.cos(tilt_z), math.sin(tilt_z)


				local rx1 = bx
				local ry1 = by * cx - bz * sx
				local rz1 = by * sx + bz * cx


				tx = rx1 * cz - ry1 * sz
				ty = rx1 * sz + ry1 * cz
				tz = rz1
			else

				local wing_side = (d.v2 % 2 > 1) and 1 or -1
				local wing_pos = (d.v2 / (math.pi * 2))
				local wing_w = wing_pos * Wingspan * 2

				local wing_flap = math.sin(phase * 2) * 15 * wing_pos

				tx = wing_w * wing_side
				ty = wing_flap + math.abs(wing_side * wing_w * 0.5)
				tz = -20 - (wing_pos * 30)
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Radius", Min = 20, Max = 200, Key = "k11" },
	{ Type = "Slider", Name = "Ring Count", Min = 1, Max = 10, Key = "k12", IntOnly = true },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Wingspan", Min = 10, Max = 150, Key = "k14" }
}

return M
end

__MODULES["shapes/Shield Wall.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Shield Wall"
	local s, w, h, d_val, h_off = (c.k13 or 20) * x9.c2, (c.k11 or 1), (c.k12 or 10), (c.k14 or 15), (c.k15 or 0)
			if not d.v4 then
				d.v4 = math.random() - 0.5
				d.v5 = math.random() - 0.5
			end
			local angle = (t * s) + (d.v4 * w)
			local tx = math.cos(angle) * d_val
			local tz = math.sin(angle) * d_val
			local ty = (d.v5 * h) + h_off
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Spin Speed", Min = 1, Max = 200, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Width", Min = 1, Max = 200, Key = "k11", Div = 10 },
	{ Type = "Slider", Name = "Height", Min = 1, Max = 50, Key = "k12" },
	{ Type = "Slider", Name = "Distance", Min = 5, Max = 100, Key = "k14" },
	{ Type = "Slider", Name = "H-Offset", Min = -50, Max = 50, Key = "k15" }
}

return M
end

__MODULES["shapes/Slingshot.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Slingshot"
	local dist = c.k11 or 50
			local cycle = c.k12 or 3
			local speed = c.k13 or 100
			if not d.v1 then
				d.v1 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
				d.v2 = math.random() * cycle
				d.v2 = 0
			end
			local phase = (t + d.v2) % cycle
			local is_charging = phase < (cycle * 0.8)
			if x1.SlingshotManual then
				is_charging = not x1.IsLaunching
			end
			if is_charging then
				local charge_pos = cen + (d.v1 * dist)
				return (charge_pos - wp) * (5 * x9.c1)
			else
				local smash_pos = cen
				return (smash_pos - wp) * (speed * x9.c1)
			end
end

M.Controls = {
	{ Type = "Slider", Name = "Charge Dist", Min = 10, Max = 200, Key = "k11" },
	{ Type = "Slider", Name = "Cycle Time", Min = 1, Max = 10, Key = "k12" },
	{ Type = "Slider", Name = "Fling Speed", Min = 1, Max = 500, Key = "k13" }
}

return M
end

__MODULES["shapes/Space Station.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Space Station"
	local R, RingThickness, s, CoreRadius = (c.k11 or 80), (c.k12 or 30), (c.k13 or 10) * x9.c2, (c.k14 or 150)
			if not d.v1 then
				d.v1 = math.random()
			end
			if not d.v2 then
				d.v2 = math.random() * math.pi * 2
			end
			if not d.v3 then
				d.v3 = math.random(1, 3)
			end

			local phase = (t * s) + d.v2
			local tx, ty, tz = 0, 0, 0

			if d.v3 == 1 then
				ty = (d.v1 - 0.5) * CoreRadius
				tx = math.cos(phase * 3) * (10 + (d.v1 * 5))
				tz = math.sin(phase * 3) * (10 + (d.v1 * 5))
			elseif d.v3 == 2 then
				local ringPhase = phase * 0.5
				local tubeOffset = (d.v1 - 0.5) * RingThickness
				tx = (R + tubeOffset) * math.cos(ringPhase)
				tz = (R + tubeOffset) * math.sin(ringPhase)
				ty = (math.random() - 0.5) * 5
			else
				local spokeCount = 4
				local spokeAngle = math.floor(d.v2 / (math.pi * 2) * spokeCount) * (math.pi * 2 / spokeCount)
				local spokeSpin = phase * 0.5
				local dist = d.v1 * R
				tx = dist * math.cos(spokeAngle + spokeSpin)
				tz = dist * math.sin(spokeAngle + spokeSpin)
				ty = 0
			end
			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Ring Radius", Min = 20, Max = 400, Key = "k11" },
	{ Type = "Slider", Name = "Ring Thickness", Min = 5, Max = 100, Key = "k12" },
	{ Type = "Slider", Name = "Orbit Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Spindle Length", Min = 20, Max = 500, Key = "k14" }
}

return M
end

__MODULES["shapes/Supernova.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Supernova"
	local ExpandingRad, MaxSize, s = (c.k11 or 15), (c.k12 or 100), (c.k13 or 25) * x9.c2
			if not d.v1 then
				d.v1 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
			end
			if not d.v2 then
				d.v2 = math.random()
			end
			local cycle = (t * s) % math.pi
			local burst = math.sin(cycle)

			local core_jitter = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 2
			local shockwave = d.v1 * (burst * MaxSize * d.v2)
			local current_pos = (burst > 0.1) and shockwave or (d.v1 * ExpandingRad + core_jitter)

			return ((cen + current_pos) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Core Radius", Min = 5, Max = 100, Key = "k11" },
	{ Type = "Slider", Name = "Blast Radius", Min = 50, Max = 800, Key = "k12" },
	{ Type = "Slider", Name = "Pulse Speed", Min = 1, Max = 200, Key = "k13", Div = 10 }
}

return M
end

__MODULES["shapes/Tesseract.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Tesseract"
	local size, outer_size, s = (c.k11 or 40), (c.k12 or 80), (c.k13 or 10) * x9.c2
			if not d.v1 then
				d.v1 = math.random(0, 31)
			end
			local target_rot = (t * s)

			local function proj_4d(x, y, z, w, rot)
				local nw = w * math.cos(rot) - x * math.sin(rot)
				local nx = w * math.sin(rot) + x * math.cos(rot)
				local perspective = size / (size - nw * 0.5)
				return nx * perspective, y * perspective, z * perspective
			end

			local points = {
				{ -1, -1, -1 },
				{ 1, -1, -1 },
				{ -1, 1, -1 },
				{ 1, 1, -1 },
				{ -1, -1, 1 },
				{ 1, -1, 1 },
				{ -1, 1, 1 },
				{ 1, 1, 1 },
			}

			local edge = d.v1
			local from, to
			if edge < 12 then
				from = points[(edge % 4) * 2 + 1]
				to = points[(edge % 4) * 2 + 2]
			elseif edge < 24 then
				from = points[((edge - 12) % 4) * 2 + 1]
				to = points[((edge - 12) % 4) * 2 + 2]
			else
				from = points[(edge - 24) + 1]
				to = points[(edge - 24) + 1]
			end

			local lerp = (math.sin(t * s + d.v1) + 1) / 2
			local lx = from[1] + (to[1] - from[1]) * lerp
			local ly = from[2] + (to[2] - from[2]) * lerp
			local lz = from[3] + (to[3] - from[3]) * lerp
			local lw = (edge >= 12 and edge < 24) and 1 or -1

			local rx, ry, rz = proj_4d(lx * outer_size, ly * outer_size, lz * outer_size, lw * outer_size, target_rot)
			return ((cen + Vector3.new(rx, ry, rz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Inner Size", Min = 10, Max = 200, Key = "k11" },
	{ Type = "Slider", Name = "Outer Size", Min = 20, Max = 400, Key = "k12" },
	{ Type = "Slider", Name = "Rotation Speed", Min = 1, Max = 100, Key = "k13", Div = 10 }
}

return M
end

__MODULES["shapes/Torus Knot.lua"] = function()
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

M.Controls = {
	{ Type = "Slider", Name = "P Knot", Min = 1, Max = 10, Key = "k11" },
	{ Type = "Slider", Name = "Q Knot", Min = 1, Max = 10, Key = "k12" },
	{ Type = "Slider", Name = "Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Radius", Min = 10, Max = 300, Key = "k14" },
	{ Type = "Slider", Name = "Tube Size", Min = 5, Max = 100, Key = "k15" }
}

return M
end

__MODULES["shapes/Vortex Funnel.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "Vortex Funnel"
	local s, R_base, R_top, H = (c.k13 or 10) * x9.c2, (c.k11 or 50), (c.k12 or 300), (c.k14 or 400)
			if not d.v4 then
				d.v4 = math.random()
			end
			if not d.v6 then
				d.v6 = math.random() * math.pi * 2
			end
			local current_r = R_base + ((R_top - R_base) * (d.v4 ^ 2))
			local phase = (t * s) + d.v6 + ((1 - d.v4) * (c.k15 or 5) * 5)
			return ((cen + Vector3.new(current_r * math.cos(phase), d.v4 * H - (H / 2), current_r * math.sin(phase))) - wp)
				* (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Swirl Speed", Min = 1, Max = 300, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Base Radius", Min = 10, Max = 300, Key = "k11" },
	{ Type = "Slider", Name = "Top Radius", Min = 50, Max = 1000, Key = "k12" },
	{ Type = "Slider", Name = "Funnel Height", Min = 50, Max = 1000, Key = "k14" },
	{ Type = "Slider", Name = "Suction Power", Min = 1, Max = 20, Key = "k15" },
	{ Type = "Slider", Name = "Move Area", Min = 50, Max = 1500, Key = "k17" }
}

return M
end

__MODULES["shapes/World Serpent.lua"] = function()
local M = {}

function M.f2(p, cen, d, t, c, x1, x6, x9)
	local wp = p.Position
	local tc = cen - wp
	local md = "World Serpent"
	local Length, Amplitude, s, Wavelength =
				(c.k11 or 400), (c.k12 or 100), (c.k13 or 20) * x9.c2, (c.k14 or 20) * 10
			if not d.v1 then
				d.v1 = math.random()
			end

			local phase = t * s
			local pos_along_body = d.v1 * Length


			local wave_offset = (pos_along_body - (phase * 500)) / Wavelength


			local outer_radius = Length / math.pi
			local angle = (pos_along_body / Length) * math.pi * 2 + phase

			local undulation_y = math.sin(wave_offset * math.pi * 2) * Amplitude
			local undulation_r = math.cos(wave_offset * math.pi * 2) * (Amplitude * 0.5)

			local current_radius = outer_radius + undulation_r
			local tx = current_radius * math.cos(angle)
			local tz = current_radius * math.sin(angle)
			local ty = undulation_y

			return ((cen + Vector3.new(tx, ty, tz)) - wp) * (x1.k10 * x9.c1)
end

M.Controls = {
	{ Type = "Slider", Name = "Snake Length", Min = 100, Max = 2000, Key = "k11" },
	{ Type = "Slider", Name = "Wave Height", Min = 10, Max = 500, Key = "k12" },
	{ Type = "Slider", Name = "Move Speed", Min = 1, Max = 100, Key = "k13", Div = 10 },
	{ Type = "Slider", Name = "Frequency", Min = 10, Max = 200, Key = "k14" }
}

return M
end

__MODULES["config.lua"] = function()
return {
	x1 = {
		k1 = 2000,
		k2 = Vector3.new(5, 5, 5),
		k3 = Color3.fromRGB(255, 105, 180),
		k4 = math.huge,
		k5 = { "NoAttract", "Character" },
		k6 = "Celestial Ribbon",
		k7 = 4,
		k8 = 0.8,
		k9 = 80,
		k10 = 20,
		k11 = 2,
		k12 = 100,
		k13 = 10,
		k14 = 5,
		k15 = 10,
		k16 = 0.6,
		k17 = 150,
		Tgt = nil,
		ImpactManual = false,
		IsLaunching = false,
		Disabled = false,
		TgtActive = false,
		PI_All = false,
		AnchorSelf = false,
		AntiFling = false,
		Paused = false,
		Damping = 0.5,
		Ki = 0.1,
		MaxSpeed = 500,
		AngularDamping = 0.5,
		VerticalStiffness = 1.0,
	},
	x2 = {
		["Pulsar Vortex"] = { k11 = 200, k12 = 8, k13 = 10, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Big Ring Things"] = { k12 = 100, k13 = 10, k14 = 5, k16 = 0.6, k15 = 10, k11 = 2, k17 = 150, k23 = false },
		["Celestial Ribbon"] = { k12 = 0, k13 = 15, k14 = 30, k16 = 0.4, k11 = 1, k17 = 150, k18 = false, k19 = false, k23 = false },
		["Hollow Worm"] = { k12 = 0, k13 = 15, k14 = 35, k16 = 0.4, k15 = 10, k11 = 15, k17 = 150, k23 = false },
		["Cosmic Comet"] = { k12 = 50, k13 = 20, k14 = 20, k16 = 0.5, k15 = 5, k11 = 5, k17 = 150, k23 = false },
		["Point Impact"] = { k12 = 0, k13 = 500, k14 = 0, k16 = 0, k15 = 0, k11 = 0, k17 = 50, k23 = false },
		["Orbital Shell"] = { k11 = 90, k12 = 0, k13 = 15, k14 = 0, k15 = 0, k16 = 0, k17 = 150, k23 = false, k18 = false, k19 = false },
		["Vortex Funnel"] = { k11 = 50, k12 = 300, k13 = 30, k14 = 400, k15 = 5, k16 = 0, k17 = 400, k23 = false },
		["Quantum Atoms"] = { k11 = 60, k12 = 0, k13 = 15, k14 = 0, k15 = 3, k16 = 0, k17 = 150, k23 = false },
		["Halo Ring"] = { k11 = 40, k12 = 0, k13 = 5, k14 = 80, k15 = 0, k16 = 0, k17 = 50, k23 = false },
		["Slingshot"] = { k11 = 50, k12 = 3, k13 = 100, k14 = 0, k15 = 5, k16 = 0, k17 = 100, k23 = false },
		["Gods Call"] = { k11 = 10, k12 = 0, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 50, k23 = false },
		["Deflect"] = { k11 = 50, k12 = 500, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 50, k23 = false },
		["Shield Wall"] = { k11 = 20, k12 = 25, k13 = 20, k14 = 50, k15 = 10, k16 = 0, k17 = 50, k23 = false },
		["Sculptor"] = { k11 = 0, k12 = 0, k13 = 0, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Torus Knot"] = { k11 = 3, k12 = 2, k13 = 10, k14 = 50, k15 = 20, k16 = 0, k17 = 0, k23 = false },
		["Möbius Strip"] = { k11 = 50, k12 = 20, k13 = 15, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["DNA Helix"] = { k11 = 20, k12 = 80, k13 = 10, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Black Hole"] = { k11 = 40, k12 = 100, k13 = 15, k14 = 50, k15 = 5, k16 = 0, k17 = 0, k23 = false },
		["Tesseract"] = { k11 = 40, k12 = 80, k13 = 10, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Klein Bottle"] = { k11 = 60, k12 = 20, k13 = 20, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Space Station"] = { k11 = 80, k12 = 30, k13 = 10, k14 = 150, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Supernova"] = { k11 = 15, k12 = 100, k13 = 25, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Dyson Sphere"] = { k11 = 150, k12 = 8, k13 = 10, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Seraphim"] = { k11 = 80, k12 = 4, k13 = 15, k14 = 40, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Alien Mothership"] = { k11 = 120, k12 = 40, k13 = 15, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Quantum Core"] = { k11 = 100, k12 = 30, k13 = 40, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Galactic Web"] = { k11 = 400, k12 = 10, k13 = 5, k14 = 0, k15 = 0, k16 = 0, k17 = 0, k23 = false, k24 = 200 },
		["Meteor Shower"] = { k11 = 500, k12 = 300, k13 = 150, k14 = 50, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["World Serpent"] = { k11 = 400, k12 = 100, k13 = 20, k14 = 20, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Aurora Borealis"] = { k11 = 600, k12 = 300, k13 = 15, k14 = 100, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Arcane Orrery"] = { k11 = 120, k12 = 4, k13 = 8, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Maelstrom Spire"] = { k11 = 30, k12 = 200, k13 = 15, k14 = 6, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Eldritch Binding"] = { k11 = 100, k12 = 200, k13 = 5, k14 = 8, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Graviton Engine"] = { k11 = 4, k12 = 60, k13 = 12, k14 = 200, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Fractal Web"] = { k11 = 40, k12 = 3, k13 = 3, k14 = 5, k15 = 0, k16 = 0, k17 = 0, k23 = false },
		["Leviathan Coil"] = { k11 = 50, k12 = 15, k13 = 8, k14 = 250, k15 = 0, k16 = 0, k17 = 0, k23 = false },
	},
}

end

__MODULES["math/serialization.lua"] = function()
local M = {}

function M.sanitize(t)
	local res = {}
	for k, v in pairs(t) do
		if typeof(v) == "Vector3" then
			res[k] = { __type = "Vector3", x = v.X, y = v.Y, z = v.Z }
		elseif typeof(v) == "Color3" then
			res[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
		elseif typeof(v) == "number" then
			if v == math.huge then
				res[k] = { __type = "inf" }
			elseif v == -math.huge then
				res[k] = { __type = "-inf" }
			elseif v ~= v then
				res[k] = { __type = "nan" }
			else
				res[k] = v
			end
		elseif typeof(v) == "table" then
			res[k] = M.sanitize(v)
		elseif typeof(v) == "Instance" or typeof(v) == "function" or typeof(v) == "userdata" then
		else
			res[k] = v
		end
	end
	return res
end

function M.desanitize(t)
	local res = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			if v.__type == "Vector3" then
				res[k] = Vector3.new(v.x, v.y, v.z)
			elseif v.__type == "Color3" then
				res[k] = Color3.new(v.r, v.g, v.b)
			elseif v.__type == "inf" then
				res[k] = math.huge
			elseif v.__type == "-inf" then
				res[k] = -math.huge
			elseif v.__type == "nan" then
				res[k] = 0/0
			else
				res[k] = M.desanitize(v)
			end
		else
			res[k] = v
		end
	end
	return res
end

return M

end

__MODULES["System.lua"] = function()
return function(context)
	local v1, v2, v3, v4, v5, v6, v7, v8, v9 = context.v1, context.v2, context.v3, context.v4, context.v5, context.v6, context.v7, context.v8, context.v9
	local x1, x2, x6, x9 = context.x1, context.x2, context.x6, context.x9
	local x5 = context.x5
	local get_shape = context.get_shape
	local load_module = context.load_module

	local x4, x8 = {}, {}
	local x7 = {}

	function x7.n(t, x, d)
		pcall(function()
			v5:SetCore("SendNotification", { Title = t, Text = x, Duration = d or 3 })
		end)
	end

	local EXCLUDED_NAMES = {
		Baseplate = true,
		HumanoidRootPart = true,
		Terrain = true,
		Handle = true,
		Head = true,
		Torso = true,
		["Left Arm"] = true,
		["Right Arm"] = true,
		["Left Leg"] = true,
		["Right Leg"] = true,
		UpperTorso = true,
		LowerTorso = true,
		LeftUpperArm = true,
		LeftLowerArm = true,
		LeftHand = true,
		RightUpperArm = true,
		RightLowerArm = true,
		RightHand = true,
		LeftUpperLeg = true,
		LeftLowerLeg = true,
		LeftFoot = true,
		RightUpperLeg = true,
		RightLowerLeg = true,
		RightFoot = true,
	}

	function x7.e(p)
		if not p:IsA("BasePart") then
			return true
		end
		if EXCLUDED_NAMES[p.Name] then
			return true
		end
		for _, t in ipairs(x1.k5) do
			if p:FindFirstChild(t) or (p.Parent and p.Parent:FindFirstChild(t)) then
				return true
			end
		end
		for _, pl in ipairs(v2:GetPlayers()) do
			if pl.Character and p:IsDescendantOf(pl.Character) then
				return true
			end
		end
		local target = p
		while target and target ~= v4 and target ~= game do
			if
				target:IsA("Model")
				and (target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("AnimationController"))
			then
				return true
			end
			if target:IsA("Accessory") or target:IsA("Tool") then
				return true
			end
			target = target.Parent
		end
		if p.Anchored then
			return true
		end
		return false
	end

	local function x3()
		return x1.S[x1.k6] or {}
	end

	local function px(md, t, c)
		local shape = get_shape(md)
		if shape and shape.px then
			shape.px(t, c, x6, x9)
		end
	end



	local no_damp = { ["Slingshot"] = true, ["Point Impact"] = true, ["Deflect"] = true }

	local function f3(real_dt)
		real_dt = real_dt or (1/60)
		if not x6.b or x1.Disabled then
			return
		end
		if x1.Paused then
			for _, d in pairs(x6.a) do
				if d.lv then
					d.lv.VectorVelocity = Vector3.new(0, 0.01, 0)
				end
			end
			return
		end
		pcall(function()
			local c = x6.b.Position
			x6.f = x6.f + 1
			local dt = x6.n > 5000 and 10 or (x6.n > 2500 and 6 or (x6.n > 1000 and 3 or 1))
			local et, ft = x1.k7 or dt, time()
			local i = 0
			if ft > x6.pi_timer then
				x6.pi_timer = ft + 1
				x6.pi_targets = {}
				if x1.PI_All then
					for _, pl in ipairs(v2:GetPlayers()) do
						if pl ~= v8 and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
							table.insert(x6.pi_targets, pl)
						end
					end
				else
					if x1.Tgt and x1.Tgt.Character and x1.Tgt.Character:FindFirstChild("HumanoidRootPart") then
						table.insert(x6.pi_targets, x1.Tgt)
					end
				end
			end
			px(x1.k6, ft, x3())
			local cur_no_damp = no_damp[x1.k6]
			
			local target_positions = {}
			local valid_targets = 0
			if #x6.pi_targets > 0 then
				for _, tgt in ipairs(x6.pi_targets) do
					if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
						table.insert(target_positions, tgt.Character.HumanoidRootPart.Position)
						valid_targets = valid_targets + 1
					end
				end
			end
			local cur_shape_mod = get_shape(x1.k6)
			local cur_shape_cfg = x1.S[x1.k6] or {}

			for k = #x6.active_array, 1, -1 do
				local p = x6.active_array[k]
				local d = x6.a[p]

				if not d or not p.Parent then
					if d then
						if d.at and d.at.Parent then d.at:Destroy() end
						if d.lv and d.lv.Parent then d.lv:Destroy() end
						if d.av and d.av.Parent then d.av:Destroy() end
						x6.a[p] = nil
					end
					local last = #x6.active_array
					if k ~= last then
						x6.active_array[k] = x6.active_array[last]
					end
					table.remove(x6.active_array, last)
					x6.n = math.max(0, x6.n - 1)
					continue
				end
				i = i + 1
				if i % et ~= (x6.f % et) then
					continue
				end
				local p_vel = p.AssemblyLinearVelocity
				local active_c = c
				if valid_targets > 0 then
					active_c = target_positions[((i - 1) % valid_targets) + 1]
				end
				local tc = active_c - p.Position
				local tc_mag = tc.Magnitude
				if tc_mag > x1.k1 then
					continue
				end
				if tc_mag > x9.c7 then
					local target_pos_delta = Vector3.new(0, 0.01, 0)
					if cur_shape_mod then
						target_pos_delta = cur_shape_mod.f2(p, active_c, d, ft, cur_shape_cfg, x1, x6, x9)
					end
					if x1.VerticalStiffness and x1.VerticalStiffness ~= 1 then
						target_pos_delta =
							Vector3.new(target_pos_delta.X, target_pos_delta.Y * x1.VerticalStiffness, target_pos_delta.Z)
					end
					if x1.Ki and x1.Ki > 0 and d.integral then
						d.integral = d.integral + (target_pos_delta * real_dt * 60 * dt)
						local max_i = 100
						if d.integral.Magnitude > max_i then
							d.integral = d.integral.Unit * max_i
						end
						target_pos_delta = target_pos_delta + (d.integral * x1.Ki)
					end
					local tv = target_pos_delta
					if x1.Damping and x1.Damping > 0 and not cur_no_damp then
						tv = tv - (p_vel * x1.Damping)
					end

					if x1.MaxSpeed and not cur_no_damp then
						local spd = p_vel.Magnitude
						local s_factor = math.clamp(1 - (spd / x1.MaxSpeed), 0.2, 1)
						tv = tv * s_factor
					end

					local smoothing = (x1.k6 == "Point Impact" and 1) or x1.k8
					if x1.DramaMode and x1.k6 == "Point Impact" then
						smoothing = 1
					end
					local sm_alpha = smoothing >= 1 and 1 or (1 - math.exp(-60 * real_dt * dt * -math.log(math.max(0.001, 1 - smoothing))))
					d.vl = d.vl and d.vl:Lerp(tv, sm_alpha) or tv
					if d.trans_vl and x6.transition_time > 0 then
						local alpha = math.clamp((ft - x6.transition_time) / x6.transition_dur, 0, 1)
						if alpha < 1 then
							local ease = alpha * alpha * (3 - 2 * alpha)
							d.vl = d.trans_vl:Lerp(d.vl, ease)
						else
							d.trans_vl = nil
						end
					end
					if x1.MaxSpeed and not cur_no_damp then
						if d.vl.Magnitude > x1.MaxSpeed then
							d.vl = d.vl.Unit * x1.MaxSpeed
						end
					else
						if d.vl.Magnitude > 3000 then
							d.vl = d.vl.Unit * 3000
						end
					end
					d.lv.VectorVelocity = d.vl
					if x1.AngularDamping and x1.AngularDamping > 0 then
						local damp_rate = -60 * math.log(math.max(0.001, 1 - math.clamp(x1.AngularDamping, 0, 0.99)))
						p.AssemblyAngularVelocity = p.AssemblyAngularVelocity
							* math.exp(-damp_rate * real_dt * dt)
					end
				end
			end
		end)
	end

	function x4.ProcessQueue()
		local queue = x6.claim_queue
		local qi = x6.queue_idx or 1
		local qn = #queue
		if qi > qn then
			if qn > 0 then
				table.clear(queue)
				x6.queue_idx = 1
			end
			return
		end
		local start = os.clock()
		while qi <= qn do
			if os.clock() - start > 0.0015 then
				break
			end
			local p = queue[qi]
			qi = qi + 1
			if p and p:IsA("BasePart") and p:IsDescendantOf(v4) then
				x4.f1(p)
			end
		end
		x6.queue_idx = qi
		if qi > qn then
			table.clear(queue)
			x6.queue_idx = 1
		end
	end

	local function f4(real_dt)
		real_dt = real_dt or (1/60)
		if not x6.b or x1.Disabled then
			return
		end
		if x1.TgtActive and x1.Tgt and x1.Tgt.Character and x1.Tgt.Character:FindFirstChild("HumanoidRootPart") then
			x6.b.Position = x1.Tgt.Character.HumanoidRootPart.Position
			x6.b.AssemblyLinearVelocity = Vector3.zero
			return
		elseif x1.AnchorSelf and v8.Character and v8.Character:FindFirstChild("HumanoidRootPart") then
			x6.b.Position = v8.Character.HumanoidRootPart.Position
			x6.b.AssemblyLinearVelocity = Vector3.zero
			return
		elseif x6.d then
			local c = v4.CurrentCamera
			if not c then
				return
			end
			x6.p = x6.p or (x6.b.Position - c.CFrame.Position).Magnitude
			local mp = v1:GetMouseLocation()
			local r = c:ViewportPointToRay(mp.X, mp.Y)
			local tp = r.Origin + (r.Direction * x6.p)
			local alpha = x9.c8 >= 1 and 1 or (1 - math.exp(-60 * real_dt * -math.log(math.max(0.001, 1 - x9.c8))))
			x6.b.Position = x6.b.Position:Lerp(tp, alpha)
			x6.b.AssemblyLinearVelocity = Vector3.zero
		end
	end

	function x4.f1(p)
		if not p:IsA("BasePart") or x7.e(p) or x6.a[p] then
			return
		end
		for _, c in ipairs(p:GetChildren()) do
			if
				c:IsA("BodyAngularVelocity")
				or c:IsA("BodyForce")
				or c:IsA("BodyGyro")
				or c:IsA("BodyPosition")
				or c:IsA("BodyThrust")
				or c:IsA("BodyVelocity")
				or c:IsA("RocketPropulsion")
			then
				c:Destroy()
			end
			if c:IsA("Attachment") or c:IsA("AlignPosition") or c:IsA("Torque") then
				c:Destroy()
			end
		end
		if p:FindFirstChild("BHAtt") then
			p.BHAtt:Destroy()
		end
		p.CanCollide = false
		p.Anchored = false
		p.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0)
		local a = Instance.new("Attachment", p)
		a.Name = "GRV_ATT"
		local lv = Instance.new("LinearVelocity", p)
		lv.Name = "GRV_LV"
		lv.MaxForce = x1.k4
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.RelativeTo = Enum.ActuatorRelativeTo.World
		lv.Attachment0 = a
		local av = Instance.new("AngularVelocity", p)
		av.Name = "GRV_AV"
		av.MaxTorque = math.huge
		av.RelativeTo = Enum.ActuatorRelativeTo.World
		av.AngularVelocity = Vector3.zero
		av.Attachment0 = a
		x6.a[p] = { at = a, lv = lv, av = av, integral = Vector3.zero }
		table.insert(x6.active_array, p)
		x6.n = x6.n + 1
	end

	function x4.f2(p)
		local d = x6.a[p]
		if d then
			if d.at and d.at.Parent then
				d.at:Destroy()
			end
			if d.lv and d.lv.Parent then
				d.lv:Destroy()
			end
			if d.av and d.av.Parent then
				d.av:Destroy()
			end
			x6.a[p] = nil
		end
		local idx = table.find(x6.active_array, p)
		if idx then
			local last = #x6.active_array
			if idx ~= last then
				x6.active_array[idx] = x6.active_array[last]
			end
			table.remove(x6.active_array, last)
			x6.n = math.max(0, x6.n - 1)
		end
	end

	function x4.f3()
		pcall(function()
			settings().Physics.AllowSleep = false
		end)
		local last_upd = 0
		table.insert(
			x6.c,
			v3.Heartbeat:Connect(function(dt)
				if time() - last_upd > 0.5 then
					last_upd = time()
					for _, p in ipairs(v2:GetPlayers()) do
						if p ~= v8 then
							pcall(function()
								p.MaximumSimulationRadius = 0
								if sethiddenproperty then
									sethiddenproperty(p, "SimulationRadius", 0)
								end
							end)
						end
					end
					pcall(function()
						if sethiddenproperty then
							sethiddenproperty(v8, "NetworkIsSleeping", false)
						end
					end)
					pcall(function()
						if setscriptable then
							setscriptable(v8, "SimulationRadius", true)
							setscriptable(v8, "MaximumSimulationRadius", true)
						end
					end)

					pcall(function()
						v8.MaximumSimulationRadius = 9e9
					end)

					pcall(function()
						if sethiddenproperty then
							sethiddenproperty(v8, "SimulationRadius", 9e9)
						elseif setsimulationradius then
							setsimulationradius(9e9)
						end
					end)

					pcall(function()
						if x6.b then
							v8.ReplicationFocus = x6.b
						else
							v8.ReplicationFocus = nil
						end
					end)
				end
			end)
		)
		table.insert(
			x6.c,
			v3.Stepped:Connect(function()
				if x1.AntiFling then
					for _, p in ipairs(v2:GetPlayers()) do
						if p ~= v8 and p.Character then
							for _, part in ipairs(p.Character:GetChildren()) do
								if part:IsA("BasePart") and part.CanCollide then
									part.CanCollide = false
								end
							end
						end
					end
				end
			end)
		)
	end

	function x4.f4(pos)
		if x6.b then
			v6:Create(x6.b, TweenInfo.new(x9.c7), { Position = pos }):Play()
			return
		end
		local f = Instance.new("Folder", v4)
		f.Name = "AS"
		x6.b = Instance.new("Part", f)
		x6.b.Size = x1.k2
		x6.b.Shape = "Ball"
		x6.b.Color = x1.k3
		x6.b.Anchored = true
		x6.b.CanCollide = false
		x6.b.Material = "Neon"
		x6.b.Position = pos
		x6.b.Transparency = x9.c7
		local bg = Instance.new("BillboardGui", x6.b)
		bg.Name = "Visual"
		bg.Adornee = x6.b
		bg.Size = UDim2.new(0, 20, 0, 20)
		bg.AlwaysOnTop = true
		local img = Instance.new("ImageLabel", bg)
		img.BackgroundTransparency = 1
		img.Size = UDim2.new(1, 0, 1, 0)
		img.Image = "rbxassetid://3570695787"
		img.ImageColor3 = x1.k3
		v6
			:Create(
				x6.b,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Size = x1.k2 * 1.2 }
			)
			:Play()
		local descendants = v4:GetDescendants()
		for i, v in ipairs(descendants) do
			if v:IsA("BasePart") then
				table.insert(x6.claim_queue, v)
			end
			if i % 5000 == 0 then
				task.wait()
			end
		end

		table.insert(
			x6.c,
			v4.DescendantAdded:Connect(function(v)
				if v:IsA("BasePart") then
					table.insert(x6.claim_queue, v)
				end
			end)
		)
		x6.o = true
		x7.n("Sys", "Started", 3)
		x5.st()
		table.insert(
			x6.c,
			v3.Heartbeat:Connect(function(real_dt)
				f3(real_dt)
				f4(real_dt)
				x4.ProcessQueue()
			end)
		)
	end

	function x4.f5()
		if x6.b then
			x6.b.Parent:Destroy()
			x6.b = nil
		end
		if x6.sg then
			x6.sg:Destroy()
			x6.sg = nil
		end
		for p, _ in pairs(x6.a) do
			x4.f2(p)
		end
		for _, c in ipairs(x6.c) do
			c:Disconnect()
		end
		x6.c = {}
		if x6.f1_connections then
			for _, c in ipairs(x6.f1_connections) do
				if c then c:Disconnect() end
			end
			table.clear(x6.f1_connections)
		end
		x6.a = {}
		x6.o = false
		v7:UnbindAction("C")
		v7:UnbindAction("R")
		if x5.g then
			x5.g:Destroy()
		end
		x7.n("Sys", "Stopped", 2)
	end

	function x8.h(n, s, o)
		if s ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		if n == "C" then
			x4.f4(v9.Hit.p)
			return Enum.ContextActionResult.Sink
		elseif n == "R" then
			x4.f5()
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end

	function x8.i()
		v7:BindAction("C", x8.h, false, Enum.KeyCode.E)
		v7:BindAction("R", x8.h, false, Enum.KeyCode.Q)
		v7:BindAction("P", function(_, s)
			if s == Enum.UserInputState.Begin then
				x1.Paused = not x1.Paused
				x7.n("Sys", x1.Paused and "Paused" or "Resumed", 2)
			end
		end, false, Enum.KeyCode.P)
		v7:BindAction("Disable", function(_, s)
			if s == Enum.UserInputState.Begin then
				x1.Disabled = not x1.Disabled
				local state = x1.Disabled and "Disabled" or "Enabled"
				x7.n("Sys", "Script " .. state, 2)
				if x6.disable_btn then
					x6.disable_btn.BackgroundColor3 = x1.Disabled and Color3.fromRGB(100, 255, 100)
						or Color3.fromRGB(60, 60, 60)
					local v = x1.Disabled
					if x6.b then
						x6.b.Transparency = v and 1 or x9.c7
						if x6.b:FindFirstChild("Visual") then
							x6.b.Visual.Enabled = not v
						end
					end
					for _, d in pairs(x6.a) do
						if d.lv then
							d.lv.MaxForce = v and 0 or x1.k4
						end
						if d.av then
							d.av.MaxTorque = v and 0 or math.huge
						end
					end
				end
			end
		end, false, Enum.KeyCode.L)
		table.insert(
			x6.c,
			v1.InputBegan:Connect(function(i, p)
				if p or not x6.b then
					return
				end
				if i.UserInputType == Enum.UserInputType.MouseButton1 and v9.Target == x6.b then
					x6.d = true
					x6.p = (v4.CurrentCamera and (x6.b.Position - v4.CurrentCamera.CFrame.Position).Magnitude) or 50
				end
			end)
		)
		table.insert(
			x6.c,
			v1.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					x6.d = false
				end
			end)
		)

		local sculptor_binder = load_module("System_sculptor.lua")(context, x7)
		sculptor_binder()

		x7.n("Rdy", "Press 'E'", 5)
	end

	return { x4 = x4, x8 = x8 }
end

end

__MODULES["System_sculptor.lua"] = function()
return function(context, x7)
	local v1, v4, v9 = context.v1, context.v4, context.v9
	local x1, x6 = context.x1, context.x6

	return function()
		local function sculptor_clear_highlights()
			for part, highlight in pairs(x6.sculptor_highlights) do
				if highlight and highlight.Parent then
					highlight:Destroy()
				end
			end
			x6.sculptor_highlights = {}
		end

		local function sculptor_add_highlight(part)
			if x6.sculptor_highlights[part] then
				return
			end
			local highlight = Instance.new("SelectionBox")
			highlight.Adornee = part
			highlight.Color3 = Color3.fromRGB(0, 255, 200)
			highlight.LineThickness = 0.05
			highlight.SurfaceTransparency = 0.8
			highlight.SurfaceColor3 = Color3.fromRGB(0, 255, 200)
			highlight.Parent = part
			x6.sculptor_highlights[part] = highlight
		end

		local function sculptor_remove_highlight(part)
			if x6.sculptor_highlights[part] then
				x6.sculptor_highlights[part]:Destroy()
				x6.sculptor_highlights[part] = nil
			end
		end

		local function sculptor_select(part, add_to_selection)
			if not add_to_selection then
				for p, _ in pairs(x6.sculptor_selected) do
					sculptor_remove_highlight(p)
				end
				x6.sculptor_selected = {}
			end
			if part and x6.a[part] then
				x6.sculptor_selected[part] = Vector3.zero
				sculptor_add_highlight(part)
			end
		end

		local function sculptor_deselect(part)
			x6.sculptor_selected[part] = nil
			sculptor_remove_highlight(part)
		end

		local function sculptor_get_mouse_world_pos(distance)
			local cam = v4.CurrentCamera
			if not cam then
				return nil
			end
			local mp = v1:GetMouseLocation()
			local ray = cam:ViewportPointToRay(mp.X, mp.Y)
			return ray.Origin + (ray.Direction * distance)
		end

		table.insert(
			x6.c,
			v1.InputBegan:Connect(function(input, processed)
				if processed or x1.k6 ~= "Sculptor" then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local target = v9.Target
					local shift_held = v1:IsKeyDown(Enum.KeyCode.LeftShift) or v1:IsKeyDown(Enum.KeyCode.RightShift)

					if target and x6.a[target] then
						if x6.sculptor_selected[target] then
							if shift_held then
								sculptor_deselect(target)
							else
								x6.sculptor_dragging = true
								x6.sculptor_drag_start = target.Position
								x6.sculptor_drag_distance = (v4.CurrentCamera.CFrame.Position - target.Position).Magnitude
								x6.sculptor_drag_target = target.Position
								for part, _ in pairs(x6.sculptor_selected) do
									x6.sculptor_selected[part] = part.Position - target.Position
								end
							end
						else
							sculptor_select(target, shift_held)
							if not shift_held then
								x6.sculptor_dragging = true
								x6.sculptor_drag_start = target.Position
								x6.sculptor_drag_distance = (v4.CurrentCamera.CFrame.Position - target.Position).Magnitude
								x6.sculptor_drag_target = target.Position
								x6.sculptor_selected[target] = Vector3.zero
							end
						end
					else
						if not shift_held then
							for p, _ in pairs(x6.sculptor_selected) do
								sculptor_remove_highlight(p)
							end
							x6.sculptor_selected = {}
						end
						x6.sculptor_box_start = v1:GetMouseLocation()
						if not x6.sculptor_box and x6.sg then
							x6.sculptor_box = Instance.new("Frame", x6.sg)
							x6.sculptor_box.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
							x6.sculptor_box.BackgroundTransparency = 0.7
							x6.sculptor_box.BorderSizePixel = 2
							x6.sculptor_box.BorderColor3 = Color3.fromRGB(0, 255, 200)
							x6.sculptor_box.ZIndex = 50
						end
					end
				end
			end)
		)

		table.insert(
			x6.c,
			v1.InputChanged:Connect(function(input, processed)
				if x1.k6 ~= "Sculptor" then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if x6.sculptor_dragging then
						x6.sculptor_drag_target = sculptor_get_mouse_world_pos(x6.sculptor_drag_distance or 50)
					elseif x6.sculptor_box_start and x6.sculptor_box then
						local current = v1:GetMouseLocation()
						local minX = math.min(x6.sculptor_box_start.X, current.X)
						local minY = math.min(x6.sculptor_box_start.Y, current.Y)
						local maxX = math.max(x6.sculptor_box_start.X, current.X)
						local maxY = math.max(x6.sculptor_box_start.Y, current.Y)
						x6.sculptor_box.Position = UDim2.new(0, minX, 0, minY)
						x6.sculptor_box.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
						x6.sculptor_box.Visible = true
					end
				end
			end)
		)

		table.insert(
			x6.c,
			v1.InputEnded:Connect(function(input)
				if x1.k6 ~= "Sculptor" then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if x6.sculptor_dragging then
						x6.sculptor_dragging = false
						x6.sculptor_drag_target = nil
					end
					if x6.sculptor_box_start and x6.sculptor_box then
						local current = v1:GetMouseLocation()
						local minX = math.min(x6.sculptor_box_start.X, current.X)
						local minY = math.min(x6.sculptor_box_start.Y, current.Y)
						local maxX = math.max(x6.sculptor_box_start.X, current.X)
						local maxY = math.max(x6.sculptor_box_start.Y, current.Y)

						local cam = v4.CurrentCamera
						if cam then
							for part, _ in pairs(x6.a) do
								local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
								if
									onScreen
									and screenPos.X >= minX
									and screenPos.X <= maxX
									and screenPos.Y >= minY
									and screenPos.Y <= maxY
								then
									x6.sculptor_selected[part] = Vector3.zero
									sculptor_add_highlight(part)
								end
							end
						end

						x6.sculptor_box.Visible = false
						x6.sculptor_box_start = nil
					end
				end
			end)
		)
	end
end

end

__MODULES["UI.lua"] = function()
return function(context)
	local v1, v2, v3, v4, v5, v6, v7, v8, v9 = context.v1, context.v2, context.v3, context.v4, context.v5, context.v6, context.v7, context.v8, context.v9
	local x1, x2, x6, x9 = context.x1, context.x2, context.x6, context.x9
	local favorites, save_favs, save_settings = context.favorites, context.save_favs, context.save_settings
	local get_shape = context.get_shape
	local load_module = context.load_module

	local UI_elements = load_module("UI_elements.lua")(context)
	local es, et, eb, eh = UI_elements.s, UI_elements.t, UI_elements.b, UI_elements.h

	local x5 = {}
	x5.g = nil
	x5.s = es
	x5.t = et
	x5.b = eb
	x5.h = eh

	function x5.st()
		if x5.g and x5.up then
			x5.up()
			return
		end
		if x5.g then
			x5.g:Destroy()
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "G_" .. math.random(999)
		if gethui then
			sg.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(sg)
			sg.Parent = game:GetService("CoreGui")
		else
			sg.Parent = v8:WaitForChild("PlayerGui")
		end
		x6.sg = sg
		x5.g = sg
		x5.mw(sg)
	end

	function x5.mw(sg)
		local hud = Instance.new("Frame", sg)
		hud.Name = "StatusHUD"
		hud.BackgroundTransparency = 1
		hud.Position = UDim2.new(0.5, -200, 0, 20)
		hud.Size = UDim2.new(0, 400, 0, 30)

		local hud_l = Instance.new("TextLabel", hud)
		hud_l.BackgroundTransparency = 1
		hud_l.Size = UDim2.new(1, 0, 1, 0)
		hud_l.Font = Enum.Font.GothamBold
		hud_l.TextSize = 14
		hud_l.TextColor3 = Color3.fromRGB(255, 255, 255)

		table.insert(
			x6.c,
			v3.RenderStepped:Connect(function()
				if not x5.g then
					return
				end
				local tgt = x1.Tgt and (x1.Tgt.DisplayName or x1.Tgt.Name) or "None"
				local state = x1.Disabled and "DISABLED" or (x1.Paused and "PAUSED" or "ACTIVE")
				local col = x1.Disabled and Color3.fromRGB(255, 80, 80)
					or (x1.Paused and Color3.fromRGB(255, 180, 80) or Color3.fromRGB(80, 255, 150))
				hud_l.Text = string.format("TARGET: %s  |  STATUS: %s", tgt:upper(), state)
				hud_l.TextColor3 = col
			end)
		)

		local m = Instance.new("Frame", sg)
		m.Name = "Main"
		m.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		m.Position = UDim2.new(0, 30, 0.5, -250)
		m.Size = UDim2.new(0, 320, 0, 500)
		m.Active = true
		m.Draggable = true
		Instance.new("UICorner", m).CornerRadius = UDim.new(0, 10)
		local ms = Instance.new("UIStroke", m)
		ms.Color = Color3.fromRGB(40, 40, 45)
		ms.Thickness = 1

		local h = Instance.new("Frame", m)
		h.BackgroundTransparency = 1
		h.Size = UDim2.new(1, 0, 0, 50)

		local t = Instance.new("TextLabel", h)
		t.BackgroundTransparency = 1
		t.Position = UDim2.new(0, 20, 0, 0)
		t.Size = UDim2.new(0.6, 0, 1, 0)
		t.Text = "PROJECT GRAVITY"
		t.TextColor3 = Color3.fromRGB(255, 255, 255)
		t.Font = Enum.Font.GothamBlack
		t.TextSize = 16
		t.TextXAlignment = 0

		local c = Instance.new("ScrollingFrame", m)
		c.BackgroundTransparency = 1
		c.Position = UDim2.new(0, 0, 0, 60)
		c.Size = UDim2.new(1, 0, 1, -70)
		c.ScrollBarThickness = 0
		c.AutomaticCanvasSize = Enum.AutomaticSize.Y
		c.CanvasSize = UDim2.new(0, 0, 0, 0)
		local l = Instance.new("UIListLayout", c)
		l.Padding = UDim.new(0, 12)
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local p = Instance.new("UIPadding", c)
		p.PaddingLeft = UDim.new(0, 20)
		p.PaddingRight = UDim.new(0, 20)
		p.PaddingBottom = UDim.new(0, 20)

		local am = Instance.new("Frame", sg)
		am.Name = "Advanced"
		am.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		am.Position = UDim2.new(0, 360, 0.5, -200)
		am.Size = UDim2.new(0, 260, 0, 380)
		am.Visible = false
		am.Active = true
		am.Draggable = true
		Instance.new("UICorner", am).CornerRadius = UDim.new(0, 10)
		local ams = Instance.new("UIStroke", am)
		ams.Color = Color3.fromRGB(40, 40, 45)
		ams.Thickness = 1

		local ah = Instance.new("Frame", am)
		ah.BackgroundTransparency = 1
		ah.Size = UDim2.new(1, 0, 0, 50)
		local at = Instance.new("TextLabel", ah)
		at.BackgroundTransparency = 1
		at.Position = UDim2.new(0, 20, 0, 0)
		at.Size = UDim2.new(0.6, 0, 1, 0)
		at.Text = "ADVANCED"
		at.TextColor3 = Color3.fromRGB(255, 255, 255)
		at.Font = Enum.Font.GothamBold
		at.TextSize = 14
		at.TextXAlignment = 0

		local ac = Instance.new("ScrollingFrame", am)
		ac.BackgroundTransparency = 1
		ac.Position = UDim2.new(0, 0, 0, 50)
		ac.Size = UDim2.new(1, 0, 1, -60)
		ac.ScrollBarThickness = 0
		ac.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ac.CanvasSize = UDim2.new(0, 0, 0, 0)
		local acl = Instance.new("UIListLayout", ac)
		acl.Padding = UDim.new(0, 10)
		acl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local ap = Instance.new("UIPadding", ac)
		ap.PaddingLeft = UDim.new(0, 20)
		ap.PaddingRight = UDim.new(0, 20)

		es(ac, "Damping", 0, 5, x1.Damping, function(v)
			x1.Damping = v
			save_settings()
		end)
		es(ac, "Integral Gain", 0, 10, x1.Ki, function(v)
			x1.Ki = v
			save_settings()
		end)
		es(ac, "Max Speed", 50, 2000, x1.MaxSpeed or 500, function(v)
			x1.MaxSpeed = v
			save_settings()
		end)
		es(ac, "Angular Damp", 0, 1, x1.AngularDamping or 0.5, function(v)
			x1.AngularDamping = v
			save_settings()
		end)
		es(ac, "Vert Stiffness", 0.1, 5, x1.VerticalStiffness or 1.0, function(v)
			x1.VerticalStiffness = v
			save_settings()
		end)

		local ab = eb(c, "Advanced Settings", function()
			am.Visible = not am.Visible
		end)
		ab.Size = UDim2.new(1, 0, 0, 36)

		local mode_f = Instance.new("Frame", c)
		mode_f.BackgroundTransparency = 1
		mode_f.Size = UDim2.new(1, 0, 0, 44)
		local db = Instance.new("TextButton", mode_f)
		db.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		db.Size = UDim2.new(1, 0, 1, 0)
		db.Text = "  " .. x1.k6:upper()
		db.TextColor3 = Color3.fromRGB(255, 255, 255)
		db.Font = Enum.Font.GothamBold
		db.TextSize = 13
		db.TextXAlignment = 0
		Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)
		local dst = Instance.new("UIStroke", db)
		dst.Color = Color3.fromRGB(40, 40, 45)

		local arr = Instance.new("TextLabel", db)
		arr.BackgroundTransparency = 1
		arr.Position = UDim2.new(1, -30, 0, 0)
		arr.Size = UDim2.new(0, 30, 1, 0)
		arr.Text = "▼"
		arr.TextColor3 = Color3.fromRGB(150, 150, 160)
		arr.TextSize = 10

		db.MouseButton1Click:Connect(function()
			if x6.dlst_container then
				x6.dlst_container.Visible = not x6.dlst_container.Visible
				if x6.dlst_container.Visible and x6.populate_modes then
					x6.populate_modes("")
				end
			end
		end)

		local gsc = Instance.new("Frame", c)
		gsc.BackgroundTransparency = 1
		gsc.Size = UDim2.new(1, 0, 0, 0)
		gsc.AutomaticSize = Enum.AutomaticSize.Y
		local gscl = Instance.new("UIListLayout", gsc)
		gscl.Padding = UDim.new(0, 8)
		gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local sc = Instance.new("Frame", c)
		sc.BackgroundTransparency = 1
		sc.Size = UDim2.new(1, 0, 0, 0)
		sc.AutomaticSize = Enum.AutomaticSize.Y
		local scl = Instance.new("UIListLayout", sc)
		scl.Padding = UDim.new(0, 8)
		scl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local function f1()
			if x6.f1_connections then
				for _, conn in ipairs(x6.f1_connections) do
					if conn then conn:Disconnect() end
				end
				table.clear(x6.f1_connections)
			else
				x6.f1_connections = {}
			end
			sc:ClearAllChildren()
			gsc:ClearAllChildren()
			local gscl = Instance.new("UIListLayout", gsc)
			gscl.Padding = UDim.new(0, 10)
			gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
			local scl = Instance.new("UIListLayout", sc)
			scl.Padding = UDim.new(0, 8)
			scl.HorizontalAlignment = Enum.HorizontalAlignment.Center
			local s = x1.S[x1.k6] or {}

			eh(gsc, "Control")
			et(gsc, "Simplified Interface", x1.SimpleMode, function(v)
				x1.SimpleMode = v
				save_settings()
				f1()
			end)

			et(gsc, "Anchor to Self", x1.AnchorSelf, function(v)
				x1.AnchorSelf = v
				save_settings()
			end)

			if not x1.SimpleMode then
				et(gsc, "Anti-Fling", x1.AntiFling, function(v)
					x1.AntiFling = v
					save_settings()
				end)
			end

			x6.disable_btn = et(gsc, "Disable Gravity", x1.Disabled, function(v)
				x1.Disabled = v
				save_settings()
				if x6.b then
					x6.b.Transparency = v and 1 or 0.8
					if x6.b:FindFirstChild("Visual") then
						x6.b.Visual.Enabled = not v
					end
				end
				for _, d in pairs(x6.a) do
					if d.lv then
						d.lv.MaxForce = v and 0 or x1.k4
					end
				end
			end)

			if not x1.SimpleMode then
				et(gsc, "Target Everyone", x1.PI_All, function(v)
					x1.PI_All = v
					save_settings()
				end)
			end

			local l_btn = Instance.new("TextButton", gsc)
			l_btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			l_btn.Size = UDim2.new(1, 0, 0, 36)
			l_btn.Text = "FORCE LAUNCH"
			l_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			l_btn.Font = Enum.Font.GothamBold
			l_btn.TextSize = 13
			Instance.new("UICorner", l_btn).CornerRadius = UDim.new(0, 6)
			l_btn.Visible = x1.ImpactManual or (x1.k6 == "Slingshot" and x1.SlingshotManual)

			l_btn.MouseButton1Click:Connect(function()
				x1.IsLaunching = not x1.IsLaunching
				l_btn.Text = x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH"
				l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(200, 50, 50)
			end)

			table.insert(
				x6.f1_connections,
				v3.Heartbeat:Connect(function()
					if x1.ImpactManual or (x1.k6 == "Slingshot" and x1.SlingshotManual) then
						l_btn.Visible = true
						l_btn.Text = x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH"
						l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(50, 150, 200)
							or Color3.fromRGB(200, 50, 50)
					else
						l_btn.Visible = false
					end
				end)
			)

			local tn = x1.Tgt and "Target: " .. (x1.Tgt.DisplayName or x1.Tgt.Name) or "Select Target"

			local tdb = Instance.new("TextButton", gsc)
			tdb.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			tdb.Size = UDim2.new(1, 0, 0, 38)
			tdb.Text = "  " .. tn:upper()
			tdb.TextColor3 = Color3.fromRGB(255, 255, 255)
			tdb.Font = Enum.Font.GothamBold
			tdb.TextSize = 12
			tdb.TextXAlignment = 0
			Instance.new("UICorner", tdb).CornerRadius = UDim.new(0, 6)
			local dst2 = Instance.new("UIStroke", tdb)
			dst2.Color = Color3.fromRGB(40, 40, 45)

			if x1.Tgt then
				local ctb = Instance.new("TextButton", tdb)
				ctb.BackgroundTransparency = 1
				ctb.Position = UDim2.new(1, -30, 0, 0)
				ctb.Size = UDim2.new(0, 30, 1, 0)
				ctb.Text = "×"
				ctb.TextColor3 = Color3.fromRGB(200, 80, 80)
				ctb.TextSize = 20
				ctb.MouseButton1Click:Connect(function()
					x1.Tgt = nil
					x1.TgtActive = false
					f1()
				end)
			end

			if m:FindFirstChild("TargetListContainer") then
				m.TargetListContainer:Destroy()
			end
			local tdlst = Instance.new("Frame", m)
			tdlst.Name = "TargetListContainer"
			tdlst.Visible = false
			tdlst.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
			tdlst.Position = UDim2.new(1, 15, 0, 0)
			tdlst.Size = UDim2.new(0, 220, 1, 0)
			Instance.new("UICorner", tdlst).CornerRadius = UDim.new(0, 10)
			local ts = Instance.new("UIStroke", tdlst)
			ts.Color = Color3.fromRGB(40, 40, 45)

			local search_bar = Instance.new("TextBox", tdlst)
			search_bar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
			search_bar.Position = UDim2.new(0, 10, 0, 10)
			search_bar.Size = UDim2.new(1, -20, 0, 34)
			search_bar.PlaceholderText = "Search players..."
			search_bar.Text = ""
			search_bar.TextColor3 = Color3.fromRGB(255, 255, 255)
			search_bar.Font = Enum.Font.Gotham
			search_bar.TextSize = 13
			Instance.new("UICorner", search_bar).CornerRadius = UDim.new(0, 6)

			local scroll_frame = Instance.new("ScrollingFrame", tdlst)
			scroll_frame.BackgroundTransparency = 1
			scroll_frame.Position = UDim2.new(0, 0, 0, 55)
			scroll_frame.Size = UDim2.new(1, 0, 1, -65)
			scroll_frame.ScrollBarThickness = 0
			scroll_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			local tdll = Instance.new("UIListLayout", scroll_frame)
			tdll.Padding = UDim.new(0, 5)
			tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center

			local active_highlight = nil
			local function clear_highlight()
				if active_highlight then
					active_highlight:Destroy()
					active_highlight = nil
				end
			end

			local function update_list(filter_text)
				clear_highlight()
				scroll_frame:ClearAllChildren()
				local tdll = Instance.new("UIListLayout", scroll_frame)
				tdll.Padding = UDim.new(0, 5)
				tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center

				for _, pl in ipairs(v2:GetPlayers()) do
					if pl == v8 then
						continue
					end
					if
						filter_text ~= ""
						and not (
							pl.DisplayName:lower():find(filter_text:lower()) or pl.Name:lower():find(filter_text:lower())
						)
					then
						continue
					end

					local ib = Instance.new("TextButton", scroll_frame)
					ib.Size = UDim2.new(1, -16, 0, 44)
					ib.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
					ib.Text = "  " .. pl.DisplayName
					ib.TextColor3 = Color3.fromRGB(255, 255, 255)
					ib.Font = Enum.Font.GothamBold
					ib.TextSize = 12
					ib.TextXAlignment = 0
					Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 6)

					ib.MouseEnter:Connect(function()
						ib.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
						if pl.Character then
							local h = Instance.new("Highlight", pl.Character)
							h.FillColor = Color3.fromRGB(255, 255, 255)
							h.OutlineColor = Color3.fromRGB(255, 255, 255)
							active_highlight = h
						end
					end)
					ib.MouseLeave:Connect(function()
						ib.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
						clear_highlight()
					end)

					ib.MouseButton1Click:Connect(function()
						x1.Tgt = pl
						x1.TgtActive = true
						tdlst.Visible = false
						f1()
					end)
				end
			end

			table.insert(x6.f1_connections, search_bar:GetPropertyChangedSignal("Text"):Connect(function()
				update_list(search_bar.Text)
			end))
			tdb.MouseButton1Click:Connect(function()
				tdlst.Visible = not tdlst.Visible
				if tdlst.Visible then
					update_list("")
				end
			end)

			if not x1.SimpleMode then
				eh(sc, "Shape")
				local shape_mod = get_shape(x1.k6)
				if shape_mod and shape_mod.Controls then
					for _, ctrl in ipairs(shape_mod.Controls) do
						local current_val = s[ctrl.Key]
						local p_frame = ctrl.Parent == "gsc" and gsc or sc
						if ctrl.Type == "Slider" then
							if current_val == nil then current_val = ctrl.Min end
							if ctrl.Div then current_val = current_val * ctrl.Div end
							es(p_frame, ctrl.Name, ctrl.Min, ctrl.Max, current_val, function(v)
								if ctrl.Div then s[ctrl.Key] = v / ctrl.Div else s[ctrl.Key] = v end
							end, ctrl.IntOnly)
						elseif ctrl.Type == "Toggle" then
							et(p_frame, ctrl.Name, current_val, function(v)
								s[ctrl.Key] = v
							end)
						end
					end
				end
			end
		end
		x5.up = f1

		local dlst_container = Instance.new("Frame", m)
		dlst_container.Name = "ModeSelector"
		dlst_container.Visible = false
		dlst_container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		dlst_container.Position = UDim2.new(1, 15, 0, 0)
		dlst_container.Size = UDim2.new(0, 220, 1, 0)
		Instance.new("UICorner", dlst_container).CornerRadius = UDim.new(0, 10)
		local dls = Instance.new("UIStroke", dlst_container)
		dls.Color = Color3.fromRGB(40, 40, 45)

		local msb = Instance.new("TextBox", dlst_container)
		msb.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		msb.Position = UDim2.new(0, 10, 0, 10)
		msb.Size = UDim2.new(1, -20, 0, 34)
		msb.PlaceholderText = "Search modes..."
		msb.Text = ""
		msb.TextColor3 = Color3.fromRGB(255, 255, 255)
		msb.Font = Enum.Font.Gotham
		msb.TextSize = 13
		Instance.new("UICorner", msb).CornerRadius = UDim.new(0, 6)

		local dlst = Instance.new("ScrollingFrame", dlst_container)
		dlst.BackgroundTransparency = 1
		dlst.Position = UDim2.new(0, 0, 0, 55)
		dlst.Size = UDim2.new(1, 0, 1, -65)
		dlst.ScrollBarThickness = 0
		dlst.AutomaticCanvasSize = Enum.AutomaticSize.Y
		dlst.CanvasSize = UDim2.new(0, 0, 0, 0)

		x6.dlst_container = dlst_container

		local function populate_modes(filter)
			dlst:ClearAllChildren()
			local dll = Instance.new("UIListLayout", dlst)
			dll.Padding = UDim.new(0, 5)
			dll.HorizontalAlignment = Enum.HorizontalAlignment.Center

			local modes = {}
			for mn, _ in pairs(x2) do
				table.insert(modes, mn)
			end

			table.sort(modes, function(a, b)
				local fa, fb = favorites[a] and 1 or 0, favorites[b] and 1 or 0
				if fa ~= fb then
					return fa > fb
				end
				return a < b
			end)

			for _, mn in ipairs(modes) do
				if filter ~= "" and not mn:lower():find(filter:lower()) then
					continue
				end

				local f = Instance.new("Frame", dlst)
				f.Size = UDim2.new(1, -16, 0, 40)
				f.BackgroundColor3 = mn == x1.k6 and Color3.fromRGB(40, 40, 180) or Color3.fromRGB(25, 25, 30)
				Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

				local ib = Instance.new("TextButton", f)
				ib.Size = UDim2.new(1, -40, 1, 0)
				ib.Position = UDim2.new(0, 8, 0, 0)
				ib.BackgroundTransparency = 1
				ib.Text = "  " .. mn
				ib.TextColor3 = Color3.fromRGB(255, 255, 255)
				ib.Font = Enum.Font.GothamBold
				ib.TextSize = 12
				ib.TextXAlignment = 0

				local sb = Instance.new("TextButton", f)
				sb.Position = UDim2.new(1, -35, 0, 0)
				sb.Size = UDim2.new(0, 35, 1, 0)
				sb.BackgroundTransparency = 1
				sb.Text = favorites[mn] and "★" or "☆"
				sb.TextColor3 = favorites[mn] and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 80, 85)
				sb.Font = Enum.Font.GothamBold
				sb.TextSize = 14

				sb.MouseButton1Click:Connect(function()
					favorites[mn] = not favorites[mn]
					save_favs()
					populate_modes(filter)
				end)

				ib.MouseButton1Click:Connect(function()
					local shape = get_shape(mn)
					if shape then
						x1.k6 = mn
						x6.transition_time = time()
						for _, d in pairs(x6.a) do
							d.trans_vl = d.vl or Vector3.zero
							d.v1, d.v2, d.v3, d.v4, d.v5, d.v6, d.v7, d.v8, d.v9 = nil, nil, nil, nil, nil, nil, nil, nil, nil
							d.integral = Vector3.zero
						end
						if db then
							db.Text = "  " .. mn:upper()
						end
						dlst_container.Visible = false
						save_settings()
						if x5.up then
							x5.up()
						end
					end
				end)
			end
		end

		msb:GetPropertyChangedSignal("Text"):Connect(function()
			populate_modes(msb.Text)
		end)

		x6.populate_modes = populate_modes
		populate_modes("")

		local minb = Instance.new("TextButton", h)
		minb.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
		minb.Position = UDim2.new(1, -60, 0.5, -10)
		minb.Size = UDim2.new(0, 20, 0, 20)
		minb.Text = ""
		Instance.new("UICorner", minb).CornerRadius = UDim.new(1, 0)

		local closeb = Instance.new("TextButton", h)
		closeb.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		closeb.Position = UDim2.new(1, -30, 0.5, -10)
		closeb.Size = UDim2.new(0, 20, 0, 20)
		closeb.Text = ""
		Instance.new("UICorner", closeb).CornerRadius = UDim.new(1, 0)

		local im = false
		minb.MouseButton1Click:Connect(function()
			im = not im
			c.Visible = not im
			if im then
				am.Visible = false
				if x6.dlst_container then
					x6.dlst_container.Visible = false
				end
				if m:FindFirstChild("TargetListContainer") then
					m.TargetListContainer.Visible = false
				end
			end
			m:TweenSize(im and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 500), "Out", "Quart", 0.3, true)
		end)

		closeb.MouseButton1Click:Connect(function()
			sg:Destroy()
		end)
	end

	return x5
end

end

__MODULES["UI_elements.lua"] = function()
return function(context)
	local v1, v6 = context.v1, context.v6
	local save_settings = context.save_settings
	local M = {}

	function M.s(p, t, mn, mx, df, cb, is_int)
		df = df or mn
		if is_int or mx - mn > 50 then
			df = math.floor(df + 0.5)
		else
			df = math.floor(df * 10 + 0.5) / 10
		end
		local f = Instance.new("Frame", p)
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, 0, 0, 42)

		local l = Instance.new("TextLabel", f)
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0, 20)
		l.Text = t
		l.TextColor3 = Color3.fromRGB(180, 180, 180)
		l.TextXAlignment = 0
		l.Font = Enum.Font.Gotham
		l.TextSize = 12

		local vl = Instance.new("TextLabel", f)
		vl.BackgroundTransparency = 1
		vl.Position = UDim2.new(1, -50, 0, 0)
		vl.Size = UDim2.new(0, 50, 0, 20)
		vl.Text = tostring(df)
		vl.TextColor3 = Color3.fromRGB(255, 255, 255)
		vl.TextXAlignment = 1
		vl.Font = Enum.Font.GothamBold
		vl.TextSize = 12

		local sc = Instance.new("Frame", f)
		sc.BackgroundTransparency = 1
		sc.Position = UDim2.new(0, 0, 0, 26)
		sc.Size = UDim2.new(1, 0, 0, 4)

		local sb = Instance.new("Frame", sc)
		sb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		sb.BorderSizePixel = 0
		sb.Size = UDim2.new(1, 0, 1, 0)
		Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)

		local fl = Instance.new("Frame", sb)
		fl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		fl.BorderSizePixel = 0
		fl.Size = UDim2.new((df - mn) / (mx - mn), 0, 1, 0)
		Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

		local k = Instance.new("ImageButton", sc)
		k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		k.AnchorPoint = Vector2.new(0.5, 0.5)
		k.Position = UDim2.new((df - mn) / (mx - mn), 0, 0.5, 0)
		k.Size = UDim2.new(0, 12, 0, 12)
		k.BorderSizePixel = 0
		k.AutoButtonColor = false
		Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

		local d = false
		local function u(i)
			local pos = i.Position.X
			local rp = pos - sc.AbsolutePosition.X
			local pc = math.clamp(rp / sc.AbsoluteSize.X, 0, 1)
			local v = mn + (mx - mn) * pc
			if is_int or mx - mn > 50 then
				v = math.floor(v + 0.5)
			else
				v = math.floor(v * 10 + 0.5) / 10
			end
			local snapped_pc = (v - mn) / (mx - mn)
			v6:Create(fl, TweenInfo.new(0.1), { Size = UDim2.new(snapped_pc, 0, 1, 0) }):Play()
			v6:Create(k, TweenInfo.new(0.1), { Position = UDim2.new(snapped_pc, 0, 0.5, 0) }):Play()
			vl.Text = tostring(v)
			cb(v)
			if save_settings then
				save_settings()
			end
		end

		k.MouseButton1Down:Connect(function()
			d = true
		end)
		sb.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				d = true
				u(i)
			end
		end)
		local c1 = v1.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				d = false
			end
		end)
		local c2 = v1.InputChanged:Connect(function(i)
			if d and i.UserInputType == Enum.UserInputType.MouseMovement then
				u(i)
			end
		end)

		f.AncestryChanged:Connect(function(_, parent)
			if not parent then
				c1:Disconnect()
				c2:Disconnect()
			end
		end)
	end

	function M.t(p, t, df, cb)
		local f = Instance.new("Frame", p)
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, 0, 0, 32)

		local l = Instance.new("TextLabel", f)
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(0.8, 0, 1, 0)
		l.Text = t
		l.TextColor3 = Color3.fromRGB(180, 180, 180)
		l.TextXAlignment = 0
		l.Font = Enum.Font.Gotham
		l.TextSize = 12

		local bg = Instance.new("Frame", f)
		bg.BackgroundColor3 = df and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(40, 40, 45)
		bg.Position = UDim2.new(1, -36, 0.5, -9)
		bg.Size = UDim2.new(0, 36, 0, 18)
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

		local toggle = Instance.new("Frame", bg)
		toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggle.Position = df and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		toggle.Size = UDim2.new(0, 14, 0, 14)
		Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

		local b = Instance.new("TextButton", f)
		b.BackgroundTransparency = 1
		b.Size = UDim2.new(1, 0, 1, 0)
		b.Text = ""

		b.MouseButton1Click:Connect(function()
			df = not df
			v6:Create(
				bg,
				TweenInfo.new(0.2),
				{ BackgroundColor3 = df and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(40, 40, 45) }
			):Play()
			v6:Create(
				toggle,
				TweenInfo.new(0.2),
				{ Position = df and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }
			):Play()
			cb(df)
			if save_settings then
				save_settings()
			end
		end)
		return b
	end

	function M.b(p, t, cb)
		local b = Instance.new("TextButton", p)
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		b.Size = UDim2.new(1, 0, 0, 34)
		b.AutoButtonColor = false
		b.Text = t
		b.TextColor3 = Color3.fromRGB(220, 220, 220)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 13
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

		local str = Instance.new("UIStroke", b)
		str.Color = Color3.fromRGB(50, 50, 55)
		str.Thickness = 1

		b.MouseEnter:Connect(function()
			v6:Create(
				b,
				TweenInfo.new(0.2),
				{ BackgroundColor3 = Color3.fromRGB(40, 40, 45), TextColor3 = Color3.fromRGB(255, 255, 255) }
			):Play()
		end)
		b.MouseLeave:Connect(function()
			v6:Create(
				b,
				TweenInfo.new(0.2),
				{ BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(220, 220, 220) }
			):Play()
		end)

		b.MouseButton1Click:Connect(function()
			cb(b)
		end)
		return b
	end

	function M.h(p, t)
		local l = Instance.new("TextLabel", p)
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0, 24)
		l.Text = t:upper()
		l.TextColor3 = Color3.fromRGB(100, 100, 110)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 10
		l.TextXAlignment = Enum.TextXAlignment.Left
	end

	return M
end

end

__MODULES["mobilever/System.lua"] = function()
return function(context)
	local v1, v2, v3, v4, v5, v6, v7, v8, v9 = context.v1, context.v2, context.v3, context.v4, context.v5, context.v6, context.v7, context.v8, context.v9
	local x1, x2, x6, x9 = context.x1, context.x2, context.x6, context.x9
	local x5 = context.x5
	local get_shape = context.get_shape
	local load_module = context.load_module
	local SUB_DIR = context.SUB_DIR or "mobilever/"

	local x4, x8 = {}, {}
	local x7 = {}

	function x7.n(t, x, d)
		pcall(function()
			v5:SetCore("SendNotification", { Title = t, Text = x, Duration = d or 3 })
		end)
	end

	local EXCLUDED_NAMES = {
		Baseplate = true,
		HumanoidRootPart = true,
		Terrain = true,
		Handle = true,
		Head = true,
		Torso = true,
		["Left Arm"] = true,
		["Right Arm"] = true,
		["Left Leg"] = true,
		["Right Leg"] = true,
		UpperTorso = true,
		LowerTorso = true,
		LeftUpperArm = true,
		LeftLowerArm = true,
		LeftHand = true,
		RightUpperArm = true,
		RightLowerArm = true,
		RightHand = true,
		LeftUpperLeg = true,
		LeftLowerLeg = true,
		LeftFoot = true,
		RightUpperLeg = true,
		RightLowerLeg = true,
		RightFoot = true,
	}

	function x7.e(p)
		if not p:IsA("BasePart") then
			return true
		end
		if EXCLUDED_NAMES[p.Name] then
			return true
		end
		for _, t in ipairs(x1.k5) do
			if p:FindFirstChild(t) or (p.Parent and p.Parent:FindFirstChild(t)) then
				return true
			end
		end
		for _, pl in ipairs(v2:GetPlayers()) do
			if pl.Character and p:IsDescendantOf(pl.Character) then
				return true
			end
		end
		local target = p
		while target and target ~= v4 and target ~= game do
			if
				target:IsA("Model")
				and (target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("AnimationController"))
			then
				return true
			end
			if target:IsA("Accessory") or target:IsA("Tool") then
				return true
			end
			target = target.Parent
		end
		if p.Anchored then
			return true
		end
		return false
	end

	local function x3()
		return x1.S[x1.k6] or {}
	end

	local function px(md, t, c)
		local shape = get_shape(md)
		if shape and shape.px then
			shape.px(t, c, x6, x9)
		end
	end



	local no_damp = { ["Slingshot"] = true, ["Point Impact"] = true, ["Deflect"] = true }

	local function f3(real_dt)
		real_dt = real_dt or (1/60)
		if not x6.b or x1.Disabled then
			return
		end
		if x1.Paused then
			for _, d in pairs(x6.a) do
				if d.lv then
					d.lv.VectorVelocity = Vector3.new(0, 0.01, 0)
				end
			end
			return
		end
		pcall(function()
			local c = x6.b.Position
			x6.f = x6.f + 1
			local dt = x6.n > 5000 and 10 or (x6.n > 2500 and 6 or (x6.n > 1000 and 3 or 1))
			local et, ft = x1.k7 or dt, time()
			local i = 0
			if ft > x6.pi_timer then
				x6.pi_timer = ft + 1
				x6.pi_targets = {}
				if x1.PI_All then
					for _, pl in ipairs(v2:GetPlayers()) do
						if pl ~= v8 and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
							table.insert(x6.pi_targets, pl)
						end
					end
				else
					if x1.Tgt and x1.Tgt.Character and x1.Tgt.Character:FindFirstChild("HumanoidRootPart") then
						table.insert(x6.pi_targets, x1.Tgt)
					end
				end
			end
			px(x1.k6, ft, x3())
			local cur_no_damp = no_damp[x1.k6]
			
			local target_positions = {}
			local valid_targets = 0
			if #x6.pi_targets > 0 then
				for _, tgt in ipairs(x6.pi_targets) do
					if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
						table.insert(target_positions, tgt.Character.HumanoidRootPart.Position)
						valid_targets = valid_targets + 1
					end
				end
			end
			local cur_shape_mod = get_shape(x1.k6)
			local cur_shape_cfg = x1.S[x1.k6] or {}

			for k = #x6.active_array, 1, -1 do
				local p = x6.active_array[k]
				local d = x6.a[p]

				if not d or not p.Parent then
					if d then
						if d.at and d.at.Parent then d.at:Destroy() end
						if d.lv and d.lv.Parent then d.lv:Destroy() end
						if d.av and d.av.Parent then d.av:Destroy() end
						x6.a[p] = nil
					end
					local last = #x6.active_array
					if k ~= last then
						x6.active_array[k] = x6.active_array[last]
					end
					table.remove(x6.active_array, last)
					x6.n = math.max(0, x6.n - 1)
					continue
				end
				i = i + 1
				if i % et ~= (x6.f % et) then
					continue
				end
				local p_vel = p.AssemblyLinearVelocity
				local active_c = c
				if valid_targets > 0 then
					active_c = target_positions[((i - 1) % valid_targets) + 1]
				end
				local tc = active_c - p.Position
				local tc_mag = tc.Magnitude
				if tc_mag > x1.k1 then
					continue
				end
				if tc_mag > x9.c7 then
					local target_pos_delta = Vector3.new(0, 0.01, 0)
					if cur_shape_mod then
						target_pos_delta = cur_shape_mod.f2(p, active_c, d, ft, cur_shape_cfg, x1, x6, x9)
					end
					if x1.VerticalStiffness and x1.VerticalStiffness ~= 1 then
						target_pos_delta =
							Vector3.new(target_pos_delta.X, target_pos_delta.Y * x1.VerticalStiffness, target_pos_delta.Z)
					end
					if x1.Ki and x1.Ki > 0 and d.integral then
						d.integral = d.integral + (target_pos_delta * real_dt * 60 * dt)
						local max_i = 100
						if d.integral.Magnitude > max_i then
							d.integral = d.integral.Unit * max_i
						end
						target_pos_delta = target_pos_delta + (d.integral * x1.Ki)
					end
					local tv = target_pos_delta
					if x1.Damping and x1.Damping > 0 and not cur_no_damp then
						tv = tv - (p_vel * x1.Damping)
					end

					if x1.MaxSpeed and not cur_no_damp then
						local spd = p_vel.Magnitude
						local s_factor = math.clamp(1 - (spd / x1.MaxSpeed), 0.2, 1)
						tv = tv * s_factor
					end

					local smoothing = (x1.k6 == "Point Impact" and 1) or x1.k8
					if x1.DramaMode and x1.k6 == "Point Impact" then
						smoothing = 1
					end
					local sm_alpha = smoothing >= 1 and 1 or (1 - math.exp(-60 * real_dt * dt * -math.log(math.max(0.001, 1 - smoothing))))
					d.vl = d.vl and d.vl:Lerp(tv, sm_alpha) or tv
					if d.trans_vl and x6.transition_time > 0 then
						local alpha = math.clamp((ft - x6.transition_time) / x6.transition_dur, 0, 1)
						if alpha < 1 then
							local ease = alpha * alpha * (3 - 2 * alpha)
							d.vl = d.trans_vl:Lerp(d.vl, ease)
						else
							d.trans_vl = nil
						end
					end
					if x1.MaxSpeed and not cur_no_damp then
						if d.vl.Magnitude > x1.MaxSpeed then
							d.vl = d.vl.Unit * x1.MaxSpeed
						end
					else
						if d.vl.Magnitude > 3000 then
							d.vl = d.vl.Unit * 3000
						end
					end
					d.lv.VectorVelocity = d.vl
					if x1.AngularDamping and x1.AngularDamping > 0 then
						local damp_rate = -60 * math.log(math.max(0.001, 1 - math.clamp(x1.AngularDamping, 0, 0.99)))
						p.AssemblyAngularVelocity = p.AssemblyAngularVelocity
							* math.exp(-damp_rate * real_dt * dt)
					end
				end
			end
		end)
	end

	function x4.ProcessQueue()
		local queue = x6.claim_queue
		local qi = x6.queue_idx or 1
		local qn = #queue
		if qi > qn then
			if qn > 0 then
				table.clear(queue)
				x6.queue_idx = 1
			end
			return
		end
		local start = os.clock()
		while qi <= qn do
			if os.clock() - start > 0.0015 then
				break
			end
			local p = queue[qi]
			qi = qi + 1
			if p and p:IsA("BasePart") and p:IsDescendantOf(v4) then
				x4.f1(p)
			end
		end
		x6.queue_idx = qi
		if qi > qn then
			table.clear(queue)
			x6.queue_idx = 1
		end
	end

	local function f4(real_dt)
		real_dt = real_dt or (1/60)
		if not x6.b or x1.Disabled then
			return
		end
		if x1.TgtActive and x1.Tgt and x1.Tgt.Character and x1.Tgt.Character:FindFirstChild("HumanoidRootPart") then
			x6.b.Position = x1.Tgt.Character.HumanoidRootPart.Position
			x6.b.AssemblyLinearVelocity = Vector3.zero
			return
		elseif x1.AnchorSelf and v8.Character and v8.Character:FindFirstChild("HumanoidRootPart") then
			x6.b.Position = v8.Character.HumanoidRootPart.Position
			x6.b.AssemblyLinearVelocity = Vector3.zero
			return
		elseif x6.d then
			local c = v4.CurrentCamera
			if not c then
				return
			end
			x6.p = x6.p or (x6.b.Position - c.CFrame.Position).Magnitude
			local mp = v1:GetMouseLocation()
			local r = c:ViewportPointToRay(mp.X, mp.Y)
			local tp = r.Origin + (r.Direction * x6.p)
			local alpha = x9.c8 >= 1 and 1 or (1 - math.exp(-60 * real_dt * -math.log(math.max(0.001, 1 - x9.c8))))
			x6.b.Position = x6.b.Position:Lerp(tp, alpha)
			x6.b.AssemblyLinearVelocity = Vector3.zero
		end
	end

	function x4.f1(p)
		if not p:IsA("BasePart") or x7.e(p) or x6.a[p] then
			return
		end
		for _, c in ipairs(p:GetChildren()) do
			if
				c:IsA("BodyAngularVelocity")
				or c:IsA("BodyForce")
				or c:IsA("BodyGyro")
				or c:IsA("BodyPosition")
				or c:IsA("BodyThrust")
				or c:IsA("BodyVelocity")
				or c:IsA("RocketPropulsion")
			then
				c:Destroy()
			end
			if c:IsA("Attachment") or c:IsA("AlignPosition") or c:IsA("Torque") then
				c:Destroy()
			end
		end
		if p:FindFirstChild("BHAtt") then
			p.BHAtt:Destroy()
		end
		p.CanCollide = false
		p.Anchored = false
		p.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0)
		local a = Instance.new("Attachment", p)
		a.Name = "GRV_ATT"
		local lv = Instance.new("LinearVelocity", p)
		lv.Name = "GRV_LV"
		lv.MaxForce = x1.k4
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.RelativeTo = Enum.ActuatorRelativeTo.World
		lv.Attachment0 = a
		local av = Instance.new("AngularVelocity", p)
		av.Name = "GRV_AV"
		av.MaxTorque = math.huge
		av.RelativeTo = Enum.ActuatorRelativeTo.World
		av.AngularVelocity = Vector3.zero
		av.Attachment0 = a
		x6.a[p] = { at = a, lv = lv, av = av, integral = Vector3.zero }
		table.insert(x6.active_array, p)
		x6.n = x6.n + 1
	end

	function x4.f2(p)
		local d = x6.a[p]
		if d then
			if d.at and d.at.Parent then
				d.at:Destroy()
			end
			if d.lv and d.lv.Parent then
				d.lv:Destroy()
			end
			if d.av and d.av.Parent then
				d.av:Destroy()
			end
			x6.a[p] = nil
		end
		local idx = table.find(x6.active_array, p)
		if idx then
			local last = #x6.active_array
			if idx ~= last then
				x6.active_array[idx] = x6.active_array[last]
			end
			table.remove(x6.active_array, last)
			x6.n = math.max(0, x6.n - 1)
		end
	end

	function x4.f3()
		pcall(function()
			settings().Physics.AllowSleep = false
		end)
		local last_upd = 0
		table.insert(
			x6.c,
			v3.Heartbeat:Connect(function(dt)
				if time() - last_upd > 0.5 then
					last_upd = time()
					for _, p in ipairs(v2:GetPlayers()) do
						if p ~= v8 then
							pcall(function()
								p.MaximumSimulationRadius = 0
								if sethiddenproperty then
									sethiddenproperty(p, "SimulationRadius", 0)
								end
							end)
						end
					end
					pcall(function()
						if sethiddenproperty then
							sethiddenproperty(v8, "NetworkIsSleeping", false)
						end
					end)
					pcall(function()
						if setscriptable then
							setscriptable(v8, "SimulationRadius", true)
							setscriptable(v8, "MaximumSimulationRadius", true)
						end
					end)

					pcall(function()
						v8.MaximumSimulationRadius = 9e9
					end)

					pcall(function()
						if sethiddenproperty then
							sethiddenproperty(v8, "SimulationRadius", 9e9)
						elseif setsimulationradius then
							setsimulationradius(9e9)
						end
					end)

					pcall(function()
						if x6.b then
							v8.ReplicationFocus = x6.b
						else
							v8.ReplicationFocus = nil
						end
					end)
				end
			end)
		)
		table.insert(
			x6.c,
			v3.Stepped:Connect(function()
				if x1.AntiFling then
					for _, p in ipairs(v2:GetPlayers()) do
						if p ~= v8 and p.Character then
							for _, part in ipairs(p.Character:GetChildren()) do
								if part:IsA("BasePart") and part.CanCollide then
									part.CanCollide = false
								end
							end
						end
					end
				end
			end)
		)
	end

	function x4.f4(pos)
		if x6.b then
			v6:Create(x6.b, TweenInfo.new(x9.c7), { Position = pos }):Play()
			return
		end
		local f = Instance.new("Folder", v4)
		f.Name = "AS"
		x6.b = Instance.new("Part", f)
		x6.b.Size = x1.k2
		x6.b.Shape = "Ball"
		x6.b.Color = x1.k3
		x6.b.Anchored = true
		x6.b.CanCollide = false
		x6.b.Material = "Neon"
		x6.b.Position = pos
		x6.b.Transparency = x9.c7
		local bg = Instance.new("BillboardGui", x6.b)
		bg.Name = "Visual"
		bg.Adornee = x6.b
		bg.Size = UDim2.new(0, 20, 0, 20)
		bg.AlwaysOnTop = true
		local img = Instance.new("ImageLabel", bg)
		img.BackgroundTransparency = 1
		img.Size = UDim2.new(1, 0, 1, 0)
		img.Image = "rbxassetid://3570695787"
		img.ImageColor3 = x1.k3
		v6
			:Create(
				x6.b,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Size = x1.k2 * 1.2 }
			)
			:Play()
		local descendants = v4:GetDescendants()
		for i, v in ipairs(descendants) do
			if v:IsA("BasePart") then
				table.insert(x6.claim_queue, v)
			end
			if i % 5000 == 0 then
				task.wait()
			end
		end

		table.insert(
			x6.c,
			v4.DescendantAdded:Connect(function(v)
				if v:IsA("BasePart") then
					table.insert(x6.claim_queue, v)
				end
			end)
		)
		x6.o = true
		x7.n("Sys", "Started", 3)
		x5.st()
		table.insert(
			x6.c,
			v3.Heartbeat:Connect(function(real_dt)
				f3(real_dt)
				f4(real_dt)
				x4.ProcessQueue()
			end)
		)
	end

	function x4.f5()
		if x6.b then
			x6.b.Parent:Destroy()
			x6.b = nil
		end
		if x6.sg then
			x6.sg:Destroy()
			x6.sg = nil
		end
		for p, _ in pairs(x6.a) do
			x4.f2(p)
		end
		for _, c in ipairs(x6.c) do
			c:Disconnect()
		end
		x6.c = {}
		if x6.f1_connections then
			for _, c in ipairs(x6.f1_connections) do
				if c then c:Disconnect() end
			end
			table.clear(x6.f1_connections)
		end
		x6.a = {}
		x6.o = false
		v7:UnbindAction("C")
		v7:UnbindAction("R")
		if x5.g then
			x5.g:Destroy()
		end
		x7.n("Sys", "Stopped", 2)
	end

	function x4.clean_physics()
		if x6.b then
			x6.b.Parent:Destroy()
			x6.b = nil
		end
		for p, _ in pairs(x6.a) do
			x4.f2(p)
		end
		x6.a = {}
		x6.o = false
		x7.n("Sys", "Cleared", 2)
	end

	function x8.h(n, s, o)
		if s ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		if n == "C" then
			local pos
			local cam = v4.CurrentCamera
			if cam then
				local viewportSize = cam.ViewportSize
				local ray = cam:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Exclude
				rp.FilterDescendantsInstances = { v8.Character }
				local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
				if result then
					pos = result.Position
				else
					pos = ray.Origin + ray.Direction * 20
				end
			else
				pos = v9.Hit.p
			end
			x4.f4(pos)
			return Enum.ContextActionResult.Sink
		elseif n == "R" then
			x4.clean_physics()
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end

	function x8.i()
		table.insert(
			x6.c,
			v1.InputBegan:Connect(function(i, p)
				if p or not x6.b then
					return
				end
				if
					(i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch)
					and v9.Target == x6.b
				then
					x6.d = true
					x6.p = (v4.CurrentCamera and (x6.b.Position - v4.CurrentCamera.CFrame.Position).Magnitude) or 50
				end
			end)
		)
		table.insert(
			x6.c,
			v1.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					x6.d = false
				end
			end)
		)

		local sculptor_binder = load_module(SUB_DIR .. "System_sculptor.lua")(context, x7)
		sculptor_binder()

		x7.n("Rdy", "Ready", 5)
	end

	return { x4 = x4, x8 = x8 }
end

end

__MODULES["mobilever/System_sculptor.lua"] = function()
return function(context, x7)
	local v1, v4, v8, v9 = context.v1, context.v4, context.v8, context.v9
	local x1, x6 = context.x1, context.x6

	return function()
		local function sculptor_clear_highlights()
			for part, highlight in pairs(x6.sculptor_highlights) do
				if highlight and highlight.Parent then
					highlight:Destroy()
				end
			end
			x6.sculptor_highlights = {}
		end

		local function sculptor_add_highlight(part)
			if x6.sculptor_highlights[part] then
				return
			end
			local highlight = Instance.new("SelectionBox")
			highlight.Adornee = part
			highlight.Color3 = Color3.fromRGB(0, 255, 200)
			highlight.LineThickness = 0.05
			highlight.SurfaceTransparency = 0.8
			highlight.SurfaceColor3 = Color3.fromRGB(0, 255, 200)
			highlight.Parent = part
			x6.sculptor_highlights[part] = highlight
		end

		local function sculptor_remove_highlight(part)
			if x6.sculptor_highlights[part] then
				x6.sculptor_highlights[part]:Destroy()
				x6.sculptor_highlights[part] = nil
			end
		end

		local function sculptor_select(part, add_to_selection)
			if not add_to_selection then
				for p, _ in pairs(x6.sculptor_selected) do
					sculptor_remove_highlight(p)
				end
				x6.sculptor_selected = {}
			end
			if part and x6.a[part] then
				x6.sculptor_selected[part] = Vector3.zero
				sculptor_add_highlight(part)
			end
		end

		local function sculptor_deselect(part)
			x6.sculptor_selected[part] = nil
			sculptor_remove_highlight(part)
		end

		local function sculptor_get_mouse_world_pos(distance)
			local cam = v4.CurrentCamera
			if not cam then
				return nil
			end
			local mp = v1:GetMouseLocation()
			local ray = cam:ViewportPointToRay(mp.X, mp.Y)
			return ray.Origin + (ray.Direction * distance)
		end

		local function get_touch_target(input)
			local cam = v4.CurrentCamera
			if not cam then
				return nil
			end
			local ray = cam:ViewportPointToRay(input.Position.X, input.Position.Y)
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Exclude
			rp.FilterDescendantsInstances = { v8.Character }
			local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
			return result and result.Instance
		end

		table.insert(
			x6.c,
			v1.InputBegan:Connect(function(input, processed)
				if processed or x1.k6 ~= "Sculptor" then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local target
					if input.UserInputType == Enum.UserInputType.Touch then
						target = get_touch_target(input)
					else
						target = v9.Target
					end

					local shift_held = v1:IsKeyDown(Enum.KeyCode.LeftShift)
						or v1:IsKeyDown(Enum.KeyCode.RightShift)
						or (x1.SculptorMultiSelect == true)

					if target and x6.a[target] then
						if x6.sculptor_selected[target] then
							if shift_held then
								sculptor_deselect(target)
							else
								x6.sculptor_dragging = true
								x6.sculptor_drag_start = target.Position
								x6.sculptor_drag_distance = (v4.CurrentCamera.CFrame.Position - target.Position).Magnitude
								x6.sculptor_drag_target = target.Position
								for part, _ in pairs(x6.sculptor_selected) do
									x6.sculptor_selected[part] = part.Position - target.Position
								end
							end
						else
							sculptor_select(target, shift_held)
							if not shift_held then
								x6.sculptor_dragging = true
								x6.sculptor_drag_start = target.Position
								x6.sculptor_drag_distance = (v4.CurrentCamera.CFrame.Position - target.Position).Magnitude
								x6.sculptor_drag_target = target.Position
								x6.sculptor_selected[target] = Vector3.zero
							end
						end
					else
						if not shift_held then
							for p, _ in pairs(x6.sculptor_selected) do
								sculptor_remove_highlight(p)
							end
							x6.sculptor_selected = {}
						end
						x6.sculptor_box_start = v1:GetMouseLocation()
						if not x6.sculptor_box and x6.sg then
							x6.sculptor_box = Instance.new("Frame", x6.sg)
							x6.sculptor_box.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
							x6.sculptor_box.BackgroundTransparency = 0.7
							x6.sculptor_box.BorderSizePixel = 2
							x6.sculptor_box.BorderColor3 = Color3.fromRGB(0, 255, 200)
							x6.sculptor_box.ZIndex = 50
						end
					end
				end
			end)
		)

		table.insert(
			x6.c,
			v1.InputChanged:Connect(function(input, processed)
				if x1.k6 ~= "Sculptor" then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					if x6.sculptor_dragging then
						x6.sculptor_drag_target = sculptor_get_mouse_world_pos(x6.sculptor_drag_distance or 50)
					elseif x6.sculptor_box_start and x6.sculptor_box then
						local current = v1:GetMouseLocation()
						local minX = math.min(x6.sculptor_box_start.X, current.X)
						local minY = math.min(x6.sculptor_box_start.Y, current.Y)
						local maxX = math.max(x6.sculptor_box_start.X, current.X)
						local maxY = math.max(x6.sculptor_box_start.Y, current.Y)
						x6.sculptor_box.Position = UDim2.new(0, minX, 0, minY)
						x6.sculptor_box.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
						x6.sculptor_box.Visible = true
					end
				end
			end)
		)

		table.insert(
			x6.c,
			v1.InputEnded:Connect(function(input)
				if x1.k6 ~= "Sculptor" then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if x6.sculptor_dragging then
						x6.sculptor_dragging = false
						x6.sculptor_drag_target = nil
					end
					if x6.sculptor_box_start and x6.sculptor_box then
						local current = v1:GetMouseLocation()
						local minX = math.min(x6.sculptor_box_start.X, current.X)
						local minY = math.min(x6.sculptor_box_start.Y, current.Y)
						local maxX = math.max(x6.sculptor_box_start.X, current.X)
						local maxY = math.max(x6.sculptor_box_start.Y, current.Y)

						local cam = v4.CurrentCamera
						if cam then
							for part, _ in pairs(x6.a) do
								local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
								if
									onScreen
									and screenPos.X >= minX
									and screenPos.X <= maxX
									and screenPos.Y >= minY
									and screenPos.Y <= maxY
								then
									x6.sculptor_selected[part] = Vector3.zero
									sculptor_add_highlight(part)
								end
							end
						end

						x6.sculptor_box.Visible = false
						x6.sculptor_box_start = nil
					end
				end
			end)
		)
	end
end

end

__MODULES["mobilever/UI.lua"] = function()
return function(context)
	local v1, v2, v3, v4, v5, v6, v7, v8, v9 = context.v1, context.v2, context.v3, context.v4, context.v5, context.v6, context.v7, context.v8, context.v9
	local x1, x2, x6, x9 = context.x1, context.x2, context.x6, context.x9
	local favorites, save_favs, save_settings = context.favorites, context.save_favs, context.save_settings
	local get_shape = context.get_shape
	local load_module = context.load_module
	local SUB_DIR = context.SUB_DIR or "mobilever/"

	local UI_elements = load_module(SUB_DIR .. "UI_elements.lua")(context)
	local es, et, eb, eh = UI_elements.s, UI_elements.t, UI_elements.b, UI_elements.h

	local x5 = {}
	x5.g = nil
	x5.s = es
	x5.t = et
	x5.b = eb
	x5.h = eh

	function x5.st()
		if x5.g and x5.up then
			x5.up()
			return
		end
		if x5.g then
			x5.g:Destroy()
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "G_" .. math.random(999)
		if gethui then
			sg.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(sg)
			sg.Parent = game:GetService("CoreGui")
		else
			sg.Parent = v8:WaitForChild("PlayerGui")
		end
		x6.sg = sg
		x5.g = sg
		x5.mw(sg)
	end

	function x5.mw(sg)
		local function toggle_window(win, state)
			if state then
				win.Visible = true
				v6:Create(win, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
			else
				local tw = v6:Create(win, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
				local conn
				conn = tw.Completed:Connect(function() 
					if win.GroupTransparency >= 0.99 then win.Visible = false end 
					if conn then conn:Disconnect() end
				end)
				tw:Play()
			end
		end

		local hud = Instance.new("Frame", sg)
		hud.Name = "StatusHUD"
		hud.BackgroundTransparency = 1
		hud.Position = UDim2.new(0.5, -150, 0, 10)
		hud.Size = UDim2.new(0, 300, 0, 30)

		local hud_l = Instance.new("TextLabel", hud)
		hud_l.BackgroundTransparency = 1
		hud_l.Size = UDim2.new(1, 0, 1, 0)
		hud_l.Font = Enum.Font.GothamBold
		hud_l.TextSize = 9
		hud_l.TextColor3 = Color3.fromRGB(255, 255, 255)

		table.insert(
			x6.c,
			v3.RenderStepped:Connect(function()
				if not x5.g then
					return
				end
				local tgt = x1.Tgt and (x1.Tgt.DisplayName or x1.Tgt.Name) or "None"
				local state = x1.Disabled and "DISABLED" or (x1.Paused and "PAUSED" or "ACTIVE")
				local col = x1.Disabled and Color3.fromRGB(255, 80, 80)
					or (x1.Paused and Color3.fromRGB(255, 180, 80) or Color3.fromRGB(80, 255, 150))
				hud_l.Text = string.format("TARGET: %s  |  STATUS: %s", tgt:upper(), state)
				hud_l.TextColor3 = col
			end)
		)

		local m = Instance.new("Frame", sg)
		m.Name = "Main"
		m.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		m.Position = UDim2.new(0.5, -110, 0.5, -160)
		m.Size = UDim2.new(0, 180, 0, 250)
		m.Active = true
		m.Draggable = true
		Instance.new("UICorner", m).CornerRadius = UDim.new(0, 10)
		local ms = Instance.new("UIStroke", m)
		ms.Color = Color3.fromRGB(40, 40, 45)
		ms.Thickness = 1

		local h = Instance.new("Frame", m)
		h.BackgroundTransparency = 1
		h.Size = UDim2.new(1, 0, 0, 26)

		local t = Instance.new("TextLabel", h)
		t.BackgroundTransparency = 1
		t.Position = UDim2.new(0, 15, 0, 0)
		t.Size = UDim2.new(0.6, 0, 1, 0)
		t.Text = "PROJECT GRAVITY"
		t.TextColor3 = Color3.fromRGB(255, 255, 255)
		t.Font = Enum.Font.GothamBlack
		t.TextSize = 10
		t.TextXAlignment = 0

		local c = Instance.new("ScrollingFrame", m)
		c.BackgroundTransparency = 1
		c.Position = UDim2.new(0, 0, 0, 40)
		c.Size = UDim2.new(1, 0, 1, -50)
		c.ScrollBarThickness = 0
		c.AutomaticCanvasSize = Enum.AutomaticSize.Y
		c.CanvasSize = UDim2.new(0, 0, 0, 0)
		local l = Instance.new("UIListLayout", c)
		l.Padding = UDim.new(0, 10)
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local p = Instance.new("UIPadding", c)
		p.PaddingLeft = UDim.new(0, 15)
		p.PaddingRight = UDim.new(0, 15)
		p.PaddingBottom = UDim.new(0, 15)

		local am = Instance.new("Frame", sg)
		am.Name = "Advanced"
		am.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		am.Position = UDim2.new(0.5, -90, 0.5, -125)
		am.Size = UDim2.new(0, 140, 0, 190)
		am.Visible = false
		am.Active = true
		am.Draggable = true
		Instance.new("UICorner", am).CornerRadius = UDim.new(0, 10)
		local ams = Instance.new("UIStroke", am)
		ams.Color = Color3.fromRGB(40, 40, 45)
		ams.Thickness = 1

		local ah = Instance.new("Frame", am)
		ah.BackgroundTransparency = 1
		ah.Size = UDim2.new(1, 0, 0, 26)
		local at = Instance.new("TextLabel", ah)
		at.BackgroundTransparency = 1
		at.Position = UDim2.new(0, 15, 0, 0)
		at.Size = UDim2.new(0.6, 0, 1, 0)
		at.Text = "ADVANCED"
		at.TextColor3 = Color3.fromRGB(255, 255, 255)
		at.Font = Enum.Font.GothamBold
		at.TextSize = 8
		at.TextXAlignment = 0

		local close_am = Instance.new("TextButton", ah)
		close_am.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		close_am.Position = UDim2.new(1, -22, 0.5, -7)
		close_am.Size = UDim2.new(0, 14, 0, 14)
		close_am.Text = ""
		Instance.new("UICorner", close_am).CornerRadius = UDim.new(1, 0)
		close_am.MouseButton1Click:Connect(function()
			am.Visible = false
		end)

		local ac = Instance.new("ScrollingFrame", am)
		ac.BackgroundTransparency = 1
		ac.Position = UDim2.new(0, 0, 0, 35)
		ac.Size = UDim2.new(1, 0, 1, -45)
		ac.ScrollBarThickness = 0
		ac.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ac.CanvasSize = UDim2.new(0, 0, 0, 0)
		local acl = Instance.new("UIListLayout", ac)
		acl.Padding = UDim.new(0, 8)
		acl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local ap = Instance.new("UIPadding", ac)
		ap.PaddingLeft = UDim.new(0, 15)
		ap.PaddingRight = UDim.new(0, 15)

		es(ac, "Damping", 0, 5, x1.Damping, function(v)
			x1.Damping = v
			save_settings()
		end)
		es(ac, "Integral Gain", 0, 10, x1.Ki, function(v)
			x1.Ki = v
			save_settings()
		end)
		es(ac, "Max Speed", 50, 2000, x1.MaxSpeed or 500, function(v)
			x1.MaxSpeed = v
			save_settings()
		end)
		es(ac, "Angular Damp", 0, 1, x1.AngularDamping or 0.5, function(v)
			x1.AngularDamping = v
			save_settings()
		end)
		es(ac, "Vert Stiffness", 0.1, 5, x1.VerticalStiffness or 1.0, function(v)
			x1.VerticalStiffness = v
			save_settings()
		end)
		if setfpscap then
			es(ac, "FPS Cap (0=Unc)", 0, 144, x1.FPSCap or 60, function(v)
				x1.FPSCap = v
				setfpscap(v)
				save_settings()
			end, true)
		end

		local ab = eb(c, "Advanced Settings", function()
			am.Visible = not am.Visible
		end)
		ab.Size = UDim2.new(1, 0, 0, 20)

		local mode_f = Instance.new("Frame", c)
		mode_f.BackgroundTransparency = 1
		mode_f.Size = UDim2.new(1, 0, 0, 24)
		local db = Instance.new("TextButton", mode_f)
		db.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		db.Size = UDim2.new(1, 0, 1, 0)
		db.Text = "  " .. x1.k6:upper()
		db.TextColor3 = Color3.fromRGB(255, 255, 255)
		db.Font = Enum.Font.GothamBold
		db.TextSize = 9
		db.TextXAlignment = 0
		Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)
		local dst = Instance.new("UIStroke", db)
		dst.Color = Color3.fromRGB(40, 40, 45)

		local arr = Instance.new("TextLabel", db)
		arr.BackgroundTransparency = 1
		arr.Position = UDim2.new(1, -30, 0, 0)
		arr.Size = UDim2.new(0, 30, 1, 0)
		arr.Text = "▼"
		arr.TextColor3 = Color3.fromRGB(150, 150, 160)
		arr.TextSize = 10

		db.MouseButton1Click:Connect(function()
			if x6.dlst_container then
				local new_state = not x6.dlst_container.Visible
				if x6.tdlst_container and x6.tdlst_container.Visible then
					toggle_window(x6.tdlst_container, false)
				end
				toggle_window(x6.dlst_container, new_state)
				if new_state and x6.populate_modes then
					x6.populate_modes("")
				end
			end
		end)

		local gsc = Instance.new("Frame", c)
		gsc.BackgroundTransparency = 1
		gsc.Size = UDim2.new(1, 0, 0, 0)
		gsc.AutomaticSize = Enum.AutomaticSize.Y
		local gscl = Instance.new("UIListLayout", gsc)
		gscl.Padding = UDim.new(0, 8)
		gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local sc = Instance.new("Frame", c)
		sc.BackgroundTransparency = 1
		sc.Size = UDim2.new(1, 0, 0, 0)
		sc.AutomaticSize = Enum.AutomaticSize.Y
		local scl = Instance.new("UIListLayout", sc)
		scl.Padding = UDim.new(0, 8)
		scl.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local function f1()
			if x6.f1_connections then
				for _, conn in ipairs(x6.f1_connections) do
					if conn then conn:Disconnect() end
				end
				table.clear(x6.f1_connections)
			else
				x6.f1_connections = {}
			end
			sc:ClearAllChildren()
			gsc:ClearAllChildren()
			local gscl = Instance.new("UIListLayout", gsc)
			gscl.Padding = UDim.new(0, 10)
			gscl.HorizontalAlignment = Enum.HorizontalAlignment.Center
			local scl = Instance.new("UIListLayout", sc)
			scl.Padding = UDim.new(0, 8)
			scl.HorizontalAlignment = Enum.HorizontalAlignment.Center
			local s = x1.S[x1.k6] or {}

			eh(gsc, "Control")


			et(gsc, "Anchor to Self", x1.AnchorSelf, function(v)
				x1.AnchorSelf = v
				save_settings()
			end)

			if not x1.SimpleMode then
				et(gsc, "Anti-Fling", x1.AntiFling, function(v)
					x1.AntiFling = v
					save_settings()
				end)
			end

			x6.disable_btn = et(gsc, "Disable Gravity", x1.Disabled, function(v)
				x1.Disabled = v
				save_settings()
				if x6.b then
					x6.b.Transparency = v and 1 or 0.8
					if x6.b:FindFirstChild("Visual") then
						x6.b.Visual.Enabled = not v
					end
				end
				for _, d in pairs(x6.a) do
					if d.lv then
						d.lv.MaxForce = v and 0 or x1.k4
					end
				end
			end)

			if not x1.SimpleMode then
				et(gsc, "Target Everyone", x1.PI_All, function(v)
					x1.PI_All = v
					save_settings()
				end)
			end

			local l_btn = Instance.new("TextButton", gsc)
			l_btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			l_btn.Size = UDim2.new(1, 0, 0, 20)
			l_btn.Text = "FORCE LAUNCH"
			l_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			l_btn.Font = Enum.Font.GothamBold
			l_btn.TextSize = 9
			Instance.new("UICorner", l_btn).CornerRadius = UDim.new(0, 6)
			l_btn.Visible = x1.ImpactManual or (x1.k6 == "Slingshot" and x1.SlingshotManual)

			l_btn.MouseButton1Click:Connect(function()
				x1.IsLaunching = not x1.IsLaunching
				l_btn.Text = x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH"
				l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(200, 50, 50)
			end)

			table.insert(
				x6.f1_connections,
				v3.Heartbeat:Connect(function()
					if x1.ImpactManual or (x1.k6 == "Slingshot" and x1.SlingshotManual) then
						l_btn.Visible = true
						l_btn.Text = x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH"
						l_btn.BackgroundColor3 = x1.IsLaunching and Color3.fromRGB(50, 150, 200)
							or Color3.fromRGB(200, 50, 50)
					else
						l_btn.Visible = false
					end
				end)
			)

			local tn = x1.Tgt and "Target: " .. (x1.Tgt.DisplayName or x1.Tgt.Name) or "Select Target"

			local tdb = Instance.new("TextButton", gsc)
			tdb.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			tdb.Size = UDim2.new(1, 0, 0, 22)
			tdb.Text = "  " .. tn:upper()
			tdb.TextColor3 = Color3.fromRGB(255, 255, 255)
			tdb.Font = Enum.Font.GothamBold
			tdb.TextSize = 8
			tdb.TextXAlignment = 0
			Instance.new("UICorner", tdb).CornerRadius = UDim.new(0, 6)
			local dst2 = Instance.new("UIStroke", tdb)
			dst2.Color = Color3.fromRGB(40, 40, 45)

			if x1.Tgt then
				local ctb = Instance.new("TextButton", tdb)
				ctb.BackgroundTransparency = 1
				ctb.Position = UDim2.new(1, -25, 0, 0)
				ctb.Size = UDim2.new(0, 25, 1, 0)
				ctb.Text = "×"
				ctb.TextColor3 = Color3.fromRGB(200, 80, 80)
				ctb.TextSize = 16
				ctb.MouseButton1Click:Connect(function()
					x1.Tgt = nil
					x1.TgtActive = false
					f1()
				end)
			end

			tdb.MouseButton1Click:Connect(function()
				if x6.tdlst_container then
					local new_state = not x6.tdlst_container.Visible
					if x6.dlst_container and x6.dlst_container.Visible then
						toggle_window(x6.dlst_container, false)
					end
					toggle_window(x6.tdlst_container, new_state)
					if new_state and x6.update_targets then
						x6.update_targets("")
					end
				end
			end)

			if not x1.SimpleMode then
				eh(sc, "Shape")
				local shape_mod = get_shape(x1.k6)
				if shape_mod and shape_mod.Controls then
					for _, ctrl in ipairs(shape_mod.Controls) do
						local current_val = s[ctrl.Key]
						local p_frame = ctrl.Parent == "gsc" and gsc or sc
						if ctrl.Type == "Slider" then
							if current_val == nil then current_val = ctrl.Min end
							if ctrl.Div then current_val = current_val * ctrl.Div end
							es(p_frame, ctrl.Name, ctrl.Min, ctrl.Max, current_val, function(v)
								if ctrl.Div then s[ctrl.Key] = v / ctrl.Div else s[ctrl.Key] = v end
							end, ctrl.IntOnly)
						elseif ctrl.Type == "Toggle" then
							et(p_frame, ctrl.Name, current_val, function(v)
								s[ctrl.Key] = v
							end)
						end
					end
				end
			end
		end
		x5.up = f1

		local dlst_container = Instance.new("CanvasGroup", sg)
		dlst_container.Name = "ModeSelector"
		dlst_container.Visible = false
		dlst_container.GroupTransparency = 1
		dlst_container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		dlst_container.Position = UDim2.new(0.5, 90, 0.5, -160)
		dlst_container.Size = UDim2.new(0, 180, 0, 250)
		dlst_container.Active = true
		dlst_container.Draggable = true
		Instance.new("UICorner", dlst_container).CornerRadius = UDim.new(0, 10)
		local dls = Instance.new("UIStroke", dlst_container)
		dls.Color = Color3.fromRGB(40, 40, 45)

		local top_dlst = Instance.new("Frame", dlst_container)
		top_dlst.BackgroundTransparency = 1
		top_dlst.Size = UDim2.new(1, 0, 0, 30)
		top_dlst.ZIndex = 11

		local back_dlst = Instance.new("TextButton", top_dlst)
		back_dlst.BackgroundTransparency = 1
		back_dlst.Position = UDim2.new(0, 10, 0, 5)
		back_dlst.Size = UDim2.new(0, 50, 0, 30)
		back_dlst.Text = "◄ Back"
		back_dlst.TextColor3 = Color3.fromRGB(150, 150, 155)
		back_dlst.Font = Enum.Font.GothamBold
		back_dlst.TextSize = 12
		back_dlst.ZIndex = 12
		back_dlst.MouseButton1Click:Connect(function()
			toggle_window(dlst_container, false)
		end)

		local msb = Instance.new("TextBox", dlst_container)
		msb.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		msb.Position = UDim2.new(0, 10, 0, 35)
		msb.Size = UDim2.new(1, -20, 0, 20)
		msb.PlaceholderText = "Search modes..."
		msb.Text = ""
		msb.TextColor3 = Color3.fromRGB(255, 255, 255)
		msb.Font = Enum.Font.Gotham
		msb.TextSize = 9
		msb.ZIndex = 11
		Instance.new("UICorner", msb).CornerRadius = UDim.new(0, 6)

		local dlst = Instance.new("ScrollingFrame", dlst_container)
		dlst.BackgroundTransparency = 1
		dlst.Position = UDim2.new(0, 0, 0, 70)
		dlst.Size = UDim2.new(1, 0, 1, -80)
		dlst.ScrollBarThickness = 0
		dlst.AutomaticCanvasSize = Enum.AutomaticSize.Y
		dlst.CanvasSize = UDim2.new(0, 0, 0, 0)
		dlst.ZIndex = 11

		x6.dlst_container = dlst_container

		local function populate_modes(filter)
			dlst:ClearAllChildren()
			local dll = Instance.new("UIListLayout", dlst)
			dll.Padding = UDim.new(0, 5)
			dll.HorizontalAlignment = Enum.HorizontalAlignment.Center

			local modes = {}
			for mn, _ in pairs(x2) do
				table.insert(modes, mn)
			end

			table.sort(modes, function(a, b)
				local fa, fb = favorites[a] and 1 or 0, favorites[b] and 1 or 0
				if fa ~= fb then
					return fa > fb
				end
				return a < b
			end)

			for _, mn in ipairs(modes) do
				if filter ~= "" and not mn:lower():find(filter:lower()) then
					continue
				end

				local f = Instance.new("Frame", dlst)
				f.Size = UDim2.new(1, -16, 0, 24)
				f.BackgroundColor3 = mn == x1.k6 and Color3.fromRGB(40, 40, 180) or Color3.fromRGB(25, 25, 30)
				f.ZIndex = 12
				Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

				local ib = Instance.new("TextButton", f)
				ib.Size = UDim2.new(1, -40, 1, 0)
				ib.Position = UDim2.new(0, 8, 0, 0)
				ib.BackgroundTransparency = 1
				ib.Text = "  " .. mn
				ib.TextColor3 = Color3.fromRGB(255, 255, 255)
				ib.Font = Enum.Font.GothamBold
				ib.TextSize = 9
				ib.TextXAlignment = 0
				ib.ZIndex = 13

				local sb = Instance.new("TextButton", f)
				sb.Position = UDim2.new(1, -35, 0, 0)
				sb.Size = UDim2.new(0, 35, 1, 0)
				sb.BackgroundTransparency = 1
				sb.Text = favorites[mn] and "★" or "☆"
				sb.TextColor3 = favorites[mn] and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 80, 85)
				sb.Font = Enum.Font.GothamBold
				sb.TextSize = 12
				sb.ZIndex = 13

				sb.MouseButton1Click:Connect(function()
					favorites[mn] = not favorites[mn]
					save_favs()
					populate_modes(filter)
				end)

				ib.MouseButton1Click:Connect(function()
					local shape = get_shape(mn)
					if shape then
						x1.k6 = mn
						x6.transition_time = time()
						for _, d in pairs(x6.a) do
							d.trans_vl = d.vl or Vector3.zero
							d.v1, d.v2, d.v3, d.v4, d.v5, d.v6, d.v7, d.v8, d.v9 = nil, nil, nil, nil, nil, nil, nil, nil, nil
							d.integral = Vector3.zero
						end
						if db then
							db.Text = "  " .. mn:upper()
						end
						toggle_window(dlst_container, false)
						save_settings()
						if x5.up then
							x5.up()
						end
					end
				end)
			end
		end

		msb:GetPropertyChangedSignal("Text"):Connect(function()
			populate_modes(msb.Text)
		end)

		x6.populate_modes = populate_modes
		populate_modes("")

		local tdlst = Instance.new("CanvasGroup", sg)
		tdlst.Name = "TargetListContainer"
		tdlst.Visible = false
		tdlst.GroupTransparency = 1
		tdlst.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
		tdlst.Position = UDim2.new(0.5, 90, 0.5, -160)
		tdlst.Size = UDim2.new(0, 180, 0, 250)
		tdlst.Active = true
		tdlst.Draggable = true
		x6.tdlst_container = tdlst
		Instance.new("UICorner", tdlst).CornerRadius = UDim.new(0, 10)
		local ts = Instance.new("UIStroke", tdlst)
		ts.Color = Color3.fromRGB(40, 40, 45)

		local top_tdlst = Instance.new("Frame", tdlst)
		top_tdlst.BackgroundTransparency = 1
		top_tdlst.Size = UDim2.new(1, 0, 0, 30)
		top_tdlst.ZIndex = 11

		local back_tdlst = Instance.new("TextButton", top_tdlst)
		back_tdlst.BackgroundTransparency = 1
		back_tdlst.Position = UDim2.new(0, 10, 0, 5)
		back_tdlst.Size = UDim2.new(0, 50, 0, 30)
		back_tdlst.Text = "◄ Back"
		back_tdlst.TextColor3 = Color3.fromRGB(150, 150, 155)
		back_tdlst.Font = Enum.Font.GothamBold
		back_tdlst.TextSize = 12
		back_tdlst.ZIndex = 12
		back_tdlst.MouseButton1Click:Connect(function()
			toggle_window(tdlst, false)
		end)

		local target_search = Instance.new("TextBox", tdlst)
		target_search.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		target_search.Position = UDim2.new(0, 10, 0, 35)
		target_search.Size = UDim2.new(1, -20, 0, 20)
		target_search.PlaceholderText = "Search players..."
		target_search.Text = ""
		target_search.TextColor3 = Color3.fromRGB(255, 255, 255)
		target_search.Font = Enum.Font.Gotham
		target_search.TextSize = 9
		target_search.ZIndex = 11
		Instance.new("UICorner", target_search).CornerRadius = UDim.new(0, 6)

		local t_scroll = Instance.new("ScrollingFrame", tdlst)
		t_scroll.BackgroundTransparency = 1
		t_scroll.Position = UDim2.new(0, 0, 0, 70)
		t_scroll.Size = UDim2.new(1, 0, 1, -80)
		t_scroll.ScrollBarThickness = 0
		t_scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		t_scroll.ZIndex = 11

		local active_highlight = nil
		local function clear_highlight()
			if active_highlight then
				active_highlight:Destroy()
				active_highlight = nil
			end
		end

		local function update_targets(filter_text)
			clear_highlight()
			t_scroll:ClearAllChildren()
			local tdll = Instance.new("UIListLayout", t_scroll)
			tdll.Padding = UDim.new(0, 5)
			tdll.HorizontalAlignment = Enum.HorizontalAlignment.Center

			for _, pl in ipairs(v2:GetPlayers()) do
				if pl == v8 then continue end
				if filter_text ~= "" and not (pl.DisplayName:lower():find(filter_text:lower()) or pl.Name:lower():find(filter_text:lower())) then
					continue
				end

				local ib = Instance.new("TextButton", t_scroll)
				ib.Size = UDim2.new(1, -16, 0, 26)
				ib.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				ib.Text = "  " .. pl.DisplayName
				ib.TextColor3 = Color3.fromRGB(255, 255, 255)
				ib.Font = Enum.Font.GothamBold
				ib.TextSize = 9
				ib.TextXAlignment = 0
				ib.ZIndex = 12
				Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 6)

				ib.MouseEnter:Connect(function()
					ib.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					if pl.Character then
						local h = Instance.new("Highlight", pl.Character)
						h.FillColor = Color3.fromRGB(255, 255, 255)
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						active_highlight = h
					end
				end)
				ib.MouseLeave:Connect(function()
					ib.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
					clear_highlight()
				end)

				ib.MouseButton1Click:Connect(function()
					x1.Tgt = pl
					x1.TgtActive = true
					toggle_window(tdlst, false)
					if x5.up then x5.up() end
				end)
			end
		end
		x6.update_targets = update_targets

		target_search:GetPropertyChangedSignal("Text"):Connect(function()
			update_targets(target_search.Text)
		end)

		local minb = Instance.new("TextButton", h)
		minb.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
		minb.Position = UDim2.new(1, -44, 0.5, -7)
		minb.Size = UDim2.new(0, 14, 0, 14)
		minb.Text = ""
		Instance.new("UICorner", minb).CornerRadius = UDim.new(1, 0)

		local closeb = Instance.new("TextButton", h)
		closeb.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		closeb.Position = UDim2.new(1, -22, 0.5, -7)
		closeb.Size = UDim2.new(0, 14, 0, 14)
		closeb.Text = ""
		Instance.new("UICorner", closeb).CornerRadius = UDim.new(1, 0)

		local im = false
		minb.MouseButton1Click:Connect(function()
			im = not im
			c.Visible = not im
			if im then
				am.Visible = false
				if x6.dlst_container and x6.dlst_container.Visible then
					toggle_window(x6.dlst_container, false)
				end
				if x6.tdlst_container and x6.tdlst_container.Visible then
					toggle_window(x6.tdlst_container, false)
				end
			end
			m:TweenSize(im and UDim2.new(0, 180, 0, 26) or UDim2.new(0, 180, 0, 250), "Out", "Quart", 0.3, true)
		end)

		closeb.MouseButton1Click:Connect(function()
			if context.x4 and context.x4.f5 then
				context.x4.f5()
			else
				sg:Destroy()
			end
		end)

		local ctrl_container = Instance.new("Frame", sg)
		ctrl_container.BackgroundTransparency = 1
		ctrl_container.Position = UDim2.new(0, 15, 0.05, 0)
		ctrl_container.Size = UDim2.new(0, 60, 0, 200)

		local hide_btn = Instance.new("TextButton", ctrl_container)
		hide_btn.Size = UDim2.new(0, 14, 0, 14)
		hide_btn.Position = UDim2.new(0, 0, 0, 6)
		hide_btn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
		hide_btn.Text = ""
		Instance.new("UICorner", hide_btn).CornerRadius = UDim.new(1, 0)

		local ctrl = Instance.new("Frame", ctrl_container)
		ctrl.BackgroundTransparency = 1
		ctrl.Position = UDim2.new(0, 22, 0, 0)
		ctrl.Size = UDim2.new(1, -22, 1, 0)

		local layout = Instance.new("UIListLayout", ctrl)
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local function create_btn(txt, col, order)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 22, 0, 22)
			b.BackgroundColor3 = col
			b.Text = txt
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 6
			b.LayoutOrder = order
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.Parent = ctrl
			return b
		end

		local btn_place = create_btn("PLC", Color3.fromRGB(50, 150, 200), 2)
		local btn_clean = create_btn("CLN", Color3.fromRGB(200, 80, 80), 3)
		local btn_up = create_btn("UP", Color3.fromRGB(80, 80, 85), 4)
		local btn_down = create_btn("DWN", Color3.fromRGB(80, 80, 85), 5)
		local btn_pause = create_btn("PAU", Color3.fromRGB(200, 150, 50), 6)
		local btn_dis = create_btn("DIS", Color3.fromRGB(60, 60, 60), 7)

		local controls_visible = true
		hide_btn.MouseButton1Click:Connect(function()
			controls_visible = not controls_visible
			hide_btn.BackgroundColor3 = controls_visible and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(200, 60, 60)
			btn_place.Visible = controls_visible
			btn_clean.Visible = controls_visible
			btn_up.Visible = controls_visible
			btn_down.Visible = controls_visible
			btn_pause.Visible = controls_visible
			btn_dis.Visible = controls_visible
		end)

		btn_place.MouseButton1Click:Connect(function()
			if context.x4 and context.x4.f4 then
				local cam = v4.CurrentCamera
				if cam then
					local vp = cam.ViewportSize
					local ray = cam:ViewportPointToRay(vp.X / 2, vp.Y / 2)
					local rp = RaycastParams.new()
					rp.FilterType = Enum.RaycastFilterType.Exclude
					rp.FilterDescendantsInstances = {v8.Character}
					local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
					local pos = res and res.Position or (ray.Origin + ray.Direction * 20)
					context.x4.f4(pos)
				end
			end
		end)

		btn_clean.MouseButton1Click:Connect(function()
			if context.x4 and context.x4.clean_physics then
				context.x4.clean_physics()
			end
		end)

		local holding_up = false
		btn_up.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				holding_up = true
				task.spawn(function()
					while holding_up and x6.b do
						x6.b.Position = x6.b.Position + Vector3.new(0, 1, 0)
						task.wait()
					end
				end)
			end
		end)
		btn_up.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				holding_up = false
			end
		end)

		local holding_down = false
		btn_down.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				holding_down = true
				task.spawn(function()
					while holding_down and x6.b do
						x6.b.Position = x6.b.Position - Vector3.new(0, 1, 0)
						task.wait()
					end
				end)
			end
		end)
		btn_down.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				holding_down = false
			end
		end)

		btn_pause.MouseButton1Click:Connect(function()
			x1.Paused = not x1.Paused
			btn_pause.BackgroundColor3 = x1.Paused and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(200, 150, 50)
		end)

		btn_dis.MouseButton1Click:Connect(function()
			x1.Disabled = not x1.Disabled
			btn_dis.BackgroundColor3 = x1.Disabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
			if x6.disable_btn then x6.disable_btn.BackgroundColor3 = btn_dis.BackgroundColor3 end
			
			local v = x1.Disabled
			if x6.b then
				x6.b.Transparency = v and 1 or x9.c7
				if x6.b:FindFirstChild("Visual") then
					x6.b.Visual.Enabled = not v
				end
			end
			for _, d in pairs(x6.a) do
				if d.lv then d.lv.MaxForce = v and 0 or x1.k4 end
				if d.av then d.av.MaxTorque = v and 0 or math.huge end
			end
		end)

		f1()
	end

	return x5
end

end

__MODULES["mobilever/UI_elements.lua"] = function()
return function(context)
	local v1, v6 = context.v1, context.v6
	local save_settings = context.save_settings
	local M = {}

	function M.s(p, t, mn, mx, df, cb, is_int)
		df = df or mn
		if is_int or mx - mn > 50 then
			df = math.floor(df + 0.5)
		else
			df = math.floor(df * 10 + 0.5) / 10
		end
		local f = Instance.new("Frame", p)
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, 0, 0, 24)

		local l = Instance.new("TextLabel", f)
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0, 12)
		l.Text = t
		l.TextColor3 = Color3.fromRGB(180, 180, 180)
		l.TextXAlignment = 0
		l.Font = Enum.Font.Gotham
		l.TextSize = 8

		local vl = Instance.new("TextLabel", f)
		vl.BackgroundTransparency = 1
		vl.Position = UDim2.new(1, -50, 0, 0)
		vl.Size = UDim2.new(0, 50, 0, 12)
		vl.Text = tostring(df)
		vl.TextColor3 = Color3.fromRGB(255, 255, 255)
		vl.TextXAlignment = 1
		vl.Font = Enum.Font.GothamBold
		vl.TextSize = 8

		local sc = Instance.new("Frame", f)
		sc.BackgroundTransparency = 1
		sc.Position = UDim2.new(0, 0, 0, 14)
		sc.Size = UDim2.new(1, 0, 0, 4)

		local sb = Instance.new("Frame", sc)
		sb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		sb.BorderSizePixel = 0
		sb.Size = UDim2.new(1, 0, 1, 0)
		Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)

		local fl = Instance.new("Frame", sb)
		fl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		fl.BorderSizePixel = 0
		fl.Size = UDim2.new((df - mn) / (mx - mn), 0, 1, 0)
		Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

		local k = Instance.new("ImageButton", sc)
		k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		k.AnchorPoint = Vector2.new(0.5, 0.5)
		k.Position = UDim2.new((df - mn) / (mx - mn), 0, 0.5, 0)
		k.Size = UDim2.new(0, 10, 0, 10)
		k.BorderSizePixel = 0
		k.AutoButtonColor = false
		Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

		local active_input = nil
		local function u(pos_x)
			local rp = pos_x - sc.AbsolutePosition.X
			local pc = math.clamp(rp / sc.AbsoluteSize.X, 0, 1)
			local v = mn + (mx - mn) * pc
			if is_int or mx - mn > 50 then
				v = math.floor(v + 0.5)
			else
				v = math.floor(v * 10 + 0.5) / 10
			end
			local snapped_pc = (v - mn) / (mx - mn)
			v6:Create(fl, TweenInfo.new(0.1), { Size = UDim2.new(snapped_pc, 0, 1, 0) }):Play()
			v6:Create(k, TweenInfo.new(0.1), { Position = UDim2.new(snapped_pc, 0, 0.5, 0) }):Play()
			vl.Text = tostring(v)
			cb(v)
			if save_settings then
				save_settings()
			end
		end

		k.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				active_input = i
				u(i.Position.X)
			end
		end)
		sb.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				active_input = i
				u(i.Position.X)
			end
		end)
		local c1 = v1.InputEnded:Connect(function(i)
			if i == active_input then
				active_input = nil
			end
		end)
		local c2 = v1.InputChanged:Connect(function(i)
			if i == active_input then
				u(i.Position.X)
			end
		end)

		f.AncestryChanged:Connect(function(_, parent)
			if not parent then
				c1:Disconnect()
				c2:Disconnect()
			end
		end)
	end

	function M.t(p, t, df, cb)
		local f = Instance.new("Frame", p)
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, 0, 0, 20)

		local l = Instance.new("TextLabel", f)
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(0.8, 0, 1, 0)
		l.Text = t
		l.TextColor3 = Color3.fromRGB(180, 180, 180)
		l.TextXAlignment = 0
		l.Font = Enum.Font.Gotham
		l.TextSize = 8

		local bg = Instance.new("Frame", f)
		bg.BackgroundColor3 = df and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(40, 40, 45)
		bg.Position = UDim2.new(1, -24, 0.5, -6)
		bg.Size = UDim2.new(0, 24, 0, 12)
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

		local toggle = Instance.new("Frame", bg)
		toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggle.Position = df and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
		toggle.Size = UDim2.new(0, 8, 0, 8)
		Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

		local b = Instance.new("TextButton", f)
		b.BackgroundTransparency = 1
		b.Size = UDim2.new(1, 0, 1, 0)
		b.Text = ""

		b.MouseButton1Click:Connect(function()
			df = not df
			v6:Create(
				bg,
				TweenInfo.new(0.2),
				{ BackgroundColor3 = df and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(40, 40, 45) }
			):Play()
			v6:Create(
				toggle,
				TweenInfo.new(0.2),
				{ Position = df and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4) }
			):Play()
			cb(df)
			if save_settings then
				save_settings()
			end
		end)
		return b
	end

	function M.b(p, t, cb)
		local b = Instance.new("TextButton", p)
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		b.Size = UDim2.new(1, 0, 0, 20)
		b.AutoButtonColor = false
		b.Text = t
		b.TextColor3 = Color3.fromRGB(220, 220, 220)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 9
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

		local str = Instance.new("UIStroke", b)
		str.Color = Color3.fromRGB(50, 50, 55)
		str.Thickness = 1

		b.MouseEnter:Connect(function()
			v6:Create(
				b,
				TweenInfo.new(0.2),
				{ BackgroundColor3 = Color3.fromRGB(40, 40, 45), TextColor3 = Color3.fromRGB(255, 255, 255) }
			):Play()
		end)
		b.MouseLeave:Connect(function()
			v6:Create(
				b,
				TweenInfo.new(0.2),
				{ BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(220, 220, 220) }
			):Play()
		end)

		b.MouseButton1Click:Connect(function()
			cb(b)
		end)
		return b
	end

	function M.h(p, t)
		local l = Instance.new("TextLabel", p)
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0, 20)
		l.Text = t:upper()
		l.TextColor3 = Color3.fromRGB(100, 100, 110)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 9
		l.TextXAlignment = Enum.TextXAlignment.Left
	end

	return M
end

end



--!native

local function safe_service(name)
	local service = game:GetService(name)
	if cloneref then
		return cloneref(service)
	end
	return service
end

local v1, v2, v3, v4, v5, v6, v7 =
	safe_service("UserInputService"),
	safe_service("Players"),
	safe_service("RunService"),
	safe_service("Workspace"),
	safe_service("StarterGui"),
	safe_service("TweenService"),
	safe_service("ContextActionService")
local HttpService = safe_service("HttpService")

if setthreadidentity then
	pcall(function()
		setthreadidentity(8)
	end)
end

local v8, v9 = v2.LocalPlayer, v2.LocalPlayer:GetMouse()
local is_mobile = v1.TouchEnabled and not v1.KeyboardEnabled
local SUB_DIR = is_mobile and "mobilever/" or ""

local loading_sg = Instance.new("ScreenGui")
loading_sg.Name = "GravityLoading"
loading_sg.DisplayOrder = 99999
loading_sg.IgnoreGuiInset = true
if gethui then
	loading_sg.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(loading_sg)
	loading_sg.Parent = game:GetService("CoreGui")
else
	loading_sg.Parent = v8:WaitForChild("PlayerGui")
end
local spinner = Instance.new("Frame", loading_sg)
spinner.Size = UDim2.new(0, 36, 0, 36)
spinner.Position = UDim2.new(0.5, -18, 0.5, -18)
spinner.BackgroundTransparency = 1
local uic = Instance.new("UICorner", spinner)
uic.CornerRadius = UDim.new(1, 0)
local uis = Instance.new("UIStroke", spinner)
uis.Thickness = 3
uis.Color = Color3.fromRGB(255, 255, 255)
local uig = Instance.new("UIGradient", uis)
uig.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local spin_t = 0
local spin_conn = v3.RenderStepped:Connect(function(dt)
	spin_t = spin_t + dt
	spinner.Rotation = spin_t * 400
end)

local loading_text = Instance.new("TextLabel", loading_sg)
loading_text.Size = UDim2.new(0, 100, 0, 20)
loading_text.Position = UDim2.new(0.5, -50, 0.5, 25)
loading_text.BackgroundTransparency = 1
loading_text.Text = "LOADING..."
loading_text.TextColor3 = Color3.fromRGB(200, 200, 200)
loading_text.Font = Enum.Font.GothamMedium
loading_text.TextSize = 12

local x9 = { c1 = 0.15, c2 = 0.05, c3 = 0.01, c4 = 0.2, c5 = 0.6, c6 = 0.8, c7 = 0.1, c8 = 0.25 }
local ANTI_SLEEP = Vector3.new(0, 0.01, 0)
local BASE_URL = "https://raw.githubusercontent.com/CarlDV/projectgravity/main/"

local function safe_http_get(url)
	local cache_buster = "?cb=" .. tostring(math.random(1000000, 9999999))
	local fetch_url = url .. cache_buster
	local success, result = pcall(function()
		return game:HttpGet(fetch_url)
	end)
	if success and result then
		return result
	end
	local req = (type(request) == "function" and request) or (type(http) == "table" and http.request) or (type(syn) == "table" and syn.request)
	if req then
		local s, r = pcall(function()
			return req({Url = fetch_url, Method = "GET"})
		end)
		if s and type(r) == "table" and r.Body then
			return r.Body
		end
	end
	return nil
end

local function load_module(path)
    local normalizedPath = string.gsub(path, "^mobilever/", "")
    if __MODULES[path] then
        return __MODULES[path]()
    elseif __MODULES[normalizedPath] then
        return __MODULES[normalizedPath]()
    end
    warn("Failed to find bundled module: " .. tostring(path))
    return nil
end

local config = load_module("config.lua")
local x1 = config.x1
local x2 = config.x2
x1.S = x2

local serialization = load_module("math/serialization.lua")
local sanitize = serialization.sanitize
local desanitize = serialization.desanitize

local favorites = {}
local function save_favs()
	if writefile then
		pcall(function()
			writefile("GravityFavorites.json", HttpService:JSONEncode(favorites))
		end)
	end
end
local function load_favs()
	if isfile and isfile("GravityFavorites.json") then
		pcall(function()
			favorites = HttpService:JSONDecode(readfile("GravityFavorites.json"))
		end)
	end
end
load_favs()

local save_pending = false
local function save_settings()
	if not writefile then
		return
	end
	if save_pending then return end
	save_pending = true
	task.delay(0.5, function()
		save_pending = false
		local data = { x1 = sanitize(x1), x2 = sanitize(x2) }
		data.x1.Tgt = nil
		data.x1.IsLaunching = nil
		local success, json = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		if success then
			pcall(function()
				writefile("GravitySettings_Auto.json", json)
			end)
		end
	end)
end

local function load_settings()
	if isfile and isfile("GravitySettings_Auto.json") then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile("GravitySettings_Auto.json"))
		end)
		if success and data then
			local cx1 = desanitize(data.x1)
			local cx2 = desanitize(data.x2)
			for k, v in pairs(cx1) do
				if k ~= "S" and x1[k] ~= nil and typeof(x1[k]) == typeof(v) then
					x1[k] = v
				end
			end
			for mk, mv in pairs(cx2) do
				if x2[mk] and type(mv) == "table" then
					for sk, sv in pairs(mv) do
						x2[mk][sk] = sv
					end
				end
			end
		end
	end
end
load_settings()

if setfpscap then
	pcall(function()
		setfpscap(x1.FPSCap or 60)
	end)
end

local loaded_shapes = {}
local function get_shape(name)
    if not loaded_shapes[name] then
        local path1 = "shapes/" .. tostring(name) .. ".lua"
        local success, res = false, nil
        if __MODULES[path1] then
            success, res = pcall(__MODULES[path1])
        end
        if success then 
            loaded_shapes[name] = res 
        else
            warn("Failed to find/execute bundled shape: " .. tostring(name))
        end
    end
    return loaded_shapes[name]
end

local x6 = {
	b = nil,
	c = {},
	a = setmetatable({}, {__mode = "k"}),
	o = false,
	d = false,
	p = 0,
	f = 0,
	n = 0,
	pi_targets = {},
	pi_timer = 0,
	ex_nodes = {},
	ex_timer = 0,
	esp_timer = 0,
	claim_queue = {},
	active_array = {},
	pre = {},
	pre_buffer = table.create(200),
	sculptor_selected = setmetatable({}, {__mode = "k"}),
	sculptor_dragging = false,
	sculptor_drag_start = nil,
	sculptor_box_start = nil,
	sculptor_box = nil,
	sculptor_highlights = setmetatable({}, {__mode = "k"}),
	sculptor_preset_ui = nil,
	transition_time = 0,
	transition_dur = 2,
	f1_connections = {},
}

get_shape(x1.k6)

coroutine.wrap(function()
	for mn, _ in pairs(x2) do
		if mn ~= x1.k6 then
			get_shape(mn)
			if task and task.wait then
				task.wait(0.05)
			end
		end
	end
end)()

local context = {
	v1 = v1,
	v2 = v2,
	v3 = v3,
	v4 = v4,
	v5 = v5,
	v6 = v6,
	v7 = v7,
	v8 = v8,
	v9 = v9,
	x1 = x1,
	x2 = x2,
	x6 = x6,
	x9 = x9,
	favorites = favorites,
	save_favs = save_favs,
	save_settings = save_settings,
	get_shape = get_shape,
	load_module = load_module,
	is_mobile = is_mobile,
	SUB_DIR = SUB_DIR,
}

local success, err = pcall(function()
	local UI_builder = load_module(SUB_DIR .. "UI.lua")
	if not UI_builder then error("Failed to load UI") end
	local x5 = UI_builder(context)
	context.x5 = x5

	local system_builder = load_module(SUB_DIR .. "System.lua")
	if not system_builder then error("Failed to load System") end
	local sys = system_builder(context)
	local x4 = sys.x4
	local x8 = sys.x8
	context.x4 = x4

	x4.f3()
	x8.i()
	x5.st()
end)

spin_conn:Disconnect()
loading_sg:Destroy()

if not success then
	warn("Project Gravity Initialization Failed: " .. tostring(err))
end