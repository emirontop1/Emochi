--[[
    Emochi UI Library - Window Element (Rewrite & Stabilized)
    
    Bu dosya, önceki tüm hataları (TweenService nil, ScreenGui.Modal) düzeltir
    ve orijinal Emochi UI özelliklerini (Opacity, Minimize/Maximize, KeyCode, Dragging) korur.
]]

-- Gerekli Servisler
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- TweenService'ı güvenli bir şekilde almayı dene (Önceki hatayı düzeltir)
local TweenService
local CanUseTween = false
local success, service = pcall(function()
    return game:GetService("TweenService")
end)

if success and service and service:IsA("TweenService") then
    TweenService = service
    CanUseTween = true
end

-- Tweening sabitleri (TweenService bulunamasa bile tanımlı kalır)
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local BUTTON_SIZE = UDim2.fromOffset(40, 40)
local MAXIMIZE_SIZE = UDim2.fromScale(0.9, 0.9) -- Ekranın %90'ı büyüklüğünde

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
    }
}

function Window:Create(options)
    options = options or {}
    local title = options.Title or "Emochi UI"
    local subTitle = options.SubTitle or "Version 1.4"
    local size = options.Size or UDim2.fromOffset(580, 460)
    local toggleKey = options.KeyCode or Enum.KeyCode.F2 -- Varsayılan F2
    local opacity = options.Opacity or 0 -- 0 = tamamen opak (tam görünür)

    local selectedTheme = Themes[options.Theme or "Dark"] or Themes.Dark

    local windowObject = setmetatable({}, Window)

    -- ScreenGui (Modal özelliği kaldırıldı)
    windowObject.ScreenGui = Instance.new("ScreenGui")
    windowObject.ScreenGui.Name = "Emochi_Window_Root"
    windowObject.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    windowObject.ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BackgroundTransparency = opacity
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = windowObject.ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = selectedTheme.Outline
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame

    -- Header (Başlık Çubuğu)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = selectedTheme.Header
    Header.BackgroundTransparency = opacity
    Header.BorderSizePixel = 0
    Header.Active = true -- Sürükleme için aktif
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -130, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(10, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = selectedTheme.Text
    TitleLabel.Text = title
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextWrapped = true
    TitleLabel.Parent = Header

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Name = "SubTitleLabel"
    SubTitleLabel.Size = UDim2.new(1, -130, 1, 0)
    SubTitleLabel.Position = UDim2.fromOffset(10 + 100, 0)  
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.TextSize = 14
    SubTitleLabel.TextColor3 = selectedTheme.Accent
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.TextWrapped = true
    SubTitleLabel.Parent = Header

    -- İçerik Konteyneri
    windowObject.Container = Instance.new("Frame")
    windowObject.Container.Name = "Container"
    windowObject.Container.Size = UDim2.new(1, -20, 1, -50)
    windowObject.Container.Position = UDim2.fromOffset(10, 40)
    windowObject.Container.BackgroundTransparency = 1
    windowObject.Container.Parent = MainFrame

    windowObject.InitialSize = size
    windowObject.InitialPosition = MainFrame.Position
    windowObject.IsMinimized = false
    windowObject.IsMaximized = false
    windowObject.IsShown = false -- Başlangıçta gizli keycode varsa

    -- Hata önleyici setSizeAndPosition fonksiyonu
    local function setSizeAndPosition(newSize, newPos)
        if CanUseTween and TweenService then
            -- TweenService varsa animasyon yap
            local tween = TweenService:Create(MainFrame, TWEEN_INFO, {Size = newSize, Position = newPos})
            pcall(function() tween:Play() end) -- Play'de çökme ihtimaline karşı pcall
        else
            -- TweenService yoksa anında ayarla (Çökme önleme)
            MainFrame.Size = newSize
            MainFrame.Position = newPos
        end
        windowObject.Container.Visible = (newSize.Y.Offset > 40)
    end

    -- Buton Oluşturucu Fonksiyon
    local function createButton(name, color, text, position)
        local Button = Instance.new("TextButton")
        Button.Name = name
        Button.Size = BUTTON_SIZE
        Button.Position = position
        Button.BackgroundColor3 = color
        Button.BackgroundTransparency = opacity
        Button.Text = text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 20
        Button.TextColor3 = selectedTheme.Text
        Button.ZIndex = Header.ZIndex + 2
        Button.Parent = Header
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = Button
        
        return Button
    end
    
    local CloseButton = createButton("CloseButton", Color3.fromRGB(200, 60, 60), "X", UDim2.new(1, -40, 0, 0))
    CloseButton.MouseButton1Click:Connect(function()
        windowObject.ScreenGui:Destroy()
        -- Global tablo temizliği ekle
        if shared.Emochi_UI_Loaded then
            shared.Emochi_UI_Loaded = nil
        end
    end)

    local MinimizeButton = createButton("MinimizeButton", Color3.fromRGB(80, 80, 90), "—", UDim2.new(1, -80, 0, 0))
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if not windowObject.IsMinimized then
            windowObject.IsMinimized = true
            -- Yüksekliği sadece başlık çubuğu kadar yap
            setSizeAndPosition(UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, 40), MainFrame.Position)
        else
            windowObject.IsMinimized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
        end
        windowObject.IsMaximized = false
        MaximizeButton.Text = "☐" 
    end)

    local MaximizeButton = createButton("MaximizeButton", Color3.fromRGB(80, 80, 90), "☐", UDim2.new(1, -120, 0, 0))
    
    MaximizeButton.MouseButton1Click:Connect(function()
        if windowObject.IsMinimized then
            windowObject.IsMinimized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
            return
        end

        if not windowObject.IsMaximized then
            windowObject.IsMaximized = true
            -- Pozisyonu ekranın ortasına ayarla
            setSizeAndPosition(MAXIMIZE_SIZE, UDim2.fromScale(0.5, 0.5))
            MaximizeButton.Text = "⇆"
        else
            windowObject.IsMaximized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
            MaximizeButton.Text = "☐"
        end
    end)
    
    -- Pencereyi açıp kapatmak için tuş sistemi
    if toggleKey and typeof(toggleKey) == "EnumItem" then
        windowObject.ScreenGui.Enabled = false
        windowObject.IsShown = false
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == toggleKey then
                windowObject.ScreenGui.Enabled = not windowObject.ScreenGui.Enabled
                windowObject.IsShown = windowObject.ScreenGui.Enabled
            end
        end)
    else
        -- Keycode yoksa her zaman açık
        windowObject.ScreenGui.Enabled = true
        windowObject.IsShown = true
    end

    -- Pencere Sürükleme Mantığı
    local dragging = false
    local dragStart, startPosition
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not windowObject.IsMaximized and not windowObject.IsMinimized and windowObject.IsShown then
                dragging = true
                dragStart = input.Position
                startPosition = MainFrame.Position
            end
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.Touch then
            if dragging then
                local delta = input.Position - dragStart
                local newX = startPosition.X.Offset + delta.X
                local newY = startPosition.Y.Offset + delta.Y
                
                -- Ekran sınırları içinde kalmasını sağla (Taşmayı önler)
                local maxX = MainFrame.Parent.AbsoluteSize.X - MainFrame.AbsoluteSize.X
                local maxY = MainFrame.Parent.AbsoluteSize.Y - MainFrame.AbsoluteSize.Y
                
                newX = math.max(0, math.min(newX, maxX))
                newY = math.max(0, math.min(newY, maxY))
                
                -- AnchorPoint (0.5, 0.5) olduğu için hesaplama biraz farklıdır
                -- Bu yüzden burada UDim2.fromOffset kullanarak kesin pozisyon veririz:
                MainFrame.Position = UDim2.fromOffset(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y)
            end
        end
    end)
    
    windowObject.ScreenGui.Parent = CoreGui
    
    return windowObject
end

return Window
