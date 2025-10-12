-- Senin GitHub repona göre ayarlanmış doğru link
local Emochi = loadstring(game:HttpGet("https://raw.githubusercontent.com/emirontop1/Ligma/main/loader.lua"))()

-- Kütüphane başarıyla yüklendiyse pencereyi oluştur
if Emochi then
    local MyWindow = Emochi:Create({
        Title = "Geliştirici Paneli",
        SubTitle = "Versiyon Beta 1.2",
        
        -- Pencerenin başlangıç boyutu
        Size = UDim2.fromOffset(650, 500),
        
        -- Kullanılacak tema
        Theme = "Dark",
        
        -- Saydamlık ayarı (0 = Opak, 1 = Tamamen Şeffaf)
        Opacity = 0.15, 
        
        -- Opsiyonel: Pencereyi açıp kapatmak için tuş sistemi
        -- Bu örnekte F2 tuşu ayarlanmıştır. Tuş atanmazsa pencere varsayılan olarak açık başlar.
        KeyCode = Enum.KeyCode.F2 
    })

end
