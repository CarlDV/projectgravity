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
				if x1.k6 == "Big Ring Things" then
					es(sc, "Ring Count", 1, 20, s.k11, function(v)
						s.k11 = v
					end, true)
					es(sc, "Ring Gap", 50, 300, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Ring Speed", 0, 200, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Height Offset", 0, 100, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "Tilt Angle", 0, 90, s.k15, function(v)
						s.k15 = v
					end)
					es(sc, "Tilt Speed", 0, 50, s.k16 * 10, function(v)
						s.k16 = v / 10
					end)
				elseif x1.k6 == "Celestial Ribbon" then
					es(sc, "Ribbon Speed", 1, 300, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Ribbon Length", 10, 500, s.k16 * 100, function(v)
						s.k16 = v / 100
					end)
					es(sc, "Ribbon Width", 1, 150, s.k11 * 2, function(v)
						s.k11 = v / 2
					end)
					es(sc, "Height Limit", 0, 200, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "Move Area", 50, 800, s.k17, function(v)
						s.k17 = v
					end)
					et(sc, "Enable Slither", s.k18, function(v)
						s.k18 = v
					end)
					et(sc, "Dual Dragons", s.k19, function(v)
						s.k19 = v
					end)
				elseif x1.k6 == "Hollow Worm" then
					es(sc, "Worm Speed", 1, 300, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Worm Length", 10, 500, s.k16 * 100, function(v)
						s.k16 = v / 100
					end)
					es(sc, "Tube Radius", 1, 100, s.k11 * 2, function(v)
						s.k11 = v / 2
					end)
					es(sc, "Height Limit", 0, 200, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "Wavelength", 1, 50, s.k15, function(v)
						s.k15 = v
					end)
					es(sc, "Move Area", 50, 800, s.k17, function(v)
						s.k17 = v
					end)
				elseif x1.k6 == "Cosmic Comet" then
					es(sc, "Comet Speed", 1, 300, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Tail Length", 10, 500, s.k16 * 100, function(v)
						s.k16 = v / 100
					end)
					es(sc, "Head Radius", 1, 50, s.k11 * 2, function(v)
						s.k11 = v / 2
					end)
					es(sc, "Tail Spread", 0, 200, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Height Limit", 0, 200, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "Move Area", 50, 800, s.k17, function(v)
						s.k17 = v
					end)
				elseif x1.k6 == "Point Impact" then
					es(sc, "Spin Speed", 1, 500, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Closeness", 1, 50, s.k11 * 2, function(v)
						s.k11 = v / 2
					end)
					es(sc, "Move Area", 50, 800, s.k17, function(v)
						s.k17 = v
					end)
				elseif x1.k6 == "Orbital Shell" then
					es(sc, "Spin Speed", 1, 300, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Shell Radius", 50, 1000, s.k11, function(v)
						s.k11 = v
					end)
					et(sc, "Cut in Half", s.k18, function(v)
						s.k18 = v
					end)
					et(sc, "Stable Flow", s.k19, function(v)
						s.k19 = v
					end)
					es(sc, "Move Area", 50, 1500, s.k17, function(v)
						s.k17 = v
					end)
				elseif x1.k6 == "Vortex Funnel" then
					es(sc, "Swirl Speed", 1, 300, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Base Radius", 10, 300, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Top Radius", 50, 1000, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Funnel Height", 50, 1000, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "Suction Power", 1, 20, s.k15, function(v)
						s.k15 = v
					end)
					es(sc, "Move Area", 50, 1500, s.k17, function(v)
						s.k17 = v
					end)
				elseif x1.k6 == "Quantum Atoms" then
					es(sc, "Orbit Speed", 1, 300, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Atom Radius", 20, 500, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Orbit Count", 1, 10, s.k15, function(v)
						s.k15 = v
					end, true)
					es(sc, "Move Area", 50, 800, s.k17, function(v)
						s.k17 = v
					end)
				elseif x1.k6 == "Halo Ring" then
					es(sc, "Spin Speed", 0, 200, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Halo Radius", 20, 300, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Height Offset", 20, 200, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Slingshot" then
					es(sc, "Charge Dist", 10, 200, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Cycle Time", 1, 10, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Fling Speed", 1, 500, s.k13, function(v)
						s.k13 = v
					end)
					et(sc, "Manual Fire", x1.SlingshotManual, function(v)
						x1.SlingshotManual = v
						x1.IsLaunching = false
					end)
				elseif x1.k6 == "Gods Call" then
					es(sc, "Ascent Speed", 1, 100, s.k11, function(v)
						s.k11 = v
					end)
				elseif x1.k6 == "Deflect" then
					es(sc, "Range", 10, 500, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Force", 50, 5000, s.k12, function(v)
						s.k12 = v
					end)
				elseif x1.k6 == "Shield Wall" then
					es(sc, "Spin Speed", 1, 200, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Width", 1, 200, s.k11 * 10, function(v)
						s.k11 = v / 10
					end)
					es(sc, "Height", 1, 50, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Distance", 5, 100, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "H-Offset", -50, 50, s.k15, function(v)
						s.k15 = v
					end)
				elseif x1.k6 == "Torus Knot" then
					es(sc, "P Knot", 1, 10, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Q Knot", 1, 10, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Radius", 10, 300, s.k14, function(v)
						s.k14 = v
					end)
					es(sc, "Tube Size", 5, 100, s.k15, function(v)
						s.k15 = v
					end)
				elseif x1.k6 == "Möbius Strip" then
					es(sc, "Radius", 10, 300, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Width", 5, 200, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
				elseif x1.k6 == "DNA Helix" then
					es(sc, "Radius", 5, 200, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Height", 10, 500, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Frequency", 10, 200, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Black Hole" then
					es(sc, "Event Horizon", 10, 200, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Disk Radius", 50, 2000, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Spin Speed", 1, 200, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Disk Height", 5, 200, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Tesseract" then
					es(sc, "Inner Size", 10, 200, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Outer Size", 20, 400, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Rotation Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
				elseif x1.k6 == "Klein Bottle" then
					es(sc, "Radius", 10, 300, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Flow Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
				elseif x1.k6 == "Space Station" then
					es(sc, "Ring Radius", 20, 400, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Ring Thickness", 5, 100, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Orbit Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Spindle Length", 20, 500, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Supernova" then
					es(sc, "Core Radius", 5, 100, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Blast Radius", 50, 800, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Pulse Speed", 1, 200, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
				elseif x1.k6 == "Dyson Sphere" then
					es(sc, "Radius", 50, 400, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Grid Density", 2, 50, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
				elseif x1.k6 == "Seraphim" then
					es(sc, "Radius", 20, 200, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Ring Count", 1, 10, s.k12, function(v)
						s.k12 = v
					end, true)
					es(sc, "Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Wingspan", 10, 150, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Alien Mothership" then
					es(sc, "Radius", 50, 400, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Core Height", 10, 150, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Beam Length", 50, 500, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Quantum Core" then
					es(sc, "Ring Radius", 50, 400, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Ring Thickness", 10, 100, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Spin Speed", 1, 200, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Core Volatility", 10, 200, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Galactic Web" then
					es(sc, "Radius Spread", 50, 1500, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Spin Speed", 1, 100, s.k12 * 10, function(v)
						s.k12 = v / 10
					end)
					es(sc, "Drift Speed", 1, 50, s.k13, function(v)
						s.k13 = v
					end)
					et(sc, "Cut In Half", s.k23, function(v)
						s.k23 = v
					end)
					es(sc, "Web Height Limit", 0, 1500, s.k24, function(v)
						s.k24 = v
						save_settings()
					end)
				elseif x1.k6 == "Meteor Shower" then
					es(sc, "XZ Spread", 100, 1500, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Spawn Height", 50, 1500, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Fall Speed", 50, 2000, s.k13, function(v)
						s.k13 = v
					end)
				elseif x1.k6 == "World Serpent" then
					es(sc, "Snake Length", 100, 2000, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Wave Height", 10, 500, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Move Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Frequency", 10, 200, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Aurora Borealis" then
					es(sc, "Sky Span", 100, 2000, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Sky Height", 50, 1500, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Flow Speed", 1, 100, s.k13 * 10, function(v)
						s.k13 = v / 10
					end)
					es(sc, "Band Width", 50, 500, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Arcane Orrery" then
					es(sc, "Orrery Radius", 40, 300, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Arm Count", 2, 8, s.k12, function(v)
						s.k12 = v
					end, true)
					es(sc, "Spin Speed", 1, 50, s.k13, function(v)
						s.k13 = v
					end)
					es(sc, "Height", 50, 500, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Maelstrom Spire" then
					es(sc, "Base Radius", 10, 150, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Tower Height", 50, 500, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Vortex Speed", 1, 50, s.k13, function(v)
						s.k13 = v
					end)
					es(sc, "Jet Count", 3, 12, s.k14, function(v)
						s.k14 = v
					end, true)
				elseif x1.k6 == "Eldritch Binding" then
					es(sc, "Sigil Radius", 30, 250, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Tower Height", 50, 500, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Rotation Speed", 1, 30, s.k13, function(v)
						s.k13 = v
					end)
					es(sc, "Tendril Count", 3, 16, s.k14, function(v)
						s.k14 = v
					end, true)
				elseif x1.k6 == "Graviton Engine" then
					es(sc, "Turbine Count", 2, 8, s.k11, function(v)
						s.k11 = v
					end, true)
					es(sc, "Radius", 20, 200, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Spin Speed", 1, 50, s.k13, function(v)
						s.k13 = v
					end)
					es(sc, "Tower Height", 50, 500, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Fractal Web" then
					es(sc, "Hex Radius", 15, 120, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Depth", 2, 4, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Breath Speed", 1, 20, s.k13, function(v)
						s.k13 = v
					end)
					es(sc, "Rotation Speed", 1, 30, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Leviathan Coil" then
					es(sc, "Coil Radius", 15, 150, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Body Thickness", 5, 50, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Coil Speed", 1, 30, s.k13, function(v)
						s.k13 = v
					end)
					es(sc, "Tower Height", 50, 500, s.k14, function(v)
						s.k14 = v
					end)
				elseif x1.k6 == "Pulsar Vortex" then
					es(sc, "Spread", 50, 800, s.k11, function(v)
						s.k11 = v
					end)
					es(sc, "Speed", 1, 30, s.k12, function(v)
						s.k12 = v
					end)
					es(sc, "Torsion Twist", 1, 50, s.k13, function(v)
						s.k13 = v
					end)
					et(gsc, "Cut in Half", s.k23, function(v)
						s.k23 = v
					end)
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
