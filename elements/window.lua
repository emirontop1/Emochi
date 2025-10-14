--[[
    Emochi UI - Window Modülü (Modern Fluent Tasarıma Güncellenmiş ve Hataları Giderilmiş Versiyon)
]]

-- Roblox Servisleri
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Loader'da oluşturulan ana Emochi tablosuna 'shared' üzerinden erişim
local Emochi = shared.Emochi_UI

-- Pencere modülünün kendisi
local WindowModule = {}

-- Temalar
local ThemeColors = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25), 
        Primary = Color3.fromRGB(30, 30, 38), 
        Secondary = Color3.fromRGB(30, 30, 38), 
        Accent = Color3.fromRGB(0, 120, 212),
        Text = Color3.fromRGB(240, 240, 240), SubText = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(15, 15, 20), Shadow = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245), Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(230, 230, 230), Accent = Color3.fromRGB(0, 122, 255),
        Text = Color3.fromRGB(20, 20, 20), SubText = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(210, 210, 210), Shadow = Color3.fromRGB(180, 180, 180)
    },
    Dracula = {
        Background = Color3.fromRGB(40, 42, 54), Primary = Color3.fromRGB(68, 71, 90),
        Secondary = Color3.fromRGB(68, 71, 90), Accent = Color3.fromRGB(189, 147, 249),
        Text = Color3.fromRGB(248, 248, 242), SubText = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(30, 31, 41), Shadow = Color3.fromRGB(0, 0, 0)
    }
}

-- Yardımcı Fonksiyonlar
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Animate(instance, goal, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, goal)
    tween:Play()
    return tween
end

-- Pencere Metotları
local WindowProto = {}
WindowProto.__index = WindowProto

function WindowProto:SetVisible(visible)
    self.Visible = visible
    local goalPosition = self.InitialPosition
    local goalTransparency = visible and 0 or 1

    if not visible then
        goalPosition = self.InitialPosition + UDim2.fromOffset(0, 30)
    end
    
    -- Pencere Ana Çerçeve Animasyonu
    Animate(self.Instance, {Position = goalPosition}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- İçerik Şeffaflık Animasyonu (Sadece görünmez yaparken tetiklenmeli)
    for _, child in ipairs(self.Instance:GetDescendants()) do
        if child:IsA("GuiObject") and child.Name ~= "Shadow" then
            -- GuiObject'leri sadece BackgroundTransparency/ImageTransparency için animasyonla
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                Animate(child, {TextTransparency = goalTransparency}, 0.3)
                Animate(child, {BackgroundTransparency = goalTransparency}, 0.3)
            elseif child:IsA("ImageLabel") then
                Animate(child, {ImageTransparency = goalTransparency}, 0.3)
            elseif not child:IsA("UIComponent") then
                 Animate(child, {BackgroundTransparency = goalTransparency}, 0.3)
            end
        end
    end
    Animate(self.Instance, {BackgroundTransparency = goalTransparency}, 0.3)
    
    -- Remote Minimize Butonu görünürlüğünü yönetme
    if self.MinimizeButton then
        self.MinimizeButton.ImageTransparency = visible and 1 or 0
    end
end

function WindowProto:Toggle()
    self:SetVisible(not self.Visible)
end

function WindowProto:Destroy()
    if self.InputConnection then
        self.InputConnection:Disconnect()
        self.InputConnection = nil
    end

    if self.MinimizeButton then
        self.MinimizeButton:Destroy()
    end

    local size = self.Instance.AbsoluteSize
    Animate(self.Instance, {Size = UDim2.fromOffset(0, 0), Position = self.Instance.Position + UDim2.fromOffset(size.X/2, size.Y/2)}, 0.3, Enum.EasingStyle.Quad)
    
    task.wait(0.3)
    self.Instance:Destroy()
    table.remove(Emochi.ActiveWindows, table.find(Emochi.ActiveWindows, self))
end

-- Ana Pencere Oluşturma Fonksiyonu
function WindowModule:Create(options)
    options = options or {}
    local newWindow = setmetatable({}, WindowProto)

    local config = {
        Title = options.Title or "Emochi UI",
        SubTitle = options.SubTitle or "Version " .. Emochi.Version,
        Size = options.Size or UDim2.fromOffset(650, 450), 
        Theme = options.Theme or "Dark",
        Draggable = options.Draggable ~= nil and options.Draggable or true,
        Closable = options.Closable ~= nil and options.Closable or true,
        MinimizeKey = options.MinimizeKey or Enum.KeyCode.RightControl,
        InitialPosition = options.InitialPosition,
        ShadowEnabled = options.ShadowEnabled ~= nil and options.ShadowEnabled or true,
        BlurIntensity = options.BlurIntensity or 0,
        CornerRadius = options.CornerRadius or UDim.new(0, 12),
        HeaderHeight = options.HeaderHeight or 36,
        MinimizeMobileButton = options.MinimizeMobileButton ~= nil and options.MinimizeMobileButton or false, 
        TabAreaWidth = options.TabAreaWidth or 160 
    }

    local colors = ThemeColors[config.Theme] or ThemeColors.Dark

    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("EmochiScreenGui")
    if not screenGui then
        screenGui = CreateInstance("ScreenGui", { Name = "EmochiScreenGui", Parent = playerGui, ZIndexBehavior = Enum.ZIndexBehavior.Global, ResetOnSpawn = false })
    end

    local windowFrame = CreateInstance("Frame", {
        Name = "WindowFrame", Parent = screenGui, Size = config.Size,
        Position = config.InitialPosition or UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(config.Size.X.Offset / 2, config.Size.Y.Offset / 2),
        BackgroundColor3 = colors.Background, BorderSizePixel = 0, ClipsDescendants = true,
        ZIndex = 1 -- Varsayılan ZIndex
    })
    
    newWindow.Instance = windowFrame
    newWindow.InitialPosition = windowFrame.Position
    newWindow.Visible = true

    -- Ana pencere için köşeler (smooth)
    CreateInstance("UICorner", { CornerRadius = config.CornerRadius, Parent = windowFrame })

    if config.ShadowEnabled then
        CreateInstance("ImageLabel", { Name = "Shadow", Parent = windowFrame, Size = UDim2.new(1, 24, 1, 24), Position = UDim2.new(0, -12, 0, -12),
            BackgroundTransparency = 1, Image = "rbxassetid://6373824844", ImageColor3 = colors.Shadow,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 25, 25), ZIndex = -1 })
    end

    if config.BlurIntensity > 0 then
        CreateInstance("UIBlur", { Name = "BackgroundBlur", Parent = windowFrame, Size = config.BlurIntensity * 24 })
    end
    
    -- #region SOL TAB ALANI

    local tabContainer = CreateInstance("Frame", { 
        Name = "TabContainer", Parent = windowFrame, 
        -- Yükseklik: Toplam yükseklik - Header yüksekliği
        Size = UDim2.new(0, config.TabAreaWidth, 1, -config.HeaderHeight), 
        -- Konum: Başlık Çubuğunun hemen altından başla
        Position = UDim2.new(0, 0, 0, config.HeaderHeight), 
        BackgroundColor3 = colors.Secondary, BorderSizePixel = 0, ZIndex = 2,
        ClipsDescendants = true
    })

    -- Sol Tab Alanı Köşesi (Alt-Sol Köşe)
    -- Üst sol köşe Başlık Çubuğu tarafından kontrol edildiği için sadece alt-sol yuvarlatılır
    CreateInstance("UICorner", { 
        CornerRadius = config.CornerRadius, 
        Parent = tabContainer,
    }) 
    
    local tabButtonHolder = CreateInstance("ScrollingFrame", {
        Name = "TabButtonHolder", Parent = tabContainer,
        Size = UDim2.new(1, -20, 1, -10),
        Position = UDim2.fromOffset(10, 5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = colors.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.fromScale(0, 0)
    })
    
    CreateInstance("UIListLayout", { 
        Parent = tabButtonHolder, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        Padding = UDim.new(0, 6) 
    })

    newWindow.TabContainer = tabButtonHolder

    -- #endregion

    -- #region BAŞLIK ÇUBUĞU (HEADER)
    
    local header = CreateInstance("Frame", { 
        Name = "Header", Parent = windowFrame, 
        Size = UDim2.new(1, 0, 0, config.HeaderHeight), 
        BackgroundColor3 = colors.Primary, BorderSizePixel = 0,
        ZIndex = 3 -- Header her zaman üstte olmalı
    })
    
    -- Başlık Çubuğu Köşeleri (Üst-Sol ve Üst-Sağ)
    CreateInstance("UICorner", { CornerRadius = config.CornerRadius, Parent = header })

    local titleLabel = CreateInstance("TextLabel", { 
        Name = "Title", Parent = header, 
        -- Genişlik: Toplam - Tab Genişliği - Boşluk
        Size = UDim2.new(1, -config.TabAreaWidth - 60, 1, 0), 
        -- Konum: Tab Genişliği + Sağ boşluktan başla
        Position = UDim2.new(0, config.TabAreaWidth + 10, 0, 0), 
        Text = "<b>" .. config.Title .. "</b>",
        RichText = true, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = colors.Text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 
    })

    CreateInstance("TextLabel", { 
        Name = "SubTitle", Parent = titleLabel, 
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 15), Text = config.SubTitle,
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = colors.SubText, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 
    })

    if config.Closable then
        local closeButton = CreateInstance("TextButton", { 
            Name = "CloseButton", Parent = header, 
            Size = UDim2.fromOffset(config.HeaderHeight, config.HeaderHeight),
            Position = UDim2.new(1, -config.HeaderHeight, 0, 0), 
            BackgroundColor3 = colors.Primary, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = colors.Text,
            ZIndex = 4
        })
        closeButton.MouseEnter:Connect(function() Animate(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2) end)
        closeButton.MouseLeave:Connect(function() Animate(closeButton, {BackgroundColor3 = colors.Primary}, 0.2) end)
        closeButton.MouseButton1Click:Connect(function() newWindow:Destroy() end)
    end

    if config.Draggable then
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, windowFrame.Position
                windowFrame.ZIndex = 10 -- Sürüklerken üste taşı
                local conn; conn = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; windowFrame.ZIndex = 1; conn:Disconnect() end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                -- Sürükleme sırasında ekranın dönmesini engelleyen şey budur: Mutlak offset kullanmak.
                windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    -- #endregion

    -- #region ANA İÇERİK KONTEYNERİ (SAĞ TARAF)

    -- Sağdaki içerik için ayrılan alanda padding bırakıyoruz (örneğin 10 birim)
    local padding = 10
    local contentContainer = CreateInstance("Frame", { 
        Name = "ContentContainer", Parent = windowFrame, 
        -- Genişlik: Pencere Genişliği - Tab Genişliği - (2 * Padding)
        Size = UDim2.new(1, -config.TabAreaWidth - (2 * padding), 1, -config.HeaderHeight - (2 * padding)),
        -- Konum: Tab Genişliği + Padding, Header Yüksekliği + Padding
        Position = UDim2.new(0, config.TabAreaWidth + padding, 0, config.HeaderHeight + padding), 
        BackgroundTransparency = 1,
        ZIndex = 1
    })
    
    newWindow.Container = contentContainer 

    CreateInstance("UIListLayout", { Parent = contentContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
    
    -- #endregion
    
    -- Klavye kısayolu ile Toggle
    newWindow.InputConnection = UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == config.MinimizeKey then newWindow:Toggle() end end)

    -- Remote Minimize Butonu Ekleme
    if config.MinimizeMobileButton then
        local minimizeButton = CreateInstance("ImageButton", {
            Name = "MinimizeMobileButton", Parent = screenGui, 
            Size = UDim2.fromOffset(40, 40), Position = UDim2.fromScale(1, 0.05) - UDim2.fromOffset(50, 0),
            BackgroundTransparency = 1, Image = "rbxassetid://2526742566",
            ImageColor3 = colors.Accent, ZIndex = 10, ImageTransparency = 1 
        })
        
        minimizeButton.MouseButton1Click:Connect(function()
            newWindow:Toggle()
        end)
        
        newWindow.MinimizeButton = minimizeButton
    end

    -- Açılış animasyonu
    local initialSize = config.Size
    windowFrame.Size = UDim2.fromOffset(0, 0)
    windowFrame.Position = newWindow.InitialPosition + UDim2.fromOffset(initialSize.X.Offset / 2, initialSize.Y.Offset / 2)
    Animate(windowFrame, { Size = initialSize, Position = newWindow.InitialPosition }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    table.insert(Emochi.ActiveWindows, newWindow)
    return newWindow
end

-- Modülü loader'a döndür
return WindowModule
