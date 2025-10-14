-- Emochi Loader'ı yükle
local LOADER_URL = "https://raw.githubusercontent.com/emirontop1/Emochi/refs/heads/main/loader.lua"
local Emochi = loadstring(game:HttpGet(LOADER_URL))()

-- Yeni pencere oluştur (tüm özellikler açık)
local myWindow = Emochi.window:Create({
    Title = "Tam Feature Kontrol Paneli",
    SubTitle = "v1.0 - Demo",
    Theme = "Dracula",            -- Temalar: Dark, Light, Dracula
    Size = UDim2.fromOffset(750, 550),
    Draggable = true,              -- Sürüklenebilir
    Closable = true,               -- Kapatılabilir
    MinimizeKey = Enum.KeyCode.RightControl, -- Kısayol ile minimize/restore
    MinimizeMobileButton = true,   -- Mobil / uzak minimize butonu
})

-- Tab alanına buton ekleme
