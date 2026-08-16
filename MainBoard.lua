local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local COLORS = {
    Background = Color3.fromRGB(20, 20, 25),      -- Màu nền chính
    Surface = Color3.fromRGB(30, 30, 38),         -- Màu bề mặt
    SurfaceLight = Color3.fromRGB(45, 45, 55),    -- Màu bề mặt sáng
    Primary = Color3.fromRGB(88, 101, 242),       -- Màu chính (Discord Blurple)
    PrimaryHover = Color3.fromRGB(105, 118, 255), -- Hover
    PrimaryActive = Color3.fromRGB(65, 78, 210),  -- Active
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    ToggleOn = Color3.fromRGB(88, 101, 242),
    ToggleOff = Color3.fromRGB(70, 70, 80),
    DropdownBg = Color3.fromRGB(40, 40, 48),
    DropdownHover = Color3.fromRGB(55, 55, 65),
    Border = Color3.fromRGB(50, 50, 60),
    ScrollBar = Color3.fromRGB(70, 70, 85),
    ScrollBarHover = Color3.fromRGB(100, 100, 120),
    Danger = Color3.fromRGB(237, 66, 69),
    Success = Color3.fromRGB(60, 200, 120),
}

-- ============ TẠO SCREEN GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernMenu"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============ TẠO MAIN FRAME ============
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 550)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -275)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Bo góc
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Viền mờ
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = COLORS.Border
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

-- Đổ bóng (Shadow)
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://13160448870"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- ============ HEADER ============
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = COLORS.Surface
Header.BackgroundTransparency = 0.5
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Chỉ bo góc trên
local HeaderCorner2 = Instance.new("UICorner")
HeaderCorner2.CornerRadius = UDim.new(0, 12)
HeaderCorner2.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚙ CÀI ĐẶT NÂNG CAO"
Title.TextColor3 = COLORS.Text
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamSemibold
Title.Parent = Header

-- Nút Close
local CloseBtn = Instance.new("ImageButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://10747356900"
CloseBtn.ImageColor3 = COLORS.TextSecondary
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    task.wait(0.25)
    ScreenGui:Destroy()
end)

-- ============ SCROLLING FRAME (Thanh cuộn) ============
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, 0, 1, -56)
ScrollContainer.Position = UDim2.new(0, 0, 0, 56)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.ScrollBarImageColor3 = COLORS.ScrollBar
ScrollContainer.ScrollBarImageTransparency = 0.3
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.Parent = MainFrame

-- Canvas layout
local CanvasLayout = Instance.new("UIListLayout")
CanvasLayout.Name = "CanvasLayout"
CanvasLayout.Padding = UDim.new(0, 8)
CanvasLayout.SortOrder = Enum.SortOrder.LayoutOrder
CanvasLayout.Parent = ScrollContainer

-- Padding trong
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 16)
UIPadding.PaddingRight = UDim.new(0, 16)
UIPadding.PaddingTop = UDim.new(0, 12)
UIPadding.PaddingBottom = UDim.new(0, 12)
UIPadding.Parent = ScrollContainer

-- ============ HÀM TẠO SECTION ============
local function CreateSection(title)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.BackgroundTransparency = 1
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.Parent = ScrollContainer
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Size = UDim2.new(1, 0, 0, 24)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = COLORS.TextSecondary
    SectionTitle.TextSize = 12
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Parent = Section
    
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.new(0, 0, 0, 28)
    Content.BackgroundTransparency = 1
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.Parent = Section
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Name = "ContentLayout"
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Content
    
    return Content
end

-- ============ HÀM TẠO TOGGLE (Công tắc) ============
local function CreateToggle(parent, labelText, defaultState, callback)
    local state = defaultState or false
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
    ToggleFrame.BackgroundColor3 = COLORS.Surface
    ToggleFrame.BackgroundTransparency = 0.5
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.AutomaticSize = Enum.AutomaticSize.None
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = COLORS.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.Parent = ToggleFrame
    
    -- Switch container
    local SwitchFrame = Instance.new("Frame")
    SwitchFrame.Name = "SwitchFrame"
    SwitchFrame.Size = UDim2.new(0, 44, 0, 24)
    SwitchFrame.Position = UDim2.new(1, -54, 0.5, -12)
    SwitchFrame.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
    SwitchFrame.BackgroundTransparency = 0.3
    SwitchFrame.BorderSizePixel = 0
    SwitchFrame.Parent = ToggleFrame
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchFrame
    
    -- Knob (nút tròn)
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = state and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchFrame
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    -- Nút bấm (che phủ toàn bộ)
    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Parent = ToggleFrame
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        
        -- Animation đổi màu
        local targetColor = state and COLORS.ToggleOn or COLORS.ToggleOff
        TweenService:Create(SwitchFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor,
            BackgroundTransparency = 0.3
        }):Play()
        
        -- Animation trượt knob
        local targetPos = state and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()
        
        if callback then callback(state) end
    end)
    
    return ToggleFrame
end

-- ============ HÀM TẠO DROPDOWN ============
local function CreateDropdown(parent, labelText, options, defaultIndex, callback)
    local isOpen = false
    local selectedIndex = defaultIndex or 1
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "DropdownFrame"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
    DropdownFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = COLORS.TextSecondary
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.Parent = DropdownFrame
    
    -- Main button
    local DropdownBtn = Instance.new("ImageButton")
    DropdownBtn.Name = "DropdownBtn"
    DropdownBtn.Size = UDim2.new(1, 0, 0, 38)
    DropdownBtn.Position = UDim2.new(0, 0, 0, 24)
    DropdownBtn.BackgroundColor3 = COLORS.Surface
    DropdownBtn.BackgroundTransparency = 0.5
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = DropdownBtn
    
    local BtnText = Instance.new("TextLabel")
    BtnText.Name = "BtnText"
    BtnText.Size = UDim2.new(1, -40, 1, 0)
    BtnText.Position = UDim2.new(0, 12, 0, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = options[selectedIndex] or "Chọn..."
    BtnText.TextColor3 = COLORS.Text
    BtnText.TextSize = 14
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.Font = Enum.Font.Gotham
    BtnText.Parent = DropdownBtn
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -36, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▾"
    Arrow.TextColor3 = COLORS.TextSecondary
    Arrow.TextSize = 18
    Arrow.Font = Enum.Font.Gotham
    Arrow.Parent = DropdownBtn
    
    -- Dropdown list
    local DropdownList = Instance.new("Frame")
    DropdownList.Name = "DropdownList"
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 66)
    DropdownList.BackgroundColor3 = COLORS.Surface
    DropdownList.BackgroundTransparency = 0.95
    DropdownList.BorderSizePixel = 0
    DropdownList.ClipsDescendants = true
    DropdownList.Visible = false
    DropdownList.AutomaticSize = Enum.AutomaticSize.Y
    DropdownList.Parent = DropdownFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 8)
    ListCorner.Parent = DropdownList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Name = "ListLayout"
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropdownList
    
    -- Tạo các option
    local optionButtons = {}
    for i, option in ipairs(options) do
        local OptBtn = Instance.new("ImageButton")
        OptBtn.Name = "OptBtn_" .. i
        OptBtn.Size = UDim2.new(1, 0, 0, 32)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Parent = DropdownList
        
        local OptText = Instance.new("TextLabel")
        OptText.Name = "OptText"
        OptText.Size = UDim2.new(1, -16, 1, 0)
        OptText.Position = UDim2.new(0, 12, 0, 0)
        OptText.BackgroundTransparency = 1
        OptText.Text = option
        OptText.TextColor3 = COLORS.Text
        OptText.TextSize = 14
        OptText.TextXAlignment = Enum.TextXAlignment.Left
        OptText.Font = Enum.Font.Gotham
        OptText.Parent = OptBtn
        
        -- Hover effect
        OptBtn.MouseEnter:Connect(function()
            OptBtn.BackgroundTransparency = 0.6
            OptBtn.BackgroundColor3 = COLORS.DropdownHover
        end)
        OptBtn.MouseLeave:Connect(function()
            OptBtn.BackgroundTransparency = 1
        end)
        
        OptBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            BtnText.Text = option
            callback and callback(option, i)
            isOpen = false
            DropdownList.Visible = false
            Arrow.Text = "▾"
        end)
        
        optionButtons[i] = OptBtn
    end
    
    -- Toggle dropdown
    DropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownList.Visible = isOpen
        Arrow.Text = isOpen and "▴" or "▾"
        
        if isOpen then
            -- Cập nhật kích thước canvas
            local count = #options
            local height = math.min(count * 34 + 8, 200)
            DropdownList.Size = UDim2.new(1, 0, 0, height)
            DropdownList.BackgroundTransparency = 0.95
        end
    end)
    
    return DropdownFrame
end

-- ============ HÀM TẠO BUTTON ============
local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("ImageButton")
    Btn.Name = "Button"
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = color or COLORS.Primary
    Btn.BackgroundTransparency = 0.8
    Btn.BorderSizePixel = 0
    Btn.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    local BtnText = Instance.new("TextLabel")
    BtnText.Name = "BtnText"
    BtnText.Size = UDim2.new(1, 0, 1, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = text
    BtnText.TextColor3 = COLORS.Text
    BtnText.TextSize = 14
    BtnText.Font = Enum.Font.GothamSemibold
    BtnText.Parent = Btn
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.5,
            BackgroundColor3 = color or COLORS.PrimaryHover
        }):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.8,
            BackgroundColor3 = color or COLORS.Primary
        }):Play()
    end)
    
    Btn.MouseButton1Click:Connect(function()
        -- Hiệu ứng click
        TweenService:Create(Btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, -4, 0, 36)
        }):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 40)
        }):Play()
        
        if callback then callback() end
    end)
    
    return Btn
end

-- ============ XÂY DỰNG MENU ============

-- Section 1: Âm thanh
local SoundSection = CreateSection("🔊 ÂM THANH")
local toggleSound = CreateToggle(SoundSection, "Âm thanh nền", true, function(state)
    print("Âm thanh nền:", state and "BẬT" or "TẮT")
end)

-- Section 2: Giao diện
local UISection = CreateSection("🎨 GIAO DIỆN")
local toggleAnim = CreateToggle(UISection, "Hiệu ứng chuyển động", true, function(state)
    print("Hiệu ứng:", state and "BẬT" or "TẮT")
end)

local toggleBlur = CreateToggle(UISection, "Hiệu ứng mờ", false, function(state)
    print("Mờ:", state and "BẬT" or "TẮT")
end)

-- Section 3: Chủ đề
local ThemeSection = CreateSection("🎭 CHỦ ĐỀ")
local dropdownTheme = CreateDropdown(ThemeSection, "Chọn chủ đề", {"Tối", "Sáng", "Tự động"}, 1, function(option, index)
    print("Đã chọn chủ đề:", option)
end)

-- Section 4: Hành động
local ActionSection = CreateSection("⚡ HÀNH ĐỘNG")

local btnSave = CreateButton(ActionSection, "💾 LƯU CÀI ĐẶT", COLORS.Primary, function()
    print("Đã lưu cài đặt!")
end)

local btnReset = CreateButton(ActionSection, "🔄 KHÔI PHỤC MẶC ĐỊNH", COLORS.Danger, function()
    print("Đã khôi phục mặc định!")
end)

-- ============ HIỆU ỨNG MỞ MENU ============
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

task.wait(0.1)

TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 550),
    Position = UDim2.new(0.5, -210, 0.5, -275)
}):Play()

-- ============ XỬ LÝ KÉO THẢ (Draggable) ============
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
