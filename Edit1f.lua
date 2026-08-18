local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local COLORS = {
    Background = Color3.fromRGB(25, 25, 25),
    TitleBar = Color3.fromRGB(35, 35, 35),
    Content = Color3.fromRGB(45, 45, 45),
    Border = Color3.fromRGB(0, 255, 0),
    Text = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(0, 200, 0),
    ToggleOff = Color3.fromRGB(100, 100, 100),
    Knob = Color3.fromRGB(255, 255, 255),
    DropdownBg = Color3.fromRGB(55, 55, 55),
    DropdownHover = Color3.fromRGB(70, 70, 70),
    SliderBg = Color3.fromRGB(70, 70, 70),
    SliderFill = Color3.fromRGB(0, 200, 0),
    ButtonBg = Color3.fromRGB(0, 150, 255),
    ButtonText = Color3.fromRGB(255, 255, 255),
    BubbleBg = Color3.fromRGB(0, 200, 0),
    BubbleText = Color3.fromRGB(255, 255, 255),
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernUIPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
local Menu = {}
Menu.__index = Menu
function Menu.new(config)
    local self = setmetatable({}, Menu)
    config = config or {}
    self.title = config.title or "CÀI ĐẶT"
    self.controls = {}
    self.controlFrames = {}
    self.callbacks = {}
    local bubble = Instance.new("TextButton")
    bubble.Name = "BubbleButton"
    bubble.Size = UDim2.new(0, 50, 0, 50)
    bubble.Position = UDim2.new(1, -65, 0, 20)
    bubble.BackgroundColor3 = COLORS.BubbleBg
    bubble.Text = "⚙"
    bubble.TextColor3 = COLORS.BubbleText
    bubble.Font = Enum.Font.SourceSansBold
    bubble.TextSize = 24
    bubble.ZIndex = 10
    bubble.Parent = screenGui
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubble
    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Color = Color3.fromRGB(255, 255, 255)
    bubbleStroke.Thickness = 2
    bubbleStroke.Parent = bubble
    self.bubble = bubble
    self.bubbleVisible = true
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.BackgroundColor3 = COLORS.Background
    mainFrame.Visible = true
    mainFrame.ZIndex = 5
    mainFrame.Parent = screenGui
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = COLORS.Border
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    self.mainFrame = mainFrame
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = COLORS.TitleBar
    titleBar.ZIndex = 6
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = self.title
    titleText.TextColor3 = COLORS.Text
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Active = false
    titleText.Parent = titleBar
    self.titleBar = titleBar
    self.titleText = titleText
    local leaderstatsFrame = Instance.new("Frame")
    leaderstatsFrame.Name = "LeaderstatsFrame"
    leaderstatsFrame.Size = UDim2.new(1, -30, 0, 60)
    leaderstatsFrame.Position = UDim2.new(0, 15, 0, 45)
    leaderstatsFrame.BackgroundColor3 = COLORS.Content
    leaderstatsFrame.ZIndex = 5
    leaderstatsFrame.Parent = mainFrame
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 10)
    statsCorner.Parent = leaderstatsFrame
    local statsStroke = Instance.new("UIStroke")
    statsStroke.Color = Color3.fromRGB(80, 80, 80)
    statsStroke.Thickness = 1
    statsStroke.Parent = leaderstatsFrame
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, -10, 1, 0)
    statsLabel.Position = UDim2.new(0, 5, 0, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.TextColor3 = COLORS.Text
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.TextSize = 14
    statsLabel.TextWrapped = true
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = leaderstatsFrame
    self.leaderstatsFrame = leaderstatsFrame
    self.statsLabel = statsLabel
    local function updateLeaderstats()
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            statsLabel.Text = "Không có leaderstats"
            return
        end
        local text = ""
        local count = 0
        for _, stat in ipairs(leaderstats:GetChildren()) do
            text = text .. stat.Name .. ": " .. tostring(stat.Value)
            count = count + 1
            if count % 3 == 0 then
                text = text .. "\n"
            else
                text = text .. "  |  "
            end
        end
        statsLabel.Text = text
    end
    spawn(function()
        while true do
            updateLeaderstats()
            wait(1)
        end
    end)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, -115)
    scrollFrame.Position = UDim2.new(0, 0, 0, 115)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = COLORS.Border
    scrollFrame.BorderSizePixel = 0
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ZIndex = 5
    scrollFrame.Parent = mainFrame
    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.FillDirection = Enum.FillDirection.Vertical
    scrollLayout.Padding = UDim.new(0, 8)
    scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent = scrollFrame
    self.scrollFrame = scrollFrame
    self.scrollLayout = scrollLayout
    self.isMinimized = false
    bubble.MouseButton1Click:Connect(function()
        self.isMinimized = not self.isMinimized
        mainFrame.Visible = not self.isMinimized
        if self.isMinimized then
            bubble.Text = "≡"
        else
            bubble.Text = "⚙"
        end
    end)
    local function dragBubble(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local startPos = input.Position
            local bubblePos = bubble.Position
            local offset = Vector2.new(startPos.X - bubblePos.X.Offset, startPos.Y - bubblePos.Y.Offset)
            local connection
            connection = UserInputService.InputChanged:Connect(function(inputChanged)
                if inputChanged.UserInputType == input.UserInputType and inputChanged.Position then
                    local newPos = inputChanged.Position - offset
                    local viewport = workspace.CurrentCamera.ViewportSize
                    local bubbleSize = bubble.AbsoluteSize
                    newPos = Vector2.new(
                        math.clamp(newPos.X, 0, viewport.X - bubbleSize.X),
                        math.clamp(newPos.Y, 0, viewport.Y - bubbleSize.Y)
                    )
                    bubble.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
                end
            end)
            local endedConnection
            endedConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded == input then
                    connection:Disconnect()
                    endedConnection:Disconnect()
                end
            end)
        end
    end
    bubble.InputBegan:Connect(dragBubble)
    local function dragMainFrame(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local startPos = input.Position
            local framePos = mainFrame.Position
            local offset = Vector2.new(startPos.X - framePos.X.Offset, startPos.Y - framePos.Y.Offset)
            local connection
            connection = UserInputService.InputChanged:Connect(function(inputChanged)
                if inputChanged.UserInputType == input.UserInputType and inputChanged.Position then
                    local newPos = inputChanged.Position - offset
                    local viewport = workspace.CurrentCamera.ViewportSize
                    local frameSize = mainFrame.AbsoluteSize
                    newPos = Vector2.new(
                        math.clamp(newPos.X, 0, viewport.X - frameSize.X),
                        math.clamp(newPos.Y, 0, viewport.Y - frameSize.Y)
                    )
                    mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
                end
            end)
            local endedConnection
            endedConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded == input then
                    connection:Disconnect()
                    endedConnection:Disconnect()
                end
            end)
        end
    end
    titleBar.InputBegan:Connect(dragMainFrame)
    self.controls = {}
    return self
end
function Menu:addToggle(label, default, callback)
    local frame = self:createBaseControl(label)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 50, 0, 26)
    switchFrame.Position = UDim2.new(1, -65, 0, 12)
    switchFrame.BackgroundColor3 = default and COLORS.ToggleOn or COLORS.ToggleOff
    switchFrame.Parent = frame
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 13)
    switchCorner.Parent = switchFrame
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, default and 27 or 3, 0, 3)
    knob.BackgroundColor3 = COLORS.Knob
    knob.Parent = switchFrame
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    local state = default
    local clickCatcher = Instance.new("TextButton")
    clickCatcher.Size = UDim2.new(1, 0, 1, 0)
    clickCatcher.BackgroundTransparency = 1
    clickCatcher.Text = ""
    clickCatcher.AutoButtonColor = false
    clickCatcher.Parent = frame
    clickCatcher.MouseButton1Click:Connect(function()
        state = not state
        switchFrame.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
        local targetPos = state and UDim2.new(0, 27, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        if callback then callback(state) end
    end)
    return frame
end
function Menu:addDropdown(label, options, defaultIndex, callback)
    if type(options) ~= "table" or #options == 0 then return end
    defaultIndex = defaultIndex or 1
    local selectedIndex = defaultIndex
    local frame = self:createBaseControl(label)
    local displayFrame = Instance.new("Frame")
    displayFrame.Size = UDim2.new(0, 120, 0, 30)
    displayFrame.Position = UDim2.new(1, -135, 0, 10)
    displayFrame.BackgroundColor3 = COLORS.DropdownBg
    displayFrame.Parent = frame
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 5)
    displayCorner.Parent = displayFrame
    local displayLabel = Instance.new("TextLabel")
    displayLabel.Size = UDim2.new(1, -25, 1, 0)
    displayLabel.Position = UDim2.new(0, 5, 0, 0)
    displayLabel.BackgroundTransparency = 1
    displayLabel.Text = tostring(options[defaultIndex])
    displayLabel.TextColor3 = COLORS.Text
    displayLabel.Font = Enum.Font.SourceSans
    displayLabel.TextSize = 14
    displayLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayLabel.Parent = displayFrame
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = COLORS.Text
    arrow.Font = Enum.Font.SourceSans
    arrow.TextSize = 14
    arrow.Parent = displayFrame
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(0, 120, 0, 100)
    dropdownList.Position = UDim2.new(1, -135, 0, 45)
    dropdownList.BackgroundColor3 = COLORS.DropdownBg
    dropdownList.ZIndex = 10
    dropdownList.Visible = false
    dropdownList.ScrollBarThickness = 4
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = Color3.fromRGB(100, 100, 100)
    dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dropdownList.Parent = frame
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    local optionButtons = {}
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = tostring(opt)
        optBtn.TextColor3 = COLORS.Text
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 14
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Parent = dropdownList
        optBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            displayLabel.Text = tostring(opt)
            dropdownList.Visible = false
            if callback then callback(opt, i) end
        end)
        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = COLORS.DropdownHover
            optBtn.BackgroundTransparency = 0.3
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundTransparency = 1
        end)
        table.insert(optionButtons, optBtn)
    end
    local toggleDropdown = Instance.new("TextButton")
    toggleDropdown.Size = UDim2.new(1, 0, 1, 0)
    toggleDropdown.BackgroundTransparency = 1
    toggleDropdown.Text = ""
    toggleDropdown.Parent = displayFrame
    toggleDropdown.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
    local function closeDropdown()
        dropdownList.Visible = false
    end
    local function onGlobalClick(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = input.Position
            local displayAbsPos = displayFrame.AbsolutePosition
            local displayAbsSize = displayFrame.AbsoluteSize
            local dropdownAbsPos = dropdownList.AbsolutePosition
            local dropdownAbsSize = dropdownList.AbsoluteSize
            local inDisplay = mousePos.X >= displayAbsPos.X and mousePos.X <= displayAbsPos.X + displayAbsSize.X and
                              mousePos.Y >= displayAbsPos.Y and mousePos.Y <= displayAbsPos.Y + displayAbsSize.Y
            local inDropdown = dropdownList.Visible and
                               mousePos.X >= dropdownAbsPos.X and mousePos.X <= dropdownAbsPos.X + dropdownAbsSize.X and
                               mousePos.Y >= dropdownAbsPos.Y and mousePos.Y <= dropdownAbsPos.Y + dropdownAbsSize.Y
            if not inDisplay and not inDropdown then
                dropdownList.Visible = false
            end
        end
    end
    UserInputService.InputBegan:Connect(onGlobalClick)
    return frame
end
function Menu:addSlider(label, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = default or (min + max) / 2
    local value = default
    local frame = self:createBaseControl(label)
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 25)
    valueLabel.Position = UDim2.new(1, -50, 0, 12)
    valueLabel.BackgroundColor3 = COLORS.Content
    valueLabel.Text = tostring(math.round(value))
    valueLabel.TextColor3 = COLORS.Text
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 14
    valueLabel.Parent = frame
    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(0, 4)
    valCorner.Parent = valueLabel
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -110, 0, 6)
    sliderBg.Position = UDim2.new(0, 15, 0, 22)
    sliderBg.BackgroundColor3 = COLORS.SliderBg
    sliderBg.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderBg
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.SliderFill
    sliderFill.Parent = sliderBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((value - min) / (max - min), -8, 0, -5)
    knob.BackgroundColor3 = COLORS.Knob
    knob.Text = ""
    knob.Parent = sliderBg
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    local dragging = false
    local dragOffset = 0
    local function updateSlider(inputPos)
        local sliderAbsPos = sliderBg.AbsolutePosition
        local sliderAbsSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp(inputPos.X - sliderAbsPos.X, 0, sliderAbsSize.X)
        local percent = relativeX / sliderAbsSize.X
        value = min + (max - min) * percent
        value = math.round(value)
        value = math.clamp(value, min, max)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0, -5)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end
    knob.MouseButton1Down:Connect(function(input)
        dragging = true
        local connection
        connection = UserInputService.InputChanged:Connect(function(inputChanged)
            if dragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(inputChanged.Position)
            end
        end)
        local endedConnection
        endedConnection = UserInputService.InputEnded:Connect(function(inputEnded)
            if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input.Position)
        end
    end)
    return frame
end
function Menu:addButton(label, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 40)
    frame.BackgroundColor3 = COLORS.Content
    frame.LayoutOrder = 1
    frame.Parent = self.scrollFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 1, -10)
    btn.Position = UDim2.new(0, 10, 0, 5)
    btn.BackgroundColor3 = COLORS.ButtonBg
    btn.Text = label
    btn.TextColor3 = COLORS.ButtonText
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return frame
end
function Menu:addLabel(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 1
    frame.Parent = self.scrollFrame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return frame
end
function Menu:createBaseControl(label)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 50)
    frame.BackgroundColor3 = COLORS.Content
    frame.LayoutOrder = 1
    frame.Parent = self.scrollFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Parent = frame
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -80, 1, 0)
    labelText.Position = UDim2.new(0, 15, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = COLORS.Text
    labelText.Font = Enum.Font.SourceSansBold
    labelText.TextSize = 16
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Active = false
    labelText.Parent = frame
    return frame
end
function Menu:setTitle(title)
    self.title = title
    self.titleText.Text = title
end
function Menu:show()
    self.mainFrame.Visible = true
    self.bubble.Text = "⚙"
    self.isMinimized = false
end
function Menu:hide()
    self.mainFrame.Visible = false
    self.bubble.Text = "≡"
    self.isMinimized = true
end
function Menu:destroy()
    self.mainFrame:Destroy()
    self.bubble:Destroy()
end
return Menu
