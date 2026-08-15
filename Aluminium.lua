--[==[ GACF UI FRAMEWORK - PHẦN 1/3 ]==]
local GACF = {}

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

-- ================== MÀU SẮC ==================
local COLORS = {
    Background = Color3.fromRGB(12, 12, 18),
    Background2 = Color3.fromRGB(20, 20, 28),
    TitleBar = Color3.fromRGB(30, 30, 42),
    Content = Color3.fromRGB(40, 40, 52),
    ContentHover = Color3.fromRGB(50, 50, 65),
    Border = Color3.fromRGB(0, 200, 255),
    BorderGlow = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    ToggleOn = Color3.fromRGB(0, 220, 120),
    ToggleOff = Color3.fromRGB(70, 70, 85),
    Knob = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 200, 255),
    Accent2 = Color3.fromRGB(100, 100, 255),
    Danger = Color3.fromRGB(255, 60, 60),
    Warning = Color3.fromRGB(255, 200, 0),
    Success = Color3.fromRGB(0, 255, 150),
    Gradient1 = Color3.fromRGB(0, 200, 255),
    Gradient2 = Color3.fromRGB(100, 100, 255),
}

-- ================== BIẾN TOÀN CỤC ==================
local screenGui = nil
local mainFrame = nil
local scrollFrame = nil
local toggleButton = nil
local isOpen = false
local toggles = {}
local buttons = {}
local sliders = {}
local dropdowns = {}
local menuTitle = "GACF VIP"
local isAnimating = false
local openDropdown = nil

-- ================== TẠO UI ==================
function GACF:CreateUI(title)
    menuTitle = title or "GACF VIP"
    
    if screenGui then
        pcall(function() screenGui:Destroy() end)
        screenGui = nil
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GACF_UI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- ===== MAIN FRAME =====
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
    mainFrame.BackgroundColor3 = COLORS.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Parent = screenGui
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 16)
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = COLORS.Border
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.4
    
    local glowBg = Instance.new("Frame")
    glowBg.Size = UDim2.new(1.2, 0, 1.2, 0)
    glowBg.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glowBg.BackgroundColor3 = COLORS.BorderGlow
    glowBg.BackgroundTransparency = 0.92
    glowBg.Parent = mainFrame
    Instance.new("UICorner", glowBg).CornerRadius = UDim.new(0, 20)
    
    -- ===== TITLE BAR =====
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = COLORS.TitleBar
    titleBar.BackgroundTransparency = 0.05
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)
    
    local gradientLine = Instance.new("Frame")
    gradientLine.Size = UDim2.new(0.6, 0, 0, 2)
    gradientLine.Position = UDim2.new(0.2, 0, 1, -1)
    gradientLine.BackgroundColor3 = COLORS.Border
    gradientLine.BackgroundTransparency = 0.5
    gradientLine.Parent = titleBar
    Instance.new("UICorner", gradientLine).CornerRadius = UDim.new(0, 1)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 18, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ " .. menuTitle
    titleText.TextColor3 = COLORS.Text
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(1, -32, 0.5, -5)
    statusDot.BackgroundColor3 = COLORS.ToggleOff
    statusDot.Parent = titleBar
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
    statusDot.Name = "StatusDot"
    
    spawn(function()
        while true do
            if mainFrame.Visible then
                TweenService:Create(statusDot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.3
                }):Play()
                wait(0.5)
                TweenService:Create(statusDot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0
                }):Play()
                wait(0.5)
            else
                wait(1)
            end
        end
    end)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COLORS.TextDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        isOpen = false
        mainFrame.Visible = false
    end)
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = COLORS.Danger
    end)
    
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = COLORS.TextDim
    end)
    
    -- ===== SCROLL FRAME =====
    scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -12, 1, -56)
    scrollFrame.Position = UDim2.new(0, 6, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = COLORS.Border
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    self:CreateToggleButton()
    
    return self
end

-- ================== TẠO TOGGLE BUTTON ==================
function GACF:CreateToggleButton()
    toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 44, 0, 44)
    toggleButton.Position = UDim2.new(1, -56, 1, -56)
    toggleButton.BackgroundColor3 = COLORS.Accent
    toggleButton.Text = "⚡"
    toggleButton.TextColor3 = COLORS.Text
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 20
    toggleButton.Parent = screenGui
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1.3, 0, 1.3, 0)
    glow.Position = UDim2.new(-0.15, 0, -0.15, 0)
    glow.BackgroundColor3 = COLORS.Accent
    glow.BackgroundTransparency = 0.8
    glow.Parent = toggleButton
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
    
    toggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        mainFrame.Visible = isOpen
        if isOpen then
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.05,
                Size = UDim2.new(0, 300, 0, 260),
                Position = UDim2.new(0.5, -150, 0.5, -130)
            }):Play()
        end
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = toggleButton.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            toggleButton.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ================== TẠO TOGGLE ==================
function GACF:AddToggle(label, icon, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "🔘"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -80, 1, 0)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Toggle"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 40, 0, 20)
    switchFrame.Position = UDim2.new(1, -50, 0.5, -10)
    switchFrame.BackgroundColor3 = default and COLORS.ToggleOn or COLORS.ToggleOff
    switchFrame.Parent = container
    Instance.new("UICorner", switchFrame).CornerRadius = UDim.new(0, 10)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = COLORS.Knob
    knob.Parent = switchFrame
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container
    
    local state = default
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        switchFrame.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
        local targetPos = state and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        if callback then callback(state) end
    end)
    
    table.insert(toggles, {container = container, state = state, callback = callback})
    return container
end

-- ================== TẠO BUTTON ==================
function GACF:AddButton(label, icon, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    container.MouseEnter:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    container.MouseLeave:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "📌"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -55, 1, 0)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Button"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 28)
    btn.Position = UDim2.new(1, -58, 0, 6)
    btn.BackgroundColor3 = COLORS.Accent
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Text = "▶"
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 48, 0, 24)}):Play()
        wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 52, 0, 28)}):Play()
    end)
    
    table.insert(buttons, {container = container, callback = callback})
    return container
end

return GACF
--[==[ GACF UI FRAMEWORK - PHẦN 2/3 ]==]
-- ================== TẠO SLIDER ==================
function GACF:AddSlider(label, icon, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 54)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 0, 20)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "📊"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0, 120, 0, 20)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Slider"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0, 44, 0, 20)
    valueText.Position = UDim2.new(1, -48, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(default or 0)
    valueText.TextColor3 = COLORS.Accent
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 13
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = container
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.7, 0, 0, 4)
    slider.Position = UDim2.new(0, 44, 0, 30)
    slider.BackgroundColor3 = COLORS.ToggleOff
    slider.Parent = container
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 2)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default or 0) / max, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.Parent = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 16, 0, 16)
    drag.Position = UDim2.new((default or 0) / max, -8, 0.5, -8)
    drag.BackgroundColor3 = COLORS.Knob
    drag.Text = ""
    drag.Parent = container
    Instance.new("UICorner", drag).CornerRadius = UDim.new(1, 0)
    
    local knobGlow = Instance.new("Frame")
    knobGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
    knobGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    knobGlow.BackgroundColor3 = COLORS.Accent
    knobGlow.BackgroundTransparency = 0.85
    knobGlow.Parent = drag
    Instance.new("UICorner", knobGlow).CornerRadius = UDim.new(1, 0)
    
    local currentValue = default or 0
    local dragging = false
    
    local function updateSlider(mouseX)
        local containerPos = slider.AbsolutePosition.X
        local containerWidth = slider.AbsoluteSize.X
        if containerWidth <= 0 then return end
        local percent = math.clamp((mouseX - containerPos) / containerWidth, 0, 1)
        currentValue = math.floor(min + (max - min) * percent)
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        drag.Position = UDim2.new(percent, -8, 0.5, -8)
        valueText.Text = tostring(currentValue)
        
        if callback then callback(currentValue) end
    end
    
    drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    table.insert(sliders, {container = container, value = currentValue, callback = callback})
    return container
end

-- ================== TẠO DROPDOWN ==================
function GACF:AddDropdown(label, icon, options, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundColor3 = COLORS.Content
    container.BackgroundTransparency = 0.3
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = COLORS.Border
    stroke.Thickness = 0.5
    stroke.Transparency = 0.8
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 32, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "📋"
    iconLabel.TextColor3 = COLORS.Text
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 17
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Position = UDim2.new(0, 44, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label or "Dropdown"
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(0.4, -10, 1, 0)
    selectedText.Position = UDim2.new(0.55, 0, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = default or options[1] or "Select"
    selectedText.TextColor3 = COLORS.Accent
    selectedText.Font = Enum.Font.GothamBold
    selectedText.TextSize = 12
    selectedText.TextXAlignment = Enum.TextXAlignment.Right
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -22, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = COLORS.TextDim
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = container
    
    local listContainer = Instance.new("Frame")
    listContainer.Name = "DropdownList"
    listContainer.Size = UDim2.new(1, 0, 0, #options * 35)
    listContainer.Position = UDim2.new(0, 0, 1, 2)
    listContainer.BackgroundColor3 = COLORS.Background2
    listContainer.Visible = false
    listContainer.ZIndex = 100
    listContainer.Parent = container
    Instance.new("UICorner", listContainer).CornerRadius = UDim.new(0, 8)
    
    local listStroke = Instance.new("UIStroke", listContainer)
    listStroke.Color = COLORS.Border
    listStroke.Thickness = 1
    listStroke.Transparency = 0.5
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listContainer
    
    local selectedValue = default or options[1]
    local isOpen = false
    
    local function closeDropdown()
        isOpen = false
        listContainer.Visible = false
        arrow.Text = "▼"
        container.Size = UDim2.new(1, -6, 0, 40)
        if openDropdown == container then
            openDropdown = nil
        end
    end
    
    local function openDropdown()
        if openDropdown and openDropdown ~= container then
            local otherContainer = openDropdown
            local otherList = otherContainer:FindFirstChild("DropdownList")
            if otherList then
                otherList.Visible = false
            end
            openDropdown = nil
        end
        isOpen = true
        listContainer.Visible = true
        arrow.Text = "▲"
        container.Size = UDim2.new(1, -6, 0, 40 + #options * 35)
        openDropdown = container
    end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdown()
        end
    end)
    
    for i, option in pairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, -8, 0, 33)
        optionBtn.BackgroundColor3 = COLORS.Content
        optionBtn.BackgroundTransparency = 0.5
        optionBtn.Text = option
        optionBtn.TextColor3 = COLORS.Text
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 12
        optionBtn.Parent = listContainer
        Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 6)
        
        optionBtn.MouseEnter:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
        end)
        
        optionBtn.MouseLeave:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            selectedValue = option
            selectedText.Text = option
            if callback then callback(option) end
            closeDropdown()
        end)
    end
    
    table.insert(dropdowns, {
        container = container,
        options = options,
        selected = selectedValue,
        callback = callback,
        UpdateOptions = function(newOptions)
            for _, child in pairs(listContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for i, option in pairs(newOptions) do
                local optionBtn = Instance.new("TextButton")
                optionBtn.Size = UDim2.new(1, -8, 0, 33)
                optionBtn.BackgroundColor3 = COLORS.Content
                optionBtn.BackgroundTransparency = 0.5
                optionBtn.Text = option
                optionBtn.TextColor3 = COLORS.Text
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.TextSize = 12
                optionBtn.Parent = listContainer
                Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 6)
                
                optionBtn.MouseEnter:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
                end)
                
                optionBtn.MouseButton1Click:Connect(function()
                    selectedValue = option
                    selectedText.Text = option
                    if callback then callback(option) end
                    closeDropdown()
                end)
            end
            listContainer.Size = UDim2.new(1, 0, 0, #newOptions * 35)
        end
    })
    
    return container
end

return GACF
--[==[ GACF UI FRAMEWORK - PHẦN 3/3 ]==]
-- ================== TẠO SEPARATOR ==================
function GACF:AddSeparator()
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = COLORS.Border
    line.BackgroundTransparency = 0.7
    line.Parent = container
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 1)
    
    return container
end

-- ================== TẠO LABEL ==================
function GACF:AddLabel(text, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = COLORS.TextDim
    label.Font = Enum.Font.Gotham
