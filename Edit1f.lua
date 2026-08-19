local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function createUIStroke(obj, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.Parent = obj
	return stroke
end

local function createUICorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = obj
	return corner
end

local function createUISizeConstraint(obj, maxSize, minSize)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = maxSize
	constraint.MinSize = minSize
	constraint.Parent = obj
	return constraint
end

function Library:CreateWindow(title)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BloxFruitsHubGUI"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 420, 0, 250)
	mainFrame.Position = UDim2.new(0.5, -210, 0.5, -125)
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
	mainFrame.BackgroundTransparency = 0
	mainFrame.Visible = true
	mainFrame.Active = true
	mainFrame.Draggable = false
	mainFrame.Parent = screenGui
	createUICorner(mainFrame, 12)
	
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316044815"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 10, 10)
	shadow.Parent = mainFrame
	
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 120, 1, 0)
	sidebar.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
	sidebar.BackgroundTransparency = 0
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame
	createUICorner(sidebar, 12)
	
	local sidebarStroke = createUIStroke(sidebar, Color3.fromRGB(0, 170, 255), 1, 0.3)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.Position = UDim2.new(0, 0, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = sidebar
	
	local tabButtons = Instance.new("Frame")
	tabButtons.Name = "TabButtons"
	tabButtons.Size = UDim2.new(1, 0, 1, -40)
	tabButtons.Position = UDim2.new(0, 0, 0, 40)
	tabButtons.BackgroundTransparency = 1
	tabButtons.Parent = sidebar
	
	local tabButtonList = Instance.new("UIListLayout")
	tabButtonList.Name = "TabButtonList"
	tabButtonList.FillDirection = Enum.FillDirection.Vertical
	tabButtonList.SortOrder = Enum.SortOrder.LayoutOrder
	tabButtonList.Padding = UDim.new(0, 4)
	tabButtonList.Parent = tabButtons
	
	local contentPanel = Instance.new("ScrollingFrame")
	contentPanel.Name = "ContentPanel"
	contentPanel.Size = UDim2.new(1, -130, 1, -20)
	contentPanel.Position = UDim2.new(0, 130, 0, 10)
	contentPanel.BackgroundTransparency = 1
	contentPanel.BorderSizePixel = 0
	contentPanel.ScrollBarThickness = 4
	contentPanel.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
	contentPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentPanel.Parent = mainFrame
	
	local contentList = Instance.new("UIListLayout")
	contentList.Name = "ContentList"
	contentList.FillDirection = Enum.FillDirection.Vertical
	contentList.SortOrder = Enum.SortOrder.LayoutOrder
	contentList.Padding = UDim.new(0, 8)
	contentList.Parent = contentPanel
	
	local floatingBubble = Instance.new("ImageButton")
	floatingBubble.Name = "FloatingBubble"
	floatingBubble.Size = UDim2.new(0, 45, 0, 45)
	floatingBubble.Position = UDim2.new(0, 10, 0, 10)
	floatingBubble.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
	floatingBubble.BackgroundTransparency = 0
	floatingBubble.Image = "rbxassetid://1316385681"
	floatingBubble.ImageColor3 = Color3.fromRGB(0, 170, 255)
	floatingBubble.ImageTransparency = 0.5
	floatingBubble.Parent = screenGui
	createUICorner(floatingBubble, 45)
	createUIStroke(floatingBubble, Color3.fromRGB(0, 170, 255), 2, 0.8)
	
	local window = {}
	local tabs = {}
	local currentTab = nil
	local bubbleDragging = false
	local dragStart = nil
	local dragOffset = nil
	local bubblePos = UDim2.new(0, 10, 0, 10)
	
	local function updateCanvasSize()
		local totalHeight = 0
		for _, child in ipairs(contentPanel:GetChildren()) do
			if child:IsA("Frame") and child.Name ~= "ContentList" then
				totalHeight = totalHeight + child.Size.Y.Offset + 8
			end
		end
		contentPanel.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 0))
	end
	
	local function createTabContent(tabName)
		local tabFrame = Instance.new("Frame")
		tabFrame.Name = tabName .. "Tab"
		tabFrame.Size = UDim2.new(1, -10, 0, 0)
		tabFrame.BackgroundTransparency = 1
		tabFrame.Visible = false
		tabFrame.Parent = contentPanel
		
		local tabList = Instance.new("UIListLayout")
		tabList.Name = "TabList"
		tabList.FillDirection = Enum.FillDirection.Vertical
		tabList.SortOrder = Enum.SortOrder.LayoutOrder
		tabList.Padding = UDim.new(0, 6)
		tabList.Parent = tabFrame
		
		local tabObject = {}
		local elements = {}
		
		function tabObject:CreateToggle(text, default, callback)
			local toggleFrame = Instance.new("Frame")
			toggleFrame.Name = "Toggle_" .. text
			toggleFrame.Size = UDim2.new(1, 0, 0, 30)
			toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
			toggleFrame.BackgroundTransparency = 0
			toggleFrame.Parent = tabFrame
			createUICorner(toggleFrame, 6)
			
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(0.7, -10, 1, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Center
			label.Font = Enum.Font.GothamMedium
			label.Parent = toggleFrame
			
			local switchBG = Instance.new("Frame")
			switchBG.Name = "SwitchBG"
			switchBG.Size = UDim2.new(0, 40, 0, 20)
			switchBG.Position = UDim2.new(1, -50, 0.5, -10)
			switchBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			switchBG.BackgroundTransparency = 0
			switchBG.Parent = toggleFrame
			createUICorner(switchBG, 20)
			
			local switchIndicator = Instance.new("Frame")
			switchIndicator.Name = "SwitchIndicator"
			switchIndicator.Size = UDim2.new(0, 16, 0, 16)
			switchIndicator.Position = UDim2.new(0, 2, 0.5, -8)
			switchIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			switchIndicator.BackgroundTransparency = 0
			switchIndicator.Parent = switchBG
			createUICorner(switchIndicator, 16)
			
			local active = default or false
			local function updateSwitch(state)
				active = state
				local targetPos = active and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				local targetColor = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
				local indicatorColor = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
				
				TweenService:Create(switchBG, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = targetColor}):Play()
				TweenService:Create(switchIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = targetPos, BackgroundColor3 = indicatorColor}):Play()
				if callback then callback(active) end
			end
			
			switchBG.MouseButton1Click:Connect(function()
				updateSwitch(not active)
			end)
			
			updateSwitch(active)
			table.insert(elements, toggleFrame)
			updateCanvasSize()
			return toggleFrame
		end
		
		function tabObject:CreateDropdown(text, options, callback)
			local dropdownFrame = Instance.new("Frame")
			dropdownFrame.Name = "Dropdown_" .. text
			dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
			dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
			dropdownFrame.BackgroundTransparency = 0
			dropdownFrame.Parent = tabFrame
			createUICorner(dropdownFrame, 6)
			
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(0.5, -10, 1, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Center
			label.Font = Enum.Font.GothamMedium
			label.Parent = dropdownFrame
			
			local dropButton = Instance.new("TextButton")
			dropButton.Name = "DropButton"
			dropButton.Size = UDim2.new(0.4, -10, 1, -4)
			dropButton.Position = UDim2.new(0.6, 0, 0, 2)
			dropButton.BackgroundColor3 = Color3.fromRGB(35, 38, 46)
			dropButton.BackgroundTransparency = 0
			dropButton.Text = options[1] or "Select"
			dropButton.TextColor3 = Color3.fromRGB(200, 200, 200)
			dropButton.TextSize = 12
			dropButton.Font = Enum.Font.GothamMedium
			dropButton.Parent = dropdownFrame
			createUICorner(dropButton, 4)
			
			local dropdownList = Instance.new("Frame")
			dropdownList.Name = "DropdownList"
			dropdownList.Size = UDim2.new(0.4, -10, 0, 0)
			dropdownList.Position = UDim2.new(0.6, 0, 0, 30)
			dropdownList.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
			dropdownList.BackgroundTransparency = 0
			dropdownList.Visible = false
			dropdownList.ClipsDescendants = true
			dropdownList.Parent = dropdownFrame
			createUICorner(dropdownList, 4)
			
			local listLayout = Instance.new("UIListLayout")
			listLayout.Name = "ListLayout"
			listLayout.FillDirection = Enum.FillDirection.Vertical
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 2)
			listLayout.Parent = dropdownList
			
			local isOpen = false
			local selected = options[1] or ""
			
			for _, option in ipairs(options) do
				local optionButton = Instance.new("TextButton")
				optionButton.Name = "Option_" .. option
				optionButton.Size = UDim2.new(1, 0, 0, 20)
				optionButton.BackgroundColor3 = Color3.fromRGB(35, 38, 46)
				optionButton.BackgroundTransparency = 0
				optionButton.Text = option
				optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
				optionButton.TextSize = 12
				optionButton.Font = Enum.Font.GothamMedium
				optionButton.Parent = dropdownList
				createUICorner(optionButton, 3)
				
				optionButton.MouseButton1Click:Connect(function()
					selected = option
					dropButton.Text = option
					if callback then callback(option) end
					isOpen = false
					TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(0.4, -10, 0, 0)}):Play()
					wait(0.2)
					dropdownList.Visible = false
				end)
			end
			
			dropButton.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				dropdownList.Visible = true
				local targetHeight = #options * 22
				TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(0.4, -10, 0, targetHeight)}):Play()
				if not isOpen then
					TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(0.4, -10, 0, 0)}):Play()
					wait(0.2)
					dropdownList.Visible = false
				end
			end)
			
			table.insert(elements, dropdownFrame)
			updateCanvasSize()
			return dropdownFrame
		end
		
		function tabObject:CreateSlider(text, min, max, default, callback)
			local sliderFrame = Instance.new("Frame")
			sliderFrame.Name = "Slider_" .. text
			sliderFrame.Size = UDim2.new(1, 0, 0, 40)
			sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
			sliderFrame.BackgroundTransparency = 0
			sliderFrame.Parent = tabFrame
			createUICorner(sliderFrame, 6)
			
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(0.6, -10, 1, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = text .. ": " .. tostring(default or min)
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Center
			label.Font = Enum.Font.GothamMedium
			label.Parent = sliderFrame
			
			local sliderTrack = Instance.new("Frame")
			sliderTrack.Name = "SliderTrack"
			sliderTrack.Size = UDim2.new(0.6, -20, 0, 4)
			sliderTrack.Position = UDim2.new(0.4, 0, 0.5, -2)
			sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			sliderTrack.BackgroundTransparency = 0
			sliderTrack.Parent = sliderFrame
			createUICorner(sliderTrack, 4)
			
			local sliderFill = Instance.new("Frame")
			sliderFill.Name = "SliderFill"
			sliderFill.Size = UDim2.new(0, 0, 1, 0)
			sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			sliderFill.BackgroundTransparency = 0
			sliderFill.Parent = sliderTrack
			createUICorner(sliderFill, 4)
			
			local value = default or min
			local function updateSlider(val)
				val = math.clamp(val, min, max)
				value = val
				local percentage = (val - min) / (max - min)
				sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
				label.Text = text .. ": " .. math.floor(val)
				if callback then callback(val) end
			end
			
			local dragging = false
			sliderTrack.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					local pos = input.Position.X - sliderTrack.AbsolutePosition.X
					local percentage = math.clamp(pos / sliderTrack.AbsoluteSize.X, 0, 1)
					updateSlider(min + (max - min) * percentage)
				end
			end)
			
			sliderTrack.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local pos = input.Position.X - sliderTrack.AbsolutePosition.X
					local percentage = math.clamp(pos / sliderTrack.AbsoluteSize.X, 0, 1)
					updateSlider(min + (max - min) * percentage)
				end
			end)
			
			updateSlider(value)
			table.insert(elements, sliderFrame)
			updateCanvasSize()
			return sliderFrame
		end
		
		function tabObject:CreateButton(text, callback)
			local button = Instance.new("TextButton")
			button.Name = "Button_" .. text
			button.Size = UDim2.new(1, 0, 0, 30)
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			button.BackgroundTransparency = 0
			button.Text = text
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextSize = 14
			button.Font = Enum.Font.GothamBold
			button.Parent = tabFrame
			createUICorner(button, 6)
			
			button.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
			
			table.insert(elements, button)
			updateCanvasSize()
			return button
		end
		
		return tabObject
	end
	
	local function selectTab(tabName)
		if currentTab then
			for _, child in ipairs(contentPanel:GetChildren()) do
				if child:IsA("Frame") and child.Name == currentTab .. "Tab" then
					child.Visible = false
				end
			end
		end
		currentTab = tabName
		for _, child in ipairs(contentPanel:GetChildren()) do
			if child:IsA("Frame") and child.Name == tabName .. "Tab" then
				child.Visible = true
				child.Size = UDim2.new(1, -10, 0, 0)
			end
		end
		updateCanvasSize()
	end
	
	function window:CreateTab(tabName)
		local tabButton = Instance.new("TextButton")
		tabButton.Name = "TabButton_" .. tabName
		tabButton.Size = UDim2.new(1, -10, 0, 30)
		tabButton.Position = UDim2.new(0, 5, 0, 0)
		tabButton.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
		tabButton.BackgroundTransparency = 0
		tabButton.Text = tabName
		tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
		tabButton.TextSize = 12
		tabButton.Font = Enum.Font.GothamMedium
		tabButton.Parent = tabButtons
		createUICorner(tabButton, 6)
		
		local tabContent = createTabContent(tabName)
		tabs[tabName] = tabContent
		
		if not currentTab then
			tabButton.TextColor3 = Color3.fromRGB(0, 170, 255)
			tabButton.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
			selectTab(tabName)
		end
		
		tabButton.MouseButton1Click:Connect(function()
			for _, btn in ipairs(tabButtons:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.TextColor3 = Color3.fromRGB(150, 150, 150)
					btn.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
				end
			end
			tabButton.TextColor3 = Color3.fromRGB(0, 170, 255)
			tabButton.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
			selectTab(tabName)
		end)
		
		return tabContent
	end
	
	local function toggleUI()
		mainFrame.Visible = not mainFrame.Visible
	end
	
	floatingBubble.MouseButton1Click:Connect(toggleUI)
	
	local bubbleDragData = {
		Dragging = false,
		StartPos = nil,
		Offset = nil
	}
	
	floatingBubble.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bubbleDragData.Dragging = true
			bubbleDragData.Offset = Vector2.new(
				input.Position.X - floatingBubble.AbsolutePosition.X,
				input.Position.Y - floatingBubble.AbsolutePosition.Y
			)
		end
	end)
	
	floatingBubble.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bubbleDragData.Dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if bubbleDragData.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local newX = math.clamp(input.Position.X - bubbleDragData.Offset.X, 0, screenGui.AbsoluteSize.X - 45)
			local newY = math.clamp(input.Position.Y - bubbleDragData.Offset.Y, 0, screenGui.AbsoluteSize.Y - 45)
			floatingBubble.Position = UDim2.new(0, newX, 0, newY)
		end
	end)
	
	window.ToggleUI = toggleUI
	window.MainFrame = mainFrame
	window.FloatingBubble = floatingBubble
	
	return window
end

return Library
