-- Emochi UI Loader
if shared.Emochi_UI then return shared.Emochi_UI end

-- Ana Emochi tablosunu ve temel bilgileri shared'da oluşturalım.
-- Böylece alt modüller (window.lua gibi) bu tabloya erişebilir.
shared.Emochi_UI = {
    Version = "2.0.0",
    Author = "emirontop1 & Gemini",
    ActiveWindows = {} -- Tüm pencereleri global olarak takip etmek için
}

local Emochi = shared.Emochi_UI

-- Yüklenecek elementlerin listesi
local components = {"window"} -- Gelecekte buraya "button", "slider" gibi elemanlar ekleyebilirsiniz.

for _, name in ipairs(components) do
    local url = "https://raw.githubusercontent.com/emirontop1/Ligma/main/elements/" .. name .. ".lua"
    local success, module = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and module then
        Emochi[name] = module
    else
        warn("Emochi UI: " .. name .. " yüklenemedi! URL: " .. url)
    end
end

return Emochi
