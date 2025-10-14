--[[
    Emochi UI - Window Modülü (Modern Fluent Tasarıma Güncellenmiş Versiyon)
    Amaç: İlk koddaki basit yapıyı koruyarak, Fluent UI'dan ilham alan modern bir
    görünüm (sol tab bar, smooth köşeler) kazandırmak.
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
        -- Daha koyu, modern arka plan ve yumuşak Primary (Başlık Çubuğu)
        Background = Color3.fromRGB(20, 20, 25), 
        Primary = Color3.fromRGB(30, 30, 38), 
        -- Sekme Alanı/Sol bar için farklı bir ton (Fluent tarzı)
        Secondary = Color3.fromRGB(30, 30, 38), 
        Accent = Color3.fromRGB(0, 120, 212), -- Modern Mavi
        Text = Color3.fromRGB(240, 240, 240), SubText = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(15, 15, 20), Shadow = Color3.fromRGB(0, 0, 0)
    },
    -- Diğer temalar aynı kalır
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
    
    Animate(self.Instance, {Position = goalPosition}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    for _, child in ipairs(self.Instance:GetDescendants()) do
        if child:IsA("GuiObject") then
            local isShadow = (child.Name == "Shadow")
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                Animate(child, {TextTransparency = goalTransparency}, 0.3)
                if not isShadow then Animate(child, {BackgroundTransparency = goalTransparency}, 0.3) end
            elseif child:IsA("ImageLabel") and not isShadow then
                Animate(child, {ImageTransparency = goalTransparency}, 0.3)
            elseif not (child:IsA("UIComponent") or isShadow) then
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
        Size = options.Size or UDim2.fromOffset(650, 450), -- Biraz büyüdü
        Theme = options.Theme or "Dark",
        Draggable = options.Draggable ~= nil and options.Draggable or true,
        Closable = options.Closable ~= nil and options.Closable or true,
        MinimizeKey = options.MinimizeKey or Enum.KeyCode.RightControl,
        InitialPosition = options.InitialPosition,
        ShadowEnabled = options.ShadowEnabled ~= nil and options.ShadowEnabled or true,
        BlurIntensity = options.BlurIntensity or 0,
        CornerRadius = options.CornerRadius or UDim.new(0, 12), -- Daha belirgin smooth köşe
        HeaderHeight = options.HeaderHeight or 36, -- Daha ince başlık çubuğu
        MinimizeMobileButton = options.MinimizeMobileButton ~= nil and options.MinimizeMobileButton or false, 
        TabAreaWidth = options.TabAreaWidth or 160 -- Sekme alanı dikey olduğu için genişlik
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
        BackgroundColor3 = colors.Background, BorderSizePixel = 0, ClipsDescendants = true
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
        Size = UDim2.new(0, config.TabAreaWidth, 1, -config.HeaderHeight), -- Başlık çubuğu yüksekliği düşüldü
        Position = UDim2.new(0, 0, 0, config.HeaderHeight), 
        BackgroundColor3 = colors.Secondary, BorderSizePixel = 0, ZIndex = 2,
        ClipsDescendants = true
    })

    -- Sol Tab Alanı İçin Köşeler (Alt-Sol Köşe: Smooth)
    -- Üst sol köşe Başlık Çubuğu tarafından kontrol edilir.
    CreateInstance("UICorner", { CornerRadius = config.CornerRadius, Parent = tabContainer })
    
    -- Tab Düğmelerinin Yerleşimi (İleride buraya eklenecek)
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

    newWindow.TabContainer = tabButtonHolder -- Tab butonları buraya eklenecek

    -- #endregion

    -- #region BAŞLIK ÇUBUĞU (HEADER)
    
    local header = CreateInstance("Frame", { 
        Name = "Header", Parent = windowFrame, 
        Size = UDim2.new(1, 0, 0, config.HeaderHeight), 
        BackgroundColor3 = colors.Primary, BorderSizePixel = 0 
    })
    
    -- Başlık Çubuğu Köşeleri (Üst-Sol ve Üst-Sağ)
    CreateInstance("UICorner", { CornerRadius = config.CornerRadius, Parent = header })

    local titleLabel = CreateInstance("TextLabel", { 
        Name = "Title", Parent = header, 
        Size = UDim2.new(1, -config.TabAreaWidth, 1, 0), -- Sağ içeriğin genişliği
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
            BackgroundColor3 = colors.Primary, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = colors.Text 
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
                -- Hızlı sürükleme için Instant/Spring yerine doğrudan atama yapılıyor,
                -- ancak bu kod yapısında 'Instant' motora gerek kalmaz, direkt atama yaparız
                windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    -- #endregion

    -- #region ANA İÇERİK KONTEYNERİ (SAĞ TARAF)

    local contentContainer = CreateInstance("Frame", { 
        Name = "ContentContainer", Parent = windowFrame, 
        Size = UDim2.new(1, -config.TabAreaWidth - 20, 1, -config.HeaderHeight - 20), -- Genişlik ve Yükseklik hesaplandı
        Position = UDim2.new(0, config.TabAreaWidth + 10, 0, config.HeaderHeight + 10), -- Konum Sol bar ve Başlık altı
        BackgroundTransparency = 1 
    })
    
    newWindow.Container = contentContainer -- Kontrollerin ekleneceği kısım

    CreateInstance("UIListLayout", { Parent = contentContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) }) -- Daha geniş padding
    
    -- #endregion
    
    -- Klavye kısayolu ile Toggle
    newWindow.InputConnection = UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == config.MinimizeKey then newWindow:Toggle() end end)

    -- Remote Minimize Butonu Ekleme
    if config.MinimizeMobileButton then
        local minimizeButton = CreateInstance("ImageButton", {
            Name = "MinimizeMobileButton", Parent = screenGui, 
            Size = UDim2.fromOffset(40, 40), Position = UDim2.fromScale(1, 0.05) - UDim2.fromOffset(50, 0),
            BackgroundTransparency = 1, Image = "rbxassetid://2526742566", -- Örnek ikon (Dişli)
            ImageColor3 = colors.Accent, ZIndex = 10, ImageTransparency = 1 -- Başlangıçta gizli
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
