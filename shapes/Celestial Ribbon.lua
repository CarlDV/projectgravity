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
		local px, pz, py = math.cos(ph) * R, math.sin(ph * 1.618) * R, math.sin(ph * 0.577) * h
		local T = Vector3.new(px, py, pz).Unit
		local Rv = T:Cross(Vector3.yAxis)
		if Rv.Magnitude < 0.01 then
			Rv = Vector3.xAxis
		end
		Rv = Rv.Unit
		local trn = Rv * math.cos(ph * 0.5) + (T:Cross(Rv)) * math.sin(ph * 0.5)
		r[i] = { p = Vector3.new(px, py, pz), t = trn, ph = ph }

		local ph2 = ph + 2.37
		local px2 = (math.sin(ph2 * 0.73) + math.cos(ph2 * 1.31) * 0.6) * R * 0.6
		local pz2 = (math.cos(ph2 * 0.59) + math.sin(ph2 * 1.17) * 0.6) * R * 0.6
		local py2 = (math.sin(ph2 * 0.41) + math.cos(ph2 * 0.89) * 0.5) * h * 0.8
		local T2 = Vector3.new(px2, py2, pz2).Unit
		local Rv2 = T2:Cross(Vector3.yAxis)
		if Rv2.Magnitude < 0.01 then
			Rv2 = Vector3.xAxis
		end
		Rv2 = Rv2.Unit
		local trn2 = Rv2 * math.cos(ph2 * 0.5) + (T2:Cross(Rv2)) * math.sin(ph2 * 0.5)
		r2[i] = { p = Vector3.new(px2, py2, pz2), t = trn2, ph = ph2 }
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
		local px, pz, py
		if isB then
			px = (math.sin(ph * 0.73) + math.cos(ph * 1.31) * 0.6) * R * 0.6
			pz = (math.cos(ph * 0.59) + math.sin(ph * 1.17) * 0.6) * R * 0.6
			py = (math.sin(ph * 0.41) + math.cos(ph * 0.89) * 0.5) * h * 0.8
		else
			px, pz, py = math.cos(ph) * R, math.sin(ph * 1.618) * R, math.sin(ph * 0.577) * h
		end
		local T = Vector3.new(px, py, pz).Unit
		local Rvec = T:Cross(Vector3.yAxis)
		if Rvec.Magnitude < 0.01 then
			Rvec = Vector3.xAxis
		end
		Rvec = Rvec.Unit
		local trn = Rvec * math.cos(ph * 0.5) + (T:Cross(Rvec)) * math.sin(ph * 0.5)
		fin = Vector3.new(px, py, pz)
			+ (trn * (d.v7 * w))
			+ (c.k18 and (trn * math.sin(ph * 8)) * (w * 2.0) or Vector3.zero)
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