--[[
    Emochi UI Library - Window Element (FINAL VERSION)
    This module creates and manages the main window element of the GUI.
    Features included:
    1. Minimize/Restore, Maximize/Restore, and Close buttons.
    2. Optional Key System for toggling visibility (options.KeyCode).
    3. Opacity Parameter (options.Opacity).
    4. Mobile Input Blocking (options.Modal).
    -- DRAG/CAMERA FIX: Header Frame Active özelliği eklendi ve sürükleme mantığı temizlendi.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Ana modül tablosu
local Window = {}
Window.__index = Window

--// THEME SETTINGS //--
local Themes = {
    Dark = {
        Background = Color3.fromRGB(35, 35, 45),
        Header = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(80, 120, 255),
        Outline = Color3.fromRGB(60, 60, 70)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Header = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 120, 255),
        Outline = Color3.fromRGB(200, 200, 200)
    }
}

-- Tweening constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local BUTTON_SIZE = UDim2.fromOffset(40, 40)
local LARGE_SIZE = UDim2.fromOffset(800, 600) -- Target size for Maximize

function Window:Create(options)
    options = options or {}
    local title = options.Title or "Emochi UI"
    local subTitle = options.SubTitle or "Version " .. (getfenv(0).Emochi and getfenv(0).Emochi.Ver or "1.0")
    local size = options.Size or UDim2.fromOffset(580, 460)
    local themeName = options.Theme or "Dark"
    local toggleKey = options.KeyCode -- Optional key code
    local opacity = options.Opacity or 0 -- Opacity parameter (0 = fully opaque)
    local isModal = options.Modal ~= false 
    local selectedTheme = Themes[themeName] or Themes.Dark

    local windowObject = setmetatable({}, Window)

    windowObject.ScreenGui = Instance.new("ScreenGui")
    windowObject.ScreenGui.Name = "Emochi_Window_Root"
    windowObject.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    windowObject.ScreenGui.ResetOnSpawn = false
    windowObject.ScreenGui.Modal = isModal 

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BackgroundTransparency = opacity -- Opacity applied
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = windowObject.ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = selectedTheme.Outline
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = selectedTheme.Header
    Header.BackgroundTransparency = opacity -- Opacity applied
    Header.BorderSizePixel = 0
    -- ÖNEMLİ DÜZELTME: Sürükleme sırasında kamera kaymasını engellemek için Frame'i aktif hale getiriyoruz.
    Header.Active = true 
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    -- Space for 3 buttons (120px) + margin
    TitleLabel.Size = UDim2.new(1, -130, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(10, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = selectedTheme.Text
    TitleLabel.Text = title
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    -- TitleLabel'ın sürüklemeyi kesmemesi için ZIndex ayarı
    TitleLabel.ZIndex = Header.ZIndex + 1 
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Header

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Name = "SubTitleLabel"
    SubTitleLabel.Size = UDim2.new(1, -130, 1, 0)
    -- This position calculation might need refinement based on font, but is set relative to Title
    SubTitleLabel.Position = UDim2.fromOffset(150, 0) 
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.TextColor3 = selectedTheme.Accent
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    -- SubTitleLabel'ın sürüklemeyi kesmemesi için ZIndex ayarı
    SubTitleLabel.ZIndex = Header.ZIndex + 1
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Parent = Header

    -- DÜĞMELERİN ZIndex'ini Başlık (Header) seviyesinin üzerine çıkarıyoruz.
    local buttonZIndex = Header.ZIndex + 2

    windowObject.Container = Instance.new("Frame")
    windowObject.Container.Name = "Container"
    windowObject.Container.Size = UDim2.new(1, -20, 1, -50)
    windowObject.Container.Position = UDim2.fromOffset(10, 40)
    windowObject.Container.BackgroundTransparency = 1
    windowObject.Container.Parent = MainFrame

    --// NEW FEATURES (Minimize, Maximize, Close, Opacity, KeySystem) //--

    -- Store initial size and state
    windowObject.InitialSize = size
    windowObject.InitialPosition = MainFrame.Position
    windowObject.IsMinimized = false
    windowObject.IsMaximized = false

    local function setSizeAndPosition(newSize, newPos)
        TweenService:Create(MainFrame, TWEEN_INFO, {Size = newSize, Position = newPos}):Play()
        -- Only show content if window height is greater than header height
        windowObject.Container.Visible = (newSize.Y.Offset > 40)
    end

    -- 1. Close Button (X) -- Far right (40px)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = BUTTON_SIZE
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) 
    CloseButton.BackgroundTransparency = opacity
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 20
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.ZIndex = buttonZIndex
    CloseButton.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        -- Destroy the ScreenGui to close the window completely
        windowObject.ScreenGui:Destroy()
    end)

    -- 2. Minimize/Restore Button (—) -- Middle (80px)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = BUTTON_SIZE
    MinimizeButton.Position = UDim2.new(1, -80, 0, 0) 
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    MinimizeButton.BackgroundTransparency = opacity
    MinimizeButton.Text = "—"
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.TextSize = 20
    MinimizeButton.TextColor3 = selectedTheme.Text
    MinimizeButton.ZIndex = buttonZIndex
    MinimizeButton.Parent = Header

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 4)
    MinCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if not windowObject.IsMinimized then
            -- Minimize: Shrink to header height
            windowObject.IsMinimized = true
            setSizeAndPosition(UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, 40), MainFrame.Position)
        else
            -- Restore: Return to initial size
            windowObject.IsMinimized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
        end
        -- Reset Maximize state upon Minimize/Restore
        windowObject.IsMaximized = false
        MaximizeButton.Text = "☐" 
    end)


    -- 3. Maximize/Restore Button (☐) -- Leftmost (120px)
    local MaximizeButton = Instance.new("TextButton")
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Size = BUTTON_SIZE
    MaximizeButton.Position = UDim2.new(1, -120, 0, 0)
    MaximizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    MaximizeButton.BackgroundTransparency = opacity
    MaximizeButton.Text = "☐" -- Square symbol (Maximize)
    MaximizeButton.Font = Enum.Font.Gotham
    MaximizeButton.TextSize = 20
    MaximizeButton.TextColor3 = selectedTheme.Text
    MaximizeButton.ZIndex = buttonZIndex
    MaximizeButton.Parent = Header

    local MaxCorner = Instance.new("UICorner")
    MaxCorner.CornerRadius = UDim.new(0, 4)
    MaxCorner.Parent = MaximizeButton
    
    MaximizeButton.MouseButton1Click:Connect(function()
        -- If minimized, restore it first
        if windowObject.IsMinimized then
            windowObject.IsMinimized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
            return
        end

        if not windowObject.IsMaximized then
            -- Maximize: Move to center and set large size
            windowObject.IsMaximized = true
            setSizeAndPosition(LARGE_SIZE, UDim2.fromScale(0.5, 0.5))
            MaximizeButton.Text = "⇆" -- Restore symbol
        else
            -- Restore: Return to initial size
            windowObject.IsMaximized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
            MaximizeButton.Text = "☐" -- Maximize symbol
        end
    end)
    
    -- 4. Keysystem (Optional Key System)
    if toggleKey and typeof(toggleKey) == "EnumItem" then
        windowObject.ScreenGui.Enabled = false -- Hidden by default if KeyCode is provided
        
        -- Controls ScreenGui.Enabled state
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == toggleKey then
                windowObject.ScreenGui.Enabled = not windowObject.ScreenGui.Enabled
            end
        end)
    else
        windowObject.ScreenGui.Enabled = true -- Visible by default if no KeyCode is provided
    end

    -- Draggable Logic (Existing drag logic)
    local dragging = false
    local dragInput, dragStart, startPosition
    
    Header.InputBegan:Connect(function(input)
        -- Yalnızca sol tık veya dokunmatik girişte sürüklemeyi başlat
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
        end
    end)
    
    -- YENİ: Sürüklemeyi bitirme mantığı
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                -- Sürükleme hareketini uygula
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPosition.X.Scale, startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    windowObject.ScreenGui.Parent = CoreGui
    
    return windowObject
end


-- Return the module table (this is essential for the require() function)
return Window
