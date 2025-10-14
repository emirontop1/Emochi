-- elements/Window.luau

local Window = {}
Window.__index = Window

local AddTabFunction = nil

-- Enum'ları (sabit değerleri) simüle edelim
local EasingStyle = { Quad = "Quad", Cubic = "Cubic", Sine = "Sine" }
local Direction = { In = "In", Out = "Out", InOut = "InOut" }

function Window.Inject(functions)
    AddTabFunction = functions.AddTab 
    print("[Window Module] Bağımlılıklar başarıyla enjekte edildi.")
end

function Window.new(options)
    local self = setmetatable({}, Window)
    
    -- *** GÜZEL GUI ÖZELLİKLERİ VE PARAMETRELERİ ***
    self.Title = options.Title or "Emochi Fluent UI"
    self.SubTitle = options.SubTitle or "" 
    self.Icon = options.Icon or "settings-2" -- Lucide Icons (örnek olarak bir isim)
    
    -- STİL VE GÖRÜNÜM PARAMETRELERİ
    self.Size = options.Size or UDim2.fromOffset(750, 500)
    self.ThemeColor = options.ThemeColor or Color3.fromRGB(80, 100, 255) -- Ana Renk
    self.Acrylic = options.Acrylic or false -- Akrilik (Blur) efekt aktif mi?
    self.MinimizeKey = options.MinimizeKey or "RightControl" -- Kısayol Tuşu
    
    -- ANİMASYON PARAMETRELERİ
    self.AnimationTime = options.AnimationTime or 0.3 -- Animasyon süresi (saniye)
    self.EasingStyle = EasingStyle[options.EasingStyle] or EasingStyle.Quad
    self.EasingDirection = Direction[options.EasingDirection] or Direction.Out
    
    self.IsMinimized = false
    self.Tabs = {}

    print(string.format("[Window Module] '%s' Başlatıldı. Stil: Tema Rengi(%s), Easing(%s)", 
        self.Title, self.ThemeColor, self.EasingStyle))
    
    -- Gerçek kodda, bu noktada pencere UI'ı yukarıdaki parametrelerle oluşturulur.
    
    return self
end

-- Animasyonlu Minimize İşlevi
function Window:Minimize()
    self.IsMinimized = not self.IsMinimized 
    local targetPosition = self.IsMinimized and UDim2.fromScale(1.5, 0) or UDim2.fromScale(0.5, 0.5) -- Örnek pozisyonlar
    
    print(string.format("[Window] Minimization animasyonu başlatıldı. Süre: %.1fs, Stil: %s", 
        self.AnimationTime, self.EasingStyle))
    
    -- Gerçek kodda: game:GetService("TweenService"):Create(self.Frame, TweenInfo.new(self.AnimationTime, self.EasingStyle), {Position = targetPosition}):Play()
end

function Window:AddTab(options)
    if not AddTabFunction then error("AddTab fonksiyonu enjekte edilmedi.") end
    local newTab = AddTabFunction(self, options) 
    table.insert(self.Tabs, newTab)
    return newTab
end

return Window
