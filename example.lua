-- Senin GitHub repona göre ayarlanmış doğru link
local Emochi = loadstring(game:HttpGet("https://raw.githubusercontent.com/emirontop1/Ligma/main/loader.lua"))()

-- Kütüphane başarıyla yüklendiyse pencereyi oluştur
if Emochi then
    local Window1 = Emochi.Window:Create({
        Title = "İsim Kısmı", 
        SubTitle ="By Emir | v" .. Emochi.Ver,
        Theme = "Dark", -- "Dark" veya "Light" olabilir
        Size = UDim2.fromOffset(580, 460)
        
        -- KeySystem notu: İstediğin KeySystem mantığını loader.lua'nın en başına,
        -- elementleri yüklemeden önce eklemen daha doğru olur.
    })
end
