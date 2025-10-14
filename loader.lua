-- Emochi UI - Loader (final)
-- Tüm modülleri buradan yönetiyoruz

local BASE_URL = "https://raw.githubusercontent.com/emirontop1/Emochi/main/"
local Emochi = {}

-- Güvenli yükleme fonksiyonu
local function safeLoad(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not success then
        warn("[Emochi Loader] Modül yüklenemedi: " .. path .. " | Hata: " .. tostring(result))
        return nil
    end
    return result
end

-- Window elementini yükle
Emochi.window = safeLoad("elements/window.lua")

-- Buraya gelecekte başka elementleri de ekleyebilirsin
-- Emochi.button = safeLoad("elements/button.lua")
-- Emochi.slider = safeLoad("elements/slider.lua")

-- Son olarak tablomuzu döndürelim
return Emochi
