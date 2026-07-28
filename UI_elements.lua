--!optimize 2
-- Project Gravity :: design system + animation engine + widget library.
-- Everything here is driven by ONE RenderStepped connection (see fx.step).
-- Widgets keep their legacy signatures (s / t / b / sub_b / h) so older callers
-- keep working, but every one of them now returns a control handle as a second
-- value so the UI can push state into them without rebuilding anything.

return function(context)
	local v1, v3 = context.v1, context.v3
	local x1, x6 = context.x1, context.x6
	local save_settings = context.save_settings
	local is_mobile = context.is_mobile and true or false

	local C3 = Color3.fromRGB
	local U2 = UDim2.new
	local UD = UDim.new
	local V2 = Vector2.new
	local CS = ColorSequence.new
	local CSK = ColorSequenceKeypoint.new
	local NS = NumberSequence.new
	local NSK = NumberSequenceKeypoint.new
	local mabs, mmax, mmin, mclamp, mfloor = math.abs, math.max, math.min, math.clamp, math.floor

	----------------------------------------------------------------------
	-- theme
	----------------------------------------------------------------------

	local TH = {
		bg0 = C3(6, 7, 11), -- void behind everything
		bg1 = C3(12, 13, 19), -- panel body
		bg2 = C3(18, 19, 28), -- cards
		bg3 = C3(25, 27, 39), -- inputs / tracks
		bg4 = C3(36, 39, 55), -- hover
		line = C3(41, 44, 62),
		line2 = C3(66, 71, 98),
		tx1 = C3(240, 242, 252),
		tx2 = C3(154, 160, 184),
		tx3 = C3(100, 105, 130),
		acc = C3(126, 92, 255), -- gravity violet
		acc2 = C3(56, 214, 255), -- event-horizon cyan
		acc3 = C3(255, 94, 188), -- redshift magenta
		ok = C3(45, 212, 155),
		warn = C3(252, 191, 60),
		bad = C3(250, 106, 106),
		white = C3(255, 255, 255),
		black = C3(0, 0, 0),
		mobile = is_mobile,
	}

	-- Only one image asset is used anywhere in the UI, and it is the one this
	-- project already ships with, so there is no risk of a missing texture.
	local SOFT = "rbxassetid://3570695787"
	TH.soft = SOFT
	TH.slice = Rect.new(100, 100, 100, 100)

	local FONT = {
		black = Enum.Font.GothamBlack,
		bold = Enum.Font.GothamBold,
		med = Enum.Font.GothamMedium,
		body = Enum.Font.Gotham,
	}
	TH.font = FONT

	-- one place to scale every hit-target for touch screens
	local M = is_mobile and 1.18 or 1
	TH.touch_mult = M
	TH.row_toggle = mfloor(42 * M)
	TH.row_slider = mfloor(50 * M)
	TH.row_button = mfloor(38 * M)
	TH.radius_panel = 16
	TH.radius_card = 12
	TH.radius_row = 9

	function TH.accent_seq(flip)
		if flip then
			return CS({ CSK(0, TH.acc2), CSK(0.5, TH.acc), CSK(1, TH.acc3) })
		end
		return CS({ CSK(0, TH.acc), CSK(0.55, TH.acc2), CSK(1, TH.acc2) })
	end

	local function tint(c, f)
		if f >= 0 then
			return Color3.new(c.R + (1 - c.R) * f, c.G + (1 - c.G) * f, c.B + (1 - c.B) * f)
		end
		f = 1 + f
		return Color3.new(c.R * f, c.G * f, c.B * f)
	end
	TH.tint = tint

	----------------------------------------------------------------------
	-- instance helpers
	----------------------------------------------------------------------

	-- Parent is assigned last on purpose: it keeps Roblox from re-laying-out
	-- the tree once per property we set. LayoutOrder is stamped automatically
	-- from insertion order, because UIListLayout does not promise anything
	-- sensible when every child shares LayoutOrder 0.
	local order_of = setmetatable({}, { __mode = "k" })

	local function attach(o, parent)
		if parent then
			if o:IsA("GuiObject") and o.LayoutOrder == 0 then
				local n = (order_of[parent] or 0) + 1
				order_of[parent] = n
				o.LayoutOrder = n
			end
			o.Parent = parent
		end
		return o
	end

	local function new(class, props, parent)
		local o = Instance.new(class)
		if props then
			for k, val in pairs(props) do
				o[k] = val
			end
		end
		return attach(o, parent)
	end

	local function corner(obj, r)
		return new("UICorner", { CornerRadius = typeof(r) == "UDim" and r or UD(0, r or 8) }, obj)
	end

	local function stroke(obj, color, thick, transparency)
		return new("UIStroke", {
			Color = color or TH.line,
			Thickness = thick or 1,
			Transparency = transparency or 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}, obj)
	end

	local function grad(obj, seq, rot, transparency)
		local g = new("UIGradient", { Rotation = rot or 0 }, nil)
		if seq then
			g.Color = seq
		end
		if transparency then
			g.Transparency = transparency
		end
		g.Parent = obj
		return g
	end

	local function pad(obj, t, b, l, r)
		return new("UIPadding", {
			PaddingTop = UD(0, t or 0),
			PaddingBottom = UD(0, b or 0),
			PaddingLeft = UD(0, l or 0),
			PaddingRight = UD(0, r or 0),
		}, obj)
	end

	local function list(obj, padding, dir)
		return new("UIListLayout", {
			Padding = UD(0, padding or 6),
			FillDirection = dir or Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}, obj)
	end

	local function label(parent, text, size, font, color, props)
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			Text = text or "",
			TextSize = size or 12,
			Font = font or FONT.med,
			TextColor3 = color or TH.tx1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = U2(1, 0, 1, 0),
		})
		if props then
			for k, val in pairs(props) do
				l[k] = val
			end
		end
		return attach(l, parent)
	end

	-- Drop shadows are deliberately gone: the panel reads better as a crisp box
	-- against the game world. This stays as a no-op so any caller that still asks
	-- for one simply gets nothing instead of an error.
	local function shadow()
		return nil
	end

	----------------------------------------------------------------------
	-- animation engine
	----------------------------------------------------------------------
	-- A spring per (instance, property). Springs are interruptible: retargeting
	-- an in-flight spring keeps its velocity, which is what makes the UI feel
	-- like it is reacting rather than replaying a canned tween.

	local KIND = { number = 1, UDim2 = 2, Color3 = 3, UDim = 4, Vector2 = 5 }
	local NCOMP = { 1, 4, 3, 2, 2 }
	local EPS = {
		{ 0.0016 },
		{ 0.0004, 0.14, 0.0004, 0.14 },
		{ 0.0022, 0.0022, 0.0022 },
		{ 0.0004, 0.14 },
		{ 0.0009, 0.0009 },
	}

	local fx = {}
	local live, live_n = {}, 0
	local pool, pool_n = {}, 0
	local rec_of = setmetatable({}, { __mode = "k" })
	local amb, amb_n = {}, 0 -- decorative, throttled or skipped when the frame budget is tight
	local core, core_n = {}, 0 -- structural, always runs
	local conn = nil
	local clock, amb_dt, frame_i = 0, 0, 0
	local avg_dt, lvl_timer, auto_lvl = 1 / 60, 0, 2
	local level = 2

	fx.PRESET = {
		snap = { k = 620, d = 38 },
		flow = { k = 300, d = 28 },
		glide = { k = 190, d = 24 },
		pop = { k = 460, d = 22 },
		bounce = { k = 420, d = 14 },
		soft = { k = 150, d = 21 },
	}

	local function decompose(kind, val, out)
		if kind == 1 then
			out[1] = val
		elseif kind == 2 then
			out[1], out[2], out[3], out[4] = val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset
		elseif kind == 3 then
			out[1], out[2], out[3] = val.R, val.G, val.B
		elseif kind == 4 then
			out[1], out[2] = val.Scale, val.Offset
		else
			out[1], out[2] = val.X, val.Y
		end
	end

	local function compose(kind, c)
		if kind == 1 then
			return c[1]
		elseif kind == 2 then
			return U2(c[1], c[2], c[3], c[4])
		elseif kind == 3 then
			return Color3.new(mclamp(c[1], 0, 1), mclamp(c[2], 0, 1), mclamp(c[3], 0, 1))
		elseif kind == 4 then
			return UD(c[1], c[2])
		end
		return V2(c[1], c[2])
	end

	local function drop(i)
		local rec = live[i]
		local per = rec_of[rec.obj]
		if per and per[rec.prop] == rec then
			per[rec.prop] = nil
		end
		live[i] = live[live_n]
		live[live_n] = nil
		live_n = live_n - 1
		rec.obj, rec.done = nil, nil
		pool_n = pool_n + 1
		pool[pool_n] = rec
	end

	local function step(dt)
		if dt > 0.1 then
			dt = 0.1
		end
		clock = clock + dt
		amb_dt = amb_dt + dt
		frame_i = frame_i + 1
		avg_dt = avg_dt + (dt - avg_dt) * 0.07

		-- quality auto-scaling: the UI gets out of the way when the physics
		-- engine is the thing that matters.
		lvl_timer = lvl_timer - dt
		if lvl_timer <= 0 then
			lvl_timer = 0.3
			local fps = 1 / mmax(avg_dt, 0.0001)
			if fps < 24 then
				auto_lvl = 0
			elseif fps < 40 then
				if auto_lvl > 1 then
					auto_lvl = 1
				end
			elseif fps > 50 then
				auto_lvl = 2
			end
			local cap = x1.FX
			if cap == nil then
				cap = 2
			end
			level = (x1.FXAuto == false) and cap or mmin(auto_lvl, cap)
		end

		local steps = 1
		if dt > 0.02 then
			steps = mmin(5, 1 + mfloor(dt * 60))
		end
		local h = dt / steps

		local i = 1
		while i <= live_n do
			local rec = live[i]
			local obj = rec.obj
			if rec.dead or obj == nil or obj.Parent == nil then
				drop(i)
			elseif rec.delay > 0 then
				rec.delay = rec.delay - dt
				i = i + 1
			else
				local cx, cv, ct = rec.cx, rec.cv, rec.ct
				local k, d, n = rec.k, rec.d, rec.n
				for _ = 1, steps do
					for j = 1, n do
						local x, vel = cx[j], cv[j]
						vel = vel + ((ct[j] - x) * k - vel * d) * h
						cx[j] = x + vel * h
						cv[j] = vel
					end
				end
				local eps = EPS[rec.kind]
				local rest = true
				for j = 1, n do
					local e = eps[j]
					if mabs(ct[j] - cx[j]) > e or mabs(cv[j]) > e * 14 then
						rest = false
						break
					end
				end
				if rest then
					for j = 1, n do
						cx[j] = ct[j]
						cv[j] = 0
					end
				end
				obj[rec.prop] = compose(rec.kind, cx)
				if rest then
					local done = rec.done
					drop(i)
					if done then
						task.spawn(done)
					end
				else
					i = i + 1
				end
			end
		end

		for j = 1, core_n do
			local f = core[j]
			if f then
				local ok, err = pcall(f, dt, clock, level)
				if not ok then
					core[j] = false
					warn("[Gravity] UI loop disabled after error: " .. tostring(err))
				end
			end
		end

		if level > 0 and (level > 1 or frame_i % 2 == 0) then
			local adt = amb_dt
			amb_dt = 0
			for j = 1, amb_n do
				local f = amb[j]
				if f then
					local ok, err = pcall(f, adt, clock, level)
					if not ok then
						amb[j] = false
						warn("[Gravity] UI effect disabled after error: " .. tostring(err))
					end
				end
			end
		elseif level == 0 then
			amb_dt = 0
		end
	end

	local function ensure_conn()
		if not conn then
			conn = v3.RenderStepped:Connect(step)
			if x6 and x6.c then
				table.insert(x6.c, conn)
			end
		end
	end

	function fx.spring(obj, prop, target, cfg)
		local kind = KIND[typeof(target)]
		if not kind then
			obj[prop] = target
			return
		end
		local per = rec_of[obj]
		if not per then
			per = {}
			rec_of[obj] = per
		end
		local rec = per[prop]
		if not rec or rec.dead then
			if pool_n > 0 then
				rec = pool[pool_n]
				pool[pool_n] = nil
				pool_n = pool_n - 1
			else
				rec = { cx = {}, cv = {}, ct = {} }
			end
			rec.obj, rec.prop, rec.kind, rec.n, rec.dead = obj, prop, kind, NCOMP[kind], false
			decompose(kind, obj[prop], rec.cx)
			local cv = rec.cv
			for j = 1, rec.n do
				cv[j] = 0
			end
			per[prop] = rec
			live_n = live_n + 1
			live[live_n] = rec
		end
		decompose(kind, target, rec.ct)
		if cfg then
			rec.k = cfg.k or 300
			rec.d = cfg.d or 28
			rec.delay = cfg.delay or 0
			rec.done = cfg.done
		else
			rec.k, rec.d, rec.delay, rec.done = 300, 28, 0, nil
		end
		ensure_conn()
		return rec
	end

	-- shorthand: fx.to(obj, prop, target, "pop", delay)
	function fx.to(obj, prop, target, preset, delay)
		local p = fx.PRESET[preset or "flow"]
		return fx.spring(obj, prop, target, { k = p.k, d = p.d, delay = delay })
	end

	function fx.set(obj, prop, val)
		local per = rec_of[obj]
		if per and per[prop] then
			per[prop].dead = true
			per[prop] = nil
		end
		obj[prop] = val
	end

	function fx.kill(obj, prop)
		local per = rec_of[obj]
		if not per then
			return
		end
		if prop then
			if per[prop] then
				per[prop].dead = true
				per[prop] = nil
			end
		else
			for p, rec in pairs(per) do
				rec.dead = true
				per[p] = nil
			end
		end
	end

	-- punch a property away from its resting value and let the spring pull it
	-- back: the cheapest way to make something feel physical.
	function fx.punch(obj, prop, from, to, preset)
		fx.set(obj, prop, from)
		fx.to(obj, prop, to, preset or "bounce")
	end

	function fx.every(f, essential)
		ensure_conn()
		if essential then
			core_n = core_n + 1
			core[core_n] = f
			return -core_n
		end
		amb_n = amb_n + 1
		amb[amb_n] = f
		return amb_n
	end

	function fx.cancel(handle)
		if not handle then
			return
		end
		if handle < 0 then
			core[-handle] = false
		else
			amb[handle] = false
		end
	end

	function fx.level()
		return level
	end

	function fx.fps()
		return 1 / mmax(avg_dt, 0.0001)
	end

	function fx.clock()
		return clock
	end

	function fx.stop()
		if conn then
			conn:Disconnect()
			conn = nil
		end
		for i = live_n, 1, -1 do
			live[i] = nil
		end
		live_n = 0
		for i = 1, amb_n do
			amb[i] = false
		end
		for i = 1, core_n do
			core[i] = false
		end
		amb_n, core_n = 0, 0
	end

	-- click ripple; one reusable frame per host so clicking fast never spams
	-- the instance tree.
	local ripple_of = setmetatable({}, { __mode = "k" })
	function fx.ripple(host, px, py, color)
		if level < 1 then
			return
		end
		local r = ripple_of[host]
		if not r or r.Parent ~= host then
			r = new("Frame", {
				BackgroundColor3 = color or TH.white,
				BorderSizePixel = 0,
				AnchorPoint = V2(0.5, 0.5),
				Size = U2(0, 0, 0, 0),
				ZIndex = 20,
				Active = false,
			}, host)
			corner(r, UD(1, 0))
			ripple_of[host] = r
		end
		if color then
			r.BackgroundColor3 = color
		end
		local a = host.AbsolutePosition
		local s = host.AbsoluteSize
		local lx, ly = (px or (a.X + s.X * 0.5)) - a.X, (py or (a.Y + s.Y * 0.5)) - a.Y
		local reach = mmax(s.X, s.Y) * 2.1
		fx.set(r, "Position", U2(0, lx, 0, ly))
		fx.set(r, "Size", U2(0, 0, 0, 0))
		fx.set(r, "BackgroundTransparency", 0.72)
		fx.to(r, "Size", U2(0, reach, 0, reach), "glide")
		fx.to(r, "BackgroundTransparency", 1, "glide")
	end

	----------------------------------------------------------------------
	-- shared input plumbing
	----------------------------------------------------------------------
	-- Every slider in the UI used to own two UserInputService connections.
	-- Now there are exactly two for the whole interface.

	local drag_slider = nil
	local function is_press(io)
		local t = io.UserInputType
		return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
	end
	local function is_move(io)
		local t = io.UserInputType
		return t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch
	end

	table.insert(
		x6.c,
		v1.InputChanged:Connect(function(io)
			if drag_slider and is_move(io) then
				drag_slider.move(io.Position.X)
			end
		end)
	)
	table.insert(
		x6.c,
		v1.InputEnded:Connect(function(io)
			if drag_slider and is_press(io) then
				local s = drag_slider
				drag_slider = nil
				s.release()
			end
		end)
	)

	-- hover/press wiring shared by every clickable surface
	local function interactive(btn, opts)
		opts = opts or {}
		local scale = opts.scale
		local hover, held = false, false
		local function visual()
			if opts.paint then
				opts.paint(hover, held)
			end
			if scale then
				local s = held and (opts.press or 0.965) or (hover and (opts.lift or 1.025) or 1)
				fx.to(scale, "Scale", s, held and "snap" or "pop")
			end
		end
		if not is_mobile then
			btn.MouseEnter:Connect(function()
				hover = true
				visual()
			end)
			btn.MouseLeave:Connect(function()
				hover = false
				if held then
					held = false
				end
				visual()
			end)
		end
		btn.InputBegan:Connect(function(io)
			if not is_press(io) then
				return
			end
			held = true
			if is_mobile then
				hover = true
			end
			visual()
			if opts.ripple ~= false then
				fx.ripple(btn, io.Position.X, io.Position.Y, opts.ripple_color)
			end
			if opts.on_press then
				opts.on_press()
			end
		end)
		btn.InputEnded:Connect(function(io)
			if not is_press(io) then
				return
			end
			held = false
			if is_mobile then
				hover = false
			end
			visual()
		end)
		return visual
	end

	----------------------------------------------------------------------
	-- widget: row scaffold
	----------------------------------------------------------------------

	-- Rows size themselves from their content plus this padding, so a row with a
	-- description grows instead of clipping and none of the heights are guesses.
	local ROW_PAD = is_mobile and 9 or 8

	local function make_row(parent, desc, desc_y)
		local f = new("Frame", {
			BackgroundColor3 = TH.bg2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = false,
		}, parent)
		corner(f, TH.radius_row)
		pad(f, ROW_PAD, ROW_PAD, 10, 10)

		local d
		if desc then
			d = label(f, desc, 10, FONT.body, TH.tx3, {
				Position = U2(0, 0, 0, desc_y or 22),
				Size = U2(1, -52, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				LineHeight = 1.15,
			})
		end

		return f, d
	end

	-- Wire a hover tint on `frame` driven by whichever objects actually receive
	-- the mouse (a TextButton child would otherwise swallow the frame's own
	-- MouseEnter). Overlapping regions are refcounted so the tint never flickers.
	local function hover_row(frame, ...)
		if is_mobile then
			return
		end
		local depth = 0
		local function upd()
			fx.to(frame, "BackgroundTransparency", depth > 0 and 0.55 or 1, depth > 0 and "snap" or "flow")
		end
		local sources = { frame, ... }
		for i = 1, #sources do
			local src = sources[i]
			src.MouseEnter:Connect(function()
				depth = depth + 1
				upd()
			end)
			src.MouseLeave:Connect(function()
				depth = mmax(0, depth - 1)
				upd()
			end)
		end
	end

	----------------------------------------------------------------------
	-- widget: slider
	----------------------------------------------------------------------

	local Elements = {}

	function Elements.s(parent, text, mn, mx, df, cb, is_int, desc)
		df = df or mn
		local snap_int = is_int or (mx - mn) > 50
		local function quantize(v)
			if snap_int then
				return mfloor(v + 0.5)
			end
			return mfloor(v * 10 + 0.5) / 10
		end
		df = mclamp(quantize(df), mn, mx)

		local row = make_row(parent, desc, 40)
		local span = mx - mn
		if span == 0 then
			span = 1
		end

		local title = label(row, text, is_mobile and 12 or 12, FONT.med, TH.tx2, {
			Size = U2(1, -66, 0, 18),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local vbox = new("TextBox", {
			BackgroundColor3 = TH.bg3,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = U2(1, -60, 0, -1),
			Size = U2(0, 60, 0, 20),
			Text = tostring(df),
			TextColor3 = TH.tx1,
			TextSize = 12,
			Font = FONT.bold,
			TextXAlignment = Enum.TextXAlignment.Right,
			ClearTextOnFocus = false,
			TextEditable = true,
			AutoLocalize = false,
		}, row)
		corner(vbox, 6)
		local vscale = new("UIScale", {}, vbox)

		local track_h = is_mobile and 8 or 6
		local hit = new("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Position = U2(0, 0, 0, 20),
			Size = U2(1, 0, 0, 16),
			ZIndex = 2,
		}, row)

		local track = new("Frame", {
			BackgroundColor3 = TH.bg3,
			BorderSizePixel = 0,
			AnchorPoint = V2(0, 0.5),
			Position = U2(0, 0, 0.5, 0),
			Size = U2(1, 0, 0, track_h),
		}, hit)
		corner(track, UD(1, 0))
		stroke(track, TH.line, 1, 0.35)

		local fill = new("Frame", {
			BackgroundColor3 = TH.acc,
			BorderSizePixel = 0,
			Size = U2((df - mn) / span, 0, 1, 0),
		}, track)
		corner(fill, UD(1, 0))
		local fill_grad = grad(fill, TH.accent_seq(), 0)

		local knob = new("Frame", {
			BackgroundColor3 = TH.white,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2((df - mn) / span, 0, 0.5, 0),
			Size = U2(0, 0, 0, 0),
			ZIndex = 3,
		}, track)
		corner(knob, UD(1, 0))
		local knob_scale = new("UIScale", {}, knob)
		local knob_stroke = stroke(knob, TH.acc, 2, 0)
		local knob_px = is_mobile and 16 or 13
		knob.Size = U2(0, knob_px, 0, knob_px)

		local halo = new("ImageLabel", {
			BackgroundTransparency = 1,
			Image = SOFT,
			ImageColor3 = TH.acc,
			ImageTransparency = 1,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = TH.slice,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(0.5, 0, 0.5, 0),
			Size = U2(1, 26, 1, 26),
			ZIndex = 2,
			Active = false,
		}, knob)

		local value = df
		local silent = false

		local function paint(v, animated)
			local a = (v - mn) / span
			if animated then
				fx.to(fill, "Size", U2(a, 0, 1, 0), "snap")
				fx.to(knob, "Position", U2(a, 0, 0.5, 0), "snap")
			else
				fx.set(fill, "Size", U2(a, 0, 1, 0))
				fx.set(knob, "Position", U2(a, 0, 0.5, 0))
			end
			if not vbox:IsFocused() then
				vbox.Text = tostring(v)
			end
		end

		local function apply(v, animated, from_user)
			v = mclamp(quantize(v), mn, mx)
			if v == value and from_user then
				return
			end
			value = v
			paint(v, animated)
			if not silent then
				fx.punch(vscale, "Scale", 1.16, 1, "bounce")
				cb(v)
				if save_settings then
					save_settings()
				end
			end
		end

		local grab_x, grab_v = 0, 0
		local function from_x(px, fine)
			local origin = track.AbsolutePosition.X
			local width = mmax(track.AbsoluteSize.X, 1)
			if fine then
				return grab_v + ((px - grab_x) / width) * span * 0.22
			end
			return mn + span * mclamp((px - origin) / width, 0, 1)
		end

		local dragging = false
		local shift_down = false

		local handle = {
			move = function(px)
				apply(from_x(px, shift_down), true, true)
			end,
			release = function()
				dragging = false
				fx.to(knob_scale, "Scale", 1, "pop")
				fx.to(halo, "ImageTransparency", 1, "flow")
				fx.to(vbox, "TextColor3", TH.tx1, "flow")
				fx.to(knob_stroke, "Thickness", 2, "flow")
			end,
		}

		hit.InputBegan:Connect(function(io)
			if not is_press(io) then
				return
			end
			dragging = true
			shift_down = v1:IsKeyDown(Enum.KeyCode.LeftShift) or v1:IsKeyDown(Enum.KeyCode.RightShift)
			grab_x, grab_v = io.Position.X, value
			drag_slider = handle
			fx.to(knob_scale, "Scale", 1.45, "bounce")
			fx.to(halo, "ImageTransparency", 0.55, "snap")
			fx.to(vbox, "TextColor3", TH.acc2, "snap")
			fx.to(knob_stroke, "Thickness", 3, "snap")
			if not shift_down then
				apply(from_x(io.Position.X), true, true)
			end
		end)

		if not is_mobile then
			hit.MouseEnter:Connect(function()
				if not dragging then
					fx.to(knob_scale, "Scale", 1.2, "pop")
					fx.to(halo, "ImageTransparency", 0.82, "flow")
				end
			end)
			hit.MouseLeave:Connect(function()
				if not dragging then
					fx.to(knob_scale, "Scale", 1, "flow")
					fx.to(halo, "ImageTransparency", 1, "flow")
				end
			end)
		end

		vbox.Focused:Connect(function()
			fx.to(vbox, "BackgroundTransparency", 0.15, "snap")
			fx.to(vbox, "TextColor3", TH.acc2, "snap")
		end)
		vbox.FocusLost:Connect(function()
			fx.to(vbox, "BackgroundTransparency", 1, "flow")
			fx.to(vbox, "TextColor3", TH.tx1, "flow")
			local typed = tonumber(vbox.Text)
			if typed then
				apply(typed, true, true)
			else
				vbox.Text = tostring(value)
			end
		end)

		hover_row(row, hit, vbox)

		local api = {
			frame = row,
			get = function()
				return value
			end,
			set = function(v, quiet)
				silent = quiet ~= false
				apply(v, true, false)
				silent = false
			end,
			set_label = function(t)
				title.Text = t
			end,
		}
		return row, api
	end

	----------------------------------------------------------------------
	-- widget: toggle
	----------------------------------------------------------------------

	function Elements.t(parent, text, df, cb, desc)
		df = df and true or false
		local tw, th = mfloor(42 * M), mfloor(22 * M)
		local row = make_row(parent, desc, th + 4)

		label(row, text, is_mobile and 12 or 12, FONT.med, TH.tx2, {
			Size = U2(1, -(tw + 14), 0, th),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local track = new("Frame", {
			BackgroundColor3 = df and TH.acc or TH.bg3,
			BorderSizePixel = 0,
			AnchorPoint = V2(1, 0),
			Position = U2(1, 0, 0, 0),
			Size = U2(0, tw, 0, th),
		}, row)
		corner(track, UD(1, 0))
		local track_stroke = stroke(track, df and TH.acc2 or TH.line, 1, df and 0.25 or 0.2)
		local track_grad = grad(track, TH.accent_seq(), 0)
		track_grad.Enabled = df

		local kp = th - 6
		local knob = new("Frame", {
			BackgroundColor3 = TH.white,
			BorderSizePixel = 0,
			AnchorPoint = V2(0, 0.5),
			Position = df and U2(1, -(kp + 3), 0.5, 0) or U2(0, 3, 0.5, 0),
			Size = U2(0, kp, 0, kp),
			ZIndex = 2,
		}, track)
		corner(knob, UD(1, 0))
		local knob_scale = new("UIScale", {}, knob)

		local btn = new("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = U2(1, 0, 1, 0),
			ZIndex = 3,
		}, row)

		local state = df
		local function paint(animated)
			local on = state
			if animated then
				fx.to(track, "BackgroundColor3", on and TH.acc or TH.bg3, "flow")
				fx.to(track_stroke, "Color", on and TH.acc2 or TH.line, "flow")
				fx.to(knob, "Position", on and U2(1, -(kp + 3), 0.5, 0) or U2(0, 3, 0.5, 0), "bounce")
				fx.punch(knob_scale, "Scale", on and 1.22 or 0.84, 1, "bounce")
				if on then
					-- flash the stroke rather than growing a ring: strokes draw
					-- outside the layout box, so nothing shifts.
					fx.set(track_stroke, "Thickness", 3.2)
					fx.set(track_stroke, "Transparency", 0)
					fx.to(track_stroke, "Thickness", 1, "glide")
					fx.to(track_stroke, "Transparency", 0.25, "glide")
				end
			else
				fx.set(track, "BackgroundColor3", on and TH.acc or TH.bg3)
				fx.set(track_stroke, "Color", on and TH.acc2 or TH.line)
				fx.set(knob, "Position", on and U2(1, -(kp + 3), 0.5, 0) or U2(0, 3, 0.5, 0))
			end
			track_grad.Enabled = on
		end

		-- No scale on the track: it is a direct child of an auto-sizing row, so
		-- growing it would change the row's height. The knob punch carries the
		-- press feedback instead.
		interactive(btn, {
			ripple = false,
			on_press = function()
				state = not state
				paint(true)
				cb(state)
				if save_settings then
					save_settings()
				end
			end,
		})

		hover_row(row, btn)

		local api = {
			frame = row,
			get = function()
				return state
			end,
			set = function(v)
				v = v and true or false
				if v == state then
					return
				end
				state = v
				paint(true)
			end,
		}
		return btn, api
	end

	----------------------------------------------------------------------
	-- widget: buttons
	----------------------------------------------------------------------

	local VARIANT = {
		ghost = { bg = TH.bg2, bgh = TH.bg4, tx = TH.tx1, line = TH.line, lineh = TH.line2 },
		accent = { bg = TH.acc, bgh = TH.acc, tx = TH.white, line = TH.acc2, lineh = TH.acc2, gradient = true },
		quiet = { bg = TH.bg1, bgh = TH.bg3, tx = TH.acc2, line = TH.line, lineh = TH.acc },
		danger = { bg = C3(58, 20, 26), bgh = C3(96, 28, 36), tx = C3(255, 190, 190), line = C3(120, 44, 52), lineh = TH.bad },
		ok = { bg = C3(14, 48, 38), bgh = C3(20, 74, 58), tx = C3(180, 255, 228), line = C3(30, 92, 74), lineh = TH.ok },
	}

	-- The returned object is a fixed-size wrapper and the thing that actually
	-- scales on hover is inside it. A UIScale on a list child would otherwise
	-- nudge every item below it every time the mouse moved.
	local function button(parent, text, cb, variant, height)
		local V = VARIANT[variant or "ghost"]
		local h = height or TH.row_button
		local wrap = new("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, h),
		}, parent)

		local b = new("TextButton", {
			BackgroundColor3 = V.bg,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Size = U2(1, 0, 1, 0),
			Text = "",
			ClipsDescendants = true,
		}, wrap)
		corner(b, TH.radius_row)
		local bs = stroke(b, V.line, 1, 0.1)
		local bscale = new("UIScale", {}, b)

		-- created up front so set_variant can switch a flat button to a gradient
		-- one without rebuilding it
		local bgrad = grad(b, TH.accent_seq(), 12)
		bgrad.Enabled = V.gradient and true or false

		-- sheen that sweeps across on hover
		local sheen = new("Frame", {
			BackgroundColor3 = TH.white,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U2(0.42, 0, 2, 0),
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(-0.35, 0, 0.5, 0),
			Rotation = 18,
			ZIndex = 2,
			Active = false,
		}, b)
		local sheen_grad = grad(
			sheen,
			CS({ CSK(0, TH.white), CSK(1, TH.white) }),
			0,
			NS({ NSK(0, 1), NSK(0.5, 0.86), NSK(1, 1) })
		)

		local lbl = label(b, text, is_mobile and 12 or 13, FONT.bold, V.tx, {
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 3,
			Size = U2(1, -16, 1, 0),
			Position = U2(0, 8, 0, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		interactive(b, {
			scale = bscale,
			ripple_color = V.gradient and TH.white or V.lineh,
			paint = function(hover)
				fx.to(b, "BackgroundColor3", hover and V.bgh or V.bg, "snap")
				fx.to(bs, "Color", hover and V.lineh or V.line, "snap")
				fx.to(lbl, "TextColor3", hover and TH.white or V.tx, "snap")
				if hover then
					fx.set(sheen, "Position", U2(-0.35, 0, 0.5, 0))
					fx.to(sheen, "Position", U2(1.35, 0, 0.5, 0), "glide")
				end
			end,
		})

		b.MouseButton1Click:Connect(function()
			if cb then
				cb(b)
			end
		end)

		local api = {
			button = b,
			label = lbl,
			stroke = bs,
			scale = bscale,
			set_text = function(t)
				if lbl.Text ~= t then
					lbl.Text = t
				end
			end,
			set_variant = function(name)
				local nv = VARIANT[name] or VARIANT.ghost
				if nv == V then
					return
				end
				V = nv
				fx.to(b, "BackgroundColor3", nv.bg, "flow")
				fx.to(bs, "Color", nv.line, "flow")
				fx.to(lbl, "TextColor3", nv.tx, "flow")
				bgrad.Enabled = nv.gradient and true or false
			end,
			flash = function(color)
				fx.set(bs, "Color", color or TH.acc2)
				fx.set(bs, "Thickness", 2.5)
				fx.to(bs, "Color", V.line, "glide")
				fx.to(bs, "Thickness", 1, "glide")
			end,
		}
		return wrap, api
	end

	Elements.button = button

	function Elements.b(parent, text, cb)
		return (button(parent, text, cb, "ghost"))
	end

	function Elements.sub_b(parent, text, cb)
		return (button(parent, text, cb, "quiet", mfloor(34 * M)))
	end

	-- compact circular icon button used in the title bar / dock
	function Elements.icon(parent, glyph, cb, color, size)
		size = size or mfloor(26 * M)
		local wrap = new("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U2(0, size, 0, size),
		}, parent)
		local b = new("TextButton", {
			BackgroundColor3 = TH.bg3,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Size = U2(1, 0, 1, 0),
			Text = "",
			ClipsDescendants = true,
		}, wrap)
		corner(b, UD(1, 0))
		local bs = stroke(b, TH.line, 1, 0.15)
		local sc = new("UIScale", {}, b)
		local lbl = label(b, glyph, mfloor(size * 0.52), FONT.bold, color or TH.tx2, {
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = U2(1, 0, 1, 0),
			ZIndex = 2,
		})
		interactive(b, {
			scale = sc,
			lift = 1.14,
			press = 0.9,
			ripple_color = color or TH.acc2,
			paint = function(hover)
				fx.to(b, "BackgroundColor3", hover and TH.bg4 or TH.bg3, "snap")
				fx.to(bs, "Color", hover and (color or TH.acc) or TH.line, "snap")
				fx.to(lbl, "TextColor3", hover and (color or TH.white) or (color or TH.tx2), "snap")
			end,
		})
		b.MouseButton1Click:Connect(function()
			if cb then
				cb(b)
			end
		end)
		return wrap, { button = b, label = lbl, stroke = bs, scale = sc }
	end

	----------------------------------------------------------------------
	-- widget: section header
	----------------------------------------------------------------------

	function Elements.h(parent, text)
		local f = new("Frame", {
			BackgroundTransparency = 1,
			Size = U2(1, 0, 0, is_mobile and 24 or 26),
		}, parent)
		local l = label(f, string.upper(text or ""), 10, FONT.bold, TH.tx3, {
			Size = U2(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
		})
		local rule = new("Frame", {
			BackgroundColor3 = TH.line,
			BorderSizePixel = 0,
			AnchorPoint = V2(1, 0.5),
			Position = U2(1, 0, 0.5, 2),
			Size = U2(1, 0, 0, 1),
		}, f)
		grad(rule, CS({ CSK(0, TH.line), CSK(1, TH.line) }), 0, NS({ NSK(0, 1), NSK(1, 0.35) }))
		-- keep the rule clear of the label
		l:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			rule.Size = U2(1, -(l.AbsoluteSize.X + 12), 0, 1)
		end)
		rule.Size = U2(1, -(l.AbsoluteSize.X + 12), 0, 1)
		return f, l
	end

	----------------------------------------------------------------------
	-- widget: card / group container
	----------------------------------------------------------------------

	function Elements.card(parent, padding)
		local f = new("Frame", {
			BackgroundColor3 = TH.bg2,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, parent)
		corner(f, TH.radius_card)
		stroke(f, TH.line, 1, 0.25)
		local p = padding or 8
		pad(f, p, p, p, p)
		local l = list(f, 4)
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center
		return f
	end

	function Elements.spacer(parent, h)
		return new("Frame", { BackgroundTransparency = 1, Size = U2(1, 0, 0, h or 4) }, parent)
	end

	----------------------------------------------------------------------
	-- widget: search box
	----------------------------------------------------------------------

	function Elements.search(parent, placeholder, on_change)
		local h = mfloor(34 * M)
		local wrap = new("Frame", {
			BackgroundColor3 = TH.bg3,
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, h),
		}, parent)
		corner(wrap, TH.radius_row)
		local ws = stroke(wrap, TH.line, 1, 0.15)

		local glass = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = V2(0, 0.5),
			Position = U2(0, 11, 0.5, -1),
			Size = U2(0, 10, 0, 10),
		}, wrap)
		corner(glass, UD(1, 0))
		local glass_stroke = stroke(glass, TH.tx3, 1.5, 0)
		new("Frame", {
			BackgroundColor3 = TH.tx3,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0),
			Position = U2(1, 0, 1, -1),
			Size = U2(0, 1.5, 0, 5),
			Rotation = -45,
		}, glass)

		local box = new("TextBox", {
			BackgroundTransparency = 1,
			Position = U2(0, 30, 0, 0),
			Size = U2(1, -40, 1, 0),
			Text = "",
			PlaceholderText = placeholder or "Search",
			PlaceholderColor3 = TH.tx3,
			TextColor3 = TH.tx1,
			TextSize = 13,
			Font = FONT.med,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
		}, wrap)

		box.Focused:Connect(function()
			fx.to(ws, "Color", TH.acc, "snap")
			fx.to(wrap, "BackgroundColor3", TH.bg4, "snap")
			fx.to(glass_stroke, "Color", TH.acc2, "snap")
		end)
		box.FocusLost:Connect(function()
			fx.to(ws, "Color", TH.line, "flow")
			fx.to(wrap, "BackgroundColor3", TH.bg3, "flow")
			fx.to(glass_stroke, "Color", TH.tx3, "flow")
		end)

		-- debounced: typing no longer rebuilds a list on every keystroke
		local pending, token = false, 0
		box:GetPropertyChangedSignal("Text"):Connect(function()
			token = token + 1
			local mine = token
			if pending then
				return
			end
			pending = true
			task.delay(0.06, function()
				pending = false
				if mine <= token and on_change then
					on_change(box.Text)
				end
			end)
		end)
		return wrap, box
	end

	----------------------------------------------------------------------
	-- widget: segmented control
	----------------------------------------------------------------------

	function Elements.segmented(parent, options, index, cb)
		local h = mfloor(30 * M)
		local wrap = new("Frame", {
			BackgroundColor3 = TH.bg3,
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, h),
		}, parent)
		corner(wrap, UD(1, 0))
		stroke(wrap, TH.line, 1, 0.3)
		pad(wrap, 3, 3, 3, 3)

		local pill = new("Frame", {
			BackgroundColor3 = TH.acc,
			BorderSizePixel = 0,
			Size = U2(1 / #options, 0, 1, 0),
			Position = U2((index - 1) / #options, 0, 0, 0),
		}, wrap)
		corner(pill, UD(1, 0))
		grad(pill, TH.accent_seq(), 0)

		local labels = {}
		local current = index
		local function select(i, fire)
			current = i
			fx.to(pill, "Position", U2((i - 1) / #options, 0, 0, 0), "pop")
			for j, l in ipairs(labels) do
				fx.to(l, "TextColor3", j == i and TH.white or TH.tx3, "snap")
			end
			if fire and cb then
				cb(i, options[i])
			end
		end

		for i, name in ipairs(options) do
			local b = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Size = U2(1 / #options, 0, 1, 0),
				Position = U2((i - 1) / #options, 0, 0, 0),
				ZIndex = 2,
			}, wrap)
			labels[i] = label(b, name, 11, FONT.bold, i == index and TH.white or TH.tx3, {
				TextXAlignment = Enum.TextXAlignment.Center,
			})
			b.MouseButton1Click:Connect(function()
				if current ~= i then
					select(i, true)
				end
			end)
		end
		return wrap, {
			set = function(i)
				select(i, false)
			end,
		}
	end

	----------------------------------------------------------------------
	-- widget: HSV colour picker
	----------------------------------------------------------------------

	function Elements.color(parent, initial, on_change)
		local wrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = U2(1, 0, 0, is_mobile and 168 or 156),
		}, parent)

		local h0, s0, v0 = initial:ToHSV()
		local hue, sat, val = h0, s0, v0

		local sv = new("Frame", {
			BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, is_mobile and 112 or 100),
		}, wrap)
		corner(sv, 10)
		stroke(sv, TH.line, 1, 0.2)
		local white = new("Frame", {
			BackgroundColor3 = TH.white,
			BorderSizePixel = 0,
			Size = U2(1, 0, 1, 0),
		}, sv)
		corner(white, 10)
		grad(white, CS({ CSK(0, TH.white), CSK(1, TH.white) }), 0, NS({ NSK(0, 0), NSK(1, 1) }))
		local black = new("Frame", {
			BackgroundColor3 = TH.black,
			BorderSizePixel = 0,
			Size = U2(1, 0, 1, 0),
			ZIndex = 2,
		}, sv)
		corner(black, 10)
		grad(black, CS({ CSK(0, TH.black), CSK(1, TH.black) }), 90, NS({ NSK(0, 1), NSK(1, 0) }))

		local sv_knob = new("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0.5),
			Size = U2(0, 14, 0, 14),
			Position = U2(sat, 0, 1 - val, 0),
			ZIndex = 4,
		}, sv)
		corner(sv_knob, UD(1, 0))
		stroke(sv_knob, TH.white, 2.5, 0)
		local sv_knob_scale = new("UIScale", {}, sv_knob)

		local hue_bar = new("Frame", {
			BackgroundColor3 = TH.white,
			BorderSizePixel = 0,
			Position = U2(0, 0, 0, (is_mobile and 112 or 100) + 10),
			Size = U2(1, -68, 0, is_mobile and 16 or 13),
		}, wrap)
		corner(hue_bar, UD(1, 0))
		stroke(hue_bar, TH.line, 1, 0.2)
		grad(hue_bar, CS({
			CSK(0.00, C3(255, 0, 0)),
			CSK(0.17, C3(255, 255, 0)),
			CSK(0.33, C3(0, 255, 0)),
			CSK(0.50, C3(0, 255, 255)),
			CSK(0.67, C3(0, 0, 255)),
			CSK(0.83, C3(255, 0, 255)),
			CSK(1.00, C3(255, 0, 0)),
		}), 0)
		local hue_knob = new("Frame", {
			BackgroundColor3 = TH.white,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(hue, 0, 0.5, 0),
			Size = U2(0, 8, 1, 6),
			ZIndex = 3,
		}, hue_bar)
		corner(hue_knob, UD(1, 0))
		stroke(hue_knob, TH.bg0, 1.5, 0.2)

		local preview = new("Frame", {
			BackgroundColor3 = initial,
			BorderSizePixel = 0,
			AnchorPoint = V2(1, 0),
			Position = U2(1, 0, 0, (is_mobile and 112 or 100) + 4),
			Size = U2(0, 58, 0, is_mobile and 28 or 26),
		}, wrap)
		corner(preview, 8)
		local preview_stroke = stroke(preview, TH.line, 1, 0.1)

		local hex = label(wrap, "", 10, FONT.bold, TH.tx3, {
			AnchorPoint = V2(1, 0),
			Position = U2(1, 0, 0, (is_mobile and 112 or 100) + 36),
			Size = U2(0, 58, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Center,
		})

		local function emit()
			local c = Color3.fromHSV(hue, sat, val)
			fx.to(preview, "BackgroundColor3", c, "snap")
			fx.to(preview_stroke, "Color", c, "snap")
			hex.Text = string.format("%02X%02X%02X", mfloor(c.R * 255 + 0.5), mfloor(c.G * 255 + 0.5), mfloor(c.B * 255 + 0.5))
			if on_change then
				on_change(c)
			end
		end

		local function set_sv(px, py)
			local a, s = sv.AbsolutePosition, sv.AbsoluteSize
			sat = mclamp((px - a.X) / mmax(s.X, 1), 0, 1)
			val = 1 - mclamp((py - a.Y) / mmax(s.Y, 1), 0, 1)
			fx.to(sv_knob, "Position", U2(sat, 0, 1 - val, 0), "snap")
			emit()
		end
		local function set_hue(px)
			local a, s = hue_bar.AbsolutePosition, hue_bar.AbsoluteSize
			hue = mclamp((px - a.X) / mmax(s.X, 1), 0, 1)
			fx.to(hue_knob, "Position", U2(hue, 0, 0.5, 0), "snap")
			fx.to(sv, "BackgroundColor3", Color3.fromHSV(hue, 1, 1), "snap")
			emit()
		end

		local sv_drag, hue_drag = false, false
		local move_conn = v1.InputChanged:Connect(function(io)
			if not is_move(io) then
				return
			end
			if sv_drag then
				set_sv(io.Position.X, io.Position.Y)
			elseif hue_drag then
				set_hue(io.Position.X)
			end
		end)
		local end_conn = v1.InputEnded:Connect(function(io)
			if is_press(io) then
				if sv_drag or hue_drag then
					fx.to(sv_knob_scale, "Scale", 1, "pop")
					if save_settings then
						save_settings()
					end
				end
				sv_drag, hue_drag = false, false
			end
		end)
		table.insert(x6.c, move_conn)
		table.insert(x6.c, end_conn)
		wrap.AncestryChanged:Connect(function(_, p)
			if not p then
				move_conn:Disconnect()
				end_conn:Disconnect()
			end
		end)

		local sv_hit = new("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = U2(1, 0, 1, 0),
			ZIndex = 3,
		}, sv)
		sv_hit.InputBegan:Connect(function(io)
			if is_press(io) then
				sv_drag = true
				fx.to(sv_knob_scale, "Scale", 1.4, "bounce")
				set_sv(io.Position.X, io.Position.Y)
			end
		end)
		local hue_hit = new("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = U2(1, 0, 1, 8),
			Position = U2(0, 0, 0, -4),
			ZIndex = 4,
		}, hue_bar)
		hue_hit.InputBegan:Connect(function(io)
			if is_press(io) then
				hue_drag = true
				set_hue(io.Position.X)
			end
		end)

		-- quick presets
		local presets = {
			C3(255, 105, 180),
			TH.acc,
			TH.acc2,
			TH.ok,
			TH.warn,
			TH.bad,
			C3(255, 255, 255),
			C3(255, 140, 40),
		}
		local strip = new("Frame", {
			BackgroundTransparency = 1,
			Position = U2(0, 0, 0, (is_mobile and 112 or 100) + (is_mobile and 34 or 30)),
			Size = U2(1, -68, 0, 18),
		}, wrap)
		local sl = list(strip, 6, Enum.FillDirection.Horizontal)
		sl.HorizontalAlignment = Enum.HorizontalAlignment.Left
		sl.VerticalAlignment = Enum.VerticalAlignment.Center
		for _, c in ipairs(presets) do
			local sw = new("TextButton", {
				BackgroundColor3 = c,
				BorderSizePixel = 0,
				Size = U2(0, 18, 0, 18),
				Text = "",
				AutoButtonColor = false,
			}, strip)
			corner(sw, UD(1, 0))
			local sws = stroke(sw, TH.line, 1, 0.3)
			interactive(sw, {
				ripple = false,
				paint = function(hover)
					fx.to(sws, "Color", hover and TH.white or TH.line, "snap")
					fx.to(sws, "Thickness", hover and 2 or 1, "snap")
				end,
			})
			sw.MouseButton1Click:Connect(function()
				hue, sat, val = c:ToHSV()
				fx.to(sv, "BackgroundColor3", Color3.fromHSV(hue, 1, 1), "flow")
				fx.to(sv_knob, "Position", U2(sat, 0, 1 - val, 0), "pop")
				fx.to(hue_knob, "Position", U2(hue, 0, 0.5, 0), "pop")
				emit()
				if save_settings then
					save_settings()
				end
			end)
		end

		emit()
		return wrap, {
			set = function(c)
				hue, sat, val = c:ToHSV()
				fx.to(sv, "BackgroundColor3", Color3.fromHSV(hue, 1, 1), "flow")
				fx.to(sv_knob, "Position", U2(sat, 0, 1 - val, 0), "flow")
				fx.to(hue_knob, "Position", U2(hue, 0, 0.5, 0), "flow")
				emit()
			end,
		}
	end

	----------------------------------------------------------------------
	-- widget: stat readout with rolling numbers
	----------------------------------------------------------------------

	function Elements.stat(parent, caption, width)
		local f = new("Frame", {
			BackgroundTransparency = 1,
			Size = U2(0, width or 62, 1, 0),
		}, parent)
		local val = label(f, "0", 12, FONT.bold, TH.tx1, {
			Position = U2(0, 0, 0, 0),
			Size = U2(1, 0, 0.58, 0),
			TextYAlignment = Enum.TextYAlignment.Bottom,
		})
		local cap = label(f, string.upper(caption), 9, FONT.med, TH.tx3, {
			Position = U2(0, 0, 0.58, 0),
			Size = U2(1, 0, 0.42, 0),
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		return f, {
			value = val,
			caption = cap,
			set = function(text, color)
				if val.Text ~= text then
					val.Text = text
				end
				if color then
					fx.to(val, "TextColor3", color, "snap")
				end
			end,
		}
	end

	----------------------------------------------------------------------
	-- exports
	----------------------------------------------------------------------

	Elements.TH = TH
	Elements.fx = fx
	Elements.new = new
	Elements.corner = corner
	Elements.stroke = stroke
	Elements.grad = grad
	Elements.pad = pad
	Elements.list = list
	Elements.label = label
	Elements.shadow = shadow
	Elements.row = make_row
	Elements.interactive = interactive
	Elements.is_press = is_press
	Elements.is_move = is_move
	Elements.CS = CS
	Elements.CSK = CSK
	Elements.NS = NS
	Elements.NSK = NSK

	return Elements
end
