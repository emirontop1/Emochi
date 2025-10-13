-- Emochi UI Kullanım Örneği
local LOADER_URL = "https://raw.githubusercontent.com/emirontop1/Ligma/main/loader.lua"
local Emochi = loadstring(game:HttpGet(LOADER_URL))()

local myWindow = Emochi.window:Create({
    Title = "Geliştirici Paneli",
    Size = UDim2.fromOffset(650, 500)
})

-- Örnek: Buton eklemek
-- local myButton = Instance.new("TextButton")
-- myButton.Text = "Hile Aktif Et"
-- myButton.Size = UDim2.fromOffset(200, 50)
-- myButton.Parent = myWindow.Container
