-- Example.luau
-- loader.luau dosyasının RAW URL'si (Bu, ana yükleme noktasıdır)
local LOADER_URL = "https://raw.githubusercontent.com/emirontop1/Emochi/main/loader.luau" 

-- loader.luau'yu dinamik olarak yükle ve çalıştır.
-- Bu tek satır, hem loader.luau'yu hem de onun içinden elements/Window.luau'yu yükler.
local Emochi = loadstring(game:HttpGet(LOADER_URL, true))() 

print("--- Kütüphane Yüklendi ve Kullanıma Hazır (Emochi) ---")

-- Kütüphane Kullanımı
local MyWindow = Emochi:CreateWindow({
    Title = "Birleştirilmiş Emochi Kütüphanesi",
})

local Tab1 = MyWindow:AddTab({
    Title = "Yeni Sekme",
})

Tab1:AddButton({
    Title = "Fonksiyonu Çalıştır",
    Callback = function()
        print("-> İşlem Tamamlandı! Tüm modüller doğru birleşti.")
    end
})
