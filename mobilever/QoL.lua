return function(context)
	local v6 = context.v6
	local v8 = context.v8
	local x1 = context.x1
	
	local QoL = {}
	
	local toast_gui = nil
	local toast_container = nil
	
	function QoL.Toast(message, duration, color)
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
			toast_container.Position = UDim2.new(0.5, 0, 1, -150)
			toast_container.Size = UDim2.new(0, 300, 0, 0)
			local layout = Instance.new("UIListLayout", toast_container)
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			layout.Padding = UDim.new(0, 8)
		end
		
		local frame = Instance.new("Frame", toast_container)
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		frame.Size = UDim2.new(0, 0, 0, 36)
		frame.BackgroundTransparency = 1
		frame.ClipsDescendants = true
		local corner = Instance.new("UICorner", frame)
		corner.CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", frame)
		stroke.Color = color
		stroke.Thickness = 1
		stroke.Transparency = 1
		
		local txt = Instance.new("TextLabel", frame)
		txt.BackgroundTransparency = 1
		txt.Size = UDim2.new(1, -20, 1, 0)
		txt.Position = UDim2.new(0, 10, 0, 0)
		txt.Text = message
		txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		txt.Font = Enum.Font.GothamBold
		txt.TextSize = 13
		txt.TextTransparency = 1
		
		v6:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 250, 0, 36),
			BackgroundTransparency = 0.1
		}):Play()
		v6:Create(stroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()
		v6:Create(txt, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		
		task.delay(duration, function()
			if not frame.Parent then return end
			local tOut = v6:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 36),
				BackgroundTransparency = 1
			})
			v6:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			v6:Create(txt, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
			tOut.Completed:Connect(function()
				frame:Destroy()
			end)
			tOut:Play()
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
