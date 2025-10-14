-- elements/Tab.luau

local Tab = {}
Tab.__index = Tab

-- Yeni Sekme Nesnesi Oluşturucu
function Tab.new(ParentWindow, options)
    local self = setmetatable({}, Tab)
    
    self.Title = options.Title or "Yeni Sekme"
    self.Icon = options.Icon or "home" -- Sekme butonu için ikon
    self.Parent = ParentWindow
    self.Elements = {} 
    
    -- Sekme Butonunun Durumu
    self.IsActive = false 
    
    print(string.format("[Tab Module] Yeni Sekme Yaratıldı: %s (İkon: %s)", self.Title, self.Icon))

    -- Gerçek kodda, bu noktada hap şeklindeki sekme butonu oluşturulur.
    
    return self
end

-- Sekme Değiştirme Animasyonu
function Tab:SetActive(state)
    self.IsActive = state
    local targetColor = state and self.Parent.ThemeColor or Color3.fromRGB(40, 40, 40) -- Tema rengine geçiş
    
    print(string.format("[Tab] '%s' sekmesi %s yapılıyor. Renk geçişi animasyonu başladı.", 
        self.Title, state and "AKTİF" or "PASİF"))
    
    -- Gerçek kodda: Sekme butonunun arkaplan rengi, pencerenin EasingStyle ve AnimationTime parametreleri kullanılarak yumuşakça değişir.
end

-- Tab İçine Buton Ekleme İşlevi (Sadece Element Eklenir)
function Tab:AddButton(options)
    local Button = {
        Title = options.Title,
        Description = options.Description or "", -- Yeni: Alt metin
        Icon = options.Icon or "mouse-pointer-2",  -- Yeni: Buton yanında küçük ikon
        Callback = options.Callback
    }
    table.insert(self.Elements, Button)
    
    print(string.format("[Tab] Buton Eklendi: %s. Detay: %s", Button.Title, Button.Description))
    
    -- Simülasyon: Geri arama hemen çalışır.
    if Button.Callback then Button.Callback() end
    
    return Button
end

return Tab
