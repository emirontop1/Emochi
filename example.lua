-- Emochi UI Kullanım Örneği
local LOADER_URL = "https://raw.githubusercontent.com/emirontop1/Emochi/refs/heads/main/loader.lua"
local Emochi = loadstring(game:HttpGet(LOADER_URL))()

local myWindow = Emochi.window:Create({
    Title = "Yeni Menü",
    Theme = "Dracula",
    Size = UDim2.fromOffset(700, 500),
    MinimizeMobileButton = true, -- Uzaktan küçültme butonu eklendi
    CornerRadius = UDim.new(0, 15) -- Daha da smooth köşeler
})

-- Kontrolleri eskisi gibi myWindow.Container içine eklemeye devam edebilirsiniz
-- Örneğin:
-- local button = Instance.new("TextButton")
-- button.Parent = myWindow.Container
