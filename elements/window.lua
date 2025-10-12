--[[
    Emochi UI Library - Window Element (GÜNCELLENMİŞ)
    Bu modül, GUI'nin ana penceresini oluşturur ve yönetir.
    Eklenen Özellikler:
    1. Minimize/Restore butonu: Pencereyi sadece başlık çubuğu boyutuna küçültür/eski boyutuna getirir.
    2. Maximize/Restore butonu: Pencereyi varsayılan boyutu ile büyük bir boyut arasında değiştirir.
    3. Opsiyonel Key System: Belirlenen bir tuş ile pencereyi açıp kapatma.
    4. Kapatma Butonu (Yeni): Pencereyi kalıcı olarak kapatır.
    5. Saydamlık Parametresi (Yeni): Pencerenin genel saydamlığını ayarlar.
    6. Mobil Giriş Engelleme: Mobil cihazlarda GUI etkileşimi sırasında kamera hareketini engeller.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Ana modül tablosu
local Window = {}
Window.__index = Window

--// TEMA AYARLARI //--
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

-- Tweening için sabit ayarlar
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local BUTTON_SIZE = UDim2.fromOffset(40, 40)
local LARGE_SIZE = UDim2.fromOffset(800, 600) -- Büyütme (Maximize) için kullanılacak hedef boyut

function Window:Create(options)
    options = options or {}
    local title = options.Title or "Emochi UI"
    local subTitle = options.SubTitle or "Version " .. (getfenv(0).Emochi and getfenv(0).Emochi.Ver or "1.0")
    local size = options.Size or UDim2.fromOffset(580, 460)
    local themeName = options.Theme or "Dark"
    local toggleKey = options.KeyCode -- Opsiyonel tuş kodu
    local opacity = options.Opacity or 0 -- Yeni Saydamlık parametresi (0 = Tamamen opak)
    local selectedTheme = Themes[themeName] or Themes.Dark

    local windowObject = setmetatable({}, Window)

    windowObject.ScreenGui = Instance.new("ScreenGui")
    windowObject.ScreenGui.Name = "Emochi_Window_Root"
    windowObject.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    windowObject.ScreenGui.ResetOnSpawn = false
    -- Mobil cihazlarda UI'ya tıklandığında kamera hareketini engellemek için eklendi.
    windowObject.ScreenGui.Modal = true 

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BackgroundTransparency = opacity -- Saydamlık uygulandı
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
    Header.BackgroundTransparency = opacity -- Saydamlık uygulandı
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    -- Üç buton (40x3=120) ve biraz boşluk için 130px ayarlandı
    TitleLabel.Size = UDim2.new(1, -130, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(10, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = selectedTheme.Text
    TitleLabel.Text = title
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Name = "SubTitleLabel"
    SubTitleLabel.Size = UDim2.new(1, -130, 1, 0)
    SubTitleLabel.Position = UDim2.fromOffset(TitleLabel.TextBounds.X + 15, 0)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.TextColor3 = selectedTheme.Accent
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.Parent = Header

    windowObject.Container = Instance.new("Frame")
    windowObject.Container.Name = "Container"
    windowObject.Container.Size = UDim2.new(1, -20, 1, -50)
    windowObject.Container.Position = UDim2.fromOffset(10, 40)
    windowObject.Container.BackgroundTransparency = 1
    windowObject.Container.Parent = MainFrame

    --// YENİ EKLEMELER //--

    -- Pencerenin başlangıç boyutunu ve konumunu sakla
    windowObject.InitialSize = size
    windowObject.InitialPosition = MainFrame.Position
    windowObject.IsMinimized = false
    windowObject.IsMaximized = false

    local function setSizeAndPosition(newSize, newPos)
        TweenService:Create(MainFrame, TWEEN_INFO, {Size = newSize, Position = newPos}):Play()
        -- Pencere yüksekliği 40'dan büyükse içeriği göster (Başlık çubuğunun yüksekliği)
        windowObject.Container.Visible = (newSize.Y.Offset > 40)
    end

    -- Kapatma Butonu (X) -- En sağda (40px)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = BUTTON_SIZE
    CloseButton.Position = UDim2.new(1, -40, 0, 0) -- Sağdan 40px
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- Kırmızı renk
    CloseButton.BackgroundTransparency = opacity -- Saydamlık uygulandı
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 20
    CloseButton.TextColor3 = Color3.new(1, 1, 1) -- Beyaz metin
    CloseButton.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        -- ScreenGui'yi yok ederek pencereyi tamamen kapat
        windowObject.ScreenGui:Destroy()
    end)

    -- 1. Minimize/Restore Butonu (Küçültme) -- Ortada (80px)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = BUTTON_SIZE
    MinimizeButton.Position = UDim2.new(1, -80, 0, 0) -- Sağdan 80px
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    MinimizeButton.BackgroundTransparency = opacity -- Saydamlık uygulandı
    MinimizeButton.Text = "—"
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.TextSize = 20
    MinimizeButton.TextColor3 = selectedTheme.Text
    MinimizeButton.Parent = Header

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 4)
    MinCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if not windowObject.IsMinimized then
            -- Küçült: Sadece başlık çubuğu yüksekliğine indir
            windowObject.IsMinimized = true
            setSizeAndPosition(UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, 40), MainFrame.Position)
        else
            -- Geri Yükle: Başlangıç boyutuna dön
            windowObject.IsMinimized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
        end
        -- Minimize/Restore yapıldığında Maximize durumunu resetle
        windowObject.IsMaximized = false
    end)


    -- 2. Maximize/Restore Butonu (Büyütme) -- En solda (120px)
    local MaximizeButton = Instance.new("TextButton")
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Size = BUTTON_SIZE
    MaximizeButton.Position = UDim2.new(1, -120, 0, 0) -- Sağdan 120px
    MaximizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    MaximizeButton.BackgroundTransparency = opacity -- Saydamlık uygulandı
    MaximizeButton.Text = "☐" -- Kare sembolü (Maximize)
    MaximizeButton.Font = Enum.Font.Gotham
    MaximizeButton.TextSize = 20
    MaximizeButton.TextColor3 = selectedTheme.Text
    MaximizeButton.Parent = Header

    local MaxCorner = Instance.new("UICorner")
    MaxCorner.CornerRadius = UDim.new(0, 4)
    MaxCorner.Parent = MaximizeButton
    
    MaximizeButton.MouseButton1Click:Connect(function()
        -- Eğer minimize edilmişse, öncelikle eski boyutuna getir
        if windowObject.IsMinimized then
            windowObject.IsMinimized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
            return
        end

        if not windowObject.IsMaximized then
            -- Büyüt: Daha büyük bir boyuta ve merkeze taşı
            windowObject.IsMaximized = true
            setSizeAndPosition(LARGE_SIZE, UDim2.fromScale(0.5, 0.5))
            MaximizeButton.Text = "⇆" -- Restore sembolü
        else
            -- Geri Yükle: Başlangıç boyutuna dön
            windowObject.IsMaximized = false
            setSizeAndPosition(windowObject.InitialSize, windowObject.InitialPosition)
            MaximizeButton.Text = "☐" -- Maximize sembolü
        end
    end)
    
    -- 3. Keysystem (Opsiyonel Tuş Sistemi)
    if toggleKey and typeof(toggleKey) == "EnumItem" then
        windowObject.ScreenGui.Enabled = false -- KeyCode varsa başlangıçta görünmez
        
        -- Kullanım amacını değiştirmemek için ScreenGui.Enabled durumunu kontrol eder
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == toggleKey then
                windowObject.ScreenGui.Enabled = not windowObject.ScreenGui.Enabled
            end
        end)
    else
        windowObject.ScreenGui.Enabled = true -- KeyCode yoksa başlangıçta görünür
    end

    -- Draggable Logic (Mevcut sürükleme mantığı)
    local dragging = false
    local dragInput, dragStart, startPosition
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
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


-- Modülü döndür
return Window
