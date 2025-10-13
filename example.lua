local Emochi = loadstring(game:HttpGet("https://raw.githubusercontent.com/emirontop1/Ligma/main/loader.lua"))()

-- Kütüphane başarıyla yüklendiyse pencereyi oluştur
if Emochi and Emochi.window then -- Emochi'nin ve 'window' elementinin yüklendiğinden emin olalım

    -- Düzeltme: Window objesine Emochi tablosu üzerinden, yani Emochi.window aracılığıyla erişmeliyiz.
    local WindowCreator = Emochi.window 
    
    local MyWindow = WindowCreator:Create({ 
        Title = "Geliştirici Paneli",
        SubTitle = "Versiyon Beta 1.2",
        
        -- Pencerenin başlangıç boyutu
        Size = UDim2.fromOffset(650, 500),
        
        -- Kullanılacak tema
        Theme = "Dark",
        
        -- Saydamlık ayarı (0 = Opak, 1 = Tamamen Şeffaf)
        Opacity = 0.15, 
        
        -- Opsiyonel: Pencereyi açıp kapatmak için tuş sistemi
        Key = Enum.KeyCode.F2 -- Kodunuzdaki KeyCode anahtarını, Window.lua'daki Key'e göre ayarladım.
    })

end
