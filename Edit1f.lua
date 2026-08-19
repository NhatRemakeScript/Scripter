local UI_Library = {}
UI_Library.__index = UI_Library

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function CreateGlassmorphismStyle(frame)
    frame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    frame.BackgroundTransparency = 0.75
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = frame
end

local function CreateNeonButton(parent, text, defaultState, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(30, 35, 50)
    button.BackgroundTransparency = 0.3
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = defaultState and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(80, 85, 100)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = button
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://13160454882"
    glow.ImageColor3 = Color3.fromRGB(0, 255, 255)
    glow.ImageTransparency = 0.8
    glow.Parent = button
    
    local isOn = defaultState or false
    
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        button.BackgroundColor3 = isOn and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(30, 35, 50)
        stroke.Color = isOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(80, 85, 100)
        glow.ImageTransparency = isOn and 0.5 or 0.8
        if callback then callback(isOn) end
    end)
    
    return button
end

local function CreateDropdown(parent, items, defaultIndex, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -30, 1, 0)
    selectedText.Position = UDim2.new(0, 10, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = items[defaultIndex or 1] or "Select"
    selectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedText.TextSize = 14
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.Parent = frame
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -25, 0, 10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(0, 255, 255)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.Gotham
    arrow.Parent = frame
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 0)
    dropdown.Position = UDim2.new(0, 0, 1, 2)
    dropdown.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    dropdown.BackgroundTransparency = 0.9
    dropdown.ClipsDescendants = true
    dropdown.Parent = frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdown
    
    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = Color3.fromRGB(0, 255, 255)
    dropdownStroke.Thickness = 1
    dropdownStroke.Transparency = 0.5
    dropdownStroke.Parent = dropdown
    
    local dropdownLayout = Instance.new("UIListLayout")
    dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropdownLayout.Padding = UDim.new(0, 2)
    dropdownLayout.Parent = dropdown
    
    local isOpen = false
    
    for i, item in ipairs(items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Size = UDim2.new(1, 0, 0, 30)
        itemButton.BackgroundTransparency = 1
        itemButton.Text = item
        itemButton.TextColor3 = Color3.fromRGB(200, 200, 220)
        itemButton.TextSize = 13
        itemButton.Font = Enum.Font.Gotham
        itemButton.Parent = dropdown
        
        itemButton.MouseButton1Click:Connect(function()
            selectedText.Text = item
            dropdown.Size = UDim2.new(1, 0, 0, 0)
            isOpen = false
            if callback then callback(item, i) end
        end)
    end
    
    frame.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local count = #items
            dropdown.Size = UDim2.new(1, 0, 0, count * 32)
        else
            dropdown.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    
    return frame
end

local function CreateScrollbar(parent, target, orientation)
    local scrollbar = Instance.new("Frame")
    scrollbar.Size = orientation == "Vertical" and UDim2.new(0, 6, 1, -10) or UDim2.new(1, -10, 0, 6)
    scrollbar.Position = orientation == "Vertical" and UDim2.new(1, -10, 0, 5) or UDim2.new(0, 5, 1, -10)
    scrollbar.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    scrollbar.BackgroundTransparency = 0.8
    scrollbar.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = scrollbar
    
    local handle = Instance.new("Frame")
    handle.Size = orientation == "Vertical" and UDim2.new(1, 0, 0, 50) or UDim2.new(0, 50, 1, 0)
    handle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    handle.BackgroundTransparency = 0.3
    handle.Parent = scrollbar
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    if orientation == "Vertical" then
        local dragging = false
        local dragStart = 0
        local startPos = 0
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position.Y
                startPos = handle.Position.Y.Scale
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = (input.Position.Y - dragStart) / scrollbar.AbsoluteSize.Y
                local newPos = math.clamp(startPos + delta, 0, 1 - handle.Size.Y.Scale)
                handle.Position = UDim2.new(0, 0, newPos, 0)
                target.CanvasPosition = Vector2.new(0, newPos * (target.CanvasSize.Y.Offset - target.AbsoluteSize.Y))
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        target:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            local maxScroll = target.CanvasSize.Y.Offset - target.AbsoluteSize.Y
            if maxScroll > 0 then
                local pos = target.CanvasPosition.Y / maxScroll
                handle.Position = UDim2.new(0, 0, pos, 0)
            end
        end)
    end
    
    return scrollbar
end

function UI_Library.CreateWindow(title)
    local self = setmetatable({}, UI_Library)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CyberGlassUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 900, 0, 600)
    self.MainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    self.MainFrame.Parent = self.ScreenGui
    CreateGlassmorphismStyle(self.MainFrame)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 300, 0, 40)
    titleLabel.Position = UDim2.new(0, 20, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "MENU CÀI ĐẶT"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = self.MainFrame
    
    local sepLine = Instance.new("Frame")
    sepLine.Size = UDim2.new(0, 880, 0, 1)
    sepLine.Position = UDim2.new(0, 10, 0, 65)
    sepLine.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    sepLine.BackgroundTransparency = 0.5
    sepLine.Parent = self.MainFrame
    
    self.ContentPanel = Instance.new("ScrollingFrame")
    self.ContentPanel.Size = UDim2.new(0, 650, 0, 520)
    self.ContentPanel.Position = UDim2.new(0, 20, 0, 80)
    self.ContentPanel.BackgroundTransparency = 1
    self.ContentPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentPanel.ScrollBarThickness = 0
    self.ContentPanel.Parent = self.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.Parent = self.ContentPanel
    
    CreateScrollbar(self.MainFrame, self.ContentPanel, "Vertical")
    
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 80, 0, 520)
    self.Sidebar.Position = UDim2.new(1, -100, 0, 80)
    self.Sidebar.BackgroundTransparency = 1
    self.Sidebar.Parent = self.MainFrame
    
    local sidebarSep = Instance.new("Frame")
    sidebarSep.Size = UDim2.new(0, 1, 0, 520)
    sidebarSep.Position = UDim2.new(0, -10, 0, 0)
    sidebarSep.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    sidebarSep.BackgroundTransparency = 0.3
    sidebarSep.Parent = self.Sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 10)
    sidebarLayout.Parent = self.Sidebar
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.TabButtons = {}
    
    self:AddTab("Home", "rbxassetid://13160454882")
    self:AddTab("Document", "rbxassetid://13160454882")
    self:AddTab("Settings", "rbxassetid://13160454882")
    self:AddTab("System", "rbxassetid://13160454882")
    self:AddTab("Exit", "rbxassetid://13160454882")
    
    if self.TabButtons[1] then
        self:SelectTab(1)
    end
    
    return self
end

function UI_Library:AddTab(tabName, iconId)
    local tab = {
        Name = tabName,
        IconId = iconId or "rbxassetid://13160454882",
        Elements = {}
    }
    table.insert(self.Tabs, tab)
    
    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, 40, 0, 40)
    button.BackgroundTransparency = 1
    button.Image = tab.IconId
    button.ImageColor3 = Color3.fromRGB(200, 200, 200)
    button.Parent = self.Sidebar
    
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 40, 0, 40)
    highlight.Position = UDim2.new(0, 0, 0, 0)
    highlight.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    highlight.BackgroundTransparency = 0.8
    highlight.Visible = false
    highlight.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = highlight
    
    tab.Button = button
    tab.Highlight = highlight
    tab.Content = Instance.new("Frame")
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Visible = false
    tab.Content.Parent = self.ContentPanel
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.Parent = tab.Content
    
    button.MouseButton1Click:Connect(function()
        local index = table.find(self.Tabs, tab)
        if index then self:SelectTab(index) end
    end)
    
    local tabHandler = {}
    tabHandler.AddSection = function(self, sectionTitle)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, 0, 0, 30)
        section.BackgroundTransparency = 1
        section.Text = sectionTitle
        section.TextColor3 = Color3.fromRGB(255, 255, 255)
        section.TextSize = 18
        section.Font = Enum.Font.GothamBold
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Parent = tab.Content
        
        local underline = Instance.new("Frame")
        underline.Size = UDim2.new(0, string.len(sectionTitle) * 8, 0, 2)
        underline.Position = UDim2.new(0, 0, 1, 2)
        underline.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        underline.BackgroundTransparency = 0.3
        underline.Parent = section
        
        return section
    end
    
    tabHandler.AddParagraph = function(self, title, desc)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = tab.Content
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame
        
        if desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 20)
            descLabel.Position = UDim2.new(0, 0, 0, 22)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = desc
            descLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            descLabel.TextSize = 12
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = frame
        end
        
        return frame
    end
    
    tabHandler.AddToggle = function(self, text, defaultState, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = tab.Content
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 200, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 10)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.TextSize = 14
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggle = CreateNeonButton(frame, defaultState and "AUTO" or "TẮT", defaultState, function(state)
            toggle.Text = state and "AUTO" or "TẮT"
            if callback then callback(state) end
        end)
        toggle.Position = UDim2.new(0, 400, 0, 5)
        
        return toggle
    end
    
    tabHandler.AddLabel = function(self, text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(180, 180, 200)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tab.Content
        return label
    end
    
    tabHandler.AddDropdown = function(self, items, defaultIndex, callback)
        return CreateDropdown(tab.Content, items, defaultIndex, callback)
    end
    
    tabHandler.AddScrollbar = function(self, orientation)
        return CreateScrollbar(tab.Content, tab.Content, orientation)
    end
    
    return tabHandler
end

function UI_Library:SelectTab(index)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        if self.CurrentTab.Highlight then
            self.CurrentTab.Highlight.Visible = false
        end
    end
    
    local tab = self.Tabs[index]
    if tab then
        tab.Content.Visible = true
        if tab.Highlight then
            tab.Highlight.Visible = true
        end
        self.CurrentTab = tab
    end
end

function UI_Library:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return UI_Library
