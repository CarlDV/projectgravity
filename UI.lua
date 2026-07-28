--!optimize 2
-- Project Gravity :: interface.
--
-- Everything the old build spread across five draggable windows (main, advanced,
-- mode list, target list, tutorial) now lives in one panel with five tabs. That
-- removes several hundred instances, all of the popup positioning maths, and the
-- per-toggle UI rebuilds: the panel is built once and state is pushed into the
-- widgets instead of the widgets being thrown away and made again.
--
-- Pages are built the first time you open them, lists reuse their rows, and all
-- animation runs on the single RenderStepped loop that lives in UI_elements.

return function(context)
	local v1, v2, v3, v4, v5, v6, v7, v8, v9 =
		context.v1, context.v2, context.v3, context.v4, context.v5, context.v6, context.v7, context.v8, context.v9
	local x1, x2, x6, x9 = context.x1, context.x2, context.x6, context.x9
	local favorites, save_favs, save_settings = context.favorites, context.save_favs, context.save_settings
	local get_shape = context.get_shape
	local load_module = context.load_module
	local reset_config = context.reset_config
	local is_mobile = context.is_mobile and true or false

	local Lighting = game:GetService("Lighting")

	----------------------------------------------------------------------
	-- performance switches
	----------------------------------------------------------------------

	local PerfOriginals = { Shadows = nil, FX = {}, Materials = {}, Particles = {} }

	local function RestorePerfShadows()
		if PerfOriginals.Shadows ~= nil then
			Lighting.GlobalShadows = PerfOriginals.Shadows
			PerfOriginals.Shadows = nil
		end
	end

	local function ApplyPerfShadows(disable)
		if disable then
			if PerfOriginals.Shadows == nil then
				PerfOriginals.Shadows = Lighting.GlobalShadows
			end
			Lighting.GlobalShadows = false
		else
			RestorePerfShadows()
		end
	end

	local function RestorePerfPostFX()
		for effect, was_enabled in pairs(PerfOriginals.FX) do
			if effect.Parent then
				effect.Enabled = was_enabled
			end
		end
		table.clear(PerfOriginals.FX)
	end

	local function ApplyPerfPostFX(disable)
		if not disable then
			RestorePerfPostFX()
			return
		end
		local function sweep(root)
			for _, effect in ipairs(root:GetDescendants()) do
				if effect:IsA("PostEffect") then
					if PerfOriginals.FX[effect] == nil then
						PerfOriginals.FX[effect] = effect.Enabled
					end
					effect.Enabled = false
				end
			end
		end
		sweep(Lighting)
		local camera = workspace.CurrentCamera
		if camera then
			sweep(camera)
		end
	end

	local function RestorePerfMaterials()
		for part, mat in pairs(PerfOriginals.Materials) do
			if part.Parent then
				part.Material = mat
			end
		end
		table.clear(PerfOriginals.Materials)
	end

	local function ApplyPerfMaterials(disable)
		if disable then
			local plastic = Enum.Material.SmoothPlastic
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") and PerfOriginals.Materials[part] == nil then
					PerfOriginals.Materials[part] = part.Material
					part.Material = plastic
				end
			end
		else
			RestorePerfMaterials()
		end
	end

	local function RestorePerfParticles()
		for p, enabled in pairs(PerfOriginals.Particles) do
			if p.Parent then
				p.Enabled = enabled
			end
		end
		table.clear(PerfOriginals.Particles)
	end

	local function ApplyPerfParticles(disable)
		if disable then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if
					obj:IsA("ParticleEmitter")
					or obj:IsA("Trail")
					or obj:IsA("Beam")
					or obj:IsA("Fire")
					or obj:IsA("Smoke")
					or obj:IsA("Sparkles")
				then
					if PerfOriginals.Particles[obj] == nil then
						PerfOriginals.Particles[obj] = obj.Enabled
					end
					obj.Enabled = false
				end
			end
		else
			RestorePerfParticles()
		end
	end

	local function RestoreAllPerf()
		RestorePerfShadows()
		RestorePerfPostFX()
		RestorePerfMaterials()
		RestorePerfParticles()
	end

	----------------------------------------------------------------------
	-- design system
	----------------------------------------------------------------------

	local E = load_module("UI_elements.lua")
	if type(E) ~= "function" then
		error("Failed to load UI_elements")
	end
	E = E(context)

	local TH, fx = E.TH, E.fx
	local new, corner, stroke, grad, pad, list, label =
		E.new, E.corner, E.stroke, E.grad, E.pad, E.list, E.label
	local CS, CSK, NS, NSK = E.CS, E.CSK, E.NS, E.NSK
	local es, et, eb, eh = E.s, E.t, E.b, E.h

	local U2 = UDim2.new
	local UD = UDim.new
	local V2 = Vector2.new
	local mfloor, mclamp, mmax, mmin, mabs = math.floor, math.clamp, math.max, math.min, math.abs

	-- Glyphs are restricted to the blocks this project already proved render in
	-- Gotham (Latin-1 punctuation, Geometric Shapes, Dingbats).
	local GLYPH = {
		close = "\u{00D7}",
		minus = "\u{2013}",
		plus = "+",
		up = "\u{25B2}",
		down = "\u{25BC}",
		pause = "\u{25AE}\u{25AE}",
		power = "\u{25C9}",
		chevron = "\u{203A}",
		star_on = "\u{2605}",
		star_off = "\u{2606}",
		dot = "\u{00B7}",
	}

	local ai_chat_module
	do
		local ok, mod = pcall(function()
			local f = load_module("ai_chat.lua")
			return f and f(context) or nil
		end)
		ai_chat_module = ok and mod or nil
	end

	----------------------------------------------------------------------
	-- module surface
	----------------------------------------------------------------------

	local x5 = {}
	x5.g = nil
	x5.s, x5.t, x5.b, x5.h = es, et, eb, eh
	x5.fx, x5.theme, x5.elements = fx, TH, E

	local toast_push
	function x5.toast(head, text, kind, dur)
		if toast_push then
			toast_push(head, text, kind, dur)
			return true
		end
		return false
	end

	function x5.st()
		if x5.g and x5.g.Parent then
			if x5.up then
				x5.up()
			end
			return
		end
		if x5.g then
			pcall(function()
				x5.g:Destroy()
			end)
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "G_" .. math.random(100, 999)
		sg.DisplayOrder = 9999
		sg.IgnoreGuiInset = true
		sg.ResetOnSpawn = false
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		pcall(function()
			sg.ClipToDeviceSafeArea = false
		end)
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

	----------------------------------------------------------------------

	function x5.mw(sg)
		local handles = {}
		local function ambient(f, essential)
			local h = fx.every(f, essential)
			handles[#handles + 1] = h
			return h
		end

		------------------------------------------------------------------
		-- metrics
		------------------------------------------------------------------

		local BASE_W = is_mobile and 328 or 404
		local BASE_H = is_mobile and 452 or 566
		local TITLE_H = is_mobile and 46 or 50
		local TABS_H = is_mobile and 32 or 34
		local FOOT_H = is_mobile and 24 or 26
		local MIN_PX = is_mobile and 52 or 58
		local ICON_PX = mfloor(26 * TH.touch_mult)

		local ui_scale, panel_h = 1, BASE_H

		local function viewport()
			local s = sg.AbsoluteSize
			if s.X < 8 or s.Y < 8 then
				local cam = v4.CurrentCamera
				return cam and cam.ViewportSize or V2(1280, 720)
			end
			return s
		end

		local function compute_scale()
			local vp = viewport()
			local s
			if is_mobile then
				s = mclamp(mmin(vp.X / 700, vp.Y / 420), 0.62, 1.05)
			else
				s = mclamp(mmin(vp.X / 1560, vp.Y / 880), 0.8, 1.3)
			end
			return s * mclamp(tonumber(x1.UIScale) or 1, 0.6, 1.6)
		end

		------------------------------------------------------------------
		-- shared state helpers (declared before anything closes over them)
		------------------------------------------------------------------

		local sync = {}
		local function on_sync(f)
			sync[#sync + 1] = f
		end

		local function target_summary()
			local n = x1.Targets and #x1.Targets or 0
			if x1.PI_All then
				return "EVERYONE"
			elseif x1.AnchorSelf then
				return "SELF"
			elseif n == 1 then
				local t = x1.Targets[1]
				return string.upper(t and (t.DisplayName or t.Name) or "NO TARGET")
			elseif n > 1 then
				return n .. " TARGETS"
			end
			return "NO TARGET"
		end

		local function apply_disabled(off)
			if x6.b then
				x6.b.Transparency = off and 1 or x9.c7
				local visual = x6.b:FindFirstChild("Visual")
				if visual then
					visual.Enabled = not off
				end
			end
			for _, d in pairs(x6.a) do
				if d.lv then
					d.lv.MaxForce = off and 0 or x1.k4
				end
				if d.av then
					d.av.MaxTorque = off and 0 or math.huge
				end
			end
		end

		local function update_core_color()
			if x6.b then
				x6.b.Color = x1.k3
				local visual = x6.b:FindFirstChild("Visual")
				if visual then
					local img = visual:FindFirstChildOfClass("ImageLabel")
					if img then
						img.ImageColor3 = x1.k3
					end
				end
			end
			save_settings()
		end

		local function update_core_size(v)
			x1.k2 = Vector3.new(v, v, v)
			if x6.b then
				x6.b.Size = x1.k2
				-- restart the idle pulse so the new size takes effect immediately;
				-- TweenService drops the previous tween on the same property
				v6:Create(
					x6.b,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Size = x1.k2 * 1.2 }
				):Play()
			end
			save_settings()
		end

		------------------------------------------------------------------
		-- panel chrome
		------------------------------------------------------------------

		-- The panel itself is an invisible container and its visible body is a
		-- child. That split is kept from the shadowed design because the close
		-- animation and the minimise morph both drive `surface` on its own.
		local panel = new("Frame", {
			Name = "Panel",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U2(0, BASE_W, 0, BASE_H),
			Active = true,
			ClipsDescendants = false,
			ZIndex = 4,
		}, sg)
		local panel_scale = new("UIScale", { Scale = 0.9 }, panel)

		local surface = new("Frame", {
			BackgroundColor3 = TH.bg1,
			BorderSizePixel = 0,
			Size = U2(1, 0, 1, 0),
			ZIndex = -1,
			Active = false,
		}, panel)
		local panel_corner = corner(surface, TH.radius_panel)

		-- System.lua gates its L-key handler on x6.disable_btn existing and writes
		-- a BackgroundColor3 into it. Hand it an invisible surface so that write is
		-- harmless; the real button is kept in step by the sync pass below.
		x6.disable_btn = new("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			Size = U2(0, 0, 0, 0),
		}, panel)

		local panel_stroke = stroke(surface, TH.line, 1.4, 0.05)
		local edge_grad = grad(
			panel_stroke,
			CS({
				CSK(0, TH.line),
				CSK(0.30, TH.line),
				CSK(0.46, TH.acc),
				CSK(0.54, TH.acc2),
				CSK(0.70, TH.line),
				CSK(1, TH.line),
			}),
			0
		)

		local aurora_clip = new("Frame", {
			BackgroundTransparency = 1,
			Size = U2(1, 0, 1, 0),
			ClipsDescendants = true,
			ZIndex = 0,
			Active = false,
		}, panel)
		local aurora_corner = corner(aurora_clip, TH.radius_panel)

		local aurora_a = new("Frame", {
			BackgroundColor3 = TH.acc,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(0.25, 0, 0.1, 0),
			Size = U2(1.6, 0, 1.1, 0),
			Active = false,
		}, aurora_clip)
		grad(aurora_a, CS({ CSK(0, TH.acc), CSK(1, TH.acc3) }), 25, NS({ NSK(0, 0.55), NSK(0.6, 1), NSK(1, 1) }))

		local aurora_b = new("Frame", {
			BackgroundColor3 = TH.acc2,
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(0.8, 0, 0.92, 0),
			Size = U2(1.4, 0, 1, 0),
			Active = false,
		}, aurora_clip)
		grad(aurora_b, CS({ CSK(0, TH.acc2), CSK(1, TH.acc) }), -35, NS({ NSK(0, 0.6), NSK(0.7, 1), NSK(1, 1) }))

		------------------------------------------------------------------
		-- title bar
		------------------------------------------------------------------

		local titlebar = new("Frame", {
			BackgroundTransparency = 1,
			Size = U2(1, 0, 0, TITLE_H),
			Active = true,
			ZIndex = 3,
		}, panel)
		pad(titlebar, 0, 0, 14, 12)

		local orb = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = V2(0, 0.5),
			Position = U2(0, 0, 0.5, 0),
			Size = U2(0, 24, 0, 24),
			ZIndex = 3,
		}, titlebar)
		local orb_scale = new("UIScale", {}, orb)
		local ring_a = new("Frame", { BackgroundTransparency = 1, Size = U2(1, 0, 1, 0), ZIndex = 3 }, orb)
		corner(ring_a, UD(1, 0))
		local ring_a_stroke = stroke(ring_a, TH.acc, 1.6, 0.1)
		grad(ring_a_stroke, CS({ CSK(0, TH.acc), CSK(0.5, TH.acc2), CSK(1, TH.acc3) }), 0, NS({ NSK(0, 0), NSK(0.55, 0.1), NSK(1, 1) }))
		local ring_b = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(0.5, 0, 0.5, 0),
			Size = U2(0.62, 0, 0.62, 0),
			ZIndex = 3,
		}, orb)
		corner(ring_b, UD(1, 0))
		local ring_b_stroke = stroke(ring_b, TH.acc3, 1.4, 0.25)
		grad(ring_b_stroke, CS({ CSK(0, TH.acc3), CSK(1, TH.acc2) }), 0, NS({ NSK(0, 1), NSK(0.45, 0.05), NSK(1, 1) }))
		local core_dot = new("Frame", {
			BackgroundColor3 = TH.white,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0.5),
			Position = U2(0.5, 0, 0.5, 0),
			Size = U2(0, 6, 0, 6),
			ZIndex = 4,
		}, orb)
		corner(core_dot, UD(1, 0))

		local title = label(titlebar, "PROJECT GRAVITY", is_mobile and 13 or 15, TH.font.black, TH.white, {
			Position = U2(0, 34, 0, is_mobile and 5 or 7),
			Size = U2(1, -170, 0, 18),
			ZIndex = 3,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		local title_grad = grad(
			title,
			CS({ CSK(0, TH.white), CSK(0.45, TH.white), CSK(0.5, TH.acc2), CSK(0.55, TH.white), CSK(1, TH.white) }),
			0
		)

		local subtitle = label(titlebar, "", 10, TH.font.med, TH.tx3, {
			Position = U2(0, 34, 0, is_mobile and 23 or 26),
			Size = U2(1, -170, 0, 14),
			ZIndex = 3,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local btn_row = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = V2(1, 0.5),
			Position = U2(1, 0, 0.5, 0),
			Size = U2(0, ICON_PX * 4 + 20, 0, ICON_PX + 4),
			ZIndex = 4,
		}, titlebar)
		local btn_layout = list(btn_row, 5, Enum.FillDirection.Horizontal)
		btn_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		btn_layout.VerticalAlignment = Enum.VerticalAlignment.Center

		------------------------------------------------------------------
		-- tab strip
		------------------------------------------------------------------

		local TABS = { "CORE", "SHAPES", "TARGET", "TUNING", "SYSTEM" }
		local TAB_N = #TABS

		local tabstrip = new("Frame", {
			BackgroundTransparency = 1,
			Position = U2(0, 12, 0, TITLE_H - 4),
			Size = U2(1, -24, 0, TABS_H - 6),
			ZIndex = 3,
		}, panel)

		local tab_bed = new("Frame", {
			BackgroundColor3 = TH.bg0,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Size = U2(1, 0, 1, 0),
			ZIndex = 3,
		}, tabstrip)
		corner(tab_bed, UD(1, 0))
		stroke(tab_bed, TH.line, 1, 0.55)

		local tab_pill = new("Frame", {
			BackgroundColor3 = TH.acc,
			BorderSizePixel = 0,
			Position = U2(0, 3, 0, 3),
			Size = U2(1 / TAB_N, -6, 1, -6),
			ZIndex = 3,
		}, tab_bed)
		corner(tab_pill, UD(1, 0))
		grad(tab_pill, TH.accent_seq(), 8)
		local pill_stroke = stroke(tab_pill, TH.acc2, 1, 0.35)

		local tab_labels = {}

		------------------------------------------------------------------
		-- body + footer
		------------------------------------------------------------------

		local body = new("Frame", {
			BackgroundTransparency = 1,
			Position = U2(0, 0, 0, TITLE_H + TABS_H),
			Size = U2(1, 0, 1, -(TITLE_H + TABS_H + FOOT_H)),
			ClipsDescendants = true,
			ZIndex = 3,
		}, panel)

		local footer = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = V2(0, 1),
			Position = U2(0, 0, 1, 0),
			Size = U2(1, 0, 0, FOOT_H),
			ZIndex = 3,
		}, panel)
		pad(footer, 0, 4, 14, 14)

		local foot_rule = new("Frame", {
			BackgroundColor3 = TH.line,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, 1),
			ZIndex = 3,
		}, footer)
		grad(
			foot_rule,
			CS({ CSK(0, TH.line), CSK(0.5, TH.acc), CSK(1, TH.line) }),
			0,
			NS({ NSK(0, 1), NSK(0.5, 0.4), NSK(1, 1) })
		)

		local foot_left = label(footer, "", 9, TH.font.med, TH.tx3, {
			Position = U2(0, 0, 0, 3),
			Size = U2(0.62, 0, 1, -3),
			ZIndex = 3,
		})
		local foot_right = label(footer, "", 9, TH.font.bold, TH.tx3, {
			Position = U2(0.62, 0, 0, 3),
			Size = U2(0.38, 0, 1, -3),
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
		})

		------------------------------------------------------------------
		-- pages
		------------------------------------------------------------------

		local pages, page_built = {}, {}
		local active_tab = 0

		local function make_page(i)
			local sf = new("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = U2(1, 0, 1, 0),
				CanvasSize = U2(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = TH.acc,
				ScrollBarImageTransparency = 0.45,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
				Visible = false,
				ZIndex = 3,
			}, body)
			pad(sf, 10, 18, 14, 14)
			list(sf, 5)
			pages[i] = sf
			return sf
		end

		local FADE_PROPS = {
			TextLabel = "TextTransparency",
			TextButton = "TextTransparency",
			TextBox = "TextTransparency",
			ImageLabel = "ImageTransparency",
			UIStroke = "Transparency",
		}

		-- one-off reveal: rows fade up in sequence the first time a tab opens.
		-- Budgeted, because a long list would otherwise start a spring per label.
		local function materialize(container, base)
			if fx.level() < 2 then
				return
			end
			local slot, budget = 0, 140
			for _, kid in ipairs(container:GetChildren()) do
				if kid:IsA("GuiObject") then
					local delay = base + slot * 0.028
					slot = slot + 1
					if slot > 14 or budget <= 0 then
						break
					end
					local targets = kid:GetDescendants()
					targets[#targets + 1] = kid
					for _, obj in ipairs(targets) do
						local prop = FADE_PROPS[obj.ClassName]
						if prop == nil and obj:IsA("Frame") then
							prop = "BackgroundTransparency"
						end
						if prop then
							local original = obj[prop]
							if original < 1 then
								obj[prop] = 1
								fx.spring(obj, prop, original, { k = 260, d = 30, delay = delay })
								budget = budget - 1
								if budget <= 0 then
									break
								end
							end
						end
					end
				end
			end
		end

		local build_page

		local function select_tab(i, instant)
			if i == active_tab then
				return
			end
			local previous = active_tab
			active_tab = i

			fx.to(tab_pill, "Position", U2((i - 1) / TAB_N, 3, 0, 3), "pop")
			fx.punch(pill_stroke, "Thickness", 2.4, 1, "bounce")
			for j = 1, TAB_N do
				fx.to(tab_labels[j], "TextColor3", j == i and TH.white or TH.tx3, "snap")
			end

			if previous > 0 and pages[previous] then
				local old = pages[previous]
				fx.to(old, "Position", U2(0, previous < i and -24 or 24, 0, 0), "flow")
				task.delay(0.13, function()
					if active_tab ~= previous and old.Parent then
						old.Visible = false
					end
				end)
			end

			local page = pages[i] or make_page(i)
			local fresh = not page_built[i]
			if fresh then
				page_built[i] = true
				build_page(i, page)
			end
			page.Visible = true
			if instant or previous == 0 then
				fx.set(page, "Position", U2(0, 0, 0, 0))
			else
				fx.set(page, "Position", U2(0, previous < i and 28 or -28, 0, 0))
				fx.to(page, "Position", U2(0, 0, 0, 0), "pop")
			end
			if fresh then
				materialize(page, instant and 0.2 or 0.04)
			end
		end

		for i = 1, TAB_N do
			local b = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Position = U2((i - 1) / TAB_N, 0, 0, 0),
				Size = U2(1 / TAB_N, 0, 1, 0),
				ZIndex = 4,
			}, tab_bed)
			tab_labels[i] = label(b, TABS[i], is_mobile and 10 or 11, TH.font.bold, TH.tx3, {
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex = 4,
			})
			b.MouseButton1Click:Connect(function()
				select_tab(i)
			end)
			if not is_mobile then
				b.MouseEnter:Connect(function()
					if active_tab ~= i then
						fx.to(tab_labels[i], "TextColor3", TH.tx1, "snap")
					end
				end)
				b.MouseLeave:Connect(function()
					if active_tab ~= i then
						fx.to(tab_labels[i], "TextColor3", TH.tx3, "flow")
					end
				end)
			end
		end

		------------------------------------------------------------------
		-- toasts
		------------------------------------------------------------------

		local toast_host = new("Frame", {
			Name = "Toasts",
			BackgroundTransparency = 1,
			AnchorPoint = V2(1, 1),
			Position = U2(1, -16, 1, -16),
			Size = U2(0, is_mobile and 214 or 262, 0, 320),
			ZIndex = 20,
		}, sg)
		local toast_layout = list(toast_host, 8)
		toast_layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		toast_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

		local TOAST_TINT = { info = TH.acc2, ok = TH.ok, warn = TH.warn, bad = TH.bad }
		local toast_live = 0

		toast_push = function(head, text, kind, dur)
			if toast_live > 4 then
				return
			end
			toast_live = toast_live + 1
			local tint = TOAST_TINT[kind or "info"] or TH.acc2

			-- The list layout owns the position of its children, so the card that
			-- actually slides is one level in.
			local item = new("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 20,
			}, toast_host)

			local card = new("Frame", {
				BackgroundColor3 = TH.bg2,
				BorderSizePixel = 0,
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 20,
			}, item)
			corner(card, 10)
			stroke(card, TH.line, 1, 0.1)
			pad(card, 9, 9, 14, 12)
			local card_scale = new("UIScale", { Scale = 0.85 }, card)

			-- scale-height sidebar: AutomaticSize ignores it, so no feedback loop
			local rail = new("Frame", {
				BackgroundColor3 = tint,
				BorderSizePixel = 0,
				Position = U2(0, -9, 0, 2),
				Size = U2(0, 3, 1, -4),
				ZIndex = 21,
			}, card)
			corner(rail, UD(1, 0))

			label(card, string.upper(head or "SYSTEM"), 10, TH.font.bold, tint, {
				Size = U2(1, 0, 0, 13),
				ZIndex = 21,
			})
			label(card, text or "", 11, TH.font.med, TH.tx2, {
				Position = U2(0, 0, 0, 15),
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				LineHeight = 1.12,
				ZIndex = 21,
			})

			fx.set(card, "Position", U2(0, 46, 0, 0))
			fx.to(card, "Position", U2(0, 0, 0, 0), "bounce")
			fx.to(card_scale, "Scale", 1, "bounce")
			fx.spring(rail, "BackgroundTransparency", 0.85, { k = 1.2, d = 2.4 })

			task.delay(dur or 3.2, function()
				if not item.Parent then
					return
				end
				fx.to(card, "Position", U2(0, 64, 0, 0), "flow")
				fx.spring(card_scale, "Scale", 0.8, {
					k = 300,
					d = 30,
					done = function()
						toast_live = mmax(0, toast_live - 1)
						item:Destroy()
					end,
				})
			end)
		end

		------------------------------------------------------------------
		-- heads-up display
		------------------------------------------------------------------

		local hud = new("Frame", {
			Name = "StatusHUD",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = V2(0.5, 0),
			Position = U2(0.5, 0, 0, 14),
			Size = U2(0, is_mobile and 244 or 300, 0, is_mobile and 30 or 34),
			Visible = x1.ShowHUD ~= false,
			ZIndex = 6,
		}, sg)
		local hud_scale = new("UIScale", {}, hud)
		local hud_surface = new("Frame", {
			BackgroundColor3 = TH.bg1,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Size = U2(1, 0, 1, 0),
			ZIndex = -1,
			Active = false,
		}, hud)
		corner(hud_surface, UD(1, 0))
		stroke(hud_surface, TH.line, 1, 0.1)

		local hud_dot = new("Frame", {
			BackgroundColor3 = TH.ok,
			BorderSizePixel = 0,
			AnchorPoint = V2(0, 0.5),
			Position = U2(0, 13, 0.5, 0),
			Size = U2(0, 8, 0, 8),
			ZIndex = 7,
		}, hud)
		corner(hud_dot, UD(1, 0))
		local hud_halo_stroke = stroke(hud_dot, TH.ok, 1.5, 0.45)

		local hud_state = label(hud, "ACTIVE", 11, TH.font.black, TH.ok, {
			Position = U2(0, 28, 0, 0),
			Size = U2(0, 60, 1, 0),
			ZIndex = 7,
		})
		local hud_target = label(hud, "NO TARGET", 11, TH.font.bold, TH.tx2, {
			Position = U2(0, 90, 0, 0),
			Size = U2(1, -166, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 7,
		})
		local hud_parts = label(hud, "0 PARTS", 10, TH.font.bold, TH.acc2, {
			AnchorPoint = V2(1, 0),
			Position = U2(1, -14, 0, 0),
			Size = U2(0, 68, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 7,
		})

		------------------------------------------------------------------
		-- floating action dock
		------------------------------------------------------------------

		local dock, dock_scale = nil, nil
		local dock_hold, dock_pause_api, dock_power_api = 0, nil, nil

		local function build_dock()
			-- Bare glyphs told nobody anything, least of all on a phone where
			-- there is no hover tooltip to fall back on. Every control now carries
			-- its own caption and the hold-to-repeat ones say so.
			local slots = 6
			local DOCK_W = is_mobile and 116 or 106
			local BTN_H = is_mobile and 38 or 36
			local PAD = 8
			local GRIP_H = 14
			local gap = 5
			local height = PAD * 2 + GRIP_H + slots * BTN_H + (slots - 1) * gap

			-- Positioned in offsets, not scale, because the drag handler works in
			-- offsets: mixing the two makes the dock jump on the first touch.
			local vpd = viewport()
			dock = new("Frame", {
				Name = "Dock",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = U2(0, 16, 0, mmax(8, mfloor(vpd.Y * 0.5 - height * ui_scale * 0.5))),
				Size = U2(0, DOCK_W, 0, height),
				Active = true,
				ZIndex = 8,
			}, sg)
			dock_scale = new("UIScale", { Scale = 0.85 }, dock)
			fx.to(dock_scale, "Scale", ui_scale, "bounce")

			local dock_surface = new("Frame", {
				BackgroundColor3 = TH.bg1,
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				Size = U2(1, 0, 1, 0),
				ZIndex = -1,
				Active = false,
			}, dock)
			corner(dock_surface, 16)
			stroke(dock_surface, TH.line, 1, 0.1)

			-- the only part of the dock that is not a button, so it doubles as the
			-- drag handle and looks like one
			local grip = new("Frame", {
				BackgroundColor3 = TH.line2,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				AnchorPoint = V2(0.5, 0),
				Position = U2(0.5, 0, 0, PAD),
				Size = U2(0, 28, 0, 4),
				ZIndex = 9,
				Active = false,
			}, dock)
			corner(grip, UD(1, 0))

			-- the buttons live one level in so the padding and list layout stay
			-- off the draggable dock frame itself
			local rack = new("Frame", {
				BackgroundTransparency = 1,
				Position = U2(0, PAD, 0, PAD + GRIP_H),
				Size = U2(1, -PAD * 2, 1, -(PAD * 2 + GRIP_H)),
				ZIndex = 9,
			}, dock)
			list(rack, gap)

			local function place()
				local cam = v4.CurrentCamera
				if not cam or not context.x4 then
					return
				end
				local vp = cam.ViewportSize
				local ray = cam:ViewportPointToRay(vp.X / 2, vp.Y / 2)
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Exclude
				rp.FilterDescendantsInstances = { v8.Character }
				local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, rp)
				context.x4.f4(res and res.Position or (ray.Origin + ray.Direction * 30))
			end

			local defs = {
				{ glyph = GLYPH.plus, caption = "PLACE", color = TH.acc2, action = place },
				{
					glyph = GLYPH.close,
					caption = "CLEAR",
					color = TH.bad,
					action = function()
						if not context.x4 then
							return
						end
						if context.x4.clean_physics then
							context.x4.clean_physics()
						elseif context.x4.f5 then
							context.x4.f5()
						end
					end,
				},
				{ glyph = GLYPH.up, caption = "RAISE", color = TH.tx1, hold = 1 },
				{ glyph = GLYPH.down, caption = "LOWER", color = TH.tx1, hold = -1 },
				{ glyph = GLYPH.pause, caption = "PAUSE", color = TH.warn, pause = true, action = function()
					x1.Paused = not x1.Paused
				end },
				{ glyph = GLYPH.power, caption = "ONLINE", color = TH.ok, power = true, action = function()
					x1.Disabled = not x1.Disabled
					apply_disabled(x1.Disabled)
					save_settings()
				end },
			}

			local function dock_button(def)
				local wrap = new("Frame", {
					BackgroundTransparency = 1,
					Size = U2(1, 0, 0, BTN_H),
					ZIndex = 10,
				}, rack)
				local b = new("TextButton", {
					BackgroundColor3 = TH.bg2,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Size = U2(1, 0, 1, 0),
					Text = "",
					ClipsDescendants = true,
					ZIndex = 10,
				}, wrap)
				corner(b, 10)
				local bs = stroke(b, TH.line, 1, 0.2)
				local sc = new("UIScale", {}, b)

				local gl = label(b, def.glyph, mfloor(BTN_H * 0.38), TH.font.bold, def.color, {
					Position = U2(0, 2, 0, 0),
					Size = U2(0, 24, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 11,
				})
				local cap = label(b, def.caption, is_mobile and 10 or 9, TH.font.black, TH.tx2, {
					Position = U2(0, 28, 0, 0),
					Size = U2(1, -32, 1, 0),
					ZIndex = 11,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				if def.hold then
					cap.Size = U2(1, -66, 1, 0)
					label(b, "HOLD", 8, TH.font.med, TH.tx3, {
						AnchorPoint = V2(1, 0.5),
						Position = U2(1, -8, 0.5, 0),
						Size = U2(0, 30, 0, 12),
						TextXAlignment = Enum.TextXAlignment.Right,
						ZIndex = 11,
					})
				end

				local hovered = false
				E.interactive(b, {
					scale = sc,
					lift = 1.05,
					press = 0.94,
					ripple_color = def.color,
					paint = function(hover)
						hovered = hover
						fx.to(b, "BackgroundColor3", hover and TH.bg4 or TH.bg2, "snap")
						fx.to(bs, "Color", hover and def.color or TH.line, "snap")
						fx.to(cap, "TextColor3", hover and TH.white or TH.tx2, "snap")
					end,
				})
				if def.action then
					b.MouseButton1Click:Connect(function()
						def.action()
					end)
				end
				return {
					frame = wrap,
					button = b,
					glyph = gl,
					caption = cap,
					stroke = bs,
					scale = sc,
					-- the sync pass must not fight the hover tint for the stroke
					is_hovered = function()
						return hovered
					end,
				}
			end

			for _, def in ipairs(defs) do
				local api = dock_button(def)
				if def.pause then
					dock_pause_api = api
				elseif def.power then
					dock_power_api = api
				end
				if def.hold then
					local b = api.button
					b.InputBegan:Connect(function(io)
						if E.is_press(io) then
							dock_hold = def.hold
						end
					end)
					b.InputEnded:Connect(function(io)
						if E.is_press(io) then
							dock_hold = 0
						end
					end)
					b.MouseLeave:Connect(function()
						dock_hold = 0
					end)
				end
			end

			local dragging, grab = false, V2(0, 0)
			dock.InputBegan:Connect(function(io)
				if E.is_press(io) then
					dragging = true
					grab = V2(io.Position.X, io.Position.Y) - dock.AbsolutePosition
				end
			end)
			dock.InputEnded:Connect(function(io)
				if E.is_press(io) then
					dragging = false
				end
			end)
			table.insert(
				x6.c,
				v1.InputChanged:Connect(function(io)
					if dragging and E.is_move(io) then
						local vp = viewport()
						local size = dock.AbsoluteSize
						-- direct, like the panel: a spring here just lags the finger
						fx.set(dock, "Position", U2(
							0,
							mclamp(io.Position.X - grab.X, 4, mmax(4, vp.X - size.X - 4)),
							0,
							mclamp(io.Position.Y - grab.Y, 4, mmax(4, vp.Y - size.Y - 4))
						))
					end
				end)
			)

			on_sync(function()
				if dock_pause_api then
					local paused = x1.Paused and true or false
					dock_pause_api.caption.Text = paused and "RESUME" or "PAUSE"
					fx.to(dock_pause_api.glyph, "TextColor3", paused and TH.white or TH.warn, "snap")
					if not dock_pause_api.is_hovered() then
						fx.to(dock_pause_api.stroke, "Color", paused and TH.warn or TH.line, "snap")
					end
				end
				if dock_power_api then
					local off = x1.Disabled and true or false
					dock_power_api.caption.Text = off and "OFFLINE" or "ONLINE"
					fx.to(dock_power_api.glyph, "TextColor3", off and TH.bad or TH.ok, "snap")
					if not dock_power_api.is_hovered() then
						fx.to(dock_power_api.stroke, "Color", off and TH.bad or TH.line, "snap")
					end
				end
			end)
		end

		local function set_dock(on)
			on = on and true or false
			if on and not dock then
				build_dock()
			end
			if dock then
				dock.Visible = on
			end
		end

		------------------------------------------------------------------
		-- pooled list rendering
		------------------------------------------------------------------
		-- Filtering never destroys rows any more; they are created once and
		-- rebound, so typing in a search box costs nothing.

		local function pooled(host, factory)
			local rows, high = {}, 0
			return function(items)
				local n = #items
				for i = 1, n do
					local row = rows[i]
					if not row then
						row = factory(host)
						rows[i] = row
					end
					row.frame.LayoutOrder = i
					row.frame.Visible = true
					row.bind(items[i], i)
				end
				for i = n + 1, high do
					if rows[i] then
						rows[i].frame.Visible = false
					end
				end
				high = mmax(high, n)
				return n
			end
		end

		------------------------------------------------------------------
		-- page content
		------------------------------------------------------------------

		local shape_controls_host, rebuild_shape_controls
		local render_shapes, render_players
		local shape_card_name
		local select_shape_tab = function()
			select_tab(2)
		end

		-- CORE ---------------------------------------------------------
		local function build_core(page)
			eh(page, "Active Formation")

			local card = new("TextButton", {
				BackgroundColor3 = TH.bg2,
				BorderSizePixel = 0,
				Size = U2(1, 0, 0, is_mobile and 56 or 62),
				Text = "",
				AutoButtonColor = false,
				ClipsDescendants = true,
			}, page)
			corner(card, TH.radius_card)
			local card_stroke = stroke(card, TH.line, 1, 0.05)
			grad(card, CS({ CSK(0, TH.bg2), CSK(1, TH.bg3) }), 90)

			local pip = new("Frame", {
				BackgroundColor3 = TH.acc,
				BorderSizePixel = 0,
				AnchorPoint = V2(0, 0.5),
				Position = U2(0, 12, 0.5, 0),
				Size = U2(0, 4, 0, is_mobile and 30 or 34),
				ZIndex = 2,
			}, card)
			corner(pip, UD(1, 0))
			grad(pip, TH.accent_seq(), 90)

			shape_card_name = label(card, string.upper(x1.k6), is_mobile and 13 or 14, TH.font.black, TH.white, {
				Position = U2(0, 26, 0, is_mobile and 10 or 12),
				Size = U2(1, -70, 0, 18),
				ZIndex = 2,
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			label(card, "browse all formations", 10, TH.font.med, TH.tx3, {
				Position = U2(0, 26, 0, is_mobile and 29 or 33),
				Size = U2(1, -70, 0, 14),
				ZIndex = 2,
			})
			local chev = label(card, GLYPH.chevron, 20, TH.font.bold, TH.tx3, {
				AnchorPoint = V2(1, 0.5),
				Position = U2(1, -14, 0.5, 0),
				Size = U2(0, 14, 0, 24),
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex = 2,
			})

			E.interactive(card, {
				ripple_color = TH.acc,
				paint = function(hover)
					fx.to(card_stroke, "Color", hover and TH.acc or TH.line, "snap")
					fx.to(card_stroke, "Thickness", hover and 1.6 or 1, "snap")
					fx.to(chev, "Position", U2(1, hover and -9 or -14, 0.5, 0), "pop")
					fx.to(chev, "TextColor3", hover and TH.acc2 or TH.tx3, "snap")
				end,
			})
			card.MouseButton1Click:Connect(select_shape_tab)

			eh(page, "Engine")

			local _, pow_api = E.button(page, "GRAVITY ONLINE", function()
				x1.Disabled = not x1.Disabled
				apply_disabled(x1.Disabled)
				save_settings()
			end, "ok", is_mobile and 40 or 42)

			local _, pause_api = E.button(page, "PAUSE PHYSICS", function()
				x1.Paused = not x1.Paused
				save_settings()
			end, "ghost", is_mobile and 36 or 38)

			local launch_btn, launch_api = E.button(page, "FORCE LAUNCH", function()
				x1.IsLaunching = not x1.IsLaunching
			end, "danger", is_mobile and 36 or 38)
			launch_btn.Visible = false

			local last_off, last_paused, last_launch = nil, nil, nil
			on_sync(function()
				local off = x1.Disabled and true or false
				if off ~= last_off then
					last_off = off
					pow_api.set_text(off and "GRAVITY OFFLINE" or "GRAVITY ONLINE")
					pow_api.set_variant(off and "danger" or "ok")
				end
				local paused = x1.Paused and true or false
				if paused ~= last_paused then
					last_paused = paused
					pause_api.set_text(paused and "RESUME PHYSICS" or "PAUSE PHYSICS")
					pause_api.set_variant(paused and "accent" or "ghost")
				end
				local show = (x1.k6 == "Slingshot" and x1.SlingshotManual) and true or false
				if launch_btn.Visible ~= show then
					launch_btn.Visible = show
				end
				if show and x1.IsLaunching ~= last_launch then
					last_launch = x1.IsLaunching
					launch_api.set_text(x1.IsLaunching and "RESET SYSTEM" or "FORCE LAUNCH")
					launch_api.set_variant(x1.IsLaunching and "accent" or "danger")
				end
			end)

			eh(page, "Behaviour")

			local grp = E.card(page, 6)

			et(grp, "Simplified Interface", x1.SimpleMode, function(v)
				x1.SimpleMode = v
				save_settings()
				if x5.up then
					x5.up()
				end
			end, "Hides the deeper physics options and formation parameters.")

			et(grp, "Show Status HUD", x1.ShowHUD ~= false, function(v)
				x1.ShowHUD = v
				hud.Visible = v
				save_settings()
			end)

			et(grp, "Preserve Collisions", x1.PreserveCollisions, function(v)
				x1.PreserveCollisions = v
				for part, data in pairs(x6.a) do
					if part and part.Parent then
						part.CanCollide = v and data.original_can_collide or false
					end
				end
				save_settings()
			end)

			local _, anti_api = et(grp, "Anti-Fling", x1.AntiFling, function(v)
				x1.AntiFling = v
				save_settings()
			end)
			local _, smooth_api = et(grp, "Force Smooth (Lags)", x1["Force Smooth (Lags)"], function(v)
				x1["Force Smooth (Lags)"] = v
				save_settings()
			end, "Updates every part every frame. Looks perfect, costs frames.")
			local _, lift_api = et(grp, "Realistic Liftoff", x1["Realistic Liftoff"], function(v)
				x1["Realistic Liftoff"] = v
				save_settings()
			end)
			local _, sling_api = et(grp, "Manual Slingshot", x1.SlingshotManual, function(v)
				x1.SlingshotManual = v
				save_settings()
			end, "Hold the charge until you press Force Launch instead of firing on a timer.")

			local last_advanced, last_sling = nil, nil
			on_sync(function()
				local advanced = not x1.SimpleMode
				if advanced ~= last_advanced then
					last_advanced = advanced
					anti_api.frame.Visible = advanced
					smooth_api.frame.Visible = advanced
					lift_api.frame.Visible = advanced
				end
				local sling = advanced and x1.k6 == "Slingshot"
				if sling ~= last_sling then
					last_sling = sling
					sling_api.frame.Visible = sling
				end
			end)

			if ai_chat_module and ai_chat_module.toggle then
				local ai_btn = E.button(page, "PROJECT GRAVITY AI", function()
					ai_chat_module.toggle(sg)
				end, "accent", is_mobile and 40 or 42)
				ai_btn.LayoutOrder = 900
			end

			local ctrl_head = eh(page, "Formation Parameters")
			ctrl_head.LayoutOrder = 950
			shape_controls_host = new("Frame", {
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 960,
			}, page)
			list(shape_controls_host, 4)

			rebuild_shape_controls = function()
				if not shape_controls_host or not shape_controls_host.Parent then
					return
				end
				for _, kid in ipairs(shape_controls_host:GetChildren()) do
					if kid:IsA("GuiObject") then
						kid:Destroy()
					end
				end
				local simple = x1.SimpleMode and true or false
				ctrl_head.Visible = not simple
				shape_controls_host.Visible = not simple
				if simple then
					return
				end
				local mod = get_shape(x1.k6)
				local cfg = x1.S[x1.k6]
				if not cfg then
					cfg = {}
					x1.S[x1.k6] = cfg
				end
				if not (mod and mod.Controls) then
					label(shape_controls_host, "This formation has no adjustable parameters.", 10, TH.font.body, TH.tx3, {
						Size = U2(1, 0, 0, 26),
						TextWrapped = true,
					})
					return
				end
				for _, ctrl in ipairs(mod.Controls) do
					local value = cfg[ctrl.Key]
					if ctrl.Type == "Slider" then
						if ctrl.LegacyToggle and type(value) == "boolean" then
							value = value and 2 or 1
							cfg[ctrl.Key] = value
						end
						if value == nil then
							value = ctrl.Default ~= nil and ctrl.Default or ctrl.Min
						end
						local max_val = ctrl.Max
						if not ctrl.ExactMax and string.find(string.lower(ctrl.Name), "speed") then
							max_val = max_val + 300
						end
						if ctrl.Div then
							value = value * ctrl.Div
						end
						value = mclamp(value, ctrl.Min, max_val)
						cfg[ctrl.Key] = ctrl.Div and (value / ctrl.Div) or value
						es(shape_controls_host, ctrl.Name, ctrl.Min, max_val, value, function(v)
							cfg[ctrl.Key] = ctrl.Div and (v / ctrl.Div) or v
						end, ctrl.IntOnly, ctrl.Desc)
					elseif ctrl.Type == "Toggle" then
						if value == nil then
							value = ctrl.Default ~= nil and ctrl.Default or false
						end
						et(shape_controls_host, ctrl.Name, value and true or false, function(v)
							cfg[ctrl.Key] = v
						end, ctrl.Desc)
					end
				end
			end
			rebuild_shape_controls()
		end

		-- SHAPES -------------------------------------------------------
		local function build_shapes(page)
			local all, filtered = {}, {}
			local query = ""

			local function order()
				table.clear(all)
				for name in pairs(x2) do
					all[#all + 1] = name
				end
				table.sort(all, function(a, b)
					local fa, fb = favorites[a] and 1 or 0, favorites[b] and 1 or 0
					if fa ~= fb then
						return fa > fb
					end
					return a < b
				end)
				table.clear(filtered)
				if query ~= "" then
					local needle = string.lower(query)
					for _, name in ipairs(all) do
						if string.find(string.lower(name), needle, 1, true) then
							filtered[#filtered + 1] = name
						end
					end
				else
					table.move(all, 1, #all, 1, filtered)
				end
				return filtered
			end

			E.search(page, "Search formations", function(text)
				query = text
				render_shapes()
			end)

			local count_label = label(page, "", 9, TH.font.med, TH.tx3, {
				Size = U2(1, 0, 0, 16),
			})

			local holder = new("Frame", {
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, page)
			list(holder, 4)

			local function shape_row(parent)
				local frame = new("TextButton", {
					BackgroundColor3 = TH.bg2,
					BorderSizePixel = 0,
					Size = U2(1, 0, 0, is_mobile and 40 or 42),
					Text = "",
					AutoButtonColor = false,
					ClipsDescendants = true,
				}, parent)
				corner(frame, TH.radius_row)
				local row_stroke = stroke(frame, TH.line, 1, 0.45)

				local mark = new("Frame", {
					BackgroundColor3 = TH.acc,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AnchorPoint = V2(0, 0.5),
					Position = U2(0, 8, 0.5, 0),
					Size = U2(0, 3, 0, 18),
					ZIndex = 2,
				}, frame)
				corner(mark, UD(1, 0))

				local name = label(frame, "", is_mobile and 11 or 12, TH.font.bold, TH.tx2, {
					Position = U2(0, 18, 0, 0),
					Size = U2(1, -60, 1, 0),
					ZIndex = 2,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})

				local star = new("TextButton", {
					BackgroundTransparency = 1,
					AnchorPoint = V2(1, 0.5),
					Position = U2(1, -6, 0.5, 0),
					Size = U2(0, 30, 1, 0),
					Text = GLYPH.star_off,
					TextColor3 = TH.tx3,
					TextSize = 14,
					Font = TH.font.bold,
					AutoButtonColor = false,
					ZIndex = 3,
				}, frame)
				local star_scale = new("UIScale", {}, star)

				local current
				local function paint()
					local selected = current == x1.k6
					fx.to(frame, "BackgroundColor3", selected and TH.bg4 or TH.bg2, "flow")
					fx.to(row_stroke, "Color", selected and TH.acc or TH.line, "flow")
					fx.to(row_stroke, "Transparency", selected and 0 or 0.45, "flow")
					fx.to(mark, "BackgroundTransparency", selected and 0 or 1, "flow")
					fx.to(name, "TextColor3", selected and TH.white or TH.tx2, "flow")
				end

				E.interactive(frame, {
					ripple_color = TH.acc,
					paint = function(hover)
						if current ~= x1.k6 then
							fx.to(row_stroke, "Color", hover and TH.line2 or TH.line, "snap")
							fx.to(frame, "BackgroundColor3", hover and TH.bg3 or TH.bg2, "snap")
							fx.to(name, "TextColor3", hover and TH.white or TH.tx2, "snap")
						end
					end,
				})

				frame.MouseButton1Click:Connect(function()
					if not current or current == x1.k6 then
						return
					end
					if not get_shape(current) then
						x5.toast("Formation", "Could not load " .. current, "bad")
						return
					end
					x1.k6 = current
					x6.transition_time = time()
					x6.transition_dur = 1.5
					for _, d in pairs(x6.a) do
						d.trans_vl = d.vl or Vector3.zero
						d.v1, d.v2, d.v3, d.v4, d.v5, d.v6, d.v7, d.v8, d.v9 =
							nil, nil, nil, nil, nil, nil, nil, nil, nil
						d.integral = Vector3.zero
					end
					save_settings()
					if x5.up then
						x5.up()
					end
					x5.toast("Formation", current, "ok", 2)
					select_tab(1)
				end)

				star.MouseButton1Click:Connect(function()
					if not current then
						return
					end
					favorites[current] = (not favorites[current]) or nil
					save_favs()
					fx.punch(star_scale, "Scale", 1.7, 1, "bounce")
					render_shapes()
				end)

				return {
					frame = frame,
					bind = function(item)
						current = item
						name.Text = item
						local fav = favorites[item] and true or false
						star.Text = fav and GLYPH.star_on or GLYPH.star_off
						star.TextColor3 = fav and TH.warn or TH.tx3
						paint()
					end,
				}
			end

			local draw = pooled(holder, shape_row)
			render_shapes = function()
				if not page.Parent then
					return
				end
				local n = draw(order())
				count_label.Text = n .. (n == 1 and " FORMATION" or " FORMATIONS")
			end
			render_shapes()
		end

		-- TARGET -------------------------------------------------------
		local function build_target(page)
			eh(page, "Focus")

			local grp = E.card(page, 6)
			local _, self_api = et(grp, "Anchor To Self", x1.AnchorSelf, function(v)
				x1.AnchorSelf = v
				if v then
					x1.PI_All = false
					table.clear(x1.Targets)
					x1.TgtActive = false
				end
				save_settings()
				if render_players then
					render_players()
				end
			end, "Locks the gravitational centre onto your own character.")

			local _, all_api = et(grp, "Target Everyone", x1.PI_All, function(v)
				x1.PI_All = v
				if v then
					x1.AnchorSelf = false
					table.clear(x1.Targets)
					x1.TgtActive = false
				end
				save_settings()
				if render_players then
					render_players()
				end
			end, "Spreads the formation across every player in the server.")

			on_sync(function()
				self_api.set(x1.AnchorSelf)
				all_api.set(x1.PI_All)
			end)

			eh(page, "Players")

			local clear_btn = E.button(page, "CLEAR TARGETS", function()
				table.clear(x1.Targets)
				x1.TgtActive = false
				save_settings()
				if render_players then
					render_players()
				end
			end, "danger", is_mobile and 32 or 34)
			clear_btn.Visible = false

			local roster, filtered = {}, {}
			local query = ""

			local function collect()
				table.clear(roster)
				for _, pl in ipairs(v2:GetPlayers()) do
					if pl ~= v8 then
						roster[#roster + 1] = pl
					end
				end
				table.sort(roster, function(a, b)
					local sa = table.find(x1.Targets, a) and 1 or 0
					local sb = table.find(x1.Targets, b) and 1 or 0
					if sa ~= sb then
						return sa > sb
					end
					return string.lower(a.DisplayName) < string.lower(b.DisplayName)
				end)
				table.clear(filtered)
				if query ~= "" then
					local needle = string.lower(query)
					for _, pl in ipairs(roster) do
						if
							string.find(string.lower(pl.DisplayName), needle, 1, true)
							or string.find(string.lower(pl.Name), needle, 1, true)
						then
							filtered[#filtered + 1] = pl
						end
					end
				else
					table.move(roster, 1, #roster, 1, filtered)
				end
				return filtered
			end

			E.search(page, "Search players", function(text)
				query = text
				render_players()
			end)

			local empty = label(page, "No other players in this server.", 10, TH.font.body, TH.tx3, {
				Size = U2(1, 0, 0, 30),
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			local holder = new("Frame", {
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, page)
			list(holder, 4)

			local highlight = nil
			local function clear_highlight()
				if highlight then
					pcall(function()
						highlight:Destroy()
					end)
					highlight = nil
				end
			end

			local function player_row(parent)
				local frame = new("TextButton", {
					BackgroundColor3 = TH.bg2,
					BorderSizePixel = 0,
					Size = U2(1, 0, 0, is_mobile and 46 or 48),
					Text = "",
					AutoButtonColor = false,
					ClipsDescendants = true,
				}, parent)
				corner(frame, TH.radius_row)
				local row_stroke = stroke(frame, TH.line, 1, 0.45)

				local avatar = new("ImageLabel", {
					BackgroundColor3 = TH.bg3,
					BorderSizePixel = 0,
					AnchorPoint = V2(0, 0.5),
					Position = U2(0, 8, 0.5, 0),
					Size = U2(0, 32, 0, 32),
					ZIndex = 2,
				}, frame)
				corner(avatar, UD(1, 0))
				local avatar_stroke = stroke(avatar, TH.line, 1.5, 0.2)

				local dname = label(frame, "", 12, TH.font.bold, TH.tx1, {
					Position = U2(0, 48, 0, 8),
					Size = U2(1, -84, 0, 16),
					ZIndex = 2,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				local uname = label(frame, "", 10, TH.font.med, TH.tx3, {
					Position = U2(0, 48, 0, 24),
					Size = U2(1, -84, 0, 14),
					ZIndex = 2,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})

				local pip = new("Frame", {
					BackgroundColor3 = TH.bg4,
					BorderSizePixel = 0,
					AnchorPoint = V2(1, 0.5),
					Position = U2(1, -12, 0.5, 0),
					Size = U2(0, 12, 0, 12),
					ZIndex = 2,
				}, frame)
				corner(pip, UD(1, 0))
				local pip_stroke = stroke(pip, TH.line, 1.5, 0)
				local pip_scale = new("UIScale", {}, pip)

				local who
				local function paint(selected)
					fx.to(pip, "BackgroundColor3", selected and TH.ok or TH.bg4, "flow")
					fx.to(pip_stroke, "Color", selected and TH.ok or TH.line, "flow")
					fx.to(row_stroke, "Color", selected and TH.ok or TH.line, "flow")
					fx.to(row_stroke, "Transparency", selected and 0.1 or 0.45, "flow")
					fx.to(avatar_stroke, "Color", selected and TH.ok or TH.line, "flow")
				end

				E.interactive(frame, {
					ripple_color = TH.ok,
					paint = function(hover)
						fx.to(frame, "BackgroundColor3", hover and TH.bg3 or TH.bg2, "snap")
						if hover and who and who.Character then
							clear_highlight()
							local ok, h = pcall(function()
								local inst = Instance.new("Highlight")
								inst.FillColor = TH.acc2
								inst.OutlineColor = TH.white
								inst.FillTransparency = 0.65
								inst.Parent = who.Character
								return inst
							end)
							highlight = ok and h or nil
						elseif not hover then
							clear_highlight()
						end
					end,
				})

				frame.MouseButton1Click:Connect(function()
					if not who then
						return
					end
					local idx = table.find(x1.Targets, who)
					if idx then
						table.remove(x1.Targets, idx)
					else
						table.insert(x1.Targets, who)
						x1.AnchorSelf = false
						x1.PI_All = false
					end
					x1.TgtActive = #x1.Targets > 0
					fx.punch(pip_scale, "Scale", 1.8, 1, "bounce")
					paint(idx == nil)
					clear_btn.Visible = #x1.Targets > 0
					save_settings()
				end)

				return {
					frame = frame,
					bind = function(item)
						who = item
						dname.Text = item.DisplayName
						uname.Text = "@" .. item.Name
						avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. item.UserId .. "&w=48&h=48"
						paint(table.find(x1.Targets, item) ~= nil)
					end,
				}
			end

			local draw = pooled(holder, player_row)
			render_players = function()
				if not page.Parent then
					return
				end
				local n = draw(collect())
				empty.Visible = n == 0
				clear_btn.Visible = x1.Targets and #x1.Targets > 0
			end
			render_players()

			table.insert(
				x6.c,
				v2.PlayerAdded:Connect(function()
					if render_players then
						render_players()
					end
				end)
			)
			table.insert(
				x6.c,
				v2.PlayerRemoving:Connect(function()
					task.defer(function()
						if render_players then
							render_players()
						end
					end)
				end)
			)
			page.AncestryChanged:Connect(function(_, p)
				if not p then
					clear_highlight()
				end
			end)
		end

		-- TUNING -------------------------------------------------------
		local function build_tuning(page)
			eh(page, "Tracking")
			local trk = E.card(page, 6)
			et(trk, "Predictive Tracking", x1.PredictiveTracking ~= false, function(v)
				x1.PredictiveTracking = v
				save_settings()
			end, "Leads the target's movement so parts stop trailing behind them.")
			es(trk, "Prediction Factor", 0, 500, x1.PredictionFactor or 150, function(v)
				x1.PredictionFactor = v
				save_settings()
			end, false, "How far ahead of the target the formation aims.")

			eh(page, "Solver")
			local slv = E.card(page, 6)
			es(slv, "Damping", 0, 5, x1.Damping, function(v)
				x1.Damping = v
				save_settings()
			end, false, "Bleeds off velocity. Higher is smoother but slower to settle.")
			es(slv, "Integral Gain", 0, 10, x1.Ki, function(v)
				x1.Ki = v
				save_settings()
			end, false, "Drives parts onto their exact target position, fixing sag.")
			es(slv, "Max Speed", 50, 2000, x1.MaxSpeed or 500, function(v)
				x1.MaxSpeed = v
				save_settings()
			end, false, "Velocity ceiling that keeps parts from flinging away.")
			es(slv, "Angular Damping", 0, 1, x1.AngularDamping or 0.5, function(v)
				x1.AngularDamping = v
				save_settings()
			end, false, "Stops parts spinning on their own axis.")
			es(slv, "Vertical Stiffness", 0.1, 5, x1.VerticalStiffness or 1.0, function(v)
				x1.VerticalStiffness = v
				save_settings()
			end, false, "Multiplies vertical pull to fight world gravity. 1.0 is neutral.")
			es(slv, "Smoothing", 0, 1, x1.k8 or 0.8, function(v)
				x1.k8 = v
				save_settings()
			end, false, "Blends each frame's velocity into the last. Lower is snappier.")

			eh(page, "Ownership")
			local own = E.card(page, 6)
			et(own, "Aggressive Claiming", x1.AggressiveClaim, function(v)
				x1.AggressiveClaim = v
				save_settings()
			end, "Forces network ownership by teleporting parts to you. Very loud.")
			et(own, "Void Protection", x1.VoidProtection, function(v)
				x1.VoidProtection = v
				save_settings()
			end, "Ignores targets that have fallen out of the world.")
			es(own, "Claim Radius", 200, 8000, x1.k1 or 2000, function(v)
				x1.k1 = v
				save_settings()
			end, true, "Parts further than this from the centre are left alone.")

			eh(page, "Core")
			local core_card = E.card(page, 8)
			E.color(core_card, x1.k3, function(c)
				x1.k3 = c
				update_core_color()
			end)
			es(core_card, "Core Size", 1, 40, (x1.k2 and x1.k2.X) or 5, update_core_size, false)
		end

		-- SYSTEM -------------------------------------------------------
		local function build_system(page)
			eh(page, "Interface")
			local iface = E.card(page, 6)

			es(iface, "UI Scale", 0.6, 1.6, tonumber(x1.UIScale) or 1, function(v)
				x1.UIScale = v
				if x5.relayout then
					x5.relayout()
				end
			end, false)

			local fx_index = 2
			if (x1.FX or 2) == 0 then
				fx_index = 1
			elseif x1.FXAuto == false then
				fx_index = 3
			end
			E.segmented(iface, { "LOW FX", "BALANCED", "MAX FX" }, fx_index, function(i)
				if i == 1 then
					x1.FX, x1.FXAuto = 0, false
				elseif i == 2 then
					x1.FX, x1.FXAuto = 2, true
				else
					x1.FX, x1.FXAuto = 2, false
				end
				save_settings()
			end)
			label(iface, "Balanced sheds effects automatically when frames get tight.", 10, TH.font.body, TH.tx3, {
				Size = U2(1, 0, 0, 24),
				TextWrapped = true,
			})

			et(iface, "Action Dock", x1.ShowDock and true or false, function(v)
				x1.ShowDock = v
				set_dock(v)
				save_settings()
			end, "A floating cluster of place, clear, raise and lower controls.")

			eh(page, "Game Performance")
			local perf = E.card(page, 6)
			et(perf, "Disable Shadows", x1.Perf_DisableShadows, function(v)
				x1.Perf_DisableShadows = v
				ApplyPerfShadows(v)
				save_settings()
			end, "Turns off world shadows. Usually the single biggest FPS win.")
			et(perf, "Disable Post-FX", x1.Perf_DisablePostFX, function(v)
				x1.Perf_DisablePostFX = v
				ApplyPerfPostFX(v)
				save_settings()
			end, "Kills bloom, blur, sun rays and colour correction.")
			et(perf, "Potato Materials", x1.Perf_PotatoMaterials, function(v)
				x1.Perf_PotatoMaterials = v
				ApplyPerfMaterials(v)
				save_settings()
			end, "Forces every part in the world to SmoothPlastic.")
			et(perf, "Hide Particles", x1.Perf_HideParticles, function(v)
				x1.Perf_HideParticles = v
				ApplyPerfParticles(v)
				save_settings()
			end, "Hides fire, smoke, beams, trails and emitters.")
			es(perf, "FPS Cap", 30, 360, mclamp(tonumber(x1.FPSCap) or 240, 30, 360), function(v)
				x1.FPSCap = v
				if setfpscap then
					pcall(setfpscap, v >= 360 and 0 or v)
				end
				save_settings()
			end, true, "360 removes the cap entirely.")
			es(perf, "Physics Stride", 1, 20, x1.k7 or 4, function(v)
				x1.k7 = v
				save_settings()
			end, true, "Frames between updates for each part. Higher is cheaper.")

			eh(page, "Controls")
			local keys = E.card(page, 8)
			local KEYS = {
				{ "E", "Place the gravitational core at your cursor" },
				{ "Q", "Release every claimed part and reset" },
				{ "P", "Pause and resume physics" },
				{ "L", "Disable and enable the engine" },
				{ "R CTRL", "Hide or show this interface" },
			}
			for _, entry in ipairs(KEYS) do
				local wide = #entry[1] > 2
				local r = new("Frame", { BackgroundTransparency = 1, Size = U2(1, 0, 0, 24) }, keys)
				local cap = new("Frame", {
					BackgroundColor3 = TH.bg3,
					BorderSizePixel = 0,
					AnchorPoint = V2(0, 0.5),
					Position = U2(0, 0, 0.5, 0),
					Size = U2(0, wide and 54 or 26, 0, 18),
				}, r)
				corner(cap, 5)
				stroke(cap, TH.line, 1, 0.2)
				label(cap, entry[1], 9, TH.font.bold, TH.acc2, { TextXAlignment = Enum.TextXAlignment.Center })
				label(r, entry[2], 10, TH.font.body, TH.tx3, {
					Position = U2(0, wide and 64 or 36, 0, 0),
					Size = U2(1, wide and -64 or -36, 1, 0),
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
			end

			eh(page, "Community")
			E.button(page, "COPY DISCORD INVITE", function()
				local copied = false
				pcall(function()
					if setclipboard then
						setclipboard("https://discord.gg/9xYyyYuKap")
						copied = true
					elseif toclipboard then
						toclipboard("https://discord.gg/9xYyyYuKap")
						copied = true
					end
				end)
				x5.toast(
					"Discord",
					copied and "Invite copied to clipboard" or "Clipboard is unavailable here",
					copied and "ok" or "warn"
				)
			end, "quiet", is_mobile and 34 or 36)

			eh(page, "Danger Zone")
			E.button(page, "RESET ALL SETTINGS", function()
				x5.confirm(
					"RESET EVERYTHING?",
					"Every global option and every formation parameter returns to its default. This cannot be undone.",
					function()
						if not reset_config then
							return
						end
						reset_config()
						save_settings()
						update_core_color()
						if x5.up then
							x5.up()
						end
						x5.toast("Settings", "Restored to defaults", "ok")
					end
				)
			end, "danger", is_mobile and 38 or 40)
		end

		build_page = function(i, page)
			if i == 1 then
				build_core(page)
			elseif i == 2 then
				build_shapes(page)
			elseif i == 3 then
				build_target(page)
			elseif i == 4 then
				build_tuning(page)
			else
				build_system(page)
			end
		end

		------------------------------------------------------------------
		-- confirmation modal
		------------------------------------------------------------------

		function x5.confirm(head, body_text, on_yes)
			if x6.reset_confirm then
				pcall(function()
					x6.reset_confirm:Destroy()
				end)
				x6.reset_confirm = nil
			end

			local veil = new("TextButton", {
				Name = "Modal",
				BackgroundColor3 = TH.black,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = U2(1, 0, 1, 0),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 30,
			}, sg)
			x6.reset_confirm = veil
			fx.to(veil, "BackgroundTransparency", 0.5, "flow")

			local box = new("Frame", {
				BackgroundColor3 = TH.bg1,
				BorderSizePixel = 0,
				AnchorPoint = V2(0.5, 0.5),
				Position = U2(0.5, 0, 0.5, 0),
				Size = U2(0, is_mobile and 284 or 334, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Active = true,
				ZIndex = 31,
			}, veil)
			corner(box, 14)
			stroke(box, TH.bad, 1.2, 0.3)
			pad(box, 18, 16, 18, 18)
			local box_scale = new("UIScale", { Scale = 0.88 }, box)
			fx.to(box_scale, "Scale", 1, "bounce")
			list(box, 10)

			label(box, head, 15, TH.font.black, TH.white, { Size = U2(1, 0, 0, 20), ZIndex = 31 })
			label(box, body_text, 11, TH.font.body, TH.tx2, {
				Size = U2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				LineHeight = 1.15,
				ZIndex = 31,
			})

			local buttons = new("Frame", { BackgroundTransparency = 1, Size = U2(1, 0, 0, 38), ZIndex = 31 }, box)

			local closing = false
			local function close()
				if closing then
					return
				end
				closing = true
				fx.to(veil, "BackgroundTransparency", 1, "flow")
				fx.spring(box_scale, "Scale", 0.88, {
					k = 320,
					d = 30,
					done = function()
						if x6.reset_confirm == veil then
							x6.reset_confirm = nil
						end
						veil:Destroy()
					end,
				})
			end

			local cancel = E.button(buttons, "CANCEL", close, "ghost", 38)
			cancel.Size = U2(0.5, -5, 0, 38)
			cancel.ZIndex = 31
			local yes = E.button(buttons, "CONFIRM", function()
				close()
				if on_yes then
					on_yes()
				end
			end, "danger", 38)
			yes.Size = U2(0.5, -5, 0, 38)
			yes.Position = U2(0.5, 5, 0, 0)
			yes.ZIndex = 31

			veil.MouseButton1Click:Connect(close)
		end

		------------------------------------------------------------------
		-- title bar buttons + minimise
		------------------------------------------------------------------

		local minimized = false
		local set_minimized

		local expand_hit = new("TextButton", {
			BackgroundTransparency = 1,
			Size = U2(1, 0, 1, 0),
			Text = "",
			AutoButtonColor = false,
			Visible = false,
			ZIndex = 12,
		}, panel)

		local close_btn = E.icon(btn_row, GLYPH.close, function()
			fx.to(hud_surface, "BackgroundTransparency", 1, "flow")
			fx.to(surface, "BackgroundTransparency", 1, "flow")
			fx.spring(panel_scale, "Scale", ui_scale * 0.82, {
				k = 320,
				d = 26,
				done = function()
					RestoreAllPerf()
					if context.x4 and context.x4.f5 then
						pcall(context.x4.f5)
					end
					if sg.Parent then
						sg:Destroy()
					end
				end,
			})
		end, TH.bad)
		close_btn.LayoutOrder = 4

		local min_btn, min_api = E.icon(btn_row, GLYPH.minus, function()
			set_minimized(not minimized)
		end, TH.ok)
		min_btn.LayoutOrder = 3

		local help_btn = E.icon(btn_row, "?", function()
			select_tab(5)
		end, TH.acc2)
		help_btn.LayoutOrder = 2

		local ai_btn
		if ai_chat_module and ai_chat_module.toggle then
			local b, api = E.icon(btn_row, "AI", function()
				ai_chat_module.toggle(sg)
			end, TH.acc)
			api.label.TextSize = 10
			b.LayoutOrder = 1
			ai_btn = b
		end

		set_minimized = function(state)
			minimized = state and true or false
			body.Visible = not minimized
			footer.Visible = not minimized
			tabstrip.Visible = not minimized
			title.Visible = not minimized
			subtitle.Visible = not minimized
			btn_row.Visible = not minimized
			expand_hit.Visible = minimized
			if minimized then
				fx.to(panel, "Size", U2(0, MIN_PX, 0, MIN_PX), "pop")
				fx.to(panel_corner, "CornerRadius", UD(0, MIN_PX / 2), "pop")
				fx.to(aurora_corner, "CornerRadius", UD(0, MIN_PX / 2), "pop")
				-- let the bar own the whole orb so the logo lands dead centre
				titlebar.Size = U2(1, 0, 1, 0)
				orb.AnchorPoint = V2(0.5, 0.5)
				fx.to(orb, "Position", U2(0.5, 1, 0.5, 0), "pop")
				fx.to(orb, "Size", U2(0, 28, 0, 28), "pop")
			else
				fx.to(panel, "Size", U2(0, BASE_W, 0, panel_h), "pop")
				fx.to(panel_corner, "CornerRadius", UD(0, TH.radius_panel), "pop")
				fx.to(aurora_corner, "CornerRadius", UD(0, TH.radius_panel), "pop")
				titlebar.Size = U2(1, 0, 0, TITLE_H)
				orb.AnchorPoint = V2(0, 0.5)
				fx.to(orb, "Position", U2(0, 0, 0.5, 0), "pop")
				fx.to(orb, "Size", U2(0, 24, 0, 24), "pop")
			end
			min_api.label.Text = minimized and GLYPH.plus or GLYPH.minus
			fx.punch(orb_scale, "Scale", 1.35, 1, "bounce")
		end

		------------------------------------------------------------------
		-- dragging
		------------------------------------------------------------------
		-- The panel tracks the pointer exactly: no spring, no inertial tilt. A
		-- lagging or rotating window reads as the interface coming apart, which
		-- is the opposite of responsive.

		local drag_active, drag_grab, drag_last_x, drag_travel = false, V2(0, 0), 0, 0

		local function clamp_panel(px, py)
			local vp = viewport()
			local size = panel.AbsoluteSize
			return mclamp(px, -size.X + 76, mmax(0, vp.X - 76)), mclamp(py, 0, mmax(0, vp.Y - 46))
		end

		local function begin_drag(io)
			drag_active = true
			drag_travel = 0
			drag_grab = V2(io.Position.X, io.Position.Y) - panel.AbsolutePosition
			drag_last_x = io.Position.X
		end

		titlebar.InputBegan:Connect(function(io)
			if not E.is_press(io) then
				return
			end
			-- don't start a drag when the press landed on the window buttons
			local a, s = btn_row.AbsolutePosition, btn_row.AbsoluteSize
			if
				btn_row.Visible
				and io.Position.X >= a.X
				and io.Position.X <= a.X + s.X
				and io.Position.Y >= a.Y
				and io.Position.Y <= a.Y + s.Y
			then
				return
			end
			begin_drag(io)
		end)

		expand_hit.InputBegan:Connect(function(io)
			if E.is_press(io) then
				begin_drag(io)
			end
		end)

		table.insert(
			x6.c,
			v1.InputChanged:Connect(function(io)
				if not drag_active or not E.is_move(io) then
					return
				end
				local px, py = clamp_panel(io.Position.X - drag_grab.X, io.Position.Y - drag_grab.Y)
				fx.set(panel, "Position", U2(0, px, 0, py))
				drag_travel = drag_travel + mabs(io.Position.X - drag_last_x)
				drag_last_x = io.Position.X
			end)
		)
		table.insert(
			x6.c,
			v1.InputEnded:Connect(function(io)
				if not drag_active or not E.is_press(io) then
					return
				end
				drag_active = false
				if minimized and drag_travel < 8 then
					set_minimized(false)
				end
			end)
		)

		------------------------------------------------------------------
		-- layout
		------------------------------------------------------------------

		local laid_out = false

		function x5.relayout()
			ui_scale = compute_scale()
			local vp = viewport()
			panel_h = mclamp(BASE_H, 250, mmax(250, vp.Y / ui_scale - 40))
			fx.to(panel_scale, "Scale", ui_scale, "flow")
			fx.to(hud_scale, "Scale", ui_scale, "flow")
			if dock_scale then
				fx.to(dock_scale, "Scale", ui_scale, "flow")
			end
			if not minimized then
				fx.to(panel, "Size", U2(0, BASE_W, 0, panel_h), "flow")
			end
			if laid_out then
				local px, py = clamp_panel(panel.AbsolutePosition.X, panel.AbsolutePosition.Y)
				fx.to(panel, "Position", U2(0, px, 0, py), "flow")
			end
		end

		table.insert(
			x6.c,
			sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				x5.relayout()
			end)
		)

		------------------------------------------------------------------
		-- ambient motion
		------------------------------------------------------------------

		ambient(function(dt, t, lvl)
			if minimized then
				ring_a.Rotation = (ring_a.Rotation + dt * 60) % 360
				ring_b.Rotation = (ring_b.Rotation - dt * 90) % 360
				return
			end
			aurora_a.Rotation = (aurora_a.Rotation + dt * 7) % 360
			aurora_b.Rotation = (aurora_b.Rotation - dt * 5) % 360
			ring_a.Rotation = (ring_a.Rotation + dt * 70) % 360
			ring_b.Rotation = (ring_b.Rotation - dt * 105) % 360
			edge_grad.Offset = V2(((t * 0.18) % 2) - 1, 0)
			if lvl > 1 then
				title_grad.Offset = V2(((t * 0.22) % 2.6) - 1.3, 0)
				local pulse = 5 + 2.5 * (0.5 + 0.5 * math.sin(t * 2.2))
				core_dot.Size = U2(0, pulse, 0, pulse)
			end
		end)

		------------------------------------------------------------------
		-- readouts and state sync
		------------------------------------------------------------------

		local HUD_TINT = { TH.ok, TH.warn, TH.bad }
		local HUD_WORD = { "ACTIVE", "PAUSED", "OFFLINE" }
		local last_state, last_target, last_parts, last_shape = -1, "", -1, ""
		local sync_timer, foot_timer = 0, 0

		ambient(function(dt)
			if dock_hold ~= 0 and x6.b then
				x6.b.Position = x6.b.Position + Vector3.new(0, dock_hold * dt * 48, 0)
			end
		end, true)

		ambient(function(dt)
			sync_timer = sync_timer - dt
			if sync_timer > 0 then
				return
			end
			sync_timer = 0.15

			local state = x1.Disabled and 3 or (x1.Paused and 2 or 1)
			if state ~= last_state then
				last_state = state
				local tint = HUD_TINT[state]
				hud_state.Text = HUD_WORD[state]
				fx.to(hud_state, "TextColor3", tint, "snap")
				fx.to(hud_dot, "BackgroundColor3", tint, "snap")
				fx.to(hud_halo_stroke, "Color", tint, "snap")
				fx.set(hud_halo_stroke, "Thickness", 5)
				fx.to(hud_halo_stroke, "Thickness", 1.5, "glide")
				fx.punch(hud_scale, "Scale", ui_scale * 1.05, ui_scale, "bounce")
			end

			local summary = target_summary()
			if summary ~= last_target then
				last_target = summary
				hud_target.Text = summary
			end

			if x1.k6 ~= last_shape then
				last_shape = x1.k6
				subtitle.Text = string.lower(x1.k6)
				if shape_card_name then
					shape_card_name.Text = string.upper(x1.k6)
				end
			end

			for i = 1, #sync do
				sync[i]()
			end
		end, true)

		ambient(function(dt)
			foot_timer = foot_timer - dt
			if foot_timer > 0 then
				return
			end
			foot_timer = 0.34
			local parts = x6.n or 0
			if parts ~= last_parts then
				last_parts = parts
				hud_parts.Text = parts .. " PARTS"
			end
			foot_left.Text = string.format("%d parts  %s  %d fps", parts, GLYPH.dot, mfloor(fx.fps() + 0.5))
			local running = x6.o and true or false
			foot_right.Text = running and "ENGINE RUNNING" or "PRESS E TO PLACE"
			fx.to(foot_right, "TextColor3", running and TH.ok or TH.tx3, "flow")
		end, true)

		------------------------------------------------------------------
		-- refresh entry point
		------------------------------------------------------------------

		function x5.up()
			if rebuild_shape_controls then
				rebuild_shape_controls()
			end
			if render_shapes then
				render_shapes()
			end
			if render_players then
				render_players()
			end
			sync_timer = 0
		end

		------------------------------------------------------------------
		-- hide / show hotkey
		------------------------------------------------------------------

		local hidden = false
		table.insert(
			x6.c,
			v1.InputBegan:Connect(function(io, processed)
				if processed or io.KeyCode ~= Enum.KeyCode.RightControl then
					return
				end
				hidden = not hidden
				if hidden then
					fx.to(panel_scale, "Scale", ui_scale * 0.8, "flow")
					task.delay(0.16, function()
						if hidden then
							panel.Visible = false
						end
					end)
					hud.Visible = false
					if dock then
						dock.Visible = false
					end
				else
					panel.Visible = true
					fx.set(panel_scale, "Scale", ui_scale * 0.8)
					fx.to(panel_scale, "Scale", ui_scale, "bounce")
					hud.Visible = x1.ShowHUD ~= false
					if dock then
						dock.Visible = x1.ShowDock and true or false
					end
				end
			end)
		)

		------------------------------------------------------------------
		-- boot
		------------------------------------------------------------------

		ApplyPerfShadows(x1.Perf_DisableShadows)
		ApplyPerfPostFX(x1.Perf_DisablePostFX)
		ApplyPerfMaterials(x1.Perf_PotatoMaterials)
		ApplyPerfParticles(x1.Perf_HideParticles)

		if x1.ShowDock == nil then
			x1.ShowDock = is_mobile
		end

		ui_scale = compute_scale()
		local vp0 = viewport()
		panel_h = mclamp(BASE_H, 250, mmax(250, vp0.Y / ui_scale - 40))
		panel.Size = U2(0, BASE_W, 0, panel_h)
		local start_x = mfloor(mmin(30, vp0.X * 0.04))
		local start_y = mmax(12, mfloor(vp0.Y * 0.5 - panel_h * ui_scale * 0.5))
		panel.Position = U2(0, start_x, 0, start_y + 26)
		laid_out = true

		set_dock(x1.ShowDock)
		select_tab(1, true)

		fx.to(panel, "Position", U2(0, start_x, 0, start_y), "pop")
		fx.set(panel_scale, "Scale", ui_scale * 0.9)
		fx.spring(panel_scale, "Scale", ui_scale, { k = 340, d = 20 })
		fx.set(hud_scale, "Scale", ui_scale * 0.8)
		fx.spring(hud_scale, "Scale", ui_scale, { k = 320, d = 22, delay = 0.12 })
		fx.punch(orb_scale, "Scale", 0.2, 1, "bounce")

		pcall(function()
			sg.Destroying:Connect(function()
				for i = 1, #handles do
					fx.cancel(handles[i])
				end
				table.clear(handles)
				table.clear(sync)
				toast_push = nil
				render_shapes, render_players, rebuild_shape_controls = nil, nil, nil
				RestoreAllPerf()
				if x5.g == sg then
					x5.g = nil
				end
				if x6.sg == sg then
					x6.sg = nil
				end
			end)
		end)

		task.delay(0.3, function()
			if sg.Parent then
				x5.toast("Project Gravity", "Ready. Press E to place the core.", "ok", 4)
			end
		end)
	end

	return x5
end
