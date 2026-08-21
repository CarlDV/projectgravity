return function(context, x7)
	local v1, v4, v8 = context.v1, context.v4, context.v8
	local x1, x6, x2 = context.x1, context.x6, context.x2
	local get_shape = context.get_shape

	x6.pc_selected = x6.pc_selected or setmetatable({}, { __mode = "k" })
	x6.pc_highlights = x6.pc_highlights or setmetatable({}, { __mode = "k" })
	x6.pc_offsets = x6.pc_offsets or setmetatable({}, { __mode = "k" })
	x6.pc_mods = x6.pc_mods or {}

	local RIDE_PHYSICS = PhysicalProperties.new(0.7, 0.5, 0.3, 1, 1)
	local LIGHT_PHYSICS = PhysicalProperties.new(0.001, 0, 0, 0, 0)
	local HL_COLOR = Color3.fromRGB(255, 170, 0)

	local function pc_clear_highlights()
		if x6.pc_highlights then
			for part, highlight in pairs(x6.pc_highlights) do
				if highlight and highlight.Parent then
					pcall(function()
						highlight:Destroy()
					end)
				end
			end
			table.clear(x6.pc_highlights)
		end
		if x6.pc_selected then
			table.clear(x6.pc_selected)
		end
		if x6.pc_offsets then
			table.clear(x6.pc_offsets)
		end
		if x6.pc_mods then
			table.clear(x6.pc_mods)
		end
		x6.pc_dragging = false
		x6.pc_drag_target = nil
	end
	x6.pc_clear = pc_clear_highlights

	local function pc_add_highlight(part)
		if x6.pc_highlights[part] then
			return
		end
		local highlight = Instance.new("SelectionBox")
		highlight.Adornee = part
		highlight.Color3 = HL_COLOR
		highlight.LineThickness = 0.05
		highlight.SurfaceTransparency = 0.8
		highlight.SurfaceColor3 = HL_COLOR
		highlight.Parent = part
		x6.pc_highlights[part] = highlight
	end

	local function pc_remove_highlight(part)
		if x6.pc_highlights[part] then
			pcall(function()
				x6.pc_highlights[part]:Destroy()
			end)
			x6.pc_highlights[part] = nil
		end
	end

	local function pc_select(part, add_to_selection)
		if not add_to_selection then
			for p, _ in pairs(x6.pc_selected) do
				pc_remove_highlight(p)
			end
			table.clear(x6.pc_selected)
			table.clear(x6.pc_offsets)
		end
		if part and x6.a and x6.a[part] then
			x6.pc_selected[part] = true
			pc_add_highlight(part)
		end
	end

	local function pc_deselect(part)
		x6.pc_selected[part] = nil
		x6.pc_offsets[part] = nil
		pc_remove_highlight(part)
	end

	local function pc_release(part)
		local d = x6.a and x6.a[part]
		if not d then
			return
		end
		if d.pc_mod then
			local mod = d.pc_mod
			if x6.pc_mods[mod] then
				x6.pc_mods[mod] = x6.pc_mods[mod] - 1
				if x6.pc_mods[mod] <= 0 then
					x6.pc_mods[mod] = nil
					if mod.cleanup then
						pcall(mod.cleanup, x6, x1)
					end
				end
			end
		end
		if d.pc_ride then
			pcall(function()
				part.CanCollide = false
				part.CustomPhysicalProperties = LIGHT_PHYSICS
			end)
		end
		d.pc_mode = nil
		d.pc_target = nil
		d.pc_shape = nil
		d.pc_mod = nil
		d.pc_cfg = nil
		d.pc_phys = nil
		d.pc_ride = nil
	end
	x6.pc_release = pc_release

	local function pc_assign(mode, opts)
		opts = opts or {}
		local mod = nil
		local shape_cfg = nil

		if mode == "shape" then
			if opts.shape == "Sculptor" then
				return 0
			end
			mod = get_shape and get_shape(opts.shape)
			if not mod or not mod.f2 then
				return 0
			end
			shape_cfg = (x2 and x2[opts.shape]) or (context.x2 and context.x2[opts.shape])
			if not shape_cfg and mod.Controls then
				shape_cfg = {}
				for _, ctrl in ipairs(mod.Controls) do
					if ctrl.Key then
						local def = ctrl.Default
						if def == nil then
							def = ctrl.Min or 0
						end
						if ctrl.Div then
							def = def / ctrl.Div
						end
						shape_cfg[ctrl.Key] = def
					end
				end
			end
			mod.pc_cfg_ref = shape_cfg
		end

		local count = 0
		for part, _ in pairs(x6.pc_selected) do
			local d = x6.a and x6.a[part]
			if d then
				pc_add_highlight(part)
				if d.pc_mod and (mode ~= "shape" or d.pc_mod ~= mod) then
					local old_mod = d.pc_mod
					if x6.pc_mods[old_mod] then
						x6.pc_mods[old_mod] = x6.pc_mods[old_mod] - 1
						if x6.pc_mods[old_mod] <= 0 then
							x6.pc_mods[old_mod] = nil
							if old_mod.cleanup then
								pcall(old_mod.cleanup, x6, x1)
							end
						end
					end
				end

				if mode == nil then
					pc_release(part)
				else
					d.pc_mode = mode
					if mode == "pin" then
						d.pc_target = opts.target or part.Position
						d.pc_shape = nil
						d.pc_mod = nil
						d.pc_cfg = nil
					elseif mode == "manual" then
						d.pc_target = opts.target or d.pc_target or part.Position
						d.pc_shape = nil
						d.pc_mod = nil
						d.pc_cfg = nil
					elseif mode == "shape" then
						d.pc_shape = opts.shape
						d.pc_mod = mod
						d.pc_cfg = shape_cfg
						x6.pc_mods[mod] = (x6.pc_mods[mod] or 0) + 1
					end

					if opts.phys ~= nil then
						d.pc_phys = opts.phys
					end

					if opts.ride ~= nil then
						d.pc_ride = opts.ride and true or false
						if d.pc_ride then
							pcall(function()
								if part.CanCollide ~= true then
									part.CanCollide = true
								end
								local props = d.original_properties or RIDE_PHYSICS
								part.CustomPhysicalProperties = props
							end)
						else
							pcall(function()
								if part.CanCollide ~= false then
									part.CanCollide = false
								end
								part.CustomPhysicalProperties = LIGHT_PHYSICS
							end)
						end
					end
				end
				count = count + 1
			end
		end

		return count
	end
	x6.pc_assign = pc_assign

	local function get_touch_target(pos)
		local cam = v4 and v4.CurrentCamera
		if not cam then
			return nil
		end
		local ray = cam:ViewportPointToRay(pos.X, pos.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		local cand = {}
		if x6.a then
			for p, _ in pairs(x6.a) do
				table.insert(cand, p)
			end
		end
		params.FilterDescendantsInstances = cand
		local res = v4:Raycast(ray.Origin, ray.Direction * 1000, params)
		return res and res.Instance or nil
	end

	local function get_touch_world_pos(pos, distance)
		local cam = v4 and v4.CurrentCamera
		if not cam then
			return nil
		end
		local ray = cam:ViewportPointToRay(pos.X, pos.Y)
		return ray.Origin + (ray.Direction * (distance or 50))
	end

	return function()
		if not v1 or not v1.InputBegan or not x6.c then
			return
		end

		table.insert(
			x6.c,
			v1.InputBegan:Connect(function(input, processed)
				if processed then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
					local target = get_touch_target(input.Position)
					local multi = x1.PartCtlMultiSelect == true

					if target and x6.a and x6.a[target] then
						if x6.pc_selected[target] then
							if multi then
								pc_deselect(target)
							else
								x6.pc_dragging = true
								local cam = v4 and v4.CurrentCamera
								x6.pc_drag_distance = cam and (cam.CFrame.Position - target.Position).Magnitude or 50
								x6.pc_drag_target = target.Position
								for part, _ in pairs(x6.pc_selected) do
									x6.pc_offsets[part] = part.Position - target.Position
									local d = x6.a[part]
									if d then
										d.pc_mode = d.pc_mode or "manual"
										d.pc_target = part.Position
									end
								end
							end
						else
							pc_select(target, multi)
							if not multi then
								x6.pc_dragging = true
								local cam = v4 and v4.CurrentCamera
								x6.pc_drag_distance = cam and (cam.CFrame.Position - target.Position).Magnitude or 50
								x6.pc_drag_target = target.Position
								x6.pc_offsets[target] = Vector3.zero
								local d = x6.a[target]
								if d then
									d.pc_mode = d.pc_mode or "manual"
									d.pc_target = target.Position
								end
							end
						end
					end
				end
			end)
		)

		table.insert(
			x6.c,
			v1.InputChanged:Connect(function(input, processed)
				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
					if x6.pc_dragging then
						local new_pos = get_touch_world_pos(input.Position, x6.pc_drag_distance or 50)
						if new_pos then
							x6.pc_drag_target = new_pos
							for part, _ in pairs(x6.pc_selected) do
								local d = x6.a and x6.a[part]
								if d then
									local off = x6.pc_offsets[part] or Vector3.zero
									d.pc_target = new_pos + off
									d.pc_mode = d.pc_mode or "manual"
								end
							end
						end
					end
				end
			end)
		)

		table.insert(
			x6.c,
			v1.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
					if x6.pc_dragging then
						x6.pc_dragging = false
						x6.pc_drag_target = nil
						for part, _ in pairs(x6.pc_selected) do
							local d = x6.a and x6.a[part]
							if d and d.pc_target then
								if not d.pc_mode or d.pc_mode == "manual" then
									d.pc_mode = x1.PartCtlMode or "pin"
								end
							end
						end
					end
				end
			end)
		)
	end
end
