return function(context)
	local v6 = context.v6
	local v8 = context.v8
	local x1 = context.x1
	
	local QoL = {}
	
	local toast_gui = nil
	local toast_container = nil
	
	function QoL.Toast(title, desc, duration, color)
		duration = duration or 3
		color = color or Color3.fromRGB(60, 200, 100)
		
		if not toast_gui then
			toast_gui = Instance.new("ScreenGui")
			toast_gui.Name = "G_ToastUI"
			toast_gui.DisplayOrder = 1000
			if gethui then 
				toast_gui.Parent = gethui()
			elseif syn and syn.protect_gui then 
				syn.protect_gui(toast_gui)
				toast_gui.Parent = game:GetService("CoreGui")
			else 
				toast_gui.Parent = v8:WaitForChild("PlayerGui") 
			end
			
			toast_container = Instance.new("Frame", toast_gui)
			toast_container.BackgroundTransparency = 1
			toast_container.Position = UDim2.new(1, -20, 1, -150)
			toast_container.Size = UDim2.new(0, 300, 0, 0)
			toast_container.AnchorPoint = Vector2.new(1, 1)
			local layout = Instance.new("UIListLayout", toast_container)
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			layout.Padding = UDim.new(0, 10)
		end
		
		local outer = Instance.new("Frame", toast_container)
		outer.BackgroundTransparency = 1
		outer.Size = UDim2.new(0, 300, 0, 0)
		outer.ClipsDescendants = false
		
		local frame = Instance.new("Frame", outer)
		frame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
		frame.Size = UDim2.new(1, 0, 0, 60)
		frame.Position = UDim2.new(1, 350, 0, 0)
		frame.ClipsDescendants = true
		local corner = Instance.new("UICorner", frame)
		corner.CornerRadius = UDim.new(0, 8)
		
		local color_bar = Instance.new("Frame", frame)
		color_bar.BackgroundColor3 = color
		color_bar.BorderSizePixel = 0
		color_bar.Size = UDim2.new(0, 4, 1, 0)
		color_bar.Position = UDim2.new(0, 0, 0, 0)
		
		local title_txt = Instance.new("TextLabel", frame)
		title_txt.BackgroundTransparency = 1
		title_txt.Size = UDim2.new(1, -24, 0, 20)
		title_txt.Position = UDim2.new(0, 16, 0, 10)
		title_txt.Text = title
		title_txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		title_txt.Font = Enum.Font.GothamBold
		title_txt.TextSize = 14
		title_txt.TextXAlignment = Enum.TextXAlignment.Left
		
		local desc_txt = Instance.new("TextLabel", frame)
		desc_txt.BackgroundTransparency = 1
		desc_txt.Size = UDim2.new(1, -24, 0, 16)
		desc_txt.Position = UDim2.new(0, 16, 0, 32)
		desc_txt.Text = desc
		desc_txt.TextColor3 = Color3.fromRGB(160, 165, 175)
		desc_txt.Font = Enum.Font.GothamMedium
		desc_txt.TextSize = 12
		desc_txt.TextXAlignment = Enum.TextXAlignment.Left
		
		-- Smooth expand to push older notifications
		v6:Create(outer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 300, 0, 60) }):Play()
		-- Crazy good slide anim with overshoot
		v6:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
		
		task.delay(duration, function()
			if not outer.Parent then return end
			-- Quick slide out
			v6:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), { Position = UDim2.new(1, 350, 0, 0) }):Play()
			
			task.delay(0.3, function()
				-- Smooth collapse
				local tOut = v6:Create(outer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 300, 0, 0) })
				tOut.Completed:Connect(function()
					outer:Destroy()
				end)
				tOut:Play()
			end)
		end)
	end
	
	function QoL.IsPartFiltered(p)
		if not p:IsA("BasePart") then return true end
		
		local max_size = x1.FilterMaxSize or 0
		local max_mass = x1.FilterMaxMass or 0
		
		if max_size > 0 then
			local s = p.Size
			if s.X > max_size or s.Y > max_size or s.Z > max_size then
				return true
			end
		end
		
		if max_mass > 0 then
			if p.Mass > max_mass then
				return true
			end
		end
		
		return false
	end

	return QoL
end
