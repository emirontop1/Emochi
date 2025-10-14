-- elements/Window.luau

local Window = {}
Window.__index = Window

-- Window Modülünün Constructor'ı
function Window.new(options)
    local self = setmetatable({}, Window)
    
    self.Title = options.Title or "Default Emochi Window"
    self.Elements = {}
    
    print(string.format("[Window Module] Yeni Pencere Yaratıldı: %s", self.Title))

    return self
end

-- Örnek Sekme Ekleme Fonksiyonu
function Window:AddTab(options)
    print(string.format("[Window] Sekme Ekleme Çağrıldı: %s", options.Title or "Yeni Sekme"))
    
    local Tab = {
        Title = options.Title,
        AddButton = function(btnOptions)
            print(string.format("  -> Buton Eklendi: %s. Geri arama çalışıyor!", btnOptions.Title))
            if btnOptions.Callback then
                btnOptions.Callback()
            end
        end
    }
    table.insert(self.Elements, Tab)
    
    return Tab
end

-- Geriye Modülün Kendisini Döndür
return Window
